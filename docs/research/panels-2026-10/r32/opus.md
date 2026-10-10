**Q17a: a real question, and the recommendation is right.** Startup should check only that the minimum is a positive integer. Whether it can buy a machine stays the operator's sizing job. `869ee2b` created this question with its own wording.

- **Restart during a rate outage.** CNF-345's reading needs an offer and a rate at boot. With neither, `OVR-19` says "refuse to run". But `LDG-64` keeps the outage bounded across "a restart mid-outage" (`12-billing-and-ledger.md:1480`). `OVR-18` says "While the engine is down no exposure-reducing mechanism runs" (`00-overview.md:333`). The startup check would turn a rate outage into an engine outage and switch off the deadline cancellations that bound it.
- **A pass proves nothing.** The next rate move or auction price drop can make it false, and nothing checks again.
- **No other validated row needs live data.** The only rows that compare one value with another check against configuration or the immutable descriptor: "no greater than the driver's declaration" (`00-overview.md:377–378`). CNF-339 is the same. The precedent is `LDG-52`: "The on-chain floor MUST exceed the cost of eventually spending the output" (`12-billing-and-ledger.md:1698`) depends on the market, yet its row is just "satoshis, per rail" (`00-overview.md:369`) and nothing prices it.
- **Strongest counter:** a 1-sat minimum passes and reopens `LDG-44`'s cheap-tenant hole. ADR-0036 Decision 3 answers it: "It is the price of a tenant", so the operator sets it like any other register value.
- **Formal layer:** no impact. `Funding.World.activationMin` (`Funding.lean:323`) is only compared with credited sums.

**Q17b: a real question, and the recommendation is right. Two corrections: the check goes before the order request, and it is a plain read, not a conditional write.**

Trace: A is admitted and queued with its commitment open. B gets the 403 and the closure is written. A worker then claims A.
- **If A is sent:** the 403 is "A 4xx rejection of the mutating request itself means the provider did not accept that request" (`03-operation-lifecycle.md:266–267`). A settles `failed`, and `LDG-39` applies: "Deterministic rejection before acceptance | **Never debited**; released with the commitment" (`12-billing-and-ledger.md:1223`).
- **If A fails locally:** `API-63`'s worker path applies: "fail the operation deterministically … releasing its commitment, with no provider mutation" (`04-api-contract.md:1400–1404`).

The tenant ends up in the same place either way: `failed`, commitment fully released, no setup fee or first unit, and the idempotency key used up. The only difference is on the provider side: one order request sent into a closed window. `08-provider-notes.md:434` still marks "whether requests after a 403 move the window" as [verify]. That is a free burn of the kind ADR-0036 Decision 2 closes. The fix is one read inside a transaction that already exists, so build it.

Defects in the framing:
- **"Reaches its first provider call."** For an auction create, the first provider call is `PRV-42`'s listing read: "confirm the named offer is still listed before sending the order request" (`02-provider-contract.md:1101`). The check belongs before the order request. It fits in `API-63`'s correlator-entry transaction, "the last write before the ordering call" (`04-api-contract.md:1399`).
- **`API-63`'s conditional write is the wrong model.** It exists because dead credentials produce an ambiguous reply, which froze money for `OPS-33`'s window. A 403 is not ambiguous. If the closure commits after A's read, A just takes the 403 path and lands in the same place. A plain read is enough, and the `STO-6` primitive inventory doesn't change.
- **`PRV-46` doesn't place this gate.** "Admission MUST be decided once per operation, before its first provider call" (`02-provider-contract.md:1056`) allows a check at dispatch but does not already put one there.

It is not admission-only. The `OPS-11` note says "`rate_limited` remains available to drivers and workers" (`03-operation-lifecycle.md:256`). The worker emits `rate_limited` with `retry_after_ms` set to the remaining interval, and `OPS-11`'s create row settles it `failed`. That is exactly what the 403 would have produced, minus the request.

