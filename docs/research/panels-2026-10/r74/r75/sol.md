Reviewed `4662d85c7e67c2ebb4c5c8e1c98dc6e1c0efc239`. Baseline and final unpiped gates passed on the unchanged base. Tracked files remain unchanged. Proposal hashes match; T’s edit anchors each occur once. Independently fetched PostgreSQL source bytes match the tally’s cached sources. No tracker, remote or production action, prototype or agents were used. [Draft](/var/tmp/provisiond-panel-r74/r75/sol/r75-sol-review.md). Original proposals and behaviour marks remain frozen; replacements below are **unreviewed**.

The settled ADR-0045 choices remain “I think we should just suppose synchronous replication”, “A: stop on time (Recommended)” and “B: check each new connection (Recommended)”. STO-7’s deposit rule remains “Before exposing a deposit destination read from the store, repeat the read-only flush-position check with a target sampled after that read, on the same uninterrupted PostgreSQL session.”

**Q1 — preferred complete printed package: P3, under its printed conditions.**

| Package | Verdict | Decisive reason |
|---|---|---|
| V1/fable | CANNOT ACCEPT | Repeat-until-pass contradicts its warning-case fixture; asynchronous streaming can satisfy its target despite empty names. PID equality does not prove topology. |
| A2/opus | CANNOT ACCEPT | Transaction binding does not establish the claimed post-COMMIT session/topology guarantee. Its healthy-progress promises exceed its evidence. The conditional detection-only fallback remains separate. |
| P3/astra | ACCEPT | Controlled mutation, session-local verification, authenticated inventory, expiring permissions and explicit stop-record collateral form a coherent conditional contract. |
| P4/sol | AMEND | Observer-only refusal can defeat CNF-362’s unchanged working-store success fixture. |

