#!/usr/bin/env bash
# The formal layer's gate (ADR-0025): build every Lean module, then run `lake exe gate`,
# which refuses any @[req] declaration whose proof depends on an axiom outside
# propext / Classical.choice / Quot.sound -- so `sorry`, a project `axiom` and
# `native_decide` are all red -- and refuses an empty index. Then `lake exe render`
# writes the marked regions; the citations and regions gates read what this script
# writes, so check-all.sh runs it first.
#
# Also refuses a module under Provisiond/ that Provisiond.lean does not import:
# a proof file the build never reads is DEF-16's green check with a .lean suffix.
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

lake build || exit 1
lake exe gate > .lake/index.jsonl
rc=$?
echo "index: $(wc -l < .lake/index.jsonl) tagged declarations -> tools/formal/.lake/index.jsonl"
[ "$rc" -eq 0 ] || exit "$rc"
# The marked regions (check_regions.py reads these; a render that fails is a red gate).
lake exe render > .lake/regions.jsonl || exit 1
echo "regions: $(wc -l < .lake/regions.jsonl) marked regions -> tools/formal/.lake/regions.jsonl"
