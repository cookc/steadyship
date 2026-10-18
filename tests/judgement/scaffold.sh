#!/usr/bin/env bash
# Scaffold for the judgement cases. run.sh copies it into each staged case as
# scaffold.sh, because the eval runner only runs scripts inside the case dir.
# `claude plugin eval --scaffold` runs it with cwd = the agent's empty working
# directory and HOME = the run's throwaway home.
# Builds the Demo Boatworks customer repo IN the cwd and its shared drive at
# ~/demo-boatworks-shared-drive, then commits so `git status` starts clean.
# Never copies tests/judgement/answer-key.md (populate.sh copies apps/, business/, shared-drive/ only).
set -euo pipefail
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PLUGIN="$(cd "$HERE/../.." && pwd)"   # staged plugin root: <stage>/plugin/evals/<case>/scaffold.sh
REPO="$PWD"
SHARE="$HOME/demo-boatworks-shared-drive"
[ -z "$(ls -A "$REPO")" ] || { echo "scaffold: cwd $REPO is not empty" >&2; exit 1; }
"$PLUGIN/scripts/init.sh" "$REPO" --business "Demo Boatworks" --setup-owner "Sam Setup" \
  --sponsor "Morgan Reid" --github-owner TBC --repo-name demo-boatworks --shared-drive "$SHARE" >/dev/null \
  || { echo "scaffold: init.sh failed" >&2; exit 1; }
mkdir -p "$SHARE"
"$PLUGIN/demo/populate.sh" "$REPO" "$SHARE" | tail -1 | grep -q '^RESULT: PASS' \
  || { echo "scaffold: populate.sh failed" >&2; exit 1; }
git add -A
git -c user.name="Steadyship" -c user.email="steadyship@example.invalid" \
  commit -q -m "chore: add Demo Boatworks apps, business docs"
[ -f apps/job-board/index.html ] && [ -f "$SHARE/Jobs.csv" ] || { echo "scaffold: fixture missing" >&2; exit 1; }
