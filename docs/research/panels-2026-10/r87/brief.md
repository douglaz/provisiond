# r87 — triage-1030 Panel H: migration connection refusal (pv-3zzo)

Read this brief and `/var/tmp/provisiond-panel-r87/notes.md` whole. Your independent reader clone is pinned to **3109b5b44eae17e288cf52aaa976993bd8c5626c**, fetched origin/master. No source has been amended. This is a launch-only reading round on the exact alternatives below, not an implementation or adoption.

Read-only: do not change source, Git state, tracker or panel records; do not commit, push, checkout, reset, stash, clean, contact a PR or start subagents/background work. Temporary verification files may be written only under `/var/tmp/provisiond-panel-r87/tmp/` in a reader-specific subdirectory. Do not read credential/session/config locations (`~/.claude`, `~/.codex`, `~/.grok`, authentication files, kubeconfig, browser profiles), other readers' output/clones, other panel folders or main-worktree content. Use your own pinned clone and this packet as evidence. **Run no `lake build`, `lake exe`, Nix gate or other formal build:** the manager runs the required full gates independently and the host allows at most two concurrent Lake builds. This is a textual specification review, not a test of a running provisiond implementation. Return a substantive final answer within the 3600-second launcher limit; aim for <=1800 words plus any exact alternative. Do not wait on other readers.

**apply notes.md rule 6 exactly as written; this prompt adds no void rule.**

No rloop Run, source/tracker/main-worktree write, PR action, adoption or follow-on round is authorized this turn. Other panels and the triage-apply manager run alongside this one. Their folders, units and checkout are outside this task. Do not use another panel's findings as votes here.

## Owner authorization, verbatim

The owner, 2026-10-30, answered **“Approve (Recommended)”** to **“Approve the triage of the five new beads as listed in triage-1030/table.md (3 ready for implementation, 2 to their own panels H and I)?”** (the current instruction relays that answer; it postdates the pin). This approves running Panel H, not a specific migration refusal policy. The technical question comes from the pv-3zzo row in `/var/tmp/provisiond-manager/triage-1030/table.md`, not triage-1027.

The row asks: “When deployment admission denies a physical connection to the `migrate` entry point or a waiting migration runner, which entry-point outcome is required: nonzero exit for deployment retry, or an internal wait/retry, with what bound and observable failure report? Distinguish initial acquisition, waiting-runner acquisition and reconnect from a SQL lock wait after connection.” It calls for a single refusal owner at STO-55, a release boundary at STO-13 and independent conformance cases. It selects no policy. The complete original row is retained in `check/triage-row.txt`; the complete pinned bead is in `check/bead.json`.

## Plain-terms failure story

A release is waiting to update the database while the previous release keeps serving. The connection authority says there is no capacity for the update program to connect. Should that program return failure so deployment can invoke it again, or stay alive and keep asking for a stated time before failing? The same choice arises when a second update program has not yet obtained its own connection, and when a program needs a replacement connection. A program that already has a connection and waits for the other updater's lock is a separate case.

This is a missing outcome contract, not evidence that either existing engine has lost data. STO-55 expressly includes “migrators and waiting runners” in the admission population, but its outcome paragraph says “Startup acquisition refusal exits for supervisor retry; `api` returns `overloaded` before any transaction; worker/periodic acquisition refusal is an `OPS-49` store error”. STO-13 places the entry point “before any component of a release starts and while the previous release's engine and `api` keep running”. Those quotes do not explicitly equate `migrate` with component startup. OPS-49's quoted scope is “a worker, or by a periodic component running in the engine process”; do not extend it by analogy. The exact passages, including exceptions, follow.

## Verification against master

pv-3zzo is open/needs-triage in the pinned JSONL. Its STO-55 and STO-13 owner blocks and the quoted OPS-49 refusal/scope passages remain unchanged from filing baseline bf82bfe93715ca120a08e73fb0cca20e4f47fce8 (mechanical receipt in `check/freshness.json`). Later checklist edits have not added an explicit migration-refusal outcome. CNF-372 includes “migrators and waiting runners” in the distinct-grant check, but its outcome list still names “startup refusal and supervisor retry, `api` refusal before any transaction, and worker/periodic refusal through the store-error loop”. CNF-57's concurrent-runner case says “one waits on `STO-12`'s key”; that is not a failed physical admission attempt. These findings leave Q1 open; nothing is dropped.

The complete tagged Migration.lean module and STO-13 backfill declarations were inspected: their checked properties concern migration shape and backfill population, not refusal outcomes. No option below changes those clauses or a formal declaration. Do not add a conformance identifier to tools/formal/. If a proposed alternative needs a declaration/guard change, identify its exact property and treat that as substantive.

## Pinned owning context

Quoted spans are verbatim from the pin. Some carry historical rationale; read the current normative sentences and all exceptions. They are not new candidate language.

### `05-persistence.md:247–330` at the pin

