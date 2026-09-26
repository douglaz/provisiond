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
import Provisiond.Period
import Provisiond.Wire
import Provisiond.Rescue
import Provisiond.Rehost
import Provisiond.Admission
/-! Historical defects as executable witnesses. Each one looked correct, was nearly built or was
built, and broke; each is retained here so the trap cannot be re-laid without a red build.

Witnesses over rationals close by `decide +kernel` (`ADR-0025`): plain `decide` gets stuck on
`Std.Rat` normalisation and `native_decide` is refused under `@[req]`. The exceptions are
`increment_replay_refused_by_key`, `mark_discards_what_the_key_admits`,
`boundary_resets_the_credit`, `straddle_split_at_the_boundary` and
`late_subject_shares_the_boundary`, which close by `with_unfolding_all decide`: each is the
witness a `ci.yml` row must see refuted, refuted `decide +kernel` reports an instance that "did not
reduce", and the row's check needs `decide` to have "proved that the proposition" false. -/

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
  { m := { commitment := 0, runwayUntil := 0, fence := none,
           destroyed := false, gone := false },
    balance := 1000, now := 0, rate := some 1, prot := 0, suspended := false,
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

/-- The stale-date machine with a cancellation enqueued against it at `50` — an earlier pass's, or
`API-58`'s fan-out's — and the trace's own sweep pass fifty seconds later, at `100`. What it
traps: the sweep joins the open episode and enqueues nothing, and the abort's date write is
derived at the re-check's own clock, `OPS-41`'s "write that re-derived `runway_until` to the
machine row" — a hundred seconds of runway from `100`, so `200`, where a date derived from the
enqueue would be `150`. -/
def agedWorld : World :=
  { enqueue { staleDateWorld with now := 50 } .exhausted with now := 100 }

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
    w.m = { commitment := 0, runwayUntil := 0, fence := none,
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
    w.m = { commitment := 100, runwayUntil := 100, fence := none,
            destroyed := false, gone := false } ∧
    w.balance = 900 ∧ sweep Fence.current w = w ∧
    w'.m.commitment = 100 ∧ w'.m.runwayUntil = 0 ∧ sweep Fence.current w' ≠ w' := by decide

/-- `OPS-42`'s "Extension first": the worker's read sees the grown commitment, aborts, makes no
provider call, settles `succeeded` closing the episode `funded`, and the customer has what it
paid for. -/
@[req "OPS-42"]
theorem extension_first_witness :
    let w := run Fence.current fenceWorld extensionFirstTrace
    w.m = { commitment := 100, runwayUntil := 100, fence := none,
            destroyed := false, gone := false } ∧
    w.balance = 900 ∧
    w.episode = some { id := ⟨1⟩, state := .closed .funded, reasons := [.exhausted] } := by decide

/-- `OPS-42`'s "Fence first", on the paid-machine trace under `current`: the read and the write are
one transaction, the extension after it is refused — no commitment, no balance moved — and the
unfunded machine is destroyed. -/
@[req "OPS-42"]
theorem fence_first_witness :
    let w := run Fence.current fenceWorld paidMachineTrace
    w.m = { commitment := 0, runwayUntil := 0, fence := none,
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
    w.m = { commitment := 0, runwayUntil := 0, fence := none,
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
writes it, so the sweep does not route the machine again; on `agedWorld` the date is a hundred
seconds from the re-check's clock. Without the write, "an abort that re-derived a future date and
wrote nothing left the stored one in the past — so the next pass routed the same machine, the
worker aborted again". -/
@[req "OPS-41"]
theorem abort_without_date_write_reroutes :
    let w := run Fence.current staleDateWorld abortTrace
    let w' := run { Fence.current with abortWritesDate := false } staleDateWorld abortTrace
    w.m.runwayUntil = 100 ∧
    w.episode = some { id := ⟨1⟩, state := .closed .funded, reasons := [.exhausted] } ∧
    sweep Fence.current w = w ∧
    (run Fence.current agedWorld abortTrace).m.runwayUntil = 200 ∧
    (run Fence.current agedWorld abortTrace).episode =
      some { id := ⟨1⟩, state := .closed .funded, reasons := [.exhausted] } ∧
    w'.m.runwayUntil = 0 ∧ sweep Fence.current w' ≠ w' := by decide

/-- `LDG-16`'s one-clause predicate: "The exhaustion sweep MUST route a machine where its stored
`runway_until` has passed, and MUST NOT route it otherwise" — the no-rate case included
(`LDG-65`: "The exhaustion sweep continues during an outage on the last derived `runway_until`"),
and a future date not. -/
@[req "LDG-16"]
theorem routed_on_stored_date_witness :
    let base := { fenceWorld with now := 100 }
    base.routed = true ∧ ({ base with rate := none }).routed = true ∧
    ({ base with m := { base.m with runwayUntil := 100 } }).routed = true ∧
    ({ base with m := { base.m with runwayUntil := 101 } }).routed = false := by decide

/-- `ADR-0026`'s sources in `ADR-0027`'s window: honest `100`s, and a poisoned `103` as the
newest pass. The stale-date machine is the pin: a hundred satoshis committed, so at `100` the
re-check derives one second of runway and at `103` none. -/
def poisonedPassTrace : List Fence.Event := .pass [100, 100, 100, 103] :: cancellationTrace

/-- The median control fixes the abort's two guards, which its trace runs through, so a flip of
either has its own red build and not this one. The values are `current`'s, not an alternative
rule. -/
def medianGuards (p : Params) : Params := { p with abortPredicate := .date, abortWritesDate := true }

/-- `LDG-58`: "The rate is the lower median of the rate observations for its currency". The
poisoned pass moves the lower median nowhere — `LDG-16`: "No single rate observation moves the
rate outside the range the window's other observations carry" — the re-check derives at `100`,
aborts, writes the date, and the episode closes `funded`. Under the rule that stood before
`ADR-0027`, one pass's observation is the rate: the re-check derives at `103`, the cancellation
proceeds, and the disk is destroyed on one observation. -/
@[req "LDG-58"]
theorem window_median_witness :
    let p := medianGuards Fence.current
    let good := run p staleDateWorld poisonedPassTrace
    let bad := run { p with rateIsWindowMedian := false } staleDateWorld poisonedPassTrace
    good.rate = some 100 ∧ good.m.destroyed = false ∧ good.m.runwayUntil = 1 ∧
    good.episode = some { id := ⟨1⟩, state := .closed .funded, reasons := [.exhausted] } ∧
    bad.rate = some 103 ∧ bad.m.destroyed = true := by decide

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
every other row a settled refresh the engine never touches. The stored date is already past. -/
def liveStore : Restore.Store :=
  { ops := fun j =>
      if j = ⟨0⟩ then { kind := .createMachine, status := .queued, applied := false }
      else if j = ⟨1⟩ then { kind := .suspendTenant, status := .running, applied := false }
      else if j = ⟨2⟩ then { kind := .deleteMachine, status := .queued, applied := false }
      else { kind := .refresh, status := .succeeded, applied := true },
    machine := { runwayUntil := 0, recordedGone := false },
    credentialGen := 0,
    record := none }

/-- The lost interval: nine committed steps, all after the backup. -/
def lostInterval : History :=
  { initial := liveStore,
    steps := [.claim ⟨0⟩, .apply ⟨0⟩, .settle ⟨0⟩ .succeeded, .claim ⟨2⟩, .apply ⟨2⟩,
              .settle ⟨2⟩ .succeeded, .extend 100, .revoke, .settle ⟨1⟩ .succeeded] }

/-- The restore: `Δ = 9`, landed at 50, after the stored date. -/
def restoreTrace : RestoreTrace := { history := lostInterval, delta := 9, now := 50, interval := 60 }

/-- The same store crashed before any step: `STO-5`'s restart. -/
def restartTrace : RestartTrace := { history := { initial := liveStore, steps := [] } }

/-- Step (3)'s instant on `restoreTrace`: thirty seconds after the restore landed at `50`, so
the grace `STO-56` writes, "step (3)'s instant plus one re-derivation interval", is `140` and not
the withdrawn `110`. -/
def stepThreeAt : Nat := 80

/-- `STO-54`'s three steps. -/
def procedure : List Restore.Event := [.lock, .startupPass, .completeProcedure stepThreeAt]

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
pass, the claim finds nothing to order, and the record's `grace_ends_at` is still null — `STO-56`:
"It is null until step (3) of `STO-54`'s procedure is marked". -/
@[req "OPS-15"]
theorem executed_create_quarantined :
    let w := Restore.run Restore.current (bootRestore restoreTrace)
      [.lock, .startupPass, .claim ⟨0⟩]
    (w.store.ops ⟨0⟩).status = .needsReconciliation ∧ w.secondOrder = false ∧
    w.store.record = some { graceEndsAt := none, restoreInstant := 50 } := by decide

/-- Without it — `OPS-15` inspecting `running` rows only — the pass leaves the executed create
`queued`, the claim takes it, and the provider is ordered twice: `ADR-0023`'s "an executed
operation runs twice". -/
@[req "OPS-15"]
theorem executed_create_reordered_without_quarantine :
    (Restore.run { Restore.current with quarantineOnRestore := false } (bootRestore restoreTrace)
      [.lock, .startupPass, .claim ⟨0⟩]).secondOrder = true := by decide

/-- `STO-54`'s record, added 2026-09-20: the process dies after the restore lands and before step
(2)'s mark. Its successor comes up while the record is open, so it is continuing the incident — the
mode is the restore's, `api` serves nothing because step (3) is unmarked, and the record's
`grace_ends_at` is still null for the same reason. What that mode then does to the executed
create is the quarantine's, and `executed_create_quarantined` is where it is asserted. -/
@[req "STO-54"]
theorem crash_inside_procedure_continues_it :
    let w := Restore.run Restore.current (bootRestore restoreTrace)
      [.lock, .crash, .lock, .startupPass]
    w.fault = .restore ∧ (permits Restore.current w).serve = false ∧
    w.store.record = some { graceEndsAt := none, restoreInstant := 50 } := by decide

/-- Without it the successor is an ordinary restart on a restored store, which is the reading the
set permitted by saying nothing: it serves at once, its pass inspects `running` rows only, the
executed create is still `queued`, and the claim orders it again — `ADR-0023`'s "an executed
operation runs twice", reached through the crash window the procedure itself opens. -/
@[req "STO-54"]
theorem crash_inside_procedure_is_the_naive_boot :
    (Restore.run { Restore.current with recordDecidesBoot := false } (bootRestore restoreTrace)
      [.lock, .crash, .lock, .startupPass, .claim ⟨0⟩]).secondOrder = true := by decide

/-- The marks, `STO-54` 2026-09-20: the record carries which steps have completed, so a crash after
step (3) does not run step (3) again. The mark stands, `api` keeps serving — the listener is not
closed a second time on a customer already served — and a repeated step (3), at a later instant,
leaves the generation where the first one put it, and the grace where the first one wrote it:
`STO-54`'s "the grace is written once per incident — `STO-56`'s `grace_ends_at`, in step (3)'s
mark transaction". -/
@[req "STO-54"]
theorem marked_step_does_not_repeat :
    let w := Restore.run Restore.current (bootRestore restoreTrace) (procedure ++ [.crash, .lock])
    let w' := Restore.step Restore.current w (.completeProcedure 200)
    w.procedureComplete = true ∧ (permits Restore.current w).serve = true ∧
    w.store.record = some { graceEndsAt := some 140, restoreInstant := 50 } ∧
    w'.store.credentialGen = w.store.credentialGen ∧ w'.store.record = w.store.record := by decide

/-- `ADR-0023`'s "a revoked token works again", refused: generation 0 is what the backup holds and
what the revocation inside Δ replaced. Nothing is served before step (3); after it, 0 is refused
and the re-issued 1 is served. -/
@[req "STO-54"]
theorem resurrected_token_refused :
    (Restore.run Restore.current (bootRestore restoreTrace)
      [.lock, .startupPass, .request 0, .completeProcedure stepThreeAt, .request 0,
       .request 1]).servedGens
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
    let w' := Restore.run Restore.current w [.completeProcedure stepThreeAt, .claim ⟨1⟩]
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
tenant extended to 100 inside the interval, the restored date is 0, the procedure writes the
grace as `STO-56`'s `grace_ends_at`, "step (3)'s instant plus one re-derivation interval" — from
step (3)'s instant, not the restore's, which the record keeps beside it — the interval `STO-54`
says "buys the tenant one re-derivation interval in which to extend again" — and no run of the
procedure writes the date back. -/
@[req "STO-54"]
theorem lost_extension_not_rebuilt :
    ∃ t : RestoreTrace, t.history.final.machine.runwayUntil = 100 ∧
      t.store.machine.runwayUntil = 0 ∧ t.now ≠ stepThreeAt ∧
      (Restore.run Restore.current (bootRestore t) procedure).store.record
        = some { graceEndsAt := some (stepThreeAt + t.interval), restoreInstant := t.now } ∧
      ∀ evs, (Restore.run Restore.current (bootRestore t) evs).store.machine.runwayUntil = 0 :=
  ⟨restoreTrace, by decide, by decide, by decide, by decide,
   fun _ => by rw [run_runwayUntil]; decide⟩

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
machine records nothing, the confirmed parent is claimed, the grace is written on the record,
and every component runs — at step (3)'s mark, which is where this clockless model lifts the
freeze (`Provisiond.Restore`'s docstring). The model refuses nothing vacuously. -/
@[req "STO-54"]
theorem successful_restore_witness :
    let w := Restore.run Restore.current (bootRestore restoreTrace)
      (procedure ++ [.claim ⟨2⟩, .sweep true true, .confirmParents, .claim ⟨1⟩])
    (w.store.ops ⟨2⟩).status = .running ∧ (w.store.ops ⟨1⟩).status = .running ∧
    w.secondOrder = false ∧ w.parentResumedUnconfirmed = false ∧
    w.store.machine = { runwayUntil := 0, recordedGone := false } ∧
    w.store.record = some { graceEndsAt := some 140, restoreInstant := 50 } ∧
    (∀ c, (permits Restore.current w).run c = true) := by decide

end Restore

/-! ## The restore grace at the claim

`ADR-0028`'s placement, composed across the two models: `Provisiond.Restore` writes the instant
at step (3), and `Provisiond.Fence` reads it at the claim. The instant the fence trace carries is
the one the restore run above wrote, so the arithmetic has one home. -/

section Grace
open Provisiond.Fence

/-- `STO-56`'s record as `Provisiond.Restore` leaves it after the procedure on `restoreTrace`:
step (3) marked at `stepThreeAt`, `grace_ends_at` one interval after that. -/
def graceRecord : Option RestoreRecord :=
  (Restore.run Restore.current (Restore.bootRestore restoreTrace) procedure).store.record.map
    (·.toRestoreRecord)

/-- The fence model at the restore instant, the record open and its instant null: a delete re-run
by step (2) already enqueued against a machine whose extension was lost in Δ — the stored date
past, the commitment rolled back to nothing — and the tenant's balance restored with it. -/
def restoredWorld : World :=
  enqueue { fenceWorld with now := 50, restore := some { graceEndsAt := none } } .exhausted

/-- The re-run delete claims at the restore instant, `50`, while the record's instant is null;
the clock reaches step (3)'s instant, `80`, and only then is the record it wrote installed; the
tenant extends inside the grace; the clock reaches `grace_ends_at`, `140`; the delete is
re-claimed. -/
def graceTrace : List Fence.Event :=
  [.claim, .fenceTxn, .fenceWrite, .advance 30, .restoreRecord graceRecord, .extend 100,
   .advance 60, .providerDelete true (some true), .settle,
   .claim, .fenceTxn, .fenceWrite, .providerDelete true (some true), .settle]

/-- `OPS-41`: "A claim made while a restore record is open and its `grace_ends_at` is null or in
the future defers, and writes no fence". Under `current` the claim at `50`, before step (3), defers
on the null instant; a claim at `80`, once step (3) has written the instant, defers to it —
`available_at = grace_ends_at = 140`; the extension at `80` lands because `destroy_committed` is
null; and the re-claim at `140`, the grace over, closes the episode `funded` with the machine
alive. Under the withdrawn placement the claim at `50` fences at once, the guard sits on the
provider call — a call at `80` is held inside the grace — the fence refuses the extension at
`80`, and the call at `140` destroys the machine: `ADR-0028`'s "A machine already fenced when
the grace begins ... refuses `LDG-62`'s extension for the whole grace". -/
@[req "OPS-41"]
theorem grace_at_claim_witness :
    let good := run Fence.current restoredWorld graceTrace
    let bad := run { Fence.current with graceAtClaim := false } restoredWorld graceTrace
    graceRecord = some { graceEndsAt := some 140 } ∧
    (run Fence.current restoredWorld [.claim]).phase = .idle ∧
    (run Fence.current restoredWorld [.claim]).m.fence = none ∧
    (run Fence.current restoredWorld
      [.claim, .advance 30, .restoreRecord graceRecord, .claim]).attempt.map
      (·.row.availableAt) = some (some 140) ∧
    good.m.destroyed = false ∧ good.m.commitment = 100 ∧ good.balance = 900 ∧
    good.m.fence = none ∧
    good.episode = some { id := ⟨1⟩, state := .closed .funded, reasons := [.exhausted] } ∧
    (run { Fence.current with graceAtClaim := false } restoredWorld
      [.claim, .fenceTxn, .fenceWrite, .advance 30, .restoreRecord graceRecord,
       .providerDelete true (some true)]).m.destroyed = false ∧
    bad.m.destroyed = true ∧ bad.m.commitment = 0 ∧ bad.balance = 1000 := by decide

end Grace

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

One tenant's ledger in `Ledger.Balances` and its entries in `Ledger.Book`, then the lifecycle in
`Funding.World`: tenant 1 enrols and mints deposit 1; the activation minimum is 100,000; the
on-chain finality window is 6; machine 1 is the metered subject, billing tenant 1 in period 0
against 30 of commitment. Every witness pair here flips one field of `Ledger.current` or
`Funding.current` and asserts only what its own parameter decides. The witnesses that are no
pair's half: `earlier_row_authorizes_unfunded_create` and `drift_identity_witness`, which pin
`appendReadsLatest` and exhibit a trace; `replay_credits_once`, where the key and the `payments`
row each refuse the replay; `expiry_ends_watching_not_binding`; and `clamp_composed_witness`,
`zero_debit_advances_the_mark` and `clamped_debit_advances_the_mark`, which exhibit the meter under
`Funding.current`. The attribution witness settles one payment, so that `keyFrom := .deposit`
decides the two-rails witness alone. -/

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

/-- `LDG-70`'s trace: a top-up of 17, a transaction reading the latest row, and two debits of 10
and 7 appended after it. -/
def staleDebitTrace : List Ledger.Posting := [.append 17, .snapshot, .append (-10), .append (-7)]

/-- Under the rule each debit computes from the greatest row: the latest `balance_after` is 0, the
sum is 0, and a create of 10 is refused. After the first debit the read is 7, which the sum funds,
and a create of 7 is authorized: the model refuses nothing vacuously. -/
@[req "LDG-70"]
theorem append_reads_latest_witness :
    let k := Ledger.Book.empty.run Ledger.current staleDebitTrace
    let k' := Ledger.Book.empty.run Ledger.current (staleDebitTrace.take 3)
    k.read = 0 ∧ k.sum = 0 ∧ Ledger.openAgainst k.read zeroBalances 10 = zeroBalances ∧
    k'.read = 7 ∧ k'.sum = 7 ∧
    (Ledger.openAgainst k'.read { zeroBalances with sum := 7 } 7).reserved = 7 := by decide

/-- Without it both debits compute from the row the transaction read, the top-up's 17, and write
`balance_after` 7, then 10: the latest is 10 while the sum is 0, and a create of 10 is authorized
against a balance the sum does not fund — `LDG-9`'s `available`, taken from the sum, is −10, where
`LDG-10` says "`available` MUST NOT go negative". -/
@[req "LDG-70"]
theorem stale_predecessor_authorizes_unfunded_create :
    let k := Ledger.Book.empty.run { Ledger.current with appendReadsLatest := false } staleDebitTrace
    k.entries.map (·.balanceAfter) = [17, 7, 10] ∧ k.read = 10 ∧ k.sum = 0 ∧
    (Ledger.openAgainst k.read zeroBalances 10).available = -10 := by decide

/-- `LDG-70`'s read is "`balance_after` on the greatest `seq` for that tenant", not an earlier row:
after a top-up of 17 and a debit of 10 the greatest row says 7 and so does the sum, while the
earlier row says 17 — and a create of 10 authorized against it is one the sum does not fund,
`LDG-9`'s `available` from the sum at −3. Against the greatest row it is refused.
`appendReadsLatest` is pinned: what this refutes is a read of the wrong row, not a guard that could
be removed, so it is not one of `ci.yml`'s rows. -/
@[req "LDG-70"]
theorem earlier_row_authorizes_unfunded_create :
    let k := Ledger.Book.empty.run { Ledger.current with appendReadsLatest := true }
      [.append 17, .append (-10)]
    let b : Ledger.Balances := { zeroBalances with sum := k.sum }
    k.entries.map (·.balanceAfter) = [17, 7] ∧ k.read = 7 ∧ k.sum = 7 ∧
    (Ledger.openAgainst (Ledger.balanceOf k.entries.head?) b 10).available = -3 ∧
    Ledger.openAgainst k.read b 10 = b := by decide

/-- `Ledger.drift_identity` decided on three credits of 10, 7 and 3, each computed from the empty
history. The first reads no row where there is none; the second reads none where the greatest row
says 10; the third none where the greatest — the second's own — says 7. The read is 3, the sum 20,
and `read − sum` is the drifts' total, −17. -/
@[req "LDG-70"]
theorem drift_identity_witness :
    let p := { Ledger.current with appendReadsLatest := false }
    let ps : List Ledger.Posting := [.append 10, .append 7, .append 3]
    let k := Ledger.Book.empty.run p ps
    Ledger.Book.empty.drifts p ps = [0, -10, -7] ∧ k.read = 3 ∧ k.sum = 20 ∧
    k.read - k.sum =
      Ledger.Book.empty.read - Ledger.Book.empty.sum + (Ledger.Book.empty.drifts p ps).sum := by
  decide

def t1 : TenantId := ⟨1⟩
def t2 : TenantId := ⟨2⟩
def d1 : DepositId := ⟨1⟩

def fundWorld : Funding.World :=
  { now := 0, finality := 6, activationMin := 100000, tenants := [], retired := [], deposits := [],
    payments := [], entries := [], deficiencies := [], subject := .machine ⟨1⟩, period := 0,
    tenant := t1, remaining := 30, roundingCredit := 0, mark := none }

/-- The rail re-announcing one settlement: "a node replays invoice settlements on reconnect". -/
def replayTrace : List Funding.Event :=
  [.enrol t1, .mint d1 t1 100, .settle d1 ⟨11⟩ .lightning 60000, .settle d1 ⟨11⟩ .lightning 60000]

/-- `STO-31`: the replay is a no-op — one entry, one `payments` row, 60,000 credited. -/
@[req "STO-31"]
theorem replay_credits_once :
    let w := Funding.run Funding.current fundWorld replayTrace
    w.entries.length = 1 ∧ w.payments.length = 1 ∧ sumFor t1 w.entries = 60000 := by decide

/-- `Funding.current` with the `payments` row pinned off, named so that a refuted witness prints
its trace inside `ci.yml`'s window. -/
def recordOff : Funding.Params := { Funding.current with paymentRecordUnique := false }

/-- `LDG-8`'s key alone, the `payments` row pinned off: the replay is still a no-op. -/
@[req "LDG-8"]
theorem replay_credits_once_by_key :
    let w := Funding.run recordOff fundWorld replayTrace
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
    let w := Funding.post Funding.current fundWorld 10 100
    let w' := Funding.post Funding.current w 20 50
    w.entries.map (·.sats) = [-30] ∧ w.remaining = 0 ∧
    w.deficiencies = [{ clampedSats := 70, absorbedSeconds := 0 }] ∧ w.roundingCredit = 0 ∧
    w'.entries.map (·.sats) = [-30] ∧
    w'.deficiencies = [{ clampedSats := 70, absorbedSeconds := 0 },
                       { clampedSats := 50, absorbedSeconds := 0 }] ∧
    w'.available = fundWorld.available := by decide +kernel

/-- The increment closing at 7 at an exact 7/5, and its crash-replay: the same end, the same
charge. -/
def incrementReplayTrace : List Funding.Event := [.post 7 (7/5), .post 7 (7/5)]

/-- `Funding.current` with the discard pinned off, named as `recordOff` is. -/
def discardOff : Funding.Params := { Funding.current with markDiscards := false }

/-- `LDG-8`'s key alone, the discard pinned off: the replay "derives the *same* key and conflicts",
and the conflict refuses it whole — one entry of −2, 28 of the commitment left, `r` at 3/5. -/
@[req "LDG-8"]
theorem increment_replay_refused_by_key :
    let w := Funding.run discardOff fundWorld incrementReplayTrace
    w.entries.map (·.sats) = [-2] ∧ w.remaining = 28 ∧ w.roundingCredit = 3/5 := by
  with_unfolding_all decide

/-- Keyed on the posting index instead, the discard pinned off, the replay is `LDG-8`'s second run
that "reads one more prior debit, derives the next index, and its insert succeeds": −2 and −1,
the commitment at 27 where one posting leaves 28, `r` at 1/5 where one posting leaves 3/5 —
"double-charging the tenant and double-decrementing the commitment". -/
@[req "LDG-8"]
theorem increment_replay_posts_twice_by_index :
    let w := Funding.run
      { Funding.current with usageKeyFrom := .postingIndex, markDiscards := false } fundWorld
      incrementReplayTrace
    w.entries.map (·.sats) = [-2, -1] ∧ w.remaining = 27 ∧ w.roundingCredit = 1/5 := by
  decide +kernel

/-- At 1/5 sat a second: an increment closes at 7 (7/5), one at 9 (2/5) rounds to nothing, that
one is replayed, and a re-meter after a restart re-observes 0 to 8 (8/5), time already charged,
closing below the mark. -/
def remeterTrace : List Funding.Event :=
  [.post 7 (7/5), .post 9 (2/5), .post 9 (2/5), .post 8 (8/5)]

/-- `LDG-38`'s mark, under the stated key: the replay of the increment that rounded to nothing and
the re-meter ending below the mark are both discarded, and the world is the one the first two
increments left — one entry of −2, 28 left, `r` at 1/5. The first wrote no entry, so no key exists
for its replay to conflict with; the second ends at an instant no key names. -/
@[req "LDG-38"]
theorem mark_discards_what_the_key_admits :
    let w := Funding.run Funding.current fundWorld remeterTrace
    w = Funding.run Funding.current fundWorld (remeterTrace.take 2) ∧
    w.entries.map (·.sats) = [-2] ∧ w.remaining = 28 ∧ w.roundingCredit = 1/5 := by
  with_unfolding_all decide

/-- Without the discard, the same trace charges what the key cannot see: the replay posts −1 and
takes `r` to 4/5, the re-meter posts −1 more, each under a key nothing held, and the commitment
stands at 26 where the mark leaves 28 — `LDG-38`: "without the mark the deduplication key protects
only exact replays, not overlapping ones". -/
@[req "LDG-38"]
theorem remeter_charged_without_the_mark :
    let p := { Funding.current with usageKeyFrom := .incrementEnd, markDiscards := false }
    let w := Funding.run p fundWorld remeterTrace
    let k := Key.usage (.machine ⟨1⟩) 0 .usageDebit
    (Funding.run p fundWorld (remeterTrace.take 3)).roundingCredit = 4/5 ∧
    w.entries.map (fun e => (e.sats, e.key)) = [(-2, k 7), (-1, k 9), (-1, k 8)] ∧
    w.remaining = 26 := by decide +kernel

/-- `STO-45`'s zero-debit increment, the second of `remeterTrace`: 2/5 against `r` at 3/5 rounds
to nothing, writes no entry and no deficiency, and still advances `r` to 1/5 and the mark from 7
to 9 — "the rounding credit and the high-water mark advance either way". Its one entry carries the
key `usageKey` derives for the increment closing at 7, and the mark at 9 stands ahead of it:
`LDG-72`'s "a mark ahead of every entry is ordinary". -/
@[req "STO-45"]
theorem zero_debit_advances_the_mark :
    let w := Funding.run Funding.current fundWorld (remeterTrace.take 1)
    let w' := Funding.run Funding.current fundWorld (remeterTrace.take 2)
    w.roundingCredit = 3/5 ∧ w.mark = some 7 ∧
    w'.entries = w.entries ∧ w'.deficiencies = [] ∧ w'.roundingCredit = 1/5 ∧ w'.mark = some 9 ∧
    w'.entries.map (·.key) = [usageKey Funding.current fundWorld 7] := by decide +kernel

/-- `STO-45`'s clamped-to-nothing increment, the second of `clamp_composed_witness`: a computed 50
against nothing left writes no entry and still advances the mark from 10 to 20 — `LDG-72`'s record,
written "without a ledger entry but with any deficiency `STO-45` requires where the increment rounds
or clamps to nothing"; `clamp_composed_witness` asserts the deficiency it books. -/
@[req "STO-45"]
theorem clamped_debit_advances_the_mark :
    let w := Funding.post Funding.current fundWorld 10 100
    let w' := Funding.post Funding.current w 20 50
    w.mark = some 10 ∧ w'.entries = w.entries ∧ w'.mark = some 20 := by decide +kernel

end Funding

/-! ## The billing period

`Provisiond.Period` on the deployment's boundaries at 10 and 20: period 0 ends at 10, period 1
runs from 10 to 20, and period 2 opens at 20. Every increment is metered at 2/5 sat a second.
`earlySubject` was created at 0, so its anniversary is the deployment's own boundaries, and
`lateSubject` at 15, inside period 1. Each guarded witness takes its own field from
`Period.current` and pins every other field, so that it decides on its own field alone; its twin
pins every field and evaluates the trap. The twins are no `ci.yml` row's witness, since no row's
flip reaches a witness that pins every field: `credit_carried_across_the_boundary`,
`straddle_filed_whole_under_its_closing_month` and `anniversary_moves_the_boundary`. -/

section Period
open Provisiond.Period

def deployment : List Nat := [10, 20]
def earlySubject : Subject := { id := 1, createdAt := 0 }
def lateSubject : Subject := { id := 2, createdAt := 15 }

/-- 2/5 in the second before the boundary at 10, and 2/5 in the second after it. -/
def twoPeriodTrace : List Increment :=
  [{ startsAt := 9, closesAt := 10, rate := 2/5 }, { startsAt := 10, closesAt := 11, rate := 2/5 }]

/-- `LDG-38`'s reset, the split and the deployment's boundaries pinned: the new period's
"`meter_totals` row starts with `r = 0`", so each period posts 1 — in period 0 closing at 10, and
in period 1 closing at 11. -/
@[req "LDG-38"]
theorem boundary_resets_the_credit :
    let p := { Period.current with splitAtBoundary := true, deploymentWide := true }
    let fs := file p deployment earlySubject twoPeriodTrace
    posted p fs 0 = [(10, 1)] ∧ posted p fs 1 = [(11, 1)] := by
  with_unfolding_all decide

/-- Carrying the credit across instead, the 3/5 period 0 left pays for period 1's 2/5, which posts
0: `LDG-38`'s "1 then 0 carrying `r`", on the composed model. -/
@[req "LDG-38"]
theorem credit_carried_across_the_boundary :
    let p : Period.Params :=
      { resetAtBoundary := false, splitAtBoundary := true, deploymentWide := true }
    let fs := file p deployment earlySubject twoPeriodTrace
    posted p fs 0 = [(10, 1)] ∧ posted p fs 1 = [(11, 0)] := by
  decide +kernel

/-- 2/5 at 5, then one increment from 9 to 11 across the boundary at 10. -/
def straddleTrace : List Increment :=
  [{ startsAt := 5, closesAt := 6, rate := 2/5 }, { startsAt := 9, closesAt := 11, rate := 2/5 }]

/-- `LDG-38`'s split, the reset and the deployment's boundaries pinned: "An increment also closes
at every period boundary", so the increment from 9 to 11 posts a piece in each period. Period 0's
closes at the boundary instant, 10, and posts 0 against the 3/5 the increment at 5 left; period 1's
closes at 11 and posts 1 from `r = 0`. -/
@[req "LDG-38"]
theorem straddle_split_at_the_boundary :
    let p := { Period.current with resetAtBoundary := true, deploymentWide := true }
    let fs := file p deployment earlySubject straddleTrace
    posted p fs 0 = [(6, 1), (10, 0)] ∧ posted p fs 1 = [(11, 1)] := by
  with_unfolding_all decide

/-- Filed whole under its closing month instead, the increment from 9 to 11 posts 1 in period 1
and nothing in period 0. The total is 2 either way, which is why the guarded witness asserts each
period's postings rather than their sum. -/
@[req "LDG-38"]
theorem straddle_filed_whole_under_its_closing_month :
    let p : Period.Params :=
      { resetAtBoundary := true, splitAtBoundary := false, deploymentWide := true }
    let fs := file p deployment earlySubject straddleTrace
    posted p fs 0 = [(6, 1)] ∧ posted p fs 1 = [(11, 1)] ∧
    (postings p fs 0).sum + (postings p fs 1).sum = 2 := by
  decide +kernel

/-- One increment from 19 to 21, across the deployment's boundary at 20. -/
def lateSubjectTrace : List Increment := [{ startsAt := 19, closesAt := 21, rate := 2/5 }]

/-- `LDG-68`'s one boundary, the reset and the split pinned: "Every tenant, every machine and every
attachment share it", so the subject created at 15 files the increment exactly as the subject
created at 0 does — split at 20, the piece to 20 under period 1 and the piece from 20 under
period 2. -/
@[req "LDG-68"]
theorem late_subject_shares_the_boundary :
    let p := { Period.current with resetAtBoundary := true, splitAtBoundary := true }
    file p deployment lateSubject lateSubjectTrace = file p deployment earlySubject lateSubjectTrace ∧
    file p deployment lateSubject lateSubjectTrace =
      [(1, { startsAt := 19, closesAt := 20, rate := 2/5 }),
       (2, { startsAt := 20, closesAt := 21, rate := 2/5 })] := by
  with_unfolding_all decide

/-- Under the anniversary instead, the subject created at 15 has boundaries at 25 and 35, and the
increment is filed whole under its own first period, while the subject created at 0 still splits
it at 20. -/
@[req "LDG-68"]
theorem anniversary_moves_the_boundary :
    let p : Period.Params :=
      { resetAtBoundary := true, splitAtBoundary := true, deploymentWide := false }
    schedule p deployment lateSubject = [25, 35] ∧
    file p deployment lateSubject lateSubjectTrace =
      [(0, { startsAt := 19, closesAt := 21, rate := 2/5 })] ∧
    file p deployment earlySubject lateSubjectTrace =
      [(1, { startsAt := 19, closesAt := 20, rate := 2/5 }),
       (2, { startsAt := 20, closesAt := 21, rate := 2/5 })] := by
  decide +kernel

end Period

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

/-- `WIR-17`'s create body, with its members in two orders at two depths: the shape `API-12` is
about, "so that key ordering and whitespace do not produce spurious conflicts". -/
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

/-! ## Rescue and install

`RSC-3`'s trust decision, `RSC-26`'s disk identity, `OPS-45`'s two markers on the claim model and
`RSC-19`'s recovery key. One install request runs the markers: the caller chose the disk carrying
stable identifier 2 from an inventory whose fingerprint is 100. `RSC-26`'s duplicate case needs a
second device set, so `duplicateRequest` is a second request, over fingerprint 102.

Every field of `Rescue.current` has a witness pair that flips it and asserts what that field
decides, as `ci.yml`'s other rows do. The
`RSC-5` pair (`Trust.run` against `Trust.runRedecided`) and the `RSC-26` pair (`Disk.resolve`
against `Disk.resolveFirst`) flip no field: what they refute is an alternative definition, not a
guard that could be removed, so neither is one of `ci.yml`'s rows. -/

section Rescue
open Provisiond.Rescue

/-- The caller pinned one key and the driver published two, which overlap: `RSC-3`'s third row. -/
def pinnedConn : Trust.Conn :=
  { trust := .pinned, callerKeys := [⟨1⟩], driverKeys := [⟨1⟩, ⟨2⟩], optIn := false }

/-- `RSC-5`'s three paths: "not on retry, not on timeout, not when the driver returns an empty key
set later". -/
def downgradePaths : List Trust.Event := [.retry, .timeout, .driverPublishes []]

/-- A request that pins and connects, and stays pinned over every path `RSC-5` names. The model
refuses nothing vacuously. -/
@[req "RSC-3"]
theorem pinned_connection_witness :
    Trust.decision [⟨1⟩] [⟨1⟩, ⟨2⟩] false = .pinOverlapping ∧
    Trust.connects (Trust.decision [⟨1⟩] [⟨1⟩, ⟨2⟩] false) = true ∧
    (Trust.run pinnedConn downgradePaths).trust = .pinned := by decide

/-- The connection `RSC-5`'s refuted alternative downgrades: the caller supplied no keys and opted
in — admissible under `RSC-4` — the driver published one, so the trust decision pinned the driver's
key. -/
def optedInConn : Trust.Conn :=
  { trust := .pinned, callerKeys := [], driverKeys := [⟨1⟩], optIn := true }

/-- `RSC-5`'s refuted alternative, as `OPS-49`'s last-statement retry is in the claim model:
re-deciding `RSC-3` on each event from the driver's *current* set. On the trace where the driver
returns an empty key set later, the state machine stays pinned and the alternative reaches
accept-new — the silent downgrade to first-use trust. -/
@[req "RSC-5"]
theorem redecided_trust_downgrades :
    Trust.admissible { callerKeys := [], firstUseOptIn := true } = true ∧
    Trust.decision [] [⟨1⟩] true = .pinDriver ∧
    (Trust.run optedInConn [.driverPublishes []]).trust = .pinned ∧
    (Trust.runRedecided optedInConn [.driverPublishes []]).trust = .firstUse := by decide

/-- The inventory the caller chose from: two disks, the second carrying the identifier it chose. -/
def chosenInventory : Disk.Inventory :=
  { devices := [{ identifier := some ⟨1⟩, path := "/dev/sda" },
                { identifier := some ⟨2⟩, path := "/dev/sdb" }],
    fingerprint := 100 }

/-- The same two disks after a boot re-ordered their names. The fingerprint is "over the whole
device set", which the re-ordering did not change. -/
def reorderedInventory : Disk.Inventory :=
  { devices := [{ identifier := some ⟨2⟩, path := "/dev/sda" },
                { identifier := some ⟨1⟩, path := "/dev/sdb" }],
    fingerprint := 100 }

/-- A second disk carrying the same identifier: "duplicate or empty serials are real on consumer
and virtualised disks". Its own fingerprint, because `RSC-46` computes one over "the device list
sorted by identifier" and this device list is not `chosenInventory`'s. -/
def duplicateInventory : Disk.Inventory :=
  { devices := [{ identifier := some ⟨2⟩, path := "/dev/sda" },
                { identifier := some ⟨2⟩, path := "/dev/sdb" }],
    fingerprint := 102 }

/-- What a caller who read that set would send: the same identifier, and the fingerprint it was
chosen from — so the resolution reaches the more-than-one case rather than aborting on the
fingerprint first. -/
def duplicateRequest : Disk.Request := { identifier := ⟨2⟩, fingerprint := 102 }

/-- The device set changed since the caller read it, so the fingerprint is another. -/
def staleInventory : Disk.Inventory :=
  { devices := [{ identifier := some ⟨2⟩, path := "/dev/sda" }], fingerprint := 101 }

/-- `RSC-26`'s request: "the chosen device's stable identifier and the `inventory_fingerprint` it
was chosen from". -/
def installRequest : Disk.Request := { identifier := ⟨2⟩, fingerprint := 100 }

/-- An identifier that resolves, and what "The identifier is authoritative; the path is derived"
buys: the caller chose the disk that was `/dev/sdb`, and against the re-ordered inventory the same
identifier resolves to the same disk under the name `/dev/sda`. A request naming the path would
have written to the other disk. A changed fingerprint aborts. -/
@[req "RSC-26"]
theorem identifier_resolves_across_a_reordering :
    Disk.resolve installRequest (some chosenInventory)
      = .resolved { identifier := some ⟨2⟩, path := "/dev/sdb" } ∧
    (Disk.resolve installRequest (some reorderedInventory)).path = some "/dev/sda" ∧
    Disk.resolve installRequest (some staleInventory) = .abortIntegrity ∧
    Disk.resolve installRequest none = .abortIntegrity := by decide

/-- "more than one is the dangerous case", and 'pick the first' there "is the same coin-flip over
which disk gets destroyed that naming `/dev/sda` was": the identifier names two of this set's
devices, the resolution aborts, and the refuted alternative writes to whichever the enumeration put
first — a disk the caller never singled out. -/
@[req "RSC-26"]
theorem duplicate_identifier_refused_not_first_taken :
    Disk.resolve duplicateRequest (some duplicateInventory) = .abortIntegrity ∧
    (Disk.resolveFirst duplicateRequest (some duplicateInventory)).path = some "/dev/sda" := by
  decide

/-- A claimed `raw_disk` install, before any of it has run. -/
def rawInstall : Install.World := Install.begin (.install .rawDisk) installRequest

/-- A claimed `rootfs_via_rescue` install, which enters rescue. -/
def rescueInstall : Install.World := Install.begin (.install .rootfsViaRescue) installRequest

/-- `RSC-26`'s re-read, "immediately before any disk I/O". -/
def reread : Install.Event := .resolveTarget (some chosenInventory)

/-- `OPS-49`'s lost reply on the first marker's write, then the repeat: the second write finds the
column set. -/
def lostReplyThenRepeat : List Install.Event :=
  [reread, .markerWrite (.committed false), .markerWrite (.committed true), .phase true]

/-- `OPS-45`, 2026-09-12 (`ADR-0022`): with `COALESCE(write_started_at, now)` under the worker
guard, "a repeat after a lost reply then affects a row and moves nothing" — the column still holds
the instant the first write set, and the phase runs. -/
@[req "OPS-45"]
theorem coalesced_repeat_moves_nothing :
    let w := Install.run Rescue.current rawInstall lostReplyThenRepeat
    w.writeStartedAt = some 1 ∧ w.exited = false ∧ w.diskWritten = true := by decide

/-- Without it — the null-guarded write — the same repeat "would affect no row and read as
overtaken": the worker exits on its own commit and the phase never runs. -/
@[req "OPS-45"]
theorem null_guarded_repeat_reads_as_overtaken :
    let w := Install.run { Rescue.current with coalesceWrite := false } rawInstall
      lostReplyThenRepeat
    w.exited = true ∧ w.diskWritten = false ∧ w.writeStartedAt = some 1 := by decide

/-- The phase the process dies inside, with no marker written first. -/
def phaseWithoutMarker : List Install.Event := [reread, .phase false]

/-- `OPS-45`: the marker is written "at the moment a phase begins that could have altered the
machine, and before that phase runs", so the phase is admitted only after that write was
acknowledged. Here nothing wrote it, the phase is refused, and the disk is untouched — which is
what the projection says. -/
@[req "OPS-45"]
theorem phase_refused_before_the_marker :
    let w := Install.run Rescue.current rawInstall phaseWithoutMarker
    w.diskWritten = false ∧ w.writeStartedAt = none ∧
    Install.classifiedUntouched (Install.markers w) = true := by decide

/-- Without it — the marker written after the phase — a process that dies inside the phase leaves
the marker unset over a disk that was written, and the projection says untouched while the disk is
not: `installRow`'s deterministic `failed` branch over a destroyed disk. -/
@[req "OPS-45"]
theorem marker_unset_over_a_written_disk_without_the_guard :
    let w := Install.run { Rescue.current with markerBeforePhase := false } rawInstall
      phaseWithoutMarker
    w.diskWritten = true ∧ w.writeStartedAt = none ∧ w.died = true ∧
    Install.classifiedUntouched (Install.markers w) = true ∧
    installRow currentRules (Install.markers w) .internal = .failed := by decide

/-- The cost `OPS-45`'s 2026-09-15 rewording states and accepts: the marker "establishes that
preservation is no longer proven, not that a byte landed", so a process that dies between the write
and the phase "leaves a set marker over an untouched disk, and nothing later can tell the two
apart". The classification is conservative there, not wrong. -/
@[req "OPS-45"]
theorem marker_set_over_an_untouched_disk :
    let w := Install.run Rescue.current rawInstall [reread, .markerWrite (.committed true), .crash]
    w.writeStartedAt = some 1 ∧ w.diskWritten = false ∧ w.died = true ∧
    Install.classifiedUntouched (Install.markers w) = false := by decide

/-- The same conservatism on the second marker, which `OPS-45` states beside the first: "`false` is
the conservative value as much as the open-session one: a process that dies between that write and
the dispatch leaves `false` over a machine that was never rebooted into rescue". No session was
opened and the column is not null, so the projection answers no — conservative there, not wrong.
Either way the row is `OPS-15`'s, which is `OPS-45`'s own sentence: "an operation interrupted
rather than classified is `OPS-15`'s, whatever the markers hold". `secondMarkerBeforeSession` is
pinned because this trace is under the rule as it stands and is not that guard's control: with the
arming write removed the column stays `none` and the witness is refuted too — a second red on a
control `ci.yml` gives one witness each. -/
@[req "OPS-45"]
theorem false_over_a_machine_never_in_rescue :
    let w := Install.run { Rescue.current with secondMarkerBeforeSession := true } rescueInstall
      [.armExit (.committed true), .crash]
    w.rescueExitedCleanly = some false ∧ w.sessionDispatched = false ∧ w.died = true ∧
    (Install.markers w).rescueClean = false := by decide

/-- `PRV-18`'s partial activation: the second marker armed, begin rescue dispatched, and the driver
reports that it cleaned up after itself. -/
def partialActivation : List Install.Event := [.armExit (.committed true), .beginRescue]

/-- `OPS-45`: "**A driver's report that it cleaned up after a partial activation (`PRV-18`) does not
move this marker**" — "the engine did not open the session and did not close it". Whatever the
arming write left in the column, the report leaves it there. -/
@[req "OPS-45"]
theorem partial_cleanup_moves_nothing :
    let w := Install.run Rescue.current rescueInstall partialActivation
    (Install.step Rescue.current w .partialCleanupReported).rescueExitedCleanly
      = w.rescueExitedCleanly := by decide

/-- Without the rule the driver's report closes a session the engine never closed: the column reads
`true`, the projection reads the machine as clean, and an operation whose machine may be sitting in
rescue settles deterministically `failed`. -/
@[req "OPS-45"]
theorem partial_cleanup_closes_a_session_the_engine_did_not :
    let w := Install.run { Rescue.current with partialCleanupMovesNothing := false } rescueInstall
      (partialActivation ++ [.partialCleanupReported])
    w.rescueExitedCleanly = some true ∧
    Install.classifiedUntouched (Install.markers w) = true := by decide

/-- An install that runs end to end: the re-read resolves, the marker is written and acknowledged,
the second marker is armed before the dispatch, the phase runs, and the exit returns success. The
model refuses nothing vacuously. -/
@[req "OPS-45"]
theorem successful_install_witness :
    let w := Install.run Rescue.current rescueInstall
      [reread, .markerWrite (.committed true), .armExit (.committed true), .beginRescue,
       .phase true, .endRescueSuccess (.committed true)]
    w.target = some "/dev/sdb" ∧ w.writeStartedAt = some 1 ∧
    w.rescueExitedCleanly = some true ∧ w.diskWritten = true ∧ w.exited = false ∧
    Install.markers w = { writeStarted := true, rescueClean := true } := by decide

/-- `RSC-38`'s inventory pass, which is `OPS-45`'s `never` row: it arms the second marker, opens
the session and closes it cleanly, and the first marker stays null throughout, so "its whole
classification turns on the second marker below". The `never` row refuses nothing vacuously — a
rescue inventory has no marker-dated phase and does not need one. -/
@[req "OPS-45"]
theorem rescue_inventory_turns_on_the_second_marker :
    let w := Install.run Rescue.current (Install.begin .rescueInventory installRequest)
      [.armExit (.committed true), .beginRescue, .endRescueSuccess (.committed true)]
    w.writeStartedAt = none ∧ w.rescueExitedCleanly = some true ∧ w.sessionDispatched = true ∧
    Install.markers w = { writeStarted := false, rescueClean := true } := by decide

/-- `OPS-45`'s headline case, from both aborts that precede a write: `RSC-3` refuses to connect
where "Neither, and no explicit opt-in", and `RSC-26` aborts on a fingerprint that differs. Neither
sets a marker, so the operation settles `failed` deterministically — `OPS-11`'s install row,
"including `integrity` before the connection, which is `RSC-3`'s host-key abort". -/
@[req "OPS-11"]
theorem aborts_before_any_write_settle_deterministically :
    Trust.connects (Trust.decision [] [] false) = false ∧
    let w := Install.run Rescue.current rawInstall [.resolveTarget (some staleInventory)]
    w.aborted = true ∧ w.diskWritten = false ∧
    Install.classifiedUntouched (Install.markers w) = true ∧
    installRow currentRules (Install.markers w) .integrity = .failed := by decide

/-- `RSC-26`'s abort followed by everything the rest of an install would do: a second re-read that
would resolve, the marker write, and the destructive phase. -/
def abortThenTheRestOfTheInstall : List Install.Event :=
  [.resolveTarget none, reread, .markerWrite (.committed true), .phase true]

/-- The abort is the end of the operation, not a field a later step may ignore. `RSC-26` aborts
"with `integrity` — before writing a single byte" and "before any write", so the unparsed inventory
forecloses the second resolution, the marker write and the phase alike: no target, no byte, and the
projection still reads the disk untouched. -/
@[req "RSC-26"]
theorem abort_is_the_end_of_the_operation :
    let w := Install.run Rescue.current rawInstall abortThenTheRestOfTheInstall
    w.aborted = true ∧ w.target = none ∧ w.diskWritten = false ∧ w.writeStartedAt = none ∧
    Install.classifiedUntouched (Install.markers w) = true := by decide

/-- One operation's session, on a machine at 203.0.113.7:22. -/
def rescueSession : Session.World := Session.begin ⟨9⟩ "203.0.113.7" 22

/-- The session that exits cleanly. -/
def cleanSession : List Session.Event :=
  [.armExit, .beginRescue false, .remoteCommand, .endRescue true]

/-- The session as it stands with a command run over it and the exit not yet attempted. -/
def openSession : List Session.Event := [.armExit, .beginRescue false, .remoteCommand]

/-- The session the engine dies in the middle of. -/
def crashedSession : List Session.Event := openSession ++ [.crash]

/-- The exit that failed — `PRV-22`'s "*always* ambiguous". -/
def failedExitSession : List Session.Event :=
  [.armExit, .beginRescue false, .remoteCommand, .endRescue false]

/-- A session that exits cleanly with no key on disk: `RSC-19` persists the key on the uncertain
branch and on no other, `PRV-21`'s exit removed the temporary credential, and the record renders
`clean`. The model refuses nothing vacuously. -/
@[req "RSC-19"]
theorem clean_exit_leaves_no_key :
    let w := Session.run Rescue.current rescueSession cleanSession
    w.keyOnDisk = none ∧ w.credentialRegistered = false ∧
    Session.rescueExit w = .clean := by decide

/-- The design `RSC-19`'s 2026-09-15 paragraph refuses, as what it would cost: persisting the key
from activation leaves "a root credential on disk for the whole of every install", here on a clean
successful one. -/
@[req "RSC-19"]
theorem persisting_at_activation_leaves_a_root_credential :
    let w := Session.run { Rescue.current with persistAtActivation := true } rescueSession
      [.armExit, .beginRescue false]
    w.keyOnDisk = some { key := { operation := ⟨9⟩ } } ∧
    (Session.run { Rescue.current with persistAtActivation := true } rescueSession
      cleanSession).keyOnDisk = some { key := { operation := ⟨9⟩ } } := by decide

/-- `OPS-45`, 2026-09-16: `false` precedes the dispatch, and "A dead process writes nothing, which
is why `false` precedes the session and not the exit: it is what lets `OPS-15`'s pass render
`rescue_exit: "unknown"` (`RSC-19`, `WIR-9a`)". With the address and port, and neither the key nor
its path. "An engine crash persists nothing" (`RSC-19`) is the key equality: what is on disk after
the crash is what the open session already had, and the crash wrote none. That it is `none` under
the rules as they stand is `clean_exit_leaves_no_key`'s to say — asserting it here too would make
this witness a second red on the `persistAtActivation` control, which `ci.yml` gives one each. -/
@[req "RSC-19"]
theorem crash_renders_rescue_exit_unknown :
    let w := Session.run Rescue.current rescueSession crashedSession
    Session.details w = { rescueExit := .unknown, rescueAddress := some "203.0.113.7",
                          rescuePort := some 22 } ∧
    w.keyOnDisk = (Session.run Rescue.current rescueSession openSession).keyOnDisk ∧
    w.credentialRegistered = true ∧ w.status = .needsReconciliation := by decide

/-- Without the pre-dispatch write — the column written `true` on success only — a crash mid-session
leaves `null`, "the only value that means no session was opened", and the pass has nothing to render
the machine's state from. -/
@[req "RSC-19"]
theorem crash_renders_nothing_without_the_arming_write :
    let w := Session.run { Rescue.current with secondMarkerBeforeSession := false } rescueSession
      crashedSession
    w.rescueExitedCleanly = none ∧ Session.rescueExit w = .noSession ∧
    Session.details w = { rescueExit := .noSession, rescueAddress := none,
                          rescuePort := none } := by decide

/-- `RSC-19`'s uncertain branch: the exit failed, so the private key is persisted "in a file named
by the operation id", the provider-side credential may still be registered (`PRV-22`), and no event
the engine runs takes the key away — `OPS-32`'s sweep removes the provider's credential and not
this file, and `RSC-21`'s removal waits for the operator. -/
@[req "RSC-19"]
theorem uncertain_exit_persists_the_key :
    let w := Session.run Rescue.current rescueSession failedExitSession
    w.keyOnDisk = some { key := { operation := ⟨9⟩ } } ∧ w.uncertain = true ∧
    w.credentialRegistered = true ∧
    (Session.run Rescue.current w [.sweepRemovesCredential, .operatorRemovesKey]).keyOnDisk
      = some { key := { operation := ⟨9⟩ } } ∧
    (Session.run Rescue.current w [.recoveryComplete, .operatorRemovesKey]).keyOnDisk = none := by
  decide

end Rescue

/-! ## The catalogue re-host

`RSC-39`'s fetch and what bounds it. One allowlisted name, `⟨1⟩`, and one the attacker controls,
`⟨2⟩`; the deployment has not enabled `http` and adds no ranges of its own. Every field of
`Rehost.current` has a pair that flips it and asserts what that field decides, as `ci.yml`'s other
rows do. `metadata_redirect_refused_under_every_guard` flips all three at once and is not one of
those rows: what it shows is that no configuration reaches an address `RSC-44` lists, which is a
property of the address bullet rather than of a guard. -/

section Rehost
open Provisiond.Rehost

/-- The name a deployment allowlisted. -/
def allowedHost : Host := ⟨1⟩

/-- The name `RSC-44`'s worked example redirects to: "an allowlisted `images.example.com`
answering `302` to `https://images.attacker.example/`". -/
def attackerHost : Host := ⟨2⟩

/-- A deployment that allowlisted one name, left `http` disabled (`SEC-18`) and added no ranges of
its own. -/
def rehostPolicy : Policy :=
  { allowlist := [allowedHost], httpEnabled := false, extraRefused := fun _ => false,
    redirectCap := 3 }

/-- `SEC-19`'s empty allowlist, the case its 2026-09-02 amendment is about. -/
def emptyAllowlist : Policy := { rehostPolicy with allowlist := [] }

/-- The caller's URL: the allowlisted name, `https`, resolving to one ordinary address. -/
def firstHop : Hop := { host := allowedHost, scheme := .https, addrs := [.plain .routable] }

/-- The fetch that should happen, so the model refuses nothing vacuously. -/
@[req "RSC-44"]
theorem a_plain_fetch_succeeds :
    Rehost.fetch Rehost.current rehostPolicy [firstHop] = .fetched := by decide

/-- `RSC-44`'s worked example: the allowlisted name answers `302` to a name nobody allowed, "at an
address that is public, routable and entirely ordinary — so every address class passes, the scheme
is held, and the fetch proceeds". -/
def attackerRedirect : List Hop :=
  [firstHop, { host := attackerHost, scheme := .https, addrs := [.plain .routable] }]

/-- `RSC-44`, 2026-09-04: with the allowlist re-checked "on every hop, against the redirect
target's own name", the redirect is "refused, exactly as the original URL would have been". -/
@[req "RSC-44"]
theorem attacker_redirect_refused :
    Rehost.fetch Rehost.current rehostPolicy attackerRedirect = .refused := by decide

/-- Without it the allowlist "was checked once, at request time, against a URL the attacker was
free to abandon on the first hop", and provisiond fetches the attacker's. -/
@[req "RSC-44"]
theorem attacker_redirect_fetched_without_the_guard :
    Rehost.fetch { Rehost.current with allowlistPerHop := false } rehostPolicy attackerRedirect
      = .fetched := by decide

/-- The same name, redirecting itself from `https` to `http` on a deployment that never enabled
it. -/
def schemeDowngrade : List Hop :=
  [firstHop, { host := allowedHost, scheme := .http, addrs := [.plain .routable] }]

/-- `RSC-44`: the scheme is held "across every hop … refused on redirect as well as on the original
URL". -/
@[req "RSC-44"]
theorem scheme_downgrade_refused :
    Rehost.fetch Rehost.current rehostPolicy schemeDowngrade = .refused := by decide

/-- Without it the rule is the original URL's alone and the downgrade proceeds, which is the state
this path was in while `RSC-17` was miscited for it. -/
@[req "RSC-44"]
theorem scheme_downgrade_fetched_without_the_guard :
    Rehost.fetch { Rehost.current with schemePerHop := false } rehostPolicy schemeDowngrade
      = .fetched := by decide

/-- `SEC-19` as amended: an empty allowlist means "**no catalogue install may be requested**". -/
@[req "SEC-19"]
theorem empty_allowlist_admits_nothing :
    Rehost.fetch Rehost.current emptyAllowlist [firstHop] = .refused := by decide

/-- Without it the empty list is the fail-open default — "an empty allowlist means 'any host'" —
and the same fetch proceeds. -/
@[req "SEC-19"]
theorem empty_allowlist_admits_anything_without_the_guard :
    Rehost.fetch { Rehost.current with allowlistRequired := false } emptyAllowlist [firstHop]
      = .fetched := by decide

/-- `RSC-44`'s own example of what the redirect bullet exists for: "A redirect to a public host
that then answers `302` to `http://169.254.169.254/`". -/
def metadataRedirect : List Hop :=
  [firstHop, { host := allowedHost, scheme := .http, addrs := [.plain .linkLocal] }]

/-- Refused with every guard set and with all three cleared. Under `Rehost.current` the scheme
refuses it too; with the guards gone only the address does, which is the point — the address
bullet is not one of the parameters, so no deployment and no missing guard reaches a link-local
address. -/
@[req "RSC-44"]
theorem metadata_redirect_refused_under_every_guard :
    Rehost.fetch Rehost.current rehostPolicy metadataRedirect = .refused ∧
    Rehost.fetch { allowlistRequired := false, allowlistPerHop := false, schemePerHop := false }
      rehostPolicy metadataRedirect = .refused := by decide

/-- An IPv4-mapped IPv6 address wrapping the same metadata address, which `RSC-44` names
separately. -/
@[req "RSC-44"]
theorem mapping_the_metadata_address_does_not_help :
    Rehost.fetch Rehost.current rehostPolicy
      [firstHop, { host := allowedHost, scheme := .https,
                   addrs := [.mapped (.mapped (.plain .linkLocal))] }] = .refused := by decide

/-- One hop past `redirectCap`, every hop of it otherwise good. -/
@[req "RSC-44"]
theorem over_the_cap_refused_though_every_hop_is_good :
    Rehost.fetch Rehost.current { rehostPolicy with redirectCap := 1 }
      [firstHop, firstHop, firstHop] = .refused := by decide

/-- `RSC-40`: a stream inside the offer's maximum whose digest is the one the caller declared. -/
@[req "RSC-40"]
theorem a_measured_stream_is_accepted :
    Rehost.measure 100 ⟨7⟩ { bytes := 50, digest := ⟨7⟩, content := ⟨1⟩ } = .accepted := by decide

/-- `RSC-40`: "enforced against the stream, aborting the transfer when exceeded" — and the size is
read before the digest, so an oversized stream aborts for its size even when it verifies. -/
@[req "RSC-40"]
theorem an_oversized_stream_aborts_for_its_size :
    Rehost.measure 100 ⟨7⟩ { bytes := 101, digest := ⟨7⟩, content := ⟨1⟩ }
      = .abortedOversize := by decide

/-- `RSC-39`'s verification, failing: a stream within the bound whose bytes hashed to something
else. Kept apart from the size abort because they are two requirements. -/
@[req "RSC-39"]
theorem a_mismatched_digest_fails_verification :
    Rehost.measure 100 ⟨7⟩ { bytes := 50, digest := ⟨8⟩, content := ⟨1⟩ }
      = .abortedIntegrity := by decide

/-- The operation mid-import: yielded, both copies present, the provider's tagged with the
operation's correlator (`RSC-42`). -/
def importingWorld : World :=
  { phase := .importing,
    copies := { operator := true, provider := { present := true, tag := some ⟨9⟩ } },
    waited := 0, reacquired := false, revalidated := false, status := .running }

/-- The import as `RSC-41` has it: yielded while it runs, then the machine re-acquired and
re-validated before the rebuild (`OPS-23`). -/
@[req "RSC-41"]
theorem an_import_yields_then_reacquires_then_rebuilds :
    let w := Rehost.run 5 importingWorld [.wait, .reacquire, .revalidate]
    w.phase = .importing ∧ Rehost.holdsMachine w.phase = false ∧ w.revalidated = true ∧
    (Rehost.beginRebuild w).phase = .rebuilding := by decide

/-- `OPS-23` is about the machine in hand: a re-validation from before the re-acquisition does not
admit the rebuild, because "the machine may be gone by the time the import finishes" and what was
validated was the machine held before it. -/
@[req "RSC-41"]
theorem revalidating_before_reacquiring_does_not_admit_the_rebuild :
    let w := Rehost.run 5 importingWorld [.revalidate, .wait, .reacquire]
    w.revalidated = false ∧ (Rehost.beginRebuild w).phase = .importing := by decide

/-- `RSC-41`: "A maximum import wait MUST be stated, past which the operation aborts and the
imported image is deleted." -/
@[req "RSC-41"]
theorem past_the_max_wait_the_operation_aborts :
    let w := Rehost.run 2 importingWorld [.wait, .wait, .wait]
    w.status = .failed ∧ w.copies.operator = false ∧ w.copies.provider.present = false := by decide

/-- `RSC-42`'s clause for the state `OPS-3` does not call settled. -/
@[req "RSC-42"]
theorem needs_reconciliation_purges_both_copies :
    (Rehost.step 5 importingWorld (.settle .needsReconciliation true)).copies.provider.present
      = false := by decide

/-- `RSC-42`: the provider-side copy "is deleted by a call that may fail or be lost". The lost
call leaves the orphan, and `OPS-32`'s sweep takes it by the tag the import carried. -/
@[req "RSC-42"]
theorem a_lost_delete_leaves_an_orphan_the_sweep_takes :
    let settled := Rehost.step 5 importingWorld (.settle .succeeded false)
    settled.copies.operator = false ∧ settled.copies.provider.present = true ∧
    (Rehost.step 5 settled (.sweep [⟨9⟩])).copies.provider.present = false := by decide

/-- And the design that sentence refuses: an import that carried no tag leaves an orphan the sweep
cannot find, however many passes it makes. -/
@[req "RSC-42"]
theorem an_untagged_orphan_survives_the_sweep :
    let untagged := { importingWorld with
      copies := { operator := true, provider := { present := true, tag := none } } }
    let settled := Rehost.step 5 untagged (.settle .succeeded false)
    (Rehost.run 5 settled [.sweep [⟨9⟩], .sweep [⟨9⟩]]).copies.provider.present = true := by decide

/-- `RSC-43`: `succeeded` is the provider's report under a probe that says the machine is neither
reachable nor booted, because no probe is consulted. -/
@[req "RSC-43"]
theorem succeeded_under_a_failing_probe :
    Rehost.settleOn true { reachable := false, booted := false } = .succeeded := by decide

end Rehost

/-! ## The admission and halt matrices

`API-7`'s pipeline, `SEC-39`'s ceilings, `LDG-20`'s solvency halt and `LDG-40`'s rate matrix. Every
field of `Admission.current` has a pair that flips it and asserts what that field decides, as
`ci.yml`'s other rows do. The requests are named rather than inlined so each refused proposition
carries a token of its own. -/

section Admission
open Provisiond.Admission

/-- An ordinary create: an active tenant, its own token, on the public listener, under its
ceiling. -/
def freshCreate : Request :=
  { principal := .customer, listener := .customer, verb := .create, tenant := .active,
    admin := false, replay := false, atCeiling := false, override := false,
    acknowledged := true }

/-- The same create with `SEC-39`'s counter already at the limit. -/
def createAtCeiling : Request := { freshCreate with atCeiling := true }

/-- `API-7` step 5a's replay — "an equal fingerprint under the same `(principal, key)`" — under
budget. -/
def replayUnderBudget : Request := { freshCreate with replay := true }

/-- The same replay with the principal's budget already spent. -/
def replayAtCeiling : Request := { freshCreate with replay := true, atCeiling := true }

/-- `WIR-42`'s attribution to a tenant that "MAY be `pending`, the ordinary case since a
returning customer enrols afresh", which is `API-7`'s worked case for the operator carve-out. -/
def pendingAttribution : Request :=
  { principal := .operator, listener := .operator, verb := .attributeDeposit, tenant := .pending,
    admin := false, replay := false, atCeiling := false, override := false,
    acknowledged := true }

/-- An ordinary tenant write after `API-58`'s suspension. -/
def suspendedInstall : Request :=
  { freshCreate with verb := .install, tenant := .suspended }

/-- `API-56`'s revocation by the recovery credential, with the tenant suspended: the case step 2's
carve-out exists for. -/
def suspendedRevoke : Request :=
  { principal := .recovery, listener := .customer, verb := .revoke, tenant := .suspended,
    admin := false, replay := false, atCeiling := false, override := false,
    acknowledged := true }

/-- `WIR-43`'s statement, written by a tenant `SEC-45` suspended for not answering. -/
def suspendedStatement : Request :=
  { freshCreate with verb := .abuseStatement, tenant := .suspended }

/-- A customer-authenticated request to an operator route (`WIR-51`'s retry), on the public
listener. -/
def customerHitsAnOperatorRoute : Request := { freshCreate with verb := .retry }

/-- The create the pipeline is supposed to admit, so nothing here is refused vacuously. -/
@[req "API-7"]
theorem a_plain_create_is_admitted :
    (admit Admission.current freshCreate).map Outcome.verdict = some .admitted := by decide

/-- `API-7` step 5c as added 2026-09-02: an ordinary create spends one slot of "machines created
per interval", and the create at its limit is refused `ceiling_exceeded`. Without the step "a
builder following these steps literally shipped no ceilings at all while the requirement and its
test both existed". -/
@[req "API-7"]
theorem the_ceiling_refuses_the_create_at_its_limit :
    (admit Admission.current freshCreate).map Outcome.slotSpent = some true ∧
      admit Admission.current createAtCeiling =
        some { verdict := .refused .ceilingExceeded, slotSpent := false } := by decide

/-- Without step 5c the same request is admitted. -/
@[req "API-7"]
theorem the_ceiling_admits_it_without_the_step :
    (admit { Admission.current with ceilingStep := false } createAtCeiling).map Outcome.verdict =
      some .admitted := by decide

/-- `API-7`: 5c sits after 5a so that "a replay must return its stored result rather than spend a
slot it already spent". Under budget the replay consumes nothing, and at the limit it is still the
stored result rather than a refusal — a replay is never charged against a fresh budget. -/
@[req "API-7"]
theorem a_replay_is_never_charged :
    admit Admission.current replayUnderBudget = some { verdict := .replayed, slotSpent := false } ∧
      admit Admission.current replayAtCeiling = some { verdict := .replayed, slotSpent := false } := by
  decide

/-- With the policy steps ahead of the fingerprint, the replay spends a second slot out of a fresh
budget and, at the limit, is refused instead of returning what it already returned. Step 5c is
pinned on, since without it there is no budget to spend and this pair would say nothing. -/
@[req "API-7"]
theorem a_replay_is_charged_without_the_ordering :
    (admit { Admission.current with replayBeforePolicy := false, ceilingStep := true }
      replayUnderBudget).map Outcome.slotSpent = some true ∧
      (admit { Admission.current with replayBeforePolicy := false, ceilingStep := true }
        replayAtCeiling).map Outcome.verdict = some (.refused .ceilingExceeded) := by decide

/-- `API-7`, 2026-09-04: "**Every operator verb skips 2 and 5b**, whether or not it names a
tenant", so the attribution to a pending tenant is admitted. -/
@[req "API-7"]
theorem the_operator_attributes_to_a_pending_tenant :
    (admit Admission.current pendingAttribution).map Outcome.verdict = some .admitted := by decide

/-- Without the carve-out the step tests a tenant the operator principal does not have, and "the
only route back for an orphaned balance failed `not_activated`". -/
@[req "API-7"]
theorem the_orphaned_balance_has_no_route_back_without_the_carve_out :
    (admit { Admission.current with operatorSkipsTenantSteps := false }
      pendingAttribution).map Outcome.verdict = some (.refused .notActivated) := by decide

/-- `API-7`: step 2 "MUST NOT look at suspension" and "A `suspended` tenant passes it and is
rejected at 5b instead". -/
@[req "API-7"]
theorem the_suspended_tenant_is_refused_at_five_b :
    stepTwo Admission.current suspendedInstall = none ∧
      stepFiveB Admission.current suspendedInstall = some .suspended := by decide

/-- The withdrawn wording, "reject unless the tenant is active", refuses at step 2 — which "made 5b
unreachable and defeated its stated reason for existing: every write retried after its tenant was
suspended lost the stored idempotent result `API-11` promises it". -/
@[req "API-7"]
theorem the_withdrawn_wording_refuses_at_step_two :
    stepTwo { Admission.current with stepTwoReadsSuspension := true } suspendedInstall =
      some .suspended := by decide

/-- Step 2's maintenance actions: revoke is "authorized by principal rather than by tenant state",
so the owner of a suspended tenant can still replace a stolen credential. -/
@[req "API-7"]
theorem the_suspended_tenant_can_still_revoke :
    (admit Admission.current suspendedRevoke).map Outcome.verdict = some .admitted := by decide

/-- Without the carve-out, gating it on tenant state "would leave a suspended or pending tenant
unable to replace a stolen credential — locking the owner out at exactly the moment the mechanism
exists for". -/
@[req "API-7"]
theorem the_owner_is_locked_out_without_the_carve_out :
    (admit { Admission.current with maintenanceCarveOut := false } suspendedRevoke).map Outcome.verdict = some (.refused .suspended) := by decide

/-- `API-7`, added 2026-08-16: "**The abuse-statement write (`WIR-43`) is a maintenance action and
MUST remain reachable while suspended**". 5b is the step that would refuse it, and the assertion is
made there rather than on the whole pipeline because the withdrawn step-2 wording refuses it too —
one flip, one witness. -/
@[req "API-7"]
theorem the_statement_survives_the_suspension :
    stepFiveB Admission.current suspendedStatement = none := by decide

/-- Without it, "`SEC-45` names an unanswered notice as a reason to suspend, so without this the
operator's escalation for silence is what guarantees the silence". -/
@[req "API-7"]
theorem silence_is_guaranteed_without_the_statement_rule :
    stepFiveB { Admission.current with statementWhileSuspended := false } suspendedStatement =
      some .suspended := by decide

/-- `WIR-34`: the operator route answers `404` to a customer-authenticated request, "so their
existence is not customer-observable". -/
@[req "WIR-34"]
theorem the_operator_route_is_not_customer_observable :
    admit Admission.current customerHitsAnOperatorRoute =
      some { verdict := .refused .notFound, slotSpent := false } := by decide

/-- Without the split the same request is answered `authentication`, which is the one answer
`WIR-34` names and refuses: "MUST return `404` — never `authentication`". -/
@[req "WIR-34"]
theorem the_route_announces_itself_without_the_split :
    (admit { Admission.current with listenerSplit := false } customerHitsAnOperatorRoute).map Outcome.verdict = some (.refused .authentication) := by decide

/-- `API-43`'s allowlist, which exists because "`API-35` will not graduate a tenant until a payment
is credited, so an enrolment that cannot pay is a dead end": the pending tenant's deposit is
admitted and its create is not. -/
@[req "API-43"]
theorem the_pending_tenant_may_fund_itself_and_buy_nothing :
    admit Admission.current { freshCreate with verb := .deposit, tenant := .pending } =
        some { verdict := .admitted, slotSpent := false } ∧
      (admit Admission.current { freshCreate with tenant := .pending }).map Outcome.verdict = some (.refused .notActivated) := by decide

/-- `API-56`: "The recovery credential MAY revoke the spending token …; the spending token MUST NOT
be able to do either", and `API-55` confines the recovery credential to that one route. Neither
credential reaches the other's surface. -/
@[req "API-56"]
theorem neither_credential_reaches_the_other :
    (admit Admission.current { freshCreate with verb := .revoke }).map Outcome.verdict = some (.refused .authentication) ∧
      (admit Admission.current { freshCreate with principal := .recovery }).map Outcome.verdict = some (.refused .authentication) := by decide

/-- `SEC-39`'s "stated override path for a genuine incident", which `API-7` 5c makes the only
exemption that reaches this pipeline: the create standing at its limit is admitted while the
override is in force, and refused the moment it is not. Step 5c is pinned on for the second half,
which is `the_ceiling_refuses_the_create_at_its_limit`'s subject and not this one's. -/
@[req "SEC-39"]
theorem the_incident_override_admits_past_the_limit :
    (admit Admission.current { createAtCeiling with override := true }).map Outcome.verdict =
        some .admitted ∧
      (admit { Admission.current with ceilingStep := true } createAtCeiling).map Outcome.verdict =
        some (.refused .ceilingExceeded) := by decide

/-- The cell `API-5` does not decide, written out: an operator token without the admin flag on a
customer route. The header it would need "MUST be ignored rather than honoured for it", so the
request names no tenant and steps 2 and 5b have nothing to test; with the flag the same request is
an ordinary one. `the_one_undecided_cell` is the claim that this is the only such cell. -/
@[req "API-5"]
theorem a_non_admin_operator_on_a_customer_route_is_undecided :
    admit Admission.current { freshCreate with principal := .operator } = none ∧
      (admit Admission.current
        { freshCreate with principal := .operator, admin := true }).map Outcome.verdict =
          some .admitted := by decide

/-! ### `LDG-20`'s halt and `LDG-40`'s rate matrix -/

/-- The deposit under a failing solvency check: `API-7`'s row refuses it `halted` because "that
halt stops top-ups *first*, and minting a destination invites exactly the payment it forbids". -/
def haltedMint : Action := .caller .deposit

/-- Every action that reduces exposure, under the halt. -/
def exposureReducingUnderHalt : List (Option Tables.ErrorKind) :=
  (Action.all.filter Action.reducesExposure).map (underHalt Admission.current)

/-- The same actions under a rate outage. -/
def exposureReducingWithoutRate : List RateAnswer :=
  (Action.all.filter Action.reducesExposure).map (underNoRate Admission.current)

/-- An unsettled Lightning invoice on an unexpired deposit, once the halt is declared. -/
def unsettledUnexpiredInvoice : Bool :=
  destinationAfterHalt Admission.current .lightning false false

/-- `LDG-20`: "On failure the system MUST halt top-ups first", and the 2026-08-31 amendment reads
"halt top-ups" halts minting, and only minting. The mint is refused; money that arrives anyway is
credited on both rails, because "Refusing or holding an arrived payment is `LDG-43`'s forbidden
outcome" — and an HTLC that settles as the cancel lands is one of those arrivals. -/
@[req "LDG-20"]
theorem the_halt_refuses_the_mint_and_credits_the_arrival :
    underHalt Admission.current haltedMint = some .halted ∧
      creditArrival Admission.current .lightning = none ∧
      creditArrival Admission.current .onchain = none ∧
      arrivalIsCredited Admission.current .lightning true = true := by decide

/-- Without that amendment the halt is the wholesale one it claimed to be, and the stranger's
satoshis are refused with nothing that can return them. -/
@[req "LDG-20"]
theorem the_arrival_is_refused_without_the_amendment :
    creditArrival { Admission.current with haltMintsOnly := false } .lightning = some .halted := by
  decide

/-- `LDG-20`: "**Cancel unsettled Lightning invoices on unexpired deposits.**" The settled one is
not cancelled — "An HTLC that settles concurrently with the cancel **was** received and MUST be
credited" — the expired one needs nothing, and the on-chain address stays payable, since the
deployment MUST "**State that the on-chain rail cannot be halted**". -/
@[req "LDG-20"]
theorem the_halt_closes_the_unsettled_invoice_and_nothing_else :
    unsettledUnexpiredInvoice = false ∧
      destinationAfterHalt Admission.current .lightning true false = true ∧
      destinationAfterHalt Admission.current .lightning false true = true ∧
      destinationAfterHalt Admission.current .onchain false false = true := by decide

/-- Without the cancellation "the float keeps growing during a declared insolvency, from
destinations issued before it, and the requirement claimed a protection it could not deliver". -/
@[req "LDG-20"]
theorem the_float_keeps_growing_without_the_cancellation :
    destinationAfterHalt { Admission.current with cancelUnsettledInvoices := false } .lightning
      false false = true := by decide

/-- `LDG-20`: "The operations that *reduce* exposure MUST never be gated by the check that fires
because exposure is too high" — over every such action, while the purchase beside them is refused.
-/
@[req "LDG-20"]
theorem nothing_that_reduces_exposure_is_halted :
    exposureReducingUnderHalt.all (· == none) = true ∧
      underHalt Admission.current (.caller .create) = some .halted := by decide

/-- Without the exemption the halt reaches the delete, the release, the retry, the operator's
suspension and the sweep's own cancellation — "refusing them because exposure is too high is the
failure `LDG-20` already forbids". -/
@[req "LDG-20"]
theorem the_halt_reaches_the_delete_without_the_exemption :
    underHalt { Admission.current with exposureExemptUnderHalt := false } (.caller .deleteMachine) =
        some .halted ∧
      underHalt { Admission.current with exposureExemptUnderHalt := false } .systemCancellation =
        some .halted := by decide

/-- `LDG-40`'s matrix with no rate: the sweep and every other exposure-reducing action continue,
the create halts "priced at an unknown rate", the extension halts with it, the solvency check
"fail[s] closed" and the meter runs native (`LDG-64`). -/
@[req "LDG-40"]
theorem the_rate_matrix_halts_the_purchase_and_nothing_else :
    exposureReducingWithoutRate.all (· == .continues) = true ∧
      underNoRate Admission.current (.caller .create) = .halts ∧
      underNoRate Admission.current (.caller .extendRunway) = .halts ∧
      underNoRate Admission.current .rederivation = .halts ∧
      underNoRate Admission.current .solvencyCheck = .failsClosed ∧
      underNoRate Admission.current .metering = .metersNative := by decide

/-- Without the sweep's row the outage stops the one activity that reduces exposure, though
`LDG-65` leaves it "the last derived `runway_until`" to run on: "what is suspended is *pricing*,
not *protection*". -/
@[req "LDG-40"]
theorem the_outage_stops_the_sweep_without_its_row :
    underNoRate { Admission.current with sweepContinuesWithoutRate := false } .exhaustionSweep
      = .halts := by decide

/-- `LDG-59`: "a USD quorum loss halts nothing priced in EUR". -/
@[req "LDG-59"]
theorem a_usd_outage_halts_nothing_priced_in_eur :
    rateAvailableFor (· == .usd) .eur = true ∧ rateAvailableFor (· == .usd) .usd = false := by
  decide

end Admission

end Provisiond.Witnesses
