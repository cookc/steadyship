#!/usr/bin/env python3
"""Re-score saved replies offline with a case's regex graders (no API calls).

Usage: regrade.py <case.yaml> <reply-file>...
A reply file is plain text, or a walkthrough transcript (docs/walkthrough-*/), in
which case only the text under "## Full reply" is scored. Python's `re` is close
enough to JS RegExp for these patterns (lookaheads, fixed-width lookbehinds).
"""
import re
import sys

import yaml


def reply_text(path):
    text = open(path, encoding="utf-8").read()
    m = re.search(r"## Full reply[^\n]*\n+(`{3,})text\n(.*?)\n\1", text, re.S)
    return m.group(2) if m else text


def main():
    case = yaml.safe_load(open(sys.argv[1], encoding="utf-8"))
    graders = [g for g in case["graders"] if g["type"] == "regex"]
    for path in sys.argv[2:]:
        text = reply_text(path)
        hits, rows = [], 0
        for g in graders:
            flags = re.I if "i" in g.get("flags", "") else 0
            found = re.search(g["pattern"], text, flags) is not None
            if g.get("match", "contains") == "not_contains":
                found = not found
            hits.append(("+" if found else "-") + g["name"])
            rows += found and g["name"].startswith("row-")
        nrows = sum(g["name"].startswith("row-") for g in graders)
        print(f"{path}: rows {rows}/{nrows}" if nrows else path)
        for h in hits:
            print("   ", h)


if __name__ == "__main__":
    main()
