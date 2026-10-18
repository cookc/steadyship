# vanilla — s3

- Arm: vanilla (steadyship plugin: Status: ✘ disabled)
- Model: `--model sonnet`
- Started: 2026-10-19T11:20:32+13:00
- Wall time: 27s
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
**No. It isn't good enough to replace the Jobs spreadsheet for the whole workshop, and the main reason is that nothing is shared.**

**What's wrong with it**

1. **Each person sees their own board.** When someone clicks "Move to Weld", the move is saved in that browser's `localStorage`. Nobody else sees it, and it isn't saved anywhere central. If two people use it, they'll have two different boards within a day. That alone rules out workshop-wide use.
2. **The job data is typed into the page.** The comment says "copied from Jobs.csv - Sam". Any new job, changed due date or correction means someone editing the HTML by hand. The app can't add a job, edit one or remove one.
3. **It already disagrees with the spreadsheet.** I compared it to `Jobs.csv` in the shared drive:
   - J-1039 is on Paint in the app, but the spreadsheet has it on Sea trial.
   - J-1041 is on Weld in the app, but the spreadsheet has it on Fit-out.
   - Job 1043 is missing its `J-` prefix, which breaks your own glossary rule.
   - Customer names are shortened ("Harbour Services" instead of "Harbour Services Ltd"), which the glossary says never to do.
   - Model is dropped completely.
4. **The stages are wrong.** There's no Sea trial stage, and "Fit-out" is spelled "Fit out". Your process has nine stages and the board has six. A job in Sea trial, like J-1039, has no column to sit in.
5. **There's no way to move a job backwards.** Rework happens in a workshop, and a mis-click can't be undone.
6. **It records nothing about changes.** There's no record of who moved what, or when.

**What's fine**

- The board layout is clear.
- The overdue highlighting works. It's slightly off in that it compares dates in UTC, which can be a day out in NZ.
- It's a reasonable prototype of what the workshop would want to see.

**What I haven't done**

- I haven't opened it in a browser.
- I haven't run `scripts/smoke.sh`.
- I haven't talked to Sam or the workshop. I don't know who uses it now, or whether the spreadsheet is the only place jobs are tracked.

The repo's own assessment (`docs/assessment/SUMMARY.md`) is still the blank template, and no spike results are filled in, so there's no earlier finding to lean on.

**What would make it ready**

- Move the data to one shared place that everyone reads and writes, not `localStorage` and not hard-coded HTML. This is the real work.
- Use the nine stages, the full customer names, the model and the `J-` job numbers.
- Allow adding and editing jobs, and moving a job back a stage.
- Decide which is the source of truth during the changeover, so you don't run both for weeks and watch them drift apart.

Until then, keep the spreadsheet as the real record. The board can run beside it as a read-only display if you want to show it off. Even for that, fix the two wrong stages and the J-1043 number first.

I can fill in the `job-board` assessment in `docs/assessment/` and run the smoke test if you'd like.
````
