#!/usr/bin/env bash
# Usage: scripts/demo-regenerate.sh [<target-dir>] [--replace] [--push]
# Rebuilds the Demo Boatworks demo customer repo: init.sh, then the fixture, then one commit.
# Default target: ~/steadyship-demo. It must not exist (or be empty) unless --replace is given.
# Pushing happens ONLY with --push (force push to origin main). Last line: RESULT: PASS|FAIL.
set -uo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
fail() { echo "RESULT: FAIL $*"; exit 1; }
TARGET=""; REPLACE=0; PUSH=0
for a in "$@"; do
  case "$a" in
    --replace) REPLACE=1;;
    --push) PUSH=1;;
    --*) fail "unknown option: $a";;
    *) [ -z "$TARGET" ] || fail "more than one target directory given"; TARGET="$a";;
  esac
done
[ -n "$TARGET" ] || TARGET="$HOME/steadyship-demo"
FX="$ROOT/plugin/demo"
[ -f "$FX/init.env" ] || fail "fixture not found at $FX"
# shellcheck disable=SC1091
. "$FX/init.env"
# The maintainers' demo repo lives under their own GitHub account and setup owner.
SETUP_OWNER="${SETUP_OWNER_OVERRIDE:-$SETUP_OWNER}"
GITHUB_OWNER="${GITHUB_OWNER_OVERRIDE:-cookc}"
REPO_NAME="${REPO_NAME_OVERRIDE:-steadyship-demo}"

if [ -e "$TARGET" ] && [ -n "$(ls -A "$TARGET" 2>/dev/null)" ]; then
  [ "$REPLACE" = "1" ] || fail "target exists and is not empty: $TARGET (use --replace to remove it first)"
  case "$(cd "$TARGET" && pwd)" in
    /|"$HOME"|"$ROOT"|"$ROOT"/*) fail "refusing to remove $TARGET";;
  esac
  echo "Removing existing $TARGET ..."
  rm -rf "$TARGET" || fail "could not remove $TARGET"
fi

"$ROOT/plugin/scripts/init.sh" "$TARGET" --business "$BUSINESS" --setup-owner "$SETUP_OWNER" \
  --sponsor "$SPONSOR" --github-owner "$GITHUB_OWNER" --repo-name "$REPO_NAME" \
  --shared-drive "$SHARED_DRIVE_LINUX" || fail "init.sh failed (see above)"
mkdir -p "$SHARED_DRIVE_LINUX" || fail "could not create $SHARED_DRIVE_LINUX"
"$FX/populate.sh" "$TARGET" "$SHARED_DRIVE_LINUX" || fail "populate.sh failed (see above)"

( cd "$TARGET" && git add -A \
  && git -c user.name="Steadyship" -c user.email="steadyship@example.invalid" \
       commit -q -m "chore: add Demo Boatworks apps, business docs (fixture v$FIXTURE_VERSION)" ) \
  || fail "could not commit in $TARGET"

if [ "$PUSH" = "1" ]; then
  echo "WARNING: --push given. Force-pushing main to git@github.com:${GITHUB_OWNER}/${REPO_NAME}.git, replacing its history."
  git -C "$TARGET" remote add origin "git@github.com:${GITHUB_OWNER}/${REPO_NAME}.git" || fail "could not add remote"
  git -C "$TARGET" push --force -u origin main || fail "push failed"
else
  echo "Not pushing (no --push). Target: $TARGET"
fi
echo "RESULT: PASS demo repo at $TARGET (shared files in $SHARED_DRIVE_LINUX)"
