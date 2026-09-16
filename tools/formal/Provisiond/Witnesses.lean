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
so a witness pair differs on the property and not on the events offered. Each of `ci.yml`'s
controls flips one field of `Fence.current` and expects exactly one theorem here red, so a
witness asserts the fields its own parameter decides and not the ones a neighbour's does. -/

section Fence
open Provisiond.Fence

/-- A machine at the end of its runway on a tenant with balance to extend it: one satoshi per
second, nothing protected, nothing reserved, the stored date already reached, no outage, the
tenant not suspended. -/
def fenceWorld : World :=
  { m := { commitment := 0, runwayUntil := 0, exhaustedSince := none, fence := none,
           destroyed := false, gone := false },
    balance := 1000, now := 0, interval := 60, rate := some 1, prot := 0, suspended := false,
    outageOpen := false, episode := none, attempt := none, phase := .idle, nextId := 1 }

/-- The same tenant's machine funded for a hundred seconds, its stored date written. -/
def fundedWorld : World :=
  { fenceWorld with m := { fenceWorld.m with commitment := 100, runwayUntil := 100 } }

/-- `OPS-41`'s 2026-09-04 input inside the lifecycle: one satoshi at two satoshis per second. -/
def subSecondWorld : World :=
  { fenceWorld with m := { fenceWorld.m with commitment := 1 }, rate := some 2 }

/-- A funded machine whose stored date is stale — a price cut the re-derivation has not yet
written, say — so the sweep routes it and the re-check finds it funded. -/
def staleDateWorld : World :=
  { fenceWorld with m := { fenceWorld.m with commitment := 100 } }

/-- The same machine a hundred seconds on, with `exhausted_since` set at the epoch: older than the
interval, so `LDG-16` routes it. -/
def agedWorld : World :=
  { staleDateWorld with now := 100, m := { staleDateWorld.m with exhaustedSince := some 0 } }

/-- The sweep routes, the worker claims, the fence transaction reads unfunded and wins, the
provider deletes, the attempt settles. -/
def cancellationTrace : List Fence.Event :=
  [.sweep, .claim, .fenceTxn, .fenceWrite, .providerDelete true (some true), .settle]

/-- The sweep routes, the worker claims, the re-check aborts, the attempt settles. -/
def abortTrace : List Fence.Event := [.sweep, .claim, .fenceTxn, .fenceWrite, .settle]

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

/-- `OPS-41`'s 2026-09-05 trace: the tenant is suspended, its fan-out enqueues the delete, the
tenant is resumed and funds the machine before the worker claims, and the worker re-checks. -/
def resumedTenantTrace : List Fence.Event :=
  [.suspend, .resume, .extend 100, .claim, .fenceTxn, .fenceWrite,
   .providerDelete true (some true), .settle]

/-- A suspension's delete on a funded machine, the tenant still suspended at the re-check. -/
def suspendedTenantTrace : List Fence.Event :=
  [.suspend, .claim, .fenceTxn, .fenceWrite, .providerDelete true (some true), .settle]

/-- `OPS-41`'s interleaving: the outage reaches its bound and enqueues the delete, the worker
claims with no rate in its snapshot, the rate returns, and the worker re-checks. -/
def restoredRateTrace : List Fence.Event :=
  [.rateLost, .outageBound, .claim, .rateRestored 1, .fenceTxn, .fenceWrite,
   .providerDelete true (some true), .settle]

/-- The same, with no rate returning: "a bound the outage has not cleared is still the bound". -/
def outageCancelTrace : List Fence.Event :=
  [.rateLost, .outageBound, .claim, .fenceTxn, .fenceWrite, .providerDelete true (some true),
   .settle]

/-- `OPS-42`'s 2026-09-09 race: the gone-write lands "between the claim and this write". -/
def goneRaceTrace : List Fence.Event :=
  [.sweep, .claim, .goneWrite, .fenceTxn, .fenceWrite, .providerDelete true (some true), .settle]

/-- `ADR-0021`'s first hole in the lifecycle: the episode stalled with the fence set, then the
machine recorded gone. -/
def goneAfterStallTrace : List Fence.Event :=
  [.sweep, .claim, .fenceTxn, .fenceWrite, .providerDelete false (some false), .settle, .goneWrite]

