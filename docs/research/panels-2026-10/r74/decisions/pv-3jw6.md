# pv-3jw6 — proposed ready-for-agent brief

Draft only. This file has not been posted and changes no tracker state. The body between the
Agent Brief markers is the proposed bead comment. Local provenance stays outside that comment.

<!-- AGENT_BRIEF_BEGIN -->
## Agent Brief

**Category:** bug. **Readiness:** ready to apply this approved package as written, after the
ordinary fresh-master anchor check and the live-Run hold.

**Owner answer, verbatim (2026-10-28):**

> Report unknown (UO) (Recommended)

**Option shown to the owner, verbatim:**

> Panel pick, 4–0 accepted as written. Record the window when it's proven; otherwise record "unknown" with the reason and let recovery proceed. Becomes ready-for-agent and the drain lane lands it.

**Problem and desired behavior:** Give restore incident creation an event clock and a separate,
honest possible-loss report. Implement UO, including its nullable endpoints and evidence/reason
reference, with the verified `defined below` → `defined above` repair only.

**Landing sites:** `STO-54`, `STO-56` in `05-persistence.md`; `OVR-19` in `00-overview.md`;
`CNF-295` and `CNF-365`, plus the fixture/schema companions named in the package, in
`10-conformance-checklist.md`. The named existing companions are `CNF-29`, `CNF-99`, `CNF-218`,
`CNF-271`, `CNF-297`, `CNF-302`, `CNF-308`, `CNF-358`, `CNF-370`; the package itself makes the
complete-checklist audit authoritative over this starting list. Synchronize the event-clock
documentation in `tools/formal/Provisiond/Restore.lean`; the retained assignments are
`RestoreTrace.store`, `afterCrash`, `bootRestore`, with `step_three_writes_grace` kept independent.
After the rule edits, append the decision/pointers to the existing restore record `ADR-0023`;
retain `ADR-0047`'s stopped-system ordering. No new requirement/checklist identifier is needed.

**Exact reviewed package to execute** (the fenced text is an edit instruction, not a new
normative copy to paste wholesale into one requirement):

<!-- REVIEWED_TEXT_BEGIN -->
~~~markdown
## STO-54 step (1)

Replace “the lost window `T − Δ` is stated as a number and published to the operator” with:

> the possible-loss report defined above is published to the operator

Insert immediately after the acknowledged-record-before-start procedure introduction, before step (1):

> For backup restore and restore-class promotion, restore_instant is transaction_timestamp() of the newly begun transaction inserting this incident. This is the event time of incident creation, not the time of the recovered history. The transaction begins after the existing stopping/fencing requirements are satisfied. Its timestamp's exact SQL definition is new; it is not claimed as a fact already proved by the formal model.
>
> The report separates that event from the history that survived. Persist a nullable conservative lower bound b, a nullable upper bound f, and their incident-keyed evidence references when the incident is inserted. A non-null b MUST certify that every source-history component commit acknowledged before b belongs to recovered committed history. A non-null f MUST certify that no component acknowledged an old-history commit after f. Known b and f MUST be finite and satisfy b≤f. A bound without valid evidence is unknown, not an invented recovery time. Inconsistent endpoint evidence is invalid; report the error and unknown bounds rather than an apparent finite interval.
>
> The last replayed commit-or-abort record's timestamp s can supply b=s−e only with evidence that e bounds the source clock's error, the timestamp was generated before insertion, and the recovered continuous prefix on matching ancestry contains that complete record. Capture the observation before restart can erase it, or identify the complete record in retained WAL. The earlier-acknowledgement implication is the certificate: this timestamp is neither an exact snapshot time nor proof that all later-timestamped transactions are absent. A bare LSN, filename or backup START TIME supplies no such certificate. An earlier operator-supplied bound needs the same inclusion proof.
>
> A verified upper error bound on the incident transaction's event clock, with retained stopping/fencing evidence that no old-history acknowledgement follows that transaction's start, can supply f=restore_instant+e_event. Source and event clocks may have different error bounds; record their provenance. If either endpoint cannot be certified, persist null for it and say that endpoint is unknown. The event timestamp alone never substitutes for a missing history bound. Retain evidence outside the lost failure domain or with the incident so that continuation does not depend on the failed primary.
>
> Publish possible loss within [b,f] and its bounding duration only when both endpoints are known. Include b because the lower certificate guarantees commits acknowledged strictly before b. Otherwise publish each known bound, identify every unknown endpoint and state that no finite duration is established; identify clock/provenance assumptions for known bounds. Missing reporting evidence does not hold incident creation, the existing restore procedure or component startup once its existing prerequisites are satisfied. Continuations reuse the persisted endpoints and evidence unchanged. Backup restores use the same contract.

At 05:1656 replace “the report naming `T − Δ` is what tells the operator the clock moved” with:

> the possible-loss report identifies uncertainty in that history clock

No change to the stopped-components ordering, acknowledged incident record, quarantine, credential bump, derivation skip, grace anchor, continuation or close rules is proposed.

## STO-56

Add nullable `lost_window_starts_at`=b and `loss_end_at`=f, with their meanings owned by STO-54. Add an incident-keyed `history_evidence_ref` identifying the retained evidence/unknown-endpoint reason; the reference is non-null even when both bounds are unknown. Existing non-null `restore_instant` remains the event timestamp defined by STO-54. Endpoints/references are written with the row and continuations do not recompute them. No allocation-evidence admission gate is added.

## OVR-19

