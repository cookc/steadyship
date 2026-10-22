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

<details>
<summary>Rather do it by hand?</summary>

```sh
claude plugin marketplace add cookc/steadyship
claude plugin install steadyship@steadyship
```

</details>

## 3. Set it up for your business

1. Make a new, empty folder, open a terminal in it, and run `claude`.
2. Say **Set up Steadyship for [your business]** and answer the questions:
   the business name, who holds the accounts, who decides what the business
   relies on, and where the shared spreadsheets live. Creating a private
   GitHub repository is an optional last step; it only happens if you say
   yes.
3. Copy your apps into the new folder's `apps/`, one folder per app.
   If you have notes on how the business works (a process guide, a
   glossary, who uses what), put them in `docs/context/business/` as `.md`
   files, or ask Steadyship to write them from your Word documents. It
   reads them before every assessment, review and change.
4. Say **Check this computer**. In about a minute it tells you whether it
   can get online, read your shared drive and open one of your apps, each
   a plain pass or fail, and writes the answers down so nobody has to
   wonder again. A fail here is good news: a problem found before anything
   was built on top of it.

## 4. Use it

The same handful of sentences on every setup. The app's name is its folder
in `apps/`, so if the folder is `job-board`, "the job board" is enough.

1. **What apps do we have and where is the same information kept twice?**
   Lists your apps by name, assesses each one into `docs/assessment/`, and
   shows where two apps keep the same thing.
2. **Review the [app name]**, for example **Review the job board**. A
   plain Yes, No or Not yet on whether the team can rely on it, with the
   evidence.
3. **Make the [app name] do [whatever you want]**, the way you ask Claude
   today. While an app is a prototype, Steadyship builds what you ask and
   adds one line: when someone else is about to rely on it, say promote.
4. **Set up my data**, then **Set up my security**, before the first
   promotion. Ten minutes each, questions about the business and nothing
   technical, written into the folder. They are the two things that are
   expensive to change later. They use a stronger model, and say so.
5. **Promote the [app name]** when other people are about to use it. It
   reads what you built, asks up to five questions about the business in
   one message, then works unattended: the same results as before, data and
   settings in files on the drive, tests, an owner, and a note in plain
   words of what changed and why.
6. For an app people already rely on, ask for changes as before. It asks
   the one or two questions an engineer would ask first, builds, and
   records why. If you changed something yourself, say **Finish the [app
   name]** to have it checked and landed.

## 5. Just looking? Try the demo business

No apps to hand yet? Demo Boatworks is a made-up boat builder with six apps
its staff built with Claude, and the spreadsheets they run on. In a new,
empty folder say **Try Steadyship with the demo business**, then **Check
this computer** and the sentences in step 4. Its app list includes
`job-board`, so **Review the job board** is a good first review.

The tests check needs Node.js; on Mac and Linux it says so rather than
installing it (https://nodejs.org).