```text
**STO-55** **ADDED 2026-09-12 (`F51`) — each pool is sized by construction, and a component holds
at most one transaction at a time.** The engine's pool holds one connection per worker plus one
per periodic component that runs in the engine process (`OVR-17`); each `api` replica's pool holds
one per admitted request plus one per periodic component on its rows; `OPS-47`'s lock connection
is outside both. Pool sizing reserves consumer checkouts within a running process; opening or
replacing a database connection also requires deployment admission. **The rule that makes the
arithmetic true:** a worker, sweep or watcher MUST NOT hold two transactions at once and MUST NOT hold a transaction
open across a provider, rail or rescue-host call — a sweep selects a bounded batch by key, commits,
and writes per row in its own transaction, and a cursor held on one connection while writing on
another would deadlock a pool sized this way on its first pass; the batch size is the
implementation's, not a deployment parameter. `LDG-69` says "A deployment MUST hold `LDG-35`'s
primitive for the duration of one database transaction and no longer", which is this rule for
the tenant primitive alone; it holds for every transaction. `STO-7`'s
`idle_in_transaction_session_timeout` — on `OVR-19` with the other store timeouts — is what bounds
a violation: set shorter than `RSC-35`'s rescue timeouts, the one network wait the set states, it
kills a transaction held across a long call, though a quick call inside a transaction breaks the
rule without tripping it, which is why the rule is stated and not only the timeout. **The
deployment MUST state the engine's worker count and each replica's read and write request
concurrency** (`OVR-19`); the pools are sized from them.

- **The pool is `api`'s concurrency bound, and a refusal happens before any transaction.** Nothing
  else bounds authenticated request concurrency — `API-29`'s per-tenant limit is a SHOULD and is
  about rate, and `WIR-49`'s held token requests cost no pool slot. A request that obtains no
  connection within a stated checkout bound (`OVR-19`) is refused `overloaded` (`DOM-17`, HTTP 503,
  `retryable: true`, `retry_after_ms`) before any transaction begins, so the refusal writes no
  `STO-35` receipt of its own, and `API-11` judges the key's re-send against whatever receipt an
  earlier send left — none, for a key never sent before. It is not `rate_limited`: `API-50` says an
  obedient caller "MUST never be throttled by the deployment's caller-throughput pacing", and a full pool is the replica's condition,
  not the caller's rate, so the decision is `503` rather than a non-rate `429`. Read and write
  checkouts are budgeted separately, on the same reasoning `API-50` applies to rate limits, so a
  poller cannot crowd out an extension.
- **The sum fits outside a stall, and the engine checks its share.** The deployment states that the engine pool,
  every replica's pool at the rollout's maximum overlap, the lock connection, the migrator and its
  waiting runners, and an operator reserve together fit inside `max_connections` less the server's
  reserved slots — a human row on `OVR-19`, since only the deployment sees the whole — and the
  engine reads `max_connections` at startup and refuses to run where its own pool plus the lock
  connection does not fit.

  Every physical connection attempt by component pools, reconnects, rollout incarnations,
  startup-lock holders, migrators and waiting runners MUST receive a distinct durable reservation
  before dialing from one serialized authority outside the protected store. This includes
  pre-authentication and delayed-handshake attempts. Ingress MUST prohibit bypass and redial under
  one reservation. Bind grants to component/attempt identity and database boot identity, and to
  backend PID and `backend_start` when known. Unknown bindings remain charged. Timeout, transport
  loss, process exit and rollout completion never release a grant.

  Unreleased grants MUST fit component capacity C. Bounded observer/operator/other-client
  allowances A include their residual and uncertain attempts. C+A MUST fit usable capacity after
  server reservations, with background/server resource pools budgeted separately. Keep separate
  read/write checkout budgets. The deployment MUST state C, the allowances A, the resource
  ceilings, and the authority and reconstruction procedures (`OVR-19`), and MUST actually bound A
  and budget the separate background/server resources. A declared allowance alone does not ensure
  a fresh observer can connect when that allowance or resources are consumed; PostgreSQL reserve
  roles alone are no proof of observer access. The enforcement construction is the deployment's.

  Release requires fencing every delayed arrival/retry and fresh privileged direct-primary
  evidence, read in a fresh transaction, that the bound backend ended. Leaving `SyncRep` is
  insufficient. Unidentified attempts remain charged until fenced server-incarnation termination
  proves absence. Observer failure denies growth and retains charges.

  Accounting loss closes ingress. Recovery requires fenced conservative reconstruction or
  stopped components and verified primary shutdown before a fresh account; either path fences all
  old grants and delayed attempts. Existing admitted sessions may continue. Exhaustion alarms,
  refuses growth and delays replacements.

  Startup acquisition refusal exits for supervisor retry; `api` returns `overloaded` before any
  transaction; worker/periodic acquisition refusal is an `OPS-49` store error (`OPS-49`: "An
  attempt denied by `STO-55` admission is a store error for this loop and sends no SQL").
  Stop-record refusals consume existing bounds and send no SQL. No individual `SyncRep` backend
  may be cancelled or terminated to make room; primary shutdown remains `STO-7`'s exception,
  "other than by shutting the primary down".

  The capacity argument is the mapping of every physical component attempt to a distinct
  unreleased grant: residual backends, unknown attempts and failed-unused attempts stay charged
  until the release evidence above proves absence. Together with the actually bounded A and the
  separate resource budgets, the C+A inequality covers occupancy outside live pools. The costs
  are reserves, durable admission infrastructure, indefinite replacement/startup delay and
  possible primary shutdown for unreconstructable accounting.
- **No pooler in transaction mode fronts the pools** (*amended 2026-10-23, `ADR-0045`; until then one "MAY front the pools only on two conditions"*): behind one, a crash of the primary ends its backends but not the component's connection to the pooler, so `STO-7`'s new-connection check would never run. The operator MUST maintain this exclusion while components use this path, including after routing changes. No additional runtime topology-drift check is required.

*Why no ADR: pool sizes and admission bounds are configuration, so the hard-to-reverse test fails,
and two independent readers said so; `LDG-65` is the set's precedent for recording a reversible
decision without one. What was found beside it — the engine's worker count and `LDG-37`'s cadence
on no register — is a defect of `OVR-19`'s own rule, and both rows are added.*
```

### `05-persistence.md:1529–1610` at the pin

