STATUS: blocked

Round 1 requires an owner clarification about Q23c's near-future cancellation day. A separate Q24 application defect is repairable from the existing owner decision. No second implementation round was launched and no specification was edited by the Manager.

## Owner clarification required: the near-future day boundary

The unresolved composition is in `02-provider-contract.md` (PRV-13, PRV-13b, PRV-13c, PRV-31) and `12-billing-and-ledger.md` (LDG-33), against ADR-0037's final 2026-10-11 Q23c amendment.

The passages:

- PRV-13: “a day-only value MUST be stored as the UTC instant at the start of that day in the provider's date zone”; “For a future earliest date, cost through that date runs to the end of its provider-local day”.
- PRV-13c: “Branch to the exception path when the stored permitted-from instant is **materially in the future**” and “later than now plus one re-derivation period plus the product's wind-down bound; anything nearer is indistinguishable from the ordinary exhaustion path and needs no exception”. It further requires: “A machine on the exception branch MUST either carry a machine-specific reserve of cost-through-that-date, or not be sold on prepaid terms at all.”
- PRV-13b's reserve formula: `+ cost_through_earliest_cancellation_date # exception branch only (PRV-13c)`.
- PRV-31: “The declared bound sizes the commitment at create.” The actual date subsequently “updates the cost-through-earliest-cancellation-date term of `LDG-33`'s `protected_sats` — it MUST NOT resize the commitment.”
- LDG-33's protected-cost formula: `+ cost through any future permitted-from date to its provider-local day end (PRV-13, PRV-13c)`. Its prose also says that this cost “MUST NOT be advertised as spendable runway while it is still in the future”.
- ADR-0037 Q23c: “A date equal to the provider's today has passed, so the machine takes the ordinary branch” and “Cost through a future earliest date runs to that day's end”. It does not address a future day's start inside the existing materiality threshold while its priced-through end lies outside that threshold.

Concrete boundary fixture, with Europe/Berlin assumed only for the fixture:

- Now: `2026-10-30T22:30:00Z`, local October 30 at 23:30.
- Earliest permitted day: October 31. Its stored start is `2026-10-30T23:00:00Z`, thirty minutes away.
- Its priced-through end is `2026-10-31T22:59:59Z`, more than twenty-four hours away.
- Re-derivation interval plus wind-down: two hours. Let the declared offer bound have this same earliest day, so a looser declaration does not accidentally mask the boundary.

The competing readings change funding and available runway:

1. Preserve the start-based materiality test: this is ordinary, and the exception-only term adds nothing at purchase. Nevertheless the future-day rule protects cost through the following day-end after ordering. The commitment may therefore be below protected cost until the permitted-from start passes. The owner's clarification must state whether this mismatch is intentional, what funds an early cancellation scheduled for that day, and whether the ordinary-path claim remains valid.
2. Treat the priced-through end as the relevant exposure for a still-future day: this case needs exception funding from the declared offer bound before ordering, with the actual day subsequently updating protected cost only. This requires changing the materiality rule or explicitly changing the reserve term's scope; the Implementer cannot choose that policy alone.

**Recommended clarification:** retain Q23c's start-of-day storage, and its ordinary treatment once that start has passed. For a still-future day-only constraint, judge exceptional exposure using its priced-through end and apply the existing cost-through-date term to the pre-order declared bound. Keep PRV-31's prohibition on post-order commitment resizing. Add the near-midnight boundary fixture to CNF-63. This recommendation is not an applied amendment; the owner may instead explicitly accept the ordinary-sizing consequence and state its funding treatment. It does not propose funding the rest of every provider day in every ordinary purchase, an alternative ADR-0037 already rejected.

This is a specification question, not a choice of proof or tooling. No adviser Consultation was run to substitute a vote for the owner's clarification.

## Confirmed repair under the existing Q24 decision

Sol's registered-key finding is valid. PRV-9's new affirmative duty begins “After acceptance, a temporary key MUST be deleted when, and only when, its operation has settled or vanished”. Its driver rule separately says that an “indeterminate registration reply gives the driver no ownership evidence and MUST NOT trigger deletion by fingerprint”. OPS-32 delegates to that eligibility rule. The vanished-record duty does not cover a still-retained settled row.

