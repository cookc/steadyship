# Rimu Joinery (second mock business, eval-only)

A made-up joinery workshop in Te Rapa, Hamilton (kitchens, wardrobes,
vanities, laundries, stairs; nine people). It is the second business for the
judgement evals, so the skills are tested on more than one set of data. It
lives under `tests/`, not `plugin/`, so it never ships.

**Persona:** Ana Tane owns Rimu Joinery and is the sponsor. The setup owner is
Sam Setup.

## Contents

- `init.env`: answers to the `steadyship-init` questions.
- `apps/`: five single-file apps (quote-calc, job-tracker, job-clock,
  cut-list, install-calendar).
- `business/`: About, How we make a kitchen, Glossary (draft).
- `shared-drive/`: Jobs, Clients, Materials, Price List, one saved quote.
- `populate.sh <repo> <shared-drive>`: same contract as `plugin/demo/populate.sh`.
- `answer-key.md`: every planted defect, with a grep to verify each. `run.sh`
  never stages it.

Changing anything here means changing `answer-key.md` and the `r*` case
graders to match. Bump `FIXTURE_VERSION` in `init.env` when you do.