```text
**STO-12** **AMENDED 2026-09-12 (`ADR-0024`) — the runner serializes itself.** Migrations MUST
be applied by a real migration runner that tracks applied versions. Splitting a schema file on
statement separators in application code is fragile — it breaks on the first trigger body, string
literal, or `BEGIN…END` block — and it provides no versioning. See `DEF-13`. The runner MUST hold
a **transaction-scoped advisory lock on a fixed key distinct from `STO-51`'s** — both keys are
constants the implementation chooses, not deployment parameters — across inspecting the
history, applying a migration and recording its completion, one migration per transaction, so the
recorded version never runs ahead of the DDL and two runners cannot interleave. *`STO-51`'s startup
lock is not this lock: it is held on a connection outside the pool, an advisory lock conflicts only
with requests for its own key, and a runner asking for that key would block the engine's own boot.*

**A statement PostgreSQL refuses inside a transaction block is its own migration, run outside one,
and it MUST be resumable.** *Added 2026-09-12: `STO-13` requires the index builds on the large
tables to be `CONCURRENTLY`, and `CREATE INDEX CONCURRENTLY` cannot run in a transaction block —
so the one-transaction rule above and that obligation contradicted each other for the exact
migrations that take longest, and both landed the same day under `ADR-0024`.* Such a migration
contains that one statement and nothing else; the runner holds a **session-scoped** advisory lock on
the same key across the build and the recording of completion, so runners still cannot interleave;
the statement is written so that a repeat after a crash is a no-op (`IF NOT EXISTS`); and before
running it the runner MUST drop any index of that name left `INVALID` by an earlier failed build,
since `IF NOT EXISTS` would otherwise skip the rebuild and record a version whose index does not
work. Completion is recorded only after the build succeeds, so the recorded version still never runs
ahead of the DDL — a crash between the two leaves a valid index and an unrecorded version, and the
repeat records it. Such a migration is never a contract step and never in the stop-everything class
(`STO-13`): an index is an addition.

**STO-13** **AMENDED 2026-09-12 (`ADR-0024`) — both halves, each where it is cheap, and the class
neither half makes safe.** Migrations MUST be forward-only and MUST be applied by the deployable's
own `migrate` entry point, run by the deployment **before any component of a release starts and
while the previous release's engine and `api` keep running** — never by `api`, and never by the
engine at boot, whose restart window `ADR-0016` priced at seconds and `OVR-18` alarms. Every
migration MUST be safe against a running instance of the previous release of both components:

- it MUST NOT drop, rename or narrow a column, table or type;
- it MUST NOT add a `NOT NULL` column a previous-release writer does not populate — such a column
  is nullable in the release that adds it and tightened after a backfill in a later one;
- it MUST NOT add a constraint a previous-release write can violate;
- it MUST NOT write a value of an enumerated column the previous release does not recognize —
  `STO-10` makes that "a hard error, not a silent default" on every old reader — so **the release
  that adds a value does not write it, and the release after may**;
- DDL that takes `ACCESS EXCLUSIVE` MUST run under a stated `lock_timeout` and retry count
  (`OVR-19`), and index builds on `operations`, `ledger_entries` and `machines` MUST be
  `CONCURRENTLY`, so that the time `api` queues behind a migration is bounded, except while that DDL's commit waits for a standby (`STO-7`) — the table lock
  still queues every later statement on that table behind it while held. A `CONCURRENTLY` build
  cannot run inside a transaction, so it is its own migration under `STO-12`'s non-transactional
  rule, not a statement inside a transactional one.

A removal, rename, tightening or `VALIDATE` is a **contract step** and ships no earlier than the
release after the one that stopped depending on the thing removed. Every component MUST read the
recorded schema version before it does anything else — `api` before its listener opens, the
engine before `STO-51`'s startup lock and so before `OPS-15`'s pass — and exit non-zero where it
is *older* than the version it requires, and MUST serve a *newer* one — a component refusing a
newer schema would refuse the normal state of every roll. **Rollback is the previous binary against the current schema**,
admissible up to and not past a contract step; past one there is no down-migration, and recovery
is `STO-54`'s restore. **A change to a predicate or derivation both components evaluate on shared
rows is made safe by none of the above** — `LDG-33`, `STO-3`'s guards, `OPS-42`/`LDG-62`'s fence
guard, `STO-47`'s conditional write, `SEC-39`'s counter key, `LDG-35`'s serialization key, and
every idempotency-key and `payment_ref` derivation — and such a release MUST stop every component
of the previous release before the first component of the new one starts, and MUST say so in its
migration. *The witness: an `api` at N−1 sizes an extension by the old `LDG-33` and writes a
future date; an engine at N re-derives by the new one, gets a past date, sets the fence and
`LDG-14` destroys the disk, with the row valid under both formulas and `OPS-23` unable to see it.*

*Until 2026-09-12 this read "MUST be safe to run concurrently with a running instance of the
previous version, or startup MUST take an exclusive lock", and nobody chose a half.*

**The `about_to_order_at` backfill is an exception to the concurrent-migration rule above**, which
runs a migration "while the previous release's engine and `api` keep running". Before enabling
`OPS-15`'s create exception or `API-63`'s dispatch test on the column, the migration MUST stop every
previous-release component, then fill `operations.about_to_order_at` with the migration instant
for every existing `running` create, preserving any value already set, and only then permit the
first new-release component to start. Those legacy running rows MUST NOT be read as
"null, so never dispatched". Backfilled values mean potentially dispatched, not a
measured dispatch time. A binary that claims without writing this column MUST NOT run against the
store after the backfill, and a previous-release component MUST NOT restart after it;
rollback past this release is inadmissible. This is a shared-predicate
contract step, and the migration MUST declare that order (`ADR-0024`: "Stop everything, migrate,
start everything. The degenerate case, and the right one for the shared-predicate class.").

*Amended 2026-10-17 (`pv-k4l`; panels r56 and r56b, `docs/research/panels-2026-10/r56/` and `docs/research/panels-2026-10/r56/r56b/`): specified the conservative one-time backfill and its stop-everything order; `ADR-0042`.*
*Amended 2026-10-23 (`pv-s4m`; panel r63, `docs/research/panels-2026-10/r63/`; owner decisions Q1 “I think we should just suppose synchronous replication”; S2′ “A: stop on time (Recommended)”; `ADR-0045`): excepted standby waits from the migration queue bound.*

```

