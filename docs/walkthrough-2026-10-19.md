# Walkthrough: Steadyship vs vanilla Claude on Demo Boatworks (2026-10-19)

Both arms got the same prompts in the same directory (`~/steadyship-demo`, regenerated at `75c437b` + `f671674`), run headless with `claude -p`.

- **Plugin arm:** `steadyship@steadyship` enabled, read from `/home/ccook/steadyship/plugin` at `5479872`.
- **Vanilla arm:** the plugin disabled. Its state was checked with `claude plugin list` before and after.

Raw transcripts are in [`walkthrough-2026-10-19/`](walkthrough-2026-10-19/).

**Caveat:** "vanilla" means this machine's Claude Code without Steadyship, not a bare model. Superpowers, feature-dev and the other user plugins stayed on in both arms, along with `defaultMode: auto` and `effortLevel: high`. Spike a was out of scope. Nothing was pushed from the demo repo.

## 1. What was run

| Scenario | Arm | Model | Time | Files changed |
|---|---|---|---|---|
| S0 status | plugin | sonnet | 15 s | none |
| S0 spike 0 (twice, two sessions) | plugin | sonnet | 16 s + 16 s | none (marker outside repo, by design) |
| S0 spike b | plugin | sonnet | 19 s | none |
| S0 spike c (job-board) | plugin | sonnet | 21 s | only git-ignored `node_modules/`, `test-results/` |
| S1 | vanilla | sonnet | 75 s | none |
| S1 | vanilla | opus | 52 s | none |
| S1 | plugin | sonnet | 43 s | none |
| S2 | vanilla | sonnet | 9 s | none |
| S2 | plugin | sonnet | 10 s | none |
| S3 | vanilla | sonnet | 27 s | none |
| S3 | plugin | sonnet | 25 s | none |

No run timed out or failed, and none wrote a tracked file. The demo repo was restored after each run and is clean now.

## 2. S0: the plugin flow

Every step worked first time, in plain language.

- **Status** gave the expected shape: "Apps assessed: 1 (`_sample` — Prototype…)… Spikes (short technical test runs): 0 passed, 0 failed, 6 not yet run (0, e, a, b, c, d). Next step: Run spike 0." It also volunteered: "This looks like the example file that ships with Steadyship, not a real app assessment."
- **Spike 0** passed: "all 6 tools installed… all 5 websites reachable." It told the user to run it again in a new session. The second session reported "persistence ok", then hedged: "that marker may have come from a run earlier today… treat that part as provisional." A non-technical user can't act on that.
- **Spike b** passed. Because the prompt said "run the script", it ran only Part 2 and said so honestly: "I can't say 'file tools: ok' yet. Say the word and I'll run it." The row it offered (`script: ok; file tools: not yet checked`) isn't one the runbook defines.
- **Spike c** passed: "opened in a test browser and loaded with no errors." It reported "whole run ~4s", but the run took 21 s including the npm install. Chromium was already cached.

Every spike reply offered its RESULTS.md row, as the skill says, and none wrote it. In a real session the user must paste four rows into a markdown table. That's the main friction a non-technical person would hit.

## 3. S1: understand my system

Scored against the answer key's 29 items (now `tests/judgement/answer-key.md`). PARTIAL counts as ½. Per-row marks are in the appendix.

| | vanilla-sonnet | vanilla-opus | plugin-sonnet |
|---|---|---|---|
| Concepts (/9) | 7 | 8 | 8 |
| Duplications (/20) | 13.5 | 15 | 15.5 |
| **Total (/29)** | **20.5** | **23** | **23.5** |
| Strict, no partials | 20 | 23 | 23 |
| Key §4 risks (/9, full + partial) | 6 + 3½ | 6 + 1½ | 6 + 2½ |

**No arm reached 24/29. Vanilla-opus came within one.** The plugin has no assess skill, and none of its skills fire on this prompt. The plugin arm behaved like vanilla: same layout, same closing offer to fill in `SUMMARY.md`. Its lead over vanilla-sonnet is run-to-run variance, not Steadyship. The extra items it found (operation vs job, "1040" in purchase requests) are ones vanilla-opus also found.

**All three found:**

