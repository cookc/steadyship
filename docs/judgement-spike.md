# Judgement spike: eval harness

Does the plugin's judgement beat vanilla Claude? This harness answers that in
one command. It runs the three walkthrough scenarios (S1 assess, S2 ask,
S3 review) on a fresh Demo Boatworks repo, once with Steadyship loaded and once
without, then scores both arms against `tests/judgement/answer-key.md`.

## Run it

```bash
tests/judgement/run.sh            # 3 cases x 2 arms x 1 run, sonnet, cost ceiling $8
tests/judgement/run.sh --runs 3   # variance check
tests/judgement/run.sh --case s1-assess --ablation none   # one case, plugin arm only
```

Results go to `tests/judgement/results/<UTC timestamp>/` (git-ignored):
`summary.md` (the table below), `result.json` (every grader verdict),
`report.html` and `eval.log`. To re-score saved replies offline with no API
calls, use `tests/judgement/regrade.py <case.yaml> <reply.md>...`.

It costs money and takes about ten minutes, so it is not in
`scripts/validate.sh` or CI.

## How it works

- It is a wrapper around `claude plugin eval` (Option A of the brief). The
  cases live in `tests/judgement/evals/`, outside `plugin/`, so they never ship.
  `run.sh` stages a throwaway copy of `plugin/`, copies in the cases as
  `evals/` and `scaffold.sh` into each case, then evaluates that copy with
  `--scaffold --ablation with-without --model sonnet --allow-tools Write Edit`.
- `scaffold.sh` builds the agent's working directory with `init.sh` and
  `populate.sh`: the Demo Boatworks repo, committed and clean. It puts the
  shared drive at `~/demo-boatworks-shared-drive`, where `~` is the run's
  throwaway home.
- Each run gets an isolated home, so none of your own plugins or settings
  load. The `without` arm loads no Steadyship skills. That makes it a cleaner
  baseline than the walkthrough's "vanilla" arm, and close to its "true
  vanilla" arm.
- **Prompt change:** the prompts are the walkthrough's, word for word, except
  that S1's shared-drive path is `~/demo-boatworks-shared-drive`.
- The agent gets Read, Glob, Grep, Write, Edit and Skill. **It has no Bash:**
  the runner refuses a shell grant unless the OS sandbox works, and this
  machine lacks `socat`.
- The answer key is never staged. A `no-peek` grader fails any run that reads
  a path matching `/evals/` or `answer-key`, because the staged cases spell
  out the answers.

## Graders

All verdicts below come from deterministic graders. The `llm` graders (judged
by haiku) are reported alongside but never decide a pass.

**S1 assess** (`s1-assess`). There is one regex per answer-key row: section 2
gives `row-c1`–`row-c9` and section 3 gives `row-d01`–`row-d20`. The summary
prints `rows N/29`, and a run passes at ≥ 24/29. Each pattern needs the
specifics, not the gist. Examples:

- `row-c2` needs a bare `1043`/`1040` and a `J-10xx`.
- `row-c6` needs Bimini with 3,450 and 3,200, or Trailer with 6,250 and 5,800.
- `row-d11` needs 725 and 740.
- `row-d13`–`d16` need the copied code itself: money formatter, `fmtMoney`
  rounding, header CSS drift, UTC dates.

The llm grader `llm-job-list-copies` asks whether the reply names at least
three apps that each hold their own copy of the job list.

**S2 ask** (`s2-ask`). It passes only if all three hold:

- `no-write`: no Write tool use.
- `no-edit`: no Edit tool use.
- `asks-job-vs-operation`: the reply has "per/by/against job|boat",
  "operation|stage|step|task" and a `?`.

The llm grader `llm-asks-before-building` checks that it asks a question
before building and adds no code.

**S2b, S2c ask** (`s2b-ask`, `s2c-ask`). These are two more change requests,
so the ask skill isn't tuned to one sentence. Each uses S2's pass rule: no
Write, no Edit, and its own `asks-*` regex.

- **S2b** asks for a trailer field on the quote builder. Its
  `asks-price-list` grader needs "price list" (or a prices file) and a `?`.
- **S2c** asks the delivery checklist to remember who ticked each box. Its
  `asks-where-or-who` grader needs a `?` and a word about where the data
  lives or who the user is: browser or `localStorage`, this or other
  computers, a shared drive or file, or sign-in.

