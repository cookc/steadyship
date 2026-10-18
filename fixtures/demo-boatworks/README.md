# Demo Boatworks (mock customer fixture)

A made-up small NZ aluminium workboat builder, used to test Steadyship end to
end. Its situation copies the real design partner: six vanilla HTML+JS apps
built by non-technical staff with Claude, data hardcoded or in `localStorage`,
spreadsheets on a shared drive, and the same concepts (customer, job, model,
part, operation) defined differently in different places. No tests, no
hosting, no sign-in.

**Persona:** Morgan Reid owns Demo Boatworks (Nelson, about 18 people). The
setup owner is Chris Cook.

## Contents

- `init-answers.md`, `init.env`: answers to the `steadyship-init` questions.
- `apps/`: six single-file apps (quote-builder, job-board, shop-timer,
  parts-list, delivery-checklist, purchase-requests).
- `shared-drive/`: what sits on the shared drive (Jobs, Customers, Parts,
  Price List 2026, a sample quote).
- `business/`: the business's own Markdown (about, how we build a boat,
  draft glossary).
- `answer-key.md`: every planted defect. Score the assess skill against it.
  Do not show it to the skill under test.

## Use

Populate an existing customer repo (made by `plugin/scripts/init.sh`) and a
shared-drive folder:

    fixtures/demo-boatworks/populate.sh <customer-repo-dir> <shared-drive-dir>

Rebuild the whole demo repo from scratch (never pushes unless asked):

    scripts/demo-regenerate.sh [<target-dir>] [--replace] [--push]

Changing anything here means changing the answer key to match. Bump
`FIXTURE_VERSION` in `init.env` when you do.