### `05-persistence.md:166–209` at the pin

```text
write-ahead logging, which are the withdrawn engine's pragmas. On PostgreSQL the surface is
`statement_timeout`, `lock_timeout`, `idle_in_transaction_session_timeout`, the isolation level and
`search_path` — an entirely different configuration reached by the identical defect (`ADR-0015`).*

**Rules about the connection follow** (added 2026-09-12, `ADR-0022`). The client-side deadline
on any store call MUST NOT be shorter than the server-side timeouts above, so that the server
decides a statement's fate before the client gives up and a lost reply is only ever a dead
transport (`OPS-49`), or a commit returned with PostgreSQL's replication warning. A standby wait has no server-side timeout and is excluded from that call's
store-call and Store-retry deadlines. A dead transport during it is found by the connection's TCP
keepalives (`OVR-19`). `OPS-21`'s stop bounds still apply. And a connection abandoned mid-transaction before it sends COMMIT — by a timeout, a cancelled
worker or a lost reply — MUST be reset before it returns to the pool, or the next checkout inherits
an aborted transaction.

**A sent COMMIT is never abandoned** (*added 2026-10-23, `ADR-0045`*): short of its process exiting, a deadline or a cancellation of the request or worker that sent it MUST NOT release its connection before the reply arrives or the transport is found dead. Cancellation alone does not release that write checkout. Dead database transports and process exits can leave waiting backends outside the pool's accounting. A request that finds the write checkouts taken is refused at checkout (`STO-55`).

**Every commit waits for the standby** (*amended 2026-10-23, `ADR-0045`; until then "`synchronous_commit` is `local`
on every connection and `on` inside exactly two transactions"*): `synchronous_commit` is `on` on every connection and
`synchronous_standby_names` is `ANY 1` over the two standbys `OVR-19` names, so PostgreSQL acknowledges a commit
only once one of them has flushed it to durable storage. The deployment MUST NOT let the primary commit without one
of them: no connection lowers `synchronous_commit`, and the primary never serves with `synchronous_standby_names`
empty. `OVR-18` alarms either standby being unavailable, and while both are, every write waits.

The operator MUST keep this synchronous replication configuration in force while the primary serves component work. Provisiond relies on that duty; no additional runtime replication-configuration drift check is required. If `synchronous_standby_names` is emptied after a connection has passed its new-connection check, a later commit on that connection can be acknowledged locally without either named standby having flushed it. That is a deployment misconfiguration, and the earlier connection check does not detect the change.

**A component checks each new connection before using it** (*added 2026-10-23, `ADR-0045`*): it MUST NOT use a
  new store connection until one of the standbys `OVR-19` names has flushed the primary's WAL up to the flush
  position the primary reports on that connection, which it learns by reading the standbys' reported positions,
  never by committing a write. A check that errors, cannot see a standby's position, or has not passed is a failed
  connection attempt: the connection is closed unused, and nothing falls back to an unchecked one. Every
  connection after a restart of the primary is new, whether the restart was in place or after a crash, so it is
  checked: a commit that was waiting for a standby when the primary stopped is "marked fully committed once the
  primary database recovers", whether or not a standby has it.
Before exposing a deposit destination read from the store, repeat the read-only flush-position check with a
  target sampled after that read, on the same uninterrupted PostgreSQL session. On session failure discard the
  result and repeat the whole read.

No component sends PostgreSQL a cancel request on a store connection: a store call whose client-side deadline
expires closes its connection, except a sent COMMIT, which no deadline releases, and the transaction's fate is the server's (`OPS-49`).

The deployment MUST NOT cancel or terminate a primary backend while it waits for a standby (wait event `SyncRep`),
other than by shutting the primary down.

A commit that returns PostgreSQL's warning "The transaction has already committed locally, but might not have been
replicated to the standby." is not acknowledged: the component treats it as a lost reply (`OPS-49`).
```

### `03-operation-lifecycle.md:1925–1945` at the pin

```text
**OPS-49** **ADDED 2026-09-12 (`ADR-0022`) — a store error is a bounded whole-transaction retry,
then the engine exits.** Where a store call by a worker, or by a periodic component running in
the engine process (`OVR-17`), errors or times out, the component MUST repeat the **whole
transaction** — never the last failed statement, and never the provider call (`OPS-12`) — with
the provider's outcome retained in memory, for a stated bound (`OVR-19`), and on exhausting the
bound MUST log loudly and the engine MUST exit non-zero into its supervisor, where `OVR-18`'s
alarm is watching. A refused generation check (`OPS-50`) is not a store error and is never
repeated. `OPS-50` says "A mismatch is not a store error (`OPS-49`) and is never repeated."
The bound covers connection, execution, commit, read-back and backoff together, but
not a commit's wait for the standby (`STO-7`), and it is a money parameter: on exhaustion the
outcome in hand is thrown away and `OPS-15` classifies the row as interrupted — unless the
bound's last repeat committed and its reply was lost, in which case the row is already written,
the money already posted once, and the startup pass finds nothing `running` to classify (*the
formal layer's claim model exhibits this trace, 2026-09-14*). A periodic component whose
repeated write affects no row under a write-once guard — `STO-3`'s resolution write, `STO-52`'s
episode index — has seen its earlier attempt land, and moves on. **`api`'s components do not run
this loop**: a failed request transaction is the caller's `internal` error, and a failed credit
is `STO-31`'s next replay.

An attempt denied by `STO-55` admission is a store error for this loop and sends no SQL
(`STO-55`: "worker/periodic acquisition refusal is an `OPS-49` store error").
```

### `10-conformance-checklist.md:365–390` at the pin

