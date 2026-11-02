**OPS-11** On failure, the system MUST classify the error into `failed` or
`needs_reconciliation` using the operation kind and the error kind:

| Operation | Classification rule |
|---|---|
| refresh | Always `failed`. It is read-only; a failure changed nothing. *The row read "adopt, refresh" until `ADR-0020` withdrew adopt from v1.* |
| suspend_tenant | Never `needs_reconciliation`, and never `failed` as a whole. It is a parent whose per-machine children carry their own outcomes (`WIR-39`), and it settles `succeeded` once every child has either settled or **reached `needs_reconciliation`** — a child that reached that state counts as complete for the parent. `needs_reconciliation` is not itself settled (`OPS-3`); it is a state only evidence or an operator moves, so an unresolved child is a child-level fact, and blocking the parent on it would leave every suspended tenant's record permanently open. |
| rescue inventory | Same rows as `install`. It is **not** read-only in the relevant sense: it boots the machine into rescue, so an ambiguous failure can strand it there, and `PRV-22` makes an end-rescue failure always ambiguous. Classifying it with `refresh` would mark it `failed` while the machine sits in rescue. |
| install | `needs_reconciliation` for `network`, `timeout`, `provider`, `internal`, `conflict`, and `integrity` **once the write-started marker is set** (`OPS-45`). `failed` for the deterministic caller errors `invalid_request`, `not_found`, `unsupported`, `authentication` and `rate_limited` **where no rescue session was left open** (the paragraph below), **and for any failure at all while `OPS-45`'s two markers say the disk is untouched and no rescue session was left open** — including `integrity` before the connection, which is `RSC-3`'s host-key abort. An install that got further than that may have begun overwriting a disk, or may have left the machine in rescue; one that did neither, provably did neither. **`failed` past the write-started marker, where rescue exited cleanly, asserts that the install did not complete and nothing about the disk** (*2026-09-15, `pv-x8r`*): the deterministic caller kinds stay `failed` there because the engine knows what it did — an installer that rejected the layout it had begun partitioning for is a known outcome — and `needs_reconciliation` is the state for an outcome nobody knows (`CONTEXT.md`), whose only truthful verb here would be `abandoned`, which settles `failed` after a human looked. It does not mean `not_applied`, which `OPS-31` refuses there. What the disk holds is `OPS-45`'s marker's fact, rendered to the caller as `WIR-9a`'s `disk_effect`; the state does not carry it. |
| create | Any create failure the worker records before any step-9 request (before any per-order key upload or order request) MUST settle `failed`, whatever its kind. The boundary is the worker invoking the first step-9 per-order key upload or order call. It is the worker's position: this rule MUST NOT read `about_to_order_at`, nor any snapshot or cached copy of it. The settle write keeps the ordinary worker guard (`STO-3`; `OPS-6`: "every write that worker makes to the operation MUST carry `claim_number = mine`"), with no `about_to_order_at IS NULL` term. The error MUST keep its reported kind. For `network`, `timeout`, `internal`, `provider` with a 5xx or no upstream status, and a cut-off `conflict`, it MUST carry `retryable: true` on both the error and the operation view; a failure classified `failed` without this pre-step-9 rule keeps its stated `retryable`. An `OPS-21` cancellation of `execute` stays a cut-off `conflict`. The commitment is released in full under `LDG-32` ("A commitment MUST be closed, and its remaining amount released in full") and `LDG-39` ("**Never debited**; released with the commitment (`LDG-32`)"), with no setup-fee or first-unit debit. Settlement takes the `LDG-35` primitive, then follows `STO-3`: "The guarded status write precedes every money write in the transaction and short-circuits the rest". Where the create holds a resource-offer exclusion, it is freed under `STO-58`: "Its lifetime follows the winning create's outcome settlement". Before step 9 no provider mutation has been requested (`PRV-50`). From step 9 onward, including a key-upload failure or an order-call failure before any byte was sent: `needs_reconciliation` if the failure is *ambiguous*, otherwise `failed`. |
| power, reverse-DNS, delete, release attachment | Subject to the goal-state success rule, any failure the worker records while `OPS-45`'s write-started marker is unset, where no rescue session was opened or the one opened was closed without error, MUST settle `failed`, whatever its kind (`OPS-45`, which owns the rule), unless the mutation is known to have been accepted (`details.accepted` is `true`). Otherwise `needs_reconciliation` if the failure is *ambiguous*, otherwise `failed`. A release is a delete of a smaller thing (`PRV-45`) and classifies exactly as one. |

*Amended 2026-10-17 (`pv-k4l`; panels r56 and r56b, `docs/research/panels-2026-10/r56/` and `docs/research/panels-2026-10/r56/r56b/`): the restart settlement is outside this classification; see `OPS-15`: "A create found `running` at startup with `about_to_order_at` null MUST be settled `failed`, on a restart only."*

*Amended 2026-10-18 (`pv-qga`; panel r57, `docs/research/panels-2026-10/r57/`; `ADR-0043`): the restart exception reads the null column on a restart; the create row instead classifies a failure recorded by the worker, by position. After step 8 is acknowledged and before step 9 begins, a recorded failure settles `failed` with the column set. A restart in that same window takes the ordinary path (`OPS-15`: "the engine MUST move every `running` operation to `needs_reconciliation`"), since the column is set.*

