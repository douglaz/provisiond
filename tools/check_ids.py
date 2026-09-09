#!/usr/bin/env python3
"""Requirement-identifier gate.

Enforces the README's append-only convention mechanically:

  * every requirement id is defined exactly once      (duplicate ids)
  * every cited id is defined somewhere               (dangling citations)
  * no id is missing from a namespace's sequence      (renumbering / gaps)
  * every cited ADR exists on disk                    (bad ADR references)
  * every conformance item carries an inline tier     (untiered items)
  * no withdrawn, merged or split CNF id has a checkbox (retired but tickable)

Identifiers are append-only. Deleting a requirement is permitted -- the gap in
the sequence IS the tombstone -- so a withdrawn id may be absent, but it must be
listed in the README's withdrawn-identifier index, which this gate checks.

Run from anywhere; it locates the repository root from its own path.
Exit status 0 = clean, 1 = failures.
"""

import collections
import glob
import os
import re
import sys

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))

NAMESPACES = [
    "OVR", "DOM", "PRV", "OPS", "API", "STO",
    "RSC", "SEC", "DEF", "CNF", "LDG", "WIR",
]
NS = "|".join(NAMESPACES)

# A requirement is *defined* in one of three shapes the set actually uses:
#   **API-7** ...                 (most namespaces)
#   - [ ] **CNF-1** ...           (conformance items)
#   ### DEF-1 - ...               (defect prohibitions, as headings)
DEF_RE = re.compile(
    r"^(?:[-*]\s+(?:\[[ x]\]\s+)?)?\*\*((?:%s)-\d+[a-z]?)\*\*"
    r"|^#{1,6}\s+\**((?:%s)-\d+[a-z]?)\**" % (NS, NS),
    re.M,
)
CITE_RE = re.compile(r"`((?:%s)-\d+[a-z]?)`" % NS)
ADR_RE = re.compile(r"`?ADR-(\d{4})`?")
WITHDRAWN_RE = re.compile(r"^\|\s*`?((?:%s)-\d+[a-z]?)`?\s*\|" % NS, re.M)

# A conformance item carries its tier inline, right after the id; a retired
# id (withdrawn, merged, split) is a marker bullet with no checkbox.
ITEM_RE = re.compile(
    r"^- \[[ x]\] \*\*(CNF-\d+[a-z]?)\*\*(?: \*\*(BLOCKING|PRE-SCALE|DEFERRED)\*\*)?"
)
MARKER_RE = re.compile(r"^- \*\*CNF-\d+[a-z]?\*\*")
RETIRED_RE = re.compile(r"\*\*(WITHDRAWN|MERGED INTO|SPLIT)\b")


def docs():
    os.chdir(ROOT)
    return sorted(glob.glob("*.md")), sorted(glob.glob("docs/adr/*.md"))


def main():
    root_md, adr_md = docs()

    defined, dupes = {}, []
    for f in root_md:
        for m in DEF_RE.finditer(open(f).read()):
            rid = m.group(1) or m.group(2)
            if rid in defined:
                dupes.append((rid, defined[rid], f))
            else:
                defined[rid] = f

    cited = set()
    for f in root_md + adr_md:
        cited.update(m.group(1) for m in CITE_RE.finditer(open(f).read()))

    # An id may be cited after deletion only if the README records it as
    # withdrawn. That index is what keeps an old citation resolvable once the
    # text is gone (the gap in the sequence is the tombstone, not a paragraph).
    withdrawn = set()
    if os.path.exists("README.md"):
        readme = open("README.md").read()
        idx = readme.find("Withdrawn identifiers")
        if idx != -1:
            withdrawn = {m.group(1) for m in WITHDRAWN_RE.finditer(readme[idx:])}

    dangling = sorted(c for c in cited if c not in defined and c not in withdrawn)

    # A single mistyped identifier (**API-9999**) would otherwise make every
    # integer below it "missing" and bury the real finding under 20KB of noise.
    # An id far above its neighbours is itself the anomaly, so report it as one
    # and compute gaps against the rest.
    gaps, outliers = {}, {}
    for ns in NAMESPACES:
        nums = sorted(
            int(re.match(r"[A-Z]+-(\d+)", k).group(1))
            for k in defined
            if k.startswith(ns + "-")
        )
        if not nums:
            continue
        body = nums
        while len(body) > 1 and body[-1] - body[-2] > 50:
            outliers.setdefault(ns, []).append(body[-1])
            body = body[:-1]
        missing = [
            n for n in range(1, max(body) + 1)
            if n not in body and f"{ns}-{n}" not in withdrawn
        ]
        if missing:
            gaps[ns] = missing if len(missing) <= 20 else (
                missing[:20] + [f"... and {len(missing) - 20} more"]
            )

    # The blocking count is the line printed below and lives nowhere in prose;
    # the checklist's own section records being wrong twice with a figure kept
    # by hand. Anything but a tier word in the tag position is untiered, not a
    # bad tier -- a headline or an AMENDED marker there is the item missing its
    # tag. A checkbox on a retired id is a withdrawn item that came back tickable.
    tiers, untiered, retired, markers = collections.Counter(), [], [], 0
    for line in open("10-conformance-checklist.md"):
        m = ITEM_RE.match(line)
        if m:
            if m.group(2):
                tiers[m.group(2)] += 1
            else:
                untiered.append(m.group(1))
            if m.group(1) in withdrawn or RETIRED_RE.search(line):
                retired.append(m.group(1))
        elif MARKER_RE.match(line):
            markers += 1

    adrs = {os.path.basename(p)[:4] for p in adr_md}
    bad_adrs = set()
    for f in root_md + adr_md:
        for m in ADR_RE.finditer(open(f).read()):
            if m.group(1) not in adrs:
                bad_adrs.add(m.group(1))

    print(f"requirements: {len(defined)} | md files: {len(root_md)} | ADRs: {len(adrs)}")
    print(f"withdrawn ids indexed: {len(withdrawn)}")
    print("DUPES:", dupes or "none")
    print("DANGLING:", dangling or "none")
    print("NUMBER GAPS:", gaps or "none")
    print("OUTLIER IDS:", outliers or "none")
    print("BAD ADR REFS:", sorted(bad_adrs) or "none")
    print(f"conformance items: {sum(tiers.values()) + len(untiered)} "
          f"| BLOCKING {tiers['BLOCKING']} | PRE-SCALE {tiers['PRE-SCALE']} "
          f"| DEFERRED {tiers['DEFERRED']} | markers {markers}")
    print("UNTIERED:", untiered or "none")
    print("RETIRED BUT TICKABLE:", retired or "none")

    return 1 if (dupes or dangling or gaps or outliers or bad_adrs
                 or untiered or retired) else 0


if __name__ == "__main__":
    sys.exit(main())
