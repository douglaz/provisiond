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

**Lightning is the primary rail; on-chain is the fallback.** Both ship in v1.

Attribution comes from the *destination*, not the payer. A funding request mints a destination
bound to exactly one tenant — a BOLT11 payment hash, or a freshly derived on-chain address — and
the credit is posted when that destination is paid. This satisfies the collect-nothing posture and
the attribution requirement with the same mechanism rather than trading one against the other.

Authentication is structural on both rails: the ledger reads settlement from the operator's own
node, never from an inbound notification. There is no webhook to forge.

## Considered options

**Lightning only** was the recommendation, and it was rejected for a reason worth recording:
inbound liquidity caps a single top-up. A customer who wants to prepay a year of a dedicated
server cannot, and the failure is invisible to them — it presents as a payment that simply does
not route. An operator can add capacity, but capacity is an operational variable and a funding
ceiling that moves with it is not a product. The fallback removes the ceiling.

**Ecash first** was rejected because the operator would hold a claim on a federation rather than
bitcoin, which changes what `LDG-17`'s solvency invariant actually asserts, and because it
requires the customer to already be inside a federation the operator accepts.

**On-chain only** was rejected on latency: minutes to an hour before a tenant can buy anything,
against a caller that is a program expecting to act now.

## Consequences

The two rails do not share a finality rule, a fee model, a minimum, or an expiry semantic, and
pretending they do is where this gets built wrong:

- **Finality differs and both must be stated.** A settled invoice is final; an unconfirmed
  transaction is not (`LDG-48`). Zero-confirmation credit is forbidden — a replaceable transaction
  would buy a machine whose setup fee is already non-refundable (`LDG-39`).
- **Credit what arrived, never what was intended** (`LDG-47`). On-chain the payer pays the network
  fee, so the received value is the credit.
- **Two minimums** (`LDG-52`). The on-chain floor must exceed the cost of eventually spending the
  output it creates, or a top-up shrinks the operator's assets while growing the float.
- **An address cannot be expired.** An invoice can. Anyone may pay a derived address forever, so
  the destination-to-tenant map outlives the funding request that created it (`LDG-51`) — and a
  payment arriving to a tenant that no longer exists is the collision this ADR's context
  describes, resolved separately.
- **Address reuse is a privacy defect, not an optimisation** (`LDG-50`). One address per tenant
  would publish that tenant's entire payment history on a public ledger, which makes the
  collect-nothing posture ornamental.
- **On-chain is the rail where the operator learns something it did not want to.** A source
  address is visible whether or not it is recorded. `ADR-0005` still forbids retaining it, and the
  discipline is harder here than on Lightning because the information arrives unbidden.