```text
- [ ] **CNF-57** — Migrations are version-tracked and re-running them is a no-op. **Then the
      release drill** (added 2026-09-12, `ADR-0024`): with release N−1's engine and `api` running,
      retain adequate admitted reservations and live independent read sessions for the
      successful-service assertions (`STO-55`);
      apply release N's migrations through the `migrate` entry point and assert no `api` write is
      refused and no engine write exits; start two runners at once and assert one waits on
      `STO-12`'s key while the engine's startup lock is untouched; start N−1 binaries against the N
      schema and assert they serve, then start a binary against a schema older than the version it
      requires and assert it exits non-zero before its listener opens or, for the engine, before
      the startup lock; and, for a release not declared stop-everything, run an N−1 `api`
      extension against an N engine cancellation and a settlement replay across the pair.
      **Then the concurrent index step** (added 2026-09-12): kill the runner mid-build of a
      `CONCURRENTLY` index on `operations` and assert the version is unrecorded and the index is
      `INVALID`; re-run and assert the invalid index is dropped, rebuilt valid, and the version
      recorded once — and assert the runner refuses a migration that places that statement inside
      a transaction with any other.
      **Then the about-to-order contract step:** leave legacy creates `running`, including one
      whose order reached the provider on a `correlator: none` channel. Stop all previous-release
      components before the backfill; assert no new component starts until it completes. Read
      each stored row: null becomes the migration instant, a set value stays unchanged, and every
      running create is covered. Restart on the migrated store and assert `needs_reconciliation`,
      never `failed` with a released commitment. Re-run the migration and assert no value changes;
      assert the backfill migration declares its stop-everything order and records that rollback
      past this release is inadmissible. (`STO-12`, `STO-13`)
      *Amended 2026-10-17 (`pv-k4l`; panels r56 and r56b, `docs/research/panels-2026-10/r56/` and `docs/research/panels-2026-10/r56/r56b/`): added the conservative backfill drill with declaration checks; retained the concurrent-migration release drill; `ADR-0042`.*
      *Amended 2026-10-28 (`pv-oehp`; `ADR-0045`; `STO-55`).*
```

### `10-conformance-checklist.md:1147–1182` at the pin

```text
- [ ] **CNF-372** — **Residual backends remain covered by durable admission.** Precheck the
      engine and multiple `api` pools; freeze standbys, send disjoint writes and identify waiting
      PIDs. Stop the engine through its recording bound, lose `api` database transports, and
      overlap a rollout. Preserve one admitted read session if asserting read success. Verify
      old PIDs survive outside live pools.

      Keep replacement checks enabled; hold check replies/disconnect detection so replacement
      backends remain while attempts fail unused. Accumulate verified residuals and unreleased
      grants to exhaustion; assert no extra dial, alarm, bounded refusal and reserved observer
      access. Verify a distinct durable grant before each physical component dial, including
      pre-authentication and delayed-handshake attempts, across the consumers in `STO-55`:
      "component pools, reconnects, rollout incarnations, startup-lock holders, migrators and
      waiting runners". Check component/attempt and database boot bindings, then PID and
      `backend_start` when known; retain unknown and failed-unused charges. Verify the deployed
      C+A and separate resource budgets against `STO-55`.

      Exercise delayed handshakes, PID reuse and competing issuers: assert no bypass or redial
      under one reservation, no duplicate issuance from the serialized authority, and no release
      on timeout, transport loss, process exit or rollout completion. Exercise observer failure:
      assert denied growth and retained charges. Exercise lost accounting: assert closed
      ingress, retained charges and continued use permitted for existing admitted sessions;
      recover by fenced conservative reconstruction, and separately by stopped components and
      verified primary shutdown before a fresh account, fencing all old grants and delayed
      attempts on either path. For unidentified attempts, require fenced server-incarnation
      termination before release.

      Exercise startup refusal and supervisor retry, `api` refusal before any transaction, and
      worker/periodic refusal through the store-error loop; assert no SQL on denied attempts,
      bounded stop-record refusal and replacement delay until verified capacity release.
      Restore progress, fence attempts and prove backend termination with fresh privileged
      direct-primary evidence read in a fresh transaction before release and restart. Never
      release merely because `wait_event` changed. Assert no individual waiting `SyncRep`
      backend is cancelled or terminated to make room. Reserved observer access must be
      demonstrated under the deployed allowances and resource budgets (`STO-55`).
      (`STO-55`, `STO-7`, `OPS-47`, `OPS-49`, `OPS-21`, `OVR-18`, `OVR-19`)
      *Added 2026-10-28 (`pv-oehp`; `ADR-0045`; owner decision 2, `docs/research/panels-2026-10/r74/owner-decisions.md`, “B4* as reviewed (Recommended)”).*
```

### `00-overview.md:338–352` at the pin

```text
**OVR-18** The engine's liveness MUST be alarmed. While the engine is down no exposure-reducing
mechanism runs (`LDG-14`, `OPS-32`, `SEC-45`'s fan-out), and the restart window is the accepted
outage (`ADR-0016`); the supervisor's restart guarantee and the alarm threshold are deployment
parameters (`OVR-19`). **Two more conditions are alarmed on the same model** (added 2026-09-12,
`ADR-0023`): the recovery point exceeding its threshold, and either named standby being
unavailable (`STO-7`). **Two exits are alarmed on the same model** (added 2026-10-24,
`ADR-0047`): an engine's superseded exit (`OPS-50`), and its startup exit on the generation
advance's timeout (`OPS-15`). `OPS-50` says "the engine MUST log loudly that it was superseded and exit non-zero at once"; `OPS-15` says "On that timeout or any store error, including a lost reply on its commit, the engine MUST log loudly and exit non-zero having claimed nothing". *Amended 2026-10-23 (`pv-s4m`; panel r63,
`docs/research/panels-2026-10/r63/`; owner decisions Q1 “I think we should just suppose
synchronous replication”; S1 “Three servers (Recommended)”; `ADR-0045`): alarmed either named
standby being unavailable.*

Admission exhaustion and accounting loss MUST be alarmed (`STO-55`).
*Amended 2026-10-28 (`pv-oehp`; `ADR-0045`; `STO-55`).*

```

