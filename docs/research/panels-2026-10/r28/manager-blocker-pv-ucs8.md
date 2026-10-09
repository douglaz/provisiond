## Owner clarification required

Relevant current passages:

- `04-api-contract.md`, `API-7`, **Rich purchase tails**: “collect every applicable refusal once, from one read-only snapshot inside the existing `LDG-35` transaction, without an extra lock, ceiling slot, write or provider call.” Its ordered list starts with “the request's own resource refusal (`conflict`/`state` for create against a provider account not `healthy`, or `conflict`/`cancellation_committed` for extension)”, followed by solvency, rate, commitment cap and balance. It also states: “Entry 0 is the headline: HTTP status, `kind`, `message` and per-kind details MUST match it”.
- The same passage states: “The cap and balance checks MUST NOT run without a rate, nor for create against an unhealthy account”. It does not address the newly unsellable offer.
- `13-wire-contract.md`, `WIR-9a`: “`because` is exactly `rate_unavailable` or `provider_account_not_healthy` (create only).” It then requires: “Every genuinely skipped check MUST appear with every applicable reason; an absent refusal does not imply that check passed.”
- `docs/adr/0030-purchase-tails-report-all-applicable-refusals.md`: “The chosen order explains the resource before the pool, then pricing and spending”. This rationale does not order two independent resource refusals on the same create.
- `tools/formal/Provisiond/Admission.lean` contains the corresponding `purchaseTail`, `tailAdmitted`, refusal ranks and proofs. The current model has account-health refusals for create and a fence refusal for extension, but no offer-sellability input. Its ordered-list and skipped-check properties need the missing policy before they can be amended faithfully.

Please settle these concrete cases:

1. **An unhealthy account and a known unsellable offer on the same create.** Both refusals could be collected with account first, or both with offer first. Both readings retain a resource-before-pool order and refuse the purchase, but they select different headlines and may produce different HTTP status and pacing. ADR-0039 does not specify their relative precedence.
2. **A healthy account, available rate, known priced offer that is unsellable, and an insufficient balance or breached supplied commitment cap.** One reading retains the existing price-check conditions and returns those spending refusals alongside the offer refusal. Another treats sale ineligibility as making purchase pricing unavailable, skips those checks, and reports an additional `not_checked` reason. Filtering the offer from the sale listing does not itself settle whether its internal price remains usable for these admission checks. The readings produce different refusal lists and skipped-check records.

The second reading would require an explicit amendment to the closed reason set in `WIR-9a`; it cannot be introduced as a harmless Lean refactor. Likewise, choosing the headline order is observable API behavior. Under the caller's instruction that a behavior question not answered by the ADR is the owner's, these choices cannot be silently delegated to the Implementer or settled by an adviser vote.

