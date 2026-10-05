import Provisiond.Req
/-! `LDG-58`'s rate over a window of accepted observations, and `LDG-59`'s two ways there is none —
the formal home `ADR-0027` names for `LDG-16`'s promise: *replacing any one observation in the
window cannot move the median past a value another observation in the window carries.* It is a
theorem about the median over plain lists, not about the lifecycle; what makes it bind every
reader of the rate is that it is a property of the input every reader reads, which is why
`Provisiond.Fence` takes its rate from here rather than carrying a second estimator.

An observation contains a price, its `observed_at`, and its stamped staleness bound.
`LDG-58`'s window is selected at an accepting pass. `acceptPass` captures its computed verdict
and its newest-by-observation-time staleness input. `rate` consumes that immutable snapshot,
with no current window or staleness setting argument (amended 2026-10-04, `pv-gip.28`).
A caller supplies snapshots in descending acceptance order. `rateAt` selects only snapshots
accepted by the queried instant (2026-10-04, Q13); tied timestamps use that supplied order.
The newest observation within a snapshot need not be the observation accepted last. Settings affect future `acceptPass`
calls, never the held snapshot. Prices are whole satoshis per second, as in `Provisiond.Runway`.

What the model omits: the source median, quorum and exclusions; per-currency storage; persistence
of stamps, transaction-clock publication and construction of the ordered snapshot list; `STO-37`'s full historical
outage replay and `STO-49` retention, including restore left edges. `Provisiond.Fence` takes
outage starts and effective spans as inputs and its pass takes an already selected price window.
Neither module proves replay, retention, or database serialization.
The promise is bounded exactly as `ADR-0027`'s *What this does not promise* bounds it: a value
carried by half the window confirms itself, one observation can still land the rate on its own
value where that lies between two honest ones, and nothing here sizes a reserve to the window's
spread. `one_observation_stays_in_range` claims the range and no tighter. -/

namespace Provisiond.Rate

/-- One accepted observation, `STO-49`'s row: its price and its `observed_at`. -/
structure Observation where
  price      : Nat
  observedAt : Nat
  staleness : Nat
  deriving DecidableEq, Repr

/-- Insertion into a price-ordered list. Structural, so a witness closes by `decide`. -/
def insert (x : Nat) : List Nat → List Nat
  | [] => [x]
  | y :: ys => if x ≤ y then x :: y :: ys else y :: insert x ys

/-- Prices in price order. -/
def sort : List Nat → List Nat
  | [] => []
  | x :: xs => insert x (sort xs)

theorem insert_perm (x : Nat) (l : List Nat) : (insert x l).Perm (x :: l) := by
  induction l with
  | nil => exact List.Perm.refl _
  | cons y ys ih =>
    unfold insert
    split
    · exact List.Perm.refl _
    · exact (List.Perm.cons y ih).trans (List.Perm.swap x y ys)

theorem sort_perm (l : List Nat) : (sort l).Perm l := by
  induction l with
  | nil => exact List.Perm.refl _
  | cons x xs ih => exact (insert_perm x (sort xs)).trans (List.Perm.cons x ih)

theorem insert_sorted (x : Nat) (l : List Nat) (h : l.Pairwise (· ≤ ·)) :
    (insert x l).Pairwise (· ≤ ·) := by
  induction l with
  | nil => simp [insert]
  | cons y ys ih =>
    rw [List.pairwise_cons] at h
    unfold insert
    split
    · rename_i hxy
      rw [List.pairwise_cons, List.pairwise_cons]
      refine ⟨fun z hz => ?_, h⟩
      rw [List.mem_cons] at hz
      rcases hz with rfl | hz
      · exact hxy
      · exact Nat.le_trans hxy (h.1 z hz)
    · rename_i hxy
      rw [List.pairwise_cons]
      refine ⟨fun z hz => ?_, ih h.2⟩
      rw [(insert_perm x ys).mem_iff, List.mem_cons] at hz
      rcases hz with rfl | hz
      · exact Nat.le_of_lt (Nat.lt_of_not_le hxy)
      · exact h.1 z hz

