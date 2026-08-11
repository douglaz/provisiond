# 12 — Billing and the ledger

This document did not exist until 2026-08-11, and its absence was the largest hole in the set:
`API-17b` requires a deployment to define its spending authority, and nothing defined it. The
decisions it records live in `ADR-0002` (prepaid balance is the only spending authority),
`ADR-0003` (the float is denominated in satoshis) and `ADR-0004` (the perimeter).

**The ledger is not an accounting convenience. It is the authorization system.** Under `ADR-0002`
a balance is the *only* thing that permits spending, so a ledger bug is an authorization bug, and
the transaction that places a hold is the same transaction that authorizes a purchase.

## Units and arithmetic

**LDG-1** Every monetary quantity MUST be a **signed integer of satoshis**. No floating point, no
decimal strings parsed late, no rounding policy at the boundary. This is the whole reason
`ADR-0003` chose satoshi denomination for the ledger: a balance comparison is integer arithmetic
with no conversion in it.

**LDG-2** Provider-side amounts MUST be recorded **in the provider's own billing currency**
alongside the satoshi amount, as a separate integer of that currency's minor units, with an
explicit currency code — even while only one provider currency is in use. Without it, the
question "what did this machine actually cost me at the provider" is unanswerable for all
history predating the second currency, and it is not reconstructable later.

**LDG-3** Adding two amounts with different currency codes MUST be an error, not an implicit
conversion. This is one type and one refusal, and it is the single cheapest defence against the
worst silent bug available here — summing USD into EUR and reporting the total as money.

**LDG-4** Every conversion MUST record the rate as an **exact rational** (numerator and
denominator), its source, its observation time, the haircut applied in basis points, and the
rounding rule version — denormalised onto the entry itself, so the entry remains
self-explanatory after any rate table is pruned. Rounding MUST be against the tenant (ceiling on
debits, floor on credits) and MUST still record which rule ran.

## Entries

**LDG-5** The ledger MUST be **append-only**. No update, no delete. A correction is a new entry
naming the entry it corrects. Balance is the sum of entries; any cached balance is an
optimisation that MUST be reconcilable against the sum.

**LDG-6** Every entry MUST carry: a stable id; the tenant; a per-tenant monotonic sequence
number (ordering under equal timestamps); a kind; the signed satoshi amount; the running balance
after it; and the ids of whatever caused it — operation, machine, hold group, and the
provider-side settlement reference once known. Provider-denominated entries additionally carry
`LDG-2`'s native amount and `LDG-4`'s conversion evidence.

**LDG-7** Entry kinds MUST at minimum distinguish: `topup`, `hold`, `hold_adjustment`,
`hold_release`, `usage_debit`, `setup_fee_debit`, `correction`, and `expiry`. A setup fee MUST
be its own kind and not folded into usage, because it is the one non-refundable component and a
caller asking "why did I not get that back" deserves a row that answers it.

**LDG-8** Every entry MUST carry an idempotency key unique within the tenant. This matters most
for `topup`: a retried payment notification that credits twice is indistinguishable from free
money, and payment rails retry by design.

## Balance and authority

**LDG-9** A tenant's **available** balance is the sum of its entries minus its open holds. The
spending authority check is `available ≥ required_hold`, and it is the only authorization a
create receives (`ADR-0002`, `API-17b`).

**LDG-10** A balance MUST NOT go negative. Any operation that would take it negative MUST fail
rather than proceed, including a re-derivation that raises a hold (`PRV-13e`) — which routes to
the exhaustion path below instead of borrowing.

**LDG-11** **Placing the hold and enqueuing the create MUST be one transaction.** A hold without
an operation silently freezes a customer's money; an operation without a hold spends the
operator's. This is the requirement `ADR-0001` was decided on: two stores cannot give one
transaction, and no amount of care recovers it.

**LDG-12** No provider mutation that can incur cost may begin before its hold is committed.

## Pricing

**LDG-23** Customer price MUST be a **derived value**, never the provider's price string passed
through. A single function maps an offer to a customer price, and every caller — the offers
endpoint, the reserve calculation (`PRV-13b`), the usage debit — MUST go through it. Hardcoding
the provider's number means that introducing a margin, or a second currency, edits every call
site instead of one.

