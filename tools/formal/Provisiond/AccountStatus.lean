import Provisiond.Req
import Provisiond.Tables
/-! `SEC-46`'s table: the states a provider account can be in, over `STO-47`'s `status` column, and
whether each one releases the tenants' commitments. `release` is a total function whose `match`
on the states carries no wildcard, so a state added without a row is a red build, and
`Status.mem_all` enumerates the type for `decide`, as `Provisiond.Tables` does for its keys.

The rule a dated amendment added is `Rules.retainUnlessTerminated`, and `current` carries it
(`ADR-0025`); `Provisiond.Witnesses` holds its refused-with and admitted-without pair. `healthy`
joined the table on 2026-09-02 as a row, not as a rule, and has no field: its arm is the row.

Not modelled: `API-63`'s recording transaction — its order, the gone-writes, the closing
increments, the failed creates and cancellations, the episode closes, the tenant lists and its
contention with admission on the account row — which is `API-63`'s, the gone-write's episode row
being `Provisiond.Fence.goneWrite`'s; `STO-47`'s rules on the row itself, that `terminated` is
write-once, which `source` outranks which, and what the configuration load inserts; the other
readers of the state, `WIR-29`'s catalogue filter and create refusal and `STO-36`'s refusal of an
assignment row; `SEC-46`'s operator deficiency, which is `LDG-66`'s; `SEC-39`'s ceiling on status
recordings; and the Markdown table, which has no rendered region, so `SEC-46` stays authoritative
under `ADR-0025`'s transitional rule. -/

namespace Provisiond.AccountStatus

/-- `STO-47`'s `provider_account_status.status`: "`healthy` | `account_unreachable` |
`credentials_rejected` | `terminated`". -/
inductive Status
  | healthy | accountUnreachable | credentialsRejected | terminated
  deriving DecidableEq, Repr

def Status.all : List Status := [.healthy, .accountUnreachable, .credentialsRejected, .terminated]

theorem Status.mem_all (s : Status) : s ∈ Status.all := by cases s <;> decide

instance {p : Status → Prop} [DecidablePred p] : Decidable (∀ s, p s) :=
  Tables.decidableForallOfList Status.all Status.mem_all p

/-- The rule `SEC-46` gained by dated amendment. -/
structure Rules where
  /-- `SEC-46`'s amendment of 2026-08-13: "Only one of them establishes that billing has stopped,
  and releasing on the other two hands the customer their satoshis back while the operator keeps
  paying for machines that are still running". `false` is the rule before it, which released on
  every loss: `account_unreachable`, `credentials_rejected` and `terminated`. -/
  retainUnlessTerminated : Bool
  deriving DecidableEq, Repr

/-- `SEC-46` as it stands. One field per line: `ci.yml`'s control flips it. -/
@[req "SEC-46"]
def current : Rules := {
    retainUnlessTerminated := true }

/-- `SEC-46`'s *Commitments* column: `terminated` is "**Closed, released in full** (`LDG-32`), in
the transaction that records it", `healthy` is "Untouched", and the two others are **Retained**
under `retainUnlessTerminated` and released without it. -/
@[req "SEC-46"]
def release (r : Rules) : Status → Bool
  | .healthy => false
  | .accountUnreachable => !r.retainUnlessTerminated
  | .credentialsRejected => !r.retainUnlessTerminated
  | .terminated => true

/-- `SEC-46`: "Only one of them establishes that billing has stopped". Decided over every state,
the one that releases is `terminated`. -/
@[req "SEC-46"]
theorem release_iff_terminated (r : Rules) (h : r.retainUnlessTerminated = true) :
    ∀ s, release r s = true ↔ s = .terminated := by
  cases r; cases h; decide

/-- `SEC-46`'s `credentials_rejected` row: "**Retained** — losing the key is not losing the
servers". -/
@[req "SEC-46"]
theorem credentials_rejected_retained (r : Rules) (h : r.retainUnlessTerminated = true) :
    release r .credentialsRejected = false := by
  simp [release, h]

/-- `SEC-46`'s `account_unreachable` row: "**Retained** — the machines are almost certainly still
running and still billing". -/
@[req "SEC-46"]
theorem account_unreachable_retained (r : Rules) (h : r.retainUnlessTerminated = true) :
    release r .accountUnreachable = false := by
  simp [release, h]

/-- `SEC-46`'s `healthy` row, "Nothing observed wrong; the default", is "Untouched" under either
value of the rule. -/
@[req "SEC-46"]
theorem healthy_untouched (r : Rules) : release r .healthy = false := rfl

end Provisiond.AccountStatus
