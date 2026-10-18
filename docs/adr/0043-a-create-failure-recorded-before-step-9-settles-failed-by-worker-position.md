# A create failure recorded before step 9 settles `failed` by worker position

**Status:** accepted (2026-10-18, the owner's decision, option 1; `pv-qga`; panel r57,
`docs/research/panels-2026-10/r57/`).

## Context

Panel r57's synthesis records the owner's decision under "Owner's decision". A List offers
read can time out without any purchase request, yet kind-only ambiguity sent that create into
reconciliation. `OPS-43` places "Obtain the current driver List offers result" at step 4 and
"Perform the per-order key upload, then the order" at step 9. The worker can distinguish a
failure recorded before invoking step 9 from a failure of a step-9 call, including a call
that failed before sending any byte.

The safety argument belongs here. Before step 9 no provider mutation has been requested:
`PRV-50` says "The driver's List offers MUST be read-only", and `PRV-47` requires validation
"without any provider mutation for that create, including a per-order key upload or order
request". `OPS-11` already uses knowledge that nothing changed: its install row says "for any
failure at all while `OPS-45`'s two markers say the disk is untouched", and its refresh row
says "a failure changed nothing". The create boundary uses worker position, without adding
a marker.

Step 8's acknowledgement is not its commit. `OPS-43` says "Step 9 MUST begin only after step
8's transaction is acknowledged." A committed transaction can lose its reply; an account-status
write can then make the repeated account check fail. The column is set although nothing was
ordered. After acknowledgement and before step 9, a recorded failure also differs from a
restart: `OPS-15` says "a set column takes that ordinary path", whereas the live worker knows
its position. The requirements carry those distinct cases.

## Decision

- `OPS-11` owns the classification: "Any create failure the worker records before any step-9
  request (before any per-order key upload or order request) MUST settle `failed`, whatever its
  kind." It owns the kind and retryability, including "An `OPS-21` cancellation of `execute`
  stays a cut-off `conflict`", and the boundary: "this rule MUST NOT read `about_to_order_at`,
  nor any snapshot or cached copy of it". From step 9 onward its create row retains
  "`needs_reconciliation` if the failure is *ambiguous*, otherwise `failed`".
- `OPS-21` points at that create row for a recorded cancellation: "For a create, a cancellation of
  `execute` recorded before step 9 is the exception". The retry-loop exit is
  separate: `OPS-49` says "A worker cancelled during the retry loop stops retrying and exits",
  and for the store-error exit "on exhaustion the outcome in hand is thrown away and
  `OPS-15` classifies the row as interrupted".
- `PRV-50` owns the read-only guarantee: "The driver's List offers MUST be read-only under
  `PRV-12`'s guarantee"; `PRV-12` says "Get machine MUST be read-only and free of side effects".
- `LDG-32` owns release: "A commitment MUST be closed, and its remaining amount released in
  full". Its includes clause and `LDG-39`'s "Deterministic rejection before acceptance" row
  point at the create classification; the latter retains "**Never debited**; released with the
  commitment (`LDG-32`)". `STO-58` owns the exclusion's lifetime: "Its lifetime follows the
  winning create's outcome settlement".
- `STO-3` owns settlement ordering: "The guarded status write precedes every money write in
  the transaction and short-circuits the rest", after taking the tenant's primitive. Its
  worker-write bullet includes this settlement, without a null-column term.
- `OPS-43` owns the step sequence and the lost-reply account-check case: "the repeat can fail
  that check with the column already set". `OPS-45` retains
  "The column is not a marker" and points to the create row for worker classification.

Retryability is guidance for a new operation, not an automatic repeat. `PRV-40` says "A retry
after expiry is a new operation, not an automatic requeue or another attempt by this operation".
Other precedents for a failed create with retryability true are `OPS-15`'s restart error,
"with `retryable: true` on both the error and the operation view", and `OPS-23`'s missing field,
`incomplete_record`, "and `retryable: true` on both the error and the operation view".

## Considered and rejected

- **Shape A: scope ambiguity to mutating requests.** This would also change power, reverse DNS,
  delete and release attachment. The owner chose the create row's narrower change; r57
  identified those existing-machine marker questions as separate work.
- **Shape C: an exception owned by OPS-43, outside the classifier.** That would divide failure
  disposition between two owners. `OPS-11` says "On failure, the system MUST classify the error".
  The analogy with `PRV-13c` fails: that requirement says a failed post-order read "MUST NOT
  change the create's settlement", while this decision selects a settlement.
- **The status quo.** Temporary commitment retention is conservative about duplicate orders,
  but manufactures uncertainty for a read with no purchase request. The explicit read-only
  guarantee and the step-9 controls answer that risk.
- **Opus's internal kind for a cancellation.** The taxonomy's `internal` means "Defect in this
  system" (`01-domain-model.md`, Error taxonomy); cancellation keeps its cut-off `conflict`. Its reason value remains
  `pv-f7a`'s separate question.
- **Opus's step-8-send or IS NULL boundary.** Inside step 8's own window the first agrees with
  step 9, since the worker can record only a deterministic `STO-47` refusal there; it differs
  after step 8 is acknowledged and before step 9, where it would leave a recorded failure
  ambiguous though nothing was ordered. The second refuses the settle write on the lost-reply path, where the column is
  set though nothing was ordered, leaving the create `running` for a restart to send to
  `needs_reconciliation`. Neither a preceding null read nor a cached null distinguishes a
  failure after step 9 begins. The worker position boundary includes the acknowledged-step-8 window without
  reading the column.

## Consequences

The requirement owners above carry the rules; this record carries the decision and rejected
options. `ADR-0035`'s Q11 order-request rejection stands: "settling a pre-send `network` failure
as `failed` (a behaviour change beyond the question)" remains rejected for step-9 calls,
including key upload. `ADR-0035` and `ADR-0042` gain dated pointers.

The tables model carries the worker-position fact on `Failure`, a dated switch and proofs for
both sides of the boundary and independence of other kinds. Witnesses pin the switch and the
cut-off distinction; `accepted_never_failed` pins the accepted mutation exclusion. `CNF-361` carries the running-system
cases, money assertions and stale-null controls; a proof is never conformance (`ADR-0025`).