**S3 review** (`s3-review`). It passes if `read-jobs-csv` holds (a Read of
`Jobs.csv`) and at least 5 of the 6 `risk-*` regexes match. The risks are:

1. browser/localStorage storage
2. backup or data loss
3. stale copy of the spreadsheet
4. job-number format
5. stage names
6. sign-in

`stale-jobs-named` (`J-1039` and `J-1041`) is reported but doesn't decide the
pass. The llm grader `llm-verdict-and-next-step` checks for a clear yes/no and
a concrete next step.

**Calibration.** The S1 regexes were run over the five hand-scored walkthrough
transcripts, and every score fell within one row of the hand score:

| Transcript | Hand (strict) | Regex |
|---|---|---|
| vanilla-s1 (sonnet) | 20.5 (20) | 20 |
| vanilla-s1-opus | 23 (23) | 23 |
| plugin-s1 | 23.5 (23) | 23 |
| true-vanilla-s1 | 22.5 (22) | 23 |
| true-vanilla-s1-opus | 21 (20) | 20 |

The regex scorer gives no partial credit, as section 7 of the answer key
specifies. Its one known looseness is `row-d08`, the quote-builder customer
list. On S3, the regexes give vanilla 4/6, plugin 5/6 and true-vanilla 4/6,
against hand marks of 4 + ½, 5 and 3 + generic. On S2 none of the three
transcripts asks job-vs-operation, which matches the hand verdict.

## Results

Each row is one full run of `tests/judgement/run.sh`: sonnet, 1 run per case
per arm. Later skill iterations append a row.

| Date | Plugin | Arm | S1 rows /29 (pass ≥24) | S2 built? / asked job-vs-op? | S3 risks /6; Jobs.csv read? | Passes (of 3) | Wall, cost |
|---|---|---|---|---|---|---|---|
| 2026-10-19 baseline | 0.2.0 (no assess/ask/review skills) | with | 23 (ran as 22) — fail | built (Edit) / no — fail | 5 / no — fail | 0 | 192 s, $0.65 both arms |
| 2026-10-19 baseline | — | without | 20 (ran as 19) — fail | built (Edit) / no — fail | 5 / no — fail | 0 | (same run) |
| 2026-10-19 assess iter 1 (S1 only, `--runs 2 --ablation none`) | 0.3.0 (steadyship-assess v0) | with | 25, 26 — pass both; no-peek ✓ | — | — | S1 2/2 | 302 s, $0.82 |
| 2026-10-19 assess iter 1, S3 check (`--runs 1 --ablation none`) | 0.3.0 | with | — | — | 6 / no — fail | — | 25 s, $0.08 |
| 2026-10-19 ask iter 1 (S2, S2b, S2c, `--runs 3`) | 0.4.0 (steadyship-ask v0) | with | — | S2 3/3, S2b 3/3, S2c 3/3: no files, asked; llm 9/9 | — | S2* 9/9 | 394 s, $1.40 both arms |
| 2026-10-19 ask iter 1 | — | without | — | built (Edit) in 9/9; asked 0/9 | — | S2* 0/9 | (same run) |
| 2026-10-19 review iter 1 (S3, `--runs 3 --ablation none`) | 0.4.0 (steadyship-review v0) | with | — | — | 6, 6, 6 / yes ×3; J-1039/J-1041 named ×3; llm 3/3 | S3 3/3 | 135 s, $0.48 |
| **2026-10-19 v0 complete** (full run, 1 run each) | 0.4.0 (assess, ask, review v0) | with | 28 — pass | S2 / S2b / S2c: no files, asked — pass ×3 | 6 / yes, stale rows named — pass | **5 of 5** | 376 s, $1.16 both arms |
| **2026-10-19 v0 complete** | — | without | 21 — fail | S2 / S2b / S2c: built (Edit), not asked — fail ×3 | 5 / no — fail | 0 of 5 | (same run) |
| 2026-10-19 Rimu Joinery (r1, r2, r3, `--runs 2`) | 0.4.0 (unchanged) | with | r1: 28, 23 live → 29, 29 regraded — pass 2/2 (1/2 live) | r2: no files, asked per job vs per operation ×2 — pass 2/2 | r3: 6, 6 / yes ×2; RJ-2061/RJ-2063 and RJ-2066 named ×2 — pass 2/2 | **6 of 6** (5 of 6 live) | 668 s, $1.92 both arms |
| 2026-10-19 Rimu Joinery | — | without | r1: 18, 17 — fail ×2 | r2: built (Write) ×2; asked 1/2 — fail ×2 | r3: 4, 4 / no — fail ×2 | 0 of 6 | (same run) |

