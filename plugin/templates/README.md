# {{BUSINESS_NAME}} — apps

The business's own apps, their assessments, and the checks that keep them
honest. Set up with Steadyship (see `steadyship.md`); works without it.

- `apps/<name>/` — each app, copied in unmodified
- `docs/assessment/` — what each app is and what it would take to rely on it
- `docs/context/` — business notes Steadyship reads first, and `engineering.md`, the facts the engineering standard cannot know
- `docs/spikes/` — the checks (environment, shared drive, tests, GitHub, hosting, team) and their results
- `lib/` — the few libraries apps may use, pinned, working offline
- `scripts/serve.mjs` — opens one app so it can read and write its master file on the shared drive
- `tests/<name>/` — each app's own tests, next to the smoke test every app gets
- `scripts/validate.sh` — every check CI runs; `scripts/test.sh <name>` runs one app's tests

Setup owner: {{SETUP_OWNER}} · Sponsor: {{SPONSOR}}
