import Provisiond.Req
/-! `LDG-9`'s available balance and the conservation laws around one tenant's one commitment, in
whole satoshis: `LDG-31`'s pairing with its clamp, `LDG-32`'s release of the exact remainder,
`LDG-35`'s authorization read against the commit that follows it, and `LDG-10`'s floor.

The operator deficiency `LDG-31`'s clamp writes is `Balances.deficiency`, a running satoshi total
the balance never reads: `LDG-66` says it "is NOT a ledger entry" and "MUST NOT alter any tenant
balance", and `deficiency_is_not_a_balance` is that sentence. `STO-37`'s record — the cause, the
native amount, the absorbed seconds — is `Provisiond.Funding.Deficiency`; here only the satoshi
figure `clamped_sats` is carried, in the unit the clamp arose in.

Two guards, each carried as a parameter so that the alternative the text forbids is a one-token
change with a witness. `clampAtAuthority`: `LDG-31`'s clamp paragraph, "the tenant is debited only
up to the authority it granted, and the remainder is recorded as an operator deficiency"; the
remainder "MUST NOT be taken from available balance", which without the clamp it is — "the
automatic seizure `ADR-0011` exists to forbid". (The dated amendment beside it, 2026-09-02, is the
pairing rule's "has no exception"; the clamp paragraph itself is undated.) `serializedAuthorization`:
`LDG-35`, "The authorization read and the commitment write MUST be serialized per tenant" — the
primitive was chosen on 2026-09-06 (`ADR-0015`), the rule is undated; without it the open
authorizes against `snapshot`, the balance an earlier transaction read — "two transactions can
each read the same balance and each commit, leaving twice the balance reserved". Both witnesses
are in `Provisiond.Witnesses`.

What the model omits: more than one commitment (`Provisiond.Funding` carries the one metered
subject's); the fee kinds `LDG-31` also pairs, which route through `clamp` the same way; the
concurrency `LDG-35` orders, modelled as one stale read and not as two interleaved transactions;
the `version` of `STO-28`'s conditional write. -/

namespace Provisiond.Ledger

structure Guards where
  clampAtAuthority        : Bool
  serializedAuthorization : Bool
  deriving DecidableEq, Repr

/-- The rules as they stand. One field per line: `ci.yml`'s controls flip one each. -/
@[req "LDG-31"]
def current : Guards := {
    clampAtAuthority        := true,
    serializedAuthorization := true }

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

end Provisiond.Ledger
