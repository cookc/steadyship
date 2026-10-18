# Spike b — the shared drive, from file tools and from a script

**Question:** can a local session see the real NAS/SharePoint folder where
the spreadsheets live (1) through Claude's file tools and (2) from a bash
script inside the VM? Both matter: (1) for the coach to read data, (2) for
tests and data moves to be automated.

**Who:** builder. **Where:** builder's machine, local session, with the
mapped drive (e.g. `Z:\`) attached via the folder picker.

## Builder runs

Part 1 — type: "In the attached Z: folder, list the first five files, create
a file called steadyship-spike.txt containing today's date, read it back to
me, then delete it."

Part 2 — type: `run spike b` and when asked for the path, give the folder
name as you attached it (Claude will work out how the VM sees it; if it
can't, that is the finding). Without the plugin: "Run
`bash scripts/spikes/nas-rw.sh <the folder path>` and tell me in plain
language whether it passed." The script lists the first five file names in
the folder, which will appear in the chat.

## What Claude does

Part 1 uses file tools only. Part 2 runs `scripts/spikes/nas-rw.sh <dir>`.

## Pass

Part 1: all four actions work. Part 2: `RESULT: PASS`.
Paste: `| b | PASS | <date> | file tools: ok; script: ok |`
If Part 1 passes and Part 2 fails, record `| b | FAIL | <date> | file tools: ok; script: not visible |` — this is the known Windows mapped-drive bug.

## If it fails

- Part 1 fails → the drive wasn't mapped before Claude started, or isn't
  attached. Map it, restart Claude, attach, retry once.
- Part 2 fails only → **Fallback:** data moves and reads go through Claude's
  file tools, not scripts; or the shared data folder is a OneDrive-synced
  SharePoint library (local path, no mapped drive) — retry Part 2 with that
  path. **Meaning:** automation that touches the NAS runs in CI or on
  Chris's machine, not in the builder's session, until the bug is fixed.
