import Provisiond.Req
/-! `LDG-9`'s available balance and the conservation laws around one tenant's identified
commitments, in whole satoshis: `LDG-31`'s pairing with its clamp, `LDG-32`'s release of the exact
remainder, `LDG-35`'s authorization read against the commit that follows it, and `LDG-10`'s floor.
Then one tenant's entries, and `LDG-70`'s read of them, "`balance_after` on the greatest `seq` for that
tenant", against the sum `Balances.sum` stands for: `drift_identity` says what their difference is
on every trace, and `open_against_read_is_the_serialized_open` is where the read meets the open.

The operator deficiency `LDG-31`'s clamp writes is `Balances.deficiency`, a running satoshi total
the balance never reads: `LDG-66` says it "is NOT a ledger entry" and "MUST NOT alter any tenant
balance", and `deficiency_is_not_a_balance` is that sentence. `STO-37`'s record — the cause, the
absorbed seconds — is partly carried by `Provisiond.Funding.Deficiency`; native cost there is
omitted. `nativeSplit` below checks the native partition in isolation; the ledger step carries
only the satoshi figure `clamped_sats`, in the unit the clamp arose in.

The guards are the fields of `Guards`, each carried as a parameter so that the alternative the text
forbids is a one-token change with a witness. `clampAtAuthority`: `LDG-31`'s clamp paragraph, "the
tenant is debited only up to the authority it granted, and the remainder is recorded as an
**operator deficiency**"; the remainder "MUST NOT be taken from available balance", which without
the clamp it is — "the automatic seizure `ADR-0011` exists to forbid". (The dated amendment
beside it, 2026-09-02, is the pairing rule's "has no exception"; the clamp paragraph itself is
undated.) The guard also governs debits naming closed or missing slots: enabled, the
whole signed amount goes to deficiency with sum and slots unchanged; disabled, the whole debit
leaves sum with slots unchanged. `LDG-31`'s amendment says "there is no debit left that pairs with
nothing", and its clamp paragraph says "It MUST NOT be taken from available balance".
`serializedAuthorization`: `LDG-35`, "The authorization read and the commitment write MUST be
serialized per tenant" — the primitive was chosen on 2026-09-06 (`ADR-0015`), the rule is undated;
without it the open authorizes against `snapshot`, the balance an earlier transaction read — "two
transactions can each read the same balance and each commit, leaving twice the balance reserved".
`appendReadsLatest`: `LDG-70`, "`balance_after` MUST be computed and written inside the same
serialized transaction that appends the entry" — the rule is undated; without it an append computes
from the row an earlier transaction read, and each such append moves the latest `balance_after` off
the sum by the difference between that row and the greatest one, which `drift_identity` totals.
The serialization is `LDG-35`'s, whose amendment says "`LDG-70` requires every append to happen
inside this serialization", and `serializedAuthorization` models it for the open; this guard is
which row the append reads. Their witnesses are in `Provisiond.Witnesses`.

Additional guards, with no dated amendment carrying these rules:
`allCommitmentsAuthorize`: the disabled open subtracts only the first open slot, in allocation
order, from the ledger sum; `LDG-9` defines
"available = Σ(ledger entries) − Σ(reserved amount of open commitments)".
`closeOwnCommitment`: the disabled close clears every open slot; `LDG-32` says
"A commitment MUST be closed, and its remaining amount released in full".
`LDG-28` says
"Releasing a commitment returns **the exact satoshi amount still reserved**".
`clampOwnCommitment`: the disabled debit clamps against the tenant's derived total, spends the
named slot first, and consumes any excess from the other slots in allocation order; `LDG-31`
says "the commitment decrements to zero, the tenant is debited only up to the authority it granted,
and the remainder is recorded as an **operator deficiency**". The clamp paragraph itself is undated.

Commitment identifiers are list positions, allocated by appending a fresh slot; `some amount`
is open and `none` is closed, retained so identifiers are never reused. They identify reservations,
not machines. A debit naming a closed or nonexistent slot records its whole signed amount as
deficiency under `clampAtAuthority`, leaving sum and every slot unchanged; with that guard off it
subtracts the whole amount from sum and leaves every slot unchanged. A close naming such a slot
leaves the entire state alone.
`Provisiond.Funding` stays single-commitment: it carries one metered subject's remaining amount and
calls only `Ledger.clamp`.

