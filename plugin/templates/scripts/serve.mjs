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
//   400 nothing to save              422 saved in a form that cannot be read as text
// Writes go to a file beside the master, then rename over it, so a write never half-completes.
// A CSV that had a byte-order mark keeps it (Excel reads it right); a new CSV gets one.
// Two computers can each run this script on the same master: a lock file beside the master
// (<master>.steadyship-lock) makes "check the version, then write" one step across all of them.
// Before a write, the master as it was is copied into steadyship-backups/ beside it: once a day
// ("<name> <date> start of day"), kept 60 days, and "<name> before last change" every time.
// A master Excel saved as plain "CSV" (Windows-1252, not UTF-8) is read correctly and is saved
// back as UTF-8 with a byte-order mark, which Excel also reads correctly; nothing turns into "?".
//
// node scripts/serve.mjs --self-test   checks the path rules for Windows and Mac/Linux paths, then exits.

import { createServer } from 'node:http';
import { promises as fs, existsSync, readFileSync } from 'node:fs';
import { createHash, randomBytes } from 'node:crypto';
import * as path from 'node:path';
import { resolve, join, normalize, extname, dirname, basename } from 'node:path';
import { fileURLToPath } from 'node:url';
import { spawn } from 'node:child_process';
import { networkInterfaces, hostname } from 'node:os';

// ---- Path rules, written against a path module so they can be checked for Windows on any computer ----
/** Is p strictly inside base? Works when base is a drive root (Z:\) or a share root (\\nas\share). */
function insideDir(P, base, p) {
  const rel = P.relative(base, p);
  return rel !== '' && rel !== '..' && !rel.startsWith('..' + P.sep) && !P.isAbsolute(rel);
}
/** The lock file Excel leaves beside a workbook it has open. */
function excelLockFor(P, p) {
  return P.join(P.dirname(p), '~$' + P.basename(p));
}
if (process.argv[2] === '--self-test') {
  const W = path.win32;
  const X = path.posix;
  const want = (ok, what) => {
    if (!ok) {
      console.error(`serve self-test FAILED: ${what}`);
      process.exit(1);
    }
  };
  for (const root of ['Z:\\', 'Z:\\Shared', '\\\\nas\\share', '\\\\nas\\share\\office']) {
    const base = W.resolve(root);
    want(insideDir(W, base, W.normalize(W.join(base, 'Jobs.csv'))), `a file in ${root} is inside it`);
    if (W.dirname(base) !== base && W.dirname(base) !== base + W.sep)
      want(!insideDir(W, base, W.normalize(W.join(base, '..', 'Jobs.csv'))), `.. leaves ${root}`);
    want(!insideDir(W, base, 'C:\\Windows\\win.ini'), `another drive is outside ${root}`);
    want(
      excelLockFor(W, W.join(base, 'Jobs.csv')) === W.join(base, '~$Jobs.csv'),
      `Excel lock name beside a file in ${root}`,
    );
  }
  for (const root of ['/', '/srv/drive']) {
    want(insideDir(X, root, X.normalize(X.join(root, 'Jobs.csv'))), `a file in ${root} is inside it`);
    want(!insideDir(X, '/srv/drive', '/srv/drive2/Jobs.csv'), 'a sibling folder is outside');
    want(!insideDir(X, '/srv/drive', '/srv/drive'), 'the folder itself is not a file in it');
    want(excelLockFor(X, X.join(root, 'Jobs.csv')) === X.join(root, '~$Jobs.csv'), `Excel lock name in ${root}`);
  }
  want(insideDir(X, '/srv/drive', '/srv/drive/..notes.csv'), 'a name that starts with two dots is still inside');
  console.log('serve self-test: OK');
  process.exit(0);
}

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
  if (!insideDir(path, DRIVE, p)) return null;
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
/** Bytes from the drive to text. UTF-8 (with or without a byte-order mark) is the normal case; a file
 * Excel saved as plain "CSV" is Windows-1252, where every byte is a character, so it never fails and
 * never loses anything. UTF-16 ("Unicode Text" in Excel) is refused in plain words.
 * @param {Buffer} buf @returns {{ text: string, bom: boolean, encoding: string } | { unreadable: string }} */
