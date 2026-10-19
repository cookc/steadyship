# Spike a — commit and push without a terminal

**Question:** can a local Claude session on the builder's machine push to the
private GitHub repo using credentials set up once, and do those credentials
survive a new session?

**Who:** {{SETUP_OWNER}} sets up once; builder runs. **Where:** builder's machine,
local session, `{{REPO_NAME}}` folder attached.

## One-time setup ({{SETUP_OWNER}}, ~15 min) — do NOT put the token in any file in the repo

1. GitHub → Settings → Developer settings → Fine-grained tokens → Generate:
   repository access = only `{{REPO_NAME}}`; permissions = Contents: Read and
   write; expiry 30 days. Copy it.
2. In a Claude session with the folder attached, paste the token into the
   chat once and ask Claude: "Run `git config credential.helper store`, then
   run `git credential approve` with the details below on stdin, then run
   `git ls-remote --heads origin`." Claude runs (its Bash tool has no
   terminal, so it cannot be prompted for a password):

   ```bash
   git config credential.helper store
   git credential approve <<'EOF'
   protocol=https
   host=github.com
   username=<the setup owner's GitHub username>
   password=<token>
   EOF
   git ls-remote --heads origin
   ```

   GitHub ignores the username for token authentication, but write the token
   owner's login here.

   The token now sits in the VM's `~/.git-credentials`, scoped to one repo
   and expiring in 30 days. **The token passes through the chat** and so
   sits in the transcript and tool logs. Tell Claude never to put it in a
   URL, a file or the remote (a token in the remote URL lands in
   `.git/config` on the builder's disk). Revoke the token after the spike;
   the 30-day expiry is only the backstop. V0 uses {{SETUP_OWNER}}'s token, not the
   builder's — a recorded V0 shortcut, to be replaced by per-builder sign-in later.
   **Alternative, if available (unverified):** {{SETUP_OWNER}} opens a terminal they
   control inside the VM and runs `git credential approve`, entering the
   same four lines, so the token never enters the conversation.
The last command should list branches; if it does, setup is done.

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

## If it cannot be attempted yet

`RESULT: SKIP no GitHub link yet` → the repository has no GitHub address;
the one-time setup above has not been done. Paste
`| a | SKIP | <date> | no GitHub link yet |` and ask {{SETUP_OWNER}} to do
the setup (or to tell Claude "set up GitHub for this repository"). Then
run the spike again. This is not a failure.

## If it fails

- "cannot read the remote" → token wrong or expired, or network to
  github.com blocked from the VM (note which: ask Claude to run
  `curl -sI https://github.com | head -1`).
- Passes first time, fails after a new session → VM home is not persistent.
  Record it. **Fallback:** the plugin asks for the token at the start of each
  session (worse), or commits land in the attached folder and {{SETUP_OWNER}} pushes
  from their machine weekly (acceptable for V0), or builders use Claude Code
  after a one-time `gh auth login`.
  **Meaning:** "no terminal ever" becomes "one setup session, then
  conversational."
