# New app

**What it is for:** one sentence.
**Owner:** nobody yet.
**Stage:** Prototype.
**How to open it:** double-click `index.html` (sample data), or run
`node scripts/serve.mjs <this folder's name>` from the repository to work
with the master file.
**Where its data lives:** `Example.csv` on the shared drive, named in
`data.json` beside this file. Nothing is kept in the browser.
**Browsers it is used on:** not yet asked.
**Parts it uses:** page (`index.html`, `app.js`), module (`logic.js`, the
rules, tested in Node by `tests/<name>/logic.test.mjs`). The template also
shows a verifier (a produced statement re-read against the rows); keep it
only if this app produces something that leaves it. A script entry point
(`scripts/<name>.mjs` calling the module) is the fourth part, for a job
that runs without a page. Delete the parts this app does not need.

## Changelog

- 0.1.0 — created from Steadyship's template.
