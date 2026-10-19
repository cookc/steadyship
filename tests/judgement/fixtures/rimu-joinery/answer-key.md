# Answer key: Rimu Joinery

Ground truth for scoring `assess`, `ask` and `review` on the second mock
business (cases `tests/judgement/evals/r*`). Every row can be checked by
reading the named file; the **Verify** column gives a command that shows it
(run from this folder, `tests/judgement/fixtures/rimu-joinery/`). Never show
this file to an agent under test: `run.sh` stages the fixture without it, and
the `no-peek` grader fails any run that reads a path matching `answer-key`.

The planted defects are deliberately a different mix from Demo Boatworks
(`tests/judgement/answer-key.md`): no job-number format variant, no money
rounding bug, no header CSS drift, no quote-validity clash. New kinds: a job
list keyed by client name, a stale labour rate copied into two apps, codes
that lose a meaningful suffix, a date format that breaks sorting, an
always-wrong date helper, a business rule (deposit) the app contradicts, a
quote that was wrong when written.

Today in the fixture's world is 2026-10-19 (Monday).

## 1. Apps, stage, and who relies on them

All five are stage **Prototype**: one HTML file, data hardcoded or in the
browser's `localStorage`, no tests, no named owner, no sign-in. Who relies on
each comes from `business/About.md`.

| App | What it does | Relied on by | Data lives in |
|---|---|---|---|
| `apps/quote-calc` | client + cabinet/benchtop quantities + labour hours -> quote with GST, deposit, valid-until | Ana Tane, every quote | hardcoded `customers` (6), `items` (10), `LABOUR_RATE`, `DEPOSIT`; saved quotes in `localStorage` key `rj_quotes` |
| `apps/job-tracker` | jobs in columns by stage, "Move to" buttons, a "Next installs" panel | the office every morning and the whole workshop (big screen) | hardcoded `jobs` (8); stage moves in `localStorage` key `rj_tracker_moves` |
| `apps/job-clock` | Start/Stop assembly timer per job | the three fitters (workshop tablet) | hardcoded `jobs` (4, by client surname); `localStorage` key `rj_clock` |
| `apps/cut-list` | panels and board sheets/cost for a set of cabinets | Rawiri (CNC) | hardcoded `boards` (4) and `cabinets` (7); nothing saved |
| `apps/install-calendar` | coming installs, panel delivery date, install labour cost | Lisa and the fitters | hardcoded `installs` (5) and `RATE`; nothing saved |

## 2. Shared concepts and where each lives

| # | Concept | Places | Variants | Verify |
|---|---|---|---|---|
| c1 | **Client** (6 places, 2 words, 3 name forms) | `shared-drive/Clients.csv` (7); `shared-drive/Jobs.csv`; `apps/quote-calc` (`customers`, 6); `apps/job-tracker` (`jobs[].client`); `apps/job-clock` (`jobs[].client`); `apps/install-calendar` (`installs[].client`); also `Q-0417` | The Glossary says "client, not customer"; quote-calc says **Customer** (label, `customers` array, saved-quote column). job-clock uses short forms: "Ngata", "Sharma", "Greenstone" for "Hemi & Kiri Ngata", "Priya & Dev Sharma", "Greenstone Homes Ltd". job-tracker spells "Jo O'Neil" (Clients.csv: "Jo O'Neill"). | `grep -n "ustomer" apps/*/index.html`; `grep -n "client: '" apps/job-clock/index.html`; `grep -rn "O'Neil" .` |
| c2 | **Job** (5 places, 2 keys) | `Jobs.csv` (9: RJ-2058 to RJ-2066); `apps/job-tracker` (8: RJ-2058 to RJ-2065); `apps/job-clock` (4); `apps/install-calendar` (5: RJ-2058 to RJ-2062); `Q-0417` ("Became job RJ-2063") | "RJ-" + 4 digits everywhere a number is used. job-clock has **no job numbers**: it identifies a job by client surname, and stores time under that name. | `grep -c "job: 'RJ-" apps/*/index.html`; `grep -n "RJ-" apps/job-clock/index.html` (none) |
| c3 | **Material code** (3 places, 2 formats) | `shared-drive/Materials.csv` (6 boards); `apps/cut-list` (`boards`, 4); `business/Glossary (draft).md` | Materials.csv and the Glossary end every code in the thickness: WMEL-16, WMEL-18, MDF-18, MDF-25, OAK-VEN-18, PLY-HOOP-18. cut-list drops it from all 4: `WMEL`, `MDF`, `OAK-VEN`, `PLY-HOOP`. | `grep -n "^  *[A-Z'-]*: { desc" apps/cut-list/index.html`; `cut -d, -f1 shared-drive/Materials.csv` |
| c4 | **Operation** (1 place, never recorded) | only `business/How we make a kitchen.md` (3 or 4 named operations per stage; Assemble has 4) and the Glossary | No app records an operation. job-clock records time per job (per client name). The Glossary and the guide both say time is booked against the operation. | `grep -n "operation" business/*.md`; `grep -n "operation" apps/*/index.html` (none) |
| c5 | **Stage** (4 places, 1 rename) | `business/How we make a kitchen.md` (9 stages); Glossary (Install/"fit"); `Jobs.csv` (official names, 7 in use); `apps/job-tracker` (`stages`, 8 columns) | job-tracker has 6 of the 9 official stages under the same names, **"Fit" instead of "Install"**, an extra **"Done"** not in the guide, and no **Measure** or **Quote**. | `grep -n "const stages" apps/job-tracker/index.html`; `grep -n "^## " "business/How we make a kitchen.md"` |
| c6 | **Labour rate** (4 places, 2 values, copied into 2 apps) | `shared-drive/Price List.csv` (85, effective 2026-07-01); `apps/install-calendar` (`RATE = 85`); `apps/quote-calc` (`LABOUR_RATE = 78`); `Q-0417` (78) | Two apps each hardcode their own copy of the rate; they already disagree (85 vs 78). | `grep -n "RATE = " apps/*/index.html`; `grep -n Labour "shared-drive/Price List.csv"` |
| c7 | **Install date** (3 places, 2 formats) | `Jobs.csv` (`install_date`); `apps/install-calendar` (`install`); `apps/job-tracker` (`install`) | Jobs.csv and install-calendar write it year first (2026-10-21), as the Glossary says. job-tracker writes **DD/MM with no year** ("21/10", "03/12"). | `grep -n "install: '" apps/*/index.html` |
| c8 | **Deposit** (4 places, 2 values) | `business/How we make a kitchen.md` (Order: 50%); Glossary (50%); `apps/quote-calc` (`DEPOSIT = 0.4`, "Deposit (40%)"); `Q-0417` (40%, $8,251.48) | 50% in the business notes vs 40% in the app and the saved quote. | `grep -rn "50%\|40%\|DEPOSIT" .` |

