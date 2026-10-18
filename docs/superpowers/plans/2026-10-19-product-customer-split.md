# Product / Customer Repo Split — Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Make `steadyship` a pure product repository (plugin + templates + an init skill + CI that proves the templates generate a working customer repo), and make every customer's repository a generated, self-contained artefact the customer owns — starting with a standing demo customer `steadyship-demo`.

**Architecture:** Everything a customer repo needs moves under `plugin/templates/` with `{{PLACEHOLDERS}}` for business facts. A deterministic scaffolder `plugin/scripts/init.sh` copies the templates into a target directory, substitutes the facts, writes a `steadyship.md` marker, and makes the first commit; a `steadyship-init` skill drives it conversationally and offers (never performs silently) GitHub repo creation. Product CI runs `init.sh` into a temp dir on every push and runs the generated repo's own checks plus the two spike scripts. Existing skills detect a Steadyship repo by the `steadyship.md` marker instead of the proposal file.

**Tech Stack:** bash, sed, git, Claude Code plugin format, Node 22 + Playwright (inside generated repos), GitHub Actions, `gh`.

**Spec:** `docs/proposal-v0.1.md` §3 ("What Steadyship is not"; no state outside the customer's repository; nothing business-specific in the product), §4 roles (setup owner, sponsor), §6, §11. Conversation decisions 19 Oct 2026: product repo stays under `cookc`; demo customer repo `cookc/steadyship-demo` is approved; real customer repos are created on-site under the customer's own GitHub account by the init skill; the init skill creates the GitHub repo only if `gh` is logged in and the user says yes.

## Global Constraints

- `plugin/` must contain **no** business-specific fact: no person's name except the plugin author in `plugin.json`, no GitHub owner except in `plugin.json`'s `repository`, no drive letter, no business name. Verified by grep in Task 1 and in product CI.
- Placeholders are exactly: `{{BUSINESS_NAME}}`, `{{SETUP_OWNER}}`, `{{SPONSOR}}`, `{{GITHUB_OWNER}}`, `{{REPO_NAME}}`, `{{SHARED_DRIVE}}`, `{{TEMPLATE_VERSION}}`. No other `{{…}}` token may exist in templates; a generated repo must contain no `{{` at all.
- A generated customer repo is self-contained: it works with the plugin uninstalled (its own `scripts/validate.sh`, smoke test, CI, runbooks). It references the product only in `steadyship.md`.
- Contracts preserved: `RESULT: PASS|FAIL <reason>` last line + exit 0/1 for `smoke.sh`, `git-push.sh`, `nas-rw.sh`; `**Stage:**` / `**Relied on by:**` lines; `RESULTS.md` columns `| Spike | Result | Date | Note |`.
- Side effects outside this machine (creating/pushing GitHub repos) happen only in the steps that say so (Task 6), which the user approved in conversation.
- Commit after every task. Trailer: `Co-Authored-By: <implementer's model> <noreply@anthropic.com>`.

---

## File structure (after)

```
steadyship/                                   PRODUCT REPO
├── .claude-plugin/marketplace.json
├── plugin/
│   ├── .claude-plugin/plugin.json            version 0.1.0
│   ├── skills/
│   │   ├── steadyship-init/SKILL.md          NEW
│   │   ├── steadyship-status/SKILL.md        marker detection changed
│   │   └── steadyship-spike/SKILL.md         marker detection added
│   ├── scripts/init.sh                       NEW scaffolder
│   └── templates/                            NEW — the customer repo, parameterised
│       ├── steadyship.md                     marker + facts
│       ├── README.md                         customer README
│       ├── .gitignore  .gitattributes
│       ├── package.json  playwright.config.ts  tests/smoke/app.spec.ts
│       ├── scripts/validate.sh  scripts/smoke.sh  scripts/spikes/{git-push,nas-rw}.sh
│       ├── apps/_sample/index.html
│       ├── docs/assessment/{README,TEMPLATE,SUMMARY,_sample}.md
│       ├── docs/spikes/{README,RESULTS,a-git,b-nas,c-tests,d-hosting,e-plugin}.md
│       ├── docs/spikes/hosting/{staticwebapp.config.json,azure-static-web-apps.yml}
│       └── .github/workflows/validate.yml    customer CI (smoke only)
├── scripts/validate.sh                       PRODUCT checks
├── tests/test-init.sh                        NEW
├── .github/workflows/validate.yml            PRODUCT CI
├── docs/proposal-v0.1.md  docs/superpowers/plans/*  docs/rehearsal.md (NEW)
├── .gitignore  .gitattributes  README.md     product versions
└── (removed from root: apps/, package.json, package-lock.json, playwright.config.ts,
     tests/smoke/, scripts/smoke.sh, scripts/spikes/, docs/assessment/, docs/spikes/)

~/steadyship-demo/                            DEMO CUSTOMER REPO (generated, Task 6)
```

---

### Task 1: Move customer files into `plugin/templates/` and parameterise them

**Files:**
- Move (git mv): `apps/_sample/index.html`, `package.json`, `playwright.config.ts`, `tests/smoke/app.spec.ts`, `scripts/smoke.sh`, `scripts/spikes/git-push.sh`, `scripts/spikes/nas-rw.sh`, `docs/assessment/*.md`, `docs/spikes/**`, `.github/workflows/validate.yml`, `.gitattributes` → same relative paths under `plugin/templates/`
- Copy then edit: `.gitignore` → `plugin/templates/.gitignore`
- Create: `plugin/templates/steadyship.md`, `plugin/templates/README.md`, `plugin/templates/scripts/validate.sh`
- Move (git mv): `package-lock.json` → `plugin/templates/package-lock.json` (generated repos need it for `npm ci`)
- Delete: `apps/.gitkeep`; root `scripts/validate.sh` content is replaced in Task 4 (leave the file for now)
- Modify: `plugin/.claude-plugin/plugin.json` (version → `0.1.0`)

**Interfaces:**
- Produces: `plugin/templates/` tree with exactly the seven placeholders; `plugin/templates/steadyship.md` marker whose first line is `# Steadyship repository` and which contains `Template version: {{TEMPLATE_VERSION}}`.

- [ ] **Step 1: Move files with history**

```bash
cd ~/steadyship
mkdir -p plugin/templates/{apps,tests,scripts/spikes,docs,.github/workflows}
git mv apps/_sample plugin/templates/apps/_sample
git mv package.json package-lock.json playwright.config.ts plugin/templates/
git mv tests/smoke plugin/templates/tests/smoke
git mv scripts/smoke.sh plugin/templates/scripts/smoke.sh
git mv scripts/spikes plugin/templates/scripts/spikes
git mv docs/assessment plugin/templates/docs/assessment
git mv docs/spikes plugin/templates/docs/spikes
git mv .github/workflows/validate.yml plugin/templates/.github/workflows/validate.yml
git mv .gitattributes plugin/templates/.gitattributes
cp .gitignore plugin/templates/.gitignore
git rm -q apps/.gitkeep
git status --short | head -40
```
Expected: renames listed as `R`, one deletion, one untracked `plugin/templates/.gitignore`.

- [ ] **Step 2: Restore product-level `.gitattributes` and `.gitignore`**

Root `.gitattributes` (new, product):
```
* text=auto eol=lf
*.sh text eol=lf
```
Root `.gitignore` becomes (product only):
```
node_modules/
.superpowers/
/tmp-init-*/
.DS_Store
Thumbs.db
```
`plugin/templates/.gitignore` stays as copied (customer rules) plus one added line at the end: `.git-credentials` is already present; add nothing else.

- [ ] **Step 3: Parameterise — apply these substitutions inside `plugin/templates/` only**

Run each and then grep to confirm nothing is left:
```bash
cd ~/steadyship/plugin/templates
# names and owners
grep -rl "Chris" . | xargs sed -i 's/Chris'"'"'s personal account/{{GITHUB_OWNER}}'"'"'s GitHub account/g; s/Chris/{{SETUP_OWNER}}/g'
grep -rl "cookc" . | xargs sed -i 's#github\.com/cookc/steadyship#github.com/{{GITHUB_OWNER}}/{{REPO_NAME}}#g; s/username=cookc/username={{GITHUB_OWNER}}/g; s/cookc/{{GITHUB_OWNER}}/g'
# shared drive letter in b-nas.md and spikes README
sed -i 's/`Z:\\`/`{{SHARED_DRIVE}}`/g; s/Z: folder/{{SHARED_DRIVE}} folder/g; s/(e\.g\. `Z:`)/(e.g. `{{SHARED_DRIVE}}`)/g; s/`Z:`/`{{SHARED_DRIVE}}`/g' docs/spikes/b-nas.md docs/spikes/README.md
# the proposal is a product doc, not in the customer repo
grep -rl "proposal-v0.1.md\|proposal §" . | xargs sed -i 's#`docs/proposal-v0.1.md`#the Steadyship proposal (product documentation)#g; s/proposal §\([0-9]*\)/Steadyship proposal §\1/g; s/See proposal §7/See the Steadyship proposal §7/g'
# clone path in spikes README
sed -i 's#C:\\Users\\<builder>\\steadyship#C:\\Users\\<builder>\\{{REPO_NAME}}#g' docs/spikes/README.md
grep -rn "Chris\|cookc\|Z:\|proposal-v0.1" . ; echo "--- leftovers above must be empty"
grep -rhoE '\{\{[A-Z_]+\}\}' . | sort -u
```
Expected: the leftovers grep prints nothing; the placeholder list is a subset of `{{BUSINESS_NAME}} {{GITHUB_OWNER}} {{REPO_NAME}} {{SETUP_OWNER}} {{SHARED_DRIVE}} {{SPONSOR}} {{TEMPLATE_VERSION}}`. If sed produced an awkward sentence (read `a-git.md`, `e-plugin.md`, `docs/assessment/README.md`, `docs/spikes/README.md`, `b-nas.md` in full afterwards), fix the wording by hand but keep the placeholder.

Then set the two role lines in `docs/assessment/README.md` to exactly:
```
**Setup owner:** {{SETUP_OWNER}}
**Sponsor:** {{SPONSOR}}
```
and its first line to `Owner: {{SETUP_OWNER}}. Time box: …` (keep the rest).

- [ ] **Step 4: Customer `scripts/validate.sh` (smoke only — no `claude` CLI in a customer repo)**

`plugin/templates/scripts/validate.sh`:
```bash
#!/usr/bin/env bash
# Runs every check this repository's CI runs. Exit non-zero on first failure.
set -euo pipefail
cd "$(dirname "$0")/.."
echo "== validate.sh =="
echo "-- smoke test on sample app"
scripts/smoke.sh apps/_sample/index.html
for f in apps/*/index.html; do
  [ "$f" = "apps/_sample/index.html" ] && continue
  echo "-- smoke test on $f"
  scripts/smoke.sh "$f"
done
echo "OK"
```
Make it executable: `chmod +x plugin/templates/scripts/validate.sh`.

- [ ] **Step 5: Customer CI template — adjust to call validate.sh**

Replace the two smoke steps in `plugin/templates/.github/workflows/validate.yml` with:
```yaml
      - name: Validate
        run: scripts/validate.sh
```
(keep checkout, setup-node, `npm ci`, `npx playwright install --with-deps chromium`).

- [ ] **Step 6: Marker and customer README templates**

`plugin/templates/steadyship.md`:
```markdown
# Steadyship repository

This repository was set up by the Steadyship plugin. It is self-contained:
everything here works without the plugin.

Business: {{BUSINESS_NAME}}
Setup owner: {{SETUP_OWNER}}
Sponsor: {{SPONSOR}}
GitHub: {{GITHUB_OWNER}}/{{REPO_NAME}}
Shared drive: {{SHARED_DRIVE}}
Template version: {{TEMPLATE_VERSION}}

Start with `docs/spikes/README.md`, then `docs/assessment/README.md`.
```

`plugin/templates/README.md`:
```markdown
# {{BUSINESS_NAME}} — apps

The business's own apps, their assessments, and the checks that keep them
honest. Set up with Steadyship (see `steadyship.md`); works without it.

- `apps/<name>/` — each app, copied in unmodified
- `docs/assessment/` — what each app is and what it would take to rely on it
- `docs/spikes/` — the go/no-go checks and their results
- `scripts/validate.sh` — every check CI runs

Setup owner: {{SETUP_OWNER}} · Sponsor: {{SPONSOR}}
```

- [ ] **Step 7: Bump plugin version and validate**

In `plugin/.claude-plugin/plugin.json` set `"version": "0.1.0"`.
Run: `cd ~/steadyship && claude plugin validate plugin --strict && claude plugin validate . --strict && echo MANIFESTS_OK`
Expected: no errors, `MANIFESTS_OK`. If `--strict` complains about `plugin/templates` or `plugin/scripts`, report it (do not rename the directories) — it is a finding for the controller.

- [ ] **Step 8: Product-level grep gate (will be reused by CI)**

Run:
```bash
cd ~/steadyship
grep -rnI "Chris\|cookc\|boat" plugin/ | grep -v 'plugin/.claude-plugin/plugin.json' ; echo "--- must be empty"
grep -rhoE '\{\{[A-Za-z_]+\}\}' plugin/templates | sort -u
```
Expected: first grep empty; second grep lists only the seven allowed placeholders.

- [ ] **Step 9: Commit**

```bash
git add -A
git commit -m "refactor: move customer repo content into plugin/templates with placeholders

Co-Authored-By: <model> <noreply@anthropic.com>"
```

---

### Task 2: `plugin/scripts/init.sh` scaffolder, test-first

**Files:**
- Create: `tests/test-init.sh`, `plugin/scripts/init.sh`

**Interfaces:**
- Produces: `plugin/scripts/init.sh <target-dir> --business NAME --setup-owner NAME --sponsor NAME --github-owner OWNER --repo-name NAME --shared-drive PATH [--no-git]` → creates the directory (must not exist or must be empty), copies `plugin/templates/` (including dotfiles) into it, substitutes the seven placeholders, sets `{{TEMPLATE_VERSION}}` from `plugin/.claude-plugin/plugin.json`, makes every `.sh` executable, and unless `--no-git`: `git init -b main`, commits `chore: initialise Steadyship repository (template vX)`. Prints `RESULT: PASS created <dir>` or `RESULT: FAIL <reason>`; exit 0/1. Never touches GitHub.

- [ ] **Step 1: Write the failing test**

`tests/test-init.sh`:
```bash
#!/usr/bin/env bash
# Generates a customer repo from the templates and checks it is complete and self-contained.
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
OUT="$(mktemp -d "${TMPDIR:-/tmp}/steadyship-init-test.XXXXXX")"
trap 'rm -rf "$OUT"' EXIT
DIR="$OUT/demo-apps"
fail() { echo "FAIL: $*"; exit 1; }

"$ROOT/plugin/scripts/init.sh" "$DIR" \
  --business "Demo Boatworks" --setup-owner "Sam Setup" --sponsor "Olive Owner" \
  --github-owner demo-org --repo-name demo-apps --shared-drive 'Z:\' | tee "$OUT/init.log"
tail -1 "$OUT/init.log" | grep -q '^RESULT: PASS' || fail "init did not PASS"

for f in steadyship.md README.md .gitignore .gitattributes package.json playwright.config.ts \
         tests/smoke/app.spec.ts scripts/validate.sh scripts/smoke.sh \
         scripts/spikes/git-push.sh scripts/spikes/nas-rw.sh apps/_sample/index.html \
         docs/assessment/README.md docs/assessment/TEMPLATE.md docs/assessment/SUMMARY.md \
         docs/assessment/_sample.md docs/spikes/README.md docs/spikes/RESULTS.md \
         docs/spikes/a-git.md docs/spikes/b-nas.md docs/spikes/c-tests.md docs/spikes/d-hosting.md \
         docs/spikes/e-plugin.md docs/spikes/hosting/staticwebapp.config.json \
         docs/spikes/hosting/azure-static-web-apps.yml .github/workflows/validate.yml; do
  [ -f "$DIR/$f" ] || fail "missing $f"
done
for s in scripts/validate.sh scripts/smoke.sh scripts/spikes/git-push.sh scripts/spikes/nas-rw.sh; do
  [ -x "$DIR/$s" ] || fail "$s not executable"
done
if grep -rn '{{' "$DIR" --exclude-dir=.git >/dev/null; then grep -rn '{{' "$DIR" --exclude-dir=.git; fail "unsubstituted placeholders"; fi
grep -q '^Business: Demo Boatworks$' "$DIR/steadyship.md" || fail "business not substituted"
grep -q '^Setup owner: Sam Setup$' "$DIR/steadyship.md" || fail "setup owner not substituted"
grep -q 'Z:\\' "$DIR/steadyship.md" || fail "shared drive with backslash not substituted"
VER="$(sed -n 's/.*"version": *"\([^"]*\)".*/\1/p' "$ROOT/plugin/.claude-plugin/plugin.json")"
grep -q "^Template version: $VER\$" "$DIR/steadyship.md" || fail "template version $VER not written"
grep -q 'Setup owner:\*\* Sam Setup' "$DIR/docs/assessment/README.md" || fail "README role line"
[ "$(git -C "$DIR" rev-list --count HEAD)" = "1" ] || fail "expected exactly one commit"
[ "$(git -C "$DIR" branch --show-current)" = "main" ] || fail "branch is not main"
[ -z "$(git -C "$DIR" status --short)" ] || fail "tree not clean after init"
git -C "$DIR" ls-files --eol scripts | grep -q 'w/crlf' && fail "CRLF in scripts" || true

# second run into a non-empty dir must refuse
set +e; "$ROOT/plugin/scripts/init.sh" "$DIR" --business x --setup-owner x --sponsor x --github-owner x --repo-name x --shared-drive x >"$OUT/again.log" 2>&1; rc=$?; set -e
[ "$rc" = "1" ] && tail -1 "$OUT/again.log" | grep -q '^RESULT: FAIL' || fail "re-init into non-empty dir should FAIL"

# the generated repo's own spike scripts work on this machine
( cd "$DIR" && scripts/spikes/nas-rw.sh "$OUT" | tail -1 | grep -q '^RESULT: PASS' ) || fail "nas-rw in generated repo"
git init -q --bare "$OUT/bare.git"
( cd "$DIR" && git remote add origin "$OUT/bare.git" && scripts/spikes/git-push.sh | tail -1 | grep -q '^RESULT: PASS' ) || fail "git-push in generated repo"

if [ "${STEADYSHIP_TEST_SMOKE:-0}" = "1" ]; then
  ( cd "$DIR" && npm ci --no-audit --no-fund >/dev/null && scripts/validate.sh | tail -1 | grep -q '^OK$' ) || fail "generated validate.sh"
fi
echo "test-init: OK"
```
`chmod +x tests/test-init.sh`.

- [ ] **Step 2: Run it — expect failure (script missing)**

Run: `tests/test-init.sh; echo "exit=$?"`
Expected: an error that `plugin/scripts/init.sh` is not found, non-zero exit.

- [ ] **Step 3: Write `plugin/scripts/init.sh`**

```bash
#!/usr/bin/env bash
# Steadyship scaffolder: creates a self-contained customer repository from plugin/templates.
# Usage: init.sh <target-dir> --business NAME --setup-owner NAME --sponsor NAME \
#        --github-owner OWNER --repo-name NAME --shared-drive PATH [--no-git]
# Last line: "RESULT: PASS created <dir>" or "RESULT: FAIL <reason>". Never touches GitHub.
set -uo pipefail
HERE="$(cd "$(dirname "$0")" && pwd)"
TEMPLATES="$HERE/../templates"
MANIFEST="$HERE/../.claude-plugin/plugin.json"
fail() { echo "RESULT: FAIL $*"; exit 1; }

TARGET="${1:-}"; shift || true
[ -n "$TARGET" ] || fail "no target directory given"
BUSINESS=""; SETUP_OWNER=""; SPONSOR=""; GITHUB_OWNER=""; REPO_NAME=""; SHARED_DRIVE=""; DO_GIT=1
while [ $# -gt 0 ]; do
  case "$1" in
    --business) BUSINESS="${2:-}"; shift 2;;
    --setup-owner) SETUP_OWNER="${2:-}"; shift 2;;
    --sponsor) SPONSOR="${2:-}"; shift 2;;
    --github-owner) GITHUB_OWNER="${2:-}"; shift 2;;
    --repo-name) REPO_NAME="${2:-}"; shift 2;;
    --shared-drive) SHARED_DRIVE="${2:-}"; shift 2;;
    --no-git) DO_GIT=0; shift;;
    *) fail "unknown option: $1";;
  esac
done
for v in BUSINESS SETUP_OWNER SPONSOR GITHUB_OWNER REPO_NAME SHARED_DRIVE; do
  [ -n "${!v}" ] || fail "missing --$(echo "$v" | tr '_' '-' | tr '[:upper:]' '[:lower:]')"
done
[ -d "$TEMPLATES" ] || fail "templates not found at $TEMPLATES"
VERSION="$(sed -n 's/.*"version": *"\([^"]*\)".*/\1/p' "$MANIFEST")"
[ -n "$VERSION" ] || fail "could not read plugin version from $MANIFEST"

if [ -e "$TARGET" ] && [ -n "$(ls -A "$TARGET" 2>/dev/null)" ]; then
  fail "target directory exists and is not empty: $TARGET"
fi
mkdir -p "$TARGET" || fail "could not create $TARGET"
TARGET="$(cd "$TARGET" && pwd)"

echo "Copying templates (version $VERSION) into $TARGET ..."
( cd "$TEMPLATES" && tar cf - . ) | ( cd "$TARGET" && tar xf - ) || fail "copy failed"

# Substitute placeholders. Values are escaped for sed's replacement side (\, &, |).
esc() { printf '%s' "$1" | sed -e 's/[\\&|]/\\&/g'; }
SUBS=(
  "{{BUSINESS_NAME}}|$(esc "$BUSINESS")"
  "{{SETUP_OWNER}}|$(esc "$SETUP_OWNER")"
  "{{SPONSOR}}|$(esc "$SPONSOR")"
  "{{GITHUB_OWNER}}|$(esc "$GITHUB_OWNER")"
  "{{REPO_NAME}}|$(esc "$REPO_NAME")"
  "{{SHARED_DRIVE}}|$(esc "$SHARED_DRIVE")"
  "{{TEMPLATE_VERSION}}|$(esc "$VERSION")"
)
echo "Filling in business details ..."
while IFS= read -r -d '' f; do
  for s in "${SUBS[@]}"; do
    sed -i "s|${s%%|*}|${s#*|}|g" "$f" || fail "substitution failed in $f"
  done
done < <(find "$TARGET" -type f ! -path "$TARGET/.git/*" -print0)

if grep -rn '{{' "$TARGET" --exclude-dir=.git >/dev/null 2>&1; then
  grep -rn '{{' "$TARGET" --exclude-dir=.git | head -5
  fail "unfilled placeholders remain (listed above)"
fi
find "$TARGET" -name '*.sh' -exec chmod +x {} +

if [ "$DO_GIT" = "1" ]; then
  echo "Creating the first commit ..."
  ( cd "$TARGET" \
    && git init -q -b main \
    && git add -A \
    && git -c user.name="Steadyship" -c user.email="steadyship@example.invalid" \
         commit -q -m "chore: initialise Steadyship repository (template v$VERSION)" ) \
    || fail "git initialisation failed"
fi
echo "Done. Next: open docs/spikes/README.md in $TARGET."
echo "RESULT: PASS created $TARGET"
```
`chmod +x plugin/scripts/init.sh`.

- [ ] **Step 4: Run the test — expect pass**

Run: `tests/test-init.sh; echo "exit=$?"`
Expected: `RESULT: PASS created …` from init, then `test-init: OK`, `exit=0`.
Then once with the smoke check: `STEADYSHIP_TEST_SMOKE=1 tests/test-init.sh | tail -3` — Expected `test-init: OK` (takes ~1 min; needs Chromium installed on this machine, which it is).

- [ ] **Step 5: Edge checks by hand**

Run: `plugin/scripts/init.sh /tmp/x-$$ --business "A & B's \"Boats\"" --setup-owner "O'Neil" --sponsor S --github-owner g --repo-name r --shared-drive '\\nas\share' --no-git | tail -1; grep -c "A & B's" /tmp/x-$$/steadyship.md; grep -c '\\\\nas\\share' /tmp/x-$$/steadyship.md; rm -rf /tmp/x-$$`
Expected: `RESULT: PASS …`, then `1`, then `1` (ampersand, quotes, apostrophe and UNC backslashes all survive).

- [ ] **Step 6: Commit**

```bash
git add tests/test-init.sh plugin/scripts/init.sh
git commit -m "feat(init): add scaffolder that generates a customer repo from templates, with test

Co-Authored-By: <model> <noreply@anthropic.com>"
```

---

### Task 3: `steadyship-init` skill; marker-based repo detection in the other two skills

**Files:**
- Create: `plugin/skills/steadyship-init/SKILL.md`
- Modify: `plugin/skills/steadyship-status/SKILL.md` (step 1), `plugin/skills/steadyship-spike/SKILL.md` (add a step 0)

**Interfaces:**
- Consumes: `plugin/scripts/init.sh` contract (Task 2); `${CLAUDE_PLUGIN_ROOT}` — the environment variable Claude Code sets to the installed plugin's directory.
- Produces: a Steadyship repo is recognised by the presence of `steadyship.md` whose first line is `# Steadyship repository` (no longer by `docs/proposal-v0.1.md`).

- [ ] **Step 1: Write `plugin/skills/steadyship-init/SKILL.md`**

```markdown
---
name: steadyship-init
description: Use when asked to "set up Steadyship", "create a Steadyship repository", "initialise this folder for Steadyship", or when a business wants to start using Steadyship. Gathers six facts, generates a self-contained repository from the plugin's templates, and offers (never performs silently) to create the GitHub repository.
---

# Steadyship setup

You are setting up a business's own Steadyship repository. The person
you are talking to is the **setup owner**: they hold the accounts. They
may be non-technical. Do the work; explain plainly.

## 1. Gather the facts (ask only for what is missing)

- Business name (e.g. "Smith Joinery")
- Setup owner's name (usually the person you are talking to)
- Sponsor's name (the owner or manager who decides what the business relies on)
- GitHub owner (their organisation or account name on GitHub — ask them
  to look at github.com; if they have none yet, say so and use "TBC")
- Repository name (suggest `<business-slug>-apps`, lower-case, hyphens)
- Shared drive path where spreadsheets live (e.g. `Z:\` on Windows,
  `/Volumes/Shared` on a Mac, or "none")
- Target folder on this computer (suggest a folder next to their other
  work, e.g. `C:\Users\<name>\<repo-name>` or `~/<repo-name>`). It must
  not exist yet, or must be empty.

Confirm the seven values back in one short list before continuing.

## 2. Generate the repository

Run:

    bash "${CLAUDE_PLUGIN_ROOT}/scripts/init.sh" "<target folder>" \
      --business "<business>" --setup-owner "<setup owner>" --sponsor "<sponsor>" \
      --github-owner "<github owner>" --repo-name "<repo name>" --shared-drive "<shared drive>"

The last line is `RESULT: PASS created <dir>` or `RESULT: FAIL <reason>`.
On FAIL, say what went wrong in plain words and stop. Common causes: the
folder already has files in it; a value was left blank.

## 3. Report

Say: "Your Steadyship repository is ready at <dir>. It is self-contained —
it works even without this plugin." Then list the three things in it that
matter now: `docs/spikes/README.md` (the go/no-go checks), `docs/assessment/README.md`
(how to assess each app), `steadyship.md` (the facts you gave me).

## 4. GitHub (offer; never do it silently)

Check whether the GitHub CLI is available and logged in:
`gh auth status >/dev/null 2>&1 && echo yes || echo no`.

- If **yes**: ask "Shall I create the private GitHub repository
  `<github owner>/<repo name>` now and upload this folder to it?" Only
  if they say yes, run:
  `cd "<dir>" && gh repo create "<github owner>/<repo name>" --private --source=. --remote=origin --push`
  and report the result. If it fails, show the last two lines of the error
  in plain words (e.g. "GitHub says that name is already taken").
- If **no**: say the repository is local only for now, and give the setup
  owner these two lines to run later from a terminal where `gh` is logged
  in, or to hand to whoever manages their GitHub:

      cd "<dir>"
      gh repo create "<github owner>/<repo name>" --private --source=. --remote=origin --push

Then: "Next step: open `docs/spikes/README.md` and run spike e."

## Rules

- Never create or push to GitHub without an explicit yes in this
  conversation.
- Never put tokens, passwords or keys in any file or in your replies.
- Do not edit the generated files by hand; if something is wrong, say so
  and stop. The templates are fixed in the plugin.
```

- [ ] **Step 2: Marker detection in `steadyship-status`**

In `plugin/skills/steadyship-status/SKILL.md` step 1, replace
```
1. Confirm you are inside a Steadyship repository: `docs/proposal-v0.1.md`
   and `.claude-plugin/marketplace.json` both exist. If not, say
   "This folder isn't a Steadyship repository" and stop.
```
with
```
1. Confirm you are inside a Steadyship repository: a file `steadyship.md`
   exists here and its first line is `# Steadyship repository`. If not,
   say "This folder isn't a Steadyship repository — ask me to set one up
   (steadyship-init)" and stop.
```
Keep the rest of step 1 (reading `**Setup owner:**` from `docs/assessment/README.md`) unchanged.

- [ ] **Step 3: Marker detection in `steadyship-spike`**

In `plugin/skills/steadyship-spike/SKILL.md`, insert before the existing step 1 under `## Steps`:
```
0. Confirm you are inside a Steadyship repository: a file `steadyship.md`
   exists here and its first line is `# Steadyship repository`. If not,
   say "This folder isn't a Steadyship repository" and stop.
```
(renumbering the following steps is optional; if you renumber, update the cross-reference "see step 3" style text accordingly).

- [ ] **Step 4: Validate and prove the skills work against a generated repo**

```bash
cd ~/steadyship && claude plugin validate plugin --strict && echo SKILLS_OK
claude plugin marketplace update steadyship >/dev/null 2>&1 || true
claude plugin update steadyship >/dev/null 2>&1 || (claude plugin uninstall steadyship@steadyship && claude plugin install steadyship@steadyship)
rm -rf /tmp/sd-demo && plugin/scripts/init.sh /tmp/sd-demo --business "Demo Boatworks" --setup-owner "Sam Setup" --sponsor "Olive Owner" --github-owner demo-org --repo-name demo-apps --shared-drive 'Z:\' | tail -1
cd /tmp/sd-demo && claude -p "Run steadyship status" --model haiku 2>&1 | tee /tmp/status-demo.txt
cd ~/steadyship && claude -p "Run steadyship status" --model haiku 2>&1 | tee /tmp/status-product.txt
```
Expected: `SKILLS_OK`; in `/tmp/sd-demo` the reply starts `**Steadyship is installed and working.**`, reports 1 app assessed, 5 spikes not yet run, next step spike e, setup owner "Sam Setup"; in `~/steadyship` (the product repo, which has no `steadyship.md`) the reply says it isn't a Steadyship repository and mentions steadyship-init. Paste both replies in the report. Then run `cd /tmp/sd-demo && claude -p "run spike b, the directory is /tmp" --model haiku` and confirm it runs `scripts/spikes/nas-rw.sh` and reports PASS.

- [ ] **Step 5: Commit**

```bash
git add plugin/skills
git commit -m "feat(plugin): add steadyship-init skill; detect repos by steadyship.md marker

Co-Authored-By: <model> <noreply@anthropic.com>"
```

---

### Task 4: Product `validate.sh`, product CI, product README

**Files:**
- Modify: `scripts/validate.sh` (root), `README.md` (root)
- Create: `.github/workflows/validate.yml` (root, product)

**Interfaces:**
- Produces: `scripts/validate.sh` runs: plugin + marketplace `--strict` validation, the no-customer-facts grep gate, placeholder whitelist check, `tests/test-init.sh` (with `STEADYSHIP_TEST_SMOKE=1` when `STEADYSHIP_FULL=1`).

- [ ] **Step 1: Product `scripts/validate.sh`**

```bash
#!/usr/bin/env bash
# Product checks for the Steadyship plugin repository. Exit non-zero on first failure.
# STEADYSHIP_FULL=1 also runs the generated repo's smoke test (needs Node + Chromium).
set -euo pipefail
cd "$(dirname "$0")/.."
echo "== validate.sh (product) =="
if command -v claude >/dev/null 2>&1; then
  echo "-- plugin manifests"
  claude plugin validate plugin --strict
  claude plugin validate . --strict
else
  echo "-- plugin manifests: skipped (claude CLI not installed)"
fi
echo "-- no customer facts in plugin/"
if grep -rnI "Chris\|cookc\|boat" plugin/ | grep -v 'plugin/.claude-plugin/plugin.json'; then
  echo "customer-specific text found in plugin/ (above)"; exit 1
fi
echo "-- placeholders are the allowed seven"
ALLOWED='{{BUSINESS_NAME}} {{GITHUB_OWNER}} {{REPO_NAME}} {{SETUP_OWNER}} {{SHARED_DRIVE}} {{SPONSOR}} {{TEMPLATE_VERSION}}'
for p in $(grep -rhoE '\{\{[A-Za-z_]+\}\}' plugin/templates | sort -u); do
  case " $ALLOWED " in *" $p "*) ;; *) echo "unexpected placeholder $p"; exit 1;; esac
