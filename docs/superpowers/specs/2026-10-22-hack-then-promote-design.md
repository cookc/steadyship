# Design: hack, then promote

Written 22 October 2026 after the cut-planner experiment (run 2). This
revises the 0.7 plan in `docs/plan-ladder.md`. Branch `feat/ladder`.

## Intent

Steadyship stops shaping prototypes. A builder hacks freely; Steadyship's
turn comes when someone else is about to rely on the thing, and at the
moment a change on a branch becomes part of a relied-on app. Underneath
both sit three written foundations the business owner cares about and can
answer for: their **data**, their **security**, and the **shape** their
apps share. Those are set once, early, by a stronger model, and re-checked
over time.

## Why (what run 2 showed)

- The plugin's cost is paid at the start (three times the time to a first
  build) and its value is realised later (settings apart from code,
  decisions that survive a week, refusals, tests). Most prototypes are
  thrown away. Paying at promotion puts the cost where the value is.
- Auditing a working prototype produces better product questions than
  asking before anything exists: "people type the sheet size into the
  notes field, should it be its own column?" is answerable in seconds and
  is purely about the business.
- Every item enforced by a template or a check held at 10 of 10; the one
  item that needed judgement (look at the drawing) failed in all four
  runs. Architecture must be a written artefact that is checked, not a
  behaviour that is requested.
- Claude desktop puts each conversation on its own branch by default. A
  merge gate turns that defect into the product.
- Data shape and security are the two things a business cannot retrofit
  cheaply once real data exists, and the two things an owner already has
  opinions about. They do not care about code.

## Goals

1. A prototype built in a Steadyship repository is built the way the
   builder asked, with one signpost line and nothing else.
2. "Promote the cut planner" turns a prototype into an Owned tool: an
   audit, product-only questions in one message, then an unattended rebuild
   that behaves the same for the same inputs except where an answer said
   otherwise, with a morning note in the builder's language.
3. "Finish" is the gate: the change on this branch is reviewed against the
   bar and the foundations, fixed, tested, logged, and merged. The builder
   never learns the word branch.
4. Data and security are each one guided conversation producing a short
   Markdown file of facts and rules, written by a stronger model, with the
   value of the step explained in one paragraph first, and a review
   trigger so the rules are re-asked when the business outgrows them.
5. Architecture (the shape) is written at the first promotion, read by
   every later promotion and finish, and drift is reported.
6. The experiment can tell whether this beats both run-2 arms: the
   Steadyship score at the plain arm's attended cost.

## Non-goals

- No new template parts, no framework, no database. The bar's defaults
  stand.
- No change to the ladder's rungs. Promote does rungs 2 to 4 in one go and
  records them; next still does one rung at a time for anyone who prefers.
