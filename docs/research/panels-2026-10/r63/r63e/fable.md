**Vote (Fable, r63e)**

**CORE: ACCEPT.** Every anchor checked in the clone: `05:147-153`, `05:186-188`, `05:199`, `05:1474`, `05:1480-1484`, `03:408-409`, `00:338-339`, `00:412`, `10:1057-1087`, `README.md:94`, `Claim.lean:318-319`, `Restore.lean:28`. `CNF-364` and `ADR-0044` are the last ids, so `CNF-365` and `ADR-0045` are free.

**RS: KEEP.** postgresql.org 26.2.8.4 reads verbatim "If primary restarts while commits are waiting for acknowledgment, those waiting transactions will be marked fully committed once the primary database recovers." 26.2.8.1: "Users will stop waiting if a fast shutdown is requested." Without RS, a deposit visible after the restart is returned by `04:830` ("re-sending one MUST return the **same** deposit"), then lost on promotion, and `05:867`'s "Allocated strictly increasing and never re-issued" breaks.

**DL: KEEP.** Without it, FA2 plus E1 leaves each timed-out write's backend outside every pool holding locks, so `05:188-193`'s "together fit inside `max_connections`" stops holding. See Ripple for the one bound DL-2 misses.

**OC: KEEP.** `05:1521-1522`: "a process that starts while a restore record is open is continuing that incident, not restarting". The standby replicates an open record; without OC, CORE-2 contradicts that sentence.

**WR: KEEP.** CORE-1 says "the primary never serves with `synchronous_standby_names` empty"; without WR nothing names what the promoted store waits on, and `00:405`'s name is startup-validated.

**RL: KEEP.** The two added cases are exactly the states where the promoted store may lack a commit a component saw; without them `05:1467`'s "never a restart" is defeated by a promotion after E2 was violated.

**N3: ACCEPT.** The "further ahead" rule is FC1; `OVR-19`'s two-identifier row and the neither-as-restart check close it.

**NREC: 3.** With two servers, RS makes every primary restart and every write wait on the one standby; with three, a single failure stops neither.

**Ripple.** S''' misses `OPS-21`. `03:1763-1764`: "The Stop-record bound runs until the record lands and covers connection, execution, commit, read-back and backoff together. On expiry the worker MUST abandon the record, and the engine MUST log loudly … and exit." `03:1771-1773`: "The deployment's supervisor MUST wait at least the Stop-record bound after a stop before it kills the engine." A stop during a stall exits the engine mid-wait, which DL-1's "no client-side deadline cuts it short" denies. Replacement, mirroring DL-2 at `03:1764`: "together, but not a commit's wait for the standby (`STO-7`), during which the record is neither abandoned nor the engine killed". `00:402`'s row quotes that sentence and follows it.

**FE1.** None. `Restore.lean` contains no `StoreOutcome` (grep empty), so no theorem carries a `committed false` across a `restart` or `restore` boot. Nearest: `Claim.lean:436-441` `lost_claim_reply_exits` asserts the stranded row is `.running` at the exit, within one trace.

**FE2.** Yes, `OPS-21` above: the Stop-record bound "covers … commit" and "never resets", then the supervisor kill. `/healthz` (`04:7`) is liveness only; `OVR-18` alarms and does not kill.

**Brief errors.** None material. `CONTEXT.md:185`'s phrase begins at `:184` ("a restart loses no committed" / "work"), and the Lean files live under `tools/formal/Provisiond/`.
