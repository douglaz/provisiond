# Tenant traffic cannot spend the provider request budget the system needs

**Status:** accepted (2026-10-06, owner decision Q3 of the provider-research grill).

## Context

Hetzner Cloud allows each project a bucket of requests: "The default limit is 3600 requests per
hour and per Project", refilling one per second (Cloud API reference, "Rate Limiting"). Every
tenant on a provider account spends from that one bucket, and so does the system's own work.

The second threat-model panel (2026-10-06, `docs/research/panels-2026-10/r19/`) found a cheap way to
empty it. A tenant with one machine loops `refresh`. Refresh opens no commitment; `04-api-contract.md`
says of it and its siblings "they are not purchases, and they pass no spending gate". It is on no
`SEC-39` ceiling, and `API-29` says only that "The service SHOULD rate-limit per tenant". `OPS-8`
lets one operation hold a machine at a time, so one machine's loop runs about one read a second,
which is the whole bucket.

The harm lands on the operator's money. A throttle refusing a delete before acceptance is
`failed` (`OPS-48`: "A throttle refusing the mutation before acceptance is `failed` and stalls the
episode"); `OPS-48` also says "Neither returns the attempt to `queued`". An exhaustion delete
can therefore leave an episode for an operator while its machine bills the operator. The account
sweep cannot record an absence while throttled either. Retrying throttles on a timer was rejected
in `F48` ("every operation is several requests") and stays rejected.

*Context qualified 2026-10-08 (`ADR-0035`): `OPS-48` owns the accepted-mutation case as well as
the pre-acceptance case quoted above.*

The machine record is already a cache with its age. `DOM-8`: "A reader MUST take the staleness
bound from `state_observed_at` rather than from the fact of a caller having asked." Nothing let a
refresh be answered from it.

## Decision

1. **A refresh is answered from the cache inside a freshness window.** A refresh of a machine whose
   `state_observed_at` falls within the deployment's stated freshness window (`OVR-19`) settles
   without a provider call. At most one provider read per machine per window then reaches the
   provider, however fast a caller loops.
2. **Reverse-DNS is ceilinged.** It joins `SEC-39`'s per-principal ceilings. A write of the value
   the record already holds settles without a provider call.
3. **The provider's request limit is a declared budget with a reserve the system owns.**
   - Each driver declares its provider's request limit in the descriptor (`PRV-44`) beside
     `order_budget`, per credential scope (Hetzner Cloud: the project).
   - The deployment spends it before any provider call, as `PRV-40` already spends the order
     budget, and may lower it but never raise it.
   - A stated share of it is reserved (`OVR-19`) for the system's exposure-reducing and evidence
     paths: funding cancellations and other system-detected episodes (`OPS-39`, which is "never
     blocked by a caller's ceiling"), automatic resolution (`OPS-27`), and the account sweep
     (`OPS-32`).
   - A tenant-initiated operation is refused deterministically, before its first provider call,
     once only the reserve remains.
   - **Admission is decided once per operation, before its first provider call.** A later request
     of an admitted operation is never refused locally, or the budget would recreate the throttled
     poll after an accepted order that the same panel found.

## Considered and rejected

- **A per-principal ceiling on `refresh` alone.** It bounds one tenant, and another tenant costs
  little.
- **Retry a throttled delete on a timer.** Rejected in `F48` and not reopened. A re-run can place a
  second order, and the eligibility it needs is a fact only the driver has.
- **Per-tenant shares of the request budget.** Fresh tenants defeat shares. The reserve protects
  what costs the operator money no matter how many tenants exist.

## Consequences

- Draining the bucket now needs many paid machines, not one. At a sixty-second window that is about
  sixty, at roughly $0.60 to $2 an hour for the cheapest Cloud type in this account's currency.
  Draining the tenant share denies tenants one another's operations. That residual is accepted,
  priced to the attacker, and alarmed on exhaustion. It never reaches the system's own deletes.
- A refresh can return state up to one window old. The caller already reads its age from
  `state_observed_at`.
- Edits owed: `PRV-44` (the declaration), `PRV-40` (generalised from orders to requests, or a
  sibling requirement), `OVR-19` (the window, the reserve and the budget rows), `SEC-39`
  (reverse-DNS), `OPS-11`'s refresh and reverse-DNS rows (a cache-answered settlement), conformance
  items, and `Provisiond.Admission`'s ceiling map, which today gives `refresh` and `reverseDns` none.
- Not covered here: a throttle that reaches an admitted operation after its mutating request was
  sent (the throttled-poll defect), Robot's per-endpoint limits beyond orders, and the provider
  quota (D3).

## Amendment — 2026-10-08: the per-machine bound covers successful observations (owner decision Q10)

An rloop Manager blocked `pv-ucs.2` on a gap in Decision 1, and a four-reader panel
(`docs/research/panels-2026-10/r26/`, unanimous) settled it. `OPS-11`'s refresh row is "Always
`failed`. It is read-only; a failure changed nothing", and `state_observed_at` records only an
authoritative read. So a refresh whose provider read fails leaves the cache stale, and the next
refresh reads again.

- **The bound counts successful observations only.** A machine whose provider answers costs at most
  one read per window. A read that fails moves nothing, and the next refresh reads again, one at a
  time under `OPS-8`, from the tenant share. Decision 1's "however fast a caller loops" and the
  Consequences' "needs many paid machines, not one" hold while the provider answers. During a
  provider read failure the residual is one paid machine's refresh loop against the tenant share,
  never the reserve. It is accepted, as tenant-share exhaustion already is.
- **The cache check runs when a worker claims the refresh, not when it is enqueued.** Otherwise
  refreshes queued against a stale machine each read in turn.
- **The machine view exposes `state_observed_at`.** The Consequences' "The caller already reads its
  age from `state_observed_at`" was false: `WIR-11` carried no such field.

Rejected: counting failed attempts and answering from the cache (it reports success after a refresh
that learned nothing, and needs a new timestamp because no dispatch time is recorded); counting them
and refusing the refresh (a legitimate retry after one provider error waits a whole window).