### `00-overview.md:363–367` at the pin

```text
**OVR-19** **A parameter is on this register or it is not a parameter.** Every value the set
says a deployment MUST state is listed here, with the requirement that mandates it. Startup MUST
validate every startup-validated row and refuse to run on a missing or out-of-range value; the rows
marked human are procedures the deployment records rather than values the process reads.

```

### `00-overview.md:416–437` at the pin

```text
| Startup-lock connection keepalives | `OPS-47` | durations | yes |
| Store-retry bound | `OPS-49` | duration | yes |
| Stop-record bound | `OPS-21` | finite, positive duration; `OPS-21` says "The Stop-record bound is measured from the stop, counts every repeat including serialization failures, and never resets." and "The deployment's supervisor MUST wait at least the Stop-record bound after a stop before it kills the engine." | yes |
| Recovery point | `STO-54` | greatest age of a committed write not yet in a separate failure domain | no — outside the process |
| Recovery-point alarm threshold | `STO-54` | duration | yes |
| Restore source/event clock-error evidence | `STO-54` | human — certificates and provenance for any asserted clock-error bounds; no unvalidated finite error assumed | no |
| Restore endpoint capture, validation and retention procedure | `STO-54` | human — possible-loss reporting procedure | no |
| Synchronous standby names | `STO-7`, `STO-54` | two identifiers | yes |
| Pooled-connection keepalives | `STO-7` | durations | yes |
| Derivation-index gap on restore | `STO-54` | integer | yes |
| Migration `lock_timeout` and retry count | `STO-13` | duration, integer | no — the migrator's, read at `migrate` |
| Store timeouts: `statement_timeout`, `lock_timeout`, `idle_in_transaction_session_timeout` | `STO-7`, `STO-55` | durations | yes |
| Engine worker count | `STO-55` | integer | yes |
| `api` request concurrency per replica, read and write | `STO-55` | integers | yes |
| Pool checkout bound | `STO-55` | duration | yes |
| Connection budget against `max_connections` | `STO-55` | human — the sum across every process at maximum rollout overlap | no; the engine checks its own share |
| Component admission capacity C | `STO-55` | integer; capacity contract at `STO-55` | no — deployment authority |
| Observer/operator/other-client allowances A | `STO-55` | bounded occupancy allowances; deployment obligations at `STO-55` | no — deployment |
| Admission resource ceilings | `STO-55` | human — server reservations and separate background/server resource budgets; `STO-55` | no — deployment |
| Admission authority and reconstruction procedures | `STO-55` | human; `STO-55` | no — deployment |
| Metering cadence | `LDG-37` | duration | yes |
| Engine liveness alarm threshold | `OVR-18` | duration | no — outside the process |
```

## Complete exact candidate forms

These are candidate amendments, not claims about the pinned requirements. Each option is a complete package. A reader may propose a different complete package, but its words are a separate form. No combined repairs count as acceptance of one of these forms. The triage row selected a comparison, not a preferred policy. A is a concrete exit form; B is the bounded internal-retry comparator; C is the narrower explicit-startup form; D is the no-change comparator.

For A and B, insert the printed STO-55 paragraph after the refusal block ending `"other than by shutting the primary down".` at `05-persistence.md:317`, before the capacity argument. For C, replace only the entire current refusal block at `05-persistence.md:312–317` with its printed replacement. For every added STO-13 paragraph/pointer, insert after the initial migration-safety bullet list and before `A removal, rename, tightening or VALIDATE` at the pin (`05-persistence.md:1576` boundary; use the actual text anchor). For the CNF-57 additions, insert just before `Then the concurrent index step`, retaining the existing text before and after it. Indentation follows CNF-57's existing continuation. Do not add a new identifier or ADR to enact these packages. Any later record follows the rule edit and cites the owner.

### A — Exit on refusal, diagnostic and deployment retry

**STO-55 insertion**, exact text:

```text
**Migration admission refusal.** If `STO-55` admission refuses a physical connection attempt
by the `migrate` entry point, including initial acquisition, acquisition by a runner scheduled
alongside another runner, or reconnect, `migrate` MUST report the refusal and exit non-zero
at once; it MUST NOT wait or retry admission internally. A later invocation is a deployment
retry; see `STO-12` for version inspection, serialization and resumability. The denied attempt
MUST send no dial and no SQL. It MUST NOT record a migration as completed because of that
refusal, and the refusal does not undo previously recorded completed migrations.
The diagnostic MUST identify `migrate`, the release being attempted, whether this was initial
acquisition or reconnect, whether another migration runner is active or scheduled, and the
admission-refusal reason, without credentials.
This rule governs refusal before a physical connection is admitted, not a SQL advisory-lock
or DDL lock wait after connection. It introduces no deadline for a sent COMMIT or standby
wait; see `STO-7`. The grant-retention and release rules above still apply on process exit or
transport loss; neither is evidence that an old backend ended. Refusal does not require
stopping the previous release or terminating any individual backend to make room.
```

**STO-13 release-boundary insertion**, exact text:

```text
For physical connection-admission refusal by the `migrate` entry point and deployment retry,
see `STO-55`. The deployment MUST NOT start any component of the new release until the
required migrations have completed successfully. The stop-everything and backfill exceptions
below retain their existing order.
```

**CNF-57 independent cases**, exact text:

