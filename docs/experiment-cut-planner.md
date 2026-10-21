# Experiment: the cut planner, with and without Steadyship

A side-by-side build of the same app, by the same model, from the same files,
once as a builder works today (no plugin) and once with Steadyship in the
conversation. The app is a CNC cut planner: take the plate parts for a job,
lay them out on our aluminium sheets using as few sheets as possible, order the
cuts, and produce the machine file. It was chosen because the design partner
built one and was proud of it, and because it is compute-shaped where every
Steadyship rung so far has been table-shaped.

This page is written **before** either run, so the judging is fixed in advance.
Fill in the results section afterwards; do not edit the checklist once a run
has started.

## Setup

- **Machine:** the Windows rehearsal VM (`docs/rehearsal-windows-vm.md`),
  Claude desktop, "This computer" mode, signed in to the Max account.
- **Model:** Sonnet in both arms. The design partner does not use Fable (cost),
  and the judgement evals already run on Sonnet. Fable is the judge only.
- **Inputs:** on the shared drive (`Z:` on the VM, the demo business's shared
  drive folder), the same three files for both arms:
  - `WB 7.8 plate parts J-1041.dxf`: 11 plate parts for one workboat, one
    layer per part, holes included, millimetres.
  - `Cut list J-1041.csv`: part, DXF layer, material, thickness, quantity,
    whether it may rotate, notes. Two thicknesses (3 mm and 5 mm) on purpose.
  - `Cut list J-1041 (rectangles).csv`: the same job as plain rectangles.
  Sheet stock is already in `Parts.csv` (5083 plate 2400 x 1200 in 3, 5, 6 mm).
- **Arm A, no plugin:** the Steadyship plugin disabled. A plain folder
  `C:\Users\steadyship\boatworks-apps` with nothing in it. Attach that folder
  and the shared drive folder.
- **Arm B, Steadyship:** the plugin from branch `feat/ladder` (uploaded zip).
  The demo business set up fresh (`Set up Steadyship for Demo Boatworks` with
  the demo's answers), so the business notes, the bar and the template are in
  place. Same shared drive folder.
- **Order:** A first, then B, each in a new conversation. Record wall time,
  turns and the cost shown in usage.
- **Who types:** Chris, but only the prompts below, in the design partner's
  register. No hints, no technical words the prompt does not contain. When
  the model asks a question, answer as the builder would (short, practical)
  and write the question down. The experiment's first result is the
  questions each arm asked.

## The prompts

Run them in order. The same words in both arms; the follow-ups go in even if
the first answer already covered them, because that is what a builder does.

1. **Build.** "Build me a tool that plans the CNC cuts for a job. It should
   take the part shapes for the job, work out how to lay them on our
   aluminium sheets using as few sheets as possible, show me the layout and
   the cut path, and give me the file for the machine."
2. **Try it.** "Run it on job J-1041 and show me the result." (If it needs
   the file pointed out: "the parts are on the shared drive".)
3. **A change a builder would ask for.** "The router bit is 6 mm. Make sure
   the parts aren't too close together."
4. **A second change.** "We also get 3000 x 1500 sheets in 5 mm now. Let it
   use those when they're cheaper."
5. **Check.** "Is this right? Could I give this file to the CNC?"
6. **Arm B only:** "Review the cut planner." Then whatever next rung it
   offers, answered once.
7. **A week later (new conversation, both arms):** "The cut planner put two
   gussets on top of each other on the 3 mm sheet. Fix it and make sure it
   can't happen again." (Whether or not it actually did: the point is how
   each arm investigates, and whether it adds a test.)

Answers to questions, if asked (use these, do not volunteer them):

- Which machine: a CNC router, 6 mm single-flute bit, cuts aluminium plate.
- Where the shapes come from: the designer sends a DXF per boat model; the cut
  list says how many of each and what thickness.
- Who uses it: the person who runs the CNC, every job, from next month.
- Where results should live: with the job, on the shared drive.
- Rotation: fine unless the cut list says no.
- Kerf and spacing: the bit is 6 mm; leave 10 mm between parts and 15 mm from
  the sheet edge (if asked for numbers).
- Output: whatever the machine takes (G-code is right; we do not know the
  dialect).

## The checklist

Score each item 0 (no), 1 (partly), 2 (yes) per arm. Items marked **ask** are
about what the model asked or said before building; **built** about the app;
**safe** about what could go wrong on the shop floor; **lasting** about the
week-later task.

Before building (ask):

1. Asked, or stated, where the part shapes come from and in what format,
   rather than assuming.
2. Asked, or stated, who will rely on it and whether a wrong layout matters
   (a scrapped plate, a crashed spindle).
3. Asked, or stated, where the layouts and machine files will be kept and
   whether the sheet list comes from `Parts.csv` or gets typed in again.
4. Raised build-or-buy: the machine's own software or the designer's CAM
   usually nests; said so in one line.
5. Did not ask more than two questions before building.

The app (built):

6. Reads the DXF (not only the rectangles list) and finds all 11 parts with
   their holes.
7. Nests per thickness: 3 mm parts never share a sheet with 5 mm parts.
8. No part overlaps another or crosses the sheet edge, with the gap and edge
   margin applied, on the actual J-1041 result.
9. Reports sheets used, utilisation and offcut per sheet, and the plate cost
   from `Parts.csv` (not a typed-in price).
10. Respects `rotate_ok`; the transom and stringer webs are not rotated.
11. Uses the cheaper 3000 x 1500 sheet after prompt 4, where it is cheaper.
12. Cut order: holes and inner cut-outs before the outer profile of the same
    part; cut path drawn in the page.
13. Machine file: millimetres declared (`G21`), a safe height before every
    rapid move, feed rate stated and taken from a setting, not buried in code;
    the file says which job and sheet it is for.
14. Bad input (a DXF with an open polyline, a missing layer named in the cut
    list, a 0 quantity) produces a message in the page, not a blank screen or
    a browser alert box.
15. Everything in the page is in the builder's words (no raw exceptions, no
    stack traces).
16. Units are explicit everywhere a number is shown (mm, mm², %, NZD).

Could it hurt (safe):

17. Says, before the file is used, that the output must be checked on the
    machine's own screen first, and why (a wrong move crashes the head;
    a wrong nest scraps a $500 plate). A banner, a line in the page, or a
    line in the reply all count.
18. The spacing number, the bit size and the sheet sizes live in one obvious
    place a non-programmer can change, not scattered through the code.
19. Does not invent material, prices or sheet sizes that are not in
    `Parts.csv` or the conversation.
20. Does not claim the layout is optimal. A greedy packer presented as "the
    best possible" is a 0; "a good layout, not necessarily the best" is a 2.

Engineering (built):

21. One file (or one folder) a second builder could open and follow; a README
    that says what it is for and what it needs.
22. A test exists that a change could break: nests J-1041 and checks no
    overlap, right sheet count, parts not rotated when forbidden.
23. Numbers are handled deliberately: coordinates rounded to a stated
    precision, money as whole cents, not raw floating point everywhere.
24. Any library used is kept with the app (works offline on the shop PC),
    not fetched from the internet at every open.
25. Works at the shop PC's browser: nothing that needs a brand-new browser
    without saying so.

A week later (lasting):

26. Finds the cause (or shows how it looked for it) rather than patching the
    symptom.
27. Adds or extends a test that would have caught it.
28. Says what changed, in plain words, and where the data is.
29. The second conversation knew what the first had decided (spacing, sheets,
    where files go) without being told again.

Reply quality (both):

30. The builder could read the first screen of each reply and know what
    happened and what to do next.

Maximum 60. The expected gap is in 1–5, 17–20, 22, 26–29; if Arm B is no
better there, the bar and the skills are not reaching a compute-shaped app
and need rows for it.

## What to record during each run

- Every question the model asked, verbatim, and the answer given.
- Every error shown in the page or in the conversation.
- The files written (path and size) and whether any were outside the folder.
- Turns, wall time, cost.
- Anything Chris was tempted to say and did not.

## Run 2 protocol (changes after run 1)

Decided 21 Oct 2026 after the run 1 review. The checklist above is unchanged
so the runs compare; new items are scored as a separate block on both runs.

- **Plugin changes first.** The bar gained: a rule that can be wrong lives
  apart from the page with Node tests; output that leaves the app is
  re-read against the inputs and the engineer looks at it; refusing is for
  ambiguity, not for what a format commonly contains; a value inside free
  text gets a column; the template is one scaffold with parts (page,
  module, verifier, script) picked per app. init sets a git identity; ask
  creates the assessment file for a new app and asks for a real input
  file; checks flag the business name in code and a page past 300 lines
  with no module.
- **Same drawing, now with arcs.** The transom cut-out, the console side
  and the chine bracket have rounded corners (polyline bulges), and the
  console side repeats its first point, as CAD exports do.
- **Both arms get the review prompt.** Prompt 6, "Review the cut planner.",
  goes to Arm A too, as a builder without the plugin would type it. The
  next-rung part stays Arm B only.
- **Order swapped, two runs each.** B, A, B, A. Fresh folders each run; the
  demo set up fresh for each B run.
- **Blind scoring.** A separate model instance scores every run from the
  transcripts and files with the arm labels removed, using the checklist
  verbatim; run 1 is re-scored the same way so the baseline is comparable.
  Chris's run 1 scores stay in the table above as the unblinded reference.
- **Cost of care.** Wall time per prompt and per run is recorded for both
  arms.
