# Checks: what this setup can really do, before anything is built on it

Each check answers one question about *this* setup, on this computer, in
about a minute, and ends in one word: `PASS`, `FAIL` or `SKIP`. The result
goes into `RESULTS.md` so nobody has to wonder again. A `FAIL` is good news
arriving early: it is the problem that would have bitten the business three
months in, found before anything was built on top of it. (Engineers call a
short experiment like this a "spike", which is why this folder is named as
it is.)

**Say "Check this computer"** and the first three run together, with the
results recorded for you:

| Check | Question | Runbook | Needs |
|---|---|---|---|
| environment | What can this environment do (tools, network, does it remember files)? | `environment.md` | Nothing |
| shared-drive | Can Claude read and write the real shared drive, from file tools *and* from a script? | `shared-drive.md` | The drive reachable as staff normally use it |
| tests | Can Claude open one real app in a test browser and report plainly? | `tests.md` | One app in `apps/` |

The other three are one-time setup checks. Run each when the business is
ready for it, by saying **"check GitHub"**, **"check hosting"** or
**"check the team"**:

| Check | Question | Runbook | Needs |
|---|---|---|---|
| github | Can a session commit and push to the private repository, no terminal? | `github.md` | The repository on GitHub, a token (one-time, {{SETUP_OWNER}}) |
| hosting | Can one app be served behind sign-in and opened by a second staff member? | `hosting.md` | Azure subscription (free), GitHub |
| team | Does the plugin reach a second Team member without their action? | `team.md` | Team owner, 2 members |

Each runbook also gives the plain prompt to paste if the Steadyship plugin
is not available.

## Before the shared drive check

Make sure the shared drive is reachable from this computer the way staff
normally use it (for example mapped as `{{SHARED_DRIVE}}`). In Claude
desktop, work in "This computer" mode so the check sees the real drive.

## Recording

"Check this computer" writes its three rows into `RESULTS.md` itself. For
the other checks, Claude gives the row and records it.
