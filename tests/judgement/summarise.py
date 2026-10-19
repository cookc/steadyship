#!/usr/bin/env python3
"""Turn a `claude plugin eval --json` result into the judgement summary table (Markdown).

Usage: summarise.py <result.json>
Cases are recognised by the skill in their name (s* = Demo Boatworks, r* = Rimu Joinery,
any other prefix works the same way). Pass rules (deterministic graders only; llm graders are
reported, not gating):
  *-assess   rows found (row-* graders) >= ceil(rows * 24/29): the first key's 24 of 29
  *-ask      no-write AND no-edit AND its asks-* grader
  *-review   read-jobs-csv AND all but one of the risk-* graders (5 of 6)
Every case also needs no-peek (the agent did not read the staged cases).
Also saves each run's final reply (taken from the llm grader's evidence) as
<case>-<arm>-<n>.md next to result.json, for regrade.py and for reading.
"""
import json
import math
import os
import sys


def verdict(case, g):
    ok = lambda n: g.get(n, False)
    if not ok("no-peek"):
        return "-", False, "PEEKED at eval files"
    kind = case.rsplit("-", 1)[-1]
    if kind == "assess":
        rows = sum(v for k, v in g.items() if k.startswith("row-"))
        total = sum(1 for k in g if k.startswith("row-"))
        return (f"rows {rows}/{total}", rows >= math.ceil(total * 24 / 29),
                f"llm job-list copies: {'yes' if ok('llm-job-list-copies') else 'no'}")
    if kind == "ask":
        built = not (ok("no-write") and ok("no-edit"))
        q = next((k for k in g if k.startswith("asks-")), "asks-?")
        asked = ok(q)
        return (f"{'built' if built else 'no files'}; {q[5:]} {'asked' if asked else 'not asked'}",
                (not built) and asked, f"llm asks-before-building: {'yes' if ok('llm-asks-before-building') else 'no'}")
    if kind == "review":
        risks = sum(v for k, v in g.items() if k.startswith("risk-"))
        nrisks = sum(1 for k in g if k.startswith("risk-"))
        read = ok("read-jobs-csv")
        extra = "; ".join(f"{k[:-6]} named {'yes' if v else 'no'}" for k, v in g.items() if k.endswith("-named"))
        return (f"risks {risks}/{nrisks}; Jobs.csv {'read' if read else 'not read'}; {extra}",
                read and risks >= nrisks - 1, f"llm verdict+next step: {'yes' if ok('llm-verdict-and-next-step') else 'no'}")
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
