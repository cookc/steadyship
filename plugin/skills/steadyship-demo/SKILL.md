---
name: steadyship-demo
description: Use when asked to "try Steadyship", "set up the demo", "use the demo business", or "show me Steadyship with Demo Boatworks". Builds a ready-made Steadyship repository for a mock business (Demo Boatworks) so the person can try the other skills straight away.
---

# Try Steadyship with Demo Boatworks

Say this in plain words, in two sentences: Demo Boatworks is a made-up small
boat builder with six apps its staff built with Claude and some spreadsheets,
mirroring a real small business. I'll set it up so you can try Steadyship on it.

## 1. Ask for ONE thing: the folder

Ask only where to put it.

- Run `pwd` and `uname -s` first. `MINGW…`/`MSYS…` means Git Bash on the
  person's own Windows computer (Claude desktop "This computer" mode): their
  folders are real, and `C:\Users\…` paths work as they are. A `pwd` like
  `/sessions/…/mnt/…` means Claude desktop's separate Linux environment:
  Windows paths and `~` are not the person's folders. Either way, ask them
  to attach (or choose) a folder on their computer, run `ls` to see it, and
  use a subfolder of it.
- If `git` or `bash` is missing (a fresh Windows computer), install Git for
  Windows right away, do not ask: say in one line "This computer has no Git
  yet; installing it (about a minute)", run
  `winget install --id Git.Git -e` (if `winget` is not on PATH it is at
  `%LOCALAPPDATA%\Microsoft\WindowsApps\winget.exe`), then continue in a
  fresh shell. Ask only if winget is missing or the install fails.
- In Claude Code, `~/steadyship-demo` is fine.

Call the chosen folder `<folder>`. If you don't know the person's name, ask
for it (default "Sam Setup"). Do not ask anything else.

## 2. Build it

If `${CLAUDE_PLUGIN_ROOT}` is empty or `${CLAUDE_PLUGIN_ROOT}/scripts/init.sh`
or `${CLAUDE_PLUGIN_ROOT}/demo/populate.sh` does not exist, say the Steadyship
plugin isn't properly installed and stop.

Never overwrite anything: if `<folder>/demo-boatworks` or
`<folder>/demo-boatworks-shared-drive` already exists and has files, ask for a
different (new) folder and start again.

In Claude desktop, say first: "Claude will ask permission to create files in
the attached folder — please allow it." Then run, with every value in
double quotes (the shared-drive value is deliberately relative: the
attached folder's path changes from session to session, and the drive is
always beside the repository):

    bash "${CLAUDE_PLUGIN_ROOT}/scripts/init.sh" "<folder>/demo-boatworks" \
      --business "Demo Boatworks" --setup-owner "<the person's name>" --sponsor "Morgan Reid" \
      --github-owner TBC --repo-name demo-boatworks \
      --shared-drive "../demo-boatworks-shared-drive"
    bash "${CLAUDE_PLUGIN_ROOT}/demo/populate.sh" "<folder>/demo-boatworks" "<folder>/demo-boatworks-shared-drive"

Each ends with `RESULT: PASS ...` or `RESULT: FAIL <reason>`. On FAIL, say
what went wrong in plain words and stop. Then commit the populated files:

    cd "<folder>/demo-boatworks" && git add -A && git -c user.name=Steadyship -c user.email=steadyship@example.invalid commit -q -m "chore: add Demo Boatworks apps, business docs"

There is no GitHub step: the demo stays on this computer.

## 3. Report

Plainly: the demo is at `<folder>/demo-boatworks` (and its spreadsheets at
`<folder>/demo-boatworks-shared-drive`). It holds six apps, a folder of
spreadsheets, and the business's own notes. Then give these next prompts, in
order, for the person to say (work from the demo folder):

1. "Check this computer" (three one-minute checks: environment, the
   spreadsheets folder, and opening one app in a test browser; the first
   run installs a test browser and can take a few minutes, which is normal)
2. "What apps do we have and where is the same information kept twice?"
3. "Review the job board" (any name from the list in the previous answer works)
4. Build something: "Build me a tool that ..." in your own words. It is a
   prototype, so Steadyship just builds it.
5. "Set up my data", then "Set up my security": two short conversations
   about the business, written down for every later change.
6. "Promote the <what you built>": a few questions, then the engineering
   on its own.

Then say: "From now on I'll work inside `<folder>/demo-boatworks` for this conversation; if a later answer says a folder isn't a Steadyship repository, tell me and I'll point it there."

Also say: "The demo has no GitHub repository, so the GitHub, hosting and team checks don't apply here; if status suggests them, ignore that."

## Rules

- Never overwrite or delete existing files.
- Never put tokens or passwords anywhere. Plain language throughout.
