**Verdict: (d). No per-tenant share. Keep the local gate, but have it close on Robot's own 403 instead of keeping a count.**

**Why.** Who loses money when the budget runs out? Effectively nobody. A refusal settles `failed` and releases the commitment. The attacker buys every attack hour at the customer rate, so the operator earns margin on it, minus `ADR-0033`'s straddle residual. The harm is lost auction sales on one account, at most 20 a day. Twenty-one honest agents hit the same ceiling, and no control creates capacity. Option (a) is the shape `ADR-0034:57` rejected today ("Fresh tenants defeat shares"), and a funded attacker gets its deposit back as compute.

The gate is still needed, but not as a count. Without it, every create after exhaustion sends three requests: `POST /key`, an order that gets a 403, then `DELETE /key`. Both key endpoints are limited to "200 requests per 1 hour", and rescue's temporary keys use the same endpoints (`08:102`). So free creates would block every tenant's installs. A local count cannot match Robot's, because nobody knows what Robot counts. A gate that closes for the 403's `interval` cannot drift from Robot, and sends nothing that could extend a sliding window.

**Verify first. It costs nothing except one day of ordering on one account.**
- On `server_market`, send 20 invalid POSTs, then one `test=true` POST. A 403 means rejected requests count.
- On `server`, send 20 `test=true` POSTs, then one more. A 403 means simulated orders count.
- Keep sending after the first 403 to see whether the window extends.

If rejected requests count, also allow one in-flight create per `offer_is_resource` offer, and check the offer is still listed before the POST (`GET /order/server_market/product/{id}`, 500/h).

**Defects in the framing**
1. Three POST endpoints carry "20 requests per day", not two: `server`, `server_market` and `server_addon` (https://robot.hetzner.com/doc/webservice/en.html). The page does not say what the limit applies to (account, user or IP), whether the day is rolling or calendar, or whether rejected and `test` requests are exempt. The 403 carries only `max_request` and `interval`.
2. "Every other tenant" is false.
   - `SEC-43` (`07:323`) already requires multiple accounts, and under `API-57` (`04:558`) the operator assigns them. One attacker tenant drains only its own accounts, so (b) is an existing MUST, not an option.
   - `02:879` ("the whole deployment") is wrong. `00:380` is right but needs to be per channel, and `PRV-44`'s single `order_budget {limit, per}` (`02:63`) cannot express that.
3. "Self-limiting" holds only for accepted orders.
   - A deterministic rejection is "**Never debited**; released" (`12:1081`). `ADR-0035:53-55` already treats rejected orders as costless to the attacker: "each would page an operator, up to twenty a day per account, free to an attacker".
   - An offer is "a live listing that can change or disappear" (`13:979`). Robot's standard listing has no stock field, and I found no check that an offer is still listed before ordering. Two Sybils racing for one auction offer give one accepted order and one free rejection.
   - The €59 minimum fee was observed on one date, per location (`08:141-143`).
4. Auction price:
   - Two orders cost "about €0.16" at provider cost (`08:380`). At `ADR-0033`'s example 20% margin (`LDG-24` sets no default), that is about €1.9 a day per account on the auction channel, and only for accepted orders.
   - The prepaid unit is an hour only where `price_hourly` is set.
   - `PRV-13b`'s reserve is not a cost: the attacker gets it back on delete.
5. `OPS-20` (requeue) is withdrawn (`README:241`).
6. `PRV-40` contradicts itself.
   - `02:880` says "nothing in this set counts" ordinary creates, yet `02:884` refuses once the budget is exhausted.
   - `rate_limited` ("Caller or provider throttled", `01:551`) could carry that refusal, but it is not on `OPS-11`'s admission-only list (`03:229-233`). `CNF-283` (`10:1270`) still says the refusal is "classified `failed` per `OPS-11`'s admission-only rule".

**Q2.** The deposit cannot be withdrawn but can still be spent (`ADR-0004`), and `API-34` reaps only unfunded pending tenants. With a share of k orders per day, N = ⌈20/k⌉ Sybils deposit N·M once and spend it on their own attack orders. The total is max(N·M, €1.9 × days), not the sum. At k=1 and M=€10, that is €200 up front, used up by day 105. The shares refill daily for the same Sybils. Meanwhile, an honest agent that needs k+1 boxes in a day is refused.

**Q3.**
- *More prepaid units as policy* is the only shape that raises the attacker's cost (24 units ≈ €46/day). But `ADR-0033` escapes `ADR-0011` only because "the provider charges the unit". An operator-chosen 24-hour minimum:
  - is the "minimum charge" `ADR-0011` rejected;
  - bills an agent who wanted two hours for 24;
  - adds the second pricing surface `ADR-0007` refuses.
- *Pacing* changes when slots are spent, not what they cost.
- *Committed runway* is released on delete: `LDG-39`'s "costs the tenant nothing".

**Q4.** No system path places an order: requeue is withdrawn, retry "enqueues a fresh `delete_machine`" (`04:1014`), and resolution only reads. Honest use can exhaust the budget on its own:
- 21 agents per account and channel in a day;
- one principal whose `SEC-39` create integer is at least 20 per hour;
- retries of sold offers, if rejected requests count;
- `PRV-34` conformance runs on a production account.

**Q5, don't build.** On the auction channel the attacker pays about €700 a year per account, or about €0 if rejected requests count. The operator loses about €0 and earns the margin. What it loses is min(honest demand, 20) auction sales a day per account, and demand before launch is zero. Past 20 a day the limit binds honest demand anyway, and the cure is more accounts or a higher limit from Hetzner.

**Edits:**
- `PRV-40`: correct the facts; a per-account, per-channel gate that closes on the 403; an alarm.
- `PRV-44`: move `order_budget` onto `ordering_channels[]`.
- `OVR-19`: the `00:380` row.
- `OPS-11`: the admission-only list.
- `CNF-283`.
- `08:399-401`.
- A new ADR for the accepted residual risk and the rejected shapes.

`ADR-0034`'s "or a sibling requirement" branch survives. No Lean declaration covers the budget. Adding `LDG-44`'s minimum to `OVR-19` is owed separately.