```text
**Migration physical-admission refusal.** Run independent fixtures for (a) the first
`migrate` connection; (b) a second runner scheduled while an admitted runner holds `STO-12`'s
migration key, with the second runner denied its own physical connection before it can
request that key; and (c) a runner that has recorded one completed migration, then loses its
transport and is denied admission for a replacement connection before its next migration.
Use a release allowed to migrate with the previous release running. Retain adequate admitted
read/write sessions for the previous-release service assertions independently of the denied
migration attempt. Exhaust component admission capacity C (`STO-55`) with charged reservations,
without cancelling or terminating an individual `SyncRep` backend. In each fixture identify
the denied physical attempt and assert it makes no dial and sends no SQL; no new-release
component starts before the required migrations complete successfully, and that refusal
records no migration completion. Previously recorded
completed versions remain unchanged. The previous release's engine and `api` keep serving
through their admitted sessions; assert an engine write and an `api` write succeed with the
required standby available. Retain all uncertain/residual charges through refusal and any
runner exit. Release capacity only with `STO-55`'s existing fencing and backend-absence evidence.
Assert the refused runner emits the `STO-55` migration diagnostic and exits non-zero at
once, without an internal admission wait/retry. A separately invoked deployment retry after
verified capacity release uses a fresh reservation and resumes through `STO-12`'s version
history. No completed migration is applied again and the release starts only after the
required migrations complete successfully. Separately, give both runners confirmed admitted
connections and contend on the migration key: assert the second waits on the key under
`STO-12` rather than taking the admission-refusal exit. Keep the existing concurrent-index
and stop-everything cases. (`STO-55`, `STO-12`, `STO-13`, `STO-7`)
```

No new parameter. This package defines the entry point result once an admission refusal has been received; it does not add a deadline for the authority to respond. Deployment invocation cadence remains outside the amendment. It adds a diagnostic and an explicit STO-13 release-boundary MUST beyond C; C tests that start order without adding that sentence.

### B — Bounded internal retry, then diagnostic exit

**STO-55 insertion**, exact text:

```text
**Migration admission refusal.** For `migrate`, this rule applies instead of the startup
acquisition-refusal outcome above. For initial physical connection acquisition by `migrate`,
acquisition by a runner scheduled alongside another runner, and reconnect, the deployment MUST
state a finite, positive Migration admission-retry bound. `migrate` MUST validate it before
attempting admission and refuse to run with a missing or out-of-range value. On the first
admission refusal in an acquisition episode, `migrate` MUST report that it is waiting and the
refusal reason, then retry admission with backoff within that bound. The episode starts at
the first refusal and ends only on obtaining a confirmed usable reservation or exiting;
elapsed time includes further admission calls and backoff, and a refusal never resets it.
Every dial still requires its own distinct reservation. Every denied attempt sends no dial
and no SQL. If no confirmed reservation is obtained before the bound expires, `migrate` MUST
report exhaustion and exit non-zero. A later invocation is a deployment retry; see `STO-12`
for version inspection, serialization and resumability. A refusal MUST NOT be recorded as a
completed migration and does not undo previously recorded completed migrations.
The diagnostic MUST identify `migrate`, the release being attempted, whether this was initial
acquisition or reconnect, whether another migration runner is active or scheduled, and the
admission-refusal reason, without credentials.
This bound covers admission refusal only, not transport or connection checks after a grant,
SQL advisory-lock or DDL lock waits, migration execution or a commit's standby wait. Those
retain their existing rules; see `STO-7`, `STO-12` and `STO-13`. It MUST NOT cancel a sent
COMMIT or release a grant. The grant-retention and release rules above still apply on process
exit or transport loss; neither is evidence that an old backend ended. Refusal does not
require stopping the previous release or terminating any individual backend to make room.
```

**STO-13 release-boundary insertion**, exact text:

```text
For physical connection-admission refusal by the `migrate` entry point and deployment retry,
see `STO-55`. The deployment MUST NOT start any component of the new release until the
required migrations have completed successfully. The stop-everything and backfill exceptions
below retain their existing order.
```

**OVR-19 added row, immediately after the migration lock_timeout row**, exact text:

```text
| Migration admission-retry bound | `STO-55` | finite, positive duration | no — validated by `migrate` before admission |
```

**CNF-57 independent cases**, exact text:

```text
**Migration physical-admission refusal.** Run independent fixtures for (a) the first
`migrate` connection; (b) a second runner scheduled while an admitted runner holds `STO-12`'s
migration key, with the second runner denied its own physical connection before it can
request that key; and (c) a runner that has recorded one completed migration, then loses its
transport and is denied admission for a replacement connection before its next migration.
Use a release allowed to migrate with the previous release running. Retain adequate admitted
read/write sessions for the previous-release service assertions independently of the denied
migration attempt. Exhaust component admission capacity C (`STO-55`) with charged reservations,
without cancelling or terminating an individual `SyncRep` backend. In each fixture identify
the denied physical attempt and assert it makes no dial and sends no SQL; no new-release
component starts before the required migrations complete successfully, and that refusal
records no migration completion. Previously recorded
completed versions remain unchanged. The previous release's engine and `api` keep serving
through their admitted sessions; assert an engine write and an `api` write succeed with the
required standby available. Retain all uncertain/residual charges through refusal and any
runner exit. Release capacity only with `STO-55`'s existing fencing and backend-absence evidence.
For each fixture, keep admission denied across multiple calls/backoffs through the stated
Migration admission-retry bound. Assert both the initial waiting and exhaustion diagnostics
carry every `STO-55` migration-diagnostic field, no dial/SQL for denied attempts, a single
unreset elapsed bound, and non-zero exit by exhaustion. Then repeat each fixture with
verified capacity release before expiry: assert a fresh distinct reservation before the dial,
continuation without first exiting, and no completed version applied again. The new release
starts only after required migrations complete successfully. Reject missing, zero, negative
and non-finite bound settings before admission. A separately invoked deployment retry after
exhaustion obeys the same rules. Separately, give both runners confirmed admitted connections
and contend on the migration key: assert the second waits on the key under `STO-12`; the
admission-refusal timer does not run merely because it waits there. No standby wait is cut
off by this bound. Keep the existing concurrent-index and stop-everything cases.
(`STO-55`, `STO-12`, `STO-13`, `STO-7`, `OVR-19`)
```