- No scheduler. "Overnight" means "unattended after the answers"; how it is
  scheduled is a later product question (headless `claude -p` or the
  desktop's scheduled tasks both exist).
- No attempt to make Sonnet step back on its own. The stronger model is
  forced where the decisions are expensive; elsewhere the written shape and
  the checks carry the load.

## Anti-goals (failure even if it works)

- The promoted app behaves differently from the prototype in a way the
  builder did not ask for. They stop trusting the morning note.
- The data or security conversation asks anything technical. The test for
  every question: would the owner have an opinion without knowing what
  code is?
- Prototyping gets slower. Measured: time to first usable layout must match
  the plain arm.
- A builder never promotes because nothing tells them to. The signpost and
  status nag exist for this.

## Constraints

- Skills stay business-agnostic (no customer facts in `plugin/`).
- Builder-facing language throughout; technical words glossed once.
- GitHub stays hidden; merges are local; nothing is pushed by a skill.
- Secrets never land in files or replies.
- Sonnet is the builder's model. The foundations and promote force a
  stronger one through the skill's `model` frontmatter and say so in one
  plain line. Claude Code docs confirm `model:` in SKILL.md applies for the
  turn the skill is active; behaviour in Claude desktop is unverified and
  the experiment checks it (the transcript records the model per message).

## The flow, as the builder sees it

1. Setup (init) ends with: "Build whatever you like in `apps/`. When
   someone else is about to rely on one, say *promote the <app>*. Before the
   first promotion I'll want two short conversations, about your data and
   about your security; they take ten minutes each and they are the
   decisions that are expensive to undo later."
2. Hacking. Any change request for a Prototype app or a new app: the ask
   skill reads the stage, says one line ("This is a prototype, so I'll
   just build it. When someone else is about to rely on it, say *promote
   the <app>*.") and builds as asked. No questions, no template, no bar.
   Apps at Owned tool or above get the ask skill as today.
3. Data (`/steadyship-data`), once. Security (`/steadyship-security`),
   once. Each: one paragraph on why, exploration of the drive and the apps,
   questions in one message, answers, a written file, and the review
   triggers.
4. Promote (`/steadyship-promote <app>`). Audit; product questions in one
   message; after the answers, no further questions: shape written or
   checked, characterisation tests, rebuild from the template at Owned tool,
   verification, changelog entry, stage and banner moved, commit. Reply is
   the morning note.
5. Finish (`/steadyship-finish`). On a branch with changes to an app at
   Owned tool or above: review the diff against the bar, data, security and
   shape; fix; add the missing test; run validate; changelog entry; merge
   into the main branch; delete the branch. For a Prototype: merge with one
   line. One product question at most; if it is needed, stop before the
   merge.
6. Over time. Status lists the foundations and their dates and nags about
   prototypes with real data. Next proposes a re-look at data or security
   when a trigger is met (a file past the budget, two writers, a new kind of
   personal data, six months passed). Assess and review read the shape and
   report drift.

## The files

All under `docs/context/`, beside `engineering.md` and `decisions.md`.

### `data.md` (written by steadyship-data)

- Why this file exists, two lines, for the owner.
- **The things the business keeps**: one row per kind (jobs, customers,
  parts, prices, staff, quotes...): what it is in their words, the master
  (file and location, or "nowhere yet, lives in people's heads"), who
  writes it, who reads it, copies that exist elsewhere, what must never be
  lost, whether it is personal, how long it must be kept and why.
- **Rules**: one master per thing; apps read a thing from its master and
  never keep a second copy; a value that exists only in free text gets its
  own column; new kinds of information are added here before an app stores
  them; the file budget; when a database is the answer (two people writing
  at once, or past the budget) and that it is a decision to be stated, not
  drifted into.
- **Review**: date written, by whom; the triggers that re-open it.

Relation to what exists: business notes hold the glossary and how work is
organised; `engineering.md` holds facts the bar cannot know; `data.md` is
the owner's map of their information and the rules apps must follow. Assess
reads apps; data asks the owner. Ask, promote, finish, review and next read
`data.md` when it exists.

### `security.md` (written by steadyship-security)

- Why, two lines.
- **Who and what**: who works here and what each may see; which data would
  hurt if it left (the customer list, prices, staff details, drawings);
  where files live and who holds the laptops; what is shared outside and
  how; who has the passwords and where they are kept; what is backed up,
  by what, and whether a restore has ever been tried; what happens when
  someone leaves or the builder is away.
- **Rules**: no secrets in files or apps; personal data named here and
  nowhere in sample data; sign-in required the day an app is hosted; which
  apps need to be kept from whom; backup owner; off-boarding steps.
- **Review**: date, triggers (a new person, hosting, personal data appears,
  six months).

### `shape.md` (written at the first promotion, read by every later one)

- One page. The parts every app is made of (from the bar); what lives in
  `lib/`; where data lives (points at `data.md`); how apps relate (through
  master files, never directly); naming; what each app owns, one line per
  app; what is shared and why; the list of things that must not be done
  twice.
- A promotion or finish that would break the shape says so and either
  conforms or proposes a change to this file, in one line, recorded in
  `decisions.md`.

## Skills

New, all with `model: opus` where marked, and `disable-model-invocation`
left off so they can trigger on the builder's words.

- **steadyship-data** (opus). Steps: where things are; one paragraph on why
  and the model line; read business notes, `engineering.md`, every app's
  data table, a Glob of the drive and the head of every CSV and sheet on
  it; draft the things table from what was found; ask in one message, at
  most eight questions, each with the recommended answer and the file that
  prompted it, every one about the business; on the answers (a later turn,
  the skill re-triggers) write `data.md`, record it in `decisions.md`,
  commit, and reply with the three rules that matter most to them and the
  review triggers.
- **steadyship-security** (opus). Same shape; reads the drive's layout,
  the repo's secrets check, hosting and sharing facts; at most eight
  questions; writes `security.md`.
- **steadyship-promote** (opus). Steps: where things are; require
  `data.md` and `security.md` (if missing, one line each on why and stop);
  read the app in full, its tests, its assessment if any, the foundations,
  the shape if any, the bar, the drive; audit (what it does, inputs,
  outputs, values typed into code, free text parsed, settings on the page,
  what it records and where, who uses it, what could leave the app, what
  already does this elsewhere); write or refresh `docs/assessment/<app>.md`;
  ask at most five product questions in one message with recommendations,
  including build-or-buy where a tool plans, nests, prices or schedules,
  and "which file is the master" where the data has none; stop. On the
  answers: record in `decisions.md`; write `shape.md` if missing or check
  against it; characterise (run the prototype on the real inputs on the
  drive, keep its outputs as fixtures under `tests/<app>/fixtures/`, and
  write Node or Playwright tests that assert them, minus what an answer
  changed); commit as "before promotion"; rebuild from `apps/_template/`
  with the parts the app needs, at Owned tool, data per `data.md`, nothing
  typed into code, settings in a file on the drive, a verifier for anything
  that leaves the app; run the characterisation tests, the app's tests,
  `scripts/validate.sh`; look at any produced output against the inputs;
  write `apps/<app>/CHANGELOG.md` entry in the builder's language (what
  changed and why, what to look at, what was left out); set the stage to
  Owned tool, the banner, rungs 2 to 4 with evidence; commit; reply with
  the morning note. After the answers, no further questions: a decision
  that cannot be made takes the bar's default and is named in the changelog.
- **steadyship-finish** (default model). Steps: where things are; find the
  branch (`git branch --show-current`), the main branch and its checkout
  (`git worktree list --porcelain`, first entry); if on the main branch,
  say there is nothing to finish; diff against the main branch; find the
  apps touched and their stages; for Prototype-only changes, merge with one
  line; otherwise review the diff against the bar's free habits and stage
  rows, `data.md`, `security.md`, `shape.md`, `decisions.md`; fix what can
  be fixed without a product decision; add one test for the behaviour
  changed; run `scripts/validate.sh` and the app's tests; changelog entry;
  commit; merge into the main branch with `--no-ff` from the main checkout
  (refuse, plainly, if that checkout has uncommitted changes); delete the
  branch; reply: what is now part of the app, what was fixed, what was
  tested. One product question at most; if asked, stop before the merge.
- **ask**: step 1 reads the stage; Prototype or no assessment file gives
  the signpost line and a plain build (no questions, no template, no bar
  rows, no decision record). Everything else unchanged.
- **next**: a foundations check first: missing `data.md` or `security.md`,
  or a review trigger met, is proposed before any rung. Promote's recorded
  rungs are honoured.
- **status**: a "Foundations" line (data, security, shape: present with
  date, or missing with the sentence to say), and a list of prototypes
  whose data folder or master file has grown since the assessment ("real
  data is going into the <app>; time to promote it").
- **review** and **assess**: read `shape.md` and `data.md` when present;
  review's verdict names shape drift as a failing row.
- **init**: the closing lines in step 1 of the flow above.
- **check**: unchanged.

## The bar

- A short section "When the bar applies": Prototype, nothing but the
  signpost; promotion, every row at Owned tool; finish, the rows a change
  touches; the foundations are read before every promotion, finish, review
  and assessment.
- Section 6 updated for the new skills.
- A defaults row "Model": the builder's model for building; a stronger
  model, forced by the skill, for data, security and promote, with one
  plain line saying so, because those are the decisions that cost most to
  undo and the token cost is visible while the cost of a bad decision is
  not.
- Regret list: "a prototype promoted without the data and security
  conversations"; "a promotion that changed behaviour nobody asked for".

## Checks

- `foundations` at repository level: NOTE when `data.md` or `security.md`
  is missing; FAIL when any app is at Owned tool or above and `shape.md` is
  missing.
- `changelog`: an app at Owned tool or above has `CHANGELOG.md`.
- Existing checks unchanged.

## Templates

- `apps/_template/CHANGELOG.md` with one entry format.
- `docs/context/README.md` naming the three foundation files and the
  sentence that creates each.
- `tests/_template/fixtures/README.md` explaining characterisation
  fixtures.

## The experiment (arm C)

Same five prompts and the week-later prompt as run 2, Sonnet, Windows VM.
Fresh state per arm: the old experiment folders and demo repositories are
deleted from the VM before each arm, not hidden.

Arm C, in one Steadyship demo repository with the plugin installed:

1. Prompts 1 to 5 as the builder, expecting plain builds with the signpost.
2. "Set up my data" and "set up my security", answered from a scripted
   answer sheet in the checklist (the Demo Boatworks facts).
3. "Promote the cut planner"; answer the questions from the sheet; leave
   it to run.
4. Week-later prompt in a new conversation on the promoted app, then
   "finish".

Measure: the same 30 items at the end, blind-scored as before; time to the
first usable layout (target: the plain arm's); builder-attended minutes
(target: well under the Steadyship arm's); same-inputs same-outputs between
the prototype and the promoted app on the real job (target: identical except
for what the answers changed); whether the forced model took effect (the
transcript's model field); three foundation items scored separately
(data.md followed, security.md followed, shape.md followed) and not added
to the 60.

Abandon the approach if the promoted app scores no better than the plain
arm's week-later, or if the rebuild changed behaviour nobody asked for.

## Build order

1. Bar and checks (the rows and the two checks).
2. Templates (changelog, context README, fixtures README).
3. steadyship-data, steadyship-security.
4. steadyship-promote.
5. steadyship-finish.
6. ask, next, status, review, assess, init edits.
7. Validate the generated repository (`tests/test-init.sh`), run the
   plugin's own validation.
8. Checklist additions and answer sheet in `docs/experiment-cut-planner/`.
9. Arm C on the VM; blind score; report.

## Left to the builder

- Exact wording of questions inside each skill, within the "owner would
  have an opinion" test.
- How finish detects the main checkout and refuses safely.
- How characterisation fixtures are stored and compared (JSON of outputs
  per real input is the obvious choice).

## Calls made after the builder check

A reviewer read the design cold and asked six questions. The answers are
the builder's calls, not the owner's decisions.

1. **Branches and the desktop's worktree default.** Every Steadyship skill
   that writes ends by *landing* its commit on the main branch, through one
   shared routine (`plugin/standard/landing.md`): when the session is on a
   `claude/...` branch inside `.claude/worktrees/`, merge it into the main
   branch from the main checkout, `--no-ff`, only if that checkout is clean;
   say in one line what happened; never remove the branch or the worktree
   the session is running in. Prototype builds land freely (no gate).
   Changes to relied-on apps land only after ask or finish has reviewed
   them: that is the gate. Finish is the explicit "I'm done" for a change
   made without the plugin's help. Promote lands the prototype first if it
   is only on an unmerged branch.
2. **"Behaves the same"** means computed values, produced files and what is
   written to the master file, never the page's structure. A recording
   page is characterised by the records it held and their fields, through a
   Playwright test that enters a record and checks the written row.
3. **Real data inside the prototype.** In scope, in the attended turn. If
   the prototype keeps records in browser storage, promote adds an Export
   button to the prototype as its first commit and the questions message
   asks the builder to press it and save the file to the drive; the rebuilt
   app starts from that file. If they do not, the rebuild starts empty and
   the changelog says the old records are one commit back, still openable.
4. **Fixtures and personal data.** Inputs are copied into
   `tests/<app>/fixtures/` with the columns `data.md` marks personal
   replaced by placeholders; outputs are JSON. `security.md`'s rule names
   fixtures. Tests never read the drive.
5. **Prototypes and the assessment file.** The prototype path creates no
   assessment file; promote writes it. Status nags on any app folder
   without an assessment file whose first commit is more than 14 days old
   ("the <app> has been around for three weeks with no owner; if anyone
   else uses it, say promote"). Next, on such an app, says "say promote"
   instead of "assess first".
6. **The worktree after a merge.** Left alone. A later tidy is next's job,
   not finish's.
