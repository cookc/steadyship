#!/usr/bin/env bash
# Usage: scripts/smoke.sh <path/to/index.html | http(s)://url>
# Prints plain-language lines; last line is "RESULT: PASS" or "RESULT: FAIL <reason>".
set -uo pipefail
cd "$(dirname "$0")/.."
APP="${1:-}"
if [ -z "$APP" ]; then
  echo "RESULT: FAIL no app given (expected a path to index.html or a URL)"
  exit 1
fi
BROWSERS="${PLAYWRIGHT_BROWSERS_PATH:-$HOME/.cache/ms-playwright}"
if [ ! -d node_modules/@playwright ] || ! ls -d "$BROWSERS"/chromium* >/dev/null 2>&1; then
  echo "Installing test tools (first run only)..."
  if [ ! -d node_modules/@playwright ]; then
    OUT="$(npm install --no-audit --no-fund 2>&1)" || { echo "$OUT" | tail -3 | sed 's/^/  /'; echo "RESULT: FAIL could not install test tools (npm)"; exit 1; }
  fi
  OUT="$(npx playwright install chromium 2>&1)" || { echo "$OUT" | tail -3 | sed 's/^/  /'; echo "RESULT: FAIL could not install the test browser (network blocked?)"; exit 1; }
fi
case "$APP" in
  http://*|https://*) ;;
  *) [ -e "$APP" ] || { echo "RESULT: FAIL could not find the app at that path: $APP"; exit 1; } ;;
esac
echo "Opening $APP in a test browser and checking it loads without errors..."
if APP="$APP" npx playwright test --config playwright.config.ts >/tmp/smoke.log 2>&1; then
  echo "The app opened and no errors were reported."
  echo "RESULT: PASS"
  exit 0
else
  if grep -qE "browserType\.launch|Executable doesn't exist|error while loading shared libraries" /tmp/smoke.log; then
    echo "The test browser could not start:"
    grep -E "browserType\.launch|Executable doesn't exist|error while loading shared libraries" /tmp/smoke.log | head -3 | sed 's/^/  /'
    echo "RESULT: FAIL the test browser could not start (tooling problem, not the app)"
    exit 1
  fi
  echo "Something went wrong when opening the app:"
  grep -E 'Error|error|uncaught|console' /tmp/smoke.log | head -5 | sed 's/^/  /'
  echo "RESULT: FAIL the app has errors (see lines above)"
  exit 1
fi