- the stale Bimini top and Trailer prices ("A quote with both options built today comes out $700 too cheap")
- the two stale board stages and `1043`
- the customer-name variants and the hyphenless part codes
- the fuel tank priced at $725 vs $740
- quote validity of 14 vs 30 days
- the hull number
- browser-only storage

**All three missed:**

- the code-level copies: `money`, the buggy `fmtMoney`, header CSS drift, UTC dates (items 13–16)
- the short "WB 6.2" model name
- Q-2026-031 itself being quoted on now-stale prices

All three also found a true issue the key lacks: every computer would issue the same next quote number ("Two people on two computers would both issue 'Q-2026-032'"). I found no untrue claims except one in plugin-sonnet: "Jobs from J-1042 onwards are missing from the Timer". The Timer does have J-1042.

## 4. S2 and S3

### S2: add painting time tracking to shop-timer

Neither arm built anything, and neither changed a file. Neither asked job vs operation or where the data should live, and neither mentioned that the timer is localStorage-only. Both asked one generic interview question in almost the same words:

- Vanilla: "If you'd rather skip the questions and have me just start, say so and I will. Tell me about the last time a painter wished they had this…"
- Plugin: "If you'd rather skip the questions and have me just start, say so and I will. Tell me about the moment a painter would use this…"

The shared wording points to a brainstorming-style behaviour present in both arms, not Steadyship. Because `-p` is single-turn, we don't know whether a later turn would reach the operation question. The S1 runs show the model can see the job/operation mismatch when told to look everywhere. Nothing triggers it at feature-request time.

### S3: is job-board good enough to replace the Jobs spreadsheet?

| Key risk | vanilla-sonnet | plugin-sonnet |
|---|---|---|
| localStorage per machine | yes | yes (cites line 57) |
| No backup | partial | yes |
| Stale copy of Jobs.csv | **yes, verified**: J-1039, J-1041 | **generic**: "the real Jobs spreadsheet isn't in the repo, so I haven't compared the two" |
| Job-number format | yes | yes |
| Stage names drift | yes | yes |
| No sign-in | no | no |

Both gave the right verdict and the same next step, which matches key §6 in substance. Neither used the stage vocabulary (Prototype → Owned tool).

- Vanilla: "keep the spreadsheet as the real record. The board can run beside it as a read-only display."
- Plugin: "Keep the spreadsheet as the source of truth for now. Treat the app as a read-only wall display at most."

The plugin arm's only process-aware line was "First, run the assessment and the spikes", and the repo's own docs give that context in either arm. It also never opened the shared drive, though `steadyship.md` names it, so it missed the concrete evidence vanilla found. Neither reply said anything untrue; I checked the line numbers and the UTC overdue claim.

## 5. Honest conclusion

**Where the plugin helps now: setup and spikes.**

- Four one-line requests each worked first time, in 15–21 s.
- The replies were plain language, gave the exact RESULTS row, and didn't over-claim.
- Vanilla has no equivalent. Someone would have to know the runbooks exist and drive them, in a terminal.

**Where it doesn't differ yet: judgement.** S1–S3 are indistinguishable between arms, as expected, because the assess, ask and review skills don't exist yet. And nothing is recorded: every S1 run offered to fill in `docs/assessment/SUMMARY.md` and left it blank.

**What weeks 3–5 must beat:**

- **Assess.** Vanilla-opus finds 23/29 unprompted in under a minute, and vanilla-sonnet finds 20–23. With all skills disabled ("true vanilla", below), sonnet scored 22.5 and opus 21. The skill must hit ≥24 reliably on sonnet and write the result to `docs/assessment/`. The gap is concrete: no run compared code across apps (items 13–16), noticed "WB 6.2", or linked Q-2026-031 to the stale prices.
- **Ask.** No arm asked job-vs-operation, or mentioned browser-only storage, before building a timer feature. The ask skill's value is consulting the business docs and the assessment at request time.
- **Review.** Both arms already say "no, keep the spreadsheet". Review must add three things: always reading the shared drive, a named stage and single writer, and sign-in.

## 6. Bugs and friction (not fixed)

