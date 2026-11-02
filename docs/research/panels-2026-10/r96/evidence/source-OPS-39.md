03-operation-lifecycle.md
**OPS-39** **AMENDED 2026-09-08 (`ADR-0017`) — the episode is a row, its index is the dedup, and
it is never blocked by a caller's ceiling.** A system-detected condition on a machine is an
**episode** (`DOM-31`, `STO-52`): opened once, and found open by every subsequent sweep until it
closes (`OPS-48`). The episode identifies the *condition* (this machine's exhaustion, this
account's loss), not the sweep that noticed it. `STO-52`'s partial unique index admits at most one
open episode per `(machine_id, key)`, and a sweep MUST enqueue nothing against a machine whose
episode under that key is open — the index, not a claim, is what makes the second sweep enqueue no
duplicate cancellation. **For an exposure-reducing cancellation the key is the action, `delete`,
not the `system_reason`** (amended 2026-08-14), and the reasons that contributed are retained as
the episode's `reasons` **set**. Two reasons to cancel the same machine — exhaustion and its
tenant's suspension, say — are one exposure, not two: keyed by reason, each sweep opened its own
episode and each enqueued its own delete, and `OPS-8`'s per-machine serialization only orders
those two calls, it does not dedupe them. On a provider that accepts a *scheduled* cancellation
(`STO-8a`, `DOM-19`) the second call can then alter or repeat the first's mutation. Every other
kind of system trigger keys on `(machine_id, system_reason)`, because those really are distinct
episodes with distinct remedies. The attempt carries the reason it was enqueued under and the
episode it belongs to (`operations.episode_id`); the added reasons live on the episode, so it
still records why it stayed open.

**Opening a fresh episode per sweep would make the index fire never**, which is the defect this
rule exists to prevent — otherwise a sweep that runs every minute enqueues a fresh cancellation
every minute for the same exhausted machine, which is repeated provider mutation by timer. That
the episode outlives the operations that carry it is trivially true — it is a row, not an entry on
an operation — so `STO-14`'s deletion of settled attempts leaves the dedup intact. **A machine
recorded gone closes its open episode in that same transaction** (`OPS-48`, `ADR-0021`); the
episode *row* outlives the tombstone as the machine's does (`STO-8`), because an operator
investigating an attempt still needs it. *Until 2026-09-09 this sentence said a tombstoned machine
keeps its open episode, and a terminated account's episodes sat `stalled` in `OPS-26`'s listing
forever.*

**Exposure-reducing system cancellations MUST be exempt from `SEC-39`'s per-principal destruction
ceiling.** That ceiling exists to bound what a runaway *caller* can destroy; applying it to the
system's own exhaustion cancels means a tenant that hit its destruction limit keeps running
machines it cannot pay for, with the operator paying. Pacing MAY delay such a cancellation
briefly; nothing may deny it. The wait `OPS-41`'s order gives a cancellation while its machine's
currency has no rate is a delay and not a denial: it ends at the rate's return or at `LDG-64`'s
bound (*added 2026-10-02, `ADR-0029`*).

**System-initiated provider mutations MUST be operations, and the tenant MUST see them.** Exhaustion cancelling a machine (`LDG-14`), `OPS-36`'s attach-then-cancel, and any other
mutation the deployment performs on a tenant's machine without a caller request MUST go through
this queue — the atomic claim (`OPS-5`), per-machine serialization (`OPS-8`), settled states,
`needs_reconciliation` included, because a cancel
whose outcome cannot be established is ambiguous no matter who requested it — and MUST appear in the
tenant's operation list marked `requested_by: system` with a stated reason (`exhausted`,
`late_attach_cleanup`, `tenant_suspended`, `rate_outage_bound`; *`account_lost` was in this list
until 2026-09-05 with nothing that enqueued it — `SEC-46` cancels nothing on an unreachable or
rejected credential and has nothing left to cancel on a termination*). Without this,
`GET /v1/operations` is not the history of
a tenant's fleet, and the hole sits exactly where the most alarming event does: the machine that
vanished overnight (`F31`). A pure balance event with no provider mutation — a commitment
release, a re-derivation — mints **no** operation; the ledger is already that record.

