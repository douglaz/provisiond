import Provisiond.Meter
import Provisiond.Runway
import Provisiond.Claim
import Provisiond.Tables
import Provisiond.Migration
import Provisiond.Fence
import Provisiond.Restore
import Provisiond.Reconcile
import Provisiond.Ledger
import Provisiond.Funding
import Provisiond.Wire
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
    debits [100, 50] 0 = [100, 50] ∧ Ledger.clamp 30 100 = (30, 70) := by
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

/-! ## Restore

One live history, and the backup predates all of it: the engine claims a create, the provider
applies it and it settles; a delete is claimed, applied and settled; the tenant extends the
machine to 100 and revokes its token; the fan-out parent that was running settles. Then the crash.
Every witness pair here flips one field of `Restore.current`, and each asserts the fields its own
parameter decides, as the fence's do. -/

section Restore
open Provisiond.Restore

/-- Row 0 a `queued` create, row 1 a `running` `suspend_tenant` parent, row 2 a `queued` delete,
every other row a settled refresh the engine never touches. The stored date is already past, and
`exhausted_since` holds an old value a sweep would route on at once. -/
def liveStore : Restore.Store :=
  { ops := fun j =>
      if j = ⟨0⟩ then { kind := .createMachine, status := .queued, applied := false }
      else if j = ⟨1⟩ then { kind := .suspendTenant, status := .running, applied := false }
      else if j = ⟨2⟩ then { kind := .deleteMachine, status := .queued, applied := false }
      else { kind := .refresh, status := .succeeded, applied := true },
    machine := { runwayUntil := 0, exhaustedSince := some 0, recordedGone := false },
    credentialGen := 0 }

/-- The lost interval: nine committed steps, all after the backup. -/
def lostInterval : History :=
  { initial := liveStore,
    steps := [.claim ⟨0⟩, .apply ⟨0⟩, .settle ⟨0⟩ .succeeded, .claim ⟨2⟩, .apply ⟨2⟩,
              .settle ⟨2⟩ .succeeded, .extend 100, .revoke, .settle ⟨1⟩ .succeeded] }

/-- The restore: `Δ = 9`, landed at 50, after the stored date. -/
def restoreTrace : RestoreTrace := { history := lostInterval, delta := 9, now := 50 }

/-- The same store crashed before any step: `STO-5`'s restart. -/
def restartTrace : RestartTrace := { history := { initial := liveStore, steps := [] } }

/-- `STO-54`'s three steps. -/
def procedure : List Restore.Event := [.lock, .startupPass, .completeProcedure]

/-- `STO-5`'s clause, "A restore from backup is not a restart and is not covered by this
sentence": the live store is sound, so `restart_never_reorders` covers every restart on it; the
restored store is not — row 0 is `queued` and the provider applied it — so no restart theorem can
be cited for it. -/
@[req "STO-5"]
theorem restore_breaks_soundness :
    liveStore.sound ∧
    restoreTrace.store.ops ⟨0⟩ = { kind := .createMachine, status := .queued, applied := true } ∧
    ¬ restoreTrace.store.sound := by
  refine ⟨fun j hj => ?_, by decide, fun h => ?_⟩
  · simp only [liveStore] at hj ⊢
    by_cases h0 : j = ⟨0⟩ <;> by_cases h1 : j = ⟨1⟩ <;> by_cases h2 : j = ⟨2⟩ <;> simp_all
  · exact absurd (h ⟨0⟩ (by decide)) (by decide)

/-- `OPS-15`'s 2026-09-12 quarantine: the executed create is `needs_reconciliation` after the
pass, the claim finds nothing to order, and `LDG-16`'s grace is set at the restore instant over
the old value the column held. -/
@[req "OPS-15"]
theorem executed_create_quarantined :
    let w := Restore.run Restore.current (bootRestore restoreTrace)
      [.lock, .startupPass, .claim ⟨0⟩]
    (w.store.ops ⟨0⟩).status = .needsReconciliation ∧ w.secondOrder = false ∧
    w.store.machine.exhaustedSince = some 50 := by decide

/-- Without it — `OPS-15` inspecting `running` rows only — the pass leaves the executed create
`queued`, the claim takes it, and the provider is ordered twice: `ADR-0023`'s "an executed
operation runs twice". -/
@[req "OPS-15"]
theorem executed_create_reordered_without_quarantine :
    (Restore.run { Restore.current with quarantineOnRestore := false } (bootRestore restoreTrace)
      [.lock, .startupPass, .claim ⟨0⟩]).secondOrder = true := by decide

/-- `ADR-0023`'s "a revoked token works again", refused: generation 0 is what the backup holds and
what the revocation inside Δ replaced. Nothing is served before step (3); after it, 0 is refused
and the re-issued 1 is served. -/
@[req "STO-54"]
theorem resurrected_token_refused :
    (Restore.run Restore.current (bootRestore restoreTrace)
      [.lock, .startupPass, .request 0, .completeProcedure, .request 0, .request 1]).servedGens
      = [1] := by decide

