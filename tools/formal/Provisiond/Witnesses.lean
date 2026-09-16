import Provisiond.Meter
import Provisiond.Runway
import Provisiond.Claim
import Provisiond.Tables
import Provisiond.Migration
import Provisiond.Fence
/-! Historical defects as executable witnesses. Each one looked correct, was nearly built or was
built, and broke; each is retained here so the trap cannot be re-laid without a red build.

Witnesses over rationals close by `decide +kernel` (`ADR-0025`): plain `decide` gets stuck on
`Std.Rat` normalisation and `native_decide` is refused under `@[req]`. -/

open Std

namespace Provisiond.Witnesses
open Provisiond.Meter Provisiond.Runway Provisiond.Claim Provisiond.Tables

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

/-! ## The cancellation fence

Every trace puts `fenceWrite` after `fenceTxn`. Under `current` the transaction already wrote and
the step is inert; under the split variant it is the write. The one schedule runs both designs,
so a witness pair differs on the property and not on the events offered. -/

section Fence
open Provisiond.Fence

/-- A machine at the end of its runway on a tenant with balance to extend it: one satoshi per
second, nothing protected, nothing reserved, the stored date already reached. -/
def fenceWorld : World :=
  { m := { commitment := 0, runwayUntil := 0, fence := none, destroyed := false },
    balance := 1000, now := 0, rate := 1, prot := 0,
    episode := none, attempt := none, phase := .idle, nextId := 1 }

/-- The sweep routes, the worker claims, the fence transaction reads unfunded and wins, the
provider deletes, the attempt settles. -/
def cancellationTrace : List Fence.Event :=
  [.sweep, .claim, .fenceTxn, .fenceWrite, .providerDelete true (some true), .settle]

/-- The cancellation, with `LDG-62` committing between the fence transaction's read and its
write. -/
def paidMachineTrace : List Fence.Event :=
  [.sweep, .claim, .fenceTxn, .extend 100, .fenceWrite, .providerDelete true (some true), .settle]

/-- The extension lands before the worker's fence transaction. -/
def extensionFirstTrace : List Fence.Event :=
  [.sweep, .claim, .extend 100, .fenceTxn, .fenceWrite, .providerDelete true (some true), .settle]

/-- A first attempt sets the fence, calls the provider and is refused; the attempt settles
`failed` and the episode stalls with the fence kept (`OPS-48`); `retry` issues a fresh attempt on
the same episode, which contends for the fence and executes. -/
def retryTrace : List Fence.Event :=
  [.sweep, .claim, .fenceTxn, .fenceWrite, .providerDelete false (some false), .settle,
   .retry, .claim, .fenceTxn, .fenceWrite, .providerDelete true (some true), .settle]

/-- A successful cancellation: the machine destroyed, the episode closed `resource_gone`, the
fence cleared in that transaction, the row settled `succeeded` under the number the claim
returned. -/
@[req "OPS-42"]
theorem successful_cancellation_witness :
    let w := run Fence.current fenceWorld cancellationTrace
    w.m = { commitment := 0, runwayUntil := 0, fence := none, destroyed := true } ∧
    w.episode = some (⟨1⟩, .closed .resourceGone) ∧
    w.attempt = some { op := ⟨2⟩, ep := ⟨1⟩,
                       row := { status := .succeeded, claim := ⟨1⟩, record := 0, revision := 2 } } ∧
    w.phase = .idle := by decide

/-- A successful extension: the commitment grown from available and the re-derived date written,
so the next sweep pass does not route the machine. -/
@[req "LDG-62"]
theorem successful_extension_witness :
    let w := run Fence.current fenceWorld [.extend 100]
    w.m = { commitment := 100, runwayUntil := 100, fence := none, destroyed := false } ∧
    w.balance = 900 ∧ sweep w = w := by decide

