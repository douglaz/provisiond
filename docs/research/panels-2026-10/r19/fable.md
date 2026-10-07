## Threat table (ranked by victim cost ÷ attacker cost)

| id | story | attacker cost | victim cost | today? | severity |
|---|---|---|---|---|---|
| **T1** *(missed)* | Induce 429s; own create is throttled after the order landed → `failed`, commitment released, server alive with attacker's key | ≈0 | full machine price until a complete sweep pass, which yields to the same throttle | yes, `[verify driver]` | high |
| **D2′** *(missed)* | Loop `refresh`/reverse-DNS on one cheap machine; drains the Project's bucket | one cheapest machine-hour | every tenant's operations; exhaustion deletes go `stalled` for an operator | yes | high |
| **M1** | create→delete churn | `(1+m)·t·p`, ≥1 sat | `p·(U−(1+m)t)`: 49× at 60 s, 299× at 10 s | A only | high |
| **D1** | 20 Robot orders | cents under A; ~20 unit-hours with a first-unit charge | a day of Robot sales in that ordering account | yes | high (Robot) |
| **D5** *(missed)* | Free long installs occupy every engine worker | N cheap machines | whole queue, including exhaustion deletes | yes, `[verify hold]` | medium |
| **D3** | Hold machines to the account limit | list + margin (operator profits) | others' creates `failed`; no money lost | yes | medium |
| **D4** | Churn draws provider action | unknown | the account | yes | low probability, total |
| **M2** | Live `U+ε` | `(1+m)·U·p` | `≤(1−m)·U·p`, 0.67× | A and minimum | low |

## Verification

- **M1 arithmetic** holds at 60 s (58.8 ÷ 1.2 = 49), but 60 s is not the floor. `LDG-37` names only `stopped` and `cancellation_scheduled` billable (12:471-476); the seed is "the first write that records it billable" (12:862) and the exit is "that transition's recorded instant" (12:879). Billable life is seconds, bounded only by `ceil` to 1 sat per fresh subject (12:639).
- **Attacker capital.** One `PRV-13b` reserve per concurrent machine (02:176-182), "released in full" at close (12:297). It bounds concurrency (`available ≥ required_commitment`, 12:221), not cycles; sequential churn needs one. The real cost is the non-refundable deposit, all of it convertible to damage at the ratio.
- **D2 quote** is exact, and the consequence is worse than drafted: "a throttled delete is `failed` … nothing in this set returns it to `queued`" (03:1065-1069). The sweep "MUST yield to `rate_limited`" (03:1357) and "Only a pass that enumerated the account completely may record an absence" (03:1292), so `LDG-74`'s error bound (12:536-539) loses its backstop.
- **D3 quote** is exact. A 403 is deterministic, so commitments release.
- **Prices** I could not confirm: `GET /v1/server_types` answers 401 "token is required" and the public pages render prices client-side.

## Missed threats

- **T1.** `rate_limited` is not on `OPS-11`'s ambiguity list (03:251-258), and `F48` concedes "A 429 says one request was not processed; every operation is several requests" (11:139). Nothing obliges a driver to treat a post-acceptance throttle as ambiguous.
- **D2′.** `04:247` says "power, install, reverse-DNS, refresh, rescue inventory … **No commitment**: they are not purchases, and they pass no spending gate". Refresh and reverse-DNS are absent from `SEC-39`'s list (07:211-214), and per-tenant limiting is SHOULD (04:1154, 03:1532-1534). Churn is the expensive way to do D2.
- **D5.** Worker count is a stated integer (05:158-160) and fairness is SHOULD.
- **Sybil price is unregistered.** Every per-principal ceiling multiplies by tenants. A tenant costs `API-35`'s "configured minimum" (04:457-458), which is absent from `OVR-19`'s register (00:350-400).
- **Already defended.**
  - Enrolment: `API-33`'s admission token, and `API-41`'s "MUST be a shedding threshold".
  - Deposit watch set: "bounded by *mint rate × expiry window*" (12:1500).
  - Dust: credited "at its received value" (12:1561), about 1×.

## Mitigations

