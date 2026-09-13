import Provisiond.Req
/-! `LDG-38`'s rounding-credit recurrence, in exact rationals.

    posted_debit_i = ceil(exact_i − r)
    r'             = r + posted_debit_i − exact_i        INVARIANT: 0 ≤ r < 1

The withdrawn form carried `exact_total` and `already_charged` and posted
`ceil(exact_total) − already_charged`; a corrupted running total mis-billed the rest of the period
without bound. `r` is confined to `[0,1)` by construction, and the theorems below are that
construction. `check_arithmetic.py` verified these with 3,000 floating-point trials; these hold for
every rational input. -/

open Std

namespace Provisiond.Meter

/-- `LDG-38`: `posted_debit_i = ceil(exact_i − r)`. -/
@[req "LDG-38"]
def postedDebit (exact r : Rat) : Int := (exact - r).ceil

/-- `LDG-38`: `r' = r + posted_debit_i − exact_i`. -/
@[req "LDG-38"]
def nextCredit (exact r : Rat) : Rat := r + postedDebit exact r - exact

/-- Lower half of the invariant: the credit never goes negative, for any input at all. -/
@[req "LDG-38"]
theorem nextCredit_nonneg (exact r : Rat) : 0 ≤ nextCredit exact r := by
  unfold nextCredit postedDebit
  have h := @Rat.le_ceil (exact - r)
  grind

/-- Upper half of the invariant: the credit stays below one, for any input at all. -/
@[req "LDG-38"]
theorem nextCredit_lt_one (exact r : Rat) : nextCredit exact r < 1 := by
  unfold nextCredit postedDebit
  have h := @Rat.ceil_lt (exact - r)
  grind

/-- A posted debit is never negative — given what the invariant provides (`r < 1`) and what the
meter provides (`exact ≥ 0`). Neither hypothesis can be dropped. -/
@[req "LDG-38"]
theorem postedDebit_nonneg (exact r : Rat) (hx : 0 ≤ exact) (hr : r < 1) :
    0 ≤ postedDebit exact r := by
  unfold postedDebit
  have h := @Rat.le_ceil (exact - r)
  have : (-1 : Rat) < exact - r := by grind
  have h2 : (-1 : Int) < (exact - r).ceil := Rat.lt_ceil_iff.mpr (by grind)
  omega

/-- `F52`'s first defect, as the theorem whose reverse does not prove: starting a period at `r = 0`
posts at least what carrying a nonnegative `r` would. The period reset is in the operator's favour,
never the customer's. -/
@[req "LDG-38"]
theorem reset_never_charges_less (exact r : Rat) (hr : 0 ≤ r) :
    postedDebit exact r ≤ postedDebit exact 0 := by
  unfold postedDebit
  apply Rat.ceil_le_iff.mpr
  have h1 : exact - r ≤ exact - 0 := by grind
  exact le_trans h1 Rat.le_ceil

/-- The recurrence over a stream of exact charges, from a starting credit: the list of posted
debits. -/
@[req "LDG-38"]
def debits : List Rat → Rat → List Int
  | [], _ => []
  | x :: xs, r => postedDebit x r :: debits xs (nextCredit x r)

/-- The credit after a stream. -/
def creditAfter : List Rat → Rat → Rat
  | [], r => r
  | x :: xs, r => creditAfter xs (nextCredit x r)

/-- The invariant the cumulative-ceiling claim rests on: `Σ d = Σ x + (r_n − r_0)`, for every
stream. With `r_0 = 0` and `0 ≤ r_n < 1`, the integer `Σ d` is `ceil(Σ x)`: the recurrence posts
exactly what the withdrawn cumulative form posted, on every subdivision, without its unbounded
state. -/
@[req "LDG-38"]
theorem debits_sum (xs : List Rat) (r : Rat) :
    ((debits xs r).sum : Rat) = xs.sum + (creditAfter xs r - r) := by
  induction xs generalizing r with
  | nil => simp only [debits, creditAfter, List.sum_nil]; grind
  | cons x xs ih =>
    simp only [debits, creditAfter, List.sum_cons, Rat.intCast_add, ih]
    unfold nextCredit
    grind

end Provisiond.Meter
