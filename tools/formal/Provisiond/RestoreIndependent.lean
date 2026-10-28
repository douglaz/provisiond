import Provisiond.Witnesses

/-!
Independent successor-sweep test model, adopted as M-I (pv-8mt4).
The false/false cell disables two global guards. It is not a one-field refutation:
the original skipped-pass model and the independent false/true cell block fresh claims.
The duplicated claim arm is checked against the original for every state and event.
-/
namespace Provisiond.RestoreIndependent

open Provisiond.Restore Provisiond.Witnesses

/-- Global guard for OPS-15's before-any-claim requirement. True is the current policy; false permits claims after lock and the restore step-(2) mark without requiring the per-process pass. It contains no condition on a selected operation, desired stranded status, or desired result. -/
@[req "OPS-15"]
def permitsI (requirePass : Bool) (p : Params) (w : World) : Permissions :=
  { Restore.permits p w with
    claim := w.locked && (!requirePass || w.passDone) &&
      (!w.fault.isRestore || w.stepTwoMarked) }

@[req "OPS-15"]
def stepI (requirePass : Bool) (p : Params) (w : World) : Event → World
  | .claim i =>
    let o := w.store.ops i
    let perm := permitsI requirePass p w
    if perm.claim && o.status = .queued
        && (o.kind ≠ .suspendTenant || perm.run .suspendTenantException) then
      { w with store := w.store.modify i fun o => { o with status := .running },
               secondOrder := w.secondOrder || (irreversible o.kind && o.applied),
               parentResumedUnconfirmed := w.parentResumedUnconfirmed
                 || (o.kind = .suspendTenant && w.fault.isRestore && !w.parentsConfirmed) }
    else w
  | e => Restore.step p w e

@[req "OPS-15"]
def runI (requirePass : Bool) (p : Params) (w : World) (es : List Event) : World :=
  es.foldl (stepI requirePass p) w

@[req "OPS-15"]
def progressTrace : List Event :=
  procedure ++ [.admit ⟨4⟩, .claim ⟨4⟩, .apply ⟨4⟩, .claim ⟨3⟩,
    .crash, .lock, .startupPass, .admit ⟨5⟩, .claim ⟨5⟩, .apply ⟨5⟩]

@[req "OPS-15"]
def initial : World := bootRestore freshWorkTrace

@[req "OPS-15"]
def skipped : Params := { restoredWorkParams with passEveryStartup := false }

-- All-state, all-event equality; no trace or selected-row premise.
@[req "OPS-15"]
theorem I_required_step_eq (p : Params) (w : World) (e : Event) :
    stepI true p w e = Restore.step p w e := by
  cases e <;> simp [stepI, permitsI, Restore.step, Restore.permits]
  all_goals cases w.fault <;> simp

/-- Original one-field mutant: stranded old work, but no later claim or application. -/
@[req "OPS-15"]
theorem original_skipped_pass_blocks :
    let w := Restore.run skipped initial progressTrace
    (w.store.ops ⟨4⟩).status = .running ∧ (w.store.ops ⟨4⟩).applied = true ∧
    (w.store.ops ⟨3⟩).status = .running ∧
    (w.store.ops ⟨5⟩).status = .queued ∧ (w.store.ops ⟨5⟩).applied = false ∧
    w.passDone = false := by decide

/-- passEveryStartup=true, requirePass=true: sweep and actual later work. -/
@[req "OPS-15"]
theorem both_guards_sweep_and_progress :
    let w := runI true restoredWorkParams initial progressTrace
    (w.store.ops ⟨4⟩).status = .needsReconciliation ∧ (w.store.ops ⟨4⟩).applied = true ∧
    (w.store.ops ⟨3⟩).status = .needsReconciliation ∧
    (w.store.ops ⟨5⟩).status = .running ∧ (w.store.ops ⟨5⟩).applied = true := by decide

/-- passEveryStartup=false, requirePass=true: the independent blocked cell stays visible. -/
@[req "OPS-15"]
theorem skipped_pass_required_claim_blocks :
    let w := runI true skipped initial progressTrace
    (w.store.ops ⟨4⟩).status = .running ∧ (w.store.ops ⟨4⟩).applied = true ∧
    (w.store.ops ⟨3⟩).status = .running ∧
    (w.store.ops ⟨5⟩).status = .queued ∧ (w.store.ops ⟨5⟩).applied = false ∧
    w.passDone = false := by decide

/-- passEveryStartup=true, requirePass=false: this trace still sweeps and progresses. -/
@[req "OPS-15"]
theorem pass_only_sweeps_and_progresses :
    let w := runI false restoredWorkParams initial progressTrace
    (w.store.ops ⟨4⟩).status = .needsReconciliation ∧ (w.store.ops ⟨4⟩).applied = true ∧
    (w.store.ops ⟨3⟩).status = .needsReconciliation ∧
    (w.store.ops ⟨5⟩).status = .running ∧ (w.store.ops ⟨5⟩).applied = true := by decide

/-- passEveryStartup=false, requirePass=false: composite harm with both guards off. -/
@[req "OPS-15"]
theorem neither_guard_strands_and_progresses :
    let w := runI false skipped initial progressTrace
    (w.store.ops ⟨4⟩).status = .running ∧ (w.store.ops ⟨4⟩).applied = true ∧
    (w.store.ops ⟨3⟩).status = .running ∧
    (w.store.ops ⟨5⟩).status = .running ∧ (w.store.ops ⟨5⟩).applied = true ∧
    w.passDone = false := by decide

-- CI repairs these fixture controls individually from clean false/false input.
-- Only badEngine reads them; neither the independent matrix nor original witnesses do.
@[req "OPS-15"]
def badRequirePass : Bool := false

@[req "OPS-15"]
def badPassEveryStartup : Bool := false

@[req "OPS-15"]
def badEngine : World :=
  runI badRequirePass { restoredWorkParams with passEveryStartup := badPassEveryStartup }
    initial progressTrace

-- Separate finite assertions let each repair refute exactly its own outcome.
@[req "OPS-15"]
theorem bad_model_later_work :
    (badEngine.store.ops ⟨5⟩).status = .running ∧
    (badEngine.store.ops ⟨5⟩).applied = true := by decide

@[req "OPS-15"]
theorem bad_model_stranded_rows :
    (badEngine.store.ops ⟨4⟩).status = .running ∧
    (badEngine.store.ops ⟨4⟩).applied = true ∧
    (badEngine.store.ops ⟨3⟩).status = .running := by decide

end Provisiond.RestoreIndependent
