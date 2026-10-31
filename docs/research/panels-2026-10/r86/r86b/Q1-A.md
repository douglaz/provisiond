### Complete candidate Q1-A — admission and claim, with system enqueue kept distinct

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


## Wording correction — 2026-10-31 (Panel N r93)

The text above is retained as the historical form approved in owner item 16.
The executable pv-5pmu Agent Brief uses the following replacements under the
owner's 2026-10-28 wording rule; all other Q1-A text is retained.

Replacement for the replay sentence:

```text
API-7 step 5a says "an equal fingerprint under the
    same `(principal, key)` returns the stored result, a different one fails `conflict`."; a replay returned there never reaches this check.
```

Replacement for the manual-release clause:

```text
API-65 says "On a row whose `cleanup` is `manual` there is no driver call to make: it
writes `released_at` and answers `200` with the row, minting no operation,"; a manual attachment release takes no capability check under this timing rule.
```

Source pin: `3d1fca55e64056e5ad6bc9ac3edcc308ecf04073`.
Review head: `fde983c1794e8d4727f22bc87d1d6ee7f407eca5`.
Panel record: `../../r93/notes.md`.
