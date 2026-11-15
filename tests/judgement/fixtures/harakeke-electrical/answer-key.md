# Answer key: Harakeke Electrical (held-out fixture)

Ground truth for scoring `assess` and `review` on the third mock business
(cases `tests/judgement/evals/h*`). Every row can be checked by reading the
named file; the **Verify** column gives a command that shows it (run from
this folder, `tests/judgement/fixtures/harakeke-electrical/`). Never show
this file to an agent under test: `run.sh` stages the fixture without it, and
the `no-peek` grader fails any run that reads a path matching `answer-key`.

**Held out.** This fixture, this key and the `h*` graders were written
without reading the Steadyship skills, standard or agents. The defects were
chosen from what goes wrong in home-made small-business software, not from
what the skills look for. The **Class** column says whether a row's kind of
defect also appears in the Demo Boatworks or Rimu Joinery key (**shared**) or
in neither (**new**): 19 new, 10 shared. The graders in `h1-assess` and
`h3-review` were written from this key alone and are frozen: do not widen
them after seeing a model's output.

Today in the fixture's world is 2026-11-16 (Monday). The last full pay week
is Monday 2026-11-09 to Sunday 2026-11-15.

## 1. Apps, stage, and who relies on them

All five are stage **Prototype**: one HTML file, data hardcoded or in the
browser's `localStorage`, no tests, no named owner, no sign-in. Who relies on
each comes from `business/About.md`.

| App | What it does | Relied on by | Data lives in |
|---|---|---|---|
| `apps/job-board` | jobs in columns by status, a status picker per card, "Today's jobs", red overdue cards, a CSV export box | the front office (TV) and every electrician each morning | hardcoded `jobs` (14 rows), hardcoded `TODAY`; status changes in `localStorage` key `he_board_status` |
| `apps/invoice-maker` | job + customer + call-out + hours + materials cost -> invoice lines, GST, trade discount, amount due | Kiri Walker, every invoice (office PC and her laptop) | hardcoded rates; saved invoices and the invoice number counter in `localStorage` key `he_invoices` |
| `apps/quick-quote` | labour hours + materials cost -> quote with GST | Hana Parata, on site | hardcoded `HOURLY` and `MATERIALS`; saved quotes in `localStorage` key `he_quotes` |
| `apps/timesheet` | hours per person per day per job; weekly pay run summary | everyone (workshop tablet); Kiri pays from it | hardcoded `staff` (7, with bank accounts), `jobList` (6 jobs), `HOLIDAYS`; entries in `localStorage` key `he_timesheet`, seeded with one week |
| `apps/van-stock` | stock, minimum and value per van | Brian Cole and the electricians | hardcoded `items` (9) and `stocktake` (18 rows); changes in `localStorage` key `he_vanstock` |

## 2. Shared concepts and where each lives

