#!/usr/bin/env bash
# Generates a customer repo from the templates and checks it is complete and self-contained.
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
OUT="$(mktemp -d "${TMPDIR:-/tmp}/steadyship-init-test.XXXXXX")"
trap 'rm -rf "$OUT"' EXIT
DIR="$OUT/demo-apps"
fail() { echo "FAIL: $*"; exit 1; }

"$ROOT/plugin/scripts/init.sh" "$DIR" \
  --business "Demo Boatworks" --setup-owner "Sam Setup" --sponsor "Olive Owner" \
  --github-owner demo-org --repo-name demo-apps --shared-drive 'Z:\' | tee "$OUT/init.log"
tail -1 "$OUT/init.log" | grep -q '^RESULT: PASS' || fail "init did not PASS"

for f in steadyship.md README.md .gitignore .gitattributes package.json playwright.config.ts \
         tests/smoke/app.spec.ts scripts/validate.sh scripts/smoke.sh scripts/test.sh scripts/check.sh scripts/serve.mjs \
         lib/papaparse.min.js lib/README.md lib/LICENSE-papaparse lib/theme.css lib/steadyship.js lib/globals.d.ts \
         apps/_template/index.html apps/_template/app.js apps/_template/data.json apps/_template/README.md \
         tests/_template/_template.spec.ts scripts/checks.sh eslint.config.mjs tsconfig.json .prettierrc .prettierignore docs/context/engineering.md \
         scripts/spikes/git-push.sh scripts/spikes/nas-rw.sh scripts/spikes/env.sh apps/_sample/index.html \
         docs/assessment/README.md docs/assessment/TEMPLATE.md docs/assessment/SUMMARY.md \
         docs/assessment/_sample.md docs/context/business/README.md docs/context/engineering.md docs/spikes/README.md docs/spikes/RESULTS.md \
         docs/spikes/environment.md docs/spikes/github.md docs/spikes/shared-drive.md docs/spikes/tests.md docs/spikes/hosting.md \
         docs/spikes/team.md docs/spikes/hosting/staticwebapp.config.json \
         docs/spikes/hosting/azure-static-web-apps.yml .github/workflows/validate.yml; do
  [ -f "$DIR/$f" ] || fail "missing $f"
done
for s in scripts/validate.sh scripts/smoke.sh scripts/test.sh scripts/checks.sh scripts/check.sh scripts/spikes/git-push.sh scripts/spikes/nas-rw.sh scripts/spikes/env.sh; do
  [ -x "$DIR/$s" ] || fail "$s not executable"