/-- Without the bump the restored generation is live again and the revoked token is served. -/
@[req "STO-54"]
theorem resurrected_token_served_without_bump :
    (Restore.run { Restore.current with bumpOnRestore := false } (bootRestore restoreTrace)
      (procedure ++ [.request 0])).servedGens = [0] := by decide

/-- Two complete passes that do not list the machine record nothing — the first because it is
the first, the second because the window has not elapsed since the first — and the pass after
the window records it gone. -/
@[req "STO-54"]
theorem absence_on_second_pass_only :
    let w := Restore.run Restore.current (bootRestore restoreTrace)
      (procedure ++ [.sweep true false, .sweep true false, .windowElapses])
    w.store.machine.recordedGone = false ∧
    (Restore.step Restore.current w (.sweep true false)).store.machine.recordedGone = true := by
  decide

/-- Without the rule the first complete pass records the absence, on a window the restore
narrowed. -/
@[req "STO-54"]
theorem absence_on_first_pass_without_rule :
    (Restore.run { Restore.current with twoPassAbsence := false } (bootRestore restoreTrace)
      (procedure ++ [.sweep true false])).store.machine.recordedGone = true := by decide

/-- The parent waits: `running` after the pass, refused by the claim; `queued` once the operator
confirms, and still refused until step (3) completes; claimed after both. -/
@[req "OPS-15"]
theorem parent_waits_witness :
    let w := Restore.run Restore.current (bootRestore restoreTrace)
      [.lock, .startupPass, .claim ⟨1⟩, .confirmParents, .claim ⟨1⟩]
    let w' := Restore.run Restore.current w [.completeProcedure, .claim ⟨1⟩]
    (Restore.run Restore.current (bootRestore restoreTrace)
      [.lock, .startupPass, .claim ⟨1⟩]).store.ops ⟨1⟩
      = { kind := .suspendTenant, status := .running, applied := false } ∧
    (w.store.ops ⟨1⟩).status = .queued ∧ w.parentResumedUnconfirmed = false ∧
    (w'.store.ops ⟨1⟩).status = .running ∧ w'.parentResumedUnconfirmed = false := by decide

/-- Without the freeze the pass returns the parent to `queued` under the restart exception and
the claim resumes a fan-out the operator may have reversed inside Δ. -/
@[req "OPS-15"]
theorem parent_resumed_without_freeze :
    (Restore.run { Restore.current with exceptionFrozen := false } (bootRestore restoreTrace)
      [.lock, .startupPass, .claim ⟨1⟩]).parentResumedUnconfirmed = true := by decide

/-- On a restart the exception fires — "on a restart it MUST NOT require an operator": the parent
is `queued` after the pass and claimed at once, and the `queued` create is claimed as the
unexecuted work it is. -/
@[req "OPS-15"]
theorem parent_resumes_on_restart :
    let w := Restore.run Restore.current (bootRestart restartTrace)
      [.lock, .startupPass, .claim ⟨1⟩, .claim ⟨0⟩]
    (w.store.ops ⟨1⟩).status = .running ∧ (w.store.ops ⟨0⟩).status = .running ∧
    w.secondOrder = false ∧ w.parentResumedUnconfirmed = false := by decide

/-- `F52` #3 (`STO-54`, `ADR-0023`, 2026-09-12): "an extension lost in Δ is not rebuilt". The
tenant extended to 100 inside the interval, the restored date is 0, the grace sets
`exhausted_since` at the restore instant, and no run of the procedure writes the date back. -/
@[req "STO-54"]
theorem lost_extension_not_rebuilt :
    ∃ t : RestoreTrace, t.history.final.machine.runwayUntil = 100 ∧
      t.store.machine.runwayUntil = 0 ∧
      (Restore.step Restore.current (bootRestore t) .lock).store.machine.exhaustedSince
        = some t.now ∧
      ∀ evs, (Restore.run Restore.current (bootRestore t) evs).store.machine.runwayUntil = 0 :=
  ⟨restoreTrace, by decide, by decide, by decide, fun _ => by rw [run_runwayUntil]; decide⟩

/-- The sentence this requirement and `ADR-0023` carried until 2026-09-12 — the grace as what
"stands between the restore and the destroyed disk" — needs the procedure to give the live date
back. No run of it does, on this trace. -/
@[req "STO-54"]
theorem grace_rebuilds_nothing :
    ¬ ∀ t : RestoreTrace, ∀ evs,
      (Restore.run Restore.current (bootRestore t) evs).store.machine.runwayUntil
        = t.history.final.machine.runwayUntil := by
  intro h
  have := h restoreTrace []
  rw [run_runwayUntil] at this
  exact absurd this (by decide)

/-- The procedure end to end: the goal-state delete re-runs, a complete pass that lists the
machine records nothing, the confirmed parent is claimed, the grace stands, and every component
runs. The model refuses nothing vacuously. -/
@[req "STO-54"]
theorem successful_restore_witness :
    let w := Restore.run Restore.current (bootRestore restoreTrace)
      (procedure ++ [.claim ⟨2⟩, .sweep true true, .confirmParents, .claim ⟨1⟩])
    (w.store.ops ⟨2⟩).status = .running ∧ (w.store.ops ⟨1⟩).status = .running ∧
    w.secondOrder = false ∧ w.parentResumedUnconfirmed = false ∧
    w.store.machine = { runwayUntil := 0, exhaustedSince := some 50, recordedGone := false } ∧
    (∀ c, (permits Restore.current w).run c = true) := by decide

end Restore

/-! ## Reconciliation knowledge

One create, dispatched at 0 with its reply lost; `PRV-36`'s visibility window is 8 (the live
DigitalOcean measurement), `OPS-33`'s negative window 1000. Every witness pair here flips one
field of `Reconcile.current`, and each asserts the fields its own parameter decides, as the
fence's and the restore's do. The absence witnesses advance past both windows or neither, so that
`absenceWindow` decides one witness alone. -/

