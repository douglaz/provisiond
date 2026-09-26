import Provisiond.Req
/-! `LDG-9`'s available balance and the conservation laws around one tenant's one commitment, in
whole satoshis: `LDG-31`'s pairing with its clamp, `LDG-32`'s release of the exact remainder,
`LDG-35`'s authorization read against the commit that follows it, and `LDG-10`'s floor. Then one
tenant's entries, and `LDG-70`'s read of them, "`balance_after` on the greatest `seq` for that
tenant", against the sum `Balances.sum` stands for: `drift_identity` says what their difference is
on every trace, and `open_against_read_is_the_serialized_open` is where the read meets the open.

The operator deficiency `LDG-31`'s clamp writes is `Balances.deficiency`, a running satoshi total
the balance never reads: `LDG-66` says it "is NOT a ledger entry" and "MUST NOT alter any tenant
balance", and `deficiency_is_not_a_balance` is that sentence. `STO-37`'s record — the cause, the
native amount, the absorbed seconds — is `Provisiond.Funding.Deficiency`; here only the satoshi
figure `clamped_sats` is carried, in the unit the clamp arose in.

The guards are the fields of `Guards`, each carried as a parameter so that the alternative the text
forbids is a one-token change with a witness. `clampAtAuthority`: `LDG-31`'s clamp paragraph, "the
tenant is debited only up to the authority it granted, and the remainder is recorded as an operator
deficiency"; the remainder "MUST NOT be taken from available balance", which without the clamp it is
— "the automatic seizure `ADR-0011` exists to forbid". (The dated amendment beside it, 2026-09-02,
is the pairing rule's "has no exception"; the clamp paragraph itself is undated.)
`serializedAuthorization`: `LDG-35`, "The authorization read and the commitment write MUST be
serialized per tenant" — the primitive was chosen on 2026-09-06 (`ADR-0015`), the rule is undated;
without it the open authorizes against `snapshot`, the balance an earlier transaction read — "two
transactions can each read the same balance and each commit, leaving twice the balance reserved".
`appendReadsLatest`: `LDG-70`, "`balance_after` MUST be computed and written inside the same
serialized transaction that appends the entry" — the rule is undated; without it an append computes
from the row an earlier transaction read, and each such append moves the latest `balance_after` off
the sum by the difference between that row and the greatest one, which `drift_identity` totals. The serialization is
`LDG-35`'s, whose amendment says "`LDG-70` requires every append to happen inside this
serialization", and `serializedAuthorization` models it for the open; this guard is which row the
append reads. Their witnesses are in `Provisiond.Witnesses`.

What the model omits: more than one commitment (`Provisiond.Funding` carries the one metered
subject's); the fee kinds `LDG-31` also pairs, which route through `clamp` the same way; the
concurrency `LDG-35` orders, modelled as one stale read and not as two interleaved transactions, and
the same for an append; the `version` of `STO-28`'s conditional write. Of `LDG-70`: any storage — no
SQL, and not the `(tenant_id, seq desc)` index the read is served from; an entry's kind, id and
causes — an `Entry` is its sequence number, amount and `balance_after`; one state for the entries
and the commitment — `Book` and `Balances` are separate, joined only by the hypothesis that
`Balances.sum` is the entries' sum; of the uses `LDG-70` names, "every create, every extend and
every metered posting" and `GET /v1/balance`, all but the create's open; a refused append —
`Book.step` takes any amount, and `LDG-10`'s floors are proved of `Balances`; a second tenant, and
with it `LDG-35`'s "ascending tenant-identifier order"; and the audit path's failure mode —
`drift_identity` is the difference the audit would find, and that "a mismatch MUST fail closed" is
not modelled. -/

namespace Provisiond.Ledger

structure Guards where
  clampAtAuthority        : Bool
  serializedAuthorization : Bool
  appendReadsLatest       : Bool
  deriving DecidableEq, Repr

/-- The rules as they stand. One field per line: `ci.yml`'s controls flip one each. -/
@[req "LDG-31"]
def current : Guards := {
    clampAtAuthority        := true,
    serializedAuthorization := true,
    appendReadsLatest       := true }

/-- The two sums `LDG-9` subtracts, the operator's satoshi deficiency beside them, and the
balance a transaction read before it committed. -/
structure Balances where
  sum        : Int
  reserved   : Int
  /-- `STO-37`'s `clamped_sats`, summed: the operator's, in satoshis, and not an entry. -/
  deficiency : Int
  /-- `LDG-35`'s authorization read, as an earlier transaction took it. -/
  snapshot   : Int
  deriving DecidableEq, Repr

/-- `LDG-9`: `available = Σ(ledger entries) − Σ(reserved amount of open commitments)`. -/
@[req "LDG-9"]
def Balances.available (b : Balances) : Int := b.sum - b.reserved

/-- `LDG-31`: "the commitment decrements to zero, the tenant is debited only up to the authority
it granted, and the remainder is recorded as an operator deficiency". The entry, and the
operator's remainder, from what remains of the commitment and the debit computed. -/
@[req "LDG-31"]
def clamp (remaining debit : Int) : Int × Int :=
  let entry := min debit (max remaining 0)
  (entry, debit - entry)

/-- The events one tenant's ledger sees. `read` is the authorization read as its own transaction;
`openCommitment` is the commit that follows it. -/
inductive Event
  | topup (sats : Int)
  | read
  | openCommitment (sats : Int)
  | usageDebit (sats : Int)
  | closeCommitment
  deriving DecidableEq, Repr

/-- `LDG-31`: posting a debit "MUST decrement that commitment by the same amount, in one
transaction" — the one step that moves both sums, clamped at the authority granted. The open is
`LDG-9`'s "`available ≥ required_commitment`", read where the guard says. A close releases the one
commitment in full (`LDG-32`). -/
@[req "LDG-31"]
def step (g : Guards) (b : Balances) : Event → Balances
  | .topup n => { b with sum := b.sum + n }
  | .read => { b with snapshot := b.available }
  | .openCommitment n =>
    let authorized := if g.serializedAuthorization then b.available else b.snapshot
    if n ≤ authorized then { b with reserved := b.reserved + n } else b
  | .usageDebit n =>
    if g.clampAtAuthority then
      let (entry, overflow) := clamp b.reserved n
      { b with sum := b.sum - entry, reserved := b.reserved - entry,
               deficiency := b.deficiency + overflow }
    else
      -- The seizure: the whole debit leaves the balance, the commitment reaches zero, and what
      -- the commitment did not cover came from `available`.
      { b with sum := b.sum - n, reserved := max (b.reserved - n) 0 }
  | .closeCommitment => { b with reserved := 0 }

def run (g : Guards) (b : Balances) (evs : List Event) : Balances := evs.foldl (step g) b

/-! ## The clamp -/

/-- The clamp spends nothing beyond the commitment: the entry is at most what remained and at
most the debit. -/
@[req "LDG-31"]
theorem clamp_within_authority (remaining debit : Int) :
    (clamp remaining debit).1 ≤ max remaining 0 ∧ (clamp remaining debit).1 ≤ debit := by
  simp only [clamp]; omega

/-- The entry and the remainder are the one debit, split: nothing is charged twice and nothing is
dropped. -/
@[req "LDG-31"]
theorem clamp_splits_the_debit (remaining debit : Int) :
    (clamp remaining debit).1 + (clamp remaining debit).2 = debit := by
  simp only [clamp]; omega

/-- A nonnegative debit against a nonnegative remainder leaves both parts nonnegative: the
remainder is the operator's loss, never a credit. -/
@[req "LDG-31"]
theorem clamp_nonneg (remaining debit : Int) (hd : 0 ≤ debit) :
    0 ≤ (clamp remaining debit).1 ∧ 0 ≤ (clamp remaining debit).2 := by
  simp only [clamp]; omega

/-- `LDG-31`: "consumption leaves `available` **unchanged**", for every balance and every debit,
with the clamp — the clamped entry and the clamped decrement are the same number. -/
@[req "LDG-31"]
theorem usage_leaves_available_unchanged (g : Guards) (hg : g.clampAtAuthority = true)
    (b : Balances) (n : Int) :
    (step g b (.usageDebit n)).available = b.available := by
  simp only [step, hg, clamp, Balances.available, ite_true]; omega

/-- The clamp writes the remainder to the deficiency and nowhere else: the commitment never goes
below zero, and the deficiency grows by exactly what the tenant was not debited. -/
@[req "LDG-31"]
theorem usage_clamps_at_zero (g : Guards) (hg : g.clampAtAuthority = true) (b : Balances)
    (n : Int) (hr : 0 ≤ b.reserved) :
    0 ≤ (step g b (.usageDebit n)).reserved ∧
    (step g b (.usageDebit n)).deficiency - b.deficiency = n - (b.sum - (step g b (.usageDebit n)).sum) := by
  simp only [step, hg, clamp, ite_true]; omega

/-- `LDG-66`: the deficiency "MUST NOT alter any tenant balance" — `available` does not read it. -/
@[req "LDG-66"]
theorem deficiency_is_not_a_balance (b : Balances) (d : Int) :
    ({ b with deficiency := d } : Balances).available = b.available := rfl

/-! ## The release -/

/-- `LDG-32`: "closed, and its remaining amount released in full" — `available` rises by exactly
the remainder, on every balance. -/
@[req "LDG-32"]
theorem close_releases_exact_remainder (g : Guards) (b : Balances) :
    (step g b .closeCommitment).available = b.available + b.reserved ∧
    (step g b .closeCommitment).reserved = 0 := by
  simp [step, Balances.available]

/-! ## The authorization -/

/-- `LDG-9`: the open "is the only authorization a create receives", and under `LDG-35`'s
serialization it is read at the commit: a commitment that opened was funded by the available
balance of the state it committed against. -/
@[req "LDG-35"]
theorem open_authorized_at_commit (g : Guards) (hg : g.serializedAuthorization = true)
    (b : Balances) (n : Int) (h : (step g b (.openCommitment n)).reserved ≠ b.reserved) :
    n ≤ b.available := by
  simp only [step, hg, ite_true] at h
  by_cases hn : n ≤ b.available
  · exact hn
  · simp [hn] at h

/-- What an event must satisfy for `LDG-10` to survive it: the amounts are nonnegative. -/
def Event.nonneg : Event → Prop
  | .topup n | .openCommitment n | .usageDebit n => 0 ≤ n
  | .read | .closeCommitment => True

/-- `LDG-10`: "A balance MUST NOT go negative, and `available` MUST NOT go negative" — under the
clamp and the serialized authorization, both floors survive every event with nonnegative amounts,
and so does the commitment's. -/
@[req "LDG-10"]
theorem floors_preserved (g : Guards) (hc : g.clampAtAuthority = true)
    (hs : g.serializedAuthorization = true) (b : Balances) (e : Event) (he : e.nonneg)
    (h : 0 ≤ b.available ∧ 0 ≤ b.reserved) :
    0 ≤ (step g b e).available ∧ 0 ≤ (step g b e).reserved := by
  cases e <;> simp only [Event.nonneg] at he <;>
    simp only [step, hc, hs, clamp, Balances.available, ite_true] at * <;> (repeat' split) <;>
    (try dsimp only) <;> omega

/-- `LDG-10` over a whole ledger. -/
@[req "LDG-10"]
theorem run_floors (g : Guards) (hc : g.clampAtAuthority = true)
    (hs : g.serializedAuthorization = true) (b : Balances) (evs : List Event)
    (he : ∀ e ∈ evs, e.nonneg) (h : 0 ≤ b.available ∧ 0 ≤ b.reserved) :
    0 ≤ (run g b evs).available ∧ 0 ≤ (run g b evs).reserved := by
  induction evs generalizing b with
  | nil => exact h
  | cons e evs ih =>
    exact ih (step g b e) (fun e' h' => he e' (List.mem_cons_of_mem _ h'))
      (floors_preserved g hc hs b e (he e (List.mem_cons_self ..)) h)

/-! ## The entries and the read -/

/-- An entry, cut to the fields the read and the sum need. Of what every entry carries, `LDG-6`
says "a per-tenant monotonic sequence number", "the signed satoshi amount" and "the running balance
after it". -/
structure Entry where
  seq          : Nat
  amount       : Int
  balanceAfter : Int
  deriving DecidableEq, Repr

/-- `balance_after` on a row, and 0 on no row: the empty history's read, matching its empty sum. -/
def balanceOf : Option Entry → Int
  | some e => e.balanceAfter
  | none   => 0

/-- The greatest `seq` in a history, 0 in the empty one. -/
def topSeq : List Entry → Nat
  | []      => 0
  | e :: es => max e.seq (topSeq es)

/-- The entry with the greatest `seq`, found by comparing sequence numbers, not by position. -/
def latest : List Entry → Option Entry
  | []      => none
  | e :: es =>
    match latest es with
    | some l => if e.seq < l.seq then some l else some e
    | none   => some e

/-- One tenant's entries in the order they were appended, and the row a transaction read before
it appended — `snapshot` in `Balances`, as a row. -/
structure Book where
  entries  : List Entry
  snapshot : Option Entry
  deriving DecidableEq, Repr

def Book.empty : Book := { entries := [], snapshot := none }

/-- `LDG-5`: "**Balance is the sum of entries** and nothing else". -/
@[req "LDG-5"]
def Book.sum (k : Book) : Int := (k.entries.map (·.amount)).sum

/-- `LDG-70`: "`balance_after` on the greatest `seq` for that tenant is the authoritative read". -/
@[req "LDG-70"]
def Book.read (k : Book) : Int := balanceOf (latest k.entries)

/-- What one tenant's entries see: `snapshot`, a transaction reading the latest row as its own
step, and `append`, an entry of a signed amount. -/
inductive Posting
  | snapshot
  | append (sats : Int)
  deriving DecidableEq, Repr

/-- The row an append computes `balance_after` from, read where the guard says. -/
def Book.predecessor (g : Guards) (k : Book) : Option Entry :=
  if g.appendReadsLatest then latest k.entries
  -- The stale predecessor: the row an earlier transaction read, behind the greatest by every
  -- entry appended since.
  else k.snapshot

/-- `LDG-70`: `balance_after` computed "as `previous.balance_after + amount_sats` read under that
serialization", on an entry that takes the next `seq`. -/
@[req "LDG-70"]
def Book.step (g : Guards) (k : Book) : Posting → Book
  | .snapshot => { k with snapshot := latest k.entries }
  | .append n =>
    { k with entries := k.entries ++ [{ seq := topSeq k.entries + 1, amount := n,
                                        balanceAfter := balanceOf (k.predecessor g) + n }] }

def Book.run (g : Guards) (k : Book) (ps : List Posting) : Book := ps.foldl (Book.step g) k

/-- Each append's drift, in trace order: `balance_after` of the row it read less `balance_after`
of the greatest row at that moment. A snapshot appends nothing and has none. -/
def Book.drifts (g : Guards) (k : Book) : List Posting → List Int
  | [] => []
  | .snapshot :: ps => (k.step g .snapshot).drifts g ps
  | .append n :: ps => (balanceOf (k.predecessor g) - k.read) :: (k.step g (.append n)).drifts g ps

theorem seq_le_topSeq {e : Entry} {es : List Entry} (h : e ∈ es) : e.seq ≤ topSeq es := by
  induction es with
  | nil => cases h
  | cons x xs ih =>
    simp only [topSeq]
    rcases List.mem_cons.mp h with rfl | h
    · omega
    · have := ih h; omega

/-- `LDG-70`'s read is "`balance_after` on the greatest `seq` for that tenant", and `Book.read` is
that by theorem, not by the definition's name: the row `latest` finds is an entry of the history,
and no entry's `seq` exceeds it, whatever position it holds. -/
@[req "LDG-70"]
theorem latest_is_greatest {es : List Entry} {l : Entry} (h : latest es = some l) :
    l ∈ es ∧ ∀ e ∈ es, e.seq ≤ l.seq := by
  induction es generalizing l with
  | nil => cases h
  | cons x xs ih =>
    simp only [latest] at h
    split at h
    · rename_i m hm
      obtain ⟨hmem, hle⟩ := ih hm
      by_cases hlt : x.seq < m.seq
      · simp only [hlt, ite_true, Option.some.injEq] at h
        subst h
        refine ⟨List.mem_cons_of_mem _ hmem, fun e he => ?_⟩
        rcases List.mem_cons.mp he with rfl | he
        · omega
        · exact hle e he
      · simp only [hlt, ite_false, Option.some.injEq] at h
        subst h
        refine ⟨List.mem_cons_self .., fun e he => ?_⟩
        rcases List.mem_cons.mp he with rfl | he
        · exact Nat.le_refl _
        · have := hle e he; omega
    · rename_i hm
      simp only [Option.some.injEq] at h
      subst h
      refine ⟨List.mem_cons_self .., fun e he => ?_⟩
      rcases List.mem_cons.mp he with rfl | he
      · exact Nat.le_refl _
      · cases xs with
        | nil => cases he
        | cons y ys => simp only [latest] at hm; split at hm <;> (try split at hm) <;> cases hm

theorem latest_append_above (es : List Entry) (e : Entry) (h : ∀ x ∈ es, x.seq < e.seq) :
    latest (es ++ [e]) = some e := by
  induction es with
  | nil => rfl
  | cons x xs ih =>
    simp only [List.cons_append, latest,
      ih (fun y hy => h y (List.mem_cons_of_mem _ hy)), h x (List.mem_cons_self ..), ite_true]

/-- `LDG-6`'s "per-tenant monotonic sequence number": an append takes a `seq` above every one in
the history, so on every history, whatever order its entries sit in, the greatest row after an
append is the entry appended and the read is that entry's `balance_after`. -/
@[req "LDG-70"]
theorem read_is_the_appended_entry (g : Guards) (k : Book) (n : Int) :
    (∀ e ∈ k.entries, e.seq < topSeq k.entries + 1) ∧
    latest (k.step g (.append n)).entries =
      some { seq := topSeq k.entries + 1, amount := n,
             balanceAfter := balanceOf (k.predecessor g) + n } ∧
    (k.step g (.append n)).read = balanceOf (k.predecessor g) + n := by
  have above : ∀ e ∈ k.entries, e.seq < topSeq k.entries + 1 :=
    fun e h => Nat.lt_succ_of_le (seq_le_topSeq h)
  have hl : latest (k.step g (.append n)).entries =
      some { seq := topSeq k.entries + 1, amount := n,
             balanceAfter := balanceOf (k.predecessor g) + n } :=
    latest_append_above k.entries _ above
  exact ⟨above, hl, by rw [Book.read, hl]; rfl⟩

theorem sum_append (g : Guards) (k : Book) (n : Int) :
    (k.step g (.append n)).sum = k.sum + n := by
  simp [Book.sum, Book.step, List.map_append, List.sum_append]

/-- `LDG-70`: "the serialization that already exists to prevent write skew is what keeps it
exact" — under the guard every append reads the greatest row, and a history whose read is its sum
keeps it so. -/
@[req "LDG-70"]
theorem append_keeps_read_at_sum (g : Guards) (hg : g.appendReadsLatest = true) (k : Book)
    (n : Int) (h : k.read = k.sum) :
    (k.step g (.append n)).read = (k.step g (.append n)).sum := by
  rw [(read_is_the_appended_entry g k n).2.2, sum_append]
  simp only [Book.predecessor, hg, ite_true]
  exact congrArg (· + n) h

/-- And so, under the guard, on every trace from the empty history the read is the sum. -/
@[req "LDG-70"]
theorem read_is_sum (g : Guards) (hg : g.appendReadsLatest = true) (ps : List Posting) :
    (Book.empty.run g ps).read = (Book.empty.run g ps).sum := by
  suffices ∀ k : Book, k.read = k.sum → (k.run g ps).read = (k.run g ps).sum from this _ rfl
  induction ps with
  | nil => exact fun _ h => h
  | cons p ps ih =>
    intro k h
    cases p with
    | snapshot => exact ih _ h
    | append n => exact ih _ (append_keeps_read_at_sum g hg k n h)

/-- What `read − sum` is, on every trace from every history, guard on or off: where it started
plus every append's drift. The audit `LDG-70` requires "recomputes the sum from the entries and
compares it to the latest `balance_after`"; this is the difference it finds. -/
@[req "LDG-70"]
theorem drift_identity (g : Guards) (k : Book) (ps : List Posting) :
    (k.run g ps).read - (k.run g ps).sum = k.read - k.sum + (k.drifts g ps).sum := by
  induction ps generalizing k with
  | nil => simp [Book.run, Book.drifts]
  | cons p ps ih =>
    cases p with
    | snapshot => simpa [Book.run, Book.drifts] using ih (k.step g .snapshot)
    | append n =>
      have := ih (k.step g (.append n))
      simp only [Book.run, List.foldl_cons, Book.drifts, List.sum_cons] at this ⊢
      rw [this, (read_is_the_appended_entry g k n).2.2, sum_append]
      omega

/-- Under the guard every drift is zero, so `drift_identity` leaves `read − sum` where it started:
at zero from the empty history, which is `read_is_sum`, reached there one append at a time. -/
@[req "LDG-70"]
theorem drifts_zero (g : Guards) (hg : g.appendReadsLatest = true) (k : Book)
    (ps : List Posting) : ∀ d ∈ k.drifts g ps, d = 0 := by
  induction ps generalizing k with
  | nil => simp [Book.drifts]
  | cons p ps ih =>
    cases p with
    | snapshot => exact ih _
    | append n =>
      intro d hd
      simp only [Book.drifts, List.mem_cons] at hd
      rcases hd with rfl | hd
      · simp [Book.predecessor, hg, Book.read]
      · exact ih _ d hd

/-- The direction that holds: on a trace from the empty history, a read that is not the sum names
an append that read a row other than the greatest. The converse does not: a stale read across entries that net to zero drifts by
nothing. -/
@[req "LDG-70"]
theorem divergence_names_a_stale_append (g : Guards) (ps : List Posting)
    (h : (Book.empty.run g ps).read ≠ (Book.empty.run g ps).sum) :
    ∃ pre n post, ps = pre ++ .append n :: post ∧
      (Book.empty.run g pre).predecessor g ≠ latest (Book.empty.run g pre).entries := by
  suffices ∀ k : Book, (k.run g ps).read - (k.run g ps).sum ≠ k.read - k.sum →
      ∃ pre n post, ps = pre ++ .append n :: post ∧
        (k.run g pre).predecessor g ≠ latest (k.run g pre).entries from
    this _ (by rw [show Book.empty.read - Book.empty.sum = 0 from rfl]; omega)
  clear h
  induction ps with
  | nil => exact fun _ h => absurd rfl h
  | cons p ps ih =>
    intro k h
    cases p with
    | snapshot =>
      obtain ⟨pre, n, post, rfl, hs⟩ := ih (k.step g .snapshot) h
      exact ⟨.snapshot :: pre, n, post, rfl, hs⟩
    | append n =>
      by_cases hp : k.predecessor g = latest k.entries
      · have hr : (k.step g (.append n)).read - (k.step g (.append n)).sum = k.read - k.sum := by
          rw [(read_is_the_appended_entry g k n).2.2, sum_append, hp]
          simp only [Book.read]; omega
        obtain ⟨pre, m, post, rfl, hs⟩ := ih (k.step g (.append n)) (hr ▸ h)
        exact ⟨.append n :: pre, m, post, rfl, hs⟩
      · exact ⟨[], n, ps, rfl, hp⟩

/-- `LDG-9`'s open, "`available ≥ required_commitment`", with `Σ(ledger entries)` read as `read`:
`step`'s `openCommitment` against a balance the caller names. -/
def openAgainst (read : Int) (b : Balances) (n : Int) : Balances :=
  if n ≤ read - b.reserved then { b with reserved := b.reserved + n } else b

/-- Under the guard, the available balance computed from the read is `LDG-9`'s, for every
`Balances` whose `sum` is the entries' sum. -/
@[req "LDG-70"]
theorem read_available_is_available (g : Guards) (hg : g.appendReadsLatest = true)
    (ps : List Posting) (b : Balances) (hb : b.sum = (Book.empty.run g ps).sum) :
    (Book.empty.run g ps).read - b.reserved = b.available := by
  rw [read_is_sum g hg, ← hb]; rfl

/-- So an open against the read is `step`'s own under `LDG-35`'s serialization, and
`open_authorized_at_commit` and `floors_preserved` hold of it as they stand. -/
@[req "LDG-70"]
theorem open_against_read_is_the_serialized_open (g : Guards)
    (ha : g.appendReadsLatest = true) (hs : g.serializedAuthorization = true) (ps : List Posting)
    (b : Balances) (hb : b.sum = (Book.empty.run g ps).sum) (n : Int) :
    openAgainst (Book.empty.run g ps).read b n = step g b (.openCommitment n) := by
  simp only [openAgainst, step, hs, ite_true, read_available_is_available g ha ps b hb]

end Provisiond.Ledger
