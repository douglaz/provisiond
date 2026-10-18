# A survived stop records `execute` within a bound

**Status:** accepted (2026-10-18, the owner's decisions 1–3; `pv-tst` and `pv-f7a`;
panels r58 and r58b, `docs/research/panels-2026-10/r58/` and
`docs/research/panels-2026-10/r58/r58b/`; the decisions are in r58's `synthesis.md`).
Extends the stop-recording decision implicit in `ADR-0022` and the recorded-create pointer in
`ADR-0043`.

## Context

The worker could know the outcome of a stopped `execute`, or exit without recording it, and
readers could not tell which behavior conformed. A cut-off `conflict` also lacked a reason value.
The owner's option A settles recording for a cancellation of `execute` the engine survives;
the larger shape settles the duration, shielding, parent and executable controls. A kill remains
a crash. The scope does not decide a stop after `execute` has returned, nor the separate
pre-dispatch classification question for existing-machine mutations (`pv-9j6`).

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
  to be refuted. Markdown attributed quotes defend the corresponding rule against prose plants.

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
transaction implementation. No existing theorem is weakened.

A proof is never conformance (`ADR-0025`). `CNF-362` carries the running-system cases, bound,
shielding, parent, validation and crash controls; `CNF-361` carries the create's release and
acknowledged-step-8 assertions. The panels did not test a running implementation.
