import Provisiond.Admission
/-! ADR-0034 (2026-10-08), including Q10: local settlements and provider request admission.

The cache model has a sequence of serialized worker claims, not concurrent executions. Enqueue
captures an observation only for the guard-off defect; the guarded path reads the current row.
Provider success/failure is an input; no network, clock progress, state payload, or persistence
is proved. Authorization and validation precede these functions and remain Admission's and Wire's.

The budget model covers one declared period, with no refill or external traffic. Scope, operation
identity and origin are immutable request facts; the caller cannot change them between requests.
Usage and admission are produced by dispatch transitions, not supplied as verdicts. Reserve is a
whole-request count. Remaining capacity uses integers so admitted continuations can be accounted
for even beyond the effective limit. Configuration validation,
provider enforcement, crash durability and system scheduling remain implementation obligations.
Accounting may exceed capacity for already admitted operations: the model asserts no provider
acceptance and invents no local mid-operation refusal. The order budget is untouched. -/
namespace Provisiond.ProviderTraffic

structure Guards where
  reuseFresh : Bool
  checkAtClaim : Bool
  preserveAge : Bool
  successfulOnly : Bool
  reverseDnsNoop : Bool
  establishedOnly : Bool
  invalidatePtr : Bool
  sharedScope : Bool
  protectReserve : Bool
  admitOnce : Bool
  accountEveryRequest : Bool
  deriving DecidableEq, Repr

@[req "PRV-46"]
def current : Guards := {
    reuseFresh := true,
    checkAtClaim := true,
    preserveAge := true,
    successfulOnly := true,
    reverseDnsNoop := true,
    establishedOnly := true,
    invalidatePtr := true,
    sharedScope := true,
    protectReserve := true,
    admitOnce := true,
    accountEveryRequest := true }

structure Cache where
  observed : Option Nat := none
  reads : Nat := 0
  succeeded : Bool := false
  deriving DecidableEq, Repr

@[req "DOM-8"]
def fresh (observed : Option Nat) (now window : Nat) : Bool :=
  match observed with
  | none => false
  | some observedAt => observedAt ≤ now && now - observedAt < window

/-- DOM-8: the queue's observation is ignored when the claim-time guard is enabled. -/
@[req "DOM-8"]
def claimRefresh (g : Guards) (window now : Nat) (atEnqueue : Option Nat)
    (providerAnswers : Bool) (s : Cache) : Cache :=
  if g.reuseFresh && fresh (if g.checkAtClaim then s.observed else atEnqueue) now window then
    { s with succeeded := true, observed := if g.preserveAge then s.observed else some now }
  else
    { observed := if providerAnswers || !g.successfulOnly then some now else s.observed
      reads := s.reads + 1, succeeded := providerAnswers }

@[req "DOM-8"]
theorem fresh_claim_reuses (g : Guards) (window now : Nat) (queued : Option Nat)
    (answer : Bool) (s : Cache) (hr : g.reuseFresh = true) (hc : g.checkAtClaim = true)
    (hp : g.preserveAge = true) (hf : fresh s.observed now window = true) :
    claimRefresh g window now queued answer s = { s with succeeded := true } := by
  simp [claimRefresh, hr, hc, hp, hf]

@[req "DOM-8"]
theorem failed_read_preserves_age (g : Guards) (window now : Nat) (queued : Option Nat)
    (s : Cache) (hc : g.checkAtClaim = true) (hs : g.successfulOnly = true)
    (hf : fresh s.observed now window = false) :
    (claimRefresh g window now queued false s).observed = s.observed ∧
    (claimRefresh g window now queued false s).succeeded = false := by
  simp [claimRefresh, hc, hs, hf]

/-- A per-address entry: provider evidence establishes it; mere requested text does not.
Invalidation before a differing dispatch is represented by clearing established. -/
structure Ptr where
  value : String
  established : Bool
  deriving DecidableEq, Repr

@[req "PRV-25"]
def ptrNoop (g : Guards) (record : Option Ptr) (requested : String) : Bool :=
  g.reverseDnsNoop && match record with
    | none => false
    | some p => (p.established || !g.establishedOnly) && p.value == requested

