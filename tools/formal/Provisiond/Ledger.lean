import Provisiond.Req
/-! `LDG-9`'s available balance and `LDG-31`'s pairing rule, as far as `LDG-31`'s worked table
reaches: one tenant, one commitment, whole satoshis, and no clamp — `LDG-31`'s "decrement clamps
at zero" is not modelled here, and M6 (funding and the tenant lifecycle) is where the ledger grows
past this. -/

namespace Provisiond.Ledger

/-- The two sums `LDG-9` subtracts. -/
structure Balances where
  sum      : Int
  reserved : Int
  deriving DecidableEq, Repr

/-- `LDG-9`: `available = Σ(ledger entries) − Σ(reserved amount of open commitments)`. -/
@[req "LDG-9"]
def Balances.available (b : Balances) : Int := b.sum - b.reserved

/-- The four events `LDG-31`'s table walks. -/
inductive Event
  | topup (sats : Int)
  | openCommitment (sats : Int)
  | usageDebit (sats : Int)
  | closeCommitment
  deriving DecidableEq, Repr

/-- `LDG-31`: posting a debit "MUST decrement that commitment by the same amount, in one
transaction" — the one step that moves both sums. A close releases the one commitment in full
(`LDG-32`). -/
@[req "LDG-31"]
def step (b : Balances) : Event → Balances
  | .topup n => { b with sum := b.sum + n }
  | .openCommitment n => { b with reserved := b.reserved + n }
  | .usageDebit n => { sum := b.sum - n, reserved := b.reserved - n }
  | .closeCommitment => { b with reserved := 0 }

/-- `LDG-31`: "consumption leaves `available` **unchanged**", for every balance and every debit. -/
@[req "LDG-31"]
theorem usage_leaves_available_unchanged (b : Balances) (n : Int) :
    (step b (.usageDebit n)).available = b.available := by
  simp [step, Balances.available]; omega

end Provisiond.Ledger
