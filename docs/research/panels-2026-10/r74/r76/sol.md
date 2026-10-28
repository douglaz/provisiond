Reviewed `4662d85c7e67c2ebb4c5c8e1c98dc6e1c0efc239`. All four r75 answers, tally/audit, candidates and extraction hashes checked; both unpiped gate runs passed. Tracked files remain unchanged. This is source-grounded text/trace review, not a measured prototype. No source application, tracker, commits, agents or remote mutation.

**Apply notes.md rule 6 exactly as written; this prompt adds no void rule.**

**Q1 — preferred printed complete form: NONE.**

| Form | Verdict |
|---|---|
| P4C, whole package | AMEND — behaviour changed |

Managed-change prevention and request-start expiry are coherent under the printed trust/enforcement assumptions. Retaining a residual identity alone proves no setting: retain its original local verification plus unchanged-setting proof, or refuse as unobservable. This needs no Q3 capacity ledger. Command-line pinning protects global reloads, not every session override.

The omitted collateral is CNF-299’s “a read still succeeds” (10:1098–1100), and CNF-362’s separate Inside execute successes “with the store working again before the Stop-record bound ends” (10:1709–1717). PostgreSQL can work while posture expiry refuses those reads/records. The initial and After execute replacements do not explicitly qualify these separate cases.

Before: those success fixtures retain their quoted setups. Replacement: R1/R2 below add current posture admission. Both repairs are behavioural. CNF-361’s “a store that works for the record” and CNF-366’s “arrange that the record can land” already require recording-capable setups; I count no independent loss there. Denied tries fit `StopRecord.finished_unrecorded_exit`; no new exit or theorem weakening follows.

Strongest argument: control managed mutation before use. Opus’s per-commit direction is stronger for acknowledgement safety under bypass, but needs server/session binding and repaired wait/fixture contracts; its incomplete A2 gains no acceptance here. It does not protect every read-based effect.

OVR timing/alarm ownership is printed. Budget observer attempts/residuals; failed access must refuse. For a provisiond background component, OVR-17 says “Every component that runs without a caller MUST be assigned to a module”. Hosting/privileges need operational evidence. Owner costs: control infrastructure, setting verification, restricted administration, reserves, maintenance/observer outages and API exits.

**Complete replacement P4R — UNREVIEWED.** Only R1/R2 add repairs; all other P4C contract text follows unchanged. All amendments are behavioural against the pin. This is not acceptance of printed P4C.

**STO-7 additions**

Insert immediately after the paragraph ending “every write waits.”:

> The deployment MUST identify a sole change authority controlling database configuration, reloads, role/database defaults, deployed SQL, endpoint routing and server credentials. Ordinary administrative paths MUST be restricted to that authority. Session-setting invariants rely on trusted component SQL; parameter ACLs do not restrict user-settable GUCs. Changes not established safe MUST be refused while components serve. Before maintenance can invalidate that proof, the authority MUST close component admission, stop every component and fence pending connection attempts. Process exit is not backend drainage: outstanding component backends MUST clear naturally, or the primary MUST be shut down before such maintenance. No component may resume until safe posture is verified.
>
> An independent authenticated observer MUST start a complete round every C and finish or declare failure within Q, using a fresh direct administrative session outside component pools. It MUST check effective replication configuration, primary node/boot identity and role, and the topology evidence defined by STO-55. Each component MUST explicitly set and verify synchronous_commit=on on every connection, verify applicable transaction settings before use, and prohibit subsequent lowering/resetting. Idle sessions MUST be rechecked each round. Busy-session evidence persists only while original session identity and enforced unchanged settings are established; otherwise it is unobservable. An observer’s SHOW/pg_settings reads do not prove another session’s GUCs. A known residual backend alone is not evidence of unsafe replication configuration or topology; this observer does not establish a residual-capacity bound.
>
> Unsafe or unobservable posture evidence MUST latch refusal and alarm. Each component MUST gate requests, new transactions, claims, passes, provider-mutation dispatch and deposit exposure on current authority evidence. Evidence MUST expire within V measured monotonically from its request’s start, never its delayed receipt; absence of notification cannot extend it. On refusal api rejects pre-transaction requests as overloaded and exits within A; the engine stops under OPS-21. A stop-record attempt is subject to the same gate. Already-sent COMMIT retains its checkout until reply, dead transport or process exit; unfinished api requests receive no success after refusal. Resumption requires operator reset, verified configuration/topology, discarded old connections and passing new-connection checks; changed history also requires STO-54’s classification/procedure. Reset does not erase recorded posture violations.
>
> This permission gates new use, not completion of transactions already admitted. A transaction admitted before permission expires can still send COMMIT after expiry; an already-sent transaction retains its server-decided fate. No new external dispatch, deposit exposure or api success is permitted after refusal. Nothing here asserts prevention of a bypass commit between observation and refusal, or revocation of an action already dispatched. Local monotonic enforcement and watchdog execution MUST function for the refusal/exit bounds to hold.
>
> Declare startup-validated finite positive C, Q, V and A, with C+Q<V, preserving the existing store timeout ordering. Persistent observable drift is observed or declared unobservable within C+Q and new use is refused deployment-wide within C+Q+V. Those bounds do not claim a durable report by that time, completion of an admitted transaction, or detection of a privileged transient change reversed between observations. Administrative bypass remains outside prevention; the authority’s durable change journal records changes it mediates.

