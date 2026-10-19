# Field test plan

The first run of Steadyship with a real builder on their own computer, their
own apps and their own shared drive. The rehearsals (Mac, Linux, the Windows
VM) proved the mechanics; the field test answers the product question: does
having "an engineer in the conversation" change what a non-technical builder
asks for and builds?

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
- **Length:** 90 minutes, in three parts of about 30. Stop at 90 even if
  unfinished; what did not fit is a finding.

## Before the day (us)

1. Confirm with the test user, by message: Windows version; whether Claude
   desktop is installed and up to date; whether Customize → Plugins is
   visible to them (Team plans can restrict plugins; if it is hidden, the org
   admin must allow plugins first); the drive letter or folder of the shared
   drive and whether it is a mapped drive, a OneDrive/SharePoint synced
   folder, or both; whether `winget` runs in PowerShell.
2. Build the fallback: `scripts/package-plugin.sh` and put the zip on a USB
   stick, in case the marketplace install or update fails (a known Claude
   desktop defect, `docs/rehearsal-windows-vm.md`).
3. Print the one-page sheet (below) and the observation table.
4. Ask them to pick, in advance: two of their real apps they are willing to
   copy into a test repository, and one change they actually want made to one
   of them.
5. Take a copy of their apps folder before the session (their job, our
   reminder), so nothing we do can lose work.

## Part A, the quick start as written (30 min)

The test user follows `README.md` from step 0, reading it themselves. We do
not type and do not pre-empt. Order:

0. Windows: Git for Windows via winget, then quit and reopen Claude desktop.
1. Add the plugin from the marketplace. If it fails, Upload plugin from the USB.
2. Choose an empty folder, say "Try Steadyship with the demo business".
3. "Run steadyship status", "run spike 0", "run spike b", "run spike c, the
   app is job-board", "What apps do we have and where is the same
   information kept twice?"

What we are watching for: where they stop reading and start guessing; which
question from a skill they cannot answer; any permission prompt they do not
understand; whether the assessment answer makes sense to them in their own
words (ask them to explain it back).

## Part B, their business (40 min)

1. "Set up Steadyship for <business name>" in a new empty folder, with their
   real shared drive path and the sponsor's name. Decline GitHub for now
   (local only) unless they already have an account and want it.
2. Copy their two chosen apps into `apps/` (File Explorer, their hands).
3. "run spike b" against the real shared drive. This is the single most
   important result of the day: a mapped drive, a SharePoint-synced folder
   and OneDrive "files on demand" placeholders can each behave differently.
4. "What apps do we have and where is the same information kept twice?"
   Then read the `docs/assessment/` files with them.
5. "Review <one of their apps>", the Yes / No / Prototype verdict.
6. The real change: they ask for it in their own words. The ask skill should
   ask one or two questions and stop. We watch whether the questions make
   sense to them, what they answer, and what gets built.

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
| A0 Git | | | |
| A1 plugin | | | |
| A2 demo | | | |
| A3 status | | | |
| A3 spike 0 | | | |
| A3 spike b | | | |
| A3 spike c | | | |
| A3 assessment | | | |
| B1 setup | | | |
| B3 spike b real drive | | | |
| B4 assessment | | | |
| B5 review | | | |
| B6 real change | | | |

Collect at the end: `docs/spikes/RESULTS.md`, `docs/assessment/`,
`docs/context/decisions.md` and `steadyship.md` from the business repository,
plus screenshots of any error. Verify the shared drive's files have the same
timestamps as before the session, except the ones the change was meant to
touch.

## Success criteria

- All six quick-start prompts complete with no typing by us.
- Spike b passes on the real shared drive, and nothing on it was altered.
- At least one skill answer changed what the test user decided to build or
  rely on, in their words.
- The test user can say who the sponsor is and what "prototype" means for
  their app after the review.

Anything short of this is not a failure of the test, it is the finding.

## Known risks and what we do

| Risk | What we do |
|---|---|
| Plugins hidden on the Team plan | Org admin enables plugins before the day; otherwise test on the setup owner's personal account and note it |
| Marketplace install or update fails | Upload plugin from the USB zip |
| No winget, or antivirus blocks the Playwright browser | Spike c records FAIL with the CI fallback; carry on |
| Shared drive is a synced folder with placeholders | Spike b tells us; record exactly what the drive is |
| Their app reads a file the assessment cannot find | Ask where it really lives; that is a finding about master files |
| Session overruns | Stop at 90 minutes; Part C always happens |

## After the day

Write `docs/field-test-findings-<date>.md` within 24 hours: the observation
table, the verbatim debrief, and a triage list of product fixes with the one
that would have saved the most minutes first.