done
echo "-- generate a customer repo and test it"
if [ "${STEADYSHIP_FULL:-0}" = "1" ]; then STEADYSHIP_TEST_SMOKE=1 tests/test-init.sh; else tests/test-init.sh; fi
echo "OK"
```

Run: `scripts/validate.sh | tail -2` → Expected `test-init: OK` then `OK`.
Run: `STEADYSHIP_FULL=1 scripts/validate.sh | tail -1` → Expected `OK`.

- [ ] **Step 2: Product CI**

`.github/workflows/validate.yml`:
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
      - name: Install Playwright browser (for the generated repo's smoke test)
        run: npx --yes playwright@1.64.1 install --with-deps chromium
      - name: Product checks (full)
        run: STEADYSHIP_FULL=1 scripts/validate.sh
```
(The `claude` CLI is not on the runner; `validate.sh` skips manifest validation there and runs it locally. Pin the Playwright version to the one in `plugin/templates/package-lock.json`; check with `grep -m1 '"node_modules/@playwright/test"' -A1 plugin/templates/package-lock.json` and use that version in the `npx --yes playwright@<version>` line.)

- [ ] **Step 3: Product README**

Replace `README.md` with:
```markdown
# Steadyship

An engineer in the conversation for non-technical people building business
software with AI. See `docs/proposal-v0.1.md`.

This is the **product** repository: the Claude plugin and the templates it
uses to set up a business's own repository. Business data never lives here.

## Layout

- `plugin/` — the Claude plugin: skills (`steadyship-init`, `steadyship-status`,
  `steadyship-spike`), the scaffolder `scripts/init.sh`, and `templates/`
  (everything a customer repository contains, with placeholders).
- `.claude-plugin/marketplace.json` — this repo is also the plugin marketplace.
- `tests/test-init.sh` — generates a customer repository and checks it works.
- `scripts/validate.sh` — every product check CI runs.
- `docs/` — proposal, plans, and `rehearsal.md` (what to test where).

## Install the plugin

    /plugin install steadyship --marketplace cookc/steadyship

Then, in a conversation: "set up Steadyship for <business>".

## Customer repositories

Each business gets its own repository, generated by `steadyship-init` from
`plugin/templates/`, owned by the business, and self-contained (it works with
the plugin uninstalled). The standing demo customer is `cookc/steadyship-demo`.
```

