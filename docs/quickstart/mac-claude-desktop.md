# Quick start: Mac, Claude desktop

For a Mac with the Claude desktop app. About ten minutes. On a Mac, Claude
desktop runs its tools in a separate Linux environment and shows your
attached folder inside it, so a few things differ from Windows; this page
says where. The first two steps are done once per computer.

Last checked on an earlier Steadyship version (19 Oct 2026); if something
on this page does not match what you see, say so.

## 1. Get the computer ready

Git is usually already on a Mac. If adding the plugin in step 2 complains
that git is required, open Terminal (Spotlight, type `Terminal`), run
`xcode-select --install`, accept the prompt, then quit and reopen Claude
desktop.

## 2. Add the plugin to Claude

1. Click **Customize** in the left sidebar, then the **Plugins** tab.
2. Click **Add marketplace**, type `cookc/steadyship`, and add it.
3. Find **steadyship** in the list and click **Install**.

**If it fails** with "failed to update marketplace", "couldn't check for
updates", or the plugin stays on an old version: that is a known Claude
desktop problem, not your computer. Download `steadyship-plugin.zip` from
https://github.com/cookc/steadyship/releases/latest, then Customize,
Plugins, **Add**, **Upload plugin**, and choose the zip.

## 3. Set it up for your business

1. Start a new chat and point it at a new, empty folder: use the folder
   chooser below the message box ("Choose…", then "Open folder…"), pick or
   create an empty folder, and allow it as trusted when asked.
2. Say **Set up Steadyship for <your business>** and answer the questions:
   the business name, who holds the accounts, who decides what the business
   relies on, and where the shared spreadsheets live. Creating a private
   GitHub repository is an optional last step; it only happens if you say
   yes.
3. Copy your apps into the new folder's `apps/`, one folder per app. Finder is fine for this.
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
7. From then on, ask for changes the way you normally would. Steadyship asks
   one or two questions first (what the new thing attaches to, where its data
   should live, whether something you already have does it), records the
   answer, and then builds.

## 4. Just looking? Try the demo business

No apps to hand yet? Demo Boatworks is a made-up boat builder with six apps
its staff built with Claude, and the spreadsheets they run on. In a new,
empty folder say **Try Steadyship with the demo business**, then the same
prompts as step 3 from "Check this computer" on. Its app list includes
`job-board`, so **Review the job board** is a good first review.

Two Mac-specific notes. The environment check may say persistence is
"unknown" the first time: run "Check this computer" again in a new chat to
get the answer. The tests check may FAIL because the test browser cannot be
downloaded in that environment; Steadyship records that and the tests run on
GitHub instead once the repository is there.
