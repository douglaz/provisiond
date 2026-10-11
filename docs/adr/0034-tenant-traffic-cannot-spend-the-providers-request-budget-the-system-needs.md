# Tenant traffic cannot spend the provider request budget the system needs

**Status:** accepted (2026-10-06, owner decision Q3 of the provider-research grill); amended 2026-10-08 (Q10), 2026-10-10 (Q19, Q20) and 2026-10-11 (Q20b).

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
episode"); `OPS-48` also says "Neither case returns the attempt to `queued`". An exhaustion delete
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
   - The deployment spends it before any provider call and may lower it but never raise it.
     *Corrected 2026-10-10 (`ADR-0036`): the earlier comparison to `PRV-40`'s order budget
     was stale; `PRV-40` says its declaration "MUST NOT be used as a locally counted
     substitute for Robot's accounting". This request-budget policy remains separate.*
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

## Amendment — 2026-10-10: Decision 3 is deferred until a shared-bucket offer is sold (owner decision Q19)

An rloop Manager blocked `pv-ucs.2` on three questions about Decision 3: whether an admitted operation's
later requests may spend the system reserve, whether operator traffic may, and how a refusal appears. A
four-reader panel (`docs/research/panels-2026-10/r36/`) found the decision protects a bucket v1 does not
use, with a count that cannot see it.

- **v1 sells only Robot (`ADR-0039`).** No v1 tenant operation reaches Hetzner Cloud's per-project bucket,
  and `PRV-44`'s `{scope, limit, per}` cannot express Robot's per-endpoint limits.
- **A local count cannot hold a reserve.** The operator's console and CLI spend the same bucket, and
  `ADR-0036` already rejected this shape for Robot orders: "A local count can drift from it in both
  directions, while a gate closed by the provider's own answer cannot." The Consequences' "It never
  reaches the system's own deletes" is withdrawn; it was false under every reading.
- **Decision 3 is deferred** until an offer that shares a provider request bucket is sellable again.
  Decisions 1 and 2 and the Q10 amendment stand. Re-admitting such an offer requires, from the panel's
  answers:
  - new admissions gated on the provider's own reported remaining count (Cloud's
    `RateLimit-Remaining`), not a local count; continuations of admitted operations dispatch, and the
    residual is stated;
  - eligibility by path, not by actor: exposure-reducing and evidence work (deletes, cancellations,
    `API-64`'s episode retries, `API-65`'s releases, `OPS-27`'s resolution, `OPS-32`'s sweep) is never
    refused by the budget, whoever requested it; `requested_by` stays an audit stamp and `SEC-39`'s
    operator ceilings stay;
  - a refusal decided at worker claim, after the cache check: `202`, then `failed` with `rate_limited`,
    `retry_after_ms` and `retryable: true`, no provider call, and a create's commitment released, as
    `PRV-40`'s claim-time refusal does. No synchronous `429`.

Rejected: building the reserve for v1; continuations that wait for tenant capacity; securing a whole
operation's requests at admission (polling has no bound: `OPS-33` "adds no timeout on an in-progress
order"); eligibility by actor.

## Amendment — 2026-10-10: Robot's server reads are spared by the account sweep (owner decision Q20)

The same panel found the v1 gap this ADR listed as "Not covered here: … Robot's per-endpoint limits beyond
orders". Robot's webservice reference (retrieved 2026-10-10) gives `GET /server` and
`GET /server/{server-number}` "200 requests per 1 hour". At a sixty-second window one machine's refresh
loop can cost sixty reads an hour, and `OPS-32`'s direct re-read and `OPS-27`'s confirming read use the
same endpoint. A second panel (`docs/research/panels-2026-10/r37/`) settled it. The reference does not
say whether a limit counts per webservice user, per account or per source IP, nor whether different
servers share a counter; four looping machines exhaust it only if they share one.

- **The refresh freshness window is no shorter than the account-sweep interval** (`DOM-8`, `OVR-19`;
  startup refuses a shorter one). A refresh inside a running sweep is answered by the sweep's
  observation, at no provider call whatever the fleet size. Decision 1's one read per machine per window
  remains the fallback when the sweep falls behind.
- **A complete sweep pass records every machine it observed present** (`OPS-32`), as `DOM-8` already
  says it "MUST write what it saw". An absence still needs the direct re-read, and a failed read never
  advances freshness.
- On Robot this costs no information: the account list carries the status the single read carries
  ("ready" or "in process"), and neither carries a power state.
- `08-provider-notes.md` records Robot's per-endpoint limits, and the live test settles each limit's
  counting scope.

Rejected: a per-driver window sized to the limit (it must grow with the fleet); refresh reading the
account list on its own path (it works, but adds a path the sweep already provides); closing tenant reads
on Robot's `403` as the primary control (it protects nothing in the first throttled interval).

## Amendment — 2026-10-11: Robot's reset limit is accepted for v1 and alarmed (owner decision Q20b)

Robot's `POST /reset/{server-number}` allows "50 requests per hour". A power cycle spends one, and a rescue
entry and its exit spend one each ("an out-of-band hard reset to enter it. Exiting is disable-rescue plus
another hard reset", `08-provider-notes.md`). No system path resets. If the limit counts per account,
tenants' resets can leave another tenant's install unable to leave rescue until the interval passes, an
exit `PRV-22` already treats as ambiguous. The harm is delay between tenants, with no operator money at
stake. Each attacker needs a paid machine, and `SEC-39` caps each principal's rescue entries and power
cycles.

- **Accepted for v1.** A throttled rescue exit raises an alarm naming the account. The live test settles
  whether the limit counts per account or per server, and this is revisited if it counts per account.
- The live test also checks whether Robot accepts a cancellation with `reserve_location=false` without
  first reading `GET /server/{server-number}/cancellation`, which would take that read off the delete
  path.

Rejected: a local admission cap on reset-producing operations that holds room for outstanding exits (a
local count, for a harm that may not exist).
