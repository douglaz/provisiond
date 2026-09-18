import Provisiond.Claim
import Provisiond.Tables
/-! `STO-54`'s restore beside `STO-5`'s restart: "A restore from backup is not a restart and is
not covered by this sentence". A live engine commits a `History` of steps on a `Store` and
crashes; what it comes up on is either that store (`RestartTrace`) or a store `Δ` steps behind it
with the provider's facts unchanged (`RestoreTrace`). The two are distinct types, so a theorem
over restart traces cannot be cited for a restore; `restore_breaks_soundness` (in the witnesses)
is the concrete trace on which `OPS-15`'s premise — "any `running` row at startup is interrupted",
and a `queued` row never ran — is false.

The four fault events the inventory names: a crash ends a `History` (the store is what it
committed); `restart` and `restore` are `Fault`'s constructors, each the boot of its own trace
type, and `Δ` is `RestoreTrace.delta`; the complete procedure is `Event.completeProcedure`,
`STO-54`'s step (3). The procedure's phases are `Permissions`, one field per thing the engine or
`api` may do — claim, serve, record absence, run each component — never one Boolean, computed
from the fault the engine came up on and the steps done.

`Params` lists the guards dated amendments added, each a field so that removing it is a one-token
change a witness theorem exercises (`ADR-0025`). Every model here is one tenant, one machine, one
engine (`OPS-47`), and time does not advance: `now` is the restore instant.

