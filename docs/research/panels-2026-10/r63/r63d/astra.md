**CORE: CANNOT ACCEPT.** Trace: deposit mint waits; primary crashes and recovers; an idempotent replay reads the now-visible deposit; primary fails permanently before replication catches up; named-standby promotion loses it. This breaks [04-api-contract.md:830](https://github.com/douglaz/provisiond/blob/dc5d40dacfba4f77c65467ea85e3eebe62a0d2e3/04-api-contract.md#L830): “re-sending one MUST return the **same** deposit”.

Append to CORE-1: “After primary recovery, components MUST NOT connect until the named standby has flushed all WAL through recovery completion.”

**E1: KEEP. E2: KEEP. E3: KEEP.**

**RF: R.** The restore procedure can quarantine a surviving standby without deliberately discarding its additional data.

**F′: UNCHANGED.** Its “runs at every startup” rule remains necessary; a replicated open restore record still governs incident continuation.

**Ripple:**

- [03-operation-lifecycle.md:1841](https://github.com/douglaz/provisiond/blob/dc5d40dacfba4f77c65467ea85e3eebe62a0d2e3/03-operation-lifecycle.md#L1841): “the only lost reply is a dead transport”.
- [10-conformance-checklist.md:1079](https://github.com/douglaz/provisiond/blob/dc5d40dacfba4f77c65467ea85e3eebe62a0d2e3/10-conformance-checklist.md#L1079): “keeps serving under a stalled standby”.
- [README.md:94](https://github.com/douglaz/provisiond/blob/dc5d40dacfba4f77c65467ea85e3eebe62a0d2e3/README.md#L94): “synchronous commit only on the two writes with no second truth”.
- `docs/adr/0022-a-store-error-is-a-bounded-whole-transaction-retry.md`: the exact filename needs confirmation; its line 23 says “The lost acknowledgement is real, and it has one shape.” That argument also needs amendment.

**FA1:** Yes, for ordinary extended-protocol commits: explicit transaction commands and implicit commits at `Sync` call `finish_xact_command`, whose “`disable_statement_timeout();`” precedes “`CommitTransactionCommand();`”. The mandatory timeout therefore does not normally cancel this wait. [PostgreSQL source](https://raw.githubusercontent.com/postgres/postgres/REL_18_STABLE/src/backend/tcop/postgres.c)

**FA2:** No. The wait watches “`WL_LATCH_SET | WL_POSTMASTER_DEATH`”, not the client socket. Interrupts are held; `client_connection_check_interval` checks remain deferred. Closing connections can therefore leave waiting backends. [Source](https://raw.githubusercontent.com/postgres/postgres/REL_18_STABLE/src/backend/replication/syncrep.c)

**FC1:** Yes, if both candidates remain inspectable: compare durable WAL positions on the same timeline and select the furthest advanced. One survivor alone cannot establish completeness. CORE-2 would need quorum-aware election and membership rules, beyond naming a standby. Patroni requires comparison with “the LSN on at least one node”. [Documentation](https://patroni.readthedocs.io/en/latest/replication_modes.html)

**FC2:** Confirmed: strict mode blocks writes “until at least one synchronous replica comes up”; streaming must also advance through the commit. [Documentation](https://patroni.readthedocs.io/en/latest/replication_modes.html)

**Brief errors:** “only a cancel or terminate reaches that state” overlooks primary recovery: waiting transactions “will be marked fully committed”. That is the CORE counterexample above. [PostgreSQL documentation](https://www.postgresql.org/docs/18/warm-standby.html#SYNCHRONOUS-REPLICATION-HA)