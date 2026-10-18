# Steadyship — an engineer in the conversation

**V0.1 concept proposal · 19 October 2026 · supersedes the Google Doc V0 draft**

> Non-technical people are building real business value with AI. What they
> build is a prototype, and they cannot tell. Steadyship puts the engineering
> judgement they lack into the conversation: it asks what they don't know to
> ask, judges what they can't judge, tells them the risks in plain words, and
> gives them a path from prototype to software a business can run on — one
> they still own if Steadyship disappears.

## 1. The problem

At the design partner (a small NZ boat manufacturer), very non-technical
staff have built 5–10 apps by talking to Claude. Vanilla HTML+JS, no server,
opened from a synced SharePoint folder, data hardcoded or in the browser's
localStorage or in spreadsheets on SharePoint/NAS. The apps overlap in
concepts (job, customer, product) and almost certainly in copied code.

The apps work and are genuinely valuable. They are also, at best,
prototypes. The specific problems:

1. **No path from prototype to production.** Claude solves the problem in
   front of it. That is right for a prototype and wrong the day the business
   starts depending on the result. Nobody flags that day, and nobody knows
   what "past prototype" involves.
2. **Poor engineering, invisible to the builder.** No structure, no tests,
   data tangled with code. Hard to change one thing without risking the
   rest; hard to evolve, which the long-term vision requires.
3. **No security practice.** Business data in localStorage and shared
   spreadsheets, no sign-in, no idea who can see or change what.
4. **No ownership over time.** No plan to upgrade, modify, back up or hand
   over; no named owner for any app.
5. **No way to share code.** The same thing gets solved several ways. A
   consistency problem now; a **data problem over time** — the same business
   facts recorded differently in different places, which puts the
   just-in-time-workshop vision (one coherent picture of jobs, capacity,
   inventory) nearly out of reach.
6. **They don't know the burden they're creating.** Every success makes the
   eventual bill bigger, and nobody can see it.

Underneath all six, the root cause:

7. **They don't know what to ask.** Claude can supply engineering judgement,
   but only when asked. They don't know they're missing a prompt, let alone
   what it should say. And when the work is done they have no opinion on
   whether it's good, no knowledge to form one, and no sense of the risks.

## 2. Why "just use Claude" doesn't fix it

The judgement exists in the model. It is not applied because nothing in the
loop asks for it: not the builder (doesn't know to), not the tool (optimises
for the request), not a reviewer (there isn't one). Anthropic's own
engineering plugins (ADRs, deploy checklists, security guidance) assume a
developer who knows when to invoke them. Lovable, Replit and Base44 bolt
scanning and git onto their own platforms; none sell judgement that
travels with the builder, works across several apps built by several
people, or speaks to someone with no technical vocabulary.

## 3. The product

**An opinionated engineer in the conversation** — a built-in consultant —
delivered as a plugin for Claude desktop/Claude Code and a plain-Markdown
repository the business owns. Like a good consultant, it has no stake in
the answer: if the right call is "don't build this, use Power Apps / a
SharePoint list / Xero / an off-the-shelf tool", it says so. Recommending
another platform is not a failure of the product; it is the product
working. It has three jobs, in priority order.

### Job 1 — Ask what they don't know to ask (before the build)

Before significant work, consult the business's shared context and put the
one or two questions that matter: *Should this be built at all, or does
something you already pay for do it? Is this a prototype or will people
rely on it? Where should this data live so someone else can see it? Is
"job" here the same as "job" in the quoting app? Who can see this?* Then set
the constraints Claude should build to, record the decision, and get out of
the way. Never a questionnaire; one or two questions, in business language.

### Job 2 — Judge what they can't judge (after the build)

When something is built or changed, review it on the builder's behalf and
say, in plain words: what this is (prototype / internal tool /
business-critical), what would break, what data is at risk, what would be
needed to rely on it, and what to do next. Give them an opinion they can
act on and a vocabulary for the risks. This is the piece nobody sells.

**The skills create the reviewer; no standing human engineer is assumed.**
A model reviewing its own output shares its blind spots, so the reviewer
is independent by construction, in three layers, strongest first:

1. **A different vendor's model** (e.g. a Codex/ChatGPT reviewer) —
   decorrelated blind spots, which a same-vendor second opinion cannot
   give. Needs a second subscription and a vendor-neutral review brief.
   Recommended as the most robust setup for a serious business; never
   required.
2. **A separate, sandboxed session** — a different model where possible,
   read-only on the repository, with no access to the builder's
   conversation; it receives a written brief and the diff, and returns a
   written verdict. Always available.
3. **Non-model verification** — tests and CI. Always on.

The pull request is the convergence point: a brief and a diff in a PR can
be consumed by any vendor's reviewer (Codex cloud review, Copilot review,
a Claude reviewer) without the builder touching a terminal, and it is
sandboxed by construction. "Sandboxed reviewer" and "any vendor" are one
mechanism, not two features.

