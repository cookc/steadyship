# true-vanilla — s1

- Arm: true-vanilla (plugin disabled, --disable-slash-commands) (steadyship plugin: Status: ✘ disabled; skills loaded at session init: 0)
- Model: `--model sonnet`
- Command: `timeout 300 claude -p "<prompt>" --model sonnet --disable-slash-commands --output-format stream-json --verbose`
- Started: 2026-10-19T11:27:12+13:00
- Wall time: 52s
- Exit code: 0
- Working directory: ~/steadyship-demo (git status before run: clean)

## Prompt

```text
I'm not technical. We have a few apps in this folder that people at Demo Boatworks built with Claude, plus our spreadsheets on the shared drive at /home/ccook/steadyship-demo-shared-drive and some notes about the business in docs/context/business. Can you look at everything and tell me: what apps we have, what each one is for, where the same information is kept in more than one place, and what could go wrong if we keep going like this? Keep it in plain English.
```

## Files changed or created by the run

None (`git status --short` empty).

## Tool calls (first line of each)

```text
Bash: git ls-files | head -200; echo ---; ls -la; echo ---; find /home/ccook/steadyship-demo-shared-drive | head -100; echo ---; ls -R docs/context/business
Bash: wc -c apps/*/index.html; for f in docs/context/business/*.md; do echo "=== $f"; cat "$f"; done; cd /home/ccook/steadyship-demo-shared-drive; for f in *.csv Quotes/*; do echo "=== $f"; cat "$f"; done
Bash: cd /home/ccook/steadyship-demo/apps && for d in delivery-checklist job-board parts-list purchase-requests quote-builder shop-timer; do echo "=================== $d"; cat $d/index.html; done; cat /home …
```

## Full reply (stdout + stderr)

````text
I read all six apps, the four spreadsheets, the saved quote, and the three business notes. I changed nothing. I read the apps' code but didn't run them, and I can't see who uses them or how they're opened day to day.

## The apps and what each is for

| App | What it's for |
|---|---|
| **Quote Builder** | Pick a customer, a boat model and options, and it works out the price plus GST. You can save quotes. |
| **Job Board** | A board showing each job as a card in its build stage, with a button to move it to the next stage. It turns red when a job is overdue. |
| **Shop Timer** | Start and stop buttons so people on the floor can track hours against a job. |
| **Parts List** | Choose a model and see the parts needed to build it, with a parts cost total. |
| **Purchase Requests** | A form for staff to ask for something to be bought (item, quantity, which job, estimated cost). |
| **Delivery Checklist** | A 10-point checklist per job to tick off before a boat is handed over. |

There's also a `_sample` app, which is just a template.

## Where the same information is kept in more than one place

Every app has its own typed-in copy of information that also lives in the spreadsheets. Nothing is linked, so the copies have already drifted apart.

**Prices**
- The Quote Builder has Bimini top at $3,200 and Trailer at $5,800.
- The Price List 2026 sheet says $3,450 and $6,250 from 1 September.
- So any quote built since September is $700 too low if it includes both.

**Job stages**
- Jobs.csv and the Job Board disagree on two jobs. J-1039 is "Sea trial" in the spreadsheet but "Paint" on the board. J-1041 is "Fit-out" in the spreadsheet but "Weld" on the board.
- I can't tell which is right.
- The board has only six stages, but your process has nine. It has no Sea trial column, so a job in Sea trial can't show up properly.
- When someone presses "Move to…" on the board, that's saved only on their own device. The spreadsheet isn't updated.

**Which jobs exist**
- Jobs.csv lists 8 jobs.
- The Job Board shows all 8.
- The Delivery Checklist knows only 4 (J-1038 to J-1041).
- The Shop Timer knows only 3 (J-1040 to J-1042).
- J-1043 and J-1044 are being built right now, but nobody can book time to them.

**Customer names**
- Customers.csv and the Quote Builder use the full legal name, for example "Harbour Services Ltd".
- The Job Board uses "Harbour Services".
- The Delivery Checklist uses "Harbour Svcs Ltd" and "Southern Charters".
- The Shop Timer uses "Harbour WB 6.2".
- Your glossary says names should never be abbreviated.

**Part codes**
- Parts.csv uses `AL-5083-5`.
- The Parts List app uses `AL50835`, with the hyphens removed.
- Purchase Requests has a mix of `AL-5083-5`, `AL50835`, "nav lights red/green" and "SS BOLT M8".
- Nobody can total up what's been requested, or match requests to the parts sheet, without tidying these first.

**Part costs and coverage**
- The fuel tank costs $740 in the sheet but $725 in the Parts List app.
- The Parts List leaves out two parts from the sheet: the flat bar and the antifoul paint. Its parts totals are therefore understated.

**Job numbers**
- Mostly "J-1041", but the Job Board has "1043" and Purchase Requests has "1040".

**Quotes**
- Saved quotes in the Quote Builder live only in the browser of whoever made them.
- The one quote on the shared drive (Q-2026-031) was written separately.
- The Quote Builder numbers new quotes from "32" plus however many that browser has saved. Two people quoting on different computers would both issue Q-2026-032.

## What could go wrong if you keep going like this

1. **Under-quoting.** The Quote Builder is on old prices, and nothing reminds anyone to update it when the price list changes. The $700 gap above is real money on every Trailer-and-Bimini quote.
2. **Information that sits on one person's device.** The timer hours, purchase requests, saved quotes, checklist ticks and board moves are all kept inside each person's own web browser. They are not on the shared drive or in any shared place. If someone clears their browser, switches phones, or uses a different computer, it's gone or invisible to everyone else. Nobody in the office can see whether a boat is ready for delivery or what hours were booked.
3. **Two answers to "where is this job?"** The office, the workshop and the spreadsheet can each say something different, as with J-1039 and J-1041. That leads to wrong promises to customers and boats not ready when expected.
4. **New jobs fall through the cracks.** Job lists are typed into each app. Every new job needs someone to remember to edit up to four apps, and it's already been missed for J-1043 and J-1044.
5. **Reports can't be built.** You can't answer "what did this boat cost us?" or "where do the hours go?" when names and codes don't match and the data is trapped on devices. The timer also tracks whole jobs, while your own process says time should be booked against operations like "Weld the hull".
6. **The written rules don't match the tools.**
   - The saved quote says it's valid for 14 days, but your notes say 30.
   - The checklist asks for the hull number to be stamped and photographed, but the glossary says hull numbers aren't recorded anywhere.
   - The notes say each app lives in a folder on the shared drive. They're actually in the code folder (`apps/`), and the shared drive holds only the spreadsheets and the one quote.
7. **Reliance on the people who built them.** Job Board has a note saying "copied from Jobs.csv - Sam". That means it's one person's manual copy, and it goes stale the day they stop doing it.

## Suggested next step

I'd start with two quick fixes that need no big rebuild:
- Update the Quote Builder's two prices.
- Decide which of Jobs.csv or the Job Board is right for J-1039 and J-1041.

Then the real fix is to keep each piece of information, such as jobs, customers, parts and prices, in one place that every app reads from. Say if you'd like me to plan that out, or just make those first two fixes.
````
