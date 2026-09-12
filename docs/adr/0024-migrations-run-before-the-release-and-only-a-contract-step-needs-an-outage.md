# Migrations run before the release, under their own lock, and only a contract step or a shared-predicate change needs an outage

**Status:** accepted (2026-09-12; amendments landed the same day). The rules are `STO-12` and
`STO-13`. Answers
the third of `impl-report-01.md` §6.15's four gaps — "live-migration policy" — which `ADR-0015`
recorded as "migrations against a live database" among the surface the set did not yet specify.

## The problem as found

`STO-13`: "Migrations MUST be forward-only and MUST be safe to run concurrently with a running
instance of the previous version, or startup MUST take an exclusive lock." Nobody chose a half, and
the set says nothing about a version skew between the engine and an `api` replica, which
`ADR-0016` made the normal state of every roll.

The proposal on the table was to have the engine run migrations as its first act after taking
`STO-51`'s startup lock, and to let `api` replicas of the previous release keep serving on the
strength of expand-only migrations. Two independent readers of one brief — Codex at xhigh and a
fresh Claude reader — rejected both halves on the same facts.

**The startup lock excludes nothing a migration needs excluded.** `OPS-47` takes it "on a connection
outside the pool", and a PostgreSQL advisory lock conflicts only with requests for the same key:
"the system does not enforce their use — it is up to the application to use them correctly". A
migration on a pooled connection is not covered by it, `api` replicas are not excluded by it at all,
and a second runner — a CI job, a test harness, the binary invoked by hand — is excluded only if it
asks for the same key, in which case it blocks the engine's own boot. What orders `api` against DDL
is the DDL's own table lock, which "Conflicts with locks of all modes" including a plain `SELECT`,
and which queues every later `api` statement on that table behind it. `STO-51` buys the migration
one thing, that only the lock holder reaches it, and that is worth exactly one engine.

**Running the migration inside the restart window is the wrong place for it.** `ADR-0016` priced
that window at seconds and `ADR-0019` fought a bounded lock wait to keep it there; `OVR-18` says
"While the engine is down no exposure-reducing mechanism runs". `CREATE INDEX CONCURRENTLY` on
`operations` or `ledger_entries` runs as long as the table is large, and a failed migration under
this placement leaves the engine crash-looping with the schema half-way while the operator debugs
DDL and every machine keeps billing.

**Expand-only is a rule about columns, and three of the four skew cases are not column problems.**
Both readers built the same witness: add a `status` value, let engine N write it, and `STO-10` makes
every N−1 `api` read of that row "a hard error, not a silent default" — every list page containing
it, for the whole roll — while `API-51` tells the caller that re-issuing under a fresh key "is a
second purchase". A `NOT NULL` column with a default is safe at the schema and unsafe wherever the
default is a fake, as `payments.credited_tenant_id` would be. A `CHECK` an N−1 writer violates
takes the money-in path down for those replicas until the roll completes. And `ADR-0022`'s
"`operations.attempts` is renamed `operations.claim_number`" is not an expansion at all: `WIR-10`'s
view selects `attempts` on every operation read.

**A version skew can destroy a paid machine with no schema change.** `LDG-62` on `api` and `OPS-41`
on the engine compute `LDG-33` on the same machine row, and `LDG-33`'s `protected_sats` term is
itself a dated amendment. An `api` at N−1 accepts an extension sized by the old formula and writes a
future date; an engine at N re-derives by the new formula, gets a past date, sets the fence, and
`LDG-14` destroys the disk. `OPS-23`'s repeated validation does not reach it: the row is valid under
both formulas. The same shape reopens `OPS-42`'s window if a release moves the fence, doubles
`SEC-39`'s ceilings if two replicas bucket differently, and mints on replay if `payment_ref`'s
derivation changes.

## The decision

- **The migrator is the deployable's own `migrate` entry point, run as a deployment step before
  any component of release N starts, while the N−1 engine and `api` keep running.** Never by `api`,
  never by the engine at boot. `ADR-0001` is untouched: one binary, one more way to invoke it.
- **The runner holds its own transaction-scoped advisory lock on a fixed key distinct from
  `STO-51`'s**, across history inspection, application and the recording of completion, one
  migration per transaction so the recorded version never runs ahead of the DDL. That lock
  serializes runners and excludes nothing else, and `STO-13` says so in those words.