- [ ] **Step 4: Commit and push; confirm CI**

```bash
git add -A
git commit -m "ci: product validate script and workflow; product README

Co-Authored-By: <model> <noreply@anthropic.com>"
git push
gh run list --limit 1
```
Expected: push ok; after ~3 min `gh run list --limit 1` shows `completed success`. If CI fails, read `gh run view --log-failed` and fix in a follow-up commit within this task.

---

### Task 5: Rehearsal checklist (Linux / Mac / on-site Windows) and proposal note

**Files:**
- Create: `docs/rehearsal.md`
- Modify: `docs/proposal-v0.1.md` §6 (one bullet) and §11 week 1–2 (one line)

- [ ] **Step 1: Write `docs/rehearsal.md`**

```markdown
# Rehearsal — what can be tested where

The on-site spikes run on the partner's Windows machine. Most of them can
be rehearsed earlier. Tick what passes; anything that fails here will fail
there.

## On Linux, with Claude Code (no accounts needed)

- `scripts/validate.sh` and `STEADYSHIP_FULL=1 scripts/validate.sh` pass.
- `steadyship-init` generates a repo into an empty folder; `steadyship-status`
  in that folder reports 1 app and 5 spikes not run; in the product repo it
  says "not a Steadyship repository".
- In the generated repo: `run spike b` against a local folder → PASS;
  `run spike c` on `_sample` → PASS (first run installs Chromium);
  `scripts/spikes/git-push.sh` against a bare repo → PASS.

## On a Mac, with Claude desktop (closest to the partner's experience)

- Install Claude desktop; install the plugin from the marketplace; confirm
  `run steadyship status` works in a local session with the demo repo
  folder attached (spike e, minus the Team-admin "installed by default" step).
- Spike a end to end against `steadyship-demo` with a 30-day fine-grained
  token, including the second-session re-run.
- Spike b against an SMB share mounted under `/Volumes/…` (macOS treats it as
  local) — both file tools and the script.
- Spike c in the desktop VM: does the Chromium download succeed inside the
  VM's network allowlist? This is the single most useful Mac check.
- Spike d: deploy `_sample` from `steadyship-demo` to Azure SWA Free and open
  it from a second Microsoft account.

## Only on the partner's Windows machine

- Git for Windows line endings (`.gitattributes` mitigates; still verify
  `git ls-files --eol scripts` shows `w/lf` after their clone).
- Mapped SMB drive visible from the VM shell (known open bug).
- Virtual Machine Platform enabled; MSIX desktop install.
- Team-plan "Installed by default" plugin sync to a second member.
- Azure sign-in with the partner's tenant and invited users.
```

