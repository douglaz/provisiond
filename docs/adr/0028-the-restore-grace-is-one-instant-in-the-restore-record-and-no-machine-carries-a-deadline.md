# The restore grace is one instant in the restore record, and no machine carries a deadline

**Status:** accepted (2026-09-25). The rules are `STO-54`, `STO-56`, `LDG-16`, `OPS-41`, `LDG-62`,
`LDG-64`, `LDG-65` and `PRV-13e`, with the machines row in `05-persistence.md`. Supersedes the
mechanism `ADR-0023` gave the grace on 2026-09-12 (a per-machine column, then the second use of
`exhausted_since`), `ADR-0026`'s second fact (`machines.destroy_not_before`), and the sentence in
`ADR-0027` that kept it. Answers `pv-gip.5`'s held attempt, `pv-gip.12`'s unusable grace, and the
inherited-fence question a four-model panel argued on 2026-09-23 — by removing the thing they were
about.

## The problem as found

`STO-54`'s grace is right and stays: "an extension lost in Δ is not rebuilt — the grace above buys
the tenant one re-derivation interval in which to extend again". A restore rewinds the store; a
top-up made after the backup instant comes back as money ("the debit that paid for it rolled back
with it") but not as runway, since `synchronous_commit` is `on` "inside exactly two transactions" —
the deposit mint and the payment credit — and the extension is not one of them. So after any
restore, a machine whose tenant paid looks out of money, and without a grace the sweep routes it
the moment the listener returns.

What was wrong was where the grace lived: on every machine, as `destroy_not_before`, read by the
worker before its provider call. Every defect this month's work chased downstream of the rate came
from that placement:

- **The worker read a billing fact.** `LDG-16` said `OPS-41`'s re-check "reads neither fact except
  to clear them", that the two bypasses "Neither reaches the predicate above", and that "Both do
  respect the destruction deadline" — three sentences that cannot all hold, resolved by a gate on
  the provider call that a review then filed as a second home (`pv-vwe.22`).
- **A held attempt with no outcome.** A queued delete re-run after a restore claims, fences,
  re-checks, finds the machine unfunded on the stale balance and must not call; `OPS-48`'s table
  had no row for it (`pv-gip.5`). The panel's answer — re-check first, then no fence and a deferral
  until the deadline — was sound and still one more rule on the worker's path.
- **Inherited fences.** A machine already fenced when the grace begins — a retried attempt, or one
  mid-flight at the backup instant — refuses `LDG-62`'s extension for the whole grace. Letting the
  extension through the fence sells runway on a disk that may already be gone, and a
  `destroy_not_before > now()` clause is a clock read no row write orders, reopening the
  2026-09-02 window; clearing the fence at restore needed an `OPS-48` row and a restore-time
  write on episode state. Four advisers rejected the first and split on the second.
- **A grace nobody could use.** The deadline ran from the restore instant, but tenants can extend
  only after step (3); a slow restore consumed it (`pv-gip.12`).
- **One formula, two homes.** `Restore.lean` and `Fence.lean` each computed "the restore instant
  plus one re-derivation interval" (`pv-vwe.22`).

Underneath all five: the grace is a property of the **incident**, and the restore procedure
already has the machinery for incident-wide facts. `STO-54` freezes "exactly five things" through
its steps — the exhaustion sweep, `LDG-64`'s canceller, the time-to-live sweep, retention and the
`suspend_tenant` exception — reading `STO-56`'s restore record, which "both components read …
before anything else they do". The grace was that freeze, held one interval longer, written on the
machine instead.

## The decision

**The restore grace is one instant, `STO-56`'s `grace_ends_at`: nullable, written in the same
transaction as step (3)'s mark — "A marked step does not run again" — as that instant plus one
re-derivation interval.** Two rules read it and nothing else does:

- **The freeze on exposure-reducing cancellation lifts at `grace_ends_at`, not at step (3).**
  `STO-54`'s five frozen actors stay frozen until then (the `suspend_tenant` exception's own later
  condition stands on top). The listener returns at step (3) as today; the meter, re-derivation,
  reconciliation and the solvency check "are not frozen" and never left. So the interval is the
  tenant's to act in, and the record MUST NOT be closed before `grace_ends_at` has passed — an
  early close would end the grace by making the record no longer open.
