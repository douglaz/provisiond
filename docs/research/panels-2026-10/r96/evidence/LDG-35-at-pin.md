**LDG-35** **The authorization read and the commitment write MUST be serialized per tenant.**
Computing `available` and opening a commitment in one transaction is not sufficient: two
transactions can each read the same balance and each commit, leaving twice the balance reserved
and one machine unfunded. This is write skew, and it commits without error under both READ
COMMITTED and SNAPSHOT isolation. A deployment MUST use a per-tenant lock, a serializable
transaction, or a conditional write against a versioned balance row, and MUST state which.
`STO-1` and `STO-51` specify exactly this kind of primitive for the queue and for one running
operation per machine; money needs one too, and did not have one.

**Stated 2026-09-06 (`ADR-0015`): per-tenant advisory locks**, held for the transaction and acquired
in the ascending order the amendment below requires. *The obligation to state one stood unmet from
the day it was written, because the reference store was an embedded single-writer engine whose
global write lock served the purpose without anyone selecting it (`STO-6`). A requirement met by
accident reads as met, which is why this one survived every review that checked whether the rule
existed rather than whether anything had chosen how to satisfy it.*

**AMENDED 2026-08-31 — two tenants, one transaction, and the primitive cannot depend on a tenant
row.** `WIR-42`'s attribution appends a correction pair spanning **two** tenants' ledgers and
`LDG-70` requires every append to happen inside this serialization, so one transaction must hold two
primitives — which this requirement never contemplated and never ordered. Therefore:

- **A transaction MAY hold the primitive for more than one tenant, and MUST acquire them in
  ascending tenant-identifier order.** Two concurrent attributions in opposite directions would
  otherwise deadlock, on the operator surface, on the money path.
- **The primitive MUST NOT require a live `tenants` row.** The ordinary input to `WIR-42` is a
  deposit whose tenant `API-34` already reaped, and `STO-26` deliberately removes the foreign key so
  its entries survive. A primitive implemented as a per-tenant lock row — which the paragraph above
  explicitly permits — would have nothing to lock for exactly the tenant being corrected.

*Found by a cross-model review of the abuse and attribution surfaces. The deadlock is the visible
half; the missing lock row is the one that fires on the common case.*

