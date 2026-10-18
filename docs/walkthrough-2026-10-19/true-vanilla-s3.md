# true-vanilla — s3

- Arm: true-vanilla (plugin disabled, --disable-slash-commands) (steadyship plugin: Status: ✘ disabled; skills loaded at session init: 0)
- Model: `--model sonnet`
- Command: `timeout 300 claude -p "<prompt>" --model sonnet --disable-slash-commands --output-format stream-json --verbose`
- Started: 2026-10-19T11:30:17+13:00
- Wall time: 26s
- Exit code: 0
- Working directory: ~/steadyship-demo (git status before run: clean)

## Prompt

```text
Is the job-board app good enough for the whole workshop to use every day instead of the Jobs spreadsheet? Be straight with me.
```

## Files changed or created by the run

None (`git status --short` empty).

## Tool calls (first line of each)

```text
Bash: git ls-files | head -100 && cat README.md CLAUDE.md 2>/dev/null | head -80
Bash: cat docs/assessment/SUMMARY.md docs/assessment/README.md; ls docs/assessment; wc -l apps/job-board/index.html; cat steadyship.md | head -60; grep -ril "jobs spreadsheet\|Jobs.xlsx\|spreadsheet" docs a …
Bash: cat apps/job-board/index.html; echo ------; cat "docs/context/business/About Demo Boatworks.md" "docs/context/business/How we build a boat.md" "docs/context/business/Glossary (draft).md"; grep -n -i " …
```

## Full reply (stdout + stderr)

````text
**No, it isn't good enough yet.** It's a fair prototype of a board view, but it can't replace the spreadsheet for the whole workshop. I read the code and the business docs. I didn't run it, and I haven't seen `Jobs.csv`. It isn't in the repo.

**Blockers**
1. **Moves are saved in each browser, not shared.** Clicking "Move to Weld" writes to `localStorage` on that one device (`apps/job-board/index.html:46-50`). If Sam moves J-1041 on the office PC, nobody else sees it. Two people will see two different boards, which is worse than the spreadsheet.
2. **The job list is hardcoded.** The comment says "copied from Jobs.csv - Sam". New jobs can't be added and due dates can't be changed. Anything that changes in the spreadsheet won't show up here, so the spreadsheet would stay the real record.
3. **A refreshed job list would clash with the saved moves.** The saved moves override whatever stage the job list says. If someone re-pastes the list from the CSV, stale browser state would silently win on some machines.
4. **Moves only go forward.** A misclick can't be undone except by clearing browser storage.

**Doesn't match how you work**
- The board has 6 stages. Your process has 9. Enquiry and Quote are arguably office work, but **Sea trial** is missing, so jobs jump from Paint to Delivery. "Fit out" should also be "Fit-out".
- J-1043 is entered as `1043`. The glossary says jobs are always `J-` plus four digits.
- Customers are shown as "Harbour Services", but the glossary says to write them exactly as in `Customers.csv` ("Harbour Services Ltd").
- There are no hull numbers or operations. That may be fine for a board, but it's a gap if the spreadsheet tracks them.

**Smaller bug**
- "Today" is calculated in UTC. In Nelson, jobs aren't flagged overdue until about 1pm on the due date (during daylight saving), and the day rolls over at the wrong time.

**What it would take**
- A shared place to store the data, so every device sees the same board. That is the main fix.
- Add, edit and move-back, with the real stage list.
- A decision on whether the board or the spreadsheet is the master. Until then you'd have the same information in two places.

I'd keep the spreadsheet as the source of truth for now. I can sketch the shared-storage fix, or fill in the job-board assessment so Morgan sees this in plain language.
````
