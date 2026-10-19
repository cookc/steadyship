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
