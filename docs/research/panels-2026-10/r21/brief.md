# Panel brief: the Robot order budget as a denial target (2026-10-06)

You are one of four independent reviewers. The working directory is a throwaway clone of the
specification repository `provisiond-spec` at commit `6280286` (numbered Markdown requirements,
ADRs in `docs/adr/`, glossary `CONTEXT.md`, Lean in `tools/formal/`, beads readable with
`br show <id>` if `br` is on PATH). Read `AGENTS.md` first. Do not edit tracked files; you may write
scratch files, run arithmetic, and fetch public provider documentation (Robot webservice reference:
`https://robot.hetzner.com/doc/webservice/en.html`). Search the Markdown with whitespace normalised.
This owner repeatedly shows my framing wrong with a first-principles question and dissolves
machinery rather than tuning it; check this framing too, and verify every fact I state before
relying on it.

## Settled today (do not re-litigate)

- `ADR-0033`: a machine's first billing unit is prepaid machine time at the customer rate.
- `ADR-0034`: refresh from cache; reverse-DNS ceilinged; provider request budget with a system reserve.
- `ADR-0035`: a failure after the provider accepted a mutation is ambiguous.
- Context: `/var/tmp/provisiond-panel-r19/synthesis.md` (threat model; this is its D1).

## The threat

`PRV-40`: Hetzner Robot documents "20 requests per day" on each of its two order endpoints; the
budget is "shared across every tenant" (but `OVR-19`'s row says "per ordering account"); "The
deployment MUST refuse a create deterministically, before any provider call, once the budget is
exhausted." Nothing divides it among tenants. `SEC-39`'s per-principal create ceiling has a default
interval of one hour and no default integer.

- Standard channel: every orderable product carries a setup fee (€59–€1349 net, observed
  2026-09-04, `08-provider-notes.md`), debited on acceptance and never refunded (`LDG-39`), so
  spending 20 standard orders costs an attacker roughly €1,200+. My claim: self-limiting.
- Auction channel: `price_setup` is 0 on all 156 offers. Under `ADR-0033` each order costs the
  attacker one prepaid hour of the cheapest auction server, so about €2/day denies every other
  tenant's auction creates until the window rolls. `ADR-0010` makes Robot the product.

## Options put to the owner

- **(a)** A per-tenant daily share of each ordering account's budget, as a `SEC-39` ceiling on
  `OVR-19`. Funded Sybil tenants still drain it; each needs `API-35`'s minimum credit, which has no
  stated number.
- **(b)** More ordering accounts (`SEC-43`): each adds its own 20/day.
- **(c)** A per-order price on budget-limited channels.
- **(d)** Accept with an alarm until there is real Robot demand.

My recommendation: (a), plus register `API-35`'s minimum on `OVR-19`, plus record the residual as
an accepted risk with an alarm; (b) as the scaling path; no (c).

## What I want from you

1. **Verify the threat and its price.** From the Robot reference: is the limit per endpoint per
   account, rolling or calendar, and does a *rejected* or `test=true` order count? Can an attacker
   burn slots for less than an accepted order (an order the provider rejects after our admission;
   our own local refusal; an order accepted then cancelled at once)? What does an auction order
   really cost the attacker under `ADR-0033` (`LDG-39`, `PRV-13b`'s reserve, release on delete)?
   Is my standard-channel claim right (any zero-fee standard product)?
2. **Is (a) worth anything against an anonymous attacker?** What does `API-35`'s minimum cost an
   attacker, given the credit cannot be withdrawn but stays spendable (`ADR-0004`)? Is a Sybil
   tenant's deposit a cost at all if it is later spent on the attack's own orders?
3. **Find a third shape.** Candidates I have not evaluated: the prepaid unit count of `ADR-0033` as a
   per-offer parameter, so a budget-limited channel prepays more units with no new mechanism;
   pacing the daily budget (an hourly sub-budget) so a burst cannot take the day; admitting scarce
   orders by committed runway; holding back a share for tenants with history. Which is smallest,
   which actually changes the attacker's cost, which conflicts with `ADR-0005` (anonymity),
   `ADR-0007` (one multiplier, no second price list) or `ADR-0011`?
4. **What else spends the budget?** `PRV-40` says conformance runs and simulated orders do. Does
   `ADR-0035`'s reconciliation, a requeue (`OPS-20`), or `OPS-27` resolution ever place or count an
   order? Can an honest burst (many agents on launch day) exhaust it with no attacker?
5. **The strongest "don't build this".** Quantify it.

## Output

At most 900 words, no preamble: verdict (a), (b), (c), (d) or a named other in one line; why in
one paragraph; every defect in my framing with `file:line` or source URL; the requirement ids and
declarations the chosen answer edits.
