# plugin — s3

- Arm: plugin (steadyship plugin: Status: ✔ enabled)
- Model: `--model sonnet`
- Started: 2026-10-19T11:22:04+13:00
- Wall time: 25s
- Exit code: 0
- Working directory: ~/steadyship-demo (git status before run: clean)

## Prompt

```text
Is the job-board app good enough for the whole workshop to use every day instead of the Jobs spreadsheet? Be straight with me.
```

## Files changed or created by the run

None (`git status --short` empty).

## Full reply (stdout + stderr)

````text
**No. It isn't ready to replace the Jobs spreadsheet, and I wouldn't let the workshop start relying on it.** I read the code and the business docs. I haven't run it in a browser, and the real Jobs spreadsheet isn't in the repo, so I haven't compared the two.

**Why not (`apps/job-board/index.html`)**
1. **Moves aren't shared.** When someone clicks "Move to Weld", it saves only in that browser's `localStorage` (line 57). Two people on two machines will see different boards. Clearing the browser data, or opening a different browser, resets the board to the hardcoded list. That is the dealbreaker for daily use.
2. **The job list is a frozen copy.** The jobs are typed into the file ("copied from Jobs.csv - Sam", lines 24–35). New jobs and changed due dates in the spreadsheet never show up, and nothing moves back to the spreadsheet. You would have two sources of truth that drift apart from day one.
3. **The stages don't match how you build a boat.** The app has 6 stages. "How we build a boat" has 9. Enquiry and Quote are missing, which is arguably fine for a workshop board. **Sea trial is also missing**, so a boat in trial has nowhere to sit. "Fit out" is also spelled differently from "Fit-out".
4. **You can only move a job forward.** There's no back button and no undo, so one wrong click can't be fixed in the app.
5. **The data has errors.**
   - Job `1043` is missing its `J-` prefix, which the glossary says is always used.
   - "Harbour Services" should be "Harbour Services Ltd" if it matches Customers.csv.
6. **There's no hull number, no time booking and no history.** It's a display of the board, not a replacement for what the spreadsheet is used for.
7. **The "overdue" check uses UTC.** `toISOString()` (line 38) can be a day out for a NZ workshop in the early morning.

**What's good about it**
- It's a clear, readable board that is quick to scan.
- It highlights overdue jobs.
- It's a simple page with no dependencies and no keys or PII, which makes it easy to improve.

**Where the project is**
- The job-board assessment hasn't been written.
- `SUMMARY.md` is still the blank template.
- None of the spikes have been run, including the data-sharing one (b, NAS read/write) and the hosting one (d). Those decide where shared data could live.

**What I'd do**
- Keep the spreadsheet as the source of truth for now. Treat the app as a read-only wall display at most.
- Before it replaces anything, it needs one shared place to store stage moves, loading jobs from there instead of hardcoding them. It also needs the stage list agreed with Morgan and a way to undo a move.
- First, run the assessment and the spikes. They'll tell you whether shared storage is workable.

I can start on the job-board assessment, or sketch the smallest change that would make moves shared, if you want either.
````