What the model omits: machines and the per-machine rule (`LDG-30`: "A machine MUST have at most
one `open` commitment at a time"); operation identity before a machine exists; setup fee and first
unit targeting; commitment growth; account termination's bulk close; attachments keeping a
commitment open; corrections; `LDG-34`'s conditional write; the fee kinds `LDG-31` also pairs,
which route through `clamp` the same way; the concurrency `LDG-35` orders, modelled as one stale
read and not as two interleaved transactions, and the same for an append; the `version` of `STO-28`'s conditional write. Of `LDG-70`: any storage — no
SQL, and not the `(tenant_id, seq desc)` index the read is served from; an entry's kind, id and
causes — an `Entry` is its sequence number, amount and `balance_after`; one state for the entries
and the commitments — `Book` and `Balances` are separate, joined only by the hypothesis that
`Balances.sum` is the entries' sum; of the uses `LDG-70` names, "every create, every extend and
every metered posting" and `GET /v1/balance`, all but the create's open; a refused append —
`Book.step` takes any amount, and `LDG-10`'s floors are proved of `Balances`; a second tenant, and
with it `LDG-35`'s "ascending tenant-identifier order"; and the audit path's failure mode —
`drift_identity` is the difference the audit would find, and that "a mismatch MUST fail closed" is
not modelled. -/

namespace Provisiond.Ledger

structure Guards where
  nativeCostSplit         : Bool
  clampAtAuthority        : Bool
  serializedAuthorization : Bool
  appendReadsLatest       : Bool
  allCommitmentsAuthorize : Bool
  closeOwnCommitment      : Bool
  clampOwnCommitment      : Bool
  deriving DecidableEq, Repr

/-- The rules as they stand. One field per line: `ci.yml`'s controls flip one each. -/
@[req "LDG-31"]
def current : Guards := {
    nativeCostSplit         := true,
    clampAtAuthority        := true,
    serializedAuthorization := true,
    appendReadsLatest       := true,
    allCommitmentsAuthorize := true,
    closeOwnCommitment      := true,
    clampOwnCommitment      := true }

/-- Slots retain closed commitments; their positions are the allocated identifiers. -/
abbrev Commitments := List (Option Int)

namespace Commitments

def remaining : Commitments → Nat → Int
  | [], _ => 0
  | x :: _, 0 => x.getD 0
  | _ :: xs, i + 1 => remaining xs i

def isOpen : Commitments → Nat → Bool
  | [], _ => false
  | x :: _, 0 => x.isSome
  | _ :: xs, i + 1 => isOpen xs i

def total : Commitments → Int
  | [] => 0
  | x :: xs => x.getD 0 + total xs

/-- The first open slot, in allocation order, for the disabled aggregate authorization. -/
def first : Commitments → Int
  | [] => 0
  | none :: xs => first xs
  | some n :: _ => n

/-- An update cannot reopen a closed slot or invent a missing slot. -/
def change : Commitments → Nat → (Int → Option Int) → Commitments
  | [], _, _ => []
  | x :: xs, 0, f => (x.bind f) :: xs
  | x :: xs, i + 1, f => x :: change xs i f

def nonneg (cs : Commitments) : Prop := ∀ i, 0 ≤ cs.remaining i

theorem total_change (cs : Commitments) (i : Nat) (f : Int → Option Int) :
    (cs.change i f).total = cs.total - cs.remaining i +
      (if cs.isOpen i then (f (cs.remaining i)).getD 0 else 0) := by
  induction cs generalizing i with
  | nil => simp [change, total, remaining, isOpen]
  | cons x xs ih =>
    cases i with
    | zero => cases x <;> simp [change, total, remaining, isOpen] <;> omega
    | succ i => simp only [change, total, remaining, isOpen, ih]; omega

theorem remaining_change_self (cs : Commitments) (i : Nat) (f : Int → Option Int) :
    (cs.change i f).remaining i =
      (if cs.isOpen i then (f (cs.remaining i)).getD 0 else 0) := by
  induction cs generalizing i with
  | nil => simp [change, remaining, isOpen]
  | cons x xs ih =>
    cases i with
    | zero => cases x <;> simp [change, remaining, isOpen]
    | succ i => exact ih i

theorem remaining_change_other (cs : Commitments) (i j : Nat) (f : Int → Option Int)
    (h : j ≠ i) : (cs.change i f).remaining j = cs.remaining j := by
  induction cs generalizing i j with
  | nil => simp [change, remaining]
  | cons x xs ih =>
    cases i <;> cases j <;> simp_all [change, remaining]

theorem isOpen_change_close (cs : Commitments) (i : Nat) :
    (cs.change i (fun _ => none)).isOpen i = false := by
  induction cs generalizing i with
  | nil => rfl
  | cons x xs ih => cases i with
    | zero => cases x <;> rfl
    | succ i => exact ih i

theorem remaining_of_closed (cs : Commitments) (i : Nat) (h : cs.isOpen i = false) :
    cs.remaining i = 0 := by
  induction cs generalizing i with
  | nil => rfl
  | cons x xs ih => cases i with
    | zero => cases x <;> simp_all [isOpen, remaining]
    | succ i => exact ih i h

theorem total_nonneg (cs : Commitments) (h : cs.nonneg) : 0 ≤ cs.total := by
  induction cs with
  | nil => exact Int.le_refl 0
  | cons x xs ih =>
    have hx := h 0
    have ht := ih (fun i => h (i + 1))
    simp only [remaining, total] at *
    omega

theorem total_append (cs : Commitments) (n : Int) :
    (cs ++ [some n]).total = cs.total + n := by
  induction cs with
  | nil => simp [total]
  | cons x xs ih => simp only [List.cons_append, total, ih]; omega

theorem nonneg_append (cs : Commitments) (n : Int) (h : cs.nonneg) (hn : 0 ≤ n) :
    (cs ++ [some n]).nonneg := by
  induction cs with
  | nil => intro i; cases i <;> simp [remaining, hn]
  | cons x xs ih =>
    intro i
    cases i with
    | zero => exact h 0
    | succ i => exact ih (fun j => h (j + 1)) i

theorem nonneg_change (cs : Commitments) (i : Nat) (f : Int → Option Int)
    (h : cs.nonneg) (hf : 0 ≤ (f (cs.remaining i)).getD 0) : (cs.change i f).nonneg := by
  intro j
  by_cases hj : j = i
  · subst j; rw [remaining_change_self]; split <;> omega
  · rw [remaining_change_other cs i j f hj]; exact h j

/-- The disabled ownership clamp drains other slots in allocation order. -/
def drain : Commitments → Int → Commitments
  | [], _ => []
  | none :: xs, n => none :: drain xs n
  | some r :: xs, n =>
    let spent := min n (max r 0)
    some (r - spent) :: drain xs (n - spent)

def pos : Commitments → Int
  | [] => 0
  | x :: xs => max (x.getD 0) 0 + pos xs

theorem pos_nonneg (cs : Commitments) : 0 ≤ cs.pos := by
  induction cs with
  | nil => exact Int.le_refl 0
  | cons x xs ih => simp only [pos]; omega

theorem total_le_pos (cs : Commitments) : cs.total ≤ cs.pos := by
  induction cs with
  | nil => exact Int.le_refl 0
  | cons x xs ih => simp only [pos, total]; omega

theorem drain_total (cs : Commitments) (m : Int) (h0 : 0 ≤ m) (h : m ≤ cs.pos) :
    (cs.drain m).total = cs.total - m := by
  induction cs generalizing m with
  | nil => simp only [pos] at h; simp only [drain, total]; omega
  | cons x xs ih =>
    cases x with
    | none =>
      simp only [pos, Option.getD_none] at h
      simp only [drain, total, Option.getD_none]
      rw [ih m h0 (by omega)]; omega
    | some r =>
      simp only [pos, Option.getD_some] at h
      have hp := pos_nonneg xs
      simp only [drain, total, Option.getD_some]
      rw [ih (m - min m (max r 0)) (by omega) (by omega)]
      omega

theorem drain_nonneg (cs : Commitments) (m : Int) (h0 : 0 ≤ m) (h : cs.nonneg) :
    (cs.drain m).nonneg := by
  induction cs generalizing m with
  | nil => intro i; simp [drain, remaining]
  | cons x xs ih =>
    have hx := h 0
    have hxs : nonneg xs := fun j => h (j + 1)
    cases x with
    | none =>
      intro i
      cases i with
      | zero => simp [drain, remaining]
      | succ i => exact ih m h0 hxs i
    | some r =>
      simp only [remaining, Option.getD_some] at hx
      intro i
      cases i with
      | zero => simp only [drain, remaining, Option.getD_some]; omega
      | succ i => exact ih (m - min m (max r 0)) (by omega) hxs i

theorem pos_change (cs : Commitments) (i : Nat) (f : Int → Option Int) :
    (cs.change i f).pos = cs.pos - max (cs.remaining i) 0 +
      (if cs.isOpen i then max ((f (cs.remaining i)).getD 0) 0 else 0) := by
  induction cs generalizing i with
  | nil => simp [change, pos, remaining, isOpen]
  | cons x xs ih =>
    cases i with
    | zero => cases x <;> simp [change, pos, remaining, isOpen] <;> omega
    | succ i => simp only [change, pos, remaining, isOpen, ih]; omega

theorem total_sub_le (cs : Commitments) (i : Nat) :
    cs.total - cs.remaining i ≤ cs.pos - max (cs.remaining i) 0 := by
  induction cs generalizing i with
  | nil => simp [total, pos, remaining]
  | cons x xs ih =>
    cases i with
    | zero => have := total_le_pos xs; simp only [total, pos, remaining]; omega
    | succ i => have := ih i; simp only [total, pos, remaining]; omega

theorem off_total (cs : Commitments) (i : Nat) (n entry own : Int) (hi : cs.isOpen i = true)
    (he : entry = min n (max cs.total 0)) (ho : own = min entry (max (cs.remaining i) 0)) :
    ((cs.change i (fun r => some (r - own))).drain (entry - own)).total = cs.total - entry := by
  have hpc := pos_change cs i (fun r => some (r - own))
  have htc := total_change cs i (fun r => some (r - own))
  simp only [hi, ite_true, Option.getD_some] at hpc htc
  have hle := total_sub_le cs i
  have hpn := pos_nonneg cs
  have htp := total_le_pos cs
  rw [drain_total _ _ (by omega) (by omega), htc]; omega

def closeAll (cs : Commitments) : Commitments := cs.map (fun _ => none)

theorem closeAll_total (cs : Commitments) : (closeAll cs).total = 0 := by
  induction cs with
  | nil => rfl
  | cons x xs ih =>
    show (none : Option Int).getD 0 + total (closeAll xs) = 0
    rw [ih]; rfl

theorem closeAll_nonneg (cs : Commitments) : nonneg (closeAll cs) := by
  induction cs with
  | nil => intro i; simp [closeAll, remaining]
  | cons x xs ih => intro i; cases i with
    | zero => simp [closeAll, remaining]
    | succ i => exact ih i

end Commitments

/-- The ledger sum, identified commitments, deficiency and earlier authorization read. -/
structure Balances where
  sum         : Int
  commitments : Commitments
  /-- `STO-37`'s `clamped_sats`, summed: the operator's, in satoshis, and not an entry. -/
  deficiency  : Int
  /-- `LDG-35`'s authorization read, as an earlier transaction took it. -/
  snapshot    : Int
  deriving DecidableEq, Repr

/-- `LDG-9`: "Σ(reserved amount of open commitments)", derived rather than stored. -/
@[req "LDG-9"]
def Balances.reserved (b : Balances) : Int := b.commitments.total

/-- `LDG-9`: `available = Σ(ledger entries) − Σ(reserved amount of open commitments)`. -/
@[req "LDG-9"]
def Balances.available (b : Balances) : Int := b.sum - b.reserved

/-- `LDG-31`: "the commitment decrements to zero, the tenant is debited only up to the authority
it granted, and the remainder is recorded as an **operator deficiency**". The entry, and the
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
  | usageDebit (commitment : Nat) (sats : Int)
  | closeCommitment (commitment : Nat)
  deriving DecidableEq, Repr

/-- `LDG-31`: posting a debit "MUST decrement that commitment by the same amount, in one
transaction"; `LDG-9` authorizes by "`available ≥ required_commitment`".
`LDG-32` says "A commitment MUST be closed, and its remaining amount released in full".
The fresh identifier is the list length before an admitted open. A debit on a closed or missing
identifier adds its whole signed amount to deficiency under `clampAtAuthority`, leaving sum and
slots unchanged; without the guard it subtracts the whole debit from sum and leaves slots
unchanged. A close on a closed or missing identifier is inert. -/
@[req "LDG-31"]
def step (g : Guards) (b : Balances) : Event → Balances
  | .topup n => { b with sum := b.sum + n }
  | .read => { b with snapshot := b.available }
  | .openCommitment n =>
    let reserved := if g.allCommitmentsAuthorize then b.reserved else b.commitments.first
    let authorized := if g.serializedAuthorization then b.sum - reserved else b.snapshot
    if n ≤ authorized then { b with commitments := b.commitments ++ [some n] } else b
  | .usageDebit i n =>
    if b.commitments.isOpen i then
      if g.clampAtAuthority then
        let authority := if g.clampOwnCommitment then b.commitments.remaining i else b.reserved
        let (entry, overflow) := clamp authority n
        let cs := if g.clampOwnCommitment then
            b.commitments.change i (fun r => some (r - entry))
          else
            let own := min entry (max (b.commitments.remaining i) 0)
            (b.commitments.change i (fun r => some (r - own))).drain (entry - own)
        { b with sum := b.sum - entry, commitments := cs,
                 deficiency := b.deficiency + overflow }
      else
        { b with sum := b.sum - n,
                 commitments := b.commitments.change i (fun r => some (max (r - n) 0)) }
    else if g.clampAtAuthority then
      { b with deficiency := b.deficiency + n }
    else
      { b with sum := b.sum - n }
  | .closeCommitment i =>
    if b.commitments.isOpen i then
      { b with commitments := if g.closeOwnCommitment then
          b.commitments.change i (fun _ => none) else b.commitments.map (fun _ => none) }
    else b

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

/-- `LDG-31`: "consumption leaves `available` **unchanged**", for every balance and debit.
The authority clamp preserves this equality with either ownership-guard setting. -/
@[req "LDG-31"]
theorem usage_leaves_available_unchanged (g : Guards) (hg : g.clampAtAuthority = true)
    (b : Balances) (i : Nat) (n : Int) :
    (step g b (.usageDebit i n)).available = b.available := by
  cases ho : g.clampOwnCommitment with
  | true =>
    by_cases hi : b.commitments.isOpen i = true
    · simp only [step, hi, hg, ho, ite_true, Balances.available, Balances.reserved,
        Commitments.total_change, clamp, Option.getD_some]; omega
    · simp [step, hi, hg, Balances.available, Balances.reserved]
  | false =>
    by_cases hi : b.commitments.isOpen i = true
    · have h := Commitments.off_total b.commitments i n _ _ hi rfl rfl
      simp only [step, hi, hg, ho, ite_true, Bool.false_eq_true, ite_false, Balances.available,
        Balances.reserved, clamp, h]
      omega
    · simp [step, hi, hg, Balances.available, Balances.reserved]

/-- Every open amount stays nonnegative and therefore so does their sum; deficiency grows by
exactly the unposted amount for any named slot, including closed or missing slots, with
either ownership-guard setting.
The old remainder hypothesis and conclusion become pointwise floors as well as the total floor. -/
@[req "LDG-31"]
theorem usage_clamps_at_zero (g : Guards) (hg : g.clampAtAuthority = true)
    (b : Balances) (i : Nat)
    (n : Int) (hr : b.commitments.nonneg) :
    (step g b (.usageDebit i n)).commitments.nonneg ∧
    0 ≤ (step g b (.usageDebit i n)).reserved ∧
    (step g b (.usageDebit i n)).deficiency - b.deficiency =
      n - (b.sum - (step g b (.usageDebit i n)).sum) := by
  by_cases hi : b.commitments.isOpen i = true
  · cases ho : g.clampOwnCommitment with
    | true =>
      have hf : 0 ≤ b.commitments.remaining i - (clamp (b.commitments.remaining i) n).1 := by
        have := hr i
        simp only [clamp]; omega
      have hp := Commitments.nonneg_change b.commitments i
        (fun r => some (r - (clamp (b.commitments.remaining i) n).1)) hr hf
      simp only [step, hi, hg, ho, ite_true]
      exact ⟨hp, Commitments.total_nonneg _ hp, by simp only [clamp]; omega⟩
    | false =>
      have hri := hr i
      have ht := Commitments.total_nonneg _ hr
      have hc := Commitments.nonneg_change b.commitments i
        (fun r => some (r - min (min n (max b.commitments.total 0)) (max (b.commitments.remaining i) 0)))
        hr (by simp only [Option.getD_some]; omega)
      have hd := Commitments.drain_nonneg _
        (min n (max b.commitments.total 0) -
          min (min n (max b.commitments.total 0)) (max (b.commitments.remaining i) 0)) (by omega) hc
      simp only [step, hi, hg, ho, ite_true, Bool.false_eq_true, ite_false, Balances.reserved, clamp]
      exact ⟨hd, Commitments.total_nonneg _ hd, by omega⟩
  · simp only [step, hi, hg, Bool.false_eq_true, ite_false, ite_true, Balances.reserved]
    exact ⟨hr, Commitments.total_nonneg _ hr, by omega⟩

/-- `LDG-66`: the deficiency "MUST NOT alter any tenant balance" — `available` does not read it. -/
@[req "LDG-66"]
theorem deficiency_is_not_a_balance (b : Balances) (d : Int) :
    ({ b with deficiency := d } : Balances).available = b.available := rfl

/-! ## The release -/

/-- `LDG-32`: "closed, and its remaining amount released in full". With the added own-close
hypothesis, available rises by the named remainder, that slot closes, other remainders are
unchanged, and the derived sum falls by exactly that remainder. -/
@[req "LDG-32"]
theorem close_releases_exact_remainder (g : Guards) (ho : g.closeOwnCommitment = true)
    (b : Balances) (i : Nat) :
    (step g b (.closeCommitment i)).available = b.available + b.commitments.remaining i ∧
    (step g b (.closeCommitment i)).commitments.isOpen i = false ∧
    (∀ j, j ≠ i → (step g b (.closeCommitment i)).commitments.remaining j =
      b.commitments.remaining j) ∧
    (step g b (.closeCommitment i)).reserved = b.reserved - b.commitments.remaining i := by
  by_cases hi : b.commitments.isOpen i = true
  · simp only [step, hi, ho, ite_true]
    have ht := Commitments.total_change b.commitments i (fun _ => none)
    simp only [hi, ite_true, Option.getD_none, Int.add_zero] at ht
    refine ⟨?_, Commitments.isOpen_change_close ..,
      fun j hj => Commitments.remaining_change_other _ i j _ hj, ht⟩
    simp only [Balances.available, Balances.reserved, ht]; omega
  · have hi' : b.commitments.isOpen i = false := Bool.eq_false_iff.mpr hi
    have hr := Commitments.remaining_of_closed _ _ hi'
    simp [step, hi, hr]

/-! ## The authorization -/

/-- `LDG-9`: the open "is the only authorization a create receives". With the added aggregate
hypothesis and serialization, a changed reservation was funded at commit. -/
@[req "LDG-35"]
theorem open_authorized_at_commit (g : Guards) (hg : g.serializedAuthorization = true)
    (ha : g.allCommitmentsAuthorize = true) (b : Balances) (n : Int)
    (h : (step g b (.openCommitment n)).reserved ≠ b.reserved) :
    n ≤ b.available := by
  simp only [step, hg, ha, ite_true] at h
  by_cases hn : n ≤ b.available
  · exact hn
  · change ¬n ≤ b.sum - b.reserved at hn
    simp [hn] at h

/-- What an event must satisfy for `LDG-10` to survive it: the amounts are nonnegative. -/
def Event.nonneg : Event → Prop
  | .topup n | .openCommitment n | .usageDebit _ n => 0 ≤ n
  | .read | .closeCommitment _ => True

/-- `LDG-10`: "A balance MUST NOT go negative, and `available` MUST NOT go negative".
The added aggregate-authorization hypothesis keeps the open funded at commit.
The old scalar floor becomes pointwise nonnegativity plus its sum across each event. -/
@[req "LDG-10"]
theorem floors_preserved (g : Guards) (hc : g.clampAtAuthority = true)
    (hs : g.serializedAuthorization = true) (ha : g.allCommitmentsAuthorize = true)
    (b : Balances) (e : Event) (he : e.nonneg)
    (h : 0 ≤ b.available ∧ b.commitments.nonneg) :
    0 ≤ (step g b e).available ∧ (step g b e).commitments.nonneg ∧
    0 ≤ (step g b e).reserved := by
  cases e with
  | topup n =>
    refine ⟨?_, h.2, Commitments.total_nonneg _ h.2⟩
    simp only [step, Balances.available, Balances.reserved]
    have hav := h.1
    change 0 ≤ b.sum - b.commitments.total at hav
    change 0 ≤ n at he
    omega
  | read => exact ⟨h.1, h.2, Commitments.total_nonneg _ h.2⟩
  | openCommitment n =>
    simp only [step, hs, ha, ite_true]
    split
    · rename_i hn
      have hp := Commitments.nonneg_append b.commitments n h.2 he
      refine ⟨?_, hp, Commitments.total_nonneg _ hp⟩
      simp only [Balances.available, Balances.reserved, Commitments.total_append]
      change n ≤ b.sum - b.commitments.total at hn
      omega
    · exact ⟨h.1, h.2, Commitments.total_nonneg _ h.2⟩
  | usageDebit i n =>
    have hu := usage_leaves_available_unchanged g hc b i n
    have hp := usage_clamps_at_zero g hc b i n h.2
    exact ⟨by rw [hu]; exact h.1, hp.1, hp.2.1⟩
  | closeCommitment i =>
    cases hl : g.closeOwnCommitment with
    | true =>
      have hr := close_releases_exact_remainder g hl b i
      refine ⟨by rw [hr.1]; have := h.1; have := h.2 i; omega, ?_, ?_⟩
      · intro j
        by_cases hj : j = i
        · subst j; rw [Commitments.remaining_of_closed _ _ hr.2.1]; exact Int.le_refl 0
        · rw [hr.2.2.1 j hj]; exact h.2 j
      · rw [hr.2.2.2]
        by_cases hi : b.commitments.isOpen i = true
        · have hp := Commitments.nonneg_change b.commitments i (fun _ => none) h.2 (by simp)
          have ht := Commitments.total_change b.commitments i (fun _ => none)
          simp only [hi, ite_true, Option.getD_none, Int.add_zero] at ht
          change 0 ≤ b.commitments.total - b.commitments.remaining i
          rw [← ht]; exact Commitments.total_nonneg _ hp
        · rw [Commitments.remaining_of_closed _ _ (Bool.eq_false_iff.mpr hi)]
          simpa [Balances.reserved] using Commitments.total_nonneg _ h.2
    | false =>
      by_cases hi : b.commitments.isOpen i = true
      · have ht := Commitments.total_nonneg _ h.2
        have hav := h.1
        simp only [Balances.available, Balances.reserved] at hav
        have hz := Commitments.closeAll_total b.commitments
        have hstep : step g b (.closeCommitment i) =
            { b with commitments := Commitments.closeAll b.commitments } := by
          simp [step, hi, hl, Commitments.closeAll]
        rw [hstep]
        refine ⟨?_, Commitments.closeAll_nonneg _, ?_⟩
        · show 0 ≤ b.sum - (Commitments.closeAll b.commitments).total
          omega
        · show 0 ≤ (Commitments.closeAll b.commitments).total
          omega
      · simp only [step, hi, Bool.false_eq_true, ite_false]
        exact ⟨h.1, h.2, Commitments.total_nonneg _ h.2⟩

/-- The event floors over a whole trace, with the added aggregate-authorization hypothesis and
pointwise image of the old scalar hypothesis; the total floor is retained too. -/
@[req "LDG-10"]
theorem run_floors (g : Guards) (hc : g.clampAtAuthority = true)
    (hs : g.serializedAuthorization = true) (ha : g.allCommitmentsAuthorize = true)
    (b : Balances) (evs : List Event) (he : ∀ e ∈ evs, e.nonneg)
    (h : 0 ≤ b.available ∧ b.commitments.nonneg) :
    0 ≤ (run g b evs).available ∧ (run g b evs).commitments.nonneg ∧
    0 ≤ (run g b evs).reserved := by
  induction evs generalizing b with
  | nil => exact ⟨h.1, h.2, Commitments.total_nonneg _ h.2⟩
  | cons e evs ih =>
    have hp := floors_preserved g hc hs ha b e (he e (List.mem_cons_self ..)) h
    exact ih (step g b e) (fun e' h' => he e' (List.mem_cons_of_mem _ h')) ⟨hp.1, hp.2.1⟩

