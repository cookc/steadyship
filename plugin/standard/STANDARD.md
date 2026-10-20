# The bar

The engineering standard Steadyship holds every app to. It is the list of
small questions a real engineer carries, written down so that:

- the builder never has to choose a framework, a library, a database or a
  host, and never sees these questions unless they ask "why";
- the agent never defaults to quick-and-dirty, and never reaches for a
  framework because it can;
- assess, review and ask all judge against one list, and a reviewer from
  any vendor can be handed the same list as its brief.

Every row says what is acceptable at each stage. "Prototype" means one
person's tool. "Owned tool" means other people rely on it. "Proper app"
means the business depends on it daily. "Platform" means several apps must
stay consistent for the business to run. An app moves up a stage only when
the evidence says it should, and the agent states the move with a reason
rather than drifting into it.

Businesses override rows in their own `docs/context/engineering.md` (for
example: "we are a Microsoft 365 shop, so sign-in means Entra and hosting
means SharePoint or Azure"). The override wins.

## 1. Free habits: from line one, at every stage

These cost nothing, so there is no over-engineering argument against them,
and they are where regret usually starts. The agent applies them without
asking and without announcing, except for one line when it adds something.

| Habit | Why |
|---|---|
| Semantic HTML: real buttons, labels, headings, lists | Gets keyboard use, screen readers and most of responsiveness for free |
| Theme tokens for colour, spacing and type; never a hard-coded value | Brand, dark mode and consistency across apps become a one-file change |
| Data never enters the page as raw HTML; one escaping helper, used everywhere | The most common hole in home-made apps; a CSV cell is enough to trigger it |
| Money as whole cents; dates as ISO text with the business's timezone stated; identifiers in the glossary's format | Floats for dollars and guessing dd/mm are regrets within a month |
| Validation at the boundary: every row read from a file is checked against a written shape; bad rows are reported, not dropped | Silent data loss is the failure nobody notices until it matters |
| Errors in plain words, in the page; never swallowed, never an alert box; what the person typed is kept | A person who loses ten minutes of typing stops trusting the app |
| No secrets, prices, staff lists or any business data typed into code | Code is copied; data belongs in the master file |
| Nothing loaded from a random CDN; dependencies pinned and from the allow-list below | An unpinned script is a change nobody reviewed |
| A smoke test under Playwright from the own-it rung; one test added for each change made | Confidence to make the next change; the thing a reviewer can verify |
| Names from the glossary; structure by concern once an app passes one file; comments say why, not what | The next builder can pick it up from the folder alone |
| A README per app: what it is for, who owns it, how to run it, where its data lives | Bus factor |
| A version in the page footer; a changelog | "Which version are you on?" is the first support question |
| Responsive at phone, tablet and desktop widths, checked by screenshot | The owner reads it on a phone; the workshop uses a tablet |
| Large touch targets and strong contrast | Gloves and glare in a workshop |
| Print styles | Job sheets get printed |

## 2. The stage table

| Question | Prototype | Owned tool | Proper app | Platform |
|---|---|---|---|---|
| **Framework?** | Vanilla HTML+JS is right | Still vanilla | One framework and UI kit, Steadyship's default, when components are copied across apps or changes are frequent | Same, shared across apps |
| **Libraries?** | None needed | A library over hand-rolled code when it is a solved problem (CSV parsing, dates, IDs), from the allow-list | Same, pinned with a lockfile | Same, shared versions |
| **Build system?** | None | None | Arrives with the framework | Monorepo with one build |
| **Where does data live?** | In the page, or browser storage, sample data only | One master file on the shared drive, one writer, via the serve script | A database, when two people write at once or rows pass the budget | One shared database with owned schemas and migrations |
| **Hosting?** | A file on a laptop | Shared drive, or the serve script on one machine | Hosted, with sign-in and backup; the business's platform if it has one | Same, released together |
| **Sign-in?** | None | None if it stays on the shared drive; required the day it is hosted | Required; roles if anyone must be kept out of something | Single sign-on across apps |
| **Who changed what?** | Don't care | A log line per write (who, when, what), once more than one person writes | Audit kept with the data | Same |
| **Tests?** | None required | Smoke test, plus one test per change | A test per behaviour that matters, run on every commit | Tests across apps |
| **Failures?** | Don't care | Says plainly when the drive is unreachable, the file is open in Excel, or a row is malformed; never loses what was typed; writes cannot half-complete | Errors reported somewhere a person sees them | Monitoring |
| **Offline?** | n/a | Keeps working for reading; queues or refuses writes, and says which | Designed in if the environment needs it (asked at own-it) | Same |
| **Backups?** | None | The master file is inside the business's existing backup; confirmed, and restored once | Automated, restore tested | Same, with retention |
| **Retention?** | n/a | Asked at own-it; tax and health-and-safety records have legal minimums | Enforced | Same |
| **Personal data?** | Sample data only | Asked at own-it; if yes, named in the assessment and local privacy law applies (for example New Zealand's Privacy Act) | Access limited by role | Same |
| **Performance?** | n/a | A stated row budget (default 5,000); never loads the whole shared drive | Pagination; measured startup on the slowest machine in use | Same |
| **Consistency with other apps?** | n/a | Brand file for logo and colours; glossary terms; same navigation pattern | Shared components | Shared design system |
| **Accessibility?** | n/a | The free habits (semantic HTML, contrast, targets, keyboard) | Checked by an automated scan on every change | Full standard if the business supplies to government |
| **Code structure?** | One file is fine | Split by concern past roughly 300 lines; no copy-paste between apps | Shared module only when duplication is shown across two apps | Shared packages |
| **Formatting and lint?** | Don't care | Enforced by the repo's validate script | Same, on every commit | Same |
| **Types?** | No | JSDoc on the data shapes | Type checking with the framework | Same |
| **Updates and rollback?** | Overwrite the file | The previous version is one commit back; the person is told what changed | Release notes; rollback is a redeploy | Release process across apps |
| **Who is told?** | Nobody | The owner, in the build report | The owner and the users, in the changelog | Same |
| **Cost?** | Nothing | Nothing beyond AI usage | Hosting bill, stated before hosting | Stated and reviewed |
| **Licences?** | n/a | Allow-list libraries only (permissive licences) | Same | Same |
| **Retire it?** | Delete the file | The assessment flags apps nobody has used in 90 days; the owner decides | Same | Same |
| **Second builder?** | n/a | Can continue from the folder alone (README, tests, glossary) | Same, plus the build runs on a fresh machine | Same |

### Triggers to move up a stage

- Prototype to Owned tool: someone other than the builder uses it, or real
  data appears.
- Owned tool to Proper app: two apps touch the same information, a second
  builder edits it, logic is copied, or the business depends on it daily.
- Proper app to Platform: the apps must stay consistent with each other
  for the business to run.

The agent states the move: "This has reached the point where it should
become a proper app. Here is why. I can do it now, or you can defer and I
will do it later." Options are not exposed; the decision is recorded either
way.

## 3. Defaults: what Steadyship picks so nobody has to

Opinions, versioned here, overridable per business.

| Choice | Default | Reason |
|---|---|---|
| Prototype and Owned tool stack | Vanilla HTML, CSS and JavaScript, one folder per app | What the builders already make; no build; opens from a folder |
| CSV handling | Papa Parse, pinned | Quoting, commas and encodings are a solved problem |
| Dates | Native `Intl` and ISO strings; a date library only when arithmetic across time zones appears | Most date bugs come from parsing, not arithmetic |
| Identifiers | The glossary's format; generated with `crypto.randomUUID()` only when the glossary has none | Business identifiers belong to the business |
| Serve script | Node, single file, no dependencies, serves one app and its master file | Nothing to install beyond Node, which the tests check already installs |
| Test runner | Playwright, Chromium | Already installed by the tests check; one runner for smoke and behaviour |
| Formatting and lint | Prettier and ESLint with the recommended rules, run by the validate script | Taste is not a review topic |
| Proper-app framework | Decided per business when the first app reaches the stage, recorded in `docs/context/engineering.md`; the choice is made once for all apps | A framework is a ten-year decision; one per business |
| Hosting | The business's existing platform where it has one (Microsoft 365: Azure Static Web Apps with Entra sign-in); otherwise decided at the stage | Sign-in people already have beats a new password |
| Database | Decided at the stage; never before two writers exist | The master file is enough for longer than people expect |

### Library allow-list

Boring, maintained, permissively licensed. Anything else needs a line in
`docs/context/engineering.md` saying why.

Papa Parse (CSV); Day.js (dates, only when needed); Zod (data shapes, from
Proper app); the framework and UI kit chosen at Proper app; Playwright
(tests); Prettier and ESLint (checks). No UI library at Prototype or Owned
tool: the free habits and the theme tokens cover it.

## 4. The regret list

Concrete things the agent does not do, with the reason. Lists of "don't"
are followed better than principles.

- `innerHTML` with anything that came from data. Use the escaping helper or
  `textContent`.
- Floats for money. Whole cents.
- `new Date("12/03/2026")`. ISO strings in, formatted on the way out.
- Browser storage as the database once a second person uses the app.
- Prices, staff names, stages or any business list typed into code. Read
  the master file.
- Copying a function from another app. Note the duplication in the
  assessment; share it only when the bar says so.
- A script tag pointing at an unpinned CDN URL.
- `try { } catch { }` that swallows. Every error reaches the page in plain
  words.
- `alert()` and `confirm()` for errors or questions.
- Global state soup: one object per app holds the state, and one function
  renders it.
- Reading the whole shared drive to find one file.
- Tests that need the shared drive, tests that `sleep`, tests that check
  the code instead of the behaviour.
- Writing a file in place. Write beside it, then rename.
- A new framework, build step, package or database "while we're at it".
  Only at the stage, only stated, only with the option to defer.
- Asking the builder a question the bar already answers.

## 5. What we lean on

Steadyship is the judgement layer: the questions, this bar, the business
context, the stage decision, the ledger and the plain-English verdict. The
engineering process underneath comes from plugins other people maintain.
We do not write a line of it. Every call is optional and reports "not run"
when the plugin is absent, as the second opinion does today.

| Need | Plugin (official marketplace unless noted) | Used by |
|---|---|---|
| Explore, design and review a change bigger than a few lines | feature-dev (explorer, architect, reviewer agents) | ask |
| Test-first builds, systematic debugging, subagent-driven work with review | superpowers | ask, next |
| Multi-agent review with confidence scoring; reviewers for tests, errors, types | code-review, pr-review-toolkit | review |
| Warnings on risky edits; security review of the diff | security-guidance | ask |
| Production-grade interface work, pointed at the business's brand file | frontend-design | ask, the template |
| The browser for smoke and behaviour tests | playwright | next, review, check |
| Tidy-up after a change so the next builder can read it | code-simplifier | ask |
| Database, hosting, monitoring | installed when an app reaches the stage that needs them | next |

The baseline set is recommended at setup. The brief handed to any of them
is this file plus the business notes, in Markdown, so a reviewer from
another provider (Codex cloud review, Copilot on a pull request) reads the
same brief and is held to the same bar. Versions tested against are listed
in the plugin's changelog.

## 6. How the skills use this file

- **Assess** answers every row for every app by reading, never by asking,
  and writes the answers into `docs/assessment/<app>.md` as the engineering
  profile, with the ledger of rungs done. The reply shows only the rows
  failing at the app's current stage.
- **Review** judges against the stage the business wants to rely on, runs
  the tests first and cites the result, and hands this file to the
  independent reviewer as its brief. "Not yet" names the failing rows.
- **Ask** checks the rows a change touches, applies the stage default in
  one line, asks the builder only for business knowledge (the own-it
  questions), adds one test, and proposes the next rung once.
- **Next** picks the rung from the ledger, does it, records it; states a
  stage move when a trigger is met.
- **Check** runs the machine checks the bar demands and reports PASS, FAIL
  or SKIP per check.

Every judgement call that reaches a human engineer during the field test
becomes a row here, or has a written reason it cannot.
