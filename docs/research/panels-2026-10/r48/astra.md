**Vote: KEEP, at `3639a80`.**

1. **Today:** a failed post-order read sends the create to `needs_reconciliation`. `PRV-5` says “Known acceptance MUST remain `true` on every later error”; `OPS-11` applies ambiguity “whatever the later error kind or status.” This includes `rate_limited`; `PRV-5` requires an alarm “naming the provider account and request path.”

   The commitment initially remains declared-bound-sized: `PRV-31` says “MUST NOT resize the commitment.” Release follows `OPS-33`’s bounded-negative-window rules, not this failure alone. While blinded, automatic attachment also fails: `OPS-27` requires “a direct read before it attaches anything.” **Dropping this GET therefore does not make creates succeed through an exhausted counter.** `PRV-13`’s absorbed-failure exception explicitly concerns “the accepted dated cancellation.”

2. **Keep’s cost:** `ADR-0036` documents “20 requests per day” per endpoint and rejects hourly pacing. Catalogue plus auction can spend one daily allotment in an hour: **40 discovery reads, 20% of 200** (channels: `PRV-38`; counter: `ADR-0037` Q28). The add-on allotment is separate (`ADR-0036`). However, **40 is not a proven hourly ceiling**: reset semantics remain unverified (`ADR-0036`), and pending orders have “no documented bound” (`OPS-33`), allowing deliveries accumulated across days to bunch. Q28’s traffic inventory omits these reads.

   Exhaustion blocks sweeps and confirming reads; `/ip`, rescue `/boot`, and cancellation POST remained responsive ([provider notes:478](https://github.com/douglaz/provisiond/blob/3639a80573619324f4f82374b17f51060005d3ab/08-provider-notes.md#L478)). Attachment absence nevertheless requires “a complete account pass” (`OPS-32`), so cleanup bookkeeping can stall indirectly. Rescue starvation from this counter is not established.

   **Drop’s cost:** uncovered provider rent through the actual cancellation date. “30 days to the end of the month” is qualified by individual contracts, not an absolute exposure cap ([provider notes:176](https://github.com/douglaz/provisiond/blob/3639a80573619324f4f82374b17f51060005d3ab/08-provider-notes.md#L176)). `LDG-63` says “cost beyond it after a provider deviation is operator-borne.” Keeping the read discovers liability; it cannot undo the purchase. Delete-time discovery may reject or schedule—the behavior remains unverified there. `LDG-75` says “the invoice supplies anything missed”; that is retrospective accounting. The sweep’s inventory has no documented earliest-date field ([research:194](https://github.com/douglaz/provisiond/blob/3639a80573619324f4f82374b17f51060005d3ab/docs/research/provider-verify-2026-10.md#L194)).

3. **Alternative evidence:** the cancellation POST already returned `earliest_cancellation_date` ([live-session2:26](https://github.com/douglaz/provisiond/blob/3639a80573619324f4f82374b17f51060005d3ab/docs/research/panels-2026-10/r45/live-session2.txt#L26)). Deferring discovery there saves the GET but loses early protection: `PRV-13c` says the cost is “not spendable runway.” No equivalent cheaper create-time source is established. Also, that session observed the date at cancellation, not delivery; delivery-date observations appear separately at [provider notes:415](https://github.com/douglaz/provisiond/blob/3639a80573619324f4f82374b17f51060005d3ab/08-provider-notes.md#L415).

   Dropping need not mean hardcoding: `PRV-31` permits a bound “reported on the offer.”

4. **Proposed changes:** retain `PRV-13c`’s “order, then **read**” and `PRV-13`’s “That separate post-order read remains required.” Add failed-post-order discovery coverage to `CNF-356`, whose current instruction merely retains `CNF-147`’s “post-order future-earliest-date and deviation cases”; amend Q28’s traffic inventory.

**Strongest case for the other side (written on request)**

Not my position: drop the extra term check. `PRV-31` already excludes bounds “later than the provider’s local today”; liability precedes discovery, and `LDG-63` assigns deviation to the operator. Reuse the cancellation response and accept delayed discovery, removing one shared-counter call and one create failure point.

Both required unpiped gate runs passed. Tracked files are unchanged.