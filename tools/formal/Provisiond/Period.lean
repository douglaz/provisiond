import Provisiond.Req
import Provisiond.Meter
/-! `LDG-68`'s billing period, composed with `Provisiond.Meter`'s recurrence: which period each
second of an increment belongs to, the split of an increment that straddles a boundary, and each
period's postings from its own rounding credit.

The period. `LDG-68`: "**The billing period is the calendar month in UTC, and it is one boundary
for the whole deployment.**" The deployment's boundaries are a given, one list for every subject,
and `key` is the half-open period an instant lies in: "A period begins at `00:00:00Z` on the first
day of a month and ends at the same instant of the next", so a boundary instant is the first of the
period it opens. `key` counts the boundaries at or before an instant, which gives every instant a
period whatever the list holds; the theorems that need the boundaries in order take that as a
hypothesis. `Params.deploymentWide` is "Every tenant, every machine and every attachment share it",
and its other value derives each subject's boundaries from its create instant, the per-machine
anniversary; the case against it is `LDG-68`'s, under "**A period is a property of the deployment,
not of a provider or a machine.**"

The split. `LDG-38`: "**An increment also closes at every period boundary**". An increment carries
its start, its close and its rate; `split` walks the boundaries in list order and cuts it at each
one strictly inside what is left of it, and each piece is an increment of its own at the same rate,
`LDG-38`'s "every increment is priced at a rate that held for the whole of it". A piece's exact
charge is its own seconds at that rate, so the split divides seconds and never a charge. `assign`
files each piece under the period of its start: the seconds a piece covers lie in one period, and a
piece closing at a boundary closes at the boundary instant and is filed under the period that
boundary ends, not under the one its close instant opens.
`piece_inside_its_period` is the rule, for boundaries in order; `pieces_sum` holds either way.
`Params.splitAtBoundary`'s other value files a straddling increment whole under its closing month,
the period of its last second.

The reset. `LDG-38`: the new period's "`meter_totals` row starts with `r = 0`". `postings` is
`Meter.debits` over one period's charges, in order, from the credit `opening` gives the period:
zero under `Params.resetAtBoundary`, and under its other value the credit the earlier periods
left. `postings_from_zero` is the rule, and `postings_sum_is_ceil` follows from it by
`Meter.debits_sum`. `LDG-72`'s record is "a running record per `(subject, billing period)`", and
the credit is the part of it this module models.

Omitted, and where: the civil calendar — the boundaries are a given, and the model does not
establish which instant is `00:00:00Z` on the first of a month, nor anything about leap seconds;
every theorem here holds of any list of boundaries in order, weekly ones included, so "the calendar
month in UTC" is `LDG-68`'s Markdown and nothing in this module; the two ends of the list — the
boundaries are finitely many, so `key` puts the instants before the earliest in a period 0 that
begins at no boundary, unlike `LDG-68`'s "A period begins at `00:00:00Z` on the first day of a
month", and the instants from the latest in a period that never ends, unlike its "ends at the same
instant of the next"; an increment's start, which is a given of the increment here — `LDG-38`
fixes it, "An increment MUST start at the subject's latest high-water mark", and
`Provisiond.Funding` models that start and the seed behind it for one open period, so the split
here cuts an increment whose start is already the rule's; that mark where it sits in an earlier
period's row — `LDG-72`: "The mark is the greatest `increment end` among that subject's rows" —
which neither module models, `Provisiond.Funding` having one row and this one no mark; `LDG-38`'s deficiency-absorbed windows split at the boundary — a piece's
seconds are all billable, and "Where an absorbed window straddles a period boundary each period
subtracts its own part and no more" is not modelled; `LDG-31`'s clamp (`Provisiond.Ledger`) and the
ledger entry, which `Provisiond.Funding` composes with the recurrence for one open period; `LDG-8`'s
key, which `posted` shows only as the close instant beside each debit of a period; `LDG-68`'s
"which entries a correction may name", since no correction exists here; and anything about
`Provisiond.Funding`'s key, mark or clamp, which this module does not import and about which it
proves nothing. -/

open Std

namespace Provisiond.Period

