# Panel brief r63d: Q1 (pv-s4m) re-formed under synchronous replication. 2026-10-23

You are one of four independent reviewers. Your working directory is a fresh throwaway clone of `provisiond-spec`
at `dc5d40d`. Read `AGENTS.md` first. You MAY edit tracked files in the clone to test a claim. Write nothing outside
it. Never commit, push, call a provider API, or run `br`. **Run no gate and no `lake`.** Keep `TMPDIR` as set. Do
not delegate, background or wait on anything. Have a draft by minute 12. Web lookups are allowed only for
`postgresql.org/docs`, the PostgreSQL source at `github.com/postgres/postgres` or `raw.githubusercontent.com/postgres/postgres`
(the official mirror), and `patroni.readthedocs.io`. Quote what you use.

## Settled (not for re-vote)

- **The owner's decision on Q1, verbatim: "I think we should just suppose synchronous replication".** The form
  below applies it. Earlier forms (S', "every promotion is a restore") are superseded.
- Q2 (pv-n98) is decided as form F' (`/var/tmp/provisiond-panel-r63c/forms-final.md`, "Form F'"). Q3 is decided:
  one Run.
- `STO-54`'s restore procedure stays for a restore from backup or point-in-time recovery.

## Sources (verified by the manager, 2026-10-23)

- 26.2.8: "When requesting synchronous replication, each commit of a write transaction will wait until
  confirmation is received that the commit has been written to the write-ahead log on disk of both the primary and
  standby server. The only possibility that data can be lost is if both the primary and the standby suffer crashes
  at the same time." "The minimum wait time is the round-trip time between primary and standby."
- `synchronous_commit` (runtime-config-wal): "When set to on, commits wait until replies from the current
  synchronous standby(s) indicate they have received the commit record of the transaction and flushed it to durable
  storage."
- 26.2.8.1: "Users will stop waiting if a fast shutdown is requested. However, as when using asynchronous
  replication, the server will not fully shutdown until all outstanding WAL records are transferred to the
  currently connected standby servers."
- 26.2.8.3: "transaction locks continue to be held until the transfer is confirmed."
- 26.2.8.4: "Such transaction commits may never be completed if any one of the synchronous standbys should crash."
  "If primary restarts while commits are waiting for acknowledgment, those waiting transactions will be marked fully
  committed once the primary database recovers. There is no way to be certain that all standbys have received all
  outstanding WAL data at time of the crash of the primary. Some transactions may not show as committed on the
  standby, even though they show as committed on the primary. The guarantee we offer is that the application will
  not receive explicit acknowledgment of the successful commit of a transaction until the WAL data is known to be
  safely received by all the synchronous standbys."
- monitoring-stats: wait event "SyncRep Waiting for confirmation from a remote server during synchronous
  replication."
- PostgreSQL source (official mirror), `src/backend/replication/syncrep.c`, inside the wait loop:
  - `ProcDiePending`: WARNING "canceling the wait for synchronous replication and terminating connection due to
    administrator command", detail "The transaction has already committed locally, but might not have been
    replicated to the standby.", then `whereToSendOutput = DestNone`.
  - `QueryCancelPending`: WARNING "canceling wait for synchronous replication due to user request", same detail,
    then `break` (the commit completes).
  - The wait is `WaitLatch(MyLatch, WL_LATCH_SET | WL_POSTMASTER_DEATH, -1, WAIT_EVENT_SYNC_REP)`.
- `src/backend/tcop/postgres.c` `finish_xact_command`: `disable_statement_timeout();` runs before
  `CommitTransactionCommand();`. The manager checked only the simple-query path. `StatementTimeoutHandler`
  (`postinit.c`) sends SIGINT.
- Patroni, replication modes: "If the PostgreSQL backend is cancelled while waiting to acknowledge replication (as
  a result of packet cancellation due to client timeout or backend failure) transaction changes become visible for
  other backends. Such changes are not yet replicated and may be lost in case of standby promotion."
  `synchronous_mode_strict` "prevents Patroni from switching off the synchronous replication on the primary when no
  synchronous standby candidates are available". "When using PostgreSQL synchronous replication, use at least
  three Postgres data nodes to ensure write availability if one host fails." Patroni is an example deployment, not
  a requirement.

## The spec today (dc5d40d)

- `05:147` (`STO-7`): "`synchronous_commit` is `local` on every connection and `on` inside exactly two
  transactions", "against the standby `OVR-19` names".
