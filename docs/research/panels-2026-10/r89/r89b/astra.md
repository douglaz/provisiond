I accept **C′ exactly as printed**. I revise my earlier acceptance of A/C: disclosure of a scope change does not authorize it, and the absence of a live free v1 offer does not dispose of a loss in the specification’s unconditional requirement.

| Printed form | Verdict | Reason |
|---|---|---|
| A | **CANNOT ACCEPT** | Removes unconditional acknowledgement coverage and narrows worker fixtures. |
| B | **CANNOT ACCEPT** | Same loss; also duplicates the scope predicate across consuming sites. |
| C | **CANNOT ACCEPT** | The hourly cases do not repair the unconditional acknowledgement loss. |
| D | **CANNOT ACCEPT** | Same loss; also duplicates scope ownership. |
| C′ | **CAN ACCEPT** | Preserves the existing wire/worker coverage while centralizing paid-create scope and adding explicit hourly demonstrations. |

These are judgments of the printed forms without repairs. My preference is also C′. Its acceptance is unqualified as a proposed exact form; adopting its additional conformance obligations still requires owner approval.

I read the complete brief, `notes.md`, and the supplied prior answers. This clone’s HEAD is `3109b5b44eae17e288cf52aaa976993bd8c5626c`. The packet’s pinned evidence ranges and explicitly retained candidate blocks match the clone. Comparing C and C′ confirms that their differences are exactly the advertised retention of `WIR-17`, `CNF-34`, and the `CNF-342` acknowledgement paragraph.

Applying rule 6 exactly—“A verified brief error that changes the question’s premise voids its tally”—I find no basis to void. The prior answers’ disputed inferences warrant correction, not an invented void rule.

**The manager’s proposed loss is verified as a normative loss.** Its strongest basis is the unconditional MUST, rather than a claim that the checklist already mandates a distinct free-create test.

At `13-wire-contract.md:665–666`, `WIR-17` says:

> “`acknowledge_purchase` MUST be literal `true` (`API-15`, `PRV-10`).”

There is no billing qualification. The zero-price premise is supported by the specification: `CNF-315` includes “a zero recurring price and a null floor”; `DOM-9` separately permits setup fee `"0"` “where the channel charges none”; and `LDG-39` expressly addresses “a positive `seconds` at a zero recurring price with a null floor.” This is a modeled case, not evidence of an available live free offer. Zero `first_unit` alone would not establish it.

Take the manager’s otherwise valid, genuinely non-billing create: zero recurring provider price, null floor, zero setup fee, enabled account with the necessary capabilities, fresh key, and acknowledgement `false`.

- **Pinned admission:** `API-7` step 5 says “deserialize and validate the body.” The false value violates `WIR-17` before replay, capability gating, or pricing. `DOM-17` maps `invalid_request` to HTTP `400`; `WIR-9a` specifies a field pointer “also where the named field is absent.” The offending field is `/acknowledge_purchase`.
- **A–D:** Their wire condition excludes this create on the non-billing reading. Their proposed `PRV-10` and `API-15` use the same condition. `OVR-6`’s “Destructive and billable actions” supplies no unconditional substitute. Therefore the acknowledgement-based refusal is no longer required.
- **Worker counterpart:** Start with a valid admitted record and remove only its acknowledgement. `OPS-23` says boundary validation “MUST be repeated in the worker before the driver is called”; a missing caller field “fails `invalid_request` naming the field,” with `retryable: false`. Its present-but-invalid rule reaches `false` too. At the pin, this applies independently of price. A–D remove that unconditional basis and restrict the relevant fixtures to paid creates.

Removing this required refusal does **not** prove that every implementation must admit the request. Other conditions can still refuse it. That distinction does not erase the lost obligation.

The fixture narrowing is also substantive: `CNF-34` changes “On separate creates” to paid creates, including its api-filled-field fixture; `CNF-342` changes “a complete, valid resource-offer” create to a paid one. Neither pinned fixture explicitly demands a separately named free case, so I do not claim a previously enumerated free-case test disappears. The normative loss independently satisfies rule 3.

The owner chose **“Every paid create (Recommended)”**, with the explanation:

> “The switch and the per-request purchase acknowledgement cover any create that starts billing, hourly cloud VMs included.”

That establishes required coverage of paid hourly creates. It does not say that acknowledgement must cease to be required elsewhere. My prior answer’s description of the narrowing as an “expressly offered scope correction” confused an offered amendment with an authorized amendment.

C′ resolves this without conflicting requirements. Its `API-15` says paid creates “MUST carry” acknowledgement; it does not say **only** paid creates must do so. Retained `WIR-17` supplies the broader literal-true requirement. The pin already combined narrower provider prose with an unconditional wire rule.

