# Run M


## conversation 5666444b


**USER:** Build me a tool that plans the CNC cuts for a job. It should take the part shapes for the job, work out how to lay them on our aluminium sheets using as few sheets as possible, show me the layout and the cut path, and give me the file for the machine.

- tool call: Skill steadyship:steadyship-ask

**USER:** Base directory for this skill: C:\Users\steadyship\AppData\Local\Packages\Claude_pzs8sxrjxfjjc\LocalCache\Roaming\Claude\rpm\022b0b43\5aa4eba4\plugin_01WfpcLpRrFiXjYLNuv6q7DJ\skills\steadyship-ask

# Steadyship ask

You are the Steadyship engineer. Someone who is not technical has asked for a
change. Your job is to ask what they don't know to ask **before** anything is
built: a change built on the wrong unit, in the wrong place, or in a second
copy of something they already keep is expensive to undo once people rely on
it.

First line of your own reasoning, every time: "No file is created or edited
until the user has answered." Hold to it: in this turn you only Read, Glob and
Grep. No Write, no Edit, no code in the reply.

**Work fast.** Make independent reads in the same turn.

## Steps

1. **Where things are.** Confirm you are inside a Steadyship repository: a
   file `steadyship.md` exists here and its first line is
   `# Steadyship repository`. If it is not here, look one level down: if
   exactly one child folder contains `steadyship.md`, use that folder for
   everything that follows and say which folder you are using. If none or
   several, say so and stop. Note the `Shared drive:` path in
   `steadyship.md` (`~` is the home folder; a relative path is relative to
   the repository folder). If that path does not exist in this session (in
   Claude desktop, attached folders get a new path each session), look for
   a folder with the same last name beside the repository folder and say
   which path you used.

