import { test, expect } from '@playwright/test';
import { pathToFileURL } from 'node:url';
import { resolve } from 'node:path';

// The template's own tests: the shape every app's tests start from.
// APP is set by scripts/test.sh; opened by path, so these run with no server.
const APP = process.env.APP || 'apps/_template/index.html';
const url = /^https?:\/\//.test(APP) ? APP : pathToFileURL(resolve(APP)).href;

test('opens with no errors and shows the sample rows', async ({ page }) => {
  const errors: string[] = [];
  page.on('pageerror', (e) => errors.push(e.message));
  await page.goto(url);
  await expect(page.locator('.stage-banner')).toContainText('Prototype');
  await expect(page.locator('#list tbody tr')).toHaveCount(2);
  await expect(page.locator('#list tbody')).toContainText('X-1');
  expect(errors).toEqual([]);
});

test('adding a row with a bad identifier keeps what was typed and says why', async ({ page }) => {
  await page.goto(url);
  await page.fill('input[name=id]', 'nope');
  await page.fill('input[name=name]', 'Typed name');
  await page.click('button[type=submit]');
  await expect(page.locator('#messages .message')).toContainText('Identifier');
  await expect(page.locator('input[name=name]')).toHaveValue('Typed name');
  await expect(page.locator('#list tbody tr')).toHaveCount(2);
});

test('adding a good row shows it with money formatted', async ({ page }) => {
  await page.goto(url);
  await page.fill('input[name=id]', 'X-3');
  await page.fill('input[name=name]', 'Third');
  await page.fill('input[name=amount]', '1,234.5');
  await page.click('button[type=submit]');
  await expect(page.locator('#list tbody tr')).toHaveCount(3);
  await expect(page.locator('#list tbody tr').nth(2)).toContainText('1,234.50');
});

test('reads on a phone-sized screen without sideways scrolling of the page', async ({ page }) => {
  await page.setViewportSize({ width: 375, height: 700 });
  await page.goto(url);
  const overflow = await page.evaluate(
    () => document.documentElement.scrollWidth > document.documentElement.clientWidth,
  );
  expect(overflow).toBe(false);
});
