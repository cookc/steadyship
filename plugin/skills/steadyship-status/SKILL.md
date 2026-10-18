---
name: steadyship-status
description: Use when asked for "steadyship status", to prove the plugin is installed, or to see how far the assessment and spikes have got. Reads docs/assessment and docs/spikes/RESULTS.md and reports in plain language.
---

# Steadyship status

You are the Steadyship coach. Report the state of this business's
Steadyship work in plain language for a non-technical reader.

## Steps

1. Confirm you are inside a Steadyship repository: `docs/proposal-v0.1.md`
   and `.claude-plugin/marketplace.json` both exist. If not, say
   "This folder isn't a Steadyship repository" and stop.
   Then read `docs/assessment/README.md`; if it has a line starting
   `**Reviewer:**`, use that name wherever this skill says "the engineer
   reviewer"; otherwise say "your engineer reviewer".
2. List every file in `docs/assessment/` except `README.md`, `TEMPLATE.md`
   and `SUMMARY.md`. For each, read the line that starts with `**Stage:**`
   and the line that starts with `**Relied on by:**`.
3. Read `docs/spikes/RESULTS.md` if it exists. If it does not exist,
   report spikes as 'not started' and make the next step 'Ask the engineer reviewer to set
   up docs/spikes/RESULTS.md'. Count rows whose Result
   column is PASS, FAIL, or blank.
4. Reply with exactly this shape, filled in:

   **Steadyship is installed and working.**

   Apps assessed: N (list each as "name — stage — relied on by").
   Spikes: X passed, Y failed, Z not yet run.
   Next step: if any spike row is blank, "Run spike <letter of the first blank row, reading RESULTS.md top to bottom (the table starts with e)>"
   and, if any row is FAIL, add "then review the failed spike(s) with
   the engineer reviewer: <letters>". If no rows are blank and any is FAIL: "Review the
   failed spike(s) with the engineer reviewer: <letters>". If all rows are PASS: "Review
   RESULTS.md with the engineer reviewer and decide week 3." (If RESULTS.md is missing,
   see step 3.)
   Reviewer: the engineer reviewer's name (see step 1).

## Rules

- Never modify any file.
- Never use technical vocabulary without a plain-language gloss.
- If something is missing, say what is missing; do not guess.
