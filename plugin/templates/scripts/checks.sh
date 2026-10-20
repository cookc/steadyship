#!/usr/bin/env bash
# Usage: scripts/checks.sh [app-folder-name]
# The machine checks the bar demands, per app: escaping, outside scripts, secrets, the stage
# banner, alert boxes, UTC dates, a README, tests of its own, format, lint, types, the file budget.
# A check that fails on a Prototype is reported as NOTE (nothing to fix yet); from Owned tool it
# is a FAIL. The last line is "RESULT: PASS" or "RESULT: FAIL <n> check(s)".
set -uo pipefail
cd "$(dirname "$0")/.."
ONLY="${1:-}"
fails=0
have() { [ -x "node_modules/.bin/$1" ]; }
stage_of() { sed -n 's/^\*\*Stage:\*\* *\([A-Za-z ]*[A-Za-z]\).*/\1/p' "docs/assessment/$1.md" 2>/dev/null | head -1; }
report() { # app check status detail
  local app="$1" check="$2" status="$3" detail="${4:-}"
  if [ "$status" = FAIL ] && [ "${ENFORCED:-0}" != 1 ]; then status=NOTE; fi
  [ "$status" = FAIL ] && fails=$((fails+1))
  printf '%s %s: %s%s\n' "$app" "$check" "$status" "${detail:+ $detail}"
}
grep_app() { grep -nE "$1" "apps/$2"/*.html "apps/$2"/*.js 2>/dev/null | grep -vE '^[^:]+:[0-9]+:\s*(//|\*|<!--)' ; }

for dir in apps/*/; do
  app="$(basename "$dir")"
  [ "$app" = "_sample" ] && continue
  [ -n "$ONLY" ] && [ "$app" != "$ONLY" ] && continue
  [ -f "$dir/index.html" ] || continue
  stage="$(stage_of "$app")"; [ -n "$stage" ] || stage="Prototype"
  ENFORCED=0; [ "$stage" != "Prototype" ] && ENFORCED=1
  echo "== $app ($stage; checks are $([ $ENFORCED = 1 ] && echo enforced || echo 'notes only until it is an Owned tool'))"
  # escaping: data must not enter the page as HTML
  hits="$(grep_app '\.innerHTML\s*[+]?=|document\.write\(|insertAdjacentHTML\(' "$app" | grep -vE "innerHTML\s*=\s*(''|\"\")\s*;?\s*$" | head -3)"
  [ -z "$hits" ] && report "$app" escaping PASS || report "$app" escaping FAIL "data may enter the page as HTML: $(echo "$hits" | head -1)"
  # nothing loaded from outside: scripts and styles come from lib/ or the app's folder
  hits="$(grep -nE '<(script|link)[^>]+(src|href)="?https?://' "$dir"/*.html 2>/dev/null | head -3)"
  [ -z "$hits" ] && report "$app" outside-scripts PASS || report "$app" outside-scripts FAIL "loaded from the internet: $(echo "$hits" | head -1)"
  # secrets
  hits="$(grep -nEi '(api[_-]?key|secret|passw(or)?d|token)["'"'"']?\s*[:=]\s*["'"'"'][^"'"'"']{6,}|AKIA[0-9A-Z]{16}|-----BEGIN [A-Z ]*PRIVATE KEY|sk-[A-Za-z0-9]{20,}' "$dir"/* 2>/dev/null | head -3)"
  [ -z "$hits" ] && report "$app" secrets PASS || report "$app" secrets FAIL "looks like a secret: $(echo "$hits" | head -1 | cut -c1-80)"
  # stage banner
  grep -q 'class="stage-banner"' "$dir/index.html" && report "$app" stage-banner PASS || report "$app" stage-banner FAIL "no stage banner at the top of the page"
  # alert boxes
  hits="$(grep_app '\b(alert|confirm|prompt)\(' "$app" | head -3)"
  [ -z "$hits" ] && report "$app" no-alert-boxes PASS || report "$app" no-alert-boxes FAIL "$(echo "$hits" | head -1)"
  # today's date from toISOString() is the UTC date
  hits="$(grep_app 'toISOString\(\)\.(slice|substr|substring|split)' "$app" | head -3)"
  [ -z "$hits" ] && report "$app" local-dates PASS || report "$app" local-dates FAIL "toISOString() gives the UTC date, wrong for part of every day: $(echo "$hits" | head -1)"
  # README and tests of its own
  [ -f "$dir/README.md" ] && report "$app" readme PASS || report "$app" readme FAIL "no apps/$app/README.md"
  [ -d "tests/$app" ] && report "$app" own-tests PASS || report "$app" own-tests FAIL "no tests/$app/"
  # format, lint, types (only when the tools are installed: npm install)
  if have prettier; then
    if node_modules/.bin/prettier --check "$dir" >/dev/null 2>&1; then report "$app" format PASS; else report "$app" format FAIL "run: npx prettier --write apps/$app"; fi
  else report "$app" format SKIP "prettier not installed (npm install)"; fi
  if have eslint; then
    if ls "$dir"/*.js >/dev/null 2>&1; then
      out="$(node_modules/.bin/eslint "$dir"/*.js 2>&1)"; rc=$?
      if [ $rc = 0 ]; then report "$app" lint PASS; else report "$app" lint FAIL "$(echo "$out" | grep -E 'error' | head -1 | sed 's/^ *//')"; fi
    else report "$app" lint SKIP "no .js file (scripts inside index.html are not linted; move them to app.js)"; fi
  else report "$app" lint SKIP "eslint not installed (npm install)"; fi
  # file budget: the master file named in data.json
  if [ -f "$dir/data.json" ]; then
    master="$(sed -n 's/.*"master" *: *"\([^"]*\)".*/\1/p' "$dir/data.json")"
    drive="$(sed -n 's/^Shared drive: *//p' steadyship.md | head -1)"; case "$drive" in "~"*) drive="$HOME${drive#\~}";; esac
    if [ -n "$master" ] && [ -f "$drive/$master" ]; then
      n="$(wc -l < "$drive/$master" | tr -d ' ')"
      [ "$n" -le 5000 ] && report "$app" file-budget PASS "$master has $n lines" || report "$app" file-budget FAIL "$master has $n lines; the bar's budget is 5,000 (time for a database)"
    else report "$app" file-budget SKIP "master file ${master:-unnamed} not visible from here"; fi
  fi
done
# types, once for the repository: only files that opt in with // @ts-check are checked
if have tsc; then
  out="$(node_modules/.bin/tsc -p tsconfig.json 2>&1)"; rc=$?
  if [ $rc = 0 ]; then echo "repository types: PASS"; else echo "repository types: FAIL $(echo "$out" | head -1)"; fails=$((fails+1)); fi
else echo "repository types: SKIP typescript not installed (npm install)"; fi
if [ "$fails" = 0 ]; then echo "RESULT: PASS"; else echo "RESULT: FAIL $fails check(s)"; exit 1; fi
