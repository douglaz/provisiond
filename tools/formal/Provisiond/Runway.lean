import Provisiond.Req
/-! `LDG-33`'s runway derivation and `OPS-41`'s abort predicate, executed rather than read.

The two most expensive arguments of 2026-09-04 were about these: the abort predicate flipped
`runway_until` → `usable_sats > 0` → back across three cross-model reviews, and a ten-line
evaluation exhibited the counterexample. This module carries the general theorem the Python gate
sampled, and the withdrawn predicate as an executable negative witness so it cannot be re-laid.

The derivation's start (`ADR-0033`, 2026-10-08). The customer prepays a machine's first billing unit
and the meter starts where it ends, so — in `ADR-0033`'s words — `LDG-33`'s derivation "must count
from the later of now and the prepaid unit's end, or every machine routes up to one unit early";
`LDG-33` now reads `runway_until = max(now, mark) + floor(usable_sats / current_customer_rate)`.
The unit's end is read as the machine subject's latest high-water mark — `LDG-72`: "The mark is the
greatest `increment end` among that subject's rows" — which the first seed writes there
(`Provisiond.Funding.seed`) and which every later posting leaves at or before now, so the two maxima
agree on every input. `Params.startAtMark` carries the rule; `runwayStart` is the term;
`runway_not_before_the_unit_end` and `runway_early_without_the_start` are the pair. Before the seed
there is no mark and the derivation counts from now, as it always did. `routed` and `abortDate` read
the date this derivation yields, so that `LDG-16`'s sweep and `OPS-41`'s abort agree with the
Markdown inside the unit too: a machine there is never routed (`not_routed_inside_the_unit`) and
its cancellation is aborted — `runway_not_before_the_unit_end`'s date is past now there, which the
fourth conjunct of `Provisiond.Witnesses.runway_counts_from_the_unit_end` executes;
`abortDate_never_on_routed` is the converse, that a machine routed on the date it would re-derive
is never aborted. -/

namespace Provisiond.Runway

/-- The rule this module carries as a parameter. `startAtMark`: `LDG-33`, `ADR-0033`, 2026-10-08 —
the derivation counts from the later of now and the machine subject's latest mark; `false` counts
from now, the form that stood until that day. -/
structure Params where
  startAtMark : Bool
  deriving DecidableEq, Repr

/-- The rule as it stands. One field per line: `ci.yml`'s control flips it. -/
@[req "LDG-33"]
def current : Params := {
    startAtMark := true }

/-- `LDG-33`: `usable_sats = max(0, reserved_sats − protected_sats)`.
`Nat` subtraction truncates at zero, which is the `max(0, ·)`. -/
@[req "LDG-33"]
def usableSats (reserved prot : Nat) : Nat := reserved - prot

/-- `LDG-33`: `floor(usable_sats / current_customer_rate)`, the seconds of runway from the
derivation's start — `runwayStart`, which was `now` until 2026-10-08. `Nat` division is the floor.
The rate is in whole satoshis per second here; the rational rate is the meter's concern
(`Provisiond.Meter`). -/
@[req "LDG-33"]
def runwaySeconds (reserved prot rate : Nat) : Nat := usableSats reserved prot / rate

/-- `LDG-33`: the instant the derivation counts from — `max(now, mark)` under the rule, where `mark`
is the machine subject's latest high-water mark (`LDG-72`) and `none` where the subject has no mark
yet; `now` without the rule or without a mark. -/
@[req "LDG-33"]
def runwayStart (p : Params) (now : Nat) (mark : Option Nat) : Nat :=
  if p.startAtMark then max now (mark.getD now) else now

/-- `LDG-33`: `runway_until = max(now, mark) + floor(usable_sats / current_customer_rate)`. -/
@[req "LDG-33"]
def runwayUntil (p : Params) (now : Nat) (mark : Option Nat) (reserved prot rate : Nat) : Nat :=
  runwayStart p now mark + runwaySeconds reserved prot rate

/-- Only `LDG-16`'s date clause, "where its stored `runway_until` has passed": the stored date is
the one `LDG-33`'s derivation yielded when a writer ran it, at `derivedAt`, and it has passed at the
sweep's `now`. Its rate and recorded-gone clauses are `Provisiond.Fence.sweep`'s, whose world holds
the stored date as a column. The `machines` table is indexed on `(runway_until)` for `LDG-13`'s
sweep. *Until 2026-10-08 this read `runwaySeconds … = 0`, the runway spent — true of the date only
where the derivation counts from now; inside the prepaid unit it routed a machine whose date lies
at the unit's end (`ADR-0033`).* -/
@[req "LDG-16"]
def routed (p : Params) (derivedAt now : Nat) (mark : Option Nat) (reserved prot rate : Nat) :
    Prop :=
  runwayUntil p derivedAt mark reserved prot rate ≤ now