Trace: the provider registers a tagged key, the registration reply is lost, no order is accepted, and the operation settles while its row remains. Driver cleanup must not delete by fingerprint, but the newly scoped sweep duty does not cover this pre-acceptance key. CNF-303 checks the driver's non-deletion on the lost reply and does not take that case through settlement and a sweep while the row is retained.

ADR-0040 Q24 already answers the behavior: “OPS-32's sweep is the only deleter of a settled operation's key, and it MUST delete one once Decision 2 permits it.” The repair is to state settled-key eligibility and sweep ownership independently of acceptance, preserving the owned pre-acceptance driver cleanup exception and the unresolved/provisioning guards. Extend CNF-303 with the retained-row lost-registration-reply trace. No new cleanup actor, shared-key ownership mechanism or owner decision is needed for this repair.

Both semantic follow-ups are recorded in **pv-ucs.10's notes only**. No new beads were created.

## Review disposition

I reviewed the implementation diff before reading the Panel feedback, checked the relevant normative owners and owner amendments, and ran the required gates independently.

- **Sol:** accepted the Q24 application defect and the Q23c funding-boundary question above. The latter blocks the Run; the report does not claim a particular running system has lost money or destroyed a machine.
- **Astra:** confirmed its observations but rejected their classification as semantic blockers under this Round's filing rule. CNF-303 existed in master `903053d` and its dated ADR marker was removed. The new rescue-workflow and LDG-74 cross-references also omit the quotations required by the brief. These are in-scope documentation-convention defects, recorded here once and dropped as cosmetic follow-ups; no issues were filed for them.
- **Fable and Opus:** both files say `REVIEWER NOT RUN (unavailable)`. Neither supplied a review or an adviser answer. Their silence is not agreement or disagreement.
- My alarm-text check found the lingering word “threshold” imprecise, but PRV-40 expressly keys the alarm to the provider's reported 403 and forbids a local substitute count; CNF-344 explicitly says “No local request count raises that alarm.” I do not infer an additional runtime requirement or file an issue from that wording.

The other ticket repairs are accepted as partial progress: the specified marker/source repairs, cache and wire consistency, offer-versus-descriptor separation, Q23a's failed-read tail and clamp coverage, Q23b's single sale-rule home and uncapped residual, and the basic Q23c start/end distinction. The whole task is **not accepted as complete** because of the defects above. There were no `rejected-*` evidence files in this Run directory.

## Verification and history

- Review base: `918af0e9ea5002314d551e7c1c5f1ca1322c34e8`.
- Implementer commit: `3b717a0` — `docs: resolve pv-ucs.10 branch review residue`. It was already committed when Manager review started. It contains the partial implementation, including the unresolved passages. It has not been rewritten, squashed, reverted or represented as fully accepted.
- Current HEAD: `12a1c898b88835a4cfca9eb9979dbde65614c93c` — `beads: record pv-ucs.10 owner clarification block`. The Manager committed only the verified pv-ucs.10 tracker-note/status change; no specification or code repair was committed by the Manager.
- The unpiped `nix develop --command bash tools/check-all.sh` exited 0 before Manager review and again after the tracker update. All reported gates passed. `git diff --check` passed. Green gates do not resolve the semantic questions above.
- `docs/verification/pv-ucs.10-2026-10-11.md` records the Implementer's single-copy CI negative-control rehearsal and cleanup. I reviewed that record and the workflow inventory; I did not independently rerun that rehearsal. Neither reviewer claimed to have rerun it.
- The tracked and untracked working tree is clean according to `git status --short`. The rloop artifacts are ignored orchestration files; this report is the only Run-directory file the Manager wrote in this Round. No provider call or live account action was made.

Under the caller's terminal **Option A** instruction, pv-ucs.10 is closed with an explicit **blocked, not completed** reason. Its notes preserve the outstanding semantic work and request reopening this same ticket after the owner answers. The closure must not be read as acceptance of the Implementer's “all items applied” claim. The next action is the owner's clarification, followed by continuation on pv-ucs.10; no other bead is selected.