Notes on the baseline (run `20261018T230900Z`, Claude Code 2.1.303, sonnet, 1 run per case per arm):

- **S1.** The graders that ran gave 22 and 19. After the run I widened two
  patterns. `row-c7` now accepts "6 of your 9 stages" and `row-d07` accepts a
  quoted bare "Harbour Services". Re-scoring the same replies with
  `regrade.py` gives 23 and 20. The walkthrough calibration didn't change.
  Both arms missed:
  - `c3` (the "WB 6.2" short name)
  - `d13`–`d16` (code copied across apps)
  - `d20` (Q-2026-031 quoted on stale prices)

  These are the same gaps as the walkthrough. The without arm also missed
  `1043`/`1040`.
- **S2.** Both arms edited `apps/shop-timer/index.html` without asking. The
  with arm added per-operation paint timers on its own, using the business
  doc, but only after building. This matches the walkthrough's "true vanilla"
  S2.
- **S3.** Both arms said no and gave next steps (llm: yes). Neither opened the
  shared drive, so neither named the stale J-1039/J-1041 rows. Both missed
  sign-in.
- **Arms are indistinguishable**, as expected: v0.2.0 has no judgement skills.
  One run each is noise-level. Use `--runs 3` before you call a skill
  iteration a win.

Notes on assess iteration 1 (runs `20261018T232012Z` S1, `20261018T232538Z` S3; without arm unchanged from the baseline, 20):

- **What changed:** new skill `steadyship-assess` v0: a nine-step procedure.
  It reads every app, business note and shared-drive file (sub-folders too).
  Then it cross-references each concept against a checklist of difference
  kinds, checks values item by item (including saved quotes against the
  current price list), looks for copied code (functions, `toISOString`, header
  CSS) and writes `docs/assessment/`. The reply has a fixed shape, and every
  bullet must stand on its own line. Target met on the first iteration, so I
  stopped there.
- **S1 misses:** `c3`, `c9` and `d20` in both runs, plus `d16` in run 1. The
  replies contain all four findings, but the regexes miss them. The quote
  findings sit in sub-bullets under a "Quote Q-2026-031" heading. The hull
  number is written as "nothing stores it" or "doesn't store the number". The
  model short name is on a line of its own, away from "in full". These are
  phrasing misses, not missing knowledge.
- **Workspace:** both runs wrote all six `docs/assessment/<app>.md` files and
  filled in `SUMMARY.md` (checked with `--keep-temp`). They left the
  `_sample` stand-in app out as not real.
- **S3:** risks 6/6 (up from 5; sign-in now named). The agent still did not
  open `Jobs.csv` or name J-1039/J-1041, the same as the baseline. The assess
  skill did not trigger on the review question. A review skill is what would
  move this.

Notes on ask and review v0 (runs `20261018T232947Z` ask, `20261018T233019Z`
review, `20261018T233656Z` v0 complete):

- **Ask, what changed:** new skill `steadyship-ask` v0. It does no Write or
  Edit in the first turn. It reads the business notes, the decisions log,
  any assessment, the app, and shared-drive files whose names match the
  change. Then it picks at most two of five questions (data model, where the
  data lives, who else keeps it, prototype or relied on, build or buy).
  Explicit triggers make a question mandatory. It recommends an answer
  quoting the source, offers "just do it the simple way", and stops. After
  the answer it logs the decision in `docs/context/decisions.md` and builds.
  The target was met on the first iteration, so I stopped there.
- **Ask, how the replies look:** S2 asks per-job vs per-operation and quotes
  the build guide's three Paint operations. S2b points out that the app's
  Trailer price ($5,800) disagrees with the price list ($6,250). S2c asks
  where ticks live and whether people pick their name or sign in. Replies
  sometimes put two sub-questions under one heading, so they ask three
  questions in total, stretching the "at most two" rule.
- **Discrimination:** the without arm built straight away in all 9 S2* runs
  and in the v0-complete run. All three S2 cases separate the arms.
