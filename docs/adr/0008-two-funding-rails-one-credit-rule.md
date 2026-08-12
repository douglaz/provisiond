# Two funding rails, one credit rule

## Context

`ADR-0002` made a prepaid balance the entire spending authority, which made the money-in path
v1-blocking. `LDG-42` then required a funding path and named three candidate rails without
choosing one, so the endpoint, the finality rule, the fee-bearer and the tenant binding were all
unwritten.

The constraints are unusually tight. `ADR-0005` forbids recording a counterparty, so attribution
cannot come from knowing who paid. `LDG-42` requires the credit to be *authenticated*, because an
unauthenticated credit notification mints money directly. `ADR-0004` forbids withdrawal, so a
payment that cannot be attributed also cannot be returned — and `LDG-43` names holding a
stranger's money with no way to return it as the one outcome this specification must not permit
by accident.

## Decision

**Both rails ship, and a deposit is one object payable over either.** A funding request mints a
single deposit carrying an **amount** and an **expiry**, and returns both a BOLT11 invoice and a
freshly derived address for it. **The payer chooses the rail; the operator does not.**

Attribution comes from the *destination*, not the payer. Either destination resolves to the
deposit and therefore to the tenant, and the credit is posted against that binding. This satisfies
the collect-nothing posture and the attribution requirement with the same mechanism rather than
trading one against the other.

Authentication is structural on both rails: the ledger reads settlement from the operator's own
node, never from an inbound notification. There is no webhook to forge.

**The expiry is the load-bearing part**, and not for the reason it first appears. On Lightning it
is ordinary — an invoice enforces its own deadline. On-chain it enforces nothing: the address
stays payable forever and no operator action changes that. What the expiry bounds is the
*operator's obligation to watch*, and that turns out to be the only bound available. Minting a
deposit is free and unauthenticated-adjacent, so any obligation attached to one permanently is an
obligation an attacker can mint without limit. With an expiry, the active watch set is bounded by
*mint rate × expiry window* no matter how patient anyone is.

That leaves one honest hazard, which `LDG-54` requires be disclosed in as many words: **an expired
address still looks payable.** It is the single place in this design where a customer can lose
money by doing something that appears correct.

## Considered options

**Lightning only** was the recommendation, and it was rejected for a reason worth recording:
inbound liquidity caps a single top-up. A customer who wants to prepay a year of a dedicated
server cannot, and the failure is invisible to them — it presents as a payment that simply does
not route. An operator can add capacity, but capacity is an operational variable and a funding
ceiling that moves with it is not a product. The second rail removes the ceiling.

**Lightning primary with on-chain as a fallback the operator selects** was the first draft of this
decision and was withdrawn within the hour. It had the deployment pick the rail at mint, answering
on-chain whenever the amount exceeded inbound capacity. That forces a liquidity guess which can be
stale by the time the customer pays, and it makes the operator's guess load-bearing in exactly the
case — the large first top-up — where being wrong costs the most. Offering both moves the choice
to the party that knows its own constraints. **The word "fallback" is retained in this ADR's title
and nowhere in the requirements**, because there is no fallback: there are two destinations for
one deposit.

**Restricting addresses to already-funded tenants** was drafted as a way to bound the permanent
monitoring obligation, and became unnecessary once the expiry applied to both rails. It is
recorded because it was nearly adopted, and it would have put friction on the largest customer's
first payment to solve a problem the expiry solves for free.

**Ecash first** was rejected because the operator would hold a claim on a federation rather than
bitcoin, which changes what `LDG-17`'s solvency invariant actually asserts, and because it
requires the customer to already be inside a federation the operator accepts.

**On-chain only** was rejected on latency: minutes to an hour before a tenant can buy anything,
against a caller that is a program expecting to act now.

## Consequences

A deposit is one object, but **the two rails underneath it share almost nothing** — not a finality
rule, not a fee model, not a minimum, and not what expiry means. Pretending the unified object
makes them uniform is where this gets built wrong:

- **Finality differs and both must be stated.** A settled invoice is final; an unconfirmed
  transaction is not (`LDG-48`). Zero-confirmation credit is forbidden — a replaceable transaction
  would buy a machine whose setup fee is already non-refundable (`LDG-39`).
- **Credit what arrived, never what was intended** (`LDG-47`). On-chain the payer pays the network
  fee, so the received value is the credit.
- **Two minimums, neither enforceable at mint** (`LDG-52`). The on-chain floor must exceed the cost
  of eventually spending the output it creates. But the deposit is payable either way, so a floor
  can only be disclosed and then applied to what arrives — never used to refuse the deposit.
- **One deposit can be paid twice** (`LDG-55`, `LDG-56`), most plausibly by a customer who pays
  on-chain, waits, and loses patience. Both payments credit. Settlement on one rail must not stop
  watching the other, and there is no refund.
- **Expiry means two different things** (`LDG-54`). On Lightning it ends payability; on-chain it
  ends only the operator's watching. The disclosure at mint is what stands between a customer and
  a payment nobody is looking for.
- **Address reuse is a privacy defect, not an optimisation** (`LDG-50`). One address per tenant
  would publish that tenant's entire payment history on a public ledger, which makes the
  collect-nothing posture ornamental.
- **On-chain is the rail where the operator learns something it did not want to.** A source
  address is visible whether or not it is recorded. `ADR-0005` still forbids retaining it, and the
  discipline is harder here than on Lightning because the information arrives unbidden.
