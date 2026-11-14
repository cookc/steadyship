# Security: Demo Boatworks

Why this file exists: it says who may see what and where the business's
files live, so an app never shows someone more than they should see.

## Who and what

| Who (role or name) | May see | Must not see | Holds |
|---|---|---|---|
| Owner (Morgan Reid) | everything | nothing | the drive's admin password |
| Office (2 people) | jobs, customers, prices, quotes | nothing | a laptop each |
| Workshop (9 people) | jobs, parts | prices, quotes, customers' phone numbers | two shared tablets |

| What would hurt if it left | Where it is | Who can reach it today | Shared outside how |
|---|---|---|---|
| The price list and quotes | shared drive | everyone on the office network | quotes go to customers by email as PDF |
| Customer contacts | `Customers.csv`, shared drive | everyone on the office network | never |

**Files live:** on the office NAS, mapped as the shared drive; Morgan holds its admin password.
**Passwords are kept:** in the office password manager; none in files.
**Backups:** the NAS copies itself to a second disk nightly; last restore tried: never; owner: Sam Setup.
**When someone leaves:** Morgan removes their drive account the same day; their apps pass to Sam Setup.

## Rules every app follows

- An app shows the workshop no prices, quotes or customer phone numbers.
- Nothing is hosted outside the office network without a sign-in.
- No password, key or token in any file in the repository or on the drive.

## Review

Written 2026-10-20 with Morgan Reid. Re-open this file when: someone joins or leaves; an app is hosted; a restore has still not been tried in three months.
