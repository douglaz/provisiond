**Final: C**

- **A — ACCEPT.** No missed site found. No repair required.
- **B — CANNOT ACCEPT.** No missed site found; my objection is repeated ownership of the scope predicate. The exact replacement package I accept instead is **A, as printed**.
- **C — ACCEPT.** No missed site found. No repair required. This is my preference.
- **D — CANNOT ACCEPT.** No missed site found; it has B’s repeated-ownership problem. The exact replacement package I accept instead is **C, as printed**.

My B/D dissent is a document-ownership objection, **not a verified blocking loss under notes.md rule 3**. I found no trace in which their printed billing predicates violate the fixed owner decision.

**Packet verification.** HEAD is `3109b5b44eae17e288cf52aaa976993bd8c5626c`. I read the brief and notes whole, checked the supplied coverage files, compared the pinned evidence blocks against this clone, and checked the explicitly retained candidate blocks. Those quotations match. I found no verified brief error changing the question’s premise, so notes.md rule 6 supplies no reason to void this question. The post-pin owner decision is clearly presented as packet evidence, rather than attributed to the pinned repository.

The decisive wording in C’s `DOM-16` is:

> “whether an upfront charge or hourly or other recurring machine rental; neither a setup fee nor immediate payment is required”

That resolves the motivating ambiguity. Its capability condition—

> “an ordering capability … that permits a paid create”

—applies to the named provider account’s capability, without requiring a new descriptor field or a provider-name classification.

B/D express the same substantive scope, but reproduce its definition in `PRV-10`, `API-15`, the configuration row, `DEF-17`, `WIR-17`, `CNF-34`, `CNF-55`, and the `CNF-342` paragraph. This conflicts with the repository instruction:

> “One rule, one home; everywhere else points at it.”

The maintenance consequence is concrete: a future scope amendment must synchronize independently written predicates across those sites. A/C give that definition one home in `DOM-16`. The exact existing packages A and C already provide the complete remedies; I am proposing no additional alternative or synthesized repair.

For **each form**, I found no omitted replacement site after inspecting the quoted evidence, supplied searches, and relevant references in the clone. In particular:

- The `WIR-17` replacement includes the paid-create scope and preserves “`acknowledge_purchase` MUST be literal `true`.”
- `OPS-43` retains its quoted phrases “explicit purchase acknowledgement” and “the account is configured to allow ordering”; both still occur in every proposed `PRV-10`.
- `WIR-29` says the listing’s capabilities “are the descriptor’s fields, rendered”; changing the descriptor condition therefore reaches discovery without another listing rule.
- `PRV-4`, `DOM-15`, and retained `CNF-18` keep the capability-withholding exception. Retained `CNF-19` still uses an internally permissive driver.
- The provider-notes matrix and `DEF-17` no longer leave competing active scope wording. Historical records need no rewriting.
- Retained `CNF-344` still says: “Another channel’s mere declaration authorizes no new ordering capability.”

**Admission traces.**

For an otherwise valid hourly create with a positive provider rental price, no setup fee, `allow_orders: false`, and `acknowledge_purchase: true`:

1. A/C classify it through “paid create”; B/D state the equivalent billing predicate directly.
2. Every proposed `DOM-16` requires withholding `provision_virtual`.
3. `DOM-10` requires gating “before the driver is called, **including create**.”
4. `API-7` step 5d says: “A refusal stops here and is not collected by the tail.”
5. The existing portion of every proposed `CNF-55` asserts HTTP `501`, `unsupported`, account/capability details, `retryable: false`, and no operation or commitment.

The existing low-balance assertion remains: the capability refusal has no `details.refusals` or `details.not_checked`, even when the balance cannot fund the create. C/D additionally instantiate this trace with the hourly fixture and require zero driver create calls and zero simulated billing starts.

For the hourly create with `allow_orders: true` but acknowledgement absent or false, the proposed `PRV-10` still requires “Both, not either,” and `WIR-17` still requires literal `true`. `API-7` step 5 is “deserialize and validate the body,” before the capability gate and purchase tail. C/D explicitly require separate absent and false cases returning HTTP `400`, `invalid_request`, `/acknowledge_purchase`, and `retryable: false`, with no operation, commitment, provider request, driver create call, or simulated billing start.

