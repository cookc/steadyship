#!/usr/bin/env python3
"""Turn a `claude plugin eval --json` result into the judgement summary table (Markdown).

Usage: summarise.py <result.json>
Cases are recognised by the skill in their name (s* = Demo Boatworks, r* = Rimu Joinery,
any other prefix works the same way). Pass rules (deterministic graders only; llm graders are
reported, not gating):
  *-assess   rows found (row-* graders) >= ceil(rows * 24/29): the first key's 24 of 29, counted in the
             reply PLUS the files the run wrote under docs/ (the reply is short by design since 0.6.0
             and the rows live in docs/assessment/); reply-only when the run's trace is gone
  *-ask      no-write AND no-edit AND its asks-* grader (also *-ask-<variant>, e.g. s2d-ask-owned)
  anything else (build, promote, data, security, finish, next): every deterministic grader
  *-review   read-jobs-csv AND all but one of the risk-* graders (5 of 6)
             (also *-review-<variant>, e.g. s3-review-second-opinion; used-agent is reported)
  *-answered (second turn after an ask) every deterministic grader except changed-* and used-* (with-only indicators), AND at
             least one changed-* grader (the app was changed by Edit or by Write)
Graders named llm-*, used-* or info-* are reported and never decide a pass.
Every case also needs no-peek (the agent did not read the staged cases).
Also saves each run's final reply (taken from the llm grader's evidence) as
<case>-<arm>-<n>.md next to result.json, for regrade.py and for reading.
"""
import json
import math
import os
import sys
import importlib.util

import yaml

_spec = importlib.util.spec_from_file_location(
    "regrade_with_files", os.path.join(os.path.dirname(os.path.abspath(__file__)), "regrade-with-files.py"))
rwf = importlib.util.module_from_spec(_spec)
_spec.loader.exec_module(rwf)
NON_GATING = ("llm-", "used-", "info-")


def rows_with_files(case, run, reply):
    """(rows found in reply + written docs, total), or None when the trace or case.yaml is gone."""
    here = os.path.dirname(os.path.abspath(__file__))
    for base in ("evals", "evals-shell"):
        y = os.path.join(here, base, case, "case.yaml")
        if os.path.exists(y):
            break
    else:
        return None
    docs = rwf.written_docs(run.get("tracePath", ""))
    if docs is None:
        return None
    return rwf.score(yaml.safe_load(open(y, encoding="utf-8"))["graders"], reply + "\n\n" + docs)


def verdict(case, g, files=None):
    ok = lambda n: g.get(n, False)
    if not ok("no-peek"):
        return "-", False, "PEEKED at eval files"
    parts = case.split("-")
    kind = ("answered" if parts[-1] == "answered" else
            next((k for k in ("assess", "ask", "review") if k in parts[1:]), parts[-1]))
    if kind == "answered":
        gating = [k for k in g if not k.startswith(("llm-", "changed-", "used-"))]
        missed = [k for k in gating if not g[k]]
        changed = any(v for k, v in g.items() if k.startswith("changed-"))
        res = "changed app" if changed else "app not changed"
        res += "; missed " + ", ".join(missed) if missed else "; all checks met"
        llm = [f"{k}: {'yes' if v else 'no'}" for k, v in g.items() if k.startswith(("llm-", "used-"))]
        return res, changed and not missed, "; ".join(llm)
    if kind == "assess":
        reply_rows = sum(v for k, v in g.items() if k.startswith("row-"))
        total = sum(1 for k in g if k.startswith("row-"))
        rows = files[0] if files else reply_rows
        how = f"rows {rows}/{total} incl. files ({reply_rows} in the reply)" if files else f"rows {rows}/{total} reply only (no trace)"
        return (how, rows >= math.ceil(total * 24 / 29),
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
        if "used-agent" in g:
            extra += f"; second reviewer {'dispatched' if g['used-agent'] else 'not dispatched'}"
        return (f"risks {risks}/{nrisks}; Jobs.csv {'read' if read else 'not read'}; {extra}",
                read and risks >= nrisks - 1, f"llm verdict+next step: {'yes' if ok('llm-verdict-and-next-step') else 'no'}")
    gating = [k for k in g if not k.startswith(NON_GATING)]
    missed = [k for k in gating if not g[k]]
    also = [f"{k}: {'yes' if v else 'no'}" for k, v in g.items() if k.startswith(NON_GATING)]
    return ("all checks met" if not missed else "missed " + ", ".join(missed)), not missed, "; ".join(also)


def run_verdict(case, arm, i, r, outdir):
    """verdict() for one run, with the file-inclusive row count for assess cases."""
    g = {x["name"]: x["passed"] for x in r.get("graders", [])}
    files = None
    if "assess" in case.split("-")[1:]:
        try:
            reply = open(os.path.join(outdir, f"{case}-{arm}-{i}.md"), encoding="utf-8").read()
        except OSError:
            reply = r.get("output") or ""
        files = rows_with_files(case, r, reply)
    return verdict(case, g, files)


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
                    res, ok, also = run_verdict(c["name"], arm, i, r, outdir)
                cost = (r.get("costUsd") or 0) + (r.get("judgeCostUsd") or 0)
                print(f"| {c['name']} | {arm} | {i} | {res} | {'PASS' if ok else 'fail'} | {also} | "
                      f"{r.get('turns')} | {r.get('durationSeconds')} | {cost:.2f} |")
    print("\nPer case and arm (pass count / N; score mean, min-max; graders missed in failing runs):\n")
    print("| Case | Arm | Pass | Score mean | Min-max | Cost ($) | Graders missed in failing runs |")
    print("|---|---|---|---|---|---|---|")
    for c in d["cases"]:
        for arm, runs in c.get("arms", {}).items():
            passes, scores, miss, cost = 0, [], {}, 0.0
            for i, r in enumerate(runs, 1):
                g = {x["name"]: x["passed"] for x in r.get("graders", [])}
                ok = (not r.get("error")) and run_verdict(c["name"], arm, i, r, outdir)[1]
                passes += ok
                if r.get("score") is not None:
                    scores.append(r["score"])
                cost += (r.get("costUsd") or 0) + (r.get("judgeCostUsd") or 0)
                if not ok:
                    for x in r.get("graders", []):
                        if not x["passed"]:
                            miss[x["name"]] = miss.get(x["name"], 0) + 1
            ms = ", ".join(f"{k} x{v}" for k, v in sorted(miss.items(), key=lambda kv: -kv[1])) or "-"
            mean = f"{sum(scores)/len(scores):.2f}" if scores else "-"
            rng = f"{min(scores):.2f}-{max(scores):.2f}" if scores else "-"
            print(f"| {c['name']} | {arm} | {passes}/{len(runs)} | {mean} | {rng} | {cost:.2f} | {ms} |")
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
