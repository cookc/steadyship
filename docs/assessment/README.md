# Hand assessment — how to run it (weeks 1–2)

Owner: Chris. Time box: 30 minutes per app, 1 hour for the summary.

1. **[ON-SITE]** With the builder, list every app they have. Include the
   half-finished ones. Write names into `SUMMARY.md` first so nothing is lost.
2. For each app, copy its folder **unmodified** into `apps/<name>/`
   (lower-case, hyphens). Do not rename files inside. Do not commit any
   data files — `.gitignore` already excludes xlsx/csv/json under `apps/`;
   if the app's data is inside `index.html`, that is fine and expected.
3. Copy `TEMPLATE.md` to `docs/assessment/<name>.md` and fill it in while
   looking at the app and talking to the builder. "Unknown" is a finding.
4. Run `scripts/smoke.sh apps/<name>/index.html` and note PASS/FAIL under
   Verdict.
5. When all apps are done, fill `SUMMARY.md`. This is the page the sponsor
   reads. No jargon.
6. Commit: `git add apps docs/assessment && git commit -m "docs(assessment): <name>"`.

What a good assessment is for: the *assess* skill (week 3) must rediscover
what you found here. Be specific about duplication and data locations;
those are what it will be measured against.
