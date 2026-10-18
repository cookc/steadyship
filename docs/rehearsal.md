# Rehearsal — what can be tested where

The on-site spikes run on the partner's Windows machine. Most of them can
be rehearsed earlier. Tick what passes; anything that fails here will fail
there.

## On Linux, with Claude Code (no accounts needed)

- `scripts/validate.sh` and `STEADYSHIP_FULL=1 scripts/validate.sh` pass.
- `steadyship-init` generates a repo into an empty folder; `steadyship-status`
  in that folder reports 1 app and 5 spikes not run; in the product repo it
  says "not a Steadyship repository".
- In the generated repo: `run spike 0` → PASS, all tools ok;
  `run spike b` against a local folder → PASS;
  `run spike c` on `_sample` → PASS (first run installs Chromium);
  `scripts/spikes/git-push.sh` against a bare repo → PASS.

## On a Mac, with Claude desktop (closest to the partner's experience)

- Install Claude desktop; give the Claude GitHub App access to `cookc/steadyship` (it is private); install the plugin from the marketplace; confirm
  `run steadyship status` works in a local session with the demo repo
  folder attached (spike e, minus the Team-admin "installed by default" step).
- Run `steadyship-init` in Claude desktop with a folder attached: the repo must appear in that folder on the Mac; then exercise both the GitHub **yes** path (against a throwaway name) and the **decline** path, and the non-empty-folder retry.
- Confirm `${CLAUDE_PLUGIN_ROOT}` resolves in desktop (if not, the skill stops with 'not properly installed').
- `run spike 0` twice in Claude desktop local sessions (persistence answer;
  gh installability); then spike e (above), then:
- Spike a end to end against `steadyship-demo` with a 30-day fine-grained
  token, including the second-session re-run.
- Spike b against an SMB share mounted under `/Volumes/…` (macOS treats it as
  local) — both file tools and the script.
- Spike c in the desktop VM: does the Chromium download succeed inside the
  VM's network allowlist? This is the single most useful Mac check.
- Spike d: deploy `_sample` from `steadyship-demo` to Azure SWA Free and open
  it from a second Microsoft account.

## Only on the partner's Windows machine

- Git for Windows line endings (`.gitattributes` mitigates; still verify
  `git ls-files --eol scripts` shows `w/lf` after their clone).
- Mapped SMB drive visible from the VM shell (known open bug).
- Virtual Machine Platform enabled; MSIX desktop install.
- Team-plan "Installed by default" plugin sync to a second member.
- Azure sign-in with the partner's tenant and invited users.
