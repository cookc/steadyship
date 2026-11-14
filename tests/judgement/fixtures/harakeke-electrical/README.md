# Harakeke Electrical (third mock business, eval-only, held out)

A made-up electrical contractor in Richmond, near Nelson (house wiring,
switchboards, maintenance; ten people, three vans). It is the **held-out**
business for the judgement evals: the fixture, its answer key and the `h*`
case graders were written without reading the Steadyship skills, standard or
agents, and the graders were frozen when they were written. It lives under
`tests/`, not `plugin/`, so it never ships.

**Persona:** Hana Parata owns Harakeke Electrical and is the sponsor. The
setup owner is Sam Setup.

## Contents

- `init.env`: answers to the `steadyship-init` questions.
- `apps/`: five single-file apps (job-board, invoice-maker, quick-quote,
  timesheet, van-stock).
- `business/`: About, How a job runs, Pay and timesheets, Glossary (draft).
- `shared-drive/`: Jobs (and a conflicted copy), Customers, Materials, Price
  List, a van stocktake, three saved invoices, one saved quote.
- `populate.sh <repo> <shared-drive>`: same contract as `plugin/demo/populate.sh`
  (copied unchanged from `fixtures/rimu-joinery/`).
- `answer-key.md`: every planted defect, with a command to verify each.
  `run.sh` never stages it.

Do not tune this fixture, its key or the `h*` graders to a model's output:
that is what makes it held out. If the fixture itself has to change, change
`answer-key.md` and the graders from the key alone, and bump
`FIXTURE_VERSION` in `init.env`.
