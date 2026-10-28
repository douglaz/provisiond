# r79 — Panel D0: pv-3jw6 source timestamp error bound

**LAUNCH AUTHORIZED BY MAIN, 2026-10-28.** This packet is unreviewed. Main authorizes this five-reader round only: no adoption, tracker mutation, implementation Run, next round or PR action follows.

Review pin: **3c214c147021a90d4ba5a74269b8bd4adc389670**. PR #31 was OPEN when pinned, so this is its supplied head `3c214c1`, rather than origin/master; receipt: check/pin.json. Read this brief and /var/tmp/provisiond-panel-r79/notes.md whole. Each reader has an independent detached clone of this pin. Resolve panel artifacts under /var/tmp/provisiond-panel-r79/, not under your clone. The main checkout is occupied by the drain: never inspect/mutate it, its branches or shared tracker. Leave /var/tmp/provisiond-panel-r78/ and its units alone. Do not run br, commit, push, change branches, contact production or read credential/session/config stores including ~/.grok, ~/.claude or ~/.codex. Work only in your own clone and your own ../<reader>.draft.md. No delegation or background work. Every unit uses MemoryMax=16G, MemorySwapMax=0, OOMPolicy=continue and timeout 3600. Save a substantive draft by minute 45; return a final answer in this turn, about 1300 words plus exact repairs/evidence.

Five seats: fable claude-fable-5-1 xhigh; opus claude-opus-5-5 xhigh; astra gpt-6-astra high; sol gpt-6.1-sol xhigh; grok grok-4.7 xhigh. Give ACCEPT / AMEND / CANNOT ACCEPT on every whole candidate, then one explicit preference among acceptable candidates or NONE. Exact location, before/replacement and changed/unchanged behaviour are required for AMEND. A direction vote is not package acceptance. Report requested counterarguments separately from votes.

**apply notes.md rule 6 exactly as written; this prompt adds no void rule.** Do not prejudge whether the error-bound edit changes behaviour: that classification is part of this question. A newly introduced runtime hold, admissible-input restriction, conformance assertion or proof hypothesis is behavioural and must be disclosed. A clarification of an already required certificate may instead be a wording repair; prove that claim from quoted text rather than its label. No synthesized repair becomes reviewed merely because one reader proposes it.

## Q1 — Does the application need total timestamp error, and is that within the owner's UO decision?

Plain terms: the clock can be right while a stored time is rounded ahead. A recovered log prefix then ends before a later acknowledged write, yet the rounded time can make that write look as if it must have survived. Should the already-approved unknown-permitted report explicitly include that rounding in its error allowance? Does doing so spell out the promised certificate, or add behaviour the owner must choose?

The owner already chose UO. Do not reopen finite-only recovery, add an evidence-caused startup hold, change promotion eligibility, or rewrite the archived r74–r77 records. The finding is review data, not authority to amend a record. This panel reviews the prospective application to the bead. Recommendations must rest on an exact form reviewed whole.

### Checked evidence and limits

The read-only bead source is `.beads/issues.jsonl:10` at the pin, id `pv-3jw6`, comment `835`. `check/pv-3jw6.json` is its decoded record. Its complete Agent Brief was compared byte-for-byte after surrounding whitespace with the committed application brief quoted below. The executable package matches UO's operative sections with only the approved “defined below” → “defined above” substitution; check/source-verification.json records this. The landing-site list belongs to that brief, not a new list invented here.

A repository search for source timestamp, clock error, precision, quantization and rounding is retained in check/timestamp-search.json. Manager finding: no explicit definition making e include timestamp precision/rounding, or requiring non-upward rounding of this source timestamp, was found in the adopted package or normative definitions. The exact application still has the clock-error sentence below. There IS an overarching certificate obligation and there ARE precision-aware prior reader explanations, quoted below. Those are the strongest case that a repair only makes an existing duty explicit. A clock-only computation is not thereby compliant with the full package. Review this distinction; do not misreport the finding as permission to publish a false certificate.

Finding: https://github.com/douglaz/provisiond/pull/31#discussion_r4401037001, on docs/research/panels-2026-10/r74/r76/q2-UO.md:17–19 at this pin. The suggested local replacement is E-TOTAL below. The archived record stays verbatim. No source change or database measurement has been made.

### Owner decision and exact application authority

**docs/research/panels-2026-10/r74/owner-decisions.md:5–10 at `3c214c147021a90d4ba5a74269b8bd4adc389670`:**

