Reviewed `4662d85c7e67c2ebb4c5c8e1c98dc6e1c0efc239`, all required r75 answers, tally and audit. Primary-source and extraction hashes match. Both unpiped gates passed. Tracked files are unchanged; only [review drafts](/var/tmp/provisiond-panel-r74/r76/astra/review-drafts/r76-review.txt) were added. This is source/trace reasoning, not a database experiment.

**Q1 — preferred printed complete form: NONE.**

| Form | Verdict |
|---|---|
| P4C, whole assembly | **AMEND — behaviour changed** |

The strongest argument holds: exclusive control can prevent managed changes before they affect serving components. It cannot prevent privileged bypass or retract replies. PostgreSQL’s empty-list path sets `WAIT_COMPLETE` before the warning branches. [Pinned source](https://github.com/postgres/postgres/blob/b049b4e7b4a159d373ef394bda67f7cf25758998/src/backend/replication/syncrep.c#L964)

Another session’s `SHOW` cannot certify a busy session’s settings. Command-line pinning does not prevent session overrides. P4C correctly relies on trusted SQL, initial local verification, enforced unchanged settings and independently authenticated topology.

Request-start expiry supports the printed **new-use** bounds under functioning local enforcement. Delayed replies and lost notifications cannot extend permission. Transactions admitted before expiry may send COMMIT before or after expiry; their server-decided completion remains possible. No new dispatch, deposit exposure or api success may be emitted after refusal. Previously emitted responses can arrive later. Neither total completion nor durable reporting is bounded.

Opus’s confirmation approach is stronger for individual acknowledgements during bypass, assuming authentic same-history reports. It does not protect read-only external effects. Its transaction reads, later-WAL waits, identity binding and monitor durability remain separate costs/completeness questions; A2 has not become reviewed.

The smallest replacement is **P4C unchanged except the following repairs**. The complete expanded [P4C-R text](/var/tmp/provisiond-panel-r74/r76/astra/review-drafts/q1-p4c-r.txt) is unreviewed.

**R1, behaviour changed.** In P4C’s STO-7 addition, replace:

> Idle sessions MUST be rechecked each round.

with:

> Idle sessions owned by a live component MUST be rechecked each round. Residual-session evidence, whether busy or idle, may persist only while retained session-local evidence, original identity and enforced unchanged settings covering executed and pending SQL remain established; retaining identity alone is insufficient. Otherwise posture is unobservable and refusal latches.

In its CNF-296 addition, replace:

> After a contending engine exits, retain its known backend identity while it remains; residual existence alone is not posture drift.

with:

> After a contending engine exits, retain its known backend identity and setting evidence while it remains and preserve the enforced unchanged-settings proof for executed and pending SQL. Exercise both a still-waiting residual and one that becomes idle before transport-death detection. Residual existence alone is not posture drift; repeat without the setting proof and assert refusal.

The ambiguity matters: a residual can finish waiting and remain idle before TCP death is detected, yet nobody can issue its local recheck. Retained identity alone does not establish the separate setting proof. This repair concerns posture, not capacity accounting; I do not claim every residual inevitably trips P4C.

**R2, behaviour changed; additions where P4C supplies none.**

Append to CNF-57:

> Maintain current STO-7 posture admission throughout the successful-service arms.

Append to CNF-299:

> Maintain current STO-7 posture admission, functioning observation and independently admitted live read sessions throughout the read and re-send success arms; no read success is promised after all such sessions are lost.

In CNF-361 replace “a store that works for the record” with:

> a store that works for the record and current STO-7 posture admission permitting every required record transaction

Apply that condition to its subsequent acknowledged-step-8 stop and successful-record assertions.

Concrete collateral: CNF-299 promises “a read still succeeds”; CNF-361 says “assert its record lands before exit”; CNF-57 says “no `api` write is refused and no engine write exits”. PostgreSQL can remain healthy while posture evidence expires. Those unqualified success assertions then fail.

P4C’s CNF-362 restrictions cover initial recording and after-return success. Shielding, parent defer, marker classification and lost-reply committed effects remain. Refused attempts consume existing budgets. A later stop before sending sends nothing; an in-flight later stop leaves server fate intact and prevents another repeat. CNF-366 already requires arranging that recording can land before either bound expires. `StopRecord.finished_unrecorded_exit` needs no new immediate-exit disjunct.

Conditions/costs: sole authority, trusted SQL/topology, functioning timers, session verification, idle rechecks, administrative connections and residuals, maintenance drainage/shutdown, and observer-failure outages. OVR-18/19 explicitly own alarms and timing. Separate pools establish no observation-capacity guarantee. Green gates establish no deployment coverage.

**Q2 — preferred printed complete form: UO.**

| Form | Verdict |
|---|---|
| UO, including nullable endpoints and evidence/unknown-reason schema | **ACCEPT** |
| F / exact U2R | **AMEND — behaviour changed** |

Strongest argument: incident creation is an execution event; surviving-history evidence is different.

`RestoreTrace.store` assigns `restoreInstant := t.now`; `afterCrash` reloads it; `bootRestore` uses `t.now`. Retaining these assignments with the proposed event documentation sufficiently synchronizes this abstraction. It proves neither SQL timestamp semantics nor certificate correctness. Both proposals preserve `step_three_writes_grace`, whose instant belongs to step (3).

No timestamp-to-insertion delay bound is needed. Let the complete replayed commit/abort record be generated at `g`, inserted at `i`, and certified `b=s−e≤g`. Any commit acknowledged before `b` already inserted its record before `g≤i`; continuous recovery through `i` includes it. Delay merely makes the boundary conservative. [Commit/abort source](https://github.com/postgres/postgres/blob/b049b4e7b4a159d373ef394bda67f7cf25758998/src/backend/access/transam/xact.c#L1446)

Conversely: A samples timestamp 10; B samples 11 and inserts; A then inserts. The prefix through A contains B. Opus’s “A commit generated after that time is absent” is false.

`transaction_timestamp()` denotes transaction start; timestamp precision is finite. Error evidence must cover quantization as well as clock error. F guarantees only acknowledgements strictly before `b`, but reports `(b,f]`; its general fallback certificate need not cover equality. UO’s `[b,f]` is correct. [Timestamp semantics](https://www.postgresql.org/docs/18/functions-datetime.html#FUNCTIONS-DATETIME-CURRENT), [precision](https://www.postgresql.org/docs/18/datatype-datetime.html)

**F-R1, behaviour changed:** replace “Report possible loss within (b,f]” with “Report possible loss within [b,f]”.

**F-R2, behaviour changed:** replace the inherited CNF-365 drill beginning “Promote, as an operator’s restore, the standby with the unavailable report” and ending “no record, no component start” with:

> Promote, as an operator’s restore, the standby with the unavailable report; retain recovery-evidence access without supplying that missing failover report. Satisfy stopping/fencing prerequisites and retain a verified complete last-replayed commit-or-abort record and valid source/event clock evidence. Assert b=s−e, f=restore_instant+e and the persisted report [b,f]. In a separate fresh-incident run, restart before capture and remove the switch segment, but retain an identified archived copy of the record: assert it may supply the certificate. In another fresh-incident run, restart before capture with the switch segment removed and no captured, retained or archived evidence for that record or any valid earlier fallback certificate: no record and no component start until valid evidence is supplied or an evidenced recovery point is chosen. Test upper-bound evidence failure independently. A missing switch segment alone is not the hold condition.

Replace F’s inherited drill pointer accordingly. [Complete finite-only F-R](/var/tmp/provisiond-panel-r74/r76/astra/review-drafts/q2-f-r.txt) remains unreviewed. Even opus’s archived-WAL restriction is insufficient when another certified earlier fallback remains.

UO requires ancestry, continuous-prefix inclusion, source-clock provenance, upper fencing/event-clock evidence, and persisted endpoints/references. Null observations, holes, wrong ancestry and missing evidence cannot become certified bounds. Invalid reporting evidence yields unknown endpoints while consistency, stopping/fencing and acknowledged-record-before-start prerequisites remain. Backup recovery and unavailable old primary use retained evidence or honest unknowns. Continuations—including changed clock allowances—reuse persisted values.

I audited actual restore arms and incident seeds against the candidates’ lists, including CNF-358’s “restore that backup with an open restore record and start the engine”; its restart arms remain distinct. I found no additional actual-restore/incident-seed omission in that scan. Evidence production/capture/retention remains a new operational obligation.

Omitting U4’s allocation gate does not amend “Allocated strictly increasing and never re-issued” or CNF-297’s “exceeds every index a rolled-back row held”. Lost allocations exceeding the gap can still cause reuse. Neither timestamp knowledge nor unknown reporting proves allocation coverage.

Owner choice remains unknown reporting versus indefinite evidence outage. UO’s nullable schema and evidence/unknown-reason retention exceed fable’s original single-field proposal. Repaired finite-only reporting is technically coherent, but F is not acceptable as printed.

**Q3 — preferred printed complete form: NONE.**

| Form | Verdict |
|---|---|
| B3R | **AMEND — behaviour changed** |
| B4*, including its supplied consumer-sentence antecedent | **AMEND — behaviour changed** |

Strongest argument: durable grants prevent spending a departed process’s slot twice. Before-dial durability, one physical attempt per grant, a fenced serialized issuer, charged unknowns and release after fenced fresh absence establish the injection into unreleased grants. Boot identity plus PID/backend_start handles reuse. A cached activity transaction is not fresh evidence; leaving SyncRep is not absence.

Include lock holders, migrators, waiting runners, operator/observer residuals and uncertain attempts; budget internal pools separately. PostgreSQL allocates PGPROC before authentication, role limits and reserve checks. Opus’s no-external-journal advantage is real for authenticated role accounting, but its accepted pre-limit occupancy class does not prove this physical invariant or protected observation. [Initialization source](https://github.com/postgres/postgres/blob/b049b4e7b4a159d373ef394bda67f7cf25758998/src/backend/utils/init/postinit.c#L704)

C1 still fails: while healthy, lose transports in the interrupt-held pre-flush segment and admit replacements against the earlier target; repeat within one incarnation, then freeze and release old commits. After local flush outruns frozen standbys, replacements fail unused but can still consume slots. Deferred `pg_sleep` runs before `HOLD_INTERRUPTS`; it is not that instrumentation. Retained server legs, withheld check replies and verified PIDs provide another honest fixture. Preserve independent read sessions; losing one transport does not establish total read loss.

**B3R repair additions, behaviour changed:**

> Startup acquisition refusal exits for supervisor retry; api acquisition refusal returns overloaded before any transaction; engine worker/periodic refusal is an OPS-49 store error. Successful-service arms of CNF-57 require sufficient admission. Successful-recording arms of CNF-361/362 require admitted recording capacity; refused admission exercises existing recording exhaustion bounds.

For both candidates, CNF-361’s “a store that works for the record” must become:

> a store that works for the record and STO-55 admission permitting every required record transaction

Apply it to subsequent acknowledged-step-8 stop and successful-record assertions. The countertrace is healthy PostgreSQL, a lost original transport, exhausted grants and no replacement for recording. CNF-361 still requires “assert its record lands before exit”. B3R also omits CNF-362’s capacity restriction; B4* supplies it.

The following **complete B4*-derived replacement is UNREVIEWED**. All normative repairs are **behaviour changed**; expanding the supplied consumer antecedent is unchanged relative to B4*. It replaces B4* entirely, without adopting B3R.

> **STO-55:** Replace “Every consumer then has a connection when it needs one and nothing starves the exposure-reducing components behind the workers” with:
>
> Pool sizing reserves consumer checkouts within a running process; opening or replacing a database connection also requires deployment admission.
>
> Replace its residual-backend paragraph with:
>
> Every physical connection attempt by component pools, reconnects, rollout incarnations, startup-lock holders, migrators and waiting runners MUST receive a distinct durable reservation before dialing from one serialized authority outside the protected store. Ingress MUST prohibit bypass and redial under one reservation. Bind grants to component/attempt identity and database boot identity, and to backend PID and backend_start when known. Unknown bindings remain charged. Timeout, transport loss, process exit and rollout completion never release a grant.
>
> Unreleased grants MUST fit component capacity C. Observer/operator/other-client allowances A use the same durable before-dial, one-physical-attempt accounting, ingress fencing and release rules, including residual and uncertain attempts. All ingress, including failed authentication and driver fallback or multihost attempts, is covered before physical allocation; one library connection call is not one attempt. Controller succession fences the former issuer before issuing any new grant.
>
> C+A MUST fit usable capacity after server reservations, with background/server resource pools budgeted separately. Keep separate read/write checkout budgets. Reserve observation capacity within A and protect it against other admission classes at ingress. Bounded privileged observation assumes responsive database, network and control resources; PostgreSQL reserved roles alone do not establish this protection. Without a usable admitted observer session or capacity for a new one, retain charges and refuse growth; no observation-success guarantee survives loss of those resources.
>
> Release requires fencing every delayed arrival/retry and fresh privileged direct-primary evidence, read in a fresh transaction, that the bound backend ended. Leaving SyncRep is insufficient. Unidentified attempts remain charged until fenced server-incarnation termination proves absence. Observer failure denies growth and retains charges.
>
> Accounting loss closes ingress. Recovery requires fenced conservative reconstruction or stopped components and verified primary shutdown before a fresh account; either path fences all old grants and delayed attempts. Existing admitted sessions may continue. Exhaustion alarms, refuses growth and delays replacements.
>
> Startup acquisition refusal exits for supervisor retry; api requests return overloaded before any transaction; engine worker/periodic acquisition refusal is an OPS-49 store error. Existing api-background failure routing remains. Stop-record refusals consume existing bounds and send no SQL. No individual SyncRep backend may be cancelled or terminated to make room; primary shutdown remains STO-7’s exception.
>
> **OPS-47:** Replace “supervisor that restarts it and never runs two” with “supervisor that retries startup subject to STO-55 admission and never runs two”.
>
> **OPS-49:** Add “An attempt denied by STO-55 admission is a store error for this loop and sends no SQL.”
>
> **OVR-18:** Add admission/accounting alarms. **OVR-19:** Register STO-55-owned C, allowances, resource ceilings and authority/reconstruction procedures.
>
> **CNF-290:** Replace “release the first and assert the second then starts” with “with sufficient STO-55 admission available, release the first and assert the second then starts; repeat with exhausted admission and assert delayed startup until verified capacity release”.
>
> **CNF-57/296/299:** Successful-service fixtures retain adequate reservations and live independent read sessions. **CNF-361:** Apply the exact replacement above throughout its successful-record assertions. **CNF-362:** Successful-recording fixtures require admitted recording capacity; refused admission exercises existing exhaustion bounds.
>
> **New drill:** Precheck engine and multiple api pools; freeze standbys, send disjoint writes and identify waiting PIDs. Stop the engine through its recording bound, lose api database transports, and overlap a rollout. Preserve one admitted read session if asserting read success. Verify old PIDs survive outside live pools.
>
> Keep replacement checks enabled; hold check replies/disconnect detection so replacement backends remain while attempts fail unused. Accumulate verified residuals and unreleased grants to exhaustion; assert no extra dial, alarm and bounded refusal. For observer-access assertions retain an independently admitted privileged observer session and responsive database/network/control resources. Separately lose that session and exhaust its allowance: assert no release or growth, not successful observation. Exercise delayed handshakes, PID reuse, competing issuers, observer failure and lost accounting. Restore progress, fence attempts and prove backend termination before release and restart. Never release merely because wait_event changed.

This strengthens B4*’s “Bounded observer/operator/other-client allowances A” paragraph and replaces its unconditional “reserved observer access” assertion. Those are behavioural resource/fixture repairs, not wording fixes.

CNF-290 has no immediate-start deadline; healthy admission remains reachable. Exhausted admission needs the printed policy. Existing StopRecord exits remain unchanged. Owner costs are durable admission, reserves, reconstruction, indefinite restart delay and possible shutdown. Capacity safety guarantees no recovery deadline.

**Q4 — preferred printed complete form: T-known.**

| Form | Verdict |
|---|---|
| T-known, T1–T6 together | **ACCEPT; technically ready for owner equality-policy choice** |

Every replacement anchor is unique. STO-54’s premise is “every acknowledged commit was flushed by one of them, and both hold a prefix of one WAL sequence”: either valid equal maximum contains them all.

Greater may restart with the other guards; behind requires operator restore. Unavailable reports and equal numbers on different timelines establish no valid tie. Known unsafe commits and known waiter cancellation remain restore-class. The restricted fixture supplies knowledge to the procedure without introducing a detector or a general knowledge qualification.

With an open incident, “A marked step does not run again”: complete the tenant bump if step (3) is unmarked; never repeat it if marked. Equality closes nothing. Engine startup generation remains distinct. Old-process stopping, old-primary fencing and other-standby streaming remain.

No further fixture restriction is needed. Equality authenticates neither reports nor hidden history. Only declared equality/control/pointer/comment changes enter. Fable’s earlier knowledge restriction was behavioural under rule 1; the tally’s disposition was correct. “Follow-up ticket” did not authorize equality policy.

**Does the brief or my proposed combination contradict itself?**

No contract-question premise is removed. **Apply notes.md rule 6 exactly as written; this prompt adds no void rule.** Candidate-completeness defects explain my AMEND votes; the brief expressly leaves completeness open. I falsified no additional manager source claim about timestamp ordering, CNF-358, pre-limit occupancy or `pg_sleep`.

One operational discrepancy remains: the brief calls the >80% rule current, while STATE.md records a claimed later owner amendment and Codex WEEK 83% at launch. I have not independently authenticated that amendment. The r75 closing sentence is not a launch receipt. This affects no question’s premise or vote.

No union is adopted. Q1 refusal can create Q3 residuals; observers consume capacity. Q2 applies to restore incidents, not Q4’s ordinary restart; open incidents still continue. None waives the allocation obligation.

**Strongest requested counterarguments, not my votes:**

- **Q1:** Per-commit confirmation protects acknowledgements through bypass; another controller adds outages.
- **Q2:** Unknown may become routine; finite-only admission forces evidence discipline.
- **Q3:** External accounting and reserves may cost more than accepting exhaustion and operator recovery.
- **Q4:** Broken reporters can fabricate ties; conservative operator restore trades credential disruption for caution.