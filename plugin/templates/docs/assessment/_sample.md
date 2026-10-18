# Assessment: _sample

Worked example against `apps/_sample/`. Real assessments replace this.

**Stage:** Prototype

**Relied on by:** only the builder

**Builder:** (example)

**Opened how:** double-click `index.html`

**Copied into repo at:** `apps/_sample/` on 2026-10-19 from this repository

## What it does (one paragraph, business language)

Shows a list of jobs with the customer and the stage each job is at.

## Data

| What | Where it lives | Who else can see it | Backed up? | Also exists in |
|---|---|---|---|---|
| Jobs | hardcoded in index.html | nobody | no (only in the file) | nowhere (single sample app) |

## Shared concepts

job (local name: "job", hardcoded in index.html); customer (local name: "customer", hardcoded in index.html). No glossary exists yet.

## Duplication spotted

- None yet (single sample app).

## Exposure

- Anyone with the file sees every job and customer name.
- No sign-in.
- No passwords or keys in the code.

## If it vanished tomorrow

Nothing — data is two example rows.

## Verdict ({{SETUP_OWNER}}, one paragraph in plain language)

A prototype. It works, but every job lives inside the page itself, so a
second person can't see the same list and a change to the file loses the
data. Smoke test: PASS.

## Candidate next step

Graduate to Owned tool: move the job list out of the page into one shared
file with a single owner.