- **Every migration is safe against a running instance of the previous release of both
  components.** Concretely: no drop, rename or narrowing of a column, table or type; no `NOT NULL`
  column a previous-release writer does not populate, so such a column is nullable first and
  tightened after a backfill; no constraint a previous-release write can violate; and no write of an
  enumerated value the previous release does not recognize — the release that adds a value does not
  write it, the release after may. A removal, rename, tightening or `VALIDATE` is a **contract
  step** and ships no earlier than the release after the one that stopped depending on the thing
  removed. DDL that takes `ACCESS EXCLUSIVE` runs under a `lock_timeout` with a bounded retry, and
  index builds on the large tables are `CONCURRENTLY`.
- **A component refuses a schema older than it requires and serves a newer one.** The refusal exits
  non-zero before the listener or before any engine work, into the supervisor's restart and
  `OVR-18`'s alarm, which is the right outcome for an unmigrated store. The direction matters: a
  component refusing a *newer* schema would refuse the normal state of every roll and would make
  availability depend on process age.
- **Rollback is the previous binary against the current schema**, admissible up to and not past a
  contract step, which the rules above guarantee because it is the roll state in the other
  direction. Past a contract step there is no down-migration, `STO-13`'s forward-only stands, and
  recovery is `ADR-0023`'s restore. The set says this so a deployment does not invent a down script
  the day it needs one.
- **A change to a predicate or derivation both components evaluate on shared rows is not made
  safe by any of the above, and such a release stops everything.** The list is named in `STO-13`:
  `LDG-33`, `STO-3`'s guards, `OPS-42`/`LDG-62`'s fence guard, `STO-47`'s conditional write,
  `SEC-39`'s counter key, `LDG-35`'s serialization key, and every idempotency-key and
  `payment_ref` derivation. Such a release stops every component of the previous release before the
  first component of the new one starts, and its migration says so. This is candidate B, kept for
  the one class it is needed for and named as an outage rather than discovered as one.
- **`ADR-0022`'s rename is corrected to add, backfill, drop across two releases.** `claim_number`
  is added and backfilled from `attempts` in the release that stops reading `attempts` and drops
  the wire field; `attempts` is dropped in the release after.

## Considered options

**The engine runs migrations after the startup lock.** Rejected above: the lock does not cover the
migration's connection, the placement puts DDL inside the priced restart window, and a failed
migration crash-loops the safety layer.

**Stop everything, migrate, start everything.** The degenerate case, and the right one for the
shared-predicate class. Rejected as the general rule because it makes every schema change an outage
of the money-in path that `api` replicates specifically to avoid.

**A compatibility generation recorded in the store**, distinct from the migration number, which a
component checks at startup and refuses when unknown. One reader's proposal. Rejected as a
mechanism: a number cannot tell a component whether it understands a newly persisted value or a
changed formula, so the semantic class still needs the stop-everything rule, and with that rule in
place the directional version check does the rest.

**Online migrations with a dedicated tool and dual writes.** Machinery the set has no reason to
buy at v1's volume, and it does not resolve the semantic disagreement that makes a skew unsafe.

## Consequences

- `STO-13` is rewritten to carry the decision above: the entry point, the runner's lock and its
  scope, the safety rules against the previous release, the contract-step rule, the `lock_timeout`
  and `CONCURRENTLY` obligations, the directional version check, the rollback story, and the
  stop-everything class with its named list. `STO-12` gains the runner's serialization.
- `OPS-15` orders itself after the migration check. `OPS-23` states that a field a previous-release
  `api` may not have written is a deterministic failure in the worker, never a passed check.
- `OVR-9`'s `store` row keeps "Migrations" and names the entry point. `OVR-19` gains the migration
  `lock_timeout` and retry count; the runner's advisory key and `STO-51`'s are constants the
  implementation chooses, distinct by `STO-12`'s rule, and not register rows (*corrected
  2026-09-12: this consequence first put the key on the register*).
- `ADR-0022`'s decision bullet on the rename is amended as above.
- `CNF-57` gains the drill: apply release N's migrations with N−1 `api` and engine running and
  assert no refused write; start N−1 binaries against the N schema and assert they serve; run a
  mixed-version extension against a cancellation and a settlement replay across the pair; attempt a
  contract step in the same release as its expansion and assert the gate refuses it.
- `11-open-findings.md`: the §6.15 finding's third closure; pool sizing remains.