- [ ] **Step 2: Proposal notes**

In `docs/proposal-v0.1.md` §6 add a bullet at the end:
```
- The product repository (plugin, templates, init skill) and each
  business's repository are separate. `steadyship-init` generates the
  latter from the former; the business owns it; it works with the plugin
  uninstalled. A standing demo customer repository exercises the same path.
```
In §11 "Weeks 1–2" after the spike list add:
```
Before going on-site, rehearse per `docs/rehearsal.md` (Linux, then a Mac
with Claude desktop); only Windows-specific items remain for the visit.
```

- [ ] **Step 3: Commit**

```bash
git add docs/rehearsal.md docs/proposal-v0.1.md
git commit -m "docs: rehearsal checklist and product/customer split note

Co-Authored-By: <model> <noreply@anthropic.com>"
git push
```

---

### Task 6: Standing demo customer `cookc/steadyship-demo` (side effects: approved in conversation)

**Files:**
- Create (outside this repo): `~/steadyship-demo/` generated by `init.sh`; GitHub repo `cookc/steadyship-demo` (private)
- Modify: `README.md` (root) — no change needed if Task 4 text is used; confirm the demo repo name matches.

**Interfaces:**
- Consumes: `plugin/scripts/init.sh` (Task 2), the installed plugin (Task 3).