- **Review, what changed:** new skill `steadyship-review` v0. It reads the
  app, the business notes and the assessment. It globs the shared drive and
  must open every master file holding the same kind of record. It compares
  row by row, checks storage, backup, stale copy, sign-in, many users and
  tests with file:line evidence, then gives Yes/No/Not yet with the stage
  and one next step. It writes "Second opinion: not run" when no Agent tool
  is available, which is always the case in the harness. Target met on the
  first iteration: Jobs.csv was read and J-1039/J-1041 named in 3/3 runs.
- **v0 complete:** the with arm passed all 5 cases and the without arm
  passed 0. S1 scored 28, missing only `c3`, the model short name. The S2
  llm judge voted FAIL, PASS, FAIL on a reply that asks two questions and
  changes nothing, so treat that as haiku judge noise. It doesn't gate.


## Second business: Rimu Joinery

The s* cases all run on Demo Boatworks, so a skill could be quietly tuned to
it. The r* cases ask the same three kinds of question about a different
business, to test whether the skills generalise.

- **Fixture:** `tests/judgement/fixtures/rimu-joinery/` (eval-only, never
  shipped). A joinery workshop in Hamilton with five apps (quote-calc,
  job-tracker, job-clock, cut-list, install-calendar), the business notes
  (About, How we make a kitchen with 9 stages and their operations, Glossary)
  and a shared drive (Jobs, Clients, Materials, Price List, quote Q-0417).
  All five apps pass the smoke test.
- **Answer key:** `fixtures/rimu-joinery/answer-key.md`. It has the same
  sections and scoring as the first key and 29 rows (8 concepts, 21
  planted items), each with a grep that verifies it. The defect mix is
  deliberately different. The job clock is keyed by client name, so the two
  Ngata jobs share one timer. The labour rate is hardcoded in two apps, 78
  in one and 85 in the other. Board codes lose their thickness suffix, which
  makes them ambiguous. The tracker writes install dates as DD/MM, so its
  "Next installs" panel sorts December first. Its stage list has "Fit" for
  "Install". A date helper is copied into three apps and always puts the
  panel date a day early in NZ. The `.btn` CSS drifts. The quote calculator
  takes a 40% deposit against the business rule of 50%. Quote Q-0417 used
  the old rate after the change.
- **Cases:** `r1-assess` uses the S1 prompt with the Rimu shared-drive path,
  and one regex per row; it passes at ≥ 24/29. `r2-ask` asks "Can you add a
  way for the fitters to log how long each kitchen takes to assemble?" Like
  S2, it passes only with no Write, no Edit and a per-job-vs-per-operation
  question. `r3-review` asks "Can the office rely on the job tracker instead
  of the Jobs spreadsheet from next week?" It passes with a Read of
  `Jobs.csv` and ≥ 5 of 6 risks. Of those risks, the install-date format
  replaces S3's job-number format, and Fit/Install replaces S3's stage names.
  `stale-jobs-named` (RJ-2061, RJ-2063) and `missing-job-named` (RJ-2066)
  are reported but don't decide the pass.
- **Harness:** a case folder can hold a `FIXTURE` file. `run.sh` then stages
  that fixture without its answer key, and `scaffold.sh` builds the repo
  from the fixture's `init.env`. `summarise.py` now scores by case-name
  ending (`-assess`, `-ask`, `-review`) and grader prefix, not by `s1`/`s2`/`s3`.
  Old results summarise to the same verdicts. `tests/judgement/README.md`
  explains how to add a third business.

Notes on the Rimu run (`20261019T015314Z`, Claude Code 2.1.303, sonnet, 2
runs per case per arm, 668 s, $1.92):

- **No skill change was needed.** The with arm passed r2 and r3 in 2/2
  runs. Run 1 of r1 scored 28 live. Run 2 scored 23 live, but its reply
  contains every finding, and five graders missed it on phrasing. It wrote
  "the clock 4" and "the calendar 5" with no "jobs" after them, and "the
  calculator" rather than "quote calculator". It gave the panel date as
  "would show 2026-10-19 instead of 2026-10-20". Run 1 put Q-0417's stale
  labour in a sub-bullet under a "Q-0417" heading, which is the same
  sub-bullet miss as Boatworks `d20`. I widened those patterns after the
  run. `regrade.py` then gives 29 and 29 for the with arm and still 18 and 17
  for the without arm. Over the four Boatworks S1 replies the Rimu graders
  score 3 or 4 of 29, all on generic rows (operation, UTC copy, browser-only
  moves). So the graders separate the two businesses.
