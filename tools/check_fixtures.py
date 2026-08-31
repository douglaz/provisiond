#!/usr/bin/env python3
"""Fixture gate -- enforces WIR-37 and WIR-1a on every JSON example in the set.

WIR-37 says the examples are test inputs rather than illustrations:

    "Fixtures are complete and valid (CNF-176): every JSON example in this
     document parses under WIR-1a with real-shaped values -- full UUIDs,
     Z-suffixed timestamps, 64-hex digests -- so the examples are test inputs,
     not illustrations. Placeholder `...` inside an object is prohibited; where
     a sub-object is elided the example says so in prose outside the JSON."

WIR-1a fixes the JSON profile as I-JSON with bounded numbers:

    "A body MUST reject a duplicate object member at any depth (not last-wins),
     MUST be valid UTF-8, and every JSON number MUST be an integer within
     +/-(2^53-1) with no exponent or fraction."

So this gate checks, for every fenced ```json block in the set:

  * it parses
  * it contains no duplicate object member at any depth
  * every number is an integer within +/-(2^53-1)
  * it contains no `...` placeholder
  * timestamps that look like RFC 3339 end in Z, never +00:00 (WIR-1)
  * sha256 fields are exactly 64 hex characters (DOM-14)

A fixture that fails here is a fixture an implementation cannot use, which is
the failure WIR-37 exists to prevent.

Exit status 0 = clean, 1 = failures.
"""

import glob
import json
import os
import re
import sys

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
MAX_INT = 2 ** 53 - 1

FENCE_RE = re.compile(r"^```json\s*\n(.*?)^```", re.M | re.S)
TS_RE = re.compile(r"^\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}(?:\.\d+)?(Z|[+-]\d{2}:\d{2})$")


def no_duplicate_keys(pairs):
    seen = {}
    for k, v in pairs:
        if k in seen:
            raise ValueError(f"duplicate object member {k!r}")
        seen[k] = v
    return seen


def walk(node, path, problems):
    if isinstance(node, dict):
        for k, v in node.items():
            walk(v, f"{path}.{k}", problems)
    elif isinstance(node, list):
        for i, v in enumerate(node):
            walk(v, f"{path}[{i}]", problems)
    elif isinstance(node, bool):
        pass
    elif isinstance(node, int):
        if abs(node) > MAX_INT:
            problems.append(f"{path}: integer {node} exceeds 2^53-1 (WIR-1a)")
    elif isinstance(node, float):
        problems.append(f"{path}: non-integer number {node} (WIR-1a)")
    elif isinstance(node, str):
        m = TS_RE.match(node)
        if m and m.group(1) != "Z":
            problems.append(f"{path}: timestamp {node!r} must end in Z (WIR-1)")
        if path.endswith(".sha256") and not re.fullmatch(r"[0-9a-fA-F]{64}", node):
            problems.append(f"{path}: sha256 must be exactly 64 hex chars (DOM-14)")


def main():
    os.chdir(ROOT)
    failures = 0
    blocks = 0

    for f in sorted(glob.glob("*.md")) + sorted(glob.glob("docs/adr/*.md")):
        text = open(f).read()
        for i, m in enumerate(FENCE_RE.finditer(text), 1):
            blocks += 1
            body = m.group(1)
            line = text[: m.start()].count("\n") + 1
            where = f"{f}:{line} (json block {i})"

            if "..." in body:
                print(f"FAIL {where}: contains a `...` placeholder (WIR-37)")
                failures += 1
                continue

            try:
                doc = json.loads(body, object_pairs_hook=no_duplicate_keys)
            except ValueError as e:
                print(f"FAIL {where}: {e}")
                failures += 1
                continue

            problems = []
            walk(doc, "$", problems)
            for p in problems:
                print(f"FAIL {where}: {p}")
            failures += len(problems)

    print(f"json fixtures checked: {blocks} | failures: {failures}")
    return 1 if failures else 0


if __name__ == "__main__":
    sys.exit(main())
