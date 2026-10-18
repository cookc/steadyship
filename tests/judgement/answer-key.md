# Answer key: Demo Boatworks

Ground truth for scoring the `assess` skill (and later `ask` / `review`). Every
row can be checked by reading the named file. Do not show this file to the
skill under test (it lives here, outside `plugin/`, so an installed plugin
cannot read it). Paths are relative to `plugin/demo/`.

## 1. Apps, stage, and who relies on them

All six are stage **Prototype**: one HTML file, data hardcoded or in the
browser's `localStorage`, no tests, no named owner, no sign-in.

| App | What it does | Relied on by | Data lives in |
|---|---|---|---|
| `apps/quote-builder` | customer + model + options -> price with GST | Morgan Reid (owner) | hardcoded prices; saved quotes in `localStorage` key `quotes` |
| `apps/job-board` | jobs in columns by stage; "Move to" buttons | the whole workshop, daily | hardcoded `jobs` array; stage moves in `localStorage` key `jobboard_stages` |
| `apps/shop-timer` | start/stop timer per job | the builders on the floor (their own use) | hardcoded 3 jobs; `localStorage` key `timers` |
| `apps/parts-list` | parts and cost per model | the purchasing builder | hardcoded `parts` and `bom` |
| `apps/delivery-checklist` | per-job delivery QA ticks | the delivery builder | hardcoded 4 jobs; `localStorage` keys `checklist-<job>` (e.g. `checklist-J-1038`) |
| `apps/purchase-requests` | staff raise purchase requests | the purchasing builder and requesters | `localStorage` key `pr`, seeded with 4 requests |

## 2. Shared concepts and where each lives

| Concept | Places | Variants |
|---|---|---|
| **Customer** (5 places, 3 spellings of Harbour Services) | `shared-drive/Customers.csv`; `shared-drive/Jobs.csv`; `apps/quote-builder` (`customers`); `apps/job-board` (`jobs[].customer`); `apps/delivery-checklist` (`jobs[].customer`) | "Harbour Services Ltd" (Customers.csv, Jobs.csv, quote-builder); "Harbour Services" (job-board); "Harbour Svcs Ltd" (delivery-checklist J-1041). Job-board drops "Ltd" from every customer. delivery-checklist has "Southern Charters" (no Ltd) for J-1038 but "Kaipara Fishing Co Ltd" for J-1040. The Glossary says customers are never abbreviated. |
| **Job** (5 places, 2 number formats) | `shared-drive/Jobs.csv` (8 jobs); `apps/job-board` (8 jobs); `apps/shop-timer` (J-1040, J-1041, J-1042); `apps/delivery-checklist` (J-1038 to J-1041); `apps/purchase-requests` (free-text "For job") | "J-1041" form everywhere except `1043` in job-board and `1040` in the second seeded purchase request. |
| **Model** (3 places hold the master name; 2 spellings) | `shared-drive/Price List 2026.csv`; `apps/quote-builder` (`models`); `apps/parts-list` (`bom` keys); also named in `Jobs.csv` and `apps/delivery-checklist` | Full "WB 6.2 Workboat" in Price List, Jobs.csv, quote-builder, delivery-checklist; short "WB 6.2" in parts-list. Glossary says models are written in full. |
| **Part** (3 places, 2 code formats) | `shared-drive/Parts.csv` (10 parts); `apps/parts-list` (8 parts); `apps/purchase-requests` (free-text "Item code") | Hyphenated "AL-5083-5" (Parts.csv, one seeded purchase request, Glossary); unhyphenated "AL50835" (parts-list, second seeded request); free text "nav lights red/green" and "SS BOLT M8" in purchase-requests. Parts.csv has AL-6082-FB50 and PAINT-AF-5L which parts-list lacks. |
| **Operation** (1 place) | only `business/How we build a boat.md` (2 to 4 named operations per stage) | No app records an operation. `apps/shop-timer` records time against a job. The Glossary and "How we build a boat" both say time is booked against the operation. |
| **Price** (2 places, 2 values differ) | `shared-drive/Price List 2026.csv`; `apps/quote-builder` (`options`); also `shared-drive/Quotes/Q-2026-031 Harbour Services.md` | "Bimini top": 3,450 in the Price List (effective 2026-09-01) vs 3,200 in quote-builder (and in Q-2026-031). "Trailer": 6,250 vs 5,800 (same). All other model and option prices match. |
| **Stage** (3 places, 2 spellings) | `business/How we build a boat.md` (9 stages); `shared-drive/Jobs.csv` (uses 7 of the same names); `apps/job-board` (`stages`) | job-board has 6 stages, spells "Fit out" not "Fit-out", and has no "Sea trial" (or Enquiry, Quote). |
| **Quote validity** | `business/Glossary (draft).md`; `business/How we build a boat.md`; `shared-drive/Quotes/Q-2026-031 Harbour Services.md` | 30 days in the Glossary and How we build a boat; 14 days in Q-2026-031. |
| **Hull number** | `business/Glossary (draft).md`, `business/How we build a boat.md` | Defined, never recorded in any app or CSV. (`apps/delivery-checklist` has a tick for "Hull number stamped" but stores no number.) |

