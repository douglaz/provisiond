import Provisiond.Claim
import Provisiond.Tables
/-! A stop during `execute`, composed with the claim guard and the classification table.
`OPS-21` says "The Stop-record bound is measured from the stop, counts every repeat including
serialization failures, and never resets." Time is discretized into positive unit-cost store
tries and serialization repeats; connection, execution, commit, read-back and backoff are included
in a try's cost. A real deadline and the supervisor's wait are implementation obligations.
A finite event prefix represents any execution, including an arbitrarily long serialization run.
The store-retry budget is independent and excludes serialization repeats. No provider call, restart,
fan-out or competing execution runs here. The parent's short delay is `none`, as in `Claim.defer`.
The schedule chooses tries, never a recorded outcome: `Claim.retryWhole` or the guarded defer
computes the store and acknowledgement. A lost reply can leave a written row on exit. -/

namespace Provisiond.StopRecord
open Provisiond.Claim Provisiond.Tables

structure Params where
  recordOnStop : Bool
  shieldRecord : Bool
  boundRecord : Bool
  deriving DecidableEq, Repr

@[req "OPS-21"]
def current : Params := { recordOnStop := true, shieldRecord := true, boundRecord := true }

/-- Redelivery belongs to the originating stop; `laterStop` is a distinct stop before the record lands.
`OPS-21` says "The record write MUST NOT be cancelled by the cancellation that stopped `execute`."
A lost lock connection is the originating stop or no event: `OPS-21` says it “is not a later stop”.
The generation refusal ends the record as `laterStop` does. -/
inductive Event
  | store (outcome : StoreOutcome) (redelivered : Bool)
  | serialization
  | laterStop
  | superseded
  deriving DecidableEq, Repr

structure Plan where
  tries : List StoreOutcome := []
  elapsed : Nat := 0
  unfinished : Bool := false
  deriving DecidableEq, Repr

/-- Prefix selection is structural recursion, with no deadline reset. An acknowledged try ends
selection even if its conditional write reports zero rows; settlement then exits under the guard.
Only an empty event suffix produces `unfinished = true`: its events end before selection finishes.
The recording-off guard produces a finished plan with no tries; it is not a permitted recording exit.
`OPS-49` says "A serialization failure is repeated at once". -/
@[req "OPS-21"]
def schedule (p : Params) (budget storeBudget : Nat) : List Event → Plan
  | [] => { unfinished := true }
  | e :: es =>
    if !p.recordOnStop || (p.boundRecord && budget == 0) || storeBudget == 0 then {} else
    match e with
    | .laterStop | .superseded => {}
    | .serialization =>
      let rest := schedule p (budget - 1) storeBudget es
      { rest with elapsed := rest.elapsed + 1 }
    | .store o redelivered =>
      if redelivered && !p.shieldRecord then {} else
      match o with
      | .committed true => { tries := [o], elapsed := 1 }
      | _ =>
        let rest := schedule p (budget - 1) (storeBudget - 1) es
        { rest with tries := o :: rest.tries, elapsed := rest.elapsed + 1 }

/-- The worker classifies a cut-off `conflict`; all other failure facts and markers are inputs. -/
@[req "OPS-21"]
def failure (f : Failure) : Failure := { f with kind := .conflict, cutOff := true }

inductive Record
  | settle (txn : Txn)
  | parent (mine : ClaimNumber)

/-- `OPS-21` says "It records no error." for the parent. `none` from the table selects the
ordinary guarded defer, not a settlement transaction or an invented parent error. -/
@[req "OPS-21"]
def record (tr : Rules) (k : Kind) (f : Failure) (m : Markers) (mine : ClaimNumber)
    (columns : Nat) (money : List Int) : Record :=
  match classify tr k (failure f) m with
  | some written => .settle { status := { written, record := columns, mine }, money }
  | none => .parent mine

