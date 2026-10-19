#!/usr/bin/env bash
# Spike (a): can this session commit and push to the shared private repo?
# No args. Pushes a marker commit to a throwaway branch and deletes it.
# The repo is always put back on the branch (or commit) it started on.
set -uo pipefail
cd "$(dirname "$0")/../.."
git rev-parse --is-inside-work-tree >/dev/null 2>&1 || { echo "RESULT: FAIL not inside a git repository"; exit 1; }
REMOTE="$(git remote get-url origin 2>/dev/null)" || { echo "RESULT: SKIP no GitHub link yet — the one-time setup in docs/spikes/a-git.md has not been done (ask Claude to 'set up GitHub for this repository')"; exit 2; }
# Never print credentials that may be embedded in the URL.
echo "Remote: $(printf '%s' "$REMOTE" | sed -E 's#//[^/@]*@#//#')"
# Per-command identity only when none is configured (never persisted).
if [ -z "$(git config user.email)" ]; then
  GIT_ID=(-c user.name="Steadyship spike" -c user.email="steadyship-spike@example.invalid")
else
  GIT_ID=()
fi
BR="spike/git-$(date +%Y%m%d-%H%M%S)"
ERR="$(mktemp)" || { echo "RESULT: FAIL could not create a temporary file"; exit 1; }
START="$(git symbolic-ref -q --short HEAD || git rev-parse HEAD)"   # branch name, or the SHA if detached
BR_MADE=0

cleanup() {   # idempotent: back to where we started, throwaway branch deleted, temp file removed
  rm -f "$ERR"
  if [ "$BR_MADE" = 1 ]; then
    if [ "$(git symbolic-ref -q --short HEAD)" = "$BR" ]; then
      git checkout -q "$START" 2>/dev/null || echo "  WARNING: could not switch back to $START; run: git checkout $START && git branch -D $BR"
    fi
    if [ "$(git symbolic-ref -q --short HEAD)" != "$BR" ]; then
      git branch -q -D "$BR" 2>/dev/null; BR_MADE=0
    fi
  fi
}
trap cleanup EXIT
fail() { cleanup; echo "RESULT: FAIL $1"; exit 1; }

echo "Checking we can read the remote ..."
git ls-remote --heads origin >/dev/null 2>&1 || fail "cannot read the remote (no credentials or no network)"
git diff --cached --quiet || fail "you have changes staged — ask {{SETUP_OWNER}} before running this spike"
echo "Creating a throwaway branch $BR with one marker commit ..."
git checkout -q -b "$BR" || fail "could not create a branch"
BR_MADE=1
{ mkdir -p docs/spikes && date -u +%Y-%m-%dT%H:%M:%SZ > docs/spikes/.git-spike-marker; } 2>/dev/null || fail "could not write the marker file"
git add docs/spikes/.git-spike-marker && git ${GIT_ID[@]+"${GIT_ID[@]}"} commit -q -m "spike: git push marker" -- docs/spikes/.git-spike-marker || fail "could not commit"
echo "Pushing ..."
if git push -q -u origin "$BR" 2>"$ERR"; then
  echo "Push worked. Cleaning up ..."
  git push -q origin --delete "$BR" 2>/dev/null || echo "  (could not delete remote branch $BR — delete it on GitHub later)"
  cleanup
  [ "$BR_MADE" = 0 ] || { echo "RESULT: FAIL pushed OK but could not clean up the local branch $BR"; exit 1; }
  echo "RESULT: PASS"
else
  echo "Push failed:"; head -3 "$ERR" | sed -E 's#//[^/@]*@#//#' | sed 's/^/  /'
  fail "could not push (credentials or network)"
fi
