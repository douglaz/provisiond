# r87b — Panel H Q1 migration refusal: ONE consensus round

Read this brief and /var/tmp/provisiond-panel-r87/r87b/notes.md whole. Your own detached reader
clone is pinned to 3109b5b44eae17e288cf52aaa976993bd8c5626c. Do not read the main checkout,
another reader clone, another panel folder, or credential/session/config locations (~/.claude,
~/.codex, ~/.grok, authentication files, kubeconfig or browser profiles). Do not change source,
Git state, tracker or panel records, commit, push, checkout, reset, stash, clean, contact PRs,
start subagents/background work or launch any follow-on work. Temporary verification files belong
only in /var/tmp/provisiond-panel-r87/r87b/tmp/<your-seat>/.
Run no lake build, lake exe, Nix gate or formal build; the manager owns the capped gates.
Return a substantive answer within 3600 seconds, aiming for <=1800 words plus any complete alternative.

**apply notes.md rule 6 exactly as written; this prompt adds no void rule.**

## What is and is not settled

The owner approved running Panel H, not a migration-refusal policy. The exact authorization
was “Approve (Recommended)” to “Approve the triage of the five new beads as listed in
triage-1030/table.md (3 ready for implementation, 2 to their own panels H and I)?”
The owner also says “If there are ties, try to run the panel once more focusing on reaching consensus”.
This is that one round, on Q1 alone. Any settled behavior/requirement/check-strength choice,
including no change, goes to the owner for approval. Nothing is enacted by this reading.

In r87, Fable preferred its exact A′ (F here), Opus preferred C, Astra and Sol preferred A.
Acceptability: A = Astra/Sol; B = Sol; C = Fable/Opus; D = nobody. Each author accepted its own
different A′; no other reader saw those exact alternatives as a candidate before answering.
No form reached three. Do not combine preferences or merge F/O into one tally.

## Plain-terms example

The old release is serving while a database updater needs a connection. Capacity is full and
the connection authority refuses it. Should the updater report failure and stop so deployment
can invoke it again, keep asking for a bounded time, or merely receive an explicit exit rule
without a required report or explicit no-wait clause? The same choice arises before a second
runner connects and after a completed migration when a replacement connection is refused.
An updater already connected and waiting for the migration lock is a separate case.

## Exact disagreements to resolve

1. A’s diagnostic asks whether another runner is “active or scheduled”. Fable/Opus object that
   the current contract supplies no such knowledge before connection, and retained grants do
   not prove liveness. Astra calls supplying context additional implementation work, not an
   inherent contradiction; Sol accepts A. Distinguish a missing defined information source
   from proof that no deployment could supply one. The pin says “The enforcement construction
   is the deployment’s” and binds grants to “component/attempt identity”; neither defines an
   active/scheduled diagnostic source. Consider the fully printed F and O independently.
2. C says “exit non-zero for deployment retry” but has no “at once”, no prohibition on internal
   waiting and no numerical bound. Opus treats deployment as the retrier; Fable accepts the
   smaller rule while acknowledging delay may pass. Astra/Sol reject it as an incomplete timing
   answer. Is that an intentional acceptable contract, or must the exact rule and check exclude
   a finite arbitrary pre-exit wait? Do not silently add A’s timing to C.
3. Astra’s B trace: a 10-second episode, capacity release at 9.9 seconds while the runner is in
   backoff or awaiting an authority response, no confirmed reservation at 10 seconds. The rule
   requires exit but the success fixture asks continuation after capacity release before expiry.
   The packet promises no backoff cadence or authority-response guarantee. Evaluate that exact
   printed fixture; do not count an unprinted “confirmed acquisition before expiry” repair as B.
   Fable/Opus also question “confirmed usable reservation” versus post-grant connection checks.
   Sol accepted B as executable. These are candidate defects under examination, not a claim that
   the alternatives already pass. Any proposed repair is a distinct complete form.
4. F and O both drop the peer-runner-status field, keep A’s immediate exit/report/boundary and
   complete fixtures, and add no parameter. F additionally says the reason is “as the authority
   returned it”; O does not. Review both whole and state whether either is acceptable exactly.
5. D’s strongest requested counterargument is that startup refusal plus existing grants,
   schema checks, alarms and resumability already provide safety, or the outcome can remain an
   intentional scope choice. None of the four readers voted D. No new test’s absence contradicts
   the unchanged base. An initial startup reading alone must also address reconnect.

No verified error changed the missing-outcome premise, so r87 is not void. Candidate errors
and a disagreement about strength are reported rather than expanded into a new void rule.
The original brief asks whether B is complete enough; Astra identifies the fixture conflict
above. A/B’s diagnostic requirement is disputed as above. The quotes themselves match the pin.

## Response required

For EACH exact form A, B, C, D, F and O, answer ACCEPT / ACCEPT WITH THIS FIX / CANNOT ACCEPT.
Conditional acceptance does not count for the printed form. Give one explicit “Final: Q1 <label>”
preference, preferably a whole printed form others can accept; preserve acceptability separately.
If no printed form works, print your complete distinct alternative, including every landing
block, not a list of edits. Do not choose an unread combination by reference.

Trace first acquisition, second runner denied before connection, reconnect after a recorded
version, already-connected SQL lock waiting, and exhaustion while adequate admitted previous-
release sessions serve. Address diagnostics, elapsed bound and what each fixture actually detects.
For any blocking loss quote its MUST/SHOULD with owner and a full trace, or identify the checked
conformance/theorem verdict changed, unreachable or vacuous, and collateral flips. A missing new
test is not a contradiction in unchanged D. Never weaken a rule to clear a review; identify what
it protects first. Check the three wording-exception dimensions independently: behavior,
normative requirement and check strength. Report any premise-changing error under rule 6 exactly.
Label the strongest no-change argument as requested counterargument, not your vote.
End with a short plain-terms owner-approval question for any settled preference and the exact
amendment identifiers. Do not claim C/F/O or D is auto-authorized by the panel-launch approval.

## Pinned owning context, verbatim


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


