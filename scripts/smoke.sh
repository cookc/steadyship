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
if [ ! -d node_modules/@playwright ]; then
  echo "Installing test tools (first run only)..."
  npm install --no-audit --no-fund >/dev/null 2>&1 || { echo "RESULT: FAIL could not install test tools (npm)"; exit 1; }
  npx playwright install chromium >/dev/null 2>&1 || { echo "RESULT: FAIL could not install the test browser (network blocked?)"; exit 1; }
fi
echo "Opening $APP in a test browser and checking it loads without errors..."
if APP="$APP" npx playwright test --config playwright.config.ts >/tmp/smoke.log 2>&1; then
  echo "The app opened and no errors were reported."
  echo "RESULT: PASS"
  exit 0
else
  echo "Something went wrong when opening the app:"
  grep -E 'Error|error|uncaught|console' /tmp/smoke.log | head -5 | sed 's/^/  /'
  echo "RESULT: FAIL the app did not load cleanly (see lines above)"
  exit 1
fi
