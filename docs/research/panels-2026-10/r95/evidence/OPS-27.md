**OPS-27** **AMENDED 2026-09-08 (`ADR-0017`) — one correlator, searched on every channel.** The
system MUST attempt automatic resolution before asking a human. Resolution searches the provider
for the operation's correlator (`PRV-26`, `PRV-27`) on **every ordering channel the driver
reaches** (`PRV-38`), takes the union of what those searches return, and reaches one of the four
outcomes below:

| Finding | Resolution | Effect on the commitment |
|---|---|---|
| Exactly one resource across every channel | **Resolved-observed.** Attach it and complete the operation as though it had succeeded. | Becomes the machine's running commitment (`OPS-36` where it was already released) |
| The provider's search is authoritative and returns nothing on any channel, and the negative window has elapsed — or a matched resource is read directly and is gone, past `PRV-36`'s window | **Resolved-absent.** No resource exists to attach — *"the mutation did not happen" until 2026-09-05, which the matched-and-gone case falsifies: the order landed and left nothing* | Closed and released in full (`LDG-32`); a charged fee per `LDG-39`'s absent row |
| More than one resource across every channel | **Unresolved — duplicate.** MUST NOT auto-attach either. Surface both for operator remediation (`OPS-38`). | Released per `OPS-33`; the duplicate is operator cost |
| Any one of the searches cannot be made authoritative — the provider cannot filter, the listing window has expired, or no verified correlator exists for the operation's ordering channel (`PRV-33`) | **Unresolved.** Escalate to an operator (`OPS-31`, `WIR-35`). | Released per `OPS-33`, which applies here too |

**Amended 2026-10-09 (`ADR-0040`): a lost-reply auction create uses the per-order fingerprint search across every ordering channel. The matched transaction supplies its delivered `server_number` for the confirming read. Offer-number equality is not assumed; an offer-number `not_found` cannot establish absence and a positive offer-number read alone cannot attribute the machine to this order.**

