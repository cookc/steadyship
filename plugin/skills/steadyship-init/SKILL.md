---
name: steadyship-init
description: Use when asked to "set up Steadyship", "create a Steadyship repository", "initialise this folder for Steadyship", or when a business wants to start using Steadyship. Gathers six facts, generates a self-contained repository from the plugin's templates, and offers (never performs silently) to create the GitHub repository.
---

# Steadyship setup

You are setting up a business's own Steadyship repository. The person
you are talking to is the **setup owner**: they hold the accounts. They
may be non-technical. Do the work; explain plainly.

## 1. Gather the facts (ask only for what is missing, one item at a time)

- Business name (e.g. "Smith Joinery")
- Setup owner's name (usually the person you are talking to)
- Sponsor's name (the owner or manager who decides what the business relies on)
- GitHub owner (their organisation or account name on GitHub — ask them
  to look at github.com; if they have none yet, say so and use "TBC")
- Repository name (suggest `<business-slug>-apps`, lower-case, hyphens)
- Shared drive path where spreadsheets live (e.g. `Z:` on Windows,
  `/Volumes/Shared` on a Mac, or "none")
- Target folder: see "Where the repository goes" below.

**Where the repository goes.** If you are running inside Claude desktop, bash runs in a separate Linux environment, so Windows paths like `C:\Users\…` and `~` do not mean the person's own folders. Ask them to attach (or confirm they have attached) a folder on their computer where the new repository should live, then run `pwd` and `ls` to find how that folder appears here, and create the repository as a new subfolder of it (e.g. `<attached folder>/<repo-name>`). After generating, list the new folder back to them so they can see it from their own computer. If you are running in Claude Code on a Mac or Linux, `~/<repo-name>` is fine. The target must not exist yet, or must be empty. If it already has files, ask for a different folder name (a new, empty folder) and run the command again. Never delete or overwrite existing files.

Confirm the seven values back in one short list before continuing.

## 2. Generate the repository

First, if `${CLAUDE_PLUGIN_ROOT}` is empty or
`${CLAUDE_PLUGIN_ROOT}/scripts/init.sh` does not exist, say the Steadyship
plugin isn't properly installed and stop.

Run:

    bash "${CLAUDE_PLUGIN_ROOT}/scripts/init.sh" "<target folder>" \
      --business "<business>" --setup-owner "<setup owner>" --sponsor "<sponsor>" \
      --github-owner "<github owner>" --repo-name "<repo name>" --shared-drive "<shared drive>"

If the shared drive is "none", pass `--shared-drive none` and tell the
person that spike b will be marked "not applicable".

Pass every value in double quotes. If the shared drive path ends in a
backslash (for example `Z:\`), drop the trailing backslash (`Z:`) or write
it with forward slashes (`Z:/`) so it doesn't escape the closing quote. If
a value contains `"`, `$` or a backtick, use single quotes for that value
instead. Backslashes in the middle of a path (`C:\Users\x`) and
apostrophes (O'Brien) are fine in double quotes.

The last line is `RESULT: PASS created <dir>` or `RESULT: FAIL <reason>`.
On FAIL, say what went wrong in plain words. If the folder already has
files in it, ask for a different folder name (a new, empty folder) and run
the command again. Never delete or overwrite existing files. For any other
FAIL (e.g. a value was left blank), fix the value if you can, otherwise stop.

## 3. Report

Say: "Your Steadyship repository is ready at <dir>. It is self-contained —
it works even without this plugin." Then list the three things in it that
matter now: `docs/spikes/README.md` (the go/no-go checks), `docs/assessment/README.md`
(how to assess each app), `steadyship.md` (the facts you gave me).

## 4. GitHub (offer; never do it silently)

If the GitHub owner is "TBC", skip the GitHub offer entirely and say the
repository is local only for now.

Otherwise, check whether the GitHub CLI is available and logged in:
`gh auth status >/dev/null 2>&1 && echo yes || echo no`.

- If **yes**: ask "Shall I create the private GitHub repository
  `<github owner>/<repo name>` now and upload this folder to it?" Only
  if they say yes, run:
  `cd "<dir>" && gh repo create "<github owner>/<repo name>" --private --source=. --remote=origin --push`
  and report the result. If it fails, show the last two lines of the error
  in plain words (e.g. "GitHub says that name is already taken").
- If **no**, or if they decline when asked: say the repository is local only for now, and give the setup
  owner these two lines to run later from a terminal where `gh` is logged
  in, or to hand to whoever manages their GitHub:

      cd "<dir>"
      gh repo create "<github owner>/<repo name>" --private --source=. --remote=origin --push

In Claude desktop, `gh` is usually not available; in that case print the two commands for the setup owner to run from a terminal on their own computer, in the folder they attached.

Then: "Next step: open `docs/spikes/README.md` and run spike e (a short check that the plugin works on your computer)."

## Rules

- Never create or push to GitHub without a yes given in answer to the
  question in step 4 of this conversation — an earlier general instruction
  like 'put it on GitHub' does not count.
- Never put tokens, passwords or keys in any file or in your replies.
- Do not edit the generated files by hand; if something is wrong, say so
  and stop. The templates are fixed in the plugin.
