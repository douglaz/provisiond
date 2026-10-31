# Panel G r86b — owner queue

Main relays one question at a time. These are two independent decisions; neither is implemented or ready-for-agent yet. Exact packages remain those read in r86b, against pin `3109b5b44eae17e288cf52aaa976993bd8c5626c`. Grok was missing (402).

## 1. Approve the unanimously selected non-create ordering package

**TL;DR: approve A, the panel's 4–0 choice, to spell out when support is checked and which local error wins?**

A hard-reset request arrives while the server knows that account cannot hard reset: it must be refused before creating work. If support disappears after a valid request was queued, the worker must check again. The proposed wording also chooses what happens when a bad field and missing support occur together, and leaves already queued cancellations' funded/gone success and waiting paths ahead of the check. A cancellation that actually proceeds can set its fence and then fail for missing support, leaving an operator decision pending.

- **Approve A (Recommended; final picks 4–0, ACCEPT 4–0):** adopt exactly [Q1-A.md](Q1-A.md), covering the existing operation mapping, admission/worker placement, validation order, cancellation fence order and the API/worker pointers.
- **Keep the text unchanged (C0; final picks 0, ACCEPT 4–0):** choose the literal no-edit form at `brief.md:787`. Existing obligations remain; the additional local precedence and placement stay unresolved. This is accepted by every reader but preferred by none.

Reader picks and strongest arguments, all unconditional:

| Reader | Pick | Strongest argument |
|---|---|---|
| fable | A | The corrected admission prohibition rules out claim-only acceptance; A fixes useful local order without losing the existing no-call and defer paths. |
| opus | A | A resolves fence placement, error precedence and rescue-check order that the existing general obligations do not spell out together. |
| astra | A | Its former funded-retry argument concerned a new operator request, so a possible later no-call success cannot exempt that request from admission rejection. |
| sol | A | A later worker refusal cannot undo an already prohibited acceptance; A preserves the worker's required cancellation decisions and stop records. |

The strongest no-edit case is that existing admission, outer-gate and repeat-validation obligations already protect the operation. It is a requested counterargument, not a dissent. The packet's statement that early checking changes a formerly permitted unsupported acceptance phase was too broad; the corrected premise and the ballots already account for that.

IDs last: **pv-5pmu / Q1**; amend **DOM-10**, with pointers in **API-7** and **OPS-23**. At the pin, **OVR-2** says “the server MUST NOT accept an operation a provider has not declared support for”; **DOM-10** says “before the driver is called”; **OPS-23** says “Validation that was performed at the API boundary MUST be repeated in the worker before the driver is called”. Approval is needed because A's additional normative order exceeds the owner's wording-only precedent. Exact source/trace evidence is in `tally.md`.

## 2. Choose between the two tied machine-kind sources

**TL;DR: allow one account to sell both kinds of machine, changing the missing-offer refusal, or require one fixed kind per account to preserve the early support refusal? The consensus round remains 2–2; there is no panel recommendation.**

One provider account can advertise both a virtual machine and a physical server, but a customer requests an offer that is no longer in the saved list. One approach uses the kind on each saved offer and, when the offer is missing, reports “offer not sellable” without guessing its kind. The other gives every account a permanent kind, so the server can name and check the required support even when the offer is missing; accounts selling both kinds must be split into distinct identities.

- **A-cited — use each offer's saved kind (fable + opus: 2 picks, 2 ACCEPT):** adopt exactly [Q2-A-cited.md](Q2-A-cited.md). Mixed accounts work; queued work retains the accepted kind and rejects a changed live kind. Missing offers switch from early unsupported to the ordinary collected refusal. The exact form changes formal docstrings but no declaration: fable/opus accept that convention, while astra/sol say the changed real case needs a substantive formal amendment. That objection is unresolved, not waived by a green citation check.
- **B-cited — require one permanent kind per account (astra + sol: 2 picks, 2 ACCEPT):** adopt exactly [Q2-B-cited.md](Q2-B-cited.md). Early unsupported still applies with no offer/listing. It adds configuration rejection of mixed/invalid accounts and changed retained identities, needing enforcement/history across restarts. It trusts the driver's new same-kind offer contract and supplies no dedicated runtime mismatch result. Fable/opus reject the printed contract for completeness/outer-gate reasons.

These are tied reviewed options, listed without inventing a panel recommendation. Each reader's r86b pick and strongest argument, all unconditional:

| Reader | Pick | Strongest argument |
|---|---|---|
| fable | A-cited | The offer already owns its kind; retaining it preserves the pre-list-read worker refusal and supports mixed accounts. It accepts the disclosed missing-offer change and rejects B's unspecified detection/history test path. |
| opus | A-cited | A openly changes the missing-offer semantics while preserving non-vacuous proofs and the existing control. B can gate on the descriptor's virtual capability while ignoring a visible physical offer kind, which it reads as an outer-gate breach. |
| astra | B-cited | With neither capability and no listing, the pinned formal Boolean is false; A supplies true instead and loses that real checked case without changing a declaration. B's opposite-kind offer is already outside its new conforming output contract. |
| sol | B-cited | An unchanged algebraic proof does not preserve a request removed by changing the input meaning. B supplies a total kind source and external checks; separate configuration validation and retained identity state can implement its deliberate restrictions. |

Both decisive traces were verified. The formal missing-offer result really changes under A. The opposite-kind driver in B's trace really violates B's proposed output contract; whether the independent outer gate must also contain that violation remains disputed. No new premise error voids this vote. The original A/B forms fail citations, and neither is an extra owner option. Fable's first-authored A-formal has not been read by the other seats or built and is not substituted for A-cited. Q2 has completed its one consensus round: no further round will launch.

IDs last: **pv-e45e / Q2**; A-cited changes **API-7**, **OPS-43**, **OPS-23**, **STO-50**, the **operations.request_summary** row, **CNF-19**, **CNF-55** and the printed **Admission.lean** docstrings; B-cited changes **PRV-44**, **API-7**, **OPS-43**, **CNF-19** and its printed **Admission.lean** guard docstring. **DOM-10** says “There MUST be no operation whose only gate is a driver-internal check”; **ADR-0025** calls adding “any other hypothesis to an existing theorem, or narrowing its conclusion” a weakening. Preserve the fixed panel-E listing/rank decisions. The owner's rule says “a tie comes to you”; this is that owner decision, not an authorization for a manager synthesis.