/-! ## Recovery of the scalar statements on one open commitment

The declarations below recover the pre-revision statements for arbitrary ledger sum, remainder,
deficiency and snapshot, deriving them from the generalized theorems where applicable. The enabled-guard hypotheses are
retained where needed; the sole-slot close agrees with the bulk close in either guard setting.
An event's named identifier remains unrestricted except the debit's sole open slot. -/

def single (sum remaining deficiency snapshot : Int) : Balances :=
  { sum, commitments := [some remaining], deficiency, snapshot }

theorem single_nonneg (sum remaining deficiency snapshot : Int) (hr : 0 ≤ remaining) :
    (single sum remaining deficiency snapshot).commitments.nonneg := by
  intro i
  cases i <;> simp [single, Commitments.remaining, hr]

theorem usage_leaves_available_unchanged_single (g : Guards) (hg : g.clampAtAuthority = true)
    (sum remaining deficiency snapshot n : Int) :
    let b := single sum remaining deficiency snapshot
    (step g b (.usageDebit 0 n)).available = b.available :=
  usage_leaves_available_unchanged g hg _ 0 n

theorem usage_clamps_at_zero_single (g : Guards) (hg : g.clampAtAuthority = true)
    (sum remaining deficiency snapshot n : Int)
    (hr : 0 ≤ (single sum remaining deficiency snapshot).reserved) :
    let b := single sum remaining deficiency snapshot
    0 ≤ (step g b (.usageDebit 0 n)).reserved ∧
    (step g b (.usageDebit 0 n)).deficiency - b.deficiency =
      n - (b.sum - (step g b (.usageDebit 0 n)).sum) := by
  have hp := usage_clamps_at_zero g hg (single sum remaining deficiency snapshot) 0 n
    (single_nonneg _ _ _ _ (by simpa [single, Balances.reserved, Commitments.total] using hr))
  exact hp.2