- [ ] **Step 1: Generate**

```bash
rm -rf ~/steadyship-demo
~/steadyship/plugin/scripts/init.sh ~/steadyship-demo \
  --business "Demo Boatworks" --setup-owner "Chris Cook" --sponsor "Demo Sponsor" \
  --github-owner cookc --repo-name steadyship-demo --shared-drive "/tmp/demo-share" | tail -1
mkdir -p /tmp/demo-share && echo "Jobs.xlsx stand-in" > /tmp/demo-share/README.txt
```
Expected: `RESULT: PASS created /home/ccook/steadyship-demo`.

- [ ] **Step 2: Create the GitHub repo and push (user-approved 19 Oct 2026)**

```bash
cd ~/steadyship-demo && gh repo create cookc/steadyship-demo --private --source=. --remote=origin --push
gh run list --repo cookc/steadyship-demo --limit 1
```
Expected: repo created, `main` pushed; after ~3 min the customer CI (`validate` — smoke on `_sample`) is `completed success`.

- [ ] **Step 3: Exercise the demo through the plugin, from Linux**

```bash
cd ~/steadyship-demo
claude -p "Run steadyship status" --model haiku 2>&1 | tail -8
claude -p "run spike b, the directory is /tmp/demo-share" --model haiku 2>&1 | tail -6
claude -p "run spike c, the app is _sample" --model haiku 2>&1 | tail -6
git status --short
```
Expected: status → 1 app, 5 not run, next step e, setup owner Chris Cook; spike b → PASS; spike c → PASS (first run installs tooling in the demo repo; `node_modules/` is gitignored); `git status` clean apart from nothing (if the skill pasted rows into RESULTS.md itself, that is a skill defect — report it; the skill is supposed to *tell the user* what to paste).

