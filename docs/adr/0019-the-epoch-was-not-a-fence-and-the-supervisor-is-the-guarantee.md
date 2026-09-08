# The epoch was not a fence, the supervisor is the guarantee, and the engine checks at boot that it is alone

**Status:** accepted (2026-09-08). Amends `ADR-0016`, which is otherwise untouched: the engine is
still one supervised process, `api` is still replicable, and the leases stay deleted.

## The problem as found

`ADR-0016` deleted the leases because, in its own words, "The promise was in prose and absent from
the predicate." The epoch that replaced them has the same defect.

`OPS-47` said "Every engine write to `operations` and `machines` MUST be guarded on `epoch = mine`
and MUST report whether it affected a row; a write that affects no row means the process has been
superseded and it MUST exit without further writes." The value compared is the process's own. The
column is written by exactly one thing — `05-persistence.md`'s `operations.epoch` was "stamped by
`STO-1`'s claim" — and only by the process doing the claiming. A worker checking that its row still
carries its own number is checking a value it wrote itself, so the term holds by construction.
`engine_epoch` is read once in the whole set, at the moment it is incremented, and compared to
nothing.

The term therefore could not fire. Of `STO-3`'s four conditional writes only the worker's carries
an epoch term, and the one that does the real work is the startup pass, which "moves every
`running` operation to `needs_reconciliation`, guarded on `(id, status = running)`". A stale
worker's write fails on the status term, set by the successor's sweep, and would fail identically
with no epoch in the schema at all.

So the guard caught a process whose operations the successor had already swept, and nothing else. A
process paused past a restart that then claimed a *fresh* queued operation stamped it with its own
stale value, called the provider, and wrote the outcome with every check passing. `ADR-0016`'s
central claim — "If two engines ever start by accident, the later one wins and the earlier one's
writes are refused — the guard is what makes "exactly one" a property the store checks rather than a
deployment promise" — was false under the stated predicate.

Two things compounded it. `OPS-47` mandated the guard on `machines` as well, and that table has no
such column, so every engine write to a machine row was unguarded, `OPS-42`'s cancellation fence
included. And `CNF-290`, which is BLOCKING, asked an implementer to "simulate the old process's
late write — a worker write to that operation and to its machine carrying the previous
`engine_epoch` — and assert each affects **no row**", which cannot be constructed against a table
with nowhere to carry the value.

## The decision

- **A second concurrent engine is out of scope, and the specification says so.** The supervisor is
  the guarantee. If a deployment ever runs two engines, this system has no defence, and the
  obligation to pick a supervisor that does not is the deployment's (`OVR-19`). This is a real
  narrowing and it is stated rather than implied: a supervisor guarantees it never *starts* two, and
  it cannot guarantee the first is *dead*, so a node cut off from its control plane while it still
  reaches the provider is a case nothing here defends against.
- **The epoch is deleted outright**, under `README.md`'s rule for withdrawn wording that recorded a
  fact which changed: the `engine_epoch` row, `operations.epoch`, `STO-3`'s `epoch = mine` term,
  `OPS-47`'s guard-and-exit sentence, and the argument for them. The `machines` guard that had no
  column is not written; the requirement demanding it is.
- **What was doing the work survives unchanged.** `OPS-15`'s startup pass, `STO-3`'s
  `status = running` term and `OPS-22`'s "log it loudly, leave the record alone, and exit" already
  handle a supervised restart end to end, which is the case that remains in scope.
- **The engine verifies at boot that it is alone** (`OPS-47`, `STO-51`). Before any claim it MUST
  take a session-scoped advisory lock on a connection outside the pool and hold it for its lifetime.
  Where the lock is refused it MUST retry for a stated bounded period and then exit non-zero having
  done no work; where the connection carrying it is lost it MUST exit. The bound and the keepalive
  settings on that connection are deployment parameters (`OVR-19`).
- **The lock is not a fence, and the requirement says so in those words.** No write is guarded on
  it, holding it proves nothing about the past, and losing it invalidates nothing already written.
  It answers one question, once, at boot: is somebody else already here. Naming the limit is what
  keeps it from growing back into the thing this ADR deletes, which is how the leases got their
  second life.

## Why a bounded wait rather than an immediate exit

`ADR-0016` priced the restart window as the accepted outage and alarmed it (`OVR-18`). A session
advisory lock survives its holder when the holder dies without closing the connection, so an
immediate exit on refusal would couple restart time to however long the database takes to reap a
half-open session, turning a seconds-long restart into a minutes-long one and attacking the premise
the single-writer design rests on. The bound absorbs that; the keepalive requirement is the actual
cure rather than a workaround for it; and exhausting the bound exits non-zero into the supervisor's
own retry, where `OVR-18`'s alarm is already watching.

## Considered options

**Fix the predicate — guard the claim itself on `engine_epoch = mine`.** One additional term on one
statement, at the only point a superseded process re-enters the system; everything it already holds
is caught by the existing sweep. Correct, and cheap. Rejected because it buys a defence for the case
this ADR puts out of scope, and keeps a column, a counter and a guard term alive to do it.

**Keep the epoch as a cheap tripwire.** Rejected because it cannot fire: the status term fails
first in every path the worker algorithm takes, so a refused write would never be the thing that
told you.

**Refuse to start with no bound.** Rejected above.

**Warn on a held lock and start anyway.** Keeps the detection without the restart hazard, but two
engines then run, and a warning nobody has wired to an alarm is decoration.

## Consequences

- `CNF-290` loses the half that could not be built and gains the one that can: a second engine
  started against the same store refuses to run and exits non-zero. The restart half and the
  per-machine index half are unchanged.
- `OVR-19` gains the startup-lock bound and the lock connection's keepalive settings.
- `STO-6`'s list of primitives the store provides for `api` replication no longer names an epoch.
- `CONTEXT.md` carries `epoch` as withdrawn vocabulary, the way it carries `requeue`.
- `F40` closed by removing the second writer; this amends how that closure is enforced, not whether
  it holds. The lease defect it recorded stays closed, because the mechanism that reintroduced its
  shape is gone rather than repaired.
- The set now states a limit it did not state before. That is the point: an implementer who reads
  `OPS-47` learns what is not defended instead of reading a guarantee and stopping.
