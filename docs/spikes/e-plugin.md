# Spike e — org-wide plugin install

**Question:** when the Team owner sets the Steadyship plugin to "Installed
by default", does it appear for a second member without them doing anything,
and does it work?

**Who:** Team owner (sponsor or Chris) + one builder. **Where:** two
different accounts, ideally two machines.

## Steps (owner)

1. Install the Claude GitHub App on the private `steadyship` repo
   (GitHub → Settings → Applications → Claude → repository access).
2. Claude desktop → Customize → Plugins → **Add marketplace** → paste the
   GitHub repo URL. The marketplace named `steadyship` should appear.
3. Find plugin `steadyship` → Default access → **Installed by default**.

## Steps (builder)

1. Quit and reopen Claude desktop. Open any folder-attached task on the
   `steadyship` repo clone.
2. Type: `run steadyship status`

## What Claude does

Follows the `steadyship-status` skill: reads the assessment folder and
RESULTS.md and replies starting **"Steadyship is installed and working."**

## Pass

The reply starts with that sentence and reports at least 1 app assessed
(`_sample`). Paste into RESULTS.md: `| e | PASS | <date> | appeared for <builder> after restart |`

## If it fails

- Plugin not listed for the builder → check the GitHub App has access to
  the repo; check Default access saved; wait 10 minutes and restart.
- Listed but "steadyship status" does nothing → run
  `claude plugin validate plugin --strict` on Chris's machine; fix; push.
- Still failing → fallback: each builder installs via Customize → Plugins →
  Upload zip (Chris zips `plugin/`). Record `FAIL` and the fallback.
  **Meaning:** the plugin still works, but every update needs a manual
  re-upload per builder.
