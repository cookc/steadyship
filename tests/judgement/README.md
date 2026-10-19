# Judgement evals

`run.sh` runs the cases in `evals/` with and without the Steadyship plugin and
scores them. How it works, the graders and every result so far:
`docs/judgement-spike.md`.

## Fixtures (one mock business per case)

Each case runs on one mock business, its **fixture**:

| Cases | Business | Fixture | Answer key |
|---|---|---|---|
| `s*` | Demo Boatworks | `plugin/demo/` (ships, for the demo) | `tests/judgement/answer-key.md` |
| `r*` | Rimu Joinery | `tests/judgement/fixtures/rimu-joinery/` | `fixtures/rimu-joinery/answer-key.md` |

A case picks its fixture with a one-line `FIXTURE` file in its folder: a
repo-relative path such as `tests/judgement/fixtures/rimu-joinery`. A case
with no `FIXTURE` file uses `plugin/demo/`. `run.sh` stages the fixture into
the case as `fixture/`, leaving out `answer-key.md`, and refuses to run if any
answer key reaches the staged copy. `scaffold.sh` reads the fixture's
`init.env`, builds the repo with `init.sh` and `populate.sh`, and puts the
shared drive at `~/<business-name-lowercase-hyphenated>-shared-drive` (for
example `~/rimu-joinery-shared-drive`). Put that path in the assess prompt.

## Adding a third business

1. Copy `fixtures/rimu-joinery/` to `fixtures/<name>/`. Change `init.env`
   (`BUSINESS`, `SPONSOR`, `REPO_NAME`), the apps, the business notes and the
   shared drive. The shared drive must have a `Jobs.csv` (the scaffold checks
   it), or change that check. Keep `populate.sh` as it is.
2. Write `answer-key.md` with the same sections as the others, and a Verify
   command per row. Plant a different mix of defects.
3. Check that every app passes the smoke test (`scripts/smoke.sh` in a repo
   built with `init.sh` and `populate.sh`).
4. Copy `evals/r1-assess`, `r2-ask` and `r3-review` to a new prefix (for
   example `t1-assess`). Point `FIXTURE` at the new fixture, rewrite the
   prompts, and rewrite the graders from the new key. Keep the name endings
   `-assess`, `-ask` and `-review`, and the grader names `row-*`, `asks-*`,
   `risk-*`, `read-jobs-csv` and `*-named`: `summarise.py` scores cases by
   them, with no per-business code.
5. Check the regexes offline before you spend money:
   `regrade.py evals/t1-assess/case.yaml fixtures/<name>/answer-key.md`
   should score every row. A reply from another business should score few.
6. Run `run.sh --case 't*'`.

## Multi-turn cases

A case can start part-way through a conversation: put a Claude Code session
transcript (JSONL, one `user` / `assistant` message object per line, as in
`~/.claude/projects/*/*.jsonl`) in the case folder and name it in
`case.yaml` as `context.history_file`. The runner passes it to
`claude --resume`, and `prompt.md` is the next user turn. Keep the history
to plain text messages (no Skill tool calls or skill text): with
`--ablation with-without` both arms replay the same history, so anything the
plugin put into it would leak into the without arm. See `evals/s2-ask-answered`.
Cases whose name ends in `-answered` pass on every deterministic grader except
`changed-*` and `used-*`, plus at least one `changed-*`.
