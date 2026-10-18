#!/usr/bin/env bash
# Runs every check CI runs. Exit non-zero on first failure.
set -euo pipefail
cd "$(dirname "$0")/.."
echo "== validate.sh =="
# Later tasks append checks below this line.
echo "-- plugin manifests"
claude plugin validate plugin --strict
claude plugin validate . --strict
echo "-- smoke test on sample app"
scripts/smoke.sh apps/_sample/index.html
echo "OK"
