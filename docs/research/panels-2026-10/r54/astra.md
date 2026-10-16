**Pick A; retain `bug`, but qualify the bead’s framing.** The dispatch policy is underspecified; “both are conformant” is stronger than the evidence, given `PRV-31`’s unqualified “MUST NOT be sold” and `PRV-13b`’s equivalent traffic prohibition.

1. **Not already settled.** `PRV-42` requires confirming the offer is “still listed”; it never says “sellable.” `DOM-9` separately says “The customer offer listing MUST include only offers sellable.” Reading the former as the provider listing fits `ADR-0036`’s “Free burns are closed where they start”; identifying it with the filtered customer listing is an inference, not an explicit requirement.

   `OPS-23` says “Validation that was performed at the API boundary MUST be repeated,” but `OPS-11` says admission-only kinds “MUST NOT be emitted by a worker.” Thus it cannot mean replaying the whole purchase tail. Neither “Validation happens at the boundary *and* again in the worker” (`04-api-contract.md:952`) nor `API-7` expressly settles whether sale eligibility belongs to that repetition. Moreover, “before the driver is called” cannot literally require a fresh driver read first.

   The snapshot alternative is incomplete: `05-persistence.md:384` enumerates the snapshot without traffic terms. Install eligibility’s different source is explicit: “The machine’s own copy of that list is what the install gate reads” (`03-operation-lifecycle.md:318`).

2. **Home: `OPS-43`. Proposed sentence:**

   > At claim, before any provider mutation, including temporary-key registration, the worker MUST obtain the named offer’s current terms and re-test sellability under `PRV-13b` and `PRV-31` using that offer and the current descriptor; an unsellable offer MUST settle the create `failed` with `invalid_request`, `details.reason: "offer_not_sellable"`, and `retryable: false`, releasing its commitment without debit.

   Add only a scope pointer in `OPS-23`. This explicitly permits the read needed for the check.

   Fact 7 needs correction: `WIR-9a` already defines “`invalid_request` / `offer_not_sellable` on create,” and `WIR-9` says its inner object is what the operation view embeds (`13-wire-contract.md:119–130`). Missing is the dispatch obligation, not the entire error shape. No `refusals` or `not_checked`: those belong “On create and extend-runway tail refusals” (`WIR-9a`). Classification follows `OPS-11`: “otherwise `failed`.”

   Extend **`CNF-241`** with unchanged-price fixtures changing cancellation and traffic terms, restart coverage, exact error/release assertions, and a still-sellable control. Replace its “no provider call” with “no provider mutation”; its existing live-price test already needs a read.

3. **Read sharing:** use one fresh driver List offers result for price, presence and terms. `PRV-44` allows both bounds “reported on the offer”; `PRV-13c` requires allowance terms “from current provider terms in List offers.” No separate engine-facing call is needed. One provider HTTP call is **not guaranteed**: List offers “May aggregate several provider endpoints” (`02-provider-contract.md:117`); the descriptor “MUST NOT perform network I/O” (:75).

4. **Costs/window:** A rejects both stories: setup/unit “Never debited”; commitment released (`LDG-39`). B and C order, assuming other dispatch checks pass. Customers pay ordinary authorized setup/unit/service; additional minimum-term exposure beyond the accepted bound is operator-borne (“Cost past the declared bound is operator-borne,” `ADR-0037`, Q25). Traffic creates “no … customer traffic debit” (`LDG-75`). B additionally needs traffic snapshot data.

   No universal queue-age maximum is specified. `OPS-40` names a deployment’s “stated worst-case admission-to-start bound” for signed URLs; `OPS-33`’s unbounded “in process” is **post-order**, not this create’s pre-claim interval.

**Strongest case for the other side (written on request)**

C avoids expanding ambiguous “validation” into commercial re-admission. Acceptance fixes the customer’s terms; Q25 already assigns deviations to the operator. This argues for explicitly accepting that exposure, although `ADR-0039` rejects “Accept the overage with an alarm.”