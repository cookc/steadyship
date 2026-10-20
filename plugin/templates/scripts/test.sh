#!/usr/bin/env bash
# Usage: scripts/test.sh <app-folder-name>
# Runs the smoke test on apps/<name>/index.html, then the app's own tests in
# tests/<name>/ if that folder exists. Plain-language lines; the last line is
# "RESULT: PASS" or "RESULT: FAIL <reason>".
set -uo pipefail
cd "$(dirname "$0")/.."
NAME="${1:-}"
[ -n "$NAME" ] || { echo "RESULT: FAIL no app given (expected a folder name under apps/)"; exit 1; }
[ -f "apps/$NAME/index.html" ] || { echo "RESULT: FAIL no app at apps/$NAME/index.html"; exit 1; }
scripts/smoke.sh "apps/$NAME/index.html" || exit 1
if [ -d "tests/$NAME" ]; then
  n="$(find "tests/$NAME" -name '*.spec.ts' | wc -l | tr -d ' ')"
  echo "Running the app's own tests ($n file(s) in tests/$NAME) ..."
  if APP="apps/$NAME/index.html" npx playwright test --config playwright.config.ts "tests/$NAME" >/tmp/test-$NAME.log 2>&1; then
    echo "All of the app's own tests passed."
  else
    grep -E '✘|Error|error|expect' "/tmp/test-$NAME.log" | head -8 | sed 's/^/  /'
    echo "RESULT: FAIL the app's own tests failed (see lines above)"
    exit 1
  fi
else
  echo "The app has no tests of its own yet (none in tests/$NAME)."
fi
echo "RESULT: PASS"
