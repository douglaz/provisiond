# A machine's first billing unit is prepaid machine time

**Status:** accepted (2026-10-06, owner decision Q2 of the provider-research grill).

## Context

Hetzner rounds a server's usage up to the hour: "We always round up the hourly usage of a server.
If you create a server just for a few minutes, we will still bill you for one whole hour" (Cloud
billing FAQ, quoted in `docs/research/provider-verify-2026-10.md` §3; Robot bills the same way).
`LDG-38`'s meter charges elapsed seconds. A machine that lives ten minutes therefore costs the
operator an hour and earns ten minutes plus margin.

A first panel (four readers, 2026-10-06) chose to let the operator absorb that remainder. The owner
refused to accept an absorbed loss without a threat model, and the threat model showed it is an
amplifier. An anonymous tenant (`ADR-0005`) whose balance cannot be withdrawn (`ADR-0004`) but stays
spendable loops create and delete. Billable life can be seconds: the seed is the first write that
records the machine billable and the exit is the recorded instant. Per cycle the operator loses
`U·p − (1+m)·t·p` and the attacker pays `(1+m)·t·p`. At a 20% margin that ratio is 49 at sixty
seconds and about 300 at ten. A rate ceiling bounds how fast it happens and never the ratio, and
every per-principal ceiling multiplies by tenants whose price is unregistered.

The set refused this shape once already, for the setup fee. `LDG-39`: the fee must not be a
reversible reservation "or a create-then-delete cycle costs the tenant nothing and the operator
the whole fee".

## Decision

**The provider's first billing unit of every machine is prepaid at the customer rate when the
order lands.** It follows the setup fee's lifecycle (`LDG-39`): committed before the order is
placed, debited on confirmed acceptance, released in full wherever the provider never charged. It
is its own entry kind, because it is priced once at acceptance for time that has not yet elapsed,
while `LDG-38` says "every increment is priced at a rate that held for the whole of it". The meter starts
where the unit ends: the machine's first seed places its mark at the seed instant plus one unit.
`LDG-38`'s existing rules then do the rest: "A seed at or before the subject's latest mark is
discarded", and an exit inside the unit closes an increment that clamps to zero seconds.

The unit is declared per offer in the descriptor as `{seconds, native_floor}`, a per-contract fact
`PRV-13c` already names ("billing granularity"). The floor carries a money minimum such as
DigitalOcean's "60 seconds or $0.01, whichever is higher".

**Why the customer rate and not cost.** The customer receives that hour. It is machine time,
which `ADR-0007` prices as "the provider's price plus a configured percentage", and it is how the
provider itself bills. `ADR-0006`'s at-cost rule is for a fee the customer gets nothing for.

## Considered and rejected

- **The operator absorbs the remainder** (the first panel's answer). Under the threat model each
  deposited satoshi can cost the operator 49 to 300.
- **The operator absorbs it, behind an aggregate exposure budget per provider account** (two
  readers of the second panel). It bounds the total loss and keeps the ratio. And the budget is
  itself shared: an attacker who spends it refuses every tenant's create, which turns the money
  threat into a denial of service.
- **A remainder at every exit from billable** (rejected 4–0 by the first panel). Provider grids
  are undocumented beyond the first unit, and it bills rounding a capped machine never incurs. It
  also breaks the quarantine, outage and provider-terminated exits and `ADR-0011`'s exit closure.
- **A minimum charged as a shortfall at exit.** A commitment at the runway floor can be smaller
  than one unit, so `LDG-31`'s clamp would turn the shortfall into an operator deficiency, and an
  attacker can choose that path. A shortfall posted as usage also covers seconds that never
  elapsed.
- **The same, at cost** (one reader's variant). It is consistent too, but it prices machine time
  the customer receives below every other second of it.

`ADR-0011` rejected "a minimum charge of one meter interval" because it "overcharges partial use".
None of its three reasons reaches this:
- the provider charges the unit, so charging it is the provider's price;
- tails are already closed at exit;
- the unit is a declared contract term, not the meter's cadence.

## Consequences

- An honest machine shorter than one unit pays the full unit, as it would buying from the provider
  directly. The offer discloses the price beside the setup fee.
- Residual, accepted: past the first unit the operator still absorbs the final partial unit, and
  a life that straddles an undocumented grid boundary can cost two units. Exploiting either
  costs the attacker more than it costs the operator (about 0.67 at a 20% margin), so it is
  priced, not amplified.
- `LDG-33`'s derivation, `runway_until = now + floor(usable_sats / current_customer_rate)`, must
  count from the later of now and the prepaid unit's end, or every machine routes up to one unit
  early.
- Edits owed: `PRV-44` (the declaration), `PRV-13b` (a reserve term beside the setup fee), `LDG-7`
  (the entry kind), `LDG-39` (the lifecycle), `LDG-38` (the first seed), `LDG-33` (runway),
  `LDG-75` (the residual as an accepted accounting gap), the offer's disclosure, and the formal
  layer's `Runway`, `Period` and `Funding` declarations.
- This closes the money threat (M1) only. The denial threats found beside it are separate: the
  shared provider request budget, the Robot order budget, provider quotas, and a throttled poll
  after an accepted order. So is the unregistered price of a tenant (`API-35`).
