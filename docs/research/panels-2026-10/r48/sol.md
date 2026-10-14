Q31 at `3639a80`: **KEEP**, while correcting the threat model.

1. **Today’s failure path.** After order acceptance, `PRV-5` requires “Known acceptance MUST remain `true` on every later error”; `OPS-11` makes acceptance an ambiguity condition “whatever the later error kind or status.” Therefore a failed required cancellation GET, including `rate_limited`, sends create to `needs_reconciliation`. There is no absorption rule comparable to cancellation’s read-back exception (`PRV-13`). The commitment remains sized from the declared bound: `PRV-31` says “it MUST NOT resize the commitment”; `LDG-39` says the fee and prepaid unit “remain reserved and are parked.” While blinded, settlement also cannot pass `OPS-27`: “a failed confirming read likewise cannot establish success.” This is unresolved create, rather than a stalled delete episode. Recovery is not guaranteed within an hour (`08-provider-notes.md:478`).

2. **Keep’s worst case.** `PRV-40` documents “20 requests per day” on each order endpoint. Standard and auction are the machine-ordering channels (`08-provider-notes.md:119`): their allowances permit 40 purchases together, hence 40 additional reads, **20% of 200**, assuming one read per delivery within one allowance. That is **not a proven hourly maximum**. Hourly pacing was rejected (`ADR-0036:61`); orders remain “`in process` with no documented bound” (`OPS-33`), so earlier deliveries can bunch. Reset/counting semantics also remain unverified (`PRV-40`). No fraction below the whole shared counter is established.

   Exhaustion blocks sweeps, create confirmations and absence confirmations (`ADR-0037`, Q28). Attachment endpoints remain separate, but absence writes still require “a complete account pass” (`OPS-32`). Rescue `/boot` reads and cancellation POST were unaffected; reset sharing remains unknown (`08-provider-notes.md:478`). Calling all rescue traffic starved would overstate the evidence.

3. **Drop’s worst case.** Exposure is actual provider cost through contractual exit beyond collectible funding; keeping also cannot undo that purchased liability. `LDG-63` explicitly says “cost beyond it after a provider deviation is operator-borne.” The documented fallback, “30 days to the end of the month,” can mean roughly two months’ rent, but individual contracts prevent treating that as a universal ceiling (`08-provider-notes.md:176`).

   Cancellation POST already returned `earliest_cancellation_date` (`docs/research/panels-2026-10/r45/live-session2.txt:26`); future-term rejection versus scheduling remains unverified (`08-provider-notes.md:176`). Invoices eventually account for missed cost—“the invoice supplies anything missed” (`LDG-75`). No contract-term audit is specified in `OPS-32`’s state/absence sweep.

4. **Alternative and vote.** Deferring discovery to that existing POST has evidence support, but changes the money rule: `LDG-33` says unavoidable minimum-term cost “MUST NOT be advertised as spendable runway while it is still in the future.” No cheaper source already read at create is documented; Q28 explicitly rejected a local read budget/reserve.

   **KEEP:** retain `PRV-13c`’s “order, then **read**” and `PRV-31`’s actual-date protection. Add create traffic to Q28’s threat model and a post-order-read failure fixture to `CNF-147`/`CNF-356`. Early discovery protects remaining funding before it is consumed.

**Strongest case for the other side (written on request)**

DROP need not hardcode immediacy: `PRV-31` already permits a bound “declared in the descriptor” or “reported on the offer.” The extra read discovers liability after purchase without resizing the commitment, consumes scarce shared capacity, and can obstruct settlement. Rely on that declaration, learn deviations from cancellation responses and invoices, and explicitly accept the later-discovery risk.

Both unpiped gate runs passed; tracked files remain unchanged.