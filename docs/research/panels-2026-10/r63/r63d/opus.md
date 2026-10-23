**CORE: CANNOT ACCEPT.** Trace: the standby is partitioned and a mint waits in `SyncRep`. The primary crashes, or is shut down as E2 allows, and restarts: "those waiting transactions will be marked fully committed once the primary database recovers" (26.2.8.4). The caller reads the deposit and pays it. A read never waits, because xact.c waits only "if (wrote_xlog && markXidCommitted)". The primary is then lost, and CORE-2 promotes the standby as a restart with no skip-forward. That breaks `05:867` "Allocated strictly increasing and never re-issued". Insert after CORE-2's first sentence: "After any start of the primary, no component connects to it until the standby `STO-7` names has flushed the primary's WAL to its position at that start: PostgreSQL marks waiting commits committed on recovery whether or not that standby has them." Unlike the dropped log clause, this can be checked while the primary's disk exists.

**E1 KEEP. E2 KEEP**: its shutdown carve-out is safe only with that sentence. **E3 KEEP**: not load-bearing (FA1).
**RF: R.** F's MUST NOT doesn't prevent the act, and a store promoted anyway still needs a classification.
**F': UNCHANGED.** It governs only restores and their record; S'' opens none, and R's promotions open one.

**Ripple**
- `05:191` "together fit inside `max_connections` less the server's reserved slots": false under a stall. A closed connection's backend keeps its slot (FA2), and each `OPS-49` exit (`03:1826`) opens a fresh pool.
- `CONTEXT.md:185` "a restart loses no committed work": a promotion loses waiting commits.
- `README.md:94` "durability is bought with synchronous commit only on the two writes with no second truth".

**Facts**
- FA1: Yes. Both Sync and an Execute of COMMIT call `finish_xact_command`, whose body runs "disable_statement_timeout();" before "CommitTransactionCommand();".
- FA2: No. The loop waits on "WL_LATCH_SET | WL_POSTMASTER_DEATH" and tests only `ProcDiePending` and `QueryCancelPending`. `ClientConnectionLost` is set in `ProcessInterrupts`, which the loop never calls.
- FC1: Yes, if both standbys answer. The one with the greater `pg_last_wal_receive_lsn()` ("received and synced to disk") holds every acknowledged commit. If one standby is also lost, no. CORE-2 needs: "promote the furthest-flushed standby, only once n−k+1 of `ANY k`'s n answer."
- FC2: Confirmed. Patroni strict mode is "blocking all client write requests until at least one synchronous replica comes up".

**Brief errors**
- "only a cancel or terminate reaches that state": a primary restart also does (26.2.8.4). A terminate (ProcDie) also breaks the wait, and `ProcArrayEndTransaction` follows, so the commit becomes visible.