- [ ] **Step 4: Record spike results in the demo repo as a real customer would**

Edit `~/steadyship-demo/docs/spikes/RESULTS.md` rows b and c with today's date and the notes from Step 3 (leave e, a, d blank — they need the Mac/desktop rehearsal). Commit and push from `~/steadyship-demo`:
```bash
cd ~/steadyship-demo && git add docs/spikes/RESULTS.md && git commit -m "spikes: b and c pass on Linux (Claude Code)" && git push
claude -p "Run steadyship status" --model haiku 2>&1 | grep -i "spikes\|next step"
```
Expected: `Spikes: 2 passed, 0 failed, 3 not yet run`, next step `Run spike e`.

- [ ] **Step 5: Report** (no commit in the product repo unless README needed a change). Note the demo repo URL and CI status in the report.

---

## Self-review against the spec

- **§3 no business-specific state in the product:** Task 1 grep gate, Task 4 CI gate. ✔
- **§3 customer repo self-contained, works without the plugin:** customer `validate.sh` has no `claude` dependency (Task 1 Step 4); `steadyship.md` is the only product reference; `test-init.sh` runs the generated repo's scripts (Task 2). ✔
- **§4 roles:** placeholders `{{SETUP_OWNER}}`, `{{SPONSOR}}`; README role lines (Task 1 Step 3). ✔
- **Init offers GitHub, never silent:** Task 3 skill §4. ✔
- **Demo customer:** Task 6; product CI generates a fresh one every push (Task 4). ✔
- **Mac/Linux rehearsal:** Task 5. ✔
- **Marker detection:** Task 3 Steps 2–3 — necessary because customer repos no longer contain the proposal. ✔
- **Placeholder scan:** none. `<model>` in commit trailers is filled by the implementer. ✔
- **Consistency:** `init.sh` flags ↔ `test-init.sh` ↔ init skill command ↔ Task 6 invocation all use `--business --setup-owner --sponsor --github-owner --repo-name --shared-drive [--no-git]`; marker first line `# Steadyship repository` in Task 1 Step 6, Task 3 Steps 2–3, Task 2 test (`^Business:` lines). `package-lock.json` moves into templates in Task 1 so `npm ci` works in generated repos and CI. ✔
