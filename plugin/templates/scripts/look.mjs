// Steadyship look script: opens one app in a real browser with real inputs and
// saves a picture of it, so the engineer can look at what the page shows (a
// drawing, a layout, a produced thing) instead of judging it from numbers.
//
// Usage: node scripts/look.mjs <app> <out.png> [--pick "<selector>=<file>[,<file>]"]... [--click "<selector>"]... [--wait 3000] [--port 8797]
//   <app>      folder name under apps/
//   <out.png>  where the full-page picture goes (test-results/ is a good place; it is not committed)
//   --pick     set a file input to one or more files, repeatable (for example --pick "#files=Z:/Jobs/J-1041.dxf,Z:/Jobs/cut list.csv")
//   --click    click something after the picks, repeatable (for example --click "button[type=submit]")
//   --wait     milliseconds to wait after the last click before the picture (default 3000)
//
// Serves the app through scripts/serve.mjs on its own port (never opens a browser window),
// takes the picture with Playwright's Chromium (installed by the tests check), then stops.
import { spawn } from 'node:child_process';
import { createServer } from 'node:http';
import { resolve, dirname, extname } from 'node:path';
import { mkdirSync, existsSync, readFileSync } from 'node:fs';
import { fileURLToPath } from 'node:url';

const ROOT = resolve(dirname(fileURLToPath(import.meta.url)), '..');
const args = process.argv.slice(2);
const [app, out] = args;
if (!app || !out) {
  console.error(
    'Usage: node scripts/look.mjs <app> <out.png> [--pick "<selector>=<file,...>"] [--click "<selector>"] [--wait ms] [--port n]',
  );
  process.exit(2);
}
const picks = [],
  clicks = [];
let wait = 3000,
  port = 8797;
for (let i = 2; i < args.length; i++) {
  if (args[i] === '--pick') picks.push(args[++i]);
  else if (args[i] === '--click') clicks.push(args[++i]);
  else if (args[i] === '--wait') wait = Number(args[++i]);
  else if (args[i] === '--port') port = Number(args[++i]);
}
let chromium;
try {
  ({ chromium } = await import('@playwright/test'));
} catch {
  console.error(
    'Playwright is not installed here: run npm install, then say "Check this computer" so the test browser is installed.',
  );
  process.exit(1);
}

// An app with a data.json is served by serve.mjs (so it can read its master file); a plain
// prototype without one is served as files, the way double-clicking index.html would show it.
const url = `http://localhost:${port}/apps/${app}/`;
let server, plain;
let serverSaid = '';
if (existsSync(resolve(ROOT, 'apps', app, 'data.json'))) {
  server = spawn(process.execPath, [resolve(ROOT, 'scripts/serve.mjs'), app, '--port', String(port), '--no-open'], {
    cwd: ROOT,
    stdio: ['ignore', 'pipe', 'pipe'],
  });
  server.stdout.on('data', (d) => {
    serverSaid += d;
  });
  server.stderr.on('data', (d) => {
    serverSaid += d;
  });
} else {
  const types = {
    '.html': 'text/html',
    '.js': 'text/javascript',
    '.mjs': 'text/javascript',
    '.css': 'text/css',
    '.json': 'application/json',
    '.csv': 'text/csv',
    '.svg': 'image/svg+xml',
    '.png': 'image/png',
  };
  plain = createServer((req, res) => {
    let p = decodeURIComponent(new URL(req.url, 'http://x').pathname);
    if (p.endsWith('/')) p += 'index.html';
    const f = resolve(ROOT, '.' + p);
    if (!f.startsWith(ROOT) || !existsSync(f)) {
      res.writeHead(404);
      res.end('not found');
      return;
    }
    res.writeHead(200, { 'Content-Type': types[extname(f)] || 'application/octet-stream' });
    res.end(readFileSync(f));
  }).listen(port, '127.0.0.1');
}
const up = async () => {
  for (let i = 0; i < 50; i++) {
    try {
      const r = await fetch(url);
      if (r.ok) return true;
    } catch {}
    await new Promise((r) => setTimeout(r, 200));
  }
  return false;
};
let code = 0;
try {
  if (!(await up())) throw new Error(`the app did not start on port ${port}: ${serverSaid.trim()}`);
  const browser = await chromium.launch();
  const page = await browser.newPage({ viewport: { width: 1280, height: 900 } });
  const problems = [];
  page.on('pageerror', (e) => problems.push(`page error: ${e.message}`));
  page.on('console', (m) => {
    if (m.type() === 'error') problems.push(`console error: ${m.text()}`);
  });
  await page.goto(url, { waitUntil: 'networkidle' });
  for (const p of picks) {
    const eq = p.indexOf('=');
    const selector = p.slice(0, eq),
      files = p
        .slice(eq + 1)
        .split(',')
        .map((f) => resolve(f.trim()));
    await page.setInputFiles(selector, files);
  }
  for (const c of clicks) await page.click(c);
  await page.waitForTimeout(wait);
  mkdirSync(dirname(resolve(out)), { recursive: true });
  await page.screenshot({ path: resolve(out), fullPage: true });
  const text = (await page.innerText('body')).replace(/\s+/g, ' ').slice(0, 600);
  await browser.close();
  console.log(`picture: ${resolve(out)}`);
  console.log(`first words on the page: ${text}`);
  for (const p of problems) console.log(p);
  if (problems.length) code = 1;
} catch (e) {
  console.error(`look.mjs: ${e.message}`);
  code = 1;
} finally {
  if (server) server.kill();
  if (plain) plain.close();
}
process.exit(code);
