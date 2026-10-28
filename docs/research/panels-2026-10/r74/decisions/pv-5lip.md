# pv-5lip — held drain bead; original approved brief preserved

Draft reference only. Existing `ready-for-agent` status is recorded in the pinned committed JSONL;
this turn changes neither it nor any dependency. The owner approval recorded in the manager brief
for triage PR #27 is, verbatim, “Approve all (Recommended)”.

**Landing sites:** `CNF-365` in `10-conformance-checklist.md`; `STO-54` is the unchanged normative owner.

**Ready to apply as written:** yes, within the existing approved scope below, once its serial
hold/order is released. No replacement policy or extra acceptance criterion is added here.

**Overlap/order:** Apply after pv-1i3n, preserving both its equality controls and pv-3jw6's restore-report arm. The original other-timeline control is still the target. This strengthens an existing operator-only verdict; it does not change promotion eligibility.

## Existing Agent Brief — verbatim, comment 828

<!-- ORIGINAL_BRIEF_BEGIN -->
~~~markdown
## Agent Brief

**Category:** bug

**Current behavior:** `STO-54` says “Only an operator starts a promotion that is a restore”; `CNF-365`'s other-timeline case only asserts “promotes neither as a restart”.

**Desired behavior / key interfaces:** Strengthen the other-timeline case in `CNF-365` to assert that automatic failover promotes neither standby at all, including as a restore, while no operator has decided. Keep operator-directed restore available and retain the unreachable-standby case.

**Acceptance criteria:** (1) A procedure automatically promoting as a restore fails this case. (2) The assertion is tied to `STO-54`'s existing operator-only rule and does not forbid an operator's later restore decision. (3) Keep the remaining promotion drills and run unpiped gates.

**Out of scope:** Changing promotion classification, the tied-position case (`pv-1i3n`), or the operator's recovery procedure.
~~~
<!-- ORIGINAL_BRIEF_END -->

## Application boundary

Use a fresh master after the live pv-6350 Run has been handled. Check anchors/assumptions against
the landed Panel A changes. Run the required gates unpiped before and after actual edits; a model
proof or document gate is not implementation conformance. Keep raw logs under `/var/tmp` and keep
tracker closure in committed JSONL. A newly discovered behavioral gap goes to the required review
and owner decision; it is not permission to enlarge this bead. No cosmetic follow-up issues.

Source: pinned committed `.beads/issues.jsonl` at `4662d85c7e67c2ebb4c5c8e1c98dc6e1c0efc239`. Preserved brief SHA-256:
`5ddba6808bcf090b80950ceb69f6a98c8d91159b53e46cf4447a784c9e751678`.
