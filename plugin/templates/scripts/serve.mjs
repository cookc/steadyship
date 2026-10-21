// Steadyship serve script: opens one app through a small local web server so it
// can read and write its master file on the shared drive. One app, one master
// file, one writer. No dependencies beyond Node.
//
// Usage: node scripts/serve.mjs <app> [--port 8787] [--shared-drive PATH] [--share]
//   <app>           folder name under apps/
//   --port          port to listen on (default 8787)
//   --shared-drive  where the business's files live (default: the Shared drive line in steadyship.md)
//   --share         let other computers on the office network open it (default: this computer only)
//
// The app says which files it uses in apps/<app>/data.json:
//   { "master": "Jobs.csv", "reads": ["Customers.csv"] }
// Paths are relative to the shared drive. Only the master can be written.
//
// The app talks to:
//   GET  /api/config                   { timeZone, currency } from steadyship.md and docs/context/engineering.md
//   GET  /api/file/<name>              the file's text (UTF-8, no byte-order mark), with an ETag header
//   PUT  /api/file/<name>              new text; needs If-Match: <ETag from the GET>; master only
// Errors come back as JSON { "error": "plain words" } with these statuses:
//   404 not a file this app uses   412 changed by someone else since you read it   423 open in Excel
//   428 no If-Match given          503 shared drive not reachable
// Writes go to a file beside the master, then rename over it, so a write never half-completes.
// A CSV that had a byte-order mark keeps it (Excel reads it right); a new CSV gets one.

import { createServer } from 'node:http';
import { promises as fs, existsSync, readFileSync } from 'node:fs';
import { createHash } from 'node:crypto';
import { resolve, join, normalize, sep, extname, dirname } from 'node:path';
import { fileURLToPath } from 'node:url';
import { spawn } from 'node:child_process';
import { networkInterfaces } from 'node:os';

const ROOT = resolve(dirname(fileURLToPath(import.meta.url)), '..');
const args = process.argv.slice(2);
const flag = (name, dflt) => {
  const i = args.indexOf(name);
  return i >= 0 && args[i + 1] !== undefined ? args[i + 1] : dflt;
};
const VALUE_FLAGS = ['--port', '--shared-drive'];
let APP;
for (let i = 0; i < args.length; i++) {
  if (VALUE_FLAGS.includes(args[i])) {
    i++;
    continue;
  }
  if (!args[i].startsWith('--')) {
    APP = args[i];
    break;
  }
}
const PORT = Number(flag('--port', 8787));
const SHARE = args.includes('--share');

function die(msg) {
  console.error(msg);
  process.exit(1);
}
if (!APP) die('Which app? Usage: node scripts/serve.mjs <app-folder-name>');
const APP_DIR = join(ROOT, 'apps', APP);
if (!existsSync(join(APP_DIR, 'index.html'))) die(`No app at apps/${APP}/index.html`);

function sharedDriveFromSteadyshipMd() {
  try {
    const md = readFileSync(join(ROOT, 'steadyship.md'), 'utf8');
    const m = md.match(/^Shared drive:\s*(.+?)\s*$/m);
    if (!m || m[1] === 'none') return null;
    let p = m[1];
    if (p.startsWith('~')) p = join(process.env.HOME || process.env.USERPROFILE || '', p.slice(1));
    return resolve(ROOT, p);
  } catch {
    return null;
  }
}

const DRIVE = flag('--shared-drive', null) ? resolve(flag('--shared-drive')) : sharedDriveFromSteadyshipMd();
if (!DRIVE) die('No shared drive: add a "Shared drive:" line to steadyship.md or pass --shared-drive PATH');

let manifest;
try {
  manifest = JSON.parse(readFileSync(join(APP_DIR, 'data.json'), 'utf8'));
} catch {
  die(`apps/${APP}/data.json is missing or not valid JSON. It should look like {"master": "Jobs.csv", "reads": []}`);
}
if (typeof manifest.master !== 'string' || !manifest.master) die(`apps/${APP}/data.json needs a "master" file name`);
const READS = Array.isArray(manifest.reads) ? manifest.reads.filter((r) => typeof r === 'string') : [];
const ALLOWED = new Map([[manifest.master, 'write'], ...READS.map((r) => [r, 'read'])]);

