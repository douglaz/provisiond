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

It also structurally checks every ```mermaid block: a declared diagram type,
balanced brackets, balanced quotes. Mermaid renders on GitHub but there is no
offline parser here, so a broken diagram would look fine in source and fail in
the browser.

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


MERMAID_RE = re.compile(r"^```mermaid\s*\n(.*?)^```", re.M | re.S)
MERMAID_KINDS = (
    "flowchart", "graph", "sequenceDiagram", "stateDiagram-v2", "stateDiagram",
    "erDiagram", "classDiagram", "journey", "gantt", "pie", "mindmap", "timeline",
)


def check_mermaid():
    """A structural sanity check, not a parser.

    Mermaid renders on GitHub but there is no offline parser here, so a broken
    diagram would ship looking fine in source and fail in the browser. This
    catches the two errors that actually happen: a block that declares no
    diagram type, and unbalanced brackets or quotes in a label.
    """
    problems = 0
    count = 0
    for f in sorted(glob.glob("*.md")) + sorted(glob.glob("docs/adr/*.md")):
        text = open(f).read()
        for m in MERMAID_RE.finditer(text):
            count += 1
            line = text[: m.start()].count("\n") + 1
            body = m.group(1)
            first = next((l.strip() for l in body.splitlines() if l.strip()), "")
            if not first.startswith(MERMAID_KINDS):
                print(f"FAIL {f}:{line}: mermaid block declares no known diagram "
                      f"type (starts {first[:40]!r})")
                problems += 1
            # erDiagram's crow's-foot notation (||--o{, }o--o|) uses braces as
            # syntax rather than as pairs, so brace balance is meaningless there.
            pairs = [("[", "]"), ("(", ")")]
            if not first.startswith("erDiagram"):
                pairs.append(("{", "}"))
            for open_c, close_c in pairs:
                if body.count(open_c) != body.count(close_c):
                    print(f"FAIL {f}:{line}: unbalanced {open_c}{close_c} "
                          f"({body.count(open_c)} vs {body.count(close_c)})")
                    problems += 1
            if body.count('"') % 2:
                print(f"FAIL {f}:{line}: odd number of double quotes")
                problems += 1
    print(f"mermaid diagrams checked: {count} | failures: {problems}")
    return problems


def main():
    os.chdir(ROOT)
    mermaid_failures = check_mermaid()
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
    return 1 if (failures or mermaid_failures) else 0


if __name__ == "__main__":
    sys.exit(main())