/-- The rules this module carries as parameters, one field per red build. -/
structure Params where
  /-- `LDG-38`: the new period's "`meter_totals` row starts with `r = 0`". `false` carries the
  credit across the boundary. -/
  resetAtBoundary : Bool
  /-- `LDG-38`: "An increment also closes at every period boundary". `false` files a straddling
  increment whole under its closing month, the period of its last second. -/
  splitAtBoundary : Bool
  /-- `LDG-68`: "Every tenant, every machine and every attachment share it". `false` is the
  per-subject anniversary, `LDG-68`'s "deriving it from the machine's create instant": each
  subject's boundaries are the deployment's, each offset by its create instant. -/
  deploymentWide  : Bool
  deriving DecidableEq, Repr

/-- The rules as they stand. One field per line: `ci.yml`'s controls flip one each. -/
@[req "LDG-68"]
def current : Params := {
    resetAtBoundary := true,
    splitAtBoundary := true,
    deploymentWide  := true }

/-- An increment of one subject: the instant it starts, a given here (the module docstring),
the instant it closes, `LDG-8`'s *increment end*, and `LDG-38`'s `customer_rate_i`, "the rate in
force throughout i". Instants are seconds. -/
structure Increment where
  startsAt : Nat
  closesAt : Nat
  rate     : Rat
  deriving DecidableEq, Repr

/-- `LDG-38`'s `exact_i = net_seconds_i × customer_rate_i`, with no absorbed window: the
increment's own seconds at its own rate, never rounded. -/
@[req "LDG-38"]
def Increment.exact (i : Increment) : Rat := ((i.closesAt - i.startsAt : Nat) : Rat) * i.rate

/-- `LDG-68`'s period of an instant, under a list of boundaries: how many of them lie at or before
it. Half-open: a boundary instant is the first instant of the period it opens. -/
@[req "LDG-68"]
def key (bs : List Nat) (t : Nat) : Nat := bs.countP (· ≤ t)

/-- A metered subject, as this module needs one: an identity and its create instant. -/
structure Subject where
  id        : Nat
  createdAt : Nat
  deriving DecidableEq, Repr

/-- The boundaries a subject's increments are filed against: the deployment's under
`deploymentWide`, whoever the subject is; otherwise its anniversary, the deployment's each offset
by its create instant. -/
@[req "LDG-68"]
def schedule (p : Params) (bs : List Nat) (s : Subject) : List Nat :=
  if p.deploymentWide then bs else bs.map (s.createdAt + ·)

/-- The increment cut at each boundary strictly inside what is left of it, the boundaries taken in
list order: each piece closes at the boundary that ends it, and the next starts there, at the same
rate. With the list in order, no boundary is left inside a piece (`split_straddles_nothing`). -/
@[req "LDG-38"]
def split : List Nat → Increment → List Increment
  | [], i => [i]
  | b :: bs, i =>
    if i.startsAt < b ∧ b < i.closesAt then
      { i with closesAt := b } :: split bs { i with startsAt := b }
    else split bs i

/-- One increment's pieces, each beside the period it is filed under. Under `splitAtBoundary`,
`split`'s pieces, each under the period of its start; otherwise the increment whole, under the
period of its last second. -/
@[req "LDG-38"]
def assign (p : Params) (bs : List Nat) (i : Increment) : List (Nat × Increment) :=
  if p.splitAtBoundary then (split bs i).map fun x => (key bs x.startsAt, x)
  else [(key bs (i.closesAt - 1), i)]

/-- A subject's increments, in the order they close, each split and filed against its
boundaries. -/
def file (p : Params) (bs : List Nat) (s : Subject) (is : List Increment) :
    List (Nat × Increment) :=
  is.flatMap (assign p (schedule p bs s))

/-- Period `k`'s pieces, in order. -/
def inPeriod (fs : List (Nat × Increment)) (k : Nat) : List Increment :=
  (fs.filter (·.1 == k)).map (·.2)

/-- Period `k`'s exact charges, in order. -/
def charges (fs : List (Nat × Increment)) (k : Nat) : List Rat := (inPeriod fs k).map (·.exact)

/-- The credit period `k` opens with: zero under `resetAtBoundary`; otherwise what the pieces of
every earlier period left, carried across. -/
@[req "LDG-38"]
def opening (p : Params) (fs : List (Nat × Increment)) (k : Nat) : Rat :=
  if p.resetAtBoundary then 0
  else Meter.creditAfter ((fs.filter (·.1 < k)).map (·.2.exact)) 0

