# pv-v4gp — held drain bead; original approved brief preserved

Draft reference only. Existing `ready-for-agent` status is recorded in the pinned committed JSONL;
this turn changes neither it nor any dependency. The owner approval recorded in the manager brief
for triage PR #27 is, verbatim, “Approve all (Recommended)”.

**Landing sites:** Proposed research artifact `docs/research/promotion-durability-audit.md`. Audit targets include `OPS-32`, `API-11`, `API-53`, `API-56`, `LDG-14`, `STO-54`, with the deposit-only boundary at `STO-7`/`API-45`/`WIR-14`/`WIR-15` and rationale at `ADR-0045`. These are read/audit targets, not authorized normative amendment sites.

**Ready to apply as written:** yes, within the existing approved scope below, once its serial
hold/order is released. No replacement policy or extra acceptance criterion is added here.

**Overlap/order:** Apply last, against the settled configuration, admission, report and equality text and the WAL-history proof. Distinguish the accepted unchecked-misconfiguration risk from a conforming trace. Do not claim equal reports authenticate hidden history or that B4* admission observes replication settings. Durable off-primary evidence and conservative classification for unknown history remain candidates requiring a later decision, not adopted duties.

## Existing Agent Brief — verbatim, comment 827

<!-- ORIGINAL_BRIEF_BEGIN -->
~~~markdown
## Agent Brief

**Category:** enhancement

**Current behavior:** `ADR-0045` states the objective “irreversible external consequences must not depend on history a promotion classified as a restart may discard” and immediately says “This is rationale, not an additional requirement.” Its chosen follow-up lists the audit cases.

**Desired behavior / key interfaces:** Produce a reviewable audit record, enumerating externally visible action classes and mapping each to the acknowledgement/history evidence it relies on. Cover the named image/key deletions, replayed revocation, idempotency 409, operation revision, disputed runway effect, and evidence that a waiting backend was cancelled/terminated. For each, give a minimal trace or a justified non-counterexample against current master.

**Acceptance criteria:** (1) The audit covers every named case and explains its action inventory source, rather than asserting completeness from memory. (2) Separate proved losses, disputed hypotheses, deployment misconfiguration, and unaffected cases; preserve the runway dispute until evidence resolves it. (3) Evaluate durable off-primary evidence and conservative-unknown classification as candidates, not adopted rules. Keep raw logs under `/var/tmp`; gate any committed research record.

**Out of scope:** Amending normative policy or adding monitoring/storage duties without the required panel/owner decision; cosmetic follow-up issues.
~~~
<!-- ORIGINAL_BRIEF_END -->

## Application boundary

Use a fresh master after the live pv-6350 Run has been handled. Check anchors/assumptions against
the landed Panel A changes. Run the required gates unpiped before and after actual edits; a model
proof or document gate is not implementation conformance. Keep raw logs under `/var/tmp` and keep
tracker closure in committed JSONL. A newly discovered behavioral gap goes to the required review
and owner decision; it is not permission to enlarge this bead. No cosmetic follow-up issues.

Source: pinned committed `.beads/issues.jsonl` at `4662d85c7e67c2ebb4c5c8e1c98dc6e1c0efc239`. Preserved brief SHA-256:
`7e433db15077cf1caef80f337aec0e9a4b5dcda8ce8d8019ce2521e34d9bf027`.
