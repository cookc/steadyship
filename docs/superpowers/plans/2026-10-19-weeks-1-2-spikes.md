# Steadyship Weeks 1–2: Spikes, Assessment, Plugin Skeleton — Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Produce everything needed to run the five go/no-go spikes on the design partner's Windows machine and Team account, plus the template Chris uses to hand-assess every app — so that by the end of week 2 there is a filled-in go/no-go table and a one-page assessment the sponsor can read.

**Architecture:** One Git repository (`~/steadyship`) that is simultaneously (1) a Claude plugin marketplace containing the `steadyship` plugin, (2) the business's context repository (assessment docs, spike runbooks and results), and (3) a home for the partner's apps copied in untouched under `apps/`. Spikes are runbooks: a prompt a builder pastes into Claude desktop, a script Claude runs inside its VM, and a written pass/fail. CI (GitHub Actions) is the fallback verifier for anything the Claude VM can't do.

**Tech Stack:** Markdown; Claude Code plugin format (`.claude-plugin/plugin.json`, `skills/*/SKILL.md`, `.claude-plugin/marketplace.json`); bash; Node 22 + `@playwright/test` for smoke tests; GitHub Actions; Azure Static Web Apps (Free) for the hosting spike.

**Spec:** `docs/proposal-v0.1.md` (§6 platform facts, §10 V0 scope, §11 weeks 1–2, §12 criteria 1–3)

## Global Constraints

- Everything is ordinary Markdown, Git, scripts and tests. No hosted service, no proprietary format, no state outside the repository (spec §3).
- Builders never use a terminal. Every spike is driven by a prompt pasted into Claude desktop; scripts are run by Claude inside its VM, never by the builder (spec §4).
- Design partner runs **Windows**, **Claude Team plan**, local desktop sessions (spec §6). Claude's VM is Ubuntu with bash, Node 22, Python, Git; outbound network is allowlisted (api.anthropic.com, npmjs, pypi verified; others unknown).
- Secrets, native CAD and large datasets never enter Git. Prototypes use sample data unless authorised (spec §9).
- Partner apps are copied into `apps/<name>/` **unmodified**. Nothing in weeks 1–2 changes an app.
- Chris has 5–10 hours/week. Anything in this plan that needs Chris on the partner's machine is marked **[ON-SITE]**.
- Commit after every task. Commit messages end with `Co-Authored-By: Claude Fable 5.1 <noreply@anthropic.com>`.

---

## File structure

```
steadyship/
├── .claude-plugin/marketplace.json      # this repo is a marketplace with one plugin
├── plugin/                              # the steadyship plugin
│   ├── .claude-plugin/plugin.json
│   └── skills/
│       ├── steadyship-status/SKILL.md   # proves install; reports assessment + spike state
│       └── steadyship-spike/SKILL.md    # runs a named spike script and reports plainly
├── scripts/
│   ├── smoke.sh                         # plain-language wrapper around playwright
│   ├── validate.sh                      # runs every check CI runs, locally
│   └── spikes/
│       ├── git-push.sh                  # spike (a)
│       └── nas-rw.sh                    # spike (b)
├── tests/smoke/app.spec.ts              # one parameterised smoke test
├── playwright.config.ts
├── package.json
├── apps/
│   └── _sample/index.html               # fixture app; later apps/<name>/ copied from partner
├── docs/
│   ├── proposal-v0.1.md                 # the spec (exists)
│   ├── assessment/
│   │   ├── README.md                    # how Chris runs the hand assessment
│   │   ├── TEMPLATE.md                  # per-app assessment
│   │   ├── SUMMARY.md                   # the sponsor's one page (template)
│   │   └── _sample.md                   # worked example
│   └── spikes/
│       ├── README.md                    # order, who, go/no-go table
│       ├── RESULTS.md                   # filled in on-site
│       ├── a-git.md … e-plugin.md       # runbooks
│       └── hosting/                     # files spike (d) deploys
│           ├── staticwebapp.config.json
│           └── azure-static-web-apps.yml
├── .github/workflows/
│   ├── validate.yml                     # plugin manifests + smoke on sample
│   └── (spike d copies hosting/azure-static-web-apps.yml here on-site)
├── .gitignore
└── README.md
```

---

### Task 1: Repository scaffold and first commit

**Files:**
- Create: `README.md`, `.gitignore`, `scripts/validate.sh`
- Create (empty dirs via .gitkeep): `apps/.gitkeep`, `docs/assessment/.gitkeep`, `docs/spikes/.gitkeep`

**Interfaces:**
- Produces: `scripts/validate.sh` — exit 0 when every local check passes; later tasks append their checks to it.

- [ ] **Step 1: Confirm starting state**

Run: `cd ~/steadyship && git status --short && ls docs`
Expected: `?? docs/` and `proposal-v0.1.md  superpowers` (no commits yet).

- [ ] **Step 2: Write README.md**

```markdown
# Steadyship

An engineer in the conversation for non-technical people building business
software with AI. See `docs/proposal-v0.1.md`.

This repository is three things at once:

1. A Claude plugin marketplace (`.claude-plugin/marketplace.json`) containing
   the `steadyship` plugin (`plugin/`).
2. The design partner's shared context repository (`docs/assessment/`,
   `docs/spikes/`).
3. A home for the partner's apps, copied in unmodified (`apps/<name>/`).

## Status

Weeks 1–2: spikes and hand assessment. See `docs/spikes/README.md` and
`docs/assessment/README.md`.

## Checks

`scripts/validate.sh` runs every check CI runs.
```

- [ ] **Step 3: Write .gitignore**

```
node_modules/
test-results/
playwright-report/
.env
.env.*
*.local
# partner data never enters git
apps/**/data/
apps/**/*.xlsx
apps/**/*.csv
apps/**/*.json
!apps/_sample/**
# native CAD
*.dwg
*.dxf
*.step
*.stp
*.iges
*.igs
*.sldprt
*.sldasm
*.f3d
.DS_Store
Thumbs.db
```

- [ ] **Step 4: Write scripts/validate.sh**

```bash
#!/usr/bin/env bash
# Runs every check CI runs. Exit non-zero on first failure.
set -euo pipefail
cd "$(dirname "$0")/.."
echo "== validate.sh =="
# Later tasks append checks below this line.
echo "OK"
```

Run: `chmod +x scripts/validate.sh && scripts/validate.sh`
Expected: `== validate.sh ==` then `OK`.

- [ ] **Step 5: Create placeholder dirs**

Run: `mkdir -p apps docs/assessment docs/spikes && touch apps/.gitkeep docs/assessment/.gitkeep docs/spikes/.gitkeep`

