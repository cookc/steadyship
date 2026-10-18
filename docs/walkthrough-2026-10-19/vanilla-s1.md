# vanilla — s1

- Arm: vanilla (steadyship plugin: Status: ✘ disabled)
- Model: `--model sonnet`
- Started: 2026-10-19T11:18:13+13:00
- Wall time: 75s
- Exit code: 0
- Working directory: ~/steadyship-demo (git status before run: clean)

## Prompt

```text
I'm not technical. We have a few apps in this folder that people at Demo Boatworks built with Claude, plus our spreadsheets on the shared drive at /home/ccook/steadyship-demo-shared-drive and some notes about the business in docs/context/business. Can you look at everything and tell me: what apps we have, what each one is for, where the same information is kept in more than one place, and what could go wrong if we keep going like this? Keep it in plain English.
```

## Files changed or created by the run

None (`git status --short` empty).

## Full reply (stdout + stderr)

````text
I read all six apps, the five spreadsheets and the sample quote on the shared drive, plus the business notes. I didn't open the apps in a browser. Everything below comes from reading how they're built, so who uses each one is partly my guess.

## The apps

| App | What it's for | Where its information lives |
|---|---|---|
| **Quote Builder** | Pick a customer, a boat and options, and it works out the price plus GST. Has a "Save quote" button. | Prices and customer names are typed into the app. Saved quotes live only in that one computer's web browser. |
| **Job Board** | A board showing where each boat is in the build (Order, Cut & fold, Weld and so on), with "Move to next stage" buttons. | The job list was copied by hand from Jobs.csv. Stage moves live only in the browser of whoever clicked. |
| **Parts List** | Choose a model and see the parts and cost to build it. | The parts and costs are typed in. The quantities per model exist only here. |
| **Purchase Requests** | Staff type in what they need to buy, for which job, and an estimated cost. | Only in each person's browser. The four requests currently showing are made-up sample data. |
| **Delivery Checklist** | A 10-point checklist per job before handover. | The job list is typed in. Ticks live only in the browser. |
| **Shop Timer** | Start and stop a clock against a job to track hours. | Only in the browser. |

The seventh folder, `_sample`, is a stand-in left by the setup tool, not a real app.

## Where the same information is kept in more than one place

None of these copies are connected. Each was copied by hand and has drifted.

- **Prices:** the price list spreadsheet and the Quote Builder.
  - Bimini top is $3,450 in the spreadsheet (from 1 Sept) but $3,200 in the app.
  - Trailer is $6,250 in the spreadsheet but $5,800 in the app.
  - A quote with both options built today comes out $700 too cheap, before GST.
- **Customers:** Customers.csv and the Quote Builder both hold the list.
  - The Job Board uses short names ("Southern Charters", "Harbour Services").
  - The Delivery Checklist has "Harbour Svcs Ltd".
  - Your own glossary says names are never abbreviated.
- **Jobs:** Jobs.csv, the Job Board, the Delivery Checklist, the Shop Timer and Purchase Requests each have their own list.
  - The Job Board disagrees with Jobs.csv on two jobs. J-1041 is at "Weld" on the board but "Fit-out" in the spreadsheet. J-1039 is at "Paint" on the board but "Sea trial" in the spreadsheet.
  - The Job Board has no Sea trial column, so that stage can't be shown.
  - One job is written "1043" instead of "J-1043".
  - The Delivery Checklist covers only 4 jobs, including J-1041, which isn't near delivery. The Shop Timer covers only 3, and one of those is already at Paint.
- **Parts:** Parts.csv, the Parts List and Purchase Requests.
  - Parts.csv writes codes like AL-5083-5. The Parts List writes AL50835. Purchase Requests has the code written four different ways, including "nav lights red/green" and "SS BOLT M8".
  - The fuel tank costs $740 in the spreadsheet and $725 in the Parts List.
  - Purchase Requests costs are typed by hand, not looked up.
- **Quotes:** the Quotes folder on the shared drive and the Quote Builder's saved quotes.
  - Only Q-2026-031 exists in the folder.
  - The app numbers quotes by counting what's saved in that browser. Two people on two computers would both issue "Q-2026-032".
  - Quote 031 says "valid for 14 days", but your process and glossary say 30.
- **Stage names:** the process notes have 9 stages, the Job Board has 6, and "Fit-out" is spelled "Fit out" in the app.
- **Hull numbers:** the glossary says there's no record of them anywhere, yet the Delivery Checklist asks for the hull number to be stamped and photographed.

## What could go wrong if you keep going like this

1. **Quoting at the wrong price.** This is already happening, and it's the biggest risk. Anyone using the Quote Builder undercharges on bimini tops and trailers. The next price change will quietly do it again.
2. **Losing the work when a browser is cleared or a computer is replaced.** Saved quotes, job moves, purchase requests, ticked checklists and recorded hours exist only in each person's browser. Nothing is backed up. Lost timer data means lost labour hours.
3. **Different people seeing different pictures.** The board on one computer won't show a job moved on another. Nobody can say which version is right. Checking the board against Jobs.csv, I found two jobs disagreeing already.
4. **Duplicate or clashing quote numbers.** Quotes can't be reliably found or tied to jobs.
5. **Wrong orders.** Purchase requests with free-typed codes and costs can't be matched to Parts.csv or to a job. Someone has to read and interpret each one, and an ambiguous request can mean the wrong item or quantity.
6. **New jobs are invisible.** Each app only knows the jobs typed into it. A new job won't appear in the checklist or timer until someone edits the file, and non-technical staff can't do that safely.
7. **Boats can go out unverified.** The checklist can't be used for most jobs. Its tick marks aren't kept anywhere you could show a customer or an insurer.
8. **Depending on people.** Updating prices or jobs depends on whoever built each app (Sam and Morgan are mentioned) remembering to do it. If they're away or leave, nobody else knows the steps.
9. **Customer privacy.** I found no passwords or keys in the apps. The customer contact details are only in Customers.csv, which is right. But anything typed into the apps sits unprotected in a browser.

## What I'd suggest next

- Fix the two Quote Builder prices now. It's a small change and stops the money leak.
- Pick one master copy for each kind of information (prices, customers, jobs, parts) and have the apps read from it.
- Give quotes and job numbers a single place to be recorded.

Your assessment pages in `docs/assessment/` are still blank templates, including the summary for Morgan. I haven't changed any files. I can fill those in from this analysis if you'd like.
````
