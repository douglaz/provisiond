import Provisiond.Claim
import Provisiond.Runway
import Provisiond.Tables
/-! `OPS-42`'s cancellation fence, composed on the claim model (`Provisiond.Claim`), `LDG-33`'s
derivation (`Provisiond.Runway`) and `OPS-48`'s episode table (`Provisiond.Tables`): one machine,
one tenant, one worker, one engine, and the transactions at the boundaries the requirements draw.
The worker's fence transaction is `OPS-41`'s re-check and `OPS-42`'s conditional write in one step
where `Params.recheckInsideFence` holds, and two steps with a gap between them where it does not —
the 2026-09-02 amendment, "without this the fence does not fence", is that parameter. `LDG-62`'s
extension is its own transaction; the provider call is made after the worker "releases it before
the provider call, which `LDG-69` forbids inside" (`OPS-42`), from the one phase the fence
transaction alone enters.

The re-check as `OPS-41` writes it: the tenant's **current** suspension state first, read in the
fence transaction; then whether a rate exists; then `LDG-33` re-derived at it. `OPS-41`'s rate
outage is a branch, not a value — `World.rate` is optional — and "'No rate' is established by a
conditional write, not a read": the worker's rate read is a snapshot, which "`LDG-35`'s per-tenant
primitive orders nothing against a deployment-wide event", modelled as the rate the worker saw when it claimed
(`Phase.holding`) — so a restoration committing after the claim is what the snapshot predates, and
a snapshot holding a rate the outage has since removed derives at it — while the write on
`STO-37`'s record is inside the transaction. The episode is `STO-52`'s row with its
`reasons` set; the sweep, `API-58`'s fan-out and `LDG-64`'s bound canceller all enqueue through
`OPS-39`'s one rule, joining an open episode and opening none while one is open. The gone-write is
`ADR-0021`'s: it closes the open episode and clears the fence in one step, from any open state.

`Params` lists the guards dated amendments added to what this module models, each a field so
that removing it is a one-token change a witness theorem exercises (`ADR-0025`). Hard-wired, and
not guards on a rule but the rule: `LDG-62`'s test on the fence, which is the fence's own second
half; and `OPS-41`'s 2026-09-09 scope, "**any** exposure-reducing cancellation" — the model never
scopes by reason.

Re-derivation consumes an optional per-currency acceptance order (`STO-49`); no observation is
`LDG-40`'s halt. The caller supplies the date computed by `LDG-33`; source aggregation, currency
selection and rate arithmetic are outside this transition. `advance` moves wall clock without
writing either fact. `legacyArmedAt` is ghost history for the withdrawn age controls in
`rederiveFacts` and `World.routed`, not a machine column: under `current`, both
`confirmationByOrder` and `noAgeDischarge` are on, so its value affects neither fact nor routing.