- [ ] **Step 6: Commit**

```bash
git add -A
git commit -m "chore: scaffold repository with proposal, README and validate script

Co-Authored-By: Claude Fable 5.1 <noreply@anthropic.com>"
```

Run: `git log --oneline`
Expected: one commit.

---

### Task 2: Plugin skeleton and marketplace manifest

**Files:**
- Create: `plugin/.claude-plugin/plugin.json`
- Create: `.claude-plugin/marketplace.json`
- Modify: `scripts/validate.sh` (append two validate calls)

**Interfaces:**
- Produces: marketplace named `steadyship`, plugin named `steadyship` at `./plugin`. Later install command is `claude plugin install steadyship@steadyship`.

- [ ] **Step 1: Run the validator before anything exists (expect failure)**

Run: `claude plugin validate plugin --strict; echo "exit=$?"`
Expected: a non-zero exit and a message that no manifest/plugin was found at `plugin`.

- [ ] **Step 2: Write plugin/.claude-plugin/plugin.json**

```json
{
  "name": "steadyship",
  "description": "An engineer in the conversation: asks what you don't know to ask, judges what you can't judge, and gives prototypes a path to software a business can run on.",
  "version": "0.0.1",
  "author": {
    "name": "Chris Cook"
  },
  "repository": "https://github.com/REPLACE_ME/steadyship",
  "license": "MIT",
  "keywords": ["engineering-guidance", "small-business", "assessment", "non-technical"]
}
```

(`REPLACE_ME` is replaced in Task 7 Step 1 once the GitHub repo exists. `--strict` warns on an invalid URL only if the field is malformed; a placeholder owner is a valid URL.)

- [ ] **Step 3: Write .claude-plugin/marketplace.json**

```json
{
  "$schema": "https://anthropic.com/claude-code/marketplace.schema.json",
  "name": "steadyship",
  "description": "Steadyship plugin marketplace",
  "owner": {
    "name": "Chris Cook"
  },
  "plugins": [
    {
      "name": "steadyship",
      "description": "An engineer in the conversation for non-technical builders.",
      "source": "./plugin",
      "category": "development"
    }
  ]
}
```

- [ ] **Step 4: Validate both (expect pass)**

Run: `claude plugin validate plugin --strict && claude plugin validate . --strict && echo BOTH_OK`
Expected: two validation reports with no errors, then `BOTH_OK`. If `--strict` flags an unrecognised field, remove that field rather than dropping `--strict`.

- [ ] **Step 5: Append to scripts/validate.sh**

Replace the line `# Later tasks append checks below this line.` with:

```bash
# Later tasks append checks below this line.
echo "-- plugin manifests"
claude plugin validate plugin --strict
claude plugin validate . --strict
```

Run: `scripts/validate.sh`
Expected: ends with `OK`.

- [ ] **Step 6: Commit**

```bash
git add -A
git commit -m "feat(plugin): add steadyship plugin and marketplace manifests

Co-Authored-By: Claude Fable 5.1 <noreply@anthropic.com>"
```

---

### Task 3: `steadyship-status` and `steadyship-spike` skills

**Files:**
- Create: `plugin/skills/steadyship-status/SKILL.md`
- Create: `plugin/skills/steadyship-spike/SKILL.md`

**Interfaces:**
- Consumes: `docs/assessment/*.md` with a line matching `**Stage:** <word>` (defined in Task 5); `docs/spikes/RESULTS.md` table (defined in Task 7); `scripts/spikes/<name>.sh` (defined in Task 6) that print a final line `RESULT: PASS` or `RESULT: FAIL <reason>`.
- Produces: skills invocable in Claude Code as `/steadyship:steadyship-status` and `/steadyship:steadyship-spike <a|b|c|d|e>`; in Claude desktop by asking "run steadyship status".

- [ ] **Step 1: Validate the (empty) skills dir (expect a warning or error)**

Run: `mkdir -p plugin/skills && claude plugin validate plugin/skills --strict; echo "exit=$?"`
Expected: non-zero or a "no skills found" report.

- [ ] **Step 2: Write plugin/skills/steadyship-status/SKILL.md**

```markdown
---
name: steadyship-status
description: Use when asked for "steadyship status", to prove the plugin is installed, or to see how far the assessment and spikes have got. Reads docs/assessment and docs/spikes/RESULTS.md and reports in plain language.
---

# Steadyship status

You are the Steadyship coach. Report the state of this business's
Steadyship work in plain language for a non-technical reader.

## Steps

1. Confirm you are inside a Steadyship repository: `docs/proposal-v0.1.md`
   and `.claude-plugin/marketplace.json` both exist. If not, say
   "This folder isn't a Steadyship repository" and stop.
2. List every file in `docs/assessment/` except `README.md`, `TEMPLATE.md`
   and `SUMMARY.md`. For each, read the line that starts with `**Stage:**`
   and the line that starts with `**Relied on by:**`.
3. Read `docs/spikes/RESULTS.md` if it exists. Count rows whose Result
   column is PASS, FAIL, or blank.
4. Reply with exactly this shape, filled in:

   **Steadyship is installed and working.**

   Apps assessed: N (list each as "name — stage — relied on by").
   Spikes: X passed, Y failed, Z not yet run.
   Next step: (the first blank spike in RESULTS.md, or if all are
   filled, "Review RESULTS.md with Chris and decide week 3.")

## Rules

- Never modify any file.
- Never use technical vocabulary without a plain-language gloss.
- If something is missing, say what is missing; do not guess.
```

- [ ] **Step 3: Write plugin/skills/steadyship-spike/SKILL.md**

```markdown
---
name: steadyship-spike
description: Use when asked to "run spike a/b/c/d/e" or "run the steadyship spike". Runs the named spike script from scripts/spikes, reports PASS or FAIL in plain language, and tells the user what to paste into docs/spikes/RESULTS.md.
---

# Steadyship spike runner

You are running a go/no-go check on this computer. The user is not
technical. Do the work; report plainly.

## Arguments

One letter: a, b, c, d or e. If none is given, ask "Which spike: a (git),
b (shared drive), c (tests), d (hosting), e (plugin)?" and stop.

## Steps

1. Open `docs/spikes/<letter>-*.md` and follow its "What Claude does"
   section exactly. It names the script and the inputs it needs.
2. If the script needs a path or value the runbook says to ask for, ask
   once, then continue.
3. Run the script with `bash`. Capture all output.
4. The last line of output is `RESULT: PASS` or `RESULT: FAIL <reason>`.
   If the script could not run at all, treat it as
   `RESULT: FAIL could not run: <error>`.
5. Reply with:

   **Spike <letter> — PASS** (or **FAIL**)

   One or two sentences in plain language saying what was checked and
   what happened. If FAIL, one sentence on what this means (copy the
   "If it fails" line from the runbook).

   Then: "Paste this into docs/spikes/RESULTS.md row <letter>:"
   followed by `| <letter> | PASS/FAIL | <today's date> | <one-line note> |`

