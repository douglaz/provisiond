# Only offers with no traffic overage are sold until a counter is proven fresh

**Status:** accepted (2026-10-07, owner decision Q8 of the provider-research grill). Narrows
`ADR-0010`'s v1 sale scope.

## Context

Hetzner Cloud bills outgoing traffic beyond a per-location allowance: "If you exceed the traffic
included in your package, we will bill you for the over-usage in blocks of 100MB", and "Any traffic
used beyond the included amount is billed as usual, even if a notification reaches you late or does
not arrive at all". The account's live prices put the EU allowance at 20 TiB and overage at $1.20/TB.
US locations include at least 1 TB and AP locations at least 0.5 TB, so sustained outbound of about
3 Mbit/s in the US or 1.5 Mbit/s in Singapore crosses it. An ordinary small website does that, and
no attacker is needed. DigitalOcean pools its allowance across the team and charges $0.01/GiB
beyond the pool. A fresh Droplet adds almost nothing to the pool yet can send hundreds of GiB in an
hour. Hetzner Robot's default dedicated servers have "a dedicated 1 GBit uplink by default and with
it unlimited traffic".

The set prices machine time only (`ADR-0007`), and nothing meters, caps or reserves for bytes.
`PRV-13b` already says a reseller "MUST be able to bound its own exposure before taking money", and
every offer with metered egress broke that MUST.

A four-reader panel (`docs/research/panels-2026-10/r25/`) rejected charging for traffic 4–0. It split
2–2 between selling only offers with no overage and cancelling a machine at a disclosed allowance.

## Decision

1. **An offer is sold only where traffic cannot run up a provider charge beyond what the operator
   prepaid.** Each offer declares a traffic bound. `unlimited` (Robot's default 1 Gbit dedicated
   servers) is sellable. An offer that has an allowance is not sold on prepaid terms. That takes in
   Hetzner Cloud, DigitalOcean and Robot servers on a 10 Gbit uplink. It is `PRV-31`'s rule
   carried over: an offer with no declared bound MUST NOT be sold on prepaid terms.
2. **The way back in is written down now.** An offer that has an allowance becomes sellable once a
   live test shows that its provider's traffic counter is fresh enough. The traffic that can slip
   through between the last reading and deletion then has to pass `ADR-0033`'s test, "priced, not
   amplified".
   - Such an offer declares its allowance less a headroom.
   - A machine past it gets an exposure-reducing cancellation with its own reason, beside
     `rate_outage_bound`.
   - The bound is disclosed before purchase, the way `LDG-64` discloses the operator's loss limit,
     so that destruction at the bound is never "a second, undisclosed trigger".

## Considered and rejected

- **Pass traffic through at cost.** `ADR-0033` says "`ADR-0006`'s at-cost rule is for a fee the
  customer gets nothing for", and the customer gets the bytes. At cost is still a second thing to
  meter (`ADR-0007`). It cannot be built on DigitalOcean, whose allowance is pooled and whose
  per-Droplet figure is a rate, not bytes. The clamp defeats it: run the commitment to its floor,
  then send. And no reading survives the gone-write.
- **Charge traffic with the margin.** This reopens `ADR-0007` and has every problem above.
- **Accept the overage with an alarm.** It breaks `PRV-13b`'s MUST, and Hetzner bills the overage
  whether or not its own notification arrives.
- **Cancel at the allowance from today.** No provider documents how fresh its counter is. Robot
  counts traffic "only after disconnecting a TCP connection", and Cloud says nothing. The cancel
  path waits for the evidence that makes it sound.
- **Power off at the allowance, or a firewall deny.** Any power-on undoes a power-off. A firewall
  change applies "only to new connection attempts", so a held stream keeps sending.

## Consequences

- **v1 sells Hetzner Robot's default dedicated servers only** until a live test re-admits another
  offer. `ADR-0010` calls Robot "the product". The Cloud and DigitalOcean drivers stay specified,
  and their conformance still runs, but their offers are not for sale. The diversification across
  two companies that `ADR-0010` wanted waits for that test.
- `PRV-13b`'s sentence that "committing the customer price also covers the operator's exposure", and
  its catastrophe bound "at most `setup_fee + one period cap`", hold only for sellable offers. Both
  say so.
- Edits owed:
  - `PRV-13b`: traffic is exposure, and the two qualified sentences.
  - `PRV-44`: the traffic bound per offer.
  - `PRV-13c`: the allowance and its price are read, never encoded.
  - `DOM-9`/`WIR-30`: offers are filtered and disclosed.
  - The purchase tail refuses an unsellable offer (`API-7`, `Provisiond.Admission.purchaseTail`).
  - `LDG-75`: residual traffic as an accepted gap.
  - `08-provider-notes.md`: the facts and `[verify]` items.
  - `ADR-0010`: a dated note.
  - Conformance items.
  - The live batches gain a counter-freshness test per provider (a held stream, a mid-month
    server, DigitalOcean's metrics).
