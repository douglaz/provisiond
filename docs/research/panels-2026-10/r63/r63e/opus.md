**CORE: ACCEPT.**

**RS: DELETE, with replacement text.**
- **Trace.** One backend is OOM-killed under `MemoryMax`, as on 2026-10-21, and the server keeps running: "When set to on, which is the default, PostgreSQL will automatically reinitialize after a backend crash" (`restart_after_crash`, postgresql.org runtime-config-error-handling).
- Crash recovery marks the waiting deposit mint committed, and the pools reconnect on their own. The deployment sees no "start of the primary".
- A re-send then returns a deposit that a later promotion loses, which breaks `04:830`: "MUST return the **same** deposit".
- **Replacement:** "The deployment turns `restart_after_crash` off, so a backend crash stops the primary. After any start of the primary, …", with the rest of RS unchanged.

**DL: KEEP. OC: KEEP**, because without it CORE-2 contradicts `05:1522`. **WR: KEEP**, because CORE-1's "never serves with `synchronous_standby_names` empty" needs it. **RL: KEEP.**

**N3: ACCEPT.**

**NREC: 3.** `STO-6` (`05:104-107`) accepts only "the supervisor's restart window" as the outage of the mechanisms that stop billing. With two servers, any single failure stops `LDG-14`'s cancellation and `SEC-45`'s suspension.

**Ripple.** DL's "Why" says `ADR-0023`'s crash loop no longer follows. S''' misses two spans that still produce it:
- **`03:1765-1772` (`OPS-21`).** It says "The Stop-record bound … covers connection, execution, commit, read-back and backoff together", then exits on expiry. It also says "The deployment's supervisor MUST wait at least the Stop-record bound after a stop before it kills the engine." DL-2 amends only `OPS-49`.
  - **Replacement:** after "backoff together", insert ", but not a commit's wait for the standby (`STO-7`)". The supervisor's wait gains "and any commit's wait for the standby".
- **`03:1846-1849` (`OPS-49`).** It says "**A `lock_timeout` is a store error for this purpose** … against this same bound". `lock_timeout` aborts a statement that waits "to acquire a lock on a table, index, row, or other database object".
  - A backend in `SyncRep` keeps its locks (FA2), and so does one orphaned by any exit during a stall.
  - An engine write for that tenant, or the successor's startup pass, then times out on the lock, exhausts the bound and exits. That is the loop again.
  - So C9's "without the engine exiting" holds only when the two writes share no lock.
  - **Replacement, appended:** "A `lock_timeout` while a primary backend waits with wait event `SyncRep` (`STO-7`) does not consume the bound; `OVR-18`'s stalled-standby alarm is that loop's alarm."

**FE1: none.**
- `committed false` appears only in `Claim.lean`, `StopRecord.lean` and `Witnesses.lean`, each within one engine lifetime.
- The closest are `lost_claim_reply_exits` and `exit_store`, and both describe the store at the exit. If a promotion undoes the commit, the row is back to `running`, which satisfies `exit_store`'s first case, "`out.store.row.status = .running ∨`".
- `Restore.lean` and `Reconcile.lean` take no `StoreOutcome`.

**FE2: yes, the two Ripple spans.**
- `OPS-21`'s bound and the supervisor's kill (`03:1765`, `:1772`) end an engine whose stop-record write is waiting for the standby.
- `OPS-49`'s `lock_timeout` rule (`03:1846`) ends an engine whose write waits on a lock that a waiting backend holds.
- Nothing else does. `OVR-18` only raises an alarm ("The engine's liveness MUST be alarmed", `00:334`), and `STO-55`'s checkout refusal happens "before any transaction begins".

**Brief errors: none found.** Every line I checked matches `dc5d40d`. `ADR-0023:187` holds the rejected option and `ADR-0042:23` holds C5's clause.