## Rules

- Never change files outside what the runbook says.
- Never put secrets (tokens, passwords) in your reply or in any file in
  the repository.
```

- [ ] **Step 4: Validate**

Run: `claude plugin validate plugin --strict && echo SKILLS_OK`
Expected: report lists two skills, no errors, `SKILLS_OK`.

- [ ] **Step 5: Install locally and prove the status skill works**

Run:
```bash
claude plugin marketplace add /home/ccook/steadyship
claude plugin install steadyship@steadyship
claude plugin list
```
Expected: `steadyship@steadyship` listed as installed/enabled.

Then start a new Claude Code session in `~/steadyship` and type: `/steadyship:steadyship-status`
Expected reply begins `**Steadyship is installed and working.**`, reports `Apps assessed: 0` (no assessments yet) and `Spikes: 0 passed, 0 failed, 0 not yet run` (no RESULTS.md yet) and a next step. (After Tasks 5 and 7 this will report 1 app and 5 unrun spikes.)

- [ ] **Step 6: Commit**

```bash
git add -A
git commit -m "feat(plugin): add steadyship-status and steadyship-spike skills

Co-Authored-By: Claude Fable 5.1 <noreply@anthropic.com>"
```

---

### Task 4: Smoke-test scaffold with a sample app

**Files:**
- Create: `package.json`, `playwright.config.ts`, `tests/smoke/app.spec.ts`, `scripts/smoke.sh`, `apps/_sample/index.html`, `.github/workflows/validate.yml`
- Modify: `scripts/validate.sh` (append smoke run)

**Interfaces:**
- Produces: `scripts/smoke.sh <path-to-index.html | http(s) URL>` → prints human lines and ends with `RESULT: PASS` or `RESULT: FAIL <reason>`; exit code 0/1. Spike (c) and the `steadyship-spike` skill rely on this exact last line.
- Produces: the contract a partner app must meet to pass the smoke test: page loads, `<title>` non-empty, no `console.error` and no uncaught exception during load.

- [ ] **Step 1: Write package.json**

```json
{
  "name": "steadyship",
  "private": true,
  "version": "0.0.1",
  "scripts": {
    "smoke": "playwright test --config playwright.config.ts"
  },
  "devDependencies": {
    "@playwright/test": "^1.50.0"
  }
}
```

Run: `npm install && npx playwright install chromium`
Expected: installs without error. (If `playwright install` cannot download the browser — e.g. inside the Claude VM — that is a spike (c) finding, not a Task 4 failure; on Chris's machine it must succeed.)

- [ ] **Step 2: Write playwright.config.ts**

```ts
import { defineConfig } from '@playwright/test';

export default defineConfig({
  testDir: './tests/smoke',
  timeout: 15_000,
  retries: 0,
  reporter: [['list']],
  use: {
    browserName: 'chromium',
    headless: true,
  },
});
```

- [ ] **Step 3: Write the failing smoke test**

`tests/smoke/app.spec.ts`:

```ts
import { test, expect } from '@playwright/test';
import { pathToFileURL } from 'node:url';
import { resolve } from 'node:path';

// APP is a path to an index.html or an http(s) URL. Set by scripts/smoke.sh.
const APP = process.env.APP;
if (!APP) throw new Error('APP env var is required (path to index.html or URL)');
const url = /^https?:\/\//.test(APP) ? APP : pathToFileURL(resolve(APP)).href;