section Reconcile
open Provisiond.Reconcile

def acct : ProviderAccount := ⟨1⟩
def mach : Candidate := { account := acct, externalId := ⟨7⟩ }

/-- The operation with its outcome unknown: nothing known, the commitment open. -/
def unknownWorld (live : Bool) : Reconcile.World :=
  { now := 0, dispatchedAt := 0, windows := { visibility := 8, negative := 1000 }, live := live,
    knowledge := .unknown, commitment := .open, orderLanded := none, throttled := false,
    retriedIntoThrottle := false, meterStoppedAt := none }

/-- The machine record `OPS-32` sweeps: observed present at attach, its commitment running. -/
def attachedWorld (live : Bool) : Reconcile.World :=
  { unknownWorld live with knowledge := .observedPresent mach }

/-- `OPS-33`'s positive witness: the negative window elapses, the commitment is released, and the
resource is still `unknown` — release is not absence. Then the sweep "MUST continue searching
for the correlator indefinitely afterwards": the match lands, the read finds the machine, and it
is attached with the commitment still closed (`OPS-36`). -/
@[req "OPS-33"]
theorem released_still_unknown :
    let w := Reconcile.run Reconcile.current (unknownWorld true) [.advance 1000, .release]
    let w' := Reconcile.run Reconcile.current w [.search [[mach]], .read .found]
    w.knowledge = .unknown ∧ w.commitment = .closed ∧
    w'.knowledge = .observedPresent mach ∧ w'.commitment = .closed := by decide

/-- Before the negative window the release is refused: a search that finds nothing is not yet a
release either. And past it, an attached machine's running commitment is not "a negative
search" and is not released. -/
@[req "OPS-33"]
theorem release_waits_for_negative_window :
    (Reconcile.run Reconcile.current (unknownWorld true)
      [.advance 999, .search [[]], .release]).commitment = .open ∧
    (Reconcile.run Reconcile.current (attachedWorld true)
      [.advance 2000, .release]).commitment = .open := by decide

/-- `OPS-27`'s 2026-09-05 sentence: the match on a gone Robot machine — "the listing outlives the
machine" — records that the order landed and observes nothing; the read is what attaches. -/
@[req "OPS-27"]
theorem match_is_not_observation :
    let w := Reconcile.run Reconcile.current (unknownWorld false) [.search [[mach], [mach]]]
    w.orderLanded = some mach ∧ w.knowledge = .unknown ∧
    (Reconcile.step Reconcile.current w (.read .found)).knowledge = .observedPresent mach := by
  decide

/-- Without it the match attaches: a machine the provider no longer has, "observed present" on
a listing alone. -/
@[req "OPS-27"]
theorem match_attaches_without_read :
    let w := Reconcile.run { Reconcile.current with readConfirmsMatch := false }
      (unknownWorld false) [.search [[mach], [mach]]]
    w.knowledge = .observedPresent mach ∧ w.live = false := by decide

/-- `OPS-27`'s union, keyed as `OPS-32` keys the machine, "by `(provider_account, external_id)`":
the same key on two channels is one candidate and a match, not a duplicate; the same
`external_id` in two accounts is two. -/
@[req "OPS-27"]
theorem duplicates_keyed_by_account_and_id :
    let other : Candidate := { account := ⟨2⟩, externalId := ⟨7⟩ }
    Reconcile.union [[mach], [mach]] = [mach] ∧
    (Reconcile.step Reconcile.current (unknownWorld true)
      (.search [[mach], [mach]])).knowledge.isDuplicate = false ∧
    (Reconcile.step Reconcile.current (unknownWorld true)
      (.search [[mach], [other, mach]])).knowledge = .multipleCandidates [mach, other] := by decide

