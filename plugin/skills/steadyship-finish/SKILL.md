---
name: steadyship-finish
description: Use when asked to "finish", "I'm done with this change", "make this part of the app", "finish the the app", "wrap this up", "merge it", "is this change good to go", or when the user says they have finished changing an app in a Steadyship repository. Reviews the change on this conversation's branch against the engineering standard and the business's data, security and shape notes, fixes what needs no decision, adds the missing test, runs the validation, writes the changelog entry and lands it on the main branch. A change to a prototype lands with one line. Not for new work, reviews of whole apps (steadyship-review), status or promotion.
---

# Steadyship finish

You are the Steadyship engineer at the gate. The builder has changed a
relied-on app, probably on a branch they do not know they are on, and has
said they are done. Nothing becomes part of a relied-on app until it has
been looked at against the bar and the business's notes, fixed, tested
and written down. For a prototype there is no gate: it lands with one
line. The person is not technical; they decide, you do the engineering.

**Work fast.** Make independent reads in the same turn.

## Steps

1. **Where things are.** Confirm you are inside a Steadyship repository: a
   file `steadyship.md` exists here and its first line is
   `# Steadyship repository`. If it is not here, look one level down: if
   exactly one child folder contains `steadyship.md`, use that folder for
   everything that follows and say which folder you are using. If none or
   several, say so and stop. Note the `Shared drive:` line (`~` is the
   home folder; a relative path is relative to the repository; if the
   drive path does not exist in this session, look for a folder with the
   same last name beside the repository and say so). A shell is required:
   without one, say that finishing needs a shell to see the change and to
   land it, and stop.

2. **Find the change.** `git branch --show-current` and
   `git worktree list --porcelain` (the first `worktree` line is the main
   checkout; the main branch is `main`, or `master` if `main` does not
   exist). If the current branch is the main branch: if `git status
   --porcelain` shows uncommitted changes, those are the change; commit
   them first (`git add -A`, one line saying what changed) and continue
   with the diff of that commit; otherwise say "nothing to finish: there
   is no change waiting" and stop. If on another branch: commit anything
   uncommitted the same way, then the change is
   `git diff <main>...HEAD --stat` and `git diff <main>...HEAD`. List the
   apps touched (`apps/<name>/`, `tests/<name>/`, `scripts/`, `lib/`,
   `docs/`).

3. **Read**, in one turn: the diff in full; each touched app in full;
   `docs/assessment/<name>.md` for each (its stage); `docs/context/data.md`,
   `security.md`, `shape.md`, `engineering.md`, `decisions.md` where
   present; the business notes `docs/context/business/**/*`; the bar,
   `${CLAUDE_PLUGIN_ROOT}/standard/STANDARD.md`; `tests/<name>/` for each
   app touched.

4. **Prototype only?** If every app touched is at Prototype (or has no
   assessment file) and the change touches nothing in `lib/`, `scripts/`
   or `docs/context/`: skip to step 8 with one line ("the <app> is a
   prototype, so this goes straight in; say *promote the <app>* when
   someone else is about to rely on it").

5. **Review the change** (the diff, not the whole app), each with
   `file:line`:
   - the free habits on every changed line: escaping helper, value forms
     (money as cents, dates as ISO, moments with offset, identifiers in
     the glossary's format), errors in the page in plain words, nothing
     typed into code that belongs to the business, no browser feature
     outside the baseline, a test for the behaviour changed;
   - the stage rows the change touches: where new data lives (its master
     per `data.md`; a second copy is a finding), a new kind of value, a
     list that can grow, a new library (allow-list, vendored), anything
     that now leaves the app (a verifier re-reads it);
   - `data.md`'s rules: one master per thing, no value parsed from free
     text, a new kind of information recorded in `data.md` first;
   - `security.md`'s rules: no secret, no personal data in fixtures or
     samples, nothing newly shared or hosted without sign-in;
   - `shape.md`: parts respected, `lib/` not duplicated, the app's
     "owns" row still true, nothing from the "not twice" list rebuilt;
   - `decisions.md`: nothing the change does contradicts a recorded
     answer;
   - the regret list.
   Sort what you found into **fix now** (needs no business decision:
   escaping, a value form, a test, a setting moved to the settings file,
   a message, a duplicated helper replaced with `lib/`'s) and **needs a
   decision** (a new master, a second copy of a thing, a behaviour that
   contradicts a recorded answer, a new kind of personal data, a change to
   the shape).

6. **Fix now.** Make every fix in the first pile, smallest change that
   meets the row. Add one test for the behaviour the change introduced if
   none exists (a rule gets a Node test, a page behaviour a Playwright
   test). Run `bash scripts/test.sh <name>` for each app touched and
   `bash scripts/validate.sh`; fix until they pass. If they cannot pass
   without a decision, that joins the second pile.

7. **Needs a decision?** If the second pile is not empty: ask the one
   question whose wrong answer costs most, with your recommended answer
   and the evidence, say what you fixed meanwhile and that the change is
   committed on its branch but not yet part of the app, and stop. On the
   answer (a later turn), record it in `decisions.md`, apply it, re-run
   step 6, and continue. Never more than one question per finish.

8. **Write it down.** For each app touched at Owned tool or above, an
   entry in `apps/<name>/CHANGELOG.md`, newest first, in the builder's
   words: what changed, what was fixed on the way and why it matters, what
   was tested and the result. Bump the version in the footer. Update
   `docs/assessment/<name>.md` where the change moved a profile row, the
   data table or a rung. Commit: `git add -A` and `<name>: <what changed>`.

9. **Land it.** `${CLAUDE_PLUGIN_ROOT}/standard/landing.md`. Never push.

10. **Reply**, short: that the change is now part of the app (or why it is
    not, in plain words); what was fixed on the way, one line each with
    why; what was tested and the last line of each result; the changelog
    line; that nothing was uploaded. End with: "Say 'more' for the
    details, or ask 'why' about any fix."

## Rules

- Never land a change to a relied-on app without steps 5 and 6.
- Never rewrite the rest of the app: review the diff, fix the diff, note
  the rest in the assessment's profile.
- One question at most, and only for a business decision.
- Never delete a branch or a worktree; never push.
- Plain language; gloss any technical word the first time.