The strongest arguments in the prior answers remain useful, with limits:

- Fable, sol, and my prior answer correctly value one scope owner and direct hourly demonstrations. C′ retains both. The live-sale restriction does not eliminate modeled zero-price cases; `ADR-0010` expressly distinguishes “which offers may be sold” from “the three-driver specification or its conformance scope.”
- Opus identifies the decisive unconditional-rule loss. However, the asserted necessary movement of the offer-price read is unproved. `API-7` still says the tail runs “After steps 1–5d” and reads the stored listing “in that snapshot.” No candidate changes that order, and account classification need not require pricing an individual offer.
- Opus’s “wholly undisclosed” characterization is too broad given the supplied parent-brief wording. Its assertion that no checklist case mentions absent acknowledgement also overlooks retained `CNF-182`’s “acknowledgement absent” and `Cancelled` assertion. That is not the new core-admission HTTP `400` demonstration.
- A missing new hourly fixture is not a blocking loss. My rejection of A rests on its weakening, not its smaller test footprint.
- B/D’s repeated predicates remain contrary to “One rule, one home; everywhere else points at it.” That maintenance objection is distinct from the verified normative loss.

**C′ preserves the required admission and claim traces.**

For an otherwise valid hourly cloud create with positive recurring price and no setup fee, C′’s definition expressly includes “hourly or other recurring machine rental” and says “neither a setup fee nor immediate payment is required.”

With ordering **off** and acknowledgement **true**, its account capability “permits a paid create,” so the descriptor withholds `provision_virtual`. `DOM-10` requires gating “before the driver is called, **including create**.” At `API-7` step 5d, “A refusal stops here and is not collected by the tail.” C′’s hourly assertions require HTTP `501`, `unsupported`, account/capability details, `retryable: false`, no operation, commitment or provider request, and zero driver creates or simulated billing starts.

With ordering **on**, absent or false acknowledgement violates retained `WIR-17` at body validation. The hourly assertions require separate HTTP `400`/`invalid_request` outcomes with `/acknowledge_purchase`, `retryable: false`, and no admission or provider effects. The both-true control requires exactly one driver create and one simulated hourly billing start.

The existing `CNF-55` low-balance case retains “no `details.refusals` or `details.not_checked`”; its replay case retains “returns its stored result.” `API-7` places equal-fingerprint replay at step 5a, before step 5d. Fresh keys in the new admission cases prevent replay from masking the tested gate.

At claim, `OPS-43` retains the order: status, stored channel closure, then step-3 validation, where caller-field checks “run first, then the checks on fields the `api` wrote at admission, then the capability gate.”

- Restarting an admitted hourly create with only `allow_orders` false reaches the capability refusal at step 3: `unsupported`, matching details, non-retryable error/view, `failed`, full release without fee/unit debit, and no provider request or List offers read.
- Removing only the stored acknowledgement reaches caller-field rejection first: `invalid_request`, `/acknowledge_purchase`, non-retryable error/view, and the same settlement and no-provider effects. C′ preserves that requirement for non-billing creates too.

Mixed free/paid capabilities remain withheld as a whole when disabled. C′ does not introduce a per-offer replacement capability gate.

**I find no additional loss in C′ as printed.** Its new obligation is the explicit hourly conformance package: admission refusals, successful control, restart, stored-field corruption, and simulated-billing observations. These are meaningful additional demonstrations, but not exhaustive driver coverage.

The original resource-offer cases retain their exclusion acquisition/release assertions. The hourly catalogue case correctly holds none: `PRV-42` says “Catalogue products do not take this claim.” `CNF-364` explicitly supplies both authorizations before removing only `list_offers`, preserving its step-4 refusal and error/settlement assertions. The retained `CNF-182` boundary ambiguity predates C′.

C′ changes no gate script, Lean statement, guard hypothesis, or negative witness. The inspected admission model says “descriptor construction [is] outside this model”; unchanged formal capability-before-tail evidence therefore does not independently prove the amended descriptor scope. Relevant quotation substrings remain intact, including the worker’s `PRV-10` quotations and `CNF-34`’s wire quotation. I claim no gate result.

The owner’s 2026-10-28 instruction—“For such wording questions, try to solve by getting a consensus of the panel”—supports this consensus recommendation. **C′ is not wording-only under item 4:** its added hourly conformance obligations require owner approval of the exact form. I infer no other reader’s acceptance and leave settlement to the manager.

This was read-only. I ran no gates, builds, runtime tests, provider calls, or subagents, and changed no source, Git state, tracker, or panel records.

Final: C′