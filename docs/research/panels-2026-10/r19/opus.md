## Threats

**The attacker spends almost nothing to deny others**

| id | story | attacker pays | victims lose | today? | sev |
|---|---|---|---|---|---|
| D2r | Loop `refresh` or reverse-DNS on one machine. Neither is on `SEC-39`'s ceiling list (07:208-211), neither opens a commitment (04:247), and the per-tenant limit is only a SHOULD (04:1154, 03:1533) | one hour of the cheapest machine, at list price plus margin | the project's 3600 requests/hour, so every tenant gets 429s. A throttled delete "settles `failed`" and waits for an operator retry (03:1066-1070), so machines the exhaustion sweep tried to delete keep billing the operator. An interrupted sweep "MUST record nothing about absence" (03:1295-1296), so customers keep paying for machines that are gone | yes | 1 |
| D4 | Abuse from a machine (scanning, spam, mining) leads to lock or termination of "the account" (08:177-181) | a few minutes of one machine | every tenant on that account | yes | 1 |
| D1 | Use up Robot's "20 requests per day" (02:876) | ≈0 if an order the provider rejects still counts against the limit [verify]: "the create fails deterministically" releases the commitment in full (12:299). Otherwise, a few seconds each of 20 auction servers | every Robot create on that account for a day. The operator pays ~20 auction-hours (≈€0.08/h, 08:378-380) | yes | 2 |
| R1 | A poll that gets throttled after the order was accepted is classified `failed`, because `rate_limited` "is on neither of `OPS-11`'s ambiguity lists" (03:1066, 03:227). The commitment is released while the server exists | needs Robot's GET limits to be throttled, e.g. via D2r [verify Robot's limits] | the server, plus a €59–1349 setup fee (08:141) | yes | 2 |

**The attacker spends money to hurt the operator**

| id | story | attacker pays | victims lose | today? | sev |
|---|---|---|---|---|---|
| M1 | Create a machine, then delete it immediately | (1+m)·t·p per cycle | U·p − (1+m)·t·p per cycle | caused by A (and true today) | 2 |
| D3 | Hold machines up to the provider's resource limit | list price plus margin | every create under that Hetzner *customer*, across all its projects | yes | 3 |

Enrolment slots and deposit minting are already defended (`API-33`, `API-41`, 04:865-879).

## Checks

- **Shortest billable life.**
  - The seed is "its row insert where the deployment bills from creation, or its later first entry into billable" (12:863-864), and the billable set is deployment-defined (12:470).
  - A delete queues behind the create and is re-claimed "with a short delay" (03:186-189), and a successful delete writes its own gone record (03:1026).
  - So t is anywhere from seconds to about a minute, depending on those deployment choices.
- **Ratio.** (U − (1+m)t)/((1+m)t) at m = 20% is 49 at 60 s and ≈300 at 10 s. It exceeds 1 only when t < U/(2(1+m)) = 25 min.
- **Capital.**
  - The commitment is at least the runway floor ("`wind_down_cost`'s duration", 02:287) × rate, plus `wind_down_cost`.
  - It is released on close (12:297), so it limits how many machines run at once, not how many cycles happen.
  - Only seconds actually consumed are revenue.
- **Rate.** `SEC-39`'s interval defaults to one hour, but its integers have no default (07:208-210). The ceiling is per principal, and Sybil tenants, each costing `API-35`'s minimum (which has no stated number), multiply it.
- **Provider facts verified against primary sources:**
  - Hetzner Cloud: "3600 requests per hour and per Project".
  - Hetzner Cloud: "Each customer has a default limit", raisable only after "a month and paid your first invoice".
  - Hetzner Cloud: "a few minutes … one whole hour".
  - DigitalOcean: "60 seconds or $0.01, whichever is higher".
- **Prices:** not checked. `server_types` answers 401 without a token, so I could not test them.

## Mitigations

Every per-principal control falls to Sybils, so each one needs a per-account backstop.

- **D2r.**
  - Add `refresh` and reverse-DNS to `SEC-39`'s list.
  - Per account, give `PRV-44` a `request_budget {limit, per}` beside `order_budget`, and have `OVR-19` state headroom reserved for system cancellations, the sweep and reconciliation.
- **D1.** `PRV-40` should:
  - state the budget per account (it says "the whole deployment" at 02:879, while the descriptor carries `account` at 02:59);
  - count rejected requests;
  - reserve slots for the operator;
  - give each tenant a daily share.

  Each extra share costs an attacker one `API-35` minimum, so the share size and that minimum are one decision.