This package adds a deployment parameter and internal wait cost. It bounds a refusal episode, not total migration runtime, SQL lock waiting or a sent COMMIT. It does not promise eventual capacity, nor bound a successful authority reply that never returns before any refusal. No particular duration or backoff cadence is selected here. Evaluate whether that is a complete enough executable contract or needs a separately reviewed form.

### C — Narrow explicit startup-refusal scope, no new reporting/bound

**STO-55 replacement**, exact text:

```text
Startup acquisition refusal exits for supervisor retry; `api` returns `overloaded` before any
transaction; worker/periodic acquisition refusal is an `OPS-49` store error (`OPS-49`: "An
attempt denied by `STO-55` admission is a store error for this loop and sends no SQL").
For `migrate`, the startup acquisition-refusal outcome applies on initial physical connection
acquisition, acquisition by a runner scheduled alongside another runner, and reconnect:
exit non-zero for deployment retry.
Stop-record refusals consume existing bounds and send no SQL. No individual `SyncRep` backend
may be cancelled or terminated to make room; primary shutdown remains `STO-7`'s exception,
"other than by shutting the primary down".
```

**STO-13 pointer insertion**, exact text:

```text
For physical connection-admission refusal by `migrate`, see `STO-55`.
```

**CNF-57 independent cases**, exact text:

```text
**Migration physical-admission refusal.** Run independent fixtures for (a) the first
`migrate` connection; (b) a second runner scheduled while an admitted runner holds `STO-12`'s
migration key, with the second runner denied its own physical connection before it can
request that key; and (c) a runner that has recorded one completed migration, then loses its
transport and is denied admission for a replacement connection before its next migration.
Use a release allowed to migrate with the previous release running. Retain adequate admitted
read/write sessions for the previous-release service assertions independently of the denied
migration attempt. Exhaust component admission capacity C (`STO-55`) with charged reservations,
without cancelling or terminating an individual `SyncRep` backend. In each fixture identify
the denied physical attempt and assert it makes no dial and sends no SQL; no new-release
component starts before the required migrations complete successfully, and that refusal
records no migration completion. Previously recorded
completed versions remain unchanged. The previous release's engine and `api` keep serving
through their admitted sessions; assert an engine write and an `api` write succeed with the
required standby available. Retain all uncertain/residual charges through refusal and any
runner exit. Release capacity only with `STO-55`'s existing fencing and backend-absence evidence.
Assert each refused runner exits non-zero for deployment retry and no denied attempt dials
or sends SQL. After verified capacity release, invoke `migrate` again with a fresh reservation
and assert normal version inspection and completion under `STO-12`, before the new release's
components start. Separately, admit both runners and assert the second waits on `STO-12`'s
key rather than treating that lock wait as physical connection-admission refusal. Keep the
existing concurrent-index and stop-everything cases. (`STO-55`, `STO-12`, `STO-13`)
```

This is a smaller explicit scope amendment plus conformance. It supplies no new diagnostic format, report, retry duration or OVR-19 row. Its migration-only exit preserves the existing non-migration startup clause; say whether that sufficiently specifies prompt exit or leaves an internal wait loophole. Existing exhaustion/accounting alarms remain.

### D — No amendment

Exact patch: zero changes to STO-55, STO-13, OVR-19, OPS-49, CNF-57, CNF-372, formal declarations or ADRs. Keep the pinned texts above byte-for-byte. No migration-specific reporting or internal-retry bound is added. A vote for D must say whether current “Startup acquisition refusal exits for supervisor retry” already governs initial/waiting-runner/reconnect migration admission refusal, with a quoted basis, or whether leaving that outcome unspecified is an intentional scope decision. The latter leaves the bead’s gap open rather than closing it as fixed.

## Question — answer Q1 as one exact package

For pv-3zzo, which complete migration-refusal package can be accepted and which should be preferred: A (exit with diagnostic), B (bounded internal retry), C (explicit startup-refusal scope only), D (no change), or a fully printed distinct alternative? Identify any new delay/resource-cost preference still requiring the owner; approval of this panel did not adopt it. The rule owner is STO-55, the release boundary/pointer is STO-13, a B parameter is on OVR-19, and independent cases land in CNF-57. Do not export the worker-only OPS-49 loop or introduce another normative copy in an ADR/CNF explanation.

Return these items:

1. A plain-terms answer and **Final: Q1 A/B/C/D/exact alternative**. Separately list **A ACCEPT/CANNOT ACCEPT; B ACCEPT/CANNOT ACCEPT; C ACCEPT/CANNOT ACCEPT; D ACCEPT/CANNOT ACCEPT** for each exact package. Conditional acceptance is not acceptance of the printed form; print the whole changed package as an alternative. Keep preference separate from acceptability.
2. Trace initial acquisition, the second runner denied before connection, reconnect after a recorded completed migration, the already-connected SQL lock wait, and capacity exhaustion while the previous release serves on adequate admitted sessions. Explain whether each printed fixture actually detects the policy it names. Do not assume a denial allocates a grant or that process exit releases one.
3. Check the deletion/weakening question explicitly: what protection did each changed sentence supply, and does any option change a checked verdict, make a conformance assertion/theorem unreachable or vacuous, or lose a quoted normative obligation? Name the owner, exact quote and trace. The accepted connection accounting, startup-lock independence, standby-wait and stop-everything exceptions stay in scope as constraints. Do not call a merely absent new test a contradiction in the unchanged base.
4. The strongest no-change argument, labelled as a requested counterargument rather than your vote. Identify any premise of this brief that is wrong, including an existing rule that already settles the issue or a candidate that contradicts its own test.
5. Any owner question in plain terms with the exact reviewed amendment ids; do not recommend an unread combination of reader fixes.

Do not tally other readers, enact a policy, edit a file, run gates, or start another round. Read every candidate and quoted context before answering.
