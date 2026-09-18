import Provisiond.Types
/-! Reconciliation knowledge: what the system knows about the resource one create ordered, as its
own type, separate from whether the commitment that paid for it is open or closed. `OPS-33`
releases the commitment "even though the operation remains open", so `unknown` with a closed
commitment is a state the model reaches and not one it can mistake for absence
(`release_leaves_knowledge_unchanged`, `released_still_unknown` in the witnesses). `OPS-27`'s
correlator match "is proof that an order landed, not that the resource exists": a search records
`World.orderLanded` and never `observedPresent`, which only a direct read yields
(`search_never_observes`).

`OPS-32`'s absence is three conjuncts, each a `Params` guard: "Only a pass that enumerated the
account completely may record an absence" (`completePassOnly`), "it may record an absence only
about a machine past `PRV-36`'s effective visibility window" (`pastWindowOnly`), and "A missing
machine MUST be re-read directly before its absence is recorded" (`rereadBeforeAbsence`);
`absence_requires_three` is the theorem. The two windows are two fields of `Windows` — `PRV-36`'s
visibility window and `OPS-33`'s negative window — and `Params.absenceWindow` names which one the
sweep reads, because `OPS-32` says "It is `PRV-36`'s window and NOT `OPS-33`'s negative window,
and the two must not be conflated".

What the guards decide: dropping the window guard records a live machine gone on a read taken
inside the listing lag, and dropping the reread guard records a live machine gone on a listing
that pagination moved it off — each stops a meter on a live machine (the witnesses). Dropping
the completeness guard alone stops a live meter only on a trace `PRV-36` excludes: with the
reread and the window in force, `absence_needs_reread_past_window` shows the sweep records
absence only on a `not_found` read past the window, whatever the pass did, and the model admits
that read on a live machine — `absence_sound` rules it out by the named hypothesis `hRead`, not
by anything the model computes. So the completeness guard's independent force is the sentence
`OPS-32`'s 2026-08-31 amendment carries, "it MUST yield to `rate_limited` rather than retrying
into it": the listing "narrows the candidates", an interrupted listing narrows nothing, and
without the guard the engine rereads into the throttle that interrupted it
(`World.retriedIntoThrottle`). `pv-vwe.5`'s criterion asked for a stopped meter on each dropped
conjunct; this is the one it does not get, and why.

One machine, one provider account, one operation, one engine. Time advances by `Event.advance`
only; the provider's fact `World.live` is fixed for a trace, so a machine the provider terminated
is a trace whose `live` is `false` throughout — the model does not date the deletion. What the
model omits: `OPS-27`'s search-authoritative absent row and its matched-and-gone read, both an
absence about an operation with no machine record (the sweep here records absence about a machine
record only) and its unresolved row, the escalation to an operator; `OPS-36`'s routing of a late
attach through exhaustion (`Provisiond.Fence`) and `OPS-32`'s "A machine with no create of its own
has no window at all" — both windows here run from the one create's dispatch; `PRV-36`'s
"`OPS-27`'s resolution MUST NOT take its first read before the window has elapsed" — a `found`
read is evidence at any time and the model takes it at any time; `OPS-32`'s "what it observed
*present* it may still record", `STO-48`'s observation instant on a listed machine; the
gone-write's episode close and fence clear (`Provisiond.Fence`'s `gone`); `STO-54`'s two-pass rule
after a restore (`Provisiond.Restore`); the imported-image and key sweeps; the unrecorded-machine
report; `OPS-36`'s funding of the cancel, "bounded by the wind-down floor" — the model opens
nothing; and the provider's `rate_limited` answer to a read — a read the engine issues while
throttled is recorded as issued, not answered. -/

namespace Provisiond.Reconcile

structure ProviderAccount where n : Nat deriving DecidableEq, Repr
structure ExternalId where n : Nat deriving DecidableEq, Repr

/-- A resource as one channel's search or one listing names it: `OPS-32`'s
`(provider_account, external_id)`. The same resource reported on two channels is one candidate,
because this is its identity. -/
structure Candidate where
  account    : ProviderAccount
  externalId : ExternalId
  deriving DecidableEq, Repr

/-- What the system knows about the resource. Not the operation's status, and not the
commitment's: `OPS-33` closes the commitment on `unknown`, and `OPS-3`'s `needs_reconciliation`
is the operation's state while this is `unknown`. -/
inductive Knowledge
  | unknown
  | observedPresent (c : Candidate)
  | authoritativeAbsence
  | multipleCandidates (cs : List Candidate)
  deriving DecidableEq, Repr

