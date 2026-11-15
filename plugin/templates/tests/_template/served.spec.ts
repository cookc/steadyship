import { test, expect } from '@playwright/test';
import { spawn, type ChildProcess } from 'node:child_process';
import { mkdtempSync, writeFileSync, readFileSync, rmSync } from 'node:fs';
import { tmpdir } from 'node:os';
import { join } from 'node:path';

// The template through the serve script, on a throwaway shared drive: what a save does to the master.
// Only meaningful for the template itself (scripts/test.sh _template).
const isTemplate = (process.env.APP || 'apps/_template/index.html').includes('apps/_template/');
const PORT = 20000 + Math.floor(Math.random() * 20000);
let drive = '';
let server: ChildProcess | undefined;

test.beforeAll(async () => {
  if (!isTemplate) return;
  drive = mkdtempSync(join(tmpdir(), 'steadyship-served-'));
  // Line 3 has a date Excel reformatted and line 4 has no identifier: both fail the check.
  writeFileSync(
    join(drive, 'Example.csv'),
    'id,name,amount,due,notes\r\nX-1,First,10.00,2026-01-31,keep\r\nX-2,Second,20.00,31/01/2026,reformatted\r\n,No id yet,5.00,,draft\r\nX-3,Third,,,\r\n',
  );
  server = spawn(
    process.execPath,
    ['scripts/serve.mjs', '_template', '--port', String(PORT), '--shared-drive', drive, '--no-open'],
    { stdio: 'ignore' },
  );
  for (let i = 0; i < 50; i++) {
    try {
      if ((await fetch(`http://127.0.0.1:${PORT}/apps/_template/`)).ok) return;
    } catch {
      /* not up yet */
    }
    await new Promise((r) => setTimeout(r, 100));
  }
  throw new Error('the serve script did not start');
});
test.afterAll(() => {
  server?.kill();
  if (drive) rmSync(drive, { recursive: true, force: true });
});

test('saving keeps the rows the app could not read, and every column it does not use', async ({ page }) => {
  test.skip(!isTemplate, 'the template only');
  await page.goto(`http://127.0.0.1:${PORT}/apps/_template/`);
  await expect(page.locator('#list tbody')).toContainText('X-3');
  await expect(page.locator('#messages')).toContainText('line 3');
  await expect(page.locator('#list tbody')).not.toContainText('X-2');
  await page.fill('input[name=id]', 'X-4');
  await page.fill('input[name=name]', 'Fourth');
  await page.click('button[type=submit]');
  await expect(page.locator('#messages')).toContainText('X-4 added');
  const lines = readFileSync(join(drive, 'Example.csv'), 'utf8').replace(/^﻿/, '').trim().split('\r\n');
  expect(lines).toEqual([
    'id,name,amount,due,notes',
    'X-1,First,10.00,2026-01-31,keep',
    'X-2,Second,20.00,31/01/2026,reformatted',
    ',No id yet,5.00,,draft',
    'X-3,Third,,,',
    'X-4,Fourth,,,',
  ]);
});