function safeDrivePath(name) {
  // name is the manifest's own string; reject anything that could leave the drive
  if (!ALLOWED.has(name)) return null;
  const p = normalize(join(DRIVE, name));
  if (!p.startsWith(DRIVE + sep) && p !== DRIVE) return null;
  return p;
}
const BOM = '\uFEFF';
function businessConfig() {
  const out = { app: APP, timeZone: null, currency: null };
  try {
    const md = readFileSync(join(ROOT, 'steadyship.md'), 'utf8');
    const tz = md.match(/^Time zone:\s*(.+?)\s*$/m);
    if (tz && /^[A-Za-z]+\/[A-Za-z_\/+-]+$/.test(tz[1])) out.timeZone = tz[1];
  } catch {}
  try {
    const eng = readFileSync(join(ROOT, 'docs', 'context', 'engineering.md'), 'utf8');
    const tz = eng.match(/^\|\s*Time zone\s*\|\s*([A-Za-z]+\/[A-Za-z_\/+-]+)\s*\|/m);
    if (tz) out.timeZone = tz[1];
    const cur = eng.match(/^\|\s*Currency\s*\|\s*([A-Z]{3})\b/m);
    if (cur) out.currency = cur[1];
  } catch {}
  return out;
}
const etagOf = (text) => '"' + createHash('sha256').update(text).digest('hex').slice(0, 32) + '"';
const hadBom = new Map(); // file name -> whether the last read had a byte-order mark

function json(res, status, body) {
  res.writeHead(status, { 'Content-Type': 'application/json; charset=utf-8', 'Cache-Control': 'no-store' });
  res.end(JSON.stringify(body));
}
async function driveReachable() {
  try {
    await fs.access(DRIVE);
    return true;
  } catch {
    return false;
  }
}
function excelLockPath(p) {
  return join(dirname(p), '~$' + p.slice(dirname(p).length + 1));
}

async function getFile(name, res) {
  const p = safeDrivePath(name);
  if (!p)
    return json(res, 404, {
      error: `This app does not use a file called ${name}. Its files are listed in apps/${APP}/data.json.`,
    });
  if (!(await driveReachable()))
    return json(res, 503, {
      error: `The shared drive is not reachable from this computer right now (${DRIVE}). Check the network and try again; nothing has been lost.`,
    });
  let text;
  try {
    text = await fs.readFile(p, 'utf8');
  } catch (e) {
    if (e.code === 'ENOENT') return json(res, 404, { error: `${name} is not on the shared drive at ${DRIVE}.` });
    return json(res, 500, { error: `Could not read ${name}: ${e.message}` });
  }
  const bom = text.startsWith(BOM);
  hadBom.set(name, bom);
  if (bom) text = text.slice(1);
  res.writeHead(200, {
    'Content-Type': (extname(p).toLowerCase() === '.csv' ? 'text/csv' : 'text/plain') + '; charset=utf-8',
    ETag: etagOf(text),
    'Cache-Control': 'no-store',
    'X-Steadyship-Writable': ALLOWED.get(name) === 'write' ? 'yes' : 'no',
  });
  res.end(text);
}

let writeChain = Promise.resolve(); // one writer: writes happen one after another
async function putFile(name, req, res) {
  const p = safeDrivePath(name);
  if (!p) return json(res, 404, { error: `This app does not use a file called ${name}.` });
  if (ALLOWED.get(name) !== 'write')
    return json(res, 405, { error: `${name} is read-only for this app; only ${manifest.master} can be changed here.` });
  const ifMatch = req.headers['if-match'];
  if (!ifMatch)
    return json(res, 428, {
      error:
        'The app did not say which version of the file it read (no If-Match header). This is a bug in the app, not a problem with the file.',
    });
  const chunks = [];
  for await (const c of req) chunks.push(c);
  let body = Buffer.concat(chunks).toString('utf8');
  if (body.startsWith(BOM)) body = body.slice(1);
  const run = async () => {
    if (!(await driveReachable()))
      return json(res, 503, {
        error: `The shared drive is not reachable from this computer right now (${DRIVE}). Your changes are still on screen; try again when it is back.`,
      });
    if (existsSync(excelLockPath(p)))
      return json(res, 423, {
        error: `${name} is open in Excel on this or another computer. Close it there, then try again; your changes are still on screen.`,
      });
    let current = '';
    try {
      current = await fs.readFile(p, 'utf8');
      if (current.startsWith(BOM)) current = current.slice(1);
    } catch (e) {
      if (e.code !== 'ENOENT') return json(res, 500, { error: `Could not read ${name} before writing: ${e.message}` });
    }
    if (etagOf(current) !== ifMatch)
      return json(res, 412, {
        error: `${name} has been changed by someone else since this screen was opened. Reload to see the latest, then make your change again.`,
      });
    const withBom = (hadBom.get(name) ?? extname(p).toLowerCase() === '.csv') ? BOM + body : body;
    const tmp = p + '.steadyship-writing';
    try {
      await fs.writeFile(tmp, withBom, 'utf8');
      await fs.rename(tmp, p);
    } catch (e) {
      try {
        await fs.unlink(tmp);
      } catch {}
      if (e.code === 'EBUSY' || e.code === 'EPERM' || e.code === 'EACCES')
        return json(res, 423, {
          error: `${name} is locked (probably open in Excel somewhere). Close it, then try again; your changes are still on screen.`,
        });
      return json(res, 500, { error: `Could not write ${name}: ${e.message}. Your changes are still on screen.` });
    }
    res.writeHead(200, { ETag: etagOf(body), 'Content-Type': 'application/json; charset=utf-8' });
    res.end(JSON.stringify({ ok: true }));
  };
  writeChain = writeChain.then(run, run);
  return writeChain;
}

