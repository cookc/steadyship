# Assessment: Job Board

**Stage:** Prototype (it already shows real jobs, so it has met the trigger to become an Owned tool, but nobody owns it yet)

**Relied on by:** unknown (the business notes do not say who uses it or how often)

**Owner:** unknown

**Builder:** Sam (from the code comment "copied from Jobs.csv - Sam", `apps/job-board/index.html:24`); surname unknown

**Opened how:** unknown (the business notes say each app "lives in a folder on the shared drive"; I did not find the apps there)

**Copied into repo at:** `apps/job-board/` in commit 365dc34 ("add Demo Boatworks apps"); original location unknown

## What it does (one paragraph, business language)

A board with one column per stage. Each job is a card showing job number, customer and due date, with a "Move to <next stage>" button. Cards past their due date get a red border. The card positions you change by pressing the button are remembered only in that browser.

## Data

| What | Where it lives | Who else can see it | Backed up? | Also exists in |
|---|---|---|---|---|
| Jobs: 8 rows, J-1038 to J-1045 (the last-but-four is typed as `1043`) | typed into the page (`index.html:26-35`) | anyone with the file | only as part of the repo | Jobs.csv (8 rows), delivery-checklist (4), shop-timer (3), purchase-requests (free text) |
| Stage list: 6 stages | typed into the page (`index.html:25`) | anyone with the file | as above | "How we build a boat.md" (9 stages) |
| Which jobs you have moved | browser storage (localStorage) key `jobboard_stages` (`index.html:37,57`) | only that one browser on that one computer | no | nowhere; never written back to Jobs.csv |

## Shared concepts

- Customer: local name `customer`; typed in the page. Glossary says written exactly as in Customers.csv and never abbreviated; the board drops "Ltd" on 7 of 8 jobs.
- Job: `job`; typed in the page. Glossary says J- and four digits; one row is `1043`.
- Stage: `stage`; typed in the page. 6 of the 9 official stages.
- Not used: model, part, operation, hull number, quote.

## Duplication spotted

- Job list (8 jobs) — also in Jobs.csv (8), delivery-checklist (4), shop-timer (3) — same data, copied by hand, differs how: J-1041 is `Weld` on the board but `Fit-out` in Jobs.csv; J-1039 is `Paint` on the board but `Sea trial` in Jobs.csv.
- Customer names — also in Customers.csv, Jobs.csv, quote-builder — differs how: board has `Southern Charters`, `Kaipara Fishing Co`, `Harbour Services`, `Fiordland Eco Tours`, `Port Nelson Pilots` where the files have `Southern Charters Ltd`, `Kaipara Fishing Co Ltd`, `Harbour Services Ltd`, `Fiordland Eco Tours Ltd`, `Port Nelson Pilots Ltd`. Only `Tasman District Council` matches.
- Job number format — also in Jobs.csv — differs how: `1043` here against `J-1043` in Jobs.csv.
- Stage names — also in "How we build a boat.md" — differs how: `Fit out` here against `Fit-out`; board has no `Enquiry`, `Quote` or `Sea trial` (uses 6 of the 9 official stages).
- "Today" as `new Date().toISOString().slice(0, 10)` (`index.html:38`) — also in purchase-requests, quote-builder — same logic: gives the UTC date, so for New Zealand (UTC+13 now) it is a day behind from midnight until about 1 pm; the red "overdue" border flips late.
- Page colours and header — also in the other 5 apps — differs how: header `#0b3d5c`, background `#eef1f4`, Arial.

## Exposure

- Anyone with the file sees every job, customer and due date.
- No sign-in.
- No passwords or keys. Customer company names only, no contact details.
- Cards are built with `innerHTML` from data typed in the page (`index.html:46,50`); safe today because the data is fixed, unsafe the day it is read from a file.

## If it vanished tomorrow

The 8 jobs would be easy to re-type, but every "Move to" press is lost: the board would show the stages typed in the page (already out of date on J-1039 and J-1041). Nothing was ever saved to Jobs.csv, so nobody could tell what the board had said. Recovery: an hour, plus working out the true stage of each job.

## Engineering profile

Judged at Prototype. `docs/context/engineering.md` has no overrides.

### Free habits

