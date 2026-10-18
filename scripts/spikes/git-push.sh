#!/usr/bin/env bash
# Spike (a): can this session commit and push to the shared private repo?
# No args. Pushes a marker commit to a throwaway branch and deletes it.
set -uo pipefail
cd "$(dirname "$0")/../.."
git rev-parse --is-inside-work-tree >/dev/null 2>&1 || { echo "RESULT: FAIL not inside a git repository"; exit 1; }
REMOTE="$(git remote get-url origin 2>/dev/null)" || { echo "RESULT: FAIL no 'origin' remote configured"; exit 1; }
echo "Remote: $REMOTE"
if [ -z "$(git config user.email)" ]; then
  git config user.email "steadyship-spike@example.invalid"; git config user.name "Steadyship spike"
fi
BR="spike/git-$(date +%Y%m%d-%H%M%S)"
echo "Checking we can read the remote ..."
git ls-remote --heads origin >/dev/null 2>&1 || { echo "RESULT: FAIL cannot read the remote (no credentials or no network)"; exit 1; }
echo "Creating a throwaway branch $BR with one marker commit ..."
START="$(git rev-parse --abbrev-ref HEAD)"
git checkout -q -b "$BR" || { echo "RESULT: FAIL could not create a branch"; exit 1; }
echo "$(date -Iseconds)" > docs/spikes/.git-spike-marker
git add docs/spikes/.git-spike-marker && git commit -q -m "spike: git push marker" || { git checkout -q "$START"; echo "RESULT: FAIL could not commit"; exit 1; }
echo "Pushing ..."
if git push -q -u origin "$BR" 2>/tmp/push.err; then
  echo "Push worked. Cleaning up ..."
  git push -q origin --delete "$BR" 2>/dev/null || echo "  (could not delete remote branch $BR — delete it on GitHub later)"
  git checkout -q "$START" && git branch -q -D "$BR"
  echo "RESULT: PASS"
else
  git checkout -q "$START" && git branch -q -D "$BR"
  echo "Push failed:"; head -3 /tmp/push.err | sed 's/^/  /'
  echo "RESULT: FAIL could not push (credentials or network)"
  exit 1
fi
