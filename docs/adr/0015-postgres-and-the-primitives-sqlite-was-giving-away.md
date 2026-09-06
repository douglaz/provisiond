# PostgreSQL is the store, and it makes explicit three primitives SQLite was giving away

**Status:** accepted (2026-09-06)

`05-persistence.md` described the store abstractly and named an embedded single-writer engine
(SQLite) as what the reference implementation used. **The store is now PostgreSQL.** This is the
first technology choice in the set with lock-in, and it is recorded here because `STO-6` already
said the choice "MUST be accepted deliberately" and nobody had accepted it.

## Why: the single point of failure is a *money* mechanism, not an availability nicety

`STO-6`: "With an embedded single-writer store, the service is a single point of failure and MUST
NOT be run as multiple replicas against a shared file."

A machine at a provider keeps running and keeps billing whether or not this process is up. **Every
mechanism that stops that is inside this process**: `LDG-14`'s exhaustion cancellation when a
runway is spent, `SEC-45`'s one-action tenant suspension, `OPS-14`'s lease sweeper, and `OPS-32`'s
account sweep — which `OPS-32` itself calls "the maximum time a customer can be billed for a machine
that no longer exists". An engine that forbids a second replica converts every process outage into
an outage of the whole safety layer, while the meter's subject goes on costing the operator money.

That is a different argument from "we would like high availability", and it is the one that
settles it.

## Why PostgreSQL specifically: `LDG-35` names what it needs and Postgres has it

`LDG-35` requires the authorization read and the commitment write to be serialized per tenant, and
is explicit that the failure it prevents "commits without error under both READ COMMITTED and
SNAPSHOT isolation". It then says a deployment "MUST use a per-tenant lock, a serializable
transaction, or a conditional write against a versioned balance row, **and MUST state which**."

**Nobody ever stated which, because on a single-writer engine the requirement was satisfied by
accident** — the engine's global write lock serializes everything, so the primitive existed without
anyone choosing it. Moving to a server engine is what forces the statement, and this ADR is it:

- **Per-tenant advisory locks**, taken for the duration of the transaction, acquired in **ascending
  tenant-identifier order** where a transaction spans two tenants — which `LDG-35`'s 2026-08-31
  amendment already requires for `WIR-42`'s cross-tenant attribution pair.
- `SERIALIZABLE` remains available as the belt-and-braces option because Postgres's SSI genuinely
  detects the write skew `LDG-35` describes, rather than merely documenting an isolation level.
- `STO-1`'s atomic claim and `STO-2`'s conditional lock upsert are `SELECT … FOR UPDATE SKIP LOCKED`
  and `INSERT … ON CONFLICT DO UPDATE` with the guard in the `WHERE` clause — both engine-checked,
  which is what `STO-1` demands when it says the guard must be "checked by the engine, not by
  application code".

## Considered options

**Keep SQLite.** Simplest to operate, no network hop, and the whole specification already works on
it. Rejected for the reason above, and for a second: a requirement satisfied by accident is exactly
the class of dependency this set keeps discovering it had — `LDG-35`'s primitive, `STO-27`, and the
change-feed note below are three instances of the same shape.

**A different server engine.** The specific reasons above are Postgres features. `SKIP LOCKED`
exists in MySQL 8 too; SSI that actually aborts on write skew is the discriminator, and `LDG-35`
is written against precisely that hazard.

## Consequences

- **The deferred change-feed hazard becomes live.** `05-persistence.md` records that on a
  single-writer engine "commit order and allocation order coincide because there is one writer; on
  a server engine they **decouple**, and a `since=seq` reader then silently skips changes that
  committed after a higher sequence was already read." That was a note about a feed nobody had
  built. It is now a property of the chosen engine, and **any feed built later owes a cursor that is
  correct under out-of-order commit** — a gap-aware or snapshot-aware cursor, not a bare sequence.
  Recorded rather than solved, because no feed exists.
- **`STO-7` keeps its rule and changes its examples.** Connection-scoped settings must still be
  applied to every pooled connection rather than once at migration time (`DEF-12`), but the settings
  are no longer SQLite pragmas — they are `statement_timeout`, `lock_timeout`, `idle_in_transaction_session_timeout`,
  the isolation level and `search_path`. The defect it guards against is identical and the
  configuration surface is entirely different.
- **`ADR-0001` is untouched.** One deployable plus a database is still one deployable; what changes
  is that the deployable becomes replicable. The two-service split `ADR-0001` rejected — a
  customer-facing service in front of a credential-holding engine — is not reintroduced.
- **Contention moves from free to real.** On the old engine `LDG-35`'s serialization cost nothing to
  reason about because everything was serialized anyway. On Postgres the meter's per-tenant lock is
  a live contention point, and `LDG-38`'s cadence is what determines how hot it gets. `DEF-11` is
  the standing warning: two write transactions per second were enough to starve the reference store.
- **New operational surface the set does not yet specify**: backup and point-in-time recovery,
  connection pool sizing, migrations against a live database, and the failure mode where the store
  is reachable but slow. None of these existed when the store was a file.
- **`STO-6` is rewritten rather than deleted.** Its argument is the reason for this decision, and a
  future reader needs to find it where the requirement lives.
