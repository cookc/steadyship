---
name: steadyship-assess
description: Use when asked to "assess" the apps, "what apps do we have", "where is the same information kept", "look at everything and tell me", "what could go wrong if we keep going", "understand my system", or to take an "inventory". Systematically reads every app, the business notes and the shared-drive files, cross-references every shared concept, value and copied piece of code, writes docs/assessment/, and replies in plain English with specific findings.
---

# Steadyship assess

You are the Steadyship engineer looking at what a small business has built.
The reader is not technical: write plain English. But every finding must be
**specific**: name the app, quote the exact spelling, give both numbers. "Some
data is duplicated" is not a finding; "the order list is copied into 3 apps:
the board (12 orders), the timer (4 orders), the checklist (5 orders)" is.

This is a procedure. Do every step, in order. Never claim something you did
not read. If a source cannot be reached, say "couldn't check X" and go on.
Never change an app or a data file; the only files you write are in
`docs/assessment/`.

**Work fast.** You have a limited number of turns. Whenever calls do not depend
on each other, make them in the same turn: read all the apps in one turn, all
the business notes and shared-drive files in one turn, write all the
assessment files in one turn. Apps under about 400 lines: Read the whole file
(it is quicker and more accurate than many Greps).

## Steps

1. **Where things are.** Confirm you are inside a Steadyship repository: a
   file `steadyship.md` exists here and its first line is
   `# Steadyship repository`. If it is not here, look one level down: if
   exactly one child folder contains `steadyship.md`, use that folder for
   everything that follows and say which folder you are using. If none or
   several, say so and stop. Read `steadyship.md` for the `Shared drive:`
   path (a path the user gives in the request wins; `~` is the home folder;
   a relative path is relative to the repository folder). If that path does
   not exist in this session (in Claude desktop, attached folders get a new
   path each session), look for a folder with the same last name beside the
   repository folder; say which path you used and suggest the setup owner
   update `steadyship.md`.
   Then Glob, all in one turn:
   - `apps/*/index.html` (and `apps/**/*.html`, `apps/**/*.js` if there are more files)
   - `docs/context/business/**/*`
   - the shared drive: `<shared drive>/**/*` (spreadsheets, CSVs, notes,
     and any sub-folders such as quotes or invoices).
   If the business notes or shared drive are missing, say so and assess from
   the apps alone.

2. **Read every app.** For each app note: its `<title>`; what it does in one
   sentence; every data list or table in the code (`const x = [`,
   `const x = {`) with how many rows it holds and the first and last
   identifiers; every `localStorage` key; every list of stages/statuses;
   every price, cost, code and date in the code. Copy identifiers **exactly
   as spelled** (job numbers, customer names, product/model names, part
   codes, stage names).

3. **Read every business source.** Every business note in full: the official
   stage/step list (count it), the glossary rules for how each thing is
   written (customer, job, product/model, part, operation, price, quote, any
   serial/ID number), stated rules such as how long a quote is valid, how
   time is recorded, who uses which app. Every shared-drive file in full,
   including files in sub-folders: headers, every row, any "effective" or
   "updated" date, and every saved document (quotes, orders).