/-- Period `k`'s posted debits: `Meter.debits` over its charges, in order, from the credit it
opens with. -/
@[req "LDG-38"]
def postings (p : Params) (fs : List (Nat × Increment)) (k : Nat) : List Int :=
  Meter.debits (charges fs k) (opening p fs k)

/-- Period `k`'s postings, each beside the instant its piece closes at. -/
def posted (p : Params) (fs : List (Nat × Increment)) (k : Nat) : List (Nat × Int) :=
  ((inPeriod fs k).map (·.closesAt)).zip (postings p fs k)

/-- Every piece lies inside the increment and keeps its rate. -/
theorem split_within (bs : List Nat) (i : Increment) :
    ∀ x ∈ split bs i, i.startsAt ≤ x.startsAt ∧ x.closesAt ≤ i.closesAt ∧ x.rate = i.rate := by
  induction bs generalizing i with
  | nil => simp [split]
  | cons b bs ih =>
    by_cases h : i.startsAt < b ∧ b < i.closesAt
    · intro x hx
      simp only [split, h, and_self, ↓reduceIte, List.mem_cons] at hx
      rcases hx with rfl | hx
      · exact ⟨Nat.le_refl _, Nat.le_of_lt h.2, rfl⟩
      · have := ih _ x hx
        simp only at this
        exact ⟨by omega, this.2.1, this.2.2⟩
    · simp only [split, h, ↓reduceIte]
      exact ih i

/-- With the boundaries in order, no boundary lies strictly inside a piece. -/
theorem split_straddles_nothing (bs : List Nat) (hs : bs.Pairwise (· ≤ ·)) (i : Increment) :
    ∀ x ∈ split bs i, ∀ b ∈ bs, ¬ (x.startsAt < b ∧ b < x.closesAt) := by
  induction bs generalizing i with
  | nil => simp
  | cons b bs ih =>
    rw [List.pairwise_cons] at hs
    by_cases h : i.startsAt < b ∧ b < i.closesAt
    · intro x hx c hc
      simp only [split, h, and_self, ↓reduceIte, List.mem_cons] at hx hc
      rcases hx with rfl | hx
      · rcases hc with rfl | hc
        · simp
        · have := hs.1 c hc
          simp only
          omega
      · rcases hc with rfl | hc
        · have := split_within bs { i with startsAt := c } x hx
          simp only at this
          omega
        · exact ih hs.2 _ x hx c hc
    · simp only [split, h, ↓reduceIte]
      intro x hx
      have := split_within bs i x hx
      simp only [List.mem_cons, forall_eq_or_imp]
      exact ⟨by omega, ih hs.2 i x hx⟩

/-- `LDG-38`'s split, "An increment also closes at every period boundary", on `LDG-68`'s periods,
"A period begins at `00:00:00Z` on the first day of a month and ends at the same instant of the
next", which the model reads as half-open (`key`): every second of every piece lies in the
period the piece is filed under, so no piece straddles a boundary, and a piece closing at one is
filed under the period that boundary ends. Needs the boundaries in order. -/
@[req "LDG-38"]
theorem piece_inside_its_period (p : Params) (hp : p.splitAtBoundary = true) (bs : List Nat)
    (hs : bs.Pairwise (· ≤ ·)) (i : Increment) :
    ∀ kx ∈ assign p bs i, ∀ t, kx.2.startsAt ≤ t → t < kx.2.closesAt → key bs t = kx.1 := by
  simp only [assign, hp, ↓reduceIte, List.mem_map]
  rintro _ ⟨x, hx, rfl⟩ t h1 h2
  simp only [key] at h1 h2 ⊢
  apply List.countP_congr
  intro b hb
  have := split_straddles_nothing bs hs i x hx b hb
  simp only [decide_eq_true_eq]
  omega

