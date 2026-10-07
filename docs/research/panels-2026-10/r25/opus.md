**Verdict: (c), placed under `PRV-13b`. Overage is never sold: each offer declares a traffic bound, and a machine that crosses it gets an exposure-reducing cancellation.**

**Why.** Option (a) has lost its precedent. `ADR-0033:43`, settled today, says "`ADR-0006`'s at-cost rule is for a fee the customer gets nothing for", and the customer does receive the bytes. Even at cost, traffic is "a second thing to meter, explain and get wrong", which `ADR-0007:27` rejected. Option (a) also can't be built on DigitalOcean, which `ADR-0010` makes mandatory:
- Its only per-droplet source reports "in megabits per second (Mbps)", which isn't invoice-grade bytes, and `LDG-37` says "the provider wins".
- Its allowance is "pooled cumulatively across all Droplets at the team level", so a per-machine charge at cost isn't the actual cost.

A stop works despite both. An estimate stops early, and if every machine stays inside its own prorated allowance the pool never overruns. DigitalOcean needs no guest agent for this: "By default, Droplet metrics show … public and private bandwidth usage". Option (a) is no safer: both options leave the same residual, the traffic after the last reading, which `ADR-0037`'s gone-write makes unreadable. On Hetzner the reading costs nothing, because `outgoing_traffic` and `included_traffic` are already on the server objects in `OPS-32`'s listing.

**What the residual costs.** `ADR-0033`'s test is "priced, not amplified", so the residual must cost less than the prepaid first unit. On your unverified $0.28/day, that unit is about $0.0117. At 400 Mbit/s, overage runs about $0.0036 a minute in the EU and $0.025 in Singapore. If Hetzner prorates the allowance, EU offers pass only if sweep plus wind-down takes about 3 minutes or less, and Singapore offers never pass. If it doesn't prorate, a headroom makes the residual zero.

**Strongest "don't build".** `ADR-0010:32` says "Hetzner Robot is the product", and Robot gives "a dedicated 1 GBit uplink by default and with it unlimited traffic". So: sell Cloud only in the EU and accept the overage. Once the allowance is gone, 300–500 Mbit/s costs $3.9–6.5 a day. That is 14–23× your $0.28 a day, on the same per-day measure as your 46×. It fails four ways:
- Hetzner's notices "do not cap or stop it".
- DigitalOcean runs $40–201 a day.
- `ADR-0033:48` refused a ratio of "49 to 300", which is the same class.
- It breaks `PRV-13b`'s MUST.

**Defects in the framing**
1. **1 Gbit/s isn't a cpx11 figure.** Hetzner says "We do not offer bandwidth guarantees for our Cloud servers, but you can expect about 300-500 Mbits" (hetzner.com/cloud/regular-performance). At that speed 20 TiB lasts 4.1–6.8 days, not about 2.
2. **The EU is the mildest case.**
   - The same page says "U.S. include at least 1 TB" and "AP locations include at least 0.5 TB".
   - Singapore is $8.30/TB in Hetzner's price-data file but $8.49 on its Singapore page; I didn't resolve the difference.
   - Overage starts above a sustained average of about 68 Mbit/s in the EU, 3.1 in the US and 1.5 in Singapore. A small site or a Tor relay crosses that, so no attacker is needed.
3. **Hetzner states neither proration nor pooling.** The FAQ says only "Your server has 20TB included traffic". Your 20 TiB comes from `/v1/pricing`, which is "Free traffic per month". The cheapest evidence is a server created mid-month and its own field, "Free Traffic for the current billing period". The invoice line is the authority.
4. **DigitalOcean was unchecked** (docs.digitalocean.com/platform/billing/bandwidth, …/droplets/details/limits). The allowance accrues "1/2,419,200" per second. Overage is "$0.01 per GiB", throughput reaches "2 Gbps", and "We do not bill for outbound data transfer that we determine is dropped by a DigitalOcean firewall rule".
5. **"No rule on traffic" is wrong.**
   - `PRV-13b` (02:162) says "MUST be able to bound its own exposure before taking money", and every Cloud offer breaks that today.
   - Overage makes two sentences false: 02:193, "committing the customer price also covers the operator's exposure", and 02:374, "at most `setup_fee + one period cap`".
   - `SEC-41` (07:179) already names "egress controls".
   - Under `LDG-75` (12:1950), "costs absent from local charges" already reach B through the invoice. Overage is unpriced, not unaccounted.
6. **Option (a) has more gaps.** Hetzner's "calendar months" have no stated timezone, while `LDG-68` is UTC. `LDG-64` has no byte leg. `wind_down_cost` covers time only. It needs a new `LDG-7` kind.

**Edits for (c)**
- `PRV-13b`: count traffic as exposure, and qualify 02:193 and 02:374.
- `PRV-44`: give each offer a `traffic_bound`, either `unlimited` or its own allowance plus a headroom, and require the bound to pass the residual test. `PRV-31`'s rule carries over: "an offer with no declared bound MUST NOT be sold on prepaid terms". Robot's 10 Gbit uplinks declare one too.
- `PRV-13c`: read the allowance and price from the provider; never encode them.
- `OPS-32`: record bytes per machine. On DigitalOcean that is one read per droplet, within `ADR-0034`'s budget.
- `LDG-15` and its WIR field: show traffic used and the bound beside `runway_until`.
- 05:379: add `traffic_allowance` to `system_reason`.
- `CONTEXT.md`: this cancellation is exposure-reducing but not a funding cancellation.
- `LDG-14`'s terms: say the disk is destroyed at the bound. If the disk must survive, use a power-off plus a refusal of `power_on`.
- `LDG-75`: traffic after the last reading arrives only on the invoice.
- `08-provider-notes`: record these facts, and add one new CNF item.

**Formal:** no Lean change, because (c) adds no debit, entry kind or runway term. Option (a) would edit `Funding.Kind`, `Meter.debits` and `Runway`'s `prot`.

The gates (`tools/check-all.sh`) pass at `ff4b4cc`. I changed no tracked files; this answer is saved at `/tmp/r25-opus/verdict.md`.
