# Quick start: Mac, Claude desktop

For a Mac with the Claude desktop app. About ten minutes. On a Mac, Claude
desktop runs its tools in a separate Linux environment and shows your
attached folder inside it, so a few things differ from Windows; this page
says where. The first two steps are done once per computer.

Last checked on an earlier Steadyship version (19 Oct 2026); if something
on this page does not match what you see, say so.

## 1. Get the computer ready

Git is usually already on a Mac, so there is normally nothing to do here.

<details>
<summary>If step 2 complains that git is required</summary>

Open Terminal (Spotlight, type `Terminal`), run `xcode-select --install`,
accept the prompt, then quit and reopen Claude desktop.

</details>

## 2. Add the plugin to Claude

1. Click **Customize** in the left sidebar, then the **Plugins** tab.
2. Click **Add marketplace**, type `cookc/steadyship`, and add it.
3. Find **steadyship** in the list and click **Install**.

<details>
<summary>If it fails, or stays on an old version</summary>

"Failed to update marketplace", "couldn't check for updates", or an old
version that won't move on: that is a known Claude desktop problem, not
your computer. Download `steadyship-plugin.zip` from
https://github.com/cookc/steadyship/releases/latest, then Customize,
Plugins, **Add**, **Upload plugin**, and choose the zip.

</details>

## 3. Set it up for your business

1. Start a new chat and point it at a new, empty folder: use the folder
   chooser below the message box ("Choose…", then "Open folder…"), pick or
   create an empty folder, and allow it as trusted when asked.
2. Say **Set up Steadyship for [your business]** and answer the questions:
   the business name, who holds the accounts, who decides what the business
   relies on, and where the shared spreadsheets live. Creating a private
   GitHub repository is an optional last step; it only happens if you say
   yes.
3. Copy your apps into the new folder's `apps/`, one folder per app. Finder is fine for this.
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

Two Mac-specific notes. The environment check may say persistence is
"unknown" the first time: run "Check this computer" again in a new chat to
get the answer. The tests check may FAIL because the test browser cannot be
downloaded in that environment; Steadyship records that and the tests run on
GitHub instead once the repository is there.