- **Discrimination:** the with arm passed 6 of 6 after regrading (5 of 6 by
  the live graders); the without arm passed 0 of 6. On r1, the without arm
  missed the code-level rows: the material-code suffix, the copied
  `nzd`/`isoDate`, the panel date, `.btn` drift, the Next-installs sort and
  the per-app job counts. On r2 the without arm wrote code both times. In
  one run it asked per job vs per operation, but only after building. On r3
  the without arm never opened `Jobs.csv`, and it missed sign-in both times.
- **Not planted:** both with-arm r1 replies noted that page widths differ
  (520–820px). That is true, but it is layout, not a copy. The key now says
  so and does not score it.

## Variance and model arms

Harness flags added: `--runs N`, `--model M`, `--cases GLOB` (alias of
`--case`), `--arms with|both`, `-j N` (concurrency) and `--max-cost-usd`.
`summarise.py` now prints a per-case table with pass count / N, mean and
min-max score, cost, and the graders missed in failing runs.
`results/latest` and `results/latest.md` point at the last run (results are
git-ignored). Claude Code 2.1.303, with-arm only, `-j 2`.

| Run | Model | Cases x runs | Wall | Cost |
|---|---|---|---|---|
| `20261019T021756Z` | sonnet | 8 x 10 | 2179 s | $13.81 (ceiling $15, not hit) |
| `20261019T022454Z` | opus | 5 x 3 | 565 s | $4.98 (ceiling $15) |
| `20261019T021801Z` | haiku | 5 x 3 | 404 s | $0.17 (ceiling $3) |

Pass rate (mean score, min):

| Case | sonnet n=10 | opus n=3 | haiku n=3 |
|---|---|---|---|
| s1-assess | 10/10 (0.94, 0.90) | 3/3 (0.89, 0.87) | 3/3 (0.87, 0.81) |
| s2-ask | 10/10 (1.00, 1.00) | 3/3 (1.00, 1.00) | 3/3 (0.93, 0.80) |
| s2b-ask | 10/10 (0.98, 0.80) | 3/3 (1.00, 1.00) | 3/3 (1.00, 1.00) |
| s2c-ask | 10/10 (1.00, 1.00) | 3/3 (1.00, 1.00) | 1/3 (0.60, 0.40) |
| s3-review | 10/10 (0.99, 0.90) | 3/3 (1.00, 1.00) | 1/3 (0.73, 0.40) |
| r1-assess | 10/10 (0.93, 0.84) | not run | not run |
| r2-ask | 10/10 (1.00, 1.00) | not run | not run |
| r3-review | 10/10 (0.98, 0.91) | not run | not run |

Reading:

- **Sonnet is stable.** 80 of 80 with-arm runs pass; no run failed a gating
  grader, so there are no wording-miss or behaviour-miss failures to
  classify, and no grader looked like the cause of a failure. The variance
  is in the assess rows only (scores 0.84-1.00), never in ask (no run built
  anything) or review. Rows sonnet misses most on the S1 key: c3 model
  short name 7/10, d20 stale Q-031 prices 6/10, d13 money format 2/10, c9
  hull number 2/10. On R1: d13 ambiguous board codes 6/10, c1 client
  naming 4/10, d09 quote-calc customer 4/10, d12 stale labour 3/10.
- **Haiku** passes assess (3/3) and the plain asks (s2, s2b), but is fragile
  where the right behaviour needs restraint. s2c-ask: in 2 of 3 runs it
  edited files and did not ask where or who. s3-review: 2 of 3 runs missed
  four to five of six risks (run 3 named none of browser storage, backup,
  stale copy, job-number format or sign-in). It is a quarter of the cost of
  sonnet or less ($0.17 for 15 runs), so it is viable for assess and
  simple ask, not for review or for asks that tempt a build. For desktop
  usage limits: haiku could carry assess and the simple ask; keep sonnet for
  review and anything where building without asking is costly.
- **Opus** passes all 15 runs and scores 1.00 on every ask and review run.
  It costs about 4 to 5 times sonnet per run ($4.98 for 15 runs against
  roughly $0.30 per run on sonnet), so it buys no pass-rate on this set.
