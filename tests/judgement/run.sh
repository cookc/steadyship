#!/usr/bin/env bash
# Judgement eval harness: assess / ask / review cases on mock businesses (s* = Demo Boatworks,
# r* = Rimu Joinery), with and without the Steadyship plugin (claude plugin eval --ablation with-without).
# Usage: tests/judgement/run.sh [--runs N] [--cases GLOB] [--model M] [--max-cost-usd USD]
#                              [--arms with|both] [-j N] [--keep] [--shell] [--gate]
#                              (defaults: 1, all, sonnet, 8, both, 1)
#   --shell also runs the cases in evals-shell/ (finish, the promote rebuild): they need Bash, and the
#     runner only grants Bash when its OS sandbox works (Linux: bubblewrap and socat installed).
#   --gate is the release gate: with arm only, 3 runs a case, exit 1 unless every case passes at
#     least 2 of 3. Writes tests/judgement/GATE.md, which the release notes quote.
#   --keep leaves each run's /tmp/claude-eval-* dir (trace and written files) for inspection.
#   --case is an alias of --cases; --ablation with-without|none is the raw form of --arms both|with.
# Costs money and takes minutes: NOT part of scripts/validate.sh or CI.
# Output: tests/judgement/results/<UTC timestamp>/{result.json,report.html,summary.md,eval.log}
#
# The cases live here, outside plugin/, so they never ship with the plugin. Each run
# stages a throwaway copy of plugin/ with the cases copied in as evals/ and evaluates
# that copy. Answer keys are never staged. A case whose folder has a FIXTURE file runs on that
# fixture (see tests/judgement/README.md); the rest run on plugin/demo.
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
J="$ROOT/tests/judgement"
RUNS=1; CASE=""; MODEL=sonnet; MAXCOST=8; ABLATION=with-without; JOBS=1; KEEP=0; SHELL_CASES=0; GATE=0; EXTRA=()
while [ $# -gt 0 ]; do
  case "$1" in
    --runs) RUNS="$2"; shift 2;;
    --case|--cases) CASE="$2"; shift 2;;
    --arms) case "$2" in with) ABLATION=none;; both) ABLATION=with-without;;
              without) echo "--arms without is not supported by the runner (use with or both)" >&2; exit 2;;
              *) echo "--arms: with|without|both" >&2; exit 2;; esac; shift 2;;
    -j|--jobs) JOBS="$2"; shift 2;;
    --model) MODEL="$2"; shift 2;;
    --max-cost-usd) MAXCOST="$2"; shift 2;;
    --ablation) ABLATION="$2"; shift 2;;
    --keep) KEEP=1; shift;;
    --shell) SHELL_CASES=1; shift;;
    --gate) GATE=1; RUNS=3; ABLATION=none; [ "$MAXCOST" != 8 ] || MAXCOST=25; [ "$JOBS" != 1 ] || JOBS=4; shift;;
    --) shift; EXTRA=("$@"); break;;   # anything after -- goes to claude plugin eval (e.g. --keep-temp)
    *) echo "unknown option: $1" >&2; exit 2;;
  esac
done
command -v claude >/dev/null || { echo "claude CLI not found" >&2; exit 2; }
OUT="$J/results/$(date -u +%Y%m%dT%H%M%SZ)"
mkdir -p "$OUT"
ln -sfn "$(basename "$OUT")" "$J/results/latest"
STAGE="$(mktemp -d "${TMPDIR:-/tmp}/steadyship-judgement-XXXXXX")"
trap 'rm -rf "$STAGE"' EXIT
( cd "$ROOT" && tar cf - --exclude=node_modules --exclude=evals plugin ) | ( cd "$STAGE" && tar xf - )
cp -R "$J/evals" "$STAGE/plugin/evals"
# The shell cases run as a second evaluation of their own: --allow-tools applies to every case in a
# run, and a case written without a shell behaves differently when handed one (the reviews read
# Jobs.csv with cat, "next" tries to run tests the sandbox cannot run). Found by the first gate run.
if [ "$SHELL_CASES" = 1 ]; then
  command -v socat >/dev/null && command -v bwrap >/dev/null || {
    echo "--shell needs the runner's sandbox: install bubblewrap and socat (sudo apt install bubblewrap socat)" >&2; exit 2; }
  mkdir -p "$STAGE/shell"
  ( cd "$ROOT" && tar cf - --exclude=node_modules --exclude=evals plugin ) | ( cd "$STAGE/shell" && tar xf - )
  mkdir -p "$STAGE/shell/plugin/evals"; cp -R "$J"/evals-shell/*/ "$STAGE/shell/plugin/evals/"
else
  echo "Not running the $(ls -d "$J"/evals-shell/*/ 2>/dev/null | wc -l | tr -d ' ') shell case(s) in evals-shell/ (finish, promote rebuild): pass --shell."