| # | Class | Concept | Places | Variants | Verify |
|---|---|---|---|---|---|
| c1 | new (duplicate record under two spellings, inside the master file) | **Customer** | `shared-drive/Customers.csv` (12 rows); `Jobs.csv`; `apps/job-board` (`jobs[].customer`); typed by hand in invoice-maker and quick-quote | The same cafe is in Customers.csv **twice**: **C-118 "Jetty Road Cafe"** (Jules, 03 555 0143, "14 Jetty Rd, Mapua") and **C-131 "Jetty Road Café Ltd"** (Jules Brennan, 021 555 0104, "14 Jetty Rd, Māpua"). Its jobs are split across the two names: HE-4127 under the first, HE-4134 under the second. The Glossary says one record each. | `grep -n "Jetty Road" shared-drive/Customers.csv shared-drive/Jobs.csv` |
| c2 | shared (job list copied into apps) | **Job** (4 places) | `shared-drive/Jobs.csv` (16 rows, HE-4124 to HE-4138); `shared-drive/Jobs (conflicted copy 2026-11-05 Kiri-Laptop).csv` (15 rows); `apps/job-board` (`jobs`, 14 rows); `apps/timesheet` (`jobList`: 6 job numbers plus "Call-out" and "Workshop") | The timesheet has its own typed-in list of **6 jobs** (HE-4129, HE-4131, HE-4133, HE-4134, HE-4135, HE-4136); a new job cannot have hours booked to it until someone edits the page. | `grep -n "const jobList" apps/timesheet/index.html`; `grep -c "no: 'HE-" apps/job-board/index.html`; `grep -c "^HE-" shared-drive/Jobs.csv` |
| c3 | shared (stale rate copied into an app) | **Labour rate** (3 places, 2 values) | `shared-drive/Price List.csv` (electrician **98**, from 2026-10-01); `apps/invoice-maker` (`RATE = 98`); `apps/quick-quote` (`HOURLY = 92`); also `Q-0352` (92) | Two apps each hardcode the hourly rate and already disagree: quotes go out at **92**, invoices at **98**. | `grep -n "RATE = \|HOURLY = " apps/*/index.html`; `grep -n "Labour - electrician" "shared-drive/Price List.csv"` |
| c4 | new (two apps work out the same figure differently) | **Materials markup** (3 places, 2 sums) | `shared-drive/Price List.csv` ("percent added to our cost", 20); Glossary and How a job runs (cost plus the markup); `apps/invoice-maker` (`cost * (1 + 0.20)`); `apps/quick-quote` (`cost / 0.8`) | Dividing by 0.8 is a 20% margin, which is **25% on cost**, not 20%. The same $480.00 of materials is **$600.00** on a quote and **$576.00** on an invoice. Q-0352 shows it: "our cost 480.00, plus markup" = 600.00. | `grep -n "MARKUP\|MATERIALS" apps/invoice-maker/index.html apps/quick-quote/index.html`; `grep -n "Materials" "shared-drive/Quotes/Q-0352 Hollis garage.md" "shared-drive/Price List.csv"` |
| c5 | new (GST-inclusive price treated as GST-exclusive) | **Call-out fee** (3 places) | `shared-drive/Price List.csv` (115.00, `gst` column **incl**, the only incl row); `business/How a job runs.md` ("$115 including GST"); `apps/invoice-maker` (`CALLOUT = 115`, added to the subtotal before GST) | The app adds 15% GST on top of a price that already includes it: the customer pays **$132.25** for the call-out, not $115 (**$17.25 too much** every call-out). `INV-1187 Hollis` shows it: call-out 115.00 in the ex-GST lines; total 376.51 where it should be 359.26. | `grep -in "call-out" "shared-drive/Price List.csv" "business/How a job runs.md" "shared-drive/Invoices/INV-1187 Hollis.md"`; `grep -n "CALLOUT" apps/invoice-maker/index.html` |
| c6 | new (unit mix-up) | **Cable quantity and unit** (4 places, 2 units) | `shared-drive/Materials.csv` (CAB-TPS-2.5 and CAB-TPS-1.5: unit **m**, 3.12 and 2.18 a metre); `shared-drive/Van stocktake 2026-10-30.csv` (qty in **m**); Glossary ("Cable is counted in metres"); `apps/van-stock` (`unit: 'roll'`, cost 312.00 and 218.00, `min: 1`) | van-stock takes the stocktake's metres as **rolls**: Van 1's 60 m of 2.5 mm cable shows as "60 roll" worth $18,720.00 (really $187.20). All vans show **$150,272.90** of stock; priced from Materials.csv the stocktake is worth **$3,652.10**. A van can never show low on cable (35 "rolls" is above the minimum of 1). | `grep -n "CAB-TPS" apps/van-stock/index.html shared-drive/Materials.csv "shared-drive/Van stocktake 2026-10-30.csv"`; `awk -F, 'NR==FNR{c[$1]=$4;next} FNR>1{t+=$3*c[$2]} END{printf "%.2f\n",t}' shared-drive/Materials.csv "shared-drive/Van stocktake 2026-10-30.csv"` (3652.10) |
| c7 | shared (state saved in one browser, never reaches the master file) | **Job status** (2 places) | `shared-drive/Jobs.csv` (`status` column, kept by Kiri); `apps/job-board` (`localStorage` `he_board_status`) | A status changed on the job board is saved on that device only: the office TV, Kiri's PC and each electrician's phone each have their own, and none of it reaches Jobs.csv. | `grep -n "he_board_status" apps/job-board/index.html` |