- **S1's resistant row c3 (model short name):** opus did NOT find it, in
  0 of 3 runs. Sonnet found it 3 of 10, haiku 0 of 3. A stronger model does
  not change the verdict on that row; it also missed c9 hull number twice,
  d13 money format twice and d16 UTC date twice. Opus's assess runs are not
  better than sonnet's (mean 0.89 against 0.94).
- No skill change was made in this part.
- Caveats: n=3 for haiku and opus is small; one failing run moves the rate
  by 33 points. Haiku and opus were run with the with-arm only, so the
  plugin's lift on those models is not measured here.

## Multi-turn cases

Two Boatworks cases, sonnet, both arms, 3 runs each. Claude Code 2.1.303.

**History mechanism: `context.history_file` works.** It names a Claude Code
session transcript (JSONL, one `user`/`assistant` message object per line)
that the runner passes to `claude --resume`; `prompt.md` is the next turn. A
haiku probe ("my favourite colour is teal" in history, then "what is it?")
recalled it. With an explicit `--ablation with-without` both arms run on
the same history (with `--ablation auto` the runner makes a history case
single-arm, assuming the history carries the plugin). So the history holds
plain text only: the S2 request and the with-arm reply from
`20261019T021756Z` `s2-ask-with-3` (asks per job vs per operation, and where
times are kept). No skill call is replayed, or it would leak into the
without arm. No fallback to a quoted conversation was needed.

**`Agent` can be granted.** A haiku probe with `allowed_tools: [Read, Glob,
Agent]` called Agent once, so `s3-review-second-opinion` runs in the
harness; no outside `claude -p` run was needed.

| Case | Run | Arm | Pass | Score mean (min) | Notes |
|---|---|---|---|---|---|
| s2-ask-answered (before fix) | `20261019T025834Z` | with | 0/3 | 0.43 (0.43) | built per operation (Edit ×4–9), said where stored; **no decisions.md** |
| | | without | 0/3 | 0.43 (0.43) | same: built, no decisions.md |
| s2-ask-answered (after fix) | `20261019T030135Z` | with | **3/3** | 0.81 (0.71) | skill fired on the answer ×3; decisions.md has question + answer ×3 |
| | | without | 0/3 | 0.43 (0.43) | built, stated storage, no decision record |
| s3-review-second-opinion | `20261019T025839Z` | with | **3/3** | 0.97 (0.91) | risks 6/6 ×3; Agent dispatched ×3; llm reconciles 3/3 |
| | | without | 0/3 | 0.58 (0.45) | never opened Jobs.csv; no sign-in risk; Agent never used |

Cost and time: before-fix run 122 s, $1.04; after-fix run 96 s, $0.80;
second-opinion run 95 s, $0.80; regression check of s2/s2b/s2c (with, 2
runs each, after the fix) 47 s, $0.51, 6/6 pass; probes $0.01. Total about
$3.15.

- **Skill change (generic).** Before the fix both arms built the change and
  said where the data lives, but neither wrote `docs/context/decisions.md`:
  on the answer turn the ask skill was not in context (the history, like a
  resumed or compacted session, does not carry it), and nothing loaded its
  "After the user answers" steps. The description now also triggers on the
  user's answer to such a question, and that section says to skip the
  asking steps and do all three closing steps. No business words were
  added; the examples are "the second one", "against each step", "go ahead".
- **Storage statement.** All 12 runs said where the times are kept. After
  the fix, run 1 stored them in the browser with an Export button and said
  so plainly ("saved only in that computer's browser (localStorage)") — it
  noticed the user had not answered the storage question and recorded that
  as open in decisions.md. Before the fix, one with-arm run wrote to a
  `Timesheet.csv` on the shared drive through the browser's folder-picker
  API (Chrome/Edge only).
- **Second opinion.** Every with-arm run dispatched one reviewer and wrote a
  reconciliation, e.g. "a separate read-only reviewer found the same
  differences. It also found the Sea trial gap, the overdue flag on
  delivered jobs and the UTC date problem, which I had not flagged." The
  reconciliations are all "agreed, plus additions"; none reported a
  disagreement, so whether the skill handles a real conflict is untested.
- `llm-built-and-recorded` failed once after the fix (run 1) because the
  build was partial by design (storage left open); the deterministic
  graders passed. `used-skill` and `used-agent` are with-only indicators.

