# Q2 UO — unknown-permitted coordinator replacement, UNREVIEWED

This replaces U1 as one complete candidate. It keeps the event/history separation and unknown-permitted recovery advocated by fable/opus, and adds explicit conservative-certificate/persistence conditions. It does **not** import opus's false “A commit generated after that time is absent” sentence. It is a new coordinator assembly, not an accepted reader form. All requirement/schema/fixture amendments below are **behaviour changed**. Formal event-clock clarification is documentation of the retained event meaning; no history boundary is assigned to an execution clock.

## STO-54 step (1)

Replace “the lost window `T − Δ` is stated as a number and published to the operator” with:

> the possible-loss report defined below is published to the operator

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