Verdicts cite evidence (smoke test passed, data file has one writer,
sign-in enforced); anything the reviewer cannot verify is labelled
unverified, never approved. The **sponsor** makes the "we rely on this"
decision from that verdict. When the reviewer genuinely cannot verify
something — a platform bug, a security question beyond its evidence — it
says so and names what a human engineer should be asked. Escalation is a
skill output, not a role, and the number of escalations is tracked and
expected to fall.

### Job 3 — Give them a path, and make the roads converge

- **Assessment:** inventory every app, what it does, who relies on it,
  where its data is, what it duplicates, how exposed it is. Produce a
  one-page picture the sponsor can read.
- **Graduation path:** a repeatable, incremental route from prototype to
  owned software: data out of the app into an owned, shared, backed-up
  place with one writer; a home that isn't a laptop; sign-in; a smoke test;
  a named owner; decisions recorded. Done with an engineer reviewing, not
  as a rebuild. No automated production release.
- **Convergence:** shared glossary with a human owner, shared data
  contracts matching the real spreadsheets, a shared module only when
  duplication proves it, a template for new apps so coherence is the
  starting point. Jobs 1 and 2 check new work against these.

Everything lives in ordinary Markdown, Git, scripts and tests. **Builders
must never be worse off for having used Steadyship.** No proprietary
format, no hosted dependency, no state outside the repository. Tested, not
asserted (see §11, week 6).

### What Steadyship is not

Not a host, database, runtime, dashboard, model router or security
certification. Adding any of these is a scope change needing a decision.
Not vendor-aligned either: it recommends Claude, another AI tool, a SaaS
product or a no-code platform on the merits, and the business keeps every
artefact if it follows that advice away from Steadyship.

## 4. Who it is for

- **Builders:** capable staff comfortable in conversational AI and files;
  have tried a terminal and found it too much. One guided setup session is
  acceptable; daily terminal use is not.
- **Business sponsor:** owner/manager; owns the glossary, priorities and
  the "can we rely on this" decision.
- **Setup owner:** whoever holds the accounts (GitHub, Azure, the Claude
  Team org). One-time plumbing — repo, tokens, hosting, plugin install —
  done by hand or by following a setup skill. Hands, not judgement.
- **No standing engineer reviewer.** Judgement comes from the skills and
  the independent reviewer they dispatch (§3, Job 2). In V0 only, Chris
  (5–10 hours/week) is the setup owner, the calibration ground truth for
  the *assess* skill, and the escalation path when a verdict says "needs a
  human engineer" — all three labelled temporary, with §12 criterion 9
  measuring how much judgement still reaches him.

## 5. Experience: Explore → Develop → Promote

- **Explore:** prototype as today. Job 1 may ask once; it never blocks.
  Prototypes use sample data unless authorised.
- **Develop:** when a prototype is kept or a second builder wants in, it
  joins the shared repository with a catalogue entry; shared concepts map to
  the glossary; Job 2 gives its first verdict. Git is hidden; the plugin
  commits from an approved state.
- **Promote:** when other staff will rely on it, the graduation path runs,
  step by step, with the reviewer signing off. The app's label changes only
  when the evidence does.

## 6. Platform facts the plan depends on (verified 19 Oct 2026)

- Claude desktop runs the Claude Code CLI in a local VM (bash, Node,
  Python, Git). **Team plan keeps local sessions** (org toggle); Pro/Max
  went cloud-only on 6 Oct. Windows needs Virtual Machine Platform and the
  MSIX install.
- Plugins (skills, commands, agents, hooks, MCP) load in desktop with the
  same format as Claude Code. Team owners can set a private GitHub
  marketplace plugin to "Installed by default" or "Required".
- Cloud sessions can't reach the company network (no NAS) and can't push to
  private GitHub repos. Local sessions pushing with user credentials:
  **unverified → spike.** Windows mapped SMB drives: file tools yes, shell
  no (open bug) → **spike.**
- No native CLAUDE.md/AGENTS.md read; skills must load repo context
  explicitly. Project memory exists but isn't authoritative.