@[req "PRV-25"]
def beforePtrDispatch (g : Guards) (record : Option Ptr) : Option Ptr :=
  if g.invalidatePtr then record.map fun p => { p with established := false } else record

@[req "PRV-25"]
theorem invalidated_is_not_noop (g : Guards) (he : g.establishedOnly = true)
    (hi : g.invalidatePtr = true) (record : Option Ptr) (requested : String) :
    ptrNoop g (beforePtrDispatch g record) requested = false := by
  cases record <;> simp [ptrNoop, beforePtrDispatch, he, hi]

inductive Origin
  | tenant (id : Nat) | fundingCancellation | systemEpisode | automaticResolution | accountSweep
  deriving DecidableEq, Repr

structure Request where
  operation : Nat
  scope : Nat
  origin : Origin
  deriving DecidableEq, Repr

structure Budget where
  limit : Nat
  reserve : Nat
  deriving DecidableEq, Repr

structure Usage where
  scope : Nat
  tenant : Option Nat
  deriving DecidableEq, Repr

structure Traffic where
  spent : List Usage := []
  admitted : List Request := []
  calls : Nat := 0
  alarms : List Nat := []
  deriving DecidableEq, Repr

@[req "PRV-46"]
def usageKey (g : Guards) (r : Request) : Usage :=
  { scope := r.scope, tenant := if g.sharedScope then none else
      match r.origin with | .tenant id => some id | _ => none }

@[req "PRV-46"]
def remaining (g : Guards) (b : Budget) (r : Request) (s : Traffic) : Int :=
  (b.limit : Int) - ((s.spent.filter (· == usageKey g r)).length : Int)

@[req "PRV-46"]
def tenantOrigin : Origin → Bool
  | .tenant _ => true
  | .fundingCancellation | .systemEpisode | .automaticResolution | .accountSweep => false

/-- A request is considered immediately before dispatch. A refusal has no dispatch effect;
continuations are recognized from the earlier transition's stored admission. -/
@[req "PRV-46"]
def dispatch (g : Guards) (b : Budget) (r : Request) (s : Traffic) : Traffic :=
  let left := remaining g b r s
  let exhausted := left ≤ (b.reserve : Int)
  let continuing := g.admitOnce && s.admitted.contains r
  if !continuing && tenantOrigin r.origin && g.protectReserve && exhausted then
    { s with alarms := r.scope :: s.alarms }
  else
    let spent := if g.accountEveryRequest then usageKey g r :: s.spent else s.spent
    let next := { s with spent := spent, admitted := r :: s.admitted, calls := s.calls + 1 }
    if left > (b.reserve : Int) && remaining g b r next ≤ (b.reserve : Int) then
      { next with alarms := r.scope :: next.alarms }
    else next

@[req "PRV-46"]
theorem reserve_refuses_new_tenant (g : Guards) (b : Budget) (r : Request) (s : Traffic)
    (hg : g.protectReserve = true) (ht : tenantOrigin r.origin = true)
    (hn : s.admitted.contains r = false) (hr : remaining g b r s ≤ (b.reserve : Int)) :
    (dispatch g b r s).calls = s.calls := by
  have hn' : r ∉ s.admitted := by simpa using hn
  simp [dispatch, hg, ht, hn', hr]

@[req "PRV-46"]
theorem admitted_request_continues (g : Guards) (b : Budget) (r : Request) (s : Traffic)
    (hg : g.admitOnce = true) (ha : s.admitted.contains r = true) :
    (dispatch g b r s).calls = s.calls + 1 := by
  have ha' : r ∈ s.admitted := by simpa using ha
  simp [dispatch, hg, ha']
  split <;> split <;> rfl

@[req "PRV-46"]
theorem system_path_retains_access (g : Guards) (b : Budget) (r : Request) (s : Traffic)
    (hs : tenantOrigin r.origin = false) :
    (dispatch g b r s).calls = s.calls + 1 := by
  simp [dispatch, hs]
  split <;> split <;> rfl

end Provisiond.ProviderTraffic
