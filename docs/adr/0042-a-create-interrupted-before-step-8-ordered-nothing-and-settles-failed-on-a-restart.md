# A create interrupted before step 8 ordered nothing, and settles `failed` on a restart

**Status:** accepted (2026-10-17, the owner's decision; `pv-k4l`; panels r56 and r56b,
`docs/research/panels-2026-10/r56/` and `docs/research/panels-2026-10/r56/r56b/`).
Amends `ADR-0016`'s startup pass.

## Context

`ADR-0016` recorded "every `running` row found at startup is by definition an interrupted
operation whose provider call is uncertain, and it goes to `needs_reconciliation`". Before step 8,
a create could have made no provider mutation. The owner chose a distinct all-channel column
rather than letting the correlator pair decide that outcome. `OPS-43` places "Perform the per-order key
upload, then the order" at step 9. That boundary includes the first mutation, not just the order.

## Decision

- `OPS-43` owns the live write: "MUST set `operations.about_to_order_at` to
  `COALESCE(about_to_order_at, <transaction time>)`" in step 8, on every ordering channel.
  Its acknowledgement rule is "Step 9 MUST begin only after step 8's transaction is acknowledged."
- `OPS-15` owns the restart outcome: "A create found `running` at startup with `about_to_order_at`
  null MUST be settled `failed`, on a restart only." It also owns the conditional status write,
  atomic full release and the exclusions: "It does not fire while a restore record is open",
  and "nor on a store that may have lost committed writes, such as a promoted asynchronous standby".
- `STO-13` owns the migration: "the migration MUST stop every previous-release component", backfill
  every existing running create before new components start, and "A binary that claims without
  writing this column MUST NOT run against the store after the backfill". This is the conservative
  backfill the bead's Agent Brief requires (items 5 and 10b), taken from panel reader sol's
  round-r56b draft.
- `API-63` owns termination's dispatch test: "A claimed create with `about_to_order_at` set MUST
  be treated as potentially dispatched".

## Considered and rejected

- **Use the correlator pair's null as the dispatch test.** That would make settlement depend on
  the unresolved meaning of the pair on a `correlator: none` channel (pv-ytv). The column records
  the transaction boundary independently.
- **Extend `write_started_at` to create.** `OPS-45` says "It does **not** reach `create`:
  there is no machine yet". Its markers answer a different question.
- **Read a set column to classify the create.** `ADR-0035` rejected "A durable dispatch marker on
  create" because it "cannot tell a key upload from an order or a rejection from an acceptance".
  That remains true of the set column. The null read settles only a `running` create on a
  restart (`OPS-15`: "A create found `running` at startup with `about_to_order_at` null MUST be
  settled `failed`, on a restart only.").
- **Use the crash-route markers.** `ADR-0032` rejected "Startup requeue": "Restore can roll those markers back too;
  they cannot establish what happened in the lost interval". A restore can lose the new
  column's committed write too; the exception is restart-only. `OPS-15` excludes that case: "It does not fire while a restore
  record is open", and "nor on a store that may have lost committed writes, such as a promoted
  asynchronous standby".
- **Require the column to be null in the worker guard.** A lost reply would refuse its own repeat.
  The shape comes from `ADR-0022`: "`COALESCE(marker, now)` guarded on `status = running`, never guarded on
  the marker being null"; the column is not a marker.

## Consequences

The requirement owners above hold the rules and their arguments. `ADR-0035` gains a dated
pointer inside its rejected bullet. A set column leaves a create as ambiguous as today; it
cannot establish whether a resource was produced. *(2026-10-18, `ADR-0043`, `pv-qga`: this remains the restart path; the create row now classifies a worker-recorded failure by position even with the column set. `OPS-11` says "Any create failure the worker records before any step-9 request (before any per-order key upload or order request) MUST settle `failed`, whatever its kind.")* The restore model carries the restart-only
arm, a restore-trace theorem and a migration theorem. The live model does not prove the
step-8-before-step-9 assumption, and the stored-record purge and kill-timing checks remain
conformance obligations.