theorem sort_sorted (l : List Nat) : (sort l).Pairwise (· ≤ ·) := by
  induction l with
  | nil => simp [sort]
  | cons x xs ih => exact insert_sorted x (sort xs) ih

/-- `LDG-58`: "the middle value of those observations in price order, or the lower of the two
middle values where their count is even". Index `(n − 1) / 2` in price order is the middle of an
odd count and the lower middle of an even one; `none` on an empty list. -/
@[req "LDG-58"]
def lowerMedian (prices : List Nat) : Option Nat :=
  (sort prices)[(prices.length - 1) / 2]?

/-- `LDG-58`'s window as of a pass at `passAt`: the observations "whose `observed_at` lies inside
the last window-length before the pass that computed the rate" — observed at or before the pass,
and less than one window-length before it. A row observed after the pass (`STO-49`: "a pass that
reads early and commits late") is not in that pass's window. -/
@[req "LDG-58"]
def window (length passAt : Nat) (obs : List Observation) : List Observation :=
  obs.filter fun o => o.observedAt ≤ passAt && passAt < o.observedAt + length

/-- `LDG-59`'s thinness, on the pass's clock: "Fewer than three observations inside the window is
no rate", "tested at the pass that computes the rate, over the window as of that pass and not
between passes". Otherwise the rate is the window's lower median. -/
@[req "LDG-59"]
def atPass (window : List Nat) : Option Nat :=
  if window.length < 3 then none else lowerMedian window

/-- The latest accepting pass's immutable inputs to the live reader. `STO-49` stores the
verdict, acceptance instant and per-observation bounds; persistence is outside this model. -/
structure AcceptedPass where
  verdict : Option Nat
  newest : Option Observation
  acceptedAt : Nat
  deriving DecidableEq, Repr

/-- Newest by observation time, independently of the order the input rows were accepted. -/
def newestObservation (obs : List Observation) : Option Observation :=
  obs.foldl (fun newest o => match newest with
    | none => some o
    | some prev => if prev.observedAt < o.observedAt then some o else some prev) none

/-- Capture `LDG-58`'s verdict at acceptance, including a null thin-window verdict.
`length` is the setting for this pass; existing observations already carry their own bounds. -/
@[req "LDG-58"]
def acceptPass (length passAt acceptedAt : Nat) (obs : List Observation) : AcceptedPass :=
  let w := window length passAt obs
  ⟨atPass (w.map (·.price)), newestObservation w, acceptedAt⟩

/-- `LDG-59`'s stamped pass verdict and newest observation's own bound. No invocation with
current window/staleness settings can reinterpret a held verdict. -/
@[req "LDG-59"]
def rate (held : AcceptedPass) (now : Nat) : Option Nat :=
  if held.newest.any (fun o => now ≤ o.observedAt + o.staleness) then held.verdict else none

@[req "LDG-59"]
theorem thin_verdict_cannot_return (held : AcceptedPass) (h : held.verdict = none) (now : Nat) :
    rate held now = none := by simp [rate, h]

@[req "LDG-59"]
theorem fresh_reads_stamped_verdict (held : AcceptedPass) (now : Nat)
    (h : held.newest.any (fun o => now ≤ o.observedAt + o.staleness) = true) :
    rate held now = held.verdict := by simp [rate, h]

/-- The accepting transaction clamps its clock against the preceding row, STO-49. -/
@[req "STO-49"]
def acceptanceTime (clock previous : Nat) : Nat := max clock previous

@[req "STO-49"]
theorem acceptance_time_never_regresses (clock previous : Nat) :
    previous ≤ acceptanceTime clock previous := Nat.le_max_right _ _

/-- Q13 (2026-10-04): the off position dates a verdict by its observation evidence instead. -/
structure Guards where
  acceptanceBoundary : Bool

@[req "LDG-58"]
def current : Guards :=
  {
    acceptanceBoundary := true }

/-- `LDG-58`: "every pass verdict MUST take effect at its row's `accepted_at`".
History is supplied in descending acceptance order; no database publication is modelled. -/
@[req "LDG-58"]
def rateAt (g : Guards) (history : List AcceptedPass) (now : Nat) : Option Nat :=
  match history with
  | [] => none
  | row :: rest =>
    let effective := if g.acceptanceBoundary then row.acceptedAt
      else (row.newest.map (·.observedAt)).getD 0
    if effective ≤ now then rate row now else rateAt g rest now

@[req "LDG-58"]
theorem later_row_preserves_past (g : Guards) (hg : g.acceptanceBoundary = true)
    (row : AcceptedPass) (history : List AcceptedPass) (now : Nat)
    (later : now < row.acceptedAt) :
    rateAt g (row :: history) now = rateAt g history now := by
  simp [rateAt, hg, Nat.not_le.mpr later]

/-! ## The promise -/

/-- What a window's prices are, once one of them is replaced: the others, and the replacement. -/
theorem count_set (l : List Nat) (i : Nat) (hi : i < l.length) (x v : Nat) :
    (l.set i x).count v = (l.eraseIdx i).count v + if x == v then 1 else 0 := by
  rw [List.set_eq_take_append_cons_drop, if_pos hi, List.eraseIdx_eq_take_drop_succ,
    List.count_append, List.count_append, List.count_cons]
  omega

theorem mem_of_mem_set (l : List Nat) (i : Nat) (hi : i < l.length) (x v : Nat)
    (h : v ∈ l.set i x) : v ∈ l.eraseIdx i ∨ v = x := by
  rw [List.set_eq_take_append_cons_drop, if_pos hi, List.mem_append, List.mem_cons] at h
  rw [List.eraseIdx_eq_take_drop_succ, List.mem_append]
  rcases h with h | h | h
  · exact Or.inl (Or.inl h)
  · exact Or.inr h
  · exact Or.inl (Or.inr h)

/-- `LDG-16`: "No single rate observation moves the rate outside the range the window's other
observations carry". The theorem `ADR-0027` names: *replacing any one observation in the window
cannot move the median past a value another observation in the window carries.* Over a window of
at least three — `LDG-59`'s thin case is no rate — replacing the observation at any one position
by any value leaves the lower median at or above some other observation and at or below some
other observation. One observation, not two: `ADR-0027` says "more poisoned observations can move
it further while they stay under half the window", and nothing here bounds that. -/
@[req "LDG-16"]
theorem one_observation_stays_in_range (l : List Nat) (i x m : Nat) (hi : i < l.length)
    (h3 : 3 ≤ l.length) (hm : lowerMedian (l.set i x) = some m) :
    (∃ a ∈ l.eraseIdx i, a ≤ m) ∧ (∃ b ∈ l.eraseIdx i, m ≤ b) := by
  unfold lowerMedian at hm
  rw [List.length_set] at hm
  obtain ⟨hk, hsk⟩ := List.getElem?_eq_some_iff.mp hm
  have hperm := sort_perm (l.set i x)
  have hsorted := sort_sorted (l.set i x)
  have hlen : (sort (l.set i x)).length = l.length := by rw [hperm.length_eq, List.length_set]
  -- The sorted window split at the median: everything before is at most `m`, everything from
  -- `m` on is at least `m`.
  have hsplit := List.take_append_drop ((l.length - 1) / 2) (sort (l.set i x))
  have hdrop := List.drop_eq_getElem_cons hk
  rw [hsk] at hdrop
  have hpw := hsorted
  rw [← hsplit, List.pairwise_append] at hpw
  obtain ⟨-, hpwdrop, hcross⟩ := hpw
  have hge : ∀ b ∈ (sort (l.set i x)).drop ((l.length - 1) / 2), m ≤ b := by
    intro b hb
    rw [hdrop, List.mem_cons] at hb
    rcases hb with rfl | hb
    · exact Nat.le_refl _
    · rw [hdrop, List.pairwise_cons] at hpwdrop
      exact hpwdrop.1 b hb
  have hle : ∀ a ∈ (sort (l.set i x)).take ((l.length - 1) / 2), a ≤ m :=
    fun a ha => hcross a ha m (by rw [hdrop]; exact List.mem_cons_self)
  have hmem : ∀ v ∈ sort (l.set i x), v ∈ l.eraseIdx i ∨ v = x :=
    fun v hv => mem_of_mem_set l i hi x v (hperm.mem_iff.mp hv)
  have hm_mem : m ∈ sort (l.set i x) := by
    rw [← hsplit, List.mem_append, hdrop]; exact Or.inr List.mem_cons_self
  -- The replacement is counted once in the window: `x` is one position of it.
  have hcount : (sort (l.set i x)).count x = (l.eraseIdx i).count x + 1 := by
    rw [hperm.count_eq, count_set l i hi x x]; simp
  constructor
  · -- Below: the `(n − 1) / 2 + 1 ≥ 2` positions at or below the median cannot all be the one
    -- replaced observation.
    apply Classical.byContradiction
    intro hno
    have hgt : ∀ a ∈ l.eraseIdx i, m < a := by
      intro a ha
      exact Nat.lt_of_not_le fun h => hno ⟨a, ha, h⟩
    have hmx : m = x := by
      rcases hmem m hm_mem with h | h
      · exact absurd (hgt m h) (Nat.lt_irrefl m)
      · exact h
    have hallx : ∀ a ∈ (sort (l.set i x)).take ((l.length - 1) / 2), x = a := by
      intro a ha
      rcases hmem a (List.mem_of_mem_take ha) with h | h
      · exact absurd (Nat.lt_of_lt_of_le (hgt a h) (hle a ha)) (Nat.lt_irrefl _)
      · exact h.symm
    have hxnot : x ∉ l.eraseIdx i := fun h => Nat.lt_irrefl x (hmx ▸ hgt x h)
    have hzero := List.count_eq_zero.mpr hxnot
    have htake : ((sort (l.set i x)).take ((l.length - 1) / 2)).count x =
        ((sort (l.set i x)).take ((l.length - 1) / 2)).length :=
      List.count_eq_length.mpr hallx
    have hlentake : ((sort (l.set i x)).take ((l.length - 1) / 2)).length = (l.length - 1) / 2 := by
      rw [List.length_take, hlen]; omega
    have hc2 : (sort (l.set i x)).count x =
        ((sort (l.set i x)).take ((l.length - 1) / 2)).count x +
        ((sort (l.set i x)).drop ((l.length - 1) / 2)).count x := by
      rw [← List.count_append, hsplit]
    rw [hdrop, List.count_cons, hmx] at hc2
    simp only [beq_self_eq_true, ↓reduceIte] at hc2
    omega
  · -- Above: the `n − (n − 1) / 2 ≥ 2` positions at or above the median cannot all be the one
    -- replaced observation.
    apply Classical.byContradiction
    intro hno
    have hlt : ∀ b ∈ l.eraseIdx i, b < m := by
      intro b hb
      exact Nat.lt_of_not_le fun h => hno ⟨b, hb, h⟩
    have hallx : ∀ b ∈ (sort (l.set i x)).drop ((l.length - 1) / 2), x = b := by
      intro b hb
      rcases hmem b (List.mem_of_mem_drop hb) with h | h
      · exact absurd (Nat.lt_of_lt_of_le (hlt b h) (hge b hb)) (Nat.lt_irrefl _)
      · exact h.symm
    have hmx : m = x := by
      rcases hmem m hm_mem with h | h
      · exact absurd (hlt m h) (Nat.lt_irrefl m)
      · exact h
    have hxnot : x ∉ l.eraseIdx i := fun h => Nat.lt_irrefl x (hmx ▸ hlt x h)
    have hzero := List.count_eq_zero.mpr hxnot
    have hdropc : ((sort (l.set i x)).drop ((l.length - 1) / 2)).count x =
        ((sort (l.set i x)).drop ((l.length - 1) / 2)).length :=
      List.count_eq_length.mpr hallx
    have hlendrop : ((sort (l.set i x)).drop ((l.length - 1) / 2)).length =
        l.length - (l.length - 1) / 2 := by
      rw [List.length_drop, hlen]
    have hsub := List.Sublist.count_le x (List.drop_sublist ((l.length - 1) / 2) (sort (l.set i x)))
    omega

/-- The edges of the promise, as `ADR-0027` and `LDG-16` state them, on the numbers they use.
`ADR-0026`'s sources `100, 100, 104` with one corrupted to `103` read `100`: the poison is one
value among many. Honest `100, 103, 104` with the `103` replaced by `101.5` — in tenths — reads
`101.5`, "which is why the bound is a range and not a membership". A poisoned value below every
honest one moves the rate "to the nearest honest value". And half a window carries itself:
`LDG-16` says "a plausible price carried by half the window can move the rate to itself", and
"It promises no more than that." Two of four at `50` read `50`. -/
@[req "LDG-16"]
theorem promise_edges :
    lowerMedian [100, 100, 103] = some 100 ∧
    lowerMedian [1000, 1015, 1040] = some 1015 ∧
    lowerMedian [100, 100, 50] = some 100 ∧
    lowerMedian [100, 100, 50, 50] = some 50 := by decide

/-- The two clocks, on one history: three observations at `0`, `10` and `20`, window length `25`,
staleness bound `15`. A pass at `20` sees all three and computes `100`; at `30` the newest is
still inside the bound, at `36` it is not, with no pass between — staleness is continuous. A pass
at `30` sees two inside its window, the ones at `10` and `20`, and at `30` the newest is still
inside the bound: no rate at that pass is thinness, not staleness — thinness is the pass's. A
pass at `12` sees two too: below three is no rate whatever the instant. -/
@[req "LDG-59"]
theorem two_clocks :
    let obs : List Observation := [⟨100, 0, 15⟩, ⟨104, 10, 15⟩, ⟨100, 20, 15⟩]
    (window 25 30 obs).length = 2 ∧
    rate (acceptPass 25 20 20 obs) 30 = some 100 ∧
    rate (acceptPass 25 20 20 obs) 36 = none ∧
    rate (acceptPass 25 30 30 obs) 30 = none ∧
    rate (acceptPass 25 12 12 obs) 12 = none := by decide

/-- `LDG-59` keeps observation time distinct from acceptance order. The same history
with a fourth row observed at `100` — `STO-49`'s "a pass that reads early and commits late" —
which the pass at `20` does not see: at `40` that pass's window is stale, and the late row keeps
its rate no more alive than its absence does. At `30` the same window is still fresh. -/
@[req "LDG-59"]
theorem late_row_keeps_nothing_alive :
    let obs : List Observation := [⟨100, 0, 15⟩, ⟨104, 10, 15⟩, ⟨100, 20, 15⟩]
    let late : List Observation := obs ++ [⟨100, 100, 15⟩]
    window 25 20 late = obs ∧
    rate (acceptPass 25 20 20 late) 40 = none ∧
    rate (acceptPass 25 20 20 obs) 40 = none ∧
    rate (acceptPass 25 20 20 late) 30 = some 100 := by decide

/-- Actual rate verdict, not a thick/thin flag: a different subsequent window cannot change
an existing snapshot. A new pass may compute a different verdict. -/
@[req "LDG-58"]
theorem settings_only_affect_a_new_pass :
    let obs : List Observation := [⟨100, 0, 60⟩, ⟨104, 10, 60⟩, ⟨100, 20, 60⟩]
    let held := acceptPass 25 20 20 obs
    rate held 30 = some 100 ∧
    rate (acceptPass 10 30 30 obs) 30 = none ∧
    rate held 40 = some 100 := by decide

/-- A later-accepted earlier observation does not supply the newest observation's bound. -/
@[req "LDG-59"]
theorem acceptance_and_observation_clocks_differ :
    let obs : List Observation := [⟨100, 0, 15⟩, ⟨104, 10, 15⟩,
      ⟨100, 20, 100⟩, ⟨100, 15, 1⟩]
    rate (acceptPass 30 25 25 obs) 40 = some 100 ∧
    rate (acceptPass 30 25 25 obs) 121 = none := by decide

end Provisiond.Rate
