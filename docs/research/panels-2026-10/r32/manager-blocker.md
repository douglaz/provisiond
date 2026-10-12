## Owner clarifications

### 1. What must startup validate about the activation minimum?

Passages:

- `00-overview.md`, `OVR-19`: “Startup MUST validate every startup-validated row and refuse to run on a missing or out-of-range value”. The new activation row has type “satoshis, large enough to purchase something” and startup validation “yes”.
- `04-api-contract.md`, `API-35`: “The minimum MUST be large enough to purchase something”. `12-billing-and-ledger.md`, `LDG-44`: “minimum funding amount” and “sufficient to purchase something”.
- `10-conformance-checklist.md`, new `CNF-345`: “configure below the price needed to purchase something: startup refuses each”.
- ADR-0036 Decision 3 only puts the minimum on the register. It gives no startup valuation source, offer selection, valuation instant, or unavailable-price rule.

Readings: startup validates a configured positive integer, with purchase sufficiency remaining an operator configuration obligation; or startup must obtain an offer and a usable conversion rate and compare a computed purchase price. The second reading can prevent startup during missing-rate or unavailable-offer conditions, whereas the first permits it. The new checklist chooses the second without specifying the inputs or failure behavior.

Recommendation, not an adopted rule: structural startup validation, preserving the existing operator obligation to configure enough to buy compute. If startup must price a purchase instead, the owner should specify the offer/rate basis and no-rate/no-offer behavior. Amend the register and checklist together after that answer.

### 2. Does channel closure stop creates admitted before the throttle?

Passages:

- ADR-0036 Decision 1: “after Robot answers `403 RATE_LIMIT_EXCEEDED` on an account and channel, the deployment refuses creates there for the `interval` Robot reported, before any provider call”.
- Current `PRV-40`: “refuse subsequent creates on that account and channel before any provider call”.
- `API-7` reads the closure in the admission tail; `CNF-283` tests subsequent creates “refused by the `API-7` tail”. No channel check is specified for an already-admitted operation before dispatch.
- By comparison, `API-63` explicitly requires the worker to “repeat the admission check as a conditional write” for account health before the ordering call. That requirement does not mention channel closure.

Concrete case: create A is admitted and queued; another create receives Robot's 403 and closes the same account/channel; A reaches its first provider call afterward. One reading sends A because its admission preceded closure. Another refuses A locally before that call, settles the existing operation, and releases its commitment. This changes provider calls, operation state and spending authority. Q12 places the admission refusal but does not settle this boundary.

Recommendation, not an adopted rule: explicitly recheck not-yet-sent creates before their first provider call and fail them locally while closed; do not interrupt a mutation already accepted or invent automatic retries. The owner must choose the boundary and its operation outcome. Do not infer the answer from an unknown upstream window-reset policy.

### 3. What response does a losing resource-offer guard return?

Passages:

- ADR-0036's correction: “it is a conditional-write guard beside `API-63`'s and `LDG-62`'s”.
- New `PRV-42`: “If the claim fails, the create MUST refuse with `conflict`/`state`, without a commitment, operation or receipt”.
- `DOM-17`: “Every error MUST carry” a boolean `retryable`, describing whether repeating “the same request” is “safe and sensible”.
- `WIR-9a` defines create `conflict`/`state` retryability for collection-snapshot account statuses `account_unreachable`, `credentials_rejected` and `terminated`; it has no outcome for a healthy account losing the new offer guard. `CNF-343` likewise omits that field and the response shape.

Readings: retryable true because the competing create can fail and release the exclusion; or false because the offer is being purchased and a caller should not repeat the purchase blindly. The guard runs after the read-only tail; its failed write also needs an explicit ordinary-versus-rich-error boundary. The similarity to the account guard does not choose the new case's retryability.

Recommendation, not an adopted rule: an ordinary conditional-write `409 conflict`/`state` refusal with `retryable: false`, with no manufactured snapshot refusal list, and conformance for the exact response. Owner confirmation is required; this report does not introduce that wire contract.

## Confirmed repairs after clarification

These are genuine defects or incomplete obligations, not requests for new product scope:

- **Absent cap:** the new channel paragraph in `CNF-307` says “cap and balance skipped” in “both cap-present and cap-absent cases”. `WIR-9a` says “without it there is no cap check to skip”, and the Lean construction emits a skipped cap only when `capPresent` is true. Require both checks with a supplied cap and only balance without one. Astra's finding is accepted and independently verified.
- **Stale ADR direction:** ADR-0034 Decision 3 still says “as `PRV-40` already spends the order budget”; current `PRV-40` says the declaration “MUST NOT be used as a locally counted substitute for Robot's accounting”. Add a dated correction pointing to ADR-0036; do not alter the separate request budget or reopen `pv-ucs.2`. Sol's finding is accepted.
- **Store primitive inventory:** `STO-6` lists “`STO-47`'s conditional write (`STO-27`) and `LDG-35`'s per-tenant serialization” but omits the new cross-tenant offer exclusion. Reconcile that inventory with `STO-27` so its statement of multi-replica primitives is complete. Fable/Opus finding accepted.
- **Logical persistence home:** the new shared closure and offer exclusion have normative readers/lifetimes but no logical state entry in the schema. Specify their shared-store representation and lifecycle consistently with the owner answers. Opus's underlying gap is accepted; demanding a particular table or unique-index design now would be unnecessary. The schema itself says “not as DDL to copy”. No representation has been chosen by this Manager.
- **Listing recheck scope:** ADR-0036 Decision 2 says “The driver confirms the offer is still listed before ordering”. The implementation places this inside the resource-identity requirement and tests only an auction offer. Make its general scope explicit and exercise an ordinary catalogue offer too. The ADR already supplies the scope; no owner vote is needed on this point.

All substantive follow-ups are recorded in the existing ticket's comment 284. No new beads were created.

