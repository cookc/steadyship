#!/usr/bin/env bash
# Builds dist/steadyship-plugin-<version>.zip for Claude desktop's "Upload plugin",
# containing exactly the files git tracks under plugin/. Usage: scripts/package-plugin.sh [out-dir]
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
OUT="${1:-$ROOT/dist}"; mkdir -p "$OUT"
VER="$(sed -n 's/.*"version": *"\([^"]*\)".*/\1/p' "$ROOT/plugin/.claude-plugin/plugin.json")"
ZIP="$OUT/steadyship-plugin-$VER.zip"; rm -f "$ZIP"
( cd "$ROOT/plugin" && git ls-files -z . | xargs -0 zip -q -X "$ZIP" )
# every tracked file must be in the archive (dotfiles included)
missing=0
while IFS= read -r f; do unzip -Z1 "$ZIP" | grep -qxF "$f" || { echo "missing from zip: $f"; missing=1; }; done < <(cd "$ROOT/plugin" && git ls-files .)
[ "$missing" = 0 ] || { echo "RESULT: FAIL zip is incomplete"; exit 1; }
echo "RESULT: PASS $ZIP ($(unzip -l "$ZIP" | tail -1 | awk '{print $2}') files)"