- **R1.** In `OPS-11`'s create row, classify a `rate_limited` that arrives after the order was sent as `needs_reconciliation`.
- **D3.** Add a per-tenant ceiling on live machines; `SEC-39` counts per interval, not machines held at once.
- **D4.** `SEC-43`/`44`/`45` already own it. Under A, though, provisiond sells anonymous throwaway IPs at about 1/60 of Hetzner's own minimum.

## M1

A ceiling limits the rate, not the ratio. Only a minimum charge keeps the operator's loss below what the attacker pays. It holds only under these conditions:

1. **Clamp.** At the runway floor, the commitment is smaller than one unit whenever wind-down < U. `LDG-31`'s clamp then turns the minimum into an operator deficiency, which is A again, and the attacker can choose that path. So `PRV-13b` needs a `provider_minimum` term, even though r18 said A needs no unit term.
2. **Not grid-independent.**
   - On a wall-clock or month-boundary grid, a life shorter than one unit can cost two units, so the minimum only guarantees a ratio ≤ 1, not zero loss.
   - DigitalOcean's minimum is an amount of money, so it should be declared per offer, in money. That gives the unit a reader in `PRV-44`, which settles r18's "unit's home" question.
3. **Its own entry kind, at cost.**
   - Posted inside the closing increment, it breaks `Funding.lifecycle_coverage`'s "∀ t, Covered w.charged t ↔ Covered spans t" (Funding.lean:1535).
   - It also changes the four-second life pinned in `Witnesses.exit_closes_each_tail`: `[-1]` with 29 remaining (Witnesses.lean:2049-2050).
   - As its own fee entry at cost, it follows `ADR-0006`'s rule: "the operator does not profit from a fee it did not earn". Charged at the customer rate, it puts margin on time nobody used.
4. **`ADR-0011` (85-90).**
   - "Turns cadence into a pricing input" does not apply, because a provider unit is not a meter interval.
   - "Does not recover the tail lost across exit/re-entry" is avoided by applying the minimum per machine, never per span.
   - "Overcharges partial use" does not hold at cost: the customer pays exactly what the provider charged.
   - The same ADR says leaving the tail free "permits create-and-delete within an interval", which is this exploit one level down.
5. **Exits.** The attacker cannot steer into quarantine or an outage, and can reach provider termination only through D4. The clamp can be steered into (see 1).

**Verdict: charge a minimum per machine, at cost, as its own entry kind, reserved in `PRV-13b`. Without the reserve term it is just A.**

## Strongest "don't build"

- **M1.** Use A plus a default for `SEC-39`, a per-account alarm on rounding loss, terms of service and `SEC-45` suspension. Exposure is at most ceiling × tenants × U·p per hour. This fails if Sybils are cheap: each costs one `API-35` minimum, and an unspent balance is a liability, not revenue. So decide that minimum first.
- **D3.** A customer holding the whole quota is a sale. An alarm plus a limit-increase request covers it.
- **D1.** Twenty orders a day is a capacity fact. An alarm plus an operator reserve may be enough until there is real Robot demand.
- **D2r cannot wait.** It hits the operator's own deletes. Only a human retrying each stalled episode clears them, and the operator retry ceiling (07:233-241) caps even that.

## Defects in the framing

1. "SEC-41 … darkens every machine": those words are at 01-domain-model.md:324. `SEC-41` itself says "one abusive tenant can terminate every tenant" (07:177).
2. "past U/(1+m), where margin covers it" is false. For t between U and 2U the operator loses up to 0.8·U·p, and at 20% margin is only guaranteed to break even past 5U.
3. "t = 1 minute": the deployment's billable set decides t, and seconds are reachable.
4. D1's "about €1.60" is the operator's cost. The attacker pays seconds or nothing, and spends only one account's budget (02:59).
5. D2's "churn spends it": refresh drains the rate limit more cheaply and needs no create.
6. D3/D4: Hetzner applies the resource limit per customer and the rate limit per project, and its abuse terms reach the whole account. `SEC-43`'s accounts must therefore be separate customers, not projects (`SEC-44`).
7. "SEC-39 … no default": the interval has a default (one hour); only the integers lack one.

Gate: `check-all.sh` exit 0 at 40c00cb.
