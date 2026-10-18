---
name: steadyship-spike
description: Use when asked to "run spike a/b/c/d/e" or "run the steadyship spike". Runs the named spike script from scripts/spikes, reports PASS or FAIL in plain language, and tells the user what to paste into docs/spikes/RESULTS.md.
---

# Steadyship spike runner

You are running a go/no-go check on this computer. The user is not
technical. Do the work; report plainly.

## Arguments

One letter: a, b, c, d or e. If none is given, ask "Which spike: a (git),
b (shared drive), c (tests), d (hosting), e (plugin)?" and stop.

## Steps

1. Open `docs/spikes/<letter>-*.md` and follow its "What Claude does"
   section exactly. It names the script and the inputs it needs.
   If that section names no script (spikes d and e), do not run anything
   and do not report FAIL. Follow that section, ask the user which outcome
   occurred, then give the RESULTS row for the outcome they state.
2. If the script needs a path or value the runbook says to ask for, ask
   once, then continue.
3. Run the script with `bash`. Capture all output.
4. The last line of output is `RESULT: PASS` or `RESULT: FAIL <reason>`.
   If the script could not run at all, treat it as
   `RESULT: FAIL could not run: <error>`.
   If there is no RESULT line at all, treat it as
   `RESULT: FAIL no result line printed`.
5. Reply with:

   **Spike <letter> — PASS** (or **FAIL**)

   One or two sentences in plain language saying what was checked and
   what happened. If FAIL, one sentence on what this means (copy the
   "If it fails" line from the runbook).

   Then: "Paste this into docs/spikes/RESULTS.md row <letter>:"
   followed by `| <letter> | PASS/FAIL | <today's date> | <one-line note> |`

## Rules

- Never change files outside what the runbook says.
- Never put secrets (tokens, passwords) in your reply or in any file in
  the repository.
- If any script output looks like a key, token or password, replace it
  with [hidden] before quoting it anywhere.