/-- A successful cancellation: the machine destroyed and recorded gone, the episode closed
`resource_gone` under its one reason, the fence cleared in that transaction, the row settled
`succeeded` under the number the claim returned, and the next sweep pass enqueues nothing against
it. -/
@[req "OPS-42"]
theorem successful_cancellation_witness :
    let w := run Fence.current fenceWorld cancellationTrace
    w.m = { commitment := 0, runwayUntil := 0, exhaustedSince := none, fence := none,
            destroyed := true, gone := true } ∧
    w.episode = some { id := ⟨1⟩, state := .closed .resourceGone, reasons := [.exhausted] } ∧
    w.attempt = some { op := ⟨2⟩, ep := ⟨1⟩,
                       row := { status := .succeeded, claim := ⟨1⟩, record := 0, revision := 2 } } ∧
    w.phase = .idle ∧ sweep Fence.current w = w := by decide

/-- A successful extension: the commitment grown from available and the re-derived date written,
so the next sweep pass does not route the machine. Without `LDG-62`'s 2026-09-05 date write the
commitment grows and the stored date stays in the past, and the next pass routes the machine the
customer has just funded. -/
@[req "LDG-62"]
theorem successful_extension_witness :
    let w := run Fence.current fenceWorld [.extend 100]
    let w' := run { Fence.current with extendWritesDate := false } fenceWorld [.extend 100]
    w.m = { commitment := 100, runwayUntil := 100, exhaustedSince := none, fence := none,
            destroyed := false, gone := false } ∧
    w.balance = 900 ∧ sweep Fence.current w = w ∧
    w'.m.commitment = 100 ∧ w'.m.runwayUntil = 0 ∧ sweep Fence.current w' ≠ w' := by decide

/-- `OPS-42`'s "Extension first": the worker's read sees the grown commitment, aborts, makes no
provider call, settles `succeeded` closing the episode `funded`, and the customer has what it
paid for. -/
@[req "OPS-42"]
theorem extension_first_witness :
    let w := run Fence.current fenceWorld extensionFirstTrace
    w.m = { commitment := 100, runwayUntil := 100, exhaustedSince := none, fence := none,
            destroyed := false, gone := false } ∧
    w.balance = 900 ∧
    w.episode = some { id := ⟨1⟩, state := .closed .funded, reasons := [.exhausted] } := by decide

/-- `OPS-42`'s "Fence first", on the paid-machine trace under `current`: the read and the write are
one transaction, the extension after it is refused — no commitment, no balance moved — and the
unfunded machine is destroyed. -/
@[req "OPS-42"]
theorem fence_first_witness :
    let w := run Fence.current fenceWorld paidMachineTrace
    w.m = { commitment := 0, runwayUntil := 0, exhaustedSince := none, fence := none,
            destroyed := true, gone := true } ∧
    w.balance = 1000 := by decide

/-- The 2026-09-02 amendment's trace, "the worker reads *unfunded*, the extension commits and grows
the commitment, the worker's `IS NULL` write then succeeds because nothing has touched that
column, and the machine the customer has just paid for is destroyed": with the re-check outside
the fence transaction it is reachable. The customer paid 100 and the disk is gone. -/
@[req "OPS-42"]
theorem paid_machine_deleted_without_recheck_inside_fence :
    let w := run { Fence.current with recheckInsideFence := false } fenceWorld paidMachineTrace
    w.m.commitment = 100 ∧ w.m.destroyed = true ∧ w.balance = 900 := by decide

/-- With the fence holding the episode and the guard's own-id clause, the retry's attempt
"contends on the same id and executes": the machine is destroyed on the second attempt. -/
@[req "OPS-42"]
theorem retry_executes_witness :
    let w := run Fence.current fenceWorld retryTrace
    w.m.destroyed = true ∧
    w.episode = some { id := ⟨1⟩, state := .closed .resourceGone, reasons := [.exhausted] } ∧
    w.attempt = some { op := ⟨3⟩, ep := ⟨1⟩,
                       row := { status := .succeeded, claim := ⟨1⟩, record := 0, revision := 2 } } := by
  decide

/-- The 2026-09-08 amendment's trace, with the column holding the attempt's id — and the same
trace under the guard as it stood until 2026-09-02, "`IS NULL` alone": either way the retry's
write "affected no row, read that as "another actor won", and settled `succeeded` recording that
no mutation was required — resolving the episode on a machine still running and still billing".
The episode closes `funded` on a machine whose stored date is still today. -/
@[req "OPS-42"]
theorem retry_refused_with_attempt_id :
    let w := run { Fence.current with fenceHolds := .attemptId } fenceWorld retryTrace
    let w' := run { Fence.current with ownIdClause := false } fenceWorld retryTrace
    w.m = { commitment := 0, runwayUntil := 0, exhaustedSince := none, fence := none,
            destroyed := false, gone := false } ∧
    w.episode = some { id := ⟨1⟩, state := .closed .funded, reasons := [.exhausted] } ∧
    w'.m.destroyed = false ∧
    w'.episode = some { id := ⟨1⟩, state := .closed .funded, reasons := [.exhausted] } := by decide

