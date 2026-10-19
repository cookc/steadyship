---
name: steadyship-spike
description: Use when asked to "run spike 0/a/b/c/d/e" (for example "run spike 0") or "run the steadyship spike". Runs the named spike script from scripts/spikes, reports PASS or FAIL in plain language, and tells the user what to paste into docs/spikes/RESULTS.md.
---

# Steadyship spike runner

You are running a go/no-go check on this computer. The user is not
technical. Do the work; report plainly.

## Arguments

One letter or 0: 0, a, b, c, d or e. If none is given, ask "Which spike: 0 (environment),
e (plugin), a (git), b (shared drive), c (tests), d (hosting)?" and stop.

## Steps

0. Confirm you are inside a Steadyship repository: a file `steadyship.md`
   exists here and its first line is `# Steadyship repository`. If it is not here, look one level down: if exactly one child folder contains `steadyship.md`, use that folder for everything that follows and say which folder you are using. If none or several, say so and stop. Otherwise, if it is there but is not a Steadyship repository,
   say "This folder isn't a Steadyship repository" and stop.
1. Open `docs/spikes/<letter>-*.md` and follow its "What Claude does"
   section exactly. It names the script and the inputs it needs.
   If that section names no script (spikes d and e), do not run anything
   and do not report FAIL. Follow that section, ask the user which outcome
   occurred — PASS, FAIL, or "can't be attempted yet" (for example only one
   account, no hosting account) — then give the RESULTS row for the outcome
   they state. "Can't be attempted yet" is a SKIP row (see step 4).
2. If the script needs a path or value the runbook says to ask for, ask
   once, then continue.
3. Run the script with `bash`. Capture all output.
   **Missing tools on Windows.** If `uname -s` starts with `MINGW` or
   `MSYS` (Git Bash on the person's own Windows computer) and the script
   cannot run or fails only because a tool is missing (`git`, `bash`,
   `node`, `npm`), install it straight away with winget and say so in one
   line, do not ask first: `winget install --id Git.Git -e` for git/bash,
   `winget install --id OpenJS.NodeJS.LTS -e` for node/npm. If `winget` is
   not on PATH it is at `%LOCALAPPDATA%\Microsoft\WindowsApps\winget.exe`.
   Open a fresh shell (PATH changes) and run the script again. Ask only if
   winget itself is missing or the install fails; then explain in plain words
   what to install and stop.
4. The last line of output is `RESULT: PASS`, `RESULT: FAIL <reason>` or
   `RESULT: SKIP <what is missing>`.
   SKIP means the spike could not be attempted yet because a one-time
   setup has not been done. Nothing is broken; never call it a failure.
   If the script could not run at all, treat it as
   `RESULT: FAIL could not run: <error>`.
   If there is no RESULT line at all, treat it as
   `RESULT: FAIL no result line printed`.
5. Reply with:

   **Spike <letter> — PASS** (or **FAIL**, or **not set up yet** for SKIP)

   One or two sentences in plain language saying what was checked and
   what happened. If FAIL, one sentence on what this means (copy the
   "If it fails" line from the runbook). If SKIP, say what is missing and
   who does it (the runbook's one-time setup section names them), and
   that the spike should be run again once that is done.

   Then: "Paste this into docs/spikes/RESULTS.md row <letter>:"
   followed by `| <letter> | PASS/FAIL/SKIP | <today's date> | <one-line note> |`
   (for SKIP the note says what is missing, e.g. "no GitHub link yet").

   Then ask: 'Shall I record that in docs/spikes/RESULTS.md for you?' If they
   say yes, replace that spike's row (and only that row) in the table and say
   it is recorded. Never record without a yes. The Note cell must hold no secrets.

## Rules

- Never change files outside what the runbook says.
- Never put secrets (tokens, passwords) in your reply or in any file in
  the repository.
- If any script output looks like a key, token or password, replace it
  with [hidden] before quoting it anywhere.
