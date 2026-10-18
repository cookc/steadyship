# true-vanilla — s1-opus

- Arm: true-vanilla (plugin disabled, --disable-slash-commands) (steadyship plugin: Status: ✘ disabled; skills loaded at session init: 0)
- Model: `--model opus`
- Command: `timeout 300 claude -p "<prompt>" --model opus --disable-slash-commands --output-format stream-json --verbose`
- Started: 2026-10-19T11:28:05+13:00
- Wall time: 58s
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
Bash: git ls-files | grep -v node_modules | head -200; echo ---; find /home/ccook/steadyship-demo-shared-drive -type f | head -100
Bash: cat README.md steadyship.md docs/context/business/*.md; wc -c apps/*/index.html; cd /home/ccook/steadyship-demo-shared-drive; for f in *.csv Quotes/*; do echo "=== $f"; cat "$f"; done
Bash: cat docs/assessment/README.md docs/assessment/SUMMARY.md | head -80
Bash: cd /home/ccook/steadyship-demo/apps && for d in delivery-checklist job-board parts-list purchase-requests quote-builder shop-timer; do echo "=================== $d"; cat $d/index.html; done
```

## Full reply (stdout + stderr)

````text
# What I found at Demo Boatworks

I read all six apps, the four spreadsheets and the saved quote on the shared drive, and the three business notes. I didn't change anything.

## The apps

| App | What it's for | Who seems to use it |
|---|---|---|
| **Quote Builder** | Pick a customer, a boat and some options, and it adds up the price with GST. It can save quotes. | Morgan |
| **Job Board** | Shows each boat as a card under its current stage. You click to move a card to the next stage. | Sam built it; the office and workshop |
| **Shop Timer** | Staff tap Start and Stop to record how long they spend on each job. | Workshop floor |
| **Parts List** | Choose a boat model and it lists the parts and quantities that go into it, with a total cost. | Whoever orders materials |
| **Purchase Requests** | Staff ask for things to be bought: item, quantity, which job and a rough cost. | Jo, Mere, Sam and others |
| **Delivery Checklist** | A 10-item tick list (welds checked, bilge pump tested and so on) to finish before a boat is handed over. | Whoever does handovers |

There's one problem that affects every app: **anything typed into an app is saved only inside that one web browser on that one computer.** Nobody else can see it, and it isn't on the shared drive. Every app also has its own copy of the business information it needs (jobs, prices, customers) typed into it. These copies don't update when the spreadsheets change.

## Where the same information is kept in more than one place

| Information | The "official" copy | Also copied into | Do they agree? |
|---|---|---|---|
| **Prices** | Price List 2026 spreadsheet | Quote Builder | **No.** The spreadsheet put the Bimini top up to $3,450 and the Trailer up to $6,250 on 1 September. The Quote Builder still uses the old prices, $3,200 and $5,800. |
| **Job list** (job number, customer, stage, due date) | Jobs spreadsheet | Job Board, Delivery Checklist, Shop Timer, and typed by hand into Purchase Requests | **No.** The Job Board has J-1039 at Paint, but the spreadsheet says Sea trial. It has J-1041 at Weld, but the spreadsheet says Fit-out. The Timer only knows 3 jobs and the Checklist only knows 4. |
| **Stages of a build** | "How we build a boat" (9 stages) | Job Board (6 stages) | **No.** The board has no Enquiry, Quote or Sea trial column, so a boat at sea trial can't appear on it. It also writes "Fit out" where the spreadsheet says "Fit-out". |
| **Customer names** | Customers spreadsheet | Quote Builder, Job Board, Delivery Checklist | **Partly.** The Quote Builder matches. The others shorten names ("Harbour Svcs Ltd", "Southern Charters"), although the glossary says names should never be shortened. |
| **Part codes and costs** | Parts spreadsheet | Parts List, and typed by hand into Purchase Requests | **No.** The Parts List writes codes without hyphens (AL50835 instead of AL-5083-5) and has the fuel tank at $725, not $740. In Purchase Requests the same plate has been entered two different ways, and nav lights were typed as words instead of a code. |
| **Quotes** | The Quotes folder on the shared drive | Quote Builder's saved list (one computer only) | They're **two separate records**, and neither has all the quotes. |
| **How long a quote is valid** | Glossary says 30 days | The saved quote Q-2026-031 says 14 days | **No.** |

Some information is kept in only one place, which is just as risky:

- **The list of parts in each boat model** exists only inside the Parts List app. It isn't in any spreadsheet.
- **Hull numbers** aren't recorded anywhere, even though the Delivery Checklist asks someone to check the hull number is stamped.

## What could go wrong if you keep going like this

1. **You're under-quoting now.** A WB 6.2 with a Bimini top and Trailer comes out of the Quote Builder about **$805 cheaper (including GST)** than the current price list. This happens on every quote with those options until someone updates the app by hand.

2. **Different people see different versions of what's happening.** The Job Board already disagrees with the spreadsheet on two boats. And when someone moves a card, only their own computer sees it. The office could tell a customer their boat is in Weld when it's already in Fit-out, or the reverse.

3. **Records can disappear with no warning.** Timesheets, purchase requests, delivery ticks, saved quotes and Job Board moves all live inside a browser. If the browser history is cleared, the laptop dies, or someone switches to a different computer, that information is gone. There's no backup. In Purchase Requests, anyone can delete a request with one click and no trace is left.

4. **The same quote number can be used twice.** The Quote Builder numbers quotes by counting what that one computer has saved. Two computers, or one browser that's been cleared, will hand out the same numbers again.

5. **New jobs don't show up in the apps.** J-1043 to J-1045 aren't in the Shop Timer, so nobody can book time to them. J-1042 onward aren't in the Delivery Checklist, so those boats can't be ticked off at handover. Someone has to remember to edit each app by hand every time a job is added.

6. **Your time records won't tell you what you want to know.** The business notes say time is booked by operation (such as "Weld the hull") so you can see where the hours really go. The Shop Timer only records a total per job, and it doesn't record who was working.

7. **Purchase requests are hard to act on.** Item codes and job numbers are typed in any format, and costs are guesses. Whoever does the buying can't reliably match a request to a part or a supplier.

8. **The copies will keep drifting apart.** Each price change, new customer or new job has to be made in up to five places. It has only been a few months and the copies already disagree in several places. That will get worse as you add jobs and change prices.

## A sensible first step

Two things are worth doing this week, before any bigger tidy-up:

- **Update the two prices in the Quote Builder** so you stop losing money on quotes.
- **Agree that the spreadsheets are the official version**, so everyone knows which copy wins when they disagree.

This folder has a blank summary page (`docs/assessment/SUMMARY.md`) meant for Morgan. If you like, I can fill it in from these findings, or fix the two prices in the Quote Builder.
````
