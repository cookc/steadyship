# Spike c — run a real smoke test and say what happened

**Question:** inside the builder's local session, can Claude install the
test tools, run the smoke test against one real app, and report the result
in plain language?

**Who:** builder. **Where:** builder's machine, local session, `steadyship`
folder attached, with at least one real app copied to `apps/<name>/` by
Chris (see `docs/assessment/README.md` step 2).

## Builder runs

Type: `run spike c` and when asked which app, give its folder name.
(Without the plugin: "Run `bash scripts/smoke.sh apps/<name>/index.html` and
tell me in plain language whether the app passed.")

## What Claude does

Runs `scripts/smoke.sh apps/<name>/index.html`. First run installs
`@playwright/test` and a Chromium browser inside the VM (may take a few
minutes).

## Pass

`RESULT: PASS`, and Claude's explanation is something the builder can
repeat back. Paste: `| c | PASS | <date> | app: <name>; install took ~N min |`

A `RESULT: FAIL the app did not load cleanly` is **also a pass for the
spike** (the tooling worked; the app has a real error — note it in the
app's assessment).

## If it fails

- `could not install the test browser` → the VM's network allowlist blocks
  the Playwright browser download. **Fallback:** tests run in GitHub
  Actions (`.github/workflows/validate.yml` already does this for every
  `apps/*/index.html`); the coach reports CI results instead of running
  locally. Record `FAIL` + "CI fallback". **Meaning:** verification is
  one push away rather than instant; acceptable for V0.
- `could not install test tools (npm)` → npm registry blocked (unexpected;
  it is on the allowlist). Record the exact error.