A/B impose that same obligation, but do not explicitly demand these hourly admission fixtures. Their opening `CNF-55` assertion requires rejection without both conditions, and their worker cases retain acknowledgement validation. The absence of the additional hourly fixtures is a coverage difference, not a contradiction or rule-3 blocking loss.

Stored replay remains distinct from a fresh create. `API-7` step 5a says an equal fingerprint under the same principal/key “returns the stored result,” before step 5d. Every form preserves `CNF-55`’s same-key, same-body replay assertion. C/D’s fresh-key instruction prevents that replay path from accidentally satisfying a new-create test.

**C/D claim-time traces.**

After admission with both settings true, restarting while the hourly create remains queued and unclaimed with only `allow_orders` changed to false removes its ordering capability. The proposed assertion requires refusal at `OPS-43` step 3: `unsupported`, matching account/capability details, `retryable: false` on error and operation view, `failed`, full commitment release, no setup-fee or first-unit debit, and no provider request—including no List offers read. Zero simulated billing starts makes the spending consequence explicit.

For the separately admitted hourly create whose stored acknowledgement is removed, `OPS-23` requires:

> “Validation that was performed at the API boundary MUST be repeated in the worker before the driver is called.”

Its caller-field rule requires `invalid_request` and `retryable: false` on both error and operation view. C/D assert those results at step 3, including `/acknowledge_purchase`, full release, no debit, no provider request, and zero simulated billing starts.

The catalogue/resource distinction is correct. `PRV-42` says:

> “Catalogue products do not take this claim.”

C/D accordingly state that the hourly catalogue fixture holds no resource-offer exclusion. They preserve the original resource-offer admission and exclusion-release assertions in the existing `CNF-55` case and the relevant dependents.

**Collateral effects and preservation.**

I found no unintended changed error, ordering rule, exclusion lifetime, retention rule, theorem statement, guard hypothesis, or retained negative-control assertion.

There are visible scope and fixture changes worth recording:

- Every form changes `WIR-17`’s previously unqualified literal-true rule to a paid-create condition. For a genuinely free create, that sentence no longer independently requires acknowledgement. This is an expressly offered scope correction, not an invisible editorial change.
- Every form selects paid fixtures in `CNF-34` and the acknowledgement paragraph of `CNF-342`. The missing api-filled field, caller-field error distinctions, complete-record controls, and install assertions remain. I found no prescribed free-create assertion that this removes.
- `CNF-364` now explicitly supplies `allow_orders: true` and `acknowledge_purchase: true`, allowing its intended List offers capability refusal to remain reachable.
- Retained `CNF-182`’s “API returns a `Cancelled` transaction” wording remains a pre-existing boundary/test-mode concern. Broadening the paid-create scope does not introduce it.
- The inspected formal admission model explicitly states that “descriptor construction [is] outside this model.” The proposals do not change its supplied capability Boolean, the capability-before-tail theorem, or its negative witness.

Mixed free/paid offers do not produce a new ambiguity requiring repair. If one account capability permits both, it “permits a paid create”; false therefore withholds the entire capability. Even a free offer using it is then refused by the capability gate. With the flag true, the acknowledgement condition applies to paid creates. This preserves the offered account-level mechanism rather than introducing a per-offer runtime capability decision.

C/D’s fixture is expressly otherwise sellable and internally permissive, with a successful control. Its statement—

> “it does not authorize sale of a live offer withheld under `PRV-13b` or `PRV-31`”

—preserves the separate live-sale restriction.

The strongest reason to prefer **A’s minimal footprint** is that its normative scope is already sufficient: it changes the definition and dependent wording while retaining existing checks, avoiding additional fixture detail and future checklist maintenance. A missing new hourly test is not proof that A permits hourly spending with ordering off.

My actual pick remains **C**. It keeps the scope definition in one place and expressly tests the precise hourly/no-setup-fee failure, independently tests acknowledgement with ordering enabled, and covers both claim-time failures with simulated billing observations.

This was a read-only review. No source, Git state, tracker, or panel record was changed; no gates, builds, runtime tests, provider calls, or subagents were run.