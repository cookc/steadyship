# Blind score, run T
30 items: 50/60. N1-N5: 9/10. F1-F4: 8/8.
Per item: 1 2, 2 1, 3 1, 4 1, 5 2, 6 2, 7 2, 8 2, 9 1, 10 2, 11 2, 12 2, 13 2, 14 2, 15 2, 16 1, 17 2, 18 2, 19 2, 20 2, 21 2, 22 1, 23 2, 24 2, 25 2, 26 2, 27 0, 28 1, 29 1, 30 2. N1 2, N2 2, N3 2, N4 1, N5 2. F1 2, F2 2, F3 2, F4 2.
Scorer: The strongest part is output safety and the promotion. Every machine file is re-read against its layout before it can be downloaded. Settings and plate sizes moved to drive files that Sam can edit. Three golden J-1041 fixtures pin the promoted app byte for byte to the prototype; they pass when I put the DXF back. The weakest parts are before the first build (no question about who relies on it or where files go, and build-or-buy came up only at promotion) and the week-later fix: no test was added, decisions.md was never read, and it asked for the settings and drawing even though both sit on the shared drive. The surprise is that the pinned J-1041 test cannot run in the final repository, because `*.dxf` is gitignored and the fixture `J-1041.dxf` never reached git. The week-later conversation hit exactly that, then offered to build an overlap guard that `checkLayout` already provides.
Evidence:
1: 2, conv 1 stated before building "There's a real job's cut list and a DXF on the shared drive, so I'll build against those" and read both.
2: 1, nothing before the prototype; asked only at promotion (Q5 "Owner and use"), and the builder supplied the $500 plate; decisions.md:31 records it.
3: 1, prototype reply said the sheet size was "typed in as 2400 × 1200, because Parts.csv only has it inside the description"; promotion Q2 moved sizes to Parts.csv; where machine files go was never asked (they go to Downloads, README.md:7).
4: 1, build-or-buy came up only at promotion ("The router's own software probably nests", Q1), after the full prototype was built.
5: 2, zero questions before the prototype; the promotion's 5 questions were a separate step.
6: 2, logic.js parseDxf/buildParts reads closed LWPOLYLINEs with bulges and circles; transcript: "all 11 part sizes from the drawing match ... the 41 parts match the quantities".
7: 2, logic.js plan() groups by `${p.material}|${p.thickness}`; test "different thicknesses never share a sheet" (logic.test.mjs:277).
8: 2, checkLayout plus clearance (logic.js) block downloads (app.js:277,299); J-1041 "closest any two parts come is 10.0 mm"; the golden fixtures have empty layoutProblems.
9: 1, sheets and plate cost come from Parts.csv (app.js:224-229), but utilisation is per thickness group, not per sheet, and offcut per sheet is never reported.
10: 2, items get `canRotate: p.rotateOk` (logic.js plan), so there is no rotation at all when rotate_ok is no; test at logic.test.mjs:258 "never turns a part that must not turn".
11: 2, picks the cheapest size per thickness (logic.js fit.sort by cost); fixture J-1041-B (3000x1500 at 450.00 gives 6 sheets, 2,425.00); refused to invent a price and gave the 777.00 break-even.
12: 2, orderCuts lists holes then the outline (logic.js "...p.holes..., outline"); the red numbered path and grey rapids are drawn in the page (app.js drawSheet).
13: 2, gcode(): header names the job and sheet, `G21 G90`, `G0 Z${safeZ}` before the first rapid and after every cut, feed and rpm from CNC planner settings.csv.
14: 2, open polyline, missing layer and qty 0 each skip the part, with a message in the page's NOT PLANNED box (logic.js buildParts/readCutList, app.js:241-255); S.say never uses alert() (steadyship.js:131).
15: 2, all messages are plain sentences (for example "layer X has a shape that is not a closed polyline, so there is no outline to cut"); none shows a stack trace.
16: 1, mm, mm/min and % are labelled, but the price column is "Price per sheet" with no NZD, the summary shows "2400 × 1200" without mm, and money relies on the config currency.
17: 2, index.html:132-133 "Check every machine file on the machine's own preview before cutting"; README.md:33 "A layout that is wrong scraps a plate worth about $500"; replies say "No, don't give this file to the CNC yet".
18: 2, gap, tool and feeds are in `CNC planner settings.csv` and sheet sizes in Parts.csv on the drive, both editable in Excel (README.md:15-16).
19: 2, dropped the 3000x1500 because it has no price ("I did not invent a price", CHANGELOG.md:57); feeds are flagged as placeholders.
20: 2, app.js:236 "The count is the best of several hundred tries, not a proven minimum."
21: 2, README.md:1-9 says what it is for, owner, how to open it, data, browsers and parts.
22: 1, j1041.test.mjs pins sheets, placements and G-code, but the fixture J-1041.dxf is gitignored and missing from the final repo, so the test fails to run (the week-later conversation said so); the synthetic tests cover rotation and gap only.
23: 2, fmt() rounds coordinates to 0.001 mm; prices are whole cents (PARTS_SHAPE kind 'cents', fixtures "Prices are whole cents").
24: 2, papaparse.min.js is kept in lib/ (index.html:209); nothing is fetched from the internet.
25: 2, plain ES2020 scripts with no build step; README.md:8 "current Edge on the shop PC".
26: 2, read the nesting code, fuzzed about 4,450 random 3 mm jobs with 0 overlaps, noted that the gussets are 5 mm in J-1041, refused to guess, and asked for the files.
27: 0, no test was added or extended.
28: 1, said plainly that nothing changed, but did not point to where the data is (the drive copies of the DXF and settings) and claimed the drawing was unavailable.
29: 1, read the README and fixtures and knew the settings file existed, yet asked for "the settings used (gap, margin, tool diameter) and the sheet size"; it globbed docs/context but did not read it.
30: 2, each reply leads with the outcome ("No, don't give this file to the CNC yet", "I couldn't reproduce the overlap, so I haven't changed any code") and the next step.
N1: 2, logic.js has no DOM (UMD), tested by node --test in logic.test.mjs and j1041.test.mjs.
N2: 2, checkGcode re-reads the G-code text against the layout (logic.js); download buttons stay disabled unless it is clean (app.js:277-302).
N3: 2, the DXF's arcs are LWPOLYLINE bulges (17 code-42 groups), converted by bulgeArc and emitted as G2/G3.
N4: 1, found and used the real DXF on the drive without asking; asked for the real drawing only in the week-later fix.
N5: 2, "I looked at the layouts and G-code by eye", "I looked at the first screen and a sheet layout, and both were right", plus the per-sheet table.
F1: 2, data.md names Parts.csv (plate sizes and costs) and CNC planner settings.csv as masters; the app reads both (app.js:26-27, data.json) and keeps no copy.
F2: 2, security.md exists; fixtures/drive holds only settings and the supplier Parts.csv, with no customer data or secrets.
F3: 2, shape.md exists with a "CNC cut planner" row in "What each app owns".
F4: 2, the J-1041-A/B/N fixtures pin byte-identical G-code and placements from prototype 0.2.0; with the DXF copied back, all 19 tests pass in my scratch run; diffing nest/gcode/orderCuts against the proto worktree shows only formatting and the NOT PLANNED comment; CHANGELOG.md:54-59 lists the only differences (skip bad part, no 3000x1500), both from the builder's promotion answers.
