S″ at `dc5d40d`: FAIL.

**CORE: CANNOT ACCEPT (blocker).** Even with E1–E3, a mint can wait unreplicated, survive primary crash/recovery, then reach the caller through API-7’s read-only replay: “returns the stored result” ([04-api-contract.md:210](https://github.com/douglaz/provisiond/blob/dc5d40dacfba4f77c65467ea85e3eebe62a0d2e3/04-api-contract.md#L210)). The caller pays; promotion loses the deposit. PostgreSQL says “those waiting transactions will be marked fully committed”. [26.2.8.4](https://www.postgresql.org/docs/17/warm-standby.html#SYNCHRONOUS-REPLICATION-HA)

Replace CORE-1’s final sentence with: “While the standby is unavailable every write waits, and `OVR-18` alarms it. A primary restarted in place MUST NOT serve either component until the named standby has durably flushed every WAL record recovered locally.”

Replace CORE-2’s restart clause with: “the engine comes up under `STO-5` unless a `STO-56` record is already open, in which case it continues that incident.” Otherwise promotion during backup recovery contradicts “a process that starts while a restore record is open is continuing that incident, not restarting” ([05-persistence.md:1522](https://github.com/douglaz/provisiond/blob/dc5d40dacfba4f77c65467ea85e3eebe62a0d2e3/05-persistence.md#L1522)).

**E1: KEEP. E2: KEEP. E3: KEEP.**

**RF: R.** It permits recovery without unnecessarily discarding the standby’s surviving writes.

**F′: UNCHANGED.** “The pass over `running` rows runs at every startup, the record open or not” remains necessary; preserve existing incidents across promotion.

**Ripple:** These missed spans each say “the only lost reply is a dead transport”:

- [03-operation-lifecycle.md:1841](https://github.com/douglaz/provisiond/blob/dc5d40dacfba4f77c65467ea85e3eebe62a0d2e3/03-operation-lifecycle.md#L1841).
- [tools/formal/Provisiond/Types.lean:23](https://github.com/douglaz/provisiond/blob/dc5d40dacfba4f77c65467ea85e3eebe62a0d2e3/tools/formal/Provisiond/Types.lean#L23).
- [docs/adr/0022…md:63](https://github.com/douglaz/provisiond/blob/dc5d40dacfba4f77c65467ea85e3eebe62a0d2e3/docs/adr/0022-a-store-error-is-a-bounded-retry-and-every-worker-write-carries-its-claim-number.md#L63).

**FA1:** Yes, for ordinary extended Execute/Sync/COMMIT: “`disable_statement_timeout();`” precedes “`CommitTransactionCommand();`”. Mandatory statement timeout does not bound this wait. [Source](https://github.com/postgres/postgres/blob/REL_18_STABLE/src/backend/tcop/postgres.c#L2826)

**FA2:** No, including with the interval enabled: “`Assert(InterruptHoldoffCount > 0)`”; the wait watches “`WL_LATCH_SET | WL_POSTMASTER_DEATH`” and defers connection-check processing. [Source](https://github.com/postgres/postgres/blob/REL_18_STABLE/src/backend/replication/syncrep.c#L142)

**FC1:** With both candidates reachable, infer the greatest same-timeline `pg_last_wal_receive_lsn()`, “received and synced to disk”, contains every acknowledgment. CORE-2 needs that comparison and primary fencing; one unreachable candidate prevents certification from configuration alone. [Documentation](https://www.postgresql.org/docs/18/functions-admin.html#FUNCTIONS-RECOVERY-INFO)

**FC2:** Confirmed: writes wait “until at least one synchronous replica comes up”. [Patroni](https://patroni.readthedocs.io/en/latest/replication_modes.html#synchronous-mode)

**Brief errors:** “only a cancel or terminate reaches that state” omits primary recovery, demonstrated by PostgreSQL’s quoted recovery behavior above.