Add human STO-54-owned rows for source/event clock-error evidence and the endpoint capture, validation and retention procedure. A missing clock certificate produces an unknown endpoint under STO-54, not an automatic startup hold. No unvalidated finite error value may be silently assumed.

## Formal synchronization

Clarify the record/module documentation that restoreInstant/t.now abstracts the newly defined incident transaction event time. Retain the event assignments in RestoreTrace.store, afterCrash and bootRestore and the existing independent completeProcedure instant used by step_three_writes_grace. Interval/certificate publication remains outside this model's scope. Do not change a declaration to assign b or f to now, and do not claim compilation proves the certificate protocol.

## CNF-295

Replace “the operator report names `T − Δ`” with:

> the operator report names the persisted conservative possible-loss bounds and bounding duration where both are known, and explicitly identifies unknown endpoints otherwise

Append within the item:

> Exercise known evidence with the old primary unavailable; a last-abort record; null replay observation; unavailable source/event clock bounds; timestamp/WAL-order inversion; wrong ancestry; WAL holes; backup restore; and interruptions before and after step marks. Invalid evidence is never labelled a certified bound. For absent or invalid reporting evidence, insert a record with unknown endpoint fields and complete the existing procedure; assert no extra reporting-evidence hold. Existing consistency, stopping/fencing, acknowledged-record-before-start and all other recovery prerequisites still apply. Re-enter the incident and assert endpoints/references unchanged. Complete step (3) much later and assert its grace uses its own event, not b, f or restore_instant.

## CNF-365

Append within the item:

> Promote a lagging standby as an operator restore with verified prefix/clock evidence and assert the incident stores certified bounds. Repeat with an idle restarted standby that has replayed no transaction record and no retained fallback proof: assert unknown history bound and an explicit nonnumeric report, followed by the existing restore procedure. Repeat with no verified event-clock bound and assert an unknown upper bound. Do not use a restart time or a backup name to fill an unknown history bound.

## Existing restore and seed fixtures

For actual-restore success arms of CNF-99/295/297/302/358/370 and the new CNF-365 arm, provide either certified evidence for any asserted known bound or an explicit unknown-endpoint incident. Do the same for seeded incident rows in CNF-29/99/218/271/308. This changes fixture/schema setup, not their other outcomes. These named items are an audit starting set; review the complete checklist for omissions rather than assuming the list exhaustive. No fresh evidence requirement is added to a restart without an open incident.

## Scope/cost

Existing no-reissue remains: deposits.derivation_index says “Allocated strictly increasing and never re-issued”; CNF-297 says “exceeds every index a rolled-back row held”. This proposal neither proves the configured gap sufficient nor adds U4's allocation gate. That pre-existing concern is separate. Owner costs are nullable endpoint schema, evidence/unknown-reason retention, clock/capture discipline and accepting an unknown report; reporting evidence alone causes no extra outage. Compare against finite-only U2R as a distinct admission policy, not two accepted versions of one U.
~~~
<!-- REVIEWED_TEXT_END -->

**Disclosed obligations:** Supply nullable schema support and a retained incident-keyed evidence
or unknown-reason reference. Finite bounds need valid prefix/ancestry and clock evidence;
unavailable or invalid evidence produces unknown endpoints. Capture and retain that evidence
outside the failure domain or with the incident; keep continuation values fixed. Reporting
uncertainty is an accepted operator outcome. The derivation-index no-reissue obligation remains
independent; this package supplies no proof that a configured skip is adequate.

**Acceptance:** Check the schema, report, event-clock documentation, continuation and checklist
companions against the complete package. Exercise its known/unknown/invalid evidence and
interruption cases as specified requirements for a future implementation; this repository does
not implement the system. Preserve the existing restore prerequisites and the separate step-(3)
grace event. Do not import finite-only F/U2R or the U4 allocation gate.

**Execution and completion:** Before applying, verify every replacement anchor against freshly
pulled master and the quoted decision against its decision record. Preserve the exact approved
package; report a substantive conflict instead of resolving it by an unreviewed synthesis.
Run `nix develop --command bash tools/check-all.sh` unpiped before and after the actual change.
Land the requirements and checklist edits before writing their amendment/decision record. Keep
arguments with their requirement owners and use pointers elsewhere. Change a formal declaration
only when its actual meaning changes; preserve theorems and keep checklist identifiers out of
formal sources. Close this bead through the tracker only after verification, flush its record,
and verify closure in committed JSONL. Add no attribution disclaimer or coauthor trailers.
<!-- AGENT_BRIEF_END -->

## Local provenance — do not post to the tracker

Decision source: `/var/tmp/provisiond-manager/owner-decisions-1028-panelA.md`. Review base: `4662d85c7e67c2ebb4c5c8e1c98dc6e1c0efc239`.
`r76/tally.md` Q2 counts fable/opus/astra/sol ACCEPT. The claim audit verifies only the
direction-word repair. Historical candidate preamble/review solicitation is omitted; every
operative section beginning `## STO-54 step (1)` is copied verbatim apart from that one repair.
Original candidate SHA-256: `5af83d294b8bb37621dc02a77239b8286911ccf096b9c2419e5224d2be8b83de`. Executable package SHA-256: `7706d6c085ecffe21484e23fdf53c68850135de27764ce02b66f22d22b90541f`.
Decision-record state supersedes STATE.md's historical owner-pending status.

This turn authorizes drafts only. No Run, tracker mutation, source application, branch operation
or PR follows from this file. Live pv-6350 must leave the checkout before any later drain starts.