**A correlator match is proof that an order landed, not that the resource exists, and the first
row MUST be confirmed by a direct read before it attaches anything.** `08-provider-notes.md`
records, from a live order, that Hetzner Robot's transaction "still" reports `status: "ready",
server_number: N` after the server is gone — "the listing outlives the machine". So resolution
MUST follow a match with *get machine* (`PRV-12`) on the matched `external_id`. Where that read
finds the machine, the first row applies. **Where it returns `not_found` inside `PRV-36`'s
visibility window, the operation stays unresolved and resolution retries on its next pass** — a
Robot order reports `ready` with a server number before the server API lists the machine, and a
read inside that window is not evidence of absence. **Where it returns `not_found` past the
window, the operation resolves *absent* — the second row's outcome, reached without waiting for
`OPS-33`'s negative window, because a direct read past the visibility window is authoritative
where a listing was not**: no machine is attached and the commitment is released in full — with one addition to `LDG-39`, that a setup fee or prepaid first unit (*the unit since 2026-10-08,
`ADR-0033`*) the provider's own transaction shows was charged becomes the deficiency `LDG-39`'s
absent row names for it rather than being pretended away.
*Added 2026-09-05, and corrected the same day: a first form invented an "accepted-but-gone"
outcome, which had no value in `WIR-35`'s closed `resolution` set, no settled status, no `LDG-39`
row, and ignored the visibility window — so the ordinary Robot create resolved as gone and came
back as an `OPS-36` late attach carrying a wind-down deficiency. Without the read at all,
reconciliation attached, metered and fee-settled a ghost.*

**A create MUST NOT settle `succeeded` on the strength of the reply in hand alone.** Before the
terminal write the system MUST search the correlator across every ordering channel the driver
reaches (`PRV-38`) and MUST settle `succeeded` only where that search yields exactly one
resource, confirmed by the direct read above. **After acceptance, zero or many resources, a
failed search, or any non-authoritative search MUST leave the create in `needs_reconciliation`**;
a failed confirming read likewise cannot establish success or settle-time absence. Later
resolution follows the rows above. A create settles exactly one machine, so **more** than one is
`OPS-38`'s many-case: it
MUST NOT auto-attach either, and it goes to an operator (`OPS-31`), never to `succeeded`. An order
that lands *after* the search was taken is beyond what any settle-time search can see, and
`OPS-32`'s account sweep is the backstop for it. *Until 2026-09-05 the search was over several
attempts' correlators; `ADR-0014` removed the second attempt, and what has to be searched is
several channels, which `PRV-38` found was never covered.*

*Amended 2026-10-08 (`ADR-0035`): the settle-time outcomes above include every unsuccessful
search after acceptance. A matched order still in progress stays unresolved; `OPS-33` owns the
negative-window qualification.*

**A create whose order landed MUST be recorded in one transaction**, in the manner of `LDG-11`.
This is one rule with **three entry points** — successful settle-time verification after the
provider **accepting the order in its reply**,
`OPS-27` **resolving-observed** a create whose reply was lost, and `OPS-36`'s **late attach** of a
machine whose commitment `OPS-33` had already released — because each writes a set of effects a
partial commit of which is unrepairable. Those effects are: the terminal write on
the operation (`STO-19`'s write-once columns), the machine row, the **settlement of the setup fee
and of the prepaid first unit** (`ADR-0033`, 2026-10-08) — each a debit where a commitment is still
open, each an `LDG-66` operator deficiency where `OPS-33` has released it (`LDG-39`, amended
2026-09-02; neither is ever taken from available balance) — the clearing of any parked `LDG-67`
record, and the commitment decrement where a commitment
is still open (`LDG-31`). They MUST commit together, under `LDG-35`'s per-tenant serialization
because the debit reads the balance. **The late-attach entry point carries three further effects,
and they commit in that same transaction**: the attach itself; *either* the wind-down commitment
*or* the `LDG-66` operator deficiency, using `OPS-36` and `LDG-40` for the branch decision,
never neither and never both; and the enqueue of the cleanup cancellation, which opens the
machine's `delete` episode as it goes (`OPS-39`, `OPS-48`). A partial commit leaves a state
nothing in the record can repair: a machine whose fee is still parked bills that setup a second
time when the obligation is next read, a debit without the machine row charges a customer for a
machine no tenant owns, a machine row without its debit runs a create nobody paid for, and an
attach whose cancellation never reached the queue is an unfunded machine billing with nothing
scheduled to stop it.

*Amended 2026-10-14 (`ADR-0037`, Q31).*
*Amended 2026-10-15 (`pv-sgj`): the landed-order transaction's placement sentence gained its MUST keyword.*
*Amended 2026-10-15 (`ADR-0037`, Q34).*
At every entry point to the landed-order transaction above, that transaction MUST include
the column write with the machine row: `PRV-13c` says "The landed-order transaction MUST write the date of a successful read the committing pass holds, otherwise null, in `machines.earliest_cancellation_date` with the machine row".
`PRV-13c` says "The system MUST record the date of the committing pass's successful post-order read in `machines.earliest_cancellation_date`", "An accepted cancellation's response (`PRV-13`) that carries the per-machine date MUST supply it to that column" and "After the committing pass's failed post-order read, the column MUST remain null until such a response supplies the date".
`PRV-13c` says "once, when the create settles, after `OPS-27`'s confirming read".

*Amended 2026-10-04 (`pv-gip.27`, J1): the flowchart and atomic attach include `LDG-40`'s
no-rate branch, "open no commitment, regardless of available balance". Verification: `CNF-308`.*

**Where the machine's tenant is suspended at the moment of the attach, that same transaction also
enqueues a system cancellation** — `requested_by: system`, `system_reason: tenant_suspended`, under
the machine's `delete` episode, opening it or adding the reason to an episode this same transaction
opened (`OPS-39`, `OPS-48`) — the identical mechanism `API-58` step (3) uses on the fan-out and the
identical attach-then-route shape as `OPS-36`. This applies at **all three** entry points. It is needed
because `API-58`'s re-sweep stops once a pass finds no un-cancelled machine, and a create that has
not yet produced a machine passes that test: the parent settles `succeeded` — counting a
`needs_reconciliation` child as complete — and no later pass will ever look again. Without it, a
create resolving *observed* after that settlement attaches a funded, billing machine to a suspended
tenant and runs its whole runway, which is precisely the outcome `SEC-45`'s one-action suspension
must not depend on a human noticing. `OPS-36`'s attach-then-cancel does not cover it: that branch fires only
where `OPS-33` had already released the commitment, and here the commitment is still open and
becomes the machine's running commitment.