## 3. Planted duplications and inconsistencies

Each row is one item for scoring. Format: concept/screen, in app, also in,
same data / same logic / differs how.

| # | Concept / screen | In | Also in | Same or differs |
|---|---|---|---|---|
| 1 | Job list | `shared-drive/Jobs.csv` | `apps/job-board` | Same 8 jobs, but a hardcoded copy; stale: J-1039 shows "Paint" (CSV: Sea trial) and J-1041 shows "Weld" (CSV: Fit-out) |
| 2 | Job number format | `apps/job-board` | `shared-drive/Jobs.csv` | Job 1043 written "1043", CSV says "J-1043"; the two lists cannot be joined on job number |
| 3 | Job list | `apps/shop-timer` | `Jobs.csv`, `apps/job-board` | Own copy, 3 jobs only (J-1040 to J-1042), labels like "Kaipara WB 6.2" instead of customer + model |
| 4 | Job list | `apps/delivery-checklist` | `Jobs.csv`, `apps/job-board` | Own copy of 4 jobs (J-1038 to J-1041), carries customer and model |
| 5 | Job reference | `apps/purchase-requests` | `Jobs.csv` | Free-text, "J-1042" vs "1040" for the same style of reference |
| 6 | Stage names | `apps/job-board` | `business/How we build a boat.md`, `Jobs.csv` | "Fit out" vs "Fit-out"; "Sea trial", "Enquiry", "Quote" missing from the board |
| 7 | Customer name | `apps/job-board` | `Customers.csv`, `quote-builder`, `delivery-checklist` | Same customers, "Ltd" removed on the board; "Harbour Svcs Ltd" in delivery-checklist; "Southern Charters" without Ltd in delivery-checklist |
| 8 | Customer list | `apps/quote-builder` (`customers`) | `shared-drive/Customers.csv` | Hardcoded copy, same 6 names; no contact details; updates to Customers.csv will not reach the picker |
| 9 | Price list | `apps/quote-builder` | `shared-drive/Price List 2026.csv` | Hardcoded copy; two prices stale: Bimini top 3,200 vs 3,450; Trailer 5,800 vs 6,250 |
| 10 | Part codes | `apps/parts-list` | `shared-drive/Parts.csv` | "AL50833" vs "AL-5083-3" (all 8 codes lose their hyphens); two Parts.csv parts absent |
| 11 | Part price | `apps/parts-list` | `shared-drive/Parts.csv` | FUELTK120 costs 725.00 in the app; FUEL-TK-120 costs 740.00 in the CSV |
| 12 | Item code | `apps/purchase-requests` | `Parts.csv`, `apps/parts-list` | Free text; matches Parts.csv in one seeded row, parts-list codes in another, neither in the rest; no lookup |
| 13 | Money formatting (`money`) | `apps/quote-builder` | `apps/parts-list` | Same logic, copied: 2 decimals and thousands separators ("$86,500.00") |
| 14 | Money formatting (`fmtMoney`) | `apps/purchase-requests` | `quote-builder`, `parts-list` | Differs: rounds to whole dollars, no separators ("$2072"); 3 copies, one is buggy |
| 15 | Header CSS block | all six apps | each other | Same `header` block, small drift: background `#0b3d5c` (quote-builder, job-board, parts-list, purchase-requests), `#0c3c5a` (shop-timer), `#0a3d62` (delivery-checklist); padding `.5rem 1rem` in parts-list, `.6rem 1rem` elsewhere; delivery-checklist uses Verdana, the rest Arial |
| 16 | Date handling (`new Date().toISOString().slice(0, 10)`) | `quote-builder`, `job-board`, `purchase-requests` | each other | Same logic copied; gives UTC date, wrong near NZ midnight |
| 17 | Job stage state | `apps/job-board` (`localStorage` `jobboard_stages`) | `Jobs.csv` stage column | Stage moves made on the board never reach Jobs.csv; each machine sees its own board |
| 18 | Time tracking | `apps/shop-timer` | `business/How we build a boat.md`, Glossary | Per job (the app) vs per operation (the business docs) |
| 19 | Quote validity | `Q-2026-031` | Glossary, How we build a boat | 14 days vs 30 days |
| 20 | Quote prices | `Q-2026-031` | `Price List 2026.csv` | Quoted on the stale Bimini top and Trailer prices (under-quoted by 700 ex GST against the current list) |

