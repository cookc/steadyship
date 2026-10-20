# Assessment: <app name>

Copy this file to `docs/assessment/<app-name>.md`. Fill every line. If
you don't know, write "unknown" — that is a finding.

**Stage:** <Prototype | Owned tool | Proper app | Platform>
<!-- Prototype = one person's tool, data inside it.
     Owned tool = a named owner, a smoke test, data in one master file with one writer.
     Proper app = the business depends on it daily: hosted, sign-in, backup, tests on every change.
     Platform = several apps that must stay consistent for the business to run. -->

**Relied on by:** <who uses it, how often; "only the builder" is a valid answer>

**Owner:** <the person responsible for it; "unknown" until someone agrees>

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
For each: what does this app call it (local name)? Where is it stored (hardcoded / localStorage / file)?

## Duplication spotted

Screens, logic or data that also exist in another app:

- <concept or screen> — also in <app> — same data / same logic / differs how: …

## Exposure

- Who could see this data if they had the file? 
- Any sign-in? 
- Anything that looks like a password, key or customer PII in the code? 

## If it vanished tomorrow

What would the business lose, and how long to recover?

## Engineering profile

How the app measures against the bar (the engineering standard Steadyship
holds every app to), judged at the stage written under **Stage** above.
"Today" says what the code does, with its evidence (`file:line`).
"Meets?" is yes, no, partly, or n/a at this stage.

### Free habits

| Habit | Today | Meets? |
|---|---|---|
| Semantic HTML (real buttons, labels, headings) | | |
| Theme tokens, no hard-coded colours or sizes | | |
| Data never enters the page as raw HTML; one escaping helper | | |
| One form per kind of value (money, dates, moments, identifiers) | | |
| Checked at every edge (file read, form, paste, file written) | | |
| Errors in the page in plain words; what was typed is kept | | |
| No business data or secrets typed into code | | |
| Stage banner at the top of the page | | |
| Only browser features in the baseline | | |
| Dependencies pinned, from the allow-list | | |
| Smoke test; one test per change | | |
| Glossary names; split by concern past one file; comments say why | | |
| README for the app | | |
| Version in the footer; changelog | | |
| Responsive at phone, tablet and desktop | | |
| Large touch targets, strong contrast | | |
| Print styles | | |

### Stage rows

| Question | Today | Meets at this stage? |
|---|---|---|
| Framework | | |
| Libraries | | |
| Build system | | |
| Where the data lives | | |
| Hosting | | |
| Sign-in | | |
| Who changed what | | |
| Tests | | |
| Failures | | |
| Offline | | |
| Backups | | |
| Retention | | |
| Personal data | | |
| Performance (file budget, long lists) | | |
| Consistency with other apps | | |
| Accessibility | | |
| Code structure | | |
| Formatting and lint | | |
| Types | | |
| Updates and rollback | | |
| Who is told | | |
| Cost | | |
| Licences | | |
| Retire it | | |
| Second builder | | |
| Browsers | | |

## Ladder

The rungs from Prototype to Owned tool, in order. Each done rung has its
evidence; the first rung not done is the next one.

| Rung | Done | Evidence |
|---|---|---|
| 1 Name it | | this file |
| 2 Own it | | an owner named above; the own-it facts recorded |
| 3 Test it | | `tests/<app>.spec.ts` exists and its last run passed |
| 4 Move its data | | data in one master file on the shared drive, one writer |
| 5 Share it | | a second person can open it |
| 6 Protect it | | backup confirmed; sign-in where hosted |

**Next rung:** <number and name — the one question it asks>

## Verdict ({{SETUP_OWNER}}, one paragraph in plain language)

What this is, what would break, what it would take to rely on it.

## Candidate next step

One of: leave as prototype / graduate to Owned tool / converge concept X with app Y / don't build, use Z instead.
