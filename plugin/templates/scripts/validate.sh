#!/usr/bin/env bash
# Runs every check this repository's CI runs. Exit non-zero on first failure.
set -euo pipefail
cd "$(dirname "$0")/.."
echo "== validate.sh =="
echo "-- smoke test on sample app"
scripts/smoke.sh apps/_sample/index.html
for f in apps/*/index.html; do
  [ "$f" = "apps/_sample/index.html" ] && continue
  echo "-- smoke test on $f"
  scripts/smoke.sh "$f"
done
echo "OK"
