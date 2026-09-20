#!/usr/bin/env bash
# The formal layer's gate (ADR-0025): build every Lean module, then run `lake exe gate`,
# which refuses any @[req] declaration whose proof depends on an axiom outside
# propext / Classical.choice / Quot.sound -- so `sorry`, a project `axiom` and
# `native_decide` are all red -- and refuses an empty index. Then `lake exe render`
# writes the marked regions; the citations and regions gates read what this script
# writes, so check-all.sh runs it first.
#
# Also refuses a module under Provisiond/ that Provisiond.lean does not import:
# a proof file the build never reads is DEF-16's green check with a .lean suffix; and a
# conformance identifier anywhere under tools/formal/, which ADR-0025 forbids.
#
# Needs `lake` and `lean` on PATH: run under `nix develop` (flake.nix). A missing
# toolchain is a failure, not a skip.
set -uo pipefail
cd "$(dirname "$0")/formal" || exit 2

if ! command -v lake >/dev/null 2>&1; then
  echo "FAIL: lake not on PATH -- run under 'nix develop' (see flake.nix)"
  exit 1
fi

for f in Provisiond/*.lean; do
  m="Provisiond.$(basename "$f" .lean)"
  if ! grep -q "^import $m\$" Provisiond.lean; then
    echo "FAIL: $f exists but Provisiond.lean does not import $m -- the build never reads it"
    exit 1
  fi
done

# ADR-0025: "a `CNF` identifier does not appear in `tools/formal/`", and AGENTS.md says the same.
# A proof is about the model under its stated hypotheses; a conformance item is about a running
# implementation. A conformance citation here is how a green build comes to read as a passed test.
# Every file under the directory, not just the .lean ones, because that is what both sentences say.
# AGENTS.md's "Quote the sentence" meets this rule here: where a requirement's own words carry a
# conformance identifier, elide it in the quote rather than reproducing it.
hits=$(grep -rn --exclude-dir=.lake -E 'CNF-[0-9]' . || true)
if [ -n "$hits" ]; then
  echo "FAIL: a conformance identifier appears in the formal layer (ADR-0025):"
  echo "$hits"
  exit 1
fi

lake build || exit 1
lake exe gate > .lake/index.jsonl
rc=$?
echo "index: $(wc -l < .lake/index.jsonl) tagged declarations -> tools/formal/.lake/index.jsonl"
[ "$rc" -eq 0 ] || exit "$rc"
# The marked regions (check_regions.py reads these; a render that fails is a red gate).
lake exe render > .lake/regions.jsonl || exit 1
echo "regions: $(wc -l < .lake/regions.jsonl) marked regions -> tools/formal/.lake/regions.jsonl"
