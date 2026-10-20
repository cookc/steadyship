# Quick start: Mac or Linux, Claude Code in a terminal

For a Mac or Linux computer using Claude Code from a terminal. About ten
minutes. The first two steps are done once per computer.

## 1 and 2. Get the computer ready and add the plugin

One line does both. It checks for Git and Node.js, tells you what to do if
either is missing, and installs the plugin into Claude Code. Safe to run
again.

```sh
curl -fsSL https://raw.githubusercontent.com/cookc/steadyship/main/scripts/setup.sh | bash
```

Read what it printed. Anything marked `to do` is for you; `RESULT: READY`
means you are done here. If Claude Code itself is missing, install it from
https://claude.ai/code, sign in once with `claude`, and run the line again.

By hand, the same thing is:

```sh
claude plugin marketplace add cookc/steadyship
claude plugin install steadyship@steadyship
```

## 3. Set it up for your business

1. Make a new, empty folder, open a terminal in it, and run `claude`.
2. Say **Set up Steadyship for <your business>** and answer the questions:
   the business name, who holds the accounts, who decides what the business
   relies on, and where the shared spreadsheets live. Creating a private
   GitHub repository is an optional last step; it only happens if you say
   yes.
3. Copy your apps into the new folder's `apps/`, one folder per app.
4. Then say these, one at a time, waiting for each to finish:
   1. **Run steadyship status**
   2. **run spike 0**
   3. **run spike b**
   4. **run spike c, the app is <one of your apps>**
   5. **What apps do we have and where is the same information kept twice?**
   6. **review the <app>**
5. From then on, ask for changes the way you normally would. Steadyship asks
   one or two questions first (what the new thing attaches to, where its data
   should live, whether something you already have does it), records the
   answer, and then builds.

The spikes are short go/no-go checks of what this computer can really do:
reach GitHub, read the shared drive, run an app's tests. Each ends with a
plain `RESULT: PASS`, `FAIL` or `SKIP` line and Steadyship offers to record
it. The "what apps do we have" question is answered from the assessment
Steadyship writes into `docs/assessment/`, and the review gives a plain
Yes / No / Prototype verdict on whether an app is good enough for the team
to rely on.

## 4. Just looking? Try the demo business

No apps to hand yet? Demo Boatworks is a made-up boat builder with six apps
its staff built with Claude, and the spreadsheets they run on. In a new,
empty folder say **Try Steadyship with the demo business**, then the same
prompts as step 3 (use `job-board` as the app for spike c and the review).

Spike c needs Node.js; on Mac and Linux it says so rather than installing it
(https://nodejs.org).
