**S2 STOP — PICK B.** Under A, repeated rolls can strand additional backends until connections run out: PostgreSQL waiters “continue to hold locks” (`18-xact.c:1564`). B avoids creating those orphans through orderly shutdown. **OTHER A: ACCEPTABLE**, accepting that availability cost. **MOVE:** a deployment requiring bounded shutdown, with explicit admission accounting for stranded backends.

**S2 LOCK — PICK A. OTHER B: NOT ACCEPTABLE as written.** Set `statement_timeout` shorter than `lock_timeout`. A migrator’s DDL commit waits in `SyncRep`, holding `ACCESS EXCLUSIVE`; an engine statement blocks, times out repeatedly, and exhausts `OPS-49`: “the engine MUST exit non-zero” ([03-operation-lifecycle.md:1829](https://github.com/douglaz/provisiond/blob/dc5d40dacfba4f77c65467ea85e3eebe62a0d2e3/03-operation-lifecycle.md#L1829)). B exempts only `lock_timeout`. Cross-role invisibility independently defeats its promised classification.

**MOVE:** an observable, causal exemption covering both timeout types and migrator blockers without exempting unrelated failures.

**P, separately for each pick:**

| Pick | P1 | P2 | P3 | P4 |
|---|---|---|---|---|
| STOP-B | KEPT | MOVED for direct waits to standby alarm; otherwise KEPT | MOVED to time excluding `SyncRep` | LOST for contention |
| LOCK-A | KEPT | KEPT for contention; direct waits MOVED to alarm | MOVED under STOP-B | LOST for contention |

P4’s direct-wait deadline loop closes; its contention variant remains.

**LOCK-B replacement:** “A whole-transaction repeat, including backoff, caused by `lock_timeout` or `statement_timeout` while blocked directly or indirectly behind a `SyncRep` waiter does not consume the Store-retry bound. The deployment MUST provide the engine sufficient visibility across engine, `api` and migrator roles to establish that cause. Unestablished or unrelated failures retain the ordinary bound. `OVR-18` alarms the excluded wait.”

**S3 — PICK S3-A.** It closes §1: `off` exits the postmaster, making RS’s “MUST NOT let a component connect” gate apply ([forms-final.md:22](/var/tmp/provisiond-panel-r63e/forms-final.md:22)). PostgreSQL documents that `on` “will automatically reinitialize after a backend crash.” ([PostgreSQL 18](https://www.postgresql.org/docs/18/runtime-config-error-handling.html)) Accepted cost: read unavailability through supervised restart and standby catch-up.

**OTHER:** S3-B ACCEPTABLE with its pooler clause; S3-AB ACCEPTABLE, with redundant safeguards. S3-P and S3-N NOT ACCEPTABLE: mint → backend crash → recovered mint returned → primary lost → promotion lacking mint → address reissued. This breaks “Allocated strictly increasing and never re-issued” ([05-persistence.md:867](https://github.com/douglaz/provisiond/blob/dc5d40dacfba4f77c65467ea85e3eebe62a0d2e3/05-persistence.md#L867)) and can lose a paid deposit.

**Ripple:**

- Qualify STOP-B’s “no client-side deadline cuts it short” (`05:143`) and corresponding `03:1830` clause for LOCK-A: “The standby wait itself has no deadline; `OPS-49`’s contention-exhaustion exit remains applicable.”
- Update untouched clock quotations: `10-conformance-checklist.md:1602` and `tools/formal/Provisiond/StopRecord.lean:4,118` quote “measured from the stop”; `docs/adr/0044-a-survived-stop-records-execute-within-a-bound.md:47` also quotes “MUST wait at least the Stop-record bound after a stop”.
- S3-B adds a pooler condition but leaves `05-persistence.md:195`: “MAY front the pools only on two conditions”.

**Brief errors:** §3’s “Otherwise … starts PostgreSQL again as primary” overgeneralizes: with timeout zero and no failover, `ha.py.src:692` says “starting as readonly because i had the session lock”; `:662`’s primary-restart branch requires a truthy timeout. The table incorrectly attributes `transaction_timeout` to STO-7/OVR-19: `00-overview.md:408` lists “`statement_timeout`, `lock_timeout`, `idle_in_transaction_session_timeout`”. No substantive H1–H4 or STO-54 merge error found.