## Short replies (plugin 0.6.0, 20 Oct 2026)

From 0.6.0 the assess reply is deliberately the first screen only (what you
have, the three findings that matter most, what to do first) and points at
`docs/assessment/` for every row; "show me everything" gives it in chat. The
`row-*` regex graders score the chat reply, so the reply-only score fell
from 25–26 to 14–15 of 29 on `s1-assess`, by design. `run.sh` now also
scores the reply **plus the files each run wrote** (recovered from the run's
trace with `tests/judgement/regrade-with-files.py`) and prints both:

| Case | Arm | Reply only | Reply + written files |
|---|---|---|---|
| s1-assess (0.6.0, sonnet, 1 run) | with | 14/29 | 28/29 (missed only `row-d13-money-format-copied`) |

The judgement did not get worse; it moved out of the chat and into the
files. The file-inclusive number is the one to track for assess; the
reply-only number is the one to watch for "did the short reply keep the
three things that matter" (prices, the job list, what a dead laptop loses
all appeared in the 0.6.0 reply).

## 0.7.0 as shipped, and after the review (14 Nov 2026)

0.7.0 (hack, then promote) shipped on 22 Oct with no run of this suite. A run
of the suite as it stood, on 0.7.0 as shipped (sonnet, one run a case, both
arms, $4.73): **with the plugin 3 of 12 cases passed; without it, 1 of 12.**
Review still passed 3/3. Every ask case failed by design: an app with no
assessment file counted as a prototype and was built as asked. Both next
cases failed because next now needs the data and security notes first, and
the cases did not provide them. Assess scored 12–15/29 on the reply and
29/29 with its files, and the summary still printed "fail". Nothing covered
promote, finish, data or security.

What changed, all on 14 Nov:

- **The ask skill** reads reliance separately from stage. A prototype other
  people rely on gets the questions; only a new app or a prototype nobody
  but its builder uses is built without asking, and its reply must end with
  the signpost line.
- **The suite**: assess passes on reply plus files; new cases for a solo
  build, an Owned-tool ask, promote (two), data, security and finish (shell);
  next cases get the notes they need; a third, held-out business.
- **Held out.** Harakeke Electrical was written by an agent that was told
  not to read the skills, the bar or this file. 19 of its 29 findings are
  defect classes in neither earlier key. Its graders were frozen before any
  run.

Result on the changed plugin (sonnet, one run a case, both arms, about $10
across the runs below; results folders `20261114T04*`):

| Case | With the plugin | Without |
|---|---|---|
| s1-assess | PASS, 29/29 incl. files (14 in the reply) | fail, 23/29 |
| r1-assess | PASS, 29/29 (10 in the reply) | fail, 19/29 |
| **h1-assess (held out)** | **PASS, 29/29 (15 in the reply)** | fail, 21/29 |
| s3-review | PASS, 6/6, Jobs.csv read | fail, 5/6, not read |
| s3-review-second-opinion | **fail, 4/6** (backup and stale copy missing from the reply) | fail, 4/6 |
| r3-review | PASS, 6/6 | fail, 4/6, not read |
| **h3-review (held out)** | **PASS, 6/6, Jobs.csv read** | fail, 5/6, not read |
| s2-ask, s2b-ask, s2c-ask, r2-ask | PASS ×4: asked, built nothing | fail ×4 (three built; one asked something else) |
| s2d-ask-owned | PASS | fail (built) |
| s2-ask-answered | PASS: decision recorded, app changed | fail: no decision record |
| s6-solo-build | PASS: built, no questions, signpost | PASS (first run failed on a grader that assumed `apps/`) |
| s4-next-test | PASS on the rerun (see graders below) | fail |
| s5-next-own | PASS | fail |
| s7-promote-foundations | PASS | PASS |
| s8-promote-audit | fail ×3, a different single miss each run (see below) | fail ×2 |
| s9-data | PASS | fail (personal data not raised) |
| s10-security | PASS | PASS |
| s11-finish-prototype (shell) | PASS: no review, tried to land | fail: asked what to do |
| s12-promote-rebuild (shell) | fail on the first grading (stage not moved); rebuilt in 9 min, $2.23, said plainly that no test could run | not run |

With the plugin: 17 of 19 cases run passed. Without: 3 of 19.

