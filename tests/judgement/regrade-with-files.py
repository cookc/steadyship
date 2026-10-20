#!/usr/bin/env python3
"""Score each run's regex graders against the reply PLUS the files the run wrote under
docs/ (recovered from the run's trace), for cases whose reply is deliberately short and
points at the written files (assess, since plugin 0.6.0).

Usage: regrade-with-files.py <result.json>
Prints one line per run: "<case> <arm> run <n>: rows <k>/<N> incl. files (<j>/<N> reply only)".
Needs the traces to still exist: run.sh passes --keep-temp and removes the temp dirs
after this script has run.
"""
import json
import re
import sys
import glob
import os

import yaml


def written_docs(trace_path):
    parts = []

    def walk(o):
        if isinstance(o, dict):
            if o.get("name") in ("Write", "Edit") and isinstance(o.get("input"), dict):
                i = o["input"]
                if "/docs/" in str(i.get("file_path", "")):
                    parts.append(i.get("content") or i.get("new_string") or "")
            for v in o.values():
                walk(v)
        elif isinstance(o, list):
            for x in o:
                walk(x)

    try:
        with open(trace_path, encoding="utf-8") as f:
            for line in f:
                try:
                    walk(json.loads(line))
                except ValueError:
                    pass
    except OSError:
        return None
    return "\n\n".join(parts)


def score(graders, text):
    rows = total = 0
    for g in graders:
        if g.get("type") != "regex" or not g["name"].startswith("row-"):
            continue
        total += 1
        flags = re.I if "i" in g.get("flags", "") else 0
        found = re.search(g["pattern"], text, flags) is not None
        if g.get("match", "contains") == "not_contains":
            found = not found
        rows += found
    return rows, total


def main():
    result = json.load(open(sys.argv[1], encoding="utf-8"))
    out_dir = os.path.dirname(os.path.abspath(sys.argv[1]))
    root = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
    for case in result.get("cases", []):
        case_yaml = os.path.join(root, "judgement", case["dir"], "case.yaml")
        if not os.path.exists(case_yaml):
            case_yaml = os.path.join(os.path.dirname(os.path.abspath(__file__)), case["dir"], "case.yaml")
        try:
            graders = yaml.safe_load(open(case_yaml, encoding="utf-8"))["graders"]
        except OSError:
            continue
        for arm, runs in case.get("arms", {}).items():
            for n, run in enumerate(runs, 1):
                reply_files = glob.glob(os.path.join(out_dir, f"{case['name']}-{arm}-{n}.md"))
                reply = open(reply_files[0], encoding="utf-8").read() if reply_files else (run.get("output") or "")
                docs = written_docs(run.get("tracePath", ""))
                if docs is None:
                    print(f"{case['name']} {arm} run {n}: trace not found; reply only")
                    continue
                k, total = score(graders, reply + "\n\n" + docs)
                j, _ = score(graders, reply)
                if total:
                    print(f"{case['name']} {arm} run {n}: rows {k}/{total} incl. files ({j}/{total} reply only)")


if __name__ == "__main__":
    main()