/-- `OPS-32`'s positive witness, on a machine the provider terminated: a complete pass past both
windows does not list it, the reread answers `not_found`, and the same pass records the absence,
stops the meter at the observation instant and closes the commitment (`LDG-32`). -/
@[req "OPS-32"]
theorem absence_recorded_witness :
    let w := Reconcile.run Reconcile.current (attachedWorld false)
      [.advance 2000, .sweep true false .notFound]
    w.knowledge = .authoritativeAbsence ∧ w.meterStoppedAt = some 2000 ∧
    w.commitment = .closed := by decide

/-- `OPS-32`'s 2026-09-04 defect, refused: a machine created seconds before the sweep, whose
create the listing "had not yet caught up with", is unlisted and its reread inside the window
answers `not_found`. Nothing is recorded; the next pass has evidence. -/
@[req "OPS-32"]
theorem inside_window_records_nothing :
    let w := Reconcile.run Reconcile.current (attachedWorld true)
      [.advance 7, .sweep true false .notFound]
    w.knowledge = .observedPresent mach ∧ w.meterStoppedAt = none := by decide

/-- Without the window rule the same pass "was recorded gone: `LDG-74` stopped its meter". -/
@[req "OPS-32"]
theorem inside_window_stops_live_meter_without_rule :
    let w := Reconcile.run { Reconcile.current with pastWindowOnly := false } (attachedWorld true)
      [.advance 7, .sweep true false .notFound]
    w.knowledge = .authoritativeAbsence ∧ w.meterStoppedAt = some 7 ∧ w.live = true := by decide

/-- "Pagination is not a snapshot": a complete pass past the window that a live machine moved off
— the reread finds it — records nothing. -/
@[req "OPS-32"]
theorem unlisted_live_machine_reread :
    let w := Reconcile.run Reconcile.current (attachedWorld true)
      [.advance 2000, .sweep true false .found]
    w.knowledge = .observedPresent mach ∧ w.meterStoppedAt = none := by decide

/-- Without the reread the listing is the evidence, and "a running machine is recorded gone, its
meter stopped and its commitment released". -/
@[req "OPS-32"]
theorem unlisted_live_machine_stopped_without_reread :
    let w := Reconcile.run { Reconcile.current with rereadBeforeAbsence := false }
      (attachedWorld true) [.advance 2000, .sweep true false .found]
    w.knowledge = .authoritativeAbsence ∧ w.meterStoppedAt = some 2000 ∧ w.live = true := by
  decide

/-- "An interrupted pass MUST record nothing about absence": the pass yields to `rate_limited`
with the machine on an unread page, and the engine issues no reread into the throttle. -/
@[req "OPS-32"]
theorem interrupted_pass_witness :
    let w := Reconcile.run Reconcile.current (attachedWorld true)
      [.advance 2000, .sweep false false .found]
    w.knowledge = .observedPresent mach ∧ w.throttled = true ∧
    w.retriedIntoThrottle = false := by decide

/-- Without the completeness guard the subset is the account: every unlisted machine is a
candidate, and the engine rereads into the throttle that interrupted it — "retrying into it". -/
@[req "OPS-32"]
theorem interrupted_pass_rereads_into_throttle :
    (Reconcile.run { Reconcile.current with completePassOnly := false } (attachedWorld true)
      [.advance 2000, .sweep false false .found]).retriedIntoThrottle = true := by decide

/-- "It is `PRV-36`'s window and NOT `OPS-33`'s negative window": a machine "the provider
terminated in its first hours" is recorded gone on the first complete pass past the listing lag,
at 20. -/
@[req "OPS-32"]
theorem absence_on_visibility_window :
    (Reconcile.run Reconcile.current (attachedWorld false)
      [.advance 20, .sweep true false .notFound]).meterStoppedAt = some 20 := by decide

/-- Bound to the negative window instead, the same machine goes "on billing its customer for
that whole window": nothing at 20, the meter stopped at 1000. `pastWindowOnly` is pinned so that
this witness decides on `absenceWindow` alone. -/
@[req "OPS-32"]
theorem negative_window_bills_the_gone_machine :
    let p := { Reconcile.current with absenceWindow := .negative, pastWindowOnly := true }
    let w := Reconcile.run p (attachedWorld false) [.advance 20, .sweep true false .notFound]
    w.meterStoppedAt = none ∧
    (Reconcile.run p w [.advance 980, .sweep true false .notFound]).meterStoppedAt
      = some 1000 := by decide

end Reconcile

/-! ## Funding and the tenant lifecycle

One tenant's ledger in `Ledger.Balances`, then the lifecycle in `Funding.World`: tenant 1 enrols
and mints deposit 1; the activation minimum is 100,000; the on-chain finality window is 6. Every
witness pair here flips one field of `Ledger.current` or `Funding.current` and asserts only what
its own parameter decides; the attribution witness settles one payment, so that `keyFrom :=
.deposit` decides the two-rails witness alone. -/

section Funding
open Provisiond.Funding

/-- Balance 100, commitment 30 remaining: the computed debit of 100 exceeds the authority. -/
def seizureBalances : Ledger.Balances := { sum := 100, reserved := 30, deficiency := 0, snapshot := 0 }

