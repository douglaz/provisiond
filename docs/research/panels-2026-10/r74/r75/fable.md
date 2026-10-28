# r75 Panel A — reader fable (Reader 1), clone pinned 4662d85

Gate: `nix develop --command bash tools/check-all.sh` unpiped, exit 0 at the pin, and exit 0 again with `check/q4-proposed.diff` applied in scratch (tracked files restored, clone clean). PostgreSQL facts come from the tally's pinned snapshots (`b049b4e` syncrep.c, xact.c, postinit.c, miscinit.c; PG18 docs); anything else is marked unverified. No database run.

## Q1 — pv-c7vg

| Package | Verdict | Reason |
|---|---|---|
| V1 (Reader 1) | CANNOT ACCEPT | Rule: "repeating it until it passes" on the same session. Fixture: a failed probe is "handled as the warning case" (lost reply: connection closed, re-read on a new checked connection), then "a further write on the same connections is acknowledged". Both cannot hold. "assert neither is acknowledged" with both standbys streaming is unprovable: an async standby can catch up and the probe passes. "healthy replication never produces one" is false (trace 2). |
| A2 (Reader 2) | AMEND, behaviour changed | Control "with a single writer, one confirmation read and no added wait" is not guaranteed (trace 2). Clause 4 has no discharge: one unverified interval makes every later promotion of that primary a restore. Confirmation read should carry the identity pair (trace 3). |
| P3 (Reader 3) | AMEND, behaviour changed | Latch condition "unaccounted sessions" trips on the residual backend CNF-296's own exit step leaves (trace 5). CNF-362 amendment is declared. |
| P4 (Reader 4) | AMEND, behaviour changed (one fixture precondition) | "A stop-record attempt is subject to the same gate" adds an unstated precondition to CNF-362's "with a working store". Otherwise internally consistent. |

Preference: NONE as printed. Smallest complete replacement, unreviewed: P4 byte-identical to `q1-sol.md` (sha `bfc82bc1…`) plus one addition, printed after the traces.

Traces:

