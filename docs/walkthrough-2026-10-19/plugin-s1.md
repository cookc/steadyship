# plugin — s1

- Arm: plugin (steadyship plugin: Status: ✔ enabled)
- Model: `--model sonnet`
- Started: 2026-10-19T11:21:09+13:00
- Wall time: 43s
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
I read all six apps, the four spreadsheets, the one saved quote and the three business notes. I didn't change anything. I read the apps' code but didn't run them, and I don't know who uses each one or how they open it.

## The apps

| App | What it's for |
|---|---|
| **Quote Builder** | Pick a customer, a boat model and options. It adds up the price and GST and keeps a list of saved quotes. |
| **Job Board** | A board with a column for each stage of the build. You press a button to move a job to the next stage, and it shows jobs past their due date in red. |
| **Parts List** | Choose a boat model and see which parts go into it, how many, and the parts cost. |
| **Purchase Requests** | A form for raising "please buy this" requests (who, item, quantity, which job, estimated cost). |
| **Shop Timer** | Start and stop a clock against a job, so you can see hours spent. |
| **Delivery Checklist** | Pick a job and tick off a 10-point pre-delivery checklist. It says "Ready for delivery" when all are ticked. |
| *(`_sample`)* | A placeholder that came with the Steadyship setup. It isn't one of yours. |

## Where the same information is kept in more than one place

Every app has its own typed-in copy of the facts it needs, and none of them read from the spreadsheets. The Job Board even has a note in it saying "copied from Jobs.csv - Sam".

- **Prices.** The Price List 2026 spreadsheet is the master. The Quote Builder has its own copy, and it's out of date:

  | Item | Price list | Quote Builder |
  |---|---|---|
  | Bimini top | $3,450 | $3,200 |
  | Trailer | $6,250 | $5,800 |

  These rose on 1 September. A quote with both would be $700 too low before GST.
- **Job stages.** Jobs.csv has J-1039 at "Sea trial" and J-1041 at "Fit-out". The Job Board shows them at "Paint" and "Weld". The board also only has 6 stages, where your "How we build a boat" note has 9. It has no Sea trial column, so J-1039 can't even be shown correctly.
- **Customer names.** The glossary says customers are always written exactly as in Customers.csv. In practice you get "Harbour Services Ltd", "Harbour Services", "Harbour Svcs Ltd", "Harbour WB 6.2" and "Southern Charters" for the same two customers.
- **Job numbers.** They're written "J-1043" in most places but "1043" on the Job Board and "1040" in Purchase Requests.
- **Parts.**
  - Parts.csv uses codes like `AL-5083-5`. The Parts List app uses `AL50835`, and Purchase Requests has `AL-5083-5`, `AL50835`, "nav lights red/green" and "SS BOLT M8" for what are the same few items.
  - The fuel tank costs $740 in the spreadsheet and $725 in the Parts List app.
  - The flat bar and antifoul are in the spreadsheet but not in any boat's parts list.
- **List of jobs.** Each app has its own hand-typed list. The Shop Timer has 3 jobs, the Delivery Checklist 4, and the Job Board 8.
- **Quote rules.** The saved quote says "valid for 14 days". Your notes say 30.
- **Quotes themselves.** The only saved quote (Q-2026-031) is a document on the shared drive. The Quote Builder doesn't know it exists and numbers its own quotes from 032 up.
- **Hull numbers.** The checklist asks for the hull number to be "stamped and photographed", but your notes say it isn't written down anywhere.

## What could go wrong if you carry on like this

1. **Quotes that are wrong.** The Quote Builder is already undercharging on two options. Customers hold you to quotes, and this one only gets noticed if someone checks.
2. **Data that lives on one device.** The Job Board moves, saved quotes, timer hours, purchase requests and checklist ticks are all kept inside whichever browser was used.
   - Other people can't see them.
   - Clearing the browser or changing phones wipes them.
   - Two people can both create "Q-2026-032".
   - The Delivery Checklist could say "Ready for delivery" on one tablet while the boat isn't ready.
3. **The board can't be trusted.** Because it's separate from Jobs.csv, it shows the wrong stage for at least two jobs. Anyone planning from it is planning from a wrong picture.
4. **Hours that go nowhere.** Shop Timer hours can't be exported and aren't linked to anything. They're per job, but your notes say time should be by operation, so you can't see where the hours really go.
5. **Purchasing mix-ups.** With four different ways of writing the same plate, nobody can easily total what's been ordered. Ordering could be duplicated or missed.
6. **Stale lists.** Every new job, price change or new part means editing several places by hand. Jobs from J-1042 onwards are missing from the Timer and Checklist.
7. **Knowledge in people's heads.** Someone made each of these (Sam for the board, Morgan for the prices), and there's no one place that says what is the master copy. Whoever leaves takes that with them.
8. **No one in charge of the spreadsheets.** Anyone can edit them, and it's not clear who is meant to.

## Suggested order of attention

1. Fix the two prices in the Quote Builder now (small job), and agree who owns the price list.
2. Decide that the spreadsheets are the master copy, and make the apps read from them instead of keeping their own copies.
3. Agree one way to write job numbers, customer names and part codes.
4. Move the data that's stuck in individual browsers (quotes, timer hours, requests, checklist ticks) somewhere shared.

The assessment template in `docs/assessment/SUMMARY.md` is still blank. I can turn this into that document for Morgan if you'd like. Do you want me to?
````
