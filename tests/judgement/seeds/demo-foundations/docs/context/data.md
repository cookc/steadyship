# Data: Demo Boatworks

Why this file exists: it says which file is the one true record of each kind
of information, so every app reads the same thing and nothing is kept twice.

## The things we keep

| Thing | What it is (our words) | Master (file, where) | Who writes it | Who reads it | Copies elsewhere | Must never be lost? | Personal? | Keep for |
|---|---|---|---|---|---|---|---|---|
| Jobs | each boat being built, its stage and promised date | `Jobs.csv`, shared drive | the office, one person at a time | everyone | job board, shop timer (typed-in copies) | yes | no | 7 years |
| Customers | who we build for and their contact | `Customers.csv`, shared drive | the office | the office | quote builder (typed-in names) | yes | yes: contact names and phone numbers | 7 years |
| Parts | part codes, suppliers and unit costs | `Parts.csv`, shared drive | the workshop lead | everyone | parts list app | no, can be rebuilt from supplier invoices | no | while current |
| Prices | models and options, ex GST | `Price List 2026.csv`, shared drive | the owner | the office | quote builder (typed-in prices) | yes | no | 7 years |
| Quotes | what we offered a customer | `Quotes/`, shared drive, one file each | the office | the office | none | yes | yes: customer contact | 7 years |
| Hours | time spent per operation | nowhere yet, in the shop timer's browser | whoever holds the tablet | nobody else | none | yes, once it is used for pricing | no | 7 years |

## Rules every app follows

- One master per thing, named above. An app reads a thing from its master and never keeps a second copy.
- A value that exists only inside free text gets its own column in the master before an app uses it. Nothing is parsed out of a description.
- A new kind of information is added to this table before any app stores it.
- A master file stays under 5,000 rows (the bar's budget). Past that, or the day two people write to it at once, a database is the answer; that is a decision stated with a reason, never drifted into.
- Personal data is named above and nowhere in sample data; New Zealand's Privacy Act 2020 applies.
- The office changes a job's stage; the workshop may read it and may not change it. (Morgan's words.)

## Review

Written 2026-10-20 with Morgan Reid. Re-open this file when: a master passes 5,000 rows; two people write to a master at once; a new kind of thing appears; personal data appears where none was; six months have passed.