PostgreSQL’s empty-list path calls `SyncRepWakeQueue(true, i)`, sets WAIT_COMPLETE, and reaches the wait loop’s completion exit before its warning branches. Released commits can become externally visible before a poll. V1/A2 protect component acknowledgement conditionally, not read-based external effects. Idle time supplies V1 no deployment-wide detection bound. A2’s monitor supplies configuration evidence, not complete topology evidence. [Pinned syncrep.c](https://github.com/postgres/postgres/blob/b049b4e7b4a159d373ef394bda67f7cf25758998/src/backend/replication/syncrep.c#L964)

Healthy concurrent trace: A’s commit is replicated and replied; B flushes later WAL locally; A samples that newer position before its replication. A must wait without a warning or failed read. Without later WAL, fresh confirmation may pass immediately; a statistics-read error is a distinct proposed lost-reply case. V1’s “healthy replication never produces one” is false. A2’s “bounded” and “milliseconds” provide no finite progress guarantee. Its additional lost-reply category is explicitly matched in STO-7/OPS-49; V1’s is not.

An existing direct TCP session cannot have a physical pooler inserted into it. A retained client-to-pooler session can survive backend release/reassignment. Identity samples can detect changes, but repeated assignment to the same backend is allowed, and COMMIT ends transaction ownership before confirmation. [PgBouncer pooling semantics](https://www.pgbouncer.org/features.html)

P3 requires exclusive authenticated configuration/routing/credential control, trusted component SQL and audited routines, complete inventory, bounded local enforcement, independent observer resources and monotonic challenge expiry. Another session’s SHOW proves no busy session’s GUC. Command-line pinning does not prevent session overrides of user-settable settings. [Parameter precedence](https://www.postgresql.org/docs/18/config-setting.html)

Delayed healthy renewals expire from their earlier challenges; disconnection cannot renew them. Persistent observable drift therefore stops new use by H+J under those execution assumptions. Busy healthy COMMIT can retain setting evidence under enforced unchanged identity/settings. Transient bypass/reversal can evade polling; root/proxy impersonation remains outside prevention. Earlier acknowledgements and already licensed external actions are not undone.

P4’s C+Q observation and C+Q+V refusal bounds likewise require monotonic request-start expiry and functioning local enforcement; api additionally uses A. Its transaction-setting verification has its own cost.

CNF-296’s “a read still succeeds” remains reachable with unchanged posture, independently admitted reads and functioning observation. STO-7’s “short of its process exiting” and “MUST NOT release its connection before the reply arrives or the transport is found dead” stay. Denied recording attempts consume existing bounds; they create no immediate exit disjunct in `StopRecord.finished_unrecorded_exit`.

**P4 repair, behaviour changed:** in CNF-362 replace “with a working store.” with:

> with a working store and verified STO-7 posture throughout recording.

Replace “in each case the engine survives the stop and the store works before the Stop-record bound ends, unless the case says otherwise.” with:

> in each case the engine survives the stop and the store works with STO-7 posture admission available before the Stop-record bound ends, unless the case says otherwise.

Append:

> With PostgreSQL working but posture admission denying every record attempt from its beginning, assert no SQL is sent, existing exhaustion bounds end recording, the row remains running, and restart recovery applies.

This does not count as printed P4 acceptance. Replacement anchors normalize line wrapping only.

Strongest argument: prevention needs a mutation boundary; observation cannot retract a reply. Owner costs remain independent control infrastructure, restricted administration, maintenance and observer-failure outages. Per-commit alternatives add transaction reads, round trips and potentially indefinite additional waits.

**Q2 — preferred complete printed package: NONE.**

| Package | Verdict | Decisive reason |
|---|---|---|
| U1/fable | CANNOT ACCEPT | Clock labels provide neither an error bound nor an acknowledged-prefix certificate; its “last replayed commit time” fixture also misnames the commit/abort observation. |
| U2/opus | AMEND | Clock/provenance proof, fallback evidence, persisted endpoints and collateral fixtures need completion; its “record’s restore instant as the window’s end” omits its rule’s allowance. |
| E3/astra | CANNOT ACCEPT | Sound conditional certificate and explicit finite-only hold, but changed field meaning lacks synchronized formal definitions. |
| U4/sol | CANNOT ACCEPT | Nullable history semantics need the concrete formal separation it acknowledges. Its allocation hold adds recovery-success fixture restrictions beyond CNF-297. |

In the [formal home](https://github.com/douglaz/provisiond/blob/4662d85c7e67c2ebb4c5c8e1c98dc6e1c0efc239/tools/formal/Provisiond/Restore.lean#L163), `RestoreTrace.store` selects history with delta but writes `restoreInstant := t.now`; `afterCrash` reloads execution now from that field and `bootRestore` uses t.now. For event now=20 and certified boundary=10, E3 cannot leave those assignments unchanged. U4’s unknown boundary cannot inhabit their Nat field. Compilation over arbitrary Nat proves neither new meaning. No existing theorem was experimentally refuted here. `Restore.step_three_writes_grace` uses the completeProcedure event’s instant independently of w.now.

Replay timestamps describe the last replayed commit/abort record and may be null; normal restart can lose the observation. They do not identify an exact snapshot. With certified clock error, record-generation ordering and continuous matching history, an appropriately earlier timestamp can certify inclusion of preceding acknowledgements. Without those conditions U1’s labelled clocks do not establish one interval. [Recovery functions](https://www.postgresql.org/docs/18/functions-admin.html#FUNCTIONS-RECOVERY-INFO-TABLE)

E3’s ordered trusted-time/insert-position certificate works because acknowledgements before the time observation inserted WAL before the sampled position. U4’s externally retained named-restore-point certificate has the same ordering argument when its request follows the trusted lower time. Both require complete record inclusion, source identity, matching ancestry, bounded clocks and evidence outside the failure domain. Neither tolerates holes or divergent history; neither needs the dead primary during recovery. A filename or backup START TIME alone proves none of this.

For U2R below, s−e precedes record generation; earlier acknowledgements precede its insertion and therefore lie in the certified prefix. An abort record can support that argument too. These are conditional proof obligations, not validated deployment mechanisms. [Commit/abort WAL ordering](https://github.com/postgres/postgres/blob/b049b4e7b4a159d373ef394bda67f7cf25758998/src/backend/access/transam/xact.c#L1446)

The allocation counterexample is real and pre-existing: restored maximum m, gap g, and more than g+1 lost allocations permit reuse. The deposits column says “Allocated strictly increasing and never re-issued” (05:924); CNF-297 says “exceeds every index a rolled-back row held”. A finite timestamp alone does not prove a sufficient gap. U4 adds an evidence check enforcing that existing obligation; it is not necessary merely to define the report. That scope/outage choice needs separate authorization; omitting it does not waive no-reissue. The formal model explicitly omits index allocation, so an absent allocation test is not itself a failed existing theorem.

**Complete U2 replacement U2R — UNREVIEWED; all amendments behaviour changed.** Scope: retain event-field meaning and U2’s finite-only hold, without U4’s allocation gate.

At STO-54 step (1), replace “the lost window `T − Δ` is stated as a number and published to the operator” with this definition/report contract:

> `restore_instant` is `transaction_timestamp()` of the newly begun incident-insert transaction. This is a new precise SQL definition, not a fact proved by the existing model. Before that transaction, retain stopping/fencing evidence establishing that no old-history acknowledgement can follow its start. Retain finite clock-error allowance e covering source and incident timestamps, with provenance proving that bound. Persist lower bound b, upper bound f=`restore_instant`+e and their evidence once, keyed by incident id; require b≤f. Every source-history commit acknowledged before b MUST belong to recovered committed history. Report possible loss within (b,f], whose duration bounds possible loss rather than measuring it.
>
> Last replayed commit/abort timestamp s permits b=s−e only with verified provenance, timestamp-generation-before-insertion ordering and a consistent recovered prefix containing that complete record on matching ancestry. Capture it before restart, or recover the identified record from retained WAL. An earlier fallback b requires the same inclusion proof; a filename or backup START TIME alone is insufficient. Missing records, holes, wrong ancestry, unbounded clock uncertainty or unverifiable upper bounds hold record creation and both components stopped until evidence is supplied or an evidenced recovery point chosen. Backups use the same rule. Continuations reuse persisted bounds/evidence.
>
> STO-56: add non-null `lost_window_starts_at`=b and `loss_end_at`=f, with semantics owned by STO-54; retain evidence durably by id. Existing `restore_instant` remains the event timestamp. OVR-19 registers clock allowance and evidence procedure. In Restore.lean’s record documentation, identify restoreInstant as the insert-transaction event time; retain store/afterCrash/bootRestore event assignments. History reporting remains explicitly outside this model. Grace remains step (3)’s own instant plus its interval.
>
> CNF-295: replace “the operator report names `T − Δ`” with “the operator report names the persisted possible-loss bounds and duration defined by STO-54”. Test known evidence with unavailable primary, null replay observation, invalid clock bounds, divergent ancestry, WAL hole, backup restore, and interruptions before/after step marks. Missing valid bounds means no incident insert or startup; valid evidence releases the hold. Complete step (3) much later than b and assert its independent grace anchor.

At 05:1656 replace “the report naming `T − Δ` is what tells the operator the clock moved” with “the persisted possible-loss report identifies uncertainty in that history clock”.

ADR-0047’s ordering remains: “MUST start neither component until the transaction that commits `STO-56`’s record (below) has been acknowledged”. Successful actual-restore fixtures in [the checklist](https://github.com/douglaz/provisiond/blob/4662d85c7e67c2ebb4c5c8e1c98dc6e1c0efc239/10-conformance-checklist.md)—CNF-99,295,297,302,358,370 and U2’s new CNF-365 restore drill—require valid bounds. Open-record seeds in CNF-29,99,218,271,308 require valid schema/evidence. CNF-288 says “`CNF-295` asserts it”; CNF-312 says “This item does not drive route 2 or establish restore conformance”. These restrictions belong to U2R, **behaviour changed**. Otherwise, for example, CNF-370’s “Then start an engine” is unreachable without evidence.

Strongest argument: separate event and history facts without repurposing the execution clock. Owner costs: schema/evidence retention, clock discipline and potentially indefinite outage. Unknown-permitted U1 remains a distinct alternative, not acceptance of U2R.

**Q3 — preferred complete printed package: NONE.**

| Package | Verdict | Decisive reason |
|---|---|---|
| C1/fable | CANNOT ACCEPT | Startup SyncRep counting misses live sessions, reconnect residuals, transient attempts and concurrent admission; read survival needs clarification. |
| B2/opus | CANNOT ACCEPT | Role limits bound admitted normal sessions, not all pre-limit physical attempts or protected observer access. |
| B3/astra | AMEND | Sound conditional invariant; needs exact consumer-availability narrowing and behavioural read-fixture restrictions. |
| B4/sol | CANNOT ACCEPT | Sound conditional accounting direction, but supervisor/restart and independent-read collateral remain incomplete. |

C1’s strongest objection is correct: after a locally flushed commit advances beyond frozen standbys, STO-7 says an unpassed check means “the connection is closed unused”. That prevents use, not physical creation. Countertrace: budget 10, two pools of 5, zero waiters; startup checks pass. Repeatedly lose one incarnation’s transports while old COMMITs are held before local flush. Replacements pass on the earlier target while replication remains healthy. Freeze, release held commits, and residuals plus live backends exceed 10 without another startup or increased rollout overlap. C1’s gate never runs on those reconnects. This respects the connection guard and source ordering; it is not a newly failed base CNF.

The manager’s read objection needs narrowing: “cut the other’s transport” does not explicitly cut every read connection. Cutting only its waiting write connection permits an independent read session to survive. Name that session; total read loss is not proved. This does not rescue C1’s budget.

B2’s source allocates PGPROC before authentication/role-limit enforcement. Normal same-role residuals count; nonregular workers and prepared transactions do not. Concurrent checks can refuse both entrants conservatively; no over-admission race was established. Unidentified/pre-limit attempts nevertheless consume slots before role or reserve refusal. Role-filtered samples cannot establish the required physical bound. Lock connections, migrator runners and administrative clients need allowances; background workers and WAL senders have separate resource pools. Keepalives do not cancel SyncRep. [Initialization](https://github.com/postgres/postgres/blob/b049b4e7b4a159d373ef394bda67f7cf25758998/src/backend/utils/init/postinit.c#L704), [role check](https://github.com/postgres/postgres/blob/b049b4e7b4a159d373ef394bda67f7cf25758998/src/backend/utils/init/miscinit.c#L859)

**Complete B3 replacement B3R — UNREVIEWED; all amendments behaviour changed.**

Replace STO-55’s “During a stall, backends left waiting by an exited process or a dead transport hold slots outside this `max_connections` account (`pv-oehp`).” with:

> One durable serialized authority outside PostgreSQL MUST grant a distinct permit before every component physical dial, including reconnect, rollout and startup-lock attempts. Controlled ingress MUST prohibit bypass and redial. Each permit authorizes at most one backend and identifies incarnation, attempt and target boot; bind PID/backend_start when known. Unknown attempts stay charged. Never release on timeout, client/process death, lease expiry or merely leaving SyncRep. Release requires fencing every delayed/retry capability and fresh authoritative evidence of termination; unidentified attempts remain charged through proven server-incarnation termination.
>
> Outstanding component permits MUST be at most C. Allowances A include live, residual and uncertain observer/operator/migrator attempts and waiting runners; apply the same before-dial accounting. Require C+A+server reserves to fit max_connections, with separately bounded internal pools/resources. Reserve read capacity separately. Maintain bounded privileged observation using reserved resources and controlled ingress, assuming responsive database/control resources; otherwise freeze releases and admissions. Exhaustion alarms and delays replacements. Accounting loss closes ingress until fenced conservative reconstruction or stopped-components primary shutdown. No local fallback or second issuer is permitted.

Matching edits:

> STO-55: replace “Every consumer then has a connection when it needs one and nothing starves the exposure-reducing components behind the workers” with “Pool sizing reserves consumer checkouts; physical growth additionally requires deployment admission.”
>
> OPS-49: denied admission sends no SQL and consumes existing store-error bounds. Stop-record bounds/exits remain unchanged. STO-7’s “MUST NOT cancel or terminate a primary backend while it waits for a standby” remains, including its shutdown exception.
>
> OPS-47: replace “under an external supervisor that restarts it and never runs two.” with “under an external supervisor that never runs two and retries startup subject to STO-55; exhausted admission may delay startup indefinitely.”
>
> CNF-290: replace “release the first and assert the second then starts.” with “With admission available, release the first and assert the second then starts; separately exhaust admission, assert delayed startup, then restore verified capacity and assert startup.”
>
> CNF-296/299: add “Retain independently admitted live read sessions and functioning admission/observation throughout these existing success traces.” Keep the cancellation-only pool bound.
>
> Add a residual drill: precheck engine and multiple api replicas; pause commits before local flush; lose selected client transports while preserving server legs; admit replacements while healthy. Freeze, release paused commits, verify old SyncRep PIDs, stop the engine through recording expiry and overlap rollout. Failed replacement checks remain closed unused. Blackhole further check replies/disconnects, retaining server legs until C exhausts; assert no additional dial and bounded refusal. Promise reads only on retained read sessions. Exercise delayed handshakes, PID reuse, competing issuers, observer failure and accounting loss. Restore replication/transports, verify actual termination, release permits and resume. Register C/allowances/reconstruction in OVR-19 and alarms in OVR-18.

The invariant is injective: actual controlled backends ≤ unreleased permits ≤ C. It requires durable-before-dial grants, complete ingress control and release-after-fenced-termination. Leaving SyncRep is not disappearance. Observer allowances include their own failed attempts.

Strongest argument: retained charges prevent double-spending departed processes’ slots. Owner costs: reserves, independent durable admission, indefinite restart delay and possible reconstruction shutdown. Capacity is guaranteed conditionally; continued service is not.

**Q4 — preferred complete package: T1–T6 together; ACCEPT.**

| Whole form | Verdict | Behaviour marks |
|---|---|---|
| T1–T6 | ACCEPT | T1/T4/T5 changed; T2/T3/T6 unchanged relative to T1. No repair required. |

STO-54’s premise is “every acknowledged commit was flushed by one of them, and both hold a prefix of one WAL sequence”. At valid equal ends F, both contain all acknowledged work: max(F,F)=F. Either promotion passes the positive fixture. Unequal same-history greater may restart; behind requires operator restore. Missing reports wait/operator; equal numbers on different timelines are not equality evidence. Prior unsafe commits or cancelled/terminated waiters remain restore-class. Equality authenticates neither reports nor historical posture.

With an open record, STO-54 says “a process that starts while a restore record is open is continuing that incident”. Before step (3)’s mark, its tenant credential bump still occurs; after the mark, it does not repeat. Engine startup generation remains separate: OPS-15 says “Its commit MUST be acknowledged before the engine begins any other write transaction”. Old components stop before promoted-store connections. STO-54 retains “the old primary MUST NOT serve a component again” and “writes continue once the other standby streams from the promoted store”.

T’s no-open-record fixture restriction is explicitly behavioural. Negative controls exercise existing exceptions. The bare STO-5 pointer and formal comment align ownership without adding a report-trust mechanism. This exact form is ready for the owner’s equality-policy choice; “Follow-up ticket” did not authorize it.

**Does this brief or my proposed combination contradict itself?**

No premise-changing brief error was verified; apply notes.md rule 6 exactly, without another void rule. Earlier event/history ambiguity, direct-TCP insertion language and frozen-target replacement overstatement require the distinctions above but leave their questions intact. I falsified no manager primary-source factual claim. Its C1 read objection establishes ambiguity, not total read-session loss. Additional findings concern U2’s endpoints/persistence, E3/U4 formal synchronization and availability collateral. None changes a question’s premise.

No combination is adopted. Q1 stopping can create Q3 residuals; charges survive. Observers need capacity allowances. Q2’s holds remain independent of Q4’s safe restart; an open incident still continues. Combined posture/capacity gates would require both admissions and existing recording bounds, never a new immediate exit. U2R/B3R remain unreviewed; owner costs remain unaccepted.

**Strongest requested counterarguments, not my votes:**

- **Q1:** Deployment trust already carries the safety argument; another controller adds outages and trust while root can bypass it.
- **Q2:** Finite evidence can indefinitely block useful recovery for a human report; explicit unknown history may be better.
- **Q3:** Durable admission and idle reserves may cost more than accepting exhaustion and operator recovery.
- **Q4:** Broken reporters can fabricate ties; historical report/posture assurance may matter more than avoiding occasional restores.