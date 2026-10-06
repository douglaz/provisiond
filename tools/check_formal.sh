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
#
# Publication: stage both successful emitters in private files, then replace each
# canonical file atomically. Identical-source/toolchain producers may overlap;
# this is not a pair snapshot, source-edit lock, Lake build lock or crash-durability
# guarantee. Deletion and differing revisions are outside this contract.
# Direct consumers validate published data, not freshness or the latest standalone
# generation's success. Old complete files survive failure; before first publication
# missing files remain red. For fresh certification, check this script's success:
# bash tools/check_formal.sh && python3 tools/check_citations.py && python3 tools/check_regions.py
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
index_tmp=
regions_tmp=
cleanup() {
  [ -z "$index_tmp" ] || rm -f "$index_tmp"
  [ -z "$regions_tmp" ] || rm -f "$regions_tmp"
}
# Only this invocation's files; SIGKILL cannot run these traps.
trap cleanup EXIT
trap 'exit 129' HUP
trap 'exit 130' INT
trap 'exit 143' TERM

index_tmp=$(mktemp .lake/index.jsonl.XXXXXX) || exit 1
regions_tmp=$(mktemp .lake/regions.jsonl.XXXXXX) || exit 1
lake exe gate > "$index_tmp" || exit "$?"
lake exe render > "$regions_tmp" || exit "$?"
index_count=$(wc -l < "$index_tmp")
regions_count=$(wc -l < "$regions_tmp")
# Check each rename explicitly: this shell deliberately does not use set -e.
mv -f "$index_tmp" .lake/index.jsonl || exit 1
mv -f "$regions_tmp" .lake/regions.jsonl || exit 1
echo "index: $index_count tagged declarations -> tools/formal/.lake/index.jsonl"
echo "regions: $regions_count marked regions -> tools/formal/.lake/regions.jsonl"