### OPS-47, 03-operation-lifecycle.md:135–143, verbatim

```text
**OPS-47** **AMENDED 2026-09-08 (`ADR-0019`) — the supervisor is the guarantee, and the engine
checks at boot that it is alone.** The engine MUST run as exactly one process under an external
supervisor that retries startup subject to `STO-55` admission and never runs two (`STO-55`:
"Startup acquisition refusal exits for supervisor retry"). **That is a deployment obligation** (`OVR-19`).
Where two engines run, no write of the first commits once the second's startup pass has
committed a new `STO-59` generation (`OPS-50`); provider calls the first already licensed still
go out. `OPS-50` says "Where the values differ, the transaction MUST roll back". A supervisor guarantees it never *starts* two; it cannot guarantee the first is dead, so
a node cut off from its supervisor while it still reaches the provider is out of scope and is
the operator's to notice (`OVR-18`).
```

## Complete exact alternatives

All landing sites are the r87 sites: STO-55’s refusal block before its capacity-argument paragraph;
STO-13 after the migration-safety bullets and before “A removal, rename, tightening or VALIDATE”;
CNF-57 immediately before “Then the concurrent index step”; B’s register row follows migration
lock_timeout in OVR-19. Preserve existing list indentation (two spaces at STO-55, six at CNF-57).
No new identifier, ADR or formal declaration is proposed. A/B/C/D and F/O below are frozen whole,
not silently repaired; prose describing a candidate is part of its reviewed context.

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


### F — Fable’s exact alternative A′


Identical to A except the diagnostic sentence in the STO-55 insertion. Landing sites and indentation as the brief specifies for A.

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
acquisition or reconnect, and the admission-refusal reason as the authority returned it,
without credentials.
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

No new parameter, identifier or ADR. The only difference from A is the diagnostic field, so A′ and A are distinct forms for the tally.

### O — Opus’s exact alternative A′


A′ is A with one clause deleted from the diagnostic sentence. Placement is identical to A.

**STO-55 insertion:**

```text
**Migration admission refusal.** If `STO-55` admission refuses a physical connection attempt
by the `migrate` entry point, including initial acquisition, acquisition by a runner scheduled
alongside another runner, or reconnect, `migrate` MUST report the refusal and exit non-zero
at once; it MUST NOT wait or retry admission internally. A later invocation is a deployment
retry; see `STO-12` for version inspection, serialization and resumability. The denied attempt
MUST send no dial and no SQL. It MUST NOT record a migration as completed because of that
refusal, and the refusal does not undo previously recorded completed migrations.
The diagnostic MUST identify `migrate`, the release being attempted, whether this was initial
acquisition or reconnect, and the admission-refusal reason, without credentials.
This rule governs refusal before a physical connection is admitted, not a SQL advisory-lock
or DDL lock wait after connection. It introduces no deadline for a sent COMMIT or standby
wait; see `STO-7`. The grant-retention and release rules above still apply on process exit or
transport loss; neither is evidence that an old backend ended. Refusal does not require
stopping the previous release or terminating any individual backend to make room.
```

**STO-13 insertion:**

```text
For physical connection-admission refusal by the `migrate` entry point and deployment retry,
see `STO-55`. The deployment MUST NOT start any component of the new release until the
required migrations have completed successfully. The stop-everything and backfill exceptions
below retain their existing order.
```

**CNF-57 cases:**

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

A′ adds no OVR-19 row, identifier, ADR or formal change.

## Prior answers, verbatim

### BEGIN r87 fable.md (verbatim)

**Plain-terms answer.** The gap is real, and closing it costs nothing the set has not already paid for the engine. The only place the pinned set interprets "Startup acquisition refusal exits for supervisor retry" is OPS-47 at `03-operation-lifecycle.md:136`, which quotes it for the engine running "under an external supervisor that retries startup subject to `STO-55` admission". The migrator has no supervisor. STO-13 has the deployment run it as a step before any component starts, and OVR-17's closed component list does not name it. So a refused `migrate` has no stated outcome at the pin. The set's existing answer for every pre-service acquisition refusal is fail fast, let the external retrier retry, and leave the admission accounting untouched. That is the right answer here too. An internal wait adds a second retry layer and a parameter nobody has priced.

**Final: Q1 exact alternative A′**, which is package A with one diagnostic field replaced, printed in full at the end.

- **A CANNOT ACCEPT** as printed.
- **B CANNOT ACCEPT** as printed.
- **C ACCEPT** as printed.
- **D CANNOT ACCEPT.**

Preference order: A′, then C. B and D are not preferred. Acceptability and preference are separate above.

**Why A fails as printed.** Its diagnostic "MUST identify ... whether another migration runner is active or scheduled". The process has no input from which to know either. "Scheduled" is a deployment fact `migrate` never sees. "Active" could only mean "the authority holds an unreleased migrator grant", and STO-55 keeps charges for dead attempts by design, so in fixture (c) the runner's own residual grant would make it report another runner as active. A MUST the process cannot truthfully meet is not executable, and the fixture sentence "assert the refused runner emits the `STO-55` migration diagnostic" has no source of truth for that field. Everything else in A is sound. B carries the same field.

**Why B fails beyond that.** It adds a deployment parameter and an in-process wait, which is a delay and resource-cost preference the owner has not taken. It duplicates the deployment's own retry, the mechanism the set chose for the engine when the pv-oehp decision accepted "indefinite replacement/startup delay" through supervisor retry. Its timer is also ambiguous in one reachable case: the episode "ends only on obtaining a confirmed usable reservation", yet the bound excludes "connection checks after a grant", so when a granted connection fails STO-7's new-connection check and is "closed unused", the text does not say whether the episode is over or still running.

**Why C passes, and what it leaves.** C lands the policy at the owner, points from STO-13, and adds fixtures that distinguish the lock wait. It does not say "at once" and states no bound, so an implementation that waits internally for a while and then exits conforms. The fixture detects only eventual exit: a never-exiting runner hangs the test, a runner that waits a while passes. That is the same property the engine's startup clause has in the base, so C is not worse than the set's precedent, but it answers the row's "with what bound and observable failure report" with no bound and no report.