function decode(buf) {
  if ((buf[0] === 0xff && buf[1] === 0xfe) || (buf[0] === 0xfe && buf[1] === 0xff))
    return { unreadable: 'It was saved as "Unicode Text". In Excel, use Save As and choose "CSV UTF-8".' };
  const bom = buf[0] === 0xef && buf[1] === 0xbb && buf[2] === 0xbf;
  const body = bom ? buf.subarray(3) : buf;
  try {
    return { text: new TextDecoder('utf-8', { fatal: true }).decode(body), bom, encoding: 'utf-8' };
  } catch {
    return { text: new TextDecoder('windows-1252').decode(body), bom: false, encoding: 'windows-1252' };
  }
}
const sleep = (ms) => new Promise((r) => setTimeout(r, ms));
// How long a save waits for another computer's save, and how long a lock must sit unchanged before it is
// taken to be left over from a crash. The environment variables exist for the tests.
const LOCK_WAIT_MS = Number(process.env.STEADYSHIP_LOCK_WAIT_MS) || 8000;
const LOCK_STALE_MS = Number(process.env.STEADYSHIP_LOCK_STALE_MS) || 30000;
const lockSeen = new Map(); // lock path -> { content, since }: how long this process has watched the same lock
/** Runs fn while holding <master>.steadyship-lock, made with "create only if absent", which is one step
 * even on a network drive. Returns { busy: true } if another computer holds it for longer than a save takes.
 * A lock left by a computer that crashed is taken over once this process has seen it unchanged for 30 seconds
 * (by this computer's own clock, so clocks that disagree do not matter). */
async function withLock(p, fn) {
  const lock = p + '.steadyship-lock';
  const deadline = Date.now() + LOCK_WAIT_MS;
  for (;;) {
    try {
      const h = await fs.open(lock, 'wx');
      await h.writeFile(`${hostname()} ${process.pid} ${randomBytes(6).toString('hex')}\n`);
      await h.close();
      lockSeen.delete(lock);
      break;
    } catch (e) {
      if (e.code !== 'EEXIST') throw e;
      let content = null;
      try {
        content = await fs.readFile(lock, 'utf8');
      } catch {}
      if (content !== null) {
        const seen = lockSeen.get(lock);
        if (!seen || seen.content !== content) lockSeen.set(lock, { content, since: Date.now() });
        else if (Date.now() - seen.since > LOCK_STALE_MS) {
          await fs.unlink(lock).catch(() => {});
          lockSeen.delete(lock);
          continue;
        }
      }
      if (Date.now() > deadline) return { busy: true };
      await sleep(40 + Math.random() * 80);
    }
  }
  try {
    return { value: await fn() };
  } finally {
    await fs.unlink(lock).catch(() => {});
  }
}
const BACKUP_DIR = 'steadyship-backups';
const KEEP_DAYS = 60;
const localDate = (d) =>
  `${d.getFullYear()}-${String(d.getMonth() + 1).padStart(2, '0')}-${String(d.getDate()).padStart(2, '0')}`;
/** Copies the master as it is now (byte for byte) before it is replaced. Throws if no copy for today exists
 * afterwards: a save with no way back is refused. */
