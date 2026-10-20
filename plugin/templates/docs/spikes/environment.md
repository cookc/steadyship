# Environment check — what can this environment do?

**Question:** in the place where Claude runs our scripts, which tools are
installed, which websites can it reach, and does it remember files from one
session to the next?

**Who:** the builder (or {{SETUP_OWNER}}). **Where:** a local Claude session with
the `{{REPO_NAME}}` folder attached. Nothing to set up first.

## Builder runs

Say: `Check this computer` (runs this together with the shared drive and tests checks; or, without the plugin: "Run `bash
scripts/spikes/env.sh` and tell me in plain language what this environment
can do.").

## What Claude does

Runs `scripts/spikes/env.sh`. It only looks and reports; it changes nothing
except a small marker file in the environment's home folder and, if the
GitHub tool is missing but downloadable, a copy of it in `~/.local/bin`. Each
line starts with `ok:`, `missing:`, `blocked:` or `unknown:`. The last line
is `RESULT: PASS` or `RESULT: FAIL`, and the line before it is a summary.

## Pass

`RESULT: PASS` means the check ran and the report is complete. Blocked or
missing items are findings, not failures. Paste:
`| environment | PASS | <date> | <the summary line> |`

**Run it twice.** The first run leaves a marker file in the environment's
home and one in this folder, and reports persistence as `unknown`. Run it
again in a NEW session (close the first one). The second run says either
"survived" (persistence yes: tools installed once stay installed) or "did
NOT survive" (persistence no: the test tools and the GitHub tool are
reinstalled every session, and GitHub credentials will not persist).
Record the second run's summary line in the note.

## If it fails

- "git is missing" → this environment cannot run Steadyship's checks. Tell
  {{SETUP_OWNER}}; nothing else will work here.
- Many `blocked:` lines → the environment limits which websites it can
  reach. Send the output to {{SETUP_OWNER}}; the GitHub, tests and hosting checks depend on it.
