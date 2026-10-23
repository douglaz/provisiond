I reviewed r63e S''' against `dc5d40d`: **FAIL**.

**CORE: CANNOT ACCEPT — C9 blocker.** Trace: an `api` extension stalls in `SyncRep` holding the tenant lock; engine metering repeatedly encounters `lock_timeout`. `03-operation-lifecycle.md:1847` calls that “a store error”; `:1829` requires “the engine MUST exit non-zero”. That exits the process hosting any other stalled engine writer. PostgreSQL confirms “transaction locks continue to be held until the transfer is confirmed”. [PostgreSQL documentation](https://www.postgresql.org/docs/18/warm-standby.html)

Replacement in C9 only: replace “each block without the engine exiting” with “each wait in `SyncRep`”; add “Exercise a contending engine write and assert `OPS-49`’s bounded retry and exit.”

**RS: KEEP. DL: DELETE → owner. OC: KEEP. WR: KEEP. RL: KEEP.**

**N3: ACCEPT.**

**NREC: 3** — a surviving standby can acknowledge writes after one server fails.

**DL blocker / Ripple:** `OPS-21` remains incompatible with the categorical deadline exemption. `03-operation-lifecycle.md:1765–1768` says “The Stop-record bound runs until the record lands and covers connection, execution, commit, read-back and backoff together”; expiry requires “MUST abandon the record” and engine “exit”. At `:1738`, “the engine MUST NOT wait for it past that bound”. S''' also misses `:1847–1850`’s lock-timeout accounting, exercised above.

Replacement deadline rule for DL-1/DL-2 only:

> A standby wait has no server-side timeout and is excluded from that call’s store-call and Store-retry deadlines. `OPS-21`’s stop bounds still apply.

Retain DL-3. Send detached-backend accounting to the owner under the stated C1 alternative: these exits can still leave waiting backends outside pools, whereas `05-persistence.md:191` requires allocations to “fit inside `max_connections`”.

**FE1:** None. `tools/formal/Provisiond/Claim.lean:15` explicitly omits “`OPS-15`’s startup pass”; `StopRecord.lean:9–10` says “No provider call, restart, fan-out or competing execution runs here.” Restore’s restart trace has no `StoreOutcome`.

**FE2:** Yes: `OPS-21`’s stop-record deadline explicitly covers “commit” and requires “exit” (`03-operation-lifecycle.md:1766–1768`); a sibling’s lock-timeout exhaustion can also exit the engine.

**Brief errors:** No additional factual errors identified.