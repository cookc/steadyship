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

- In Claude desktop, bash runs in a separate Linux environment, so Windows
  paths and `~` are not the person's folders. Ask them to attach a folder on
  their computer, run `pwd` and `ls` to see how it appears here, and use a
  subfolder of it.
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

Run, with every value in double quotes:

    bash "${CLAUDE_PLUGIN_ROOT}/scripts/init.sh" "<folder>/demo-boatworks" \
      --business "Demo Boatworks" --setup-owner "<the person's name>" --sponsor "Morgan Reid" \
      --github-owner TBC --repo-name demo-boatworks \
      --shared-drive "<folder>/demo-boatworks-shared-drive"
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

1. "Run steadyship status"
2. "run spike 0"
3. "run spike b" (the shared folder is `<folder>/demo-boatworks-shared-drive`)
4. "run spike c, the app is job-board"
5. "What apps do we have and where is the same information kept twice?"

## Rules

- Never overwrite or delete existing files.
- Never put tokens or passwords anywhere. Plain language throughout.