/-- The parent's whole-transaction repeats: no money, and a repeated defer changes nothing.
A lost reply still repeats; where the defer affects no row, `OPS-8` says the meaning is
"already deferred, or already claimed again". -/
@[req "OPS-21"]
def repeatParent (g : Guards) (s : Store) (mine : ClaimNumber) :
    List StoreOutcome → Store × Bool
  | [] => (s, false)
  | .refused :: os => repeatParent g s mine os
  | .committed false :: os =>
    repeatParent g { s with row := defer g s.row mine } mine os
  | .committed true :: _ => ({ s with row := defer g s.row mine }, true)

def applyRecord (g : Guards) (s : Store) : Record → List StoreOutcome → Store × Bool
  | .settle t, os =>
    let (s', reply) := retryWhole g s t os
    (s', match reply with | some .moved | some .repeated => true | _ => false)
  | .parent mine, os => repeatParent g s mine os

structure Result where
  store : Store
  recorded : Bool
  elapsed : Nat
  deriving DecidableEq, Repr

/-- Recorded or not, with the actual durable store, including a commit whose reply was lost.
On an unfinished plan, `recorded = false` describes a prefix whose events end first.
On a finished plan under `finished_unrecorded_exit`'s recording and ownership hypotheses,
it is one of the exits that theorem names.
`OPS-21` says "The worker MUST NOT pursue the record past the Stop-record bound (`OVR-19`), and
the engine MUST NOT wait for it past that bound." -/
@[req "OPS-21"]
def trace (p : Params) (g : Guards) (s : Store) (r : Record)
    (budget storeBudget : Nat) (events : List Event) : Result :=
  let plan := schedule p budget storeBudget events
  let (s', recorded) := applyRecord g s r plan.tries
  { store := s', recorded, elapsed := plan.elapsed }

/-- Every prefix, however long, consumes at most the budget measured from the originating stop.
`OPS-21` says "The Stop-record bound is measured from the stop, counts every repeat including
serialization failures, and never resets." -/
@[req "OPS-21"]
theorem schedule_bounded (p : Params) (hb : p.boundRecord = true)
    (events : List Event) (budget storeBudget : Nat) :
    (schedule p budget storeBudget events).elapsed ≤ budget := by
  induction events generalizing budget storeBudget with
  | nil => simp [schedule]
  | cons e es ih =>
    have step (h : ¬(!p.recordOnStop || (p.boundRecord && budget == 0) || storeBudget == 0) = true) :
        0 < budget := by simp [hb] at h; omega
    cases e with
    | laterStop | superseded => simp [schedule]
    | serialization =>
      simp only [schedule]
      split
      · simp
      · rename_i h
        have := step h
        have := ih (budget - 1) storeBudget
        simp only; omega
    | store o redelivered =>
      cases o with
      | refused =>
        simp only [schedule]
        split
        · simp
        · rename_i h
          have := step h
          split
          · simp
          · have := ih (budget - 1) (storeBudget - 1)
            simp only; omega
      | committed acked =>
        cases acked
        · simp only [schedule]
          split
          · simp
          · rename_i h
            have := step h
            split
            · simp
            · have := ih (budget - 1) (storeBudget - 1)
              simp only; omega
        · simp only [schedule]
          split
          · simp
          · rename_i h
            have := step h
            split <;> simp <;> omega

@[req "OPS-21"]
theorem trace_bounded (p : Params) (hb : p.boundRecord = true) (g : Guards)
    (s : Store) (r : Record) (budget storeBudget : Nat) (events : List Event) :
    (trace p g s r budget storeBudget events).elapsed ≤ budget := by
  exact schedule_bounded p hb events budget storeBudget

/-- Any number of serialization repeats past expiry cannot reach the committing suffix. -/
@[req "OPS-21"]
theorem serialization_exhausts (n storeBudget : Nat) (suffix : List Event) :
    let plan := schedule ⟨true, true, true⟩ n (storeBudget + 1)
      (List.replicate n .serialization ++ suffix)
    plan.tries = [] ∧ plan.elapsed = n := by
  induction n with
  | zero => cases suffix <;> simp [schedule]
  | succ n ih => simpa [List.replicate_succ, schedule] using ih

/-- Store exhaustion exits before any suffix, even serialization repeats. `OPS-21` says
"whichever ends first ends the record" about the independent bounds. -/
@[req "OPS-49"]
theorem store_exhaustion_exits (g : Guards) (s : Store) (r : Record) (budget : Nat)
    (suffix : List Event) :
    trace ⟨true, true, true⟩ g s r (budget + 1) 1 (.store .refused false :: suffix) =
      ⟨s, false, 1⟩ := by
  have exhausted : (schedule ⟨true, true, true⟩ budget 0 suffix).tries = [] ∧
      (schedule ⟨true, true, true⟩ budget 0 suffix).elapsed = 0 := by
    cases suffix <;> simp [schedule]
  cases r <;> simp [trace, schedule, exhausted.1, exhausted.2, applyRecord, retryWhole,
    tryOnce, repeatParent]

/-- A later stop exits immediately, unlike redelivery of the original stop (`OPS-49`:
"A worker cancelled during the retry loop stops retrying and exits"). -/
@[req "OPS-49"]
theorem later_stop_exits (p : Params) (g : Guards) (s : Store) (r : Record)
    (budget storeBudget : Nat) (pre es : List Event) :
    trace p g s r budget storeBudget (pre ++ .laterStop :: es) =
      trace p g s r budget storeBudget pre := by
  have stopped : ∀ budget storeBudget,
      (schedule p budget storeBudget (pre ++ .laterStop :: es)).tries =
        (schedule p budget storeBudget pre).tries ∧
      (schedule p budget storeBudget (pre ++ .laterStop :: es)).elapsed =
        (schedule p budget storeBudget pre).elapsed := by
    induction pre with
    | nil => intro budget storeBudget; simp [schedule]
    | cons e pre ih =>
      intro budget storeBudget
      cases e with
      | laterStop | superseded => simp [schedule]
      | serialization =>
        simp [schedule, (ih (budget - 1) storeBudget).1, (ih (budget - 1) storeBudget).2]
        split <;> simp
      | store o redelivered =>
        cases o with
        | refused =>
          simp [schedule, (ih (budget - 1) (storeBudget - 1)).1,
            (ih (budget - 1) (storeBudget - 1)).2]
          split <;> (try split) <;> simp
        | committed acked => cases acked <;> simp [schedule,
            (ih (budget - 1) (storeBudget - 1)).1, (ih (budget - 1) (storeBudget - 1)).2] <;>
            split <;> (try split) <;> simp
  simp only [trace, (stopped budget storeBudget).1, (stopped budget storeBudget).2]

/-- A generation refusal truncates selection after its durable prefix, including a commit
whose reply was lost. `exit_store` retains that alternative.
`OPS-50` says "A refused generation check ends recording without another attempt; an earlier
attempt may already have committed with its reply lost." -/
@[req "OPS-50"]
theorem superseded_exits (p : Params) (g : Guards) (s : Store) (r : Record)
    (budget storeBudget : Nat) (pre es : List Event) :
    trace p g s r budget storeBudget (pre ++ .superseded :: es) =
      trace p g s r budget storeBudget pre := by
  have stopped : ∀ budget storeBudget,
      (schedule p budget storeBudget (pre ++ .superseded :: es)).tries =
        (schedule p budget storeBudget pre).tries ∧
      (schedule p budget storeBudget (pre ++ .superseded :: es)).elapsed =
        (schedule p budget storeBudget pre).elapsed := by
    induction pre with
    | nil => intro budget storeBudget; simp [schedule]
    | cons e pre ih =>
      intro budget storeBudget
      cases e with
      | laterStop | superseded => simp [schedule]
      | serialization =>
        simp [schedule, (ih (budget - 1) storeBudget).1, (ih (budget - 1) storeBudget).2]
        split <;> simp
      | store o redelivered =>
        cases o with
        | refused =>
          simp [schedule, (ih (budget - 1) (storeBudget - 1)).1,
            (ih (budget - 1) (storeBudget - 1)).2]
          split <;> (try split) <;> simp
        | committed acked => cases acked <;> simp [schedule,
            (ih (budget - 1) (storeBudget - 1)).1, (ih (budget - 1) (storeBudget - 1)).2] <;>
            split <;> (try split) <;> simp
  simp only [trace, (stopped budget storeBudget).1, (stopped budget storeBudget).2]

/-- An acknowledged working store applies the computed classification or the parent's defer.
`OPS-21` says "A cancellation of `execute` that the engine survives MUST be recorded before
 the engine exits, for every operation kind"; the bounded abandonment conditions still apply. -/
@[req "OPS-21"]
theorem working_store_records (tr : Rules) (g : Guards) (s : Store) (k : Kind)
    (f : Failure) (m : Markers) (columns : Nat) (money : List Int)
    (running : s.row.status = .running) (mine : ClaimNumber) (owns : s.row.claim = mine)
    (budget storeBudget : Nat) (hb : 0 < budget) (hs : 0 < storeBudget) (redelivered : Bool) :
    let out := trace ⟨true, true, true⟩ g s (record tr k f m mine columns money)
      budget storeBudget [.store (.committed true) redelivered]
    out.recorded = true ∧ out.store.row.status ≠ .running ∧
    out.store.row.status =
      match classify tr k (failure f) m with | some w => w.status | none => .queued := by
  have hold : holds g s.row mine = true := by simp [holds, owns]
  have bz : budget ≠ 0 := by omega
  have sz : storeBudget ≠ 0 := by omega
  simp only [trace, schedule, record]
  split <;> simp [bz, sz, applyRecord, retryWhole, tryOnce, runTxn, workerGuard, running,
    hold, workerWrite, repeatParent, defer, Written.status_ne_running]

@[req "OPS-21"]
theorem parent_records_queued (tr : Rules) (g : Guards) (s : Store) (f : Failure)
    (m : Markers) (columns : Nat) (money : List Int) (mine : ClaimNumber)
    (running : s.row.status = .running) (owns : s.row.claim = mine) :
    let out := trace ⟨true, true, true⟩ g s (record tr .suspendTenant f m mine columns money)
      1 1 [.store (.committed true) true]
    out.recorded = true ∧ out.store.row.status = .queued ∧
      out.store.row.availableAt = none ∧ out.store.ledger = s.ledger := by
  simp [trace, schedule, record, classify, applyRecord, repeatParent, defer, holds, running, owns]

/-- A parent's defer is a fixed point. No later claim occurs inside this stop's record. -/
theorem defer_fixed (g : Guards) (r : Row) (mine : ClaimNumber) :
    defer g (defer g r mine) mine = defer g r mine := by
  unfold defer; split <;> simp_all

/-- Parent repeats never post money, including a lost-reply commit. -/
@[req "OPS-21"]
theorem parent_ledger (g : Guards) (s : Store) (mine : ClaimNumber) (os : List StoreOutcome) :
    (repeatParent g s mine os).1.ledger = s.ledger := by
  induction os generalizing s with
  | nil => rfl
  | cons o os ih => cases o with
    | refused => exact ih s
    | committed acked => cases acked <;> simp [repeatParent, ih]

@[req "OPS-21"]
theorem parent_trace_no_money (p : Params) (g : Guards) (s : Store) (mine : ClaimNumber)
    (budget storeBudget : Nat) (events : List Event) :
    (trace p g s (.parent mine) budget storeBudget events).store.ledger = s.ledger := by
  exact parent_ledger g s mine (schedule p budget storeBudget events).tries

/-- Composes `Claim.posts_at_most_once` for the selected whole-transaction tries; serialization
and the stop events, `superseded` included, never touch the store. `OPS-49`'s lost-reply case has "the money already
posted once". The parent's defer posts none. -/
@[req "OPS-49"]
theorem money_posts_at_most_once (p : Params) (g : Guards) (s : Store) (t : Txn)
    (budget storeBudget : Nat) (events : List Event) :
    (trace p g s (.settle t) budget storeBudget events).store.ledger = s.ledger ∨
    (trace p g s (.settle t) budget storeBudget events).store.ledger = s.ledger + t.money.sum := by
  exact posts_at_most_once g s t (schedule p budget storeBudget events).tries

/-- All durable settlement stores are either untouched or the one whole transaction's result. -/
theorem settlement_store (g : Guards) (s : Store) (t : Txn) (os : List StoreOutcome) :
    (retryWhole g s t os).1 = s ∨ (retryWhole g s t os).1 = (runTxn g s t).1 := by
  by_cases hm : workerGuard g s.row t.status = .moved
  · have after : workerGuard g (runTxn g s t).1.row t.status ≠ .moved := by
      simp [runTxn, hm, workerWrite_of_moved g _ _ hm, workerGuard_moved_iff,
        Written.status_ne_running]
    induction os with
    | nil => exact Or.inl rfl
    | cons o os ih =>
      cases o with
      | refused => simpa [retryWhole, tryOnce] using ih
      | committed acked =>
        cases acked
        · exact Or.inr (retryWhole_fixed g (runTxn g s t).1 t os after)
        · exact Or.inr rfl
  · exact Or.inl (retryWhole_fixed g s t os hm)

theorem parent_store (g : Guards) (s : Store) (mine : ClaimNumber) (os : List StoreOutcome) :
    (repeatParent g s mine os).1 = s ∨
    (repeatParent g s mine os).1 = { s with row := defer g s.row mine } := by
  induction os generalizing s with
  | nil => exact Or.inl rfl
  | cons o os ih =>
    cases o with
    | refused => exact ih s
    | committed acked =>
      cases acked
      · have h := ih { s with row := defer g s.row mine }
        right
        simpa only [repeatParent, defer_fixed, or_self] using h
      · exact Or.inr rfl

/-- The truthful exit case includes a lost-reply commit. `OPS-49` says "unless the bound's last
repeat committed and its reply was lost". On exit the initial running row remains for restart,
or the record is already written and its money posted once; a parent instead has a durable defer. -/
@[req "OPS-21"]
theorem exit_store (p : Params) (g : Guards) (s : Store) (r : Record)
    (budget storeBudget : Nat) (events : List Event) (running : s.row.status = .running) :
    let out := trace p g s r budget storeBudget events
    out.recorded = false →
      out.store.row.status = .running ∨
      match r with
      | .settle t => out.store.row.status = t.status.written.status ∧
          out.store.ledger = s.ledger + t.money.sum
      | .parent mine => out.store = { s with row := defer g s.row mine } := by
  intro out _
  cases r with
  | settle t =>
    rcases settlement_store g s t (schedule p budget storeBudget events).tries with h | h
    · left; simpa [out, trace, applyRecord, h] using running
    · by_cases hm : workerGuard g s.row t.status = .moved
      · right
        simp [out, trace, applyRecord, h, runTxn, hm, workerWrite_of_moved g _ _ hm]
      · left; simpa [out, trace, applyRecord, h, runTxn, hm] using running
  | parent mine =>
    rcases parent_store g s mine (schedule p budget storeBudget events).tries with h | h
    · left; simpa [out, trace, applyRecord, h] using running
    · right; exact h

/-- An acknowledged settlement try records under the repeat branch, even after a lost reply. -/
theorem settlement_acknowledged (g : Guards) (hb : g.repeatBranch = true)
    (s : Store) (t : Txn) (os : List StoreOutcome)
    (guard : workerGuard g s.row t.status ≠ .zeroRows)
    (ack : .committed true ∈ os) :
    (match (retryWhole g s t os).2 with
      | some .moved | some .repeated => true | _ => false) = true := by
  induction os generalizing s with
  | nil => simp at ack
  | cons o os ih =>
    have after : workerGuard g (runTxn g s t).1.row t.status ≠ .zeroRows := by
      cases hm : workerGuard g s.row t.status with
      | moved => simpa [runTxn, hm] using
          (show workerGuard g (workerWrite g s.row t.status) t.status ≠ .zeroRows by
            rw [repeat_admitted g hb s.row t.status hm]; decide)
      | repeated => simp [runTxn, hm]
      | zeroRows => exact False.elim (guard hm)
    cases o with
    | refused => simpa [retryWhole, tryOnce] using ih s guard (by simpa using ack)
    | committed a =>
      cases a with
      | false => simpa [retryWhole, tryOnce] using (ih (runTxn g s t).1 after (by simpa using ack))
      | true => cases hm : workerGuard g s.row t.status <;>
          simp_all [retryWhole, tryOnce, runTxn]

/-- The parent's acknowledgement is independent of whether the guarded defer changed a row. -/
theorem parent_acknowledged (g : Guards) (s : Store) (mine : ClaimNumber)
    (os : List StoreOutcome) (ack : .committed true ∈ os) :
    (repeatParent g s mine os).2 = true := by
  induction os generalizing s with
  | nil => simp at ack
  | cons o os ih => cases o with
    | refused => simpa [repeatParent] using ih s (by simpa using ack)
    | committed a => cases a with
      | false => simpa [repeatParent] using (ih { s with row := defer g s.row mine } (by simpa using ack))
      | true => rfl

/-- A finished, unrecorded plan has consumed a bound or encountered a stop at its elapsed index.
Recording must be enabled: otherwise a finished plan can make no try without any exit fact.
The repeat branch is needed because a lost-reply settlement followed by an acknowledgement
otherwise reports zero rows. The initial running status and ownership of the record exclude
another execution's zero-row exit; parent acknowledgements need neither ownership nor status.
All hypotheses are fields or ownership conditions, independent of the current parameter values. -/
@[req "OPS-21"]
theorem finished_unrecorded_exit (p : Params) (g : Guards) (s : Store) (r : Record)
    (budget storeBudget : Nat) (events : List Event) (recording : p.recordOnStop = true)
    (repeatEnabled : g.repeatBranch = true) (running : s.row.status = .running)
    (owns : match r with
      | .settle t => s.row.claim = t.status.mine
      | .parent mine => s.row.claim = mine)
    (finished : (schedule p budget storeBudget events).unfinished = false)
    (unrecorded : (trace p g s r budget storeBudget events).recorded = false) :
    let plan := schedule p budget storeBudget events
    (p.boundRecord = true ∧ plan.elapsed = budget) ∨
    plan.tries.length = storeBudget ∨
    events[plan.elapsed]? = some .laterStop ∨
    events[plan.elapsed]? = some .superseded ∨
    (p.shieldRecord = false ∧ ∃ o, events[plan.elapsed]? = some (.store o true)) := by
  have selection : ∀ (events : List Event) (budget storeBudget : Nat),
      (schedule p budget storeBudget events).unfinished = false →
      let plan := schedule p budget storeBudget events
      .committed true ∈ plan.tries ∨
      (p.boundRecord = true ∧ plan.elapsed = budget) ∨
      plan.tries.length = storeBudget ∨
      events[plan.elapsed]? = some .laterStop ∨
      events[plan.elapsed]? = some .superseded ∨
      (p.shieldRecord = false ∧ ∃ o, events[plan.elapsed]? = some (.store o true)) := by
    intro events
    induction events with
    | nil => intro budget storeBudget done; simp [schedule] at done
    | cons e es ih =>
      intro budget storeBudget done
      by_cases halt : (!p.recordOnStop || (p.boundRecord && budget == 0) || storeBudget == 0) = true
      · have causes : (p.boundRecord = true ∧ budget = 0) ∨ storeBudget = 0 := by
          simpa [recording, Bool.and_eq_true] using halt
        rcases causes with h | h
        · exact Or.inr (Or.inl ⟨h.1, by simp [schedule, h.1, h.2]⟩)
        · exact Or.inr (Or.inr (Or.inl (by simp [schedule, h])))
      · have room : (p.boundRecord = true → 0 < budget) ∧ 0 < storeBudget := by
          have nonzero : (p.boundRecord = true → budget ≠ 0) ∧ storeBudget ≠ 0 := by
            simpa [recording, Bool.and_eq_true] using halt
          exact ⟨fun h => Nat.pos_of_ne_zero (nonzero.1 h), Nat.pos_of_ne_zero nonzero.2⟩
        cases e with
        | laterStop | superseded => simp [schedule, halt]
        | serialization =>
          have h := ih (budget - 1) storeBudget (by simpa [schedule, halt] using done)
          rcases h with ack | bound | store | later | superseded | redelivery
          · exact Or.inl (by simpa [schedule, halt] using ack)
          · exact Or.inr (Or.inl (by
              simp only [schedule, halt, Bool.false_eq_true, ↓reduceIte]
              exact ⟨bound.1, by have := room.1 bound.1; omega⟩))
          · exact Or.inr (Or.inr (Or.inl (by simpa [schedule, halt] using store)))
          · exact Or.inr (Or.inr (Or.inr (Or.inl (by simpa [schedule, halt] using later))))
          · exact Or.inr (Or.inr (Or.inr (Or.inr (Or.inl (by
              simpa [schedule, halt] using superseded)))))
          · exact Or.inr (Or.inr (Or.inr (Or.inr (Or.inr (by simpa [schedule, halt] using redelivery)))))
        | store o redelivered =>
          by_cases delivered : (redelivered && !p.shieldRecord) = true
          · have red : redelivered = true ∧ p.shieldRecord = false := by simpa using delivered
            simp [schedule, halt, red.1, red.2]
          · cases o with
            | committed a => cases a with
              | true => simp [schedule, halt, delivered]
              | false =>
                have h := ih (budget - 1) (storeBudget - 1)
                  (by simpa [schedule, halt, delivered] using done)
                rcases h with ack | bound | store | later | superseded | redelivery
                · exact Or.inl (by simpa [schedule, halt, delivered] using ack)
                · exact Or.inr (Or.inl (by
                    simp only [schedule, halt, delivered, Bool.false_eq_true, ↓reduceIte]
                    exact ⟨bound.1, by have := room.1 bound.1; omega⟩))
                · exact Or.inr (Or.inr (Or.inl (by
                    simp only [schedule, halt, delivered, Bool.false_eq_true, ↓reduceIte, List.length_cons]
                    omega)))
                · exact Or.inr (Or.inr (Or.inr (Or.inl (by
                    simpa [schedule, halt, delivered] using later))))
                · exact Or.inr (Or.inr (Or.inr (Or.inr (Or.inl (by
                    simpa [schedule, halt, delivered] using superseded)))))
                · exact Or.inr (Or.inr (Or.inr (Or.inr (Or.inr (by simpa [schedule, halt, delivered] using redelivery)))))
            | refused =>
                have h := ih (budget - 1) (storeBudget - 1)
                  (by simpa [schedule, halt, delivered] using done)
                rcases h with ack | bound | store | later | superseded | redelivery
                · exact Or.inl (by simpa [schedule, halt, delivered] using ack)
                · exact Or.inr (Or.inl (by
                    simp only [schedule, halt, delivered, Bool.false_eq_true, ↓reduceIte]
                    exact ⟨bound.1, by have := room.1 bound.1; omega⟩))
                · exact Or.inr (Or.inr (Or.inl (by
                    simp only [schedule, halt, delivered, Bool.false_eq_true, ↓reduceIte, List.length_cons]
                    omega)))
                · exact Or.inr (Or.inr (Or.inr (Or.inl (by
                    simpa [schedule, halt, delivered] using later))))
                · exact Or.inr (Or.inr (Or.inr (Or.inr (Or.inl (by
                    simpa [schedule, halt, delivered] using superseded)))))
                · exact Or.inr (Or.inr (Or.inr (Or.inr (Or.inr (by simpa [schedule, halt, delivered] using redelivery)))))
  rcases selection events budget storeBudget finished with ack | exits
  · have recorded : (applyRecord g s r (schedule p budget storeBudget events).tries).2 = true := by
      cases r with
      | parent mine => exact parent_acknowledged g s mine _ ack
      | settle t =>
        apply settlement_acknowledged g repeatEnabled s t _ _ ack
        simp [workerGuard, running, holds, owns]
    simp [trace, recorded] at unrecorded
  · exact exits

end Provisiond.StopRecord