async function keepCopy(p) {
  const dir = join(dirname(p), BACKUP_DIR);
  const ext = extname(p);
  const stem = basename(p, ext);
  await fs.mkdir(dir, { recursive: true });
  const daily = join(dir, `${stem} ${localDate(new Date())} start of day${ext}`);
  try {
    await fs.copyFile(p, daily, fs.constants.COPYFILE_EXCL);
  } catch (e) {
    if (e.code !== 'EEXIST') throw e;
  }
  await fs.copyFile(p, join(dir, `${stem} before last change${ext}`)).catch(() => {}); // open in Excel: the daily copy still stands
  const cutoff = localDate(new Date(Date.now() - KEEP_DAYS * 86400000));
  for (const f of await fs.readdir(dir).catch(() => [])) {
    const m = f.startsWith(stem + ' ') && f.slice(stem.length + 1).match(/^(\d{4}-\d{2}-\d{2}) start of day/);
    if (m && m[1] < cutoff) await fs.unlink(join(dir, f)).catch(() => {});
  }
}

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
const excelLockPath = (p) => excelLockFor(path, p);

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
  let read;
  try {
    read = decode(await fs.readFile(p));
  } catch (e) {
    if (e.code === 'ENOENT') return json(res, 404, { error: `${name} is not on the shared drive at ${DRIVE}.` });
    return json(res, 500, { error: `Could not read ${name}: ${e.message}` });
  }
  if ('unreadable' in read) return json(res, 422, { error: `${name} cannot be read as text. ${read.unreadable}` });
  const text = read.text;
  res.writeHead(200, {
    'Content-Type': (extname(p).toLowerCase() === '.csv' ? 'text/csv' : 'text/plain') + '; charset=utf-8',
    ETag: etagOf(text),
    'Cache-Control': 'no-store',
    'X-Steadyship-Writable': ALLOWED.get(name) === 'write' ? 'yes' : 'no',
    'X-Steadyship-Encoding': read.encoding,
  });
  res.end(text);
}

let writeChain = Promise.resolve(); // writes from this computer happen one after another; withLock covers other computers
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
  if (body.trim() === '')
    return json(res, 400, {
      error: `The app tried to save ${name} with nothing in it, so nothing was saved. This is a bug in the app, not a problem with the file.`,
    });
  const locked = async () => {
    if (existsSync(excelLockPath(p)))
      return json(res, 423, {
        error: `${name} is open in Excel on this or another computer. Close it there, then try again; your changes are still on screen.`,
      });
    let current = '';
    let before = null; // the master as it is now; null when it does not exist yet
    try {
      before = decode(await fs.readFile(p));
      if ('unreadable' in before)
        return json(res, 422, { error: `${name} cannot be read as text. ${before.unreadable}` });
      current = before.text;
    } catch (e) {
      if (e.code !== 'ENOENT') return json(res, 500, { error: `Could not read ${name} before writing: ${e.message}` });
    }
    if (etagOf(current) !== ifMatch)
      return json(res, 412, {
        error: `${name} has been changed by someone else since this screen was opened. Reload to see the latest, then make your change again.`,
      });
    if (before) {
      try {
        await keepCopy(p);
      } catch (e) {
        return json(res, 500, {
          error: `Could not keep a safety copy of ${name} in ${BACKUP_DIR} (${e.message}), so nothing was saved. Your changes are still on screen.`,
        });
      }
    }
    // Keep a byte-order mark the file had; a new CSV, or one that was not UTF-8, gets one so Excel reads it right.
    const isCsv = extname(p).toLowerCase() === '.csv';
    const withBom = (before ? before.bom || (before.encoding !== 'utf-8' && isCsv) : isCsv) ? BOM + body : body;
    const tmp = `${p}.steadyship-writing-${process.pid}-${randomBytes(4).toString('hex')}`;
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
  const run = async () => {
    if (!(await driveReachable()))
      return json(res, 503, {
        error: `The shared drive is not reachable from this computer right now (${DRIVE}). Your changes are still on screen; try again when it is back.`,
      });
    let held;
    try {
      held = await withLock(p, locked);
    } catch (e) {
      return json(res, 500, { error: `Could not write ${name}: ${e.message}. Your changes are still on screen.` });
    }
    if (held.busy)
      return json(res, 423, {
        error: `Another computer is saving ${name} right now. Wait half a minute, then try again; your changes are still on screen.`,
      });
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
  const p = normalize(join(ROOT, rel.endsWith('/') ? rel + 'index.html' : rel));
  if (!insideDir(path, join(ROOT, 'apps', APP), p) && !insideDir(path, join(ROOT, 'lib'), p)) {
    res.writeHead(404);
    return res.end('Not found');
  }
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
