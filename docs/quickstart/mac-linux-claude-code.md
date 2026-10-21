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
   If you have notes on how the business works (a process guide, a
   glossary, who uses what), put them in `docs/context/business/` as `.md`
   files, or ask Steadyship to write them from your Word documents.
   Steadyship reads them before every assessment, review and change.
4. Say **Check this computer**. Three one-minute checks run in one go: can
   Claude reach GitHub from here, can it read and write the shared drive
   your apps depend on, can it open one of your apps in a test browser.
   Each ends in a plain `PASS`, `FAIL` or `SKIP`, and the results are
   written into the repository so nobody has to wonder again. A `FAIL` is
   good news arriving early: the thing that would have bitten you three
   months in, found before anything was built on top of it.
5. Say **What apps do we have and where is the same information kept
   twice?** Steadyship lists your apps by name and writes an assessment of
   each into `docs/assessment/`.
6. Say **Review the <app>**, using one of the app names from that list, for
   a plain Yes / No / Prototype verdict on whether the team can rely on it.
7. From then on, build whatever you like in `apps/`, the way you do today.
   While something is a prototype Steadyship stays out of the way: it builds
   what you ask and says one line, that when someone else is about to rely
   on it you should say **Promote the <app>**.
8. Before the first promotion, two short conversations: **Set up my data**
   and **Set up my security**. Ten minutes each, questions about the
   business and nothing technical, written into the folder. They are the
   two things that are expensive to change later, which is why they come
   before the code. They run on a stronger model, and say so.
9. **Promote the <app>** when other people are about to use it. Steadyship
   audits what you built, asks up to five questions about the business in
   one message, then works through to the end on its own: the same
   behaviour for the same inputs, data and settings in files on the drive,
   tests, an owner, and a note in plain words of what changed and why.
   For an app people already rely on, changes get the engineer's one or
   two questions first, and **finish** checks and lands a change you made
   yourself.

## 4. Just looking? Try the demo business

No apps to hand yet? Demo Boatworks is a made-up boat builder with six apps
its staff built with Claude, and the spreadsheets they run on. In a new,
empty folder say **Try Steadyship with the demo business**, then the same
prompts as step 3 from "Check this computer" on. Its app list includes
`job-board`, so **Review the job board** is a good first review.

The tests check needs Node.js; on Mac and Linux it says so rather than
installing it
(https://nodejs.org).
