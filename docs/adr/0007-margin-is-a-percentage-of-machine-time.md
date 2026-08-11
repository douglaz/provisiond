# Margin is a percentage of machine time; privileged operations are free

**Status:** accepted (2026-08-11)

Customer price is the provider's price plus a configured percentage, applied to **machine time
only**. Setup fees pass through at cost (`ADR-0006`). Custom-image installs, rescue sessions and
reimages are **not separately charged**.

## The trade-off, stated plainly

This prices the commodity and gives away the differentiator. Machine-hours are what Hetzner
already sells and what a caller can price-check against a public list; automated custom images
and rescue access are the thing a privex-class reseller cannot offer, and they carry the
operator's real work and real risk — an install is the operation that can destroy a customer's
disk and the one whose failure lands in `needs_reconciliation`.

It was chosen anyway, and the reasons are good ones: it is a single multiplier with no second
price list, no per-operation accounting, and no pricing surface for a caller to reason about
before deciding to buy. A customer who installs forty images pays the same as one who boots
Debian once — which is a subsidy, but a legible one, and it makes the expensive operation free
to try, which is how the differentiator gets discovered at all.

## Considered and rejected

- **Thin markup plus a fee per privileged operation.** Charges for the work and the risk, and
  scales with value delivered rather than with hardware spend. Rejected as a second pricing
  surface and a second thing to meter, explain and get wrong.
- **Hardware at cost plus a flat platform fee.** Maximally defensible — the customer verifies you
  take nothing on hardware. Rejected because a subscription prices *access* while the caller's
  pattern is bursty and unattended; an agent wanting one box for two hours should not meet a
  monthly fee.

## Consequences

- **Privileged operations MUST be metered even though they are free** (`LDG-25`). A price cannot
  be introduced later for something that was never measured, and the decision to give installs
  away should be revisited against data rather than against memory of this conversation.
- Margin is configuration, never a constant — `PRV-13c`'s rule applies to the operator's own
  commercial terms as much as to a provider's.
- The reserve holds `customer_rate`, not provider cost, or every machine is under-held by exactly
  the margin (`PRV-13b`).
- Your markup is derivable by any caller who reads the provider's public price list. That is a
  property of reselling a commodity, not a leak, and the specification should not pretend
  otherwise by hiding prices.
