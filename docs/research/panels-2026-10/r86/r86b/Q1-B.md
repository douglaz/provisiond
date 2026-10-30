### Complete candidate Q1-B — claim only for non-create, including caller/operator requests

Insert the following paragraphs at the same `DOM-10` insertion point instead of Q1-A's paragraphs:

```text
For power on, power off, reboot, hard reset, every install strategy, rescue inventory,
reverse DNS, delete/cancel and API-cleanable attachment release, the required capability
check runs in the worker at claim, not at admission. API admission retains its validation,
admissibility and ceiling checks and enqueues an otherwise valid request even when the
running api descriptor lacks that operation's capability. This includes API-64 operator
retry and API-65's API-cleanable release. A suspend parent takes no per-machine capability
check at admission. A manual attachment release has no driver operation or capability check.

Every operation in the preceding paragraph MUST pass the capability check using the
worker's running descriptor after claim and per-machine serialization, before its first
driver call and before either OPS-45 marker is written. This includes operations enqueued
without an HTTP request and attachment releases enqueued by a successful delete. Repeated
validation checks caller-supplied fields first, api-written admission fields second, then
the other applicable local validation, including machine install eligibility and OPS-40's
signed-URL check; the capability check follows. The first failing check stops subsequent
checks. A capability refusal is classified by OPS-11 and carries DOM-10's existing
unsupported result. This paragraph introduces no commitment, rate or solvency check for
a non-purchase.

For an exposure-reducing cancellation, OPS-41's restore claim gate and ordered fence-
transaction decision run before this capability check. A no-call success or defer returned
by that decision takes no capability check. A decision that proceeds to cancellation MUST
pass the capability check after the fence transaction is acknowledged and before any
driver call or write-started marker. Capability failure follows the existing failed-attempt
and episode disposition; it does not authorize another automatic attempt or clear a fence.
An internally enqueued operation takes no capability check at enqueue. API-7's operator
retry ceiling and OPS-39's system-ceiling exemption retain their existing scope.

The capability is the operation's entry in the mapping table. A rescue-based install checks
its strategy capability first and rescue_ssh second, before beginning rescue; an inventory
checks rescue_ssh. PRV-25's identical-PTR success remains after its capability check. No
capability is inferred from an install-eligibility list, and this timing rule adds no gate
to refresh or the capability-less methods named by PRV-4.
```

Use the exact same `API-7` and `OPS-23` pointer insertions printed under Q1-A. No create gate moves. This historical candidate expressly admits missing support; assess its conflict with the newly included OVR-2. It is not an authorized exception to OVR-2.

