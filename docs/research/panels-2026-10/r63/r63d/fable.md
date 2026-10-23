**Votes**

- **CORE: ACCEPT.** One missed consequence is under Ripple.
- **E1: KEEP.** Load-bearing. FA2 shows a close never reaches the cancel branch; a driver's cancel request does (libpq's cancel path, which pgx sends by default on a context deadline, from memory, not verified here).
- **E2: KEEP.** Load-bearing. After FA1, `pg_cancel_backend`/`pg_terminate_backend` are the only remaining routes to a visible, unreplicated commit short of postmaster death.
- **E3: DELETE.** It changes no behaviour. `OPS-49` repeats the transaction and the write-once guard "has seen its earlier attempt land, and moves on" (`03:1834-1835`), which is what an ack does. Replacement: delete, or alarm it under `OVR-18` if a tripwire is wanted.
- **RF: R.** `STO-54`'s procedure is written for a store that "lands at some instant T − Δ" (`05:1466`), which is exactly a lagging standby; F forbids a state that only exists after a violation and offers the lossier path.
- **F': UNCHANGED.** F1-F8 only touch `running`-row passes and the freeze; nothing in S'' changes a restore from backup.

**Ripple (missed spans)**

- `05:141-143` with C1: the client deadline now fires on every write under a stall, and the server backend keeps waiting (FA2), so each expiry orphans one `max_connections` slot outside every pool. `05:189-193`'s "together fit inside `max_connections`" stops holding, which C7's deleted cap used to guarantee. Replacement for C1's end: "…(`OPS-49`). The commit's wait for the standby has no client-side deadline: a backend whose client has gone keeps waiting and would hold a slot outside every pool, so a dead transport is detected by TCP keepalives (`OVR-19`), not a deadline."
- C12: rejoin the old primary as a standby before asserting the restart branch, or the successor's startup writes wait (FC2). Same for CORE-2: add "writes resume when a standby streams from the promoted store".
- `README.md` ADR index needs an `0045` row.

**Facts**

- **FA1: no.** Extended protocol: `exec_execute_message` calls `finish_xact_command()` for a transaction-control command, and otherwise `disable_statement_timeout()` after Execute; `PqMsg_Sync` then calls `finish_xact_command()`, whose first act is "cancel active statement timeout after each command". `transaction_timeout` is disabled in `CommitTransaction` before `RecordTransactionCommit()`. E3 is not load-bearing.
- **FA2: no.** The loop tests only `syncRepState`, `ProcDiePending`, `QueryCancelPending` and `WL_POSTMASTER_DEATH`; "Neither [`CHECK_FOR_INTERRUPTS` nor `ProcessInterrupts`] appears inside the loop", so `ClientConnectionLost` is never evaluated. The transaction stays "still show[ing] as running" until the ack.
- **FC1: yes, by LSN.** `ANY 1` lets "each commit proceed as soon as at least any" one replies, so neither standby holds every ack by construction; WAL is linear, so the standby with the greatest flushed LSN does. CORE-2 would need "the standby with the greatest flushed LSN is promoted", and `OVR-19`'s single identifier would become a set. Patroni: "will not promote a standby unless it is certain that the standby contains all transactions".
- **FC2: confirmed.** "the primary is not be available for writes … blocking all client write requests until at least one synchronous replica comes up." CORE-1's non-empty `synchronous_standby_names` has the same effect: "If no synchronous standby names are specified here, then synchronous replication is not enabled."

**Brief errors:** none found.
