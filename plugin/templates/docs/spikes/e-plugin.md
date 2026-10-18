# Spike e — org-wide plugin install

**Question:** when the Team owner sets the Steadyship plugin to "Installed
by default", does it appear for a second member without them doing anything,
and does it work?

**Who:** Team owner (sponsor or {{SETUP_OWNER}}) + one builder. **Where:** two
different accounts, ideally two machines.

## Steps (owner)

1. **{{SETUP_OWNER}}**: arrange with Steadyship that the Claude GitHub App
   has access to the repository `{{PLUGIN_MARKETPLACE}}` (where the
   Steadyship plugin is published), so the Team owner can add it.

Then the **Team owner**:

2. Claude desktop → Customize → Plugins → **Add marketplace** → paste
   `https://github.com/{{PLUGIN_MARKETPLACE}}`. The marketplace named `steadyship` should appear.
3. Find plugin `steadyship` → Default access → **Installed by default**.

## Steps (builder)

1. Quit and reopen Claude desktop. Open any folder-attached task on the
   `{{REPO_NAME}}` repo clone.
2. Type: `run steadyship status`

## What Claude does

Follows the `steadyship-status` skill: reads the assessment folder and
RESULTS.md and replies starting **"Steadyship is installed and working."**

## Pass

The reply starts with that sentence and reports at least 1 app assessed
(`_sample`). Paste into RESULTS.md: `| e | PASS | <date> | appeared for <builder> after restart |`

## If it fails

- Plugin not listed for the builder → check the GitHub App has access to
  `{{PLUGIN_MARKETPLACE}}`; check Default access saved; wait 10 minutes and
  restart.
- Listed but "steadyship status" does nothing → wait 10 minutes and restart;
  then ask Steadyship to check that the plugin validates.
- Still failing → fallback: each builder installs via Customize → Plugins →
  Upload zip (Steadyship supplies a zip of the plugin). Record `FAIL` and the fallback.
  **Meaning:** the plugin still works, but every update needs a manual
  re-upload per builder.