- **M1: charge the first provider unit when the order lands.**
  - `PRV-44`: per-offer declaration `{seconds, native_floor}`. `PRV-13c` already calls "billing granularity" a per-contract fact (02:396).
  - `PRV-13b`: a reserve term beside the setup fee.
  - `PRV-13d`: floor ≥ the unit.
  - `LDG-39`: the same lifecycle table as the setup fee.
  - `LDG-38`: the machine's first entry into billable is the unit's end. 12:863 already admits "its later first entry into billable".
  - Disclosure beside `setup_fee_sats` (01:154), plus an `ADR-0007` consequence.
  - Lean: the four declarations stand, since coverage is "intervals … not satoshis" (Funding.lean:1569). It needs a new declaration; I have not written or proved one.
  - Scope: per offer.
- **T1: `PRV-5`, one sentence.** A throttle after the operation's mutating request was sent is `PRV-11`'s ambiguous shape, never `rate_limited`. This is the half of `F48`'s kept design that needs no measurement.
- **D2 and D2′.**
  - `SEC-39`: every provider-calling kind gets a ceiling (per tenant).
  - `PRV-40`/`PRV-44`: declare the request limit with its scope and spend it "before any provider call", with a stated reserve for `OPS-39` cancellations, `OPS-27` resolution and `OPS-32` (per provider credential scope).
- **D1.** `SEC-39` gets a per-principal share of `order_budget`, counted over `PRV-40`'s `per`, on `OVR-19`. Add `API-35`'s minimum to the register. Scope: per ordering account.
- **D3, D4, D5: no mechanism.**
  - D3: alarm on `resource_limit_exceeded`, raise the limit, and rely on `SEC-43`.
  - D4: goes on `SEC-41`'s recorded-risk list.
  - D5: `OPS-24` SHOULD→MUST only if the hold is confirmed.

## M1 verdict

Charge the first unit as `LDG-39`'s order-landed charge, not as an exit shortfall. A + ceiling leaves 49–299× leverage multiplied by unpriced tenants.

- **Grid.** The lower bound is documented: "we will still bill you for one whole hour" (research:568-569). A wall-clock or month-boundary grid bills at most two units, leaving M2's 0.67×. The monthly cap is per server and irrelevant. DigitalOcean needs the native floor, or declares none (≤$0.01 per machine).
- **`ADR-0011`.** None of its three reasons (ADR-0011:88-90) transfers: the operator's cost is the unit, tails are already closed, and the unit is a declared term, not cadence.
- **Steering.** Debited at acceptance, so no exit degrades it. Quarantine fires only on `LDG-72`'s post-restore checks and outage on the price feed; neither is caller-reachable.

## Strongest "don't build"

Robot is "the entire product" (`ADR-0010`), and there `PRV-40` caps M1 at 40 unit-hours a day per account. On Cloud, a low ceiling plus an alarm plus `API-58` suspension bounds the loss before a human acts.

It fails for M1 because the suspended party re-enrols in 30 seconds, and because the loss needs no adversary (defect 1). It holds for D3, D4, D5 and any per-tenant share of the request limit.

## Defects in the framing

1. **It is a price, not a threat.** Every honest machine under 50 minutes sells below cost under A, and below about 2.5 h on average (`U/2` versus `m·L`). The set already decided both halves:
   - `LDG-37`: "Where the two disagree the provider wins, because the provider is what invoices the operator" (12:461-462).
   - `LDG-39`: "a create-then-delete cycle costs the tenant nothing and the operator the whole fee" (12:1096-1098).
2. **"Shortfall in the exit's closing increment".** A `usage_debit` over unelapsed seconds breaks `lifecycle_coverage`'s iff (Funding.lean:1535) and the quarantine exit's "MUST post no usage debit" (12:1017). A separate charge breaks neither.
3. **"Living past `U/(1+m)`, where margin covers it" is false.** 61 minutes costs two units against 1.22 paid. Margin covers a worst-case remainder only from `1/m` = 5 units.
4. **`SEC-41` does not say "darkens".** That is `DOM-23`'s (01:324). `SEC-41` says "one abusive tenant can terminate every tenant" (07:177).
5. **D2 scope.** The limit is "per Project", and "remaining requests will increase by 1 every second": a bucket, not an hour's lockout.
6. **D1 bound.** `SEC-39`'s interval is "default one hour" (07:210) against a daily budget, so any ceiling ≥1 admits 24 a day. The budget is "per ordering account" (00:380).
7. **r18's "docs are silent" on the grid is half wrong.** The FAQ rounds "the hourly usage of a server"; only multi-unit and month-boundary behaviour is undocumented.

No tracked files were edited and the gates were not run.
