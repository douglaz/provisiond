# Q1 fact-finding: "The question is if it's feasible to deal with data loss" (owner, 2026-10-23)

Spec at dc5d40d. PostgreSQL quotes come from curl of postgresql.org/docs/current on 2026-10-23, checked verbatim
(scratchpad pg/ws.html, pg/wal.html).

## Part 2: avoiding the loss (synchronous replication)

### What the spec does today

- One named standby, used two ways. `05:147` (`STO-7`): "`synchronous_commit` is `local` on every connection and
  `on` inside exactly two transactions ... the deposit mint and `STO-30`'s payment credit ... against the standby
  `OVR-19` names". `05:1474` (`STO-54`): "The deployment runs asynchronous streaming replication". So the standby
  is synchronous for two money-in writes and asynchronous for every other write. A promotion can lose any write
  except those two. "synchronous standby" at `00:338` and `:405` names the standby, not a mode for all writes.

### What PostgreSQL guarantees (warm-standby 26.2.8, runtime-config-wal)

- "each commit of a write transaction will wait until confirmation is received that the commit has been written
  to the write-ahead log on disk of both the primary and standby server. The only possibility that data can be
  lost is if both the primary and the standby suffer crashes at the same time."
- `synchronous_commit = on`: "This ensures the transaction will not be lost unless both the primary and all
  synchronous standbys suffer corruption of their database storage."
- The edge: "If primary restarts while commits are waiting for acknowledgment, those waiting transactions will be
  marked fully committed once the primary database recovers. There is no way to be certain that all standbys have
  received all outstanding WAL data at time of the crash of the primary. Some transactions may not show as
  committed on the standby, even though they show as committed on the primary. The guarantee we offer is that the
  application will not receive explicit acknowledgment of the successful commit of a transaction until the WAL data
  is known to be safely received by all the synchronous standbys."
  → A promoted synchronous standby holds every **acknowledged** commit. An unacknowledged one is a lost reply,
  which the engine already treats as fatal (`OPS-49`).

### What it costs

- Latency: "The minimum wait time is the round-trip time between primary and standby." "transaction locks continue
  to be held until the transfer is confirmed. As a result, incautious use of synchronous replication will reduce
  performance for database applications because of increased response times and higher contention."
- Standby down: "Such transaction commits may never be completed if any one of the synchronous standbys should
  crash. The best solution for high availability is to ensure you keep as many synchronous standbys as requested."
  The page documents no wait timeout. The ways out it names are a fast shutdown, or lowering the count in
  `synchronous_standby_names` (or disabling it) and reloading.
- So tolerating one standby's loss needs two synchronous standbys (`ANY 1 (s1, s2)`), i.e. a third database node.

### Was it weighed? Yes, in ADR-0023 (2026-09-12), and rejected

- `docs/adr/0023-*.md` "Why not synchronous commit on every write": one of the two readers recommended
  "`synchronous_commit = on` with a named standby and no positive recovery point". It was rejected on `ADR-0022`'s
  premise "the client never gives up first": with no server-side timeout for the wait, "under a stalled standby the
  client's deadline fires first on every write, the rare lost acknowledgement becomes the steady state ... the
  engine exits, and the successor's startup pass — which writes — stalls the same way. A crash loop across the
  whole safety layer".
- The quorum: "A quorum of two standbys (`ANY 1 (s1, s2)`) tolerates one standby's loss at the cost of a third node
  and returns the stall when the second goes. It is an addition to this ADR for a deployment that wants it, not an
  alternative: a synchronous standby replicates a bad migration, an operator `DELETE` and logical corruption
  instantly and faithfully, so the restore procedure is owed regardless".
- Considered options: "**Synchronous replication on every commit, recovery point zero.** Rejected above."
- Panel C (r63-r63c) never re-weighed it. Its brief settled the deployment as asynchronous.

### What it would mean for Q1

- Synchronous replication on every write would make a promotion lose nothing that any process acted on, so a
  promotion could be a restart. But it reopens ADR-0023 (crash loop on a stalled standby, or a third node), and the
  restore procedure stays for backup restores either way.

## Part 1 (stopped when the owner decided; subagent survey, NOT manager-verified)

Verdict "partly": STO-54 stops destructive actions on a restored store but rebuilds nothing lost in Δ. Gaps:
- Operations born in Δ: no row to search from; the sweep reports and never attaches.
- Lean `Live` has no enqueue.
- Provider reads rest on client-library evidence:
  - Robot standard channel unconfirmed with a real order.
  - The visibility window is unmeasured (n=1).
  - The Robot 30-day transaction window.
- Money corrections (LDG-74/LDG-5) have no trigger or route.
- A rollback past corruption also defeats the synchronous mint.
- A second loss mid-incident is unspecified (astra's candidate bead).
