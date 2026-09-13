#!/usr/bin/env bash
# Run every gate that guards this specification set.
#
# These gates lived in a scratch directory until 2026-08-31, when that directory
# was cleaned by age and they ceased to exist without anyone noticing. They are
# committed here so that the checks guarding the specifications outlive the
# machine that ran them last.
#
# Each gate runs to completion and its exit status is captured directly -- never
# through a pipe, which would report the status of the last command in the
# pipeline rather than the gate's own.
#
# Exit status 0 = every gate passed.

set -uo pipefail

cd "$(dirname "$0")/.." || exit 2

declare -a NAMES=()
declare -a CODES=()
overall=0

run() {
  local name="$1"; shift
  echo
  echo "=============================================================="
  echo "  $name"
  echo "=============================================================="
  "$@"
  local rc=$?
  NAMES+=("$name")
  CODES+=("$rc")
  [ "$rc" -ne 0 ] && overall=1
  return 0
}

run "identifiers  (append-only, dangling, gaps, ADR refs)" python3 tools/check_ids.py
run "fixtures     (WIR-37 JSON, WIR-1a, mermaid structure)" python3 tools/check_fixtures.py
run "obligations  (a duty assigned to another requirement)" python3 tools/check_obligations.py
run "coverage     (requirements exercised by CNF items)"   python3 tools/check_coverage.py
run "citations    (a claim about what another requirement says)" python3 tools/check_citations.py
run "formal       (Lean build, axiom policy, @[req] index)" bash tools/check_formal.sh

echo
echo "=============================================================="
echo "  SUMMARY"
echo "=============================================================="
for i in "${!NAMES[@]}"; do
  if [ "${CODES[$i]}" -eq 0 ]; then status="PASS"; else status="FAIL"; fi
  printf '  %-4s  %s\n' "$status" "${NAMES[$i]}"
done
echo

if [ "$overall" -eq 0 ]; then
  echo "All gates passed."
else
  echo "One or more gates FAILED."
fi
exit "$overall"
