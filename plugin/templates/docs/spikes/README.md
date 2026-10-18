# Spikes — weeks 1–2 go/no-go

Six checks, run **on the partner's Windows machine, on their Claude Team
account, in a local (on-device) session**. Order matters: (0) first, then (e), so the
others can use the plugin; if (e) fails, every runbook also gives the plain
prompt to paste instead.

| Spike | Question | Runbook | Needs |
|---|---|---|---|
| 0 | What can this environment do (tools, network, does it remember files)? | `0-env.md` | Nothing |
| e | Does the plugin reach a second Team member without their action? | `e-plugin.md` | Team owner, 2 members |
| a | Can a session commit and push to the private repo, no terminal? | `a-git.md` | GitHub token (one-time, {{SETUP_OWNER}}) |
| b | Can a session read/write the real shared drive — from file tools *and* from a script? | `b-nas.md` | The mapped drive letter |
| c | Can a session run the smoke test on one real app and report plainly? | `c-tests.md` | One app in `apps/` |
| d | Can one app be served behind sign-in and opened by a second staff member? | `d-hosting.md` | Azure subscription (free), GitHub |

## Before any spike **[ON-SITE, {{SETUP_OWNER}}, ~1 hour]**

1. Confirm the Claude desktop app is the MSIX install and Windows has
   "Virtual Machine Platform" enabled (Settings → Optional features).
2. In Claude: Organization settings → Cowork → make sure local sessions are
   still allowed (the "Run Cowork in the cloud" toggle may be on, but it must
   not force cloud-only). Spikes a–c must run in a local session; if only
   cloud is offered, stop and tell {{SETUP_OWNER}}.
3. Clone the repo onto the machine into `C:\Users\<builder>\{{REPO_NAME}}`
   ({{SETUP_OWNER}} does this once; builders never do). Prefer cloning from inside a
   Claude session (Linux git in the VM). If cloning with Git for Windows,
   run `git config --global core.autocrlf false` first, or the spike
   scripts will fail with `$'\r': command not found`.
4. Attach that folder in Claude desktop via the folder picker.
5. Also map the NAS share to a drive letter (e.g. `{{SHARED_DRIVE}}`) if it isn't already,
   and attach it too.

## Recording

After each spike, paste the row the skill gives you into `RESULTS.md`.
Commit from the setup owner's machine if spike (a) hasn't passed yet.
