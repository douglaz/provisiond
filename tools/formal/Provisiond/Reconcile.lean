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
`absence_requires_three` is the theorem, with `successfulConfirmationOnly` enabled for
`OPS-32`'s "a failed direct absence confirmation cannot record absence".
`visibilityUsesObserved` computes the effective visibility maximum from supplied samples.
`Windows` carries the inputs for `PRV-36`'s visibility window and the separate `OPS-33`
negative window — and `Params.absenceWindow` names which one the
sweep reads, because `OPS-32` says "It is `PRV-36`'s window and NOT `OPS-33`'s negative window,
and the two must not be conflated". `Params.visibilityFromWaitEnd` selects the amended
visibility origin; the negative window still reads `dispatchedAt`.

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
has no window at all" — the model's negative window runs from the one create's dispatch and
its visibility window from that call's wait end; `PRV-36`'s
"`OPS-27`'s resolution MUST NOT take its first read before the window has elapsed" — a `found`
read is evidence at any time and the model takes it at any time; `OPS-32`'s "what it observed
*present* it may still record", `STO-48`'s observation instant on a listed machine; the
gone-write's episode close and fence clear (`Provisiond.Fence`'s `gone`); `STO-54`'s two-pass rule
after a restore (`Provisiond.Restore`); the imported-image and key sweeps; the unrecorded-machine
report; `OPS-36`'s funding of the cancel, "bounded by the wind-down floor" — the model opens
nothing, including `LDG-40`'s 2026-10-04 no-rate attach branch and its deficiency records;
and the provider's `rate_limited` answer to a read — a read the engine issues while
throttled is recorded as issued, not answered. `ADR-0035` adds the provider-evidence input
`matchedOrderInProgress` solely to exclude that case from negative-window release; order
completion and the negative window's origin after completion are not modelled. -/

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

/-- Visibility inputs and a separate negative window. `PRV-36`'s effective window is
"`max(declared, max(observed))`": `declaredVisibility` and supplied `observedVisibility`
durations feed `effectiveVisibility`, listing lag in seconds, measured after the create
call's wait ends
(`OPS-32`); `negative` is `OPS-33`'s bounded negative window, "derived per
provider from that provider's own allocation behaviour", whose origin `OPS-33` leaves unstated —
the model starts the negative window at dispatch. A matched in-progress order is excluded by
`negativeOnly`; the model does not choose a new window origin after it finishes. -/
structure Windows where
  declaredVisibility : Nat
  observedVisibility : List Nat := []
  negative   : Nat
  deriving DecidableEq, Repr

/-- Which window a rule reads. -/
inductive WindowField
  | visibility
  | negative
  deriving DecidableEq, Repr

/-- `PRV-36`: "the effective window is `max(declared, max(observed))`". Samples are given
inputs; the `STO-53` sample write path remains outside this model. Their maximum does not
prove a bound on future provider behaviour. With the guard off, use the declaration alone. -/
@[req "PRV-36"]
def Windows.effectiveVisibility (ws : Windows) (useObserved : Bool) : Nat :=
  if useObserved then max ws.declaredVisibility (ws.observedVisibility.foldr max 0)
  else ws.declaredVisibility

def Windows.get (ws : Windows) (useObserved : Bool) : WindowField → Nat
  | .visibility => ws.effectiveVisibility useObserved
  | .negative   => ws.negative

/-- A direct read of a candidate, `PRV-12`'s *get machine*. -/
inductive Answer
  | found
  | notFound
  | failed
  deriving DecidableEq, Repr

/-- The dated amendments this module carries. `completePassOnly`: `OPS-32`, 2026-09-02, "Only a
pass that enumerated the account completely may record an absence". `pastWindowOnly`: `OPS-32`,
2026-09-04, "it may record an absence only about a machine past `PRV-36`'s effective visibility
window". `rereadBeforeAbsence`: `OPS-32`, 2026-09-04, "A missing machine MUST be re-read directly
before its absence is recorded". `absenceWindow`: `OPS-32`, 2026-09-04, "It is `PRV-36`'s window
and NOT `OPS-33`'s negative window" — a prohibition rather than a withdrawn draft, carried as a
guard because the bead asks that "never one" be checkable, and
`negative_window_bills_the_gone_machine` is what checks it. `readConfirmsMatch`: `OPS-27`,
2026-09-05, "the first row MUST be confirmed by a direct read before it attaches anything".
`negativeOnly`: `OPS-33`, 2026-10-08 (`ADR-0035`), "the negative window MUST NOT run against a
matched order that is still in progress". `visibilityFromWaitEnd`: `PRV-36`, 2026-10-09
(`ADR-0037`, Q13), visibility begins at the end of the mutating call's wait.
`visibilityUsesObserved`: `PRV-36`, 2026-09-08 (`ADR-0018`), "the effective window
is `max(declared, max(observed))`". `successfulConfirmationOnly`: `OPS-32`, 2026-10-10
(`ADR-0034`, Q20), "a failed direct absence confirmation cannot record absence". -/
structure Params where
  completePassOnly    : Bool
  pastWindowOnly      : Bool
  rereadBeforeAbsence : Bool
  absenceWindow       : WindowField
  readConfirmsMatch   : Bool
  negativeOnly       : Bool
  visibilityFromWaitEnd : Bool
  visibilityUsesObserved : Bool
  successfulConfirmationOnly : Bool
  deriving DecidableEq, Repr

