import Provisiond.Admission
/-! ADR-0034 (2026-10-08, Q10; 2026-10-10, Q20): local settlements and sweep freshness.

The cache model has a sequence of serialized worker claims, not concurrent executions. Enqueue
captures an observation only for the guard-off defect; the guarded path reads the current row.
Cache.reads counts refresh-provider reads, not the sweep's account-list request.
Provider success/failure is an input; no network, clock progress, state payload, or persistence
is proved. A successful complete sweep observation is modeled as a write at its supplied time;
the model does not prove enumeration, scheduling, state payload, persistence or provider behavior.
Authorization and input validation remain Admission's and Wire's. -/
namespace Provisiond.ProviderTraffic

structure Guards where
  reuseFresh : Bool
  checkAtClaim : Bool
  preserveAge : Bool
  successfulOnly : Bool
  reverseDnsNoop : Bool
  establishedOnly : Bool
  invalidatePtr : Bool
  sweepWritesPresent : Bool
  windowAtLeastSweep : Bool
  deriving DecidableEq, Repr

@[req "DOM-8"]
def current : Guards := {
    reuseFresh := true,
    checkAtClaim := true,
    preserveAge := true,
    successfulOnly := true,
    reverseDnsNoop := true,
    establishedOnly := true,
    invalidatePtr := true,
    sweepWritesPresent := true,
    windowAtLeastSweep := true }

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

/-- Startup checks positive durations and the owner window relationship. -/
@[req "DOM-8"]
def validFreshness (g : Guards) (window sweepInterval : Nat) : Bool :=
  0 < window && 0 < sweepInterval && (!g.windowAtLeastSweep || sweepInterval ≤ window)

/-- A complete pass writes the observation of a managed machine it found present. -/
@[req "OPS-32"]
def sweepPresent (g : Guards) (now : Nat) (s : Cache) : Cache :=
  if g.sweepWritesPresent then { s with observed := some now } else s

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

end Provisiond.ProviderTraffic
