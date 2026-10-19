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
if printf '%s' "$TARGET" | grep -Eq '^[A-Za-z]:[\\/]'; then
  # Git Bash on Windows (MSYS) can translate C:\... itself; elsewhere a Windows path means the wrong environment.
  if command -v cygpath >/dev/null 2>&1; then
    TARGET="$(cygpath -u "$TARGET")"
  else
    fail "Windows-style paths cannot be used here — give the folder as this environment sees it (ask Claude to run pwd)"
  fi
fi
BUSINESS=""; SETUP_OWNER=""; SPONSOR=""; GITHUB_OWNER=""; REPO_NAME=""; SHARED_DRIVE=""; DO_GIT=1
need() { [ $# -ge 2 ] || fail "$1 needs a value"; case "$2" in --*) fail "$1 needs a value (got $2)";; esac; }
while [ $# -gt 0 ]; do
  case "$1" in
    --business) need "$@"; BUSINESS="$2"; shift 2;;
    --setup-owner) need "$@"; SETUP_OWNER="$2"; shift 2;;
    --sponsor) need "$@"; SPONSOR="$2"; shift 2;;
    --github-owner) need "$@"; GITHUB_OWNER="$2"; shift 2;;
    --repo-name) need "$@"; REPO_NAME="$2"; shift 2;;
    --shared-drive) need "$@"; SHARED_DRIVE="$2"; shift 2;;
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
for req in .gitignore .gitattributes .github/workflows/validate.yml; do
  [ -f "$TEMPLATES/$req" ] || fail "template is incomplete (missing $req) — reinstall the Steadyship plugin"
done

# Build in a staging folder outside the target, then copy in at the end: the
# target may be a folder attached to Claude desktop, where creating files is
# allowed but deleting (sed backups, git lock files) needs a separate
# permission, and a half-built repository must never be left behind.
STAGE="$(mktemp -d)" || fail "could not create a temporary folder"
trap 'rm -rf "$STAGE"' EXIT
FINAL="$TARGET"; TARGET="$STAGE/repo"; mkdir -p "$TARGET"

echo "Copying templates (version $VERSION) ..."
( cd "$TEMPLATES" && tar cf - --exclude=node_modules --exclude=.git . ) | ( cd "$TARGET" && tar xf - ) || fail "copy failed"

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
    # -i.suffix + rm works on both GNU and BSD (macOS) sed
    sed -i.steadyship-bak "s|${s%%|*}|${s#*|}|g" "$f" && rm -f "$f.steadyship-bak" || fail "substitution failed in $f"
  done
done < <(find "$TARGET" -type f ! -path "$TARGET/.git/*" -print0)

# Only our own {{UPPER_CASE}} placeholders count; GitHub Actions "${{ secrets.X }}" is legitimate.
if grep -rnE '\{\{[A-Z_]+\}\}' "$TARGET" --exclude-dir=.git >/dev/null 2>&1; then
  grep -rnE '\{\{[A-Z_]+\}\}' "$TARGET" --exclude-dir=.git | head -5
  fail "unfilled placeholders remain (listed above)"
fi
find "$TARGET" -name '*.sh' -exec chmod +x {} +

# Manifest of what the templates generated (for future upgrades).
if command -v sha256sum >/dev/null 2>&1; then SHA="sha256sum"; else SHA="shasum -a 256"; fi
mkdir -p "$TARGET/.steadyship" || fail "could not create .steadyship"
( cd "$TARGET" && find . -type f ! -path './.steadyship/*' ! -path './.git/*' -print | sed 's|^\./||' | LC_ALL=C sort \
    | while IFS= read -r f; do $SHA "$f"; done > .steadyship/manifest ) || fail "could not write manifest"

if [ "$DO_GIT" = "1" ]; then
  echo "Creating the first commit ..."
  ( cd "$TARGET" \
    && git init -q -b main \
    && git add -A \
    && git -c user.name="Steadyship" -c user.email="steadyship@example.invalid" \
         commit -q -m "chore: initialise Steadyship repository (template v$VERSION)" ) \
    || fail "git initialisation failed"
fi

echo "Placing the repository in $FINAL ..."
mkdir -p "$FINAL" || fail "could not create $FINAL"
FINAL="$(cd "$FINAL" && pwd)"
( cd "$TARGET" && tar cf - . ) | ( cd "$FINAL" && tar xf - ) || fail "could not write into $FINAL"
[ -f "$FINAL/steadyship.md" ] || fail "copy into $FINAL is incomplete"
echo "Done. Next: open docs/spikes/README.md in $FINAL."
echo "RESULT: PASS created $FINAL"