## 3. Planted duplications and inconsistencies

Each row is one item for scoring. Format: concept/screen, in, also in, same
data / same logic / differs how.

| # | Class | Concept / screen | In | Also in | Same or differs | Verify |
|---|---|---|---|---|---|---|
| d01 | shared (stale hand copy) | Job list (stale statuses) | `apps/job-board` | `Jobs.csv` | Hardcoded copy ("copied from Jobs.csv on 11 Nov"); two rows stale: **HE-4129** board "Booked", CSV "In progress"; **HE-4133** board "In progress", CSV "Waiting on parts". The other twelve rows agree. | `grep -n "HE-4129\|HE-4133" apps/job-board/index.html shared-drive/Jobs.csv` |
| d02 | shared (stale hand copy, missing rows) | Job list (missing rows) | `apps/job-board` | `Jobs.csv` | Board has 14 rows, CSV has 16: **HE-4137** (Sarah Whitcombe, 23 Nov) and **HE-4138** (Lower Queen Vets, 24 Nov) are not on the board. | `grep -c "no: 'HE-" apps/job-board/index.html`; `grep -n "HE-413[78]" apps/job-board/index.html shared-drive/Jobs.csv` |
| d03 | new (duplicate ID in the master file) | Job number | `shared-drive/Jobs.csv` | `apps/job-board`, `apps/timesheet`, `Q-0352`, Glossary ("One number, one job") | **HE-4131** is two different jobs: Hartley Road School "Classroom 6 - LED lighting upgrade" (Tom Bryant, In progress) and Richard Hollis "Garage sub-board and three outlets" (Emma Clarke, Booked). The job board saves status by job number, so changing one changes both; hours booked to HE-4131 in the timesheet cannot be told apart. | `grep -n "HE-4131" shared-drive/Jobs.csv apps/*/index.html`; `grep -n "saved\[j.no\]" apps/job-board/index.html` |
| d04 | new (two diverging copies of the master file) | Jobs spreadsheet | `shared-drive/Jobs (conflicted copy 2026-11-05 Kiri-Laptop).csv` | `shared-drive/Jobs.csv` | A second copy of the master. It holds a booked job the master does not have: **Greg Tanner, "Replace outdoor sensor light", Dylan Fraser, 2026-11-25**, numbered **HE-4137**, the number the master has since given to Sarah Whitcombe. (The copy's older statuses are just its age and are not scored.) | `grep -n "Tanner\|HE-4137" shared-drive/Jobs*.csv` |
| d05 | new (hard-coded date left in from testing) | "Today" | `apps/job-board` | the real date | `const TODAY = '2026-11-02'` is fixed. "Today's jobs" always looks at 2 November (no job that day, so it says "No jobs today"), and a card only turns red if it was due before 2 November: on 16 November nothing is red, though HE-4129, HE-4131 (school) and HE-4133 are open and past their date. | `grep -n "TODAY" apps/job-board/index.html` |
| d06 | new (CSV written without quoting) | CSV export | `apps/job-board` ("Export list (CSV)") | `Jobs.csv` (addresses are quoted there) | Fields are joined with commas and nothing is quoted, and every address has a comma ("41 Main Rd, Stoke"), so each exported row has one or two columns too many and opens in a spreadsheet with the columns shifted. | `grep -n "join(',')" apps/job-board/index.html`; `grep -c '",' shared-drive/Jobs.csv` |
| d07 | new (sensitive data shown to everyone) | Customer access codes | `apps/job-board` (`access`, printed on every card) | `shared-drive/Customers.csv` (`access_notes`) | The board on the front-office TV and on every phone shows customers' **alarm, key safe, gate and lockbox codes** in full: Lower Queen Vets "Alarm 4471#", Marsh "Key safe 2580", Redwood Row Orchards "Gate code 1962", Hope Hall Society "Lockbox 7306". | `grep -n "Alarm\|Key safe\|Gate code\|Lockbox" apps/job-board/index.html` |
| d08 | new (spreadsheet stripped leading zeros) | Phone number | `shared-drive/Customers.csv` | - | Two phone numbers have lost their leading zero and spaces: **C-109** Aroha & Pete Marsh `275550161` (027 555 0161) and **C-122** Pokororo Lodge `35550148` (03 555 0148). The other ten are written "027 555 0138" style. | `awk -F, 'NR>1 && $4 !~ /^0/' shared-drive/Customers.csv` |
| d09 | new (discount and GST in the wrong order) | Trade discount | `apps/invoice-maker` | `business/How a job runs.md`, `Price List.csv` ("percent off the price before GST"), `INV-1184` | The app works out GST on the full subtotal, then takes 10% of the ex-GST subtotal off the GST-inclusive total. The GST line is too high and the customer over-pays. **INV-1184**: GST 51.87 and amount due **363.09**; discount first gives 311.22 + GST 46.68 = **357.90** (over by **5.19**). | `grep -n "discount\|const gst\|const total\|const due" apps/invoice-maker/index.html`; `grep -n "GST\|discount\|due" "shared-drive/Invoices/INV-1184 Saxton Property Management.md"` |
| d10 | new (ID collision from a per-browser counter) | Invoice number | `apps/invoice-maker` | `shared-drive/Invoices/` | The next number is `1181 +` the count of invoices saved in *this* browser, so the office PC and Kiri's laptop each count on their own. Two different invoices are both **INV-1187**: Richard Hollis (2026-11-05, 376.51) and Hartley Road School (2026-11-06, 2,036.88). | `ls shared-drive/Invoices`; `grep -n "'INV-'" apps/invoice-maker/index.html` |
| d11 | shared (a business rule the app does not follow) | Invoice before CoC | `apps/invoice-maker` (no CoC anywhere in it) | `business/How a job runs.md` ("No invoice goes out until the CoC number is on the job"), Glossary, `Jobs.csv` | The app invoices any job; nothing checks or records the CoC. It has already happened: **HE-4126** (Greg Tanner, EV charger circuit) is "Invoiced" with an empty `coc_no`. | `grep -n "HE-4126" shared-drive/Jobs.csv`; `grep -ci "coc" apps/invoice-maker/index.html` (0); `grep -n "CoC" business/*.md` |
| d12 | shared (a saved quote that was wrong when written) | Quote prices | `shared-drive/Quotes/Q-0352 Hollis garage.md` | `Price List.csv` | Dated **2026-10-20**, after the 2026-10-01 rate rise, but labour is at **92**: 14 h = 1,288.00 instead of 1,372.00, **84.00 under** ex GST. Its materials line is 600.00 where cost plus 20% is 576.00 (c4). Net 60.00 under ex GST. | `grep -n "Date\|Labour\|Materials" "shared-drive/Quotes/Q-0352 Hollis garage.md"` |
| d13 | new (typed value silently mis-read) | Hours typed as h:mm | `apps/timesheet` (`parseFloat(e.hours)`) | `business/Pay and timesheets.md` ("7.5 or 7:30. Both mean seven and a half hours") | `parseFloat('7:30')` is 7: the minutes are dropped with no warning. Seeded entry: **Wiremu Tipene, 2026-11-10, HE-4129, "7:30"** counts as 7, so his week shows **21.5** hours, not 22. | `grep -n "parseFloat\|7:30" apps/timesheet/index.html "business/Pay and timesheets.md"` |
| d14 | new (off-by-one in a date range) | Pay week | `apps/timesheet` | `business/Pay and timesheets.md` ("Monday to Sunday") | The week is `date >= start && date < end` with `end = start + 6 days`, so **Sunday is left out** (the heading still says "2026-11-09 to 2026-11-15"). Seeded entry: **Sione Faleolo, Sunday 2026-11-15, Call-out, 3 hours** is not listed or paid: his week shows 8 hours, not 11. | `grep -n "addDays(start, 6)\|e.date < end" apps/timesheet/index.html`; `grep -n "2026-11-15" apps/timesheet/index.html` |
| d15 | new (hard-coded year) | Public holidays | `apps/timesheet` (`HOLIDAYS`) | `business/Pay and timesheets.md` (public holiday = time and a half plus a day in lieu) | The list is the eleven **2025** dates only. No 2026 date (Labour Day was 2026-10-26) or later is ever treated as a public holiday. | `grep -n -A1 "const HOLIDAYS" apps/timesheet/index.html`; `grep -c "'2026-" <(grep -A1 "const HOLIDAYS" apps/timesheet/index.html)` (0) |
| d16 | new (personal data shown to everyone) | Staff bank accounts | `apps/timesheet` (`staff[].bank`) | - | All seven people's **bank account numbers** are in the page and printed in the "Pay run summary" table, on the workshop tablet everyone uses. | `grep -n "bank" apps/timesheet/index.html` |
| d17 | shared (a business rule the app does not follow) | Overtime | `apps/timesheet` (`DAY_HOURS = 8`) | `business/Pay and timesheets.md` ("hours over 40 in the week. A long day on its own is not overtime") | The app pays overtime on anything over **8 hours in a day**; the rule is over **40 in the week**. Seeded: **Tom Bryant** 9.5 h on 2026-11-12 gets **1.5 h overtime** in a 25.5 hour week (should be none). | `grep -n "DAY_HOURS" apps/timesheet/index.html`; `grep -n "Overtime" "business/Pay and timesheets.md"` |
| d18 | new (total silently skips unknown items) | Stock value | `apps/van-stock` | `shared-drive/Materials.csv` | **SWB-12W** (switchboard enclosure, 138.00) is in Van 2's stock but not in the app's `items`, so it falls back to cost 0: two of them (276.00) show as $0.00 and are left out of both totals without any warning; the row shows the code where the name should be. | `grep -n "SWB-12W\|cost: 0" apps/van-stock/index.html shared-drive/Materials.csv` |
| d19 | new (no floor on a count) | Stock quantity | `apps/van-stock` ("Used 1") | - | `s.qty -= 1` with no check: stock goes **below zero** (Van 3's one RCD, used three times, shows -2 and a value of -$96.00), and the negative value is subtracted from the totals. | `grep -n "qty -= 1" apps/van-stock/index.html`; `grep -c "Math.max\|qty > 0\|qty <= 0" apps/van-stock/index.html` (0) |
| d20 | shared (stale price copied into an app) | Item cost | `apps/van-stock` | `shared-drive/Materials.csv` | **RCD-2P-40** costs **48.00** in the app, **54.50** in Materials.csv. The other six "each" items match. | `grep -n "RCD-2P-40" apps/van-stock/index.html shared-drive/Materials.csv` |
| d21 | shared (data only in one browser) | Timesheet entries | `apps/timesheet` (`localStorage` `he_timesheet`) | - | Hours are saved in the browser of the device they were typed on. Anything entered on a phone never reaches the workshop tablet or Kiri's pay run summary; clearing the tablet's browser loses the week. | `grep -n "he_timesheet" apps/timesheet/index.html` |
| d22 | new (wrong variable: a rate that is defined but never used) | Apprentice rate | `apps/invoice-maker` | `shared-drive/Price List.csv` (apprentice **62**) | `APPRENTICE_RATE = 62` is defined and never used; apprentice hours are charged at `RATE` (**98**). **INV-1187 Hartley Road School**: apprentice 6 h at 98.00 = 588.00 instead of 372.00, **216.00 over** ex GST (248.40 incl GST). | `grep -n "APPRENTICE_RATE\|apprentice" apps/invoice-maker/index.html "shared-drive/Invoices/INV-1187 Hartley Road School.md" "shared-drive/Price List.csv"` |

Total scoring items in sections 2 and 3: 7 rows in section 2 plus 22 in
section 3 = **29** (19 new class, 10 shared class).

Not planted, true, and not scored (do not count for or against): the `nzd`,
`today` and `round2` helpers are copied between apps with identical code; the
quick-quote number counter is per browser like the invoice one (only Hana
uses it); the job-board export has no `coc_no` column; the Invoices folder
holds only the three invoices a customer asked for a copy of.

## 4. Risks

1. All saved app data is per browser and per device (`localStorage`): board
   status changes (`he_board_status`), invoices and the invoice counter
   (`he_invoices`), quotes (`he_quotes`), timesheet entries (`he_timesheet`),
   van stock (`he_vanstock`). No backup of any of it.
2. Money going out wrong on every invoice of that kind: call-out fee charged
   at $132.25 (c5), apprentice time at the electrician rate (d22), property
   manager over-charged and GST overstated (d09), and two invoices with the
   same number (d10).
3. Quotes and invoices disagree: 92 vs 98 an hour (c3), and materials at
   25% vs 20% on cost (c4). Q-0352 already went out wrong (d12).
4. Pay is wrong: minutes dropped from "7:30" (d13), Sunday call-outs never
   paid (d14), overtime paid by the day instead of over 40 hours (d17),
   public holidays stop at 2025 (d15). Bank accounts are on a shared tablet
   (d16).
5. The job board is a stale copy the office and every electrician read each
   morning: two wrong statuses, two jobs missing (d01, d02), "today" frozen
   at 2 November (d05), HE-4131 is two jobs sharing one status (d03), and it
   shows customers' alarm and key safe codes on the front-office TV (d07).
6. The master itself is not clean: a duplicate job number (d03), a
   conflicted copy with a booked job the master lacks (d04), a duplicate
   customer (c1), phone numbers without their leading zero (d08), a job
   invoiced without a CoC (d11).
7. Van stock value is wrong by a factor of about forty (cable in rolls, c6),
   with one item at $0 (d18), one stale cost (d20) and stock that can go
   negative (d19).
8. No sign-in anywhere; no named owner, no tests, no hosting: the apps run
   from a shared folder.

## 5. Future-aware questions each app should trigger

| App | Question |
|---|---|
| `job-board` | Which job list is the real one: `Jobs.csv`, the conflicted copy, or the board? Who writes status changes? Should access codes be on a screen in the front office at all? |
| `invoice-maker` | Is `Price List.csv` the authority for rates, and which prices include GST? Who gives out invoice numbers when two computers are used? Should it refuse a job with no CoC? |
| `quick-quote` | Should a quote and an invoice use the same rates and the same materials sum? |
| `timesheet` | Where do the hours need to end up so Kiri sees all of them? Is overtime by the day or the week? Do bank accounts belong in it? |
| `van-stock` | Is `Materials.csv` the master for codes, units and costs? Is cable counted in metres or rolls? |

## 6. Expected graduation candidate

**`job-board` -> Owned tool**, with `shared-drive/Jobs.csv` declared the
single master (Kiri updates it; the board reads it), after the master is
cleaned up (HE-4131, the conflicted copy). Reasons: the office and every
electrician rely on it daily, and the job list is copied into two apps
(board, timesheet). `invoice-maker` is the most urgent *fix* (wrong money on
real invoices) and `timesheet` the next (wrong pay); both are corrections,
not stage changes. Nothing here justifies Proper app or Platform yet.

## 7. Scoring

Same rules as the other two keys. For each of the 29 items in sections 2 and
3, mark it found if the reply (or `docs/assessment/*.md`) names the concept,
the places it lives, and the way they differ, accurately enough that a reader
could find it. No partial credit. Pass at **24 of 29 or more**. Also check
separately: stage "Prototype" for all five, the section 6 candidate chosen,
the section 5 questions raised. Penalise any claim not supported by the
files.

Cases and pass rules (deterministic graders only; `llm` graders are reported):

- `h1-assess`: one regex grader per row, `row-c1`...`row-c7`, `row-d01`...`row-d22`; pass at >= 24/29.
- `h3-review` ("rely on the job board instead of the Jobs spreadsheet"): Read of `Jobs.csv` and >= 5 of 6 risks: browser storage (c7), stale copy (d01/d02), duplicate job number HE-4131 (d03), fixed "today" (d05), access codes on show (d07), export breaks on commas (d06). Reported, not gating: `stale-jobs-named` (HE-4129 and HE-4133), `missing-job-named` (HE-4137 or HE-4138), `conflicted-copy-named`.