Item 20 is dated: the quote was written 2026-06-02, before the 2026-09-01
price change, so it was correct then. It matters because quote-builder still
produces those prices.

Total scoring items in sections 2 and 3: 9 rows in section 2 plus 20 in
section 3 = **29**.

## 4. Risks

1. All app data in `localStorage` is per browser and per machine: quotes
   (`quotes`), timers (`timers`), board stage moves (`jobboard_stages`),
   delivery ticks (`checklist-<job>`), purchase requests (`pr`).
2. No backup of any of it; clearing browser data loses it.
3. Quote prices are stale in quote-builder (Bimini top, Trailer); the owner
   relies on it, so new quotes under-price those two items by 250 and 450 ex
   GST.
4. Job numbers are inconsistent ("1043" vs "J-1043"), so the lists cannot be
   joined by a script or a spreadsheet lookup.
5. Delivery-checklist ticks are lost if the browser cache is cleared; a boat
   could be delivered with an unrecorded or forgotten check.
6. Purchase requests never reconcile to parts: free-text codes mean nobody can
   total demand by part, or compare with Parts.csv costs.
7. Job-board is a stale copy that the whole workshop reads daily: two of eight
   rows show the wrong stage today.
8. No sign-in anywhere; quote and pricing data are readable by anyone with the
   file. Customer contact names and phone numbers are in Customers.csv.
9. No named owner, no tests, no hosting: apps run from a synced folder.

## 5. Future-aware questions each app should trigger

| App | Question (the assess skill should raise it, or flag the underlying issue) |
|---|---|
| `shop-timer` | Should time be booked against the job or against the operation? (The business docs say operation; the app uses job.) |
| `quote-builder` | Is `Price List 2026.csv` the authority for prices? Who updates the app when it changes? |
| `job-board` | Which job list is authoritative: `Jobs.csv` or the board? Who writes stage changes? |
| `purchase-requests` | Should "item code" be the part code from `Parts.csv`? |
| `parts-list` | Is `Parts.csv` the master for part codes and costs? |
| `delivery-checklist` | Should checklist results be stored with the job so they survive a cleared browser, and is there a hull number to record? |

## 6. Expected graduation candidate

**`job-board` -> Owned tool**, with `shared-drive/Jobs.csv` declared the single
writer (one named person updates it; the board reads it). Reasons: relied on
by the whole workshop daily (the Prototype -> Owned tool trigger), job data
copied into four apps, and the copy is already stale. Other apps stay
Prototype for now; shop-timer is the one to converge on the job concept next.
Nothing here justifies Proper app or Platform yet.

## 7. Scoring

The 80% criterion: take the assessment documents the skill produced
(`docs/assessment/*.md` and `SUMMARY.md`). For each of the 29 items in
sections 2 and 3, mark it found if the assessment names the concept, the
places it lives, and the way they differ (the "Variants" or "Same or differs"
column), accurately enough that a reader could find it. Partial credit is not
given. Pass at **24 of 29 or more** (24 / 29 = 83%). Also check separately:
the stage per app is "Prototype" for all six, the graduation candidate in
section 6 is chosen, and the future-aware questions in section 5 appear.
Penalise (do not count) any claim not supported by the files.
