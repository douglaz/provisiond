**CORE: CANNOT ACCEPT.** C9’s “without the engine exiting” and C13’s “DL answers its crash loop” fail under contention: transaction A holds `LDG-35` while waiting for replication; engine transaction B repeatedly times out acquiring that lock. `03-operation-lifecycle.md:1847` says “A `lock_timeout` is a store error”; `:1829` requires “the engine MUST exit non-zero”. DL excludes A’s standby wait, not B’s lock wait. PostgreSQL confirms “transaction locks continue to be held until the transfer is confirmed.” ([§26.2.8.3](https://www.postgresql.org/docs/current/warm-standby.html#SYNCHRONOUS-REPLICATION-PERFORMANCE))

Replacement within CORE: delete C9’s “without the engine exiting”; replace C13’s crash-loop assertion with “DL removes deadline-driven abandonment during the standby wait; lock-contention exhaustion can still restart the engine.” Accepting that residual belongs to the owner.

**RS: KEEP. OC: KEEP. WR: KEEP. RL: KEEP.**

**DL: DELETE as written; refer to owner.** Its universal deadline exemption conflicts with the stop-record deadline quoted below. Replacement for DL-1/2’s exemption: “Ordinary store-call deadlines and the Store-retry bound exclude a commit’s wait for the standby. `OPS-21`’s Stop-record bound and exit rules remain applicable.” Retain DL-3. This preserves bounded shutdown but does not solve abandoned-backend accumulation or the contention trace above; the owner must choose the remaining operational policy, including the stated C1 alternative.

**N3: ACCEPT** as the three-server substitution; it does not resolve the shared DL/CORE findings.

**NREC: 3.** One database-server failure preserves a path to synchronous writes without first provisioning a replacement.

**FE1:** None. `Claim.lean:426` states “`exited` has no successor but itself”; `StopRecord.lean:9` explicitly excludes “restart”. Their `committed false` traces do not cross a restart or promotion.

**Ripple / FE2:** Yes. `03-operation-lifecycle.md:1765–1768` says the Stop-record bound “covers connection, execution, commit, read-back and backoff together” and “On expiry the worker MUST abandon the record, and the engine MUST log loudly … and exit.” A stop-record commit stalled in replication therefore still has a deadline. `:1738` additionally says “the engine MUST NOT wait for it past that bound.” The contention-triggered engine exit above is another remaining path; no external stop is needed.

**Brief errors:** The claim that DL answers `ADR-0023`’s crash loop is false generally: the lock-timeout trace above survives DL. The restart correction is sound.