theorem close_releases_exact_remainder_single (g : Guards)
    (sum remaining deficiency snapshot : Int) :
    let b := single sum remaining deficiency snapshot
    (step g b (.closeCommitment 0)).available = b.available + b.reserved ∧
    (step g b (.closeCommitment 0)).reserved = 0 := by
  cases ho : g.closeOwnCommitment <;>
    simp [step, single, ho, Balances.available, Balances.reserved, Commitments.isOpen,
      Commitments.change, Commitments.total] <;> omega

/-- On a sole open slot, first-slot and aggregate authorization read the same remainder. -/
theorem step_single_allCommitmentsAuthorize (g : Guards)
    (sum remaining deficiency snapshot : Int) (e : Event) :
    step g (single sum remaining deficiency snapshot) e =
      step { g with allCommitmentsAuthorize := true }
        (single sum remaining deficiency snapshot) e := by
  cases e <;> simp [step, single, Balances.reserved, Commitments.total, Commitments.first]

theorem open_authorized_at_commit_single (g : Guards) (hg : g.serializedAuthorization = true)
    (sum remaining deficiency snapshot n : Int)
    (h : (step g (single sum remaining deficiency snapshot) (.openCommitment n)).reserved ≠
      (single sum remaining deficiency snapshot).reserved) :
    n ≤ (single sum remaining deficiency snapshot).available := by
  rw [step_single_allCommitmentsAuthorize] at h
  exact open_authorized_at_commit { g with allCommitmentsAuthorize := true } hg rfl _ n h

