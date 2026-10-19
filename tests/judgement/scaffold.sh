#!/usr/bin/env bash
# Scaffold for the judgement cases. run.sh copies it into each staged case as
# scaffold.sh, because the eval runner only runs scripts inside the case dir.
# `claude plugin eval --scaffold` runs it with cwd = the agent's empty working
# directory and HOME = the run's throwaway home.
# Builds the mock business's customer repo IN the cwd and its shared drive at
# ~/<business-name-in-lowercase-with-hyphens>-shared-drive, then commits so
# `git status` starts clean.
# Fixture: <case>/fixture/ if run.sh staged one there (the case has a FIXTURE file),
# else the plugin's own demo (Demo Boatworks). Business details come from the
# fixture's init.env. Never copies an answer key (run.sh stages fixtures without it;
# populate.sh copies apps/, business/, shared-drive/ only).
set -euo pipefail
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PLUGIN="$(cd "$HERE/../.." && pwd)"   # staged plugin root: <stage>/plugin/evals/<case>/scaffold.sh
FX="$PLUGIN/demo"
[ ! -d "$HERE/fixture" ] || FX="$HERE/fixture"
[ -f "$FX/init.env" ] && [ -x "$FX/populate.sh" ] || { echo "scaffold: no fixture at $FX" >&2; exit 1; }
# shellcheck disable=SC1091
. "$FX/init.env"
REPO="$PWD"
SLUG="$(printf '%s' "$BUSINESS" | tr '[:upper:] ' '[:lower:]-')"
SHARE="$HOME/$SLUG-shared-drive"
[ -z "$(ls -A "$REPO")" ] || { echo "scaffold: cwd $REPO is not empty" >&2; exit 1; }
"$PLUGIN/scripts/init.sh" "$REPO" --business "$BUSINESS" --setup-owner "$SETUP_OWNER" \
  --sponsor "$SPONSOR" --github-owner "$GITHUB_OWNER" --repo-name "$REPO_NAME" --shared-drive "$SHARE" >/dev/null \
  || { echo "scaffold: init.sh failed" >&2; exit 1; }
mkdir -p "$SHARE"
"$FX/populate.sh" "$REPO" "$SHARE" | tail -1 | grep -q '^RESULT: PASS' \
  || { echo "scaffold: populate.sh failed" >&2; exit 1; }
git add -A
git -c user.name="Steadyship" -c user.email="steadyship@example.invalid" \
  commit -q -m "chore: add $BUSINESS apps, business docs"
[ -f "$SHARE/Jobs.csv" ] && ls apps/*/index.html >/dev/null 2>&1 || { echo "scaffold: fixture missing" >&2; exit 1; }
