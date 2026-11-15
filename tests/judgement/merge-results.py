#!/usr/bin/env python3
"""Fold a second `claude plugin eval` result into the first, in place.
Usage: merge-results.py <result.json> <other result.json>
run.sh uses it for --shell, where the shell cases are evaluated on their own (see run.sh)."""
import json
import os
import sys


def main():
    main_path, other_path = sys.argv[1], sys.argv[2]
    if not os.path.exists(other_path):
        # Normal when --cases matched nothing on that side; otherwise the gate fails on the missing cases.
        print(f"merge-results: no {other_path}; nothing to merge", file=sys.stderr)
        sys.exit(0 if os.path.exists(main_path) else 1)
    other = json.load(open(other_path))
    if not os.path.exists(main_path):
        json.dump(other, open(main_path, "w"), indent=1)
        return
    d = json.load(open(main_path))
    have = {c["name"] for c in d["cases"]}
    d["cases"] += [c for c in other["cases"] if c["name"] not in have]
    d["cases"].sort(key=lambda c: c["name"])
    d["costUsd"] = (d.get("costUsd") or 0) + (other.get("costUsd") or 0)
    d["durationSeconds"] = (d.get("durationSeconds") or 0) + (other.get("durationSeconds") or 0)
    d["partial"] = bool(d.get("partial") or other.get("partial"))
    json.dump(d, open(main_path, "w"), indent=1)


if __name__ == "__main__":
    main()
