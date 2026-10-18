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
         tests/smoke/app.spec.ts scripts/validate.sh scripts/smoke.sh \
         scripts/spikes/git-push.sh scripts/spikes/nas-rw.sh apps/_sample/index.html \
         docs/assessment/README.md docs/assessment/TEMPLATE.md docs/assessment/SUMMARY.md \
         docs/assessment/_sample.md docs/spikes/README.md docs/spikes/RESULTS.md \
         docs/spikes/a-git.md docs/spikes/b-nas.md docs/spikes/c-tests.md docs/spikes/d-hosting.md \
         docs/spikes/e-plugin.md docs/spikes/hosting/staticwebapp.config.json \
         docs/spikes/hosting/azure-static-web-apps.yml .github/workflows/validate.yml; do
  [ -f "$DIR/$f" ] || fail "missing $f"
done
for s in scripts/validate.sh scripts/smoke.sh scripts/spikes/git-push.sh scripts/spikes/nas-rw.sh; do
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
grep -q 'Setup owner:\*\* Sam Setup' "$DIR/docs/assessment/README.md" || fail "README role line"
for f in .gitignore .gitattributes .github/workflows/validate.yml; do [ -f "$DIR/$f" ] || fail "missing $f"; done
[ -f "$DIR/.steadyship/manifest" ] || fail "manifest missing"
grep -qE '^[0-9a-f]{64}  steadyship\.md$' "$DIR/.steadyship/manifest" || fail "manifest lacks steadyship.md"
git -C "$DIR" ls-files --error-unmatch .steadyship/manifest >/dev/null || fail "manifest not committed"
[ "$(git -C "$DIR" rev-list --count HEAD)" = "1" ] || fail "expected exactly one commit"
[ "$(git -C "$DIR" branch --show-current)" = "main" ] || fail "branch is not main"
[ -z "$(git -C "$DIR" status --short)" ] || fail "tree not clean after init"
git -C "$DIR" ls-files --eol scripts | grep -q 'w/crlf' && fail "CRLF in scripts" || true

# second run into a non-empty dir must refuse
set +e; "$ROOT/plugin/scripts/init.sh" "$DIR" --business x --setup-owner x --sponsor x --github-owner x --repo-name x --shared-drive x >"$OUT/again.log" 2>&1; rc=$?; set -e
[ "$rc" = "1" ] && tail -1 "$OUT/again.log" | grep -q '^RESULT: FAIL' || fail "re-init into non-empty dir should FAIL"

# special characters survive substitution
SP="$OUT/special"
"$ROOT/plugin/scripts/init.sh" "$SP" --business "A & B's \"Boats\" | x" --setup-owner "O'Neil" --sponsor S \
  --github-owner g --repo-name r --shared-drive '\\nas\share' --no-git >/dev/null || fail "special-char init"
grep -qF "Business: A & B's \"Boats\" | x" "$SP/steadyship.md" || fail "special business"
grep -qF "Setup owner: O'Neil" "$SP/steadyship.md" || fail "special setup owner"
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
git init -q --bare "$OUT/bare.git"
( cd "$DIR" && git remote add origin "$OUT/bare.git" && scripts/spikes/git-push.sh | tail -1 | grep -q '^RESULT: PASS' ) || fail "git-push in generated repo"

if [ "${STEADYSHIP_TEST_SMOKE:-0}" = "1" ]; then
  echo "-- generated repo smoke: running (npm ci + scripts/validate.sh)"
  ( cd "$DIR" && npm ci --no-audit --no-fund >/dev/null && scripts/validate.sh | tail -1 | grep -q '^OK$' ) || fail "generated validate.sh"
  echo "-- generated repo smoke: PASS"
else
  echo "-- generated repo smoke: skipped (set STEADYSHIP_TEST_SMOKE=1)"
fi
echo "test-init: OK"
