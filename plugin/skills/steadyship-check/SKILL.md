---
name: steadyship-check
description: Use when asked to "check this computer", "run the checks", "check the shared drive", "check the tests", "check GitHub", "check hosting", "check the team", or the older "run spike 0/a/b/c/d/e". Runs Steadyship's one-minute checks of what this setup can really do (environment, shared drive, tests) in one go and records the results; the GitHub, hosting and team checks run one at a time from their runbooks. Not for status, assessments, reviews or changes.
---

# Steadyship check

You are checking what this computer and setup can really do, before
anything is built on it. The user is not technical. Do the work; report
plainly. Each check ends in one word: PASS, FAIL or SKIP (could not be
attempted yet, nothing is broken).

## Which check

- No name, "this computer", "the checks", "environment", "shared drive",
  "tests", or the old "spike 0", "spike b", "spike c": **A, the combined
  run** below. "The app is <name>" picks the app for the tests check.
- "GitHub" or "spike a": **B** with `docs/spikes/github.md`.
- "hosting" or "spike d": **B** with `docs/spikes/hosting.md`.
- "the team" or "spike e": **B** with `docs/spikes/team.md`.

First, in either case, confirm you are inside a Steadyship repository: a
file `steadyship.md` exists here and its first line is
`# Steadyship repository`. If it is not here, look one level down: if
exactly one child folder contains `steadyship.md`, use that folder for
everything that follows and say which folder you are using. If none or
several, say "This folder isn't a Steadyship repository" and stop.

## A. Check this computer

1. Say in one line what is about to happen: three one-minute checks
   (environment, shared drive, tests), results recorded in
   `docs/spikes/RESULTS.md`. If `apps/` has no app yet (other than
   `_sample`), say the tests check will be skipped until one is copied in.
   The first tests run installs a test browser and can take a few minutes;
   say so.
2. Run `bash scripts/check.sh`, adding `--app <name>` if the user named
   one. Capture all output.
   **Missing tools on Windows.** If `uname -s` starts with `MINGW` or
   `MSYS` (Git Bash on the person's own Windows computer) and a check
   fails only because a tool is missing (`git`, `bash`, `node`, `npm`),
   install it straight away with winget and say so in one line, do not ask
   first: `winget install --id Git.Git -e` for git/bash,
   `winget install --id OpenJS.NodeJS.LTS -e` for node/npm. If `winget`
   is not on PATH it is at `%LOCALAPPDATA%\Microsoft\WindowsApps\winget.exe`.
   Open a fresh shell (PATH changes) and run the script again. Ask only if
   winget itself is missing or the install fails; then explain in plain
   words what to install and stop.
   **Shared drive not visible.** If the shared-drive row says "not visible
   from here" and `pwd` looks like `/sessions/…/mnt/…` (Claude desktop's
   separate Linux environment), the recorded path is a Windows or Mac
   path this environment cannot see. Ask once: "Which attached folder is
   the shared drive?", find how it appears here (`ls` the attached
   folders), and run the script again with `--shared-drive <that path>`.
   If it is still not visible, that is the finding; do not keep retrying.
3. Reply with one line per check, in plain words: what was checked and
   what happened, then the word. For example: "Shared drive: read, wrote
   and deleted a test file on Z: — PASS." For a FAIL, add one sentence on
   what it means, taken from the runbook's "If it fails" section
   (`docs/spikes/environment.md`, `shared-drive.md`, `tests.md`). For a
   SKIP, say what is missing and that the check runs again once it is
   there. If the environment check reports persistence as "unknown", say
   in one line that the next run in a new chat will answer it.
4. Say the results are recorded in `docs/spikes/RESULTS.md`, then give the
   next step: if no app is in `apps/` yet, "copy your apps into `apps/`,
   one folder each, and say Check this computer again"; otherwise "say:
   What apps do we have and where is the same information kept twice?".

## B. GitHub, hosting, team (one at a time)

1. Open the runbook and follow its "What Claude does" section exactly. It
   names the script and the inputs it needs. If that section names no
   script (hosting, team), do not run anything and do not report FAIL:
   follow the section, ask the user which outcome occurred (PASS, FAIL, or
   "can't be attempted yet"), and record that. "Can't be attempted yet" is
   a SKIP.
2. If the script needs a value the runbook says to ask for, ask once,
   then continue.
3. Run the script with `bash`. The last line of output is `RESULT: PASS`,
   `RESULT: FAIL <reason>` or `RESULT: SKIP <what is missing>`. If the
   script could not run at all, treat it as `RESULT: FAIL could not run:
   <error>`; if there is no RESULT line, as `RESULT: FAIL no result line
   printed`.
4. Reply with **<Check> — PASS** (or **FAIL**, or **not set up yet** for
   SKIP), then one or two plain sentences on what was checked and what
   happened. If FAIL, one sentence on what it means (the runbook's "If it
   fails" line). If SKIP, what is missing and who does it (the runbook's
   one-time setup section names them).
5. Record it: replace that check's row (and only that row) in
   `docs/spikes/RESULTS.md` with
   `| <github|hosting|team> | PASS/FAIL/SKIP | <today's date> | <one-line note> |`
   and say it is recorded. The Note cell must hold no secrets.

## Rules

- Never change files outside what the script or runbook says.
- Never put secrets (tokens, passwords) in your reply or in any file in
  the repository. If any output looks like a key, token or password,
  replace it with [hidden] before quoting it.
- Plain language; gloss any technical word the first time.