**Why D fails.** No sentence in the pin says the startup clause covers `migrate`, and the one quotation of it binds it to the engine. Calling the omission intentional leaves the bead open as filed.

## Traces

**Initial acquisition.** The authority refuses before any dial. No grant exists, so nothing is charged by this attempt and the exit releases nothing. Under A′ and C the runner exits non-zero. Under B it polls with backoff until its bound. Fixture (a) detects the policy if the harness owns the authority: it counts admission requests, checks the primary for no new backend, and reads the exit. A′'s "at once" is observable as exactly one request and exit before any capacity release. B's "single unreset elapsed bound" is observable by refusing throughout and asserting exit at first refusal plus bound regardless of request count.

**Second runner denied before connection.** Runner one holds STO-12's key mid-migration. Runner two asks for a reservation and is refused. It never holds a connection, so it never requests the key. Fixture (b) detects this through the absence of a second backend and a second lock waiter. All three packages separately admit both runners and assert the second waits on the key, which is the right control for the already-connected case.

**Reconnect after a recorded completed migration.** Migration k is recorded. The transport dies. The old backend's grant stays charged, since "Timeout, transport loss, process exit and rollout completion never release a grant". The replacement request is refused. The runner exits. Fixture (c) detects the policy and the accounting: the version table shows k recorded and k+1 absent, charges persist through exit, and a later invocation after fenced release resumes at k+1 without re-applying k, which CNF-57's existing no-op re-run already demands.

**Already-connected SQL lock wait.** Governed by STO-12, not by any package. Each package's control case asserts the second runner waits on the key. B's claim that "the admission-refusal timer does not run merely because it waits there" is observable only by waiting past the bound and asserting no exit.

**Exhaustion while the previous release serves.** The previous release's pools are already admitted sessions, and "Existing admitted sessions may continue". Each fixture asserts an engine write and an `api` write succeed on retained sessions and that no `SyncRep` backend is cancelled. This detects that the migrator's exit neither releases nor cancels anything, provided the harness provokes no reconnect in the previous release during the test, which the fixtures' "independently of the denied migration attempt" wording covers.

## Deletion and weakening check

A, B and A′ are pure insertions. No existing sentence changes, so no quotation, theorem or fixture loses its anchor. C replaces the block at `05-persistence.md:312` with its six original sentences intact plus one inserted sentence. I verified that OPS-47's quotation at `03-operation-lifecycle.md:138` and both quotes inside the block still match the pin. The obligation gate's pattern matches nothing in any candidate paragraph. No rendered-region marker touches the three landing sites. No Lean docstring quotes the refusal block. The STO-13 declarations quote the `CONCURRENTLY` sentences and the backfill population sentence, none of which any package touches, and Migration.lean models migration shape only.

Two substantive additions deserve naming. A and A′ add a new deployment MUST NOT at STO-13, that no component of the new release starts "until the required migrations have completed successfully". The base says only that `migrate` is "run by the deployment before any component of a release starts", and a component started early self-corrects by exiting on an older schema. The new sentence strengthens "run" to "completed successfully". It agrees with the backfill order and ADR-0024 and generalizes an assertion CNF-57 already makes for the backfill. B adds an OVR-19 row and a validated parameter. Neither contradicts a checked verdict, but both are substantive under rule 3, not editorial.

A landing detail: the STO-55 insertions must carry the bullet's two-space continuation indentation that lines 312 to 317 use. The brief prints them unindented. The STO-13 anchor at line 1576 is correct.

## Requested counterargument for no change

The set already makes a refused migrator harmless: it cannot dial without a grant, exhaustion is alarmed at OVR-18, every component refuses an unmigrated schema and exits into its supervisor, and STO-12 makes any re-run resume. Whether `migrate` exits or waits, the release cannot advance unsafely, and the deployment's own job timeout bounds any wait. The exit code of a deployment step is tooling, like the invocation cadence the brief itself leaves outside. The engine's startup clause carries no bound either, so demanding one for `migrate` is asymmetric. The reply is that the bead is about a deployment being unable to tell which behavior to expect, and safety is not the question. This is a counterargument, not my vote.

**Premise check.** Every quoted span in the brief is byte-identical to my pin, the line anchors are right, and the bead is open with the needs-triage label in the pinned tracker. OPS-47's quotation strengthens the brief's premise rather than contradicting it. No candidate contradicts its own test except through the unknowable diagnostic field in A and B. One residual outside this bead: no package states what `migrate` does when a granted connection fails STO-7's check, when STO-13's lock_timeout retry count is exhausted, or when a statement errors. That is a follow-on finding, not a defect of this question.

## Owner questions

1. Does the owner want an observable failure report from `migrate` at all? That is the fork between A′ and C. Both exit at once without a parameter; only A′ requires a diagnostic and the explicit STO-13 release-boundary MUST.
2. B's "Migration admission-retry bound" and its in-process wait are a new delay and resource-cost preference. Nobody has adopted it. If the owner wants an internal wait, B needs a re-reviewed form that resolves the failed-unused-grant episode question.

## Exact alternative A′

Identical to A except the diagnostic sentence in the STO-55 insertion. Landing sites and indentation as the brief specifies for A.

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
acquisition or reconnect, and the admission-refusal reason as the authority returned it,
without credentials.
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

No new parameter, identifier or ADR. The only difference from A is the diagnostic field, so A′ and A are distinct forms for the tally.

### END r87 fable.md

### BEGIN r87 opus.md (verbatim)

**Final: Q1 C.**

When the connection authority refuses the database-update program a connection, the program should exit non-zero and let the deployment run it again. That is already what a starting engine or `api` does. A program that already has its connection and is waiting for the other updater's lock was never refused, and every form leaves it alone. C says this with the fewest new obligations.

A has the right policy, but its required diagnostic asks the refused program for a fact it cannot know. B's bounded internal wait is a coherent policy, but it has the same diagnostic flaw and adds a delay and a new parameter the owner has not chosen. D leaves a lost connection that a running `migrate` must replace (the reconnect case) with no outcome at all.

