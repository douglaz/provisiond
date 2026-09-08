# The engine is one supervised process, fenced by an epoch, and the leases go

**Status:** accepted (2026-09-07). Amends `ADR-0015`'s consequence "the deployable becomes
replicable": `api` is replicable, `engine` is not.

`STO-3` guarded every worker write on `(id, status = running, claimant = me)`. `OPS-3` and
`OPS-22` both say a worker's write "MUST be conditional on that worker still holding the lease" and
both delegate to `STO-3`, whose predicate never reads `lease_expires_at`. A worker whose lease had
expired but which `OPS-14`'s sweeper had not yet reached wrote a terminal state that landed; a second
operation could take the machine lock under `OPS-9` the instant the first's lease expired, while the
first's stale write still passed. The promise was in prose and absent from the predicate.

The fix on the table was a fencing token — `attempt` reused as a generation, plus a database-time
expiry term on every worker write and every renewal. It would have worked. **We chose instead to
remove the condition that made a token necessary: more than one writer process.**

## The decision

- **`engine` runs as exactly one supervised process.** The supervisor is the deployment's —
  systemd, a scheduler with `replicas: 1` and a recreate strategy, anything that restarts a dead
  process and never runs two. The store stays PostgreSQL; nothing in `ADR-0015`'s choice of engine
  changes.
- **`api` stays freely replicable.** Every write it makes is a short transaction under `LDG-35`'s
  per-tenant advisory lock, and none of its background components (`OVR-17`) touches a provider.
- **One fence, per process lifetime.** At startup the engine increments a single `engine_epoch`
  row and holds the value; every engine write to `operations` and `machines` is guarded on
  `epoch = mine`. A process that was paused, partitioned or superseded fails its next write and
  MUST exit. If two engines ever start by accident, the later one wins and the earlier one's writes
  are refused — the guard is what makes "exactly one" a property the store checks rather than a
  deployment promise. (`OPS-47`, `STO-51`)
- **Startup is the sweep.** `OPS-15` already runs the sweeper at startup. With one writer, every
  `running` row found at startup is by definition an interrupted operation whose provider call is
  uncertain, and it goes to `needs_reconciliation` — the same answer the lease sweeper gave, reached
  without a deadline. The one exception the sweeper carried survives unchanged: a `suspend_tenant`
  parent found `running` returns to `queued` and resumes its fan-out, because it is a parent whose
  children carry the uncertainty (`OPS-11`, `OPS-15`).
- **Per-machine serialization is a store rule, not a lock table.** At most one `running` operation
  per machine, enforced by the store (a partial unique index). The queue itself stays durable in
  Postgres and `STO-1`'s atomic claim stays, minus the lease expiry it used to stamp. *An in-process
  actor per machine is one way an implementation may schedule against that rule; it is not required
  and the rule does not depend on it.*
- **Deleted, not amended**: the lease deadline and heartbeat (`OPS-7`, `OPS-10`), the lease sweep
  (`OPS-14`, `OPS-17`), the machine lock and its takeover (`OPS-9`, `STO-2`), the `machine_locks`
  table, `operations.lease_expires_at`, and the `claimant = me` term of `STO-3`'s guard, which the
  epoch term replaces. Withdrawn text that recorded a fact which changed is deleted outright under
  `README.md`'s convention; the trap the leases were laid against is recorded here instead.

## Why this beats the fencing token

Any design with more than one writer process needs every write fenced by an ownership token —
that is a property of pausable processes, not of this specification, and per-machine actors would
only have moved the token from the operation to the machine's ownership. A token per operation
means a heartbeat cadence, a lease duration, a sweep interval tied to it, an equality-at-expiry rule,
and a renewal of two rows in one transaction, all of which have to agree and all of which the
2026-09-07 review found either absent or unstated. A token per process lifetime is one column, one
value read at startup, and one `WHERE` term. There is nothing left to disagree.

## What `ADR-0015` weighed and what it did not

`ADR-0015` rejected the single-writer engine because "every mechanism that stops a machine billing
is inside this process", so a process outage is an outage of the safety layer. That is still true,
and this ADR accepts it, because the argument did not weigh the restart window. A supervised
process restarts in seconds and a rescheduled container in about a minute; `LDG-14`'s exhaustion
cancellation arriving a minute late costs cents. What the argument was actually afraid of is a dead
engine nobody notices for hours, and that is a monitoring obligation: **the engine's liveness MUST
be alarmed** (`OVR-18`). The restart window is the accepted outage, and it is named here so nobody
re-derives replicas as the fix for it.

`ADR-0015`'s other reasons stand untouched: `LDG-35`'s serialization is still discharged by
advisory locks, because `api` is the module that opens commitments and `api` is replicated.

## Considered options

**Keep the leases and add the token** (`attempt` as generation, database-time expiry on every worker
write and renewal). Correct, and the smaller diff to the text. Rejected because it keeps five
requirements' worth of timing machinery alive to defend a second engine replica that this ADR
concludes is not worth its cost.

**Per-machine actors as the serialization, in place of a store rule.** Rejected as a *requirement*
because the specification is language-neutral and because the queue is durable in Postgres anyway;
an implementation may still use them.

**Leader election among several engines** via a session-level advisory lock. Rejected because a
leader whose session drops while its connection pool lives on is the stale writer again, which puts
the per-write token straight back.

## Consequences

- `OPS-32`'s account sweep, `LDG-14`'s exhaustion cancellation and every other `engine`-owned
  periodic component (`OVR-17`) run on the one engine and need no lease of their own. The
  multi-replica sweep concern the 2026-09-07 review raised does not arise.
- `CNF-290` is the restart drill that replaces any takeover drill: kill the engine between dispatch
  and reply, restart it, and assert the interrupted operation is `needs_reconciliation`, that the
  old process's late write is refused by the epoch, and that the store refuses a second `running`
  operation on a machine that has one.
- The deployment's operational surface gains one item: the engine's liveness alarm and the
  supervisor's restart guarantee are deployment parameters and belong in whichever register the
  2026-09-07 session settles on.
- `README.md`'s "Language and runtime" paragraph, which says a store "that forbids a second replica"
  is disallowed, now reads against `api`; the engine was never the thing that paragraph protected.
