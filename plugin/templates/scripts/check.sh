#!/usr/bin/env bash
# "Check this computer": the three checks worth a minute before anything is built on this setup.
#   environment  - tools, network, whether files persist          (scripts/spikes/env.sh)
#   shared-drive - read, write and delete on the shared drive      (scripts/spikes/nas-rw.sh)
#   tests        - open one app in a test browser                  (scripts/smoke.sh)
# Usage: scripts/check.sh [--shared-drive <folder>] [--app <name>] [--no-record]
# The shared drive comes from steadyship.md unless given; the app is the first folder in apps/
# (other than _sample) unless given. Rows are written to docs/spikes/RESULTS.md unless --no-record.
# Last line: "RESULT: PASS" (no check failed; skips are listed) or "RESULT: FAIL <checks>".
set -uo pipefail
cd "$(dirname "$0")/.." || { echo "RESULT: FAIL could not find the repository folder"; exit 1; }
DRIVE=""; APP=""; RECORD=1
while [ $# -gt 0 ]; do
  case "$1" in
    --shared-drive|--app) [ $# -ge 2 ] || { echo "RESULT: FAIL $1 needs a value"; exit 1; }
      if [ "$1" = "--app" ]; then APP="$2"; else DRIVE="$2"; fi; shift 2 ;;
    --no-record) RECORD=0; shift ;;
    *) echo "RESULT: FAIL unknown option $1"; exit 1 ;;
  esac
done
TODAY="$(date +%Y-%m-%d)"
LOG="$(mktemp)"; trap 'rm -f "$LOG"' EXIT
declare -A RES NOTE
show() { sed 's/^/    /' "$LOG"; }
clean() { printf '%s' "$1" | tr -d '|\r' | cut -c1-160; }

echo "== 1/3 Environment: tools, network, persistence =="
if bash scripts/spikes/env.sh >"$LOG" 2>&1; then RES[environment]=PASS; else RES[environment]=FAIL; fi
show
sum="$(sed -n 's/^Environment summary: //p' "$LOG" | tail -1)"
[ "${RES[environment]}" = PASS ] && NOTE[environment]="${sum:-ran}" || NOTE[environment]="$(sed -n 's/^RESULT: FAIL //p' "$LOG" | tail -1)"

echo "== 2/3 Shared drive: read, write, delete =="
[ -n "$DRIVE" ] || DRIVE="$(sed -n 's/^Shared drive: *//p' steadyship.md 2>/dev/null | head -1)"
DRIVE="${DRIVE%[\\/]}"   # Z:\ -> Z:
case "$DRIVE" in
  ""|none|None|NONE) RES[shared-drive]=SKIP; NOTE[shared-drive]="no shared drive recorded in steadyship.md"
    echo "    no shared drive recorded; skipped" ;;
  *)
    case "$DRIVE" in
      "~"|"~/"*) DRIVE="$HOME${DRIVE#\~}" ;;
      [A-Za-z]:*) command -v cygpath >/dev/null 2>&1 && DRIVE="$(cygpath -u "$DRIVE")" ;;
    esac
    if [ ! -d "$DRIVE" ]; then
      RES[shared-drive]=FAIL; NOTE[shared-drive]="not visible from here: $DRIVE"
      echo "    $DRIVE is not visible from here"
    elif bash scripts/spikes/nas-rw.sh "$DRIVE" >"$LOG" 2>&1; then
      RES[shared-drive]=PASS; NOTE[shared-drive]="read, write and delete ok on $DRIVE"; show
    else
      RES[shared-drive]=FAIL; NOTE[shared-drive]="$(sed -n 's/^RESULT: FAIL //p' "$LOG" | tail -1)"; show
    fi ;;
esac

echo "== 3/3 Tests: open one app in a test browser =="
if [ -z "$APP" ]; then
  for d in apps/*/; do d="${d%/}"; d="${d#apps/}"; [ "$d" = "_sample" ] && continue; [ -f "apps/$d/index.html" ] && { APP="$d"; break; }; done
fi
if [ -z "$APP" ]; then
  RES[tests]=SKIP; NOTE[tests]="no app in apps/ yet"; echo "    no app in apps/ yet; skipped"
elif [ ! -f "apps/$APP/index.html" ]; then
  RES[tests]=FAIL; NOTE[tests]="no apps/$APP/index.html"; echo "    apps/$APP/index.html not found"
else
  bash scripts/smoke.sh "apps/$APP/index.html" >"$LOG" 2>&1; rc=$?
  show
  last="$(sed -n 's/^RESULT: //p' "$LOG" | tail -1)"
  case "$last" in
    PASS*) RES[tests]=PASS; NOTE[tests]="$APP opened without errors" ;;
    "FAIL the app has errors"*) RES[tests]=PASS; NOTE[tests]="tooling ok; $APP has errors, see its assessment" ;;
    *) RES[tests]=FAIL; NOTE[tests]="${last#FAIL }" ;;
  esac
fi

echo "== Results =="
printf '| %-13s | %-6s | %s |\n' Check Result Note
failed=""
for k in environment shared-drive tests; do
  printf '| %-13s | %-6s | %s |\n' "$k" "${RES[$k]}" "$(clean "${NOTE[$k]}")"
  [ "${RES[$k]}" = FAIL ] && failed="$failed $k"
done
if [ "$RECORD" = 1 ] && [ -f docs/spikes/RESULTS.md ]; then
  for k in environment shared-drive tests; do
    row="| $k | ${RES[$k]} | $TODAY | $(clean "${NOTE[$k]}") |"
    if grep -q "^| $k |" docs/spikes/RESULTS.md; then
      awk -v k="$k" -v row="$row" 'index($0, "| " k " |") == 1 { print row; next } { print }' docs/spikes/RESULTS.md > "$LOG.r" && mv "$LOG.r" docs/spikes/RESULTS.md
    else
      printf '%s\n' "$row" >> docs/spikes/RESULTS.md
    fi
  done
  echo "Recorded in docs/spikes/RESULTS.md."
fi
if [ -n "$failed" ]; then echo "RESULT: FAIL$failed"; exit 1; fi
echo "RESULT: PASS"
