# Ready owner questions — main asks ONE at a time

## 1. Suspension release transaction

TL;DR: approve the panel's explicit one-transaction release rule?

A suspended customer's queued $50 order is failed before any purchase. Its reserved money must come back. Should the specification also say that failing the order and releasing its money happen together, and that a cleanup attempt which loses a race releases nothing?

- **B: say so explicitly (Recommended).** Add the guarded transaction rule and the full independent race/kind fixtures. First pick fable, opus and astra; sol accepts B but prefers A. Preference B 3–1, acceptance 4–0. Their strongest reason: a test of eventual release alone leaves its transaction order implicit.
- **A: tests only.** Full independent fixtures, relying on the existing release duty. Sol's first pick; all four accept. Strongest reason: avoid another normative copy when the outcome is already required.
- **C: smaller test set.** Representative create/install/power fixtures only; all accept, none prefers. It catches power-only mistakes but misses a filter handling just these kinds.

Exact reviewed forms: r83 brief Q1-A/B/C; recommendation frozen in check/settled-Q1-B.txt. IDs/homes: pv-gvc, API-58, CNF-202; existing release owner LDG-32 says "the create fails deterministically" (12-billing-and-ledger.md:312). Land with or after pv-kv2's still-pending exact mechanics, under the owner's item-3 "Stop before buying (Recommended)" decision. Do not add the newly discovered deferred-operation guard fix to this approval.

## 2. Retry advice when an account changes during admission

TL;DR: approve status-specific retry advice captured while the account is locked?

The service checks an account, then the provider goes offline before it can reserve the customer's money. The order is refused and buys nothing. If that account can recover, should the customer be told that sending the same order later makes sense, while a permanently closed account gets stop advice?

- **A: distinguish recoverable from permanent (Recommended).** Retain the refusing status under the account lock; true for unreachable/rejected credentials, false for terminated. Fable/opus/astra/sol all pick and accept A (4–0). Strongest reason: the same unchanged order can succeed after recovery, and a later recovery must not rewrite the refused decision.
- **B: always say stop.** Constant false needs no retained-status decision. All four reject it: the recoverable-account trace gives no safety reason for permanent-stop advice.
- **N: leave the gap.** No text changes. All four reject: the existing earlier-snapshot values and later worker values do not specify this admission-race response.

Exact reviewed forms: r83 brief Q2-A/B/N; recommendation frozen in check/settled-Q2-A.txt. IDs/homes: pv-bxh, API-63, WIR-9a, CNF-278; DOM-17 says retryable describes whether repeating "the same request is safe and sensible" (01-domain-model.md:656–657). This is the HTTP admission response, not pv-ip7's existing-operation worker refusal.


## Queue update — 2026-10-30T21:44:05.012918+00:00: Q1/Q2 answered; ask only Q4

The earlier questions in §§1–2 are already answered in owner-decisions-1030.md: item 13 pv-gvc **"B: say it explicitly (Recommended)"**, item 14 pv-bxh **"A: tell them apart (Recommended)"**. Do not re-ask them. Approved Q1 still lands with or after resolved Q4 mechanics.

The sole Q4 consensus round ended without settlement: fable/astra/sol prefer D, opus A, but D has a verified loss of the positive public fleet-warning duty and no other form clears the settling rule. **Ask the one question at [r83b/owner-questions.md](r83b/owner-questions.md)**: exact reviewed D versus exact reviewed A, with each reader's pick, strongest argument and the disclosure tradeoff. There is **no settled panel recommendation**. No new round and no unreviewed synthesis. Item 3 **"Stop before buying (Recommended)"** remains fixed and is not a ballot option. No ready-for-agent disposition for pv-kv2 until that question is resolved.