- **A claim of an exposure-reducing cancellation MUST defer while a restore record is open and its
  `grace_ends_at` is null or in the future.** Claims begin after step (2) and the instant is
  written at step (3), so the null case is real: a delete re-run by step (2) and claimed before
  step (3) would otherwise fence, re-check the restored balance, and call the provider — the very
  tenant the grace exists for (*found by all four readers of the first draft, 2026-09-25*). When
  the instant is set, the claim returns the operation to `queued` with
  `available_at = grace_ends_at`; when it is not yet written, by `OPS-8`'s ordinary short delay.
  Either is "the same write as `OPS-8`'s defer, though nothing refused it", in `OPS-49`'s words, in the bullet it marks as `F51`'s; `OPS-8`
  itself covers an index refusal and a short delay, so `OPS-41` states this scope and duration
  rather than citing it. The worker reads the restore record **at each such claim** — a new duty,
  since `STO-56`'s "both components read the open row before anything else they do" is the
  startup read, taken once per process, so it cannot see an instant written or passed later in the
  incident. This covers every path that reaches the
  worker: a delete re-run by step (2), an operator's retry, the outage bound, a suspended
  tenant's. No fence is written, so `LDG-62`'s extension is refused by nothing the grace introduced.
  `OPS-41` owns the rule; `OPS-48` gains no row, since a re-queued attempt has not settled.

