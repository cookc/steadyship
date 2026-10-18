# vanilla — s1-opus

- Arm: vanilla (steadyship plugin: Status: ✘ disabled)
- Model: `--model opus`
- Started: 2026-10-19T11:19:30+13:00
- Wall time: 52s
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
I've looked through everything: your six apps, the four spreadsheets and the saved quote on the shared drive, and the three business notes. I haven't changed anything.

## Your apps

| App | What it's for | Likely users |
|---|---|---|
| **Quote Builder** | Choose a customer, a boat and its options, and it works out the price with GST. It can save a list of quotes. | Morgan / office |
| **Job Board** | A board with a column for each stage. You click a button to move a job to the next stage. | Sam (who copied the jobs into it) / workshop |
| **Shop Timer** | Tap Start and Stop to record the hours spent on a job. | Workshop floor |
| **Parts List** | Shows the parts each boat model needs and adds up their cost. | Office / purchasing |
| **Purchase Requests** | Staff ask for parts to be bought for a job. | Workshop (Jo, Mere, Sam) |
| **Delivery Checklist** | A 10-point tick list for each boat before handover. | Whoever hands the boat over |

(There's also a `_sample` app. It's a stand-in for testing and not one of yours.)

## The biggest thing to know first

**None of these apps save to the shared drive.** Anything you enter is stored inside the web browser on the one computer or tablet you used. That means:

- Two people opening the same app on different devices see different information.
- If someone clears their browser history, switches browser or gets a new laptop, everything they entered is gone: quotes, timer hours, purchase requests, checklist ticks, job moves.
- Nothing an app does ever updates your spreadsheets, and changes to the spreadsheets never reach the apps. Each app has its own copy of the lists, typed in by hand when someone built it.

## Where the same information is kept in more than one place

| Information | The spreadsheet | Also copied into | Do they agree? |
|---|---|---|---|
| **Prices** | Price List 2026 | Quote Builder | **No.** The Bimini top costs $3,450 in the price list but $3,200 in the app. The trailer costs $6,250 in the list but $5,800 in the app. The list was updated on 1 September and the app wasn't, so **every quote with those options is about $250–$450 too low.** |
| **Job stages** | Jobs | Job Board | **No.** The spreadsheet says J-1039 is at Sea trial, but the board says Paint. The spreadsheet says J-1041 is at Fit-out, but the board says Weld. I can't tell which is right. Ask whoever runs the floor. |
| **The stages themselves** | "How we build a boat" (9 stages) | Job Board (6 stages) | **No.** The board has no Enquiry, Quote or Sea trial columns, so it *can't* show a boat in sea trial. It also writes "Fit out" where everywhere else says "Fit-out". |
| **List of jobs** | Jobs (8 jobs) | Job Board, Shop Timer, Delivery Checklist, Purchase Requests | **Partly.** The Shop Timer only has 3 jobs, so nobody can book time to J-1043 or J-1044, even though J-1043 is being welded right now. The Delivery Checklist only has 4 jobs. J-1043 is written "1043" on the Job Board, and J-1040 is written "1040" in a purchase request. |
| **Customer names** | Customers | Quote Builder, Job Board, Delivery Checklist, Jobs | **No.** "Harbour Services Ltd" also shows up as "Harbour Services" and "Harbour Svcs Ltd", and "Southern Charters Ltd" as "Southern Charters". Your glossary says names should never be shortened. |
| **Parts and costs** | Parts | Parts List, Purchase Requests | **No.** The fuel tank is $740 in the spreadsheet but $725 in the app. The app writes part codes without hyphens ("AL50835" instead of "AL-5083-5"). Purchase requests use four different styles, including plain words like "nav lights red/green". |
| **What each boat needs** | *(nowhere)* | Parts List only | The list of parts for each model exists only inside that one app. |
| **Quote numbers** | Quotes folder (Q-2026-031) | Quote Builder | The app makes up its own numbers, starting at 032, separately on every computer. Two people would both create a "Q-2026-032". |
| **How long a quote is valid** | Your notes say 30 days | The actual quote Q-2026-031 says 14 days | **No.** |
| **Hull number** | *(nowhere)* | Delivery Checklist asks you to confirm it's stamped | Your glossary says nobody writes it down yet, so there's nothing to check it against. |

## What could go wrong if you keep going like this

1. **Underquoting.** This is already happening with Bimini tops and trailers. Each time prices change, someone has to remember to change the app as well, and nothing warns them if they forget.
2. **Lost work.** A browser clean-up or a dead tablet wipes out timer hours, purchase requests or checklist ticks, and there's no backup.
3. **People acting on the wrong picture.** The office reads the spreadsheet and the floor reads the board, and right now they disagree on two of eight jobs. That could lead to promising a customer the wrong date or ordering parts at the wrong time.
4. **Hours you can't trust.** Your notes say time is booked to each *operation* (like "Weld the hull") so you can see where the hours go. The timer only records time per *job*, doesn't say who was working, and is missing jobs. You won't be able to tell where the hours really went.
5. **Purchase requests slipping through.** Requests stay on whichever device they were typed on, so the person doing the ordering may never see them. Anyone can delete a request with the "x" button, and no record is kept. Because item codes are typed freely, it's easy to order the wrong thing or order the same thing twice.
6. **A handover with no paper trail.** The checklist ticks aren't saved anywhere official. If a customer later disputes something, you can't prove what was checked or when.
7. **It gets worse with every new job.** Each new job, customer or price change has to be typed into the spreadsheet *and* into up to five apps by hand. That only works while one person remembers every place.

## What I'd suggest first

- **Today:** fix the two prices in the Quote Builder. Check any quotes sent since 1 September that included a Bimini top or trailer.
- **This week:** pick one place as the "real" record for jobs, prices, customers and parts. The spreadsheets are the obvious choice. Then have the apps read from them instead of keeping their own copies. Also decide whether quotes are valid for 14 or 30 days.

This repository has a summary template (`docs/assessment/SUMMARY.md`) laid out for exactly this kind of write-up for Morgan. I can fill it in with these findings if you'd like.
````
