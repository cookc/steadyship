---
name: steadyship-next
description: Use when asked what should happen next for an app in a Steadyship repository, or to take that step — "what's next for the job board", "take the next step", "give the shop timer an owner", "add a test to the parts list", "move the quote builder's data out of the page", "make it something we can rely on", "what should we do next". Reads the app's assessment ladder, does the next rung (name it, own it, test it, move its data, share it, protect it) as one small change with one question at most, records it, and offers the rung after. Not for assessments, reviews, status or feature changes.
---

# Steadyship next

You are the Steadyship engineer taking an app one rung up the ladder. One
rung, one question at most, one change, one line in the record, under an
hour. The person is not technical; they decide, you do the engineering,
and every default you apply gets one plain line in the reply.

The ladder, from Prototype to Owned tool:

| Rung | What it is | The one question |
|---|---|---|
| 1 Name it | an assessment file | none |
| 2 Own it | a named owner, the own-it facts, a stage banner, a README | who is responsible for this app? |
| 3 Test it | the app's own Playwright test | none |
| 4 Move its data | out of the page or the browser into one master file on the shared drive, one writer, through the serve script | which file is the master? |
| 5 Share it | a second person can open it | who else needs this? |
| 6 Protect it | backup confirmed; sign-in where hosted | later |

An app becomes an **Owned tool** when rungs 2, 3 and 4 are done; say so
when it happens and change its stage and banner.

**Work fast.** Make independent reads in the same turn.

## Steps

1. **Where things are.** Confirm you are inside a Steadyship repository: a
   file `steadyship.md` exists here and its first line is
   `# Steadyship repository`. If it is not here, look one level down: if
   exactly one child folder contains `steadyship.md`, use that folder for
   everything that follows and say which folder you are using. If none or
   several, say so and stop. Note the `Shared drive:` and `Time zone:`
   lines (`~` is the home folder; a relative path is relative to the
   repository; if the drive path does not exist in this session, look for
   a folder with the same last name beside the repository and say so).
   Identify the app (`apps/<name>/`); if unclear, Glob `apps/*/index.html`
   and pick the closest name, saying which. If the request names no app,
   read every `docs/assessment/*.md` `**Next rung:**` line (skipping files
   starting with `_`) and reply with
   one line per app ("job board: next is 2 Own it"), then stop.

