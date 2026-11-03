For power on, power off, reboot, hard reset, every install strategy, rescue inventory,
reverse DNS, delete/cancel and API-cleanable attachment release, a caller or operator
request MUST pass the capability check before admission enqueues the operation. This check
runs after API-7's steps 1–5c and all endpoint-local admission validation and admissibility
checks, immediately before the enqueue transaction's first write. It uses the descriptor
running in api and makes no provider request. A failed check enqueues no operation and
makes no endpoint-state or money write. API-7 step 5a says "an equal fingerprint under the
    same `(principal, key)` returns the stored result, a different one fails `conflict`."; a replay returned there never reaches this check. `API-64` says "the state change, the enqueue and the idempotency record commit together". An API-64 operator retry checks delete_machine before its state-change/enqueue
transaction; API-65 says "On a row whose `cleanup` is `manual` there is no driver call to make: it
writes `released_at` and answers `200` with the row, minting no operation,"; a manual attachment release takes no capability check under this timing rule.
A suspend parent takes no per-machine capability check at admission: its cancellation
children are gated at claim as below.

Every operation in the preceding paragraph MUST also pass the capability check in the
worker using the descriptor running there, including operations enqueued without an HTTP
request, API-64 retry attempts and attachment releases enqueued by a successful delete.
The check runs after claim and per-machine serialization, before the operation's first
driver call and before either OPS-45 marker is written. Repeated validation checks caller-
supplied fields first, api-written admission fields second, then the other applicable
local validation, including machine install eligibility and OPS-40's signed-URL check;
the capability check follows. The first failing check stops subsequent checks. A capability
refusal is classified by OPS-11 and carries DOM-10's existing unsupported result; `OPS-11` says "the system MUST classify the error into `failed` or `needs_reconciliation`". This
paragraph introduces no commitment, rate or solvency check for a non-purchase.

For an exposure-reducing cancellation, OPS-41's restore claim gate and ordered fence-
transaction decision run before this capability check. `OPS-41` says "the worker MUST make no provider call, settle the operation `succeeded`" and "the claim MUST defer"; a no-call success or defer returned
by that decision takes no capability check. A decision that proceeds to cancellation MUST
pass the capability check after the fence transaction is acknowledged and before any
driver call or write-started marker. Capability failure follows the existing failed-attempt
and episode disposition; it does not authorize another automatic attempt or clear a fence.
An internally enqueued operation takes no capability check at enqueue. API-7's operator
retry ceiling and OPS-39's system-ceiling exemption retain their existing scope.

The capability is the operation's entry in the mapping table. A rescue-based install checks
its strategy capability first and rescue_ssh second, before beginning rescue; an inventory
checks rescue_ssh. `PRV-25` says "After the ordinary authorization, capability and `API-16` validation" and "An identical established value MUST settle `succeeded`"; that identical-PTR success remains after its capability check. No
capability is inferred from an install-eligibility list, and this timing rule adds no gate
to refresh, a manual attachment release, or the capability-less methods named by PRV-4; `PRV-4` says "The three methods with no entry there — *describe capabilities*, *get machine* and *refresh rescue session*".