/-- `LDG-31`'s clamp: the tenant is debited 30, the commitment reaches zero, 70 is the
operator's, and `available` is what it was. -/
@[req "LDG-31"]
theorem clamp_witness :
    Ledger.step Ledger.current seizureBalances (.usageDebit 100) =
      { sum := 70, reserved := 0, deficiency := 70, snapshot := 0 } ∧
    (Ledger.step Ledger.current seizureBalances (.usageDebit 100)).available =
      seizureBalances.available := by decide

/-- Without it the excess is taken from available balance — `LDG-31`: "It MUST NOT be" — the same
debit takes 100 from the tenant, and `available` falls by the 70 nobody authorized: "the automatic
seizure `ADR-0011` exists to forbid, arriving through the meter". -/
@[req "LDG-31"]
theorem seizure_without_clamp :
    (Ledger.step { Ledger.current with clampAtAuthority := false } seizureBalances
      (.usageDebit 100)).available = 0 := by decide

/-- `LDG-35`'s trace: a top-up of 100, an authorization read, and two commitments of 100 each
committing against it. -/
def skewTrace : List Ledger.Event := [.topup 100, .read, .openCommitment 100, .openCommitment 100]

def zeroBalances : Ledger.Balances := { sum := 0, reserved := 0, deficiency := 0, snapshot := 0 }

/-- Serialized, the second open reads the balance the first one spent and is refused: one
commitment, `available` at zero. -/
@[req "LDG-35"]
theorem serialized_authorization_witness :
    (Ledger.run Ledger.current zeroBalances skewTrace).reserved = 100 ∧
    (Ledger.run Ledger.current zeroBalances skewTrace).available = 0 := by decide

/-- Without it both commit against the one read — "two transactions can each read the same
balance and each commit, leaving twice the balance reserved and one machine unfunded". -/
@[req "LDG-35"]
theorem write_skew_without_serialization :
    let b := Ledger.run { Ledger.current with serializedAuthorization := false } zeroBalances skewTrace
    b.reserved = 200 ∧ b.available = -100 := by decide

def t1 : TenantId := ⟨1⟩
def t2 : TenantId := ⟨2⟩
def d1 : DepositId := ⟨1⟩

def fundWorld : Funding.World :=
  { now := 0, finality := 6, activationMin := 100000, tenants := [], retired := [], deposits := [],
    payments := [], entries := [], deficiencies := [], subject := t1, remaining := 30,
    roundingCredit := 0 }

/-- The rail re-announcing one settlement: "a node replays invoice settlements on reconnect". -/
def replayTrace : List Funding.Event :=
  [.enrol t1, .mint d1 t1 100, .settle d1 ⟨11⟩ .lightning 60000, .settle d1 ⟨11⟩ .lightning 60000]

/-- `STO-31`: the replay is a no-op — one entry, one `payments` row, 60,000 credited. -/
@[req "STO-31"]
theorem replay_credits_once :
    let w := Funding.run Funding.current fundWorld replayTrace
    w.entries.length = 1 ∧ w.payments.length = 1 ∧ sumFor t1 w.entries = 60000 := by decide

/-- `LDG-8`'s key alone, the `payments` row pinned off: the replay is still a no-op. -/
@[req "LDG-8"]
theorem replay_credits_once_by_key :
    let w := Funding.run { Funding.current with paymentRecordUnique := false } fundWorld replayTrace
    w.entries.length = 1 ∧ sumFor t1 w.entries = 60000 := by decide

/-- Keyed on the observation event instead — `LDG-8`'s "generated by the receiving code" — and with
no `payments` row to refuse the reference, "a redelivered payment notification credits twice
under two different keys": the replay mints 60,000. -/
@[req "LDG-8"]
theorem replay_credits_twice_from_observation :
    let w := Funding.run { Funding.current with keyFrom := .observation, paymentRecordUnique := false }
      fundWorld replayTrace
    w.entries.length = 2 ∧ sumFor t1 w.entries = 120000 := by decide

/-- `LDG-55`'s customer, "paying on-chain, waiting, losing patience, and paying over Lightning":
two payments, two references, one deposit. -/
def bothRailsTrace : List Funding.Event :=
  [.enrol t1, .mint d1 t1 100, .settle d1 ⟨21⟩ .lightning 60000, .settle d1 ⟨22⟩ .onchain 60000]

/-- `LDG-56`: "Paying a deposit twice credits twice" — and `LDG-52`: the two 60,000 payments
against the 100,000 minimum activate the tenant, where "the withdrawn per-payment reading left it
pending forever holding 120,000 non-refundable satoshis". -/
@[req "LDG-55"]
theorem second_rail_credited :
    let w := Funding.run Funding.current fundWorld bothRailsTrace
    w.entries.length = 2 ∧ sumFor t1 w.entries = 120000 ∧
    w.tenants = [{ id := t1, status := .active }] := by decide

