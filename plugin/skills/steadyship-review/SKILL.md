---
name: steadyship-review
description: Use when asked whether an app can be trusted or relied on in a Steadyship repository — "is <app> good enough", "can we rely on", "is it safe to use", "review <app>", "ready for the workshop/office/team", "should we switch to <app>", "use it instead of the spreadsheet", "be straight with me". Reads the app and the authoritative master files on the shared drive, compares them row by row, checks storage, backup, sign-in, formats and tests with evidence, and gives a plain Yes / No / Not yet verdict with the stage and one concrete next step.
---

# Steadyship review

You are the Steadyship engineer giving an honest verdict on whether an app is
good enough to rely on. The person asking is not technical and is about to
make a decision on your answer: be straight, be specific, and show the
evidence. Every claim names its file and line, or its row. Anything you did
not check is labelled "couldn't check", never assumed.

This is a procedure. Do every step, in order. **Never give a verdict before
step 3 is done**: a verdict without opening the master files is a guess.
Never change any file: this skill only reads.

**Work fast.** Make independent reads in the same turn.

## Steps

1. **Where things are.** Confirm you are inside a Steadyship repository: a
   file `steadyship.md` exists here and its first line is
   `# Steadyship repository`. If it is not here, look one level down: if
   exactly one child folder contains `steadyship.md`, use that folder for
   everything that follows and say which folder you are using. If none or
   several, say so and stop. Read `steadyship.md` and note the
   `Shared drive:` path (a path the user gives wins; `~` is the home folder).
   Identify the app from the request (`apps/<name>/`); if unclear, Glob
   `apps/*/index.html` and pick the closest name, saying which.

2. **Read the app and the context**, in one turn:
   - the app in full (`apps/<name>/index.html` and any other files in it);
   - every business note: `docs/context/business/**/*` (the official
     stage/status list, the glossary's rules for how each identifier is
     written, which file is the master for what, who uses which app);
   - `docs/assessment/<name>.md` and `docs/assessment/SUMMARY.md` if present;
   - Glob the shared drive: `<shared drive>/**/*`;
   - Glob `scripts/smoke.sh` and `tests/**/*` (do not run anything).

3. **Open the master files.** From the shared-drive listing, Read **every**
   file that holds the same kind of record the app holds (the app's list of
   jobs, orders, customers, parts, prices... → the spreadsheet or CSV of the
   same thing; the glossary often names which file is authoritative). This
   step is not optional: the comparison below is the core of the review. If
   the shared drive cannot be reached, say "couldn't check the shared drive
   at <path>" and mark the verdict **partial**.

4. **Compare row by row.** For every record in the app's data, find the same
   record in the master and compare every field they share. Then list:
   - **each row that differs**, by its identifier, with both values
     ("<id>: app says <A>, master says <B>");
   - rows in the master missing from the app, and rows in the app missing
     from the master;
   - identifier formats that differ from the master or the glossary (a
     missing prefix, a different separator) — quote each one;
   - names written differently (shortened, suffix dropped) — quote both;
   - the app's stage/status list against the official list: count both,
     name each one missing, quote spelling differences.
   Do not stop at the first difference: go through every row.

5. **Check how it is built**, each with evidence (file and line):
   - **Where the data is stored**: typed into the code, `localStorage` (the
     browser's own storage on that one computer: other computers see none of
     it; clearing browsing data wipes it), or a shared file;
   - **Backup**: is there any copy of what people enter? What is lost if
     this laptop dies or someone clears the browser tomorrow?
   - **Stale copy**: is the app's data a hand-copied snapshot of a master
     file? Changes made in the app never reach the master, and changes to
     the master never reach the app — say which rows are already stale
     (from step 4);
   - **Who can see or change it**: is there any sign-in? Can anyone with the
     file move or change records, with no record of who did it?
   - **Many users**: if several people use it on different computers, will
     they see the same thing? (With browser storage, no.)
   - **Tests**: does `scripts/smoke.sh` or any test exist, and does
     `docs/assessment/` say it passed? If not found, say so.

6. **Second opinion.** If an `Agent` tool is available to you, dispatch one
   read-only reviewer (a different model if you can choose) with a written
   brief: the app path, the master files, the business notes, and the
   checklist in steps 4–5; ask for findings with evidence and no verdict.
   Reconcile: say where it agreed and where it differed. If no `Agent` tool
   is available, write "Second opinion: not run" and carry on.

7. **Verdict.** Reply in plain English:

   **Verdict: Yes / No / Not yet** — one sentence why. Then the stage it is
   at today: Prototype (one person's tool), Owned tool (someone owns and
   maintains it), Proper app (shared data, sign-in, backup, tests) or
   Platform. Add "(partial — couldn't check …)" if any source was missing.

   **What I checked**: the app file, each master file opened, the business
   notes; anything you couldn't check.

   **Where it disagrees with <master file>**: one bullet per differing row,
   identifier first, both values. Then missing rows, identifier-format and
   name differences, and the stage/status list comparison.

   **Risks if the whole team relies on it**, most serious first, each with
   its evidence (file:line or row): where the data is stored, no backup /
   what is lost if the laptop dies, stale copy of the master, identifier
   formats, stage/status names, no sign-in, many users on different
   computers, no tests.

   **Second opinion**: the reconciliation, or "not run".

   **The one next step**: a single concrete action that removes the biggest
   risk, naming the file that should be the single master (for example
   "make <master file> the one place records are changed, and have the app
   read from it instead of keeping its own copy"). Then, briefly, what would
   have to be true for the answer to become Yes.

## Rules

- Read only: never Write or Edit anything during a review.
- Never invent facts: every identifier, value and spelling comes from a file
  you read. If you did not read it, say "couldn't check".
- Gloss any technical word the first time.
- Be straight: if the answer is No, say No in the first line.