/-- `OPS-42`'s "Extension first": the worker's read sees the grown commitment, aborts, makes no
provider call, settles `succeeded` closing the episode `funded`, and the customer has what it
paid for. -/
@[req "OPS-42"]
theorem extension_first_witness :
    let w := run Fence.current fenceWorld extensionFirstTrace
    w.m = { commitment := 100, runwayUntil := 100, fence := none, destroyed := false } ∧
    w.balance = 900 ∧ w.episode = some (⟨1⟩, .closed .funded) := by decide

/-- `OPS-42`'s "Fence first", on the paid-machine trace under `current`: the read and the write are
one transaction, the extension after it is refused — no commitment, no balance moved — and the
unfunded machine is destroyed. -/
@[req "OPS-42"]
theorem fence_first_witness :
    let w := run Fence.current fenceWorld paidMachineTrace
    w.m = { commitment := 0, runwayUntil := 0, fence := none, destroyed := true } ∧
    w.balance = 1000 := by decide

/-- The 2026-09-02 amendment's trace, "the worker reads *unfunded*, the extension commits and grows
the commitment, the worker's `IS NULL` write then succeeds because nothing has touched that
column, and the machine the customer has just paid for is destroyed": with the re-check outside
the fence transaction it is reachable. The customer paid 100 and the disk is gone. -/
@[req "OPS-42"]
theorem paid_machine_deleted_without_recheck_inside_fence :
    let w := run { Fence.current with recheckInsideFence := false } fenceWorld paidMachineTrace
    w.m = { commitment := 100, runwayUntil := 100, fence := none, destroyed := true } ∧
    w.balance = 900 := by decide

/-- With the fence holding the episode, the retry's attempt "contends on the same id and
executes": the machine is destroyed on the second attempt. -/
@[req "OPS-42"]
theorem retry_executes_witness :
    let w := run Fence.current fenceWorld retryTrace
    w.m.destroyed = true ∧ w.episode = some (⟨1⟩, .closed .resourceGone) ∧
    w.attempt = some { op := ⟨3⟩, ep := ⟨1⟩,
                       row := { status := .succeeded, claim := ⟨1⟩, record := 0, revision := 2 } } := by
  decide

/-- The 2026-09-08 amendment's trace, with the column holding the attempt's id: the retry's
write "affected no row, read that as "another actor won", and settled `succeeded` recording that
no mutation was required — resolving the episode on a machine still running and still billing".
The episode closes `funded` on a machine whose stored date is still today. -/
@[req "OPS-42"]
theorem retry_refused_with_attempt_id :
    let w := run { Fence.current with fenceHolds := .attemptId } fenceWorld retryTrace
    w.m = { commitment := 0, runwayUntil := 0, fence := none, destroyed := false } ∧
    w.episode = some (⟨1⟩, .closed .funded) := by decide

end Fence

/-! ## The closed tables -/

/-- `OPS-45`'s reason for existing (2026-09-02): `RSC-3`'s host-key abort is an `integrity` failure
before the connection, with nothing written and the rescue exited cleanly. Under the marker rule it
is `failed`; under the install row as it stood — the kind column alone — it was
`needs_reconciliation`, "an operator-resolved loss". -/
@[req "OPS-11"]
theorem host_key_abort_witness :
    let abort : Failure := ⟨.integrity, false, .unrecorded, false⟩
    classify currentRules .install abort ⟨false, true⟩ = some .failed ∧
    classify { currentRules with markerRule := false } .install abort ⟨false, true⟩ =
      some .needsReconciliation := by decide

/-- `OPS-11`'s 2026-08-31 amendment: `DELETE` against an already-deleted resource answers `422`,
which the driver maps as the goal state holding. With the row it is `succeeded`; without it, a 4xx
was "the provider rejected the request and did not act" and the delete that succeeded was recorded
`failed` — and `LDG-32` then never closed the commitment. -/
@[req "OPS-11"]
theorem already_deleted_witness :
    let rejection : Failure := ⟨.provider, false, .status4xx, true⟩
    classify currentRules .deleteMachine rejection ⟨true, true⟩ = some .succeeded ∧
    classify { currentRules with goalStateRow := false } .deleteMachine rejection ⟨true, true⟩ =
      some .failed := by decide

