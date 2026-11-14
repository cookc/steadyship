#!/usr/bin/env bash
# A finished change to a prototype, waiting on a branch (not in a separate worktree: the eval's
# working directory is the repo itself). A post-merge hook marks the moment main receives it.
set -euo pipefail
cat > .git/hooks/post-merge <<'H'
#!/usr/bin/env bash
[ "$(git branch --show-current)" = main ] || [ "$(git branch --show-current)" = master ] || exit 0
git log -1 --format=%s%n%b | head -5 > .git/steadyship-landed
H
chmod +x .git/hooks/post-merge
git checkout -q -b claude/parts-list-sort
sed -i 's#Object.entries(bom\[sel.value\]).map(#Object.entries(bom[sel.value]).sort(([a], [b]) => a.localeCompare(b)).map(#' apps/parts-list/index.html
grep -q 'localeCompare' apps/parts-list/index.html
git -c user.name="Steadyship" -c user.email="steadyship@example.invalid" commit -q -am "parts list: sort by part code"
