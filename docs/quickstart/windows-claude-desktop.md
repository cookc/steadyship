# Quick start: Windows, Claude desktop

For a Windows PC with the Claude desktop app, working on files on this
computer. About ten minutes. The first two steps are done once per computer.

## 1. Get the computer ready

Claude needs Git on the computer before it can add a plugin. Node.js is
optional (the tests check uses it; Steadyship installs it when needed).

**The easy way:** one script installs Git and Node.js if they are missing,
checks for Claude desktop, and downloads a spare copy of the plugin. It
changes nothing else.

1. Open PowerShell: press Start, type `PowerShell`, press Enter.
2. Paste this line and press Enter. Say Yes if Windows asks for permission.

   ```powershell
   irm https://raw.githubusercontent.com/cookc/steadyship/main/scripts/setup-windows.ps1 | iex
   ```

3. Read what it printed. Anything marked `to do` is for you; `RESULT: READY`
   means you are done here.

**By hand:**

1. Open PowerShell.
2. Run `winget install --id Git.Git -e` and say Yes to the permission prompt.
3. Optional: run `winget install --id OpenJS.NodeJS.LTS -e`.

**Then:** if Claude desktop was already open, quit it fully (right-click its
icon by the clock, then Quit) and open it again. It only notices Git after a
restart.

## 2. Add the plugin to Claude

1. Click **Customize** in the left sidebar, then the **Plugins** tab.
2. Click **Add marketplace**, type `cookc/steadyship`, and add it.
3. Find **steadyship** in the list and click **Install**.

**If it fails** with "failed to update marketplace", "couldn't check for
updates", or the plugin stays on an old version: that is a known Claude
desktop problem, not your computer. Use the spare copy instead.

1. The zip is at `Downloads\steadyship-plugin.zip` if you ran the setup
   script. Otherwise download `steadyship-plugin.zip` from
   https://github.com/cookc/steadyship/releases/latest.
2. Customize, Plugins, **Add**, **Upload plugin**, and choose the zip.

## 3. Set it up for your business

1. Start a new chat and point it at a new, empty folder: use the folder
   chooser below the message box ("Choose…", then "Open folder…"), pick or
   create an empty folder, and allow it as trusted when asked.
2. Say **Set up Steadyship for <your business>** and answer the questions:
   the business name, who holds the accounts, who decides what the business
   relies on, and where the shared spreadsheets live. Creating a private
   GitHub repository is an optional last step; it only happens if you say
   yes.
3. Copy your apps into the new folder's `apps/`, one folder per app. File Explorer is fine for this.
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

The tests check installs Node.js and a test browser if they are missing.
No terminal needed beyond step 1.
