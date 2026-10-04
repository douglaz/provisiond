import Provisiond.Admission
/-! A small arithmetic interpretation of `LDG-75`, not an accounting lifecycle model.
Each input leg is one account/currency balance already derived from records. The caller supplies
current rates, currency-wide cost completeness and the stress amount over valued currencies.
This model proves neither invoice/month/void derivation, close-write persistence, provider truth,
asset eligibility, snapshot consistency nor the stress calculation. Unrated legs carry `none`;
the caller must propagate any open outage to every leg of its currency and omit its stress.
The completeness bit connects to `Provisiond.Admission.nextHalt`. Headroom is over supplied
valued terms only; it does not assure an incomplete pool or reserve a draw. -/
namespace Provisiond.Payables

structure Rate where
  satsNumerator : Nat
  denominatorPred : Nat
  deriving DecidableEq, Repr

structure Leg where
  balance : Int
  rate : Option Rate
  costComplete : Bool
  deriving DecidableEq, Repr

@[req "LDG-40"]
def Leg.isValued (leg : Leg) : Bool := leg.costComplete && leg.rate.isSome

@[req "LDG-40"]
def complete (legs : List Leg) : Bool := legs.all Leg.isValued

/-- `LDG-75`: floor per account/currency before valuing, and round the valuation up.
The rate denominator is positive by representation. -/
@[req "LDG-75"]
def valued (leg : Leg) : Nat :=
  if !leg.costComplete then 0 else
  match leg.rate with
  | none => 0
  | some r =>
    let d := r.denominatorPred + 1
    (leg.balance.toNat * r.satsNumerator + d - 1) / d

@[req "LDG-75"]
def required (float stress : Nat) (legs : List Leg) : Nat :=
  float + (legs.map valued).sum + stress

@[req "LDG-75"]
def covered (held float stress : Nat) (legs : List Leg) : Bool :=
  required float stress legs ≤ held

@[req "LDG-75"]
def headroom (held float stress : Nat) (legs : List Leg) : Nat :=
  held - required float stress legs

@[req "LDG-40"]
theorem unrated_is_omitted (b : Int) (c : Bool) : valued ⟨b, none, c⟩ = 0 := by
  cases c <;> rfl

@[req "LDG-40"]
theorem open_cost_is_omitted (b : Int) (r : Rate) : valued ⟨b, some r, false⟩ = 0 := rfl

@[req "LDG-40"]
theorem open_cost_keeps_halt (g : Admission.Guards) (h : g.completeCheckToLift = true)
    (b : Int) (r : Rate) :
    Admission.nextHalt g true (complete [⟨b, some r, false⟩]) false = true := by
  simp [Admission.nextHalt, complete, Leg.isValued, h]

@[req "LDG-75"]
theorem a_credit_is_not_an_asset (n : Nat) (r : Rate) :
    valued ⟨-(Int.ofNat n), some r, true⟩ = 0 := by
  simp [valued, Nat.div_eq_of_lt (Nat.lt_succ_self r.denominatorPred)]

@[req "LDG-75"]
theorem headroom_preserves_coverage (held float stress draw : Nat) (legs : List Leg)
    (hc : covered held float stress legs = true)
    (hd : draw ≤ headroom held float stress legs) :
    covered (held - draw) float stress legs = true := by
  simp [covered] at *
  unfold headroom at hd
  omega

@[req "LDG-75"]
theorem separate_floors_witness :
    required 0 0 [⟨-100, some ⟨1, 0⟩, true⟩, ⟨60, some ⟨1, 0⟩, true⟩] = 60 := by decide

@[req "LDG-75"]
theorem pay_record_draw_witness :
    covered 140 100 20 [⟨60, some ⟨1, 0⟩, true⟩] = false ∧
    covered 140 100 20 [⟨0, some ⟨1, 0⟩, true⟩] = true := by decide

end Provisiond.Payables
