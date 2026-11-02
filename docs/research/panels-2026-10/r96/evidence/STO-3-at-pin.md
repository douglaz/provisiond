**STO-3** **AMENDED 2026-09-12 (`ADR-0022`) — the worker's guard carries the claim number and
admits its own repeat; the defer is the fifth guarded write and the restore quarantine the
sixth.** Six conditional writes move an operation, and each MUST report whether it affected a row
(`OPS-22`):

- **A worker's write** — every settled-state write, and a worker moving its own operation into
  `needs_reconciliation` — is guarded on
  `(id, status = running, claim_number = mine) OR (id, status = target, claim_number = mine, the
  written columns are not distinct from what is being written)`, where `mine` is the number
  `STO-1`'s claim returned (`OPS-6`). The second branch admits the row this same execution's write
  already produced — the claim term is on both branches, since matching columns do not establish
  matching execution — so a repeat after a lost reply (`OPS-49`) affects one row and changes
  nothing; `revision` and `updated_at` advance only on the first branch, which keeps `API-53`'s
  "strictly increases on each client-visible modification" true. **The guarded status write
  precedes every money write in the transaction and short-circuits the rest** — after `OPS-50`'s generation read and then `LDG-35`'s primitive where the settlement needs it,
  since those locks, in that order, are the transaction's entry —
  so `OPS-27`'s multi-row settlement repeats as a unit or not at all. `OPS-50` says "MUST read
  `STO-59`'s row `FOR SHARE` as its first statement".
  This includes the create row's worker settlement (`OPS-11`: "MUST settle `failed`, whatever its kind"): take the `LDG-35` primitive, make this guarded status write, then release under `LDG-32` ("A commitment MUST be closed, and its remaining amount released in full"). It adds no `about_to_order_at IS NULL` term.
  A write that affects no row means something other than this execution moved the operation —
  the startup pass after a restart, or a later claim after a defer — and the worker exits
  (`OPS-22`). *Until 2026-09-12 the guard was `(id, status = running)` alone; the `epoch = mine`
  term that once sat beside it held by construction, because the claiming process stamped the
  value itself (`ADR-0019`). The claim number does not: a later claim rewrites it.*
  *Amended 2026-10-18 (`pv-qga`; panel r57, `docs/research/panels-2026-10/r57/`; `ADR-0043`): included the create settle write within this worker branch and its money order.*
- **The defer** (`OPS-8`) — `running` back to `queued` with `available_at` advanced — is guarded
  on `(id, status = running, claim_number = mine)`. A write that affects no row means the operation
  was already deferred or already claimed again; the worker moves on and does not exit. *Added
  2026-09-12: this write was not in the list, and unguarded by the claim number a retried defer
  landing after a re-claim pulled the second execution's operation back to `queued`.*
- **The startup pass** (`OPS-15`) moves every `running` operation to its startup state —
  `needs_reconciliation`, or `failed` for a `refresh` (`ADR-0020`) and, on a restart,
  for the create exception (`OPS-15`: "A create found `running` at startup with `about_to_order_at` null MUST be settled `failed`, on a restart only.") — guarded on
  `(id, status = running)`, with `(kind = create, about_to_order_at IS NULL)` additionally inside
  the create settlement's conditional write, and carrying **no claim term**: it is made by no execution. It runs after `OPS-15`'s generation advance and before the process makes any claim, so no
  earlier engine's write commits beside it (`OPS-50`). `OPS-50` says "MUST read `STO-59`'s row
  `FOR SHARE` as its first statement, compare it for equality with the value the engine's own
  startup pass wrote" and "Where the values differ, the transaction MUST roll back". `OPS-15`
  says "every earlier engine's write either committed before it, and is swept here, or is refused
  after it".
- **Resolution out of `needs_reconciliation`** is not a worker write (`OPS-3`): it is guarded on
  `(id, status = needs_reconciliation, resolution IS NULL)`, which is `STO-19`'s write-once rule
  expressed as the same kind of conditional write. *Unscoped, this requirement forbade every
  transition `OPS-3` enumerates — a `status = running` guard can never hold for an operation
  sitting in `needs_reconciliation`.*
- **The suspension fan-out's administrative transition.** `API-58` step (4) moves an operation
  that is still `queued` and was never claimed straight to `failed`, guarded on
  `(id, status = queued, requested_by = caller, the operation's tenant is suspended, and that
  suspension's fan-out parent is still unsettled)`. A child claimed by a real worker between the
  pass and the write must lose this race and settle as its own worker's write instead.
  *`requested_by = caller` was added 2026-09-05: the fan-out joins a pre-existing exhaustion
  episode by naming its queued delete rather than enqueuing a second one, and without this term
  step (4) failed the very delete step (3) had just named — an episode `OPS-48` then holds
  `stalled` for an operator, on a machine the suspension had reported as accounted for.*
- **The restore quarantine** (`STO-54`, `OPS-15`) moves a `queued` create, install or rescue
  inventory to `needs_reconciliation`, guarded on `(id, status = queued)`, and carries no claim
  term: it runs before any claim. *Added 2026-09-12.*

**Step 8's `operations`-row write** (`OPS-43`) is also a worker write, though it moves no status.
It is guarded on the first branch alone (`OPS-43`: "guarded on `(id, status = running,
claim_number = mine)`"), and its `COALESCE` preserves a set value. A whole-transaction repeat after
a lost reply changes no column and advances neither `revision` nor `updated_at` (`OPS-43`: "a
whole-transaction repeat after a lost reply affects one row and changes nothing").

*Amended 2026-10-17 (`pv-k4l`; panels r56 and r56b, `docs/research/panels-2026-10/r56/` and `docs/research/panels-2026-10/r56/r56b/`): included the create startup guard and step-8 worker write; the latter moves no status, and its repeat advances neither `revision` nor `updated_at`.*

*Amended 2026-10-24 (`pv-buc`; panel r66e, `docs/research/panels-2026-10/r66/r66e/`; owner decisions “Yes, R (Recommended)” and “Adopt; one combined Run”; `ADR-0047`): amended transaction entry and startup ordering.*

