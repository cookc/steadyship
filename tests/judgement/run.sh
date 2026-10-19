#!/usr/bin/env bash
# Judgement eval harness: assess / ask / review cases on mock businesses (s* = Demo Boatworks,
# r* = Rimu Joinery), with and without the Steadyship plugin (claude plugin eval --ablation with-without).
# Usage: tests/judgement/run.sh [--runs N] [--case GLOB] [--model M] [--max-cost-usd USD]
#                              [--ablation with-without|none]   (defaults: 1, all, sonnet, 8, with-without)
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
RUNS=1; CASE=""; MODEL=sonnet; MAXCOST=8; ABLATION=with-without; EXTRA=()
while [ $# -gt 0 ]; do
  case "$1" in
    --runs) RUNS="$2"; shift 2;;
    --case) CASE="$2"; shift 2;;
    --model) MODEL="$2"; shift 2;;
    --max-cost-usd) MAXCOST="$2"; shift 2;;
    --ablation) ABLATION="$2"; shift 2;;
    --) shift; EXTRA=("$@"); break;;   # anything after -- goes to claude plugin eval (e.g. --keep-temp)
    *) echo "unknown option: $1" >&2; exit 2;;
  esac
done
command -v claude >/dev/null || { echo "claude CLI not found" >&2; exit 2; }
OUT="$J/results/$(date -u +%Y%m%dT%H%M%SZ)"
mkdir -p "$OUT"
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
      --output-dir "$OUT" --report "$OUT/report.html" --json "$OUT/result.json")
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