const TYPES = {
  '.html': 'text/html; charset=utf-8',
  '.js': 'text/javascript; charset=utf-8',
  '.mjs': 'text/javascript; charset=utf-8',
  '.css': 'text/css; charset=utf-8',
  '.json': 'application/json; charset=utf-8',
  '.svg': 'image/svg+xml',
  '.png': 'image/png',
  '.jpg': 'image/jpeg',
  '.ico': 'image/x-icon',
  '.woff2': 'font/woff2',
  '.csv': 'text/csv; charset=utf-8',
  '.md': 'text/plain; charset=utf-8',
};
async function serveStatic(urlPath, res) {
  // Only this app's folder and the shared lib/ folder are served; nothing else in the repository.
  const rel = decodeURIComponent(urlPath.split('?')[0]);
  const allowedPrefixes = [`/apps/${APP}/`, '/lib/'];
  if (!allowedPrefixes.some((pre) => rel.startsWith(pre))) {
    res.writeHead(404, { 'Content-Type': 'text/plain' });
    return res.end('Not found');
  }
  let p = normalize(join(ROOT, rel));
  if (!p.startsWith(join(ROOT, 'apps', APP) + sep) && !p.startsWith(join(ROOT, 'lib') + sep)) {
    res.writeHead(404);
    return res.end('Not found');
  }
  if (rel.endsWith('/')) p = join(p, 'index.html');
  try {
    const data = await fs.readFile(p);
    res.writeHead(200, {
      'Content-Type': TYPES[extname(p).toLowerCase()] || 'application/octet-stream',
      'Cache-Control': 'no-store',
    });
    res.end(data);
  } catch {
    res.writeHead(404, { 'Content-Type': 'text/plain' });
    res.end('Not found');
  }
}

const server = createServer(async (req, res) => {
  try {
    const url = req.url || '/';
    if (url === '/' || url === `/apps/${APP}`) {
      res.writeHead(302, { Location: `/apps/${APP}/` });
      return res.end();
    }
    if (url === '/api/config') return json(res, 200, businessConfig());
    const api = url.match(/^\/api\/file\/([^/?]+)$/);
    if (api) {
      const name = decodeURIComponent(api[1]);
      if (req.method === 'GET') return await getFile(name, res);
      if (req.method === 'PUT') return await putFile(name, req, res);
      return json(res, 405, { error: 'Only GET and PUT are supported here.' });
    }
    if (req.method !== 'GET' && req.method !== 'HEAD') return json(res, 405, { error: 'Only GET is supported here.' });
    return await serveStatic(url, res);
  } catch (e) {
    return json(res, 500, { error: `Something went wrong in the serve script: ${e.message}` });
  }
});

const HOST = SHARE ? '0.0.0.0' : '127.0.0.1';
server.on('error', (e) => {
  if (e.code === 'EADDRINUSE')
    die(`Port ${PORT} is already in use. Is the app already open? Close that window, or run with --port ${PORT + 1}.`);
  die(`Could not start: ${e.message}`);
});
server.listen(PORT, HOST, () => {
  const url = `http://localhost:${PORT}/apps/${APP}/`;
  console.log(`Serving apps/${APP} with its data on ${DRIVE}`);
  console.log(`Open: ${url}`);
  if (SHARE) {
    for (const list of Object.values(networkInterfaces()))
      for (const n of list || [])
        if (n.family === 'IPv4' && !n.internal)
          console.log(`Others on the office network: http://${n.address}:${PORT}/apps/${APP}/`);
  }
  console.log('Leave this window open while the app is in use. Close it to stop.');
  if (!args.includes('--no-open')) {
    const opener =
      process.platform === 'win32'
        ? ['cmd', ['/c', 'start', '', url]]
        : process.platform === 'darwin'
          ? ['open', [url]]
          : ['xdg-open', [url]];
    try {
      spawn(opener[0], opener[1], { stdio: 'ignore', detached: true })
        .on('error', () => {})
        .unref();
    } catch {}
  }
});