theorem floors_preserved_single (g : Guards) (hc : g.clampAtAuthority = true)
    (hs : g.serializedAuthorization = true)
    (sum remaining deficiency snapshot : Int) (e : Event) (he : e.nonneg)
    (h : 0 ≤ (single sum remaining deficiency snapshot).available ∧
         0 ≤ (single sum remaining deficiency snapshot).reserved) :
    let b := single sum remaining deficiency snapshot
    0 ≤ (step g b e).available ∧ 0 ≤ (step g b e).reserved := by
  have hp := floors_preserved { g with allCommitmentsAuthorize := true } hc hs rfl
    (single sum remaining deficiency snapshot) e he
    ⟨h.1, single_nonneg _ _ _ _ (by simpa [single, Balances.reserved, Commitments.total] using h.2)⟩
  dsimp only
  rw [step_single_allCommitmentsAuthorize]
  exact ⟨hp.1, hp.2.2⟩

theorem run_floors_single (g : Guards) (hc : g.clampAtAuthority = true)
    (hs : g.serializedAuthorization = true) (ha : g.allCommitmentsAuthorize = true)
    (sum remaining deficiency snapshot : Int) (evs : List Event) (he : ∀ e ∈ evs, e.nonneg)
    (h : 0 ≤ (single sum remaining deficiency snapshot).available ∧
         0 ≤ (single sum remaining deficiency snapshot).reserved) :
    let b := single sum remaining deficiency snapshot
    0 ≤ (run g b evs).available ∧ 0 ≤ (run g b evs).reserved := by
  have hp := run_floors g hc hs ha (single sum remaining deficiency snapshot) evs he
    ⟨h.1, single_nonneg _ _ _ _ (by simpa [single, Balances.reserved, Commitments.total] using h.2)⟩
  exact ⟨hp.1, hp.2.2⟩

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

