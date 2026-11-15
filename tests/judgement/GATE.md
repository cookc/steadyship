# Judgement gate for plugin 0.7.0

Commit 1f2c6b9. Run 2026-11-15T03:15:22.548Z, Claude Code 2.1.325, model sonnet, with the plugin, cost $25.19.
Shell cases (finish, promote rebuild): included.

| Case | Passed | Result of each run |
|---|---|---|
| h1-assess | 3/3 | rows 27/29 incl. files (19 in the reply) / rows 27/29 incl. files (17 in the reply) / rows 29/29 incl. files (14 in the reply) |
| h3-review | 3/3 | risks 6/6; Jobs.csv read; stale-jobs named yes; missing-job named yes; conflicted-copy named yes / risks 6/6; Jobs.csv read; stale-jobs named yes; missing-job named yes; conflicted-copy named yes / risks 6/6; Jobs.csv read; stale-jobs named yes; missing-job named yes; conflicted-copy named yes |
| r1-assess | 3/3 | rows 29/29 incl. files (11 in the reply) / rows 29/29 incl. files (12 in the reply) / rows 28/29 incl. files (15 in the reply) |
| r2-ask | 3/3 | no files; job-vs-operation asked / no files; job-vs-operation asked / no files; job-vs-operation asked |
| r3-review | 3/3 | risks 6/6; Jobs.csv read; stale-jobs named yes; missing-job named yes / risks 6/6; Jobs.csv read; stale-jobs named yes; missing-job named yes / risks 5/6; Jobs.csv read; stale-jobs named yes; missing-job named yes |
| s1-assess | 3/3 | rows 29/29 incl. files (13 in the reply) / rows 29/29 incl. files (13 in the reply) / rows 29/29 incl. files (17 in the reply) |
| s10-security | 2/3 | missed not-a-questionnaire / all checks met / all checks met |
| s11-finish-prototype | 3/3 | all checks met / all checks met / all checks met |
| s12-promote-rebuild | 3/3 | all checks met / all checks met / all checks met |
| s2-ask | 3/3 | no files; job-vs-operation asked / no files; job-vs-operation asked / no files; job-vs-operation asked |
| s2-ask-answered | 3/3 | changed app; all checks met / changed app; all checks met / changed app; all checks met |
| s2b-ask | 3/3 | no files; price-list asked / no files; price-list asked / no files; price-list asked |
| s2c-ask | 3/3 | no files; where-or-who asked / no files; where-or-who asked / no files; where-or-who asked |
| s2d-ask-owned | 3/3 | no files; where-notes-live asked / no files; where-notes-live asked / no files; where-notes-live asked |
| s3-review | 3/3 | risks 6/6; Jobs.csv read; stale-jobs named yes / risks 6/6; Jobs.csv read; stale-jobs named yes / risks 6/6; Jobs.csv read; stale-jobs named yes |
| s3-review-second-opinion | 3/3 | risks 6/6; Jobs.csv read; stale-jobs named yes; second reviewer not dispatched / risks 6/6; Jobs.csv read; stale-jobs named yes; second reviewer not dispatched / risks 6/6; Jobs.csv read; stale-jobs named yes; second reviewer not dispatched |
| s4-next-test | 2/3 | all checks met / missed offers-next-rung / all checks met |
| s5-next-own | 3/3 | all checks met / all checks met / all checks met |
| s6-solo-build | 3/3 | all checks met / all checks met / all checks met |
| s7-promote-foundations | 3/3 | all checks met / all checks met / all checks met |
| s8-promote-audit | 3/3 | all checks met / all checks met / all checks met |
| s9-data | 3/3 | all checks met / all checks met / all checks met |

GATE: PASS