- `05:1474` (`STO-54`): "The deployment runs asynchronous streaming replication". `00:338` "a stalled synchronous
  standby", `:405` "Synchronous standby name".
- `05:1480-1484`: "Synchronous commit on every write was rejected because PostgreSQL has no server-side timeout for
  the standby wait, which would make `OPS-49`'s lost reply the steady state on every write (`ADR-0023`)". The
  owner's decision reverses this.

## Form S''

**CORE** (one vote):

- CORE-1, `STO-7`'s paragraph `05:147-153` ("**`synchronous_commit` is `local` … re-sends its key.") becomes:
  "**Every commit waits for the standby** (*amended 2026-10-23, `ADR-0045`; until then "`synchronous_commit` is
  `local` on every connection and `on` inside exactly two transactions"*): `synchronous_commit` is `on` on every
  connection and `synchronous_standby_names` names the standby `OVR-19` names, so PostgreSQL acknowledges a commit
  only once that standby has flushed it to durable storage. The deployment MUST NOT let the primary commit without
  that standby: no connection lowers `synchronous_commit`, and the primary never serves with
  `synchronous_standby_names` empty. While the standby is unavailable every write waits, and `OVR-18` alarms it."
- CORE-2, `STO-54` gains, after its posture bullets: "- **Promoting the synchronous standby is a restart**
  (*added 2026-10-23, `ADR-0045`*). The standby `STO-7` names holds every commit the primary acknowledged, so its
  promotion loses none, and the engine comes up on it under `STO-5`'s restart rule. Before any component connects
  to the promoted store, the deployment MUST stop every engine and `api` process that was connected to the old
  primary, and the old primary MUST NOT serve a component again: it may hold commits the standby lacks ("Some
  transactions may not show as committed on the standby, even though they show as committed on the primary"), so
  it rejoins only as a standby of the promoted store." *(RF's sentence follows here.)*
- Conforming edits, also part of CORE:
  - C1, `05:141-143`: "and a lost reply is only ever a dead transport (`OPS-49`)" becomes "and a lost reply is a
    dead transport or a commit still waiting for the standby (`STO-7`, `OPS-49`)".
  - C2, `05:1474`: "The deployment runs asynchronous streaming replication" becomes "The deployment runs
    synchronous streaming replication (`STO-7`)".
  - C3, `05:1480-1484`: the bullet "**Synchronous commit is bought for the two writes with no second truth.** …
    (`ADR-0023`)." is deleted.
  - C4, `STO-5`'s note `05:83-84` gains at its end: "*Promoting the standby `STO-7` names is a restart; `STO-54`
    says what any other promotion is (`ADR-0045`).*"
  - C5, `03:408-409` (`OPS-15`): ", nor on a store that may have lost committed writes, such as a promoted
    asynchronous standby" is deleted.
  - C6, `00:338-339` (`OVR-18`): "and a stalled synchronous standby, which hangs the two money-in transactions
    `STO-7` commits synchronously and nothing else." becomes "and a stalled synchronous standby, on which every
    write waits (`STO-7`)."
  - C7, `05:186-188`: the bullet "**Synchronous-commit transactions are capped per replica** …" is deleted, and so
    is `00:412`'s `OVR-19` row "Synchronous-commit concurrency cap per replica".
  - C8, `05:199`: "`LDG-35`'s transaction-scoped locks, `STO-12`'s migrator lock and `SET LOCAL
    synchronous_commit` are compatible" becomes "`LDG-35`'s transaction-scoped locks and `STO-12`'s migrator lock
    are compatible".
  - C9, `CNF-296` (`10:1057-1063`) becomes: "**Every write waits for the standby** (*amended 2026-10-23,
    `ADR-0045`; was "The two synchronous writes hang alone"*). Stall the named standby. Assert an engine write and
    an `api` write each block, a read still succeeds, and `OVR-18`'s alarm fires. Release the standby and assert the
    caller's re-sent funding request returns the same deposit (`API-45`) and the rail's replayed settlement credits
    once (`STO-31`). Then assert `synchronous_commit` reads `on` on a freshly checked-out connection (`CNF-56`'s
    method). (`STO-7`, `STO-54`, `OVR-18`)"
  - C10, `CNF-299` (`10:1085-1087`): "Then stall the standby (`CNF-296`'s method) with more funding requests than
    the synchronous-commit cap and assert no more than the cap's connections are occupied and a suspension request
    (`API-58`) is admitted." is deleted.
  - C11, `Restore.lean:28`: "What the model omits: the promoted-standby condition and the money release." becomes
    "What the model omits: the money release. Promoting the synchronous standby is a restart (`STO-54`)."
  - C12, new `CNF-365`: "**Promoting the synchronous standby is a restart** (`ADR-0045`). With both components
    running, let one create commit step 8 and order, and claim a second; kill the primary and promote the named
    standby by the deployment's procedure. Assert every engine and `api` process connected to the old primary has
    stopped before any component connects to the promoted store, and that the old primary serves no component; both
    rows are on the promoted store; no restore record is written; and the successor's startup pass takes
    `OPS-15`'s restart branch. (`STO-5`, `STO-7`, `STO-54`, `OPS-15`)"
  - C13, new `ADR-0045`: records the owner's decision verbatim; amends `ADR-0023` (its rejected option
    "Synchronous replication on every commit, recovery point zero" is adopted, and the stall it rejected is accepted
    as writes that wait) and `ADR-0042` (C5's clause). It quotes the PostgreSQL sources above, labelling the source
    code as such, and names Patroni's strict mode as an example deployment only. Under rejected options: S' (every
    promotion a restore), B, D, and whichever of R or F loses.

**The cancelled-wait clauses** (one vote each; all three would sit in `STO-7` after CORE-1):

- E1: "No component sends PostgreSQL a cancel request on a store connection: a store call whose client-side deadline
  expires closes its connection, and the transaction's fate is the server's (`OPS-49`)."
- E2: "The deployment MUST NOT cancel or terminate a primary backend while it waits for the standby (wait event
  `SyncRep`), other than by shutting the primary down."
- E3: "A commit that returns PostgreSQL's warning "The transaction has already committed locally, but might not
  have been replicated to the standby." is not acknowledged: the component treats it as a lost reply (`OPS-49`)."
- Why: Patroni's note above. A cancelled wait makes a commit visible to other sessions before the standby has it,
  so a later promotion can drop a row another process acted on (`ADR-0023`'s cases, e.g. a lost extension
  that routes a paid machine to destruction). Under strict settings, only a cancel or terminate reaches that state.
  A manager's clause conditioning the restart on the old primary's log was dropped before launch: it can't be checked
  once the primary's disk is gone.

**RF** (one vote), after CORE-2:

- **R:** "Any other promotion — of a standby `STO-7` does not name, or after the primary committed without it — is
  a restore: the procedure below runs on it, and `STO-56`'s record is committed into the promoted store before
  either component is started." R also brings: `STO-56` "written into the restored store" → "written into the
  restored or promoted store"; `CONTEXT.md` **Restore** gains ", or a promotion `STO-54` classes as one", and `:186`
  "a restore loses an interval" → "a restore may lose an interval"; C11 adds "and any other promotion is a
  `RestoreTrace`".
- **F:** "Any other promotion — of a standby `STO-7` does not name, or after the primary committed without it — MUST
  NOT be performed; the store comes back by a restore from backup instead."
- Neutral statement: under CORE-1, such a promotion happens only where the deployment broke its MUST NOT. Under F,
  the way back is a backup, which loses more than the standby. Under R, the existing procedure handles it.

## Answer

- **CORE:** ACCEPT or CANNOT ACCEPT. **E1, E2, E3:** KEEP or DELETE each. **RF:** R or F, one line of reason.
  **F':** UNCHANGED or CHANGE, with one line of reason: does F' still hold, word for word, for the
  restore-from-backup path and beside S''?
- A CANNOT ACCEPT, DELETE or CHANGE names the normative content lost or made wrong (quote the MUST/SHOULD with
  file:line), or a trace that breaks it, and gives replacement text for that span only. Wording preferences are
  not counted.
- **Ripple:** the list C1-C12 is the manager's grep of every span the change contradicts. Name only the spans it
  misses, quoted with file:line.
- **Facts** (not votes), one or two lines each, with a quote:
  - FA1: on the extended query protocol drivers use, is `statement_timeout` still disabled before the commit's
    wait? If a mandatory `statement_timeout` can cancel the wait, say so: E3 then becomes load-bearing.
  - FA2: does a backend waiting in `SyncRep` notice its client closing the connection, including with
    `client_connection_check_interval` set?
  - FC1: with three nodes under `ANY 1 (s1, s2)`, can the standby holding every acknowledged commit still be
    identified after the primary is lost? What would CORE-2 need to add?
  - FC2: confirm or refute: with two nodes in strict mode, after a successful failover, writes still wait until a
    replacement standby streams.
- List wrong facts under "Brief errors", with the grep or quote that shows each one.

**Total: at most 400 words.**
