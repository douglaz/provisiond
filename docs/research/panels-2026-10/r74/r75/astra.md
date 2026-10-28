Reviewed `4662d85c7e67c2ebb4c5c8e1c98dc6e1c0efc239`. Both required unpiped gate runs passed. Tracked files are unchanged; no agents, tracker commands or database prototype were used. [Draft and replacement text](/var/tmp/provisiond-panel-r74/r75/astra/review-evidence/r75-draft.txt) are saved. Original proposal bytes and behaviour marks remain intact; extraction hashes match.

**Q1 — preferred complete package: P3, under its printed trust conditions.**

| Package | Verdict |
|---|---|
| V1 — fable | CANNOT ACCEPT |
| A2 — opus | CANNOT ACCEPT |
| P3 — astra | ACCEPT |
| P4 — sol | AMEND |

The empty-list release is real: `SyncRepUpdateSyncStandbysDefined` wakes queues with `all=true`, sets `WAIT_COMPLETE`, and the waiter exits before the warning branches. [PostgreSQL source](https://github.com/postgres/postgres/blob/b049b4e7b4a159d373ef394bda67f7cf25758998/src/backend/replication/syncrep.c#L964).

V1’s repeat-until-pass rule conflicts with its warning-case fixture. Asynchronous streaming can already have flushed the commit despite empty names, defeating unconditional refusal. Conversely, a post-reply global flush position can include later writers’ or background WAL: healthy replication can require another wait. An incomplete probe is neither a failed SQL read nor PostgreSQL’s replication warning. V1 also supplies no idle deployment-wide detection bound.

A2 distinguishes waiting from failed reads, but transaction-local identity checks do not establish its post-COMMIT uninterrupted-session premise. A pooler may release the backend after COMMIT or repeatedly return the same backend. An established direct connection differs from a retained client-to-pooler connection. [PgBouncer’s transaction-pooling contract](https://www.pgbouncer.org/features.html).

A2’s “bounded” concurrent wait lacks a progress assumption; its monitor’s period-plus-query-timeout bound omits durable-record latency. Quorum-view/checkpointer consistency remains explicitly unverified. Closing an interval after catch-up does not discharge its printed restore classification. Read-only external consequences remain exposed. Its conditional detection-only fallback is a separate package.

P3’s strongest argument is prevention of **managed changes** before they cross live use. Its conditions include exclusive configuration/routing/credential control, trustworthy inventory, trusted component SQL and initial session-local verification. Another session’s `SHOW` supplies no substitute. Command-line pinning prevents global reload overrides, not arbitrary root interference. [PostgreSQL parameter precedence](https://www.postgresql.org/docs/18/config-setting.html).

Under those conditions, busy-COMMIT evidence can remain valid. Challenge-based expiry bounds new-use refusal by `H+J`, including idle/disconnected components and delayed replies, assuming functioning local enforcement. That is not retrospective protection of already-admitted consequences, nor a bounded durable-report guarantee when observer storage fails. Transient privileged bypass remains outside prevention/polling guarantees.

P3 already declares “explicitly require verified posture in its success fixture and add refused admission.” Its exact editorial rendering is this insertion after CNF-362’s title:

> For successful recording cases, maintain verified STO-7 posture permitting record admission until the record lands. Repeat the initial stop with PostgreSQL working but posture evidence unavailable: refused attempts send no SQL and consume the existing Stop-record/Store-retry bounds; assert their exhaustion exit.

This changes baseline behaviour but adds none to P3’s declared restriction. **P4 needs that insertion: AMEND, behaviour changed.** Otherwise working PostgreSQL plus observer failure/refusal breaks CNF-362’s “the engine exits only after the record lands” ([10:1681](https://github.com/douglaz/provisiond/blob/4662d85c7e67c2ebb4c5c8e1c98dc6e1c0efc239/10-conformance-checklist.md#L1681)).

CNF-296’s “a read still succeeds” remains reachable with independent admitted reads and unchanged verified posture. A healthy SyncRep wait alone must not invalidate evidence. STO-7’s “short of its process exiting” remains; refused recording consumes existing bounds, adding no exit to `StopRecord.finished_unrecorded_exit`.

Owner costs remain open: P3’s control infrastructure, restricted administration and maintenance/observer-failure outages; V1/A2’s hot-path reads and potentially indefinite additional waits.

**Q2 — preferred complete package: NONE.**

| Package | Verdict |
|---|---|
| U1 — fable | CANNOT ACCEPT |
| U2 — opus | AMEND |
| E3 — astra | CANNOT ACCEPT as complete wording |
| U4 — sol | CANNOT ACCEPT as complete wording |

`RestoreTrace.store` writes `restoreInstant := t.now` while `delta` selects history; `afterCrash` reloads that event into `now`; `bootRestore` uses `t.now`. `step_three_writes_grace` uses the completion event’s own instant. [Formal owner](https://github.com/douglaz/provisiond/blob/4662d85c7e67c2ebb4c5c8e1c98dc6e1c0efc239/tools/formal/Provisiond/Restore.lean#L164). This establishes an event/history distinction, not an exact SQL timestamp assignment.

E3’s intentional redefinition is permissible policy, but it supplies no synchronized formal replacement separating history and execution time. U4 identifies that obligation without returning complete synchronized changes. Compilation over arbitrary `Nat` would validate neither semantic amendment.

U1’s timestamp identifies a replayed commit **or abort**, not an exact history end. Labelling two clocks does not establish a bounded common-clock interval; its fixture additionally says “last replayed commit time.” U2’s allowance can support a conservative boundary under verified clock and prefix assumptions. However, its report ends at `restore_instant + allowance`, its CNF-295 replacement names `restore_instant`, and the adjusted upper endpoint/allowance is not persisted despite “Both are read from the record and never re-computed.” [Recovery-function semantics](https://www.postgresql.org/docs/18/functions-admin.html#FUNCTIONS-RECOVERY-INFO-TABLE).

The evidence arguments are conditional:

- Trusted time before an insertion-position sample, or before a uniquely named restore-point insertion, covers earlier acknowledgements once the recovered continuous matching prefix includes that position.
- A replayed commit/abort timestamp can support a conservative bound with verified source-clock bounds and provenance. Timestamp disorder defeats an exact snapshot, not necessarily this ordering argument.
- Externally retained certificates can work without the old primary. Bare LSNs, filenames and unverified backup `START TIME` cannot establish inclusion. Nulls, holes, divergent ancestry and missing clock evidence require the chosen missing-evidence action.

U4’s allocation counterexample is real and pre-existing: restored maximum `m`, lost allocations beyond `m+g+1`, then skip `g`, can reuse an index. The schema requires “Allocated strictly increasing and never re-issued”; CNF-297 requires “exceeds every index a rolled-back row held” ([05:924](https://github.com/douglaz/provisiond/blob/4662d85c7e67c2ebb4c5c8e1c98dc6e1c0efc239/05-persistence.md#L924), [10:1081](https://github.com/douglaz/provisiond/blob/4662d85c7e67c2ebb4c5c8e1c98dc6e1c0efc239/10-conformance-checklist.md#L1081)). Unknown reporting did not create that defect. U4’s added evidence gate is a separate mechanism, requiring collateral fixtures and owner choice. A known recovery time alone does not prove allocation coverage; rejecting the addition does not waive no-reissue.

**Complete exact replacement U2* — UNREVIEWED.** This replaces U2 entirely, retaining finite-only admission and the event field. Following amendments are **behaviour changed**, except the specified formal clarification.

STO-54: replace “the lost window `T − Δ` is stated as a number and published to the operator” with:

> the record’s conservative possible-loss interval [L,U] is published to the operator

Add:

> The report states possible loss, not an exact snapshot or measured loss. `restore_instant` is the restored store’s transaction-start timestamp for the transaction inserting this incident, begun after every engine and api process stopped, with STO-54’s existing fencing requirements satisfied. L must certify that every component commit acknowledged before L belongs to the recovered committed history. U is `restore_instant` plus a verified upper bound on that event clock’s error.
>
> Before incident creation, retain incident-keyed evidence of source cluster, ancestry, continuous recovered prefix, source record/position, clock bounds and endpoint derivation outside the lost failure domain. A captured last-replayed commit-or-abort record time minus a verified source-clock error bound is admissible only with that record’s time provenance and inclusion in the recovered continuous source history established. Capture before a restart can erase it. An operator-supplied earlier bound needs the same inclusion proof; a backup name or timestamp alone does not provide it.
>
> Missing or invalid evidence for either endpoint keeps components stopped and prevents record creation until an evidenced recovery point is obtained. Backup restores obey the same rule. Require finite L≤U. Persist both endpoints and their evidence reference with the incident; report and continuation reuse them unchanged.

Replace STO-54’s later “the report naming `T − Δ`” with “the report of the persisted possible-loss interval”—**behaviour unchanged relative to this reporting amendment**.

STO-56: add non-null `lost_window_starts_at`, `loss_end_upper_at`, and `history_evidence_ref`, with semantics owned by STO-54. Keep non-null `restore_instant` with the event definition above. OVR-19 adds STO-54-owned verified clock-error bounds and the human capture/validation/retention procedure.

Formal clarification—**behaviour unchanged**: document that `t.now` abstracts the chosen incident event timestamp; retain the event assignments in `RestoreTrace.store`, `afterCrash`, and `bootRestore`. Interval/evidence verification remains outside the model’s stated publication scope. Preserve `step_three_writes_grace`.

CNF-295: replace “the operator report names `T − Δ`” with “the operator report names the persisted conservative interval [L,U]”. Require valid endpoint evidence in successful restore arms of **CNF-99, 295, 297, 302, 358 and 370**, and the added restore-class CNF-365 case. Seed valid evidence wherever other tests construct incident rows.

Add to CNF-365:

> Promote a lagging standby as an operator restore and assert captured evidence yields the persisted endpoints; repeat without valid evidence.

Add to CNF-295:

> Exercise known-boundary, unavailable-old-primary, missing/null evidence, clock failure, wrong ancestry, WAL-hole, backup and interruption cases. Invalid evidence creates no record and starts neither component. Valid evidence permits the original procedure, preserving endpoints across interruptions and the later step-(3) grace anchor. Include a last-abort record and nonzero allowance.

STO-54’s settled ordering remains: “MUST start neither component until the transaction that commits `STO-56`’s record (below) has been acknowledged.” No allocation mechanism is added or existing allocation obligation waived.

This replacement distinguishes known boundary, missing-boundary refusal, persisted continuation and evidenced backup recovery. Costs: schema, retained evidence, clock discipline and potentially indefinite outage. **U2* is not acceptance of an unknown-permitted U.**

**Q3 — preferred complete package: NONE.**

| Package | Verdict |
|---|---|
| C1 — fable | CANNOT ACCEPT |
| B2 — opus | CANNOT ACCEPT |
| B3 — astra | AMEND |
| B4 — sol | AMEND |

C1 correctly prevents **use** after a flushed position outruns frozen standbys. It does not prevent physical backends during checks.

Its startup count fails before the freeze: start two pools of five against component budget ten, with no waiters. Within one incarnation, repeatedly lose transports after COMMIT enters its interrupt-held path but before local flush; replacements check the earlier flushed prefix while replication remains healthy. Freeze, then release delayed commits: eleven old backends can become waiters although overlap never exceeded two. Live non-waiting backends were also uncounted. [Source-grounded abstract trace](/var/tmp/provisiond-panel-r74/r75/astra/review-evidence/c1-trace.txt). Its literal fixture kills one api and cuts the other’s transport; no surviving read session is established.

B2’s race causes conservative refusal, not demonstrated over-admission of authenticated sessions. But PGPROC allocation precedes authentication, role-limit checking and reserved-slot checking. A burst paused before those checks threatens physical capacity/reserves; a soon-refused attempt can also exceed its literal all-samples role count. [Initialization ordering](https://github.com/postgres/postgres/blob/b049b4e7b4a159d373ef394bda67f7cf25758998/src/backend/utils/init/postinit.c#L704), [role check](https://github.com/postgres/postgres/blob/b049b4e7b4a159d373ef394bda67f7cf25758998/src/backend/utils/init/miscinit.c#L858). Lock, migrator, waiting-runner, admin and unidentified attempts need bounds; background/prepared resources need separate accounting. Keepalive cleanup after leaving SyncRep is not proof of disappearance.

B3/B4’s strongest argument is an injection: every backend maps to one unreleased durable grant, bounded by capacity. It requires no bypass/redial, fenced exclusive issuance, charged unknowns and fencing delayed arrivals before fresh absence. Observer allowances must include residuals and depend on functioning access/network/server resources. Capacity does not imply continued service.

**B3 AMEND, behaviour changed:** replace STO-55’s “Every consumer then has a connection when it needs one and nothing starves the exposure-reducing components behind the workers” with:

> Pool sizing reserves consumer checkouts within a running process; opening or replacing a database connection also requires deployment admission.

Replace B3’s “bounded allowances” with “bounded allowances including live, residual and unidentified attempts.”

**B4 AMEND, behaviour changed:** its supervisor-delay prose needs the exact supervisor/fixture alignment below.

**Complete exact replacement B4* — UNREVIEWED.** This replaces B4 entirely. All amendments are **behaviour changed**.

STO-55: use the consumer-sentence replacement above. Replace “During a stall, backends left waiting by an exited process or a dead transport hold slots outside this `max_connections` account (`pv-oehp`).” with:

> Every physical connection attempt by component pools, reconnects, rollout incarnations, startup-lock holders, migrators and waiting runners MUST receive a distinct durable reservation before dialing from one serialized authority outside the protected store. Ingress MUST prohibit bypass and redial under one reservation. Bind grants to component/attempt identity and database boot identity, and to backend PID and `backend_start` when known. Unknown bindings remain charged. Timeout, transport loss, process exit and rollout completion never release a grant.
>
> Unreleased grants MUST fit component capacity C. Bounded observer/operator/other-client allowances A include their residual and uncertain attempts. C+A MUST fit usable capacity after server reservations, with background/server resource pools budgeted separately. Keep separate read/write checkout budgets.
>
> Release requires fencing every delayed arrival/retry and fresh privileged direct-primary evidence, read in a fresh transaction, that the bound backend ended. Leaving SyncRep is insufficient. Unidentified attempts remain charged until fenced server-incarnation termination proves absence. Observer failure denies growth and retains charges.
>
> Accounting loss closes ingress. Recovery requires fenced conservative reconstruction or stopped components and verified primary shutdown before a fresh account; either path fences all old grants and delayed attempts. Existing admitted sessions may continue. Exhaustion alarms, refuses growth and delays replacements.
>
> Startup acquisition refusal exits for supervisor retry; api returns overloaded before any transaction; worker/periodic acquisition refusal is an OPS-49 store error. Stop-record refusals consume existing bounds and send no SQL. No individual SyncRep backend may be cancelled or terminated to make room; primary shutdown remains STO-7’s exception.

OPS-47: replace “supervisor that restarts it and never runs two” with “supervisor that retries startup subject to STO-55 admission and never runs two”.

OPS-49 adds:

> An attempt denied by STO-55 admission is a store error for this loop and sends no SQL.

OVR-18 adds admission/accounting alarms. OVR-19 registers STO-55-owned C, allowances, resource ceilings and authority/reconstruction procedures.

CNF-290: replace “release the first and assert the second then starts” with:

> with sufficient STO-55 admission available, release the first and assert the second then starts; repeat with exhausted admission and assert delayed startup until verified capacity release

CNF-57/296/299 successful-service fixtures retain adequate reservations and live independent read sessions. CNF-362 successful-recording fixtures require admitted recording capacity; refused admission exercises existing exhaustion bounds.

New drill:

> Precheck engine and multiple api pools; freeze standbys, send disjoint writes and identify waiting PIDs. Stop the engine through its recording bound, lose api database transports, and overlap a rollout. Preserve one admitted read session if asserting read success. Verify old PIDs survive outside live pools.
>
> Keep replacement checks enabled; hold check replies/disconnect detection so replacement backends remain while attempts fail unused. Accumulate verified residuals and unreleased grants to exhaustion; assert no extra dial, alarm, bounded refusal and reserved observer access. Exercise delayed handshakes, PID reuse, competing issuers, observer failure and lost accounting. Restore progress, fence attempts and prove backend termination before release and restart. Never release merely because `wait_event` changed.

This preserves STO-7’s “other than by shutting the primary down” exception and OPS-21’s “MUST wait at least the Stop-record bound”. Costs: reserves, durable admission infrastructure, restart delay and possible shutdown for unreconstructable accounting.

**Q4 — preferred complete package: T-complete.**

| Package | Verdict |
|---|---|
| T1–T6, as one whole form | ACCEPT |

All replacement anchors match uniquely. No repair is required. T1/T4/T5 retain **behaviour changed** marks; T2/T3/T6 remain unchanged relative to T1.

STO-54’s premise is “every acknowledged commit was flushed by one of them, and both hold a prefix of one WAL sequence.” Either equal maximal prefix therefore contains the acknowledged history.

Greater same-history end: restart with other conditions satisfied. Behind choice: operator restore. Missing reports or equal numbers on different timelines: no equality path. Prior unreplicated commits or cancelled waiters: restore-class.

With an open record, “A marked step does not run again”: before step (3), complete its tenant bump; afterward, do not repeat it. Equality closes nothing. Old-process stopping, old-primary fencing and “writes continue once the other standby streams” remain. Engine startup-generation advancement remains distinct from tenant credential generation.

Equality authenticates neither reports nor historical posture. Only the declared equality/test/pointer/comment changes are introduced. **Technically ready for the owner’s equality choice in this reading**; this single vote neither satisfies the panel threshold nor authorizes implementation.

**Does this brief or my proposed combination contradict itself?**

The independent questions are compatible; V1 and U2 contain the internal mismatches identified above. No premise-changing verified brief error was found: **apply notes.md rule 6 exactly as written; this prompt adds no void rule**.

The tally’s “Astra explicitly proposes matching changes” needs narrowing: B3 names supervisor/restart amendments but omits STO-55’s universal consumer promise. This changes package completeness, not Q3’s premise. I do not adopt a blanket brief-error objection to E’s intentional field redefinition. Other central manager traces were independently confirmed, including freshly fetched PostgreSQL files matching its snapshots.

No union is adopted. Q1 refusal can create Q3 residuals; grants must survive it. Combining them requires observation capacity and both permissions for new work. Q2* can prolong an operator restore; Q4 restart does not create that obligation, while an open incident continues it. Restart classification also does not waive Q3 admission. Owner costs remain undecided.

**Requested counterarguments, not my votes:**

- **Q1:** Trusted configuration already carries the deployment assumption; another controller adds outages.
- **Q2:** Finite evidence may block useful recovery indefinitely; honest unknown reporting could be preferable.
- **Q3:** Durable external accounting may cost more than accepting exhaustion and operator recovery.
- **Q4:** Bad reporters can falsely tie; conservative operator recovery trades credentials for caution, although that does not refute T under valid reports.