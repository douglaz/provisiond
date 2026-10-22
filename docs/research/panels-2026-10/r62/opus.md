**Q1 (pv-p3k): AMEND A.** Keep A's `DOM-16` MUST; move `retryable` and position to their owners:
- `DOM-10`, after "naming the provider account and the capability": ", with `retryable: false` on both the error and the operation view where there is one."
- `PRV-4` gains: "An ordering capability that `DOM-16`'s `allow_orders` withholds is not declared, and implementing it is not a breach of this requirement."
- `API-7` gains step 5d: "gate a create on its ordering capability under `DOM-10` (`PRV-10`, `DOM-16`). A refusal stops here and is not collected."
- `PRV-10` gains: "The configuration half is `DOM-10`'s gate on the create's ordering capability (`DOM-16`): `API-7`'s step 5d at admission, `OPS-43`'s step 3 at claim."
- `OPS-43` step 3 gains: "Its field checks run first, then the capability gate."
- `WIR-29`'s fixture drops `"allow_orders": true`, since `capabilities` now carries it.

A as drafted breaks `PRV-4`, "MUST NOT implement one whose capability it does not declare", and `CNF-18`. After 5c is the right position: at step 5 the gate would run before 5a and refuse a replay that should return its stored result. Collecting it would need a `TailRefusal` constructor for nothing. Under a SHOULD, `details.capability` would name a declared capability, which is `DOM-15`'s defect. Reject C (not a caller error) and D (the flag is deliberate configuration). Touches `DOM-16`, `DOM-10`, `PRV-4`, `PRV-10`, `API-7`, `OPS-43`, `WIR-29`, `CNF-18`, `CNF-55`. **Mechanics**: `DOM-10` and `DOM-15` already fix the kind.

**Q2 (pv-009): REJECT A → B**, with `retryable` from my `DOM-10` sentence. A cites `PRV-10`, but `DOM-10` owns the error. A also adds a check to step 3, whose checks have no order, so "the first failing check" is undefined there. B puts the gate beside the read it guards.
- `credentials_rejected`: step 1, `conflict`/`state`, `retryable: true`.
- Closed channel: step 2, `rate_limited`.

Both are the same under A and B; C gives `unsupported` for both.

`retryable` is the same as Q1's (`false`). Touches `OPS-43`, `DOM-10`. **Mechanics.**

**Q3 (pv-gpw): REJECT A → B.** `PRV-47`'s caller sentence is settled, so A would give step-7 caller values a second home.
- `OPS-23`, after the bullets: "A field that is present but fails this repeated validation fails as its writer's bullet says, and settles as these missing-field failures do."
- `PRV-47` gains: "A value this system wrote rather than the caller, such as `PRV-9`'s operation-id name or tag or `PRV-32`'s per-order correlator key, that this validation rejects fails `internal`; `OPS-11`'s create row gives its `retryable`."
- `CNF-342` asserts per writer.

**Engine-written kind:** `internal` ("Defect in this system"). **`retryable`:** `true`. `OPS-11`'s create row already forces it before step 9, so the sentence cites that row. Reject C: the divergence stays. Touches `OPS-23`, `PRV-47`, `CNF-342`. **Mechanics.**

**Q4 (pv-ss4): AMEND A.**
> An `invalid_request` that names a rejected field carries `details.field`, an RFC 6901 JSON Pointer into the request body (`"/acknowledge_purchase"`, `"/provider_options/location"`). Where one validation step rejects several, it names the least pointer, comparing pointers as strings by UTF-16 code units, the order JCS (`WIR-3`) sorts member names in.

`WIR-2`: "naming the unknown field with the least pointer under `WIR-9a`'s order".

"Code-unit order" is ambiguous: UTF-8 and UTF-16 order differ above U+E000. "One check" leaves step 3's acknowledgement check and SSH-key check unordered against each other. The order is recoverable: it depends only on the set of rejected pointers, not on member order, which a JSONB store doesn't keep. An engine-written value isn't in the body, so it carries no key. Touches `WIR-9a`, `WIR-2`, `OPS-23`, `PRV-47`, `CNF-34`, `CNF-342`. **Mechanics.**

**Q5 (pv-7j3): ACCEPT A.** `WIR-48`'s sentence continues its `state` clause. `WIR-29` refuses a synchronous create on a terminated account with `conflict`/`state`. `CNF-248` keeps `account_terminated` recorded-only: "Each excluded reason is recorded on an operation's `error`." Touches `WIR-48`. **Mechanics.**

**Q6:** One Run: they share `OPS-43` step 3, `OPS-23`, `PRV-47` and `CNF-342`; `pv-7j3` is one word.

## Against my picks (written on request)

- **Q1:** A configuration flag now edits a descriptor that `PRV-44` calls "a typed, immutable value", and that takes a `PRV-4` carve-out. `false` also tells callers to stop when an operator can flip the flag.
- **Q2:** B gates, at claim, a capability that admission may never have checked. That makes claim stricter than admission, a second inversion beside the one `OPS-43` already documents.
- **Q3:** `internal` with `retryable: true` tells callers to resend a request that fails the same way every time. The `CNF-342` engine case also needs a fault-injecting driver, which is CodeRabbit's case for narrowing.
- **Q4:** String order isn't segment order: `"/a!"` sorts before `"/a/x"`. One key also hides every other rejection, so an agent fixes one field per round trip.
- **Q5:** `account_terminated` says why. `state` lumps a fixable refusal (not flagged assignable) with a permanent one.
- **Q6:** Five beads across about 15 ids make a long review, and `pv-7j3` is independent.

## Brief errors

1. Q3's strawman gives `internal`, `retryable: false`. `OPS-11`'s create row: "For `network`, `timeout`, `internal`, … it MUST carry `retryable: true` on both the error and the operation view", before step 9, and step 7 is before it. (`grep -n 'MUST carry \`retryable: true\`' 03-operation-lifecycle.md`, line 232)
2. The `WIR-29` quote leaves out "This view is a subset of the driver's descriptor (`PRV-44`)" and "nothing here is declared anywhere else". `PRV-44` has no `allow_orders` (`grep -n allow_orders 02-provider-contract.md` hits only line 1038).

**New bead (not voted):** `DOM-10`'s gate has no admission step for power, install or rescue inventory either.

---
I didn't run the gates: I edited no Lean, no `CNF` quote and no tracked file. A copy of this answer is in the clone at `panel-b-answer.md`, untracked (895 words).
