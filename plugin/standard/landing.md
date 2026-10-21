# Landing a change

Claude desktop starts most conversations on their own branch, in a folder
under `.claude/worktrees/`, so work done in one conversation is invisible
to the next until it is merged. Builders never see branches. Every
Steadyship skill that writes files ends with this routine, after its
commit, when a shell is available.

1. `git branch --show-current`. If it is the main branch (`main` or
   `master`, whichever `git rev-parse --verify main` finds), nothing to do.
2. `git worktree list --porcelain`: the first `worktree` line is the main
   checkout. If the current folder is that checkout, nothing to do.
3. In the main checkout, `git -C <main checkout> status --porcelain`. If
   every line it prints is under `docs/` (Steadyship's own records: check
   results, assessments, decisions), commit them there first:
   `git -C <main checkout> add docs && git -C <main checkout> commit -m
   "docs: Steadyship records"`. If anything else is listed, do not merge:
   say "your main folder has unsaved changes to <files>, so this stays on
   its own branch for now; say *finish* once those are saved" and stop
   here.
4. `git -C <main checkout> merge --no-ff <branch> -m "<the commit's one
   line>"`. On a conflict, abort the merge (`git -C <main checkout> merge
   --abort`), say which files conflicted in plain words, and stop here.
5. Say one line: "This is now part of the main app folder." Never delete
   the branch or the worktree the conversation is running in, and never
   push.

A prototype lands without review. A change to an app at Owned tool or
above lands only after the ask or finish skill has reviewed it against
the bar; that review is the gate.