/-- `LDG-5`: "**Balance is the sum of entries** and nothing else", over one tenant's `Book`. The
clause's tagged home is `Provisiond.Funding.sumFor`, which filters the ledger to one tenant first;
that module imports this one, so the sum `LDG-70` compares its read against is restated here. -/
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

/-- An append takes the next `seq`, `topSeq + 1`: one way to meet `LDG-6`'s "per-tenant monotonic
sequence number", which also permits gaps. So on every history, whatever order its entries sit in,
the greatest row after an append is the entry appended, and `LDG-70`'s read is that entry's
`balance_after`. -/
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

/-- Under the guard every drift is zero, so `drift_identity` leaves `read − sum` where it
started. -/
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
an append that read a row other than the greatest. The converse does not: a stale row whose
`balance_after` equals the greatest's drifts by nothing, and drifts of opposite sign cancel. -/
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
  if n ≤ read - b.reserved then { b with commitments := b.commitments ++ [some n] } else b

/-- Under the guard, the available balance computed from the read is `LDG-9`'s, for every
`Balances` whose `sum` is the entries' sum. -/
@[req "LDG-70"]
theorem read_available_is_available (g : Guards) (hg : g.appendReadsLatest = true)
    (ps : List Posting) (b : Balances) (hb : b.sum = (Book.empty.run g ps).sum) :
    (Book.empty.run g ps).read - b.reserved = b.available := by
  rw [read_is_sum g hg, ← hb]; rfl

