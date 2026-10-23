# S3 analysis: PostgreSQL's self-restart after a backend crash (pv-s4m, panel C). 2026-10-23

Owner's S3 answer, verbatim: "Analyze this better". S1 is decided ("Three servers (Recommended)"), so every text
below uses the three-server form: `ANY 1` over the two standbys `OVR-19` names.

## Plain terms

One database process crashes, for example because a memory cap kills it. By default PostgreSQL then restarts all
its processes by itself within seconds, and the server never stops. A deposit that was saved on the main server
but was still waiting for a copy becomes visible after that self-restart, even if neither copy has it. Our
catch-up rule fires only when the server starts. This self-restart doesn't look like a start from outside: even
the server's recorded start time stays the same. So the hole is real.

It's open only while both copies are behind. With healthy copies that's milliseconds. When both copies are
unreachable, it lasts the whole outage. A customer can be shown a deposit address in that window, and the deposit
is lost if the main server then dies before a copy catches up.

Two fixes close it:

- **Turn the self-restart off.** A crash then stops the server, and our catch-up rule runs on the restart. That's
  one setting. The cost is that a crash in one process takes the whole database down until something restarts it.
- **Check each connection.** Before the engine or `api` uses a new database connection, it waits until a copy has
  caught up to the main server. This works no matter who restarts the server, or how. The cost is a check in both
  components and a monitoring permission.

Patroni doesn't close it on its own. Its documentation names the same leak.

## 1. Is the hole real? Yes

Each fact is quoted from PostgreSQL 18 (docs at postgresql.org/docs/18; source at `REL_18_STABLE`). Copies are in
`src/`: `18-xact.c`, `18-syncrep.c`, `postgres18.c`, `postmaster.c`, `walsender.c`, `pgstatfuncs.c`, and the docs as
`.txt`. r63e's `src/` copies are from a newer branch, so their line numbers differ.

- **H1. The commit is durable locally before it waits.** xact.c `RecordTransactionCommit` writes the commit record
  (`XactLogCommitRecord`, :1446), flushes it (`XLogFlush(XactLastRecEnd)`, :1506), marks clog
  (`TransactionIdCommitTree`, :1518), and only then waits (`SyncRepWaitForLSN(XactLastRecEnd, true)`, :1567). The
  comment at :1563-1564 says: "at this stage we have marked clog, but still show as running in the procarray and
  continue to hold locks". So until the wait ends, no other session sees the commit.
- **H2. A backend crash ends every session and reinitializes the server, without stopping it.**
  - `runtime-config-error-handling`: "`restart_after_crash` (boolean) When set to on, which is the default,
    PostgreSQL will automatically reinitialize after a backend crash."
  - postmaster.c: a child exit other than status 0 or 1 is a crash (:2593-2594). `HandleFatalError(PMQUIT_FOR_CRASH,
    …)` sends `SIGQUIT` to every child (`TerminateChildren(sigtosend)`, :2719). Each session gets "terminating
    connection because of crash of another server process" (postgres.c:2989).
  - Once every child has gone, postmaster.c logs "all server processes terminated; reinitializing", re-creates
    shared memory and starts the startup process (`StartChildProcess(B_STARTUP)`), all inside the same postmaster
    (:3198-3222).
- **H3. Recovery makes the waiting commit visible.** The startup process replays the WAL. The commit record from
  H1 is in it, and replay marks it committed (`xact_redo_commit`, xact.c:6148, → `TransactionIdCommitTree`, :6180). The
  docs, 26.2.8.4: "If primary restarts while commits are waiting for acknowledgment, those waiting transactions will
  be marked fully committed once the primary database recovers. … Some transactions may not show as committed on the
  standby, even though they show as committed on the primary."
- **H4. From outside, the reinit is not a start.**
  - `pg_postmaster_start_time()` "Returns the time when the server started." Its value is `PgStartTime`.
  - A code search of postgres/postgres finds `PgStartTime` in five files. It is assigned only in `PostmasterMain`
    (postmaster.c:1371), in `PostgresSingleUserMain` (postgres.c:4160), and copied to `EXEC_BACKEND` children
    (launch_backend.c:773, :1033). The reinit path doesn't touch it.
  - The postmaster process doesn't exit, so a supervisor watching it sees nothing.
  - RS reads "After any start of the primary". Its words may cover a reinit, but the deployment has nothing to
    detect it by.
- **The trace** (opus, r63e; checked against H1-H4). With both standbys unreachable, a deposit mint waits. A
  memory cap kills one backend, and the server reinitializes. The pools reconnect, and the mint is visible. A
  re-send then returns the deposit (`04:830`, "MUST return the **same** deposit"). The primary is then lost, and
  `STO-54` promotes the standby further ahead, which never got the mint. Its address is later re-issued, which
  breaks `05:867` ("Allocated strictly increasing and never re-issued").