test(`smoke: ${APP}`, async ({ page }) => {
  const errors: string[] = [];
  page.on('console', (m) => { if (m.type() === 'error') errors.push(`console.error: ${m.text()}`); });
  page.on('pageerror', (e) => errors.push(`uncaught: ${e.message}`));

  const response = await page.goto(url, { waitUntil: 'load' });
  if (response) expect(response.ok(), `HTTP ${response.status()}`).toBeTruthy();

  await expect(page).not.toHaveTitle('');
  expect(errors, errors.join('\n')).toEqual([]);
});
```

- [ ] **Step 4: Run it against a non-existent app (expect FAIL)**

Run: `APP=apps/_sample/index.html npx playwright test; echo "exit=$?"`
Expected: 1 failed (navigation to a missing file errors), `exit=1`.

- [ ] **Step 5: Write the sample app**

`apps/_sample/index.html`:

```html
<!doctype html>
<html lang="en">
<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <title>Sample job list</title>
  <style>
    body { font-family: system-ui, sans-serif; margin: 2rem; }
    table { border-collapse: collapse; }
    td, th { border: 1px solid #999; padding: .25rem .5rem; }
  </style>
</head>
<body>
  <h1>Sample job list</h1>
  <p>A stand-in for a partner app. Data is hardcoded, exactly like the real ones.</p>
  <table id="jobs">
    <thead><tr><th>Job</th><th>Customer</th><th>Stage</th></tr></thead>
    <tbody></tbody>
  </table>
  <script>
    const jobs = [
      { job: 'J-1041', customer: 'Sample Marine', stage: 'Lamination' },
      { job: 'J-1042', customer: 'Sample Marine', stage: 'Fit-out' },
    ];
    const tbody = document.querySelector('#jobs tbody');
    for (const j of jobs) {
      const tr = document.createElement('tr');
      tr.innerHTML = `<td>${j.job}</td><td>${j.customer}</td><td>${j.stage}</td>`;
      tbody.appendChild(tr);
    }
  </script>
</body>
</html>
```

- [ ] **Step 6: Run again (expect PASS)**

Run: `APP=apps/_sample/index.html npx playwright test; echo "exit=$?"`
Expected: `1 passed`, `exit=0`.

- [ ] **Step 7: Write scripts/smoke.sh**

```bash
#!/usr/bin/env bash
# Usage: scripts/smoke.sh <path/to/index.html | http(s)://url>
# Prints plain-language lines; last line is "RESULT: PASS" or "RESULT: FAIL <reason>".
set -uo pipefail
cd "$(dirname "$0")/.."
APP="${1:-}"
if [ -z "$APP" ]; then
  echo "RESULT: FAIL no app given (expected a path to index.html or a URL)"
  exit 1
fi
if [ ! -d node_modules/@playwright ]; then
  echo "Installing test tools (first run only)..."
  npm install --no-audit --no-fund >/dev/null 2>&1 || { echo "RESULT: FAIL could not install test tools (npm)"; exit 1; }
  npx playwright install chromium >/dev/null 2>&1 || { echo "RESULT: FAIL could not install the test browser (network blocked?)"; exit 1; }
fi
echo "Opening $APP in a test browser and checking it loads without errors..."
if APP="$APP" npx playwright test --config playwright.config.ts >/tmp/smoke.log 2>&1; then
  echo "The app opened and no errors were reported."
  echo "RESULT: PASS"
  exit 0
else
  echo "Something went wrong when opening the app:"
  grep -E 'Error|error|uncaught|console' /tmp/smoke.log | head -5 | sed 's/^/  /'
  echo "RESULT: FAIL the app did not load cleanly (see lines above)"
  exit 1
fi
```

Run: `chmod +x scripts/smoke.sh && scripts/smoke.sh apps/_sample/index.html; echo "exit=$?"`
Expected: last two lines `The app opened and no errors were reported.` / `RESULT: PASS`, `exit=0`.

Run: `scripts/smoke.sh apps/does-not-exist/index.html; echo "exit=$?"`
Expected: last line starts `RESULT: FAIL`, `exit=1`.

- [ ] **Step 8: Append to scripts/validate.sh**

After the two `claude plugin validate` lines add:

```bash
echo "-- smoke test on sample app"
scripts/smoke.sh apps/_sample/index.html
```

Run: `scripts/validate.sh`
Expected: ends with `RESULT: PASS` then `OK`.

- [ ] **Step 9: Write .github/workflows/validate.yml**

```yaml
name: validate
on:
  push:
  pull_request:
jobs:
  validate:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-node@v4
        with:
          node-version: 22
      - run: npm ci
      - run: npx playwright install --with-deps chromium
      - name: Smoke test sample app
        run: APP=apps/_sample/index.html npx playwright test --config playwright.config.ts
      - name: Smoke test every partner app that has an index.html
        run: |
          set -e
          for f in apps/*/index.html; do
            [ "$f" = "apps/_sample/index.html" ] && continue
            echo "== $f"; APP="$f" npx playwright test --config playwright.config.ts
          done
```

(Plugin manifest validation needs the `claude` CLI, which isn't on the runner; it stays local in `validate.sh` for now.)

- [ ] **Step 10: Commit**

```bash
git add -A
git commit -m "feat(tests): add playwright smoke scaffold, sample app and CI workflow

Co-Authored-By: Claude Fable 5.1 <noreply@anthropic.com>"
```

---

### Task 5: Hand-assessment template, README, sponsor summary and worked example

**Files:**
- Create: `docs/assessment/TEMPLATE.md`, `docs/assessment/README.md`, `docs/assessment/SUMMARY.md`, `docs/assessment/_sample.md`
- Delete: `docs/assessment/.gitkeep`

**Interfaces:**
- Produces: per-app file `docs/assessment/<app-name>.md` whose lines `**Stage:** Prototype|Owned tool|Proper app|Platform` and `**Relied on by:** ...` are read by `steadyship-status` (Task 3).

- [ ] **Step 1: Write docs/assessment/TEMPLATE.md**

```markdown
# Assessment: <app name>

Copy this file to `docs/assessment/<app-name>.md`. Fill every line. If
you don't know, write "unknown" — that is a finding.

**Stage:** Prototype
<!-- One of: Prototype | Owned tool | Proper app | Platform. See proposal §7. -->

**Relied on by:** <who uses it, how often; "only the builder" is a valid answer>

**Builder:** <name>

**Opened how:** <e.g. double-click index.html from SharePoint-synced folder; localhost; URL>

**Copied into repo at:** `apps/<name>/` on <date> from <original location>

## What it does (one paragraph, business language)

## Data

| What | Where it lives | Who else can see it | Backed up? | Also exists in |
|---|---|---|---|---|
| e.g. Jobs | hardcoded in index.html | nobody | no | Quoting app, Jobs.xlsx on NAS |

## Shared concepts

Which of these does the app use, and does it match the glossary (if one exists yet)?
customer / job / product / part / revision / operation / release / exception / other: ___

## Duplication spotted

Screens, logic or data that also exist in another app:

- 

## Exposure

- Who could see this data if they had the file? 
- Any sign-in? 
- Anything that looks like a password, key or customer PII in the code? 

## If it vanished tomorrow

What would the business lose, and how long to recover?

## Verdict (Chris, one paragraph in plain language)

What this is, what would break, what it would take to rely on it.

## Candidate next step

One of: leave as prototype / graduate to Owned tool / converge concept X with app Y / don't build, use Z instead.
```

- [ ] **Step 2: Write docs/assessment/README.md**

```markdown
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
```

- [ ] **Step 3: Write docs/assessment/SUMMARY.md**

```markdown
# What you've built, and what it would take to rely on it

Prepared by Chris for <sponsor name>, <date>. Plain language on purpose.

## The apps

| App | Who uses it | What it is today | Biggest risk | Suggested next step |
|---|---|---|---|---|
| | | Prototype | | |

## The three things that matter most

1. 
2. 
3. 

## Where the same information lives more than once

| Information | Lives in | And also in | Which one is right? |
|---|---|---|---|
| | | | |

## If a laptop died tomorrow

## What I recommend we do first, and why

## What I recommend we do *not* do yet, and why
```

- [ ] **Step 4: Write the worked example docs/assessment/_sample.md**

```markdown
# Assessment: _sample

Worked example against `apps/_sample/`. Real assessments replace this.

**Stage:** Prototype

**Relied on by:** only the builder

**Builder:** (example)

**Opened how:** double-click `index.html`

**Copied into repo at:** `apps/_sample/` on 2026-10-19 from this repository

## What it does (one paragraph, business language)

Shows a list of jobs with the customer and the stage each job is at.

## Data

| What | Where it lives | Who else can see it | Backed up? | Also exists in |
|---|---|---|---|---|
| Jobs | hardcoded in index.html | nobody | no (only in the file) | would also be in a quoting app and Jobs.xlsx |

## Shared concepts

job, customer. No glossary exists yet.

## Duplication spotted

- None yet (single sample app).

## Exposure

- Anyone with the file sees every job and customer name.
- No sign-in.
- No passwords or keys in the code.

## If it vanished tomorrow

Nothing — data is two example rows.

## Verdict (Chris, one paragraph in plain language)

A prototype. It works, but every job lives inside the page itself, so a
second person can't see the same list and a change to the file loses the
data. Smoke test: PASS.

## Candidate next step

Graduate to Owned tool: move the job list out of the page into one shared
file with a single owner.
```

- [ ] **Step 5: Remove the placeholder and check the status skill reads it**

Run: `rm docs/assessment/.gitkeep && grep -l '^\*\*Stage:\*\*' docs/assessment/*.md`
Expected: `docs/assessment/TEMPLATE.md` and `docs/assessment/_sample.md`.

Then in a Claude Code session: `/steadyship:steadyship-status`
Expected: `Apps assessed: 1 (_sample — Prototype — only the builder)` (TEMPLATE.md excluded by the skill's rule).

- [ ] **Step 6: Commit**

```bash
git add -A
git commit -m "docs(assessment): add template, runbook, sponsor summary and worked example

Co-Authored-By: Claude Fable 5.1 <noreply@anthropic.com>"
```

---

### Task 6: Spike scripts (a) git push and (b) shared-drive read/write

**Files:**
- Create: `scripts/spikes/git-push.sh`, `scripts/spikes/nas-rw.sh`

**Interfaces:**
- Produces: both scripts print a final line `RESULT: PASS` or `RESULT: FAIL <reason>` and exit 0/1 (contract used by `steadyship-spike`, Task 3).
- `git-push.sh` takes no args; uses the repo's `origin`.
- `nas-rw.sh <directory>` takes the shared-drive path as Claude's VM sees it.

- [ ] **Step 1: Write scripts/spikes/nas-rw.sh**

```bash
#!/usr/bin/env bash
# Spike (b): can a script in Claude's VM read and write the shared drive?
# Usage: scripts/spikes/nas-rw.sh <directory on the shared drive>
set -uo pipefail
DIR="${1:-}"
[ -z "$DIR" ] && { echo "RESULT: FAIL no directory given"; exit 1; }
[ -d "$DIR" ] || { echo "RESULT: FAIL directory not visible from the script: $DIR"; exit 1; }
MARK="$DIR/steadyship-spike-$(date +%s).txt"
echo "Listing $DIR ..."; ls -1 "$DIR" | head -5 | sed 's/^/  /'
echo "Writing a test file ..."
echo "steadyship spike $(date -Iseconds)" > "$MARK" 2>/dev/null || { echo "RESULT: FAIL could read but not write: $DIR"; exit 1; }
echo "Reading it back ..."
grep -q 'steadyship spike' "$MARK" || { echo "RESULT: FAIL wrote a file but could not read it back"; exit 1; }
rm -f "$MARK" || { echo "RESULT: FAIL could not delete the test file (remove $MARK by hand)"; exit 1; }
echo "Read, write and delete all worked."
echo "RESULT: PASS"
```

- [ ] **Step 2: Test nas-rw.sh locally (expect PASS, then FAIL)**

Run: `chmod +x scripts/spikes/nas-rw.sh && scripts/spikes/nas-rw.sh /tmp; echo "exit=$?"`
Expected: `RESULT: PASS`, `exit=0`.

Run: `scripts/spikes/nas-rw.sh /definitely/not/here; echo "exit=$?"`
Expected: `RESULT: FAIL directory not visible from the script: /definitely/not/here`, `exit=1`.

- [ ] **Step 3: Write scripts/spikes/git-push.sh**

```bash
#!/usr/bin/env bash
# Spike (a): can this session commit and push to the shared private repo?
# No args. Pushes a marker commit to a throwaway branch and deletes it.
set -uo pipefail
cd "$(dirname "$0")/../.."
git rev-parse --is-inside-work-tree >/dev/null 2>&1 || { echo "RESULT: FAIL not inside a git repository"; exit 1; }
REMOTE="$(git remote get-url origin 2>/dev/null)" || { echo "RESULT: FAIL no 'origin' remote configured"; exit 1; }
echo "Remote: $REMOTE"
if [ -z "$(git config user.email)" ]; then
  git config user.email "steadyship-spike@example.invalid"; git config user.name "Steadyship spike"
fi
BR="spike/git-$(date +%Y%m%d-%H%M%S)"
echo "Checking we can read the remote ..."
git ls-remote --heads origin >/dev/null 2>&1 || { echo "RESULT: FAIL cannot read the remote (no credentials or no network)"; exit 1; }
echo "Creating a throwaway branch $BR with one marker commit ..."
START="$(git rev-parse --abbrev-ref HEAD)"
git checkout -q -b "$BR" || { echo "RESULT: FAIL could not create a branch"; exit 1; }
echo "$(date -Iseconds)" > docs/spikes/.git-spike-marker
git add docs/spikes/.git-spike-marker && git commit -q -m "spike: git push marker" || { git checkout -q "$START"; echo "RESULT: FAIL could not commit"; exit 1; }
echo "Pushing ..."
if git push -q -u origin "$BR" 2>/tmp/push.err; then
  echo "Push worked. Cleaning up ..."
  git push -q origin --delete "$BR" 2>/dev/null || echo "  (could not delete remote branch $BR — delete it on GitHub later)"
  git checkout -q "$START" && git branch -q -D "$BR"
  echo "RESULT: PASS"
else
  git checkout -q "$START" && git branch -q -D "$BR"
  echo "Push failed:"; head -3 /tmp/push.err | sed 's/^/  /'
  echo "RESULT: FAIL could not push (credentials or network)"
  exit 1
fi
```

- [ ] **Step 4: Test git-push.sh locally against a bare repo (expect PASS), then with no remote (expect FAIL)**

Run:
```bash
chmod +x scripts/spikes/git-push.sh
git init -q --bare /tmp/steadyship-bare.git
git remote add origin /tmp/steadyship-bare.git
scripts/spikes/git-push.sh; echo "exit=$?"
git remote remove origin
scripts/spikes/git-push.sh; echo "exit=$?"
```
Expected: first run ends `RESULT: PASS`, `exit=0`, and `git branch` shows only your original branch; second run `RESULT: FAIL no 'origin' remote configured`, `exit=1`.

- [ ] **Step 5: Commit**

```bash
git add scripts/spikes
git commit -m "feat(spikes): add git-push and nas-rw spike scripts

Co-Authored-By: Claude Fable 5.1 <noreply@anthropic.com>"
```

---

### Task 7: Spike runbooks, hosting files, results table and GitHub setup

**Files:**
- Create: `docs/spikes/README.md`, `docs/spikes/RESULTS.md`, `docs/spikes/e-plugin.md`, `docs/spikes/a-git.md`, `docs/spikes/b-nas.md`, `docs/spikes/c-tests.md`, `docs/spikes/d-hosting.md`, `docs/spikes/hosting/staticwebapp.config.json`, `docs/spikes/hosting/azure-static-web-apps.yml`
- Modify: `plugin/.claude-plugin/plugin.json` (repository URL), `README.md` (clone URL)
- Delete: `docs/spikes/.gitkeep`

**Interfaces:**
- Consumes: `scripts/spikes/*.sh`, `scripts/smoke.sh` contracts; `steadyship-spike` skill.
- Produces: `docs/spikes/RESULTS.md` table read by `steadyship-status`: columns `| Spike | Result | Date | Note |`, Result one of `PASS`, `FAIL`, blank.

- [ ] **Step 1: Create the private GitHub repo and point everything at it**

Run (Chris's machine, `gh` authenticated):
```bash
gh repo create steadyship --private --source=. --remote=origin --push
```
Expected: repo created, `main` pushed. Then replace `REPLACE_ME` in `plugin/.claude-plugin/plugin.json` with your GitHub username/org, and add the clone URL to `README.md` under a `## Clone` heading.

Run: `claude plugin validate plugin --strict && git push`
Expected: no errors; CI `validate` workflow runs green on GitHub (check `gh run list --limit 1`).

- [ ] **Step 2: Write docs/spikes/RESULTS.md**

```markdown
# Spike results — go/no-go

Filled in on the partner's machine. One row per spike. Result is PASS,
FAIL, or blank (not run). The `steadyship-status` skill reads this table.

| Spike | Result | Date | Note |
|---|---|---|---|
| e | | | |
| a | | | |
| b | | | |
| c | | | |
| d | | | |

## Decision (Chris, after all rows are filled)

Per proposal §11: every PASS, or a FAIL with its fallback accepted below,
means proceed to week 3.

| Spike | Fallback accepted? | What changes |
|---|---|---|
| | | |
```

- [ ] **Step 3: Write docs/spikes/README.md**

```markdown
# Spikes — weeks 1–2 go/no-go

Five checks, run **on the partner's Windows machine, on their Claude Team
account, in a local (on-device) session**. Order matters: (e) first, so the
others can use the plugin; if (e) fails, every runbook also gives the plain
prompt to paste instead.

| Spike | Question | Runbook | Needs |
|---|---|---|---|
| e | Does the plugin reach a second Team member without their action? | `e-plugin.md` | Team owner, 2 members |
| a | Can a session commit and push to the private repo, no terminal? | `a-git.md` | GitHub token (one-time, Chris) |
| b | Can a session read/write the real shared drive — from file tools *and* from a script? | `b-nas.md` | The mapped drive letter |
| c | Can a session run the smoke test on one real app and report plainly? | `c-tests.md` | One app in `apps/` |
| d | Can one app be served behind sign-in and opened by a second staff member? | `d-hosting.md` | Azure subscription (free), GitHub |

## Before any spike **[ON-SITE, Chris, ~1 hour]**

1. Confirm the Claude desktop app is the MSIX install and Windows has
   "Virtual Machine Platform" enabled (Settings → Optional features).
2. In Claude: Organization settings → Cowork → check "Run Cowork in the
   cloud". Note the setting. For spikes a–c use a **local** session.
3. Clone the repo onto the machine into `C:\Users\<builder>\steadyship`
   (Chris does this once; builders never do).
4. Attach that folder in Claude desktop via the folder picker.
5. Also map the NAS share to a drive letter (e.g. `Z:`) if it isn't already,
   and attach it too.

## Recording

After each spike, paste the row the skill gives you into `RESULTS.md`.
Commit from Chris's machine if spike (a) hasn't passed yet.
```

- [ ] **Step 4: Write docs/spikes/e-plugin.md**

```markdown
# Spike e — org-wide plugin install

**Question:** when the Team owner sets the Steadyship plugin to "Installed
by default", does it appear for a second member without them doing anything,
and does it work?

**Who:** Team owner (sponsor or Chris) + one builder. **Where:** two
different accounts, ideally two machines.

## Steps (owner)

1. Install the Claude GitHub App on the private `steadyship` repo
   (GitHub → Settings → Applications → Claude → repository access).
2. Claude desktop → Customize → Plugins → **Add marketplace** → paste the
   GitHub repo URL. The marketplace named `steadyship` should appear.
3. Find plugin `steadyship` → Default access → **Installed by default**.

## Steps (builder)

1. Quit and reopen Claude desktop. Open any folder-attached task on the
   `steadyship` repo clone.
2. Type: `run steadyship status`

## What Claude does

Follows the `steadyship-status` skill: reads the assessment folder and
RESULTS.md and replies starting **"Steadyship is installed and working."**

## Pass

The reply starts with that sentence and reports at least 1 app assessed
(`_sample`). Paste into RESULTS.md: `| e | PASS | <date> | appeared for <builder> after restart |`

## If it fails

- Plugin not listed for the builder → check the GitHub App has access to
  the repo; check Default access saved; wait 10 minutes and restart.
- Listed but "steadyship status" does nothing → run
  `claude plugin validate plugin --strict` on Chris's machine; fix; push.
- Still failing → fallback: each builder installs via Customize → Plugins →
  Upload zip (Chris zips `plugin/`). Record `FAIL` and the fallback.
  **Meaning:** the plugin still works, but every update needs a manual
  re-upload per builder.
```

- [ ] **Step 5: Write docs/spikes/a-git.md**

```markdown
# Spike a — commit and push without a terminal

**Question:** can a local Claude session on the builder's machine push to the
private GitHub repo using credentials set up once, and do those credentials
survive a new session?

**Who:** Chris sets up once; builder runs. **Where:** builder's machine,
local session, `steadyship` folder attached.

## One-time setup (Chris, ~15 min) — do NOT put the token in any file in the repo

1. GitHub → Settings → Developer settings → Fine-grained tokens → Generate:
   repository access = only `steadyship`; permissions = Contents: Read and
   write; expiry 30 days. Copy it.
2. In a Claude session with the folder attached, ask Claude:
   "Set the git remote to https://github.com/<owner>/steadyship.git and
   configure `git config credential.helper store`. Then run
   `git ls-remote origin` and when it asks for a password I'll give you the
   token." Give the token when prompted. (The token now sits in the VM's
   `~/.git-credentials`. It is scoped to one repo and expires in 30 days.)
3. Ask: "Run `git ls-remote --heads origin`" — expected: a list of branches.

## Builder runs

Type: `run spike a` (or, without the plugin: "Run `bash
scripts/spikes/git-push.sh` and tell me in plain language if it passed.")

## What Claude does

Runs `scripts/spikes/git-push.sh`: creates a throwaway branch, one marker
commit, pushes it, deletes it. Last line `RESULT: PASS` or `RESULT: FAIL`.

## Pass

`RESULT: PASS`. **Then close the session, open a new one, and run it
again.** Both must pass — the second proves credentials persist.
Paste: `| a | PASS | <date> | persisted across sessions: yes/no |`

## If it fails

- "cannot read the remote" → token wrong or expired, or network to
  github.com blocked from the VM (note which: ask Claude to run
  `curl -sI https://github.com | head -1`).
- Passes first time, fails after a new session → VM home is not persistent.
  Record it. **Fallback:** the plugin asks for the token at the start of each
  session (worse), or commits land in the attached folder and Chris pushes
  from his machine weekly (acceptable for V0), or builders use Claude Code
  after a one-time `gh auth login` (proposal §11 fallback).
  **Meaning:** "no terminal ever" becomes "one setup session, then
  conversational."
```

- [ ] **Step 6: Write docs/spikes/b-nas.md**

```markdown
# Spike b — the shared drive, from file tools and from a script

**Question:** can a local session see the real NAS/SharePoint folder where
the spreadsheets live (1) through Claude's file tools and (2) from a bash
script inside the VM? Both matter: (1) for the coach to read data, (2) for
tests and data moves to be automated.

**Who:** builder. **Where:** builder's machine, local session, with the
mapped drive (e.g. `Z:\`) attached via the folder picker.

## Builder runs

Part 1 — type: "In the attached Z: folder, list the first five files, create
a file called steadyship-spike.txt containing today's date, read it back to
me, then delete it."

Part 2 — type: `run spike b` and when asked for the path, give the folder
name as you attached it (Claude will work out how the VM sees it; if it
can't, that is the finding).

## What Claude does

Part 1 uses file tools only. Part 2 runs `scripts/spikes/nas-rw.sh <dir>`.

## Pass

Part 1: all four actions work. Part 2: `RESULT: PASS`.
Paste: `| b | PASS | <date> | file tools: ok; script: ok |`
If Part 1 passes and Part 2 fails, record `| b | FAIL | <date> | file tools: ok; script: not visible |` — this is the known Windows mapped-drive bug.

## If it fails

- Part 1 fails → the drive wasn't mapped before Claude started, or isn't
  attached. Map it, restart Claude, attach, retry once.
- Part 2 fails only → **Fallback:** data moves and reads go through Claude's
  file tools, not scripts; or the shared data folder is a OneDrive-synced
  SharePoint library (local path, no mapped drive) — retry Part 2 with that
  path. **Meaning:** automation that touches the NAS runs in CI or on
  Chris's machine, not in the builder's session, until the bug is fixed.
```

- [ ] **Step 7: Write docs/spikes/c-tests.md**

```markdown
# Spike c — run a real smoke test and say what happened

**Question:** inside the builder's local session, can Claude install the
test tools, run the smoke test against one real app, and report the result
in plain language?

**Who:** builder. **Where:** builder's machine, local session, `steadyship`
folder attached, with at least one real app copied to `apps/<name>/` by
Chris (see `docs/assessment/README.md` step 2).

## Builder runs

Type: `run spike c` and when asked which app, give its folder name.
(Without the plugin: "Run `bash scripts/smoke.sh apps/<name>/index.html` and
tell me in plain language whether the app passed.")

## What Claude does

Runs `scripts/smoke.sh apps/<name>/index.html`. First run installs
`@playwright/test` and a Chromium browser inside the VM (may take a few
minutes).

## Pass

`RESULT: PASS`, and Claude's explanation is something the builder can
repeat back. Paste: `| c | PASS | <date> | app: <name>; install took ~N min |`

A `RESULT: FAIL the app did not load cleanly` is **also a pass for the
spike** (the tooling worked; the app has a real error — note it in the
app's assessment).

## If it fails

- `could not install the test browser` → the VM's network allowlist blocks
  the Playwright browser download. **Fallback:** tests run in GitHub
  Actions (`.github/workflows/validate.yml` already does this for every
  `apps/*/index.html`); the coach reports CI results instead of running
  locally. Record `FAIL` + "CI fallback". **Meaning:** verification is
  one push away rather than instant; acceptable for V0.
- `could not install test tools (npm)` → npm registry blocked (unexpected;
  it is on the allowlist). Record the exact error.
```

- [ ] **Step 8: Write the hosting files**

`docs/spikes/hosting/staticwebapp.config.json`:

```json
{
  "routes": [
    { "route": "/.auth/login/aad", "allowedRoles": ["anonymous", "authenticated"] },
    { "route": "/.auth/logout", "allowedRoles": ["anonymous", "authenticated"] },
    { "route": "/*", "allowedRoles": ["staff"] }
  ],
  "responseOverrides": {
    "401": { "redirect": "/.auth/login/aad", "statusCode": 302 }
  },
  "auth": {
    "identityProviders": {
      "github": { "enabled": false },
      "twitter": { "enabled": false }
    }
  },
  "navigationFallback": { "rewrite": "/index.html" }
}
```

`docs/spikes/hosting/azure-static-web-apps.yml` (copied to `.github/workflows/` during the spike):

```yaml
name: deploy-spike-app
on:
  push:
    branches: [main]
    paths: ['apps/SPIKE_APP/**']
  workflow_dispatch:
jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - name: Put the auth config next to the app
        run: cp docs/spikes/hosting/staticwebapp.config.json apps/SPIKE_APP/
      - uses: Azure/static-web-apps-deploy@v1
        with:
          azure_static_web_apps_api_token: ${{ secrets.AZURE_STATIC_WEB_APPS_API_TOKEN }}
          repo_token: ${{ secrets.GITHUB_TOKEN }}
          action: upload
          app_location: apps/SPIKE_APP
          output_location: ''
          skip_app_build: true
```

- [ ] **Step 9: Write docs/spikes/d-hosting.md**

```markdown
# Spike d — one app, hosted, behind sign-in, opened by someone else

**Question:** can one existing app be served from somewhere that isn't a
laptop, require a Microsoft sign-in, and be opened by a second staff member?

**Who:** Chris (setup, ~1 hour), then a second staff member. **Where:**
Azure portal + GitHub + any browser.

## Why Azure Static Web Apps (Free)

SharePoint will not serve HTML+JS (strict file handling). SWA Free costs
$0, deploys from the GitHub repo, and has built-in Microsoft sign-in with
"invitation" roles (up to 25 invited users on Free) — so only invited staff
can open it, without paying for the Standard tier. See proposal §6.

## Steps (Chris)

1. Pick the app: the simplest one that passed spike c. Call it `<name>`.
2. Azure portal → Create → Static Web App: Plan **Free**; Source **GitHub**;
   repo `steadyship`, branch `main`; Build preset **Custom**; app location
   `apps/<name>`; output location empty. Create. (Azure adds a workflow
   file and a repo secret `AZURE_STATIC_WEB_APPS_API_TOKEN_...`.)
3. Delete the Azure-generated workflow, copy
   `docs/spikes/hosting/azure-static-web-apps.yml` to
   `.github/workflows/deploy-spike-app.yml`, replace `SPIKE_APP` with
   `<name>` (two places) and the secret name with the one Azure created.
   Commit and push. Check the Actions run is green.
4. SWA → Role management → Invite: the second staff member's Microsoft
   account, provider **Microsoft Entra ID**, role **staff**, 24 hours.
   Send them the invite link.
5. Open the SWA URL yourself: you must be redirected to a Microsoft login,
   and after login see **403** (you aren't in `staff`) — that proves the
   gate works. Invite yourself too if you want in.

## Steps (second staff member)

Open the invite link, sign in with their work Microsoft account, then open
the app URL. The app should load.

## Pass

Second staff member sees the app; an uninvited signed-in account gets 403;
a logged-out browser is redirected to login.
Paste: `| d | PASS | <date> | SWA Free, invited roles, url: <url> |`

## If it fails

- No Azure subscription available → **Fallback:** Cloudflare Pages +
  Cloudflare Access (free for up to 50 users, Entra as identity provider).
  Record `FAIL` + fallback. **Meaning:** hosting is still solved, with a
  second vendor to manage.
- Sign-in works but tenant restriction is wanted (any Microsoft account
  can *attempt* login) → invitations already restrict who gets in; strict
  tenant lock needs SWA Standard (~US$9/month). Note it; not a fail.
- Deploy action fails → check `app_location` matches the folder exactly
  (case-sensitive) and the secret name.
```

- [ ] **Step 10: Remove placeholder, validate, commit, push**

Run:
```bash
rm docs/spikes/.gitkeep
scripts/validate.sh
git add -A
git commit -m "docs(spikes): add runbooks a–e, hosting config and results table

Co-Authored-By: Claude Fable 5.1 <noreply@anthropic.com>"
git push
```
Expected: `validate.sh` ends `OK`; push succeeds; CI green.

Then in a Claude Code session: `/steadyship:steadyship-status`
Expected: `Apps assessed: 1 (...)`, `Spikes: 0 passed, 0 failed, 5 not yet run`, `Next step: run spike e`.

---

### Task 8: On-site execution checklist **[ON-SITE]**

This task is not code. It is the ordered list of what Chris does on the partner's machine so nothing from Tasks 1–7 is wasted. Expected total: two visits, ~3 hours each, or one long one.

**Files:**
- Modify: `docs/spikes/RESULTS.md` (filled), `docs/assessment/*.md` (one per app), `docs/assessment/SUMMARY.md` (filled)

- [ ] **Step 1: Pre-flight (Chris, remote, 30 min)** — Task 7 Step 1 done; CI green; GitHub App installed on the repo; fine-grained token generated (not stored anywhere yet); Azure subscription confirmed or Cloudflare account ready.

- [ ] **Step 2: Visit 1, machine prep (1 hour)** — `docs/spikes/README.md` "Before any spike" steps 1–5. Note the "Run Cowork in the cloud" setting in RESULTS.md's Note column for spike e.

- [ ] **Step 3: Visit 1, spike e then a (1 hour)** — follow `e-plugin.md`, then `a-git.md` including the second-session re-run. Paste rows.

- [ ] **Step 4: Visit 1, app inventory (1 hour)** — `docs/assessment/README.md` steps 1–2 for every app (copy in, no assessment yet). Commit from Chris's machine if (a) failed.

- [ ] **Step 5: Between visits (Chris, remote, 2–3 hours)** — assessments for every app (README steps 3–4), SUMMARY.md, commit. Set up spike d through step 4 of `d-hosting.md`.

- [ ] **Step 6: Visit 2, spikes b, c, d (1.5 hours)** — `b-nas.md`, `c-tests.md` on the app chosen for d, then `d-hosting.md` "Steps (second staff member)". Paste rows.

- [ ] **Step 7: Visit 2, sponsor read-through (30 min)** — walk the sponsor through SUMMARY.md. Proposal §12 criterion 3: can they say, unprompted, which apps the business depends on and what the main risk is? Write their answer verbatim at the bottom of SUMMARY.md.

- [ ] **Step 8: Decision (Chris, 30 min)** — fill the Decision table in RESULTS.md. Commit and push. Run `/steadyship:steadyship-status`; it should report 5 spikes with results and "Review RESULTS.md with Chris and decide week 3."

---

## Self-review against the spec

- **§11 weeks 1–2, spikes (a)–(e):** Task 6 (scripts a, b), Task 7 (runbooks a–e, hosting files), Task 8 (execution). Spike c uses Task 4. ✔
- **§11 hand assessment "every app… ground truth for the assess skill":** Task 5 template emphasises duplication and data location; Task 8 steps 4–5. ✔
- **§12 criterion 1 (spikes pass or fallbacks accepted):** every runbook has an "If it fails" with the fallback and its meaning; RESULTS.md has the Decision table. ✔
- **§12 criterion 3 (sponsor can restate):** Task 8 step 7. ✔
- **§6 "no native CLAUDE.md; skills must load repo context":** both skills read files explicitly. ✔
- **§9 secrets never in Git:** `.gitignore` (Task 1), token handling in `a-git.md` kept to the VM credential store, hosting token in a GitHub secret. ✔
- **Global constraint "apps copied unmodified":** assessment README step 2; `.gitignore` keeps their data out. Note: an app whose data is in a `.json` beside `index.html` will be excluded by `.gitignore` and the smoke test may then fail on the copy — record that in the app's assessment as "data file not committed"; it is a finding, not a bug. ✔
- **Placeholder scan:** `REPLACE_ME` and `SPIKE_APP` are deliberate tokens replaced in named steps; no TBD/TODO. ✔
- **Type/name consistency:** `RESULT: PASS|FAIL` line is the contract in `smoke.sh`, `git-push.sh`, `nas-rw.sh`, and `steadyship-spike`; `**Stage:**` / `**Relied on by:**` lines match between TEMPLATE.md, `_sample.md` and `steadyship-status`; RESULTS.md columns match the skill. Skill names `steadyship-status` / `steadyship-spike` match plugin namespace `steadyship:`. ✔