/-- `ADR-0021`'s first hole: a machine recorded gone under `API-63`'s termination, its episode
`stalled` with the fence set. With the gone-write row the episode closes `resource_gone` and the
fence clears; without it the episode stays open, "its fence set, in `OPS-26`'s listing forever". -/
@[req "OPS-48"]
theorem termination_leaves_episode_open_witness :
    episodeStep currentRows .stalled .goneWrite = (.closed .resourceGone, true) ∧
    episodeStep { currentRows with goneWriteRow := false } .stalled .goneWrite = (.stalled, false) := by
  decide

/-- `ADR-0021`'s second read: the sweep finds a suspended tenant's stalled machine funded after a
rate rise. With the exemption the episode stays `stalled` and fenced; without it the row "would
have un-fenced it on a rate rise" and closed the episode `funded` on a machine "not kept by being
funded". -/
@[req "OPS-48"]
theorem suspended_sweep_close_witness :
    episodeStep currentRows .stalled (.sweepFunded true) = (.stalled, false) ∧
    episodeStep { currentRows with suspensionExemption := false } .stalled (.sweepFunded true) =
      (.closed .funded, true) := by decide

/-- The edge `DOM-31`'s diagram drew and `ADR-0021` deleted, `stalled --> closed : abandoned`: a
`stalled` episode's attempt is `failed`, "a settled state the resolution verbs cannot reach", so
the verb changes nothing; with the edge restored, an operator could "end an exposure by declaring
it over". -/
@[req "OPS-48"]
theorem abandon_from_stalled_witness :
    episodeStep currentRows .stalled (.resolved .abandoned false) = (.stalled, false) ∧
    episodeStep { currentRows with abandonFromStalled := true } .stalled (.resolved .abandoned false) =
      (.closed .abandoned, true) := by decide

/-- `OPS-3`'s two non-create rows (2026-09-02): with them `applied` on a non-create settles
`succeeded`; without them "every install that failed after entering rescue could be resolved
exactly one way, as a loss" (`OPS-31`) — `abandoned` is the one verb left. On a create `applied` is
no verb under either. -/
@[req "OPS-3"]
theorem non_create_verbs_witness :
    resolve currentResolution false .applied = some .succeeded ∧
    (Verb.all.filter fun v => (resolve { nonCreateVerbs := false } false v).isSome) =
      [.abandoned] ∧
    resolve currentResolution true .applied = none := by decide

/-! ## The migration plan -/

open Provisiond.Migration in
/-- `F52` #2 (`STO-12`, `STO-13`, 2026-09-12): the `CONCURRENTLY` build on a large table has a
home, and it is the standalone migration — constructible under PostgreSQL's rule, and holding
exactly that statement. -/
@[req "STO-12"]
theorem concurrent_build_has_a_home :
    (Migration.standalone (refuses := postgres) (standaloneRule := true)
      (.createIndex true true) rfl rfl).holds (.createIndex true true) := rfl

open Provisiond.Migration in
/-- The same build inside a transactional migration is not a value of the type: the proof field
`ok` would have to say PostgreSQL admits it, and `postgres` says it does not. -/
@[req "STO-12"]
theorem concurrent_build_not_transactional :
    ¬ ∃ ok : ∀ s ∈ [Statement.createIndex true true], postgres s = false,
      (Migration.transactional (standaloneRule := true) [.createIndex true true] ok).holds
        (.createIndex true true) := by
  rintro ⟨ok, _⟩
  have h := ok (.createIndex true true) (List.mem_singleton.mpr rfl)
  simp [postgres] at h

end Provisiond.Witnesses