def Knowledge.isDuplicate : Knowledge → Bool
  | .multipleCandidates _ => true
  | _ => false

/-- `OPS-33`'s subject, "a negative search": no resource established. -/
def Knowledge.isNegative : Knowledge → Bool
  | .unknown | .multipleCandidates _ => true
  | .observedPresent _ | .authoritativeAbsence => false

/-- The commitment `OPS-33` releases — "closed and released in full"; `LDG-32` owns the release
on every terminal outcome. -/
inductive Commitment
  | open
  | closed
  deriving DecidableEq, Repr

/-- Two windows, two fields. `visibility` is `PRV-36`'s effective window, "`max(declared,
max(observed))`", listing lag in seconds, "measured from the dispatch of the create that produced
its `external_id`" (`OPS-32`); `negative` is `OPS-33`'s bounded negative window, "derived per
provider from that provider's own allocation behaviour", whose origin `OPS-33` leaves unstated —
the model starts both at the dispatch. -/
structure Windows where
  visibility : Nat
  negative   : Nat
  deriving DecidableEq, Repr

/-- Which window a rule reads. -/
inductive WindowField
  | visibility
  | negative
  deriving DecidableEq, Repr

def Windows.get (ws : Windows) : WindowField → Nat
  | .visibility => ws.visibility
  | .negative   => ws.negative

/-- A direct read of a candidate, `PRV-12`'s *get machine*. -/
inductive Answer
  | found
  | notFound
  deriving DecidableEq, Repr

/-- The dated amendments this module carries. `completePassOnly`: `OPS-32`, 2026-09-02, "Only a
pass that enumerated the account completely may record an absence". `pastWindowOnly`: `OPS-32`,
2026-09-04, "it may record an absence only about a machine past `PRV-36`'s effective visibility
window". `rereadBeforeAbsence`: `OPS-32`, 2026-09-04, "A missing machine MUST be re-read directly
before its absence is recorded". `absenceWindow`: `OPS-32`, 2026-09-04, "It is `PRV-36`'s window
and NOT `OPS-33`'s negative window" — a prohibition rather than a withdrawn draft, carried as a
guard because the bead asks that "never one" be checkable, and
`negative_window_bills_the_gone_machine` is what checks it. `readConfirmsMatch`: `OPS-27`,
2026-09-05, "the first row MUST be confirmed by a direct read before it attaches anything". -/
structure Params where
  completePassOnly    : Bool
  pastWindowOnly      : Bool
  rereadBeforeAbsence : Bool
  absenceWindow       : WindowField
  readConfirmsMatch   : Bool
  deriving DecidableEq, Repr

/-- The sweep and the search as they stand, tagged to the sweep's own requirement though one
field is `OPS-27`'s. One field per line: `ci.yml`'s controls flip one each. -/
@[req "OPS-32"]
def current : Params := {
    completePassOnly    := true,
    pastWindowOnly      := true,
    rereadBeforeAbsence := true,
    absenceWindow       := .visibility,
    readConfirmsMatch   := true }

structure World where
  now          : Nat
  /-- The dispatch of the create that produced the `external_id`: both windows start here. -/
  dispatchedAt : Nat
  windows      : Windows
  /-- The provider's fact: the machine exists. Not in the store. -/
  live         : Bool
  knowledge    : Knowledge
  commitment   : Commitment
  /-- `OPS-27`'s match: the order landed, on this candidate. -/
  orderLanded  : Option Candidate
  /-- `OPS-32` yielded to `rate_limited` on its last pass, and the throttle has not lifted. -/
  throttled    : Bool
  /-- A read the engine issued while throttled: "retrying into it". -/
  retriedIntoThrottle : Bool
  /-- `LDG-74`: "Billing stops at the observation instant". -/
  meterStoppedAt : Option Nat
  deriving DecidableEq, Repr

/-- `OPS-33`'s negative window has elapsed. -/
def World.negativeElapsed (w : World) : Bool :=
  decide (w.dispatchedAt + w.windows.negative ≤ w.now)

/-- The window the sweep reads has elapsed. -/
def pastWindow (p : Params) (w : World) : Bool :=
  decide (w.dispatchedAt + w.windows.get p.absenceWindow ≤ w.now)

/-- `OPS-27`: "takes the union of what those searches return". The union, so the same resource on
two channels is one candidate. -/
def union (channels : List (List Candidate)) : List Candidate :=
  channels.foldl (fun acc ch => ch.foldl (fun acc c => if c ∈ acc then acc else acc ++ [c]) acc) []

inductive Event
  | advance (d : Nat)
  /-- `OPS-33`: the engine releases the commitment once the negative window has elapsed — of "a
  negative search", so on `unknown` or, "which applies here too", on the duplicate; never a
  machine's running commitment. -/
  | release
  /-- `OPS-27`: the correlator searched on every channel, each channel's result as given. -/
  | search (channels : List (List Candidate))
  /-- The direct read that confirms a match, with the provider's answer. -/
  | read (a : Answer)
  /-- `OPS-32`'s pass: complete or interrupted, the machine listed or not, and the provider's
  answer to the reread the pass issues for a candidate. -/
  | sweep (complete listed : Bool) (a : Answer)
  deriving DecidableEq, Repr

/-- The sweep on a machine record. The listing narrows the candidates — an unlisted machine on a
complete pass, or on any pass without the completeness guard; the engine rereads each candidate;
the reread's `not_found` is the evidence where the reread guard holds, the listing's omission
where it does not; the record needs the window and the completeness the guards demand. -/
@[req "OPS-32"]
def sweepStep (p : Params) (w : World) (complete listed : Bool) (a : Answer) : World :=
  let candidate := !listed && (complete || !p.completePassOnly)
  let evidence  := if p.rereadBeforeAbsence then candidate && a = .notFound else !listed
  let record    := evidence && (!p.pastWindowOnly || pastWindow p w)
                   && (!p.completePassOnly || complete)
  { w with throttled := !complete,
           retriedIntoThrottle := w.retriedIntoThrottle || (candidate && !complete),
           knowledge := if record then .authoritativeAbsence else w.knowledge,
           commitment := if record then .closed else w.commitment,
           meterStoppedAt := if record then some w.now else w.meterStoppedAt }

@[req "OPS-27"]
def searchStep (p : Params) (w : World) (channels : List (List Candidate)) : World :=
  match union channels with
  | []  => w
  | [c] => if p.readConfirmsMatch then { w with orderLanded := some c }
           else { w with knowledge := .observedPresent c }
  | cs  => { w with knowledge := .multipleCandidates cs }

def step (p : Params) (w : World) : Event → World
  | .advance d => { w with now := w.now + d, throttled := false }
  | .release =>
    if w.negativeElapsed && w.knowledge.isNegative then { w with commitment := .closed } else w
  | .search channels =>
    match w.knowledge with
    | .unknown => searchStep p w channels
    | _ => w
  | .read a =>
    match w.knowledge, w.orderLanded, a with
    | .unknown, some c, .found => { w with knowledge := .observedPresent c }
    | _, _, _ => w
  | .sweep complete listed a =>
    match w.knowledge with
    | .observedPresent _ => sweepStep p w complete listed a
    | _ => w

def run (p : Params) (w : World) (evs : List Event) : World := evs.foldl (step p) w

/-! ## Release and knowledge are separate -/

/-- `OPS-33`: "the commitment MUST be closed and released in full even though the operation
remains open". The release changes what the system knows about the resource not at all, on every
world. -/
@[req "OPS-33"]
theorem release_leaves_knowledge_unchanged (p : Params) (w : World) :
    (step p w .release).knowledge = w.knowledge := by
  simp only [step]; split <;> rfl

/-- The release reads the negative window and the subject, and nothing else: a running
machine's commitment is `OPS-27`'s first row's, not a negative search's. -/
@[req "OPS-33"]
theorem release_on_negative_window (p : Params) (w : World) (h : w.commitment = .open) :
    (step p w .release).commitment = .closed ↔
      w.negativeElapsed = true ∧ w.knowledge.isNegative = true := by
  simp only [step]; split <;> simp_all

/-- `OPS-36`: "the system MUST NOT open a fresh commitment sized to keep the machine running".
No event reopens a closed one; the wind-down funding `OPS-36` does require is omitted, above. -/
@[req "OPS-36"]
theorem closed_is_absorbing (p : Params) (w : World) (e : Event) (h : w.commitment = .closed) :
    (step p w e).commitment = .closed := by
  cases e with
  | advance d => exact h
  | release => simp only [step]; split <;> simp [h]
  | search channels =>
    simp only [step]
    split
    · simp only [searchStep]; split <;> (try split) <;> simp [h]
    · exact h
  | read a => simp only [step]; split <;> simp [h]
  | sweep complete listed a =>
    simp only [step]
    split
    · simp only [sweepStep]; split <;> simp [h]
    · exact h

/-! ## A match is not an observation -/

/-- `OPS-27`: "A correlator match is proof that an order landed, not that the resource exists".
With the confirming read, a search leaves `observedPresent` reachable by no search: what a search
observes present was observed present before it. -/
@[req "OPS-27"]
theorem search_never_observes (p : Params) (hp : p.readConfirmsMatch = true) (w : World)
    (channels : List (List Candidate)) (c : Candidate)
    (h : (step p w (.search channels)).knowledge = .observedPresent c) :
    w.knowledge = .observedPresent c := by
  simp only [step] at h
  split at h
  · simp only [searchStep, hp] at h
    split at h <;> simp_all
  · exact h

/-! ## Absence is three conjuncts -/

/-- `OPS-32`, with its three guards: the one step that records an absence is a complete pass that
did not list the machine, whose reread answered `not_found`, past the window. -/
@[req "OPS-32"]
theorem absence_requires_three (p : Params) (h1 : p.completePassOnly = true)
    (h2 : p.pastWindowOnly = true) (h3 : p.rereadBeforeAbsence = true) (w : World) (e : Event)
    (h0 : w.knowledge ≠ .authoritativeAbsence)
    (h : (step p w e).knowledge = .authoritativeAbsence) :
    e = .sweep true false .notFound ∧ pastWindow p w = true := by
  cases e with
  | advance d => exact absurd h h0
  | release => rw [release_leaves_knowledge_unchanged] at h; exact absurd h h0
  | search channels =>
    simp only [step] at h
    split at h
    · simp only [searchStep] at h; split at h <;> (try split at h) <;> simp_all
    · exact absurd h h0
  | read a => simp only [step] at h; split at h <;> simp_all
  | sweep complete listed a =>
    simp only [step] at h
    split at h
    · simp only [sweepStep, h1, h2, h3] at h
      cases complete <;> cases listed <;> cases a <;> simp_all
    · exact absurd h h0

/-- The window and the reread alone: an absence is recorded on a `not_found` reread past the
window, whatever the pass did. This is why the completeness guard stops no meter by itself — a
reread past `PRV-36`'s window is authoritative — and why its own witness is the throttle. -/
@[req "OPS-32"]
theorem absence_needs_reread_past_window (p : Params) (h2 : p.pastWindowOnly = true)
    (h3 : p.rereadBeforeAbsence = true) (w : World) (complete listed : Bool) (a : Answer)
    (h0 : w.knowledge ≠ .authoritativeAbsence)
    (h : (step p w (.sweep complete listed a)).knowledge = .authoritativeAbsence) :
    listed = false ∧ a = .notFound ∧ pastWindow p w = true := by
  simp only [step] at h
  split at h
  · simp only [sweepStep, h2, h3] at h
    cases complete <;> cases listed <;> cases a <;> simp_all
  · exact absurd h h0

/-- `PRV-36`, "A read of provider state is not authoritative about a mutation the driver issued
until that provider's effective visibility window has elapsed", as the hypothesis `hRead`: past
the window, a `not_found` read is the provider's fact. Under it, an absence the sweep records is
about a machine that is gone. -/
@[req "PRV-36"]
theorem absence_sound (p : Params) (h2 : p.pastWindowOnly = true)
    (h3 : p.rereadBeforeAbsence = true) (w : World) (complete listed : Bool) (a : Answer)
    (hRead : pastWindow p w = true → a = .notFound → w.live = false)
    (h0 : w.knowledge ≠ .authoritativeAbsence)
    (h : (step p w (.sweep complete listed a)).knowledge = .authoritativeAbsence) :
    w.live = false :=
  have ⟨_, ha, hw⟩ := absence_needs_reread_past_window p h2 h3 w complete listed a h0 h
  hRead hw ha

/-- `OPS-32`: "An interrupted pass MUST record nothing about absence", and — the guard's own
force — issues no reread into the throttle that interrupted it. -/
@[req "OPS-32"]
theorem interrupted_pass_records_nothing (p : Params) (h1 : p.completePassOnly = true)
    (w : World) (listed : Bool) (a : Answer) :
    (step p w (.sweep false listed a)).knowledge = w.knowledge ∧
    (step p w (.sweep false listed a)).retriedIntoThrottle = w.retriedIntoThrottle := by
  simp only [step]
  split
  · simp only [sweepStep, h1]; cases listed <;> cases a <;> simp_all
  · exact ⟨rfl, rfl⟩

end Provisiond.Reconcile
