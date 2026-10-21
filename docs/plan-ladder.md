# Plan: the ladder and the bar (0.7)

Written 21 Oct 2026, before field-test feedback. This is the plan for the
next set of features, on the branch `feat/ladder`. Releases stay at 0.6.1
until the first business has reported back; this merges as 0.7.0.

## Why not "graduate the app"

The proposal's V0 scope says: assess all apps, graduate one, converge one
concept. A single "graduate the job board" skill would be the rebuild our
own rules forbid, and a person who says "not yet" to it gets nothing. The
unit of work is smaller: **one rung, one question, one change, one line in
the record, under an hour.** Convergence is not a skill at all; it is a
glossary with an owner and a master-file pointer per concept, applied one
app at a time as each app is next touched.

Underneath the rungs sits **the bar** (`plugin/standard/STANDARD.md`): the
hundred small questions a real engineer carries, written down with the
acceptable answer at each stage and the default Steadyship picks, so the
builder never chooses and the agent never defaults to quick-and-dirty.

## The ladder

Rungs from Prototype to Owned tool, in order. Each is a section of one
skill, not a skill each.

| Rung | What happens | The one question |
|---|---|---|
| 1 Name it | Catalogue entry: purpose, who uses it | none (assess does it) |
| 2 Own it | A named owner; the five non-functional questions (how many users at once, offline, what if it is down a day, personal data, who changes what) | who is responsible for this app? |
| 3 Test it | A Playwright smoke test: opens, no console errors, main screen with real data, one happy path | none; stated in one line |
| 4 Move its data | Out of the page or browser storage into one master file on the shared drive with one writer, via the local serve script | which file is the master? |
| 5 Share it | A second person can open it (serve script now, hosting later) | who else needs this? |
| 6 Protect it | Backup confirmed, sign-in where hosted | later |

