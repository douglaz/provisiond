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

**The restore grace is one instant, `STO-56`'s `grace_ends_at`, written when step (3) completes as
that instant plus one re-derivation interval.** Two rules read it and nothing else does:

- **The freeze on exposure-reducing cancellation lifts at `grace_ends_at`, not at step (3).**
  `STO-54`'s frozen actors stay frozen until then; the listener, the meter, re-derivation,
  reconciliation and the solvency check return at step (3) as today, so the interval is the
  tenant's to act in.
- **The worker MUST NOT claim an exposure-reducing cancellation before `grace_ends_at`.** A claim
  that finds the open restore record's instant in the future returns the operation to `queued`
  with `available_at = grace_ends_at` — "the same write as `OPS-8`'s defer, though nothing refused
  it", which `F51`'s parent already uses — and re-claims after it. This covers every path that
  reaches the worker: a delete re-run by step (2), an operator's retry, the outage bound, a
  suspended tenant's. No fence is written, so `LDG-62`'s extension is refused by nothing the grace
  introduced. `OPS-41` owns the rule; `OPS-48` gains no row, since a re-queued attempt has not
  settled.

**`machines.destroy_not_before` is withdrawn**, and with it every sentence that read it: `LDG-16`'s
deadline paragraph and its "Both do respect the destruction deadline"; the deadline half of the
sweep's routing predicate, which is again "stored `runway_until` has passed" alone; `OPS-41`'s and
`LDG-62`'s "clears the deadline"; `PRV-13e`'s "never writes `machines.destroy_not_before`";
`STO-54`'s step that wrote it on "every machine whose stored `runway_until` has passed". The
worker reads no billing fact. The sweep's predicate has one clause.

**A machine already fenced when the grace begins gets no extension from it**, and `STO-54` says
so in its "what the restore does not repair" paragraph. Its fence stayed set because the provider
refused (`stalled`) or because nobody yet knows what the provider did (`uncertain`); in neither
case could it have extended before the restore either, since `LDG-62`'s write is "guarded on
`machines.destroy_committed IS NULL`". Its route back is `OPS-42`'s — the retry, the resolution,
the operator — unchanged by this decision. The owner chose this over clearing fences at restore:
it engineers nothing for a case the set already calls "stated as accepted".

The grace governs **every** exposure-reducing cancellation, whichever path enqueued it, because the
freeze list already does and because a rule that scoped it by reason would be the scoping `OPS-41`'s
2026-09-09 amendment refused.

## What this costs

**A machine that exhausts naturally inside the interval waits it out.** Under the column, only a
machine already past its date at the restore waited; now one whose date passes during the interval
does too. `LDG-16` refuses exactly this delay for ordinary exhaustion, because "delaying it an
interval would run every ordinary exhaustion one interval into the wind-down reserve". It is
accepted here because a restore is "a recovery incident with a stated procedure", not the ordinary
path: the cost is one interval of reserve on the machines that exhaust during one interval after
one incident, and the column's cost was the five defects above on every path, always.

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

`STO-56` gains `grace_ends_at`, written when step (3) completes. `STO-54` says the freeze lifts at
that instant, loses the step that wrote a deadline on every machine, and names the fenced machine
in its not-repaired paragraph. `OPS-41` gains the claim rule, in `OPS-8`'s words, and loses its
deadline read. `LDG-16` loses its deadline paragraph, its bypass sentence's "Both do respect the
destruction deadline", and the deadline half of its routing predicate; its three worker sentences
collapse to one: the worker reads no billing fact. `LDG-62` and `OPS-41` lose "clears the
deadline"; `LDG-64` and `LDG-65` say the bound and the suspended tenant's cancellation wait for
the grace as every cancellation does; `PRV-13e` loses "never writes `machines.destroy_not_before`".
`05-persistence.md`'s machines table loses the column with a dated note. `CNF-99`'s restore cases
measure from step (3), assert the queued delete is re-queued to `grace_ends_at` and not fenced,
and add the fenced machine that gets no extension. `ADR-0027`'s "The destruction deadline stays"
bullet and `ADR-0026`'s status line point here. `CONTEXT.md` gains **Restore grace**.

The formal layer (`pv-gip.2`): `destroyNotBefore` leaves the machine row; `providerDelete`'s gate,
`provider_waits_for_deadline`, `observationKeepsDeadline` and its witness go; `Restore`'s grace is
the record's one instant, which `Fence` reads as a claim guard — the two-home formula of
`pv-vwe.22` dissolves with its first site; `pv-gip.12` closes by construction.

*Four independent readers — Fable, Opus, and Codex at `gpt-6-astra` and `gpt-5.6-sol` — argued
the inherited-fence question to a 4–0 rejection and a 2–2 split on 2026-09-23; the owner's answer
was to ask whether the grace was for fenced machines at all, and the decision above is what that
question dissolved.*