## 1. Acceptance

- **A — CANNOT ACCEPT** as printed.
- **B — CANNOT ACCEPT** as printed.
- **C — ACCEPT** (preferred).
- **D — CANNOT ACCEPT.**
- **A′ (printed in full at the end) — ACCEPT.** It is a distinct form and not my preference.

**Why A and B fail.** Both STO-55 insertions say: "The diagnostic MUST identify … whether another migration runner is active or scheduled".
- A runner refused before its first connection has no database session, so it cannot see who holds `STO-12`'s key.
- The only other source is the admission authority, whose "enforcement construction is the deployment's" (`05-persistence.md:299`).
- The authority's charges don't mean a live process. STO-55 says: "Unknown bindings remain charged. Timeout, transport loss, process exit and rollout completion never release a grant" (`:290–291`).
- "Scheduled" is the deployment's plan, and nothing passes it to the runner.

Concrete failure: runner R1 crashes after recording a migration, and its grant stays charged. The deployment invokes R2, which is refused. R2 must say whether another runner is active. "Active" would be false, and "not active" has no evidence behind it.

A's fixture (b) then requires "the refused runner emits the `STO-55` migration diagnostic". B requires both diagnostics to "carry every `STO-55` migration-diagnostic field". So each candidate's own test asserts an output the specification gives no way to produce.

B also has a smaller ambiguity: its episode ends on "a confirmed usable reservation", yet the bound covers "not transport or connection checks after a grant".

**Why C is enough on prompt exit.** C maps refusal to "exit non-zero for deployment retry". That is the same indicative wording the base uses for startup ("exits for supervisor retry"). `OPS-47` reads that wording as putting the retry with someone else: "an external supervisor that retries startup subject to `STO-55` admission" (`03-operation-lifecycle.md:135–138`). Giving the retry to the deployment rules out an internal admission retry by the runner, just as the base rules one out for the engine.

What C leaves open is small:
- It has no "at once", so a runner could pause before exiting. That changes no charge; the base startup clause has the same gap.
- Its list is closed. A `migrate` connection that is neither the first nor a replacement isn't named. `STO-12` requires no such connection, so this doesn't block.

**Why D fails.** See §4.

## 2. Traces

**(i) Initial acquisition.** The authority refuses and no reservation exists. STO-55 says every attempt "MUST receive a distinct durable reservation before dialing", so there is no dial and no SQL. No version is recorded.
- A: report, then exit once. B: a waiting report, backoff retries within the bound (each one its own admission call), then exit. C: exit non-zero. D: undefined.
- Fixture (a) catches each policy. A: one admission call, then exit. B: several calls across the bound, then the continuation if capacity is released before expiry. C: exit, then a normal re-run after release.

