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
| `h*` | Harakeke Electrical | `tests/judgement/fixtures/harakeke-electrical/` | `fixtures/harakeke-electrical/answer-key.md` |

Harakeke Electrical is the held-out fixture: it, its answer key and the `h*` graders were authored without reading the skills, and the graders were frozen at authoring time (do not widen them after seeing model output).

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

## What each case tests

| Case | Skill | What must happen |
|---|---|---|
| `s1`, `r1`, `h1` `-assess` | assess | the answer key's rows are found, in the reply plus the files written |
| `s3`, `r3`, `h3` `-review` | review | the master file is opened and the key's risks named |
| `s2`, `s2b`, `s2c`, `r2` `-ask` | ask | a prototype people rely on: asks first, changes nothing |
| `s2d-ask-owned` | ask | an app at Owned tool: asks first |
| `s2-ask-answered` | ask | the answer turn: decision recorded, app changed |
| `s6-solo-build` | ask | a page only its builder will use: built, no questions, signpost line |
| `s4`, `s5` `-next-*` | next | one rung done or offered, with the notes in place (`SEEDS`) |
| `s7-promote-foundations` | promote | no data or security notes: stops and says how to start each |
| `s8-promote-audit` | promote | notes in place: audit and at most five questions, no rebuild yet |
| `s9-data`, `s10-security` | data, security | first turn: the questions, nothing written yet |
| `s11-finish-prototype` (shell) | finish | a prototype change on a branch: no review, and it tries to land it on main |
| `s12-promote-rebuild` (shell) | promote | the turn after the answers: the app rebuilt with tests, a data file and a changelog, and a straight account of whether the tests ran |

Not covered: finish on an app at Owned tool (it needs a fixture app that
has been promoted), and anything that needs the shell to write. The
runner's sandbox gives the shell a read-only disk: no test tool can be
installed, no test can run, no commit or merge can complete. So `s11`
grades the attempt to land and `s12` grades the files written and whether
the reply is straight about the tests. A rebuild whose tests actually pass
has only run 3 of `docs/experiment-cut-planner.md` behind it.

## Seeds, shell cases, the gate

- **Seeds.** A case's `seed/` folder is laid over the repo before the first
  commit. A `SEEDS` file (repo-relative folders, one a line) pulls in shared
  ones: `seeds/demo-foundations` is Demo Boatworks' data and security notes.
  A `setup.sh` in the case runs after the commit (a branch with a change
  waiting).
- **Shell cases** live in `evals-shell/` and run only with `run.sh --shell`.
  The runner grants Bash only when its OS sandbox works, which on Linux needs
  `bubblewrap` and `socat`. `s12` takes about ten minutes and $2 a run.
  They are evaluated on their own, after the others, and the two results are
  merged: the runner's tool grant covers every case in a run, and a case
  written without a shell behaves differently when given one.
- **The gate.** `run.sh --gate` runs every case three times with the plugin
  and writes `GATE.md` here: a case passes at two of three. Commit `GATE.md`
  before tagging; the release workflow refuses a tag without a passing one
  for that version and quotes it in the release notes. It needs a few GB of
  free disk and costs about $25. History of attempts is in
  `docs/judgement-spike.md`.

## Changing a grader

A grader is written from the skill's stated behaviour and the answer key
before the case is run. After a run it may be changed only when it was wrong
about the harness or about formatting (it needed bold text, it matched a path
inside a file's contents), never to accept a reply that missed the substance.
Every such change applies to both arms and gets a dated comment on the grader
and a line in `docs/judgement-spike.md`. The `h*` graders are frozen: a miss
there is a miss.

`tool_used` graders: `input_match` sees the whole tool input, file contents
included. To match a path, anchor it: `'"file_path":\s*"[^"]*docs/x\.md'`.
