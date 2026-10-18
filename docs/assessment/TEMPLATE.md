# Assessment: <app name>

Copy this file to `docs/assessment/<app-name>.md`. Fill every line. If
you don't know, write "unknown" — that is a finding.

**Stage:** Prototype
<!-- One of: Prototype | Owned tool | Proper app | Platform. See proposal §7. -->

**Relied on by:** <who uses it, how often; "only the builder" is a valid answer>

**Builder:** <name>

**Opened how:** <e.g. double-click index.html from SharePoint-synced folder; localhost; URL>

**Copied into repo at:** `apps/<name>/` on <date> from <original location>

## What it does (one paragraph, business language)

## Data

| What | Where it lives | Who else can see it | Backed up? | Also exists in |
|---|---|---|---|---|
| e.g. Jobs | hardcoded in index.html | nobody | no | Quoting app, Jobs.xlsx on NAS |

## Shared concepts

Which of these does the app use, and does it match the glossary (if one exists yet)?
customer / job / product / part / revision / operation / release / exception / other: ___

## Duplication spotted

Screens, logic or data that also exist in another app:

- 

## Exposure

- Who could see this data if they had the file? 
- Any sign-in? 
- Anything that looks like a password, key or customer PII in the code? 

## If it vanished tomorrow

What would the business lose, and how long to recover?

## Verdict (Chris, one paragraph in plain language)

What this is, what would break, what it would take to rely on it.

## Candidate next step

One of: leave as prototype / graduate to Owned tool / converge concept X with app Y / don't build, use Z instead.
