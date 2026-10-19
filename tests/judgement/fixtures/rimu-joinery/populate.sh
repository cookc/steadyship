#!/usr/bin/env bash
# Usage: populate.sh <customer-repo-dir> <shared-drive-dir>
# Copies the Rimu Joinery fixture into a generated customer repo and a shared-drive folder.
#   apps/*            -> <repo>/apps/<name>/            (unmodified)
#   business/*.md     -> <repo>/docs/context/business/
#   shared-drive/*    -> <shared-drive-dir>/
# Last line: RESULT: PASS or RESULT: FAIL <reason>.
set -uo pipefail
HERE="$(cd "$(dirname "$0")" && pwd)"
fail() { echo "RESULT: FAIL $*"; exit 1; }
REPO="${1:-}"; SHARE="${2:-}"
[ -n "$REPO" ] && [ -n "$SHARE" ] || fail "usage: populate.sh <customer-repo-dir> <shared-drive-dir>"
[ -d "$REPO/apps" ] || fail "$REPO does not look like a Steadyship repo (no apps/ folder)"
mkdir -p "$SHARE" || fail "could not create $SHARE"
n=0
for d in "$HERE"/apps/*/; do
  name="$(basename "$d")"
  mkdir -p "$REPO/apps/$name" && cp "$d"index.html "$REPO/apps/$name/index.html" || fail "could not copy app $name"
  echo "App:      apps/$name/index.html"
  n=$((n+1))
done
mkdir -p "$REPO/docs/context/business" || fail "could not create docs/context/business"
for f in "$HERE"/business/*.md; do
  cp "$f" "$REPO/docs/context/business/" || fail "could not copy $f"
  echo "Business: docs/context/business/$(basename "$f")"
done
( cd "$HERE/shared-drive" && tar cf - . ) | ( cd "$SHARE" && tar xf - ) || fail "could not copy shared-drive files"
( cd "$HERE/shared-drive" && find . -type f | sed 's|^\./|Shared:   |' | sort )
echo "Copied $n apps, business docs and shared-drive files into $REPO and $SHARE"
echo "RESULT: PASS"