/-- Keyed on the deposit instead — `STO-31`'s "never from the deposit, which may legitimately
produce two credits" — the second rail's payment is suppressed as a replay, and the customer's
second 60,000 is stranded — `LDG-55`: "which is `LDG-43`'s forbidden outcome reached through an
optimisation". -/
@[req "STO-31"]
theorem second_rail_suppressed_by_deposit_key :
    let w := Funding.run { Funding.current with keyFrom := .deposit } fundWorld bothRailsTrace
    w.entries.length = 1 ∧ sumFor t1 w.entries = 60000 ∧
    w.tenants = [{ id := t1, status := .pending }] := by decide

/-- The deposit expires at 100; at 100 the watcher sees a settlement and then the same payment
is brought to the operator's attention. -/
def expiryTrace : List Funding.Event :=
  [.enrol t1, .mint d1 t1 100, .advance 100, .settle d1 ⟨31⟩ .onchain 5000,
   .lateOnchain d1 ⟨31⟩ 5000]

/-- Expiry in its two senses: the watcher credits nothing at the expired deposit (`LDG-57`), and
the same payment noticed later is credited to the tenant the binding names (`LDG-51`). -/
@[req "LDG-51"]
theorem expiry_ends_watching_not_binding :
    (Funding.run Funding.current fundWorld (expiryTrace.take 4)).entries.length = 0 ∧
    (Funding.run Funding.current fundWorld expiryTrace).entries.map
        (fun e => (e.tenant, e.kind, e.sats, e.deposit)) =
      [(t1, .topup, 5000, some d1)] := by decide

/-- The deposit expires at 200 and its window runs to 206; at 150 the time-to-live reaps the
tenant and a payment settles. -/
def reapTrace : List Funding.Event :=
  [.enrol t1, .mint d1 t1 200, .advance 150, .reap t1, .settle d1 ⟨41⟩ .onchain 60000]

/-- `API-34`: the reap waits for the window, the tenant is live when the payment settles, and the
credit is attributed. -/
@[req "API-34"]
theorem reap_waits_for_window_witness :
    let w := Funding.run Funding.current fundWorld reapTrace
    w.live t1 = true ∧ w.entries.length = 1 ∧ (w.entries.all fun e => !w.unattributed e) = true := by
  decide

/-- Without the floor "a live, correctly-paid, still-watched deposit outlives the tenant it
belongs to — manufacturing `LDG-43`'s stranded payment out of configuration alone": the tenant
is gone, and the payment is recorded — never dropped — unattributed. -/
@[req "API-34"]
theorem stranded_payment_without_window :
    let w := Funding.run { Funding.current with reapWaitsForWindow := false } fundWorld reapTrace
    w.live t1 = false ∧ w.entries.length = 1 ∧ (w.entries.all fun e => w.unattributed e) = true := by
  decide

/-- One payment of 90,000 settles below the minimum; at 300, past the window, the tenant is
reaped; the customer enrols afresh as tenant 2 and the operator attributes the deposit. -/
def attributionTrace : List Funding.Event :=
  [.enrol t1, .mint d1 t1 200, .settle d1 ⟨51⟩ .lightning 90000, .advance 300, .reap t1,
   .enrol t2, .attribution d1 t2]

/-- `WIR-42`: one `correction` pair naming the credit moves 90,000 from the reaped tenant to the
named one and the float is unchanged; the target is persisted; a second call naming another live
tenant appends nothing ("a second call naming a different tenant is `409`, never a re-credit");
and a payment settling afterwards "is credited to that tenant directly as an ordinary `topup`"
(`LDG-43`), which — `WIR-42` — "counts toward `API-35`'s activation minimum like any other". -/
@[req "WIR-42"]
theorem attribution_witness :
    let w := Funding.run Funding.current fundWorld attributionTrace
    let w' := Funding.run Funding.current w
      [.enrol ⟨3⟩, .attribution d1 ⟨3⟩, .lateOnchain d1 ⟨53⟩ 20000]
    w.live t1 = false ∧ sumFor t1 w.entries = 0 ∧ sumFor t2 w.entries = 90000 ∧
    float w.entries = 90000 ∧ w.entries.length = 3 ∧
    (w.entries.drop 1).map (fun e => (e.kind, e.corrects)) =
      [(.correction, some ⟨0⟩), (.correction, some ⟨0⟩)] ∧
    w.deposits = [{ id := d1, tenant := t1, expiresAt := 200, attributedTo := some t2 }] ∧
    w'.entries.length = 4 ∧ (w'.entries.getLast?.map (·.kind)) = some .topup ∧
    sumFor t2 w'.entries = 110000 ∧
    w'.tenants = [{ id := t2, status := .active }, { id := ⟨3⟩, status := .pending }] := by decide

