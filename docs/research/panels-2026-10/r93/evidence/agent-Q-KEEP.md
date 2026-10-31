## Agent Brief

**Category:** bug
**Summary:** Specify the non-create capability-check placement and error precedence.

**Owner decision:** “Approve A (Recommended)” (`owner-decisions-1030.md`, item 16). Adopted exact form: `docs/research/panels-2026-10/r86/r86b/Q1-A.md`.

**Current behavior:**

`01-domain-model.md:515` at `3109b5b44eae17e288cf52aaa976993bd8c5626c`:

```text
**DOM-10** Every operation with a capability MUST be gated on it before the
driver is called, **including create**; the driver methods with no capability entry are the ones
`PRV-4` names. There MUST be no operation whose only gate is
a driver-internal check. A capability check failure MUST return an "unsupported" error
naming the provider account and the capability, with `retryable: false` on both the error and the operation view where there is one.
```

`04-api-contract.md:241` at `3109b5b44eae17e288cf52aaa976993bd8c5626c`:

```text
5d. **gate a create on its ordering capability** under `DOM-10` (`PRV-10`, `DOM-16`). A refusal stops here and is not collected by the tail.
```

**Desired behavior / key interfaces:**

This form adds the following paragraphs after the existing mapping table in `DOM-10` (before its amendment note); existing mapping rows and error sentence stay as quoted:

```text
For power on, power off, reboot, hard reset, every install strategy, rescue inventory,
reverse DNS, delete/cancel and API-cleanable attachment release, a caller or operator
request MUST pass the capability check before admission enqueues the operation. This check
runs after API-7's steps 1–5c and all endpoint-local admission validation and admissibility
checks, immediately before the enqueue transaction's first write. It uses the descriptor
running in api and makes no provider request. A failed check enqueues no operation and
makes no endpoint-state or money write. A replay returned by API-7 step 5a never reaches
this check. An API-64 operator retry checks delete_machine before its state-change/enqueue
transaction; API-65's manual release has no driver operation and takes no capability check.
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
refusal is classified by OPS-11 and carries DOM-10's existing unsupported result. This
paragraph introduces no commitment, rate or solvency check for a non-purchase.

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
to refresh, a manual attachment release, or the capability-less methods named by PRV-4.
```

In `API-7`, insert after step 5d and before "The tail then depends on what the endpoint does:":

```text
For the non-create tails, capability-check placement and precedence belong to DOM-10.
```

In `OPS-23`, append before its amendment notes:

```text
For non-create capability-check placement and its order relative to this validation,
OPS-40 and OPS-41, see DOM-10.
```

No create gate moves under Q1-A. For a refusal before any rescue dispatch, the existing classifier and markers retain their quoted meanings. The added early admission check does change an unsupported request's observable phase; assess that explicitly.


**Acceptance criteria:**

`docs/research/panels-2026-10/r86/r86b/Q1-A.md:11`:

```text
A failed check enqueues no operation and
makes no endpoint-state or money write.
```

`docs/research/panels-2026-10/r86/r86b/Q1-A.md:25`:

```text
The first failing check stops subsequent checks.
```


**Out of scope / retained / rejected:**

`docs/research/panels-2026-10/r86/r86b/Q1-A.md:58`:

```text
No create gate moves under Q1-A.
```

`owner-decisions-1030.md`, item 16:

> Rejected: "Keep text unchanged (C0)".

**Drift since the panel pin:**

- `01-domain-model.md:515` at `3109b5b44eae17e288cf52aaa976993bd8c5626c` and `01-domain-model.md:515` at `832a2197aec28e63bd6d0bf70996171cd0dbd6f7`: unchanged (the complete landing-site file is byte-identical).
- `04-api-contract.md:241` at `3109b5b44eae17e288cf52aaa976993bd8c5626c` and `04-api-contract.md:241` at `832a2197aec28e63bd6d0bf70996171cd0dbd6f7`: unchanged (the complete landing-site file is byte-identical).
- `03-operation-lifecycle.md:2051` at `3109b5b44eae17e288cf52aaa976993bd8c5626c` and `03-operation-lifecycle.md:2051` at `832a2197aec28e63bd6d0bf70996171cd0dbd6f7`: unchanged (the complete landing-site file is byte-identical).

PR #51 is included in this base; its merged tip is `832a2197aec28e63bd6d0bf70996171cd0dbd6f7`.

