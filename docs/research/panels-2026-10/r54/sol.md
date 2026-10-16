I reviewed `pv-hsm` at `6853d62`: **FAIL—bug in the dispatch contract. Pick A**, with corrections to the framing.

1. **Not redundant.** `PRV-42` requires confirming the offer is “still listed”; `DOM-9` expressly filters the “customer offer listing.” Presence in the provider feed does not establish sellability (`02-provider-contract.md:1232`; `01-domain-model.md:188`).

   `OPS-23` says “Validation that was performed at the API boundary MUST be repeated,” but never defines whether that includes purchase-tail eligibility. `API-13`’s introductory “Validation happens at the boundary *and* again in the worker” supplies no explicit limit. Conversely, `OPS-11`’s admission-only kinds “MUST NOT be emitted by a worker,” defeating an interpretation that repeats every boundary gate (`03-operation-lifecycle.md:1623`, `:234`; `04-api-contract.md:952`). Thus “so the worker repeats” is an inference. I would not certify **both conformant** either: `PRV-31` says “per offer and before any order,” while `PRV-13b` says allowance offers “MUST NOT be sold” pending evidence (`02-provider-contract.md:544`, `:280`).

2. **Home: `OPS-43`. Proposed addition:**

   > At claim, before any provider mutation, the worker MUST repeat the named offer’s sellability checks under `PRV-13b` and `PRV-31` using the current descriptor and current driver List offers result, resolving date bounds against provider-local today at that check; an unsellable offer MUST fail the create with the `WIR-9a` unsellable-offer error.

   Specify `kind: invalid_request`, `details.reason: "offer_not_sellable"`, `retryable: false`, without purchase-tail arrays. This is deterministic `failed`, outside the admission-only kind list: the create row says “otherwise `failed`” (`OPS-11`).

   **Fact 7 needs correction:** the shape exists. `WIR-9a` defines `reason: "offer_not_sellable"`; `WIR-10b` makes operation errors “exactly `WIR-9`’s inner object.” The missing piece is its required production at dispatch (`13-wire-contract.md:130`, `:274`).

   **Extend `CNF-241`:** keep price unchanged, change cancellation bounds or traffic terms between admission and claim, repeat across restart, and assert refusal before mutation and commitment release. Correct its “no provider call” to “no provider mutation” so reads remain possible (`10-conformance-checklist.md:2547`; `LDG-32`: “the create fails deterministically”).

3. **Read:** propose sharing one current List offers result across price, presence and sellability. `PRV-44` permits both bounds to be “reported on the offer instead”; `PRV-13c` requires allowance `traffic_bound` “from current provider terms in List offers.” No new driver operation is necessary. One HTTP request is not guaranteed: List offers “May aggregate several provider endpoints”; describe is “Pure and synchronous” (`02-provider-contract.md:75–118`, `:575`). B needs an additional traffic source: the snapshot enumeration lacks traffic (`05-persistence.md:384`).

4. **Costs:** A orders neither changed offer; rejection means “Never debited” and release (`LDG-39`). B, once its traffic source is specified, and C order both. Ordinary fee/unit/compute accounting remains applicable; the extra minimum-term exposure falls under Q25’s “Cost past the declared bound is operator-borne.” Traffic overage likewise creates “no…customer traffic debit” (`ADR-0037`, Q25; `LDG-39`, `LDG-38`, `LDG-75`).

   **Window:** no universal numeric maximum. `OPS-40` references a deployment’s “stated worst-case admission-to-start bound”; `OPS-33`’s “no timeout on an in-progress order” concerns **post-order** waiting, not admission-to-claim.

**Strongest case for the other side (written on request)**

For C: “before taking money” places eligibility at admission (`PRV-13b`). The explicit later checks name price and disappearance (`OPS-43`, `PRV-42`). Q25 already assigns subsequent deviation to the operator; another veto changes an accepted purchase.