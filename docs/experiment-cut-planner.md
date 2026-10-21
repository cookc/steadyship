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