>
> 1. **pv-3jw6** — Q: "pv-3jw6: when a promoted restore can't prove how much history survived, what should the
>    restore report do?" A: **"Report unknown (UO) (Recommended)"**. Option text shown: "Panel pick, 4–0 accepted as
>    written. Record the window when it's proven; otherwise record "unknown" with the reason and let recovery
>    proceed. Becomes ready-for-agent and the drain lane lands it."
>    - The reviewed form is UO with opus's verified wording repair ("defined below" → "defined above").

**docs/research/panels-2026-10/r74/decisions/pv-3jw6.md:9–32 at `3c214c147021a90d4ba5a74269b8bd4adc389670`:**

> **Category:** bug. **Readiness:** ready to apply this approved package as written, after the
> ordinary fresh-master anchor check and the live-Run hold.
>
> **Owner answer, verbatim (2026-10-28):**
>
> > Report unknown (UO) (Recommended)
>
> **Option shown to the owner, verbatim:**
>
> > Panel pick, 4–0 accepted as written. Record the window when it's proven; otherwise record "unknown" with the reason and let recovery proceed. Becomes ready-for-agent and the drain lane lands it.
>
> **Problem and desired behavior:** Give restore incident creation an event clock and a separate,
> honest possible-loss report. Implement UO, including its nullable endpoints and evidence/reason
> reference, with the verified `defined below` → `defined above` repair only.
>
> **Landing sites:** `STO-54`, `STO-56` in `05-persistence.md`; `OVR-19` in `00-overview.md`;
> `CNF-295` and `CNF-365`, plus the fixture/schema companions named in the package, in
> `10-conformance-checklist.md`. The named existing companions are `CNF-29`, `CNF-99`, `CNF-218`,
> `CNF-271`, `CNF-297`, `CNF-302`, `CNF-308`, `CNF-358`, `CNF-370`; the package itself makes the
> complete-checklist audit authoritative over this starting list. Synchronize the event-clock
> documentation in `tools/formal/Provisiond/Restore.lean`; the retained assignments are
> `RestoreTrace.store`, `afterCrash`, `bootRestore`, with `step_three_writes_grace` kept independent.
> After the rule edits, append the decision/pointers to the existing restore record `ADR-0023`;
> retain `ADR-0047`'s stopped-system ordering. No new requirement/checklist identifier is needed.

The next excerpt is the **complete operative application package**, already present in bead comment 835. The candidate operations below apply to this package, rather than silently editing the archived record. Its historical line references inside the quotation remain verbatim; the authoritative paths/lines in this brief are the enclosing pin-labelled citations.

**docs/research/panels-2026-10/r74/decisions/pv-3jw6.md:39–97 at `3c214c147021a90d4ba5a74269b8bd4adc389670`:**

