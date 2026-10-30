Final: C

| Printed form | Verdict | Missed sites | Required repair |
|---|---|---|---|
| A | ACCEPT | None found | None |
| B | ACCEPT | None found | None |
| C | ACCEPT | None found | None |
| D | ACCEPT | None found | None |

These are acceptances of the printed packages without edits. My preference is C.

I checked the pinned evidence excerpts and retained blocks against this clone at `3109b5b44eae17e288cf52aaa976993bd8c5626c`; they match. I found no verified premise-changing brief error and no other source misquotation. Applying notes.md rule 6 exactly, I have no basis to void this question’s tally.

**Scope and coverage.** A/C define the relevant property once: “A **paid create** is a create that starts new provider billing to the operator,” expressly including “hourly or other recurring machine rental” and requiring neither a setup fee nor immediate payment. B/D print that same property at the consuming sites. None depends on a company allowlist, invoice date or undefined provider class.

For each form, I found no missed replacement after inspecting the supplied coverage list and following its references. The packages address `DOM-16`, `PRV-10`, `API-15`, the configuration row, provider-notes Create row, DEF-17 paragraph, wire field rule and the printed checklist dependents.

The retained consumers remain usable:

- `OPS-43` quotes “explicit purchase acknowledgement” and “the account is configured to allow ordering”; both strings survive in every proposed `PRV-10`.
- `API-7` retains “gate a create on its ordering capability” and “A refusal stops here and is not collected by the tail.”
- `DOM-15` retains its exception for “An ordering capability withheld under `DOM-16`”; `PRV-4` likewise keeps that withholding exception.
- `WIR-29` says the listing’s capabilities are “the descriptor’s fields, rendered.” The revised descriptor condition therefore reaches discovery without introducing another declaration mechanism.
- The retained `CNF-344` statement, “Another channel’s mere declaration authorizes no new ordering capability,” remains compatible.

**Hourly create, ordering off.** Consider the otherwise valid hourly catalogue fixture, with positive recurring provider price, no setup fee and `acknowledge_purchase: true`.

In A/C, the proposed definition makes this a paid create. Their `DOM-16` then makes an ordering capability “that permits a paid create MUST be conditional” on `allow_orders`; with the flag false, the descriptor “does not declare that capability.” B/D reach the same result through their expanded predicate.

`DOM-10` requires capability gating “before the driver is called, **including create**.” Consequently, the listing omits `provision_virtual`, and the fresh create fails at admission step 5d. Every form’s `CNF-55` retains the HTTP `501`/`unsupported` assertion, account and capability details, `retryable: false`, and no operation or commitment. Its deliberately insufficient-balance case also retains **no** `details.refusals` or `details.not_checked`: the ordering refusal precedes the purchase tail.

C/D additionally require this outcome on the explicit hourly fixture, with no provider request, zero driver create calls and zero simulated billing starts. Their permissive driver and successful control make the rejection meaningful.

**Hourly create, ordering on, acknowledgement absent or false.** Enabling the capability satisfies only the configuration half. Every proposed `PRV-10` still says “Both, not either.” Every proposed `API-15` requires the request’s acknowledgement, and every proposed `WIR-17` requires `acknowledge_purchase` to be literal `true` within the same billing scope.

Thus omission and `false` fail body validation before an operation or commitment opens. C/D explicitly assert separate HTTP `400`/`invalid_request` cases, `details.field: "/acknowledge_purchase"`, `retryable: false`, no provider request and zero billing starts. They also require a fresh-key control with both values true to call the fixture driver exactly once and record one simulated hourly billing start.

A/B state the same obligation but lack those dedicated hourly admission fixtures. That is a difference in demonstration strength, not a narrower billing scope or a contradiction. Notes rule 3 expressly says, “A merely absent new runtime test is not a contradiction in the unchanged base.”

**C/D’s worker cases.** The hourly restart case admits while both authorizations hold, leaves the operation queued and unclaimed, and changes only `allow_orders`. The proposed assertion then rejects at `OPS-43` step 3 with `unsupported`, the account/capability details and `retryable: false` on both error and operation view. It requires `failed`, full commitment release, no setup-fee or first-unit debit, no provider request—including no List offers read—and zero billing starts.

The separate stored-acknowledgement case removes only that caller field. `OPS-23` says a missing caller-supplied field “fails `invalid_request` naming the field,” with `retryable: false` on both error and view. C/D assert that step-3 outcome and the same release and no-provider-request consequences.

These follow the unchanged worker ordering: `OPS-43` says caller-field checks “run first, then the checks on fields the `api` wrote at admission, then the capability gate.” The subsequent List offers read remains at step 4.

The exclusion distinction is preserved. `PRV-42` says, “Catalogue products do not take this claim.” C/D accordingly give the hourly catalogue fixture no resource-offer exclusion. They retain the original resource-offer case’s acquisition and settlement-release assertions; the revised `CNF-342` acknowledgement paragraph retains them too. The revised `CNF-364` supplies both authorizations before removing only `list_offers`, preserving its intended step-4 failure.

**Collateral effects and maintenance.** I found no unintended blocking loss meeting notes rule 3. The existing refusal ordering, stored replay, error/view agreement, commitment release and resource-offer exclusion checks remain. Every form retains `CNF-55`’s “same-key, same-body replay … returns its stored result”; the revised scope does not move that replay behind the capability gate.

There are substantive distinctions to disclose:

- All forms condition the formerly unqualified wire sentence, “`acknowledge_purchase` MUST be literal `true`,” on the selected billing scope. That sentence consequently no longer imposes the acknowledgement on a genuinely non-billing create. This is part of the offered scope correction, not a purely typographical change.
- All forms select paid fixtures for the acknowledgement-dependent `CNF-34` and `CNF-342` cases.
- C/D add implementation-conformance obligations. Their simulated billing assertions are stronger than A/B’s existing checks.
- B/D distribute the billing predicate across the normative requirements, catalogue and dependent text. That is a departure from the repository’s drafting discipline: `AGENTS.md` says, “One rule, one home; everywhere else points at it.” The repeated predicates currently agree, but future amendments must keep those copies synchronized. I do not treat that maintenance objection as a verified blocking loss under notes rule 3; it is a substantial reason to prefer A/C.

A mixed free/paid capability creates no ambiguity requiring repair. The proposed condition concerns a capability “that permits a paid create.” If it permits both free and paid creates, false withholds the **whole capability**, so free creates through it are refused too. The wording does not authorize retaining that capability and substituting a per-offer runtime spending gate.

The retained Robot assertion about an absent acknowledgement returning a `Cancelled` transaction is a pre-existing concern: the same text is pinned and retained in every form. It is not a newly introduced inconsistency. Likewise, C/D explicitly say the fixture “does not authorize sale of a live offer withheld under `PRV-13b` or `PRV-31`.”

**Strongest argument for the minimal footprint:** A resolves the wording question, centralizes the scope and preserves the existing checks without adding fixture and simulated-billing obligations. Nothing in the settled decision requires a newly specified hourly fixture, and the revised obligations already cover hourly creates.

My actual pick remains **C**. It combines that single scope owner with direct checks of the motivating hourly failure and the independent acknowledgement requirement, while preserving the existing assertions.

This was a read-only assessment of the proposed text. I ran no gates or runtime tests and changed no source, Git state or tracker records.