*Amended 2026-10-23 (`pv-9j6`; panel r64b; owner decision “Yes, settle failed (Recommended)”; `ADR-0046`): made the last row read the write-started marker for recorded failures below goal-state success and except known-accepted mutations, with ambiguity in the fallback branch.*

**The table MUST be total, and seven kinds added later were missing.** `insufficient_balance`,
`not_activated`, `halted`, `gone`, `suspended`, — added 2026-09-02 — `ceiling_exceeded`
(`DOM-20`, `DOM-21`, `SEC-39`) and — added 2026-09-12 — `overloaded` (`STO-55`) are
**admission-only**: they are decided
before any driver call, they MUST NOT be emitted by a worker or a driver, and any pre-provider
occurrence classifies deterministically as `failed` for every operation kind. Nothing was
destroyed and nothing was ordered, so ambiguity cannot arise. Every kind in `DOM-17` MUST have a
defined classification for every operation kind. There is no implicit default, because the two possible defaults are both wrong:
defaulting to `failed` invites a caller to retry a mutation that may have happened, and
defaulting to `needs_reconciliation` pages a human for a typo. `CNF-31b` tests totality.

One case needs stating because two requirements appear to disagree. `PRV-22` says "Failure of end
rescue is *always* ambiguous". That does not conflict with the install row: an install whose
*rescue exit* fails has already done its work and reached the provider, so it is never a
deterministic caller error, and the install row classifies it `needs_reconciliation` regardless
of which error kind the driver reports. *Amended 2026-09-14: the same holds where the operation died
before reaching it. `OPS-45`'s second marker is one column, `false` for both, so the classification
cannot tell them apart, and the machine may be sitting in rescue either way — which is the fact the
marker records. The never-attempted exit was a third case until `RSC-18` was withdrawn, 2026-09-15.*

*Amended 2026-10-09 and 2026-10-10 (`ADR-0036`): `PRV-40` says to "refuse subsequent
creates on that account and channel before any provider call" and, for a queued
create closed at worker claim, to "settle the existing operation `failed`". These
are occurrences decided before provider acceptance, not an admission-only error
kind. `rate_limited` remains available to drivers and workers. See `API-7` for the
purchase-tail refusal.*

A failure is **ambiguous** when:

- the error kind is `network`, `timeout`, or `internal` — the request may have been
  received and acted on before the transport died; or
- the error kind is `conflict` *and* it arose from the worker being cut off mid-flight
  (`OPS-21`) rather than from a provider-reported state conflict; or
- the error kind is `provider` *and* the upstream status was 5xx, or no upstream status
  was recorded at all. A 4xx rejection of the mutating request itself means the provider did not
  accept that request; a 5xx means it may have acted and then failed to say so; or
- the operation's mutating request was accepted by the provider (`details.accepted: true`,
  `PRV-5`), whatever the later error kind or status.

**Amended 2026-10-08 (`ADR-0035`): acceptance is an additional ambiguity condition for the
create row and the last row.** A later `rate_limited`, `not_found`, `authentication`, or provider 4xx error MUST NOT
classify that accepted mutation `failed`. The goal-state success rule below still takes
precedence. The refresh, parent, install/rescue-inventory and admission-only rows are unchanged;
pre-provider admission has no accepted mutation. Unknown acceptance follows `PRV-5`'s
"MUST report `details.accepted: null` with the mutating request's own failure mapped as above",
never an implicit default.

The accepted dated cancellation read-back (`PRV-13`) is an evidence read after a successful
mutating response. Failure of that read alone does not enter this failure classifier; the
settlement for the known accepted date belongs to `PRV-13`. `PRV-13c` says "A failed
post-order read of any kind, `rate_limited` included, MUST NOT enter `OPS-11`'s classifier and
MUST NOT change the create's settlement." *Amended 2026-10-14 (`ADR-0037`, Q31).*
This exception does not reclassify unknown acceptance or a later failure of the mutating
request. *Clarified 2026-10-11
(`ADR-0037`, Q22).*

**AMENDED 2026-08-31 — "a 4xx means the provider did not act" is false, and believing it strands a
customer's money.** For a **goal-state mutation** — delete, power on, power off, end rescue — a
provider may reject the request precisely *because the goal state already holds*, and that rejection
means the opposite of failure. Measured: `DELETE /v2/images/{id}` against a resource already deleted
returns `422 "Can not delete an already deleted image."` Classified `failed` under the sentence
above, a delete that succeeded is recorded as a failure, and `LDG-32` then never closes the
commitment — the customer's satoshis stay reserved against a resource that is gone.

**A provider rejection whose meaning is "already in the target state" MUST classify `succeeded`.**
Which specific codes carry that meaning is a provider fact, so the mapping belongs in the driver
(`PRV-5` already owns translating provider responses) and MUST be recorded in
`08-provider-notes.md`, pinned to codes rather than to message text, and re-verified when the
provider's API changes. This table states the rule; it does not enumerate anyone's error codes.

