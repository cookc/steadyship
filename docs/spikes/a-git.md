# Spike a — commit and push without a terminal

**Question:** can a local Claude session on the builder's machine push to the
private GitHub repo using credentials set up once, and do those credentials
survive a new session?

**Who:** Chris sets up once; builder runs. **Where:** builder's machine,
local session, `steadyship` folder attached.

## One-time setup (Chris, ~15 min) — do NOT put the token in any file in the repo

1. GitHub → Settings → Developer settings → Fine-grained tokens → Generate:
   repository access = only `steadyship`; permissions = Contents: Read and
   write; expiry 30 days. Copy it.
2. In a Claude session with the folder attached, ask Claude:
   "Set the git remote to https://github.com/<owner>/steadyship.git and
   configure `git config credential.helper store`. Then run
   `git ls-remote origin` and when it asks for a password I'll give you the
   token." Give the token when prompted. (The token now sits in the VM's
   `~/.git-credentials`. It is scoped to one repo and expires in 30 days.)
3. Ask: "Run `git ls-remote --heads origin`" — expected: a list of branches.

## Builder runs

Type: `run spike a` (or, without the plugin: "Run `bash
scripts/spikes/git-push.sh` and tell me in plain language if it passed.")

## What Claude does

Runs `scripts/spikes/git-push.sh`: creates a throwaway branch, one marker
commit, pushes it, deletes it. Last line `RESULT: PASS` or `RESULT: FAIL`.

## Pass

`RESULT: PASS`. **Then close the session, open a new one, and run it
again.** Both must pass — the second proves credentials persist.
Paste: `| a | PASS | <date> | persisted across sessions: yes/no |`

## If it fails

- "cannot read the remote" → token wrong or expired, or network to
  github.com blocked from the VM (note which: ask Claude to run
  `curl -sI https://github.com | head -1`).
- Passes first time, fails after a new session → VM home is not persistent.
  Record it. **Fallback:** the plugin asks for the token at the start of each
  session (worse), or commits land in the attached folder and Chris pushes
  from his machine weekly (acceptable for V0), or builders use Claude Code
  after a one-time `gh auth login` (proposal §11 fallback).
  **Meaning:** "no terminal ever" becomes "one setup session, then
  conversational."
