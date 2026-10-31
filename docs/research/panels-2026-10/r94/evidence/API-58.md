**fences work already in flight** — a create claimed before the suspension landed MUST be allowed
to settle rather than abandoned mid-order, and its machine is then cancelled by the same sweep,
because abandoning an in-flight order is how a machine ends up bought, unrecorded and unbilled —
then (3) enqueues a system cancellation per machine (`OPS-39`) — then (4) **transitions the tenant's own work — `requested_by: caller`, never a system
cancellation — that is already
`queued` but never claimed straight to `failed`, carrying the reason in the operation's `error`:
`conflict`, with `details.reason: "tenant_suspended"`** (`WIR-9a`, `WIR-10b`) — it
has touched no provider, so cancelling it needs no operation, and it does **not** carry the error
kind `suspended`, which `OPS-11` classifies as admission-only and forbids a worker to emit: that
kind stays an admission-time rejection of a *caller's* write (`DOM-20`).
**Its `requested_by` stays `caller` and its `system_reason` stays null**, because `WIR-10` permits
a non-null `system_reason` only on `requested_by: system`, and re-labelling the request `system`
to make room for one would attribute the caller's own create to the system and destroy the record
of who asked for it. The reason belongs in the error, which is where a caller reads why its work
did not run. *`system_reason: tenant_suspended` was the withdrawn form and it produced an
operation view no strict parser should accept.* The value stays legal on the step-(3)
cancellations, which the system really did request (`OPS-39`). This transition is also **not** a
worker classification: nothing was claimed and no driver was called, so `OPS-11`'s install row —
which sends `conflict` to `needs_reconciliation` "once the write-started marker is set" — does not reach it, and the operation goes
straight to `failed` as stated. **Not being a classification does not exempt the database write**:
it is `STO-3`'s fifth named case (fourth until the defer was listed on 2026-09-12), guarded on its full predicate — `(id, status = queued,
requested_by = caller, tenant suspended, this suspension's parent still unsettled)`, quoted rather
than paraphrased since 2026-09-05, when a paraphrase here dropped the `requested_by` term and let
step (4) fail the system delete step (3) had just named — and reporting whether it affected a row, so a child claimed
by a real worker in the meantime loses this race and settles through that worker instead. The fan-out then lets anything
already `running` settle, **then re-sweeps: a create that
settled after the fan-out has produced a machine the first pass never saw, and it MUST be
cancelled by a second pass rather than left running against a suspended tenant** — the fan-out
repeats until a pass finds no un-cancelled machine; then (5) aggregates the outcomes,
including any that end `needs_reconciliation`. **The parent then settles `succeeded`, with those
children named in its result** (`WIR-39`'s `cancellations`) — its own job was to fan out and
account for every machine, and it has done it. `OPS-11`'s `suspend_tenant` row already counts a
`needs_reconciliation` child as complete for the parent, and step (5) did not say what that makes
the parent's own outcome; it is `succeeded`, never `failed` and never `needs_reconciliation`. The
unresolved children are their own records, resolved by their own evidence or their own operator
verb (`OPS-27`, `OPS-31`), and read through `GET /v1/operations` like any other operation. Holding
the parent open until they resolve would fence `WIR-41`'s resume off indefinitely and leave every
suspended tenant with a record that never closes.
**A create that has produced no machine yet passes the re-sweep's test**, so settlement here is not
the last guard: where such a create later attaches a machine to a still-suspended tenant, `OPS-27`'s
one-transaction rule enqueues the cancellation in the attach transaction itself, under the same
`OPS-39` trigger step (3) uses. **A process that dies mid-fan-out MUST NOT strand
the suspension**: the engine's startup pass (`OPS-15`) returns an interrupted `suspend_tenant`
parent to `queued`, and it is re-claimed and resumed like any other queued work, because the sweep
is idempotent by the open episode (`STO-52`'s index) and mutates no provider itself. It MUST NOT go
to `needs_reconciliation` and, on a restart, MUST NOT need an operator — *after a restore it waits for one while `STO-54`'s freeze holds the exception off (`STO-54`, `OPS-15`), because the fan-out it would resume may have been reversed inside the
lost interval*. Reads of the ledger, the machine list **and the tenant's abuse
cases** (`API-59`) MUST continue
to work while suspended — the customer's history is their evidence, and `LDG-22` forbids purging
it anyway. *The case reads joined this list on 2026-08-16 for the same reason and one more: the
collection exists because a notice commonly arrives after the machine is gone, and a suspended
tenant is the likeliest holder of exactly that case.* `SEC-45`'s one-action termination is this verb; `API-34`'s deletion applies only to
**pending** tenants, which have no machines. They MAY hold a below-minimum credit, whose ledger
entries survive them (`STO-26`, `LDG-22`) and remain re-attributable through `WIR-42` — so
"no ledger" was wrong, and it is the case `API-34` exists to handle.

**AMENDED 2026-09-02 — "un-cancelled" is defined, and a deterministically-failed child no longer
hangs the fan-out.** The re-sweep's terminating condition was never defined, and the two readings a
builder could reach were both wrong. **A machine is *cancelled* for the purpose of step (4) when this suspension has already accounted
for it** — the fan-out enqueued a cancellation for it, whatever that cancellation then did —
**and *un-cancelled* otherwise.** The parent records the machines it has enqueued for, in
`WIR-39`'s `cancellations` result; the pass enqueues for every non-tombstoned machine of the tenant
that is not already named there, and terminates when a pass finds none. **Where `OPS-39`'s episode
is already open on a machine under the `delete` key** — an exhaustion episode that predates the
suspension, or the machine `OPS-27`'s suspended-attach clause enqueued for — the pass MUST NOT
enqueue, and MUST instead **append `tenant_suspended` to that episode's `reasons` set (`DOM-31`)
and name its `current_operation_id` in `cancellations`**, which is what "accounted for" means for
it. *Added
2026-09-05. Without this the pass could neither enqueue for such a machine — `OPS-39` forbids the
duplicate — nor name it, so every pass found it un-cancelled, the parent never settled, `WIR-41`'s
resume was refused forever and a worker slot was pinned for the life of the tenant.* **An operation
that `OPS-41`'s no-mutation abort settled does NOT account for its machine**, whatever list names
it: the abort closed the episode (`OPS-48`), so the next pass opens a fresh one and enqueues afresh
— **and replaces the aborted operation's id in `cancellations` with the fresh one's**, so the
per-machine result always names the child currently accounting for the machine rather than one
that settled without acting — which `STO-52`'s index permits precisely because the episode is
closed. *Added 2026-09-05 against the interleaving where the worker's re-check reads the episode
before the join appends `tenant_suspended`, finds the machine funded after a price cut, and aborts
— after which a pass that trusted the name would settle the parent over a funded fleet on a
suspended tenant.*

*The test is the parent's own record, not the episode row.* An earlier draft of this
amendment keyed it on an episode existing "open or already resolved", which fails in both
directions: `OPS-48` **closes** the episode on `abandoned` and clears the fence, so an operator's
`abandoned` made a machine read un-cancelled again and the fan-out re-enqueued against it; and an
episode opened by an *exhaustion* sweep before the suspension would have made a machine read
cancelled that this suspension never touched. The parent's list is the thing that actually answers
"has this fan-out dealt with that machine", and it is already returned to the operator.

*Why the entry and not the outcome.* Keyed on the outcome, a child that fails deterministically —
`authentication` after a credential rotation, `unsupported` on an account that never declared
`delete_machine` — leaves its machine un-cancelled forever, while `OPS-39` forbids the next pass
enqueuing a second delete under the same open episode. The fan-out then cannot terminate and cannot
progress: the parent never settles, `WIR-41`'s resume is fenced indefinitely, and a worker slot is
pinned. Keyed on the entry, the pass terminates because the machine has been **accounted for**,
which is what the parent's job actually is.

**What that costs, stated rather than hidden: the parent settles `succeeded` while a machine of a
suspended tenant may still be running.** Three things bound it and all three are required. The
child's failure is a record of its own, named in the parent's result (`WIR-39`'s `cancellations`)
and readable through `GET /v1/operations`. A `failed` attempt moves its episode to `stalled`
(`OPS-48`), which `OPS-26`'s listing **surfaces to the operator** beside `uncertain`, and the
recovery is `API-64`'s retry on the same episode — which `API-7` skips step 5b for, so a suspended
tenant's stalled episode stays retryable. *Until 2026-09-05 this sentence continued "and the
machine keeps consuming its commitment, so `LDG-13`'s exhaustion path reaches it on the ordinary
schedule whether or not anyone looks" — which `OPS-48` forbids: the episode stays open, the sweep
enqueues nothing against an open episode, and the operator listing and retry are the only
recovery. `CNF-272` carried the same false clause and was corrected the day before; this copy was
not.* **A
suspension is not a promise that the fleet is gone; it is a promise that every machine has been
accounted for and that nothing further can be bought.** The terms and the operator documentation
MUST say so in those words, because "suspended" reads as "stopped" and on this one branch it is not.

**AMENDED 2026-08-31 — the flag lands at admission, not in the worker.** The withdrawn wording
said "the suspension flag and the full fan-out MUST commit together", which on a `202`-returning
endpoint (`WIR-39`) puts the flag in a *worker's* transaction. `API-7` step 5b reads
