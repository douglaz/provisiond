import Provisiond.Req
/-! `LDG-33`'s runway derivation and `OPS-41`'s abort predicate, executed rather than read.

The two most expensive arguments of 2026-09-04 were about these: the abort predicate flipped
`runway_until` → `usable_sats > 0` → back across three cross-model reviews, and a ten-line
evaluation exhibited the counterexample. This module carries the general theorem the Python gate
sampled, and the withdrawn predicate as an executable negative witness so it cannot be re-laid.

The derivation's start (`ADR-0033`, 2026-10-08). The customer prepays a machine's first billing unit
and the meter starts where it ends, so `LDG-33` "must count from the later of now and the prepaid
unit's end, or every machine routes up to one unit early". The unit's end is read as the machine
subject's latest high-water mark — `LDG-72`: "The mark is the greatest `increment end` among that
subject's rows" — which the first seed writes there (`Provisiond.Funding.seed`) and which every
later posting leaves at or before now, so the two maxima agree on every input. `Params.startAtMark`
carries the rule; `runwayStart` is the term; `runway_not_before_the_unit_end` and
`runway_early_without_the_start` are the pair. Before the seed there is no mark and the derivation
counts from now, as it always did. -/

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

/-- Only `LDG-16`'s date clause, "where its stored `runway_until` has passed", read as the runway
being spent, for a machine whose start is `now` — one past its prepaid unit, or with no mark yet;
inside the unit the start is ahead of now and the date has not passed with no seconds left
(`runway_not_before_the_unit_end`). Its rate and recorded-gone clauses are
`Provisiond.Fence.sweep`'s. The `machines` table is indexed on `(runway_until)` for `LDG-13`'s
sweep. -/
@[req "LDG-16"]
def routed (reserved prot rate : Nat) : Prop := runwaySeconds reserved prot rate = 0

/-- `OPS-41` as it stands: abort where the re-derived `runway_until` is strictly in the future. -/
@[req "OPS-41"]
def abortDate (reserved prot rate : Nat) : Bool := runwaySeconds reserved prot rate > 0

/-- The withdrawn 2026-09-04 form, `usable_sats > 0`. Retained as a trap: it reads as the obvious
predicate and it aborts machines the sweep will route again on the next pass, forever. -/
def abortSats (reserved prot _rate : Nat) : Bool := usableSats reserved prot > 0

/-- The date predicate never aborts a machine the sweep routed, so an abort is always a fixed
point: the machine it declines to cancel is one the next pass will not route. This is the general
form of what `tools/check_arithmetic.py` sampled over an 11×40×40 box. -/
@[req "OPS-41"]
theorem abortDate_never_on_routed (reserved prot rate : Nat)
    (h : routed reserved prot rate) : abortDate reserved prot rate = false := by
  unfold abortDate routed runwaySeconds at *
  simp [h]

/-- The withdrawn predicate admits a routed machine it aborts: one usable satoshi at two satoshis
per second. `runway = floor(1/2) = 0`, so the sweep routes it; `usable_sats = 1 > 0`, so the
withdrawn form aborts it; nothing changes; the next pass routes it again. -/
@[req "OPS-41"]
theorem abortSats_admits_loop :
    ∃ reserved prot rate : Nat,
      routed reserved prot rate ∧ abortSats reserved prot rate = true :=
  ⟨1, 0, 2, rfl, rfl⟩

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

end Provisiond.Runway