Every app's assessment file records which rungs are done (the **ledger**).
Status reads it ("the job board has an owner and a test; next is moving its
data"). Review's verdict is derived from it, so "Not yet" always names the
missing rung. Assess, review, status and ask all look at one list.

## How agents keep heading up

- **"While I'm in here."** Ask already runs before every change. It gains a
  rule: when it touches an app, it proposes the next rung for that app,
  once, in one line, and "not now" is a fine answer.
- **Standing rules inside any change** (from the bar's free habits):
  snapshot before restructuring; when a change writes data, ask where that
  data lives today and point at the master if it is a copy; check business
  terms against the glossary; one line for any dependency added; one test
  for the thing changed.
- **Stage triggers.** When the bar's trigger for a stage move is met, the
  skill states the move with the reason and the option to defer; it never
  drifts into it.

## What gets built, in order

1. **The bar** (`plugin/standard/STANDARD.md`): free habits, the stage
   table, the regret list, what we lean on. Assess, review and ask all read
   it, so it is first. Argue with the rows before anything is built on them.
2. **Companion plugins.** The setup script installs the baseline set on
   Claude Code (feature-dev, code-review, pr-review-toolkit,
   security-guidance, frontend-design, code-simplifier); in Claude desktop
   the setup report names them once as optional. Superpowers and the
   Playwright plugin are on demand (the bar says why). Every call to one
   is optional and reports "not run" when absent, as the second opinion
   does today.
3. **Assess writes the engineering profile**: every row of the bar answered
   by reading, per app; the reply shows only the rows failing at the current
   stage. The ledger lives in the same file.
4. **Review verdicts against the bar** for the stage the business wants to
   rely on, runs the tests first, cites the result, and sends the bar as the
   brief to the independent reviewer.
5. **Ask consults the rows a change touches**, applies the stage default in
   one line, asks only for business knowledge, adds one test per change,
   proposes the next rung.
6. **The "what's next" skill** (`steadyship-next`): names the next rung for
   an app, does it, records it. "What's next for the job board?"
7. **The serve script** for rung 4: double-click to run; serves one app and
   reads and writes its master file; one writer; plain messages when the
   drive is unreachable or the file is open in Excel; never loses what was
   typed; writes that cannot half-complete; UTF-8 with BOM so Excel reads
   it.
8. **The new-app template** carrying the free habits: structure, the
   stage banner, theme tokens from the business brand file, the escaping
   helper, the data layer with validation and the value forms, the table
   helper that renders only the rows on screen, error display, print styles, a smoke test, a README, JSDoc shapes.
9. **Machine checks** in the generated repo's `scripts/validate.sh`: format,
   lint, browser-baseline check, JSDoc type check, secret scan, dependency
   allowlist, escaping check, accessibility scan, screenshots at three
   widths, a row-count budget. Review cites them.
10. **The reference app**: the demo job board taken to Owned tool and kept
    in the plugin as the exemplar.

## Assumptions (my recommendations, pending your answers)

- Graduation first, convergence second; the data rung is the convergence
  of that concept.
- Rung 4 uses the local serve script, not the browser's file-access
  permission (any browser, one writer, stepping stone to hosting).
- Hosting is deferred until after field-test feedback; the ledger records
  "hosted: not yet".
- The demo job board is the development target; the skill is proven on it
  before it meets a real app.
- The other-vendor reviewer waits; the brief is written so it needs no
  second integration when it comes.
- The glossary owner is asked at rung 2 of the first app that needs it, not
  at init.

## How we know it worked

- Judgement eval: new cases where "make the job board track hours" must
  produce a build that uses the CSV library, escapes data, keeps the theme,
  stays responsive, adds a test, and proposes the next rung in one line.
- The existing eval does not regress on brevity.
- A fresh-VM run (Windows, Claude desktop) of: What's next for the job
  board, four times, ending with jobs in Jobs.csv on the shared drive and a
  smoke test passing. Also verifies whether hook-based companion plugins run
  inside Claude desktop.
- Plugin-uninstalled test still passes: the serve script and tests work
  without Steadyship.

## Out of scope for 0.7

Hosting with sign-in, the other-vendor reviewer, a database stage, model
routing, anything that stores state outside the repository.

## Status, 21 Oct 2026

Built on the branch, validated, CI green:

| Step | State |
|---|---|
| 1 The bar | reviewed by Chris; value forms, edges, banner, browser baseline, time zones, long lists, types added |
| 2 Companion plugins | setup.sh installs the baseline six; desktop names them once; superpowers and playwright on demand |
| 3 Assess profile and ledger | every assessment has the profile tables and the ladder; checked in an eval trace |
| 4 Review against the bar | runs `scripts/test.sh`, names failing rows, cites the ladder, hands the bar to the reviewer |
| 5 Ask rules | builds to the bar, one test per change, new apps from the template, next-rung offer once |
| 6 `steadyship-next` | written; eval cases s4 and s5 |
| 7 Serve script | `scripts/serve.mjs`, tested by `tests/test-serve.sh`; Papa Parse vendored in `lib/` |
| 8 New-app template | `apps/_template`, `lib/steadyship.js`, `lib/theme.css`, `tests/_template` |
| 9 Machine checks | `scripts/checks.sh`; eslint with the browser baseline, prettier, tsc; notes at Prototype, enforced from Owned tool |
| 10 Reference app | not done: graduating the demo job board would remove the defects the assess eval is scored on. `_template` is the exemplar until a separate reference business exists |

Still to do before this merges as 0.7.0: run the next skill for real on a
scratch copy of the demo (rungs 2, 3 and 4 in turn, with a person answering);
a fresh-VM run of the quick start including a rung; confirm that hook-based
plugins and other plugins' agents are reachable from Claude desktop; README
and the website's features page updated to what then exists.

## Revised 22 Oct 2026: hack, then promote

The cut-planner experiment (`docs/experiment-cut-planner.md`) showed the
plugin's cost is paid at the start of a build and its value later. The
design in `docs/superpowers/specs/2026-10-22-hack-then-promote-design.md`
moves Steadyship out of prototyping: prototypes are built as asked; two
foundation conversations (data, security) happen once on a stronger model;
`steadyship-promote` turns a prototype into an Owned tool unattended after
one message of product questions; `steadyship-finish` is the gate before a
change lands on a relied-on app; the shape every app shares is written at
the first promotion and upheld from then on. The rungs above stand; promote
does 2 to 4 in one go. Built, tested on the VM (run 3) and merged as
0.7.0; the look script, the test-first rule and the engineer agent were
added after run 3 and have had one VM test each or none.