What the model omits: `Provisiond.Reconcile`'s knowledge type — absence here is the machine's
`recordedGone` Boolean, and `OPS-32`'s own three conjuncts (a complete pass, `PRV-36`'s window,
the direct reread) are that module's, so on a restart the sweep records an absence on a complete
pass alone; a crash inside the procedure, which `STO-54` does not address (`pv-5yf`), so no fault
is an `Event`; `STO-54`'s step (1) beyond the freeze and `LDG-16`'s grace (the published window,
the account status and the rate quorum) and step (3) beyond the credential bump (the watch set,
the rails, `SEC-39`'s counters, the derivation index); the operator cancelling a waiting parent,
which `Event.confirmParents` stands for beside confirming it; the sweep's per-account report; and
everything after the procedure that touches the stored date — the tenant extending again inside
the grace (`LDG-62`), the second derivation `LDG-16` waits for and the routing at the interval's
end (`Provisiond.Fence` has those) — so the grace is stated as the column set, and
`lost_extension_not_rebuilt` says the procedure writes no date, not that nothing ever does. -/

namespace Provisiond.Restore
open Provisiond.Claim Provisiond.Tables

/-- How the engine came up. `STO-5`'s restart: the same store the crash left. `STO-54`'s restore:
a store landed "at some instant `T − Δ` before the failure". -/
inductive Fault
  | restart
  | restore
  deriving DecidableEq, Repr

def Fault.isRestore : Fault → Bool
  | .restart => false
  | .restore => true

/-- One operation row and the provider's fact about it: `applied` is whether the provider applied
the call this row ordered. The provider's fact is not in the store, and no restore rewinds it. -/
structure Op where
  kind    : Kind
  status  : Status
  applied : Bool
  deriving DecidableEq, Repr

/-- The one machine: its stored date, `LDG-16`'s column, and whether the sweep recorded it gone. -/
structure Machine where
  runwayUntil    : Nat
  exhaustedSince : Option Nat
  recordedGone   : Bool
  deriving DecidableEq, Repr

/-- The store: the operations by id — a total function, so an id nobody wrote holds what the
initial store said — the machine, and the tenant's credential generation (`API-56`). -/
structure Store where
  ops           : OperationId → Op
  machine       : Machine
  credentialGen : Nat

def Store.modify (s : Store) (i : OperationId) (f : Op → Op) : Store :=
  { s with ops := fun j => if j = i then f (s.ops j) else s.ops j }

/-- The live engine's committed steps: the claim, the provider applying the call, the settlement,
`LDG-62`'s extension writing a date, `API-56`'s revocation bumping the generation. -/
inductive Live
  | claim (i : OperationId)
  | apply (i : OperationId)
  | settle (i : OperationId) (w : Written)
  | extend (date : Nat)
  | revoke
  deriving DecidableEq, Repr

def liveStep (s : Store) : Live → Store
  | .claim i => s.modify i fun o => if o.status = .queued then { o with status := .running } else o
  | .apply i => s.modify i fun o => if o.status = .running then { o with applied := true } else o
  | .settle i w =>
    s.modify i fun o => if o.status = .running then { o with status := w.status } else o
  | .extend d => { s with machine := { s.machine with runwayUntil := d } }
  | .revoke => { s with credentialGen := s.credentialGen + 1 }

/-- The live run up to the crash: an initial store and the steps committed on it, in order. -/
structure History where
  initial : Store
  steps   : List Live

/-- The store after the first `k` steps — what a backup taken then holds. -/
def History.at (h : History) (k : Nat) : Store := (h.steps.take k).foldl liveStep h.initial

/-- The store the crash left. -/
def History.final (h : History) : Store := h.steps.foldl liveStep h.initial

/-- `STO-5`'s trace: the engine comes up on `History.final`. -/
structure RestartTrace where
  history : History

/-- `STO-54`'s trace: the backup holds the store `delta` steps before the crash, the provider's
facts are the crash's, and `now` is the restore instant. -/
structure RestoreTrace where
  history : History
  delta   : Nat
  now     : Nat

/-- The restored store: every row as the backup held it, with `applied` as the provider holds it. -/
@[req "STO-54"]
def RestoreTrace.store (t : RestoreTrace) : Store :=
  let old := t.history.at (t.history.steps.length - t.delta)
  let new := t.history.final
  { old with ops := fun j => { old.ops j with applied := (new.ops j).applied } }

/-- `OPS-15`'s premise, as a property of a store: a `queued` row never ran. -/
def Store.sound (s : Store) : Prop :=
  ∀ j, (s.ops j).status = .queued → (s.ops j).applied = false

/-- One live step keeps the premise: a claim precedes the call, and the call precedes nothing
that returns a row to `queued`. -/
theorem liveStep_sound (s : Store) (e : Live) (h : s.sound) : (liveStep s e).sound := by
  cases e with
  | claim i =>
    intro j
    simp only [liveStep, Store.modify]
    split
    · split
      · simp
      · exact h j
    · exact h j
  | apply i =>
    intro j
    simp only [liveStep, Store.modify]
    split
    · split
      · intro hq; simp_all
      · exact h j
    · exact h j
  | settle i w =>
    intro j
    simp only [liveStep, Store.modify]
    split
    · split
      · cases w <;> simp [Written.status]
      · exact h j
    · exact h j
  | extend d => exact h
  | revoke => exact h

theorem foldl_sound (s : Store) (steps : List Live) (h : s.sound) :
    (steps.foldl liveStep s).sound := by
  induction steps generalizing s with
  | nil => exact h
  | cons e es ih => exact ih _ (liveStep_sound s e h)

/-- `STO-5`: the store a restart comes up on keeps the premise — "no loss of queued or running
operations" means a `queued` row is one that never ran, and a `running` one is interrupted. -/
@[req "STO-5"]
theorem restart_store_sound (t : RestartTrace) (h : t.history.initial.sound) :
    t.history.final.sound :=
  foldl_sound _ _ h

/-! ## The procedure -/

/-- What `STO-54`'s step (1) freezes and what it does not: "exactly five things are frozen,
because starting either component to reconcile starts everything it hosts — the exhaustion sweep,
`LDG-64`'s canceller, `API-34`'s time-to-live sweep, `STO-14`'s and `STO-43`'s retention, and
`OPS-15`'s `suspend_tenant` exception"; "`OPS-27`'s and `OPS-32`'s sweeps, the meter,
re-derivation, the solvency check and the settlement watcher are not frozen". -/
inductive Component
  | exhaustionSweep | outageCanceller | ttlSweep | retention | suspendTenantException
  | resolutionSweep | accountSweep | meter | rederivation | solvencyCheck | settlementWatcher
  deriving DecidableEq, Repr

def Component.all : List Component :=
  [.exhaustionSweep, .outageCanceller, .ttlSweep, .retention, .suspendTenantException,
   .resolutionSweep, .accountSweep, .meter, .rederivation, .solvencyCheck, .settlementWatcher]

theorem Component.mem_all (c : Component) : c ∈ Component.all := by cases c <;> decide

instance {p : Component → Prop} [DecidablePred p] : Decidable (∀ c, p c) :=
  decidableForallOfList Component.all Component.mem_all p

/-- `STO-54`'s freeze, as a total table. -/
@[req "STO-54"]
def frozenOnRestore : Component → Bool
  | .exhaustionSweep | .outageCanceller | .ttlSweep | .retention | .suspendTenantException => true
  | .resolutionSweep | .accountSweep | .meter | .rederivation | .solvencyCheck
  | .settlementWatcher => false

/-- "exactly five things are frozen". -/
@[req "STO-54"]
theorem frozen_exactly_five : (Component.all.filter frozenOnRestore).length = 5 := by decide

/-- `STO-54`'s step (2), the partition `OPS-15` carries: "every `queued` create, install and
rescue inventory is moved to `needs_reconciliation` — a repeat is a second order, a second disk
write, a second boot into rescue"; "the goal-state kinds (delete, power, end-rescue, release
attachment, reverse DNS) re-run". A `refresh` is read-only (`OPS-11`) and re-runs; a
`suspend_tenant` parent is neither — it waits, below. -/
@[req "OPS-15"]
def irreversible : Kind → Bool
  | .createMachine | .install | .rescueInventory => true
  | .deleteMachine | .power | .releaseAttachment | .reverseDns | .refresh | .suspendTenant => false

/-- The dated amendments this module carries. `quarantineOnRestore`: `OPS-15`, 2026-09-12, "on a
restore (`STO-54`) the pass additionally moves every `queued` create, install and rescue inventory
to `needs_reconciliation`". `exceptionFrozen`: `OPS-15`, 2026-09-12, "the `suspend_tenant`
exception below does not fire on a restore". `bumpOnRestore`: `STO-54`, 2026-09-12, "every
tenant's credential generation is bumped". `twoPassAbsence`: `STO-54`, 2026-09-12, "The first pass
may record nothing about absence". -/
structure Params where
  quarantineOnRestore : Bool
  exceptionFrozen     : Bool
  bumpOnRestore       : Bool
  twoPassAbsence      : Bool
  deriving DecidableEq, Repr

/-- The procedure as it stands. One field per line: `ci.yml`'s controls flip one each. -/
@[req "STO-54"]
def current : Params := {
    quarantineOnRestore := true,
    exceptionFrozen     := true,
    bumpOnRestore       := true,
    twoPassAbsence      := true }

structure World where
  fault            : Fault
  store            : Store
  /-- The restore instant. Time does not advance. -/
  now              : Nat
  /-- `STO-51`'s startup lock taken: `STO-54`'s step (1) done. -/
  locked           : Bool
  /-- `OPS-15`'s pass run: step (2) done. -/
  passDone         : Bool
  /-- Step (3) done: "the freeze lifts when step (3) completes". -/
  procedureComplete : Bool
  /-- Complete `OPS-32` passes since the engine came up. -/
  completePasses   : Nat
  /-- `PRV-36`'s effective window has elapsed since the first complete pass. -/
  windowElapsed    : Bool
  /-- The operator "has confirmed or cancelled every waiting parent". -/
  parentsConfirmed : Bool
  /-- An irreversible kind claimed after the provider had applied it: the second order. -/
  secondOrder      : Bool
  /-- The credential generations `api` served a request under. -/
  servedGens       : List Nat
  /-- A `suspend_tenant` parent claimed on a restore before the operator confirmed it. -/
  parentResumedUnconfirmed : Bool

/-- The procedure's phases, each its own permission. -/
structure Permissions where
  claim         : Bool
  serve         : Bool
  recordAbsence : Bool
  run           : Component → Bool

/-- What the engine and `api` may do, from the fault and the steps done. On a restart everything
but the claim — which `OPS-15` puts after the pass, and `STO-51` after the lock — is permitted at
once. On a restore: the claim after step (2), a request after step (3), an absence on a second
complete pass after the window, a frozen component when step (3) completes — "except the
exception, which stays off until the operator has confirmed or cancelled every waiting parent",
read as a second condition beside step (3), not a substitute for it. -/
@[req "STO-54"]
def permits (p : Params) (w : World) : Permissions :=
  match w.fault with
  | .restart =>
    { claim := w.locked && w.passDone, serve := true, recordAbsence := true, run := fun _ => true }
  | .restore =>
    { claim := w.locked && w.passDone,
      serve := w.procedureComplete,
      recordAbsence := !p.twoPassAbsence || (decide (1 ≤ w.completePasses) && w.windowElapsed),
      run := fun c => match c with
        | .suspendTenantException =>
          !p.exceptionFrozen || (w.procedureComplete && w.parentsConfirmed)
        | c => !frozenOnRestore c || w.procedureComplete }

/-- `OPS-15`'s pass on one row. `running`: a `refresh` "MUST be settled `failed`"; a
`suspend_tenant` parent "MUST be returned to `queued`" on a restart and on a restore "waits for
operator confirmation" — left `running` here until `Event.confirmParents`; every other kind to
`needs_reconciliation`. `queued`: untouched on a restart; on a restore the irreversible kinds
are quarantined. -/
@[req "OPS-15"]
def passOp (p : Params) (f : Fault) (o : Op) : Op :=
  match o.status, o.kind with
  | .running, .refresh => { o with status := .failed }
  | .running, .suspendTenant =>
    if f.isRestore && p.exceptionFrozen then o else { o with status := .queued }
  | .running, _ => { o with status := .needsReconciliation }
  | .queued, k =>
    if f.isRestore && p.quarantineOnRestore && irreversible k then
      { o with status := .needsReconciliation }
    else o
  | _, _ => o

inductive Event
  /-- Step (1): the startup lock, with `LDG-16`'s grace — "every machine whose stored
  `runway_until` has passed has `exhausted_since` set to the restore instant", whatever the
  column held: an older value is a deficiency the sweep would route at once. -/
  | lock
  /-- Step (2): `OPS-15`'s pass. -/
  | startupPass
  /-- Step (3): the credential bump. -/
  | completeProcedure
  /-- The engine claims row `i`. -/
  | claim (i : OperationId)
  /-- `api` receives a request under a token of generation `gen`. -/
  | request (gen : Nat)
  /-- An `OPS-32` pass over the account: complete or interrupted, the machine listed or not. -/
  | sweep (complete listed : Bool)
  | windowElapses
  /-- The operator "has confirmed or cancelled every waiting parent" the pass found. -/
  | confirmParents
  deriving DecidableEq, Repr

def step (p : Params) (w : World) : Event → World
  | .lock =>
    let m := w.store.machine
    let m' := if w.fault.isRestore && decide (m.runwayUntil ≤ w.now)
              then { m with exhaustedSince := some w.now } else m
    { w with locked := true, store := { w.store with machine := m' } }
  | .startupPass =>
    if w.locked then
      { w with passDone := true,
               store := { w.store with ops := fun j => passOp p w.fault (w.store.ops j) } }
    else w
  | .completeProcedure =>
    if w.fault.isRestore && w.passDone then
      { w with procedureComplete := true,
               store := { w.store with credentialGen :=
                 if p.bumpOnRestore then w.store.credentialGen + 1 else w.store.credentialGen } }
    else w
  | .claim i =>
    let o := w.store.ops i
    let perm := permits p w
    if perm.claim && o.status = .queued
        && (o.kind ≠ .suspendTenant || perm.run .suspendTenantException) then
      { w with store := w.store.modify i fun o => { o with status := .running },
               secondOrder := w.secondOrder || (irreversible o.kind && o.applied),
               parentResumedUnconfirmed := w.parentResumedUnconfirmed
                 || (o.kind = .suspendTenant && w.fault.isRestore && !w.parentsConfirmed) }
    else w
  | .request gen =>
    if (permits p w).serve && gen = w.store.credentialGen then
      { w with servedGens := gen :: w.servedGens }
    else w
  | .sweep complete listed =>
    if w.locked && (permits p w).run .accountSweep then
      let m := w.store.machine
      let m' := if complete && !listed && (permits p w).recordAbsence
                then { m with recordedGone := true } else m
      { w with completePasses := if complete then w.completePasses + 1 else w.completePasses,
               store := { w.store with machine := m' } }
    else w
  | .windowElapses => { w with windowElapsed := w.windowElapsed || decide (1 ≤ w.completePasses) }
  | .confirmParents =>
    if w.passDone then
      { w with parentsConfirmed := true,
               store := { w.store with ops := fun j =>
                 let o := w.store.ops j
                 if o.status = .running ∧ o.kind = .suspendTenant then { o with status := .queued }
                 else o } }
    else w

def run (p : Params) (w : World) (evs : List Event) : World := evs.foldl (step p) w

def boot (f : Fault) (s : Store) (now : Nat) : World :=
  { fault := f, store := s, now := now, locked := false, passDone := false, procedureComplete := false,
    completePasses := 0, windowElapsed := false, parentsConfirmed := false, secondOrder := false,
    servedGens := [], parentResumedUnconfirmed := false }

/-- `STO-5`: the engine comes up on the store the crash left. -/
@[req "STO-5"]
def bootRestart (t : RestartTrace) : World := boot .restart t.history.final 0

/-- `STO-54`: the engine comes up on the restored store, at the restore instant. -/
@[req "STO-54"]
def bootRestore (t : RestoreTrace) : World := boot .restore t.store t.now

/-! ## Restart: the pass is sound on its premise -/

/-- No `queued` row of an irreversible kind has run. -/
def World.safe (w : World) : Prop :=
  ∀ j, (w.store.ops j).status = .queued → irreversible (w.store.ops j).kind = true →
    (w.store.ops j).applied = false

theorem step_fault (p : Params) (w : World) (e : Event) : (step p w e).fault = w.fault := by
  cases e <;> simp only [step] <;> (try split) <;> (try split) <;> rfl

/-- An invariant every step keeps, every run keeps. -/
theorem run_preserves (p : Params) (I : World → Prop) (hI : ∀ w e, I w → I (step p w e))
    (w : World) (hw : I w) (evs : List Event) : I (run p w evs) := by
  induction evs generalizing w with
  | nil => exact hw
  | cons e es ih => exact ih _ (hI w e hw)

theorem passOp_kind (p : Params) (f : Fault) (o : Op) : (passOp p f o).kind = o.kind := by
  obtain ⟨k, st, a⟩ := o
  cases st <;> cases k <;> simp [passOp] <;> split <;> rfl

theorem passOp_restart_queued (p : Params) (o : Op)
    (h : (passOp p .restart o).status = .queued) :
    passOp p .restart o = o ∨ o.kind = .suspendTenant := by
  obtain ⟨k, st, a⟩ := o
  cases st <;> cases k <;> simp_all [passOp, Fault.isRestore]

theorem step_safe_restart (p : Params) (w : World) (hf : w.fault = .restart) (hs : w.safe)
    (hn : w.secondOrder = false) (e : Event) :
    (step p w e).safe ∧ (step p w e).secondOrder = false := by
  cases e with
  | lock => exact ⟨hs, hn⟩
  | startupPass =>
    simp only [step]
    split
    · refine ⟨fun j hq hi => ?_, hn⟩
      simp only [hf] at hq hi ⊢
      rw [passOp_kind] at hi
      rcases passOp_restart_queued p _ hq with h | h
      · rw [h] at hq ⊢; exact hs j hq hi
      · simp [h, irreversible] at hi
    · exact ⟨hs, hn⟩
  | completeProcedure => simp only [step, hf, Fault.isRestore]; exact ⟨hs, hn⟩
  | claim i =>
    simp only [step]
    split
    · rename_i hc
      simp only [Bool.and_eq_true, decide_eq_true_eq] at hc
      refine ⟨fun j hq hi => ?_, ?_⟩
      · simp only [Store.modify] at hq hi ⊢
        by_cases hji : j = i
        · simp [hji] at hq
        · simp only [hji, if_false] at hq hi ⊢
          exact hs j hq hi
      · simp only [hn, Bool.false_or]
        by_cases hi : irreversible (w.store.ops i).kind = true
        · simp [hi, hs i hc.1.2 hi]
        · simp [Bool.eq_false_iff.mpr hi]
    · exact ⟨hs, hn⟩
  | request gen => simp only [step]; split <;> exact ⟨hs, hn⟩
  | sweep complete listed => simp only [step]; split <;> exact ⟨hs, hn⟩
  | windowElapses => exact ⟨hs, hn⟩
  | confirmParents =>
    simp only [step]
    split
    · refine ⟨fun j hq hi => ?_, hn⟩
      simp only at hq hi ⊢
      by_cases hc : (w.store.ops j).status = .running ∧ (w.store.ops j).kind = .suspendTenant
      · rw [if_pos hc] at hi
        simp [hc.2, irreversible] at hi
      · simp only [hc, if_false] at hq hi ⊢
        exact hs j hq hi
    · exact ⟨hs, hn⟩

/-- `OPS-15`'s pass, stated over restart traces only: from a sound store, however the engine
runs, no irreversible kind is ordered twice — a `queued` row never ran, and the pass moves every
`running` one out of the engine's reach. The restore trace type has no such theorem;
`restore_breaks_soundness` in the witnesses is why. -/
@[req "OPS-15"]
theorem restart_never_reorders (p : Params) (t : RestartTrace) (h : t.history.initial.sound)
    (evs : List Event) : (run p (bootRestart t) evs).secondOrder = false :=
  (run_preserves p (fun w => w.fault = .restart ∧ w.safe ∧ w.secondOrder = false)
    (fun w e ⟨hf, hs, hn⟩ => ⟨by rw [step_fault]; exact hf, step_safe_restart p w hf hs hn e⟩)
    (bootRestart t) ⟨rfl, fun j hq _ => restart_store_sound t h j hq, rfl⟩ evs).2.2

/-! ## Restore: quarantine before the first claim -/

/-- No `queued` row is of an irreversible kind: step (2) has run. -/
def World.quarantined (w : World) : Prop :=
  ∀ j, (w.store.ops j).status = .queued → irreversible (w.store.ops j).kind = false

theorem passOp_restore_quarantines (p : Params) (hq : p.quarantineOnRestore = true)
    (o : Op) (h : (passOp p .restore o).status = .queued) :
    irreversible (passOp p .restore o).kind = false := by
  rw [passOp_kind]
  obtain ⟨k, st, a⟩ := o
  cases st <;> cases k <;> simp_all [passOp, Fault.isRestore, irreversible]

theorem step_quarantined_restore (p : Params) (hq : p.quarantineOnRestore = true) (w : World)
    (hf : w.fault = .restore) (hs : w.passDone = true → w.quarantined)
    (hn : w.secondOrder = false) (e : Event) :
    ((step p w e).passDone = true → (step p w e).quarantined) ∧
    (step p w e).secondOrder = false := by
  cases e with
  | lock => exact ⟨hs, hn⟩
  | startupPass =>
    simp only [step]
    split
    · refine ⟨fun _ j hj => ?_, hn⟩
      simp only [hf] at hj ⊢
      exact passOp_restore_quarantines p hq _ hj
    · exact ⟨hs, hn⟩
  | completeProcedure =>
    simp only [step]
    split
    · exact ⟨fun hp j => hs (by simpa using hp) j, hn⟩
    · exact ⟨hs, hn⟩
  | claim i =>
    simp only [step]
    split
    · rename_i hc
      simp only [permits, hf, Bool.and_eq_true, decide_eq_true_eq] at hc
      refine ⟨fun hp j hq' => ?_, ?_⟩
      · simp only [Store.modify] at hq' ⊢
        by_cases hji : j = i
        · simp [hji] at hq'
        · simp only [hji, if_false] at hq' ⊢
          exact hs hp j hq'
      · simp only [hn, Bool.false_or]
        have := hs hc.1.1.2 i hc.1.2
        simp [this]
    · exact ⟨hs, hn⟩
  | request gen => simp only [step]; split <;> exact ⟨hs, hn⟩
  | sweep complete listed => simp only [step]; split <;> exact ⟨hs, hn⟩
  | windowElapses => exact ⟨hs, hn⟩
  | confirmParents =>
    simp only [step]
    split
    · refine ⟨fun hp j hq' => ?_, hn⟩
      simp only at hq' ⊢
      by_cases hc : (w.store.ops j).status = .running ∧ (w.store.ops j).kind = .suspendTenant
      · rw [if_pos hc]
        simp [hc.2, irreversible]
      · simp only [hc, if_false] at hq' ⊢
        exact hs hp j hq'
    · exact ⟨hs, hn⟩

/-- `STO-54`'s step (2), "before the first claim": with the quarantine, however the engine
runs and whatever the lost interval held, no irreversible kind is ordered twice. The claim is
permitted only after the pass, and the pass leaves no irreversible kind `queued`. -/
@[req "OPS-15"]
theorem quarantine_before_first_claim (p : Params) (hq : p.quarantineOnRestore = true)
    (t : RestoreTrace) (evs : List Event) :
    (run p (bootRestore t) evs).secondOrder = false :=
  (run_preserves p
    (fun w => w.fault = .restore ∧ (w.passDone = true → w.quarantined) ∧ w.secondOrder = false)
    (fun w e ⟨hf, hs, hn⟩ =>
      ⟨by rw [step_fault]; exact hf, step_quarantined_restore p hq w hf hs hn e⟩)
    (bootRestore t) ⟨rfl, fun h => by simp [bootRestore, boot] at h, rfl⟩ evs).2.2

/-! ## Restore: the credential bump before the first request -/

theorem step_gen_restore (p : Params) (hb : p.bumpOnRestore = true) (g : Nat) (w : World)
    (hf : w.fault = .restore)
    (hg : (w.procedureComplete = false → w.store.credentialGen = g) ∧
          (w.procedureComplete = true → g < w.store.credentialGen))
    (hs : g ∉ w.servedGens) (e : Event) :
    ((step p w e).procedureComplete = false → (step p w e).store.credentialGen = g) ∧
    ((step p w e).procedureComplete = true → g < (step p w e).store.credentialGen) ∧
    g ∉ (step p w e).servedGens := by
  cases e with
  | lock => exact ⟨hg.1, hg.2, hs⟩
  | startupPass => simp only [step]; split <;> exact ⟨hg.1, hg.2, hs⟩
  | completeProcedure =>
    simp only [step]
    split
    · refine ⟨by simp, fun _ => ?_, hs⟩
      dsimp only
      by_cases hr : w.procedureComplete = true
      · have := hg.2 hr; omega
      · have := hg.1 (by simpa using hr); omega
    · exact ⟨hg.1, hg.2, hs⟩
  | claim i => simp only [step]; split <;> exact ⟨hg.1, hg.2, hs⟩
  | request gen =>
    simp only [step]
    split
    · rename_i hc
      simp only [permits, hf, Bool.and_eq_true, decide_eq_true_eq] at hc
      obtain ⟨hr, hgen⟩ := hc
      refine ⟨hg.1, hg.2, ?_⟩
      have := hg.2 hr
      simp only [List.mem_cons, not_or]
      exact ⟨by omega, hs⟩
    · exact ⟨hg.1, hg.2, hs⟩
  | sweep complete listed => simp only [step]; split <;> exact ⟨hg.1, hg.2, hs⟩
  | windowElapses => exact ⟨hg.1, hg.2, hs⟩
  | confirmParents => simp only [step]; split <;> exact ⟨hg.1, hg.2, hs⟩

/-- `STO-54`'s step (3), "before the first `api` request": with the bump, a token of the
generation the backup held — which is the generation a revocation inside the interval had
replaced — is served by no run of the procedure. A request is permitted only after step (3),
and step (3) leaves the restored generation behind. -/
@[req "STO-54"]
theorem bumped_before_first_request (p : Params) (hb : p.bumpOnRestore = true)
    (t : RestoreTrace) (evs : List Event) :
    t.store.credentialGen ∉ (run p (bootRestore t) evs).servedGens :=
  (run_preserves p
    (fun w => w.fault = .restore ∧
      ((w.procedureComplete = false → w.store.credentialGen = t.store.credentialGen) ∧
       (w.procedureComplete = true → t.store.credentialGen < w.store.credentialGen)) ∧
      t.store.credentialGen ∉ w.servedGens)
    (fun w e ⟨hf, hg, hs⟩ =>
      have := step_gen_restore p hb _ w hf hg hs e
      ⟨by rw [step_fault]; exact hf, ⟨this.1, this.2.1⟩, this.2.2⟩)
    (bootRestore t)
    ⟨rfl, ⟨fun _ => rfl, fun h => by simp [bootRestore, boot] at h⟩, by simp [bootRestore, boot]⟩
    evs).2.2

/-! ## Restore: absence on the second pass only -/

theorem step_absence_restore (p : Params) (ht : p.twoPassAbsence = true) (w : World)
    (hf : w.fault = .restore)
    (hi : w.store.machine.recordedGone = true → 2 ≤ w.completePasses ∧ w.windowElapsed = true)
    (hw : w.windowElapsed = true → 1 ≤ w.completePasses) (e : Event) :
    ((step p w e).store.machine.recordedGone = true →
      2 ≤ (step p w e).completePasses ∧ (step p w e).windowElapsed = true) ∧
    ((step p w e).windowElapsed = true → 1 ≤ (step p w e).completePasses) := by
  cases e with
  | lock =>
    refine ⟨fun h => ?_, hw⟩
    simp only [step] at h
    split at h <;> exact hi h
  | startupPass => simp only [step]; split <;> exact ⟨hi, hw⟩
  | completeProcedure => simp only [step]; split <;> exact ⟨hi, hw⟩
  | claim i => simp only [step]; split <;> exact ⟨hi, hw⟩
  | request gen => simp only [step]; split <;> exact ⟨hi, hw⟩
  | sweep complete listed =>
    simp only [step]
    split
    · dsimp only
      refine ⟨fun h => ?_, fun h => ?_⟩
      · split at h
        · rename_i hc
          simp only [permits, hf, ht, Bool.not_true, Bool.false_or, Bool.and_eq_true,
            decide_eq_true_eq, Bool.not_eq_true'] at hc
          refine ⟨?_, hc.2.2⟩
          simp only [hc.1, ↓reduceIte]
          omega
        · refine ⟨?_, (hi h).2⟩
          have := (hi h).1
          split <;> omega
      · have := hw h
        split <;> omega
    · exact ⟨hi, hw⟩
  | windowElapses =>
    dsimp only [step]
    refine ⟨fun h => ?_, fun h => ?_⟩
    · have := hi h
      exact ⟨this.1, by simp [this.2]⟩
    · simp only [Bool.or_eq_true, decide_eq_true_eq] at h
      rcases h with h | h
      · exact hw h
      · exact h
  | confirmParents => simp only [step]; split <;> exact ⟨hi, hw⟩

/-- `STO-54`: "The first pass may record nothing about absence ... A second pass separated by the
effective window is what may record absence." With the rule, an absence the engine records
was recorded on a pass after the first, with the window elapsed since a complete one. -/
@[req "STO-54"]
theorem no_absence_on_first_pass (p : Params) (ht : p.twoPassAbsence = true) (t : RestoreTrace)
    (h0 : t.store.machine.recordedGone = false) (evs : List Event) :
    (run p (bootRestore t) evs).store.machine.recordedGone = true →
    2 ≤ (run p (bootRestore t) evs).completePasses ∧
    (run p (bootRestore t) evs).windowElapsed = true :=
  (run_preserves p
    (fun w => w.fault = .restore ∧
      (w.store.machine.recordedGone = true → 2 ≤ w.completePasses ∧ w.windowElapsed = true) ∧
      (w.windowElapsed = true → 1 ≤ w.completePasses))
    (fun w e ⟨hf, hi, hw⟩ => ⟨by rw [step_fault]; exact hf, step_absence_restore p ht w hf hi hw e⟩)
    (bootRestore t)
    ⟨rfl, fun h => by simp [bootRestore, boot, h0] at h, fun h => by simp [bootRestore, boot] at h⟩
    evs).2.1

/-! ## Restore: the parent waits -/

theorem step_parent_restore (p : Params) (hx : p.exceptionFrozen = true) (w : World)
    (hf : w.fault = .restore) (hn : w.parentResumedUnconfirmed = false) (e : Event) :
    (step p w e).parentResumedUnconfirmed = false := by
  cases e
  case claim i =>
    simp only [step]
    split
    · rename_i hc
      simp only [permits, hf, hx, Bool.not_true, Bool.false_or, Bool.and_eq_true,
        decide_eq_true_eq, Bool.or_eq_true] at hc
      rcases hc.2 with h | h <;> simp [h, hn]
    · exact hn
  all_goals (simp only [step]; (try split) <;> exact hn)

/-- `OPS-15` on a restore: a `suspend_tenant` parent "waits for operator confirmation and is not
claimed". With the exception frozen, no run of the procedure claims a parent before the operator
confirmed. -/
@[req "OPS-15"]
theorem parent_waits_for_confirmation (p : Params) (hx : p.exceptionFrozen = true)
    (t : RestoreTrace) (evs : List Event) :
    (run p (bootRestore t) evs).parentResumedUnconfirmed = false :=
  (run_preserves p (fun w => w.fault = .restore ∧ w.parentResumedUnconfirmed = false)
    (fun w e ⟨hf, hn⟩ => ⟨by rw [step_fault]; exact hf, step_parent_restore p hx w hf hn e⟩)
    (bootRestore t) ⟨rfl, rfl⟩ evs).2

/-! ## The freeze and the grace -/

/-- "the freeze lifts when step (3) completes, except the exception". -/
@[req "STO-54"]
theorem freeze_lifts_at_step_three (p : Params) (w : World) (hf : w.fault = .restore)
    (hr : w.procedureComplete = true) (c : Component) (hc : c ≠ .suspendTenantException) :
    (permits p w).run c = true := by
  cases c <;> simp_all [permits, frozenOnRestore]

/-- Before step (3), a component runs on a restore exactly when the table does not freeze it. -/
@[req "STO-54"]
theorem frozen_until_step_three (p : Params) (w : World) (hf : w.fault = .restore)
    (hr : w.procedureComplete = false) (c : Component) (hc : c ≠ .suspendTenantException) :
    (permits p w).run c = !frozenOnRestore c := by
  cases c <;> simp_all [permits, frozenOnRestore]

/-- The exception "stays off until the operator has confirmed or cancelled every waiting parent":
with the freeze, it runs on a restore only after step (3) and the confirmation both. -/
@[req "STO-54"]
theorem exception_stays_off_until_confirmed (p : Params) (hx : p.exceptionFrozen = true)
    (w : World) (hf : w.fault = .restore)
    (h : (permits p w).run .suspendTenantException = true) :
    w.procedureComplete = true ∧ w.parentsConfirmed = true := by
  simpa [permits, hf, hx] using h

/-- No event of the procedure writes `runway_until`: the frame `lost_extension_not_rebuilt` (in the
witnesses) rests on. -/
theorem run_runwayUntil (p : Params) (w : World) (evs : List Event) :
    (run p w evs).store.machine.runwayUntil = w.store.machine.runwayUntil :=
  run_preserves p (fun w' => w'.store.machine.runwayUntil = w.store.machine.runwayUntil)
    (fun w' e h => by
      rw [← h]
      cases e <;> simp only [step] <;> (try split) <;> (try split) <;> rfl)
    w rfl evs

end Provisiond.Restore