**LDG-24** The margin is a **percentage applied to machine time only** (`ADR-0007`). Setup fees
pass through at cost (`ADR-0006`). It MUST be configuration, resolvable per provider account or
product class, and MUST NOT be a constant in code — `PRV-13c`'s rule about not encoding
commercial terms applies to the operator's own terms as much as to a provider's.

**LDG-25** Privileged operations — custom-image installs, rescue sessions, reimages — are **free
in v1 but MUST be metered from the first release**. They are the operator's actual differentiator
and carry its actual risk, and a price cannot be introduced later for something that was never
counted. The meter is what makes the decision to give them away revisable against evidence rather
than against recollection.

**LDG-26** The offers endpoint MUST return customer prices, and MUST NOT return provider cost.
This is not concealment — any caller can derive the margin from the provider's public price list,
and `ADR-0007` accepts that — it is that provider cost is operator business data with no role in
a customer's decision.

## Exhaustion

**LDG-13** A machine whose funding fails MUST be cancelled, and cancellation is the *only*
effective remedy — powering a machine off does not stop provider billing on either the cloud or
the dedicated products. There is no unfunded grace period, because the customer already bought
one: `PRV-13d`'s runway is prepaid, so expiry is the end of a window the caller chose and paid
for, not a surprise.

**LDG-14** At end of runway the machine is cancelled **and its disk is destroyed with it**. No
snapshot is taken and no data is retained. A snapshot would be an unfunded billable attachment
(`PRV-13a`) belonging to the one customer proven to have no balance. **This MUST be stated
plainly in the terms and in the API documentation** — in words, not by implication from a
retention table. It is the harshest behaviour in the product and it must not be a discovery.

**LDG-15** Exhaustion MUST be visible before it happens. The remaining runway MUST be readable
from the machine view, so a caller can act on it. A caller that is software will act on a number
long before it would act on an email, and there is no email.

**LDG-16** A rate or price movement MUST NOT have its own cancellation machinery. It reaches the
machine through `PRV-13e`'s re-derivation and then through this same path — with `PRV-13e`'s
guards: a per-tick cap, and a deficiency that must persist across more than one derivation
before it can cancel anything.

## Solvency

**LDG-17** The operator MUST hold satoshis at least equal to the float — the sum of all customer
balances including open holds — plus a margin for provider payables already incurred and not yet
settled. Customer float is not operating capital and MUST NOT be spent on operating costs, and
the operator's own margin MUST be distinguishable in the ledger from customer balances.

**LDG-18** The float MUST NOT be pledged, lent, or posted as collateral. `ADR-0003` rejected
borrowing against it: no EU safeguarding rule reaches an unlicensed business, so the customers
are ordinary unsecured creditors and nothing external will stop this — which is exactly why it is
written here. What does apply is directors' duties near insolvency and plain misrepresentation.

**LDG-19** The solvency invariant SHOULD be published. Stating it converts a later breach from
an unregulated act into an actionable misrepresentation, which is the only enforcement mechanism
the regulatory perimeter fails to supply (`ADR-0004`). A published invariant that is quietly
violated is worse than none; publish it only if it is enforced.

**LDG-20** Solvency MUST be checked against stress, not only at spot: bitcoin down 50%,
the provider-currency pair adverse by 15%, an inaccessible venue for seven days, no new top-ups,
and every existing balance spent with maximum provider cost through cancellation. An asset counts
only if it can reach the provider's bank account before the liability falls due. On failure the
system MUST refuse every bill-increasing operation while continuing to permit cancellation and
deletion — the operations that *reduce* exposure MUST never be gated by the check that fires
because exposure is too high.

## Privacy constraints on the ledger

**LDG-21** The ledger MUST NOT record anything identifying beyond the tenant identifier
(`ADR-0005`). No caller addresses, no payment counterparty information, no correspondence.
Payment references are retained only as far as reconciling a top-up requires, and MUST NOT
include a spendable secret — no ecash token, no preimage.

**LDG-22** Ledger retention is **not** subject to the operation payload purge (`OPS-2` as amended
by `ADR-0005`). A financial record must outlive the request that caused it, and it contains no
caller secrets to purge — which is only true because `LDG-21` kept them out in the first place.

## What deliberately does not exist here

There is no withdrawal, no transfer between tenants, no fiat refund, and no balance expiry
sweep that credits the operator. Each is prohibited by `ADR-0004`, each for more than one
independent reason, and adding any of them is a change to the regulatory position of the whole
business rather than a feature.
