import Provisiond.Req
/-! `LDG-33`'s runway derivation and `OPS-41`'s abort predicate, executed rather than read.

The two most expensive arguments of 2026-09-04 were about these: the abort predicate flipped
`runway_until` → `usable_sats > 0` → back across three cross-model reviews, and a ten-line
evaluation exhibited the counterexample. This module carries the general theorem the Python gate
sampled, and the withdrawn predicate as an executable negative witness so it cannot be re-laid. -/

namespace Provisiond.Runway

/-- `LDG-33`: `usable_sats = max(0, reserved_sats − protected_sats)`.
`Nat` subtraction truncates at zero, which is the `max(0, ·)`. -/
@[req "LDG-33"]
def usableSats (reserved prot : Nat) : Nat := reserved - prot

/-- `LDG-33`: `runway_until = now + floor(usable_sats / current_customer_rate)`, as seconds from
`now`. `Nat` division is the floor. The rate is in whole satoshis per second here; the rational
rate is the meter's concern (`Provisiond.Meter`). -/
@[req "LDG-33"]
def runwaySeconds (reserved prot rate : Nat) : Nat := usableSats reserved prot / rate

/-- Only `LDG-16`'s date clause, "where its stored `runway_until` has passed", read as the runway
being spent; its rate and recorded-gone clauses are `Provisiond.Fence.sweep`'s. The `machines`
table is indexed on `(runway_until)` for `LDG-13`'s sweep. -/
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

end Provisiond.Runway