**(ii) Second runner refused before connecting.** R1 is admitted and holds the key inside a migration transaction. R2 is refused, never reaches the advisory-lock request, and so is not in `STO-12`'s wait.
- A and C: R2 exits, R1 finishes, and the release proceeds.
- B: R2 waits. If capacity is released, it dials on a fresh reservation, waits on the key (a SQL wait that does not run B's timer), then finds every version recorded and does nothing.
- Fixture (b) catches this. It must time R2's refusal inside R1's transaction-scoped hold, and "while an admitted runner holds `STO-12`'s migration key" says so.

**(iii) Reconnect after a recorded migration.** The runner's transport drops. The old backend and its grant stay charged, because transport loss never releases one and release needs fencing plus fresh direct-primary evidence. The replacement attempt is refused.
- A and C: exit. The re-run after verified release inspects the history under the key and skips the recorded migration.
- B: wait, then continue in the same process.
- Fixture (c)'s "No completed migration is applied again" (A) and "normal version inspection and completion" (C) catch a runner that cannot resume.

**(iv) Lock wait after connecting.** No admission refusal happens, so every form leaves this to `STO-12` and `STO-13`. Each form's "Separately …" assertion fails a runner that treats the lock wait as a refusal (an exit in A or C, a running timer in B). The existing "assert one waits on `STO-12`'s key" stays.

**(v) Exhaustion while the previous release serves.**
- Capacity C is full of charged reservations. The previous engine and `api` keep writing on sessions they already hold ("Existing admitted sessions may continue", `:309`).
- No individual `SyncRep` backend is cancelled, and `OVR-18` alarms the exhaustion.
- The fixtures assert those writes succeed and no new-release component starts. Under A and B that rests on the new explicit MUST. Under C it rests on the base `STO-13`: migrations "MUST be … applied by the deployable's own `migrate` entry point, run by the deployment **before any component of a release starts**".
- No fixture assumes a refusal allocates a grant, and none releases one on exit: "Retain all uncertain/residual charges through refusal and any runner exit."

**What the fixtures can measure.**
- A's "at once" is measurable as a single admission call. Promptness has no number, so it cannot be timed.
- C's "exits non-zero for deployment retry" catches a runner that never exits. A runner that asks again before exiting shows up in the authority's log.
- B's single unreset bound is measurable as the time from first refusal to exit, with refusals in between.

## 3. Deletions and weakening

- **A and A′:** insertions only. Every existing STO-55 sentence stays, so these quotes still resolve:
  - `OPS-47`: "Startup acquisition refusal exits for supervisor retry"
  - `OPS-49`: "worker/periodic acquisition refusal is an `OPS-49` store error"
  - CNF-372's consumer list
- **A's new `STO-13` MUST** only strengthens. It matches the backfill's "only then permit the first new-release component to start" and the shared-predicate stop, and it says both keep their order.
- **Exit "at once" fits `STO-7`.** `STO-7` says: "short of its process exiting, a deadline or a cancellation … MUST NOT release its connection" (`:179`). Process exit is the stated exception, and A adds no deadline.
- **B:** "applies instead of the startup acquisition-refusal outcome above" changes `migrate`'s outcome only if that clause ever reached `migrate`. No current test covers `migrate` there, since CNF-372's "Exercise startup refusal and supervisor retry" names no `migrate` case, so no checked verdict flips. The new OVR-19 row follows the existing "no — the migrator's, read at `migrate`" row.
- **C:** all six base lines stay verbatim and one sentence is added. The only change is that `migrate`'s retrier is the deployment, not a supervisor.
- **D:** loses nothing; the gap stays open.
- **Formal layer:** nothing in `tools/formal` is tagged `STO-55`. `Admission.lean` tags API, WIR, SEC and LDG ids. `Migration.lean` checks migration shape. The `STO-13` backfill theorems (`Restore.lean:646–655`, `Witnesses.lean:1284`) model the backfill, not refusal. No option makes a theorem unreachable or vacuous.
- **CNF-57:** no assertion is removed; the insertions go before "Then the concurrent index step".
- **Rule 3:** no option has a blocking loss. The A/B defect is in their new text, not a lost base obligation.
- **Landing (mechanical, not a vote point):** the printed STO-55 texts are flush-left, but the refusal block is a two-space continuation inside "The sum fits…". Landing must keep that indentation.

## 4. Requested counterargument (not my vote)

**The case for D.** ADR-0024 makes `migrate` "one binary, one more way to invoke it". Each invocation is a process starting, so its first connection is startup acquisition and "Startup acquisition refusal exits" already covers the first and the second runner. `STO-12`'s resumability makes a re-run safe. The deployment sees the exit status, and `OVR-18` alarms "Admission exhaustion". STO-55 already accepts "indefinite replacement/startup delay" (`:323`). CNF-372 already checks grants for "migrators and waiting runners".

**Why it fails.**
1. "Supervisor retry" names a retrier. `OPS-47` binds it to the engine's supervisor, while `STO-13` says `migrate` is "run by the deployment", and `00-overview.md:137` puts it before "a release's components start".
2. A reconnect inside a running `migrate` is not startup. `OPS-49` is scoped to "a worker, or by a periodic component running in the engine process", and `api`'s request path does not apply. The "indefinite … delay" sentence even allows a `migrate` that waits forever, which is the bead's own gap.

**Premise check.** No brief error changes the question's premise, so rule 6 voids nothing. Every quoted block matches the pin, and the brief's "no formal declaration" claim holds.
- B's "instead of" wording assumes the startup clause otherwise reaches `migrate`, which the brief rightly says no quote shows. The wording is harmless.
- A's and B's diagnostic conflicts with their own fixture (b), as shown in §1.
- The brief leaves out `OPS-47`'s gloss on "supervisor", which supports its premise.

## 5. Owner question

If C or A′ settles, no owner question is needed: neither adds a delay or resource cost. The refused runner exits at once, as startup already does. B's internal wait and its new "Migration admission-retry bound" are the only new delay or parameter. If unsettled, ask:

> When the connection authority refuses the database update program, should it fail at once and let the deployment re-run it (**C**)? The same, plus a required message naming the program, the release, initial-or-reconnect and the authority's reason (**A′**)? Or keep asking for a configured time first (**B**, whose diagnostic needs repair before it can be accepted)?

## A′ — exact alternative (ACCEPT, not preferred)

A′ is A with one clause deleted from the diagnostic sentence. Placement is identical to A.

**STO-55 insertion:**

```text
**Migration admission refusal.** If `STO-55` admission refuses a physical connection attempt
by the `migrate` entry point, including initial acquisition, acquisition by a runner scheduled
alongside another runner, or reconnect, `migrate` MUST report the refusal and exit non-zero
at once; it MUST NOT wait or retry admission internally. A later invocation is a deployment
retry; see `STO-12` for version inspection, serialization and resumability. The denied attempt
MUST send no dial and no SQL. It MUST NOT record a migration as completed because of that
refusal, and the refusal does not undo previously recorded completed migrations.
The diagnostic MUST identify `migrate`, the release being attempted, whether this was initial
acquisition or reconnect, and the admission-refusal reason, without credentials.
This rule governs refusal before a physical connection is admitted, not a SQL advisory-lock
or DDL lock wait after connection. It introduces no deadline for a sent COMMIT or standby
wait; see `STO-7`. The grant-retention and release rules above still apply on process exit or
transport loss; neither is evidence that an old backend ended. Refusal does not require
stopping the previous release or terminating any individual backend to make room.
```

**STO-13 insertion:**

```text
For physical connection-admission refusal by the `migrate` entry point and deployment retry,
see `STO-55`. The deployment MUST NOT start any component of the new release until the
required migrations have completed successfully. The stop-everything and backfill exceptions
below retain their existing order.
```

**CNF-57 cases:**

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

A′ adds no OVR-19 row, identifier, ADR or formal change.

### END r87 opus.md

### BEGIN r87 astra.md (verbatim)

I prefer **A**: when admission refuses the updater’s connection, report why and exit immediately. Let the deployment invoke it again. This makes release failure observable without adding an internal retry timer.

**Final: Q1 A**

- **A ACCEPT**
- **B CANNOT ACCEPT**
- **C CANNOT ACCEPT**
- **D CANNOT ACCEPT**

These are judgments on the printed packages, not adoption. I verified the clone’s pin as `3109b5b44eae17e288cf52aaa976993bd8c5626c`, read `notes.md` whole and inspected the cited owning text and migration declarations. No files, Git state or tracker records were changed; no gates or builds were run.

1. **Acceptability and preference**

**A** supplies an explicit action, timing and report: “exit non-zero at once; it MUST NOT wait or retry admission internally.” Its release boundary and independent fixtures make that policy reviewable. It introduces no promise of eventual capacity or total rollout completion. Its diagnostic requires deployment/runner context, including the release and peer-runner status; that is additional implementation work, but I found no inherent contradiction.

**B** has a concrete rule/fixture conflict. Its rule says:

> “If no confirmed reservation is obtained before the bound expires, `migrate` MUST report exhaustion and exit non-zero.”

Its success fixture instead says:

> “with verified capacity release before expiry … continuation without first exiting”

Capacity release is not confirmed reservation acquisition. Consider a ten-second bound: the runner receives refusals, is in backoff or awaiting an authority response, and capacity becomes available at 9.9 seconds. At ten seconds it still has no confirmed reservation. The rule requires exhaustion and exit; the fixture requires continuation. Neither a particular backoff cadence nor an authority-response guarantee eliminates this permitted trace.

This is not an objection to bounded retry as a policy. The printed package demands incompatible verdicts on that trace. Making its success fixture require timely confirmed acquisition would change the reviewed fixture; I am not accepting that unprinted repair.

**C** explicitly assigns migration refusal an eventual nonzero outcome, but does not adequately settle the timing question. Its “exit non-zero for deployment retry” lacks A’s prohibition on internal waiting/retrying and B’s elapsed bound. A runner could wait internally for an arbitrary interval and then exit nonzero; C’s printed denied-capacity fixtures would pass. I cannot accept C as a complete answer to whether the invocation exits promptly or waits under a stated bound. This is incompleteness, not evidence that C deletes an existing protection.

**D** preserves the existing specification but leaves this bead’s outcome gap unresolved. I cannot accept it as the requested resolution. Deliberately leaving the policy unspecified would be a separate scope decision, not a fix.

2. **Execution traces and what the fixtures detect**

| Case from the candidate CNF-57 fixtures | A | B | C |
|---|---|---|---|
| Initial acquisition denied | Diagnostic and immediate nonzero exit; the no-internal-wait/retry assertion distinguishes the policy. | Waiting report, retries and exhaustion are tested. The early-capacity-release success branch has the conflict above. | Tests nonzero exit, but cannot distinguish prompt exit from waiting first. |
| Second runner denied before connecting | Exits without requesting the migration key. The independently admitted first runner separates admission refusal from lock contention. | Same separation; denial starts the retry episode. Both expiry and recovery branches are requested, subject to the success-fixture defect. | Correctly separates admission from SQL locking, but leaves exit timing undetected. |
| Reconnect after a completed migration | Exits; a separately invoked runner inspects history and resumes. The fixture checks that previously completed versions remain unchanged and are not applied again. | Waits within the episode, continuing if a reservation is confirmed in time, otherwise exits. The printed recovery assertion incorrectly substitutes capacity release for confirmation. | Checks eventual exit and subsequent deployment invocation, without testing internal-wait duration. |
| Already connected, waiting on the migration key | Separate admitted-connection fixture correctly rejects misclassification as admission refusal. | Explicitly checks that the admission timer does not run merely for this SQL wait. | Also distinguishes the SQL wait from physical-admission refusal. |

D adds no such outcome fixtures. That absence is not a contradiction in the unchanged base.

For capacity exhaustion, the candidate fixtures retain adequate admitted previous-release read/write sessions and require the standby needed for successful writes. This is a reachable setup: charged reservations exhaust new admission without requiring the existing sessions to disappear. The candidates then assert actual engine and `api` write success, rather than treating process survival as service success.

The relevant existing permission is [STO-55](https://github.com/douglaz/provisiond/blob/3109b5b44eae17e288cf52aaa976993bd8c5626c/05-persistence.md#L308): “Existing admitted sessions may continue.” Its accounting constraint is “Timeout, transport loss, process exit and rollout completion never release a grant.” Accordingly, a denied request need not allocate any grant, and exiting the refused runner cannot free an earlier uncertain or residual grant. The candidates’ capacity-release steps must operate on previously charged reservations using the prescribed evidence.

The fixtures are conformance instructions, not evidence that a running implementation has passed them.

3. **Deletion, weakening and protected verdicts**

**A and B insert text; they delete no existing sentence.** Their STO-55 additions supply migration-specific outcomes, reporting, completion-history treatment and exclusions. Their STO-13 insertion supplies the explicit boundary:

> “The deployment MUST NOT start any component of the new release until the required migrations have completed successfully.”

B additionally supplies the retry parameter, validation and episode semantics. Its changed outcome is substantive: a refused invocation can remain alive and later continue.

**C replaces the refusal block but reproduces its existing protections**, adding the migration scope sentence. The retained clauses still assign startup exit, API overload and worker/periodic store-error handling; retain stop-record bounds; and prohibit terminating an individual waiting backend to make room. Its defect is the unresolved timing contract, not a removed clause.

**D changes no verdict or obligation.**

I found no existing conformance assertion or theorem made unreachable or vacuous by these packages. B’s identified conflict is between its *new* rule and *new* success fixture. A/C add coverage; D’s missing new coverage is not a blocking loss under notes rule 3.

The following constraints remain material:

- **Connection accounting — STO-55, `05-persistence.md`:** “Ingress MUST prohibit bypass and redial under one reservation.” The release condition requires “fencing every delayed arrival/retry and fresh privileged direct-primary evidence, read in a fresh transaction, that the bound backend ended.” A later deployment invocation or B’s later admission call cannot reuse a reservation or erase uncertain charges.
- **Startup-lock independence — STO-12, `05-persistence.md`:** the runner’s lock uses “a fixed key distinct from `STO-51`’s”. Existing CNF-57 requires that “the engine’s startup lock is untouched”. The added fixtures retain that case and add a separately admitted pair; refusal before connection cannot replace or satisfy the lock-contention check.
- **Standby waits — STO-7, `05-persistence.md`:** “short of its process exiting, a deadline or a cancellation … MUST NOT release its connection before the reply arrives or the transport is found dead.” A expressly introduces no standby/COMMIT deadline; B excludes those waits and says its bound “MUST NOT cancel a sent COMMIT or release a grant.” C changes physical refusal outcomes only. None authorizes clearing an old backend to obtain migration capacity.
- **Exceptional release order — STO-13, `05-persistence.md`:** a shared-predicate release “MUST stop every component of the previous release before the first component of the new one starts”. The backfill separately requires stopping previous-release components, filling the column, “and only then permit the first new-release component to start”. A/B expressly preserve these exceptions. Their statement that refusal does not require stopping the previous release adds no permission to restart an already stopped exceptional release. The new service-success fixtures explicitly use a release allowed to migrate concurrently.
- **Retry-loop scope — OPS-49, `03-operation-lifecycle.md`:** “Where a store call by a worker, or by a periodic component running in the engine process” defines the loop’s population. None of the packages exports it to `migrate`.

Textual inspection of [Migration.lean](https://github.com/douglaz/provisiond/blob/3109b5b44eae17e288cf52aaa976993bd8c5626c/tools/formal/Provisiond/Migration.lean) confirms that `transactional_holds_nothing_refused`, `large_index_is_standalone` and `no_home_without_standalone_rule` concern migration shape. [Restore.lean](https://github.com/douglaz/provisiond/blob/3109b5b44eae17e288cf52aaa976993bd8c5626c/tools/formal/Provisiond/Restore.lean#L646) defines `migrateCreate` and `claimed_legacy_create_stays_unresolved`; the corresponding witness distinguishes legacy backfill outcomes. These packages change neither those declarations nor their hypotheses or represented populations. No formal weakening is needed, and no conformance identifier belongs there.

4. **Requested counterargument for no change — not my vote**

The strongest argument is that [STO-55](https://github.com/douglaz/provisiond/blob/3109b5b44eae17e288cf52aaa976993bd8c5626c/05-persistence.md#L312) already says “Startup acquisition refusal exits for supervisor retry”, while its admission population expressly includes “migrators and waiting runners”. One could interpret every runner’s initial acquisition as startup and treat deployment reinvocation as supervisor retry, avoiding additional policy and reporting requirements.

That interpretation is insufficient for reconnect: the invocation has already started and recorded a migration. Nor does population membership determine the refusal outcome. [STO-13](https://github.com/douglaz/provisiond/blob/3109b5b44eae17e288cf52aaa976993bd8c5626c/05-persistence.md#L1555) places `migrate` “before any component of a release starts”; it does not explicitly equate its acquisition phases with component startup.

I found no verified existing rule that settles the whole question. B’s candidate inconsistency does not overturn the premise that the pinned migration-refusal outcome is missing. Under notes rule 6, I therefore identify no premise-changing brief error requiring this question to be voided. I make no tally.

5. **Owner question**

**For pv-3zzo, adopt the exact r87 Q1 package A—STO-55 insertion, STO-13 release boundary and CNF-57 cases—so a refused updater reports why and stops immediately, leaving the deployment to invoke it again?**

That choice accepts possible repeated deployment invocations and potentially indefinite overall release delay while capacity remains unavailable. B instead purchases an internally waiting process, repeated authority calls and a deployment-selected duration; its printed fixture conflict prevents accepting that exact package. Panel authorization adopted neither cost preference.
### END r87 astra.md

### BEGIN r87 sol.md (verbatim)

Prefer A: when admission refuses the migration connection, report why and return failure immediately so deployment controls the next invocation. B is also coherent, but deliberately buys an internal waiting period and a new deployment parameter.

**Final: Q1 A**

- **A ACCEPT** — preferred, exactly as printed.
- **B ACCEPT** — a valid alternative policy, exactly as printed.
- **C CANNOT ACCEPT** — it specifies the exit status but leaves delay before exit unspecified.
- **D CANNOT ACCEPT** — as a resolution of pv-3zzo. Keeping the outcome unspecified is possible as an intentional scope decision, but would leave the bead open.

These are review judgments, not adoption.

**Traces and fixture effectiveness**

| Situation | Outcome and what the printed fixtures detect |
|---|---|
| Initial acquisition | A reports refusal and exits non-zero without an internal admission wait/retry. B reports waiting, retries with backoff, then either obtains a reservation within the episode bound or reports exhaustion and exits non-zero. C requires non-zero exit but provides no explicit timing. D adds no outcome. The A fixture distinguishes immediate refusal handling from internal retry; B exercises both exhaustion and recovery before expiry; C checks eventual exit only. |
| Second runner denied before connection | The admitted runner holds the migration key; the second runner cannot yet request that key. A exits; B waits for admission within its bound; C eventually exits. The independent fixtures correctly distinguish this refusal from SQL lock contention. Merely launching two connected runners would not exercise it. |
| Reconnect after a recorded migration | Version V is already recorded, the transport fails, and admission refuses the replacement attempt before the next migration. A exits; B starts a refusal episode; C requires non-zero exit. The fixtures check preservation of V and absence of a completion caused by refusal. Later progress inspects history through the normal runner, rather than assuming the lost transport erased V. |
| Already-connected SQL lock wait | This is outside the refusal policy. [STO-12](https://github.com/douglaz/provisiond/blob/3109b5b44eae17e288cf52aaa976993bd8c5626c/05-persistence.md#L1529) requires a migration key “distinct from `STO-51`’s”; existing CNF-57 checks that one runner “waits on `STO-12`’s key while the engine’s startup lock is untouched.” A–C retain that case and add an explicit admitted-pair comparison. B’s admission episode has ended on obtaining the reservation; waiting for the SQL key does not start its timer. |
| Exhaustion while the previous release serves | The fixtures retain admitted read/write sessions and make a required standby available. Exhaustion blocks additional physical attempts without making the service assertions impossible merely by withholding every connection or every standby. [STO-55](https://github.com/douglaz/provisiond/blob/3109b5b44eae17e288cf52aaa976993bd8c5626c/05-persistence.md#L307) expressly permits: “Existing admitted sessions may continue.” A–C can therefore exercise refusal and successful previous-release writes in the same fixture. |

A’s “at once, without an internal admission wait/retry” is observable as the absence of another admission call or an admission-backoff phase after refusal. It does not require inventing a numeric response-time parameter.

B is executable within its stated scope. Its episode includes later admission calls and backoff, so a subsequent call cannot silently extend the deadline. An implementation must arrange expiration even if that call remains pending, while retaining any uncertain grant. The printed tests exercise repeated refusals, a single unreset bound, recovery before expiry, invalid settings and exhaustion diagnostics. No particular backoff cadence is necessary to distinguish those outcomes.

B does **not** bound the first authority call before any refusal, post-grant connection checking, SQL execution, SQL lock waits or total migration runtime. Those are explicit limits of this package, not promises its fixtures establish.

C’s counterexample is simple: receive refusal, wait an arbitrarily long finite period, then exit non-zero. Its proposed sentence and fixture do not expressly reject that trace. An internal retry that succeeds and returns success would conflict with its required refusal outcome; the remaining loophole is delay before the required failure. Rejecting C on that basis identifies an incomplete new timing contract, not a lost baseline obligation.

D adds no distinguishing fixture. The absence of a migration-specific test is not itself a contradiction in the unchanged base.

**Deletion, weakening and preserved protections**

A and B are insertions. They delete no existing sentence or fixture. C replaces the refusal block but retains its original startup, API, worker/periodic, stop-record and backend-protection sentences verbatim, adding migration scope between them.

The protection audit is:

- **Outcome and timing:** A’s refusal sentence excludes internal admission waiting and retry; its later-invocation sentence assigns retry to deployment. B instead explicitly substitutes a bounded migration policy for the generic startup outcome. That is a substantive behavioral choice: refusal can be followed by successful continuation within the same invocation under B, while A requires exit.
- **Bounds and observability:** B’s parameter, validation, episode-start, elapsed-time and non-reset sentences prevent an endlessly renewed refusal loop. Its OVR-19 row gives that parameter a registered home. A and B’s diagnostic sentences make the blocked release and acquisition stage identifiable without credentials. C adds neither protection.
- **Database effects and resumability:** A and B’s no-dial/no-SQL and completion sentences prevent a denied attempt from executing or being recorded as a completed migration, while preserving earlier completed versions. Their deployment-retry pointers use the existing version/serialization owner. [STO-12](https://github.com/douglaz/provisiond/blob/3109b5b44eae17e288cf52aaa976993bd8c5626c/05-persistence.md#L1534) requires the lock across “inspecting the history, applying a migration and recording its completion.”
- **Release boundary:** A and B add the explicit successful-completion condition before new components start. C adds only a pointer. The existing [STO-13](https://github.com/douglaz/provisiond/blob/3109b5b44eae17e288cf52aaa976993bd8c5626c/05-persistence.md#L1555) ordering remains: migrations run “before any component of a release starts.” C’s conformance start-order assertion therefore has an existing normative basis; it is not contradicted merely because C adds no new boundary sentence.
- **Check strength:** The CNF-57 additions distinguish the entry-point policies and preserve the existing release, connected-runner, concurrent-index and backfill cases. None makes an existing assertion unreachable or vacuous.

The retained accounting constraint is decisive for reconnect and timeout traces. [STO-55](https://github.com/douglaz/provisiond/blob/3109b5b44eae17e288cf52aaa976993bd8c5626c/05-persistence.md#L285) requires a “distinct durable reservation before dialing” and states: “Timeout, transport loss, process exit and rollout completion never release a grant.” A denial need not allocate a grant. Previously issued or uncertain grants remain charged; neither runner exit nor B’s expiration establishes backend absence. The printed fixtures correctly require the existing fencing and backend-absence evidence before release.

Startup-lock independence is preserved by the distinct-key requirement quoted above. The admitted-pair lock test remains reachable because exhaustion fixtures are independent of it.

The standby protection also remains. [STO-7](https://github.com/douglaz/provisiond/blob/3109b5b44eae17e288cf52aaa976993bd8c5626c/05-persistence.md#L178) states that a sent COMMIT’s connection “MUST NOT” be released before its reply or dead-transport detection, short of process exit. A excludes sent-COMMIT and standby deadlines; B expressly excludes those waits and prohibits cancellation or grant release by its timer. Neither authorizes eviction: STO-55 retains “No individual `SyncRep` backend may be cancelled or terminated to make room.”

The fixtures’ previous-release service assertions apply to a release permitted to migrate concurrently. They do not erase [STO-13’s backfill exception](https://github.com/douglaz/provisiond/blob/3109b5b44eae17e288cf52aaa976993bd8c5626c/05-persistence.md#L1595), which requires stopping previous components and “only then” permitting the first new component after backfill. The shared-predicate stop-everything order also remains unchanged.

No formal declaration or hypothesis needs changing. [Migration.lean](https://github.com/douglaz/provisiond/blob/3109b5b44eae17e288cf52aaa976993bd8c5626c/tools/formal/Provisiond/Migration.lean#L1) concerns migration shape and the standalone home for concurrent index builds. The [backfill declarations](https://github.com/douglaz/provisiond/blob/3109b5b44eae17e288cf52aaa976993bd8c5626c/tools/formal/Provisiond/Restore.lean#L646) concern population and conservative restart classification. None carries an admission-refusal outcome. I found no affected theorem, changed existing conformance verdict, or lost quoted normative obligation. No formal build was run.

**Requested counterargument for no change — not my vote**

The strongest argument for D reads “Startup acquisition refusal exits for supervisor retry” broadly: migration acquisition is preparation for deployment startup, so it already exits; deployment can provide retry scheduling and reporting without more requirements.

That reading is plausible for initial acquisition, but the text does not expressly extend “startup” to migrator reconnect or a runner denied before obtaining its own connection. STO-13’s “before any component of a release starts” does not supply that equivalence. Nor can the retry policy be imported from [OPS-49](https://github.com/douglaz/provisiond/blob/3109b5b44eae17e288cf52aaa976993bd8c5626c/03-operation-lifecycle.md#L1925), whose subject is “a worker, or by a periodic component running in the engine process.”

**Premise check and owner question**

The pinned JSONL matches the packet bead, and the STO-55/STO-13 owner spans match the filing baseline. I found no premise-changing brief error and no candidate contradicting its own fixture. Under notes.md rule 6, I therefore identify no basis to void this question.

The owner question is: **Adopt exact r87 Q1 A, requiring immediate diagnostic failure and a later deployment invocation, or exact r87 Q1 B, keeping the migrator alive to retry within a validated deployment-stated bound?** I recommend A. B’s waiting/resource cost and new parameter require an explicit owner choice; panel-launch approval did not make it.

No source, tracker or panel records were edited; no gates or builds were run.
### END r87 sol.md