/-- `STO-46`'s row alone, the key pinned to the observation so it refuses nothing: the replay is
a no-op — and so is "a chain re-scan" that "re-reports confirmed outputs" after `WIR-42` moved the
first credit to another tenant, whose ledger holds no key for it: three entries, nothing
minted. -/
@[req "STO-46"]
theorem replay_refused_by_record :
    let p := { Funding.current with keyFrom := .observation }
    let w := Funding.run p fundWorld replayTrace
    let w' := Funding.run p fundWorld (attributionTrace ++ [.lateOnchain d1 ⟨51⟩ 90000])
    w.entries.length = 1 ∧ sumFor t1 w.entries = 60000 ∧
    w'.entries.length = 3 ∧ sumFor t2 w'.entries = 90000 ∧ float w'.entries = 90000 := by decide

/-- `WIR-42`'s 2026-09-05 defect: "Keyed on the bare payment identity, the negative entry collided
with the source tenant's own `topup`, which already holds that identity under the unique
`(tenant_id, idempotency_key)` — so the correction could not insert, on the only route an
orphaned balance has back". `keyFrom` is pinned so that this witness decides on the prefix
alone. -/
@[req "WIR-42"]
theorem attribution_collides_without_prefix :
    let w := Funding.run { Funding.current with correctionPrefix := false, keyFrom := .payment }
      fundWorld attributionTrace
    sumFor t1 w.entries = 90000 ∧ sumFor t2 w.entries = 0 ∧ w.entries.length = 1 ∧
    w.deposits = [{ id := d1, tenant := t1, expiresAt := 200, attributedTo := none }] := by decide

/-- `LDG-31` and `LDG-38` composed, on the 2026-09-02 input: a computed 100 against 30 remaining
posts an entry of 30, a `clamp_overflow` of 70 that absorbed no time, and leaves `r` at what the
recurrence says; the next computed 50 finds nothing left, posts no entry, and books 50 more —
never 120 — with `available` unchanged throughout. -/
@[req "LDG-31"]
theorem clamp_composed_witness :
    let w := Funding.post fundWorld 100
    let w' := Funding.post w 50
    w.entries.map (·.sats) = [-30] ∧ w.remaining = 0 ∧
    w.deficiencies = [{ clampedSats := 70, absorbedSeconds := 0 }] ∧ w.roundingCredit = 0 ∧
    w'.entries.map (·.sats) = [-30] ∧
    w'.deficiencies = [{ clampedSats := 70, absorbedSeconds := 0 },
                       { clampedSats := 50, absorbedSeconds := 0 }] ∧
    w'.available = fundWorld.available := by decide +kernel

end Funding

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

/-! ## Wire canonicalization and redaction

Each of `ci.yml`'s controls flips one field of `Wire.current` and expects exactly one theorem here
red; the admitted-without theorem of each pair sets its field explicitly, so it stays green under
the flip. -/

section Wire
open Provisiond.Wire

/-- `WIR-22`'s body, `{"acknowledge_destruction": true}`, sent to two machines' delete endpoints
under one idempotency key. -/
def deleteBody : Json := .obj (.cons "acknowledge_destruction" (.bool true) .nil)

def deleteOn (machine : String) : Request :=
  { method := .post, target := requestTarget ("/v1/machines/" ++ machine ++ "/actions/delete") none,
    body := deleteBody }

def deleteOnA : Request := deleteOn "a"
def deleteOnB : Request := deleteOn "b"

/-- `WIR-3`: "the same idempotency key reused against a different machine or endpoint would replay
the first call's result instead of conflicting — masking or misapplying a destructive action".
With the endpoint in the preimage, the delete on B conflicts. -/
@[req "WIR-3"]
theorem endpoint_in_fingerprint_witness :
    onKeyReuse Wire.current deleteOnA deleteOnB = .conflict := by decide

/-- Without it — a body-only fingerprint — the delete on B replays the delete on A: B stands, and
the caller holds a `202` saying it is going. -/
@[req "WIR-3"]
theorem endpoint_dropped_replays :
    onKeyReuse { Wire.current with endpointInPreimage := false } deleteOnA deleteOnB = .replay := by
  decide

/-- `WIR-5a` on the two shapes it names: "the origin-form path with its query when one is present
(`/v1/operations?terminal=false&limit=100`), the path alone when none is (`/v1/machines`, never a
trailing `?`)". -/
@[req "WIR-5a"]
theorem request_target_witness :
    requestTarget "/v1/operations" (some "terminal=false&limit=100") =
        "/v1/operations?terminal=false&limit=100" ∧
      requestTarget "/v1/machines" none = "/v1/machines" := by decide

/-- `WIR-17`'s create body with its members in two orders at two depths — `CNF-24`'s shape,
"differing only in JSON key order". -/
def createBody : Json :=
  .obj (.cons "offer_id" (.str "cx22")
       (.cons "acknowledge_purchase" (.bool true)
       (.cons "provider_options"
          (.obj (.cons "location" (.str "fsn1") (.cons "backups" (.bool false) .nil)))
       .nil)))

