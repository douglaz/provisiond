**Final picks: Q1 P; Q2 E; Q3 B; Q4 T.** These are technical recommendations with the conditions below, not acceptance of a complete amendment.

Read the pinned sources and panel-root R74 notes. Both required gate runs passed unpiped. Tracked files remain unchanged; [draft notes](/var/tmp/provisiond-panel-r74/astra/r74-reader-draft.txt) are the only added file. No database prototype was performed.

**Q1 — P: enforce the configuration boundary, with bounded detection**

A reload empties the standby list immediately after a successful check. A local acknowledgement can precede the next poll. PostgreSQL determines `synchronous_commit` behavior at commit time; an empty standby list removes the remote wait. Detection cannot undo that acknowledgement. [PostgreSQL WAL settings](https://www.postgresql.org/docs/18/runtime-config-wal.html)

Proposed additions to **STO-7**, [05-persistence.md](https://github.com/douglaz/provisiond/blob/4662d85c7e67c2ebb4c5c8e1c98dc6e1c0efc239/05-persistence.md#L170) — **AMEND, behaviour changed**:

> The deployment MUST mediate changes to replication settings, database endpoints, routing and pooling through one authenticated change authority. Components MUST have no configuration-management credentials. The primary MUST start with `synchronous_standby_names` pinned on its command line to the required names.
>
> Components MUST explicitly set and verify `synchronous_commit = on` on each physical session. Only the trusted store driver and audited database routines may change session settings; they MUST NOT lower it. Resetting settings invalidates verification before further use. Session evidence MUST identify the backend, server incarnation and successful setting verification.
>
> The authority MUST refuse effective protected-configuration or topology changes while components run. Before applying a change it MUST inhibit replacement starts, stop components under their stop rules, and either prove all potentially committing backends have ended or shut down the primary. It MUST verify safe posture before permitting startup. No live backend may be replaced behind a retained component connection.

Command-line settings cannot be changed globally without restarting. `SHOW` observes the current session; role defaults affect new sessions. Consequently, neither another session’s `SHOW` nor revoking administrative privileges proves a component cannot lower this user-settable setting. Trusted component SQL remains necessary. [PostgreSQL setting parameters](https://www.postgresql.org/docs/18/config-setting.html)

Runtime addition — **AMEND, behaviour changed**:

> An independent deployment observer MUST renew evidence from the actual primary, authenticated host/network/pooler inventory, and every component’s session registry. Session evidence requires initial session-local verification and exclusive control over subsequent setting changes. A busy session is not certified by another session’s `SHOW`. Missing identities, unaccounted sessions, unverifiable transitions, unsafe configuration or stale evidence MUST latch refusal. SQL probes alone MUST NOT certify topology.
>
> Declare finite positive maximum evidence age H, query deadline Q, refresh cadence C and enforcement delay J, with C + Q < H. Each renewal MUST use a fresh component challenge and gather evidence afterward. Permission expires no later than H after that component sent the challenge, measured monotonically; delayed replies cannot extend it. The observer MUST durably retain and distribute the latch. Components MUST check permission before new transactions and new work dispatches.
>
> Persistent observable drift therefore stops new use within H + J of taking effect. Transient violations require the authority’s durable change record; polling alone does not guarantee their detection.
>
> On refusal, `api` MUST reject new work `overloaded` before a transaction, close its listener and exit within a stated finite positive drain bound. The engine MUST claim nothing new, begin no periodic pass, and initiate stopping. Stop-record attempts may use only independently verified safe posture; otherwise admission refuses them within their existing bounds. Already-sent transactions retain their server-decided fate. Sent COMMIT connections remain retained until reply, dead transport or process exit. No latch response cancels or terminates a `SyncRep` backend.
>
> Only the authority may clear the latch, after stopping affected incarnations, verifying posture and determining whether history was endangered. Configuration repair alone does not certify earlier acknowledgements. Replacement connections undergo the existing connection check.

**Trust and races.** P prevents managed changes because they cannot cross live use. Its trust boundary includes component SQL, administrative credentials, endpoint certificates, routing and inventory completeness. A privileged bypass immediately after observation can still produce a local acknowledgement before expiry. A proxy capable of impersonating the trusted endpoint defeats topology evidence. No PostgreSQL atomic primitive is claimed.

**Conformance additions beside CNF-296/365 — behaviour changed:** test retained-connection drift, both with boundary enforcement and with enforcement deliberately disabled to exercise detection. Include a pre-detection acknowledgement and assert it is not described as prevented. Test unsafe-before-first-use refusal, unchanged healthy posture, legitimate standby unavailability, observer/query failure, lost latch delivery, delayed evidence, backend reassignment and an already-sent COMMIT. Standby unavailability alone must not trip the posture latch when configuration evidence remains available; existing reads remain possible.

These tests establish observed traces and bounds. Deployment controls establish exclusive mutation paths and trustworthy topology. Transaction pooling actually reassigns server connections between transactions. [PgBouncer features](https://www.pgbouncer.org/features.html)

**Collateral and owner choice.** STO-7’s “short of its process exiting” remains essential. OPS-21 says “The deployment’s supervisor MUST wait at least the Stop-record bound”; no earlier kill is introduced. CNF-362’s “with a working store” can otherwise flip when PostgreSQL works but observation fails: explicitly require verified posture in its success fixture and add refused admission—**behaviour changed**. Its refused-store trace and `StopRecord.finished_unrecorded_exit` need no weakening.

OVR-18 needs the latch alarm; OVR-19 needs the STO-7 timings, `api` drain bound and human authority/topology procedure. The owner must accept independent monitoring, restricted administration and maintenance downtime. **P1.**

**Q2 — E: conservative surviving-history boundary; missing evidence holds startup**

Example: retained evidence places an insertion-position sample L after trusted time 10:00. Recovery contains the complete matching history through L; the old primary was fenced by 10:07. Report possible loss during `(10:00,10:07]`, not seven minutes of demonstrated loss.

Replace STO-54’s instant/report language — **AMEND, behaviour changed**:

> `restore_instant` is a conservative lower bound b on surviving acknowledged history: every transaction acknowledged in the source history before b belongs to the recovered committed history. It is neither promotion time nor component startup time, and does not assert an exact wall-clock snapshot.
>
> Before committing the restore record, retain evidence keyed by incident id identifying the source cluster, timeline ancestry, recovered endpoint, provenance, clock uncertainty and derivation of b. Publish b, an upper bound f on when the old primary could still acknowledge before fencing, and the possible-loss interval `(b,f]`. Its duration is an upper bound, not measured loss.
>
> A sufficient certificate records a trusted clock interval immediately before sampling `pg_current_wal_insert_lsn` on the identified source. Its lower clock bound may be b only after verifying a consistent recovered prefix containing every WAL record through that position on matching ancestry. Retain the certificate outside the loss’s failure domain.
>
> Missing WAL, divergent ancestry, unbounded clock uncertainty or insufficient replay invalidate that certificate. A bare LSN, last replayed transaction timestamp, backup filename or restart time is insufficient.
>
> Without a finite verified b, keep both components stopped and create no record containing a guessed instant. The operator must obtain verifiable evidence or recover an evidenced point. Backup restores use the same definition. Persist b once; continuation uses that value and retained evidence.

Add to STO-56: “`restore_instant` has STO-54’s meaning; retained evidence and the report are keyed by `id`.”—**behaviour changed**, despite retaining the schema.

Sampling insertion position *after* the time observation covers earlier acknowledgements even if prior drift permitted asynchronous acknowledgement. This certificate does not require a new synchronous write. Continuous recovery and verified ancestry establish inclusion; numerical comparison alone does not.

`pg_last_xact_replay_timestamp` reports the primary-generated commit/abort timestamp of the last replayed transaction, not a certificate covering all earlier wall-clock history. Physical recovery requires continuous archived WAL. [Administration functions](https://www.postgresql.org/docs/18/functions-admin.html), [continuous archiving](https://www.postgresql.org/docs/18/continuous-archiving.html). The certificate protocol is a proposed deployment proof obligation, not an experimentally verified implementation.

**CNF-295 additions — behaviour changed:** exercise a known certificate; unavailable old primary with retained evidence; missing certificate, clock discontinuity and WAL hole each holding startup; ordinary physical backup plus replay through an evidenced endpoint; interruptions before and after step marks preserving b. A backup timestamp alone must fail. Complete step (3) much later than b and assert its independent grace anchor.

**Consumers and collateral.** STO-54 says “the instant is read from the record and never re-computed”. STO-56 specifies “step (3)’s instant plus one re-derivation interval”. In [Restore.lean](https://github.com/douglaz/provisiond/blob/4662d85c7e67c2ebb4c5c8e1c98dc6e1c0efc239/tools/formal/Provisiond/Restore.lean#L92), `Record.restoreInstant`, `RestoreTrace.store` and `afterCrash` carry the instant; `step_three_writes_grace` uses the step event’s time. The model supplies arbitrary `now`; it does not prove historical derivation. No grace theorem needs weakening.

CNF-295’s numeric reporting assertion changes. Recovery-success fixtures, including CNF-297, CNF-358 and CNF-370, need explicit verified boundaries—**behaviour changed**—so their startup assertions remain reachable.

The owner must accept potentially indefinite outage and retained evidence/clock discipline. OVR-19 should register STO-54’s human evidence procedure and any declared clock-error or retention parameters. **P2.** Q4’s safe tie requires no invented restore timestamp.

**Q3 — B: durable permits for physical connection attempts**

Example: `api` transports die while their commits wait; the engine exits. Replacements consume new permits while old permits remain charged. Admission eventually stops before residual backends consume recovery reserves.

Add to STO-55 — **AMEND, behaviour changed**:

> A deployment-wide authority outside the protected PostgreSQL store MUST serialize durable reservations before every physical connection attempt. Component pools, reconnects, startup-lock connections and rollout incarnations MUST use controlled ingress without bypass.
>
> Each permit authorizes at most one attempt, without automatic redial. Bind it to component incarnation, attempt identifier, target server incarnation and, once known, backend PID plus `backend_start`. Reusing a healthy physical session consumes no additional permit.
>
> Let C be the component allotment and A the bounded allowances for operator, observer, migrator and other admitted clients. C + A MUST fit within usable connection capacity after server-reserved slots. Outstanding component permits MUST never exceed C. Reserve read capacity separately from write capacity; retain live-pool limits.
>
> A permit survives timeout, failed handshake, dead transport, process exit and rollout completion. Release it only after the issuer cannot create or retry that attempt and authoritative evidence proves its backend ended. An absent activity row is insufficient while an attempt can still arrive. Unidentified attempts remain charged until old ingress attempts are fenced and server-incarnation termination proves they cannot survive or appear. Incarnation-lease expiry never releases a permit.
>
> Exhaustion MUST refuse physical growth and delay replacements. A checkout unable to obtain an admitted session returns the existing overloaded refusal within its bound. Stop-record attempts retain their existing bounds. Existing admitted sessions may continue within their budgets.
>
> Observer failure freezes releases and new admissions. Accounting-state loss closes ingress and suppresses replacements until conservative reconstruction, or fenced primary shutdown and a fresh incarnation, establishes the account. Recovery MUST NOT cancel or terminate `SyncRep` backends.

**Authority and proof.** Use a durable serializable journal, one admission leader and fail-closed ingress; replacement leaders fence prior dialers. Observe backends through independently reserved privileged access and fresh transactions: PostgreSQL caches activity observations within a transaction. [PostgreSQL statistics](https://www.postgresql.org/docs/18/monitoring-stats.html)

Every actual component backend maps injectively to an outstanding permit:

`live + residual ≤ outstanding permits ≤ C`.

Bounded noncomponent admission contributes at most A. This is a capacity invariant, not continued-service assurance. It promises neither writes during a stall nor reads after all admitted read sessions die. Reserved slots support privileged recovery access but do not implement application accounting. [Connection settings](https://www.postgresql.org/docs/18/runtime-config-connection.html)

**Conformance addition beside CNF-296 — behaviour changed:** precheck multiple `api` pools; stall replication; fill write pools and identify `SyncRep` backends. Sever database transports, stop the engine and launch overlapping replacements. Observe old backends surviving their client incarnations.

Replacement connections must still satisfy STO-7; do not bypass its check to manufacture more waiting commits. Repeatedly blackhole replacement position-query replies and disconnects, retaining their server backends beyond connection deadlines. Combine those residuals with original waiters until C is reached. Assert the total exceeds the live-pool allowance before exhaustion. Request cancellation alone does not establish this case.

Test reserved operator access, no overrun, delayed handshakes, observer failure, accounting loss, competing supervisors and PID reuse. Restore replication/transports, prove termination, release permits and resume.

**Collateral and owner choice.** OPS-47 specifies “an external supervisor that restarts it”; qualify restart admission by STO-55. CNF-290 says “release the first and assert the second then starts”; require available admission and add exhausted-admission delay. Both are **behaviour changed**. Preserve CNF-296/299 read-success fixtures with admitted read sessions; exhaustion tests promise no universal read availability. Refusals consume existing stop bounds; no StopRecord theorem needs weakening.

OVR-19’s STO-55 row gains C, allowances, authority/reconstruction procedure and monitoring access; OVR-18 gains exhaustion/accounting alarms. The owner must choose reserve cost, external authority durability and potentially indefinite restart delay. **P3**, independent of Q1.

**Q4 — T: either maximal tied standby may restart**

Equal prefixes of the same history contain the same acknowledged WAL records. Conservative restore offers no additional history-preservation benefit under the stipulated valid evidence.

Use T’s exact STO-54 substitutions — **AMEND, behaviour changed**:

> “and a standby whose reported end is at least as far ahead as the other’s is promoted (either may be chosen when they are equal):”

> “or of a standby whose reported end is behind the other’s,”

Replace “so that one holds them all” with “so any standby at the maximal reported end holds them all”—**behaviour unchanged relative to T**, clarifying its reasoning.

CNF-365 addition — **behaviour changed**:

> Repeat with both named standbys reporting the same flushed end on the old primary’s timeline, with every other restart-promotion condition satisfied, once promoting each standby. Assert restart classification, no restore record and no credential-generation bump from the restore procedure. Repeat with an unavailable report and with reports on different timelines; neither case may use the equal-position path.
>
> Repeat equality with an open restore record, and separately after violated replication posture; equality MUST NOT override incident continuation or restore classification.

Unequal comparable reports choose the greater end; choosing the lesser remains restore-class. Preserve old-process stopping, old-primary fencing, named-standby membership and a standby streaming from the promoted store.

STO-54 explicitly says “unless a restore record (`STO-56`) is open there” and includes “after the primary committed without one of them”. Equality overrides neither. Tenant credentials avoid the restore bump only for the safe tie without an open incident; engine startup generation remains separate.

CNF-365 gains the tied restart verdict. No further production behavior changes. `Restore.lean` does not model WAL comparison, so it supplies no proof of this classification. **P3;** no new deployment parameter.

**Does this document contradict itself?**

I found no source counterexample changing Q1–Q4’s stated premises. Alternative candidates are not simultaneous obligations. D needs an observation boundary and cannot promise retrospective prevention; P needs enforceable control. Refusal needs explicit stop-record treatment. These are completion obligations for sketches, not additional void rules.

My proposals agree: safe equality requires no restore instant; unavailable evidence is not equality. Q1 monitoring consumes Q3’s reserved allowance. Neither authority depends on writing through stalled PostgreSQL. Q3 never releases capacity merely because Q1 stopped a process.

Apply notes.md rule 6 exactly: no premise-changing brief error is claimed, and no extra void rule or Panel E acceptance threshold is imported.

**Requested counterarguments, not my votes**

- **Q1:** Trusted immutable configuration may suffice; monitoring adds outages and another trusted control plane.
- **Q2:** Requiring time evidence can indefinitely block useful recovery; explicit unknown history may offer a better availability tradeoff.
- **Q3:** Durable external admission may cost more than accepting exhaustion and operator recovery.
- **Q4:** Prioritize establishing trustworthy promotion reports before refining the tie case; conservative treatment avoids that amendment work, at credential and availability cost.