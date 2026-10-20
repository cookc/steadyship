# Hand assessment — how to run it (weeks 1–2)

Owner: {{SETUP_OWNER}}. Time box: 30 minutes per app, 1 hour for the summary.

**Setup owner:** {{SETUP_OWNER}}
**Sponsor:** {{SPONSOR}}

(The setup owner holds the accounts and does the one-time plumbing. There
is no standing engineer reviewer: judgement comes from the skills and the
independent reviewer they dispatch. In V0 {{SETUP_OWNER}}
is also the calibration ground truth for the *assess* skill and the
escalation path; both are temporary.)

0. Sponsor confirms, in writing (one line in `SUMMARY.md`), that real
   business data may sit in the private GitHub repository `{{GITHUB_OWNER}}/{{REPO_NAME}}`,
   and for the hosting check on Azure.
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
6. If the Exposure section found anything that looks like a key, password
   or customer PII in the code, do NOT commit that app — record it in the
   assessment and tell the sponsor.
7. Commit after each app, and once more after `SUMMARY.md`: `git add apps docs/assessment && git commit -m "docs(assessment): <name>"`.

What a good assessment is for: the *assess* skill (week 3) must rediscover
what you found here. Be specific about duplication and data locations;
those are what it will be measured against.