def createBodyReordered : Json :=
  .obj (.cons "provider_options"
          (.obj (.cons "backups" (.bool false) (.cons "location" (.str "fsn1") .nil)))
       (.cons "acknowledge_purchase" (.bool true)
       (.cons "offer_id" (.str "cx22")
       .nil)))

def createWith (b : Json) : Request :=
  { method := .post, target := requestTarget "/v1/machines" none, body := b }

/-- `API-12`: two values, one canonical form, and the retry replays — reordered at the top level
and one level down, `Json.canonical_eq_of_reorder`'s theorem on a concrete pair. -/
@[req "API-12"]
theorem reordered_at_two_depths_replays :
    createBody ≠ createBodyReordered ∧
      createBody.canonical = createBodyReordered.canonical ∧
      onKeyReuse Wire.current (createWith createBody) (createWith createBodyReordered) = .replay := by
  decide

/-- A live create's row: the payload `STO-9` names beside `STO-50`'s enumerated columns. -/
def secretPayload : Payload :=
  { hostname := "worker-1", sshKeys := ["ssh-ed25519 AAAAC3Nz"], userData := some "#cloud-config",
    postInstall := some "#!/bin/sh", imageUrl := some "https://images.example/x?sig=s3cr3t",
    diskLayout := some "raw", spendingCap := some 100000 }

def secretRow : Wire.Row :=
  { id := ⟨1⟩, tenant := ⟨7⟩, idempotencyKey := "agent-7:create:1", kind := .createMachine,
    status := .running, machine := none, providerAccount := some "hetzner-cloud-1",
    request := some secretPayload, providerIds := [], correlator := some "op-1",
    offerSnapshot := some "cx22", setupFeeSats := some 0, writeStartedAt := none,
    rescueExitedCleanly := none, result := .null, error := .null, revision := 1,
    retryable := false, requestedBy := .caller, systemReason := none, episode := none,
    committedSats := some 72000, createdAt := 0, updatedAt := 0, correlationId := "c-1" }

/-- `STO-50` with the enumeration closed: the summary of the live row is the summary of the purged
one, and nothing in it names the hostname, the keys or the script. -/
@[req "STO-50"]
theorem closed_summary_witness :
    summary Wire.current secretRow = summary Wire.current (purge secretRow) := by decide

/-- Without it — "what was attempted" as the open bucket `F38` found — the whole payload sits in
the record that outlives the purge. -/
@[req "STO-50"]
theorem open_summary_leaks :
    (summary { Wire.current with closedSummary := false } secretRow).attempted =
      some secretPayload := by decide

/-- `API-21`: one view for the live row and the purged row; `WIR-10`'s `poll_after_ms` present on
the running one. -/
@[req "API-21"]
theorem view_witness :
    operationView 5000 secretRow = operationView 5000 (purge secretRow) ∧
      (operationView 5000 secretRow).pollAfterMs = some 5000 ∧
      (operationView 5000 { secretRow with status := .succeeded }).pollAfterMs = none := by
  decide

/-- A provider body with `DOM-6`'s cases: a key containing `Password` in mixed case, a key equal to
`token`, an `api_key` inside an array element, and two keys the rule leaves alone. -/
def providerBody : Json :=
  .obj (.cons "db_Password" (.str "hunter2")
       (.cons "token" (.str "t0k")
       (.cons "name" (.str "worker-1")
       (.cons "keys" (.arr (.cons (.obj (.cons "api_key" (.str "k") (.cons "id" (.num 3) .nil))) .nil))
       .nil))))

def providerBodyRedacted : Json :=
  .obj (.cons "db_Password" marker
       (.cons "token" marker
       (.cons "name" (.str "worker-1")
       (.cons "keys" (.arr (.cons (.obj (.cons "api_key" marker (.cons "id" (.num 3) .nil))) .nil))
       .nil))))

/-- `DOM-6`: "replaced with a redaction marker, recursively through objects and arrays". -/
@[req "DOM-6"]
theorem redaction_witness :
    providerBody.redact = providerBodyRedacted ∧ providerBody.clean = false ∧
      providerBodyRedacted.clean = true := by decide

/-- Tenant 2's machine, with the two provider columns `WIR-11` hides. -/
def machineOfTenantTwo : Owned MachineRow :=
  { owner := ⟨2⟩,
    record := { id := ⟨9⟩, name := "worker-1", externalId := "hz-123456",
                metadata := .obj (.cons "token" (.str "x") .nil) } }

/-- `SEC-8` on the concrete lookup: tenant 1 asking for tenant 2's machine gets what it gets for
no machine; tenant 2 gets the view, without the provider columns. -/
@[req "SEC-8"]
theorem foreign_machine_witness :
    machineLookup ⟨1⟩ (some machineOfTenantTwo) = machineLookup ⟨1⟩ none ∧
      machineLookup ⟨1⟩ (some machineOfTenantTwo) = .notFound ∧
      machineLookup ⟨2⟩ (some machineOfTenantTwo) = .ok { id := ⟨9⟩, name := "worker-1" } := by
  decide

end Wire

end Provisiond.Witnesses
