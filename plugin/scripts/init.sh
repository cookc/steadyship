#!/usr/bin/env bash
# Steadyship scaffolder: creates a self-contained customer repository from plugin/templates.
# Usage: init.sh <target-dir> --business NAME --setup-owner NAME --sponsor NAME \
#        --github-owner OWNER --repo-name NAME --shared-drive PATH [--no-git]
# Last line: "RESULT: PASS created <dir>" or "RESULT: FAIL <reason>". Never touches GitHub.
set -uo pipefail
HERE="$(cd "$(dirname "$0")" && pwd)"
TEMPLATES="$HERE/../templates"
MANIFEST="$HERE/../.claude-plugin/plugin.json"
fail() { echo "RESULT: FAIL $*"; exit 1; }

TARGET="${1:-}"; shift || true
[ -n "$TARGET" ] || fail "no target directory given"
BUSINESS=""; SETUP_OWNER=""; SPONSOR=""; GITHUB_OWNER=""; REPO_NAME=""; SHARED_DRIVE=""; DO_GIT=1
while [ $# -gt 0 ]; do
  case "$1" in
    --business) BUSINESS="${2:-}"; shift 2;;
    --setup-owner) SETUP_OWNER="${2:-}"; shift 2;;
    --sponsor) SPONSOR="${2:-}"; shift 2;;
    --github-owner) GITHUB_OWNER="${2:-}"; shift 2;;
    --repo-name) REPO_NAME="${2:-}"; shift 2;;
    --shared-drive) SHARED_DRIVE="${2:-}"; shift 2;;
    --no-git) DO_GIT=0; shift;;
    *) fail "unknown option: $1";;
  esac
done
for v in BUSINESS SETUP_OWNER SPONSOR GITHUB_OWNER REPO_NAME SHARED_DRIVE; do
  [ -n "${!v}" ] || fail "missing --$(echo "$v" | tr '_' '-' | tr '[:upper:]' '[:lower:]')"
done
[ -d "$TEMPLATES" ] || fail "templates not found at $TEMPLATES"
VERSION="$(sed -n 's/.*"version": *"\([^"]*\)".*/\1/p' "$MANIFEST")"
[ -n "$VERSION" ] || fail "could not read plugin version from $MANIFEST"
MARKETPLACE="$(sed -n 's#.*"repository": *"https://github.com/\([^"]*\)".*#\1#p' "$MANIFEST")"
[ -n "$MARKETPLACE" ] || fail "could not read plugin repository (marketplace) from $MANIFEST"

if [ -e "$TARGET" ] && [ -n "$(ls -A "$TARGET" 2>/dev/null)" ]; then
  fail "target directory exists and is not empty: $TARGET"
fi
mkdir -p "$TARGET" || fail "could not create $TARGET"
TARGET="$(cd "$TARGET" && pwd)"

echo "Copying templates (version $VERSION) into $TARGET ..."
( cd "$TEMPLATES" && tar cf - . ) | ( cd "$TARGET" && tar xf - ) || fail "copy failed"

# Substitute placeholders. Values are escaped for sed's replacement side (\, &, |).
esc() { printf '%s' "$1" | sed -e 's/[\\&|]/\\&/g'; }
SUBS=(
  "{{BUSINESS_NAME}}|$(esc "$BUSINESS")"
  "{{SETUP_OWNER}}|$(esc "$SETUP_OWNER")"
  "{{SPONSOR}}|$(esc "$SPONSOR")"
  "{{GITHUB_OWNER}}|$(esc "$GITHUB_OWNER")"
  "{{REPO_NAME}}|$(esc "$REPO_NAME")"
  "{{SHARED_DRIVE}}|$(esc "$SHARED_DRIVE")"
  "{{TEMPLATE_VERSION}}|$(esc "$VERSION")"
  "{{PLUGIN_MARKETPLACE}}|$(esc "$MARKETPLACE")"
)
echo "Filling in business details ..."
while IFS= read -r -d '' f; do
  for s in "${SUBS[@]}"; do
    sed -i "s|${s%%|*}|${s#*|}|g" "$f" || fail "substitution failed in $f"
  done
done < <(find "$TARGET" -type f ! -path "$TARGET/.git/*" -print0)

# Only our own {{UPPER_CASE}} placeholders count; GitHub Actions "${{ secrets.X }}" is legitimate.
if grep -rnE '\{\{[A-Z_]+\}\}' "$TARGET" --exclude-dir=.git >/dev/null 2>&1; then
  grep -rnE '\{\{[A-Z_]+\}\}' "$TARGET" --exclude-dir=.git | head -5
  fail "unfilled placeholders remain (listed above)"
fi
find "$TARGET" -name '*.sh' -exec chmod +x {} +

if [ "$DO_GIT" = "1" ]; then
  echo "Creating the first commit ..."
  ( cd "$TARGET" \
    && git init -q -b main \
    && git add -A \
    && git -c user.name="Steadyship" -c user.email="steadyship@example.invalid" \
         commit -q -m "chore: initialise Steadyship repository (template v$VERSION)" ) \
    || fail "git initialisation failed"
fi
echo "Done. Next: open docs/spikes/README.md in $TARGET."
echo "RESULT: PASS created $TARGET"