- SharePoint Online won't serve HTML+JS (strict handling; custom script
  blocked and auto-reverts). Candidate hosts: Azure Static Web Apps Free
  with Entra sign-in, or a Teams tab pointing at it → **spike.**
- Anthropic routes "run tests, open a PR" to the Code tab and is merging
  Cowork into plain Claude. Expect UI churn; keep enforcement in scripts
  and CI.
- The product repository (plugin, templates, init skill) and each
  business's repository are separate. `steadyship-init` generates the
  latter from the former; the business owns it; it works with the plugin
  uninstalled. A standing demo customer repository exercises the same path.

## 7. Architecture: staged, and the coach decides when

The destination is what an engineer would have built: a proper framework
(e.g. Next.js with React, Mantine or similar UI kit — examples, not
decisions), a monorepo with a build system, shared packages, tests and CI,
a real database with owned schemas. The builders should never have to
choose any of that. The coach judges when each step is justified, then
states it rather than asking:

> "You've reached the point where this should become a proper app. We're
> going to move it onto X now. Here's why it will be better long-term.
> You can defer this and I'll do it tonight if you prefer."

Options are not exposed; the user gets a decision, a reason, and a chance to
defer. The decision is recorded. Approximate stages and the triggers the
coach watches for:

| Stage | What it looks like | Typical trigger to move on |
|---|---|---|
| Prototype | Single HTML+JS file, sample or local data | Someone other than the builder uses it; real data appears |
| Owned tool | In the repo, data in an owned shared file with one writer, smoke test, named owner, hosted with sign-in | Two apps touch the same concept; a second builder edits it; logic is copied |
| Proper app | Framework + UI kit, components, typed data contracts, build and CI | Several apps share data or UI; the business depends on it daily; changes are frequent |
| Platform | Monorepo, shared packages, shared database with owned schemas, migrations, release process | Apps must stay consistent with each other; the JIT-workshop vision needs one data model |

Standing rules at every stage: snapshot the working baseline and write a
behavioural test before restructuring; introduce a shared module, package
or database only when duplication or data divergence is shown, not
pre-emptively; keep every step incremental and reversible. In V0 the first
expected move is one app from Prototype to Owned tool; whether any app
should move to Proper app in V0 is the coach's call based on the
assessment, and a good test of whether it makes that call well.

## 8. Model allocation

Native picker; `model:` on plugin agents where honoured; "use the strongest
model" for Job 2 verdicts, glossary/data-ownership decisions and promotion.
Record decisions so cheaper runs don't rediscover them. Measure usage per
verified change. No router.

## 9. Data handling

Whether business data may be processed in Anthropic cloud sessions is the
customer's decision, not Steadyship's. Steadyship supports either answer:
local sessions (keeps NAS access, needs the desktop app) or cloud (needs the
shared data reachable some other way). The coach asks once, records the
answer, and adapts. Standing rules regardless: secrets, native CAD and large
datasets never enter Git; prototypes use sample data unless authorised.

## 10. V0 scope

**In:** the repository; three skills — *assess* (Job 3 inventory + Job 2
verdict per app), *ask-before-building* (Job 1), *review-after-building*
(Job 2, designed from the start as a skill that dispatches an independent
sandboxed reviewer and renders an evidence-cited verdict; cross-vendor
review via PR is a documented option, not a V0 dependency); hidden-git
commit flow; smoke-test scaffold; hosting decision;
**assess all apps, graduate one, converge one concept**; handoff test;
plugin-uninstalled test.

**Out (V1 candidates):** cross-vendor agent handoff; model routing;
new-app template beyond a minimal one; any hosted service; any dashboard;
a second SME. Stack moves (framework, monorepo, CI, shared database) are
not pre-excluded: the coach proposes them when the assessment justifies it
and Chris agrees — but V0 commits to graduating one app, not re-platforming
all of them.

## 11. Pilot plan (5–10 hours/week, ~6 weeks)

### Weeks 1–2 — Spikes and hand assessment (go/no-go)

On the partner's real Windows machine and Team account:

- **(a) Git:** local session commits and pushes to a private repo with the
  builder's credentials, no terminal. *Fail → "Claude Code after one setup
  session", and the doc says so.*
- **(b) NAS/SharePoint:** session reads and writes the real shared
  spreadsheet location from file tools and from a script.
- **(c) Tests:** session runs a Playwright smoke test on one existing app
  and reports pass/fail in plain language.
- **(d) Hosting:** one app served from Azure SWA Free (or alternative)
  behind Entra sign-in, opened by a second staff member.
