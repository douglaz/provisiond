12-billing-and-ledger.md
**LDG-32** **AMENDED.** A commitment MUST be closed, and its remaining amount released in full,
on **every** terminal outcome: the machine's meter stops **and every billable attachment it left
behind has release evidence (`released_at`)** (`PRV-13a`, `STO-18`); the create fails deterministically; the create
is resolved absent (`OPS-27`); the create is abandoned (`OPS-31`); **or the machine's
provider account is recorded `terminated`** (`SEC-46`, `API-63`), which stops every meter in that
account (`LDG-74`) and closes every open commitment on its machines in the transaction that records
it — *the stop is named here because the first row above makes stopped billing the precondition for
every other outcome on this list, and the termination row arrived without it.*

*The account-termination row was missing until 2026-09-02 while `SEC-46` and `API-63` both cited
this requirement as the closing rule and the commitment state machine above drew the edge — the
"every terminal outcome" list named four and the set had five.* And the abandonment row is scoped to
the kinds that opened a commitment: an install or a delete opens none, and the only one within reach
is the machine's **running** commitment, which abandonment MUST NOT release (`OPS-31`).

The outcome "the create fails deterministically" includes the create row's case. `OPS-11` says "Any create failure the worker records before any step-9 request (before any per-order key upload or order request) MUST settle `failed`, whatever its kind."

*Amended 2026-10-18 (`pv-qga`; panel r57, `docs/research/panels-2026-10/r57/`; `ADR-0043`): included the worker-recorded failure case regardless of error kind.*

**Attachments keep the commitment open, and metering follows them.** `PRV-13a` models volumes,
snapshots and reserved addresses that survive machine deletion and keep costing money; `PRV-13b`
reserves for them; but the meter (`LDG-37`) was machine-only, so a released commitment left them
billing against nothing. A deployment MUST meter each billable attachment on its own identity
through the earlier applicable `PRV-45` effective date or `released_at` observation, and MUST
keep the commitment open while any billable attachment's `released_at` is null, even if its
customer meter has stopped at a stored date. Whether an offer may be sold with a billable
attachment that can outlive its machine is `PRV-49`'s rule. *Amended 2026-10-09
(`ADR-0037`, Q14): customer stop and release evidence separate. Amended 2026-10-11
(`ADR-0037`, Q23b): sale rule has one owner.*

**Losing a provider account is not evidence that billing stopped** — see `SEC-46`, amended for the
same reason. **A terminal path with no close rule strands a customer's satoshis
permanently** — there is no withdrawal (`ADR-0004`), no expiry, and under `ADR-0005` no identity
to appeal with, so an ordinary retry loop against a contended offer would otherwise render a
balance unusable forever.

