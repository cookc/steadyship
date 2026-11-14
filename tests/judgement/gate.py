#!/usr/bin/env python3
"""The release gate's record. Usage: gate.py <result.json> <plugin version> <commit>
Prints Markdown: one line per case with passes out of runs, then "GATE: PASS" or "GATE: FAIL <cases>".
A case passes the gate when at least two thirds of its with-arm runs pass (2 of 3)."""
import json
import math
import os
import sys

sys.argv, argv = sys.argv[:1], sys.argv
import summarise  # noqa: E402


def main():
    path, version, commit = argv[1], argv[2], argv[3]
    d = json.load(open(path))
    outdir = os.path.dirname(os.path.abspath(path))
    print(f"# Judgement gate for plugin {version}\n")
    print(f"Commit {commit}. Run {d.get('startedAt', '')}, Claude Code {d.get('claudeVersion')}, "
          f"model {d['suite'].get('modelOverride')}, with the plugin, cost ${d.get('costUsd', 0):.2f}.")
    shell = any(os.path.isdir(os.path.join(os.path.dirname(os.path.abspath(__file__)), "evals-shell", c["name"]))
                for c in d["cases"])
    print("Shell cases (finish, promote rebuild): " + ("included." if shell else "NOT run (no --shell)."))
    print("\n| Case | Passed | Result of each run |\n|---|---|---|")
    failed = []
    for c in d["cases"]:
        runs = c.get("arms", {}).get("with") or next(iter(c.get("arms", {}).values()), [])
        arm = "with" if "with" in c.get("arms", {}) else next(iter(c.get("arms", {})), "with")
        res = [("ERROR", False, "") if r.get("error") else summarise.run_verdict(c["name"], arm, i, r, outdir)
               for i, r in enumerate(runs, 1)]
        n = sum(1 for x in res if x[1])
        if not runs or n < math.ceil(len(runs) * 2 / 3):
            failed.append(c["name"])
        print(f"| {c['name']} | {n}/{len(runs)} | {' / '.join(x[0] for x in res)} |")
    print()
    print("GATE: PASS" if not failed and not d.get("partial") else
          "GATE: FAIL " + (", ".join(failed) or "run was cut short (cost ceiling)"))


if __name__ == "__main__":
    main()
