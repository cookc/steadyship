# Field test plan

The first run of Steadyship with a real builder on their own computer, their
own apps and their own shared drive. The rehearsals (Mac, Linux, the Windows
VM) proved the mechanics; the field test answers the product question: does
having "an engineer in the conversation" change what a non-technical builder
asks for and builds?

This is the internal plan. The version written for the test user is
`docs/field-test-guide.md`; send them that a week before.

## Who, where, how long

- **Test user:** the design partner's setup owner, on their Windows computer,
  on the business's Team plan. They do the typing. We watch, we answer
  questions only when asked, and we write down every hesitation.
- **Sponsor:** named before the session (the owner or manager who decides
  what the business relies on). They need not attend, but the setup owner
  must be able to name them.
- **Where:** their office, at their desk, with the shared drive mapped the
  way they normally use it. A screen share is a fallback, not the plan: half
  the value is seeing the real machine.
- **Length:** 90 minutes, in three parts. Stop at 90 even if unfinished;
  what did not fit is a finding.

## Before the day (us)

1. Send `docs/field-test-guide.md`. It asks the test user for what we need:
   Windows version; whether Customize → Plugins is visible (Team plans can
   restrict plugins; if hidden, the org admin must allow them first); the
   drive letter or folder of the shared drive (mapped drive, OneDrive or
   SharePoint synced folder, or both); two apps and one change; the
   sponsor's name; a backup copy of their apps folder. It also offers the
   setup script (`scripts/setup-windows.ps1`), which installs Git and Node
   and downloads the fallback zip.
2. Build the fallback anyway: download `steadyship-plugin.zip` from the
   latest GitHub release (the `release` workflow attaches it on every
   `v*` tag) onto a USB stick, in case the marketplace install or update
   fails (a known Claude desktop defect, `docs/rehearsal-windows-vm.md`)
   and their download is blocked too.
3. Print the observation table (below).
4. A few days before, check they have answered the guide's questions and
   picked the two apps and the change; chase if not.

## Part A, the quick start as written, on their business (50 min)

The test user follows `docs/quickstart/windows-claude-desktop.md` steps 1 to
3, reading it themselves. We
do not type and do not pre-empt. Order:

1. Computer ready: the setup script if they did not run it already (or Git
   via winget by hand), then quit and reopen Claude desktop.
2. Add the plugin from the marketplace. If it fails, Upload plugin from the
   USB.
3. "Set up Steadyship for <business name>" in a new empty folder, with their
   real shared drive path and the sponsor's name. Decline GitHub for now
   (local only) unless they already have an account and want it.
4. Copy their two chosen apps into `apps/` (File Explorer, their hands).
5. "Check this computer". The shared-drive check against the real drive is
   the single most important result of the day: a mapped drive, a
   SharePoint-synced folder and OneDrive "files on demand" placeholders can
   each behave differently. The tests check on one of their apps tells us
   whether their code runs at all under a test browser.
6. "What apps do we have and where is the same information kept twice?"
   Then read the `docs/assessment/` files with them.
7. "Review <one of their apps>", using a name from the list the previous
   answer gave, for the Yes / No / Prototype verdict. Ask them
   to explain the verdict back in their own words.

What we are watching for: where they stop reading and start guessing; which
question from a skill they cannot answer; any permission prompt they do not
understand; whether the assessment and the verdict make sense to them.

The demo business is not part of the day. It is the fallback if Part A
cannot run on their machine for reasons outside the product (plugins hidden
on the Team plan and no admin to hand): run it on the setup owner's personal
account and note that the real-drive results are missing.

## Part B, the real change (20 min)

They ask for the change in their own words. The ask skill should ask one or
two questions and stop. We watch whether the questions make sense to them,
what they answer, what gets built, and whether they read the decision it
recorded.

## Part C, debrief (20 min)

Ask, and write the answers down verbatim:

1. What did it tell you that you did not know?
2. Was there a moment you did not understand what it was asking? Which?
3. Would you run "review" before giving an app to the team? Why or why not?
4. What was annoying?
5. If this disappeared tomorrow, what would you miss, if anything?

## Observation sheet

| Step | What happened | Minutes | Friction / quote |
|---|---|---|---|
| A1 computer ready | | | |
| A2 plugin | | | |
| A3 setup | | | |
| A4 copy apps | | | |
| A5 check: environment | | | |
| A5 check: shared drive (real) | | | |
| A5 check: tests (their app) | | | |
| A6 assessment | | | |
| A7 review | | | |
| B real change | | | |

Collect at the end: `docs/spikes/RESULTS.md`, `docs/assessment/`,
`docs/context/decisions.md` and `steadyship.md` from the business repository,
plus screenshots of any error. Verify the shared drive's files have the same
timestamps as before the session, except the ones the change was meant to
touch.

## Success criteria

- Every quick-start prompt completes on their own repository with no typing
  by us.
- The shared-drive check passes on the real drive, and nothing on it was
  altered.
- At least one skill answer changed what the test user decided to build or
  rely on, in their words.
- The test user can say who the sponsor is and what "prototype" means for
  their app after the review.

Anything short of this is not a failure of the test, it is the finding.

## Known risks and what we do

| Risk | What we do |
|---|---|
| Plugins hidden on the Team plan | Org admin enables plugins before the day; otherwise the demo on the setup owner's personal account, and note it |
| Marketplace install or update fails | Upload plugin from the USB zip |
| No winget, or antivirus blocks the Playwright browser | The tests check records FAIL with the CI fallback; carry on |
| Shared drive is a synced folder with placeholders | The shared-drive check tells us; record exactly what the drive is |
| Their app reads a file the assessment cannot find | Ask where it really lives; that is a finding about master files |
| Session overruns | Stop at 90 minutes; Part C always happens |

## After the day

Write `docs/field-test-findings-<date>.md` within 24 hours: the observation
table, the verbatim debrief, and a triage list of product fixes with the one
that would have saved the most minutes first.