STO-7’s existing “MUST NOT release its connection before the reply arrives or the transport is found dead”, deposit check, warning treatment and “other than by shutting the primary down” exception retain their text. No new lost-reply category, backend-cancellation permission or early record exit is proposed.

**STO-55 topology addition**

Insert after its transaction-mode pooler paragraph:

> The change authority MUST establish topology from controlled routing, endpoint and credential ownership, independently of the component SQL path. End-to-end authenticated database connections with keys confined to database endpoints are one admissible construction. SQL identity samples alone are insufficient. Observation connections and their possible residuals MUST be included in the deployment’s connection budget; no service or observation-capacity guarantee follows merely from a separate pool.

This does not import Q3’s external reservation mechanism.

**OPS-49 addition**

Append to the store-error handling contract:

> An attempt denied by STO-7’s posture gate is a store error for this loop and sends no SQL. A refused record attempt consumes the existing Stop-record and Store-retry bounds; it creates no immediate new exit.

**OVR-18 / OVR-19**

Append to OVR-18’s alarm roster, without rewriting its other entries:

> The posture refusal latch is alarmed; see STO-7.

Add these OVR-19 rows (ownership stays in STO-7/STO-55):

| Parameter | Mandated by | Type | Startup-validated |
|---|---|---|---|
| Posture observation cadence C | STO-7 | finite positive duration | yes |
| Posture round deadline Q | STO-7 | finite positive duration | yes |
| Posture evidence lifetime V | STO-7 | finite positive duration, C+Q<V | yes |
| api refusal drain bound A | STO-7 | finite positive duration | yes |
| Posture change authority, observation, reset and topology procedure | STO-7, STO-55 | human procedure and trust/inventory ownership | no |

**CNF-296 addition**

Append these paragraphs within the item, before its owner references/history:

> Retain independently admitted live read sessions and functioning posture observation throughout the existing unchanged-configuration stall traces. A healthy busy COMMIT retains its setting evidence under the enforced unchanged-session conditions; legitimate standby unavailability alone does not trip the posture latch. After a contending engine exits, retain its known backend identity while it remains; residual existence alone is not posture drift. Assert the later one-standby success trace remains reachable.
>
> With authority enforcement enabled, attempt an unsafe replication change while components serve: assert refusal before the change takes effect. Exercise controlled maintenance through closed admission, stopped components and either verified backend drainage or primary shutdown; resume only after verification and operator reset.
>
> Separately disable the change boundary to inject a persistent empty standby list immediately after a retained-session check. Permit a pre-detection local commit and do not describe it as prevented. Assert observation/failure by C+Q, refusal of new use everywhere by C+Q+V, no new api success after refusal, api exit within A of refusal and engine stopping under its existing bounds. Repeat idle, with disconnected components, lost latch notification and delayed evidence replies; old challenges never extend expiry. Restore safe configuration without resetting: assert the latch remains. Reset only by the stated procedure.
>
> Keep one transaction admitted before expiry open across expiry. Assert its server-decided completion remains possible while no subsequent new transaction, provider dispatch, deposit exposure or api success passes refusal. Exercise an already-sent waiting COMMIT through stop expiry: retain its checkout while its process lives and transport remains live; never cancel or terminate the backend to force an outcome. Do not assert completion within the posture detection bound.

