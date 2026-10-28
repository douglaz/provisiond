Reviewed master `4662d85c7e67c2ebb4c5c8e1c98dc6e1c0efc239`. Baseline and final unpiped gates passed; tracked files are unchanged. A [draft](/var/tmp/provisiond-panel-r74/sol/draft-notes/r74-panel-a.md) is saved. No PostgreSQL prototype was run. These are direction recommendations, not ACCEPT votes on complete amendments.

**Q1 — Final pick: P, conditional on an enforceable deployment change authority. P1 comes first.**

**Example/reason:** after a successful connection check, an administrator empties the standby list. A subsequent commit can succeed locally before any poll. PostgreSQL documents the local behavior with an empty list and selection of `synchronous_commit` at commit time. Detection cannot prevent that commit. A controlled configuration boundary can prevent the transition while components serve. ([WAL settings](https://www.postgresql.org/docs/18/runtime-config-wal.html#GUC-SYNCHRONOUS-COMMIT))

Proposed owner insertions, each **AMEND, behaviour changed**:

- **[STO-7](https://github.com/douglaz/provisiond/blob/4662d85c7e67c2ebb4c5c8e1c98dc6e1c0efc239/05-persistence.md#L160)**, after the replication posture paragraph: “The deployment MUST identify a sole change authority controlling database configuration, reloads, role/database defaults, deployed SQL, endpoint routing and server credentials. Ordinary administrative paths MUST be restricted to that authority. Session-setting invariants rely on trusted component SQL; parameter ACLs do not restrict user-settable GUCs. Changes not established safe MUST be refused while components serve. Before maintenance can invalidate that proof, the authority MUST close component admission, stop every component and fence pending connection attempts. Process exit is not backend drainage: outstanding component backends MUST clear naturally, or the primary MUST be shut down before such maintenance. No component may resume until safe posture is verified.”
- **STO-7**, continuing: “An independent authenticated observer MUST start a complete round every C and finish or declare failure within Q, using a fresh direct administrative session outside component pools. It MUST check effective replication configuration, primary node/boot identity and role, and STO-55's topology evidence. Each component MUST explicitly set and verify synchronous_commit=on on every connection, verify applicable transaction settings before use, and prohibit subsequent lowering/resetting. Idle sessions MUST be rechecked each round. Busy-session evidence persists only while original session identity and enforced unchanged settings are established; otherwise it is unobservable. An observer's SHOW/pg_settings reads do not prove another session's GUCs.”
- **STO-7**, continuing: “Unsafe or unobservable evidence MUST latch refusal and alarm. Each component MUST gate requests, new transactions, claims, passes, provider-mutation dispatch and deposit exposure on current authority evidence. Evidence MUST expire within V measured monotonically from its request's start, never its delayed receipt; absence of notification cannot extend it. On refusal api rejects pre-transaction requests as overloaded and exits within A; the engine stops under OPS-21. A stop-record attempt is subject to the same gate. Already-sent COMMIT retains its checkout until reply, dead transport or process exit; unfinished api requests receive no success after refusal. Resumption requires operator reset, verified configuration/topology, discarded old connections and passing new-connection checks; changed history also requires STO-54's classification/procedure. Reset does not erase recorded posture violations.”
- **STO-55**, after its pooler prohibition: “The change authority MUST establish this topology from controlled routing, endpoint and credential ownership, independently of the component SQL path. End-to-end authenticated database connections with keys confined to database endpoints are one admissible construction. SQL identity samples alone are insufficient.”
- **[OPS-49](https://github.com/douglaz/provisiond/blob/4662d85c7e67c2ebb4c5c8e1c98dc6e1c0efc239/03-operation-lifecycle.md#L1916)**: “An attempt denied by STO-7's posture gate is a store error for this loop and sends no SQL.” **[OVR-18](https://github.com/douglaz/provisiond/blob/4662d85c7e67c2ebb4c5c8e1c98dc6e1c0efc239/00-overview.md#L338)** adds the posture latch to its alarm roster by pointer.

The observation bound is C+Q for persistent observable drift; all components refuse within C+Q+V, including disconnected ones. Engine exit follows existing bounds; api uses A. This requires functioning monotonic admission/watchdog execution and complete authority ownership.

Administrative bypass remains outside prevention: a privileged actor can toggle unsafe settings between samples, leaving no detectable sample, or commit immediately after the last safe sample. The controller journal detects controlled transitions, including reversals; it cannot establish that an unlogged root bypass never occurred. Busy-session invariant carry-forward is a trust condition, not an inspection API. If unenforceable, fail closed and disclose the long-transaction outage cost. ([pg_settings](https://www.postgresql.org/docs/18/view-pg-settings.html))

Pooler reassignment can occur between a PID check and the next transaction; reusing the same backend defeats PID-only detection. Endpoint authentication requires exclusive key/issuance control; DNS changes alone do not reroute an established direct TLS session. ([PgBouncer](https://www.pgbouncer.org/features.html), [TLS verification](https://www.postgresql.org/docs/18/libpq-ssl.html))

Conformance additions to **[CNF-296/CNF-365](https://github.com/douglaz/provisiond/blob/4662d85c7e67c2ebb4c5c8e1c98dc6e1c0efc239/10-conformance-checklist.md#L1070) — AMEND, behaviour changed**: inject persistent empty-list drift immediately after a retained-session check; demonstrate a possible pre-detection local commit, then bounded refusal everywhere. Reject unsafe posture before first use. Keep unchanged settings healthy. Lose one/both standbys without configuration changes: alarm, waiting writes and retained independent reads remain. Fail observer queries and isolate a replica from notifications: evidence expires. Introduce transaction pooling, force reassignment, then repeat with unchanged PID evidence: authoritative topology evidence must refuse it. Exercise already-sent COMMIT through stop expiry, retaining its checkout while alive and never cancelling its backend. Test controlled changes and bypass separately. Tests establish executions/bounds; deployment controls establish prevention.

**Collateral/cost:** preserve CNF-296's “a read still succeeds” during unchanged-posture stalls; expiring evidence merely because COMMIT waits would break it. `StopRecord.finished_unrecorded_exit` needs no additional exit disjunct: denied recording uses refused attempts and existing exhaustion. No cancellation exception or new lost-reply category is proposed.

OVR-19 needs STO-7-owned C, Q, V and A: startup-validated positive finite durations, C+Q<V, preserving existing client/server timeout ordering. Authority procedures are human rows; monitoring capacity belongs in STO-55's budget. Owner costs include control/observation infrastructure, restricted administration and maintenance/observer-failure outages.

**Q2 — Final pick: U, with an explicit allocation-safety gate.**

**Example/reason:** a promoted store has a WAL prefix but no surviving timestamp certificate. Calling its 14:00 startup the history boundary invents evidence. PostgreSQL's last replay timestamp concerns a commit **or abort**, can be null, and does not establish an exact history-loss instant. ([Recovery functions](https://www.postgresql.org/docs/18/functions-admin.html#FUNCTIONS-RECOVERY-INFO-TABLE))

**STO-54 — AMEND, behaviour changed**, replace the “lost window T − Δ” reporting instruction with:

> The incident MUST distinguish the recovery event from surviving history. recovery_started_at records the procedure's event time, not its recovery point. restore_instant is nullable: when present it is a conservative UTC lower boundary L such that every acknowledged component commit before L is proved included in the recovered history; null means no finite boundary is established. Retain recovered cluster identity, timeline ancestry/WAL end, evidence reference/derivation, clock-error bounds, and an upper bound U on the last possible old-history acknowledgement from completed component stopping/fencing. Report possible loss within [L,U], including duration, or unknown lower extent through U. Later commits may survive; neither endpoint asserts an exact snapshot. Invalid clocks, missing provenance, WAL holes or incomparable history MUST NOT yield finite L. Unknown history permits incident creation and recovery continuation, never the restart branch or waiver of another prerequisite. Persist these facts before component startup and reuse them unchanged across interruption. All recovery actions and closure conditions remain applicable without finite L.

**STO-54 — AMEND, behaviour changed**, add:

> Before marking step (3), the operator MUST establish that the configured index skip satisfies the deposits derivation_index rule, “Allocated strictly increasing and never re-issued”, and retain verifiable coverage evidence on the incident. Step (3) MUST check that evidence. Without sufficient evidence it remains unmarked and the listener closed; choosing a known recovery point is an alternative.

This prescribes no new allocator.

**STO-56 — AMEND, behaviour changed**: make `restore_instant` nullable; add non-null `recovery_started_at`, `loss_end_upper_at`, structured `history_evidence` with bounded/unknown status and nullable unavailable fields, and nullable `allocation_evidence`. Add: “Recovery-evidence semantics and validation are owned by STO-54.” Missing upper-clock evidence blocks timestamped incident creation until stopping/fencing has a defensible upper bound; an unavailable old primary does not itself prevent establishing it.

One sufficient known-boundary construction is an externally retained, uniquely named WAL restore-point certificate: cluster/history identity, position P, and the earliest defensible UTC time of the request creating it. If the recovered continuous prefix includes P, commits acknowledged before that request are included. This is an ordering inference, not LSN-to-time conversion. PostgreSQL supplies restore points and timeline history; certificate production, clock bounds and prefix verification remain deployment-validation dependencies. No compulsory heartbeat is proposed. ([Backup functions](https://www.postgresql.org/docs/18/functions-admin.html#FUNCTIONS-BACKUP), [archive recovery](https://www.postgresql.org/docs/18/continuous-archiving.html))

Traces/conformance, **CNF-295 — AMEND, behaviour changed**:

- Certificate L=09:00, included P, fence upper bound U=10:00: report possible loss within that hour.
- Old primary/certificate unavailable: record unknown extent, acknowledge the incident row under safe replication, then continue recovery. Independent allocation coverage permits step (3); absent coverage holds it.
- Interrupt before step (2)'s mark and after step (3)'s: reuse evidence/null, allocation evidence, marks, token bump and grace.
- Ordinary backup/PITR: verify backup, continuous WAL/timeline provenance and target certificate; otherwise report unknown. File modification time is insufficient. Include clock rollback, wrong-timeline and WAL-hole controls.

A Q4 tie needs no invented timestamp.

Consumers checked: STO-54's “the instant is read from the record and never re-computed”; STO-56's field; CNF-295's “the operator report names `T − Δ`”; the glossary; and [Restore.lean](https://github.com/douglaz/provisiond/blob/4662d85c7e67c2ebb4c5c8e1c98dc6e1c0efc239/tools/formal/Provisiond/Restore.lean#L92)'s `Record`, `RestoreTrace.store`, `afterCrash`, `bootRestore`, plus record-literal witnesses. Nullable history must not become `afterCrash`'s execution clock. Preserve `Restore.step_three_writes_grace`: grace remains anchored to step (3), not the history boundary.

**Collateral/cost:** numeric-only reporting and the non-null schema intentionally change. Restore maximum m followed by more lost allocations than gap g can reissue an index, violating CNF-297's “exceeds every index a rolled-back row held”. This hazard also exists for inadequately sized gaps on dated restores.

**CNF-297 — AMEND, behaviour changed**: require verified gap coverage for its successful fixture; add insufficient/unknown coverage expecting held step (3), not minting. Quarantine, token invalidation, grace and closure stay. Formal record literals need representation changes, not weaker conclusions. Owner costs: schema/evidence work, unbounded loss reports and potentially indefinite listener closure. E instead holds startup for a finite boundary. Priority P2.

**Q3 — Final pick: B, with one fail-closed admission authority outside the stalled database.**

**Example/reason:** api A disappears but its backend remains in SyncRep. Releasing A's slot credit immediately lets its replacement spend the same capacity twice. A timer does not establish backend disappearance.

**STO-55 — AMEND, behaviour changed**, add:

> Every physical connection attempt by a component, replacement, rollout, lock holder or migrator MUST consume a distinct deployment-wide reservation durably recorded before the attempt. A reservation permits at most one attempt/backend and MUST NOT expire or be reused merely because a process, transport or checkout disappeared. The single admission authority MUST serialize grants outside the protected PostgreSQL store. It MUST enforce issued-unreleased reservations plus bounded monitoring/operator allowances within the stated usable connection budget; those allowances also cover residuals and uncertain attempts. All supervisors and component reconnects MUST use it; no local fallback is permitted.

Continue:

> Reservations MUST identify component incarnation, connection attempt and database-node boot identity, and bind to backend PID and backend_start when available. Unknown bindings remain charged. Release requires proof the attempt cannot arrive later and a fresh, privileged direct-primary observation that its backend is absent. Leaving SyncRep alone is insufficient. Observation failure retains charges and denies growth. Exhaustion MUST alarm and delay/refuse admission; api refuses overloaded before a transaction, and engine acquisition follows OPS-49. Existing connections may continue within their reservations. Authority-state loss MUST deny growth; reset requires fencing all old grants/attempts and reconstructing them conservatively, or verified primary shutdown after component stopping. No SyncRep cancellation or termination is permitted.

Replace “Every consumer then has a connection when it needs one and nothing starves the exposure-reducing components behind the workers” with “Pool sizing reserves consumer checkouts within a running process; opening or replacing a database connection also requires the deployment reservation below.” **AMEND, behaviour changed.**

**OPS-49 — AMEND, behaviour changed**: “An attempt denied by STO-55's deployment reservation gate is a store error for this loop and sends no SQL.” Add exhaustion to OVR-18 by pointer.

Mechanically, one durable fsync-before-grant journal and one issuer suffice; failover must not create a second issuer. Fence delayed dial capabilities before observing absence, or a backend can appear immediately after release. Use fresh privileged `pg_stat_activity` observations; unidentified backends remain conservatively charged. Protect monitoring/emergency access with actual server reservations and bounded privileged connections. ([Activity statistics](https://www.postgresql.org/docs/18/monitoring-stats.html#MONITORING-PG-STAT-ACTIVITY-VIEW), [connection reservations](https://www.postgresql.org/docs/18/runtime-config-connection.html#GUC-RESERVED-CONNECTIONS))

The invariant is **actual charged backends ≤ unreleased reservations ≤ application budget**. Grant-before-open and release-after-fenced-absence preserve it. It guarantees capacity under controlled admission, neither write progress without a standby nor continued reads after all connections disappear. Existing usable read sessions and reserved observation/recovery access remain possible, subject to resource and lock availability. Manual/root connections require a bounded separate allowance.

New conformance case, **AMEND, behaviour changed**: precheck engine and multiple api replicas while healthy; stall both standbys; send disjoint writes and confirm exact PIDs enter SyncRep. Deliver an engine stop and exercise Stop-record expiry; lose api transports and overlap a rollout. Confirm original PIDs remain in SyncRep outside live pools. Keep replacement connection checks enabled: attempts can consume physical capacity while checking and fail before use; do not claim each replacement creates another waiting commit. Repeat stalls with verified residuals and release observations withheld until reservations exhaust. Assert no additional dial, alarm, bounded refusal and working reserved observer access. Exercise delayed attempts, PID reuse, competing supervisors and accounting loss. Restore standby progress, prove backend absence, release credit, then admit replacements. Immediate cleanup of every backend fails to exercise the residual case.

**Collateral/cost:** the quoted consumer-availability assurance narrows; no stop-record exit changes. CNF-296's cancellation-only pool bound and healthy CNF-57 rollout service remain with adequate reservations. OVR-19 needs STO-55-owned numeric total/allowance ceilings validated against server limits, plus human authority/reconciliation procedures. Its budget row includes residuals/overlap; the supervisor guarantee discloses capacity delay. Owner costs: unused capacity, durable admission infrastructure, potentially indefinite restart delay and primary downtime when accounting cannot be reconstructed. Priority P3.

**Q4 — Final pick: T, with an explicit no-open-incident fixture.**

**Example/reason:** both reports end at F on the same history. Every acknowledged commit is in one prefix, hence at or below max(F,F)=F. Either holds them all. R supplies no safety benefit under these assumptions.

**STO-54 — AMEND, behaviour changed**:

- Replace “and the one further ahead is promoted:” with “and a standby whose reported end is at least as far ahead as the other's is promoted (either may be chosen when they are equal):”.
- Replace “or of the one not further ahead,” with “or of a standby whose reported end is behind the other's,”.

**AMEND, behaviour unchanged**: replace “so that one holds them all” with “so every standby at the maximal reported end holds them all”. Align CNF-365's title with “maximal reported end”, **behaviour unchanged**.

**CNF-365 — AMEND, behaviour changed**:

> Repeat with both named standbys reporting the same flushed end on the old primary's timeline, no open restore record and every other restart-promotion condition satisfied, once promoting each standby. Assert restart classification, no restore record and no tenant credential-generation bump from the restore procedure.

Add equal-number/different-timeline, unavailable-report, behind-standby and violated-posture cases: automation waits; operator restore requires its acknowledged record before startup. With an existing open record, assert incident continuation and no repeated marked step. Preserve old-process stopping, old-primary fencing and a standby streaming from the promoted store.

**Collateral/cost:** only equality classification and declared tests change; different timelines remain incomparable. STO-54's open-record exception remains. Tenant generation stays unchanged by an ordinary tied promotion; engine generation still advances under OPS-15's “Its commit MUST be acknowledged before the engine begins any other write transaction”. The Lean model does not prove WAL comparison; update its classification prose without weakening restore theorems. Tie policy remains an owner choice. Priority P3.

**Does this document contradict itself?**

The brief's problem premises survive inspection. T's fixture needs a closed-incident context: equal reports plus an existing unmarked incident counterexample an unconditional “no restore record/no credential-generation bump”. STO-54 instead says “a process that starts while a restore record is open is continuing that incident”. This affects fixture scope and my conditional T pick, not Q4's premise.

“Lost window T − Δ” is an instant/window ambiguity already in STO-54, not a false quotation or changed Q2 premise. The allocation hazard does not falsify Q2's evidence-definition problem. Under notes.md rule 6, I find no premise-changing error warranting a void tally.

My proposals agree: Q1 stopping can create Q3 residuals; Q3 retains their reservations. Q2 uncertainty waives neither stopped components nor acknowledged incident creation or allocation safety. Q4 equality overrides neither missing/incomparable evidence, unsafe posture nor an open incident. These independent picks approve no unread combined amendment.

**Requested counterarguments, not my votes:**

- **Q1:** deployment trust already carries the safety argument; another controller adds failure modes and outages while root remains capable of bypass.
- **Q2:** E preserves a non-null schema and forces an auditable recovery point instead of propagating uncertainty.
- **Q3:** a deployment-wide no-growth gate followed by operator recovery is simpler if continued availability is unnecessary.
- **Q4:** prefix maximality already covers equality; clarify that reasoning without adding a separate tie-election mechanism.