/-- The current guards; `Params` names their owners. Tagged to the sweep's requirement;
the search and negative-release declarations retain their own tags. One field per line for
`ci.yml`'s controls. -/
@[req "OPS-32"]
def current : Params := {
    completePassOnly    := true,
    pastWindowOnly      := true,
    rereadBeforeAbsence := true,
    absenceWindow       := .visibility,
    readConfirmsMatch   := true,
    negativeOnly       := true,
    visibilityFromWaitEnd := true,
    visibilityUsesObserved := true,
    successfulConfirmationOnly := true }

structure World where
  now          : Nat
  /-- The dispatch of the create that produced the `external_id`: negative window origin. -/
  dispatchedAt : Nat
  /-- The reply or mutating-call deadline expiry: visibility window origin. -/
  callWaitEndedAt : Nat
  windows      : Windows
  /-- The provider's fact: the machine exists. Not in the store. -/
  live         : Bool
  knowledge    : Knowledge
  commitment   : Commitment
  /-- `OPS-27`'s match: the order landed, on this candidate. -/
  orderLanded  : Option Candidate
  /-- Provider evidence of a matched order still in progress, not a resource's absence. -/
  matchedOrderInProgress : Bool := false
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
  decide ((if p.absenceWindow = .visibility && p.visibilityFromWaitEnd
           then w.callWaitEndedAt else w.dispatchedAt) +
           w.windows.get p.visibilityUsesObserved p.absenceWindow ≤ w.now)

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
the reread's `not_found` is the evidence where both reread and successful-confirmation guards
hold; disabling only successful confirmation also admits a failed read. The listing's omission
is evidence without the reread guard; the record needs the window and the completeness the guards demand. -/
@[req "OPS-32"]
def sweepStep (p : Params) (w : World) (complete listed : Bool) (a : Answer) : World :=
  let candidate := !listed && (complete || !p.completePassOnly)
  let confirms := if p.successfulConfirmationOnly then a = .notFound else a ≠ .found
  let evidence  := if p.rereadBeforeAbsence then candidate && confirms else !listed
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
    if w.negativeElapsed && w.knowledge.isNegative &&
        (!p.negativeOnly || !w.matchedOrderInProgress) then { w with commitment := .closed } else w
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

/-- The release reads the negative window and its subject, excluding a matched in-progress
order under `ADR-0035`. A running machine's commitment is not a negative search's. -/
@[req "OPS-33"]
theorem release_on_negative_window (p : Params) (w : World) (h : w.commitment = .open) :
    (step p w .release).commitment = .closed ↔
      (w.negativeElapsed = true ∧ w.knowledge.isNegative = true) ∧
        (p.negativeOnly = false ∨ w.matchedOrderInProgress = false) := by
  simp only [step]; split <;> simp_all

/-- `OPS-33`: "the negative window MUST NOT run against a matched order that is still in
progress". Advancing the model's clock cannot release that order through a negative search. -/
@[req "OPS-33"]
theorem in_progress_preserves_commitment (p : Params) (hp : p.negativeOnly = true)
    (w : World) (h : w.matchedOrderInProgress = true) :
    (step p w .release).commitment = w.commitment := by
  simp [step, hp, h]

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
did not list the machine, whose reread answered `not_found`, past the window.
The additional hypothesis `h4` enables `successfulConfirmationOnly`. -/
@[req "OPS-32"]
theorem absence_requires_three (p : Params) (h1 : p.completePassOnly = true)
    (h2 : p.pastWindowOnly = true) (h3 : p.rereadBeforeAbsence = true)
    (h4 : p.successfulConfirmationOnly = true) (w : World) (e : Event)
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
    · simp only [sweepStep, h1, h2, h3, h4] at h
      cases complete <;> cases listed <;> cases a <;> simp_all
    · exact absurd h h0