> ## STO-54 step (1)
>
> Replace “the lost window `T − Δ` is stated as a number and published to the operator” with:
>
> > the possible-loss report defined above is published to the operator
>
> Insert immediately after the acknowledged-record-before-start procedure introduction, before step (1):
>
> > For backup restore and restore-class promotion, restore_instant is transaction_timestamp() of the newly begun transaction inserting this incident. This is the event time of incident creation, not the time of the recovered history. The transaction begins after the existing stopping/fencing requirements are satisfied. Its timestamp's exact SQL definition is new; it is not claimed as a fact already proved by the formal model.
> >
> > The report separates that event from the history that survived. Persist a nullable conservative lower bound b, a nullable upper bound f, and their incident-keyed evidence references when the incident is inserted. A non-null b MUST certify that every source-history component commit acknowledged before b belongs to recovered committed history. A non-null f MUST certify that no component acknowledged an old-history commit after f. Known b and f MUST be finite and satisfy b≤f. A bound without valid evidence is unknown, not an invented recovery time. Inconsistent endpoint evidence is invalid; report the error and unknown bounds rather than an apparent finite interval.
> >
> > The last replayed commit-or-abort record's timestamp s can supply b=s−e only with evidence that e bounds the source clock's error, the timestamp was generated before insertion, and the recovered continuous prefix on matching ancestry contains that complete record. Capture the observation before restart can erase it, or identify the complete record in retained WAL. The earlier-acknowledgement implication is the certificate: this timestamp is neither an exact snapshot time nor proof that all later-timestamped transactions are absent. A bare LSN, filename or backup START TIME supplies no such certificate. An earlier operator-supplied bound needs the same inclusion proof.
> >
> > A verified upper error bound on the incident transaction's event clock, with retained stopping/fencing evidence that no old-history acknowledgement follows that transaction's start, can supply f=restore_instant+e_event. Source and event clocks may have different error bounds; record their provenance. If either endpoint cannot be certified, persist null for it and say that endpoint is unknown. The event timestamp alone never substitutes for a missing history bound. Retain evidence outside the lost failure domain or with the incident so that continuation does not depend on the failed primary.
> >
> > Publish possible loss within [b,f] and its bounding duration only when both endpoints are known. Include b because the lower certificate guarantees commits acknowledged strictly before b. Otherwise publish each known bound, identify every unknown endpoint and state that no finite duration is established; identify clock/provenance assumptions for known bounds. Missing reporting evidence does not hold incident creation, the existing restore procedure or component startup once its existing prerequisites are satisfied. Continuations reuse the persisted endpoints and evidence unchanged. Backup restores use the same contract.
>
> At 05:1656 replace “the report naming `T − Δ` is what tells the operator the clock moved” with:
>
> > the possible-loss report identifies uncertainty in that history clock
>
> No change to the stopped-components ordering, acknowledged incident record, quarantine, credential bump, derivation skip, grace anchor, continuation or close rules is proposed.
>
> ## STO-56
>
> Add nullable `lost_window_starts_at`=b and `loss_end_at`=f, with their meanings owned by STO-54. Add an incident-keyed `history_evidence_ref` identifying the retained evidence/unknown-endpoint reason; the reference is non-null even when both bounds are unknown. Existing non-null `restore_instant` remains the event timestamp defined by STO-54. Endpoints/references are written with the row and continuations do not recompute them. No allocation-evidence admission gate is added.
>
> ## OVR-19
>
> Add human STO-54-owned rows for source/event clock-error evidence and the endpoint capture, validation and retention procedure. A missing clock certificate produces an unknown endpoint under STO-54, not an automatic startup hold. No unvalidated finite error value may be silently assumed.
>
> ## Formal synchronization
>
> Clarify the record/module documentation that restoreInstant/t.now abstracts the newly defined incident transaction event time. Retain the event assignments in RestoreTrace.store, afterCrash and bootRestore and the existing independent completeProcedure instant used by step_three_writes_grace. Interval/certificate publication remains outside this model's scope. Do not change a declaration to assign b or f to now, and do not claim compilation proves the certificate protocol.
>
> ## CNF-295
>
> Replace “the operator report names `T − Δ`” with:
>
> > the operator report names the persisted conservative possible-loss bounds and bounding duration where both are known, and explicitly identifies unknown endpoints otherwise
>
> Append within the item:
>
> > Exercise known evidence with the old primary unavailable; a last-abort record; null replay observation; unavailable source/event clock bounds; timestamp/WAL-order inversion; wrong ancestry; WAL holes; backup restore; and interruptions before and after step marks. Invalid evidence is never labelled a certified bound. For absent or invalid reporting evidence, insert a record with unknown endpoint fields and complete the existing procedure; assert no extra reporting-evidence hold. Existing consistency, stopping/fencing, acknowledged-record-before-start and all other recovery prerequisites still apply. Re-enter the incident and assert endpoints/references unchanged. Complete step (3) much later and assert its grace uses its own event, not b, f or restore_instant.
>
> ## CNF-365
>
> Append within the item:
>
> > Promote a lagging standby as an operator restore with verified prefix/clock evidence and assert the incident stores certified bounds. Repeat with an idle restarted standby that has replayed no transaction record and no retained fallback proof: assert unknown history bound and an explicit nonnumeric report, followed by the existing restore procedure. Repeat with no verified event-clock bound and assert an unknown upper bound. Do not use a restart time or a backup name to fill an unknown history bound.
>
> ## Existing restore and seed fixtures
>
> For actual-restore success arms of CNF-99/295/297/302/358/370 and the new CNF-365 arm, provide either certified evidence for any asserted known bound or an explicit unknown-endpoint incident. Do the same for seeded incident rows in CNF-29/99/218/271/308. This changes fixture/schema setup, not their other outcomes. These named items are an audit starting set; review the complete checklist for omissions rather than assuming the list exhaustive. No fresh evidence requirement is added to a restart without an open incident.
>
> ## Scope/cost
>
> Existing no-reissue remains: deposits.derivation_index says “Allocated strictly increasing and never re-issued”; CNF-297 says “exceeds every index a rolled-back row held”. This proposal neither proves the configured gap sufficient nor adds U4's allocation gate. That pre-existing concern is separate. Owner costs are nullable endpoint schema, evidence/unknown-reason retention, clock/capture discipline and accepting an unknown report; reporting evidence alone causes no extra outage. Compare against finite-only U2R as a distinct admission policy, not two accepted versions of one U.