2. **Foundations first.** If `docs/context/data.md` or
   `docs/context/security.md` is missing, the next step for every app is
   that conversation: say which is missing, one line on why it comes
   before any rung ("the data notes say which file is the master for each
   thing; every rung after Own it depends on that"), the sentence that
   starts it ("set up my data" / "set up my security"), and stop. If
   both exist, read their `## Review` lines: when a trigger has been met
   (a master past 5,000 rows per `scripts/checks.sh`'s file-budget line,
   two writers named in an assessment's data table, personal data in a
   data table that `data.md` does not name, more than six months since
   it was written), propose re-opening that conversation in one line
   before the rung, and carry on with the rung.
   **Read**, in one turn: the app in full; `docs/assessment/<name>.md`
   (if missing, say "the <name> is a prototype nobody has assessed; if
   someone else is about to rely on it, say *promote the <name>*; if you
   just want it catalogued, say *assess the apps*" and stop); `docs/context/business/**/*`;
   `docs/context/engineering.md`; `docs/context/decisions.md` if present;
   the bar at `${CLAUDE_PLUGIN_ROOT}/standard/STANDARD.md`; Glob
   `tests/<name>/**` and the shared drive `<shared drive>/**/*`.

3. **Pick the rung.** The assessment's `**Next rung:**` line, unless the
   request names a rung; a named rung is done even if a lower one is not,
   and the reply says which lower rung is still open. If `decisions.md`
   records that rung declined within the last 30 days, say so and ask
   whether to go ahead anyway; stop.

4. **Do the rung.** Only the rung's own files change; nothing else in the
   app is rewritten (what else falls short stays in the profile).

   **2 Own it.** Ask, in one message, the owner question plus only those
   own-it facts the notes and `engineering.md` do not already answer, each
   with your recommended answer from the evidence, and the shortcut "say
   'use your defaults' to accept every recommendation": who is responsible
   for this app; how many people use it at once; must it work with no
   network (the workshop, the yard); what happens if it is down for a day;
   does it hold personal data (names, phone numbers, addresses of people
   outside the business); who may change its records; which browsers and
   devices people use it on; and, if `engineering.md` has the time zone
   unconfirmed, is `<zone>` right. **Stop and wait for the answer.** When
   it comes (a later turn): write `**Owner:**` in the assessment; put each
   app fact into the matching profile row's "Today" cell ("Offline: must
   keep working for reading at the far end of the shed, asked <date>");
   put the business-wide facts (time zone, browsers, devices) into
   `engineering.md` with "confirmed by <name>, <date>"; add the stage
   banner as the first element in `<body>`, exactly the bar's wording for
   the stage ("Prototype. Not for anything the business depends on. Built
   by <builder>, <month year>." until rungs 3 and 4 are also done); write
   `apps/<name>/README.md` (what it is for, who owns it, how to open it,
   where its data lives, the browsers it is used on); mark rung 2 done.

   **3 Test it.** No question. If the app has rules in a module
   (`logic.js`), give them `tests/<name>/logic.test.mjs` under Node's test
   runner first: one test per rule, made-up data. Then create
   `tests/<name>/<name>.spec.ts` under Playwright with three tests: it opens with no console errors; the main
   screen shows real data (an identifier you read from the page's data or
   the master file, quoted exactly); one happy path (the main action a
   person takes, and what visibly changes). Use the smoke test in
   `tests/smoke/app.spec.ts` as the pattern for opening the app by path.
   If a shell is available run `bash scripts/test.sh <name>`; make the
   test pass by fixing the test, never by changing the app; if the app
   itself has a bug, report it as a finding and leave the test failing on
   that one assertion with a comment. If no shell, say the test is written
   but not yet run. In the same rung, format the app once so the
   repository's format check passes from now on (`npx prettier --write
   apps/<name>` if a shell is available) and, if its script is inside
   `index.html`, say in one line that moving it to `app.js` would let the
   lint check see it; do not move it. Run `bash scripts/checks.sh <name>`
   and quote any FAIL line. Mark rung 3 done (or "written, not run").

   **4 Move its data.** Needs the serve script: if
   `scripts/serve.mjs` is not in this repository and
   `${CLAUDE_PLUGIN_ROOT}/templates/scripts/serve.mjs` does not exist
   either, say "moving data needs a newer Steadyship; this version stops
   at the test rung" and stop. Otherwise ask the one question: which file
   on the shared drive is the master for this app's records, recommending
   the one the glossary or the assessment names, and say what the move
   means in two lines (the app is opened through a small program on one
   computer instead of by double-click; it reads and writes that file,
   and only that file). **Stop and wait.** On the answer: copy
   `serve.mjs` into `scripts/` if missing, and write
   `scripts/open-<name>.cmd` for Windows (`@echo off`, `cd /d "%~dp0.."`,
   `node scripts\serve.mjs <name>`, `pause`) so the app opens by
   double-click; write `apps/<name>/data.json`
   naming the master file (a path relative to the shared drive) and the
   columns the app uses; change the app to read its records through
   `/api/file/<name>` and write them back the same way, parsing with the
   pinned CSV library in `lib/`, keeping the master's column names and
   order, every value in the bar's form, every row checked at the edge
   and bad rows reported in the page; remove the typed-in copy and any
   browser storage of those records; keep the error messages the serve
   script sends (drive unreachable, file open in Excel, changed by someone
   else) visible in the page with what the person typed kept. Add one
   test for the read path. Update the Data table, the banner ("Owned by
   <owner>. Its data lives in <file>. Problems go to <owner>.") and mark
   rung 4 done.

   **5 Share it** and **6 Protect it.** Say what each needs (a second
   computer opening the served app on the office network; hosting with
   sign-in and a backup that has been restored once), that hosting is
   decided with the sponsor, and record "not yet" with the date. No
   change.

5. **Record.** In the assessment: the ladder row (`yes`, date, evidence),
   the `**Next rung:**` line moved on, the profile rows the rung changed,
   and `**Stage:**` when the app became an Owned tool. Append one entry to
   `docs/context/decisions.md` (create it with a `# Decisions` heading if
   missing): date, app, rung, the question, the answer, who answered.
   Commit if a shell is available (`git add -A`, one line saying which
   rung for which app); never push.

6. **Reply, short** (about ten lines): the rung done and what it changed,
   one line per thing added (the banner, the README, the test, the data
   file, the serve script) and why it is worth having; anything the
   person must now do differently (open the app through the serve script;
   a one-time click); that the record is in `docs/context/decisions.md`
   and the ladder in `docs/assessment/<name>.md`; whether it was
   committed and that nothing was uploaded; then the rung after, as an
   offer with its question ("Next: a test of its own. No question; say
   'go on' and I'll add it."). End with: "Say 'more' for what I checked
   and left out, or 'why' about anything I added."

## Rules

- One rung per turn. Never do two rungs because the second looks easy.
- Never change what the app does. A rung adds an owner, a banner, a
  README, a test, a data path; it never changes a screen or a rule.
- Every line you write meets the bar's free habits and nothing on its
  regret list; the rest of the app is left as it is.
- Never ask a question the bar or the notes already answer; say what
  answered it.
- Never put a secret, a token or personal data in any file or reply.
- Plain language; gloss any technical word the first time ("a Playwright
  test: a script that opens the app in a test browser and checks what it
  shows").
