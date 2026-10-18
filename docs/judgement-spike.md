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
