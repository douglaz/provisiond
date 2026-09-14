import Provisiond.Meter
import Provisiond.Runway
import Provisiond.Claim
/-! Historical defects as executable witnesses. Each one looked correct, was nearly built or was
built, and broke; each is retained here so the trap cannot be re-laid without a red build.

Witnesses over rationals close by `decide +kernel` (`ADR-0025`): plain `decide` gets stuck on
`Std.Rat` normalisation and `native_decide` is refused under `@[req]`. -/

open Std

namespace Provisiond.Witnesses
open Provisiond.Meter Provisiond.Runway Provisiond.Claim

/-! ## The claim model -/

/-- `OPS-6`'s trace, "stated so it can be checked": execution A claims (number 1) and defers, its
write commits and the reply is lost; execution B claims (number 2); A repeats its defer under
`OPS-49`, still holding 1. -/
def staleDeferTrace (g : Guards) : Row :=
  let r0 : Row := { status := .queued, claim := ⟨0⟩, record := 0, revision := 0 }
  let r1 := (claim true r0).1
  let r2 := defer g r1 ⟨1⟩
  let r3 := (claim true r2).1
  defer g r3 ⟨1⟩

/-- With the claim term, B's operation stays `running` under number 2, at the revision B's claim
wrote. -/
@[req "OPS-6"]
theorem stale_defer_refused :
    staleDeferTrace current = { status := .running, claim := ⟨2⟩, record := 0, revision := 3 } := by
  decide

/-- Without it — the guard as it stood until 2026-09-12 — A's stale defer pulls B's operation back
to `queued` mid-execution: the negative witness for `ADR-0022`'s term. -/
@[req "OPS-6"]
theorem stale_defer_admitted_without_claim_term :
    (staleDeferTrace { current with claimTerm := false }).status = .queued := by decide

/-- A successful execution: claim, settle, done — the number returned is the one the write
carries, the row settles `succeeded`, and `revision` advanced once per status change. The model
refuses nothing vacuously. -/
@[req "OPS-5"]
theorem successful_execution_witness :
    let r0 : Row := { status := .queued, claim := ⟨0⟩, record := 0, revision := 4 }
    let (r1, n) := claim true r0
    n = some ⟨1⟩ ∧
    workerWrite current r1 { written := .succeeded, record := 7, mine := ⟨1⟩ } =
      { status := .succeeded, claim := ⟨1⟩, record := 7, revision := 6 } := by decide

/-- `OPS-22`'s lost-reply repeat on the concrete transaction: the whole-transaction retry posts
100 once and reports `repeated`; the prohibited last-statement retry posts 160. -/
@[req "OPS-49"]
theorem double_post_witness :
    let s : Store := { row := { status := .running, claim := ⟨1⟩, record := 0, revision := 0 },
                       ledger := 0 }
    let t : Txn := { status := { written := .succeeded, record := 7, mine := ⟨1⟩ },
                     money := [40, 60] }
    retryWhole current s t [.committed false, .committed true] =
      ({ row := { status := .succeeded, claim := ⟨1⟩, record := 7, revision := 1 },
         ledger := 100 }, some .repeated) ∧
    (retryLast current s t [.committed false]).1.ledger = 160 := by decide

/-- Exhaustion is not always a thrown-away outcome: a lost reply on the bound's last try leaves
the row written and the money posted once, and the engine exits knowing nothing of it. `OPS-15`'s
`running` guard then finds no row to classify. -/
@[req "OPS-49"]
theorem exhaustion_after_lost_reply :
    let s : Store := { row := { status := .running, claim := ⟨1⟩, record := 0, revision := 0 },
                       ledger := 0 }
    let t : Txn := { status := { written := .succeeded, record := 7, mine := ⟨1⟩ },
                     money := [40, 60] }
    retryWhole current s t [.refused, .committed false] =
      ({ row := { status := .succeeded, claim := ⟨1⟩, record := 7, revision := 1 },
         ledger := 100 }, none) := by decide

/-- `F52` #1 (`LDG-38`, 2026-09-12): 0.4 sat consumed in each of two periods posts `1, 0`
carrying the credit and `1, 1` resetting it. The sentence that said the reset was "in the
customer's favour" was backwards. -/
@[req "LDG-38"]
theorem period_reset_witness :
    debits [2/5, 2/5] 0 = [1, 0] ∧
    postedDebit (2/5) 0 = 1 ∧ postedDebit (2/5) 0 = 1 := by
  decide +kernel

/-- `LDG-38`'s reason for existing: per-tick rounding makes the price depend on the metering
cadence. Sixty one-minute increments of 1/60 sat post one satoshi under the recurrence and sixty
under per-tick `ceil`. -/
@[req "LDG-38"]
theorem per_tick_rounding_witness :
    (debits (List.replicate 60 (1/60)) 0).foldl (· + ·) 0 = 1 ∧
    ((List.replicate 60 ((1:Rat)/60)).map Rat.ceil).foldl (· + ·) 0 = 60 := by
  decide +kernel

/-- `LDG-31`/`LDG-38` (the 2026-09-02 double charge): computed 100 against 30 remaining posts 30
to the tenant and 70 as operator deficiency; the next computed 50 is 50, not 120, because the
recurrence advances on the computed debit and the clamp never touches `r`. -/
@[req "LDG-31"]
theorem clamp_leaves_credit_witness :
    debits [100, 50] 0 = [100, 50] ∧
    min (100 : Int) 30 = 30 ∧ (100 : Int) - min 100 30 = 70 := by
  decide +kernel

/-- `OPS-41` (2026-09-04): the withdrawn `usable_sats > 0` predicate on the historical input. -/
@[req "OPS-41"]
theorem sub_second_runway_witness :
    runwaySeconds 1 0 2 = 0 ∧ abortSats 1 0 2 = true ∧ abortDate 1 0 2 = false := by
  decide

end Provisiond.Witnesses