**docs/research/panels-2026-10/r74/decisions/pv-3jw6.md:114–122 at `3c214c147021a90d4ba5a74269b8bd4adc389670`:**

> **Execution and completion:** Before applying, verify every replacement anchor against freshly
> pulled master and the quoted decision against its decision record. Preserve the exact approved
> package; report a substantive conflict instead of resolving it by an unreviewed synthesis.
> Run `nix develop --command bash tools/check-all.sh` unpiped before and after the actual change.
> Land the requirements and checklist edits before writing their amendment/decision record. Keep
> arguments with their requirement owners and use pointers elsewhere. Change a formal declaration
> only when its actual meaning changes; preserve theorems and keep checklist identifiers out of
> formal sources. Close this bead through the tracker only after verification, flush its record,
> and verify closure in committed JSONL. Add no attribution disclaimer or coauthor trailers.

### Current requirement owners at the pin

The application changes the following currently numeric report rule and adds its event/history definition there.

**05-persistence.md:1558–1565 at `3c214c147021a90d4ba5a74269b8bd4adc389670`:**

>   promotion that is a restore: an automatic failover promotes only as a restart, and otherwise leaves the store
>   without a primary until both standbys report or an operator decides.
> - **The procedure, in this order.** *Before the restore begins,* the deployment MUST stop every
> engine and `api` process, and MUST start neither component until the transaction that commits
> `STO-56`'s record (below) has been acknowledged (*added 2026-10-24, `ADR-0047`*). (1) *Before
> the startup lock:* the public listener is down;
>   the lost window `T − Δ` is stated as a number and published to the operator; exactly five
>   things are frozen, because starting either component to reconcile starts everything it hosts —

**05-persistence.md:1377–1384 at `3c214c147021a90d4ba5a74269b8bd4adc389670`:**

> **STO-56** **`restore_incidents`** — `id`, `restore_instant`, `steps_completed` (0 to 3),
> `grace_ends_at`, nullable (*added 2026-09-25, `ADR-0028`*), and `closed_at`, nullable. One row per
> restore (`STO-54`), written into the restored or promoted store before either component is started and closed
> by the operator; at most one row may have `closed_at` null, a partial unique index over the table.
> Both components read the open row before anything else they do: it is what says a starting process
> is continuing an incident rather than restarting, and `steps_completed` is what says where to
> resume, so neither fact depends on an operator being at the console when a process dies. *Added
> 2026-09-20 (`ADR-0023`).*

**CONTEXT.md:187–196 at `3c214c147021a90d4ba5a74269b8bd4adc389670`:**

> **Restore**:
> Bringing the store back from a backup, landing at some instant before the failure, or a promotion
> `STO-54` classes as one. A recovery
> incident with a stated procedure (`ADR-0023`), never a **restart**: a restart loses no acknowledged commit and the startup pass settles what was in flight at startup; a restore may lose an interval, and the
> engine brought up on it naïvely performs destructive actions on state the restore rewrote.
> The **restore record** is the row that makes the incident recognizable to a process rather than to
> an operator: open from before either component starts until the operator closes it, carrying the
> restore instant and which of the procedure's steps have completed (`STO-56`, `STO-54` owns what it
> means). *Added 2026-09-20.*
> _Avoid_: restart, recovery (bare — the rescue recovery directory and the recovery credential

**tools/formal/Provisiond/Restore.lean:39–43 at `3c214c147021a90d4ba5a74269b8bd4adc389670`:**

> pass alone; when the record closes, which `STO-56` gives to the operator once the obligations that
> outlive step (3) are discharged — so the record is open throughout this module and every successor
> here is a continuation, and a boot on a closed record is the restart `bootRestart` already is;
> `STO-54`'s step (1) beyond the freeze (the published window,
> the account status and the rate quorum) and step (3) beyond the credential bump and the grace

The following prior explanations discuss precision explicitly. They are evidence of review intent, not a silently imported second normative definition of e.

