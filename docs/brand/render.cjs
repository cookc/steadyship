// Renders docs/brand/logo.html to PNGs with Playwright's Chromium.
// Run from any folder that has Playwright installed (a generated Steadyship
// repository after `npm ci` will do):  node <repo>/docs/brand/render.cjs
const path = require('path');
const pw = require(require.resolve('playwright', { paths: [process.cwd(), __dirname] }));
(async () => {
  const browser = await pw.chromium.launch();
  const page = await browser.newPage({ deviceScaleFactor: 2 });
  await page.goto('file://' + path.join(__dirname, 'logo.html'));
  await page.evaluate(() => document.fonts.ready);
  await page.waitForTimeout(300);
  for (const [id, file] of [['light', 'logo.png'], ['dark', 'logo-dark.png']]) {
    await page.locator('#' + id).screenshot({ path: path.join(__dirname, file), omitBackground: true });
  }
  await page.locator('#social').screenshot({ path: path.join(__dirname, 'social-preview.png') });
  await browser.close();
  console.log('RESULT: PASS logo.png logo-dark.png social-preview.png');
})().catch((e) => { console.error(e); process.exit(1); });