**CNF-299 addition — REPAIR R1, behaviour changed**

Append within the item before owner references/history:

> Maintain current STO-7 posture evidence throughout the existing capacity-only success traces, including the independent read and the successful re-send after checkout capacity returns.

**CNF-365 addition**

Append within the item before its owner references/history:

> Start with unsafe posture before first use and assert refused admission. On an already fronted client-to-pooler connection, introduce transaction-mode pooling and force backend reassignment, then repeat with unchanged PID observations; controlled independent topology evidence must refuse that path. SQL identity samples alone never certify absence of pooling. Test loss of endpoint authentication/inventory evidence and query failure: evidence expires and refusal applies. A direct already-established authenticated TCP session is a different case from a retained pooler client session. Do not infer historical safety or absence of a transient privileged bypass from current safe configuration alone.

**CNF-362 success restrictions and refusal control**

**REPAIR R2 — behaviour changed.** Insert immediately after the item’s title, before its first quotation:

> Every case asserting successful recording, including the Inside execute marker-repeat cases, runs with STO-7 posture admission permitting the required recording transactions until the record lands. Cases injecting refusal, a later stop, supersession, or bound exhaustion retain their stated outcomes.

Replace “with a working store.” with:

> with a working store and verified STO-7 posture throughout recording.

Replace the sentence “in each case the engine survives the stop and the store works before the Stop-record bound ends, unless the case says otherwise.” (line wrapping ignored) with:

> in each case the engine survives the stop and the store works with STO-7 posture admission available before the Stop-record bound ends, unless the case says otherwise.

Append within the item before owner references/history:

> With PostgreSQL working but posture admission denying every record attempt from its beginning, assert no SQL is sent, existing exhaustion bounds end recording, the row remains running, and restart recovery applies. Verify that a later stop, superseded generation or a bound ends recording only under its existing rule; posture refusal is not an additional immediate exit.

**Q2 — preferred printed complete form: UO.**

| Form | Verdict |
|---|---|
| UO, including its entire schema/unknown policy | ACCEPT |
| F / exact U2R | AMEND — behaviour changed |

Both retain event meaning: RestoreTrace.store writes restoreInstant := t.now; afterCrash reloads it; bootRestore uses t.now. The printed documentation synchronizes that abstraction with the new insert-transaction event, without proving SQL semantics. Neither endpoint becomes execution now; step_three_writes_grace retains completeProcedure’s own instant.

