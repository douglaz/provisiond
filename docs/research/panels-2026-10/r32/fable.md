**Q17a — Verdict: real question; recommendation right. Startup checks a positive integer and nothing more.**

Every "yes" row on `OVR-19` is a shape or range check against configuration or the descriptor. The one cross-check, "no greater than the driver's declaration" (`00-overview.md:377`), compares two in-process values. No row reads a rate or a listing. "Large enough to purchase something" is a function of the cheapest sellable offer, `PRV-13b`'s reserve, the live rate and the margin, which is not a startup constant.

Restart during a rate outage: `LDG-64` makes the outage operator-borne and time-bounded, and the bound's cancellations run only if the process runs. The set already names the failure: "blocked from deleting a machine during a rate outage — the one action that would have stopped the bleeding" (`04-api-contract.md:304`). A startup that prices a purchase rebuilds that defect.

Framing defects. The type column smuggles the obligation into the validator (`00-overview.md:390`). `CNF-345` then asserts an untestable step, "configure below the price needed to purchase something: startup refuses each" (`10-conformance-checklist.md:3390-3391`), with no price basis. `ADR-0036` Decision 3 says only "goes on `OVR-19`'s register. It is the price of a tenant." It never said startup prices anything.

Third shape: alarm at runtime when the minimum falls below the cheapest sellable reserve, on `OVR-19`'s alarm model (`00-overview.md:336`). Don't build it: a tenant activated too low gets `insufficient_balance` on its first create and tops up. `API-35`'s harm was immortal rows for one satoshi, which any positive minimum ends.

Edits: `OVR-19` row type → "positive integer satoshis"; `API-35` keeps "MUST be large enough to purchase something" as the operator's obligation (`04-api-contract.md:480-481`); `CNF-345` → "Omit, zero, negative or noninteger: startup refuses each", price clause dropped. Formal: none, `OVR-19` appears only in `Fence.lean` for the outage setting.

**Q17b — Verdict: real; recommendation right in substance. Make it a read at claim time, not a guard in `API-63`'s transaction.**

Trace. A admitted: commitment and operation committed, 202. B on another worker gets 403; closure stored, alarm raised. A worker claims A. Both ways A settles `failed` with its commitment released in full, because `LDG-39`'s row "Deterministic rejection before acceptance: Never debited; released with the commitment" (`12-billing-and-ledger.md:1223`) covers a local refusal and a 403 alike. No setup fee, no first unit. The tenant's cost is identical; the argument is on the provider side.

Sending A spends an order request plus the per-order key upload and delete against the key limit rescue shares (`r21/synthesis.md:42`), and raises the alarm again. The real risk: "whether requests after a 403 move the window" is `[verify]` (`08-provider-notes.md:433-434`), and `ADR-0036` Decision 4 exists to learn it. Until known, every send into a closed channel may prolong every tenant's closure.

Framing defect: "first provider call" and `API-63`'s transaction are different instants. That transaction is "the last write before the ordering call" (`04-api-contract.md:1398-1399`), after `PRV-32`'s key upload ("never a preceding key upload", `02-provider-contract.md:42`) and after `PRV-42`'s listing confirmation (`02-provider-contract.md:1101-1102`). Placed there, the recheck saves the order request but not the key spend. Put the read in the claim (`OPS-5`).

Read, not conditional write. `API-63`'s write exists because a wrong outcome opens a commitment against a dead account. Here a wrong outcome is one 403 the current path already handles, and `LDG-69` leaves that residue under any shape. No new `STO-27` primitive.

Not admission-only, and no `OPS-11` edit: Q12's text says `rate_limited` "remains available to drivers and workers" (`03-operation-lifecycle.md:255-256`). A pre-send worker refusal carries `accepted: false`, is not ambiguous, and classifies `failed`. Kind `rate_limited`, `details.retry_after_ms` the remaining interval, operation-view `retryable: true`, mirroring `WIR-9a:166`.

Don't defer: "No deferral is specified" (`11-open-findings.md:194`), `OPS-45`'s no re-run, and a waiting commitment holds machine time `PRV-13b` prices. Manager right.

Strongest don't-build: skip the recheck; exposure is bounded by creates concurrently in flight behind the 403, a handful. It loses to the sliding-window unknown.

Edits: one sentence in `PRV-40`'s closure paragraph (`02-provider-contract.md:1035-1039`): a worker claiming a create on a closed account and channel fails it `rate_limited` with `retry_after_ms`, releasing its commitment, before any provider request. `CNF-283` (`10-conformance-checklist.md:1476`): add the queued-behind case, asserting no key upload and no order request. Formal: none; `tools/formal/` tags no `API-63` or worker path.

**Q17c — Verdict: real only as a gap shared with `API-63` and `LDG-62`. Recommendation right: ordinary `409 conflict`/`state`, `retryable: false`, no pacing.**

Trace. Two tenants on two replicas pass the read-only tail from their snapshots. Each admitting transaction attempts the claim on (account, channel, offer). One commits commitment and operation, 202. The loser's write affects no row, the transaction aborts, nothing is written and no receipt, so the same key re-evaluates afresh (`04-api-contract.md:284-285`).

Framing defect: expecting a `WIR-9a` row. That table is for "Purchase-tail entries" (`13-wire-contract.md:157`); a guard runs after collection and is not an entry. `API-63`'s write-time `account_terminated` and `LDG-62`'s fence lack a row for the same reason. The gap is one sentence for all three guards.

`retryable: false`: the winner either lands, and the offer leaves the feed (`02-provider-contract.md:1091`), or fails and releases the claim; the loser cannot tell which, and the listing is its oracle. `WIR-9a` reserves `true` for a condition someone repairs ("The named account can recover"). `ADR-0036`'s threat is N creates racing one offer; `true` tells the losers to loop. `retryable` is guidance (`01-domain-model.md:643-647`), so an agent wanting that machine can still re-list and resubmit.

`API-50` does not apply: it governs `429` and caller pacing (`04-api-contract.md:1207`); a `409` carries no `retry_after_ms`. Rich tail: no. The tail passed, there is one refusal, and `ADR-0030` aggregates only co-occurring refusals.

Third shape: `details.reason: offer_in_flight`, a new value in `WIR-9a:137`'s closed list. Don't build until an agent needs to branch on offer-taken versus account-bad; `state` is not false here, which was `API-63`'s reason to split.

Edits. The owner is `API-7`'s "Admission retains the conditional-write guards in `API-63`, `LDG-62` and `PRV-42`" (`04-api-contract.md:285-286`): add "a guard that affects no row refuses as one `WIR-9` error, `retryable: false`, no `details.refusals`". `PRV-42` (`02-provider-contract.md:1098-1099`) and `CNF-343` (`10-conformance-checklist.md:3373`) point at it and assert the exact response. Formal: none; `purchaseTail` (`Admission.lean:1056`) models the snapshot tail and no guard.

Not run: the gates, since I edited nothing.