/-- The pieces' seconds sum to the increment's, and so do their exact charges. A sum does not
rule out an overlap offset by a gap; `split` has neither by construction, and this theorem does not
prove it. `LDG-38` asks it of an absorbed window, "every part is counted
exactly once"; this is the same of the increment's own seconds. It holds whether or not the
increment is split. -/
@[req "LDG-38"]
theorem pieces_sum (p : Params) (bs : List Nat) (i : Increment) :
    ((assign p bs i).map fun kx => kx.2.closesAt - kx.2.startsAt).sum = i.closesAt - i.startsAt ∧
    ((assign p bs i).map (·.2.exact)).sum = i.exact := by
  suffices h : ∀ i, ((split bs i).map fun x => x.closesAt - x.startsAt).sum =
      i.closesAt - i.startsAt ∧ ((split bs i).map (·.exact)).sum = i.exact by
    unfold assign
    split
    · simpa [List.map_map, Function.comp_def] using h i
    · simp [Rat.add_zero]
  induction bs with
  | nil => simp [split, Rat.add_zero]
  | cons b bs ih =>
    intro i
    by_cases h : i.startsAt < b ∧ b < i.closesAt
    · simp only [split, h, and_self, ↓reduceIte, List.map_cons, List.sum_cons]
      obtain ⟨h1, h2⟩ := ih { i with startsAt := b }
      refine ⟨by simp only at h1; omega, ?_⟩
      rw [h2]
      simp only [Increment.exact]
      have : i.closesAt - i.startsAt = (b - i.startsAt) + (i.closesAt - b) := by omega
      rw [this, Rat.natCast_add, Rat.add_mul]
    · simp only [split, h, ↓reduceIte]
      exact ih i

/-- `LDG-38`'s reset, the new period's "`meter_totals` row starts with `r = 0`": period `k`'s
postings are `Meter.debits` over period `k`'s own charges from `r = 0`, so no period reads
another's credit. -/
@[req "LDG-38"]
theorem postings_from_zero (p : Params) (hp : p.resetAtBoundary = true)
    (fs : List (Nat × Increment)) (k : Nat) :
    postings p fs k = Meter.debits (charges fs k) 0 := by
  simp [postings, opening, hp]

/-- Under the reset, two filings that agree on period `k`'s charges post the same in period `k`,
whatever either holds in any other period. -/
@[req "LDG-38"]
theorem postings_read_only_their_period (p : Params) (hp : p.resetAtBoundary = true)
    (fs fs' : List (Nat × Increment)) (k : Nat) (h : charges fs k = charges fs' k) :
    postings p fs k = postings p fs' k := by
  rw [postings_from_zero p hp, postings_from_zero p hp, h]

/-- From any credit in `[0, 1)`, the credit after a stream stays there:
`Meter.nextCredit_nonneg` and `Meter.nextCredit_lt_one`, one increment at a time. -/
theorem creditAfter_bounds (xs : List Rat) (r : Rat) (h0 : 0 ≤ r) (h1 : r < 1) :
    0 ≤ Meter.creditAfter xs r ∧ Meter.creditAfter xs r < 1 := by
  induction xs generalizing r with
  | nil => exact ⟨h0, h1⟩
  | cons x xs ih =>
    exact ih _ (Meter.nextCredit_nonneg x r) (Meter.nextCredit_lt_one x r)

/-- Under the reset, period `k` posts `ceil` of its exact sum: `Meter.debits_sum` from `r = 0`,
with the credit it ends on in `[0, 1)` by `creditAfter_bounds`. -/
@[req "LDG-38"]
theorem postings_sum_is_ceil (p : Params) (hp : p.resetAtBoundary = true)
    (fs : List (Nat × Increment)) (k : Nat) :
    (postings p fs k).sum = (charges fs k).sum.ceil := by
  rw [postings_from_zero p hp]
  have hs := Meter.debits_sum (charges fs k) 0
  have ⟨c0, c1⟩ := creditAfter_bounds (charges fs k) 0 (by decide) (by decide)
  have hle : (charges fs k).sum.ceil ≤ (Meter.debits (charges fs k) 0).sum :=
    Rat.ceil_le_iff.mpr (by grind)
  have hlt : (Meter.debits (charges fs k) 0).sum - 1 < (charges fs k).sum.ceil :=
    Rat.lt_ceil_iff.mpr (by rw [Rat.intCast_sub]; grind)
  omega

/-- `LDG-68`: "Every tenant, every machine and every attachment share it". Under the
deployment-wide boundaries an instant's period does not depend on the subject. -/
@[req "LDG-68"]
theorem key_shared (p : Params) (hp : p.deploymentWide = true) (bs : List Nat) (s s' : Subject)
    (t : Nat) : key (schedule p bs s) t = key (schedule p bs s') t := by
  simp [schedule, hp]

end Provisiond.Period
