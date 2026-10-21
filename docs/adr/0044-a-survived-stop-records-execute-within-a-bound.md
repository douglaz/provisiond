# A survived stop records `execute` within a bound

**Status:** accepted (2026-10-18, the owner's decisions 1–4; `pv-tst` and `pv-f7a`;
panels r58, r58b and r58c, `docs/research/panels-2026-10/r58/`,
`docs/research/panels-2026-10/r58/r58b/` and `docs/research/panels-2026-10/r58/r58c/`; the
decisions are in r58's `synthesis.md`); amended 2026-10-19 (`pv-zbp`).
Extends the stop-recording decision implicit in `ADR-0022` and the recorded-create pointer in
`ADR-0043`.

## Context

The worker could know the outcome of a stopped `execute`, or exit without recording it, and
readers could not tell which behavior conformed. A cut-off `conflict` also lacked a reason value.
The owner's option A settles recording for a cancellation of `execute` the engine survives;
the larger shape settles the duration, shielding, parent and executable controls. A kill remains
a crash. The scope now includes a stop after `execute` returns under the amendment below; it decides
neither any periodic component's store loop nor the separate pre-dispatch classification question for existing-machine mutations (`pv-9j6`).

The safety argument belongs here. A stop cannot remove uncertainty about a provider call. It
can preserve the worker's knowledge of its position and markers by recording the classification.
That write needs protection from the cancellation being recorded, and a duration independent of
store-error accounting: serialization repeats could otherwise continue indefinitely. A supervisor
that kills earlier than that duration defeats the opportunity to record. A lost acknowledgement
still does not prove the write failed: a durable record may already exist when the worker exits.

## Decision

- `OPS-21` owns the scope: "A cancellation of `execute` that the engine survives MUST be recorded
  before the engine exits, for every operation kind". It defines survival: "“Survives” means the process outlives the stop."
- `OPS-11` retains the classification. Its create boundary is "Any create failure the worker
  records before any step-9 request (before any per-order key upload or order request) MUST settle
  `failed`, whatever its kind." Its install row includes "while `OPS-45`'s two markers say the
  disk is untouched and no rescue session was left open"; rescue inventory has "Same rows as
  `install`"; refresh has "Always `failed`". The widened pointer lives in `OPS-21`.
- `OPS-21` owns shielding: "The record write MUST NOT be cancelled by the cancellation that stopped
  `execute`." Its store-error path uses `OPS-49`: "the component MUST repeat the **whole
  transaction**". A later stop during that loop still exits, as does exhaustion, with the
  lost-reply case `OPS-49` names: "unless the bound's last repeat committed and its reply was lost".
- `OPS-21` owns a stop during a store transaction inside `execute` (owner decision 4): "A stop that
  arrives while a store transaction inside `execute` is in flight or repeating under `OPS-49`, such
  as `OPS-43`'s step-8 transaction or an `OPS-45` marker write, is the cancellation being recorded."
  It adds "A transaction already sent MAY finish" and "the worker MUST NOT repeat it or begin anything
  it precedes, and makes the record". For the markers it says "the record MUST classify against the
  markers its own transaction reads". `OPS-49`'s bullet points back
  to it; that bullet's exit remains for a later stop during the record's own loop. For a stop after
  `execute` returns, see the amendment of 2026-10-19 below (`pv-zbp`).
- `OPS-21` owns the stop duration: "The worker MUST NOT pursue the record past the Stop-record bound (`OVR-19`), and the engine MUST NOT wait for it past that bound." Its accounting rule is "The Stop-record bound is measured from the
  stop, counts every repeat including serialization failures, and never resets." Its supervisor
  obligation is "The deployment's supervisor MUST wait at least the Stop-record bound after a stop
  before it kills the engine." `OVR-19` registers its type as "finite, positive duration" and marks
  the row startup-validated. The independent Store-retry bound and its exits retain their owner.
- `OPS-21` owns the parent: "A cancelled `suspend_tenant` parent MUST be returned to `queued` with `available_at` advanced at any point in its fan-out, subject to the same Stop-record bound and exits." This uses the ordinary guarded defer;
  `OPS-15` owns resumption, "resuming its fan-out from wherever it stopped", and says the re-sweep
  "is idempotent by `OPS-39`'s dedup".
- `WIR-9a` owns the reason union, now including `"cut_off"` (`OPS-21`). The recorded stop's kind
  remains `conflict`; the parent's defer records no error. Retryability retains its existing owners.
- `Provisiond.StopRecord` composes the guarded transaction and defer from `Provisiond.Claim` with
  `Provisiond.Tables`' classification. Its event traces distinguish original-stop redelivery,
  later stops, store outcomes and serialization failures, with independent budgets. Its current
  recording, shielding and bound switches have paired witnesses in `Provisiond.Witnesses`.
  The PYCONTROL list in `ci.yml` removes each switch separately and requires only its witness
  to be refuted. `CNF-362`, `OPS-49` and `OVR-19` quote these `OPS-21` sentences as its words, so
  the citation gate fails an edit that drops or changes one.

## Considered and rejected

- **B: may exit without recording; both behaviors conform.** Rejected by owner decision 1: it
  leaves callers and implementers without a common stop outcome despite a working store.
- **C: must not record.** Rejected: it discards worker knowledge and substitutes crash recovery
  even when the process and store can complete the record.
- **The smaller shape: the Store-retry bound alone, or one attempt, without Lean or CI controls.**
  Proposed by r58b's fable and opus. Rejected by owner decision 2: serialization repeats are
  outside that bound, an attempt can remain under the original cancellation, and the panels'
  plausible wrong edits passed the existing gates.
- **`execution_cancelled`.** Rejected beside `cancellation_committed`: `CONTEXT.md` says "Use
  **cancel** whenever an end date is involved". Owner decision 3 chose `cut_off` for this
  different event.
- **X: a stop during `OPS-49`'s retry loop inside `execute` exits** (r58c, astra and sol). Rejected
  by owner decision 4: decision 2's "stay as settled" meant the record write's own loop. Exiting
  parks a create nobody ordered, and the outcome would turn on whether the store error came before
  the stop.
- **Parent with `available_at` unchanged** (opus). Rejected in favor of the waiting parent's
  existing defer shape and its short delay.
- **Parent left to restart recovery** (r58, sol). Rejected by the owner's every-kind decision;
  a surviving worker must attempt its defer within the same duration.

## Consequences

The requirement owners carry the rules; this record carries their rationale and the rejected
options. Existing classification rows, restart exceptions and the store-error loop's exits stay
with their owners. The model has no real clock, provider, fan-out or supervisor; its unit-cost
budget abstracts elapsed time and its parent short delay uses the claim model's `none`.
The lost-reply exit theorem admits either the still-running row or an already-written record.
Money safety composes the existing whole-transaction theorem rather than introducing a new
transaction implementation. No existing theorem is weakened. The model's schedule starts at the
record write, so a stop during a store transaction inside `execute` reaches no gate: in r58c every
plant of either reading passed every gate, and `CNF-361` and `CNF-362` are its only checks.

A proof is never conformance (`ADR-0025`). `CNF-362` carries the running-system cases, bound,
shielding, parent, validation and crash controls; `CNF-361` carries the create's release and
acknowledged-step-8 assertions. The panels did not test a running implementation.

## Amendment — 2026-10-19: the settle write records a survived stop (`pv-zbp`)

The pv-zbp triage applied decisions 1 and 4 of 2026-10-18 to a stop after `execute` returns
and before the worker's settle write lands. In r58's `synthesis.md`
(`docs/research/panels-2026-10/r58/`), section "Owner decision, 2026-10-18", decision 1 is:
"Any stop the engine survives MUST record the outcome before the engine exits. This covers every
operation kind, not just create." Section "Owner decision 4, 2026-10-18: Y" limits the preserved
loop exit to "the stop-record write's own loop". This amendment records that application.

**Decision.**

`OPS-21` owns the rule: "A stop the engine survives that arrives after `execute` returns and before the worker's settle write lands MUST be recorded by that settle write, under the shielding below, and the Stop-record bound and exits that apply to a recorded cancellation."
`OPS-21` owns the shield: "The settle write that records a stop after `execute` returns MUST NOT be cancelled or abandoned by that stop."
`OPS-21` owns the recorded outcome: "The record of a stop after `execute` returns is the guarded write the worker would have made without the stop, settling the outcome in hand with that outcome's own error, if it has one, and with a failure classified under `OPS-11`; it is not a cut-off `conflict`."
For the create verification, `OPS-21` says "For a create, the worker's settle-time verification is inside `execute`: `OPS-27`'s correlator search and its confirming read, so a stop during either is the cancellation being recorded."
The worker algorithm points to that owner at the settle writes.

The worker's loop exit in `OPS-49` is scoped to a later stop: "For a worker, this means a later
stop, one arriving during the loop of the write that records an earlier stop, rather than the
stop being recorded." Its first-stop sentence quotes the rule above. The periodic components'
store loops remain undecided.

*Amended 2026-10-20 (`pv-gq8`): the quoted loop-only definition is the 2026-10-19 wording; `OPS-49`'s bullet now quotes `OPS-21`'s later-stop exit, which holds at any point before the record lands.*

`CNF-362` says "This item is the only check of these after-return cases; no gate or formal model
decides whether a first stop after `execute` returns is recorded by the settle write or exits." There is no Lean or CI change:
`Provisiond.StopRecord.trace` takes any `Record.settle`, its schedule starts at the record write,
and neither the model nor a gate separates the readings. The conformance cases exercise the
settle write and the create's verification placement; they do not prove an implementation.

**Considered and rejected.**

- **Exit when the stop lands in an ordinary settle write's loop.** Rejected: it throws away an
  outcome in hand and makes the result depend on whether the store error came before the stop.

## Amendment — 2026-10-19: a stop during an absorbed read (`pv-zbp`, `pv-ilb`; panel r59)

The pv-zbp branch first made a stop during `PRV-13c`'s post-order read a cut-off, which parked a
verified create. `PRV-13c` says "A failed post-order read of any kind, `rate_limited` included, MUST
NOT enter `OPS-11`'s classifier and MUST NOT change the create's settlement". `pv-ilb` found the same
split at `PRV-13`'s direct read after an accepted dated cancellation. Panel r59
(`docs/research/panels-2026-10/r59/`) went 4-0 for absorbing the stop as that read's failure, and the
owner chose it for both reads on 2026-10-19.

**Decision.** `OPS-21` says "A stop the engine survives after a create's settle-time confirming read succeeds, or after a delete's cancellation is accepted with an effective date, and before `execute` returns MUST NOT cancel `execute`."
`OPS-21` says "The worker still makes the read that follows, the stop ends it at once as a failed read unless it has already completed, `execute` returns the outcome that read gives, and the settle write records the stop as it records a stop after `execute` returns."
`CNF-362`'s absorbed-read cases check it against the outcome `CNF-356` asserts for a failed
post-order read. There is no Lean or CI change.

**Considered and rejected.**

- **Cut-off: the create parks in `needs_reconciliation`.** Rejected: the outcome is already final when
  the read starts, and `ADR-0037` (Q31) already rejected "keeping it with a failure that waits in
  `needs_reconciliation`".
- **Drop the read from the placement sentence and leave the case open.** Rejected: two engines would
  then settle the same stop differently, which is the split `pv-ilb` reported.
