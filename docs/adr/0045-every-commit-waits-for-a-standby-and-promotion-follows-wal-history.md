# Every commit waits for a standby, and promotion follows WAL history

**Status:** accepted (2026-10-23; `pv-s4m`). The requirement edits precede this record.
Decision record: [panel r63](../research/panels-2026-10/r63/), especially
[the chosen form](../research/panels-2026-10/r63/r63h/forms-chosen.md).
Line references in the voted rationale are at `dc5d40d`.

## Decision and owners

The owner's decision was “I think we should just suppose synchronous replication”. The answers
were S1 “Three servers (Recommended)”, S2′ “A: stop on time (Recommended)”, S3 “B: check each new
connection (Recommended)”, P “Wait (Recommended)”, and owner question F (a quick shutdown while both standbys are down) “Check again (Recommended)”.

`STO-7` owns the commit rule: “`synchronous_commit` is `on` on every connection and
`synchronous_standby_names` is `ANY 1` over the two standbys `OVR-19` names”. It owns the connection
check: “A component checks each new connection before using it”. `STO-54` owns classification:
“Promoting the standby that holds every acknowledged commit is a restart”. Its automatic-failover
choice is “Only an operator starts a promotion that is a restore: an automatic failover promotes
only as a restart, and otherwise leaves the store without a primary until both standbys report
or an operator decides.”

This amends `ADR-0023`: its rejected option “Synchronous replication on every commit, recovery
point zero” is adopted, and the stall it rejected is accepted as writes that wait.
DL removes deadline-driven abandonment during the standby wait; lock-contention exhaustion can still
restart the engine. This is LOCK-A in the [r63f record](../research/panels-2026-10/r63/r63f/tally.md).
It amends `ADR-0022` through `OPS-49`: “The bound covers connection, execution, commit, read-back and
backoff together, but not a commit's wait for the standby (`STO-7`)”. It amends `ADR-0042` by deleting
its create-exception exclusion “nor on a store that may have lost committed writes, such as a
promoted asynchronous standby”; `OPS-15` retains “It does not fire while a restore record is open”.

Design objective: irreversible external consequences must not depend on history a promotion
classified as a restart may discard. A restore can still lose acknowledged history.
This is rationale, not an additional requirement. Known counterexample: `OPS-32`'s sweep acts on
reads (`03-operation-lifecycle.md:1630-1635`): “an image tagged with an operation's correlator whose
operation has settled or vanished” is “deleted rather than reported”; its temporary-key condition
is “when, and only when, `PRV-9` permits it”. Follow-up `pv-v4gp` audits against it.

## PostgreSQL evidence