The inclusion proof needs no timestamp-to-insertion delay bound. Let g generate the complete replayed commit OR abort record and let b=s−e≤g under the certified source-clock bound. For any component acknowledgement a<b, its commit record was inserted before a, hence before g and this later record’s insertion. The continuous matching recovered prefix therefore contains it. Timestamp order need not equal WAL order. [Pinned commit/abort source](https://github.com/postgres/postgres/blob/b049b4e7b4a159d373ef394bda67f7cf25758998/src/backend/access/transam/xact.c#L1446). For example A samples 10, B samples 11 and inserts, then A inserts: a prefix through A includes B, refuting opus’s “A commit generated after that time is absent”.

Equality is separate: the certificate covers a<b, not a=b. Finite timestamp precision cannot establish a strict real-time ordering between equal readings. Bounds must account for the actual reported timestamp precision/rounding. UO’s [b,f] is conservative; F’s (b,f] is unsupported when b=f or loss occurs at the excluded boundary.

F amendment F1, first paragraph: before “Report possible loss within (b,f]”; replacement “Report possible loss within [b,f]” — behaviour changed, reporting payload.

F amendment F2, its inherited CNF-365 fixture. Before:

> Promote, as an operator’s restore, the standby with the unavailable report; assert `lost_window_starts_at` is its last replayed transaction’s time less the allowance; repeat with that store restarted and its switch segment removed before capture: no record, no component start.

Replacement:

> Promote as an operator restore with certified finite endpoints, using a captured complete replayed commit-or-abort record for b=s−e; assert persisted b and f=restore_instant+e. Repeat after restart without any valid lower-bound certificate, including from retained or archived WAL or an evidenced earlier prefix: no record and neither component starts until valid bounds are supplied or an evidenced recovery point is chosen.

Behaviour changed. Removing only the switch segment does not exclude an archive copy; even opus’s added “and no retained or archived WAL holding that record” does not exclude a different, earlier certified fallback permitted by F. This fixture reference cannot silently inherit either repair. F1/F2 are not counted acceptance of F.

UO permits nullable endpoints and requires a non-null incident-keyed evidence/unknown-reason reference. Invalid/inconsistent evidence yields unknown bounds; existing restore prerequisites stand. The replay observation can be null or erased by normal startup. [PostgreSQL recovery functions](https://www.postgresql.org/docs/18/functions-admin.html#FUNCTIONS-RECOVERY-INFO-TABLE). A finite upper endpoint needs event-clock and stopping/fencing evidence; a filename or bare LSN proves neither endpoint. Unavailable primary, backup recovery, null observation, holes and wrong ancestry do not manufacture certificates. Capture/production/retention are new deployment obligations, not existing facts. Persisted endpoints/evidence survive interruption and later changes in clock allowances; continuation does not recompute them.

I checked actual restore arms and open-row contexts against the checklist. CNF-358 expressly says “restore that backup with an open restore record and start the engine” (10:1540–1543); its restart arms remain distinct. CNF-288 points at CNF-295; CNF-312 says “This item does not drive route 2 or establish restore conformance”. Schema setup applies to every constructed incident; the named lists are not exhaustive claims.

Allocation remains defective when restored maximum m, skip g and lost allocations through m+n have n>g+1. The column says “Allocated strictly increasing and never re-issued” (05:924); CNF-297 says “exceeds every index a rolled-back row held”. Omitting U4’s additional enforcement gate waives neither obligation and adds no replacement allocation mechanism.

Strongest argument: separate event time from surviving-history bounds. UO permits recovery with honest uncertainty; repaired F could enforce finite reporting through indefinite outage. The owner chooses. UO costs nullable schema, evidence/unknown-reason retention and clock/capture discipline: substantially more than one nullable column. STO-54’s “MUST start neither component until the transaction that commits STO-56’s record ... has been acknowledged” remains a prerequisite, not reporting evidence’s optional hold.

**Q3 — preferred printed complete form: B4*.**

| Form | Verdict |
|---|---|
| B3R | AMEND — behaviour changed |
| B4*, with its supplied consumer antecedent | ACCEPT, under its printed capacity/control obligations |

That antecedent is: “Pool sizing reserves consumer checkouts within a running process; opening or replacing a database connection also requires deployment admission.”

The injection holds: each covered physical backend has its distinct durable grant before dialing; unreleased grants≤C, other attempts/residuals≤A. Ingress, durable serialization and controller fencing must enforce these bounds across failover. Libpq fallback/multiple hosts require separate grants for separate physical attempts, not one grant per library call. [libpq connection semantics](https://www.postgresql.org/docs/18/libpq-connect.html#LIBPQ-MULTIPLE-HOSTS). Unknown attempts stay charged; PID/backend_start plus database boot identity prevent identity reuse from proving absence. Fence delayed arrivals before a fresh direct-primary observation; leaving SyncRep proves no termination. Cached activity is insufficient; B4* explicitly requires a fresh transaction. [Statistics snapshot semantics](https://www.postgresql.org/docs/18/monitoring-stats.html#MONITORING-STATS-VIEWS).

C/A must include the lock holder, migrators, waiting runners and observer/operator uncertainties; server-internal pools have separate ceilings. Privileged observation depends on those controlled resource allowances and functioning server/network resources. PostgreSQL reserve roles alone do not protect against pre-authentication slot occupancy. Observation failure retains charges and denies growth; it does not promise useful reads after every admitted read session is gone.

B4* expressly routes startup refusal to supervisor retry, API refusal to overloaded before a transaction, and worker/periodic refusal to OPS-49. Its successful CNF-57/296/299 fixtures retain capacity and independent reads; CNF-362’s successful recording has admitted capacity. Denied records consume existing bounds without cancellation or a new exit. OPS-47’s changed supervisor clause permits delay, and CNF-290 preserves “release the first and assert the second then starts” with healthy capacity. The original contains no immediate-start deadline. Exhausted capacity may delay restart indefinitely.

B3R omits that complete routing and recording/release fixture coverage. With PostgreSQL working but all grants retained, CNF-362’s record cannot land. AMEND B3R’s generic “OPS-49: denied admission sends no SQL and consumes existing store-error bounds” by appending:

> Startup acquisition refusal exits for supervisor retry; api acquisition refusal returns overloaded before any transaction; worker and periodic acquisition refusal uses OPS-49.

For its CNF-296/299 edit, before: “Retain independently admitted live read sessions and functioning admission/observation throughout these existing success traces.” Replacement: retain that sentence and append:

> CNF-57’s successful release fixtures retain adequate admission. Every CNF-362 case asserting successful recording has admission for the required transactions until the record lands; refused admission exercises the existing exhaustion bounds.

Both additions are behaviour changed; no repaired B3R is counted ACCEPT.

C1’s guard objection survives: after a locally flushed waiting commit outruns frozen standbys, new checks fail unused. It does not bound pre-freeze reconnect residue or failed-check backends. While healthy, one incarnation repeatedly replaces transports with old COMMITs paused before insertion/local flush and server legs retained; freeze, release, verify SyncRep PIDs. Startup counting misses them. Later failed checks also occupy physical slots. Opus’s deferred pg_sleep trigger precedes HOLD_INTERRUPTS and is not demonstrated instrumentation inside the protected segment. B4* instead withholds check replies/disconnect detection and verifies exact residual PIDs. Let R be the preserved, prechecked api read session; cutting a write transport need not cut R.

Opus’s strongest dissent remains that role accounting retains authenticated residuals without an external journal. The source’s concurrent role checks err toward refusal; I found no successful-session over-admission race. But PGPROC allocation precedes authentication and role/reserve checks. Accepting that weaker pre-limit occupancy class does not prove this question’s physical-attempt invariant; authentication_timeout is not a bound on every initialization/cleanup phase.

Strongest argument: process loss cannot spend the same physical slot twice. Owner costs: durable admission, controlled ingress, reserves, indefinite restart delay and possible reconstruction shutdown. Capacity safety supplies no general availability guarantee.

**Q4 — preferred printed complete form: T-known.**

| Form | Verdict |
|---|---|
| T-known as a whole | ACCEPT; technically ready for the owner’s equality-policy choice |

Every edit anchor matches once. Under “every acknowledged commit was flushed by one of them, and both hold a prefix of one WAL sequence”, equal valid maxima contain identical acknowledged history: either may restart. Unequal greater/behind remain distinct; unavailable reports and other timelines do not use equality. Old processes stop, the old primary is fenced, and the other standby must stream.

The known-violation restriction supplies procedure knowledge for injected unsafe-commit/cancelled-waiter controls. It exercises classification without a historical detector or a new STO-54 knowledge qualification. Unknown history is not certified safe. Fable’s earlier restriction was behavioural under rule 1; the tally’s disposition was correct.

With an open incident, “A marked step does not run again”: before step (3), finish its tenant bump; afterward, do not repeat it. Equality closes nothing. Engine startup-generation advancement remains separate. No declaration/theorem changes or extra guards are needed. Equality authenticates neither reports nor hidden history. Owner policy and credential/availability tradeoff remain undecided; “Follow-up ticket” was not approval.

**Does this brief or my proposed combination contradict itself?**

No verified error changes a question’s premise; no tally is void under rule 6. P4C’s collateral and F’s fixture/report contract are incomplete; that changes verdicts, not the drift/history premises. The older inversion-delay objection is unnecessary for the earlier-acknowledgement certificate. The manager’s corrected CNF-358, trigger-ordering and healthy-capacity CNF-290 distinctions hold. The r75 closing launch sentence is not a receipt; I infer no launch authorization or quota compliance from it. STATE’s preparation/changed-quota account needs receipt reconciliation; it changes no question’s premise.

No combination is adopted. Q1 exits create residuals Q3 must retain; posture observers consume Q3 allowances, and both gates would have to permit new work/recording without adding an immediate exit. Q4 restart does not create a Q2 reporting incident, while an existing incident continues through equality. B4* does not authorize either reporting policy or equality policy.

**Strongest requested counterarguments — not my votes:**

- Q1: another control plane adds outages and trust while privileged bypass still exists.
- Q2: unknown may become routine; requiring finite evidence makes reporting auditable, at potentially indefinite service cost.
- Q3: role accounting plus operator recovery may cost less than a durable admission authority and idle reserves, accepting the weaker invariant.
- Q4: broken reports can fabricate equality; conservative operator recovery buys caution at credential and availability cost.