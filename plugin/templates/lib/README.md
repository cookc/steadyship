# lib

Libraries the apps may use, kept here so they work with no internet and
never change under an app. Each is pinned to one version from Steadyship's
allow-list; nothing is added here without a line in
`docs/context/engineering.md` saying why.

| File | What | Version | Licence |
|---|---|---|---|
| `papaparse.min.js` | CSV reading and writing (quotes, commas, line endings done right) | 5.4.1 | MIT, see `LICENSE-papaparse` |

An app loads one with a relative path, so it works from a double-click and
through the serve script alike: `<script src="../../lib/papaparse.min.js"></script>`.