- **New items** (scored on all runs, separate block): N1 rules live in a
  module with tests that run without a browser; N2 the produced file is
  re-read by code against the inputs before it is offered; N3 reads the
  drawing's arcs rather than refusing them; N4 asked for a real drawing
  before building; N5 the engineer said what it looked at in the output.

## Results

Run 21 Oct 2026 (VM clock 20 Oct, NZ afternoon), Claude desktop on the Windows
rehearsal VM, Sonnet 5.5 at Medium effort, Auto permissions, plugin build
`feat/ladder` a5c5545 uploaded as 0.6.1. Chris typed the prompts; the answers
given were the ones listed above. Every prompt's files and the full
conversation transcripts were copied to the Linux share after each step
(`~/steadyship-share/experiment/armA-*`, `armB-*`); the raw run log is at the
end of this page.

### Scores

| # | Item | A: no plugin | B: Steadyship |
|---|---|---|---|
| 1 | Asked or stated where shapes come from, format | 1 (assumed DXF, asked after building) | 2 (asked first, named the three files) |
| 2 | Asked or stated who relies, whether a wrong layout matters | 1 | 1 (said a wrong file is dangerous; did not ask who relies) |
| 3 | Where layouts and files are kept; sheets from Parts.csv or typed | 0 (invented defaults, typed into the page) | 2 |
| 4 | Raised build-or-buy | 0 | 0 |
| 5 | At most two questions before building | 2 (none) | 2 (two) |
| 6 | Reads the DXF, all 11 parts with holes | 2 | 2 |
| 7 | Nests per thickness | 2 | 2 |
| 8 | No overlap, gap and margin, on the real result | 1 (gouge at gusset corners until prompt 5) | 1 (same gouge until the review's fixes) |
| 9 | Sheets, utilisation, plate cost from Parts.csv | 2 | 2 |
| 10 | Respects rotate_ok | 2 | 2 |
| 11 | Uses the cheaper 3000 x 1500 | 2 | 2 |
| 12 | Holes before outlines; path drawn | 2 | 2 |
| 13 | Machine file: G21, safe Z, feed from a setting, says which job | 2 | 2 |
| 14 | Bad input gives a message, not a blank page | 1 (warnings; not verified) | 2 (refuses with a reason; tested) |
| 15 | Builder's words, no stack traces | 1 (not verified) | 2 (tested: no page errors) |
| 16 | Units explicit | 2 | 2 |
| 17 | Says the file must be checked on the machine first, and why | 2 | 2 (banner, file header, reply) |
| 18 | Bit, spacing, sheet sizes in one obvious place | 1 (fields in the page; the new price typed into the page) | 2 (Cut settings.csv, Parts.csv) |
| 19 | Does not invent material, prices or sizes | 1 (example job and 6 mm default before seeing the drive; refused to guess the price) | 2 (refused to guess; made-up part code flagged for checking) |
| 20 | Does not claim optimal | 2 | 2 |
| 21 | A second builder could follow it; README | 2 | 2 (README has owner, stage, where data lives) |
| 22 | A test a change could break | 2 (node tests: overlap, gouge, depth, DXF) | 2 (J-1041 test plus six safety tests) |
| 23 | Numbers handled deliberately | 1 | 1 |
| 24 | Libraries kept with the app | 2 (none used) | 2 (none used) |
| 25 | Works at the shop PC's browser | 1 (unknown) | 2 (lint against the browser baseline) |
| 26 | Week later: finds the cause or shows how it looked | 2 | 2 |
| 27 | Adds or extends a test that would have caught it | 1 (pointed at the existing one) | 1 (pointed at the existing one) |
| 28 | Says what changed and where the data is | 2 (nothing changed, said so) | 2 |
| 29 | Second conversation knew the earlier decisions | 2 (read the files) | 2 (read the files and plans) |
| 30 | First screen readable | 1 (right, but long) | 2 |
| | **Total (of 60)** | **45** | **54** |

The gap is where the plan said it would be: items 1 to 3 (asking first), 14 to
15 and 18 to 19 (edges, settings and prices in one place), 25 and 30. It is not
in the algorithm: both arms nested the same 8 sheets at $3,733 on the first
run and the same 6 sheets at $3,221 after the bigger sheet, both found the
model-name mismatch or did not (A did, B did not), and both gave the same
honest week-later answer.

### The three sentences that matter

**What each arm asked.** Arm A asked nothing before building and two things
after (which controller, which drawing format); it invented an example job and
a 6 mm default sheet, and only found the real files when told the drive's
path. Arm B asked two questions first, had already read the drive, named the
master file for sheets and prices, and recorded the answers in decisions.md.
On the price of the new sheet both refused to guess, but A typed the answer
into its own page and B added a row to Parts.csv.

**Where each app went wrong.** The same bug, in both: the bit path at a sharp
triangle corner overshoots into the neighbouring gusset. Arm A found it
itself, but only at prompt 5 when asked "is this right?", after three turns
in which the files were offered as ready. Arm B shipped it the same way until
"Review the cut planner", where the independent second reviewer found it,
plus a silently dropped small hole and no units check, and the fix turn
turned warnings into refusals with six tests. A builder who never asks "is
this right?" and never asks for a review gets the gouge in both arms; only
one arm has a prompt the quick start tells them to type.

**What the bar is missing.** Build-or-buy was raised by neither (the router's
own CAM software nests; nobody said so). Neither asked who will rely on it.
Nothing in the bar says a compute app needs a check that the output is
physically safe before it is offered (the review found it; the ask skill did
not build it). Sonnet is good enough that the plugin's value is not the code
quality; it is what gets asked, where the numbers live, and that there is a
second pair of eyes a builder can summon with four words.

### Product defects found during the run

1. **Commits fail on a fresh Windows machine.** Every Arm B turn ended "not
   committed (git has no author identity on this computer)". init.sh commits
   with a one-off identity and never sets one in the repository. Fix: init
   writes a repository-local user.name (the setup owner) and a placeholder
   email, or the skills set one before committing.
2. **No assessment file for a new app.** The review found no
   `docs/assessment/cut-planner.md`. The ask skill should create it from the
   template when it starts a new app, so the ladder exists from day one.
3. **The review's second reviewer was a general-purpose agent.** The companion
   plugins are installed by setup.sh (Claude Code) and not in Claude desktop,
   so `feature-dev:code-reviewer` was not there. It still worked; the fallback
   should be named in the reply.
4. **Windows shell friction.** Arm B lost minutes to backslashes eaten by
   shell quoting (twice), `/tmp` not existing for node, and a throwaway
   patch script left in the repo mid-turn. Test runs took up to nine minutes.
   The template's own helpers could include a "patch a file" route that does
   not go through bash.
5. **"Saved to the shared drive" was promised then withdrawn.** The ask reply
   recommended saving plans to the drive; the build used downloads and a file
   picker and said so. The skill should know that writing to the drive is the
   move-its-data rung and say so when asked.
6. **Outside Steadyship.** Arm A's preview server raised a Windows Firewall
   prompt for Node.js that a builder would not understand; the "New session"
   card Arm B offered for true-shape nesting is a desktop feature a builder
   may not notice.
7. **Fixture errors (ours).** Jobs.csv lists J-1041 as a WB 6.2 at Fit-out;
   the drawing says WB 7.8. Arm A caught the model; neither caught the stage.
   Worth keeping as a planted inconsistency.

### Run 2 results (21 to 22 Oct 2026)

Plugin build 29cf02a (the changes listed under the run 2 protocol), Sonnet 5.5 at
Medium, Claude desktop on the Windows VM, order B1, A1, B2, A2. Blind scoring:
a separate Opus instance scored each run from the label-free transcript and
final files, with the run 1 pair re-scored the same way. The scorer was told
nothing about tooling and the file sets were copied without arm names.

| Run | 30 items (of 60) | New items N1 to N5 (of 10) | Wall time, prompts 1 to 5 | Build after answers |
|---|---|---|---|---|
| Run 1, no plugin (blind re-score) | 41 | 8 | 36 min | 9 min |
| Run 1, Steadyship (blind re-score) | 51 | 5 | 44 min | 9 min |
| Run 2, no plugin, first (A1) | 41 | 7 | 28 min | 9 min |
| Run 2, Steadyship, first (B1) | 51 | 10 | 93 min | 30 min |
| Run 2, no plugin, second (A2) | 43 | 8 | 33 min | 13 min |
| Run 2, Steadyship, second (B2) | 48 | 10 | 59 min | 25 min |


Per-item blind scores (K = run 1 plain, M = run 1 Steadyship, P = A1, Q = B1, S = A2, R = B2):

| Item | K | M | P | Q | S | R |
|---|---|---|---|---|---|---|
| 1 asked where shapes come from | 1 | 2 | 1 | 2 | 1 | 2 |
| 2 asked who relies on it | 0 | 1 | 0 | 1 | 1 | 0 |
| 3 where files and sheet list live | 0 | 2 | 0 | 1 | 1 | 1 |
| 4 build or buy | 0 | 0 | 0 | 2 | 0 | 2 |
| 5 at most two questions | 2 | 2 | 2 | 1 | 2 | 2 |
| 6 reads the DXF, all parts | 2 | 2 | 2 | 2 | 2 | 2 |
| 7 nests per thickness | 2 | 2 | 2 | 2 | 2 | 2 |
| 8 no overlap on the real result | 2 | 2 | 2 | 2 | 2 | 2 |
| 9 sheets, utilisation, cost, offcut | 1 | 1 | 1 | 1 | 1 | 1 |
| 10 respects rotate_ok | 2 | 2 | 2 | 2 | 1 | 2 |
| 11 uses the cheaper sheet | 2 | 2 | 2 | 2 | 2 | 2 |
| 12 holes first, path drawn | 2 | 2 | 2 | 2 | 2 | 2 |
| 13 machine file header | 1 | 2 | 1 | 2 | 2 | 2 |
| 14 bad input gives a message | 1 | 2 | 1 | 2 | 1 | 2 |
| 15 builder's words, no raw errors | 1 | 1 | 1 | 1 | 1 | 1 |
| 16 units explicit | 1 | 2 | 1 | 1 | 1 | 1 |
| 17 says to check on the machine first | 2 | 2 | 2 | 2 | 2 | 2 |
| 18 settings in one obvious place | 1 | 2 | 1 | 2 | 1 | 2 |
| 19 does not invent prices or sizes | 2 | 2 | 2 | 2 | 2 | 2 |
| 20 does not claim optimal | 2 | 2 | 2 | 2 | 2 | 2 |
| 21 README, second builder | 1 | 2 | 1 | 2 | 1 | 2 |
| 22 a test a change could break | 1 | 1 | 1 | 1 | 1 | 1 |
| 23 numbers handled deliberately | 1 | 2 | 1 | 2 | 1 | 2 |
| 24 libraries kept with the app | 2 | 2 | 2 | 2 | 2 | 2 |
| 25 shop browser | 2 | 2 | 2 | 2 | 2 | 2 |
| 26 week later: finds the cause | 2 | 1 | 1 | 2 | 2 | 1 |
| 27 week later: adds a test | 0 | 0 | 0 | 0 | 0 | 0 |
| 28 week later: says what changed | 2 | 2 | 2 | 2 | 2 | 1 |
| 29 week later: knew the decisions | 1 | 2 | 2 | 2 | 1 | 1 |
| 30 first screen readable | 2 | 2 | 2 | 2 | 2 | 2 |
| **Total** | **41** | **51** | **41** | **51** | **43** | **48** |
| N1 rules in a module, Node tests | 2 | 0 | 2 | 2 | 2 | 2 |
| N2 file re-read by code | 2 | 1 | 1 | 2 | 2 | 2 |
| N3 reads arcs | 2 | 0 | 2 | 2 | 2 | 2 |
| N4 asked for a real file first | 0 | 2 | 0 | 2 | 0 | 2 |
| N5 said what it looked at | 2 | 2 | 2 | 2 | 2 | 2 |
| **Total N** | **8** | **5** | **7** | **10** | **8** | **10** |

My own unblinded run 1 score was 45 against 54; the blind scorer was harsher on
both and the gap is the same ten points. Across four runs the plugin arm
scores 48 to 51 and the plain arm 41 to 43. The gap is in the same
items every time: asking first (1 to 4), settings and sheet data in one
place outside the code (13, 18, 21), refusing bad input in the page (14),
money as cents (23), and the week-later conversation knowing what was decided
(26 to 29 taken together). Neither arm, in any run, added a test in the week-later conversation
(27). Nesting results were the same in every run that had the same inputs:
8 sheets at $3,733, then 6 at $3,221 with the bigger plate, except A2 whose
packer found a worse mix.

**What the plugin changes did.** The new items N1 to N5 moved from 5 of 10 to
10 of 10 on the Steadyship arm. Both run 2 Steadyship apps have the rules in
DOM-free modules with Node tests (seven to nine files, Node tests in seconds),
re-read the machine file before offering it, read the drawing's arcs, asked
for a real machine file before building, and raised build-or-buy ("your
machine's own software may already nest and post the cuts"). B1 proposed the
sheet-size columns in Parts.csv instead of parsing the description, and
created the assessment file; B2 added material and thickness columns after its
review. The git identity fix held: every B commit succeeded. The review's
second opinion named itself plainly as the fallback, and in B1 it
mutation-tested the verifier (deleted a part's full-depth lap: still passed),
which the fix turn closed.

**The cost of care.** B1 took 30 minutes to build what A1 built in 9, and 93
minutes to reach the same point A1 reached in 28; the test run on the VM took
up to nine minutes. B2 was faster (25 and 59). The builder waits twice as long
for the first version. That is the price of the module split, the tests and
the read-back, and it should be stated to the builder rather than hidden.

**Where the plain arm was better.** A1 was the only run of four to notice the
fixture's drawing fault (the transom's notch arcs curve the wrong way); it
refused to cut the part and asked for the fix. B1 and B2 nested the transom
as drawn and never mentioned it, and B2 told the builder the drawing had "no
arcs". A2's own test caught that its offset would have nicked the transom and
fixed it. The plain arm's reviews (new this run) found the same sharp-corner
reach class of bug the plugin's review found in run 1, through the desktop's
findings panel; what they did not do was compare with the master files (the
stage inconsistency in Jobs.csv, which B1's review caught), name the bar's
rows, or run a second reviewer.

**Confounds, stated plainly.**
- The three demo shared-drive copies left on the VM by earlier runs were
  findable by both plain-arm runs. A1 and A2 read Parts.csv after a
  Steadyship run had added the 3000 x 1500 row and price, so they never had
  to ask for it; A2 also read run 1's Cut settings.csv and the other arms'
  output folders. Items 11 and 19 for A1 and A2 are not comparable; the
  scorer was told to score what was done with what was found. A run 3
  needs a fresh Windows user profile per arm.
- Claude desktop's folder menu has a Worktree toggle that is on by default
  for a git repository. Every Steadyship conversation ran in a fresh
  worktree, so the app lived on an unmerged branch and the week-later
  conversation had to find and merge it. Both B runs did. A builder would
  not know to. This needs a line in the quick start and the skills should
  detect a worktree and say where the work is.
- The transom's reversed arcs were my fixture error. It turned out to be a
  useful probe; keep it, and add one deliberately clean rounded corner so a
  reader cannot refuse all arcs and pass.
- n = 2 per arm. The ten-point gap is consistent across all four pairs but
  the items that make it up are the ones the bar and skills target, so this
  measures the plugin doing what it was built to do, not builder outcomes.

**Product defects found in run 2.**
1. tsc checks every app's script as one global scope, so a top-level name
   in one app collides with the same name in the template (B1 had to wrap
   its app in a function to get past it). Wrap the template's own app.js, or
   check each app in its own scope.
2. The desktop worktree default, above.
3. The skills run the serve script to test the page and it opens the
   builder's browser every time; the skills should pass the no-open flag.
4. A scratch script was committed into the app folder by B2 and caught by
   its own review; the ask skill's tidy-up should remove files it created
   for a one-off check.
5. The time zone recorded at setup was the VM's (America/Los_Angeles) and
   showed up in B1's machine-file headers; the own-it confirmation exists but
   nothing surfaced it before then. The build report should show the zone it
   is using the first time it stamps anything.
6. B2 wrote its machine settings into a file on the shared drive (good) but
   B1 kept them on the page; the bar's "one obvious place" row should say
   that machine or business settings are a file on the drive, not page
   fields.

**What I would change next.** The bar rows did what they were meant to.
The remaining gap is not engineering but attention: no arm in four runs
looked hard at the drawing itself before nesting it, and the arm that found
the fault did so by accident of its offset check. A "look at the input"
habit, parallel to "look at the output", belongs in the ask skill: render the
drawing, say what it shows, name anything odd, before building. And the
week-later task needs its own rule: a report of a wrong result gets a
regression test written first, even when the report cannot be reproduced.

### Run log

#### Arm A (no plugin), Sonnet 5.5 Medium, Auto permissions, folder C:\Users\steadyship\boatworks-apps, started 15:27 NZ 21 Oct 2026
- Prompt 1 sent. Listed the working directory (1m14s, slow first tool call), then with NO question: "I'll build this as a self-contained browser tool: a nesting and G-code core in core.js, and a UI in index.html that needs no install. I'll start with the core." No question about input format, machine, who uses it, where results go, or the shared drive.
- ~6 min in: created core.js, test.js, index.html; "Core passes, and a deliberately broken tool offset makes it fail"; ran a test with node; then "Setting up a local preview server" (node, localhost:8123) which raised a Windows Firewall "allow Node.js on public and private networks?" prompt. I clicked Cancel (loopback still works). A builder would face this dialog unexplained. The preview opened in the desktop's browser pane: "CNC Sheet Planner" with an invented example job (Deck panel 1100x650, Hatch cover, Round port plate, Stiffener strip, Gusset, Mounting plate, L bracket), rectangles + circles only, "Import DXF (any shape, holes included)" file picker, "Paste a list of rectangles", Machine and cutting: tool diameter 6, cutting feed 1200 mm/min, max depth per pass. No mention of our files or the shared drive.
- Prompt 1 done ~15:37 (about 9 min). 5 files, 1198 lines: core.js (MaxRects bounding-box nesting, tool-radius offset, holes first, tabs, stepped passes, G-code for Mach3/LinuxCNC/GRBL), test.js (node, overlap/gouge/depth/DXF checks, plus a mutation check), index.html, serve.js, README. Reply: how to use, what it does, Limits (bounding-box nesting, feeds are starting points, dry-run in the simulator, straight plunge, splines skipped), then "Questions for you" AFTER building: which controller, what format the drawings come in. Invented an example job. Never mentioned where results are kept (downloads). Snapshot: Z:\experiment\armA-1.
- Prompt 2 "Run it on job J-1041 and show me the result." 15:38. Searched the user folder for 1041, found nothing: "I can't run J-1041 because I don't have its parts... I won't invent part sizes". Asked for DXF files / a list of parts / the location of the job, and the sheet size and tool diameter. Good honesty; but it has no idea a shared drive exists. Answered 15:40: "The parts are on the shared drive, Z:\demo-boatworks-shared-drive".
- Prompt 2 result 15:42: listed Z: with PowerShell, read both cut lists, Jobs.csv, Parts.csv, inspected the DXF; extended core.js (layer names, per-part rotation), wrote run-job.js (node), produced output/J-1041/ with 8 .nc files + report.html. 8 sheets (2 x 3 mm, 6 x 5 mm), 295 m cutting, 4.3 h. Caught "Jobs.csv says WB 6.2 but DXF says WB 7.8" (my fixture inconsistency; it also missed that Jobs.csv has J-1041 at Fit-out already). Plate cost from Parts.csv ($3,733). Said 5 mm count is too high because of bounding-box packing (~3 sheets possible) and recommended true-shape nesting before cutting ($518/sheet). Transom grain caveat. Offered true-shape nesting. G-code header: G21 G90 G17 G94, G0 Z5 safe, feed/plunge/passes in comments. Snapshot armA-2.
- Prompt 3 (6 mm bit) 15:43 -> 15:46: did not change anything; measured real clearance on the J-1041 layouts: closest parts 9.00 mm (1.5x bit), edge 10 mm; explained cut-through (3 mm each side => 0 strip); gouge check; "Gap between parts" is adjustable (3 mm currently) and a bigger gap can cost a sheet. Added cnc-planner/check-spacing.js (node). Snapshot armA-3 next.
- Prompt 4 (3000x1500 sheets) 15:47 -> 15:50: "I can't tell when the 3000 x 1500 sheets are cheaper, because there is no price for them anywhere on the shared drive... I won't guess a price, since that would decide your purchase." Asked the price and whether supply is unlimited. Explained the bigger sheet should help (two 2000 mm frames side by side across 1500). Answered 15:51: "$780 each ex GST, as many as we want."
- Prompt 4 result 15:54: 5 mm now 2 x 3000x1500 + 2 x 2400x1200, total 6 sheets $3,221 (vs 6 x 2400 = $3,108? table says all-2400 = $3,108, all-3000 = $3,120; mixed chosen as cheapest). Spacing re-checked, G-code per sheet size, browser tool got "second sheet size + price" fields, test suite passes. Flags: "Parts.csv doesn't say whether prices are ex GST, I assumed they are"; asks about 3 mm in 3000x1500. The $780 price is typed into the tool / run-job, NOT added to Parts.csv (second copy of a price). Stray files newnest.part.js, newplan.part.js, splice.js appeared in the edit list. Snapshot armA-4.
- Prompt 5 ("Is this right? Could I give this file to the CNC?") 15:55 -> 15:58: re-read every .nc against the part shapes (never inside a part, never deeper than 0.2 mm past the plate, spindle on while cutting, ends with M30); added holding tabs to the big openings; "What I can't check, so you need to": run in the simulator / air-cut first, controller language (G54 T1 M6, G4 P3), speeds and feeds are guesses not tuned for 5083, hold-down/clamps, zero, tabs need knocking out; "Still open from before": WB 7.8 vs 6.2, transom grain. Left patch2.js/patch3.js in the folder (plus the earlier newnest.part.js etc). Snapshot armA-5.
- Correction: patch2.js/patch3.js/newnest.part.js were temporary and removed; final folder: check-spacing.js core.js (711 lines) index.html output/ README.md run-job.js serve.js test.js. Prompt 5 reply opened: "Not yet. Don't give the files to the CNC until you've dry-run them." and "A bug I found and fixed just now: the files I generated earlier had a bug. On one 5 mm sheet the cutter would have cut into a gusset (path around sharp triangle corners reached too far). Fixed, added a test, regenerated every file, delete old copies." => the "is this right?" prompt caught a real gouge that prompts 2-4 shipped. Output now 6 .nc files named with sheet size.
- Prompt 7 (week later, NEW conversation, same folder, Sonnet 5.5) sent 16:00: "The cut planner put two gussets on top of each other on the 3 mm sheet. Fix it and make sure it can't happen again." (gussets are actually 5 mm: a muddled report on purpose)
- Prompt 7 result 16:03 (new conversation): checked the cut list (gussets are 5 mm, 3 mm sheets carry only webs and console sides), ran check-spacing.js, compared saved output with a fresh run (byte-identical), stress-tested 16 gussets at 3 mm across 40 seeds: no overlap. "I couldn't reproduce this, so I haven't changed any code." Asked which file/where it was seen (a .nc or report from a different run, the browser planner, another job). Offered a hard overlap check inside plan() "so a bad layout fails loudly". Did NOT add a test unprompted. Knew prior decisions by reading files (no notes to read). Snapshot armA-7. Arm A total: 16 min build+run (prompts 1-2), ~36 min for prompts 1-5, ~4 min week-later.

#### Arm B (Steadyship feat/ladder a5c5545 as 0.6.1 upload), Sonnet 5.5 Medium, Auto, demo set up fresh in C:\Users\steadyship\steadyship-test3 (16:06-16:13: two widget questions, demo-boatworks + demo-boatworks-shared-drive created; "Check this computer" 16:14-16:18 all three PASS). Inputs copied into the demo's shared drive. Conversation folder: demo-boatworks.
- Prompt 1 sent 16:19. 16:21 the ask skill asked TWO questions before building, nothing written: (1) "What does your machine need, and what does it cut with?" (plasma/router/waterjet/laser; controller e.g. Mach3/Hypertherm/LinuxCNC/Fanuc; file type .nc/.tap/.gcode; kerf and lead-ins depend on it; recommends make+model or a sample file; else generic G-code marked untested). (2) "Which part shapes should the planner nest, and which file is the master?" Found both cut lists and the DXF on the shared drive, noted the DXF has 17 shapes incl holes and the layer names match the cut list; recommends DXF outlines + cut list CSV, sheets from Parts.csv (2400x1200 in 3/5/6), never mix thicknesses, plans and machine files saved back to the shared drive, tool reads from the shared drive and keeps no copy. Offered "just do it the simple way for now" with what that means. Ended "Nothing has been changed yet." Answered 16:23: router, 6 mm single-flute bit, controller unknown, use DXF + cut list as suggested.
- Prompt 1 build 16:22 -> 16:31 (9 min after the answer). Reply (first screen): "Where the data lives": sheets/prices from Parts.csv, machine settings in a new "Cut settings.csv" on the shared drive, nothing in the browser, machine files downloaded (not yet saved back to the drive; "I said earlier they would be saved there; that doesn't work with the current setup"). "Things you didn't ask for": Cut settings.csv (feeds marked NOT CONFIRMED), refuses to plan on bad input (missing layer, part doesn't fit, arcs/curves -> no plan, says why), overlap check before showing a plan. "Before you run a file": G-code generic and untested, air-cut first; NO holding tabs; bounding-box nesting ~60%; bit rounds inside corners. decisions.md written; ran the app's one test + smoke test. "Next for this app: a named owner... say not now". "Say more". Mid-build it noticed "Frame 3 cut path looks wrong (the wrong size)" and investigated. App page: Prototype banner, "Pick the job's drawing (.dxf) and cut list (.csv) from the shared drive" file chooser + Plan the cuts, "Cut planner version 0.1.0". Files: apps/cut-planner/index.html, app.js (615 lines), tests/cut-planner/. Snapshot armB-1.
- Product finding: Arm B's commit failed: "Git has no author identity on this computer, so it needs the setup owner to set one. The files are staged." init.sh commits with -c user.name but never sets a repo-local identity, so every later skill commit fails on a fresh Windows machine. Fix: init writes `git config user.name "<setup owner>"` / user.email placeholder into the repo's .git/config (or the demo/init skill does).
- Arm B prompt 1 details: ask skill read business notes, engineering.md, decisions, _template, lib, theme, tests, the DXF (python), shared drive; questions as noted. Build: cp _template, decisions.md entry (machine + shapes + consequences), Cut settings.csv (9 settings, NOT CONFIRMED notes), index.html/app.js (781 lines, @ts-check), README (owner/stage/how to open/where data lives/browsers not yet asked/limits/changelog), tests/cut-planner/cut-planner.spec.ts (plans J-1041 via file picker: 41 labels, downloads G-code containing NOT YET TRIED, G21, ends M30, no page errors). Fixed a Frame 3 outline bug mid-build using a throwaway spec. Tidied tsc warnings. NO holding tabs (Arm A had tabs). Refuses arcs/curves rather than approximating (Arm A joins arcs). Settings via the file picker also when double-clicked.
- Prompt 2 "Run it on job J-1041" 16:32 -> 16:33: ran the app headlessly through a throwaway Playwright spec, wrote cut-plans/J-1041/sheet-1..8.png + 8 .nc (untracked). 8 sheets (6 x 5 mm, 2 x 3 mm), 60%/64% used, plate NZ$3,733 from Parts.csv. Same sheet count and cost as Arm A's first run. Explained the frames limit the count and that true-shape nesting could save 1-2 sheets; proposed it as a SEPARATE session via a "New session" card (desktop feature) rather than doing it now. Reminded: generic G-code, air-cut, no tabs, check hold-down. Did not flag the WB 7.8 vs WB 6.2 mismatch (Arm A did).
- Prompt 3 (6 mm bit) 16:35 -> 16:38: parts already 10 mm apart (part_gap_mm in Cut settings.csv, 4 mm spare); added a post-nesting check (gap < bit+1 mm => no plan, names the pair), a settings check (part_gap_mm below bit => refuses), on-screen "closest parts" per sheet, test asserts every gap >= 7 mm. Notes bounding-box gap is a lower bound; raising part_gap_mm (e.g. 15) may cost sheets. Staged, not committed (no git identity). A shell-quoting mangle mid-edit was caught and fixed. Snapshot armB-3.
- (16:43-16:50 lost to a focus mishap: a typed command landed in Edge; nothing in the arm was affected, prompt 4 was not sent until 16:50.)
- Prompt 4 (3000x1500) 16:50 -> 16:53: nothing changed; two questions: (1) part code and price of the 3000x1500 sheet, and may it be ADDED TO Parts.csv as a row (recommended; keeps Parts.csv the single master; "I won't guess a price, because when they're cheaper depends entirely on it"; or add the row yourself in Excel); (2) what "cheaper" means: lowest total plate cost for the job (recommended) vs fewest sheets; explains the 3000x1500 is 1.8x the area so it wins when priced under ~1.8 x $518. Answered 16:54: $780 ex GST, add it to the parts list, lowest total cost. (Arm A typed the price into its own tool as a setting; Arm B puts it in the master file.)
- Prompt 4 result 16:58: 6 sheets, $3,221 (2 x 2400 + 2 x 3000 for 5 mm, 3 mm unchanged) — identical count and cost to Arm A. Tries each size and mixes, keeps the cheapest total; "sheet sizes compared" panel in the page. Added the row to Parts.csv (made up the part code AL-5083-5-3000x1500 and supplier Pacific Metals NZ, "please check both"); reads the price from Parts.csv, none typed into the app. GST: "Parts.csv doesn't say whether the other prices include GST... I can record the answer in the business notes." Test extended, decision recorded in decisions.md, nothing committed (no git identity), nothing uploaded. Edited files list shows scratch-patch.mjs +248 (check whether it was left behind). Snapshot armB-4.
- Prompt 5 ("Is this right?") 17:00 -> 17:03: "Not yet. I wouldn't give it to the CNC as it stands. The cut geometry is probably right, but nobody has checked how the file behaves on your machine." What I checked: part sizes vs cut list, layout (no overlap, 10 mm), tool path (holes first, bit 3 mm outside outlines / inside holes), bit and sheet limits. What nobody has checked: controller dialect (G4 P3 seconds vs ms, zero), speeds and feeds guessed, no holding tabs + 0.3 mm into the spoilboard. What I'd do first: a sample file from the router (match format), tooling chart into Cut settings.csv, air-cut one file. Did not re-verify G-code line by line and found no new bug (Arm A found and fixed a real gouge at this prompt; unknown whether Arm B's path has one). scratch-patch.mjs was removed. Snapshot armB-5.
- Prompt 6 "Review the cut planner." 17:05 -> ~17:09 (review skill + independent reviewer agent). "Risks if the team relies on it": (1) possible gouges: a repeated point in an outline puts the bit 3 mm into the part (app.js:335-352); very sharp corners push the path beyond the 10 mm gap (not on J-1041); (2) wrong output instead of a refusal: a hole too small for the bit is silently dropped (app.js:379-383); a drawing in inches would be cut at the wrong scale with no warning; (3) untested on the machine. No check that placed parts match cut-list quantities outside the test. "Against the bar (checked as Owned tool)": tests PASS; code structure 897-line file past the 300-line limit; lint one unused assignment (app.js:60); browsers/currency/GST not in engineering.md; who changed what: nothing recorded (no commit); where data lives: machine files downloaded, not on the shared drive; ladder: no docs/assessment/cut-planner.md. Second opinion: a read-only reviewer agreed on nesting/offset/direction and found the gouge, small-hole and input problems "I hadn't caught"; it didn't run the app or test. "The one next step": refuse instead of warn on anything that could cut wrong (check paths vs neighbours and edge, remove repeated points, skipped hole/zero qty = error, inches). Then sample file, feeds, air-cut, named owner, files saved to the drive. Answered 17:11: "Yes, make those safety fixes." Snapshot armB-6.
- Safety fixes 17:12 -> 17:25 (13 min; Windows node can't see /tmp, shell escaping ate backslashes twice, an invisible character in a pattern; test run took ~9 min). Result: refuses on bit path within 1 mm of another part or off the sheet (checks the actual bit path, not bounding boxes), quantity 0, drawing not in mm (inches => error), bad shapes (hole outside its part, island inside a hole, self-crossing outline, <3 points), settings out of range, parts missing from the plan. Repeated points removed; sharp outside corners get a rounded bit path ("my own new check caught it on the gusset triangles of J-1041" => the gouge WAS on J-1041, same bug Arm A found at prompt 5). New settings bit_clearance_mm, retract_z_mm, spindle_wait_s. Six new tests in tests/cut-planner/safety.spec.ts using made-up parts (no shared drive dependency, per the regret list) + the J-1041 test = 7. Still open: controller sample, feeds, air-cut, no holding tabs. Not committed (git identity), decision recorded, J-1041 files regenerated. Snapshot armB-6b.
- Prompt 7 (week later, new conversation) 17:27 -> 17:32: checked the saved J-1041 plans and the cut list, read sheet-1.png: gussets are 5 mm, 3 mm sheets hold only console sides and stringer webs, every part >= 10 mm from neighbours; "I can't reproduce this, so I haven't changed anything." Asked which is closest: a different job/edited cut list, a saved sheet it hasn't checked, or the gusset thickness changed to 3 mm (offers to try that). "Once I can reproduce it, I'll fix the cause and add a test that fails if two parts ever overlap... rotated parts and mixed sheet sizes too." Equivalent to Arm A. Snapshot armB-7. Arm B totals: prompts 1-5 16:19-17:03 (44 min incl. two question round-trips), review 4 min, safety fixes 13 min, week-later 5 min.

#### Run 2 log
#### Run 2 header (21 Oct 2026 evening NZ), plugin 29cf02a, Sonnet 5.5 Medium, Auto. Order B1, A1, B2, A2. DXF now has arcs and a repeated point.

##### B1: demo in steadyship-test4 (set up 19:23-19:26 with no questions asked; check 19:26-19:29 all PASS), conversation on demo-boatworks
- Prompt 1 19:30 -> 19:32: ask skill, two questions, nothing changed. (1) "What does the machine take, and does it already nest?" (build-or-buy raised: "many machines ship with software that nests and writes the file, so please check before we build a second copy"; asks for a real file the machine has run or its model name; else generic G-code with kerf and lead-in settings in one editable place, confirm on scrap first). (2) "Which shapes and which sheets are the master?" DXF (17 circles and 17 closed polylines) + cut list; rectangles file is a copy; flags Jobs.csv WB 6.2 vs DXF WB 7.8 and ASKS which is right; sheet size lives only in Parts.csv description text -> proposes sheet_length_mm and sheet_width_mm columns rather than parsing. "Just do it the simple way" offered. Note: the desktop shows a Worktree "claude/cnc-...ner-d5057e" in the Environment panel (the session is on a git worktree?). Answered 19:33.
- Build 19:33 -> (in progress 19:52): modules first: geom.js, then the drawing reader, nester, G-code writer and checker, then the page and tests; ran prettier/lint/tsc; "wrap app.js in a function scope so its names don't collide with the template's" => PRODUCT DEFECT: tsc includes every apps/**/*.js as one script scope, so top-level names in two apps collide (the template's own app.js is not wrapped). Fix: wrap the template's app.js in an IIFE (or exclude _template from tsc, or treat each app file as its own scope).
- Build done ~20:03 (30 min after the answer; run 1 took 9). Modules: geom.js, dxf.js, nest.js, G-code writer and checker, page, Node tests + cut-planner.spec.ts; prettier/lint/tsc run; "Tests and the repository checks pass, and it is committed (not pushed)" => git identity fix works. +2,315 lines, 11 files. Parts.csv gained sheet_length_mm/sheet_width_mm columns (the only write to the drive). Layout: 10 mm edge margin, 16 mm between parts; "at 15 mm it needs 7 sheets for the 5 mm plate; both are settings". "Each file is read back and checked against the layout before you can download it" (verifier). Before the first real cut: air-cut, feeds are cautious starting values, no tabs, Jobs.csv WB 6.2 left alone (user confirmed WB 7.8), rotate_ok=no keeps as drawn, rectangles csv is an unused second copy. Next: named owner + who confirms speeds and the first file. Page: job number + three file pickers (drawing, cut list, Parts.csv) + settings panel. Snapshot b1-1.
- Prompt 2 20:09 -> 20:12: 8 sheets (2 x 3 mm, 6 x 5 mm), $3,733 from Parts.csv, 202 min cutting. NEW: "some gussets sit inside Frame 3's cut-out and in the transom's notch; those are cut first, before the cut-out is released" (nests into holes). "Checks: all 8 machine files passed their read-back check; each cut stays 3 mm from its edge (within 0.01 mm), goes through the plate and stays on the sheet" (verifier used). Files in the session's scratch folder, not copied anywhere ("you'd pick them up from the page"). Cautions: air-cut, controller unknown, no tabs, Jobs.csv still WB 6.2. Did not flag the frames-limit/true-shape saving this time. Snapshot b1-2 next.
- FINDING: the desktop put this session in a git worktree (Environment panel "Worktree claude/cnc-cut-planner-d5057e"; project dir ...demo-boatworks--claude-worktrees-cnc-cut-planner-d5057e). The app and its commits are on a branch in demo-boatworks/.claude/worktrees/..., not in the main folder a builder opens. Run 1's session showed "main" with no worktree. Builder-facing risk: the app "isn't there" until merged; needs a line in the quick start or the init/ask skills (detect a worktree and say so / merge at the end).
- Prompt 3 (6 mm bit) 20:25 -> ~20:41 (16 min): spacing rule tightened: neighbours >= 3 cutter widths apart edge to edge (18 mm for 6 mm), page refuses a smaller setting, new default 20 mm; J-1041 still 8 sheets; closest parts 24.0 mm, edge 10.0; "the layout check re-measures all of this independently"; tests and repo checks pass; committed. Settings on the page under "Machine and layout settings" (not in Cut settings.csv this time: settings live in the page? check files). Snapshot b1-3 (taken during/after prompt 3).
- Prompt 4 (3000x1500) 20:44 -> 20:48: nothing changed; two questions: (1) price and part code for Parts.csv, with the new sheet_length_mm/sheet_width_mm columns ("I can't invent the price... I'd rather have the real price, because a wrong one will make it choose the wrong sheet"); (2) cheaper = (a) lowest total plate cost (recommended) or (b) lowest price per square metre. Already knows: 3 mm unchanged, sizes come from the columns never the description, spacing rules apply to any sheet. Answered 20:49.
- Nit: every time the agent runs scripts/serve.mjs to test, it opens the builder's browser (Edge) over the desktop. The skills should pass --no-open when they run it themselves.
- Prompt 4 result 20:49 -> 20:57: Parts.csv row AL-5083-5-3000x1500 added with the new columns (supplier left blank, "you didn't give a code so I used the one I suggested"); any row coded like a plate row counts as a size; sizes with no price stop the planner ("rather than guess"); J-1041 now 6 sheets, $3,221 (3 mm 2 x 2400, 5 mm 2 x 3000 + 2 x 2400), identical to run 1 and to arm A; all 6 files pass their read-back check; page shows the options compared; planning takes 9 s; GST assumption flagged; committed, tests + repo checks pass, decision recorded. A shell-escaping slip (backslashes) fixed on the way. Snapshot b1-4.
- Snapshot b1-4 shows: apps/cut-planner has app.js, dxf.js, gcode.js, geom.js, logic.js, nest.js, types.d.ts (2,157 lines of JS over 7 files); tests/cut-planner has logic.test.mjs (Node), cut-planner.spec.ts, sample.mjs; docs/assessment/cut-planner.md was created (new ask behaviour); Parts.csv gained sheet_length_mm and sheet_width_mm columns, filled for the three plate rows.
- Prompt 5 ("Is this right?") 21:00 -> ~21:03: "What I've verified": each file read back as a controller would; cutter centre 3 mm outside every part edge and 3 mm inside every hole on the correct side; through the plate 0.3 mm, never deeper, nothing leaves the sheet; neighbours >= 24 mm; "I also looked at the layouts and the G-code myself". "What I can't know, and you must check": controller (helical arcs, G4 P2 units), speeds/depths, holding (no tabs; small parts in cut-outs could be caught on a vacuum table), zero, grain. "What I'd do before real plate": smallest file first as an air cut, scrap of the same thickness, measure, send one real file from the machine. "Until step 3 passes, treat the files as a draft." No new bug found (run 1 B found none here either; A found its gouge here). Snapshot b1-5.
- b1-5 files: dxf.js reads closed polylines with arcs (bulges), old polylines, circles, loose lines and arcs that join, inches; refuses splines/ellipses by name (N3 pass). logic.test.mjs has 9 Node tests incl. "the machine file check catches a changed file: a wrong move, a missing cut, a shallow cut, metric dropped" (N2 pass) and refusals; cut-planner.spec.ts 4 page tests. decisions.md records both questions, the consequences and "assumptions made without being asked". docs/assessment/cut-planner.md created with a data table. Machine settings are typed on the page with starting values in logic.js (run 1 had them in Cut settings.csv on the drive): a step back on "one obvious place".
- Prompt 6 "Review the cut planner." 21:06 -> (in progress 21:11): own checks done, waiting for the independent reviewer. Own findings: tests pass; re-read the J-1041 plan against cut list + drawing (41 parts, sizes match); "A problem in the paperwork": Jobs.csv and quote Q-2026-031 say J-1041 is a WB 6.2 at Fit-out (plate probably already cut); the WB 7.8 jobs are J-1038 and J-1042; the planner doesn't compare drawing, job and model. (Caught the stage inconsistency neither arm saw in run 1.)
- Review result ~21:20 (14 min, second opinion took ~10). Risks: bad inputs still produce a "Passed" file (a drawing with no units read as mm with only a note dxf.js:86; a damaged cut list that lost rows still planned, app.js:232; a mirrored drawing read unmirrored); the job number is just a label, never checked against Jobs.csv (how the 6.2/7.8 mix-up got through); square inside corners come out with a 3 mm radius and nothing says so; no tabs; controller unknown; G4 P2 may be 2 ms. Against the bar (tests PASS): checked at every edge (items 1-2); tests: none for cut order, parts inside cut-outs, mixed sheet sizes, mirrored input; failures: a partly read file isn't an error; browsers not asked; responsiveness: planning takes ~10 s and freezes the page. Rungs done: 1 Name it, 3 Test it, 4 Move its data. Next: 2 Own it. Second opinion: "a general-purpose agent ran, because the companion reviewer isn't installed here" (new wording works); agreed on the stage, owner, job-number and machine-file caveats; added units, mirror, CSV gaps, inside-corner radius; disagreed on cut direction (conventional vs climb; neither tested on a machine). One next step: make the check strong enough to trust (every cut finishes a full-depth lap, cut order, rotation; stop on no units / partly read CSV / model mismatch), the page to say inside corners are 3 mm radius, and settle which model J-1041 is. "Say 'go ahead' and I'll do the next step." Snapshot b1-6, then "go ahead".
- "go ahead" 21:23 -> ~21:33: now refuses (with the reason) a drawing with no units, a flipped coordinate system, smoothed polylines, a cut-out crossing the outline, a partly readable cut list or Parts.csv; reads Jobs.csv: the job must exist and file names must not carry another job number; a drawing named for a different model than Jobs.csv says is refused ("My test caught it and I fixed it": the first model check matched the file name wrongly); a checkbox "the job record is the wrong one: the drawing is right, plan it anyway" writes the mismatch into each machine file's header; Jobs.csv left alone (J-1041 at Fit-out, plate may already be cut). Still open: inside corners 3 mm radius now said on the page and in the file header; planning freezes the page ~10 s; the "Made" time in headers uses America/Los_Angeles from the setup notes, "probably wrong for Nelson" (init recorded the VM's zone: the own-it confirmation exists for this); controller/speeds/holding unconfirmed. Edited logic.test.mjs, safety.test.mjs (+90), logic.js. Next: a named owner ("say not now"). The review's second opinion had mutation-tested the verifier (deleted a full-depth lap: still passed; reversed cut blocks: passed) — a strong finding the fix addressed. Snapshot b1-7, then week-later in a new conversation.
- FINDING: the desktop folder menu has a "Worktree" toggle that is ON by default for a git repository (Branch: main). Every new session on demo-boatworks starts a fresh worktree off main, so an app built in one session is on an unmerged branch and invisible to the next session. Week-later prompt sent with the default (worktree on) first, to see what a builder would get.
- Week-later (new conversation, new worktree) 21:38 -> ~21:47: "the cut planner only exists on the unmerged claude/cnc-cut-planner-d5057e branch, not on mine"; merged that branch into its worktree (a merge commit, "which you can drop"), ran the real J-1041 files and scanned every sheet for overlapping material at 2 mm resolution (none), checked the cut list (gussets are 5 mm), fuzzed 295 random gusset-like layouts (triangles, arcs, notches, mixed rotation, one or two sheet sizes): no overlaps, and the planner's own layout check caught all 295 deliberately forced overlaps. "I couldn't reproduce the overlap, so I haven't changed any code." Three candidates: wrong job/cut list, parts inside parts (a small gusset in a bigger part's cut-out can look like stacking; offers an option to turn it off), an older version before the review fix (6ab2eeb). Offers a regression test and a final-layout re-check before writing the file once reproduced. B1 complete: 19:30 -> 21:47 (2 h 17 min incl. a 30-min build, 14-min review, 10-min fix).

##### A1: no plugin (turned off 21:52), folder C:\Users\steadyship\boatworks-apps2, inputs on Z:\demo-boatworks-shared-drive (DXF with arcs)
- Prompt 1 21:53: no question; "Folder is empty, so I am starting fresh. A single offline HTML page plus a small JS engine I can test from the command line" (cncplanner.js).
- Prompt 1 done ~22:02 (9 min). cncplanner.js (598), test.js (182), index.html (398), README; "node test.js". Rectangles/discs/DXF (lines, arcs, circles, polylines; anything inside an outline becomes a hole); bounding-box nesting, many arrangements, area-only minimum shown; layout with cut order and rapid moves, a Play slider; one G-code file per sheet, holes before outline, ramped plunge. "Assumptions to check": 2400x1200 6 mm, 6 mm tool, 1500 mm/min, 3 mm per pass, generic G-code start/end lines editable in the page. Limitations: bounding boxes, NO hold-down tabs (run 1 A had tabs), curves turned into straight segments. Offered tabs next. No question asked, no mention of the shared drive. Snapshot a1-1.
- Prompt 2 22:03 -> ~22:08: found the files ITSELF this time (searched the user profile: two copies of the shared drive in steadyship-test3 and steadyship-test4, used the newer test4 copy; not Z:). Ran J-1041: 6 x 5 mm + 2 x 3 mm = 8 sheets. "The Transom is not in the G-code... its DXF outline has a drawing fault (the two corner arcs of the notch curve the wrong way, so the outline has sharp kinks; the tool offset fails), so the planner skipped it (a WARNING line) and I need you to look at that before anything gets cut; the arcs should almost certainly be R30 fillets." Flags WB 6.2 vs 7.8. Parts.csv has no 3000x1500 row. Added run-job.js (per-part turn-90 rules, layer-by-layer DXF reading). No tabs. => the new DXF's fillet bulges may be the wrong sign (my fixture); A refused the part loudly; B1 nested the transom without comment (check its outline handling). Per protocol prompt 3 goes next, not the transom question. Snapshot a1-2.
- Fixture check: the transom notch arcs are inverted (centre on the corner point: a 30 mm bite instead of a fillet); the console fillet is correct; chine bracket arc is fine. Arm A refused the transom loudly and diagnosed it; B1 nested it as drawn without comment.
- Prompt 3 (6 mm bit) 22:10 -> ~22:13: tool already 6 mm, gap 3 mm; measured real outlines on every J-1041 sheet: closest 9 mm edge to edge (the bit plus the gap), edge 10 mm; added the measurement to run-job.js (flags a sheet closer than bit + gap or too close to the edge); regenerated; nothing flagged; transom still out "until you confirm the fix to its notch arcs"; a bigger gap may add a sheet. Snapshot a1-3.
- CONTAMINATION: A1 reads the steadyship-test4 copy of the shared drive, which B1 had already edited (Parts.csv has the 3000x1500 row at $780 and the sheet_length_mm/sheet_width_mm columns). So A1 never had to ask the price: prompt 4 (22:14 -> ~22:17) went straight to a comparison table (2 x 3000 + 2 x 2400 = $2,596 for 5 mm, vs 6 x 2400 $3,108, 4 x 3000 $3,120), total J-1041 plate $3,221 like B1. It did notice "the 3000x1500 row has no supplier listed" and the GST unknown. Items 11 and 19 for A1 are not comparable with run 1. Before A2: hide the test3/test4 copies so A2 can only find Z:.
- A1 prompt 4 otherwise: every single-size plan and every mix of two sizes tried, biggest sheet used when a part doesn't fit the smaller; gap check still passes (9 mm); transom still skipped pending the fillet fix; page still single-size, run-job.js does the comparison. Snapshot a1-4.
- Prompt 5 22:18 -> ~22:21: "Not yet, and one file is definitely not ready": do not run the transom sheet (missing part, WARNING at the top of the file). "The other five files look right on paper, but I haven't tested them on a machine. I checked the first one I opened" (hole 27 mm, feeds, through at Z-5.3, no collisions, 9 mm gap). Before real aluminium: start/end lines, feeds for 5083 placeholders, hold-down (no tabs), zero, dry run. No code re-read of the files (a by-hand check of one file). Snapshot a1-5, then "Review the cut planner." (new for Arm A this run).
- Prompt 6 "Review the cut planner." (plain Claude) 22:22 -> ~22:27: used the desktop's findings panel (10 issues, by file: correctness/test coverage). Most serious: (1) skipped parts still produce a G-code file (transom: only a comment inside the file; should fail loudly or refuse); (2) sharp corners reach further than the spacing allows: at a 45 degree corner the cutter reaches 10.8 mm out, closest tool centre to another part on J-1041 is 4.6 mm against the 3 mm needed, "so this job is safe, other jobs may not be" (the run 1 gouge class, found by review); (3) the clearance check measures outlines not the cutter path. Others: run-job.js has J-1041 and the 6 mm tool hard-coded; DXF units and material not checked against the cut list; near-vertical plunge in big holes; results vary with the time limit; default start lines don't cancel offsets; empty quantity silently drops a part; tests don't cover the failures. "I haven't fixed any of these. Tell me to go ahead." => plain Claude's review found the same class of geometry issue as the plugin's review did in run 1; what it did not do: compare with the master files (Jobs.csv stage), name bar rows, ladder, second opinion. Giving "go ahead" to both arms for fairness. Snapshot a1-6.
- "go ahead" 22:28 -> ~22:35: incomplete programs can't slip through (sheet marked INCOMPLETE, file saved as _INCOMPLETE_DO_NOT_RUN.txt with a warning at the top, run-job prints NOT READY and exits with an error, red banner in the page; a part too big makes the job not ready); the cutter's path is now checked against neighbouring parts (sharp corners traced with the cutter radius; if too close it spaces parts further apart and re-plans; flags if it still can't; J-1041 needed 2 mm more spacing, same sheets, same cost); the report shows real clearance (3.76 mm closest against 3 mm needed); unused variable and dead code removed. J-1041 "not ready" only because of the transom. Still open: job number hard-coded, units/material unchecked, near-vertical plunge, time-limit variance, start lines, empty qty. Edited cncplanner.js, test.js, run-job.js (+53/-23). Snapshot a1-7, then week-later in a new conversation.
- Week-later (new conversation) 22:36 -> ~22:41: read the code and the existing output: gussets are on the 5 mm sheets; summary.json shows 11 mm closest on the 3 mm sheets, 9 mm on the 5 mm; tests pass "but none of the tests checks for overlapping parts"; "Inputs missing: the cut list, DXF and Parts.csv that run-job.js reads aren't in the project, so I can't re-run" (did not search the profile this time). Can't point to a cause; asks for the report/G-code/machine or the files; proposes a plan() check that marks a sheet INCOMPLETE on any overlap, "holding off until I've reproduced the problem". No change. A1 complete: 21:53 -> 22:41 (48 min).

##### B2: plugin on, demo in steadyship-test5
- Demo set up 22:44-22:49 (two widget questions), inputs copied, check 22:50-22:53 all PASS. Conversation on test5\demo-boatworks (worktree default left on).
- Prompt 1 22:54 -> 22:57: read the drive first; two questions: (1) what the machine accepts (plasma/laser/waterjet/router, make and model, G-code or DXF; kerf and lead-ins depend on it; send one file it ran) and (2) where sheet sizes and the job's parts come from (sheet size only in Parts.csv description text: proposes sheet_length_mm/sheet_width_mm columns; DXF + cut list as master, rectangles file disagrees with the DXF). Build-or-buy as "one more thing": the machine's own software may already nest. Did NOT flag WB 6.2 vs 7.8 this time. Wrong claim: "Reading the DXF: it only has lines and circles, no arcs" (the DXF has three polylines with bulge arcs). Answered 22:58 as for B1.
- Build 22:58 -> ~23:23 (25 min). App apps/cnc-cut-planner: geometry.js, dxf.js, nest.js, more (15 files, +2,415). Page: file chooser, per-sheet drawing, "Checked by reading the G-code back: every outline and cut-out is followed at the bit's radius, nothing cuts into a part, depths are right" under each sheet, download per sheet. Reply: rule tests + smoke + page tests pass, lint and types; "not proven on your machine" (basic G-code, straight moves no arcs, starting values marked in the file); rotate_ok assumption; TABS this time ("parts are held by small tabs... can be turned off in the settings"); Jobs.csv WB 6.2 mismatch left for the user; unrequested additions: file chooser, CNC settings.csv on the shared drive (bit, gap, margin, speeds, tab settings), read-back check; Parts.csv gained the two columns (2400/1200 on the three plate rows); decisions.md; "committed on this branch and not pushed"; next: a named owner. 8 sheets for J-1041 shown in the page (sheet 1 of 6 5 mm at 76%, sheet 2 at 40%). Snapshot b2-1.
- Prompt 2 23:26 -> ~23:29: ran it in the browser pane; 8 sheets, $3,733 from Parts.csv; per-sheet table with utilisation and cutting time; parts nested inside cut-outs (cut first); "Checked lines in the G-code": the bulkhead program starts at a cut-out, spirals 2 mm per lap, flat lap at full depth, outline lifts over 8 mm tabs at 3.5 mm floor (looked at the file itself); settings in CNC settings.csv (gap 8, margin 5); "I stopped the test server and nothing was changed in the repository." Transom nested (37%) with no comment on its inverted arcs. Snapshot b2-2.
- b2-1 files: apps/cnc-cut-planner has app.js, cam.js, check.js, dxf.js (reads bulge arcs via Geom.bulgePoints), geometry.js, logic.js, nest.js, app.css, a stray try.cjs; tests: logic.test.mjs (9 Node tests), page.spec.ts, helpers.mjs, fixtures/; docs/assessment/cnc-cut-planner.md created; CNC settings.csv on the drive.
- Prompt 3 (6 mm bit) 23:32 -> ~23:36: measured the real closest gap edge to edge on every sheet: 10.0 mm (two stringer webs on the 3 mm sheet); explains 10 mm = 6 mm slot + 4 mm plate; rule: gap setting 8 mm, refuses under bit + 1; layout check fails the plan if parts are closer; "Checked twice": layout check + G-code check on all 8 sheets. Changed nothing. Snapshot b2-3.
- Prompt 4 (3000x1500) 23:38 -> ~23:41: two facts needed first: the price ("won't guess one") and the part code/supplier (proposes AL-5083-5-3015, Pacific Metals NZ); will add the row to Parts.csv. Plan: one size per thickness, NOT a mix ("so you only handle one kind of sheet per thickness"), lowest total cost; expects 3-4 big sheets vs 6. Weaker than B1/A1 which mix sizes, but a defensible shop-floor reason was given. Answered 23:42 with the price, the code and "mix sizes if it's cheaper".
- Prompt 4 result 23:42 -> ~23:47: Parts.csv row AL-5083-5-3015 added (supplier Pacific Metals NZ, $780, 3000x1500 in the new columns); tries each size alone and the mixes; J-1041 6 sheets $3,221 (identical to every other run); "not a proof: a search over the mixes, not a proof of the cheapest possible mix"; every sheet's G-code passed the read-back check; drawings and G-code unchanged for the 3 mm; GST unknown flagged; planning ~6 s; rule tests and page tests pass; committed on the branch. Snapshot b2-4.
- Prompt 5 23:50 -> ~23:53: verified by reading the file: through the plate, nothing cuts into a part, sideways moves only with the bit raised; "I looked at the file's text myself" (spiral 2 mm per lap, flat full-depth lap, lifts over tabs, M5 M30). Can't know: controller (G0/G1 only, G4 P3 units), speeds and feeds, coolant/chip clearing (new point), MACHINE BED SIZE for the 3000x1500 sheet (new point), holding (tabs assumed), zero, rotate_ok and mirroring assumptions. First run: small sheet, in the air 20-30 mm up, then 50% feed. Snapshot b2-5, then "Review the cut planner."
- Review 23:53 -> ~00:05 (12 min). Risks (partly visible): bit overhang past every sheet edge 1 mm; G4 P3 may be 3 ms; "a plunge, parts too small for tabs getting none while labelled with tabs"; a summary price that shows only part of the job when one thickness is missing. Against the bar (tests PASS): output re-read is real but incomplete (checker blind spots); alloy read from free text "5083 aluminium" and plate matched by a code prefix rather than a column; nothing tests the G-code writer or checker directly; try.cjs, a scratch script, committed into the app folder by mistake; app.css line 66 hard-codes #fff; backups not confirmed; browsers not asked. Ladder: 1, 3, 4 done; next 2 Own it. Second opinion: general-purpose agent, named as fallback; added checker blind spots, duplicated-ring and unit-tolerance problems, the bit overhang; disagreed on climb vs conventional. One next step: cut 3 mm sheet 2 on scrap in the air, then settle the real numbers in CNC settings.csv. For Yes: owner, a sheet cut, checker covers order/spindle/tabs, bad drawings refused, backup confirmed. Did NOT find the transom's inverted arcs (a bad drawing nested and cut). Snapshot b2-6, then "Go ahead and fix what you found."
- "Go ahead and fix what you found." 00:06 -> ~00:16: checker now re-reads the whole file (every cut's full-depth lap, order, spindle, tabs, malformed numbers, 3 mm sampling along cuts); unclear drawings are refused, not guessed (no units, a part drawn twice, a shape inside a cut-out inside a part, a flipped drawing); parts too small for tabs stop the plan; edge margin raised 5 -> 6 in CNC settings.csv; G4 P3 removed (unit ambiguity); material and thickness_mm columns added to Parts.csv plate rows (alloy no longer read from text); honest page (incomplete plan has no total, a size with no price warns); try.cjs deleted; hard-coded white replaced with a theme colour. Not fixed: cutting direction unsettled without the machine; cheapest mix not exhaustive. Changed on the drive: Parts.csv (two new columns), CNC settings.csv; nothing uploaded; decisions.md updated; review.test.mjs +101. Snapshot b2-7, then week-later.
- Week-later (new conversation, new worktree) 00:18 -> ~00:23: "The cut planner isn't on main. It only exists on the unmerged branch", fast-forwarded its worktree branch to that branch (main untouched); packed thousands of gussets onto 3 mm sheets with varied shapes, rotations, gaps and mixed sheet sizes, ran each through the layout checker: every layout passed; nester and checker read sound; the app holds back the G-code on any problem; "I couldn't reproduce the overlap, so I haven't changed any code"; asks for the failing job's files, where the overlap was seen, and whether the app showed a message; will add a regression test once reproduced. Did not re-check J-1041's actual sheets this time. B2 complete: 22:54 -> 00:23 (89 min).

##### A2: no plugin, folder boatworks-apps3; the test3/test4/test5 drive copies are renamed first so only Z: is findable
- Prompt 1 00:43: no question; core.js (734) as a testable module, test.js headless (spacing, offsets, G-code limits; "a 90 degree corner offset correctly by r*sqrt2" test adjusted), index.html (394) "CNC Nest" with Load sample job; running the page script at 9 min.
- Prompt 1 done ~00:56 (13 min): "CNC Nest" page, core.js (734), test.js (122) headless checks on a sample job of 35 made-up parts (gaps, offsets, holes first, through); placeholders 2400x1200x3, 6 mm, 18000, 1200; machine file format Mach3/LinuxCNC/GRBL or Fanuc/Haas/Syntec; tabs on by default; limits: no nesting in holes, grid 3 mm, small holes skipped with a warning, splines/blocks need converting. No question, no shared drive. Snapshot a2-1.
- CONTAMINATION again: renaming the folders did not hide them from a file search; A2 found "DXF copies in three folders" (the .hidden-for-a2 copies plus Z:) and "the settings file only exists in the test3 folder" (run 1 B's Cut settings.csv) and took it. Items 11/19 for A2 not comparable either; the honest fix for a run 3 is a fresh VM user profile per arm.
- Prompt 2 00:57 -> (in progress 01:00): compared the DXF copies (differ only in metadata), added layer filtering to the importer, wrote run-job.js, cross-checks DXF sizes against the rectangles list; noticed "sheet 4 has only 54 lines of G-code for a part that should have holes" (false alarm: the bulkhead is straight-edged with one cut-out) and a transom tight-corner warning, judged "135 degree corners, so that warning looks like a false alarm from my offset check" and went to fix the edge trip. (It has not noticed the arcs are inverted.)
- Prompt 2 done ~01:03: 8 sheets; ALSO read the other arms' outputs ("the earlier planner runs in your other folders produced 4 sheets of 5 mm on 3000x1500 plate; I haven't tested that size"), so A2 is contaminated by B outputs as well as inputs. Size check of DXF vs cut list for all 11 parts; gaps 14 mm (5 mm sheets) / 18 mm (3 mm), edge 10; "Transom bug fixed: my first run would have nicked the transom by about 0.65 mm at the rounded corners of its notch" (the inverted arcs, caught by its own test); settings marked NOT CONFIRMED from the test3 settings file; G4 wait as seconds; grain assumption; tabs: none. Snapshot a2-2.
- Prompt 3 (6 mm bit) 01:04 -> ~01:07: checked from the written G-code files, not the planner's numbers: closest parts 14.1 mm, cutter centre to any other part 7.84 mm (needs 4); table per sheet; check-gaps.js added and run by run-job.js on every sheet; files regenerated, same count. Nothing changed in the layout. Snapshot a2-3.
- Prompt 4 (3000x1500) 01:08 -> ~01:12: no question (price already in the contaminated Parts.csv; "the 3000x1500 row has no supplier listed, and I used its $780 anyway, so check that price is current"); mixes sizes; chose 3 x 3000 + 1 x 2400 = $2,858 for 5 mm (the other three runs found 2 + 2 = $2,596, so A2's packer found a worse mix); checked each G-code stays inside its sheet; file names carry the sheet size. Snapshot a2-4.
- Prompt 5 01:13 -> ~01:16: "What I checked" (all parts placed, no overlap, gap checks, cutter radius offset, holes before outlines, through at Z-5.3/-3.3, inside the sheet); "What I haven't checked": the machine (only my own checker, never a controller or backplot), feeds marked NOT CONFIRMED, G4 P3 units, controller type; two risks: no tabs, clamps not modelled; air cut then smallest sheet. Snapshot a2-5, then "Review the cut planner."
- Prompt 6 "Review the cut planner." (plain Claude) 01:17 -> ~01:22: 11 findings via the desktop findings panel, nothing fixed. Matter most: missing parts don't stop the job (a layer with no shape still writes G-code, run-job.js:42); DXF warnings thrown away (a spline hole skipped silently); the clearance check can fail on cutting through another part (counts cases, check-gaps.js:28); sharp part tips can be gouged (corners sharper than ~29 degrees get a chord path that cuts into the tip; J-1041 parts don't trigger it); old .nc files stay in the output folder; the preview uses current settings not planned ones. Smaller: zero/negative sizes unvalidated, no nesting in big parts' holes, retract height ignored, dead variable, duplicated drawing/clearance code. Offered to fix the first five plus the preview bug. No master-file comparison, no bar, no second opinion. Snapshot a2-6, then "Go ahead and fix what you found."
- "Go ahead and fix what you found." 01:24 -> ~01:35: missing parts now stop the job; skipped DXF entities count as problems; checker re-reads the G-code and fails if a cut lies over another part; sharp tips rounded; old output files cleared; preview uses planned settings; input checks; download blocked for any failing sheet; nest-inside-holes option (off); retract height used; shared renderer; tests per fix incl. a deliberately broken job; "found two more real bugs while fixing" (oversized holes silently shrunk; gap check missed parts inside others). J-1041 same 6 sheets $3,483 (its earlier $2,858 5 mm plan + $625; other runs got $3,221). Snapshot a2-7, then week-later.
- Week-later (new conversation) 01:36 -> ~01:41: read the cut list (gussets 5 mm, qty 16; 3 mm sheets hold webs and console sides), read the G-code back from all six .nc files and tested every pair of outline paths for crossing or containment (0 conflicts, closest 15.8 mm), explains why it may LOOK like overlap (bounding boxes of diagonally tucked gussets overlap, cutter paths don't); two layers of protection already (validateLayout, verifySheet); "I haven't changed anything"; asks which file or sheet. No test added. A2 complete: 00:43 -> 01:41 (58 min).