| Habit | Today | Meets? |
|---|---|---|
| Semantic HTML (real buttons, labels, headings) | real `<button>`, `<h1>`, `<h2>` (`index.html:21,45,54`); cards are `<div>`s | partly |
| Theme tokens, no hard-coded colours or sizes | every colour typed in `<style>` (`index.html:8-17`) | no |
| Data never enters the page as raw HTML; one escaping helper | `innerHTML` with job and customer (`index.html:46,50`); no escaping helper | no |
| One form per kind of value (money, dates, moments, identifiers) | ISO dates (good); job id `1043` against `J-1043` (`index.html:32`) | no |
| Checked at every edge (file read, form, paste, file written) | nothing read or written but browser storage; `JSON.parse` unguarded (`index.html:37`) | no |
| Errors in the page in plain words; what was typed is kept | no error handling | no |
| No business data or secrets typed into code | jobs, customers, due dates, stages typed in (`index.html:25-35`) | no |
| Stage banner at the top of the page | none | no |
| Only browser features in the baseline | plain JavaScript only | yes |
| Dependencies pinned, from the allow-list | none, nothing loaded from outside | yes |
| Smoke test; one test per change | no test of its own (generic `tests/smoke/app.spec.ts` can open any app; no record that it has been run on this one) | n/a at Prototype |
| Glossary names; split by concern past one file; comments say why | one file under 100 lines; glossary names used except `Fit out`, `1043`, shortened customers; one comment, "copied from Jobs.csv - Sam" | partly |
| README for the app | none | no |
| Version in the footer; changelog | none | no |
| Responsive at phone, tablet and desktop | viewport tag set (`index.html:5`); board scrolls sideways (`index.html:11`); never checked by screenshot | partly |
| Large touch targets, strong contrast | move buttons at `.75rem` (`index.html:16`) are small for gloves | no |
| Print styles | none | no |

### Stage rows

| Question | Today | Meets at this stage? |
|---|---|---|
| Framework | none, plain HTML and JavaScript | yes |
| Libraries | none | yes |
| Build system | none | yes |
| Where the data lives | in the page and browser storage (`index.html:26,37`) | yes for Prototype; no for Owned tool |
| Hosting | a file | yes |
| Sign-in | none | yes |
| Who changed what | not recorded | yes (not needed yet) |
| Tests | none of its own | yes |
| Failures | no messages at all | yes |
| Offline | works offline (nothing to fetch) | n/a |
| Backups | none confirmed | yes |
| Retention | not asked | n/a |
| Personal data | company names only | yes |
| Performance (file budget, long lists) | 8 cards; all rendered | yes |
| Consistency with other apps | own colours and font; no brand file | n/a |
| Accessibility | partly (see habits) | n/a |
| Code structure | one file, under 100 lines | yes |
| Formatting and lint | not run | yes |
| Types | none | yes |
| Updates and rollback | overwrite; previous version in git | yes |
| Who is told | nobody | yes |
| Cost | nothing | yes |
| Licences | no libraries | yes |
| Retire it | no usage record | n/a |
| Second builder | not possible from the folder alone (no README) | n/a |
| Browsers | not asked yet | n/a |

## Ladder

| Rung | Done | Evidence |
|---|---|---|
| 1 Name it | yes | this file |
| 2 Own it | no | no owner in the business notes |
| 3 Test it | no | no `tests/job-board.spec.ts` |
| 4 Move its data | no | jobs typed in the page, moves in browser storage; Jobs.csv is the likely master |
| 5 Share it | unknown | not confirmed that a second person can open it |
| 6 Protect it | no | no backup confirmed; not hosted |

**Next rung:** 2 Own it — who is responsible for this app?

## Verdict (Sam Setup, one paragraph in plain language)

This is a one-person-style prototype holding real jobs. It looks authoritative but is a hand-made copy of Jobs.csv that has already drifted: two stages differ (J-1039, J-1041) and seven customer names are shortened. Anyone who trusts the board over the spreadsheet will be misled. To rely on it, it needs an owner and to read its jobs from Jobs.csv (and write moves back) instead of carrying its own copy.

## Candidate next step

Graduate to Owned tool: name an owner, then make Jobs.csv the one master.
