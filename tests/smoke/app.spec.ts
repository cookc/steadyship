import { test, expect } from '@playwright/test';
import { pathToFileURL } from 'node:url';
import { resolve } from 'node:path';

// APP is a path to an index.html or an http(s) URL. Set by scripts/smoke.sh.
const APP = process.env.APP;
if (!APP) throw new Error('APP env var is required (path to index.html or URL)');
const url = /^https?:\/\//.test(APP) ? APP : pathToFileURL(resolve(APP)).href;

test(`smoke: ${APP}`, async ({ page }) => {
  const errors: string[] = [];
  page.on('console', (m) => { if (m.type() === 'error') errors.push(`console.error: ${m.text()}`); });
  page.on('pageerror', (e) => errors.push(`uncaught: ${e.message}`));

  const response = await page.goto(url, { waitUntil: 'load' });
  if (response) expect(response.ok(), `HTTP ${response.status()}`).toBeTruthy();

  await expect(page).not.toHaveTitle('');
  expect(errors, errors.join('\n')).toEqual([]);
});