done
# GitHub Actions "${{ secrets.X }}" is legitimate; only {{UPPER_CASE}} placeholders count.
if grep -rnE '\{\{[A-Z_]+\}\}' "$DIR" --exclude-dir=.git >/dev/null; then grep -rnE '\{\{[A-Z_]+\}\}' "$DIR" --exclude-dir=.git; fail "unsubstituted placeholders"; fi
grep -q '^Business: Demo Boatworks$' "$DIR/steadyship.md" || fail "business not substituted"
grep -q '^Setup owner: Sam Setup$' "$DIR/steadyship.md" || fail "setup owner not substituted"
grep -q 'Z:\\' "$DIR/steadyship.md" || fail "shared drive with backslash not substituted"
VER="$(sed -n 's/.*"version": *"\([^"]*\)".*/\1/p' "$ROOT/plugin/.claude-plugin/plugin.json")"
grep -q "^Template version: $VER\$" "$DIR/steadyship.md" || fail "template version $VER not written"
MP="$(sed -n 's#.*"repository": *"https://github.com/\([^"]*\)".*#\1#p' "$ROOT/plugin/.claude-plugin/plugin.json")"
grep -q "^Plugin marketplace: $MP\$" "$DIR/steadyship.md" || fail "plugin marketplace $MP not written"
grep -qE "^Time zone: ([A-Za-z]+/[A-Za-z_/+-]+|not yet confirmed)$" "$DIR/steadyship.md" || fail "time zone line missing or malformed"
grep -q "^| Time zone | " "$DIR/docs/context/engineering.md" || fail "engineering.md lacks the time zone row"
grep -q 'Setup owner:\*\* Sam Setup' "$DIR/docs/assessment/README.md" || fail "README role line"
for f in .gitignore .gitattributes .github/workflows/validate.yml; do [ -f "$DIR/$f" ] || fail "missing $f"; done
[ -f "$DIR/.steadyship/manifest" ] || fail "manifest missing"
grep -qE '^[0-9a-f]{64}  steadyship\.md$' "$DIR/.steadyship/manifest" || fail "manifest lacks steadyship.md"
git -C "$DIR" ls-files --error-unmatch .steadyship/manifest >/dev/null || fail "manifest not committed"
[ "$(git -C "$DIR" rev-list --count HEAD)" = "1" ] || fail "expected exactly one commit"
[ "$(git -C "$DIR" branch --show-current)" = "main" ] || fail "branch is not main"
[ -z "$(git -C "$DIR" status --short)" ] || fail "tree not clean after init"
git -C "$DIR" ls-files --eol scripts | grep -q 'w/crlf' && fail "CRLF in scripts" || true
# an app's data manifest is tracked; its data files are not
mkdir -p "$DIR/apps/x"; echo '{"master":"Jobs.csv"}' > "$DIR/apps/x/data.json"; echo 'a,b' > "$DIR/apps/x/Jobs.csv"
[ -z "$(git -C "$DIR" check-ignore apps/x/data.json)" ] || fail "apps/x/data.json must not be ignored"
[ -n "$(git -C "$DIR" check-ignore apps/x/Jobs.csv)" ] || fail "apps/x/Jobs.csv must be ignored"
rm -rf "$DIR/apps/x"

# second run into a non-empty dir must refuse
set +e; "$ROOT/plugin/scripts/init.sh" "$DIR" --business x --setup-owner x --sponsor x --github-owner x --repo-name x --shared-drive x >"$OUT/again.log" 2>&1; rc=$?; set -e
[ "$rc" = "1" ] && tail -1 "$OUT/again.log" | grep -q '^RESULT: FAIL' || fail "re-init into non-empty dir should FAIL"

# special characters survive substitution
SP="$OUT/special"
"$ROOT/plugin/scripts/init.sh" "$SP" --business "A & B's \"Boats\" | x" --setup-owner "O'Neil" --sponsor S \
  --github-owner g --repo-name r --shared-drive '\\nas\share' --time-zone Pacific/Auckland --no-git >/dev/null || fail "special-char init"
grep -qF "Business: A & B's \"Boats\" | x" "$SP/steadyship.md" || fail "special business"
grep -qF "Setup owner: O'Neil" "$SP/steadyship.md" || fail "special setup owner"
grep -q "^Time zone: Pacific/Auckland$" "$SP/steadyship.md" || fail "explicit --time-zone not written"
grep -qF 'Shared drive: \\nas\share' "$SP/steadyship.md" || fail "special shared drive"
grep -rqE '\{\{[A-Z_]+\}\}' "$SP" && fail "placeholders remain in special run" || true

# flag with no value must fail fast, not hang
TO=""; command -v timeout >/dev/null 2>&1 && TO=timeout || { command -v gtimeout >/dev/null 2>&1 && TO=gtimeout; }
if [ -n "$TO" ]; then
  set +e; "$TO" 5 "$ROOT/plugin/scripts/init.sh" "$OUT/hang" --business >/dev/null 2>&1; rc=$?; set -e
  [ "$rc" = "1" ] || fail "dangling flag should exit 1 (got $rc)"
else
  echo "-- dangling-flag check skipped (no timeout command)"
fi

# Windows-style target is rejected
set +e; "$ROOT/plugin/scripts/init.sh" 'C:\Users\x\repo' --business b --setup-owner s --sponsor p --github-owner g --repo-name r --shared-drive d --no-git >"$OUT/win.log" 2>&1; rc=$?; set -e
[ "$rc" = "1" ] && tail -1 "$OUT/win.log" | grep -q 'Windows-style paths' || fail "Windows-style path should FAIL"

# the generated repo's own spike scripts work on this machine
( cd "$DIR" && scripts/spikes/nas-rw.sh "$OUT" | tail -1 | grep -q '^RESULT: PASS' ) || fail "nas-rw in generated repo"
( cd "$DIR" && export HOME="$OUT/home" && mkdir -p "$HOME" && scripts/spikes/env.sh | tail -1 | grep -q '^RESULT: PASS' ) || fail "env.sh in generated repo"
# persistence: first run unknown; same home again -> yes; a fresh (wiped) home -> no
( cd "$DIR" && export HOME="$OUT/home" && scripts/spikes/env.sh | grep -q 'persistence yes' ) || fail "env.sh second run should report persistence yes"
( cd "$DIR" && export HOME="$OUT/home2" && mkdir -p "$HOME" && scripts/spikes/env.sh | grep -q 'persistence no' ) || fail "env.sh with a wiped home should report persistence no"
[ -f "$DIR/.steadyship/env-spike.ran" ] || fail "env.sh should leave a repo-side marker"
# run from the parent folder (as the skill does with the one-level-down rule): marker still found in the repo
( cd "$OUT" && export HOME="$OUT/home3" && mkdir -p "$HOME" && bash "$DIR/scripts/spikes/env.sh" | grep -q 'persistence no' ) || fail "env.sh run from another folder should still find the repo marker"
( cd "$DIR" && git status --porcelain | grep -q 'env-spike.ran' ) && fail "repo-side marker should be git-ignored"
# a tool whose --version fails (Windows' Store placeholder python3) must count as missing, not ok
FAKE="$OUT/fakebin"; mkdir -p "$FAKE"; printf '#!/bin/sh\necho "Python was not found; run without arguments to install from the Microsoft Store"; exit 9009\n' > "$FAKE/python3"; chmod +x "$FAKE/python3"
( cd "$DIR" && export HOME="$OUT/home4" && mkdir -p "$HOME" && PATH="$FAKE:$PATH" scripts/spikes/env.sh | grep '^missing: python3 (a shortcut exists' >/dev/null ) || fail "env.sh should treat a non-running python3 shortcut as missing"
# the combined check: shared drive given, no app yet -> environment PASS, shared-drive PASS, tests SKIP, rows recorded
( cd "$DIR" && export HOME="$OUT/home5" && mkdir -p "$HOME" && scripts/check.sh --shared-drive "$OUT" > "$OUT/check.log" 2>&1 ) || { cat "$OUT/check.log"; fail "check.sh should PASS with a visible shared drive and no app"; }
tail -1 "$OUT/check.log" | grep -q '^RESULT: PASS$' || fail "check.sh last line should be RESULT: PASS"
grep -q '^| environment | PASS | [0-9-]* | ' "$DIR/docs/spikes/RESULTS.md" || fail "check.sh should record the environment row"
grep -q '^| shared-drive | PASS | [0-9-]* | read, write and delete ok' "$DIR/docs/spikes/RESULTS.md" || fail "check.sh should record the shared-drive row"
grep -q '^| tests | SKIP | [0-9-]* | no app in apps/ yet' "$DIR/docs/spikes/RESULTS.md" || fail "check.sh should record tests as SKIP without an app"
[ "$(grep -c '^| environment |' "$DIR/docs/spikes/RESULTS.md")" = 1 ] || fail "check.sh must replace the row, not add one"
grep -q '^| github | | | |' "$DIR/docs/spikes/RESULTS.md" || fail "check.sh must leave the other rows alone"
# the recorded Windows-style drive is reported as not visible here, and that is a FAIL, not a crash
( cd "$DIR" && export HOME="$OUT/home5" && scripts/check.sh --no-record > "$OUT/check2.log" 2>&1 ) || true; tail -1 "$OUT/check2.log" | grep -q '^RESULT: FAIL shared-drive$' || { cat "$OUT/check2.log"; fail "check.sh with an invisible drive should FAIL shared-drive only"; }
grep -q '^| shared-drive | PASS |' "$DIR/docs/spikes/RESULTS.md" || fail "--no-record must not touch RESULTS.md"
# spike a without a GitHub link is SKIP (not set up), never FAIL
( cd "$DIR" && { scripts/spikes/git-push.sh || true; } | tail -1 | grep -q '^RESULT: SKIP' ) || fail "git-push without a remote should SKIP"
git init -q --bare "$OUT/bare.git"
( cd "$DIR" && git remote add origin "$OUT/bare.git" && scripts/spikes/git-push.sh | tail -1 | grep -q '^RESULT: PASS' ) || fail "git-push in generated repo"

if [ "${STEADYSHIP_TEST_SMOKE:-0}" = "1" ]; then
  echo "-- generated repo smoke: running (npm ci + scripts/validate.sh)"
  ( cd "$DIR" && npm ci --no-audit --no-fund >/dev/null && scripts/validate.sh > "$OUT/validate.log" 2>&1 && tail -1 "$OUT/validate.log" | grep -q '^OK$' ) || { tail -25 "$OUT/validate.log"; fail "generated validate.sh"; }
  ( cd "$DIR" && export HOME="$OUT/home5" && scripts/check.sh --shared-drive "$OUT" --app _sample | tail -1 | grep -q '^RESULT: PASS$' ) || fail "check.sh with the sample app"
  grep -q '^| tests | PASS | [0-9-]* | _sample opened without errors' "$DIR/docs/spikes/RESULTS.md" || fail "check.sh should record the tests row"
  echo "-- generated repo smoke: PASS"
  "$ROOT/plugin/demo/populate.sh" "$DIR" "$OUT/share" | tail -1 | grep -q '^RESULT: PASS' || fail "fixture populate"
  ( cd "$DIR" && scripts/validate.sh | tail -1 | grep -q '^OK$' ) || fail "fixture apps smoke"
  echo "-- fixture apps smoke: PASS"
else
  echo "-- generated repo smoke: skipped (set STEADYSHIP_TEST_SMOKE=1)"
fi
echo "test-init: OK"