4. **Concept cross-reference.** Make a list of concepts: customer, job,
   product/model, part, operation/task, stage/status, price, quote validity,
   serial/ID numbers, plus every term the glossary defines. For each concept,
   list every place it lives (app or file) and the exact form used there.
   Then look for every one of these differences and record each one you find:
   - **Shortened names:** a name written in full in one place and shortened
     in another (a company suffix such as "Ltd" dropped; a word abbreviated,
     e.g. "Company" to "Co"; a product/model name written as only its
     code or number). Quote both forms.
   - **Number formats:** the same identifier with and without a prefix or
     separator (e.g. "A-120" vs "120"). Name the app and the identifier.
   - **Code formats:** codes with hyphens in one place and without in
     another; free-text codes typed any way. Quote examples of each.
   - **Missing or renamed list items:** an app's stage/status list vs the
     official list: count both ("uses 5 of the 8 official stages"), name the ones
     missing, quote spelling differences (hyphen vs space, capitals).
   - **Missing rows:** an app holding fewer rows than the master (say how
     many, which).
   - **Defined but never recorded:** a concept the business notes define or
     require that no app or file actually records (for example a serial
     number nobody stores, or a rule that work is tracked at a finer level
     than any app tracks it). Say which app comes closest and what it records
     instead (e.g. "the timer records time per job, but the business notes
     say time is booked per operation").
   - **Rules that disagree:** a rule stated one way in the notes and another
     way in a document (e.g. a validity period, a tax rate, a unit).

5. **Value cross-check.** Compare like with like, item by item:
   - every price in an app against the price list: name each item whose price
     differs, with both values and the price list's effective date;
   - every part cost in an app against the parts file (same part even if the
     code is spelled differently): name each difference with both values;
   - every job row in an app against the jobs file: name each job whose stage
     or customer differs, with both values;
   - every saved quote or order document against the **current** price list
     and the business rules: did it use old prices (which items, both values,
     total difference), a different validity period, a different tax rate?
     If it was written before the price change, say so; it matters because
     the app still produces those prices.

6. **Copied code.** Look across all apps for the same code written more than
   once: functions with the same or a similar name or body (formatting money,
   formatting dates, saving/loading, rendering a table); the same one-liners
   (`toFixed`, `toLocaleString`, `toISOString`, `localStorage.setItem`); and
   the same `<style>` blocks (header colour, font, padding). Grep for
   `function `, `toFixed`, `toISOString`, `background:`, `font-family` if you
   have not already read every app. For each repeat record:
   - the function or block by its name in the code, and the count and names
     of the apps it is in ("`money()` is copied into 2 apps: A and B");
   - identical or drifted, and the drift by its **effect** in plain words
     (e.g. "the copy called `fmtMoney` in C rounds to whole dollars and drops
     the thousands separators: $1500 instead of $1,500.00");
   - for styles, the exact values that drift (each hex colour, font, padding,
     and which apps have which);
   - for dates, whether `toISOString()` is used for "today": that gives the
     UTC date, so the date is wrong for part of the day outside UTC. Say how
     many apps copied it.

7. **Risks.** Per app and overall: data kept only in the browser
   (`localStorage`: one machine, one browser, lost when browsing data is
   cleared, never written back to the shared files, so changes made in the
   app never reach the spreadsheet); no backup; hard-coded copies of a master
   list that go stale (name what is already stale); identifiers that differ so
   lists cannot be matched up; free text that can never be totalled or
   reconciled; no sign-in (anyone with the file sees everything); anything
   else you saw. Say plainly what is lost if a laptop dies tomorrow.

8. **Write it down.** Read `docs/assessment/TEMPLATE.md` and
   `docs/assessment/SUMMARY.md` (if `SUMMARY.md` is still the blank
   template, fill it; if it already has content, update it). Then, in one
   turn, write:
   - `docs/assessment/<app-folder-name>.md` for **every** app, from
     TEMPLATE.md: Stage is `Prototype` unless the evidence says otherwise;
     "Relied on by" from the business notes if stated, else "unknown";
     Builder/Opened how/Copied into repo: from the notes or "unknown"; the
     Data table; Shared concepts with the local name and where stored;
     **Duplication spotted** as bullets in exactly this shape:
     `- <concept or screen> — also in <app or file> — same data / same logic / differs how: <exact difference>`;
     Exposure; If it vanished tomorrow; Verdict in plain words; Candidate
     next step (one of the template's options).
   - `docs/assessment/SUMMARY.md` for the sponsor: the apps table, the three
     things that matter most, the "same information in more than one place"
     table (every concept from step 4, with which one should be right), if a
     laptop died tomorrow, what to do first, what not to do yet.
   Replace every `<...>` placeholder; fill `{{...}}` names from
   `steadyship.md`. Do not touch `README.md`.

9. **Reply, short.** The files you just wrote hold every row; the reply is
   the first screen, for someone who did not know what to ask. Start with
   one line saying which steps you did and which sources you could not
   check. Then, in plain English, every bullet one self-contained line that
   names the thing, the places and the exact difference:

   **What you have**: one line per app: name, what it is for, who relies on
   it, where its data lives.

   **The three things that matter most**: the three findings from steps 4–7
   with the biggest consequence, each with its exact values quoted (both
   spellings, both prices, the row counts), chosen so that at least one is
   about the same information living in more than one place and at least
   one is about what is lost if a laptop dies. Name every app that keeps
   its own copy of the most-copied list, in one of these lines.

   **What I'd do first**: one to three steps, the first being the one app
   most relied on, and which file should be the single master for its data.

   End with: "The full picture — every row that differs, every copied
   function, every risk — is in docs/assessment/SUMMARY.md and one file
   per app. Say 'show me everything' and I'll put it here."

   Nothing else. No "copied code" section, no full risk list, no
   per-concept table in the reply: that is what the files are for.

10. **"Show me everything" / "more" / "the full list"** (a later turn): give
    the full version from what you read in this conversation, in these
    sections, every bullet one self-contained line: **Where the same
    information lives more than once** (one bullet per concept from step 4,
    the places, the row counts, spellings quoted side by side), **Things
    that don't agree** (every difference from step 5 with both values),
    **Copied code** (every repeat from step 6 with count, apps and drift),
    **What could go wrong** (the risks from step 7, most serious first). If
    that context is gone, re-read `docs/assessment/` and give it from there.

## Rules

- Never modify apps or data files. Write only in `docs/assessment/`.
- Never invent facts: every name, number and spelling must come from a file
  you read. If you did not read it, say "couldn't check".
- Gloss any technical word the first time (e.g. "localStorage, the
  browser's own storage on that one computer").
- Complete in the files, short in the reply: the files hold every row; the
  reply holds the three things that matter and where the rest is. Short
  never means vague: every line in the reply still quotes its exact values.