**Strongest "don't build":** a closure catches only a handful of queued creates, and none of them costs the tenant anything either way. The answer is that the fix is one read. Formal layer: no impact, because `API-63`'s dispatch check isn't modelled ("Not modelled", `AccountStatus.lean:13`).

**Q17c: a real question. `retryable: false` is right, but for a different reason. Ordinary error is right.**

Trace: T1 and T2 both read offer X as open, and both tails pass. T1's claim commits. T2's write loses and gets `409 conflict`/`state`, with no commitment, operation or receipt.
- **Sending the same request again is safe.** The claim prevents a double purchase, and since there is no receipt the request is evaluated afresh. So the Manager's reason, "should not repeat the purchase blindly", isn't the reason.
- **It is not sensible.** T1 usually succeeds, and the listing leaves the feed (`08-provider-notes.md:419`). The claim is held "until its outcome is known" (`02-provider-contract.md:1098–1099`), and "A Robot order can sit `in process` with no documented bound" (ADR-0040:14). `true` would invite polling an unbounded hold for a machine someone else already bought. T1's likeliest failure, a 403, closes T2's channel too. The right move for T2 is another offer, so `false`.
- **`API-50` doesn't apply.** It governs `429`. A `conflict` carries only `reason` (`13-wire-contract.md:137`) and no pacing.
- **Ordinary error, because the guard runs only after the tail found nothing.** A rich list would hold one entry. **Strongest "don't build" for the rich tail:** it needs a new `TailRefusal` constructor and pushes `rank` past 6. That grows `empty_iff_admitted`'s case split, which already needed `maxHeartbeats 1000000` (`Admission.lean:1117`). It would also amend the settled tail order. The ordinary shape leaves `Admission.lean` untouched.

Defects in the framing:
- **The `WIR-9a` table is the wrong home.** It is scoped "Purchase-tail entries MUST use these `retryable` values" (`13-wire-contract.md:157`). A guard-loss row there would label it a tail entry, which contradicts the ordinary-error verdict.
- **The account guard has no value to borrow.** Its rows are keyed on "collection-snapshot `STO-47` status" (`13-wire-contract.md:162–163`), and `API-63`'s guard only loses when that snapshot read `healthy`. `API-63`'s own guard loss has the same gap. Its value is owed in the same edit, but the owner should pick it separately; it doesn't block 17c.

**Other.** `869ee2b` isn't just in history; HEAD's files carry it (CNF-345 is at `10-conformance-checklist.md:3389`). The gates pass at HEAD (`All gates passed`, exit 0), and I edited nothing.

**Edits** (land the rules first, the records after):
1. **17a.**
   - `OVR-19` row (`00-overview.md:390`): change the type to "positive integer satoshis". The current cell restates `API-35`.
   - CNF-345: delete "or configure below the price needed to purchase something".
   - `API-35` (`04-api-contract.md:480–481`): append "Sizing it is the operator's obligation; startup validates only the register type (`OVR-19`)."
2. **17b.**
   - `PRV-40`, after `:1035–1037`: "A claimed create not yet sent MUST read the closure in `API-63`'s correlator-entry transaction and, while closed, fail without the order request: `rate_limited`, `retry_after_ms` for the remaining interval, `failed`, commitment released. A closure committed after that read leaves the provider's 403 to settle it the same way."
   - `OPS-11` note (`03-operation-lifecycle.md:254`): "an admission occurrence" becomes "an admission occurrence, or at dispatch a worker failure the create row classifies `failed`".
   - CNF-283: add the queued-A case and the race where the closure commits after A's read.
3. **17c.**
   - `PRV-42` (`02-provider-contract.md:1099–1100`): "…refuse with `conflict`/`state`, `retryable: false`, as an ordinary error without a refusal list…".
   - CNF-343: assert the envelope and its `retryable` value.
   - Record `API-63`'s guard-loss `retryable` as owed.
4. **Records.** Add a dated note to ADR-0036 recording the Q17 answers.
