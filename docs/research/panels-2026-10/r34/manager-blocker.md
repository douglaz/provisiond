## Owner clarification 1: an effective date behind already-posted usage

**Documents and passages:**

- ADR-0037's Q14 amendment, `docs/adr/0037-the-billing-stop-window-is-withdrawn-and-wind-down-is-sized-to-the-gone-write.md`: “The effective date stops the customer's meter”; “The meter closes at the earlier of that date and `released_at`, on its next tick inside the serialization”; and “a date that has already passed is stored and clipped the same way.” It also says: “The customer owes the attachment's rate through the effective date.”
- `12-billing-and-ledger.md`, `LDG-38`: “an increment whose end instant is at or before that mark MUST be discarded, not posted” and “An increment MUST start at the subject's latest high-water mark”. The new attachment paragraph preserves “mark discard”.
- `LDG-5`: “The ledger MUST be append-only. No update, no delete. A correction is a new entry naming the entry it corrects.” This supplies the correction representation, but does not select a writer or trigger for this newly discovered date.
- `10-conformance-checklist.md`, `CNF-328`, now restricts the delayed-date fixture to “With the mark preceding a date already passed at acceptance”. That does not cover the disputed case.

**Concrete trace:** an attachment has a mark at t=20 and has already been charged at 1 sat/second through t=20. An `applied` resolution then supplies effective date t=10. Future meter attempts clipped to t=10 are discarded; clipping alone does not return the 10 sats charged for [10,20). Reading Funding's `exitSubject`, `post` and discard guard confirms that distinction; the model supplies a boundary, not a correction mechanism.

**Different readings:**

1. The effective date determines the customer's final charge, so learning it requires an automatic append-only correction for already-posted excess.
2. It stops subsequent posting, while correction of the excess requires operator action under the existing correction machinery.
3. Already-posted debits stand; only unposted time is clipped, leaving an explicitly accepted customer overcharge in this case.

**Clarification requested:** choose the correction obligation and its responsible actor/trigger for a date learned behind the meter's mark. State the applicable treatment of already-posted usage, rather than only the boundary for the next tick.

**Recommendation, not adopted:** require an idempotent automatic corrective credit naming the affected usage entries, without editing ledger entries or rewinding the meter's high-water mark. Preserve the existing correction-period and serialization rules, and add a case whose mark is already beyond the date.

The Implementer and Astra identified this question. Opus argues that discard already answers it by leaving the debit standing, with prepaid and restore examples as precedents. I agree that discard determines what the next posting does; I do not accept that it determines whether another correction entry is required. A prepaid unit is a deliberately purchased unit, and the restore exception has an explicit operator-correction sentence. Neither supplies an attachment-date correction decision. The absence of that decision is why this returns to the owner.

## Owner clarification 2: admission without an attachment bound

**Documents and passages:**

- ADR-0037's Q14 amendment: “A month-end date learned after ordering needs a bound declared per attachment kind at create, as `PRV-31` declares one for machines, or the shortfall meets `LDG-31`'s clamp.” Owner comment 287 uses the same bound-or-clamp construction.
- Existing `PRV-31` in `02-provider-contract.md`: “an offer with **no declared bound MUST NOT be sold on prepaid terms.**” Its subject is the machine's per-offer cancellation bound.
- New `PRV-45`: “For each billable attachment kind that can return an effective date after create, a driver MUST declare a worst-case effective-date bound before create in `PRV-44`'s descriptor; without it, the offer MUST NOT be sold on prepaid terms.”

**Different readings:**

1. The reference to the machine-bound shape includes refusal when an attachment bound is missing; the clamp is only the fallback when a provider's actual date exceeds a declared bound.
2. The alternative after “or” permits the offer without a bound and assigns the resulting shortfall to the operator through the clamp.

These readings admit different create requests. The brief required carrying the attachment bound and clamp through the specification; it did not independently authorize choosing this admission policy. Opus explicitly raised this ambiguity. The implementation selected the first reading without an explicit clarification.

**Clarification requested:** does a missing bound prohibit sale, or is sale with the operator absorbing the clamp shortfall allowed? If sale is prohibited, confirm that it enters the existing descriptor-decidable `offer_not_sellable` path rather than a new refusal kind.

**Recommendation, not adopted:** require the declared bound before sale, matching the machine-bound approach, and use the clamp for an actual date beyond that declaration. This preserves a priced reserve while retaining protection against a provider exceeding its declared bound.

## Required repairs after clarification

These findings are recorded in `pv-ucs.6` comment 289. They are acceptance work on this ticket, not new beads. Read the then-current requirements; locations below are by identifier rather than stale line numbers.

1. **Commitment closure still has opposite predicates.** `LDG-32` opens with closure when “the machine stops billing **and every billable attachment it left behind has stopped billing**”, while its new paragraph requires it to “keep the commitment open while any billable attachment's `released_at` is null, even if its customer meter has stopped at a stored date.” Q14 explicitly places closure after absence evidence. Correct the opening trigger and dependent live statements, including the quoted trigger in `LDG-74` and `CNF-187`, `CNF-238`, and `CNF-277`. Preserve the account-termination path. The account-termination text in `API-63` also needs its meter-stop description checked against the date exception. This is a requirement defect, not cosmetic wording. Accepted from Fable, Opus and Sol, and independently confirmed.

2. **The wire date is optional even for known scheduling.** `WIR-35` says an attachment `applied` resolution “MAY carry” the date and “without the date the applied release is complete.” The same requirement makes the date mandatory for a delete when scheduling is established. ADR-0037 requires the carrier “as it does for `delete_machine`”. Require the attachment date on known-scheduled resolution, so omission cannot assert completed cleanup and cause premature `released_at`, commitment release and tombstoning. Accepted from Opus and independently confirmed; the owner has already decided this behaviour.

3. **Attachment-bound scope and its follow-through need reconciliation.** `PRV-44` declares the field “per surviving billable attachment kind”; `PRV-45` requires it for kinds “that can return an effective date after create”; and `LDG-33` now protects attachments “through their per-kind effective-date bounds”. Make the descriptor and reserve agree on applicability and preserve protection for ordinary no-date attachments. If the owner confirms missing-bound refusal, connect it explicitly to the existing customer listing/create-tail owners (`DOM-9`, `API-7`) and add an executable conformance scenario for refusal. `CNF-328`'s “Verify the per-kind bound declared at create” does not demonstrate a missing-bound prohibition. Scope mismatch accepted from Sol; refusal/coverage gap accepted from Fable and Opus, conditional on the owner decision above.

4. **A live research instruction still attributes the old sizing rule.** `docs/research/provider-verify-2026-10.md`, section 3, quotes `PRV-13b`: “Wind-down's latency term is the effective visibility window owned by `PRV-36`”. The current owner instead introduces the sequential allowance. This is a live procedure specifically included in the brief, not a historical panel record. Refresh its quote and point to the owner without duplicating the composition. All reviewers reported it; I verified the source and dependent text. Expanding the citation scanner's scope is not required to fix it.

5. **The new CI diagnostic token does not identify its intended witness.** The `visibilityFromWaitEnd` mutation row in `.github/workflows/ci.yml` matches `visibilityFromWaitEnd := __src.visibilityFromWaitEnd`. That is an inherited-field printout shared by other parameter records, not the late-acceptance trace. The current row does refute the desired witness, but its extra targeted-witness assertion could accept a different single refutation containing the same generic field. Give that assertion a discriminator for the intended witness while preserving the existing exactly-one-error and `decide`-refutation checks. Fable raised the finding; Opus independently confirmed its printed-output limitation. No particular refactoring or expanded gate framework is mandated.