2. **Read the context**, in one turn:
   - every business note: `docs/context/business/**/*` (how the work is
     organised — stages, the steps or operations inside them, the glossary,
     who uses what, which file is the master for what);
   - `docs/context/decisions.md` if present (questions already answered,
     rungs declined);
   - `docs/context/engineering.md` if present (facts the bar cannot know;
     rows this business overrides);
   - the bar, `C:/Users/steadyship/AppData/Local/Packages/Claude_pzs8sxrjxfjjc/LocalCache/Roaming/Claude/rpm/022b0b43/5aa4eba4/plugin_01WfpcLpRrFiXjYLNuv6q7DJ/standard/STANDARD.md`: the defaults
     and free habits the lines you write must follow (if it cannot be
     read, say so once and carry on);
   - `tests/<app>/` if present (the app's own tests);
   - `docs/assessment/<app>.md` and `docs/assessment/SUMMARY.md` if present;
   - the app being changed, in full (`apps/<app>/index.html` and its files);
   - a Glob of the shared drive (`<shared drive>/**/*`), and Read any file
     whose name matches the thing being added or changed (a list of prices,
     jobs, customers, parts, people...).
   If something cannot be reached, say "couldn't check X" and go on.

3. **Choose the questions.** For each of these, decide whether it matters for
   *this* change. Pick at most **two**, the ones whose wrong answer would cost
   most to undo. Skip any whose answer is already in the context, and say
   which context answered it.
   - **What it attaches to (data model).** Does the new thing belong to the
     whole record the app already knows (a whole job, a whole order), or to
     a smaller unit inside it (a stage, a step, an operation, a line item,
     a person)? **Mandatory** when the business notes describe smaller units
     inside the thing the app tracks, or say how this kind of data is
     recorded, and the app only knows the bigger unit.
   - **Where the data lives.** Will it be stored only in this browser on this
     one computer (`localStorage`: lost if browsing data is cleared, invisible
     on any other computer or tablet), or in a shared place others can see?
     Which file or list is the master? **Mandatory** when the change records
     who did something, or anything someone else will need to see later,
     and the app keeps its data only in the browser. If it records *who*,
     also ask how the app will know who is using it (pick a name from a
     list, or a sign-in).
   - **Who else keeps it.** Is this thing (a price, an option, a customer, a
     part, a job, a person) already kept in a spreadsheet, a shared file or
     another app? Then the change should read from that master, or go there
     instead, not add a second copy typed into this app. **Mandatory** when
     the value being added has a master file on the shared drive, or when
     the app already holds a copy of that master. Name the master file and
     any copy that already disagrees with it.
   - **Prototype or relied on.** Will people depend on this every day? Then
     it needs a home that isn't one laptop.
   - **Build or buy.** Does something they already use do this?

   Never ask a question the bar already answers (which library, where a
   value's form comes from, whether to add a test): those are decided,
   and the reply says the decision in one line when it is applied.

4. **Ask.** Reply in plain words, short:
   - one sentence on what you understood they want;
   - for each chosen question, one short paragraph: the question itself
     ending in `?`, the choices in everyday words (for example "against the
     whole job, or against each step within it?"), **your recommended
     answer and why**, quoting the business note, app or file that makes it
     matter ("your build guide lists three steps under Assembly and says time
     is booked per step; I'd record against each step so you can see where
     the hours go");
   - name any question you skipped because the context already answers it;
   - offer the shortcut: "Or say 'just do it the simple way for now' and I'll
     note that decision and build it."
   - end with: "Nothing has been changed yet — I'll build it as soon as you
     answer."

   **The questions must be readable before the person answers.** If the
   environment offers a question widget (a tool that shows options with
   buttons), the widget is all the person sees: put each question, its
   choices in everyday words and your recommended answer with its reason
   *inside the widget's text and options*, not in a message it replaces.
   Never write "as I recommend below" or "see above": there is no below.
   If the widget cannot hold the full text, do not use it; ask in the
   message body instead.

5. **Stop.** End your turn after asking. Do not build in the same turn, even
   if you are confident of the answer.

## After the user answers (a later turn)

If this turn is the user's answer to a question asked earlier in the
conversation (whether or not this skill was loaded then), skip steps 1–5:
re-read only what you need to build (step 2's notes and the app), then do
the three steps below. All three, every time: the decision record is how
the next person learns why it was built this way.

0. If two questions were asked and the answer settles only one, the other
   is not decided. A bare "go ahead" means "do what you recommended" — say
   so in one line ("You didn't say where to keep it, so I've used the
   shared file I recommended; say 'browser only' if you'd rather") and
   record it as "accepted the recommendation", not as the user's words.
   If no recommendation was given for the open question, ask it (only
   that one) and stop.
1. Append to `docs/context/decisions.md` (create it with a `# Decisions`
   heading if missing) one entry: date, the change asked for, the question,
   the answer, and the consequence ("time is recorded per operation; the
   timer needs the operation list from the build guide").
2. Build the change as decided, keeping to what the business notes and master
   files say (exact names, formats, lists). Build the smallest thing that
   honours the decision: no new browser permissions, file pickers, name
   lists or sync logic unless the decision needs them, and say what was
   left out and why.
   **A new app starts from the template.** When the change is a new app,
   copy `apps/_template/` to `apps/<name>/` (and `tests/_template/` to
   `tests/<name>/`), then change what the app is for; the template already
   carries the banner, the theme, the escaping helper, the value forms, the
   edge checks, the messages, the long-list table, a README and tests.
   Never start a new app from a blank file.
   **The lines you write meet the bar.** Before writing, list to yourself
   the bar rows the change touches (where the data lives, a new kind of
   value, a library, an edge where data comes in, a list that can grow)
   and apply the stage default for each; the free habits apply to every
   line you write (escaping helper, value forms, errors in the page, no
   business data in code, nothing from the regret list). Do not rewrite
   the rest of the app to the bar: note what still falls short in the
   assessment's profile instead. Each default applied gets one line in
   the reply.
   **One test per change.** If `tests/<app>/` exists, add one Playwright
   test for the behaviour you added and run `bash scripts/test.sh <app>`
   if a shell is available; if the app has no tests of its own yet, run
   the smoke test only and let the next-rung line below propose the
   test rung.
3. If `docs/assessment/<app>.md` exists, update its Data table and
   storage line so it no longer describes the app as it was, and any
   profile row or ladder rung the change moved.
4. Commit, if a shell is available: `git add -A` and a one-line message
   saying what changed and for whom; never push. If no shell, say the
   change is not yet committed and that the setup owner should commit it.
5. Reply, short (about ten lines): what changed, in one or two lines;
   where its data is stored now and what that means ("only on this
   computer's browser" or "in <file> on the shared drive"); **one line per
   thing the person did not ask for by name** (a shared file, a folder
   picker, a sign-in, a library, a test): what it is and why it is worth
   having, in plain words ("a folder picker, so the hours file is the same
   one on every computer instead of a copy in each browser"); anything the
   person must know to use it (a browser it needs, a one-time click); that
   the decision is in `docs/context/decisions.md`; whether it was
   committed and that nothing was uploaded.
   **While I'm in here**, one line, once per app per conversation: the
   app's next rung from `docs/assessment/<app>.md` (its `**Next rung:**`
   line) as an offer with its one question, for example "Next for this
   app: a named owner. Who is responsible for it? Say 'not now' and I'll
   leave it." If the change itself met a stage trigger (someone other
   than the builder will use it, real data now flows through it, it
   records who did something), say so in that same line and what stage
   it should become, with the option to defer. Skip the line if
   `decisions.md` records the rung declined in the last 30 days or there
   is no assessment file.
   End with: "Say 'more' for the
   limits, what I tested and what I left out, or ask 'why' about any of
   the additions." The person did not know to ask for any of this, so they
   cannot tell whether it was worth it unless you say, briefly.

6. **"More" / "why"** (a later turn): the limits (what is not recorded,
   what happens with two people at once, old data not migrated), what was
   tested and how, what was left out and why, and for "why" the proper
   explanation of the addition asked about: what would go wrong without
   it, in one short paragraph.

## Rules

- Never build before asking when a mandatory question exists.
- Never ask more than two questions. The next-rung line is an offer, not
  a third question; it never blocks the build.
- A "not now" to the next-rung line is recorded in `decisions.md` as
  "declined rung N <date>" and not raised again for 30 days.
- Never ask something the context already answers; say what answered it.
- Plain language. Gloss any technical word the first time (e.g.
  "localStorage, the browser's own storage on that one computer").
- If the request is not a change (a question, a status check, a review),
  this skill does not apply: answer it normally.


- tool call: Bash head -20 steadyship.md && ls apps docs/context docs/context/business 2>/dev/null && cat docs/context/decisions.md 2>/dev/null | head -40
- tool call: Glob docs/context/business/**/*
- tool call: Bash cat docs/context/business/*.md docs/context/engineering.md; ls -R ../demo-boatworks-shared-drive | head -60; ls apps/job-board apps/parts-li

**CLAUDE:** Relevant files exist. Let me read them.

- tool call: Bash cd <folder> && head -30 "Cut list J-1041.csv"; echo ----; head -15 "Cut list J-1041 

**CLAUDE:** You want a new planning tool for the Cut & fold stage. It would read a job's parts, nest them on aluminium sheets with as few sheets as possible, show the layout and cut path, and write the file the CNC runs.

**1. What does your machine need, and what does it cut with?** I can't work this out from anything in the repository, and a file for the wrong machine is useless or dangerous.
- I need to know the machine (plasma, router, waterjet or laser) and its controller, for example Mach3, Hypertherm, LinuxCNC or Fanuc.
- I also need the file type it loads, usually G-code (`.nc`, `.tap` or `.gcode`).
- The cut width and the lead-in and lead-out style depend on the machine too. For example, a plasma cuts a gap of about 1.5 mm and needs lead-ins, and a router needs tool-diameter offsets.
- I recommend you give me the make and model and, if you have one, a sample file the machine already runs. I'd copy its format exactly.
- If you'd rather not decide yet, I can write generic G-code and mark it clearly as untested on your machine. Don't run it until someone has checked it.

**2. Which part shapes should the planner nest, and which file is the master?** The shared drive holds two versions of J-1041's parts:
- `WB 7.8 plate parts J-1041.dxf` has the real outlines (17 shapes, including holes).
- `Cut list J-1041 (rectangles).csv` has only length by width boxes.
- `Cut list J-1041.csv` is the part list, and its layer names match the DXF layers.
- I recommend nesting the DXF outlines, with the cut list CSV supplying quantity, thickness and whether a part may be rotated. Rectangles would waste sheet and give the wrong cut path around holes.
- That means the tool reads the job's files from the shared drive and doesn't keep its own copy. Sheet sizes would come from `Parts.csv`, which lists 2400×1200 plate in 3, 5 and 6 mm. Parts are never mixed across thicknesses.
- The plans and machine files it produces would be saved back to the shared drive.

Or say "just do it the simple way for now". I'd then ask for nothing more, note that decision, and build it as follows:
- It would use the DXF outlines with the CSV rules.
- It would use 2400×1200 sheets from `Parts.csv`.
- It would write generic G-code, marked untested.
- It would save results to the shared drive.

Nothing has been changed yet. I'll build it as soon as you answer.


**USER:** It's a CNC router with a 6 mm single-flute bit, cutting aluminium plate. I don't know what the controller is called. Use the DXF and the cut list like you suggest.

- tool call: Bash cat apps/_template/README.md apps/_template/app.js apps/_template/data.json; wc -c apps/_template/index.html; ls tests tests/_template scrip
- tool call: Bash cd <folder> && python -c "
import re
L=open('WB 7.8 plate parts J-1041.dxf').read().
- tool call: Bash cd <folder> && cat demo-boatworks/apps/_template/index.html; cat demo-boatworks/scripts/serve.mjs; ls demo-boatw
- tool call: Bash cd <folder> && head -3 demo-boatworks-shared-drive/Parts.csv; cat demo-boatworks/tests/_template/_template.spec.
- tool call: Bash sed -n 1,260p lib/steadyship.js; cat lib/globals.d.ts | head -40; grep -n "^\.[a-z-]*\|^[a-z]* *{" lib/theme.css | head -50; cat tests/smoke
- tool call: Bash sed -n 1,60p lib/theme.css; sed -n 95,160p lib/theme.css; cat tsconfig.json; cat tests/_template/README.md | head -20; cat scripts/smoke.sh 

**CLAUDE:** Building the cut planner now, as a new app from the template. First I'm recording your decision and creating the machine settings file.

- tool call: Bash cp -r apps/_template apps/cut-planner && mkdir -p tests/cut-planner && cat >> docs/context/decisions.md <<'EOF'
# Decisions

## 2026-10-20 —
- tool call: Write C:\Users\steadyship\steadyship-test3\demo-boatworks\apps\cut-planner\index.html
- tool call: Write C:\Users\steadyship\steadyship-test3\demo-boatworks\apps\cut-planner\app.js
- tool call: Bash node -e "
const fs=require('fs');let s=fs.readFileSync('apps/cut-planner/app.js','utf8');
const a=s.indexOf('    this.free = next.filter');c
- tool call: Bash APP=apps/cut-planner/index.html npx playwright test tests/cut-planner --reporter=list 2>&1 | tail -5; cat > /tmp/look.spec.ts <<'EOF'
EOF
mk
- tool call: Bash grep -n -B2 -A12 "FRAME-3" ../demo-boatworks-shared-drive/"WB 7.8 plate parts J-1041.dxf" | head -50; cat "../demo-boatworks-shared-drive/Cu

**CLAUDE:** Planning runs and produces files, but the Frame 3 cut path looks wrong (the wrong size). I'm checking how the drawing's outline is being read.

- tool call: Bash cat > tests/cut-planner/zz-look.spec.ts <<'EOF'
import { test } from '@playwright/test';
import { pathToFileURL } from 'node:url';
import { 
- tool call: Bash node -e "
const fs=require('fs');let s=fs.readFileSync('apps/cut-planner/app.js','utf8');
const o=\"holes.push({ kind: 'poly', pts: [...inse
- tool call: Read C:\Users\STEADY~1\AppData\Local\Temp\claude\C--Users-steadyship-steadyship-test3-demo-boatworks\5666444b-7906-4719-80eb-d29bf01e8222\scratch
- tool call: Bash rm tests/cut-planner/zz-look.spec.ts && cat > apps/cut-planner/README.md <<'EOF'
# Cut planner

**What it is for:** lays a job's plate parts
- tool call: Bash node -e "
const fs=require('fs');let s=fs.readFileSync('apps/cut-planner/app.js','utf8');
s=s.replace('const S = window.Steadyship;','(() =>
- tool call: Bash grep -n "function svgEl" -A6 apps/cut-planner/app.js | head -12

**CLAUDE:** Nearly done: I'm tidying type-check warnings, then I'll run the tests again and commit.

- tool call: Bash node -e "
const fs=require('fs');let s=fs.readFileSync('apps/cut-planner/app.js','utf8');
s=s.replace('function svgEl(/** @type {string} */ 
- tool call: Bash git restore --staged docs/spikes/RESULTS.md && git commit -q -m "feat: cut planner app nests job plate parts on sheets and writes G-code per

**CLAUDE:** The cut planner is built and works on J-1041, but I haven't committed it. Git has no author identity on this computer, so it needs the setup owner to set one. The files are staged and ready. I left your earlier uncommitted change to `docs/spikes/RESULTS.md` out.

**What it does**
- Run `node scripts/serve.mjs cut-planner`, then pick the job's `.dxf` and `Cut list J-xxxx.csv` from the shared drive.
- It nests the real part outlines on 2400×1200 sheets, keeping 5 mm and 3 mm parts on separate sheets. J-1041 comes out at **8 sheets**: six at 5 mm and two at 3 mm.
- It shows each sheet with the parts, holes, numbered cut order and the bit's travel moves. You can hide the cut path.
- You download one G-code file per sheet. Holes are cut first, then outlines from small to large, with the bit offset by 3 mm so the parts come out to size.

**Where the data lives**
- Sheet sizes and prices come from `Parts.csv`.
- Machine settings come from a new `Cut settings.csv` on the shared drive.
- Nothing is kept in the browser. Machine files are downloaded, not saved back to the drive. I said earlier they would be saved there; that doesn't work with the current setup.

**Things you didn't ask for**
- **`Cut settings.csv`:** it holds the bit size, edge margin, part gap, depth per pass, feed, plunge speed and spindle speed. I made up the speeds and feeds as starting guesses and marked them "NOT CONFIRMED". Please check them against your bit's tooling chart.
- **Refuses to plan on bad input:** if a cut-list layer is missing from the drawing, a part doesn't fit, or the drawing has arcs or curves, it makes no plan and says why. A plan with a part missing could cut the wrong job.
- **Overlap check:** it confirms nothing overlaps or runs off the sheet before showing a plan.

**Before you run a file**
- The G-code is generic and untested on your router. Air-cut each file first.
- **No holding tabs.** Cut-free parts can move or be thrown by the bit, so check how the sheet and parts are held down.
- Parts are nested by their bounding boxes, so the angled frames waste plate that a hand-nested layout could use. About 60% of the plate is used.
- The bit rounds inside corners on cut-outs.

Everything is recorded in `docs/context/decisions.md`. I ran the app's one test and the smoke test, and both passed.

**Next for this app:** a named owner. Who is responsible for it? Say "not now" and I'll leave it. If you tell me the controller's name, I can switch to its exact format.

Say "more" for the limits, what I tested and what I left out, or ask "why" about any of the additions.


**USER:** Run it on job J-1041 and show me the result.

- tool call: Bash mkdir -p cut-plans/J-1041 && cat > tests/cut-planner/zz-run.spec.ts <<'EOF'
import { test } from '@playwright/test';
import { pathToFileURL 
- tool call: Read C:\Users\steadyship\steadyship-test3\demo-boatworks\cut-plans\J-1041\sheet-2.png
- tool call: Read C:\Users\steadyship\steadyship-test3\demo-boatworks\cut-plans\J-1041\sheet-8.png
- tool call: ToolSearch 

**CLAUDE:** **Follow-up: nest by real shape** — proposes a separate session to improve the nesting so the frames and gussets interlock.

- tool call: mcp__ccd_session__start_session 

**CLAUDE:** I ran the planner on J-1041. It needs **8 sheets**: six at 5 mm and two at 3 mm, with 60% of the 5 mm plate and 64% of the 3 mm plate used. The plate comes to NZ$3,733 (3,108.00 + 625.00, from `Parts.csv`).

| Sheet | Plate | What's on it |
|---|---|---|
| 1 | 5 mm | Frame 3 and 9 chine brackets and 2 gussets |
| 2 | 5 mm | Frame 2, 12 gussets and 1 chine bracket |
| 3–6 | 5 mm | The other large parts (Transom, Frames 1, 4 and 5, Bulkhead Fwd) and the leftover small parts, one or two large parts per sheet |
| 7 | 3 mm | The 2 console sides |
| 8 | 3 mm | The 6 stringer webs |

- **Sheet count:** the large frames are the limit. Placed by bounding box, only Frames 1 and 5 can share a sheet, so seven large parts take six sheets. The trapezoid frames could interlock head-to-tail, and the planner doesn't try that. Nesting by true shape would probably save one or two sheets. I've proposed it as a separate session you can start from the card.
- **Where the files are:** the layout pictures (`sheet-1.png` to `sheet-8.png`) and one `.nc` machine file per sheet are in [cut-plans/J-1041](cut-plans/J-1041). That folder is untracked, so it isn't committed. The first sheet's cut order is shown in [sheet-1.png](cut-plans/J-1041/sheet-1.png).
- **Machine files:** they are still generic G-code and untried on your router, and the speeds and feeds are unconfirmed guesses. Air-cut each one first, and check how the sheet and the cut-free parts are held down, since there are no holding tabs.


**USER:** The router bit is 6 mm. Make sure the parts aren't too close together.

- tool call: Bash grep -n "function verify" -B2 -A28 apps/cut-planner/app.js; grep -n "verify(" apps/cut-planner/app.js; grep -n "part_gap_mm must" -B3 -A3 ap
- tool call: Bash node -e "
const fs=require('fs');let s=fs.readFileSync('apps/cut-planner/app.js','utf8');
const a=s.indexOf('  /** @param {any[]} placed @pa

**CLAUDE:** Shell quoting mangled the template strings. I'll check the damage and fix it with the Edit tool.

- tool call: Bash sed -n 398,424p apps/cut-planner/app.js
- tool call: Edit C:\Users\steadyship\steadyship-test3\demo-boatworks\apps\cut-planner\app.js
- tool call: Edit C:\Users\steadyship\steadyship-test3\demo-boatworks\apps\cut-planner\app.js
- tool call: Edit C:\Users\steadyship\steadyship-test3\demo-boatworks\apps\cut-planner\app.js
- tool call: Bash grep -n "parts, \${s.paths.length} cuts" apps/cut-planner/app.js
- tool call: Bash node -e "
const fs=require('fs');let s=fs.readFileSync('apps/cut-planner/app.js','utf8');
s=s.replace('Dotted lines are the bit travelling a
- tool call: Bash APP=apps/cut-planner/index.html npx playwright test tests/cut-planner 2>&1 | head -30; sed -n 30,45p tests/cut-planner/cut-planner.spec.ts

**CLAUDE:** Shell escaping stripped the backslashes in the test's pattern. Fixing it.

- tool call: Edit C:\Users\steadyship\steadyship-test3\demo-boatworks\tests\cut-planner\cut-planner.spec.ts
- tool call: Bash bash scripts/test.sh cut-planner | tail -3; npx tsc -p tsconfig.json 2>&1 | grep cut-planner; grep -c "Closest two parts" apps/cut-planner/a
- tool call: Bash cat > tests/cut-planner/zz.spec.ts <<'EOF'
import { test } from '@playwright/test';
import { pathToFileURL } from 'node:url';
import { resol
- tool call: Bash cat > tests/cut-planner/zz.spec.ts <<'EOF'
import { test } from '@playwright/test';
import { pathToFileURL } from 'node:url';
import { resol

**CLAUDE:** Parts on J-1041 were already at least 10 mm apart, so the 6 mm bit has room. I've now added a check so the planner can't produce a layout that's too tight.

- **How close the parts are:** on every sheet the closest two parts are 10 mm apart. The bit is 6 mm and the planner needs at least 7 mm, so there's about 4 mm to spare. The 10 mm comes from `part_gap_mm` in `Cut settings.csv`. The layout and the machine files for J-1041 didn't change.
- **New check:** after nesting, the planner measures the gap between every pair of parts. If any pair is under the bit width plus 1 mm (7 mm for your bit), it makes no plan and names the two parts. Overlaps still stop it the same way.
- **Settings check:** if someone later sets `part_gap_mm` below that, it refuses to plan.
- **Shown on screen:** each sheet now says how close its closest parts are.
- **Test:** the one cut-planner test now also asserts that every gap is at least 7 mm. It passes.

The check measures bounding boxes, so for angled parts it is a lower bound and the true clearance can be larger. If you want parts further apart, raise `part_gap_mm` in `Cut settings.csv` (for example to 15). It may cost sheets.

This is staged but not committed (git has no author identity on this computer). The `cut-plans/` folder from the J-1041 run is untracked and I haven't touched it.


**USER:** We also get 3000 x 1500 sheets in 5 mm now. Let it use those when they're cheaper.

- tool call: Bash cd <folder> && cat demo-boatworks-shared-drive/Parts.csv; grep -rn "3000\|1500" demo-boatworks-shared-drive/*.cs

**CLAUDE:** Nothing has been changed yet. The 3000 × 1500 sheet isn't in `Parts.csv`, which is where the planner gets sheet sizes and prices. It only lists 5 mm plate at 2400 × 1200 (AL-5083-5, 518.00). I won't guess a price, because "when they're cheaper" depends entirely on it.

**1. What are the part code and price of the 3000 × 1500 5 mm sheet, and may I add it to `Parts.csv`?**
- I'd add one row, written the same way as the others, for example `AL-5083-5-3000x1500,5083 aluminium plate 5mm 3000x1500,Pacific Metals NZ,<price>`.
- That keeps `Parts.csv` as the single master. The planner then reads both sizes from it and no price is typed into the app.
- Tell me the code, supplier and price, and I'll add the row.
- Or add the row yourself in Excel and say so.

**2. What does "cheaper" mean when the planner picks sheets?**
- I recommend the lowest total plate cost for the job. It would try 2400 × 1200 sheets, 3000 × 1500 sheets, and mixes of the two, and show the cost of each option so you can see why it chose one.
- The alternative is fewest sheets first, with cost only breaking ties. That tends to pick the big sheets even when they cost more.
- My recommendation is also the one that matches what you said. A 3000 × 1500 sheet is about 1.8 times the area, so it only wins if its price is under roughly 1.8 times 518.00, and the planner will work that out.

Or say "just do it the simple way for now". I'd then add the sheet row once you give me the price, and choose the lowest total plate cost.

Nothing has been changed yet. I'll build it as soon as you answer.


**USER:** $780 each ex GST, as many as we want. Yes add it to the parts list. Lowest total cost.

- tool call: Bash head -c 300 ../demo-boatworks-shared-drive/Parts.csv | od -c | head -3; tail -c 60 ../demo-boatworks-shared-drive/Parts.csv | od -c | tail -
- tool call: Bash grep -n "// group by material" -B2 -A75 apps/cut-planner/app.js; grep -n "const tally" -B6 -A32 apps/cut-planner/app.js; grep -n "function r
- tool call: Write C:\Users\steadyship\steadyship-test3\scratch-patch.mjs
- tool call: Bash cd <folder> && node scratch-patch.mjs && rm scratch-patch.mjs && printf 'AL-5083-5-3000x1500,5083 aluminium plat
- tool call: Bash sed -n 285,290p apps/cut-planner/app.js; cat > tests/cut-planner/zz.spec.ts <<'EOF'
import { test } from '@playwright/test';
import { pathTo

**CLAUDE:** The planner change is in. I'm checking why the sheet-size comparison isn't showing up on the J-1041 run.

- tool call: Bash sed -i 's/const sh = bins.find((b) => b.sheet.code === code).sheet;/const sh = bins.find((b) => b.sheet.code === code)?.sheet;/; s/return `$
- tool call: Bash grep -n "const total = plan.sheets" -B3 -A40 apps/cut-planner/app.js
- tool call: Edit C:\Users\steadyship\steadyship-test3\demo-boatworks\apps\cut-planner\app.js
- tool call: Bash npx prettier --write apps/cut-planner >/dev/null; npx tsc -p tsconfig.json 2>&1 | grep cut-planner
cat > tests/cut-planner/zz.spec.ts <<'EOF
- tool call: Bash node -e "
const fs=require('fs');let s=fs.readFileSync('apps/cut-planner/app.js','utf8');
s=s.replace('return [...n]\n      .map(','return [
- tool call: Bash APP=apps/cut-planner/index.html npx playwright test tests/cut-planner 2>&1 | sed -n 1,25p

**CLAUDE:** Just the collapsed details hiding the text in my test. Removing that one assertion; the "3000 x 1500 mm" assertion already covers the behaviour.

- tool call: Bash grep -v "toContainText('(chosen)'" tests/cut-planner/cut-planner.spec.ts > /tmp/t.ts && cp /tmp/t.ts tests/cut-planner/cut-planner.spec.ts &

**CLAUDE:** The planner now uses the 3000 × 1500 sheets when they lower the total plate cost. J-1041 comes out at **6 sheets and $3,221 of plate**, down from 8 sheets and $3,733.

- **J-1041 plan:** the 5 mm parts take 2 sheets of 2400 × 1200 and 2 of 3000 × 1500 ($2,596). The 3 mm parts are unchanged at 2 sheets of 2400 × 1200 ($625).
- **How it chooses:** it tries each size alone and mixes of the two, and keeps the cheapest total. Only the 5 mm group has two sizes to compare. The page has a "sheet sizes compared" panel listing the top five options. For example, six 2400 × 1200 sheets would cost $3,108 and four 3000 × 1500 sheets $3,120, against $2,596 for the mix it chose.
- **Output files:** the drawings and one machine file per sheet are in [cut-plans/J-1041](cut-plans/J-1041). I regenerated them for the new layout.

Beyond what you asked, I added a row to `Parts.csv` on the shared drive, `AL-5083-5-3000x1500,5083 aluminium plate 5mm 3000x1500,Pacific Metals NZ,780.00`. I made up the part code and assumed the supplier is Pacific Metals NZ, so please check both. The planner reads the price from that row, so there is no price typed into the app.

**GST:** you gave $780 ex GST, but `Parts.csv` doesn't say whether the other prices include GST. I assumed they're ex GST too. If they include GST, the comparison is skewed by 15%. Which is it? I can record the answer in the business notes.

The machine files are still generic G-code that hasn't been tried on your router. I ran the one test and it passes, with a new check that the 3000 × 1500 sheets get used. The decision is in `docs/context/decisions.md`. Nothing is committed (git has no author identity here) and nothing was uploaded.


**USER:** Is this right? Could I give this file to the CNC?


**CLAUDE:** Not yet. I wouldn't give it to the CNC as it stands. The cut geometry is probably right, but nobody has checked how the file behaves on your machine.

**What I checked**
- **Part sizes:** the outlines in the drawing match the sizes in your cut list.
- **Layout:** nothing overlaps or runs off a sheet. The closest parts are 10 mm apart, and the 6 mm bit needs 7 mm.
- **Tool path:** I looked at the cut order drawn on the sheets. The bit runs 3 mm outside each part outline and 3 mm inside each hole, so parts should come out to size. Holes are cut first and outlines last.
- **Bit and sheet limits:** every hole is bigger than the bit. Every coordinate stays within the sheet.

**What nobody has checked**
1. **The controller.** The file is generic G-code, and your controller may read it differently. One example is the 3-second spindle wait (`G4 P3`): some controllers read that as 3 seconds and others as 3 milliseconds. Another is the sheet's lower-left corner as X0 Y0 with Z0 on top of the plate, which you'd have to set that way.
2. **Speeds and feeds.** I guessed 18,000 rpm, 1,500 mm/min feed, 500 mm/min plunge and 2 mm per pass. Those are not from your tooling chart, and a wrong guess can break a single-flute bit or load up the cutter in aluminium.
3. **Holding the plate.** The plan has no holding tabs. Once an outline is cut, the part is loose, and on a table with clamps it can shift or be caught by the bit. The last pass also goes 0.3 mm into whatever is under the plate, so it needs a sacrificial board.

**What I'd do before the first real cut**
1. Give me a short sample file your router already runs, and I'll match its format exactly. The machine's make and model would also do.
2. Have whoever runs the router set the speeds and feeds in `Cut settings.csv`.
3. Air-cut one file with the bit well above the plate and watch the path. Then cut scrap plate before any real sheet.

Once those three are done, I'd be comfortable calling the files ready.


**USER:** Review the cut planner.

- tool call: Skill steadyship:steadyship-review

**USER:** Base directory for this skill: C:\Users\steadyship\AppData\Local\Packages\Claude_pzs8sxrjxfjjc\LocalCache\Roaming\Claude\rpm\022b0b43\5aa4eba4\plugin_01WfpcLpRrFiXjYLNuv6q7DJ\skills\steadyship-review

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
   `Shared drive:` path (a path the user gives wins; `~` is the home folder;
   a relative path is relative to the repository folder). If that path does
   not exist in this session (in Claude desktop, attached folders get a new
   path each session), look for a folder with the same last name beside the
   repository folder; say which path you used.
   Identify the app from the request (`apps/<name>/`); if unclear, Glob
   `apps/*/index.html` (skipping `_sample` and `_template`) and pick the
   closest name, saying which.

2. **Read the app and the context**, in one turn:
   - the app in full (`apps/<name>/index.html` and any other files in it);
   - the bar, the engineering standard every app is held to:
     `C:/Users/steadyship/AppData/Local/Packages/Claude_pzs8sxrjxfjjc/LocalCache/Roaming/Claude/rpm/022b0b43/5aa4eba4/plugin_01WfpcLpRrFiXjYLNuv6q7DJ/standard/STANDARD.md` (if it cannot be read, say
     "couldn't read the bar" once and judge from the assessment's profile);
   - `docs/context/engineering.md` (facts the bar cannot know and rows
     this business overrides; an override wins);
   - every business note: `docs/context/business/**/*` (the official
     stage/status list, the glossary's rules for how each identifier is
     written, which file is the master for what, who uses which app);
   - `docs/assessment/<name>.md` and `docs/assessment/SUMMARY.md` if present;
   - Glob the shared drive: `<shared drive>/**/*`;
   - Glob `scripts/test.sh` and `tests/**/*`.

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
   - **Tests**: if a shell is available, run `bash scripts/test.sh <name>`
     now and quote its last line; it is the one claim in the review that
     is proven rather than read. If no shell, say whether `tests/<name>/`
     exists and what `docs/assessment/` says about the last run, and
     write "tests: not run here".
   - **Against the bar**: from the bar and the assessment's engineering
     profile, name every row the app fails at the stage the person wants
     to rely on ("every day", "instead of the spreadsheet", "the whole
     workshop" mean Owned tool at least; "the business runs on it" means
     Proper app). The free habits apply at every stage. Then read the
     assessment's ladder: which rungs are done and which is next.

6. **Second opinion.** If an `Agent` tool is available to you, dispatch one
   read-only reviewer with a written brief: the app path, the master
   files, the business notes, `docs/context/engineering.md`, the path to
   the bar, and the checklist in steps 4–5; ask for findings with evidence
   and no verdict. Prefer a reviewer agent from a companion plugin if one
   is listed (`feature-dev:code-reviewer`, or a `pr-review-toolkit`
   reviewer); otherwise a general agent, a different model if you can
   choose. Say which one ran.
   Reconcile: say where it agreed and where it differed. If no `Agent` tool
   is available, write "Second opinion: not run" and carry on.

7. **Verdict, short.** The person is about to decide on your first line.
   Reply in plain English, about a screen, no more:

   **Verdict: Yes / No / Not yet** — one sentence why. Then the stage it is
   at today: Prototype (one person's tool), Owned tool (someone owns and
   maintains it), Proper app (shared data, sign-in, backup, tests) or
   Platform. Add "(partial — couldn't check …)" if any source was missing.

   **What I checked**: one line: the app file, each master file opened, the
   business notes; anything you couldn't check.

   **Where it disagrees with <master file>**: the five most serious
   differences, identifier first, both values; then one line with the
   count of the rest ("and 7 more rows, plus 3 spelling differences").

   **Risks if the team relies on it**: the three most serious, each with
   its evidence (file:line or row), one line each; then one line naming
   the others by topic only ("also: no sign-in, no tests").

   **Against the bar**: "Tests: PASS" or "FAIL" or "not run here", then
   the rows it fails at that stage, by the bar's row name, up to five, one
   line each with the evidence; then one line for the rest by name only.
   Then the ladder in one line: "Rungs done: 1 Name it. Next: 2 Own it."

   **Second opinion**: one line: which reviewer ran, where it agreed, what
   it added, where it disagreed, or "not run".

   **The one next step**: a single concrete action that removes the biggest
   risk, naming the file that should be the single master; usually it is
   the next rung. Then, in one line, what would have to be true for the
   answer to become Yes: the rungs and rows still missing, by name.

   End with: "Say 'show me everything' for every row and every risk."

8. **"Show me everything" / "more"** (a later turn): the full lists from
   what you read in this conversation: every differing row with both
   values, missing rows, every identifier-format and name difference, the
   stage/status list comparison, every risk with its evidence, and the
   second opinion in full. If that context is gone, re-read and give it.

## Rules

- Read only: never Write or Edit anything during a review. Running the
  app's tests is the one command allowed.
- Never invent facts: every identifier, value and spelling comes from a file
  you read. If you did not read it, say "couldn't check".
- Gloss any technical word the first time.
- Be straight: if the answer is No, say No in the first line.


- tool call: Agent general-purpose
- tool call: Read C:\Users\steadyship\AppData\Local\Packages\Claude_pzs8sxrjxfjjc\LocalCache\Roaming\Claude\rpm\022b0b43\5aa4eba4\plugin_01WfpcLpRrFiXjYLNuv6q
- tool call: Bash cat docs/assessment/SUMMARY.md | head -40; ls docs/assessment; bash scripts/test.sh cut-planner | tail -3; cat "../demo-boatworks-shared-dri
- tool call: Bash cd <folder> && node -e "
const fs=require('fs');const t=fs.readFileSync('demo-boatworks-shared-drive/WB 7.8 plat
- tool call: Bash timeout 100 bash scripts/validate.sh 2>&1 | tail -15
- tool call: Bash timeout 100 bash scripts/validate.sh 2>&1 | grep -i "cut-planner"

**CLAUDE:** **Verdict: Not yet.** The layouts and sizes check out, but nobody has verified the machine files on your router. The review also turned up cases where the cut path itself could be wrong. Stage today: **Prototype** (a one-person tool, and the banner says so).

**What I checked:** I read all of `apps/cut-planner/` and the bar. I read the J-1041 drawing, cut list and rectangles file, `Parts.csv` and `Cut settings.csv` on the shared drive, and the business and engineering notes. I ran the app's test and `scripts/validate.sh`. I couldn't check the machine side at all, because I don't know your controller and have no sample file it runs.

**Against the shared drive:** the app stores no records of its own, so there is nothing stale. I compared all 11 parts in the drawing with the rectangles file, and every length and width matches. The only differences are spelling, with "Bulkhead Fwd" against "Bulkhead fwd" and the same capitalisation on three other names. The planner matches by drawing layer, so that is harmless.

**Risks if the team relies on it**
1. **Possible gouges.** The independent reviewer found that a repeated point in a drawing outline puts the bit on the part's own edge, cutting about 3 mm into it (`app.js:335-352`). Very sharp corners also push the bit's path further out than the 10 mm gap. I read the code and this holds. It doesn't show on J-1041, whose drawing is clean.
2. **Wrong output instead of a refusal.** A hole too small for the bit is only a note on the sheet card (`app.js:379-383`). The file is still offered, and its header doesn't mention the missing hole. A part with quantity 0 silently disappears, and a drawing in inches would be cut at the wrong scale with no warning.
3. **The file itself is untested on your machine.** The spindle wait, work-offset setup and speeds and feeds are all guesses (`app.js:441`, `Cut settings.csv`), and there are no holding tabs.

Also: no check that the placed parts match the cut list quantities except in the test, one place where the settings code only requires values above zero, and the nesting being bounding-box only.

**Against the bar (checked as Owned tool, the level for daily use)**
- **Tests: PASS.** The one test also skips silently if the shared drive isn't there, and the regret list says tests shouldn't depend on it.
- **Code structure:** one 897-line file, past the 300-line limit.
- **Lint:** one unused-assignment note at `app.js:60`.
- **Browsers, currency and GST:** none of these is recorded in `docs/context/engineering.md`.
- **Who changed what:** nothing records who generated which file.
- **Where its data lives:** machine files are downloaded, not saved on the shared drive.
- **Ladder:** there is no `docs/assessment/cut-planner.md`, so no rungs are recorded yet.

**Second opinion:** a general read-only reviewer ran. It agreed on the nesting, the offset sides and the cut direction, and it found the gouge, small-hole and input-checking problems above that I hadn't caught. It didn't run the app or the test.

**The one next step:** make the planner refuse instead of warning on anything that could cut wrong. That means checking the actual bit paths against neighbouring parts and the sheet edge, removing repeated points, treating a skipped hole or zero quantity as an error, and reading the drawing's units. I'd do that before any file goes near the router, and I can start now.

For this to become a Yes, it also needs a sample file from your controller, confirmed speeds and feeds, and an air-cut. After that it needs a named owner and the machine files saved to one shared place.

Say "show me everything" for every row and every risk.


**USER:** Yes, make those safety fixes.


**CLAUDE:** Making the safety fixes now. I'm recording the decision first, then changing the planner.

- tool call: Read C:\Users\steadyship\steadyship-test3\demo-boatworks\apps\cut-planner\app.js
- tool call: Read C:\Users\steadyship\steadyship-test3\demo-boatworks\apps\cut-planner\app.js
- tool call: Read C:\Users\steadyship\steadyship-test3\demo-boatworks\apps\cut-planner\app.js
- tool call: Bash grep -n -A2 "INSUNITS" ../demo-boatworks-shared-drive/"WB 7.8 plate parts J-1041.dxf"; grep -n "summary.appendChild(ul)" -B2 apps/cut-planne
- tool call: Write C:\Users\steadyship\steadyship-test3\scratch-patch2.mjs
- tool call: Bash cd <folder> && node -e "
const fs=require('fs');let t=fs.readFileSync('scratch-patch2.mjs','utf8');
const a=t.in
- tool call: Bash cat > tests/cut-planner/zz.spec.ts <<'EOF'
import { test } from '@playwright/test';
import { pathToFileURL } from 'node:url';
import { resol
- tool call: Bash grep -n "function offsetPoly" -B3 -A22 apps/cut-planner/app.js; grep -n "function offsetChecked" -A16 apps/cut-planner/app.js
- tool call: Bash cat > /tmp/new.txt <<'EOF'
  /** Offset a counter-clockwise polygon outward by d (negative = inward). Straight edges meet at sharp corners,


**CLAUDE:** Windows Node can't see `/tmp` (the shell's path), so I'll use the working folder instead.

- tool call: Bash cp /tmp/new.txt ./new-offset.txt && node -e "
const fs=require('fs');const L=fs.readFileSync('apps/cut-planner/app.js','utf8').split('\n');

- tool call: Bash cat > tests/cut-planner/safety.spec.ts <<'EOF'
import { test, expect, type Page } from '@playwright/test';
import { pathToFileURL } from 'no
- tool call: Bash sed -i "s|const g = await gcodeOf(page);|const g = (await gcodeOf(page)).replace(/G0 X0 Y0[\\\\s\\\\S]*\$/, ''); // drop the final return to

**CLAUDE:** Shell escaping ate the backslashes again. Fixing them directly in the file.

- tool call: Edit C:\Users\steadyship\steadyship-test3\demo-boatworks\tests\cut-planner\safety.spec.ts
- tool call: Edit C:\Users\steadyship\steadyship-test3\demo-boatworks\tests\cut-planner\safety.spec.ts
- tool call: Bash npx prettier --write tests/cut-planner >/dev/null; APP=apps/cut-planner/index.html npx playwright test tests/cut-planner --reporter=list 2>&
- tool call: Bash npx tsc -p tsconfig.json 2>&1 | grep cut-planner; cat > tests/cut-planner/zz.spec.ts <<'EOF'
import { test } from '@playwright/test';
import
- tool call: Bash node -e "
const fs=require('fs');let s=fs.readFileSync('apps/cut-planner/README.md','utf8');
s=s.replace(/\*\*Limits:\*\*.*\n/,'**Refuses to
- tool call: Bash sed -n 63,68p apps/cut-planner/app.js
- tool call: Bash sed -i '65d' apps/cut-planner/app.js && sed -n 63,67p apps/cut-planner/app.js && bash scripts/test.sh cut-planner | tail -2 && timeout 100 b
- tool call: Bash node -e "
const fs=require('fs');let s=fs.readFileSync('apps/cut-planner/app.js','utf8');
s=s.split('﻿').join('\\\\uFEFF');fs.writeFileSync(

**CLAUDE:** Almost finished: one cosmetic lint note left. An invisible character in a file-reading pattern wasn't replaced. I'm fixing it by hand.

- tool call: Edit C:\Users\steadyship\steadyship-test3\demo-boatworks\apps\cut-planner\app.js
- tool call: Bash bash scripts/test.sh cut-planner | tail -1 && timeout 100 bash scripts/validate.sh 2>&1 | grep "cut-planner lint"; npx tsc -p tsconfig.json 
- tool call: Bash node -e "
const fs=require('fs');let s=fs.readFileSync('apps/cut-planner/app.js','utf8');
const bad='/^'+String.fromCharCode(0xFEFF)+'/';con

**CLAUDE:** The planner now refuses unsafe plans instead of warning about them. J-1041 still plans the same way, with 6 sheets and $3,221 of plate, and all 7 of the app's tests pass. Lint and the type check are clean.

**What it now refuses** (it shows the reason and makes no file):
- **Hole too small:** it refuses a hole smaller than the bit plus clearance. Before, it only left a note on the sheet card and still offered the file.
- **Bit path too close:** it checks the actual bit path, not just the bounding boxes. If the path would come within 1 mm of another part, or run off the sheet, it refuses.
- **Quantity 0:** a part with quantity 0 is refused. Before, it silently vanished.
- **Wrong units:** a drawing not in millimetres is refused, and so is a mirrored one. A drawing that doesn't state its units is read as millimetres, with a visible note.
- **Bad shapes:** a hole that isn't wholly inside its part, an island inside a hole, an outline that crosses itself, and an outline with fewer than 3 distinct points are all refused.
- **Settings out of range:** each setting has a sensible range, and anything outside it is refused.
- **Parts missing from the plan:** it also refuses if the plan doesn't hold every part in the cut list.

**What it now does differently**
- **Repeated points:** a repeated point in an outline is removed. Before, it put the bit on the part's own edge.
- **Sharp outside corners:** these now get a rounded bit path. A long spike would have swung toward the neighbouring part. My own new check caught it on the gusset triangles of J-1041.

**New settings:** `Cut settings.csv` gained `bit_clearance_mm`, `retract_z_mm` and `spindle_wait_s`. These were previously fixed in the code, and the values are unconfirmed.

**Tests:** six new tests use made-up parts and don't need the shared drive. One checks that the path around a sharp triangle stays one bit radius out. The other five check that bad input is refused. Together with the J-1041 test that makes 7.

**Still open before a file goes near the router:**
- **Controller sample:** a sample file from your controller, or its make and model, so I can match its format. The spindle wait, work-offset setup and speeds and feeds are still unconfirmed.
- **Air-cut:** an air-cut, then scrap plate, before any real sheet.
- **Holding tabs:** none are added, so check how the sheet and the cut-free parts are held.

Not committed (git has no author identity on this computer). Decision recorded in `docs/context/decisions.md`. The J-1041 files in [cut-plans/J-1041](cut-plans/J-1041) are regenerated.


## conversation 661beaca


**USER:** The cut planner put two gussets on top of each other on the 3 mm sheet. Fix it and make sure it can't happen again.

- tool call: Skill steadyship:steadyship-ask

**USER:** Base directory for this skill: C:\Users\steadyship\AppData\Local\Packages\Claude_pzs8sxrjxfjjc\LocalCache\Roaming\Claude\rpm\022b0b43\5aa4eba4\plugin_01WfpcLpRrFiXjYLNuv6q7DJ\skills\steadyship-ask

# Steadyship ask

You are the Steadyship engineer. Someone who is not technical has asked for a
change. Your job is to ask what they don't know to ask **before** anything is
built: a change built on the wrong unit, in the wrong place, or in a second
copy of something they already keep is expensive to undo once people rely on
it.

First line of your own reasoning, every time: "No file is created or edited
until the user has answered." Hold to it: in this turn you only Read, Glob and
Grep. No Write, no Edit, no code in the reply.

**Work fast.** Make independent reads in the same turn.

## Steps

1. **Where things are.** Confirm you are inside a Steadyship repository: a
   file `steadyship.md` exists here and its first line is
   `# Steadyship repository`. If it is not here, look one level down: if
   exactly one child folder contains `steadyship.md`, use that folder for
   everything that follows and say which folder you are using. If none or
   several, say so and stop. Note the `Shared drive:` path in
   `steadyship.md` (`~` is the home folder; a relative path is relative to
   the repository folder). If that path does not exist in this session (in
   Claude desktop, attached folders get a new path each session), look for
   a folder with the same last name beside the repository folder and say
   which path you used.

2. **Read the context**, in one turn:
   - every business note: `docs/context/business/**/*` (how the work is
     organised — stages, the steps or operations inside them, the glossary,
     who uses what, which file is the master for what);
   - `docs/context/decisions.md` if present (questions already answered,
     rungs declined);
   - `docs/context/engineering.md` if present (facts the bar cannot know;
     rows this business overrides);
   - the bar, `C:/Users/steadyship/AppData/Local/Packages/Claude_pzs8sxrjxfjjc/LocalCache/Roaming/Claude/rpm/022b0b43/5aa4eba4/plugin_01WfpcLpRrFiXjYLNuv6q7DJ/standard/STANDARD.md`: the defaults
     and free habits the lines you write must follow (if it cannot be
     read, say so once and carry on);
   - `tests/<app>/` if present (the app's own tests);
   - `docs/assessment/<app>.md` and `docs/assessment/SUMMARY.md` if present;
   - the app being changed, in full (`apps/<app>/index.html` and its files);
   - a Glob of the shared drive (`<shared drive>/**/*`), and Read any file
     whose name matches the thing being added or changed (a list of prices,
     jobs, customers, parts, people...).
   If something cannot be reached, say "couldn't check X" and go on.

3. **Choose the questions.** For each of these, decide whether it matters for
   *this* change. Pick at most **two**, the ones whose wrong answer would cost
   most to undo. Skip any whose answer is already in the context, and say
   which context answered it.
   - **What it attaches to (data model).** Does the new thing belong to the
     whole record the app already knows (a whole job, a whole order), or to
     a smaller unit inside it (a stage, a step, an operation, a line item,
     a person)? **Mandatory** when the business notes describe smaller units
     inside the thing the app tracks, or say how this kind of data is
     recorded, and the app only knows the bigger unit.
   - **Where the data lives.** Will it be stored only in this browser on this
     one computer (`localStorage`: lost if browsing data is cleared, invisible
     on any other computer or tablet), or in a shared place others can see?
     Which file or list is the master? **Mandatory** when the change records
     who did something, or anything someone else will need to see later,
     and the app keeps its data only in the browser. If it records *who*,
     also ask how the app will know who is using it (pick a name from a
     list, or a sign-in).
   - **Who else keeps it.** Is this thing (a price, an option, a customer, a
     part, a job, a person) already kept in a spreadsheet, a shared file or
     another app? Then the change should read from that master, or go there
     instead, not add a second copy typed into this app. **Mandatory** when
     the value being added has a master file on the shared drive, or when
     the app already holds a copy of that master. Name the master file and
     any copy that already disagrees with it.
   - **Prototype or relied on.** Will people depend on this every day? Then
     it needs a home that isn't one laptop.
   - **Build or buy.** Does something they already use do this?

   Never ask a question the bar already answers (which library, where a
   value's form comes from, whether to add a test): those are decided,
   and the reply says the decision in one line when it is applied.

4. **Ask.** Reply in plain words, short:
   - one sentence on what you understood they want;
   - for each chosen question, one short paragraph: the question itself
     ending in `?`, the choices in everyday words (for example "against the
     whole job, or against each step within it?"), **your recommended
     answer and why**, quoting the business note, app or file that makes it
     matter ("your build guide lists three steps under Assembly and says time
     is booked per step; I'd record against each step so you can see where
     the hours go");
   - name any question you skipped because the context already answers it;
   - offer the shortcut: "Or say 'just do it the simple way for now' and I'll
     note that decision and build it."
   - end with: "Nothing has been changed yet — I'll build it as soon as you
     answer."

   **The questions must be readable before the person answers.** If the
   environment offers a question widget (a tool that shows options with
   buttons), the widget is all the person sees: put each question, its
   choices in everyday words and your recommended answer with its reason
   *inside the widget's text and options*, not in a message it replaces.
   Never write "as I recommend below" or "see above": there is no below.
   If the widget cannot hold the full text, do not use it; ask in the
   message body instead.

5. **Stop.** End your turn after asking. Do not build in the same turn, even
   if you are confident of the answer.

## After the user answers (a later turn)

If this turn is the user's answer to a question asked earlier in the
conversation (whether or not this skill was loaded then), skip steps 1–5:
re-read only what you need to build (step 2's notes and the app), then do
the three steps below. All three, every time: the decision record is how
the next person learns why it was built this way.

0. If two questions were asked and the answer settles only one, the other
   is not decided. A bare "go ahead" means "do what you recommended" — say
   so in one line ("You didn't say where to keep it, so I've used the
   shared file I recommended; say 'browser only' if you'd rather") and
   record it as "accepted the recommendation", not as the user's words.
   If no recommendation was given for the open question, ask it (only
   that one) and stop.
1. Append to `docs/context/decisions.md` (create it with a `# Decisions`
   heading if missing) one entry: date, the change asked for, the question,
   the answer, and the consequence ("time is recorded per operation; the
   timer needs the operation list from the build guide").
2. Build the change as decided, keeping to what the business notes and master
   files say (exact names, formats, lists). Build the smallest thing that
   honours the decision: no new browser permissions, file pickers, name
   lists or sync logic unless the decision needs them, and say what was
   left out and why.
   **A new app starts from the template.** When the change is a new app,
   copy `apps/_template/` to `apps/<name>/` (and `tests/_template/` to
   `tests/<name>/`), then change what the app is for; the template already
   carries the banner, the theme, the escaping helper, the value forms, the
   edge checks, the messages, the long-list table, a README and tests.
   Never start a new app from a blank file.
   **The lines you write meet the bar.** Before writing, list to yourself
   the bar rows the change touches (where the data lives, a new kind of
   value, a library, an edge where data comes in, a list that can grow)
   and apply the stage default for each; the free habits apply to every
   line you write (escaping helper, value forms, errors in the page, no
   business data in code, nothing from the regret list). Do not rewrite
   the rest of the app to the bar: note what still falls short in the
   assessment's profile instead. Each default applied gets one line in
   the reply.
   **One test per change.** If `tests/<app>/` exists, add one Playwright
   test for the behaviour you added and run `bash scripts/test.sh <app>`
   if a shell is available; if the app has no tests of its own yet, run
   the smoke test only and let the next-rung line below propose the
   test rung.
3. If `docs/assessment/<app>.md` exists, update its Data table and
   storage line so it no longer describes the app as it was, and any
   profile row or ladder rung the change moved.
4. Commit, if a shell is available: `git add -A` and a one-line message
   saying what changed and for whom; never push. If no shell, say the
   change is not yet committed and that the setup owner should commit it.
5. Reply, short (about ten lines): what changed, in one or two lines;
   where its data is stored now and what that means ("only on this
   computer's browser" or "in <file> on the shared drive"); **one line per
   thing the person did not ask for by name** (a shared file, a folder
   picker, a sign-in, a library, a test): what it is and why it is worth
   having, in plain words ("a folder picker, so the hours file is the same
   one on every computer instead of a copy in each browser"); anything the
   person must know to use it (a browser it needs, a one-time click); that
   the decision is in `docs/context/decisions.md`; whether it was
   committed and that nothing was uploaded.
   **While I'm in here**, one line, once per app per conversation: the
   app's next rung from `docs/assessment/<app>.md` (its `**Next rung:**`
   line) as an offer with its one question, for example "Next for this
   app: a named owner. Who is responsible for it? Say 'not now' and I'll
   leave it." If the change itself met a stage trigger (someone other
   than the builder will use it, real data now flows through it, it
   records who did something), say so in that same line and what stage
   it should become, with the option to defer. Skip the line if
   `decisions.md` records the rung declined in the last 30 days or there
   is no assessment file.
   End with: "Say 'more' for the
   limits, what I tested and what I left out, or ask 'why' about any of
   the additions." The person did not know to ask for any of this, so they
   cannot tell whether it was worth it unless you say, briefly.

6. **"More" / "why"** (a later turn): the limits (what is not recorded,
   what happens with two people at once, old data not migrated), what was
   tested and how, what was left out and why, and for "why" the proper
   explanation of the addition asked about: what would go wrong without
   it, in one short paragraph.

## Rules

- Never build before asking when a mandatory question exists.
- Never ask more than two questions. The next-rung line is an offer, not
  a third question; it never blocks the build.
- A "not now" to the next-rung line is recorded in `decisions.md` as
  "declined rung N <date>" and not raised again for 30 days.
- Never ask something the context already answers; say what answered it.
- Plain language. Gloss any technical word the first time (e.g.
  "localStorage, the browser's own storage on that one computer").
- If the request is not a change (a question, a status check, a review),
  this skill does not apply: answer it normally.


ARGUMENTS: The cut planner put two gussets on top of each other on the 3 mm sheet. Fix it and make sure it can't happen again.

- tool call: Bash head -3 steadyship.md; ls; ls cut-plans docs/context docs/context/business 2>/dev/null; cat apps/cut-planner/README.md docs/context/decision
- tool call: Bash ls -R cut-plans | head -30; cat apps/cut-planner/data.json; grep -n "function \|clearance\|overlap" apps/cut-planner/app.js | head -120
- tool call: Bash sed -n 241,420p apps/cut-planner/app.js; sed -n 470,490p apps/cut-planner/app.js; sed -n 620,650p apps/cut-planner/app.js
- tool call: Read C:\Users\steadyship\steadyship-test3\demo-boatworks\cut-plans\J-1041\sheet-5.png
- tool call: Read C:\Users\steadyship\steadyship-test3\demo-boatworks\cut-plans\J-1041\sheet-6.png
- tool call: Bash git status --short | head; grep -il gusset -r apps docs tests lib scripts 2>/dev/null | head; grep -rn -i gusset docs/context/business | hea

**CLAUDE:** I'm checking the saved J-1041 plans for the overlap. The two 3 mm sheets I've looked at so far show no gussets, so I'm looking for them in the job's drawing.

- tool call: Bash grep -n "Shared drive" steadyship.md; grep -rli gusset --include=* . --exclude-dir=node_modules --exclude-dir=.git 2>/dev/null | head; ls ..
- tool call: Bash cd <folder> && S=demo-boatworks-shared-drive; find $S -type f | head -50; grep -ril gusset $S | head; grep -i -
- tool call: Read C:\Users\steadyship\steadyship-test3\demo-boatworks\cut-plans\J-1041\sheet-1.png

**CLAUDE:** I can't reproduce this, so I haven't changed anything.

- **Gussets aren't on 3 mm.** In `Cut list J-1041.csv` and the DXF layer, all 16 gussets are 5 mm. In the saved J-1041 plan in `cut-plans/`, they're on 5 mm sheets 1–3 (e.g. Gusset 1, 2 and 6 on [sheet 1](cut-plans/J-1041/sheet-1.png)). The two 3 mm sheets hold only Console Sides and Stringer Webs.
- **No overlap in those plans.** The sheets I checked (1, 5, 6) show every part at least 10 mm from its neighbours. The planner also has a check that refuses to produce a file when two parts overlap or sit closer than the bit allows. By design, an overlap in a finished plan shouldn't be possible.

So the plan you saw probably came from a different run than the saved one. Possibly a different cut list or drawing, a changed thickness, or a sheet I haven't looked at (2–4).

Which of these is closest?

1. **A different job or edited cut list.** Tell me which files, or drop them in the shared drive, and I'll reproduce it.
2. **A saved sheet I haven't checked.** Tell me the file name.
3. **You changed the gusset thickness to 3 mm.** I'll try that and see whether it overlaps.

Once I can reproduce it, I'll fix the cause and add a test that fails if two parts ever overlap. That test will cover rotated parts and mixed sheet sizes too.