How to read it:

- **One run a case.** The 0.4.0 variance work above says single runs flip.
  The gate (three runs, two must pass) is the number to trust; it has not
  been run yet.
- **The held-out result is the strongest line here**: on a business and
  defect classes the skill author never saw, with frozen graders, assess
  found 29 of 29 and review 6 of 6, against 21 and 5 for plain Claude, which
  again never opened the master file.
- **s7 and s10 do not separate the arms.** Plain Claude also passes them, so
  they guard against regressions and prove nothing about the plugin's value.
- **s8-promote-audit is not passing.** Run 1 failed on a grader bug (below).
  Run 2 asked five numbered questions holding eleven question marks; the
  skill now says a bundled question counts as several. Run 3 asked five
  with five, and failed on a pattern gap (below). It has not yet passed
  cleanly end to end.
- **The reply-only assess score is still below plain Claude's** (10–15
  against 19–23). The findings are in the files; whether a reader opens them
  is a field-test question.

Graders changed after a run, each for both arms (policy in
`tests/judgement/README.md`):

- `s6` `built-app`: matched only `apps/`; plain Claude writes to the repo
  root. Now any `.html`.
- `s8` `no-rebuild`: `input_match` sees file contents, and the assessment
  names `tests/job-board/`. Now anchored to `file_path`.
- `s8` `says-browser-storage`: missed "in that one browser only". Pattern
  gap closed.
- `s4` `offers-next-rung`: required bold `**Next`. The offer was there,
  unbolded.

No `h*` grader was changed.

Shell cases, added the same day once `socat` was installed:

- **s11** first showed a real gap: a branch checked out in the main folder
  was never landed ("nothing to do"). `landing.md` now switches to main and
  merges when the folder is clean. The case's first change was a comment
  that claimed a sort; the skill refused to land it, correctly, so the
  change is now a real sort.
- **The sandbox's shell cannot write.** No merge, no commit, no `npm ci`,
  no test run. `s11` therefore gates on the attempt to land, and `s12` on
  the rebuilt files and a straight reply; its stage move is reported only.
- **The gate has not passed, because it has not completed.** The one
  attempt ran out of disk: 33 of 66 runs never started and the assess
  traces were lost. Of the cases that did run three times: both original
  ask cases 3/3, security 3/3, finish 3/3, both held-out and Rimu reviews
  2/3 (one run each did not open `Jobs.csv`), the answer turn 2/3. The
  rebuild went 0/3, at least partly from the full disk. None of this is a
  gate result.

### The gate, 15 Nov 2026

Three attempts, $66 in all.

1. 14 Nov: the disk filled part-way; 33 of 66 runs never started. No result. $15.24.
2. 15 Nov, 02:44 UTC: ran to the end and failed on seven cases. Two causes were the harness:
   - `--shell` gave Bash to every case, not only the two shell cases. The reviews then read
     `Jobs.csv` with `cat` (the check looks for Read), and "next" tried to run tests in a sandbox
     whose shell cannot write, and stopped. The shell cases are now a second evaluation of their own.
   - `gate.py` scored assess after the run folders had been removed, so it saw the reply only
     (13 to 19 of 29) where `summarise.py`, a step earlier, had 28 or 29 with the files. The gate now
     scores before cleanup.
   One cause was a grader: `s12` `straight-about-tests` did not accept "its browser tests haven't
   run". Widened, wording only. The other `s12` miss in that run was real: one of three replies
   stopped mid-work at "Now the README, changelog, shape and assessment." with no changelog. $25.52.
3. 15 Nov, 03:15 UTC: **pass**, 22 cases, 63 of 66 runs. $25.19. The record is
   `tests/judgement/GATE.md`. The three misses: `s10-security` once asked more than the skill allows
   (`not-a-questionnaire`), `s4-next-test` once did not offer the next rung, `r3-review` once named
   five risks of six (still a pass).

Read with these in mind:

- `s3-review-second-opinion` passes on the risks; the second reviewer was dispatched in none of its
  six runs across attempts 2 and 3 (the reply says so each time). That check is reported, not gating.
- The shell cases grade the attempt and the account of it, because the sandbox shell cannot write.
  No gate run has a rebuild whose tests ran.
- The assess reply alone carries 11 to 19 of 29 rows; the rest are in the files it writes.