- **(e) Plugin:** a private-marketplace plugin set to "Installed by
  default" appears for a second Team member without their action.

Before going on-site, rehearse per `docs/rehearsal.md` (Linux, then a Mac
with Claude desktop); only Windows-specific items remain for the visit.

Alongside, Chris assesses every app by hand: what it is, who relies on it,
where its data is, what it duplicates, what's exposed. This is the ground
truth the *assess* skill must later reproduce, and the first time the
sponsor sees the burden on one page.

### Weeks 3–4 — Repository and the *assess* skill

Stand up the repository with the hand assessment. Build *assess*; run it on
the real apps; it must find what Chris found and flag contradictions.
Glossary owner agreed with the sponsor. Pick the one app to graduate and
the one concept to converge.

### Week 5 — *ask* and *review*, one real change

Build the two conversational skills. Run one real feature on the chosen app
(a workshop workflow touching "job" or "operation"): question asked,
decision recorded, built, reviewed with a plain-language verdict, smoke test
passes, committed without a terminal. Move that app's data out of
localStorage.

### Week 6 — Handoff and uninstall

A second builder on a second Windows machine continues the work from the
repository. Then, plugin removed, a fresh Claude Code session restores one
app from the repository, runs its tests, and answers five questions about
the system from the repository alone.

## 12. Success criteria (pass/fail)

1. Spikes (a)–(e) pass, or their fallbacks are documented and accepted.
2. *Assess* reproduces ≥ 80% of the hand assessment's findings and flags
   at least one real contradiction.
3. The sponsor, shown the assessment, can say in their own words which
   apps the business depends on and what the main risk is.
4. The feature task completes with no terminal use and at most two
   interruptions from *ask*.
5. *Review*'s verdict on that change is one Chris agrees with, and the
   builder can restate it.
6. One app's data is out of localStorage with an owner and backup
   recorded; one shared concept has one definition used by two apps.
7. A second builder on another machine makes a change that merges cleanly.
8. The plugin-uninstalled test passes.
9. Every judgement call that reached Chris during V0 is listed; each is
   either now handled by a skill or the independent reviewer, or has a
   written reason it cannot be. The list is expected to be short and
   shrinking.

## 13. Risks

1. **Anthropic absorbs it.** Their engineering plugin already has ADR and
   deploy-checklist skills. Differentiate on non-developer audience,
   multi-app, multi-builder, business language; open-source the conventions
   so adoption is a win either way.
2. **Buyers want a cage, not a method** (Retool 2026: 55% platform
   controls vs 26% process). V0 is a method on one client; commercial
   question deferred to a second SME.
3. **The judgement doesn't transfer.** *Review* says things the builder
   can't act on, or *ask* interrupts too much. Measured (criteria 4, 5).
4. **Stale context is worse than none.** Contradiction detection is in V0.
5. **Platform churn.** Nothing depends on UI; enforcement is scripts/CI.
6. **Git fails for non-devs.** Fallback defined in spike (a).
7. **Maintainer risk.** Chris at 5–10 h/week. Principle in §3; uninstall
   test; scope held to §10.
8. **Premature abstraction.** §7 requires duplication evidence first.
9. **Graduating one app proves little.** Accepted for V0; the assessment
   of all apps is what shows the shape of the whole.

## 14. Decision sought today

Run the weeks 1–2 spikes and hand assessment. Nothing else is committed
until their results are in.

## Appendix — references

- Superpowers: https://github.com/obra/superpowers
- Agent Skills: https://agentskills.io/ · AGENTS.md: https://agents.md/
- Claude plugins platform support: https://claude.com/docs/plugins/platform-support
- Org plugin sync: https://claude.com/docs/plugins/org-sync
- Cowork cloud/local on Team: https://support.claude.com/en/articles/13455879
- Windows desktop checklist: https://claude.com/docs/government/deploy-desktop/windows-checklist
- SharePoint custom script: https://learn.microsoft.com/en-us/sharepoint/allow-or-prevent-custom-script
- Azure Static Web Apps plans: https://learn.microsoft.com/en-us/azure/static-web-apps/plans
- CSA "Vibe coding governance gap" (Jun 2026): https://labs.cloudsecurityalliance.org/research/csa-research-note-vibe-coding-ai-governance-gap-20260602-csa/
- Retool AI governance report (May 2026): https://retool.com/blog/ai-governance-report-2026
- Original V0 draft: https://docs.google.com/document/d/1QIOxuySpE16I3rUKcVvIebDB1P2EsRXHdjRewtI2GL4