fi
for c in "$STAGE"/plugin/evals/*/ "$STAGE"/shell/plugin/evals/*/; do
  [ -d "$c" ] || continue
  cp "$J/scaffold.sh" "$c/scaffold.sh"
  # A case with a FIXTURE file (a repo-relative fixture dir) gets that business staged
  # into <case>/fixture/, minus its answer key; otherwise scaffold.sh uses plugin/demo.
  if [ -f "$c/FIXTURE" ]; then
    fx="$ROOT/$(head -1 "$c/FIXTURE")"
    [ -f "$fx/init.env" ] || { echo "case $(basename "$c"): no fixture at $fx" >&2; exit 2; }
    mkdir -p "$c/fixture"
    ( cd "$fx" && tar cf - --exclude=answer-key.md . ) | ( cd "$c/fixture" && tar xf - )
  fi
  # A case with a SEEDS file (repo-relative folders, one a line) gets each laid into <case>/seed/.
  if [ -f "$c/SEEDS" ]; then
    mkdir -p "$c/seed"
    while read -r sd; do [ -n "$sd" ] || continue
      [ -d "$ROOT/$sd" ] || { echo "case $(basename "$c"): no seed folder $sd" >&2; exit 2; }
      ( cd "$ROOT/$sd" && tar cf - . ) | ( cd "$c/seed" && tar xf - ); done < "$c/SEEDS"
  fi
done
[ -z "$(find "$STAGE" -name 'answer-key*')" ] || { echo "answer key found in staged plugin; refusing" >&2; exit 2; }

# evaluate <staged plugin> <output dir> <max cost> <tool>...
evaluate() {
  local plugin="$1" out="$2" cost="$3"; shift 3
  local args=(--scaffold --allow-tools "$@" --model "$MODEL" --runs "$RUNS" --ablation "$ABLATION"
      --trust-plugin --no-publish --threshold 0 --max-cost-usd "$cost"
      --concurrency "$JOBS" --output-dir "$out" --report "$out/report.html" --json "$out/result.json"
      --keep-temp)   # temp dirs hold each run's trace; regrade-with-files.py reads them, then they are removed
  [ -z "$CASE" ] || args+=(--case "$CASE")
  [ ${#EXTRA[@]} -eq 0 ] || args+=("${EXTRA[@]}")
  mkdir -p "$out"
  echo "Staged plugin: $plugin  ->  results: $out"
  local start rc; start=$(date +%s)
  set +e
  claude plugin eval "$plugin" "${args[@]}" 2>&1 | tee -a "$OUT/eval.log"
  rc=${PIPESTATUS[0]}
  set -e
  echo "claude plugin eval exit $rc after $(( $(date +%s) - start ))s" | tee -a "$OUT/eval.log"
}
evaluate "$STAGE/plugin" "$OUT" "$MAXCOST" Write Edit
if [ "$SHELL_CASES" = 1 ]; then
  # What the first evaluation spent comes off the ceiling for the second; then the two results are merged.
  left="$(python3 -c 'import json,sys
try: spent = json.load(open(sys.argv[1])).get("costUsd", 0)
except OSError: spent = 0
print(max(1, round(float(sys.argv[2]) - spent, 2)))' "$OUT/result.json" "$MAXCOST")"
  evaluate "$STAGE/shell/plugin" "$OUT/shell" "$left" Write Edit Bash
  python3 "$J/merge-results.py" "$OUT/result.json" "$OUT/shell/result.json"
fi
[ -f "$OUT/result.json" ] || { echo "no result.json written" >&2; exit 1; }
# Since plugin 0.6.0 the assess reply is deliberately short and the rows live in docs/assessment/, so
# summarise.py scores an assess case on the reply plus the files the run wrote (read from each run's
# trace, which is why the temp dirs are kept until it has run).
python3 "$J/summarise.py" "$OUT/result.json" | tee "$OUT/summary.md"
# The gate scores from the same traces, so it runs before they are removed.
if [ "$GATE" = 1 ]; then
  python3 "$J/gate.py" "$OUT/result.json" "$(sed -n 's/.*"version": *"\([^"]*\)".*/\1/p' "$ROOT/plugin/.claude-plugin/plugin.json")" \
    "$(git -C "$ROOT" rev-parse --short HEAD)$(git -C "$ROOT" diff --quiet HEAD -- plugin || echo '+uncommitted')" | tee "$J/GATE.md"
fi
if [ "$KEEP" = 1 ]; then echo "kept run dirs:"; grep -o '"tracePath": *"[^"]*"' "$OUT/result.json" | sed 's/.*: *"//; s/"$//' | sed 's#/out/trace.jsonl$##' | sort -u
else
  grep -o '"tracePath": *"[^"]*"' "$OUT/result.json" | sed 's/.*: *"//; s/"$//' | sed 's#/out/trace.jsonl$##' | sort -u | while read -r d; do case "$d" in /tmp/claude-eval-*) chmod -R u+rwx "$d" 2>/dev/null; rm -rf "$d";; esac; done
fi
ln -sfn "$(basename "$OUT")/summary.md" "$J/results/latest.md"
[ "$GATE" != 1 ] || tail -1 "$J/GATE.md" | grep -q '^GATE: PASS' || exit 1