/-- The window and the reread, with successful confirmation enabled: an absence is recorded on a `not_found` reread past the
window, whatever the pass did. This is why the completeness guard stops no meter by itself — a
reread past `PRV-36`'s window is authoritative — and why its own witness is the throttle.
The additional hypothesis `h4` enables `successfulConfirmationOnly`. -/
@[req "OPS-32"]
theorem absence_needs_reread_past_window (p : Params) (h2 : p.pastWindowOnly = true)
    (h3 : p.rereadBeforeAbsence = true) (h4 : p.successfulConfirmationOnly = true)
    (w : World) (complete listed : Bool) (a : Answer)
    (h0 : w.knowledge ≠ .authoritativeAbsence)
    (h : (step p w (.sweep complete listed a)).knowledge = .authoritativeAbsence) :
    listed = false ∧ a = .notFound ∧ pastWindow p w = true := by
  simp only [step] at h
  split at h
  · simp only [sweepStep, h2, h3, h4] at h
    cases complete <;> cases listed <;> cases a <;> simp_all
  · exact absurd h h0

/-- `PRV-36`, "A read of provider state is not authoritative about a mutation the driver issued
until that provider's effective visibility window has elapsed", as the hypothesis `hRead`: past
the window, a `not_found` read is the provider's fact. Under it, an absence the sweep records is
about a machine that is gone. The additional hypothesis `h4` enables
`successfulConfirmationOnly`; the provider fact remains the explicit hypothesis `hRead`. -/
@[req "PRV-36"]
theorem absence_sound (p : Params) (h2 : p.pastWindowOnly = true)
    (h3 : p.rereadBeforeAbsence = true) (h4 : p.successfulConfirmationOnly = true)
    (w : World) (complete listed : Bool) (a : Answer)
    (hRead : pastWindow p w = true → a = .notFound → w.live = false)
    (h0 : w.knowledge ≠ .authoritativeAbsence)
    (h : (step p w (.sweep complete listed a)).knowledge = .authoritativeAbsence) :
    w.live = false :=
  have ⟨_, ha, hw⟩ := absence_needs_reread_past_window p h2 h3 h4 w complete listed a h0 h
  hRead hw ha

/-- `OPS-32`: "it may record an absence only about a machine past `PRV-36`'s effective
visibility window". With the completeness, window, reread and successful-confirmation guards,
the visibility field, wait-end origin and observed-maximum guard enabled, the existing transition
can establish a new absence only after wait-end plus the computed maximum. Samples are inputs;
the `STO-53` sample write path is omitted and no future provider bound is proved. -/
@[req "OPS-32"]
theorem absence_past_effective_visibility (p : Params) (h1 : p.completePassOnly = true)
    (h2 : p.pastWindowOnly = true) (h3 : p.rereadBeforeAbsence = true)
    (h4 : p.successfulConfirmationOnly = true) (hv : p.absenceWindow = .visibility)
    (ho : p.visibilityFromWaitEnd = true) (hm : p.visibilityUsesObserved = true)
    (w : World) (e : Event) (h0 : w.knowledge ≠ .authoritativeAbsence)
    (h : (step p w e).knowledge = .authoritativeAbsence) :
    e = .sweep true false .notFound ∧
      w.callWaitEndedAt + max w.windows.declaredVisibility
        (w.windows.observedVisibility.foldr max 0) ≤ w.now := by
  have ⟨he, hw⟩ := absence_requires_three p h1 h2 h3 h4 w e h0 h
  exact ⟨he, by simpa [pastWindow, Windows.get, Windows.effectiveVisibility, hv, ho, hm] using hw⟩

/-- `OPS-32`: "a failed direct absence confirmation cannot record absence". With rereading
and successful confirmation enabled, a failed answer preserves knowledge, commitment and meter
through the existing sweep transition, whatever the listing and window say. -/
@[req "OPS-32"]
theorem failed_confirmation_records_nothing (p : Params)
    (hr : p.rereadBeforeAbsence = true) (hs : p.successfulConfirmationOnly = true)
    (w : World) (complete listed : Bool) :
    (step p w (.sweep complete listed .failed)).knowledge = w.knowledge ∧
    (step p w (.sweep complete listed .failed)).commitment = w.commitment ∧
    (step p w (.sweep complete listed .failed)).meterStoppedAt = w.meterStoppedAt := by
  simp only [step]
  split
  · simp [sweepStep, hr, hs]
  · exact ⟨rfl, rfl, rfl⟩

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
