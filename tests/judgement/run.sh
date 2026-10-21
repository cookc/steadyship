#!/usr/bin/env bash
# Judgement eval harness: assess / ask / review cases on mock businesses (s* = Demo Boatworks,
# r* = Rimu Joinery), with and without the Steadyship plugin (claude plugin eval --ablation with-without).
# Usage: tests/judgement/run.sh [--runs N] [--cases GLOB] [--model M] [--max-cost-usd USD]
#                              [--arms with|both] [-j N] [--keep]   (defaults: 1, all, sonnet, 8, both, 1)
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
RUNS=1; CASE=""; MODEL=sonnet; MAXCOST=8; ABLATION=with-without; JOBS=1; KEEP=0; EXTRA=()
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
for c in "$STAGE"/plugin/evals/*/; do
  cp "$J/scaffold.sh" "$c/scaffold.sh"
  # A case with a FIXTURE file (a repo-relative fixture dir) gets that business staged
  # into <case>/fixture/, minus its answer key; otherwise scaffold.sh uses plugin/demo.
  if [ -f "$c/FIXTURE" ]; then
    fx="$ROOT/$(head -1 "$c/FIXTURE")"
    [ -f "$fx/init.env" ] || { echo "case $(basename "$c"): no fixture at $fx" >&2; exit 2; }
    mkdir -p "$c/fixture"
    ( cd "$fx" && tar cf - --exclude=answer-key.md . ) | ( cd "$c/fixture" && tar xf - )
  fi
done
[ -z "$(find "$STAGE" -name 'answer-key*')" ] || { echo "answer key found in staged plugin; refusing" >&2; exit 2; }

ARGS=(--scaffold --allow-tools Write Edit --model "$MODEL" --runs "$RUNS" --ablation "$ABLATION"
      --trust-plugin --no-publish --threshold 0 --max-cost-usd "$MAXCOST"
      --concurrency "$JOBS" --output-dir "$OUT" --report "$OUT/report.html" --json "$OUT/result.json"
      --keep-temp)   # temp dirs hold each run's trace; regrade-with-files.py reads them, then they are removed
[ -z "$CASE" ] || ARGS+=(--case "$CASE")
[ ${#EXTRA[@]} -eq 0 ] || ARGS+=("${EXTRA[@]}")
echo "Staged plugin: $STAGE/plugin  ->  results: $OUT"
start=$(date +%s)
set +e
claude plugin eval "$STAGE/plugin" "${ARGS[@]}" 2>&1 | tee "$OUT/eval.log"
rc=${PIPESTATUS[0]}
set -e
echo "claude plugin eval exit $rc after $(( $(date +%s) - start ))s" | tee -a "$OUT/eval.log"
[ -f "$OUT/result.json" ] || { echo "no result.json written" >&2; exit 1; }
python3 "$J/summarise.py" "$OUT/result.json" | tee "$OUT/summary.md"
# Since plugin 0.6.0 the assess reply is deliberately short and the rows live in docs/assessment/;
# score the reply plus the files the run wrote, from each run's trace, then drop the temp dirs.
{ echo; echo "Rows including the files each run wrote (assess replies are short by design):"; echo;
  python3 "$J/regrade-with-files.py" "$OUT/result.json"; } | tee -a "$OUT/summary.md"
if [ "$KEEP" = 1 ]; then echo "kept run dirs:"; grep -o '"tracePath": *"[^"]*"' "$OUT/result.json" | sed 's/.*: *"//; s/"$//' | sed 's#/out/trace.jsonl$##' | sort -u
else
  grep -o '"tracePath": *"[^"]*"' "$OUT/result.json" | sed 's/.*: *"//; s/"$//' | sed 's#/out/trace.jsonl$##' | sort -u | while read -r d; do case "$d" in /tmp/claude-eval-*) chmod -R u+rwx "$d" 2>/dev/null; rm -rf "$d";; esac; done
fi
ln -sfn "$(basename "$OUT")/summary.md" "$J/results/latest.md"