What the model omits: the first 2026-09-05 form of
the suspension exemption, keyed on the attempt's own reason; a second attempt enqueued while one is
in flight (the model holds one attempt, and every enqueue waits for it); `OPS-31`'s resolution
verbs on an `uncertain` episode (`Provisiond.Tables` has the rows); `LDG-62`'s sizing of the
commitment it grows — `extend` takes the satoshis as given — and its wire answers; the
`late_attach_cleanup` reason (`OPS-36` is `pv-vwe.5`'s). The provider's answer is classified as
`succeeded` on a reply, `failed` on a refusal and `needs_reconciliation` on a lost reply —
`OPS-11`'s table is `Provisiond.Tables`'s and is not repeated. A machine is "funded" where a rate
exists and re-deriving `LDG-33` at it puts the date strictly in the future; whole satoshis per
second throughout. -/

namespace Provisiond.Fence
open Provisiond.Claim Provisiond.Runway Provisiond.Tables

/-- What `machines.destroy_committed` holds. `attempt` is the column as it stood until 2026-09-08,
"the attempt's operation id"; the distinct identity types mean the withdrawn design has to be
written down to be modelled at all. -/
inductive Holder
  | episode (e : EpisodeId)
  | attempt (o : OperationId)
  deriving DecidableEq, Repr

structure Machine where
  /-- `reserved_sats`. -/
  commitment     : Nat
  /-- The stored date the sweep routes on (`05-persistence.md`'s index). -/
  runwayUntil    : Nat
  /-- `STO-49`'s per-currency acceptance order, never an instant (`LDG-16`). -/
  rateConfirmationRef : Option Nat
  /-- `STO-54`'s wall-clock deadline (`LDG-16`). -/
  destroyNotBefore : Option Nat
  /-- `machines.destroy_committed`. -/
  fence          : Option Holder
  /-- The provider applied a delete. Monotone: nothing here restores a machine. -/
  destroyed      : Bool
  /-- `machines.state` recorded gone (`STO-48`), by the gone-write. Monotone. -/
  gone           : Bool
  deriving DecidableEq, Repr

/-- `OPS-39`'s stated reasons, those this model enqueues under. -/
inductive Reason
  | exhausted | tenantSuspended | rateOutageBound
  deriving DecidableEq, Repr

/-- `STO-52`'s row: the episode, its state, and "the reasons that contributed are retained as the
episode's `reasons` **set**" (`OPS-39`). -/
structure EpisodeRow where
  id      : EpisodeId
  state   : Episode
  reasons : List Reason
  deriving DecidableEq, Repr

/-- The cancellation the worker holds: its operation, its episode, and its row as the claim
model's guards see it. -/
structure Attempt where
  op  : OperationId
  ep  : EpisodeId
  row : Row
  deriving DecidableEq, Repr

/-- Settled, in `OPS-3`'s sense, or `needs_reconciliation`: no longer `queued` or `running`. -/
def Attempt.done (a : Attempt) : Bool :=
  a.row.status != .queued && a.row.status != .running

def freshRow : Row := { status := .queued, claim := ⟨0⟩, record := 0, revision := 0 }

inductive Holds
  | episodeId | attemptId
  deriving DecidableEq, Repr

/-- `OPS-41`'s abort predicate: the re-derived date (`abortDate`), or the withdrawn 2026-09-04
form `usable_sats > 0` (`abortSats`). -/
inductive AbortPredicate
  | date | sats
  deriving DecidableEq, Repr

/-- What the suspension exemption reads: "the tenant's current state" (`OPS-41`), or "the
episode's `reasons` set, which is deduplication history" — the form rewritten away on 2026-09-05. -/
inductive SuspensionKey
  | currentState | episodeReasons
  deriving DecidableEq, Repr

/-- The dated amendments this module carries, each a parameter so that removing it is a one-token
change a witness theorem exercises. `recheckInsideFence`: `OPS-42`, 2026-09-02, "`OPS-41`'s
re-check and this fence write MUST be one transaction". `fenceHolds`: `OPS-42`, 2026-09-08, "the
fence holds the episode, not the attempt". `fenceOnOpenEpisode`: `OPS-42`, 2026-09-09, the write
guarded "on that episode being open". `abortPredicate`: `OPS-41`, 2026-09-04, "The predicate is
the re-derived `runway_until`". `abortWritesDate`: `OPS-41`, 2026-09-05, "write that re-derived
`runway_until` to the machine row". `extendWritesDate`: `LDG-62`, 2026-09-05, the same write.
`suspensionKey`: `OPS-41`, 2026-09-05, "keyed on the tenant's current state ... and not on the
episode's `reasons` set". `outageWrite`: `OPS-41`, 2026-09-05, "'No rate' is established by a
conditional write, not a read". `ownIdClause`: `OPS-42`, 2026-09-02, the guard's second
disjunct, "`IS NULL` alone until 2026-09-02". The setter's 2026-09-21 guards (`LDG-16`):
`armWinsFutureClear`, "Where one write would both arm it and clear it, the arm wins";
`confirmationByOrder`, "a greater acceptance order, never a later instant and never elapsed time";
`observationKeepsDeadline`, "wall clock, and no observation discharges it";
`backwardCannotConfirm`, "A backward move never confirms itself".
`noAgeDischarge`: the 2026-09-05 age discharge, withdrawn 2026-09-21 (`LDG-16`:
"a mark discharged by **age** re-opens the case of 2026-09-05"); its off position routes an
armed reference once the mark is "older than one re-derivation interval" (`ADR-0026`).
Their off positions retain withdrawn traps, not alternative current rules (`ADR-0026`).
`retryGuard`: `OPS-48`, 2026-09-09,
`retry` as "a conditional write on `(id, state = stalled)`". -/
structure Params where
  recheckInsideFence   : Bool
  fenceHolds           : Holds
  fenceOnOpenEpisode   : Bool
  abortPredicate       : AbortPredicate
  abortWritesDate      : Bool
  extendWritesDate     : Bool
  suspensionKey        : SuspensionKey
  outageWrite          : Bool
  ownIdClause          : Bool
  armWinsFutureClear   : Bool
  confirmationByOrder  : Bool
  observationKeepsDeadline : Bool
  backwardCannotConfirm : Bool
  noAgeDischarge       : Bool
  retryGuard           : Bool
  deriving DecidableEq, Repr

/-- The fence as it stands, with every guard it composes from `OPS-41`, `LDG-62`, `LDG-16` and
`OPS-48` present; tagged to the fence's own requirement. One field per line: `ci.yml`'s controls
flip one each. -/
@[req "OPS-42"]
def current : Params := {
    recheckInsideFence   := true,
    fenceHolds           := .episodeId,
    fenceOnOpenEpisode   := true,
    abortPredicate       := .date,
    abortWritesDate      := true,
    extendWritesDate     := true,
    suspensionKey        := .currentState,
    outageWrite          := true,
    ownIdClause          := true,
    armWinsFutureClear   := true,
    confirmationByOrder  := true,
    observationKeepsDeadline := true,
    backwardCannotConfirm := true,
    noAgeDischarge       := true,
    retryGuard           := true }

/-- What this attempt writes into the fence column. -/
def Params.holder (p : Params) (a : Attempt) : Holder :=
  match p.fenceHolds with
  | .episodeId => .episode a.ep
  | .attemptId => .attempt a.op

/-- The abort predicate in force, on what the re-check read. -/
def Params.abort (p : Params) (commitment prot rate : Nat) : Bool :=
  match p.abortPredicate with
  | .date => abortDate commitment prot rate
  | .sats => abortSats commitment prot rate

/-- Where the worker is. `holding`: claimed, `OPS-8`'s hold on the machine, before the fence
transaction, carrying the rate it read at the claim — a snapshot, which `OPS-41` says
"`LDG-35`'s per-tenant primitive orders nothing against a deployment-wide event". `readUnfenced`: the split variant's phase between its read and
its write, with what the read decided and the date it derived. `fenced`: the fence written — the
only phase a provider call leaves from. `noMutation`: `OPS-41`'s abort, with the re-derived date
where the re-check derived one, to be settled `succeeded`. `dispatched`: the provider call made,
holding its reply or its loss. -/
inductive Phase
  | idle
  | holding (mine : ClaimNumber) (rateSeen : Option Nat)
  | readUnfenced (mine : ClaimNumber) (proceed : Bool) (date : Option Nat)
  | fenced (mine : ClaimNumber)
  | noMutation (mine : ClaimNumber) (date : Option Nat)
  | dispatched (mine : ClaimNumber) (reply : Option Bool)
  deriving DecidableEq, Repr

structure World where
  m          : Machine
  /-- The tenant's available balance. -/
  balance    : Nat
  now        : Nat
  /-- One re-derivation interval (`LDG-16`). -/
  interval   : Nat
  /-- Ghost history for the withdrawn elapsed-time tests in `rederiveFacts` and `World.routed`;
  inert under `current` as described above, never a durable exhaustion fact. -/
  legacyArmedAt : Nat := 0
  /-- `LDG-59`'s rate, whole satoshis per second, and `none` while "there is no rate" (`LDG-64`). -/
  rate       : Option Nat
  /-- `protected_sats`. -/
  prot       : Nat
  /-- The tenant's current suspension state (`API-58`, `WIR-41`). -/
  suspended  : Bool
  /-- `OPS-41`'s "**this machine's** open `rate_outage` deficiency record (`STO-37`, guarded on
  `absorbed_until IS NULL`)". -/
  outageOpen : Bool
  episode    : Option EpisodeRow
  attempt    : Option Attempt
  phase      : Phase
  nextId     : Nat
  deriving DecidableEq, Repr

def World.episodeOpen (w : World) : Bool := w.episode.any (·.state.isOpen)

/-- Whether the wall-clock deadline is "null or past" (`LDG-16`). -/
def World.deadlinePassed (w : World) : Bool :=
  match w.m.destroyNotBefore with
  | none => true
  | some deadline => deadline ≤ w.now

/-- `LDG-16`: "The exhaustion sweep MUST route a machine where its stored `runway_until` has
passed, its `rate_confirmation_ref` is null and its `destroy_not_before` is null or past".
The withdrawn age discharge lives here because `sweep` is "routed on
the **stored** date and `LDG-16`'s facts (`World.routed`) and on nothing else".
Putting the off branch in `sweep`, or selecting a second predicate there, would leave the
carrier named in `Admission.lean:66-69` — "`rederiveFacts` (the no-observation branch) and
`World.routed`" — intact while the control broke an unnamed extra guard. -/
@[req "LDG-16"]
def World.routed (w : World) (p : Params) : Bool :=
  let referenceNull := match w.m.rateConfirmationRef with
    | none => true
    | some _ => !p.noAgeDischarge && w.legacyArmedAt + w.interval < w.now
  w.m.runwayUntil ≤ w.now && referenceNull && w.deadlinePassed

/-- `LDG-65`: "cancelled normally — unless its `rate_confirmation_ref` is armed". With
`noAgeDischarge` on, an armed reference refuses routing for every rate state, including `none`;
rate availability is absent from `World.routed`, so this is a property of that predicate,
not another guard. -/
@[req "LDG-65"]
theorem armed_reference_not_routed (p : Params) (ha : p.noAgeDischarge = true)
    (w : World) (order : Nat)
    (h : w.m.rateConfirmationRef = some order) (rate : Option Nat) :
    ({ w with rate := rate }).routed p = false := by
  simp [World.routed, ha, h]

/-- The result is a state, not a pair of arm/clear commands: a reference cannot be both set and
cleared by the same write. The deadline is a separate fact on a separate clock (`ADR-0026`). -/
structure ExhaustionFacts where
  rateConfirmationRef : Option Nat
  destroyNotBefore : Option Nat
  deriving DecidableEq, Repr

/-- The clock of a pass, and ghost history only the withdrawn age test uses. -/
structure DerivationClock where
  now : Nat
  interval : Nat
  legacyArmedAt : Nat
  deriving DecidableEq, Repr

/-- `LDG-16`: "Re-derivation (`PRV-13e`) MUST arm it, with the observation it consumed, on every
rate-produced backward move of a `runway_until` that stood in the future"; "on no other write".
"It is discharged by the first strictly later accepted observation for the machine's currency
whose own write does not arm it again". The optional observation is an acceptance order in that
currency; `none` is the halted pass. "Re-derivation's own write is not one: it discharges the
reference on the terms above and never touches the deadline." The branches are exhaustive.
Off-guard branches retain the traps named in `Params`: clear wins,
elapsed age substitutes for observation order, an observation whose write leaves the reference
slot empty ends grace, or a backward move confirms itself. No cancellation bypass belongs to
this function. -/
@[req "LDG-16"]
def rederiveFacts (p : Params) (oldDate newDate : Nat) (observation : Option Nat)
    (clock : DerivationClock) (facts : ExhaustionFacts) : ExhaustionFacts :=
  match observation with
  | none => facts
  | some order =>
    let arms := clock.now < oldDate && newDate < oldDate
    let later := match facts.rateConfirmationRef with
      | none => false
      | some prior => prior < order
    let reference :=
      if !p.armWinsFutureClear && clock.now < newDate then none
      else if !p.backwardCannotConfirm && later then none
      else if arms then some order
      else match facts.rateConfirmationRef with
        | none => none
        | some prior =>
          if (if p.confirmationByOrder then prior < order
              else clock.legacyArmedAt + clock.interval < clock.now) then none else some prior
    { rateConfirmationRef := reference,
      destroyNotBefore := if p.observationKeepsDeadline || reference.isSome then facts.destroyNotBefore
                          else none }

/-- `LDG-16`: "Where one write would both arm it and clear it, the arm wins" and
"A backward move never confirms itself", including a later order and a future new date. -/
@[req "LDG-16"]
theorem backward_arms (p : Params) (ha : p.armWinsFutureClear = true)
    (hb : p.backwardCannotConfirm = true) (oldDate newDate order : Nat)
    (clock : DerivationClock) (facts : ExhaustionFacts)
    (hf : clock.now < oldDate) (hm : newDate < oldDate) :
    (rederiveFacts p oldDate newDate (some order) clock facts).rateConfirmationRef = some order := by
  simp [rederiveFacts, ha, hb, hf, hm]

/-- `LDG-16`: "It is discharged by the first strictly later accepted observation for the
machine's currency whose own write does not arm it again". The result names the new order only
in `backward_arms`; a non-arming write either clears or retains the old one. -/
@[req "LDG-16"]
theorem nonarming_discharges_iff_later (p : Params) (ha : p.armWinsFutureClear = true)
    (hb : p.backwardCannotConfirm = true) (hc : p.confirmationByOrder = true)
    (oldDate newDate order prior : Nat) (clock : DerivationClock) (deadline : Option Nat)
    (hn : ¬ (clock.now < oldDate ∧ newDate < oldDate)) :
    (rederiveFacts p oldDate newDate (some order) clock ⟨some prior, deadline⟩).rateConfirmationRef
      = none ↔ prior < order := by
  simp [rederiveFacts, ha, hb, hc, Bool.and_eq_true, hn]

/-- `LDG-16`: "A move of a date that had already passed arms nothing". With no old reference,
a backward move cannot put an already-exhausted machine behind another confirmation. -/
@[req "LDG-16"]
theorem past_date_does_not_arm (p : Params) (oldDate newDate order : Nat)
    (clock : DerivationClock) (deadline : Option Nat) (hpast : oldDate ≤ clock.now) :
    (rederiveFacts p oldDate newDate (some order) clock ⟨none, deadline⟩).rateConfirmationRef
      = none := by
  simp [rederiveFacts, Nat.not_lt.mpr hpast]

/-- `PRV-13e`: "It never writes `machines.destroy_not_before`". No accepted observation,
including one that arms or discharges the reference, changes the deadline. -/
@[req "PRV-13e"]
theorem rederivation_keeps_deadline (p : Params) (hd : p.observationKeepsDeadline = true)
    (oldDate newDate : Nat) (observation : Option Nat) (clock : DerivationClock)
    (facts : ExhaustionFacts) :
    (rederiveFacts p oldDate newDate observation clock facts).destroyNotBefore = facts.destroyNotBefore := by
  cases observation <;> simp [rederiveFacts, hd]

/-- `LDG-40`: "the halt MUST NOT itself trigger exhaustion". Without an observation the
setter is the identity, regardless of the proposed date or clock. -/
@[req "LDG-40"]
theorem no_observation_changes_nothing (p : Params) (oldDate newDate : Nat)
    (clock : DerivationClock) (facts : ExhaustionFacts) :
    rederiveFacts p oldDate newDate none clock facts = facts := rfl

/-- `LDG-16`: "never a later instant and never elapsed time". Under acceptance-order
confirmation, changing only the withdrawn age clock or the interval changes neither fact. -/
@[req "LDG-16"]
theorem confirmation_ignores_age (p : Params) (hc : p.confirmationByOrder = true)
    (oldDate newDate : Nat) (observation : Option Nat) (clock : DerivationClock)
    (interval armedAt : Nat) (facts : ExhaustionFacts) :
    rederiveFacts p oldDate newDate observation { clock with interval := interval, legacyArmedAt := armedAt } facts
      = rederiveFacts p oldDate newDate observation clock facts := by
  cases observation <;> simp [rederiveFacts, hc]

/-- `PRV-13e`: "written in the same transaction as the date that observation explains".
The no-observation case writes nothing. The existing cancellation fence is preserved.
`legacyArmedAt` records the arming instant solely to execute the withdrawn age control. -/
@[req "PRV-13e"]
def rederive (p : Params) (w : World) (newDate : Nat) (observation : Option Nat) : World :=
  match observation with
  | none => w
  | some order =>
    let facts := rederiveFacts p w.m.runwayUntil newDate (some order)
      ⟨w.now, w.interval, w.legacyArmedAt⟩ ⟨w.m.rateConfirmationRef, w.m.destroyNotBefore⟩
    { w with
      m := { w.m with
        runwayUntil := newDate
        rateConfirmationRef := facts.rateConfirmationRef
        destroyNotBefore := facts.destroyNotBefore }
      legacyArmedAt := if w.now < w.m.runwayUntil && newDate < w.m.runwayUntil
                       then w.now else w.legacyArmedAt }

/-- `STO-54`: the deadline is "the restore instant plus one re-derivation interval", and
"any `rate_confirmation_ref` already present is preserved". This model carries the reference
and observations against which preservation matters; `Provisiond.Restore` carries the procedure.
The restore instant is the incident's recorded instant, not a fresh clock on a repeated pass. -/
@[req "STO-54"]
def restoreGrace (w : World) (restoreInstant : Nat) : World :=
  if w.m.runwayUntil ≤ restoreInstant then
    { w with m := { w.m with destroyNotBefore := some (restoreInstant + w.interval) } }
  else w

/-- `LDG-16`: "An authorized future-date write clears both". Used only by the extension and
no-mutation abort; re-derivation has its own transition above. -/
@[req "LDG-16"]
def writeDate (m : Machine) (now d : Nat) : Machine :=
  { m with runwayUntil := d,
           rateConfirmationRef := if now < d then none else m.rateConfirmationRef,
           destroyNotBefore := if now < d then none else m.destroyNotBefore }

/-- `LDG-16`: "An authorized future-date write clears both". The event wrappers decide
authorization; this is their shared write. -/
@[req "LDG-16"]
theorem authorized_date_clears_both (m : Machine) (now d : Nat) (hf : now < d) :
    (writeDate m now d).rateConfirmationRef = none ∧
    (writeDate m now d).destroyNotBefore = none := by
  simp [writeDate, hf]

/-- `STO-54`: "any `rate_confirmation_ref` already present is preserved", for every restore
write, regardless of whether the date qualifies for grace. -/
@[req "STO-54"]
theorem restore_preserves_reference (w : World) (instant : Nat) :
    (restoreGrace w instant).m.rateConfirmationRef = w.m.rateConfirmationRef := by
  unfold restoreGrace; (repeat' split) <;> rfl

/-- The new setters change neither the cancellation fence nor the worker or balance. This is
the part of the frame they retain when the whole machine row can no longer stay unchanged. -/
theorem setters_keep_cancellation_state (p : Params) (w : World) (date : Nat)
    (observation : Option Nat) (instant : Nat) :
    (rederive p w date observation).m.fence = w.m.fence ∧
    (rederive p w date observation).phase = w.phase ∧
    (rederive p w date observation).balance = w.balance ∧
    (restoreGrace w instant).m.fence = w.m.fence ∧
    (restoreGrace w instant).phase = w.phase ∧
    (restoreGrace w instant).balance = w.balance := by
  cases observation <;> simp [rederive, restoreGrace] <;> split <;> simp

/-! ## The events -/

/-- `OPS-39`: an episode is "opened once, and found open by every subsequent sweep until it
closes", so an enqueue against a machine whose episode is open joins it — the reason is added to
the set and nothing is enqueued, "the index, not a claim, is what makes the second sweep enqueue no
duplicate cancellation". Otherwise the episode is opened `attempting` "with its first attempt
enqueued in the same transaction" (`OPS-48`), once the previous attempt is done. -/
@[req "OPS-39"]
def enqueue (w : World) (r : Reason) : World :=
  if w.episodeOpen then
    { w with episode := w.episode.map fun ep => { ep with reasons := ep.reasons.insert r } }
  else if w.phase == .idle && w.attempt.all Attempt.done then
    let ep : EpisodeId := ⟨w.nextId⟩
    { w with episode := some { id := ep, state := .attempting, reasons := [r] },
             attempt := some { op := ⟨w.nextId + 1⟩, ep := ep, row := freshRow },
             nextId := w.nextId + 2 }
  else w

/-- `OPS-48`'s row applied to the machine's episode `ep`: the state after the event, and the fence
"**Cleared**, same transaction" exactly where the row says (`episodeStep`'s second component). -/
def applyRow (w : World) (ep : EpisodeRow) (ev : Tables.Event) : World :=
  { w with episode := some { ep with state := (episodeStep currentRows ep.state ev).1 },
           m := { w.m with fence := if (episodeStep currentRows ep.state ev).2 then none
                                    else w.m.fence } }

/-- The exhaustion sweep: `LDG-14`'s "At end of runway the machine MUST be cancelled", routed on
the **stored** date and `LDG-16`'s facts (`World.routed`) and on nothing else, for a machine not
recorded gone — `LDG-74`: "a machine established gone has nothing left to cancel". Its other row
is `OPS-48`'s sweep-close: the sweep "finds the machine of a `stalled` episode funded under
`OPS-41`'s predicate ... **and its tenant not suspended** at that read" and closes it `funded`,
clearing the fence; a `stalled` episode has no attempt in flight, which the guard states. -/
@[req "LDG-14"]
def sweep (p : Params) (w : World) : World :=
  match w.episode, w.rate with
  | some ep, some r =>
    if ep.state == .stalled && w.phase == .idle && w.attempt.all Attempt.done
        && p.abort w.m.commitment w.prot r then
      applyRow w ep (.sweepFunded w.suspended)
    else if w.routed p && !w.m.gone then enqueue w .exhausted else w
  | _, _ => if w.routed p && !w.m.gone then enqueue w .exhausted else w

/-- `OPS-8`: the claim, through the claim model, taking the rate snapshot the re-check will read.
A row that is not `queued` is not claimed. -/
@[req "OPS-8"]
def claimStep (w : World) : World :=
  match w.phase, w.attempt with
  | .idle, some a =>
    match Claim.claim true a.row with
    | (r, some n) => { w with attempt := some { a with row := r }, phase := .holding n w.rate }
    | (_, none) => w
  | _, _ => w

/-- What the re-check has to derive at. `derive r`: a rate, from the snapshot or — under the
conditional write, where the write "affects no row" and "a rate now exists — restoration" — from
the rate in force. `noRate`: "where none does ... the cancel proceeds, because a bound the outage
has not cleared is still the bound" (`OPS-41`); without the write, a snapshot saying no rate is
taken at its word. `meterStopped`: the write affected no row and no rate exists, "the machine's
own meter stopped (`LDG-74`), there is nothing left to cancel". -/
inductive RateRead
  | derive (r : Nat) | noRate | meterStopped
  deriving DecidableEq, Repr

@[req "OPS-41"]
def readRate (p : Params) (w : World) (rateSeen : Option Nat) : RateRead :=
  match rateSeen with
  | some r => .derive r
  | none =>
    if !p.outageWrite || w.outageOpen then .noRate
    else match w.rate with
      | some r => .derive r
      | none => .meterStopped

/-- `OPS-41`'s exemption: "where the machine's tenant IS suspended at the moment of the re-check,
read in the same fence transaction", or — the withdrawn key — the episode's `reasons` set. -/
@[req "OPS-41"]
def exempt (p : Params) (w : World) : Bool :=
  match p.suspensionKey with
  | .currentState => w.suspended
  | .episodeReasons => w.episode.any (·.reasons.contains .tenantSuspended)

/-- `OPS-41`'s re-check: whether the cancellation proceeds, and the re-derived date where one was
derived. A suspended tenant's machine "cannot be found funded"; otherwise `readRate` decides what
there is to derive at, and the abort predicate is applied to what the transaction read. -/
@[req "OPS-41"]
def recheck (p : Params) (w : World) (rateSeen : Option Nat) : Bool × Option Nat :=
  if exempt p w then (true, none)
  else match readRate p w rateSeen with
    | .derive r =>
      (!p.abort w.m.commitment w.prot r, some (w.now + runwaySeconds w.m.commitment w.prot r))
    | .noRate => (true, none)
    | .meterStopped => (false, none)

/-- `OPS-42`'s conditional write, "guarded on `destroy_committed IS NULL` *or* `destroy_committed`
already holding this operation's episode id" — "**and on that episode being open**" under
`fenceOnOpenEpisode`: one row where it admits, zero rows otherwise. -/
@[req "OPS-42"]
def fenceAdmits (p : Params) (w : World) (a : Attempt) : Bool :=
  (w.m.fence == none || (p.ownIdClause && w.m.fence == some (p.holder a))) &&
  (!p.fenceOnOpenEpisode || w.episode.any fun ep => ep.id == a.ep && ep.state.isOpen)

/-- The write itself, where the re-check said proceed: the fence set and the worker `fenced`, or
"another actor won the race and the worker MUST abort the cancellation". -/
def writeFence (p : Params) (w : World) (n : ClaimNumber) (a : Attempt) (d : Option Nat) : World :=
  if fenceAdmits p w a then
    { w with m := { w.m with fence := some (p.holder a) }, phase := .fenced n }
  else { w with phase := .noMutation n d }

/-- The fence transaction: `OPS-41`'s re-check "in the same serialized transaction that writes
`OPS-42`'s fence". Under `recheckInsideFence` it reads and writes in one step: an abort is
`noMutation` with no fence written, and a machine the re-check lets through takes the write.
Without it the transaction is the read alone, and the write is `fenceWrite`'s later step. -/
@[req "OPS-41"]
def fenceTxn (p : Params) (w : World) : World :=
  match w.phase, w.attempt with
  | .holding n rs, some a =>
    -- Written out four times rather than bound once: a `let` here is a `have` the `split`
    -- tactic cannot see through, and the four are one term to the kernel.
    if !p.recheckInsideFence then
      { w with phase := .readUnfenced n (recheck p w rs).1 (recheck p w rs).2 }
    else if (recheck p w rs).1 then writeFence p w n a (recheck p w rs).2
    else { w with phase := .noMutation n (recheck p w rs).2 }
  | _, _ => w

/-- The split variant's second transaction: the fence write, deciding on what an earlier
transaction read. It exists only where the read and the write are split; under
`recheckInsideFence` there is no such step. -/
@[req "OPS-42"]
def fenceWrite (p : Params) (w : World) : World :=
  match p.recheckInsideFence, w.phase, w.attempt with
  | false, .readUnfenced n proceed d, some a =>
    if proceed then writeFence p w n a d else { w with phase := .noMutation n d }
  | _, _, _ => w

/-- `LDG-62`: in its own transaction, "conditional-write the machine row guarded on
`machines.destroy_committed IS NULL`", failing `conflict` where it affects no row — "opening or
growing no commitment and moving no balance" — and refused for a suspended tenant, which "`API-7`
step 5b refuses" (`OPS-41`). Where it is admitted it grows the commitment from available under
"`LDG-10`'s no-negative rule" and, under `extendWritesDate`, writes the re-derived `runway_until`
— which `LDG-33` "recomputes ... only when a rate exists" (`LDG-65`). -/
@[req "LDG-62"]
def extend (p : Params) (w : World) (sats : Nat) : World :=
  if w.m.fence != none || w.suspended || w.balance < sats then w
  else
    let c := w.m.commitment + sats
    match p.extendWritesDate, w.rate with
    | true, some r =>
      { w with m := writeDate { w.m with commitment := c } w.now (w.now + runwaySeconds c w.prot r),
               balance := w.balance - sats }
    | _, _ => { w with m := { w.m with commitment := c }, balance := w.balance - sats }

/-- The provider call, outside every serialization (`LDG-69`), from `fenced` and nowhere else.
`LDG-16`'s bypasses "Both do respect the destruction deadline", checked here even for an
already-enqueued cancellation. `applied` is the provider's fact and `reply` what came back
(`ProviderOutcome`, flattened). -/
@[req "OPS-41"]
def providerDelete (w : World) (applied : Bool) (reply : Option Bool) : World :=
  match w.phase with
  | .fenced n =>
    if w.deadlinePassed then
      { w with m := { w.m with destroyed := w.m.destroyed || applied }, phase := .dispatched n reply }
    else w
  | _ => w

/-- `LDG-16`: "Both do respect the destruction deadline". Every provider call waits while
that deadline is future, including a cancellation already fenced under either bypass. -/
@[req "LDG-16"]
theorem provider_waits_for_deadline (w : World) (applied : Bool) (reply : Option Bool)
    (hd : w.deadlinePassed = false) : providerDelete w applied reply = w := by
  unfold providerDelete; split <;> simp [hd]

/-- How the reply settles the attempt: `OPS-48`'s first column and `STO-3`'s written state. -/
def ofReply : Option Bool → Settled × Written
  | some true => (.gone, .succeeded)
  | some false => (.failed, .failed)
  | none => (.needsReconciliation, .needsReconciliation)

/-- The terminal transaction: `STO-3`'s guarded write on the row, and `OPS-48`'s row on **this
attempt's** episode (`operations.episode_id`) with the fence cleared exactly where that row says.
A settlement with the resource gone is a gone-write of its own — `OPS-48`: "Where that write and
an attempt's terminal write are one transaction, as a delete's own 'already gone' answer is, they
are one close under the first row" — so it records the machine gone. An attempt whose episode is
no longer the machine's "changes the attempt and not the episode" (`OPS-48`), and so does one
under a closed episode, since `episodeStep` is `closed_absorbing`. -/
def finish (w : World) (n : ClaimNumber) (a : Attempt) (s : Settled) (wr : Written) : World :=
  let row := workerWrite Claim.current a.row { written := wr, record := 0, mine := n }
  match w.episode with
  | some ep =>
    if ep.id == a.ep then
      applyRow { w with attempt := some { a with row := row }, phase := .idle,
                        m := { w.m with gone := w.m.gone || s == .gone } } ep (.settled s)
    else { w with attempt := some { a with row := row }, phase := .idle,
                  m := { w.m with gone := w.m.gone || s == .gone } }
  | none => { w with attempt := some { a with row := row }, phase := .idle,
                     m := { w.m with gone := w.m.gone || s == .gone } }

/-- `OPS-41`'s abort write: "write that re-derived `runway_until` to the machine row and clear
both of `LDG-16`'s exhaustion facts — `machines.rate_confirmation_ref` and
`machines.destroy_not_before`". -/
def writeAbortDate (w : World) (d : Nat) : World := { w with m := writeDate w.m w.now d }

/-- Settlement, from the abort or from the provider's answer. The abort also does what `OPS-41`
says of the funded case under `abortWritesDate` — the date write — so the sweep does not route
the same machine on the next pass; the lost-race abort settles "as `OPS-41` requires" (`OPS-42`)
and is read here as the same terminal transaction, writing the date the re-check derived where it
derived one. -/
@[req "OPS-48"]
def settle (p : Params) (w : World) : World :=
  match w.phase, w.attempt with
  | .noMutation n d, some a =>
    match p.abortWritesDate, d with
    | true, some d => writeAbortDate (finish w n a .noMutation .succeeded) d
    | _, _ => finish w n a .noMutation .succeeded
  | .dispatched n reply, some a => finish w n a (ofReply reply).1 (ofReply reply).2
  | _, _ => w

/-- `retry` (`API-64`), as `OPS-48`'s row has it: "on a `stalled` episode", "with a fresh attempt
enqueued in the same transaction as the state change; admissible in no other state" — under
`retryGuard`, "a conditional write on `(id, state = stalled)`", which is what makes a retry
racing a gone-write lose; without it, a plain write of `attempting`. -/
@[req "OPS-48"]
def retry (p : Params) (w : World) : World :=
  match w.phase, w.attempt, w.episode with
  | .idle, some a, some ep =>
    if a.done && (!p.retryGuard || ep.state == .stalled) then
      { w with episode := some { ep with state := (episodeStep currentRows .stalled .retry).1 },
               attempt := some { op := ⟨w.nextId⟩, ep := ep.id, row := freshRow },
               nextId := w.nextId + 1 }
    else w
  | _, _, _ => w

/-- The gone-write (`ADR-0021`): "the write of `machines.state` to gone with `state_observed_at`
(`STO-48`), by any of `LDG-74`'s triggers ... or by `API-63`'s termination", which "closes its
open episode `resource_gone` and clears the fence, in that transaction" — `OPS-48`'s row: "in any
open state, `scheduled` included". What the trigger observed is not modelled; the event is the
write. -/
@[req "OPS-48"]
def goneWrite (w : World) : World :=
  match w.episode with
  | some ep => applyRow { w with m := { w.m with gone := true } } ep .goneWrite
  | none => { w with m := { w.m with gone := true } }

/-- `API-58`'s suspension: the tenant's state, and its fan-out, which enqueues a
`tenant_suspended` cancellation — joining "an already-open exhaustion episode" (`OPS-41`). -/
@[req "API-58"]
def suspend (w : World) : World := enqueue { w with suspended := true } .tenantSuspended

/-- `WIR-41`'s resume: the tenant's state, and nothing else. -/
@[req "WIR-41"]
def resume (w : World) : World := { w with suspended := false }

/-- The rate lost (`LDG-59`'s quorum gone): this machine carries an open `rate_outage` record,
which `OPS-41` says "under `LDG-64` is every machine metered through the outage". -/
@[req "LDG-64"]
def rateLost (w : World) : World := { w with rate := none, outageOpen := true }

/-- The rate restored, at `r`: `LDG-64`'s "close the absorbed window at the first valid rate
observation", the record's `absorbed_until` written "by the observation that restores `LDG-59`'s
quorum". -/
@[req "LDG-64"]
def rateRestored (w : World) (r : Nat) : World := { w with rate := some r, outageOpen := false }

/-- `LDG-64`'s bound canceller: "cancel machines at that bound if no rate has returned", one
`rate_outage_bound` cancellation, "enqueued only for a machine carrying such a record" (`OPS-41`). -/
@[req "LDG-64"]
def outageBound (w : World) : World :=
  if w.rate == none && w.outageOpen then enqueue w .rateOutageBound else w

inductive Event
  | advance (seconds : Nat)
  | rederive (newDate : Nat) (observation : Option Nat)
  | restoreGrace (restoreInstant : Nat)
  | sweep | claim | fenceTxn | fenceWrite
  | extend (sats : Nat)
  | providerDelete (applied : Bool) (reply : Option Bool)
  | settle | retry | goneWrite | suspend | resume
  | rateLost | rateRestored (r : Nat) | outageBound
  deriving DecidableEq, Repr

def step (p : Params) (w : World) : Event → World
  | .advance seconds => { w with now := w.now + seconds }
  | .rederive date observation => rederive p w date observation
  | .restoreGrace instant => restoreGrace w instant
  | .sweep => sweep p w
  | .claim => claimStep w
  | .fenceTxn => fenceTxn p w
  | .fenceWrite => fenceWrite p w
  | .extend s => extend p w s
  | .providerDelete a r => providerDelete w a r
  | .settle => settle p w
  | .retry => retry p w
  | .goneWrite => goneWrite w
  | .suspend => suspend w
  | .resume => resume w
  | .rateLost => rateLost w
  | .rateRestored r => rateRestored w r
  | .outageBound => outageBound w

def run (p : Params) (w : World) : List Event → World
  | [] => w
  | e :: es => run p (step p w e) es

/-! ## Both commit orderings -/

theorem extend_guard (w : World) (sats : Nat) (hs : w.suspended = false) (hf : w.m.fence = none)
    (hb : sats ≤ w.balance) : (w.m.fence != none || w.suspended || w.balance < sats) = false := by
  simp [hf, hs, Nat.not_lt.mpr hb]

/-- An admitted extension grows the commitment by what it took from available and writes the
re-derived date (`LDG-62`, 2026-09-05: "an extension that grew the commitment and wrote no date
left the stored one in the past"). -/
@[req "LDG-62"]
theorem extend_admitted (p : Params) (hd : p.extendWritesDate = true) (w : World) (r : Nat)
    (hr : w.rate = some r) (hs : w.suspended = false) (sats : Nat) (hf : w.m.fence = none)
    (hb : sats ≤ w.balance) :
    (extend p w sats).m.commitment = w.m.commitment + sats ∧
    (extend p w sats).balance = w.balance - sats ∧
    (extend p w sats).m.runwayUntil = w.now + runwaySeconds (w.m.commitment + sats) w.prot r := by
  simp [extend, extend_guard w sats hs hf hb, hr, hd, writeDate]

/-- What an extension leaves alone, admitted or refused, whatever the rate and the date rule. -/
theorem extend_frame (p : Params) (w : World) (sats : Nat) :
    (extend p w sats).phase = w.phase ∧ (extend p w sats).attempt = w.attempt ∧
    (extend p w sats).suspended = w.suspended ∧ (extend p w sats).prot = w.prot ∧
    (extend p w sats).now = w.now ∧ (extend p w sats).m.fence = w.m.fence ∧
    (extend p w sats).episode = w.episode ∧ (extend p w sats).rate = w.rate ∧
    (extend p w sats).outageOpen = w.outageOpen ∧ (extend p w sats).nextId = w.nextId ∧
    (extend p w sats).m.destroyed = w.m.destroyed := by
  unfold extend; (repeat' split) <;> simp [writeDate]

/-- A fence transaction whose re-check aborts: no fence written, the worker `noMutation` with
the date the re-check derived. -/
theorem fenceTxn_abort (p : Params) (hp : p.recheckInsideFence = true) (w : World)
    (n : ClaimNumber) (rs : Option Nat) (a : Attempt) (hph : w.phase = .holding n rs)
    (ha : w.attempt = some a) (hre : (recheck p w rs).1 = false) :
    fenceTxn p w = { w with phase := .noMutation n (recheck p w rs).2 } := by
  simp [fenceTxn, hph, ha, hp, hre]

/-- `OPS-42`: "Extension first: the worker's read sees the new commitment, `OPS-41` applies, and
it makes no provider call at all." With the read inside the fence transaction, an extension the
store admitted before it is what the re-check reads; where that grown commitment funds the
machine at the rate the worker holds, the transaction decides no mutation, writes no fence, and the
provider call is inert. -/
@[req "OPS-42"]
theorem extension_first (p : Params) (hp : p.recheckInsideFence = true) (w : World)
    (n : ClaimNumber) (r : Nat) (a : Attempt) (hph : w.phase = .holding n (some r))
    (hr : w.rate = some r) (ha : w.attempt = some a) (hs : w.suspended = false)
    (hk : p.suspensionKey = .currentState) (sats : Nat) (hf : w.m.fence = none)
    (hb : sats ≤ w.balance)
    (hfunded : p.abort (w.m.commitment + sats) w.prot r = true) :
    ∃ d, (fenceTxn p (extend p w sats)).phase = .noMutation n d ∧
    (fenceTxn p (extend p w sats)).m.fence = none ∧
    (fenceTxn p (extend p w sats)).m.commitment = w.m.commitment + sats ∧
    ∀ applied reply,
      providerDelete (fenceTxn p (extend p w sats)) applied reply = fenceTxn p (extend p w sats) := by
  have hc : (extend p w sats).m.commitment = w.m.commitment + sats := by
    unfold extend; simp only [extend_guard w sats hs hf hb]; (repeat' split) <;> simp_all [writeDate]
  obtain ⟨hph', ha', hs', hprot', hnow', hf', -⟩ := extend_frame p w sats
  have hre : (recheck p (extend p w sats) (some r)).1 = false := by
    simp [recheck, exempt, hk, hs', hs, readRate, hc, hprot', hfunded]
  have hft := fenceTxn_abort p hp (extend p w sats) n (some r) a (hph'.trans hph) (ha'.trans ha) hre
  refine ⟨_, by rw [hft], ?_, ?_, ?_⟩
  · rw [hft]; simpa using hf'.trans hf
  · rw [hft]; simpa using hc
  · intro applied reply; rw [hft]; simp [providerDelete]

/-- `LDG-62`'s refusal: with the fence set, an extension changes nothing — no commitment, no
balance, no date. -/
@[req "LDG-62"]
theorem extend_refused_under_fence (p : Params) (w : World) (h : Holder) (hf : w.m.fence = some h)
    (sats : Nat) : extend p w sats = w := by
  simp [extend, hf]

/-- `OPS-42`: "Fence first: the extension is refused, and the customer keeps its satoshis." A fence
transaction whose re-check lets the cancellation through and wins the write leaves the fence
holding this attempt, and every extension after it is `extend_refused_under_fence`'s: the
commitment and the balance are what the re-check read. -/
@[req "OPS-42"]
theorem fence_first (p : Params) (hp : p.recheckInsideFence = true) (w : World)
    (n : ClaimNumber) (rs : Option Nat) (a : Attempt) (hph : w.phase = .holding n rs)
    (ha : w.attempt = some a) (hproceed : (recheck p w rs).1 = true)
    (hadmit : fenceAdmits p w a = true) (sats : Nat) :
    (fenceTxn p w).phase = .fenced n ∧
    (fenceTxn p w).m.fence = some (p.holder a) ∧
    extend p (fenceTxn p w) sats = fenceTxn p w ∧
    (fenceTxn p w).m.commitment = w.m.commitment ∧ (fenceTxn p w).balance = w.balance := by
  have hft : fenceTxn p w =
      { w with m := { w.m with fence := some (p.holder a) }, phase := .fenced n } := by
    simp [fenceTxn, hph, ha, hp, hproceed, writeFence, hadmit]
  refine ⟨by simp [hft], by simp [hft], ?_, by simp [hft], by simp [hft]⟩
  exact extend_refused_under_fence p _ (p.holder a) (by simp [hft]) sats

/-! ## Destruction only after a fence transaction whose re-check let it through -/

/-- The `destroyed` flag flips in one step only: a provider call that applied, from `fenced`. -/
@[req "OPS-41"]
theorem destroyed_only_by_provider_from_fenced (p : Params) (w : World) (e : Event)
    (h : (step p w e).m.destroyed = true) (hw : w.m.destroyed = false) :
    ∃ n reply, e = .providerDelete true reply ∧ w.phase = .fenced n := by
  cases e with
  | advance seconds => exfalso; simp [step, hw] at h
  | rederive d obs => exfalso; unfold step rederive at h; (repeat' split at h) <;> simp_all
  | restoreGrace t => exfalso; unfold step restoreGrace at h; (repeat' split at h) <;> simp_all
  | providerDelete applied reply =>
    simp only [step] at h
    unfold providerDelete at h
    split at h
    · rename_i n hph
      split at h
      · cases applied
        · simp [hw] at h
        · exact ⟨n, reply, rfl, hph⟩
      · simp [hw] at h
    · simp [hw] at h
  | sweep => exfalso; unfold step sweep enqueue applyRow at h; (repeat' split at h) <;> simp_all
  | claim => exfalso; unfold step claimStep at h; (repeat' split at h) <;> simp_all
  | fenceTxn =>
    exfalso; unfold step fenceTxn writeFence at h; (repeat' split at h) <;> simp_all
  | fenceWrite =>
    exfalso; unfold step fenceWrite writeFence at h; (repeat' split at h) <;> simp_all
  | extend s =>
    exfalso; obtain ⟨-, -, -, -, -, -, -, -, -, -, hd⟩ := extend_frame p w s
    rw [step, hd] at h; simp_all
  | settle =>
    exfalso; unfold step settle writeAbortDate finish applyRow at h
    (repeat' split at h) <;> simp_all [writeDate]
  | retry => exfalso; unfold step retry at h; (repeat' split at h) <;> simp_all
  | goneWrite => exfalso; unfold step goneWrite applyRow at h; (repeat' split at h) <;> simp_all
  | suspend => exfalso; unfold step suspend enqueue at h; (repeat' split at h) <;> simp_all
  | resume => exfalso; simp [step, resume] at h; simp_all
  | rateLost => exfalso; simp [step, rateLost] at h; simp_all
  | rateRestored r => exfalso; simp [step, rateRestored] at h; simp_all
  | outageBound =>
    exfalso; unfold step outageBound enqueue at h; (repeat' split at h) <;> simp_all

/-- Under `current`'s one-transaction rule, `fenced` is entered by the fence transaction alone,
from `holding`, on a machine whose re-check let it through — `OPS-41`: "after claiming the machine
(`OPS-8`) and before any provider mutation, re-read that machine's commitment and its
`runway_until` — in the same serialized transaction that writes `OPS-42`'s fence" — and it leaves
the fence holding this attempt. With `destroyed_only_by_provider_from_fenced` and
`recheck_proceeds`: destruction only after a fence transaction whose re-check read unfunded, no
rate, or suspended. -/
@[req "OPS-41"]
theorem fenced_only_by_fence_txn (p : Params) (hp : p.recheckInsideFence = true) (w : World)
    (e : Event) (n : ClaimNumber) (h : (step p w e).phase = .fenced n)
    (hw : w.phase ≠ .fenced n) :
    e = .fenceTxn ∧ ∃ rs, w.phase = .holding n rs ∧ (recheck p w rs).1 = true ∧
    ∃ a, w.attempt = some a ∧ (step p w e).m.fence = some (p.holder a) := by
  cases e with
  | advance seconds => exfalso; exact hw (by simpa [step] using h)
  | rederive d obs => exfalso; unfold step rederive at h; (repeat' split at h) <;> simp_all
  | restoreGrace t => exfalso; unfold step restoreGrace at h; (repeat' split at h) <;> simp_all
  | fenceTxn =>
    simp only [step] at h ⊢
    unfold fenceTxn at h ⊢
    split at h
    · rename_i n' rs a hph ha
      simp only [hp, Bool.not_true, Bool.false_eq_true, ↓reduceIte] at h ⊢
      split at h
      · rename_i hproceed
        unfold writeFence at h ⊢
        split at h
        · simp at h; subst h
          exact ⟨by trivial, rs, hph, hproceed, a, ha, by simp [*]⟩
        · simp at h
      · simp at h
    · exact absurd h hw
  | sweep => exfalso; unfold step sweep enqueue applyRow at h; (repeat' split at h) <;> simp_all
  | claim => exfalso; unfold step claimStep at h; (repeat' split at h) <;> simp_all
  | fenceWrite =>
    exfalso; unfold step fenceWrite writeFence at h; (repeat' split at h) <;> simp_all
  | extend s => exfalso; rw [step, (extend_frame p w s).1] at h; exact hw h
  | providerDelete a r =>
    exfalso; unfold step providerDelete at h; (repeat' split at h) <;> simp_all
  | settle =>
    exfalso; unfold step settle writeAbortDate finish applyRow at h
    (repeat' split at h) <;> simp_all
  | retry => exfalso; unfold step retry at h; (repeat' split at h) <;> simp_all
  | goneWrite => exfalso; unfold step goneWrite applyRow at h; (repeat' split at h) <;> simp_all
  | suspend => exfalso; unfold step suspend enqueue at h; (repeat' split at h) <;> simp_all
  | resume => exfalso; simp [step, resume] at h; exact hw h
  | rateLost => exfalso; simp [step, rateLost] at h; exact hw h
  | rateRestored r => exfalso; simp [step, rateRestored] at h; exact hw h
  | outageBound =>
    exfalso; unfold step outageBound enqueue at h; (repeat' split at h) <;> simp_all

/-- What a re-check that lets the cancellation through has read, under `current`'s three keys
(each a hypothesis, so that a flipped key reddens its witness and not this theorem): the tenant
suspended now; no rate, the outage still open for this machine; or a rate — the snapshot's, or
restoration's where the outage write found the record closed — at which the machine is
unfunded. -/
@[req "OPS-41"]
theorem recheck_proceeds (p : Params) (hk : p.suspensionKey = .currentState)
    (hab : p.abortPredicate = .date) (hout : p.outageWrite = true) (w : World) (rs : Option Nat)
    (h : (recheck p w rs).1 = true) :
    w.suspended = true ∨
    (rs = none ∧ w.outageOpen = true) ∨
    ∃ r, readRate p w rs = .derive r ∧ abortDate w.m.commitment w.prot r = false := by
  unfold recheck at h
  split at h
  · left; simpa [exempt, hk] using ‹exempt p w = true›
  · split at h
    · rename_i r hr
      right; right
      exact ⟨r, hr, by simpa [Params.abort, hab] using h⟩
    · rename_i hr
      right; left
      unfold readRate at hr
      split at hr
      · simp at hr
      · simp only [hout, Bool.not_true, Bool.false_or] at hr
        split at hr
        · exact ⟨rfl, by assumption⟩
        · split at hr <;> simp at hr
    · simp at h

/-- Between the fence write and the provider call the machine row, the balance and the worker stay
put: with the fence set and the worker `fenced`, every event but the provider call, gone-write,
re-derivation and restore-grace write leaves them as they are — the sweep enqueues nothing,
joining the open episode at most, the extension is refused, the settlement has nothing to settle.
The gone-write is the one write that moves the fence under a fenced worker, by `ADR-0021`'s design, and `gone_clears_and_closes_together` says
what it does. The added setters are excluded from this whole-row frame: `PRV-13e` requires
"written in the same transaction as the date that observation explains", and `STO-54` requires
"`destroy_not_before` set to the restore instant plus one re-derivation interval". They can
change the date and exhaustion facts, but neither changes the cancellation fence. -/
@[req "OPS-42"]
theorem fenced_waits_for_the_provider (p : Params) (w : World) (n : ClaimNumber) (h : Holder)
    (hph : w.phase = .fenced n) (hf : w.m.fence = some h) (e : Event)
    (he : ∀ applied reply, e ≠ .providerDelete applied reply) (hg : e ≠ .goneWrite)
    (hr : ∀ date observation, e ≠ .rederive date observation)
    (hs : ∀ instant, e ≠ .restoreGrace instant) :
    (step p w e).m = w.m ∧ (step p w e).balance = w.balance ∧ (step p w e).phase = w.phase := by
  cases e with
  | advance seconds => simp [step]
  | rederive d obs => exact absurd rfl (hr d obs)
  | restoreGrace t => exact absurd rfl (hs t)
  | providerDelete a r => exact absurd rfl (he a r)
  | goneWrite => exact absurd rfl hg
  | sweep => unfold step sweep enqueue applyRow; (repeat' split) <;> simp_all
  | claim => simp [step, claimStep, hph]
  | fenceTxn => simp [step, fenceTxn, hph]
  | fenceWrite => unfold step fenceWrite; (repeat' split) <;> simp_all
  | extend s => simp [step, extend, hf]
  | settle => simp [step, settle, hph]
  | retry => simp [step, retry, hph]
  | suspend => unfold step suspend enqueue; (repeat' split) <;> simp_all
  | resume => simp [step, resume]
  | rateLost => simp [step, rateLost]
  | rateRestored r => simp [step, rateRestored]
  | outageBound => unfold step outageBound enqueue; (repeat' split) <;> simp_all

/-! ## The episode: a set fence names it, a close is permanent -/

/-- The machine's open episode's id, where it has one. -/
def World.openEpisodeId (w : World) : Option EpisodeId :=
  match w.episode with
  | some ep => if ep.state.isOpen then some ep.id else none
  | none => none

/-- `OPS-42`'s fence is "`machines.destroy_committed` set to its episode's id" and `OPS-48` clears
it "exactly when the episode closes ... and by no other path" (`05-persistence.md`), so a set fence
names an open episode with the same id. Stated as a decidable predicate on a world. -/
def fenceNamesOpenEpisode (w : World) : Bool :=
  match w.m.fence with
  | none => true
  | some (.attempt _) => false
  | some (.episode e) => w.openEpisodeId == some e

/-- Every episode this world has minted has an id below the counter. -/
def idsFresh (w : World) : Bool :=
  w.episode.all fun ep => ep.id.n < w.nextId

/-- An initial world: no fence, no episode. -/
def Init (w : World) : Prop := w.m.fence = none ∧ w.episode = none

/-- Both invariants together, which is what one step has to preserve. -/
def Inv (w : World) : Prop := fenceNamesOpenEpisode w = true ∧ idsFresh w = true

/-- A world that differs only outside the fence, the episode and the counter keeps `Inv`. -/
theorem inv_same (w w' : World) (hf : w'.m.fence = w.m.fence) (he : w'.episode = w.episode)
    (hn : w'.nextId = w.nextId) (hw : Inv w) : Inv w' := by
  unfold Inv fenceNamesOpenEpisode World.openEpisodeId idsFresh at hw ⊢
  rw [hf, he, hn]; exact hw

theorem episodeStep_closed (r : CloseReason) (ev : Tables.Event) :
    episodeStep currentRows (.closed r) ev = (.closed r, false) :=
  closed_absorbing true true false r ev

theorem episodeStep_keeps_open (s : Episode) (ev : Tables.Event) (hs : s.isOpen = true)
    (hc : (episodeStep currentRows s ev).2 = false) :
    (episodeStep currentRows s ev).1.isOpen = true := by
  cases hno : (episodeStep currentRows s ev).1.isOpen with
  | true => rfl
  | false =>
    have h2 : (episodeStep currentRows s ev).2 = true :=
      (fence_cleared_iff_closes true true false s ev).mpr ⟨hs, hno⟩
    rw [hc] at h2
    exact absurd h2 Bool.false_ne_true

theorem fence_none_of_not_open (w : World) (hw : fenceNamesOpenEpisode w = true)
    (hnot : w.episodeOpen = false) : w.m.fence = none := by
  unfold fenceNamesOpenEpisode World.openEpisodeId at hw
  unfold World.episodeOpen at hnot
  split at hw
  · assumption
  · simp at hw
  · exfalso
    cases hE : w.episode <;> simp [hE] at hw hnot
    simp [hnot] at hw

theorem applyRow_inv (w : World) (ep : EpisodeRow) (ev : Tables.Event) (hep : w.episode = some ep)
    (hw : Inv w) : Inv (applyRow w ep ev) := by
  obtain ⟨hw, hi⟩ := hw
  constructor
  · unfold fenceNamesOpenEpisode World.openEpisodeId at hw ⊢
    simp only [applyRow, hep] at hw ⊢
    split at hw
    · rename_i hf; simp [hf]
    · simp at hw
    · rename_i e hf
      cases hc : (episodeStep currentRows ep.state ev).2
      · simp only [Bool.false_eq_true, ↓reduceIte, hf]
        split at hw
        · rename_i hopen
          simp [episodeStep_keeps_open ep.state ev hopen hc]
          simpa using hw
        · simp at hw
      · simp
  · unfold idsFresh at hi ⊢; simp only [applyRow, hep] at hi ⊢; simpa using hi

theorem applyRow_closed (w : World) (ep : EpisodeRow) (ev : Tables.Event) (r : CloseReason)
    (hc : ep.state = .closed r) : (applyRow w ep ev).episode = some ep := by
  cases ep with
  | mk id st rs => simp only at hc; subst hc; simp [applyRow, episodeStep_closed]

theorem enqueue_inv (w : World) (r : Reason) (hw : Inv w) : Inv (enqueue w r) := by
  obtain ⟨hw, hi⟩ := hw
  unfold enqueue
  split
  · constructor
    · unfold fenceNamesOpenEpisode World.openEpisodeId at hw ⊢
      cases hE : w.episode <;> simp [hE] at hw ⊢ <;> exact hw
    · unfold idsFresh at hi ⊢; cases hE : w.episode <;> simp [hE] at hi ⊢; exact hi
  · split
    · rename_i hnot _
      have := fence_none_of_not_open w hw (by simpa using hnot)
      exact ⟨by simp [fenceNamesOpenEpisode, this], by simp [idsFresh]⟩
    · exact ⟨hw, hi⟩

theorem enqueue_closed (w : World) (r : Reason) (hnot : w.episodeOpen = false) :
    (enqueue w r).episode = w.episode ∨
    (enqueue w r).episode = some { id := ⟨w.nextId⟩, state := .attempting, reasons := [r] } := by
  unfold enqueue
  simp only [hnot, Bool.false_eq_true, ↓reduceIte]
  split <;> simp

theorem writeFence_inv (p : Params) (hh : p.fenceHolds = .episodeId)
    (ho : p.fenceOnOpenEpisode = true) (w : World) (n : ClaimNumber) (a : Attempt)
    (d : Option Nat) (hw : Inv w) : Inv (writeFence p w n a d) := by
  unfold writeFence
  split
  · rename_i hadmit
    unfold fenceAdmits at hadmit
    simp only [ho, Bool.not_true, Bool.false_or, Bool.and_eq_true] at hadmit
    refine ⟨?_, (inv_same w _ rfl rfl rfl hw).2⟩
    unfold fenceNamesOpenEpisode World.openEpisodeId
    simp only [Params.holder, hh]
    cases hE : w.episode <;> simp_all
  · exact inv_same w _ rfl rfl rfl hw

theorem claimStep_frame (w : World) :
    (claimStep w).m.fence = w.m.fence ∧ (claimStep w).episode = w.episode ∧
    (claimStep w).nextId = w.nextId := by
  unfold claimStep; (repeat' split) <;> simp

theorem providerDelete_frame (w : World) (applied : Bool) (reply : Option Bool) :
    (providerDelete w applied reply).m.fence = w.m.fence ∧
    (providerDelete w applied reply).episode = w.episode ∧
    (providerDelete w applied reply).nextId = w.nextId := by
  unfold providerDelete; (repeat' split) <;> simp

theorem finish_inv (w : World) (n : ClaimNumber) (a : Attempt) (s : Settled) (wr : Written)
    (hw : Inv w) : Inv (finish w n a s wr) := by
  unfold finish
  split
  · rename_i ep hep
    split
    · exact applyRow_inv _ ep _ (by simpa using hep) (inv_same w _ rfl rfl rfl hw)
    · exact inv_same w _ rfl rfl rfl hw
  · exact inv_same w _ rfl rfl rfl hw

/-- One step preserves both invariants, under the two guards the first needs: the fence holds the
episode id (`fenceHolds`) and the write is guarded on that episode being open
(`fenceOnOpenEpisode`). -/
theorem inv_step (p : Params) (hh : p.fenceHolds = .episodeId) (ho : p.fenceOnOpenEpisode = true)
    (w : World) (hw : Inv w) (e : Event) : Inv (step p w e) := by
  cases e with
  | advance seconds => exact inv_same w _ rfl rfl rfl hw
  | rederive d obs =>
    simp only [step]; unfold rederive; (repeat' split) <;> exact inv_same w _ rfl rfl rfl hw
  | restoreGrace t =>
    simp only [step]; unfold restoreGrace; (repeat' split) <;> exact inv_same w _ rfl rfl rfl hw
  | sweep =>
    simp only [step]; unfold sweep
    split
    · rename_i ep r hep hr
      split
      · exact applyRow_inv w ep _ hep hw
      · split
        · exact enqueue_inv w _ hw
        · exact hw
    · split
      · exact enqueue_inv w _ hw
      · exact hw
  | claim =>
    obtain ⟨h1, h2, h3⟩ := claimStep_frame w
    exact inv_same w _ h1 h2 h3 hw
  | fenceTxn =>
    simp only [step]; unfold fenceTxn
    split
    · split
      · exact inv_same w _ rfl rfl rfl hw
      · split
        · exact writeFence_inv p hh ho w _ _ _ hw
        · exact inv_same w _ rfl rfl rfl hw
    · exact hw
  | fenceWrite =>
    simp only [step]; unfold fenceWrite
    split
    · split
      · exact writeFence_inv p hh ho w _ _ _ hw
      · exact inv_same w _ rfl rfl rfl hw
    · exact hw
  | extend s =>
    obtain ⟨-, -, -, -, -, hf, he, -, -, hn, -⟩ := extend_frame p w s
    exact inv_same w _ hf he hn hw
  | providerDelete a r =>
    obtain ⟨h1, h2, h3⟩ := providerDelete_frame w a r
    exact inv_same w _ h1 h2 h3 hw
  | settle =>
    simp only [step]; unfold settle
    split
    · split
      · exact inv_same _ _ rfl rfl rfl (finish_inv w _ _ _ _ hw)
      · exact finish_inv w _ _ _ _ hw
    · exact finish_inv w _ _ _ _ hw
    · exact hw
  | retry =>
    simp only [step]; unfold retry
    split
    · rename_i a ep hph ha hep
      split
      · obtain ⟨hw, hi⟩ := hw
        constructor
        · unfold fenceNamesOpenEpisode World.openEpisodeId at hw ⊢
          simp only [hep] at hw ⊢
          split at hw <;> simp_all [episodeStep, Episode.isOpen]
        · unfold idsFresh at hi ⊢; simp only [hep] at hi ⊢; simp at hi ⊢; omega
      · exact hw
    · exact hw
  | goneWrite =>
    simp only [step]; unfold goneWrite
    split
    · rename_i ep hep
      exact applyRow_inv _ ep _ (by simpa using hep) (inv_same w _ rfl rfl rfl hw)
    · exact inv_same w _ rfl rfl rfl hw
  | suspend =>
    simp only [step]; unfold suspend
    exact enqueue_inv _ _ (inv_same w _ rfl rfl rfl hw)
  | resume => exact inv_same w _ rfl rfl rfl hw
  | rateLost => exact inv_same w _ rfl rfl rfl hw
  | rateRestored r => exact inv_same w _ rfl rfl rfl hw
  | outageBound =>
    simp only [step]; unfold outageBound
    split
    · exact enqueue_inv w _ hw
    · exact hw

theorem inv_run (p : Params) (hh : p.fenceHolds = .episodeId) (ho : p.fenceOnOpenEpisode = true)
    (w : World) (hw : Inv w) (es : List Event) : Inv (run p w es) := by
  induction es generalizing w with
  | nil => exact hw
  | cons e es ih => exact ih (step p w e) (inv_step p hh ho w hw e)

theorem inv_init (w : World) (h0 : Init w) : Inv w :=
  ⟨by simp [fenceNamesOpenEpisode, h0.1], by simp [idsFresh, h0.2]⟩

/-- A set fence names an open episode with the same id, over every state reachable from an
initial world, under `OPS-42`'s two guards: `fenceHolds = .episodeId` (2026-09-08) and
`fenceOnOpenEpisode` (2026-09-09). Each guard's witness shows the invariant broken without it. -/
@[req "OPS-42"]
theorem fence_names_open_episode (p : Params) (hh : p.fenceHolds = .episodeId)
    (ho : p.fenceOnOpenEpisode = true) (w0 : World) (h0 : Init w0) (es : List Event) :
    fenceNamesOpenEpisode (run p w0 es) = true :=
  (inv_run p hh ho w0 (inv_init w0 h0) es).1

/-- One step on a closed episode: it is untouched, or superseded by a fresh one opened
`attempting` under the counter's next id. Nothing puts a closed episode back in an open state. -/
theorem closed_step (p : Params) (hg : p.retryGuard = true) (w : World) (ep : EpisodeRow)
    (hep : w.episode = some ep) (r : CloseReason) (hc : ep.state = .closed r) (e : Event) :
    (step p w e).episode = some ep ∨
    ∃ r', (step p w e).episode = some { id := ⟨w.nextId⟩, state := .attempting, reasons := [r'] } := by
  have hnot : w.episodeOpen = false := by simp [World.episodeOpen, hep, hc, Episode.isOpen]
  cases e with
  | advance seconds => left; exact hep
  | rederive d obs => left; simp only [step]; unfold rederive; (repeat' split) <;> exact hep
  | restoreGrace t => left; simp only [step]; unfold restoreGrace; (repeat' split) <;> exact hep
  | sweep =>
    simp only [step]; unfold sweep
    split
    · rename_i ep' r' hep' hr
      rw [hep] at hep'; obtain rfl := Option.some.inj hep'
      split
      · rename_i hst; simp [hc] at hst
      · split
        · rcases enqueue_closed w .exhausted hnot with h | h
          · left; rw [h, hep]
          · right; exact ⟨_, h⟩
        · left; exact hep
    · split
      · rcases enqueue_closed w .exhausted hnot with h | h
        · left; rw [h, hep]
        · right; exact ⟨_, h⟩
      · left; exact hep
  | claim => left; rw [step, (claimStep_frame w).2.1]; exact hep
  | fenceTxn =>
    left; simp only [step]; unfold fenceTxn writeFence; (repeat' split) <;> simpa using hep
  | fenceWrite =>
    left; simp only [step]; unfold fenceWrite writeFence; (repeat' split) <;> simpa using hep
  | extend s =>
    left; obtain ⟨-, -, -, -, -, -, he, -, -, -, -⟩ := extend_frame p w s
    rw [step, he]; exact hep
  | providerDelete a rp => left; rw [step, (providerDelete_frame w a rp).2.1]; exact hep
  | settle =>
    left
    have hfin : ∀ n a s wr, (finish w n a s wr).episode = some ep := by
      intro n a s wr
      unfold finish
      split
      · rename_i ep' hep'
        rw [hep] at hep'; obtain rfl := Option.some.inj hep'
        split
        · exact applyRow_closed _ ep _ r hc
        · simpa using hep
      · simpa using hep
    simp only [step]; unfold settle
    split
    · split
      · unfold writeAbortDate; simpa using hfin _ _ _ _
      · exact hfin _ _ _ _
    · exact hfin _ _ _ _
    · exact hep
  | retry =>
    left; simp only [step]; unfold retry
    split
    · rename_i a ep' hph ha hep'
      rw [hep] at hep'; obtain rfl := Option.some.inj hep'
      split
      · rename_i hst; simp [hc, hg] at hst
      · exact hep
    · exact hep
  | goneWrite =>
    left; simp only [step]; unfold goneWrite
    split
    · rename_i ep' hep'
      rw [hep] at hep'; obtain rfl := Option.some.inj hep'
      exact applyRow_closed _ ep _ r hc
    · simpa using hep
  | suspend =>
    simp only [step]; unfold suspend
    rcases enqueue_closed { w with suspended := true } .tenantSuspended
        (by simpa [World.episodeOpen] using hnot) with h | h
    · left; rw [h]; exact hep
    · right; exact ⟨_, h⟩
  | resume => left; simpa [step, resume] using hep
  | rateLost => left; simpa [step, rateLost] using hep
  | rateRestored r' => left; simpa [step, rateRestored] using hep
  | outageBound =>
    simp only [step]; unfold outageBound
    split
    · rcases enqueue_closed w .rateOutageBound hnot with h | h
      · left; rw [h, hep]
      · right; exact ⟨_, h⟩
    · left; exact hep

/-- `ADR-0021`: "A close is permanent." Over every reachable state, an episode that is closed is
never changed under its id by any event: what carries that id afterwards is the same row. A
later episode is a fresh row under a fresh id, so a stale attempt settling under the old one
"changes the attempt and not the episode" (`OPS-48`). Needs `retryGuard`, the 2026-09-09
conditional write: a plain `retry` write reopens a closed episode (`retry_guard_witness`). -/
@[req "OPS-48"]
theorem closed_absorbing_in_lifecycle (p : Params) (hh : p.fenceHolds = .episodeId)
    (ho : p.fenceOnOpenEpisode = true) (hg : p.retryGuard = true) (w0 : World) (h0 : Init w0)
    (es : List Event)
    (ep : EpisodeRow) (hep : (run p w0 es).episode = some ep) (r : CloseReason)
    (hc : ep.state = .closed r) (e : Event) (ep' : EpisodeRow)
    (hep' : (step p (run p w0 es) e).episode = some ep') (hid : ep'.id = ep.id) : ep' = ep := by
  have hfresh := (inv_run p hh ho w0 (inv_init w0 h0) es).2
  rcases closed_step p hg _ ep hep r hc e with h | ⟨r', h⟩
  · rw [h] at hep'; exact (Option.some.inj hep').symm
  · rw [h] at hep'
    obtain rfl := Option.some.inj hep'
    simp only [idsFresh, hep, Option.all_some] at hfresh
    simp only at hid
    rw [← hid] at hfresh
    simp at hfresh

/-- A stale attempt — one whose episode is not the machine's — cannot take the fence: under the
open-episode term its write affects no row, and it aborts. -/
@[req "OPS-42"]
theorem stale_attempt_refused (p : Params) (ho : p.fenceOnOpenEpisode = true) (w : World)
    (a : Attempt) (ep : EpisodeRow) (hep : w.episode = some ep) (hne : ep.id ≠ a.ep) :
    fenceAdmits p w a = false := by
  simp [fenceAdmits, ho, hep, hne]

/-- Nor can its settlement touch the episode or the fence: `finish` writes `OPS-48`'s row on the
attempt's own episode, and where that is not the machine's, the row is not there to write. -/
@[req "OPS-48"]
theorem stale_attempt_settles_alone (w : World) (n : ClaimNumber) (a : Attempt) (s : Settled)
    (wr : Written) (ep : EpisodeRow) (hep : w.episode = some ep) (hne : ep.id ≠ a.ep) :
    (finish w n a s wr).episode = w.episode ∧ (finish w n a s wr).m.fence = w.m.fence := by
  simp [finish, hep, hne]

/-- `ADR-0021`: the gone-write "closes its open episode `resource_gone` and clears the fence, in
that transaction", from every open state, and records the machine gone. -/
@[req "OPS-48"]
theorem gone_clears_and_closes_together (w : World) (ep : EpisodeRow) (hep : w.episode = some ep)
    (hopen : ep.state.isOpen = true) :
    (goneWrite w).m.fence = none ∧
    (goneWrite w).episode = some { ep with state := .closed .resourceGone } ∧
    (goneWrite w).m.gone = true := by
  have := gone_closes_and_clears ep.state hopen
  simp [goneWrite, applyRow, hep, this]

/-- `OPS-48`: under the conditional write, `retry` is "admissible in no other state" than
`stalled` — on any other episode, or with no episode, it changes nothing. -/
@[req "OPS-48"]
theorem retry_only_from_stalled_in_lifecycle (p : Params) (hg : p.retryGuard = true) (w : World)
    (h : ∀ ep, w.episode = some ep → ep.state ≠ .stalled) : retry p w = w := by
  unfold retry
  split
  · rename_i a ep _ _ hep
    have := h ep hep
    simp [this, hg]
  · rfl

end Provisiond.Fence
