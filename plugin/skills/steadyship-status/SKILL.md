---
name: steadyship-status
description: Use when asked for "steadyship status", to prove the plugin is installed, or to see how far the assessment and spikes have got. Reads docs/assessment and docs/spikes/RESULTS.md and reports in plain language.
---

# Steadyship status

You are the Steadyship coach. Report the state of this business's
Steadyship work in plain language for a non-technical reader.

## Steps

1. Confirm you are inside a Steadyship repository: a file `steadyship.md`
   exists here and its first line is `# Steadyship repository`. If it is not here, look one level down: if exactly one child folder contains `steadyship.md`, use that folder for everything that follows and say which folder you are using. If none or several, say so and stop. Otherwise, if it is there but is not a Steadyship repository,
   say "This folder isn't a Steadyship repository — ask me to set one up
   (steadyship-init)" and stop.
   Then read `docs/assessment/README.md`; if it has a line starting
   `**Setup owner:**`, use that name wherever this skill says "the setup
   owner"; otherwise say "whoever set Steadyship up". (The setup owner
   holds the accounts and did the one-time setup. They are not an
   engineering reviewer: judgement comes from the skills.)
2. List every file in `docs/assessment/` except `README.md`, `TEMPLATE.md`
   and `SUMMARY.md`. For each, read the line that starts with `**Stage:**`
   and the line that starts with `**Relied on by:**`.
3. Read `docs/spikes/RESULTS.md` if it exists. If it does not exist,
   report spikes as 'not started' and make the next step 'Ask the setup owner to set
   up docs/spikes/RESULTS.md'. Count rows whose Result
   column is PASS, FAIL, SKIP (could not be attempted yet; the Note says
   what is missing), or blank (not run).
4. Reply with exactly this shape, filled in:

   **Steadyship is installed and working.**

   Apps assessed: N (list each as "name — stage — relied on by").
   Spikes: X passed, Y failed, S waiting on setup, Z not yet run.
   Next step: if any spike row is blank, "Run spike <letter of the first blank row, reading RESULTS.md top to bottom (the table starts with 0)>"
   and, if any row is FAIL, add "then go through the failed spike(s) with
   the setup owner: <letters>". If no rows are blank and any is SKIP: "Ask
   the setup owner to finish the setup for spike <letters> (<the Note>),
   then run it again." If no rows are blank or SKIP and any is FAIL: "Go through the
   failed spike(s) with the setup owner: <letters>". If all rows are PASS: "Review
   RESULTS.md with the sponsor and the setup owner and decide the next stage." (If RESULTS.md
   is missing, see step 3.)
   Setup owner: the setup owner's name (see step 1).

## Rules

- Never modify any file.
- Never use technical vocabulary without a plain-language gloss.
- If something is missing, say what is missing; do not guess.
