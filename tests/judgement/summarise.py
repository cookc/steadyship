#!/usr/bin/env python3
"""Turn a `claude plugin eval --json` result into the judgement summary table (Markdown).

Usage: summarise.py <result.json>
Case pass rules (deterministic graders only; llm graders are reported, not gating):
  s1-assess  rows found (row-* graders) >= 24 of 29
  s2-ask     no-write AND no-edit AND asks-job-vs-operation
  s3-review  read-jobs-csv AND >= 5 of the 6 risk-* graders
Every case also needs no-peek (the agent did not read the staged cases).
Also saves each run's final reply (taken from the llm grader's evidence) as
<case>-<arm>-<n>.md next to result.json, for regrade.py and for reading.
"""
import json
import os
import sys


def verdict(case, g):
    ok = lambda n: g.get(n, False)
    if not ok("no-peek"):
        return "-", False, "PEEKED at eval files"
    if case.startswith("s1"):
        rows = sum(v for k, v in g.items() if k.startswith("row-"))
        total = sum(1 for k in g if k.startswith("row-"))
        return f"rows {rows}/{total}", rows >= 24, f"llm job-list copies: {'yes' if ok('llm-job-list-copies') else 'no'}"
    if case.startswith("s2"):
        built = not (ok("no-write") and ok("no-edit"))
        asked = ok("asks-job-vs-operation")
        return (f"{'built' if built else 'no files'}; job-vs-op {'asked' if asked else 'not asked'}",
                (not built) and asked, f"llm asks-before-building: {'yes' if ok('llm-asks-before-building') else 'no'}")
    if case.startswith("s3"):
        risks = sum(v for k, v in g.items() if k.startswith("risk-"))
        read = ok("read-jobs-csv")
        return (f"risks {risks}/6; Jobs.csv {'read' if read else 'not read'}; stale J-1039/J-1041 {'named' if ok('stale-jobs-named') else 'not named'}",
                read and risks >= 5, f"llm verdict+next step: {'yes' if ok('llm-verdict-and-next-step') else 'no'}")
    return "", False, ""


def main():
    d = json.load(open(sys.argv[1]))
    outdir = os.path.dirname(os.path.abspath(sys.argv[1]))
    for c in d["cases"]:
        for arm, runs in c.get("arms", {}).items():
            for i, r in enumerate(runs, 1):
                ev = [g["evidence"] for g in r.get("graders", []) if g.get("evidence")]
                if ev:
                    with open(os.path.join(outdir, f"{c['name']}-{arm}-{i}.md"), "w", encoding="utf-8") as f:
                        f.write(ev[0])
    print(f"# Judgement run {d.get('startedAt', '')}\n")
    print(f"Claude Code {d.get('claudeVersion')}, model {d['suite'].get('modelOverride')}, "
          f"ablation {d['suite'].get('ablation')}, wall {d.get('durationSeconds')} s, "
          f"cost ${d.get('costUsd', 0):.2f}{' (PARTIAL)' if d.get('partial') else ''}\n")
    print("| Case | Arm | Run | Result | Pass | Also | Turns | Time (s) | Cost ($) |")
    print("|---|---|---|---|---|---|---|---|---|")
    for c in d["cases"]:
        for arm, runs in c.get("arms", {}).items():
            for i, r in enumerate(runs, 1):
                g = {x["name"]: x["passed"] for x in r.get("graders", [])}
                if r.get("error"):
                    res, ok, also = "ERROR", False, r["error"][:120].replace("|", "/")
                else:
                    res, ok, also = verdict(c["name"], g)
                cost = (r.get("costUsd") or 0) + (r.get("judgeCostUsd") or 0)
                print(f"| {c['name']} | {arm} | {i} | {res} | {'PASS' if ok else 'fail'} | {also} | "
                      f"{r.get('turns')} | {r.get('durationSeconds')} | {cost:.2f} |")
    print("\nPer-grader detail (✓/✗ per run, arms in order):\n")
    for c in d["cases"]:
        names = [g["name"] for g in c.get("graders", [])]
        print(f"- **{c['name']}**")
        for arm, runs in c.get("arms", {}).items():
            for i, r in enumerate(runs, 1):
                g = {x["name"]: x["passed"] for x in r.get("graders", [])}
                misses = [n for n in names if not g.get(n, False)]
                print(f"  - {arm} run {i}: missed {', '.join(misses) if misses else 'none'}")


if __name__ == "__main__":
    main()