1. `docs/assessment/_sample.md` is counted by steadyship-status, so a fresh repo reports "Apps assessed: 1".
2. Spike 0's home-folder marker survives demo regenerations, so the persistence check is ambiguous on a reused machine ("treat that part as provisional").
3. Spike b invents an undefined row when only Part 2 runs. Either define that row or always run Part 1.
4. Spike c's "install took <minutes>" field invites a guess. The reply said "~4s" for a 21 s run.
5. Rows are offered, never written. Pasting into a markdown table is the hardest S0 step for the target user.
6. In S3 the plugin arm didn't read the shared drive named in `steadyship.md`. Future skills should read `Shared drive:` and look there.
7. The baseline isn't bare. S2's identical question in both arms shows the other plugins shape behaviour. A cleaner baseline would use `--setting-sources` or a bare profile.

## True vanilla (all skills disabled)

Bug 7 says the vanilla arm wasn't bare. So S1–S3 were re-run with Steadyship disabled and `--disable-slash-commands`, which left every session with zero skills (`skills: []` at init). Transcripts are `true-vanilla-*.md`. The other plugins were still installed: superpowers' SessionStart hook still injected its "using-superpowers" text, but no skill could be invoked.

| Scenario | Model | Time | Files changed |
|---|---|---|---|
| S1 | sonnet | 52 s | none |
| S1 | opus | 58 s | none |
| S2 | sonnet | 72 s | `apps/shop-timer/index.html` (+38 −12), plus `/tmp/t.mjs` outside the repo |
| S3 | sonnet | 26 s | none |

No run timed out. The demo repo was restored after each run.

**S1** (per-row marks in the appendix):

| | vanilla-sonnet | vanilla-opus | plugin-sonnet | true-vanilla-sonnet | true-vanilla-opus |
|---|---|---|---|---|---|
| Concepts (/9) | 7 | 8 | 8 | 8 | 7.5 |
| Duplications (/20) | 13.5 | 15 | 15.5 | 14.5 | 13.5 |
| **Total (/29)** | **20.5** | **23** | **23.5** | **22.5** | **21** |
| Strict, no partials | 20 | 23 | 23 | 22 | 20 |
| Key §4 risks (/9, full + partial) | 6 + 3½ | 6 + 1½ | 6 + 2½ | 6 + 2½ | 5 + 2½ |

Neither run reached 24. Both missed the same items as before: 13–16, "WB 6.2" and Q-2026-031. Opus also missed `1043`. Both again found the duplicate next-quote-number problem. I found no untrue claims; I checked the hull-number glossary line, the "apps live on the shared drive" note and opus's "$805 (including GST)".

**S2: built without asking.** "I added paint time tracking to the shop timer, in `apps/shop-timer/index.html`. I haven't committed it." It added a "Start paint" button and a paint clock per job, then checked them with a Playwright script and `scripts/validate.sh` (PASS). It raised storage and operations only after building:

- "Times are still stored only in each device's browser, as before. Painters on separate tablets or phones won't see each other's times."
- "If you also want prime, topcoat and antifoul tracked separately, that's a small extension. The business notes list those as the three steps of the paint stage."

**S3: did not open the shared drive,** even though it read `steadyship.md`, which names it: "I haven't seen `Jobs.csv`. It isn't in the repo."

- **Risks named:** localStorage per machine, job-number format and stage drift. The stale copy was named only generically ("copied from Jobs.csv - Sam… won't show up here"). It missed no backup and no sign-in.
- **Verdict:** "No, it isn't good enough yet… I'd keep the spreadsheet as the source of truth for now."
- **Next step:** "A shared place to store the data" and "A decision on whether the board or the spreadsheet is the master."
- **Accuracy:** one citation is wrong. `index.html:46-50` should be lines 37 and 57. The UTC point ("about 1pm") is correct.

**What changed versus the confounded arm.** In S1 and S3, nothing material changed. Scores sit within the earlier 20.5–23.5 spread, and S3 gives the same verdict as before, missing the shared drive like the plugin arm did. S2 changed completely. The earlier "If you'd rather skip the questions…" interview came from superpowers' brainstorming skill, not from Claude. Bare Claude simply built the painting timer, in 72 s, without asking job vs operation or where the data should live. It did mention localStorage and the paint operations, but only afterwards, as caveats on a finished change. So the ask skill must beat a baseline of zero questions.

