---
name: steadyship-init
description: Use when asked to "set up Steadyship", "create a Steadyship repository", "initialise this folder for Steadyship", or when a business wants to start using Steadyship. Gathers six facts, generates a self-contained repository from the plugin's templates, and offers (never performs silently) to create the GitHub repository.
---

# Steadyship setup

You are setting up a business's own Steadyship repository. The person
you are talking to is the **setup owner**: they hold the accounts. They
may be non-technical. Do the work; explain plainly.

## 1. Gather the facts (ask only for what is missing)

- Business name (e.g. "Smith Joinery")
- Setup owner's name (usually the person you are talking to)
- Sponsor's name (the owner or manager who decides what the business relies on)
- GitHub owner (their organisation or account name on GitHub — ask them
  to look at github.com; if they have none yet, say so and use "TBC")
- Repository name (suggest `<business-slug>-apps`, lower-case, hyphens)
- Shared drive path where spreadsheets live (e.g. `Z:\` on Windows,
  `/Volumes/Shared` on a Mac, or "none")
- Target folder on this computer (suggest a folder next to their other
  work, e.g. `C:\Users\<name>\<repo-name>` or `~/<repo-name>`). It must
  not exist yet, or must be empty.

Confirm the seven values back in one short list before continuing.

## 2. Generate the repository

Run:

    bash "${CLAUDE_PLUGIN_ROOT}/scripts/init.sh" "<target folder>" \
      --business "<business>" --setup-owner "<setup owner>" --sponsor "<sponsor>" \
      --github-owner "<github owner>" --repo-name "<repo name>" --shared-drive "<shared drive>"

The last line is `RESULT: PASS created <dir>` or `RESULT: FAIL <reason>`.
On FAIL, say what went wrong in plain words and stop. Common causes: the
folder already has files in it; a value was left blank.

## 3. Report

Say: "Your Steadyship repository is ready at <dir>. It is self-contained —
it works even without this plugin." Then list the three things in it that
matter now: `docs/spikes/README.md` (the go/no-go checks), `docs/assessment/README.md`
(how to assess each app), `steadyship.md` (the facts you gave me).

## 4. GitHub (offer; never do it silently)

Check whether the GitHub CLI is available and logged in:
`gh auth status >/dev/null 2>&1 && echo yes || echo no`.

- If **yes**: ask "Shall I create the private GitHub repository
  `<github owner>/<repo name>` now and upload this folder to it?" Only
  if they say yes, run:
  `cd "<dir>" && gh repo create "<github owner>/<repo name>" --private --source=. --remote=origin --push`
  and report the result. If it fails, show the last two lines of the error
  in plain words (e.g. "GitHub says that name is already taken").
- If **no**: say the repository is local only for now, and give the setup
  owner these two lines to run later from a terminal where `gh` is logged
  in, or to hand to whoever manages their GitHub:

      cd "<dir>"
      gh repo create "<github owner>/<repo name>" --private --source=. --remote=origin --push

Then: "Next step: open `docs/spikes/README.md` and run spike e."

## Rules

- Never create or push to GitHub without an explicit yes in this
  conversation.
- Never put tokens, passwords or keys in any file or in your replies.
- Do not edit the generated files by hand; if something is wrong, say so
  and stop. The templates are fixed in the plugin.
