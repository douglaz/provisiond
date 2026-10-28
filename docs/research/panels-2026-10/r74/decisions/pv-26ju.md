# pv-26ju — held drain bead; original approved brief preserved

Draft reference only. Existing `ready-for-agent` status is recorded in the pinned committed JSONL;
this turn changes neither it nor any dependency. The owner approval recorded in the manager brief
for triage PR #27 is, verbatim, “Approve all (Recommended)”.

**Landing sites:** New WAL-history model/declarations in `tools/formal/`, imported by `tools/formal/Provisiond.lean`, tagged to the existing `STO-7`/`STO-54` owners. Any Markdown rendering/scope pointer belongs at those owners under `ADR-0025`; no new normative policy or checklist identifier.

**Ready to apply as written:** yes, within the existing approved scope below, once its serial
hold/order is released. No replacement policy or extra acceptance criterion is added here.

**Overlap/order:** Apply after pv-c7vg and pv-1i3n, preferably after the checklist edits settle. Use actual commit identities and history prefixes. Equal valid maximal prefixes are compatible with the chosen equality policy; divergent-history and lagging-promotion witnesses remain negative cases. State the trusted configuration/report premises, without assuming the conclusion.

## Existing Agent Brief — verbatim, comment 826

<!-- ORIGINAL_BRIEF_BEGIN -->
~~~markdown
## Agent Brief

**Category:** enhancement

**Current behavior:** The reviewed follow-up explicitly asks to “Prove `BarrierAck ∧ SameHistory ⇒ Replicated`” and retain “counterexamples without `SameHistory` (H-d) and with a lagging promotion (H-e)”. The proof is a requested addition, not evidence already supplied by current green gates.

**Desired behavior / key interfaces:** Add a small WAL-history model and tagged declarations for the existing replication/promotion owners. Represent commit identity/history and flushed prefixes, not comparable positions alone. Prove the stated barrier implication under explicit deployment hypotheses; retain concrete divergent-history and lagging-promotion traces.

**Acceptance criteria:** (1) The implication derives replication from the modeled barrier and history facts; no hypothesis simply assumes the conclusion. (2) Dropping the history requirement admits the named divergent-history counterexample, and choosing a lagging promotion admits loss of an acknowledged commit. (3) State model limits and guard hypotheses; preserve existing proofs, use no `CNF` identifiers in formal sources, and run full unpiped gates.

**Out of scope:** New production mechanisms, changing promotion policy or trusted deployment assumptions, or claiming the model proves PostgreSQL implementation behavior.
~~~
<!-- ORIGINAL_BRIEF_END -->

## Application boundary

Use a fresh master after the live pv-6350 Run has been handled. Check anchors/assumptions against
the landed Panel A changes. Run the required gates unpiped before and after actual edits; a model
proof or document gate is not implementation conformance. Keep raw logs under `/var/tmp` and keep
tracker closure in committed JSONL. A newly discovered behavioral gap goes to the required review
and owner decision; it is not permission to enlarge this bead. No cosmetic follow-up issues.

Source: pinned committed `.beads/issues.jsonl` at `4662d85c7e67c2ebb4c5c8e1c98dc6e1c0efc239`. Preserved brief SHA-256:
`7f28cad2825a1d474e7b998b054f5490109d0ddecb551d7ac35f8b8fd2f1e4e0`.