## To promote the regenerated demo

This was deliberately not done automatically. The regenerated history is on local `main` and remote `boatworks`. To promote it, run:

```bash
git -C ~/steadyship-demo push --force origin main
```

Or set `boatworks` as the default branch on GitHub.

---

## Appendix: S1 per-row marks

F = FOUND, P = PARTIAL (½), N = NOT FOUND. Columns: vanilla-sonnet (VS), vanilla-opus (VO), plugin-sonnet (PS), true-vanilla-sonnet (TVS), true-vanilla-opus (TVO).

**Section 2: shared concepts**

| # | Concept | VS | VO | PS | TVS | TVO | Note |
|---|---|---|---|---|---|---|---|
| 1 | Customer (3 spellings) | F | F | F | F | F | all name "Harbour Svcs Ltd" and the glossary rule |
| 2 | Job (2 number formats) | F | F | F | F | P | VS gives `1043` only; VO, PS also give `1040` in purchase requests; TVO: "job numbers are typed in any format", no example |
| 3 | Model ("WB 6.2" short in parts-list) | N | N | N | N | N | |
| 4 | Part (2 code formats) | F | F | F | F | F | |
| 5 | Operation (no app records it) | N | F | F | F | F | VO: "Your notes say time is booked to each *operation*… The timer only records time per *job*" |
| 6 | Price (2 values differ) | F | F | F | F | F | |
| 7 | Stage (6 vs 9, "Fit out") | F | F | F | F | F | |
| 8 | Quote validity (14 vs 30) | F | F | F | F | F | |
| 9 | Hull number never recorded | F | F | F | F | F | |
| | **Subtotal** | **7** | **8** | **8** | **8** | **7.5** | |

**Section 3: planted duplications**

| # | Item | VS | VO | PS | TVS | TVO | Note |
|---|---|---|---|---|---|---|---|
| 1 | Job list stale on board | F | F | F | F | F | |
| 2 | `1043` vs `J-1043` | F | F | F | F | N | TVO doesn't mention `1043` |
| 3 | Shop-timer own 3 jobs | F | F | F | F | F | PS also quotes the "Harbour WB 6.2" label |
| 4 | Delivery-checklist own 4 jobs | F | F | F | F | F | |
| 5 | Purchase-requests free-text job ref | P | F | F | F | P | VS lists it as holding jobs but gives no format; TVS names `1040`; TVO is generic |
| 6 | Stage names on board | F | F | F | F | F | |
| 7 | Customer name variants | F | F | F | F | F | |
| 8 | Quote-builder customer list copy | F | F | P | P | F | PS says "every app has its own typed-in copy" but doesn't name quote-builder's customer list; TVS: "Customers.csv and the Quote Builder use the full legal name", not that it's a copy |
| 9 | Quote-builder stale prices | F | F | F | F | F | |
| 10 | Part codes lose hyphens | F | F | F | F | F | PS also notes the two parts missing |
| 11 | Fuel tank 725 vs 740 | F | F | F | F | F | |
| 12 | Purchase-request item code free text | F | F | F | F | F | |
| 13 | `money` copied | N | N | N | N | N | |
| 14 | `fmtMoney` differs/buggy | N | N | N | N | N | |
| 15 | Header CSS drift | N | N | N | N | N | |
| 16 | UTC date logic copied | N | N | N | N | N | (both S3 replies noticed it in job-board alone) |
| 17 | Board stage moves never reach Jobs.csv | F | F | F | F | F | |
| 18 | Time per job vs per operation | N | F | F | F | F | |
| 19 | Quote validity 14 vs 30 | F | F | F | F | F | |
| 20 | Q-2026-031 quoted on stale prices | N | N | N | N | N | VO: "Check any quotes sent since 1 September", not tied to Q-031 |
| | **Subtotal** | **13.5** | **15** | **15.5** | **14.5** | **13.5** | |

**Section 4 risks** (F/P/N for risks 1–9):

- VS: F F F P F F F P P
- VO: F F F N F F F N P
- PS: F F F P F F F N P
- TVS: F F F F P F F N P
- TVO: F F F P P F F N N
