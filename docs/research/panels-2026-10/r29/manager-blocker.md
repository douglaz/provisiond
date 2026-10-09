## Owner question 1: how the deadline enters wind-down

Relevant passages:

- `02-provider-contract.md:265-268`, PRV-13b's sizing prose: "size `wind_down_cost` as **detection interval + `PRV-36`'s effective visibility window + margin**, subject to the provider-call deadline in `OVR-19` and the machine-wait term below".
- `00-overview.md:411-413`, OVR-19: the deadline is "measured from dispatch for each provider call" and sizing "MUST cover this bound as well as the effective visibility window".
- `10-conformance-checklist.md`, CNF-329: "including when either is larger".
- ADR-0037 Decision 2: "`OVR-19` gains a provider-call deadline, so the case where no reply ever comes is bounded too."

These do not specify whether the latency allowance is the maximum of the deadline and visibility window, their sum, or a constrained configuration in which the existing window already covers the deadline. With a 600-second deadline and a 30-second window, maximum and sum contribute 600 and 630 seconds respectively before the common detection, hold and margin terms. Reading only the displayed formula contributes 30. These are different commitments, not different phrasings of one implementation.

CNF-329 does not imply maximum uniquely: sum also covers either larger term. I accept Fable/Opus's unresolved-composition finding, but not Fable's suggestion that the checklist already settles it as maximum.

**Recommended clarification, not an adopted rule:** have PRV-13b explicitly own the clock origins and composition. If both bounds run from the same mutation dispatch and overlap, use their maximum; if a later call introduces a sequential wait, identify that wait explicitly. OVR-19 should register the parameter and point to the sizing owner, and CNF-329 should demonstrate the owner's exact rule. I am not choosing the reserve formula or treating a reviewer preference as authorization.

## Owner question 2: scheduled attachment completion and meter boundary

Relevant passages:

- ADR-0037 Decision 4: "A release whose result carries a future effective date writes no `released_at`". It names Robot IPs/subnets as the motivating example.
- `02-provider-contract.md:481-484`, PRV-45: "A successful release with no future effective date MUST write the row's `released_at` in its terminal transaction" and "A release whose result carries a future effective date MUST NOT write `released_at`, including when resolved `applied`."
- `12-billing-and-ledger.md:323-328`, LDG-32: "MUST meter each billable attachment on its own identity until `released_at` is set", and "MUST NOT sell an offer whose attachments have no bounded automatic cleanup unless the operator has explicitly accepted and capped that exposure."
- `12-billing-and-ledger.md:947-949`, LDG-38: "for an attachment release, it is `released_at`".
- CNF-328: "This case asserts no transition at the future date."

Withholding the immediate release write is required by the accepted ADR. What happens later is not specified. A successful scheduled release can leave the attachment metered and the commitment/tombstone gate open after the provider's effective date. Existing completed-release and operator paths are not a scheduled-attachment finalization policy. The machine-only scheduled cancellation rules do not silently supply one for attachments.

The owner needs to distinguish these readings:

- The known effective date ends customer metering, with later evidence completing release bookkeeping.
- Only a later authoritative observation/completed-release write ends metering, at that observation's instant.
- Completion is intentionally operator-driven, with the corresponding LDG-32 exposure acceptance/cap and commercial limitation stated explicitly.

These differ in who pays between the scheduled date and later evidence, and in whether the system requires human intervention. The owner must also say what a resolution arriving after the originally future date means: mere passage of that date, proof of completion, or some other evidence. "Future" without its reference instant does not settle that delayed case.

**Recommended clarification, not an adopted design:** explicitly decide whether scheduled attachments use the scheduled-machine meter-boundary policy, and identify an evidence-driven completion path without automatic replay of the release mutation. State the exact stop instant and which writer records it. Do not infer the policy from a nullable timestamp or add a sweep, timer, schema, or new mutation based only on this recommendation.

## Missing wire representation and dependent repairs

These are concrete defects to repair after the relevant owner clarification, recorded on the same ticket rather than filed as new beads.

**Future-date operator resolution lacks a specified carrier.** WIR-35 (`13-wire-contract.md:861-874`) specifies an `effective_cancellation_date` for `delete_machine` and gives `release_attachment` the `applied`/`not_applied`/`abandoned` verbs, without defining the scheduled-release date form. WIR-2 says "Unknown fields in a request body MUST be rejected"; the wire introduction says "Where a shape disagrees with prose elsewhere, this document wins". PRV-45 and CNF-328 now require the scheduled `applied` case. A strict implementation cannot invent the missing body shape, and a bare `applied` cannot convey whether the operator established scheduling or completed release. Fable and Sol independently identified this; I verified the passages. Resolve the carrier and delayed-resolution semantics with question 2. Do not remove the required conformance case merely to hide the gap.

**API-65 overstates the tombstone effect.** `04-api-contract.md:1077` says "Either is what opens `STO-18`'s tombstone gate". A successful future-date API release now leaves it closed. Qualify that requirement's statement under PRV-45, as the Implementer already qualified CNF-293. This is a false behavioral statement inside a requirement, not merely cosmetic wording.

**ADR-0035's accepted release rule needs an amendment record.** Its Decision says "A release that resolution finds applied writes `released_at`", and its Consequences repeats the write. Record ADR-0037's exception there so the earlier accepted decision is not an unconditional competing rule. This does not reopen `pv-ucs.3`'s separate unknown-acceptance error-kind question.

