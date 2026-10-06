# The Robot order budget is closed by the provider's throttle and not shared out

**Status:** accepted (2026-10-06, owner decision Q5 of the provider-research grill).

## Context

Hetzner Robot limits each of its three order endpoints (`server`, `server_market`, `server_addon`)
to "20 requests per day" (Robot webservice reference). When the limit is reached it answers
`403 RATE_LIMIT_EXCEEDED` with `max_request` and `interval`. The reference does not say whether the
limit is per account, per webservice user or per address. It does not say whether the day rolls or
resets by the calendar, or whether rejected and `test=true` requests count. `PRV-40` made the limit a
capacity bound, but counted only two endpoints, called it both deployment-wide and per ordering
account, and gave its refusal no kind on `OPS-11`'s admission-only list.

The threat-model panel (`/var/tmp/provisiond-panel-r19/`, D1) asked whether one tenant could exhaust
it. A fourth panel (`/var/tmp/provisiond-panel-r21/`, four readers, unanimous) answered.

- **Nobody loses money at exhaustion.** A refused create settles `failed` and releases its
  commitment. An attacker buys every accepted order's first unit at the customer rate (`ADR-0033`).
  The harm is lost auction sales, at most twenty a day per account and channel, and twenty-one honest
  agents reach the same wall.
- **The attack may cost nothing.** The limit counts requests, not orders. A rejected order costs the
  tenant nothing under `LDG-39`'s "Deterministic rejection before acceptance" row, and `ADR-0035`
  already calls refused orders "free to an attacker". Tenants could provoke rejections. `API-13`
  bounds an offer identifier only by length. A driver option reaches the provider with no rule that
  it be validated first. Several creates could race for one auction offer, which is one physical
  machine.
- **One attacker cannot reach every tenant.** `API-57` says "A tenant MUST be assigned at least one
  provider account", and `SEC-43` already calls for several. An attacker drains only the accounts
  assigned to it.

## Decision

1. **The budget is not shared out per tenant, and no order carries a price of its own.** It is
   closed by the provider's throttle: after Robot answers `403 RATE_LIMIT_EXCEEDED` on an account and
   channel, the deployment refuses creates there for the `interval` Robot reported, before any
   provider call. The refusal is `rate_limited` with `retry_after_ms`, and it joins `OPS-11`'s
   admission-only list. Exhaustion raises an alarm. The declared limit stays in the descriptor as
   documentation and as the alarm threshold. `order_budget` moves onto each ordering channel, since
   one value cannot describe three endpoints.
2. **Free burns are closed where they start.**
   - The driver validates everything it forwards before it sends the order request.
   - At most one create is in flight per offer that is itself the resource (`PRV-42`).
   - The driver confirms the offer is still listed before ordering.
3. **`API-35`'s funding minimum goes on `OVR-19`'s register.** It is the price of a tenant.
4. **A live test settles what the reference does not.** On the auction endpoint, twenty invalid
   requests and then a `test=true` one. On the standard endpoint, twenty test requests and then one
   more. Then keep sending after the first `403`. It costs one day of ordering on one account.

## Considered and rejected

- **A per-tenant daily share.** `ADR-0034` rejected this shape for the request budget: "Per-tenant
  shares of the request budget. Fresh tenants defeat shares." A fresh tenant's deposit is spent on the
  attack's own orders (`ADR-0004`), so it is an entry price and not a running cost.
- **A local count of the budget.** Nobody knows what Robot counts. A local count can drift from it
  in both directions, while a gate closed by the provider's own answer cannot.
- **Prepaying more units on budget-limited offers.** It is the one shape that raises the attacker's
  running cost. `ADR-0033` escapes `ADR-0011`'s objection ("overcharges partial use") only because
  the provider charges the unit. An operator-chosen minimum is the charge `ADR-0011` rejected, and a
  second price surface besides. It is recorded as the upgrade path if the alarm shows a real attack.
- **Pacing the budget hourly.** It changes when slots are taken, not what they cost, and it delays an
  honest order for several servers.

## Consequences

- Accepted residual: a funded attacker can deny auction orders on the accounts assigned to it, at
  most twenty a day per account and channel. It pays the customer rate for every order Robot accepts,
  and less if rejected requests count before the free burns are closed. More ordering accounts
  (`SEC-43`) are how an operator scales out of it.
- Edits owed: `PRV-40` (facts, the gate, the refusal, the alarm), `PRV-44` (`order_budget` per
  ordering channel), `PRV-42` (one create in flight per offer), the driver's validation before the
  order request, `OPS-11`'s admission-only list and `API-7`'s tail, `OVR-19` (the channel rows and
  `API-35`'s minimum), `CNF-283`, `08-provider-notes.md`, and `Provisiond.Admission`'s tail refusals
  if the kind enters there.