**`machines.destroy_not_before` is withdrawn**, and with it every sentence that read it: `LDG-16`'s
deadline paragraph and the provider-call sentence `pv-gip.1` gave it — "an exposure-reducing
cancellation MUST NOT make its provider call while its machine's `destroy_not_before` is in the
future"; the deadline half of the sweep's routing predicate, which is again "stored `runway_until`
has passed" alone; `OPS-41`'s and `LDG-62`'s "clears the deadline"; `LDG-65`'s deadline clause;
`PRV-13e`'s "never writes `machines.destroy_not_before`"; `STO-54`'s step that wrote it on "every
machine whose stored `runway_until` has passed"; `CNF-295`'s two assertions of it. The worker's
re-check and its provider call read no fact the grace wrote — the re-check reads the commitment and
`runway_until` as it always has, and the one grace fact the worker does read, the restore record at
each claim, is `OPS-41`'s rule above. The sweep's predicate has one clause. *(2026-10-02: `ADR-0029` gave it a second, that the
machine's currency has a rate. The grace is still no clause of it.)*

**A machine already fenced when the grace begins gets no extension from it**, and `STO-54` says
so in its "what the restore does not repair" paragraph. Its fence stayed set because the provider
refused (`stalled`), because nobody yet knows what the provider did (`uncertain`), or because the
provider accepted a cancellation for a future date (`scheduled`); in none of these could it have
extended before the restore either, since `LDG-62`'s write is "guarded on
`machines.destroy_committed IS NULL`". Its route back is `OPS-42`'s — the retry, the resolution,
the operator — unchanged by this decision, and a retry's claim waits the interval like every
claim: "outside the grace" means no extension, not exemption from the wait. The owner chose this
over clearing fences at restore: it engineers nothing for cases of which the set already calls one
— "a provider that refuses the delete indefinitely, on a machine that is out of runway, whose
customer wants to pay" — "stated as accepted", and the others have their own resolution.

The grace governs every exposure-reducing cancellation **that claims**, whichever path enqueued it.
The claim rule is what makes it universal; `STO-54`'s freeze names "exactly five things" and is
the precedent for an incident-wide fact, not the mechanism. A rule that scoped the grace by reason
would be the scoping `OPS-41`'s 2026-09-09 amendment refused. A provider-side scheduled
cancellation never claims and is outside it.

## What this costs

**A machine that exhausts naturally inside the interval waits it out.** Under the column, only a
machine already past its date at the restore waited; now one whose date passes during the interval
does too. `LDG-16` refuses exactly this delay for ordinary exhaustion, because "delaying it an
interval would run every ordinary exhaustion one interval into the wind-down reserve". It is
accepted here because a restore is "a recovery incident with a stated procedure", not the ordinary
path: the cost is one interval of reserve on the machines that exhaust during one interval after
one incident, and the column's cost was the five defects above on every path, always.

**Cancellations no extension can save wait too.** A suspended tenant's fleet, a stalled episode's
retry, a late-attach cleanup — each waits the interval, one interval of operator-borne charge per
restore, the price of not scoping by reason.

**One column on one row.** `STO-56` gains `grace_ends_at`; `machines` loses `destroy_not_before`.

## What was rejected

**Keeping the column and answering the fence question with "neither".** It keeps the worker's
billing read, the held attempt's deferral rule, the two-home formula and the unusable-grace
ticket, to protect a case the freeze protects for free.

**Clearing the fence at restore where the episode is `stalled`** — two advisers' answer to the
inherited fence. Sound for that case, and it costs an `OPS-48` row keyed on a restore rather than
on a settlement, a restore-time write on episode state, and a distinction the restore must draw
between `stalled` and `uncertain` fences. The owner declined to build it for machines already in
`OPS-42`'s accepted no-exit.

**Letting the extension through a fence while the deadline is future.** Rejected 4–0: the
deadline binds calls not yet made, an `uncertain` attempt's call may already have destroyed the
disk, such an attempt is never re-claimed, `LDG-32` returns the commitment's "remaining amount"
and the meter runs to the observation instant; and a clock comparison in a guard that exists to be
totally ordered by a row write reopens the 2026-09-02 class.

**Rebuilding the extension** — `ADR-0023` bought durability "where there is no second truth" and
an extension has none. **Extending from the restored balance automatically** — a purchase the
tenant did not make.

## What this does not promise

The grace is one interval from the instant a tenant can first act; nothing extends it for a slow
tenant, and nothing shortens it for a machine that was genuinely exhausted. A fenced machine is
outside it. A tenant who does not extend inside it is routed at its end "one interval after a
date the tenant was never shown", as `STO-54` already says.

## Consequences

This is the edit list `pv-gip.5` lands, and the record and the ticket name the same edits.

`STO-56` gains `grace_ends_at`, nullable, written in step (3)'s mark transaction, and the rule
that the record is not closed before it has passed. `STO-54` says the freeze lifts at
`grace_ends_at` (the exception's later condition standing), loses the step that wrote a deadline on
every machine, and names the fenced machine in its not-repaired paragraph. `OPS-41` gains the claim
rule in `OPS-49`'s words — defer while the record is open and the instant is null or future, to the
instant when set and by a short delay when not — and the per-claim read of the record. `LDG-16`
loses its deadline paragraph, the provider-call sentence `pv-gip.1` gave it, and the deadline half
of its routing predicate; its bypass sentence says the bound's and the suspended tenant's
cancellations claim like every other and wait for the grace; its worker sentences collapse to
one: the worker reads no fact the grace wrote. `LDG-62` and `OPS-41` lose "clears the deadline";
`LDG-65` loses its deadline clause; `LDG-64` has none and is untouched; `PRV-13e` loses "never
writes `machines.destroy_not_before`". `05-persistence.md`'s machines table loses the column with a
dated note in the row's place. `CNF-99`'s restore cases measure from step (3), assert the queued
delete is re-queued to `grace_ends_at` and not fenced, that an extension inside the grace closes
the episode `funded` at the re-claim, and that the fenced machine gets no extension; `CNF-295`'s
restore rehearsal stops asserting the column. The deciding commit already pointed `ADR-0027`'s
"The destruction deadline stays" bullet and `ADR-0026`'s status line here and added **Restore
grace** to `CONTEXT.md`; those are not the ticket's.

The formal layer (`pv-gip.2`): `destroyNotBefore` leaves the machine row; `providerDelete`'s gate,
`provider_waits_for_deadline`, `observationKeepsDeadline` and its witness go; `Restore`'s grace is
the record's one instant, which `Fence` reads as a claim guard — the two-home formula of
`pv-vwe.22` dissolves with its first site; `pv-gip.12` closes by construction.

*Four independent readers — Fable, Opus, and Codex at `gpt-6-astra` and `gpt-5.6-sol` — argued
the inherited-fence question to a 4–0 rejection and a 2–2 split on 2026-09-23; the owner's answer
was to ask whether the grace was for fenced machines at all, and the decision above is what that
question dissolved.*