1. Verified: syncrep.c:964–983 `SyncRepUpdateSyncStandbysDefined` calls `SyncRepWakeQueue(true, i)` for every mode; :944 sets `SYNC_REP_WAIT_COMPLETE`; the loop at :285 breaks before either WARNING branch (:300, :318). The reply is a plain success. V1 and A2 protect component acknowledgement only and say read-only effects stay with pv-v4gp. V1 supplies no bound while idle ("Detection bound: the commit itself"). A2's M supplies period-plus-timeout detection without refusal. P3/P4 supply H+J and C+Q+V refusal for persistent drift and exclude transient bypass explicitly.
2. xact.c:1505 `XLogFlush(XactLastRecEnd)` precedes :1567 `SyncRepWaitForLSN`, and `pg_current_wal_flush_lsn()` is cluster-global. After one's own reply the flush position can already include another session's locally flushed unreplicated commit, or a bgwriter/checkpointer record the walwriter flushed. So a healthy probe can fail once even with a single writer; A2's "one read, no added wait" control is flaky, and V1 turns that case into an alarm. A2's later-WAL wait is the standby wait with no server timeout; the prose word "bounded" has no basis, as the tally says.
3. Transaction pooling binds a backend per transaction ("assigned to a client only during a transaction"). A1's in-transaction `pg_backend_pid`, `backend_start` and `synchronous_commit` read proves that transaction's backend and setting; it cannot prove pooling is absent (same backend reused). A2's post-COMMIT read may land on another backend; the positions are global, so on the same server it stays conservative. Only a different server behind a pooler defeats it, which pipelining the identity pair into the confirmation closes. V1's PID-only check misses PID reuse. Direct TCP: no pooler can be inserted into an established session (opus is right; STO-55's case is a retained client-to-pooler session).
4. `SHOW` and `pg_settings` are session-local; `pg_stat_activity` carries no GUCs. P3 and P4 both say so and substitute trusted component SQL plus a sole change authority, a trust obligation rather than an inspection. Persistent drift (file plus reload, role defaults, topology) is observable from a fresh admin session; transient toggles and root bypass are not, and both say so. Expiry runs from challenge or request start, measured monotonically, so a disconnected or delayed component refuses within V (P4) or H (P3) without hearing anything. A busy COMMIT expires nothing because renewal uses the observer's own session (P4: "Busy-session evidence persists only while original session identity and enforced unchanged settings are established"). CNF-296's "a read still succeeds" survives in P4.
5. Retention: V1 runs after the reply; A2 says "the COMMIT's connection is retained"; P3 and P4 keep STO-7's "MUST NOT release its connection before the reply arrives". Stop records: P3/P4 route denial through existing bounds; `finished_unrecorded_exit` (StopRecord.lean:432) already lists `plan.tries.length = storeBudget`, so denied tries need no new disjunct. P3 trace: CNF-296 (10:1072) "Exercise a contending engine write and assert `OPS-49`'s bounded retry and exit" leaves a SyncRep backend with no live registry; P3's "Missing identities, unaccounted sessions … MUST latch refusal" then latches; 10:1077 "Then stall one only and assert an engine write and an `api` write each succeed" is unreachable until "Only the authority may clear the latch". P4's observer checks configuration, node identity and topology, not session accounting, so it does not trip. P4's gap: CNF-362 (10:1660) "with a working store" no longer suffices when posture evidence has expired.

P4 replacement delta (unreviewed, behaviour changed), appended after P4's CNF-296/CNF-365 paragraph:

> **CNF-362 — AMEND, behaviour changed**: "with a working store" becomes "with a working store and current `STO-7` posture evidence". Separately expire that evidence during a stop and assert the record is denied without SQL, the denied attempts consume the Stop-record bound, and the engine exits naming the operation.

Owner costs, not accepted: P4 adds a change authority, observer infrastructure, maintenance and observer-failure outages, api exit on latch, and every stop under a latch becomes a bounded unrecorded exit. A2 adds a round trip per commit plus later-WAL waits, a monitor slot and period, and a new lost-reply case. V1 adds a round trip per commit.

## Q2 — pv-3jw6

Formal home verified: `RestoreTrace.store` (Restore.lean:163–168, `@[req "STO-54"]`) writes `restoreInstant := t.now` while `delta` selects history; `afterCrash` :437 loads `now` from `restoreInstant`; `bootRestore` :541 uses `t.now`; `step_three_writes_grace` :548 uses `instant`. Prose: STO-56 lists the column, STO-54 says "the instant is read from the record and never re-computed", and T − Δ is published but unstored. So restore_instant is event time at the pin. E3 and U4 change its meaning; AGENTS.md says "Change the declaration and the Markdown together", and neither prints a Lean edit, so afterCrash would load a history bound as the execution clock.

Evidence soundness. (a) `pg_last_xact_replay_timestamp()`: "the commit or abort WAL record … generated on the primary", NULL without replay and after a normal start, static after recovery. It bounds replayed WAL on the primary's clock, but commit timestamps are not WAL-ordered across backends, so "every commit acknowledged before it survived" needs an allowance even on one clock. U2 has one; U1 says "no skew parameter". (b) Trusted time followed by a `pg_current_wal_insert_lsn` sample (E3): an acknowledgement before the time has its record below the sample, and a verified continuous same-ancestry prefix through it proves inclusion. Sound, but the sample must predate the failure, so E3 implicitly requires a standing sampler it never states; without one every restore, backup restores included, holds forever. (c) Named restore point (U4): `pg_create_restore_point` returns the LSN; its request time orders acknowledgements the same way; it is not a transaction commit, so no SyncRep wait; superuser or granted EXECUTE. None needs the old primary. (a) is NULL on an idle restarted standby; (b) and (c) are invalidated by holes or divergent ancestry. No LSN or filename is a clock.

Allocation: 05:924 "Allocated strictly increasing and never re-issued"; CNF-297 "exceeds every index a rolled-back row held". With restored maximum m, n allocations lost in Δ and gap g, the next index m+g+1 is at most m+n when n > g, a reissue. Valid, pre-existing, and independent of knowing the instant, since knowing Δ gives no count. It is outside this bead's necessary scope and should be filed separately.

| Package | Verdict | Reason |
|---|---|---|
| U1 (Reader 1) | AMEND, behaviour changed | Window start presented as the "history end" without the ordering caveat; "last replayed commit time" should read "transaction"; the null fixture needs a standby restarted with no transaction record after its restartpoint (reachable, contrived). No formal change needed; CNF-295 amendment declared. |
| U2 (Reader 2) | AMEND, behaviour changed | The hold needs capture steps in CNF-295, CNF-297 and CNF-370 ("read before that store restarts or serves anything"); the allowance must be stated to cover commit-timestamp ordering, not only skew. No formal change needed. |
| E3 (Reader 3) | AMEND, behaviour changed | Missing Lean sync; implicit continuous sampler; CNF-358 is a restart fixture, not a restore one. |
| U4 (Reader 4) | AMEND, behaviour changed | Missing Lean sync; the allocation gate bundles an out-of-scope mechanism with CNF-295/CNF-297 restrictions. |

Preference: NONE as printed. Smallest complete replacement, unreviewed: U1 byte-identical to `q2-fable.md` (sha `46aa1ce8…`) with three exact substitutions in its STO-54 clause and fixture: "and the lost window starts at the promoted store's history end" → "and the lost window starts no later than the promoted store's history end"; "where it is not null, on the old primary's clock" → "where it is not null, on the old primary's clock and no finer than that clock's commit-record ordering"; CNF-365 "its last replayed commit time" → "its last replayed transaction's time". Hold versus unknown is the owner's choice; finite-only U2 is the alternative and is not acceptance of U1. Fixtures an evidence hold restricts: CNF-295, CNF-297, CNF-370 (capture step) and CNF-365 (null case). Costs: U1 one nullable column and one read; U2 column, allowance, hold; E3 sampler, retention and indefinite outage; U4 four columns, evidence and a step-(3) hold.

## Q3 — pv-oehp

C1 dissent in full. Verified: XLogFlush (:1505) precedes the wait (:1567), so after a frozen stall's first waiting write every new-connection check fails unused (05:194–196). This bounds nothing: a failing check still forks a backend for the attempt deadline; r63h trace 1 (tally.md:42–48, source-verified) loses the transport before the local flush, the replacement samples the earlier target and passes while healthy, and a later freeze strands the originals. Repeating that inside one live incarnation, whose count C1 reads once at startup, exceeds any sum, so rollout overlap is no bound. Idle orphans whose wait completed are not `wait_event = SyncRep` and go uncounted. C1's fixture kills one replica, cuts the other's transport, then asserts "reads on the surviving replica succeed"; that process must reconnect and the check fails while frozen. CANNOT ACCEPT. The guard observation is right; the solution is not.

B2. Source ordering verified: `InitProcess` precedes `InitPostgres` (postinit.c:704), `PerformAuthentication` (:900) precedes `InitializeSessionUserId` (:901), whose check is `CountUserBackends(roleid) > rform->rolconnlimit` (miscinit.c:873–880) with the comment "they might both think they were over the limit". Each attempt sets its own role before counting, so the race refuses rather than over-admits (memory-ordering caveat unverified). A transient attempt holds a PGPROC before both the role check and the reserve check, so a flood of failing attempts can transiently consume the reserve; B2 declares that unverified. Superusers are exempt and prepared or background connections uncounted (CREATE ROLE doc). Unlisted collateral: STO-55 (05:216) "Every consumer then has a connection when it needs one" narrows and B2 does not amend it; the lock connection's role is a cost note, not a clause. AMEND, behaviour changed.

B3. The invariant live + residual ≤ permits ≤ C holds given grant-before-dial, no bypass, charged unknowns and release after fenced absence. Its fixture reaches residue honestly: blackholed position-query replies leave idle backends past the attempt deadline with the check preserved. Gaps: the same STO-55 sentence is unamended; "one attempt" must forbid driver fallbacks (libpq sslmode, gssencmode and multi-host retries open more than one TCP connection per dial); the dialer fence is unnamed. AMEND, behaviour changed.

B4. ACCEPT as printed, on its stated conditions. One backend maps to one charged grant through "at most one attempt/backend" bound to PID, backend_start and node boot identity (PID reuse covered; a primary restart ends every old backend and is releasable by boot identity). Lost state: "MUST deny growth; reset requires fencing all old grants/attempts and reconstructing them conservatively, or verified primary shutdown". Delayed attempts: "Fence delayed dial capabilities before observing absence". Observer: reserved privileged access and "Observation failure retains charges and denies growth". STO-55's consumer sentence is replaced with exact text, OPS-49 denial is a store error, and exhaustion consumes existing bounds, so `finished_unrecorded_exit` is unchanged. OPS-47 still "restarts it"; CNF-290's "release the first and assert the second then starts" stays reachable with one observation round of delay. CNF-296/CNF-299 reads need live admitted sessions only. The fixture holds residual PIDs in SyncRep after engine stop-record expiry and api transport loss, overlaps a rollout with checks enabled, and covers accounting loss, PID reuse, competing supervisors, observer withheld to exhaustion and verified recovery. Conditions: a dial must be exactly one TCP connection (driver fallbacks off); `reserved_connections` semantics are not in the snapshot, an unverified PostgreSQL dependency; the authority is a new availability dependency ("no local fallback"). Preference: B4.

Costs, separate: B3/B4 durable issuer, idle reserve, indefinite restart delay, primary shutdown on lost accounting; B2 roles, allowances, a successor blocked while orphans fill its role; C1 none, and no bound.

## Q4 — pv-1i3n

All seven anchors are unique at the pin; the diff applies; the gate passes with it.

| Part | Verdict |
|---|---|
| T1 | ACCEPT, behaviour changed. The restore list stays exhaustive: two reports are either both maximal or one behind; unavailable and other-timeline cases are separate clauses. |
| T2 | ACCEPT, behaviour unchanged. |
| T3 | ACCEPT, behaviour unchanged; a bare pointer is AGENTS.md's "one rule, one home". |
| T4 | ACCEPT, behaviour changed. It makes the first drill runnable when the kill leaves a tie; the strict further-ahead case stays in the stop-one, write, stop-other drill. |
| T5 | AMEND, wording only, behaviour unchanged (below). |
| T6 | ACCEPT, behaviour unchanged; no declaration touched. |

Traces: a valid tie promotes either as a restart, OPS-15 takes the restart branch, the startup generation advances under OPS-15 :381, tenant generation is untouched; unequal same-history greater is a restart and behind is an operator restore; unavailable waits; equal numbers on different timelines and prior posture violations are restores; an open record continues the incident, step (3) marked is not repeated (`marked_step_three_writes_nothing`) and unmarked bumps when completed; stopping, fencing and streaming text is retained. Nothing beyond the declared changes is introduced. One caveat: the violated-posture controls assert a classification the procedure cannot observe at the pin, the evidence gap pv-v4gp owns. Repair: "Repeat equal reports after the primary committed without either named standby" → "Repeat equal reports after the primary, to the deployment's knowledge, committed without either named standby", and "after a waiting backend was cancelled or terminated" → "after a waiting backend was, to its knowledge, cancelled or terminated". With that wording the whole form is ACCEPT and ready for the owner to choose equality policy; "Follow-up ticket" was not that choice.

## Does this brief or my combination contradict itself?

The r75 brief holds: the WAIT_COMPLETE wake, PGPROC before the role check, 05:924, CNF-297 and the separate `now`/`delta` all verify. Rule 6 as written: no tally voided.

Manager claims I broke, none premise-changing:

1. Q1: A2's healthy single-writer "one read passes" is also false, not only the concurrent case; non-transactional records flushed by other processes advance the global flush position.
2. Q1: "The returned P forms explicitly try to preserve those reads" fails for P3, whose "unaccounted sessions" latch defeats CNF-296's later success after its own exit step.
3. Q1: A2's post-COMMIT read is global, so only a different server behind a pooler defeats it.
4. Q3: "sol … still needs the exact supervisor/fixture alignment" is not required; OPS-47 and CNF-290 remain reachable under B4.
5. Q2: CNF-358 is a restart fixture and no hold restricts it.

Cross-question interactions, no union adopted: P3's latch is unworkable without Q3's accounting; P4's exits create residuals B4 charges; A2's clause 4 would fold a posture record into T's "every other condition"; U4's gate and T never meet because ties write no record; B4 must budget any Q1 observer. My verdicts stand independently: Q1 NONE, Q2 NONE, Q3 B4, Q4 T-complete with the T5 wording.

## Requested counterargument, not my vote

- Q1: a change authority and observer are a second control plane whose outages stop the service, and root bypass remains; the deployment already owns reload rights.
- Q2: an operator-run restore can publish "unknown" by hand; a column, a read step and a hold are machinery for a report a human already reads.
- Q3: a durable admission issuer is a new single point of failure bounding an availability-only class that primary shutdown already clears.
- Q4: a false tie is what a broken reporter shows; leaving ties to an operator costs a page, not a write.