## 3. Planted duplications and inconsistencies

Each row is one item for scoring. Format: concept/screen, in, also in, same
data / same logic / differs how.

| # | Concept / screen | In | Also in | Same or differs | Verify |
|---|---|---|---|---|---|
| d01 | Job list (stale stages) | `apps/job-tracker` | `Jobs.csv` | Hardcoded copy ("copied from Jobs.csv 28 Sept"); two rows stale: **RJ-2061** tracker "Edge & drill", CSV "Assemble"; **RJ-2063** tracker "Cut", CSV "Edge & drill". The other six agree (Install shown as "Fit"). | `grep -n "RJ-206[13]" apps/job-tracker/index.html shared-drive/Jobs.csv` |
| d02 | Job list (missing row) | `apps/job-tracker` | `Jobs.csv` | Tracker has 8 jobs, CSV has 9: **RJ-2066** (Tania Whitehead, Laundry, Design) is missing. | `grep -c "job: 'RJ-" apps/job-tracker/index.html`; `grep RJ-2066 shared-drive/Jobs.csv` |
| d03 | Job list | `apps/job-clock` | `Jobs.csv`, `apps/job-tracker` | Own copy of **4 jobs** (Greenstone show home kitchen, Ngata kitchen, Sharma kitchen, Ngata master wardrobe = RJ-2061, RJ-2062, RJ-2063, RJ-2065), with no job numbers. | `grep -n "client: '" apps/job-clock/index.html` |
| d04 | Timer key | `apps/job-clock` | `Jobs.csv` | Time is stored under the client name (`clock[client]`, `running.client`), not the job. The two **Ngata** jobs (kitchen RJ-2062, master wardrobe RJ-2065) share one timer: starting either shows both running, and their hours add into one total. | `grep -n "running.client\|clock\[" apps/job-clock/index.html` |
| d05 | Job list | `apps/install-calendar` | `Jobs.csv`, `apps/job-tracker` | Own copy of **5 jobs** (RJ-2058 to RJ-2062) with install dates and install hours. | `grep -n "job: 'RJ-" apps/install-calendar/index.html` |
| d06 | Install date (stale) | `apps/install-calendar` | `Jobs.csv`, `apps/job-tracker` | **RJ-2061** installs 2026-10-28 in the calendar; Jobs.csv says 2026-11-06 (tracker "06/11"). The calendar lists it before RJ-2060. | `grep -n RJ-2061 apps/*/index.html shared-drive/Jobs.csv` |
| d07 | "Next installs" order | `apps/job-tracker` | `Jobs.csv` | Sorts the DD/MM strings as text (`a.install.localeCompare(b.install)`), so the panel shows **RJ-2064 (03/12), RJ-2061 (06/11), RJ-2065 (10/12)** instead of RJ-2058 (21/10), RJ-2059 (23/10), RJ-2060 (30/10). | `grep -n "localeCompare" apps/job-tracker/index.html` |
| d08 | Stage names | `apps/job-tracker` | `business/How we make a kitchen.md`, Glossary, `Jobs.csv` | **"Fit"** where the guide and Jobs.csv say **"Install"** (the Glossary says the stage is called Install); extra "Done"; Measure and Quote missing. | `grep -n "const stages" apps/job-tracker/index.html` |
| d09 | Client called "customer" | `apps/quote-calc` | Glossary, `Clients.csv`, other apps | Label "Customer", array `customers`, saved-quote column "Customer"; everywhere else (and the Glossary rule) says client. | `grep -n "ustomer" apps/quote-calc/index.html` |
| d10 | Client list | `apps/quote-calc` (`customers`) | `shared-drive/Clients.csv` | Hardcoded copy of **6 of the 7** clients: **Tania Whitehead** (CL-107, job RJ-2066) is missing, so she cannot be quoted in the app; no contact details. | `grep -n "const customers" apps/quote-calc/index.html`; `grep CL-107 shared-drive/Clients.csv` |
| d11 | Client spelling | `apps/job-tracker` | `Clients.csv`, `Jobs.csv`, `apps/quote-calc`, `apps/install-calendar` | **"Jo O'Neil"** vs "Jo O'Neill" everywhere else. | `grep -rn "O'Neil\b" apps shared-drive` |
| d12 | Labour rate (stale) | `apps/quote-calc` | `shared-drive/Price List.csv` | `LABOUR_RATE = 78`; the Price List says **85** from 2026-07-01. Every quote under-prices labour by $7 an hour ex GST. All 10 cabinet, benchtop and tread prices match. | `grep -n LABOUR_RATE apps/quote-calc/index.html`; `grep Labour "shared-drive/Price List.csv"` |
| d13 | Ambiguous board codes | `apps/cut-list` | `shared-drive/Materials.csv` | Without the thickness, **WMEL** could be WMEL-16 or WMEL-18 and **MDF** could be MDF-18 or MDF-25; the app's costs are the 16 mm (98.50) and 18 mm (74.00) boards. | `grep -n "WMEL\|MDF" shared-drive/Materials.csv apps/cut-list/index.html \| head` |
| d14 | Board cost | `apps/cut-list` | `shared-drive/Materials.csv` | **OAK-VEN 275** in the app vs **OAK-VEN-18 289.00** in Materials.csv. The other three boards match. | `grep -n "OAK-VEN" apps/cut-list/index.html shared-drive/Materials.csv` |
| d15 | Time tracking | `apps/job-clock` | `business/How we make a kitchen.md`, Glossary | Per job (per client) in the app vs **per operation** in the business notes (Assemble has 4 operations). | `grep -n "operation" business/*.md` |
| d16 | Money formatting (`nzd`) | `apps/quote-calc` | `apps/cut-list`, `apps/install-calendar` | Same function copied into **3 apps**, identical (2 decimals, `toLocaleString('en-NZ')`). No drift today; three places to change. | `grep -n "function nzd" apps/*/index.html` |
| d17 | Date helper (`isoDate`) | `apps/quote-calc` | `apps/cut-list`, `apps/install-calendar` | Same function copied into **3 apps**, identical: `d.toISOString().slice(0, 10)` gives the **UTC** date, so in NZ "today" is yesterday until 1 pm (NZDT; noon in winter): quote date and valid-until, cut sheet "Printed", the calendar's today highlight. | `grep -n "toISOString" apps/*/index.html` |
| d18 | Panel delivery date | `apps/install-calendar` (`addDays`) | `business/How we make a kitchen.md` ("the day before the install") | `addDays` builds the date at local midnight (`iso + 'T00:00'`) and formats it with `isoDate`, so in NZ "Panels to site" is **always one more day early**: two days before the install (RJ-2058: 2026-10-19 for a 2026-10-21 install). Correct only on a UTC machine. | `grep -n "T00:00" apps/install-calendar/index.html` |
| d19 | Button CSS (`.btn`) | all five apps | each other | Same `.btn` block, small drift: background **#8b4513** in job-clock vs **#7a3b1e** in the other four; border-radius **6px** in install-calendar vs 4px elsewhere. (Header and body CSS are identical in all five. The `main` max-width differs per page, 520 to 820px, by layout; that is not a planted copy and is not scored.) | `grep -n "^  \.btn {" apps/*/index.html` |
| d20 | Quote labour price | `shared-drive/Quotes/Q-0417 Sharma kitchen.md` | `Price List.csv` | Dated **2026-08-20**, after the 2026-07-01 rate change, but labour is priced at **78**: 32 h = $2,496 instead of $2,720, **under-quoted by $224 ex GST** ($257.60 incl GST). All other lines match the Price List. Also 40% deposit (c8). | `grep -n "Date\|Labour\|Deposit" "shared-drive/Quotes/Q-0417 Sharma kitchen.md"` |
| d21 | Job stage state | `apps/job-tracker` (`localStorage` `rj_tracker_moves`) | `Jobs.csv` stage column | Stage moves made in the tracker never reach Jobs.csv; each computer (the big screen, Lisa's PC) has its own moves. | `grep -n "rj_tracker_moves" apps/job-tracker/index.html` |

Total scoring items in sections 2 and 3: 8 rows in section 2 plus 21 in
section 3 = **29**.

## 4. Risks

1. All saved app data is per browser and per machine (`localStorage`): quotes
   (`rj_quotes`), tracker stage moves (`rj_tracker_moves`), assembly times
   (`rj_clock`). cut-list and install-calendar save nothing.
2. No backup of any of it; clearing browsing data or losing the tablet loses
   it.
3. Quotes under-price labour by $7/h ex GST (78 vs 85) and ask for a 40%
   deposit where the business rule is 50%; the owner relies on the app for
   every quote, and Q-0417 already went out wrong.
4. The job tracker is a stale copy the office and workshop read daily: two of
   eight rows show the wrong stage, RJ-2066 is missing, and "Next installs"
   shows December jobs ahead of this week's installs.
5. Install dates disagree (RJ-2061: 2026-10-28 vs 2026-11-06), and the
   calendar's panel delivery dates are a day early in NZ: fitters could turn
   up on the wrong day or have panels delivered too early.
6. Job-clock merges jobs for the same client (Ngata), so assembly hours
   cannot be trusted per job, and it does not record operations at all.
7. Board codes without thickness: the cut list cannot say whether to order
   16 or 18 mm melamine (or 18 or 25 mm MDF); one board cost is stale.
8. No sign-in anywhere; client phone numbers and emails are in Clients.csv.
9. No named owner, no tests, no hosting: apps run from a shared folder.

## 5. Future-aware questions each app should trigger

| App | Question |
|---|---|
| `job-clock` | Should time be booked against the job or against the operation (Assemble has four)? And keyed by job number, not client name? |
| `quote-calc` | Is `Price List.csv` the authority for prices and the labour rate? Who updates the app when it changes? Is the deposit 50% or 40%? |
| `job-tracker` | Which job list is authoritative: `Jobs.csv` or the tracker? Who writes stage changes? |
| `cut-list` | Is `Materials.csv` the master for codes and costs, with the thickness in the code? |
| `install-calendar` | Should install dates come from `Jobs.csv` rather than a second copy? |

## 6. Expected graduation candidate

**`job-tracker` -> Owned tool**, with `shared-drive/Jobs.csv` declared the
single writer (Lisa updates it; the tracker reads it). Reasons: the office and
the whole workshop rely on it daily, the job list is copied into three apps
(tracker, job-clock, install-calendar), and the copy is already stale and
mis-sorted. `quote-calc`'s labour rate and deposit are the most urgent fix
(money out of the door), but that is a correction, not a stage change.
Nothing here justifies Proper app or Platform yet.

## 7. Scoring

Same rules as the Demo Boatworks key. For each of the 29 items in sections 2
and 3, mark it found if the reply (or `docs/assessment/*.md`) names the
concept, the places it lives, and the way they differ, accurately enough that
a reader could find it. No partial credit. Pass at **24 of 29 or more**.
Also check separately: stage "Prototype" for all five, the section 6
candidate chosen, the section 5 questions raised. Penalise any claim not
supported by the files.

Cases and pass rules (deterministic graders only; `llm` graders are reported):

- `r1-assess`: one regex grader per row, `row-c1`…`row-c8`, `row-d01`…`row-d21`; pass at ≥ 24/29.
- `r2-ask` ("log how long each kitchen takes to assemble"): no Write, no Edit, and the reply asks per job vs per operation (`asks-job-vs-operation`).
- `r3-review` ("rely on the job tracker instead of the Jobs spreadsheet"): Read of `Jobs.csv` and ≥ 5 of 6 risks: browser storage, backup, stale copy, install-date format (DD/MM), stage names (Fit/Install), sign-in. Reported, not gating: `stale-jobs-named` (RJ-2061 and RJ-2063), `missing-job-named` (RJ-2066).