**docs/research/panels-2026-10/r74/r76/astra.md:74–74 at `3c214c147021a90d4ba5a74269b8bd4adc389670`:**

> `transaction_timestamp()` denotes transaction start; timestamp precision is finite. Error evidence must cover quantization as well as clock error. F guarantees only acknowledgements strictly before `b`, but reports `(b,f]`; its general fallback certificate need not cover equality. UO’s `[b,f]` is correct. [Timestamp semantics](https://www.postgresql.org/docs/18/functions-datetime.html#FUNCTIONS-DATETIME-CURRENT), [precision](https://www.postgresql.org/docs/18/datatype-datetime.html)

**docs/research/panels-2026-10/r74/r76/sol.md:122–122 at `3c214c147021a90d4ba5a74269b8bd4adc389670`:**

> Equality is separate: the certificate covers a<b, not a=b. Finite timestamp precision cannot establish a strict real-time ordering between equal readings. Bounds must account for the actual reported timestamp precision/rounding. UO’s [b,f] is conservative; F’s (b,f] is unsupported when b=f or loss occurs at the excluded boundary.

**docs/research/panels-2026-10/r74/r76/check/tally-claim-audit.md:33–33 at `3c214c147021a90d4ba5a74269b8bd4adc389670`:**

> | Fable: F's open lower endpoint is defensible because actual insertion precedes acknowledgement; opus/astra/sol disagree. | For the *particular* replay construction and a real-time error bound including representation error, the strict insertion-before-ack order can also cover equality. But F's general contract and permitted earlier fallback certify only acknowledgements “before b”. It allows a certificate that proves nothing about a lost acknowledgement at b, yet reports `(b,f]`. Example: all acknowledgements strictly before 10 survived, one at 10 did not, b=10 is a permitted lower certificate. The reported interval excludes that possible loss. [Timestamp precision](https://www.postgresql.org/docs/18/datatype-datetime.html) and [transaction-start semantics](https://www.postgresql.org/docs/18/functions-datetime.html#FUNCTIONS-DATETIME-CURRENT) reinforce the need to include representation/rounding in actual error evidence, but the general fallback counterexample alone is sufficient. UO's `[b,f]` avoids this inference. Fable's equality defence does not rescue all of F. |

### Concrete failure story to check

This is a hypothetical representation allowed by the unqualified clock-error recipe, not a claim that a measured PostgreSQL build rounds to milliseconds. All times below are seconds in the same real-time frame, with a perfect source clock.

1. Replayed record R's timestamp is generated at 10.0004; its representation rounds up to s=10.001. R is inserted at 10.0005.
2. Another component commit C is inserted at 10.0006 and acknowledged at 10.0007, after R. The recovered continuous prefix ends with complete R on matching ancestry; it lacks C.
3. With source-clock error e=0, the recipe gives b=10.001. C was acknowledged strictly before b and is missing. Generation-before-insertion and recovered-prefix conditions both hold, but the candidate b fails UO's general certificate.
4. A verified total allowance of at least 0.0006, or the conservative separate upward-representation allowance q=0.001, instead puts b at or before R's generation. If that allowance is not evidenced, UO's existing unknown-endpoint path applies. No extra startup hold follows.

`check/counterexample.json` verifies the inequalities with exact rational arithmetic. This is a counterexample to treating clock error alone as sufficient, not a proof of a PostgreSQL implementation defect or a passing Lean theorem. Under a verified downward-only representation q may be zero. Check whether existing provenance can already establish this, and whether the distinction affects any accepted execution versus only the way its certificate is described. Mere finite precision is not by itself proof of an upward error.

### Exact whole candidates

All three candidates are the complete application package quoted above, plus ONLY the operation printed for that candidate. The candidate files `check/E-KEEP.md`, `check/E-TOTAL.md`, `check/E-SPLIT.md` render their entire prospective package. They are review artifacts outside the source clone; no applied spec tree is claimed. The unchanged paragraph tails, event-clock upper-bound clause, certificate/unknown rules, schema, conformance instructions and formal scope are part of every candidate. Do not count a preference for the unknown policy as acceptance of a different equation or definition.

#### E-KEEP — keep the adopted UO wording

Apply the complete existing package exactly. Make no error-definition change. In particular, retain this sentence from the pinned application brief, line 51:

> The last replayed commit-or-abort record's timestamp s can supply b=s−e only with evidence that e bounds the source clock's error, the timestamp was generated before insertion, and the recovered continuous prefix on matching ancestry contains that complete record.

The general certificate still binds; E-KEEP is not permission to call the illustrative clock-only result valid. Its strongest case is that the certificate already requires whatever representation evidence is necessary, so a second definition adds no duty. Explain whether the local wording remains a misleading sufficient recipe, or can safely remain as written with the retained inclusion-proof requirement. No extra normative clarification is smuggled into E-KEEP.

#### E-TOTAL — the finding's replacement

At the prospective STO-54 insertion, replace only the first sentence of application-brief line 51 (the E-KEEP sentence above) with:

> The last replayed commit-or-abort record's timestamp s can supply b=s−e only with evidence that e bounds the source timestamp's total error, including source-clock error and timestamp precision, quantization and rounding, the timestamp was generated before insertion, and the recovered continuous prefix on matching ancestry contains that complete record.

Keep all subsequent sentences and all other application instructions byte-identical. This deliberately names precision, quantization and rounding within e; decide whether it repairs the certificate's explanation or changes accepted reporting behaviour/cost. Do not automatically label it wording-only or add a new startup gate. If “total error” wrongly demands an unnecessary two-sided certificate or fails to say what event the error is relative to, give an exact AMEND.

#### E-SPLIT — a separate upward representation allowance

At the same location, replace only that first sentence with:

> The last replayed commit-or-abort record's timestamp s can supply b=s−e−q only with evidence that e bounds the source clock's error, q is a finite nonnegative upper bound on any upward difference between s and the source-clock reading at timestamp generation introduced by timestamp precision, representation, quantization or rounding, the timestamp was generated before insertion, and the recovered continuous prefix on matching ancestry contains that complete record.

Keep all subsequent sentences and all other application instructions byte-identical. e stays the source-clock allowance; q covers only representation that moves the value forward. The subtraction then accounts for both. No minimum resolution, mandated rounding algorithm, new startup validation, independent conformance case or finite-report admission gate is introduced. Uncertified endpoints follow the unchanged unknown contract. The additional evidence quantity and changed equation are disclosed; decide whether they materially change behaviour, merely express an equivalent conservative certificate, or are needless complexity. No default q=0 is authorized without evidence.

### Adversarial checks and answer format

1. Establish the exact certificate inequality relative to the real generation instant. Show whether the failure story is consistent with the quoted package; distinguish a violated overarching MUST from a gap in the local recipe. Is there an existing quoted definition that completely resolves precision already? If so, cite it rather than inventing a defect.
2. Evaluate each complete candidate for safety and scope. Check upward, downward and nearest rounding; coarse precision; error sign; zero/perfect clock error; unavailable/invalid precision evidence; finite arithmetic and b≤f; and the unchanged unknown-report, continuation and no-extra-hold outcomes. No implementation language or fixed precision is assumed. The units and source timestamp's provenance must match the certificate.
3. Classify E-TOTAL and E-SPLIT separately as WORDING-REPAIR within the owner's existing UO decision, BEHAVIOUR-CHANGE requiring the owner, or UNRESOLVED, with a quoted reason. A known false finite certificate was never allowed by the general MUST. Conversely, an extra bound/procedure/accepted-input restriction is not made editorial by calling it conservative. Identify any valid previous outcome a candidate disallows or any newly permitted outcome it adds.
4. Check for collision with the package's OVR-19 evidence-row instruction, other certificate paths and independent event-clock bound. The upper bound remains unchanged in all candidates; flag an adjacent issue rather than silently repairing it. If it makes a candidate unacceptable, say so with a trace; do not expand this one source-timestamp question into an unread combined form. No CNF identifier belongs in tools/formal/. No theorem weakening is proposed.
5. Give the strongest requested counterargument for keeping the adopted wording and for the smallest explicit repair, labelled as counterarguments. Is a cheaper exact third form adequate? Supply its complete replacement and classification as AMEND; it is not reviewed merely because one seat writes it.
6. End with a table of ACCEPT / AMEND / CANNOT ACCEPT for E-KEEP, E-TOTAL, E-SPLIT; one final preference or NONE; and a separate classification verdict for each repair. Return exact fixes with path, before/after and behavioural consequences. Do not recommend an unread synthesis or claim a panel majority can authorize a new owner policy. Check whether the rules, examples, scope and answer criteria contradict each other.
