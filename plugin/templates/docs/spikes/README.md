# Spikes: the checks that come before anything is built

"Spike" is engineering slang for a short, throwaway experiment that answers
one question before you commit to anything. Each spike here answers one
question about *this* setup, on this computer, in about a minute, and ends
in one word: `PASS`, `FAIL` or `SKIP`. The result goes into `RESULTS.md`
so nobody has to wonder again. A `FAIL` is good news arriving early: it is
the problem that would have bitten the business three months in, found
before anything was built on top of it.

To run one, say "run spike 0" (or b, c, a, d, e) in a chat with this
repository open. Run 0 first; b and c next; a, d and e when the business
is ready for GitHub, hosting and a second team member. Each runbook below
also gives the plain prompt to paste if the Steadyship plugin is not
available.

| Spike | Question | Runbook | Needs |
|---|---|---|---|
| 0 | What can this environment do (tools, network, does it remember files)? | `0-env.md` | Nothing |
| b | Can a session read/write the real shared drive — from file tools *and* from a script? | `b-nas.md` | The mapped drive letter |
| c | Can a session run the smoke test on one real app and report plainly? | `c-tests.md` | One app in `apps/` |
| a | Can a session commit and push to the private repo, no terminal? | `a-git.md` | GitHub token (one-time, {{SETUP_OWNER}}) |
| d | Can one app be served behind sign-in and opened by a second staff member? | `d-hosting.md` | Azure subscription (free), GitHub |
| e | Does the plugin reach a second Team member without their action? | `e-plugin.md` | Team owner, 2 members |

## Before spike b

Make sure the shared drive is reachable from this computer the way staff
normally use it (for example mapped as `{{SHARED_DRIVE}}`). In Claude
desktop, work in "This computer" mode so the checks see the real drive.

## Recording

After each spike, paste the row the skill gives you into `RESULTS.md`.
Commit from the setup owner's machine if spike (a) hasn't passed yet.
