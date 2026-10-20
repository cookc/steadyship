# Check results

One row per check. Result is PASS, FAIL, SKIP (could not be attempted yet;
the note says what is missing), or blank (not run). "Check this computer"
fills the first three rows itself; the other three are recorded when they
are run. The `steadyship-status` skill reads this table.

| Check | Result | Date | Note |
|---|---|---|---|
| environment | | | |
| shared-drive | | | |
| tests | | | |
| github | | | |
| hosting | | | |
| team | | | |

## Decision ({{SETUP_OWNER}}, after all rows are filled)

Every PASS, or a FAIL with its fallback accepted below, means the setup can go ahead.
A FAIL without an accepted fallback means stop and talk to {{SETUP_OWNER}}.

| Check | Fallback accepted? | What changes |
|---|---|---|
| | | |
