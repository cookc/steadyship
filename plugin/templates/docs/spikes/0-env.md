# Spike 0 — what can this environment do?

**Question:** in the place where Claude runs our scripts, which tools are
installed, which websites can it reach, and does it remember files from one
session to the next?

**Who:** the builder (or {{SETUP_OWNER}}). **Where:** a local Claude session with
the `{{REPO_NAME}}` folder attached. Nothing to set up first.

## Builder runs

Type: `run spike 0` (or, without the plugin: "Run `bash
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
`| 0 | PASS | <date> | <the summary line> |`

**Run it twice.** The first run leaves a marker file. Run it again in a NEW
session (close the first one). If it says "files in this environment's home
survived", the environment remembers files; if it says "run spike 0 again"
again, it does not. Record both runs in the note.

## If it fails

- "git is missing" → this environment cannot run Steadyship's checks. Tell
  {{SETUP_OWNER}}; nothing else will work here.
- Many `blocked:` lines → the environment limits which websites it can
  reach. Send the output to {{SETUP_OWNER}}; later spikes (a, c, d) depend on it.