[PostgreSQL 18, synchronous replication](https://www.postgresql.org/docs/18/warm-standby.html#SYNCHRONOUS-REPLICATION)
says commits waiting when the primary restarts are “marked fully committed once the primary
database recovers”. Its warning about divergent visibility is “Some transactions may not show as
committed on the standby, even though they show as committed on the primary”.
The same documentation says “Users will stop waiting if a fast shutdown is requested.”

The following are **source code** citations, PostgreSQL 18:
[18-syncrep.c:553-559](https://github.com/postgres/postgres/blob/b049b4e7b4a159d373ef394bda67f7cf25758998/src/backend/replication/syncrep.c#L553)
advances the flush position and calls `SyncRepWakeQueue(false, SYNC_REP_WAIT_FLUSH)`;
[18-syncrep.c:905-924](https://github.com/postgres/postgres/blob/b049b4e7b4a159d373ef394bda67f7cf25758998/src/backend/replication/syncrep.c#L905)
releases waiters in WAL order, stopping at `if (!all && walsndctl->lsn[mode] < proc->waitLSN)`.
[18-xact.c:1506](https://github.com/postgres/postgres/blob/b049b4e7b4a159d373ef394bda67f7cf25758998/src/backend/access/transam/xact.c#L1506)
flushes locally with `XLogFlush(XactLastRecEnd)` before the commit is visible. The fast-shutdown
window between releasing waiters and ending every session is **unmeasured**.

Patroni's [strict mode](https://patroni.readthedocs.io/en/latest/replication_modes.html#synchronous-mode)
(`synchronous_mode_strict`) is an example deployment only. It is not the requirement's owner.

## Why the report is per timeline

The report is what each standby holds, not `receive_lsn`. After a restart with the primary dead,
both standbys reported `pg_last_wal_receive_lsn() = 0/4000000`, whatever they held (H-e). An old
primary started as a standby without `pg_rewind` reported a TL1 position ahead of s2's TL2 position,
yet lacks every TL2 commit (H-e2). The committed
[verification record](../research/panels-2026-10/r63/r63g/verify.md) retains these results.

Runtime replication-configuration and routing duties, including their misconfiguration limits, are owned by `STO-7` and `STO-55`. For `pv-c7vg`, on 2026-10-28 the owner answered “Don't add the check”, selecting “Trust the deployment to keep replication on.” The fuller option was “No new control — Rely on the deployment never disabling synchronous replication; document it as an operator requirement. Cheapest, and it puts safety on infrastructure configuration.” No runtime controller was adopted. The separate action/history audit stays with `pv-v4gp`.

## Why the connection check is a read

The [verification record](../research/panels-2026-10/r63/r63g/verify.md), H-f, records the privilege:
without `pg_read_all_stats`, a role sees only pid, usesysid, usename and application_name in
`pg_stat_replication`. So the deployment grants it, or provides a SECURITY DEFINER function owned
by a role that holds it. A missing grant fails closed: no connection is ever used.

The target is the flush position, not the insert position (H-f;
[source code, xlog.c:9488](https://github.com/postgres/postgres/blob/b049b4e7b4a159d373ef394bda67f7cf25758998/src/backend/access/transam/xlog.c#L9488)).
The insert position can sit past a page header that no standby's flush reaches on an idle primary.
A flush target is safe because no connection is below `local`. The check is a read, not a write:
a write check leaves one `SyncRep` waiter per attempt during a stall (H-f: 3 of 3).
Rejected for v1: re-admitting a transaction-mode pooler with a per-transaction check.

## Deposit reads and residual availability

The unmeasured fast-shutdown window is the reason for the deposit-read check. `STO-7` owns it:
“Before exposing a deposit destination read from the store, repeat the read-only flush-position
check with a target sampled after that read, on the same uninterrupted PostgreSQL session.”
It needs S3-B′'s read permission and an uninterrupted session. It covers deposit destinations only:
`WIR-14`'s “`POST /v1/deposits`”, including `API-45`'s “re-sending one MUST return the **same**
deposit”, and `WIR-15`'s “`GET /v1/deposits/{id}`”. The non-deposit consequences stay with
follow-up `pv-v4gp`.

**Amended 2026-10-28 (`pv-oehp`).** The owner selected “B4* as reviewed (Recommended)”
in [decision 2](../research/panels-2026-10/r74/owner-decisions.md), with authority also in
committed bead comment 836. “B4* plus astra's additions” and “No new machinery” were rejected.
Contract, deployment obligations, costs and capacity argument: `STO-55` in `05-persistence.md`.
Lifecycle companions: `OPS-47` and `OPS-49` in `03-operation-lifecycle.md`; alarms and register:
`OVR-18` and `OVR-19` in `00-overview.md`. Conformance companions and the residual-capacity
drill: `10-conformance-checklist.md`, including `CNF-372`.
Follow-up `pv-26ju` carries the WAL-history proof and counterexamples.

## Rejected options

The [owner questions](../research/panels-2026-10/r63/r63h/owner-questions.md) hold the descriptions
of STOP-B “wait it out”, S3-A, S3-AB, PA-1 and FSW-L. The r63b–r63h records in
[panel r63](../research/panels-2026-10/r63/) hold the alternatives B, D and option F (forbid).
Also rejected: S′ (every promotion a restore), two servers (S1), and INV-STO
(“Nothing irreversible rests on an unacknowledged commit”, 0-4).
