# Assessment: _sample

Worked example against `apps/_sample/`. Real assessments replace this.

**Stage:** Prototype

**Relied on by:** only the builder

**Owner:** unknown

**Builder:** (example)

**Opened how:** double-click `index.html`

**Copied into repo at:** `apps/_sample/` on 2026-10-19 from this repository

## What it does (one paragraph, business language)

Shows a list of jobs with the customer and the stage each job is at.

## Data

| What | Where it lives | Who else can see it | Backed up? | Also exists in |
|---|---|---|---|---|
| Jobs | hardcoded in index.html | nobody | no (only in the file) | nowhere (single sample app) |

## Shared concepts

job (local name: "job", hardcoded in index.html); customer (local name: "customer", hardcoded in index.html). No glossary exists yet.

## Duplication spotted

- None yet (single sample app).

## Exposure

- Anyone with the file sees every job and customer name.
- No sign-in.
- No passwords or keys in the code.

## If it vanished tomorrow

Nothing — data is two example rows.

## Engineering profile

Judged as a Prototype.

### Free habits

| Habit | Today | Meets? |
|---|---|---|
| Semantic HTML (real buttons, labels, headings) | a real table with headings (`index.html:17`) | yes |
| Theme tokens, no hard-coded colours or sizes | `#999` and `2rem` typed in (`index.html:8-10`) | no |
| Data never enters the page as raw HTML; one escaping helper | rows built with `innerHTML` (`index.html:29`) | no |
| One form per kind of value (money, dates, moments, identifiers) | job numbers as text in the glossary's shape; no money or dates | yes |
| Checked at every edge (file read, form, paste, file written) | no edges: data is typed into the page | n/a |
| Errors in the page in plain words; what was typed is kept | nothing can fail; nothing is typed | n/a |
| No business data or secrets typed into code | two sample jobs in the page (`index.html:23-26`) | no |
| Stage banner at the top of the page | none | no |
| Only browser features in the baseline | yes | yes |
| Dependencies pinned, from the allow-list | none used | yes |
| Smoke test; one test per change | the repository's smoke test opens it | partly |
| Glossary names; split by concern past one file; comments say why | one file, 36 lines; no glossary yet | yes |
| README for the app | none | no |
| Version in the footer; changelog | none | no |
| Responsive at phone, tablet and desktop | one table; fits a phone | yes |
| Large touch targets, strong contrast | no buttons; black on white | yes |
| Print styles | none | no |

### Stage rows

| Question | Today | Meets at this stage? |
|---|---|---|
| Framework | none | yes |
| Libraries | none | yes |
| Build system | none | yes |
| Where the data lives | in the page (`index.html:23`) | yes, sample data |
| Hosting | a file on a laptop | yes |
| Sign-in | none | yes |
| Who changed what | not recorded | yes |
| Tests | the repository's smoke test | yes |
| Failures | nothing can fail | yes |
| Offline | works, it is a file | yes |
| Backups | none | yes |
| Retention | n/a | yes |
| Personal data | sample names only | yes |
| Performance (file budget, long lists) | two rows | yes |
| Consistency with other apps | no other apps | yes |
| Accessibility | semantic table | yes |
| Code structure | one file | yes |
| Formatting and lint | not run | yes |
| Types | none | yes |
| Updates and rollback | overwrite the file | yes |
| Who is told | nobody | yes |
| Cost | nothing | yes |
| Licences | n/a | yes |
| Retire it | delete the folder | yes |
| Second builder | n/a | yes |
| Browsers | whatever the builder uses | yes |

## Ladder

| Rung | Done | Evidence |
|---|---|---|
| 1 Name it | yes | this file |
| 2 Own it | no | no owner named |
| 3 Test it | partly | the repository's smoke test; no test of its own |
| 4 Move its data | no | data in the page |
| 5 Share it | no | |
| 6 Protect it | no | |

**Next rung:** 2 Own it — who is responsible for this app?

## Verdict ({{SETUP_OWNER}}, one paragraph in plain language)

A prototype. It works, but every job lives inside the page itself, so a
second person can't see the same list and a change to the file loses the
data. Smoke test: PASS.

## Candidate next step

Graduate to Owned tool: move the job list out of the page into one shared
file with a single owner.
