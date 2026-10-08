**Verdict: (c), reshaped — the included allowance is a second operator loss limit, handled exactly like `LDG-64`'s rate-outage bound: disclosed on the offer, enforced by the existing exposure-reducing cancellation. No byte meter, no entry kind, no reserve term.**

**Why.** Traffic is not a pricing problem but an exposure the operator cannot bound by reserving: seconds per interval have a ceiling, bytes do not (Hetzner publishes no per-server speed; DigitalOcean premium is "up to 10Gbps outbound"). The provider already answers the only question that matters — is this machine past what the operator paid for — on every server object the sweep already lists (`outgoing_traffic`, `included_traffic`). The set already has the shape for a disclosed operator loss limit that destroys a machine: `LDG-64` "The bound is the operator's own loss limit … MUST be disclosed before purchase (`WIR-30`'s offer)" (12-billing-and-ledger.md:1360-1367) and the `rate_outage_bound` reason in `OPS-39`/`Fence.lean:142`. Adding one reason reuses all of it; (a) builds a second meter for a quantity whose reserve cannot be sized and leaves the clamp path open.

**Defects in the framing**

- *1 Gbit/s is not conservative.* No official figure exists; the servers FAQ says only that graphs are "retrieved from the host server". Cloud Mercato measured two cpx11 at avg 3143 / max 3823 Mbps (pcr.cloud-mercato.com/providers/hetzner/flavors/cpx11/performance/network-bandwidth): $39/day at 3 Gbit/s.
- *Per server, not pooled, at Hetzner:* FAQ "Example: Your server has 20TB included traffic"; API `included_traffic` is on the server, "Free Traffic for the current billing period in bytes", nullable. Proration is undocumented → `[verify]`; irrelevant under (c), since both numbers are the provider's.
- *US/SG include 1 TB*, pricing is "per month in bytes in this Location" (cloud.spec.json). Your 8 TiB for ccx63/ash needs the token; unverified.
- *DigitalOcean is where the money is:* pooled per team, accrued per second (1/2,419,200 of the plan), $0.01/GiB ≈ $9.3/TB (docs.digitalocean.com/products/billing/bandwidth/). Per-Droplet usage exists only as a Mbps time series (`/v2/monitoring/metrics/droplet/bandwidth`, no agent needed); the pool only on the billing page, "updated daily". This is the shared budget `ADR-0033`/`0034` rejected. 1 Gbit/s for a month ≈ $3,000 against $4; a fresh $4 Droplet contributes nothing to the pool yet can send 500 GiB ($5) in 72 min for the $0.01 minimum: 500× per cycle.
- *Needs no attacker:* a 300 Mbit/s seedbox costs $90/month at Hetzner EU on an $8.40 machine; anonymous sats-paid tenants select for it.
- *Counter freshness:* Robot counts "only after disconnecting a TCP connection"; Cloud is undocumented. A held stream can hide until it closes — a defect of (a) and (c) alike; live test.
- *Period:* Hetzner invoices "based on full calendar months" in its local time; `LDG-68` is UTC and "a property of the deployment, not of a provider" (12:81). (a) has a boundary with no rule; (c) has no boundary.

**Where (a) is wrong**

- `ADR-0033`:57: "`LDG-31`'s clamp would turn the shortfall into an operator deficiency, and an attacker can choose that path." Run the commitment to the floor, then blast; every traffic debit clamps to zero. A reserve term cures it only with a byte ceiling: 10 Gbit/s × 1 h × $0.01/GiB ≈ $42/h per Droplet, 10× its month.
- At cost is still a second price list: `price_per_tb_traffic` per location per provider must be shown (`LDG-26`, `WIR-30`) and converted (`LDG-27`). `ADR-0007` rejected the *surface*, not the margin.
- The source dies with the server: no final reading after the gone-write, none for a provider-terminated machine. On DigitalOcean no per-machine fact exists to debit; any attribution is a policy.
- Runway dissolves (a byte debit decrements under `LDG-31`, the date floats under `LDG-33`); the reserve does not. Outage: no rate → no debit (`LDG-64`), another native-only accrual class for `LDG-75`. `LDG-7` and `Funding.lean:180` gain a kind.

**Third shapes**

- *Power off at the allowance:* keeps the disk, stops the cost — but power-on, reboot, hard-reset, install and rescue all boot it; each needs a refusal or every power cycle buys one sweep interval of egress ($0.54/h at 1 Gbit/s vs $0.012/h machine time, 45×). *Firewall deny:* "the new settings apply only to new connection attempts" (firewalls FAQ) — a held stream never closes. Both dead.
- *No-exposure offers only:* Robot 1G "unlimited traffic" qualifies, Cherry reportedly 100 TB then €0.50/TB (third-party, unverified); it removes every launch cloud driver.
- *`LDG-75` gap + `SEC-42` terms:* `SEC-42` enforces only "at request time from data the system already holds" (07:187); an undisclosed destruction is "a second, undisclosed trigger" `LDG-64` refuses (12:1363).

**Strongest "don't build (a)", quantified:** worst case at Hetzner EU ≈ $362/machine-month, median tenant $0; (a) adds a meter, an entry kind, an accrual class and six Lean declarations to recover $1.20/TB, keeps the clamp path, and is unbuildable where the money is (DO: pooled, rate-series counter).

**Residual of (c):** egress between observation and destroy, one sweep interval plus `PRV-36`'s window. Hourly: Hetzner $0.54–1.6; DO $4.19, $42 on 10 Gbit/s premium — so tighten the interval (`LDG-74`: "a money parameter") or don't list premium DO offers. Priced, not amplified: burning 20 TiB first costs ≈ 2 days of cpx11 ≈ $0.56, ratio ≈ 1. On DO the ceiling must be the *accrued* allowance (`transfer` × age / 28 d) or churn restores 500× — making the $4 Droplet a 1.6 Mbit/s product. The owner's call; the honest one.

**Edits**

- `PRV-44`/`DOM-9`/`WIR-30`: offer carries `included_traffic_bytes` per provider period (null = unlimited) from the price feed; `WIR-11`: both counters and their observed instant (`STO-48` pattern).
- `OPS-32`: record both counters from the listing already taken; at or past allowance and not gone, open `(machine_id, traffic_allowance)` (`STO-52`, `OPS-39` reasons), routed by `OPS-41` beside `rate_outage_bound`.
- `LDG-14`: third disclosed trigger, `LDG-64`'s sentence as model; `CONTEXT.md`:93 excludes it from *funding cancellation*; `LDG-75` gaps: post-observation egress; `08-provider-notes.md` DO: accrued allowance, metrics integration, `[verify]`; one `CNF` item plus negative control.
- Formal: `Fence.lean:142` `Reason` gains `trafficAllowance` with an enqueue theorem shaped like `outageBound` (Fence.lean:983-996). Nothing in `Meter`, `Funding`, `Runway`, `Ledger`, `Payables`. (a) would touch all five plus `Period`.
