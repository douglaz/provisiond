Draft is complete in my clone at `r74-fable-draft.md` (under 3000 prose words). Final answer follows.

# r74 Panel A — reader fable (clone pinned 4662d85)

S1–S15 match the pin. Also read: `Restore.lean`, r63c Form S′, r63g verify (H-e, H-f), r63h tally (trace 1), PostgreSQL 18 docs and `syncrep.c` at `b049b4e` (fetched). PostgreSQL claims below are from those; anything else is marked unverified.

Two primary-source PostgreSQL facts drive Q1 and Q3:

- `syncrep.c:957–994` (`SyncRepUpdateSyncStandbysDefined`): when a reload empties `synchronous_standby_names`, the checkpointer **wakes every `SyncRep` waiter** (`SyncRepWakeQueue(true, i)`, comment "it's futile for backends to continue waiting"), and those COMMITs return **success with no warning**. Docs: "If no synchronous standby names are specified here, then synchronous replication is not enabled and transaction commits will not wait for replication."
- `syncrep.c`'s wait loop (`:300–340`) tests `ProcDiePending`, `QueryCancelPending` and postmaster death only; the file contains no `CHECK_FOR_INTERRUPTS` or `ClientConnectionLost`. So a backend waiting in `SyncRep` does not notice a dead client, whatever `client_connection_check_interval` or server keepalives say. Residual backends live until a standby flushes, the list is emptied, or the primary shuts down.

## Q1 — pv-c7vg

**(a) Pick: OTHER, "V".** Verify each commit's replication on the component side, on the same session, using the deposit-read method `STO-7` already owns; no monitor, no latch, no cadence. D's alarm is folded in; D's monitor/latch is not. Condition: the owner accepts one extra read round trip per commit. P is not achievable with a PostgreSQL primitive (below). Z rejected: the reload itself *acknowledges* every stalled write.

**(b) Example.** An operator empties the list and reloads to clear a stall. Every waiting COMMIT returns success at once; a create dispatches on a row no standby holds; the primary dies later and the promoted standby lacks it, while `STO-54`'s restore precondition "after the primary committed without one of them" has no evidence. Strongest reason for V: the reload's own release is the race no monitor cadence covers; only a per-commit check on the committing session sees it.

**(c) Mechanics.** After a COMMIT reply without the warning, the component repeats `STO-7`'s read-only flush-position check on the same uninterrupted session with a target sampled after the reply. Pass: acknowledge. Not passed: keep the connection and repeat — the standby wait done client-side, outside deadlines as the server-side wait is (`STO-7`: "A standby wait has no server-side timeout and is excluded"). Session failure or a backend-identity change: the reply is the warning case, a lost reply (`OPS-49`), whose existing path re-reads on a *new, checked* connection and so cannot see an unflushed position. A failed verification on a warning-free reply is alarmed on `OVR-18`'s model; healthy replication never produces one (ANY 1 flushed before the reply), so the first alarm is the detector. Resumption is automatic; no latch. Pooler leg: the connection check records `pg_backend_pid()` and later checks compare it; a pooler cannot interpose on an open TCP connection, so it meets new, checked connections, and its first backend switch fails the next check closed. Observation point: the committing session plus `pg_stat_replication` (readable per `ADR-0045` H-f). Detection bound: the commit itself. Trust boundary: as today's check — `OVR-19`'s names are real standbys and the view is honest. Why P fails: `synchronous_standby_names` "can only be set in the postgresql.conf file or on the server command line"; no primitive stops a superuser reload, and `SET` protects only `synchronous_commit` ("They override values obtained from the configuration files"). Prevention lives in change control the set cannot test.

Negative controls: drift on a retained connection — next verification fails, alarm, lost-reply path (the local commit exists; V prevents its acknowledgement, not its existence). Unsafe before first use — the connection check passes with asynchronously streaming standbys; the first commit's verification catches it. Healthy — one read, passes. One standby down — passes. Both down — COMMIT itself waits. Observer failure — lost reply. Pooler reassignment — pid mismatch, closed. Sent COMMIT — retention unchanged; V runs after the reply. Strongest residual: other sessions read a locally committed row before a standby flushed it (visibility ordering under an emptied list: unverified beyond `ADR-0045`'s `:1506`). That is `pv-v4gp`'s class, not closed here. A test proves component behaviour under an emptied list and a pooler; only the deployment establishes that `OVR-19`'s names are the real standbys and who may reload.

