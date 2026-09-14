import Provisiond.Req
/-! Identity and outcome types every lifecycle model shares.

Each identity is its own structure, never an alias: a fence holding an attempt's id where an
episode's belongs is then a type error rather than a review finding. The two outcome types keep
apart facts the prose keeps apart — `ADR-0022`'s "the commit record is durable and the reply never
arrives", and a provider call that was dispatched, that was applied, and that answered, which are
three facts and not one. -/

namespace Provisiond

structure OperationId where n : Nat deriving DecidableEq, Repr
structure ClaimNumber where n : Nat deriving DecidableEq, Repr
structure EpisodeId where n : Nat deriving DecidableEq, Repr
structure MachineId where n : Nat deriving DecidableEq, Repr
structure TenantId where n : Nat deriving DecidableEq, Repr

/-- What one store transaction did, as the store and the worker each see it. `refused` is a
store error in `OPS-49`'s sense — a `statement_timeout` or `lock_timeout` the store rolled back
and reported, which consumes the bound; the constraint violations and serialization failures
`OPS-49` says "are not store errors and do not consume the bound" are not values of this type.
`committed acked` is the durable commit with the reply received or — `acked = false` — lost in
transport. Acknowledged without committed is not a value of this type: `OPS-49` says "the only
lost reply is a dead transport", after the server decided. -/
inductive StoreOutcome
  | refused
  | committed (acked : Bool)
  deriving DecidableEq, Repr

/-- What one provider call did. `dispatched applied reply`: the request left, the provider did or
did not apply it, and the response arrived (`some`) or was lost (`none`). The worker sees `reply`
only; `applied` is the provider's fact, which is why a lost reply settles nothing as `failed`. -/
inductive ProviderOutcome
  | notDispatched
  | dispatched (applied : Bool) (reply : Option Bool)
  deriving DecidableEq, Repr

end Provisiond
