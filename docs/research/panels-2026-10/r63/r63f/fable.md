**Draft (fable, r63f).** Facts first: I checked FA1-FA2, FL1-FL4, H1-H4, §2-§3 and the STO-54 merge against the sources. All hold. No brief errors found.

## S2 — STOP: **PICK B**

**OTHER (A): ACCEPTABLE.** It loses no money: `03:1738` "A transaction already sent MAY finish", and `03:1771` "a row still `running` goes to restart recovery as after a crash" already cover the orphan. Its costs: every stop during a stall doubles the engine's connections (`05:191`) and throws away each in-flight outcome, which `03:1831` calls "a money parameter", into `OPS-26`'s rota. B keeps the outcome and records it when a standby returns.

**MOVE:** a supervisor on `OVR-19` that cannot be told to wait. Even then a kill is "a crash" (`03:1773`), so B degrades to A's outcome, not below it.

**P:** P1 KEPT. P2 MOVED to `OVR-18`'s stalled-standby alarm (C6) during a stall; unchanged otherwise. P3 KEPT, extended across the stall. P4 KEPT only with LOCK-B.

## S2 — LOCK: **PICK B**, with two repairs

**OTHER (A): ACCEPTABLE** in money, but P4 LOST. Trace: an `api` backend, or an orphan from any crash, waits in `SyncRep` holding `LDG-35`; the successor's startup pass "at startup, before any claim" (`03:352-353`) writes, blocks, times out, exhausts, exits, restarts. That is `ADR-0023:167-168` "the successor's startup pass — which writes — stalls the same way. A crash loop".

**Repairs to LOCK-B's text:**
- FL1: add to `00:408`'s row and `STO-7`: "`lock_timeout` MUST be shorter than `statement_timeout`, so a lock wait always surfaces as a lock timeout" (docs: otherwise "the statement timeout would always trigger first").
- FL3: append "The engine reads the holder's wait event from `pg_stat_activity`, so its role MUST hold `pg_read_all_stats` or the privileges of `api`'s role (`OVR-19`); without them the columns are null."
- FL2: no OPS-49 change; the migrator runs its own bound (`STO-13`). But `05:1400`'s "so that the time `api` queues behind a migration is bounded" is false while the DDL's commit waits. Both forms miss it. `STO-13` gains ", except while that DDL's commit waits for a standby (`STO-7`)".

**P under LOCK-B:** P2's "a lock timeout outside any bound is an unalarmed loop" (`03:1849`) MOVED: the loop is alarmed by C6. P4 KEPT.

## S3: **PICK S3-A**

Closes §1: with `off`, postmaster.c:3186-3190 logs "shutting down because restart_after_crash is off" and calls `ExitPostmaster(1)`, so the only way back is a start RS gates ("After any start of the primary, the deployment MUST NOT let a component connect … until one of them has flushed"). The mint is below that WAL end. **Cost accepted:** a backend crash stops the primary until the supervisor restarts it and RS clears; the delta over `on` is the restart delay, since every session dies either way (H2). No pooler problem.

**OTHER:**
- **S3-B: ACCEPTABLE.** Closes it including fast shutdown. Costs: a pool hook in both components, `pg_read_all_stats` (walsender.c:4031), the pooler clause. The no-privilege variant is simpler text: "MUST NOT read on a new connection before a commit it made on that connection was acknowledged" (syncrep.c:924 makes that past every recovered commit), but needs a writable row.
- **S3-AB: ACCEPTABLE.** Both costs; `off` adds nothing without a pooler.
- **S3-P: NOT ACCEPTABLE.** ha.py:669 "starting primary after failure" with no gate; Patroni's own docs: "it is still possible to lose transactions even when using synchronous_mode_strict".
- **S3-N: NOT ACCEPTABLE.** §1's trace re-issues an address against `05:867` "Allocated strictly increasing and never re-issued". Money.

## Ripple (both forms miss)

- `05:1400` (`STO-13`), above.
- `00:338-339` `OVR-18` is now the alarm LOCK-B leans on; C6's text must land with it.
- `00:408` gains the `lock_timeout` < `statement_timeout` constraint; `OVR-19` gains the role requirement.

## Brief errors

None. Verified: SyncRep's loop checks only `ProcDiePending` and `QueryCancelPending` (18-syncrep.c:300, :317), never `ClientConnectionLost` (postgres18.c:3379), so FA2 holds even with `client_connection_check_interval`. `transaction_timeout` is disabled at 18-xact.c:2373 before `RecordTransactionCommit` at :2381 (FA1). STO-54 merge: OC's clause as its own sentence changes no meaning.