**(d) Clauses.** AMEND `STO-7`, after "is not acknowledged: the component treats it as a lost reply (`OPS-49`)." add — *behaviour changed*:

> **A commit is acknowledged only by a standby's flush** (*added, `pv-c7vg`*): a commit reply without that warning is acknowledged only once the component has repeated the read-only flush-position check above on the same uninterrupted session with a target sampled after the reply, repeating it until it passes, outside every deadline as the standby wait is; on session failure the reply is the warning case. A check that does not pass on a warning-free reply is logged loudly on `OVR-18`'s model. The connection check records the backend's `pg_backend_pid()`, and a later read of a different value on that connection is a session failure.

AMEND `CNF-296`, append — *behaviour changed*:

> With both standbys streaming, empty `synchronous_standby_names` on the running primary by a reload. Make an engine write and an `api` write on connections checked out before the reload; assert neither is acknowledged, each is handled as the warning case, and the alarm fires; restore the list, reload, and assert a further write on the same connections is acknowledged without a restart. While a write waits with both standbys stalled, empty the list by a reload; assert the released commit is not acknowledged. Front one component's new connections with a transaction-mode pooler; assert the first commit whose check sees another backend is the warning case.

**(e) Collateral.** None: `CNF-365`'s "no check-issued writes, and no check-created `SyncRep` backend" holds (V reads); no Lean declaration is tagged `STO-7`.

**(f) Owner.** One read per commit and client-side waiting where the server would have waited. No new `OVR-19` row (the repeat cadence is the implementation's, like `STO-55`'s batch size).

## Q2 — pv-3jw6

**Brief error (rule 6; my view: it changes E's premise, not the question's).** The brief treats `restore_instant` as "how far back the surviving state goes". At the pin it is the recovery event's instant: `Restore.lean:24` "time does not advance: `now` is the restore instant", `:168` `restoreInstant := t.now` with `delta` separate; `ADR-0028:42` "The deadline ran from the restore instant, but tenants can extend". `T − Δ` is published and has no field. E would change the field's meaning under the formal model. The bead's gap stands.

**(a) Pick: U**, with E's evidence folded in and no startup hold. Condition: `restore_instant` keeps its meaning (the instant the record is committed), and the history boundary gets its own nullable field.

**(b) Example.** s2, lagging, is promoted by the operator after s1 died with the primary. Its last replayed commit carries the primary's clock 10:00:05; the last component connected to the old primary stopped at 10:00:40. The published window is [10:00:05 (primary clock), 10:00:40 (deployment clock)]; `restore_instant` is 10:03:00 when the record commits. Reason: `pg_last_xact_replay_timestamp()` "Returns the time stamp of the last transaction replayed during recovery. This is the time at which the commit or abort WAL record for that transaction was generated on the primary" — read on the promoted store itself, no old primary needed. The end is the stop instant because an acknowledged commit needs a connected component. Historical: r63c Form S′ carried this read; it went with the superseded form.

**(c) Mechanics.** Read before promotion or any restart: the value "will remain static" after recovery, and a restarted server returns NULL until something replays — why the record stores it once, "never re-computed". Missing (NULL: a standby restarted after the primary died, nothing replayed since): null field, the report names the end and says the start is unknown, and the procedure runs unchanged — nothing automated consumes Δ (consumers at the pin: `CNF-295`'s report assertion and `05:1656`'s prose; bump, quarantine and skip are window-independent). An operator may substitute an earlier instant the store is shown to hold, never a later one. Interrupted: the successor reads the record. Backup restore: same read after recovery completes, before the first restart. The two ends name their clocks; no skew parameter. Step (3)'s grace anchor stays the event's own instant (`Restore.lean:390–396`).

**(d) Clauses.** AMEND `STO-54`, restore-class promotion sentence, after "before either component is started." — *behaviour changed*:

> For a promotion, `restore_instant` is the instant that record is committed, as for a backup, and the lost window starts at the promoted store's history end: `pg_last_xact_replay_timestamp()` read on it before promotion or any restart, where it is not null, on the old primary's clock, and ends at the instant the last component connected to the old primary stopped. Where it is null the start is unknown, the record says so, and step (1) publishes the end alone; an operator MAY supply an earlier instant the store is shown to hold, never a later one. A backup restore uses the same read after its recovery completes.