- **When it's open:** only while no standby has flushed the waiting commit. With healthy standbys that's the
  replication round trip. When both are unreachable, it's the whole outage.

## 2. What `restart_after_crash = off` changes, and what it costs

- **What changes** (postmaster.c:3185-3189): once every child has exited after a crash, the postmaster logs
  "shutting down because \"restart_after_crash\" is off" and calls `ExitPostmaster(1)`. The server stops, and its
  next start is an ordinary start, which RS sees. Crash recovery runs either way, so it adds no time.
- **Who restarts it:** the deployment's supervisor or clusterware. PostgreSQL won't. The docs name this use: "in
  some circumstances, such as when PostgreSQL is being invoked by clusterware, it may be useful to disable the
  restart so that the clusterware can gain control and take any actions it deems appropriate." Under systemd, the
  unit needs `Restart=on-failure` (`man systemd.service`: "If set to no (the default), the service will not be
  restarted").
- **Downtime added, compared with `on`:**
  - the supervisor's restart delay;
  - RS's catch-up wait before any component connects. With a healthy standby, that's its reconnection and
    catch-up. With both standbys unreachable, it lasts until one returns, which is the wait that closes the hole.
- **What `on` gives, by contrast:** under strict synchronous commit, writes after a reinit already wait for a
  standby to reconnect (CORE-1: "acknowledges a commit only once one of them has flushed it"). So `off` mainly
  costs reads, plus the restart delay.
- **The docs' own warning:** "Leaving this value set to on is normally the best way to maximize the availability
  of the database."
- **Setting it:** "This parameter can only be set in the postgresql.conf file or on the server command line." So
  it's a deployment setting, checked by `CNF-365` (S3 Run review point: crash a single backend).

## 3. Patroni

- **Does Patroni set or recommend it? No.**
  - Patroni's docs pages (replication modes, dynamic configuration, YAML settings, Patroni configuration, FAQ)
    don't mention `restart_after_crash`.
  - A GitHub code search of `patroni/patroni` (default branch) finds it in one file,
    `patroni/postgresql/available_parameters/0_postgres.yml` (`restart_after_crash: - type: Bool`). That's the
    list Patroni uses to validate user-set parameters.
- **What Patroni does when PostgreSQL is not running** (`ha.py`, `recover()`, docstring "Handle the case when
  postgres isn't running"):
  - If the node holds the leader lock and `primary_start_timeout` is 0, and a failover is possible, Patroni logs
    "Primary crashed. Failing over." and demotes.
  - Otherwise, with the leader lock, a non-zero timeout and the cluster state `in production` / `in crash
    recovery`, it starts PostgreSQL again as primary: "starting primary after failure" (ha.py:662).
  - With timeout 0 and no failover possible, it takes ha.py:692 instead: "starting as readonly because i had the
    session lock". (r63f correction, opus and sol.)
  - Neither path waits for a standby before clients connect.
  - The docs: "primary_start_timeout: the amount of time a primary is allowed to recover from failures before
    failover is triggered (in seconds). Default is 300 seconds. When set to 0 failover is done immediately after a
    crash is detected if possible."
- **With `on` (the default):** the postmaster never exits, so `recover()` doesn't run. *Inference, not verified
  in code:* Patroni doesn't treat an in-place reinit as a crash.
  - What the code does show: `config.py` notes that a failed connection "but the process creation time of the
    postmaster doesn't match the old value. It is an indicator that Postgres crashed". A reinit keeps the same
    postmaster.
- **Patroni documents the leak:** "Because of the way synchronous replication is implemented in PostgreSQL it is
  still possible to lose transactions even when using synchronous_mode_strict. If the PostgreSQL backend is
  cancelled while waiting to acknowledge replication (as a result of packet cancellation due to client timeout or
  backend failure) transaction changes become visible for other backends. Such changes are not yet replicated and
  may be lost in case of standby promotion."
- **Its guarantee covers promotion, not reads:** "Patroni will not promote a standby unless it is certain that the
  standby contains all transactions that may have returned a successful commit status to client".

## 4. The alternatives

### (i) A catch-up check on every new connection

Every session dies in a crash (H2), so after a reinit every component connection is new. If each new connection
waits before its first use, the reinit is covered without anyone detecting it.

- **The check.** On the new connection, read the primary's WAL flush position (`pg_current_wal_flush_lsn()`,
  "Returns the current write-ahead log flush location"). Then wait until one of the two standbys `OVR-19` names
  reports a `flush_lsn` at or past it in `pg_stat_replication` ("Last write-ahead log location flushed to disk by
  this standby server"). An asynchronous walsender doesn't count.
- **Why it suffices.**
  - Recovered commits sit at or below the flush position at connect time.
  - A commit still waiting stays invisible while its xid is in the procarray (H1).
  - So once a named standby has flushed past that position, it holds every commit this connection can see.
- **What else it covers.**
  - Any full start: after a fast shutdown, "Users will stop waiting if a fast shutdown is requested" (26.2.8.1),
    and those commits come back on restart (H3).
  - It doesn't depend on `restart_after_crash`, on the supervisor, or on the deployment detecting a start. So it
    can replace RS's deployment gate as well as `off`.
- **Except behind a transaction-mode pooler.** `STO-55` (`05:195-197`) allows one: "A pooler in transaction mode
  MAY front the pools only on two conditions", and "a later transaction may run on a different backend".
  - Behind such a pooler, a crash kills the backends, but the component's connection to the pooler can stay open.
    The component then sees no new connection, and the check never runs.
  - There are three ways out:
    - forbid the pooler under (i);
    - make the pooler run the same check on each new server connection, which is a deployment gate again;
    - add `off` and keep RS's deployment gate ("Both" below).
- **Costs.**
  - **Privilege.** `pg_stat_replication`'s details are hidden from other roles: walsender.c:4031, "Only superusers
    and roles with privileges of pg_read_all_stats can see details. Other users only get the pid value". So each
    component's role needs `pg_read_all_stats`, or a narrow function owned by a role that has it.
  - **A no-privilege variant.** Commit one small write under `synchronous_commit = on` on the new connection. The
    wait ends only when a standby has flushed to at least that commit's LSN (syncrep.c `SyncRepWakeQueue`: a
    waiter stays queued while `walsndctl->lsn[mode] < proc->waitLSN`, :924), and that is past everything recovered. It
    needs a row to write.
  - **Per connection:** one round trip, plus a wait of about one replication round trip when the standbys are
    healthy. Pools reuse connections, so this is paid rarely.
  - **While both standbys are down,** new connections block, reads included. Pooled connections keep serving.
    After a reinit every connection is new, so everything blocks until a standby returns. RS has that cost too.
  - **A hook in both components' pools,** which `CNF-365` tests by crashing a single backend. Behind a
    transaction-mode pooler, the hook has to move to the pooler (above).

### (ii) Patroni or other clusterware

Not closed on its own (section 3). Patroni doesn't change `restart_after_crash`. With `on` it isn't involved. With
`off` it restarts the primary in place and doesn't gate connections. Its docs name the leak. It closes the hole
only together with `off` and `primary_start_timeout = 0`, which fails over on every backend crash. The failover
happens only "if possible". Otherwise Patroni starts the node read-only under its lock (ha.py:692), which is also
ungated.

### (iii) Other options found

- **A `login` event trigger that runs (i) inside the server.** The docs (18, §38.1.1) say "The login event occurs
  when an authenticated user logs into the system". PostgreSQL 17's release notes add "event triggers that fire at
  connection time". It would cover every client, not only the components. Against it, from the same page: "Any bug
  in a trigger procedure for this event may prevent successful login to the system", and "it's recommended to
  avoid long-running queries in login event triggers". A catch-up wait is exactly a long-running query.
- **Detect the reinit and apply RS.** `pg_postmaster_start_time()` doesn't change (H4). The log line "all server
  processes terminated; reinitializing" is a signal, but the server accepts connections as soon as recovery
  ends, so a log watcher races the pools. **Rejected:** it doesn't close the hole reliably.
- **Leave it open.** The hole stays open as section 1 describes. It needs a backend crash while both standbys
  lack the commit, followed by loss of the primary before one catches up.

## 5. Summary

| Option | Closes the hole? | Main cost |
|---|---|---|
| `off` + RS (opus's r63e sentence) | Yes | A backend crash stops the whole database until the supervisor restarts it, plus RS's catch-up wait. Depends on the deployment's RS gate at every start |
| (i) per-connection check, replacing RS's gate | Yes, for reinit, restart and fast shutdown, unless a transaction-mode pooler fronts the pools (`STO-55`) | A pool hook in both components, plus `pg_read_all_stats` or a write on connect. New connections wait one replication round trip. A pooler must run the check itself, or be forbidden |
| Both: `off`, RS kept, and (i) | Yes, with or without a pooler | Both costs. Without a pooler, `off` adds nothing to the hole once (i) is in place. Behind a pooler, `off` with RS's gate is what closes the reinit |
| Patroni / clusterware alone | No | — |
| Login trigger | Yes, if it works | The docs advise against long-running login triggers, and a bug locks everyone out |
| Leave it open | No | The window above |

**Verdict.** The hole is real, verified in source and docs. Both `off` and the per-connection check close it.

- `off` is one setting and reuses RS as voted. But each process crash becomes a full stop, and it still relies on
  the deployment noticing every start.
- The per-connection check doesn't rely on any of that, and covers every way the primary comes back, unless a
  transaction-mode pooler hides the reinit from the components. Its cost falls on the two components, plus a
  permission, and on the pooler where there is one.
- Patroni doesn't close the hole on its own.

The panel (r63f) votes among these.