/-- `OPS-41`'s 2026-09-04 defect inside the lifecycle: under the date predicate the sub-second
machine is routed, read unfunded, and the worker goes to the provider; under the withdrawn
`usable_sats > 0` it is routed, aborted, settled `succeeded` "saying no mutation was needed",
the episode closed `funded`, the fence cleared — and the machine row is exactly what it was, so
the next pass routes it again and the same trace runs again on a fresh episode, "once per sweep,
each cycle minting a tenant-visible operation that claims to be done". The abort has no fixed
point. -/
@[req "OPS-41"]
theorem withdrawn_predicate_loops_in_lifecycle :
    let p := { Fence.current with abortPredicate := .sats }
    let w := run p subSecondWorld abortTrace
    (run Fence.current subSecondWorld [.sweep, .claim, .fenceTxn, .fenceWrite]).phase =
      .fenced ⟨1⟩ ∧
    w.m = subSecondWorld.m ∧
    w.episode = some { id := ⟨1⟩, state := .closed .funded, reasons := [.exhausted] } ∧
    (run p w abortTrace).m = subSecondWorld.m ∧
    (run p w abortTrace).episode =
      some { id := ⟨3⟩, state := .closed .funded, reasons := [.exhausted] } := by decide

/-- `OPS-41`'s 2026-09-05 date write: the abort re-derives a date a hundred seconds out and
writes it, and clears `exhausted_since` where it was set, so the sweep does not route the machine
again. Without the write, "an abort that re-derived a future date and wrote nothing left the
stored one in the past — so the next pass routed the same machine, the worker aborted again". -/
@[req "OPS-41"]
theorem abort_without_date_write_reroutes :
    let w := run Fence.current staleDateWorld abortTrace
    let w' := run { Fence.current with abortWritesDate := false } staleDateWorld abortTrace
    w.m.runwayUntil = 100 ∧
    w.episode = some { id := ⟨1⟩, state := .closed .funded, reasons := [.exhausted] } ∧
    sweep Fence.current w = w ∧
    (run Fence.current agedWorld abortTrace).m.exhaustedSince = none ∧
    (run Fence.current agedWorld abortTrace).m.runwayUntil = 200 ∧
    w'.m.runwayUntil = 0 ∧ sweep Fence.current w' ≠ w' := by decide

/-- `LDG-16`'s routing, on the stored date and the column: null routes at once; set and older
than one interval routes; set and younger does not; set with no rate does not, "however old" —
and without the 2026-09-05 no-rate clause it does, which is the day's trace: "no derivation ran,
the column aged past one interval, the sweep routed, and `OPS-41` read 'no rate, the cancel
proceeds' — a disk destroyed by one reading". -/
@[req "LDG-16"]
theorem exhausted_since_routing_witness :
    let base := { fenceWorld with now := 100 }
    let aged := { base with m := { base.m with exhaustedSince := some 0 }, rate := none }
    base.routed Fence.current = true ∧
    ({ base with m := { base.m with exhaustedSince := some 30 } }).routed Fence.current = true ∧
    ({ base with m := { base.m with exhaustedSince := some 50 } }).routed Fence.current = false ∧
    aged.routed Fence.current = false ∧
    aged.routed { Fence.current with noRateHoldsExhausted := false } = true ∧
    ({ base with m := { base.m with runwayUntil := 101 } }).routed Fence.current = false := by
  decide

/-- `OPS-41`'s suspension key. Keyed on the tenant's current state, a suspended tenant's funded
machine is cancelled regardless of funding, and a resumed tenant's machine, funded before the
worker claimed, is found funded and kept: the episode closes `funded` under its one reason,
`tenant_suspended`. Keyed on the episode's `reasons` set — "the reason is history" — the same
resumed tenant "still had `tenant_suspended` on the episode, and a later attempt skipped the
funding check and destroyed a machine its live tenant had paid for". -/
@[req "OPS-41"]
theorem suspension_keyed_on_current_state_witness :
    let w := run Fence.current fenceWorld resumedTenantTrace
    let s := run Fence.current fundedWorld suspendedTenantTrace
    let w' := run { Fence.current with suspensionKey := .episodeReasons } fenceWorld
      resumedTenantTrace
    w.m.destroyed = false ∧ w.m.commitment = 100 ∧ w.balance = 900 ∧ w.m.fence = none ∧
    w.episode = some { id := ⟨1⟩, state := .closed .funded, reasons := [.tenantSuspended] } ∧
    s.m.destroyed = true ∧ s.m.commitment = 100 ∧
    w'.m.destroyed = true ∧ w'.balance = 900 := by decide