/-- So an open against the read is `step`'s own under `LDG-35`'s serialization, and
`open_authorized_at_commit` and `floors_preserved` apply with their guard hypotheses.
The added aggregate-authorization hypothesis makes the open read all reservations. -/
@[req "LDG-70"]
theorem open_against_read_is_the_serialized_open (g : Guards)
    (ha : g.appendReadsLatest = true) (hs : g.serializedAuthorization = true)
    (hr : g.allCommitmentsAuthorize = true) (ps : List Posting)
    (b : Balances) (hb : b.sum = (Book.empty.run g ps).sum) (n : Int) :
    openAgainst (Book.empty.run g ps).read b n = step g b (.openCommitment n) := by
  simp only [openAgainst, step, hs, hr, ite_true, read_available_is_available g ha ps b hb]
  rfl

/-- The serialized-read equality on one open commitment: first-slot and aggregate authorization
read the same remainder, so either aggregate-authorization setting gives the same open. -/
theorem open_against_read_is_the_serialized_open_single (g : Guards)
    (ha : g.appendReadsLatest = true) (hs : g.serializedAuthorization = true)
    (ps : List Posting)
    (sum remaining deficiency snapshot : Int) (hb : sum = (Book.empty.run g ps).sum) (n : Int) :
    let b := single sum remaining deficiency snapshot
    openAgainst (Book.empty.run g ps).read b n = step g b (.openCommitment n) := by
  dsimp only
  simp [openAgainst, step, hs, single, Balances.reserved, Commitments.total,
    Commitments.first, read_is_sum g ha, ← hb]

/-- `LDG-31`'s native split for a computed positive debit; the caller supplies the clamped
customer debit. The 2026-10-04 guard retains a full native cost on the entry when disabled,
which double-counts the deficiency remainder. The surrounding ledger model still omits native currency rows. The `min` only
makes out-of-domain inputs total; when customer ≤ computed it leaves the formula unchanged. -/
@[req "LDG-31"]
def nativeSplit (g : Guards) (native computed customer : Nat) : Nat × Nat :=
  let entry := min native (native * customer / computed)
  (if g.nativeCostSplit then entry else native, native - entry)

@[req "LDG-31"]
theorem native_cost_is_partitioned (g : Guards) (hg : g.nativeCostSplit = true)
    (n d c : Nat) :
    (nativeSplit g n d c).1 + (nativeSplit g n d c).2 = n := by
  simp only [nativeSplit, hg, ite_true]
  have := Nat.min_le_left n (n * c / d)
  omega

end Provisiond.Ledger