/-- `OPS-41` as it stands: abort where re-deriving `LDG-33` from what the worker read now puts the
date "strictly in the future" — past `now`. *Until 2026-10-08 this read `runwaySeconds … > 0`,
which inside the prepaid unit cancelled a machine whose re-derived date is the unit's end.* -/
@[req "OPS-41"]
def abortDate (p : Params) (now : Nat) (mark : Option Nat) (reserved prot rate : Nat) : Bool :=
  runwayUntil p now mark reserved prot rate > now

/-- The withdrawn 2026-09-04 form, `usable_sats > 0`. Retained as a trap: it reads as the obvious
predicate and it aborts machines the sweep will route again on the next pass, forever. -/
def abortSats (reserved prot _rate : Nat) : Bool := usableSats reserved prot > 0

/-- The date predicate never aborts a machine the sweep routes on the date the abort itself
derives, so an abort is always a fixed point: the date it writes is one the next pass will not
route until it passes, inside the prepaid unit as anywhere else. This is the general form of what
`tools/check_arithmetic.py` sampled over an 11×40×40 box. -/
@[req "OPS-41"]
theorem abortDate_never_on_routed (p : Params) (now : Nat) (mark : Option Nat)
    (reserved prot rate : Nat) (h : routed p now now mark reserved prot rate) :
    abortDate p now mark reserved prot rate = false := by
  unfold abortDate routed at *
  simp [h]

/-- The withdrawn predicate admits a routed machine it aborts: one usable satoshi at two satoshis
per second, no mark. `runway = floor(1/2) = 0`, so the date is now and the sweep routes it;
`usable_sats = 1 > 0`, so the withdrawn form aborts it; nothing changes; the next pass routes it
again. -/
@[req "OPS-41"]
theorem abortSats_admits_loop :
    ∃ (p : Params) (now : Nat) (mark : Option Nat) (reserved prot rate : Nat),
      routed p now now mark reserved prot rate ∧ abortSats reserved prot rate = true :=
  ⟨current, 0, none, 1, 0, 2, by unfold routed; decide, rfl⟩

/-- `ADR-0033`, with the rule: a machine inside its prepaid unit — its mark at the unit's end, ahead
of now — has a `runway_until` no earlier than that end, whatever it has left to spend. -/
@[req "LDG-33"]
theorem runway_not_before_the_unit_end (p : Params) (h : p.startAtMark = true)
    (now unitEnd reserved prot rate : Nat) :
    unitEnd ≤ runwayUntil p now (some unitEnd) reserved prot rate := by
  simp only [runwayUntil, runwayStart, h, ite_true, Option.getD_some]
  omega

/-- Without the rule the same inputs give a date earlier by exactly the unit's unelapsed part,
`unitEnd − now`: up to one unit — `ADR-0033`, "or every machine routes up to one unit early". -/
@[req "LDG-33"]
theorem runway_early_without_the_start (p : Params) (h : p.startAtMark = false)
    (now unitEnd reserved prot rate : Nat) (hin : now ≤ unitEnd) :
    runwayUntil p now (some unitEnd) reserved prot rate + (unitEnd - now) =
      runwayUntil { p with startAtMark := true } now (some unitEnd) reserved prot rate := by
  simp only [runwayUntil, runwayStart, h, Bool.false_eq_true, ite_true, ite_false,
             Option.getD_some]
  omega

/-- With no mark yet — before the machine's first seed — the derivation counts from now under
either setting. -/
@[req "LDG-33"]
theorem runway_from_now_before_the_seed (p : Params) (now reserved prot rate : Nat) :
    runwayUntil p now none reserved prot rate = now + runwaySeconds reserved prot rate := by
  simp [runwayUntil, runwayStart]

/-- `ADR-0033` under the rule: a machine inside its prepaid unit — its mark at the unit's end,
ahead of now — is never routed on a date derived inside the unit, whatever it has left to spend;
`abortDate` on the same inputs is `runway_not_before_the_unit_end`'s date past now, the abort
`Provisiond.Witnesses.runway_counts_from_the_unit_end` executes. -/
@[req "LDG-16"]
theorem not_routed_inside_the_unit (p : Params) (h : p.startAtMark = true)
    (derivedAt now unitEnd reserved prot rate : Nat) (hin : now < unitEnd) :
    ¬ routed p derivedAt now (some unitEnd) reserved prot rate := by
  have h1 := runway_not_before_the_unit_end p h derivedAt unitEnd reserved prot rate
  unfold routed
  omega

end Provisiond.Runway