/-- `OPS-41`'s outage branch. With no rate the cancellation proceeds and the funded machine is
destroyed, "because a bound the outage has not cleared is still the bound". With the rate
restored between the claim and the re-check, the conditional write on this machine's outage
record affects no row, the worker re-derives at the restored rate, and the fleet funded for
months is kept. Without the write the stale snapshot is taken at its word: "workers claim at T+2s
and destroy a fleet that is funded for months". -/
@[req "OPS-41"]
theorem no_rate_cancellation_witness :
    let c := run Fence.current fundedWorld outageCancelTrace
    let w := run Fence.current fundedWorld restoredRateTrace
    let w' := run { Fence.current with outageWrite := false } fundedWorld restoredRateTrace
    c.m.destroyed = true ∧
    c.episode = some { id := ⟨1⟩, state := .closed .resourceGone, reasons := [.rateOutageBound] } ∧
    w.m.destroyed = false ∧ w.m.fence = none ∧
    w.episode = some { id := ⟨1⟩, state := .closed .funded, reasons := [.rateOutageBound] } ∧
    w'.m.destroyed = true := by decide

/-- `ADR-0021`'s gone-write in the lifecycle. On a stalled, fenced episode it closes the episode
`resource_gone` and clears the fence in one step. Racing the fence write, under the 2026-09-09
open-episode term the write affects no row, the worker aborts, and the attempt settles under a
closed episode that stays closed with no fence. Without the term the write is admitted on a
closed episode: the provider is called on a machine already gone, the terminal transaction finds
the episode closed and clears nothing, and "a fence set under a closed episode would clear
never" — every extension is refused, and the invariant that a set fence names an open episode is
false. -/
@[req "OPS-48"]
theorem gone_write_witness :
    let g := run Fence.current fenceWorld goneAfterStallTrace
    let w := run Fence.current fenceWorld goneRaceTrace
    let w' := run { Fence.current with fenceOnOpenEpisode := false } fenceWorld goneRaceTrace
    g.m.fence = none ∧ g.m.gone = true ∧
    g.episode = some { id := ⟨1⟩, state := .closed .resourceGone, reasons := [.exhausted] } ∧
    w.m.fence = none ∧ w.m.destroyed = false ∧
    w.episode = some { id := ⟨1⟩, state := .closed .resourceGone, reasons := [.exhausted] } ∧
    w.attempt = some { op := ⟨2⟩, ep := ⟨1⟩,
                       row := { status := .succeeded, claim := ⟨1⟩, record := 0, revision := 2 } } ∧
    w'.m.fence.isSome = true ∧ w'.m.destroyed = true ∧
    w'.episode = some { id := ⟨1⟩, state := .closed .resourceGone, reasons := [.exhausted] } ∧
    extend Fence.current w' 100 = w' ∧
    fenceNamesOpenEpisode w' = false := by decide

/-- `ADR-0021`'s other guard: `retry` as "a conditional write on `(id, state = stalled)`". After
the gone-write closed the stalled episode, a retry affects no row: the episode stays closed and no
attempt is enqueued. As a plain write it reopens the closed episode `attempting` with a fresh
attempt against a machine recorded gone, and "a close is permanent" is false. -/
@[req "OPS-48"]
theorem retry_guard_witness :
    let w := run Fence.current fenceWorld (goneAfterStallTrace ++ [.retry])
    let w' := run { Fence.current with retryGuard := false } fenceWorld
      (goneAfterStallTrace ++ [.retry])
    w.episode = some { id := ⟨1⟩, state := .closed .resourceGone, reasons := [.exhausted] } ∧
    (w.attempt.map (·.op)) = some ⟨2⟩ ∧
    w'.episode = some { id := ⟨1⟩, state := .attempting, reasons := [.exhausted] } ∧
    (w'.attempt.map (·.op)) = some ⟨3⟩ ∧ w'.m.gone = true := by decide

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
