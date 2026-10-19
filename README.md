<p align="center">
  <picture>
    <source media="(prefers-color-scheme: dark)" srcset="docs/brand/logo-dark.png">
    <img src="docs/brand/logo.png" width="400" alt="Steadyship">
  </picture>
</p>

An engineer in the conversation for non-technical people building business
software with AI. Steadyship is a Claude plugin: it asks what you don't know
to ask, judges what you can't judge, and gives prototypes a path to software a
business can run on. The thinking behind it is in `docs/proposal-v0.1.md`.

## Quick start

Four steps. The first two are done once per computer; after that it is all
typing into Claude.

1. [Get the computer ready](#1-get-the-computer-ready)
2. [Add the plugin to Claude](#2-add-the-plugin-to-claude)
3. [Try the demo business](#3-try-the-demo-business)
4. [Set up your own business](#4-set-up-your-own-business)

### 1. Get the computer ready

Claude needs Git on the computer before it can add a plugin. Node.js is
optional (one check uses it; Steadyship installs it when needed).

**Windows, the easy way:** one script installs Git and Node.js if they are
missing, checks for Claude desktop, and downloads a spare copy of the plugin.
It changes nothing else.

1. Open PowerShell: press Start, type `PowerShell`, press Enter.
2. Paste this line and press Enter. Say Yes if Windows asks for permission.

   ```powershell
   irm https://raw.githubusercontent.com/cookc/steadyship/main/scripts/setup-windows.ps1 | iex
   ```

3. Read what it printed. Anything marked `to do` is for you; `RESULT: READY`
   means you are done here.

**Windows, by hand:**

1. Open PowerShell.
2. Run `winget install --id Git.Git -e` and say Yes to the permission prompt.
3. Optional: run `winget install --id OpenJS.NodeJS.LTS -e`.

**Then, on Windows either way:** if Claude desktop was already open, quit it
fully (right-click its icon by the clock, then Quit) and open it again. It
only notices Git after a restart.

**Mac or Linux:** Git is usually already there (`git --version` in a
terminal). If not: on a Mac run `xcode-select --install`; on Linux use your
package manager. If you use Claude Code in a terminal, this one line does
step 1 and step 2 together:

```sh
curl -fsSL https://raw.githubusercontent.com/cookc/steadyship/main/scripts/setup.sh | bash
```

### 2. Add the plugin to Claude

**Claude desktop**

1. Click **Customize** in the left sidebar, then the **Plugins** tab.
2. Click **Add marketplace**, type `cookc/steadyship`, and add it.
3. Find **steadyship** in the list and click **Install**.

**Claude Code (terminal)**

1. `/plugin marketplace add cookc/steadyship`
2. `/plugin install steadyship@steadyship`

**If it fails** with "failed to update marketplace", "couldn't check for
updates", or the plugin stays on an old version: that is a known Claude
desktop problem, not your computer. Use the spare copy instead.

1. The zip is at `Downloads\steadyship-plugin.zip` if you ran the setup
   script. Otherwise download `steadyship-plugin.zip` from
   https://github.com/cookc/steadyship/releases/latest.
2. Customize, Plugins, **Add**, **Upload plugin**, and choose the zip.

### 3. Try the demo business

Demo Boatworks is a made-up boat builder with six apps its staff built with
Claude, and the spreadsheets they run on. It lets you try everything on
something that doesn't matter.

1. Start a new chat and point it at a new, empty folder. In Claude desktop,
   use the folder chooser below the message box ("Choose…", then "Open
   folder…"), pick or create an empty folder, and allow it as trusted when
   asked.
2. Say: **Try Steadyship with the demo business**
3. Then say these, one at a time, waiting for each to finish:
   1. **Run steadyship status**
   2. **run spike 0**
   3. **run spike b**
   4. **run spike c, the app is job-board**
   5. **What apps do we have and where is the same information kept twice?**

The spikes are short go/no-go checks of what this computer can really do
(reach GitHub, read the shared drive, run an app's tests). Each ends with a
plain `RESULT: PASS`, `FAIL` or `SKIP` line and Steadyship offers to record it.
Spike c installs Node.js and a test browser if they are missing. The last
question is answered from the assessment Steadyship writes into
`docs/assessment/`.

That is the whole quick start. No terminal needed beyond step 1.

### 4. Set up your own business

1. In a new, empty folder, say **Set up Steadyship for <your business>** and
   answer the questions (business name, who holds the accounts, who decides
   what the business relies on, where the shared spreadsheets live). Creating
   a private GitHub repository is an optional last step; it only happens if
   you say yes.
2. Copy your apps into the new folder's `apps/`, one folder per app.
3. Say **run spike b** to prove the shared drive can be read from here.
4. Say **What apps do we have and where is the same information kept twice?**
5. Say **review the <app>** for a plain Yes / No / Prototype verdict on
   whether an app is good enough for the team to rely on.
6. Ask for a change the way you normally would. Steadyship asks one or two
   questions first (what the new thing attaches to, where its data should
   live, whether something you already have does it), records the answer, and
   then builds.

## What you get

- A repository of your own, self-contained: it works even without the plugin.
- A status check: what apps you have, what each is for, what is at risk.
- Go/no-go spikes: short checks of what your environment can really do.
- An assessment of each app, written into `docs/assessment/`, from prototype
  to something the business can run on.
- Reviews, and the questions an engineer would ask before a change is built,
  with the answers recorded in `docs/context/decisions.md`.

## For developers

- `plugin/` is the Claude plugin: `skills/` (`steadyship-init`, `-demo`,
  `-status`, `-spike`, `-assess`, `-review`, `-ask`), the scaffolder
  `scripts/init.sh`, `templates/` for the generated customer repository, and
  `demo/` (the mock customer, see `plugin/demo/README.md`).
- `.claude-plugin/marketplace.json` makes this repository the plugin
  marketplace.
- `scripts/validate.sh` runs every product check CI runs; `STEADYSHIP_FULL=1`
  adds the generated repository's Playwright smoke test.
- `tests/test-init.sh` generates a customer repository and checks it works.
- `tests/judgement/` is the judgement eval harness (assess/ask/review on Demo
  Boatworks, with and without the plugin): `tests/judgement/run.sh`, results
  in `docs/judgement-spike.md`. It costs money and minutes, so it is not in
  `scripts/validate.sh` or CI.
- `scripts/package-plugin.sh` builds the upload zip; `scripts/setup.sh` and
  `scripts/setup-windows.ps1` are the end-user setup scripts above;
  `scripts/demo-regenerate.sh` rebuilds the standing demo repository.
- Releasing: bump `version` in `plugin/.claude-plugin/plugin.json`, commit,
  then tag `vX.Y.Z` and push the tag. The `release` workflow attaches the zip
  to a GitHub release, which the setup scripts download.
- `docs/` holds the proposal, plans, rehearsal notes (`rehearsal.md`,
  `rehearsal-windows-vm.md`), the field-test plan and guide, and the logo
  files in `docs/brand/`.

Each business gets its own repository, generated by `steadyship-init` from
`plugin/templates/`, owned by the business, and self-contained.

## Licence

Apache License 2.0, see `LICENSE`.