AMEND `STO-56`: add `history_end_at`, nullable, "the lost window's start as `STO-54` defines it; null where no evidence fixed it" — *behaviour changed* (schema). AMEND `CNF-295`'s "the operator report names `T − Δ`" → "names the lost window as `STO-54` defines it, an unknown start included" — *behaviour changed* (assertion). AMEND `CNF-365`, append: "Promote a lagging standby as a restore; assert `history_end_at` equals its last replayed commit time read before promotion and the report names both ends. Repeat with that standby restarted after the primary died and nothing replayed; assert `history_end_at` is null and the report says the start is unknown." — *behaviour changed*.

**(e) Collateral.** None: `Record.restoreInstant := t.now` keeps its meaning; witnesses fixing `restoreInstant := 50` unchanged; the new field is not modelled (the module omits step (1)'s publication by its own doc). `CNF-295`'s "names `T − Δ`" is amended, not flipped.

**(f) Owner.** A nullable column; a read the deployment must perform before promotion/restart; "unknown" as a published value. No availability cost (E's hold is unneeded).

## Q3 — pv-oehp

**Premise refinement, not an error.** Under S1, a full stall already bounds growth: the first waiting write's record is flushed locally before the wait (`ADR-0045`, xact.c `:1506`), so the primary's flush position passes every standby's and every later new connection fails the check unused. Growth past the pools alive at onset needs an idle stall, a slow-but-moving standby, or flapping — r63h trace 1's shape.

**(a) Pick: OTHER, "C".** The primary's own count of `SyncRep` waiters is the accounting authority, and each component checks its share against it at startup — `STO-55`'s existing pattern ("the engine reads `max_connections` at startup and refuses to run where its own pool plus the lock connection does not fit"), extended to `api` and to the count. No supervisor logic, reservation state or identity.

**(b) Example.** Stall; the engine stops on time twice and one `api` replica loses its transport; 20 backends wait. The replacement engine's startup read sees 20 + its pool > sum − reserve and exits; the supervisor's existing loop retries with short reads; `OVR-18`'s liveness alarm is already up; reads continue on surviving replicas. The stall clears, waiters drain, the next attempt starts. Reason: the server already counts exactly the class nobody else sees, and a startup refusal is a finite bound while a backoff is not.

**(c) Mechanics.** Invariant (capacity): the number of this deployment's primary backends never exceeds the stated sum; each start adds at most its pool, admitted only when `count + pool ≤ sum − reserve`. Availability: reads on live replicas (read checkouts never wait at COMMIT), operator access via the reserve, recovery via the drain. Observation: `pg_stat_activity` rows with `wait_event = 'SyncRep'`, read on the first checked connection with the `pg_read_all_stats` grant or definer function `ADR-0045` already requires (other roles' wait events are hidden without it). Exhaustion: refuse to start, alarm. Observer failure: a store error at startup, exit, retry. Accounting loss: none, the server is the state. Release: waiters leave when a standby flushes, the list is emptied (then Q1's V governs the live ones), or the primary shuts down; never by cancellation. Concurrent starters overshoot by at most one pool each; the human row is already "the sum across every process at maximum rollout overlap", so the slack lives there. `STO-7`'s prohibition stands.

**(d) Clauses.** AMEND `STO-55`, replace "During a stall, backends left waiting by an exited process or a dead transport hold slots outside this `max_connections` account (`pv-oehp`)." with — *behaviour changed*:

> During a stall, backends left waiting by an exited process or a dead transport hold slots outside the pools, and the primary counts them: its `pg_stat_activity` rows whose `wait_event` is `SyncRep`. Each component reads that count at startup on its first checked connection and refuses to run where its own pool, the lock connection for the engine, and the count do not fit inside the stated sum less the operator reserve; a count it cannot read is a store error at startup. Waiters leave the count only as `STO-7` allows.

AMEND `CNF-296`, append — *behaviour changed*:

> With both standbys stalled and writes waiting from the engine and two `api` replicas, kill the engine and one replica with their transports open, cut the other's transport, and start a replacement engine and a third replica under a rollout. Assert the primary's `SyncRep` count never exceeds the stated sum less the operator reserve, a replacement runs only while the count plus its pool fits, an operator connection succeeds throughout, reads on the surviving replica succeed, and no `SyncRep` backend is cancelled or terminated. Release the stall; assert the waiters drain and every refused start then runs without operator action. Repeat with the count read failing; assert the process exits and the alarm fires.

**(e) Collateral.** None: `StopRecord.*` theorems and stop-on-time untouched.

**(f) Owner.** Restart delay during stalls at budget; `api` gains a startup refusal. No new parameter.

## Q4 — pv-1i3n

**(a) Pick: T**, with two wording-only companions and no fixture beyond T's.

**(b) Example.** Idle night; both standbys report the same flushed end on the old primary's timeline; the primary dies. Under T automation promotes either as a restart; under R an operator must run a procedure that kills every spending token for no missing commit. Reason: equal ends on one history mean both hold every acknowledged commit; "both hold a prefix of one WAL sequence, so that one holds them all" already covers a tie.

**(c) Evidence.** Same-timeline is a precondition, so equal ends are comparable. A false tie from `pg_last_wal_receive_lsn()` after restart (`ADR-0045` H-e) is already excluded by `CNF-365`'s existing "Stop one standby, make an acknowledged write, stop the other, lose the primary, restart both standbys, and assert the procedure promotes the one holding that write": a reporter that returns segment boundaries fails it. Cases: equal → restart, either; unequal same history → further ahead; unavailable report → wait/operator; other timeline → not a restart; open restore record → continuing the incident whichever path; posture violated earlier ("after the primary committed without one of them") → restore, and Q1's V alarm is the only evidence that condition ever has — without Q1 it is unobservable.

**(d) Clauses.** AMEND `STO-54`: "and the one further ahead is promoted:" → "and a standby whose reported end is at least as far ahead as the other's is promoted (either may be chosen when they are equal):" — *behaviour changed*. "or of the one not further ahead," → "or of a standby whose reported end is behind the other's," — *behaviour changed*. "so that one holds them all" → "so the promoted one holds them all" — *behaviour unchanged*. `STO-5`'s pointer "Promoting the standby `STO-54`'s report puts further ahead is a restart" → "Promoting the standby `STO-54`'s rule selects is a restart" — *behaviour unchanged* (it defers to `STO-54`); same phrase in `CNF-365`'s title and first drill sentence, and in `Restore.lean:29–30`'s doc comment — *behaviour unchanged*. `CNF-365` gains T's fixture verbatim — *behaviour changed*.

**(e) Collateral.** None: no Lean declaration compares positions (`Fault` is `restart | restore`); `CNF-365`'s unequal, unavailable and other-timeline drills stand.

**(f) Owner.** None.

## Does this document contradict itself?

- **Q2 vs base** (above): the brief identifies `restore_instant` with the history boundary; the pin's formal model and `ADR-0028` make it the event instant. Rule 6: changes E's premise, not the question's.
- **Q1 D vs Q3.** D's response "stop components under the existing stop rules" manufactures Q3's residual backends; V stops nothing. Z-Q1 vs Q3-C: an operator who empties the list to clear exhaustion creates Q1's event, and `syncrep.c` acknowledges every residual waiter — the two beads share one mechanism and should be read together.
- **Q1 D's observability.** A monitor cannot observe "every component connection's applicable settings": `synchronous_commit` is per session and `pg_stat_activity` shows no GUCs. D as sketched is not implementable as written.
- **Q2 vs Q4** agree: a tie restart writes no record and needs no instant; a restore-class promotion fixes `history_end_at` or null.
- **Q4 vs Q1.** `STO-54`'s "after the primary committed without one of them" precondition is unobservable without Q1; T leaves it as is, V supplies its evidence.
- No other quotation failed verification.

## Requested counterargument, not my vote

- **Q1 (don't add V).** A read on every commit's hot path guards against an operator error the deployment is already trusted to prevent (as for names, keepalives, `max_connections`); a managed deployment refuses an empty list anyway (Patroni strict mode, example only); and V still lets other sessions read the unreplicated row.
- **Q2 (don't add the field).** Nothing automated consumes the window; the operator can read the timestamp by hand and write "unknown"; a column and a before-restart read add a step a tired operator skips.
- **Q3 (don't add C).** A full stall already bounds growth through the connection check; flapping is rare, `superuser_reserved_connections` already protects operator access, and the violation costs availability only.
- **Q4 (don't adopt T).** A tie is also what a broken reporter shows; leaving ties to the operator keeps false ties out of automation, at the cost of a page, not a write.
