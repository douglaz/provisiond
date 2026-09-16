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

What the model omits, each `pv-vwe.10`'s: the rate as an optional value (`rate` here is a whole
number of satoshis per second and never absent, so `OPS-41`'s no-rate branch has no case); the
tenant's suspension; `OPS-42`'s "and on that episode being open" term (the fence write does not
read the episode); the gone-write and the tombstone; `LDG-16`'s `exhausted_since`; time, which
never advances, so `now` is the sweep's clock and the re-check's. The provider's answer is
classified as `succeeded` on a reply, `failed` on a refusal and `needs_reconciliation` on a lost
reply — `OPS-11`'s table is `Provisiond.Tables`'s and is not repeated. Also `pv-vwe.10`'s, and
hard-wired here as the requirements stand: `OPS-41`'s abort predicate (`World.funded` is
`abortDate`, never the withdrawn `abortSats`); the date write on the abort and on the extension
(both 2026-09-05, neither a parameter yet); `retry` only from `stalled`, executed but not
proved; and "a set fence names an open episode with the same id" as an invariant over reachable
worlds. Nobody's ticket: `LDG-62`'s sizing of a commitment it opens ("requested runway × current
customer rate + `protected_sats`") — `extend` takes the satoshis as given — and the
`late_attach_cleanup` record's `resolved_at`. A refused extension and one the balance cannot fund
(`LDG-10`) both leave the world as it was; the wire answer that distinguishes them is not
modelled. -/

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
  commitment  : Nat
  /-- The stored date the sweep routes on (`05-persistence.md`'s index). -/
  runwayUntil : Nat
  /-- `machines.destroy_committed`. -/
  fence       : Option Holder
  /-- The provider applied a delete. Monotone: nothing here restores a machine. -/
  destroyed   : Bool
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

/-- The two dated amendments of `OPS-42` this module carries, each a parameter so that removing it
is a one-token change a witness theorem exercises. `recheckInsideFence`: 2026-09-02, "`OPS-41`'s
re-check and this fence write MUST be one transaction". `fenceHolds`: 2026-09-08, "the fence holds
the episode, not the attempt". -/
structure Params where
  recheckInsideFence : Bool
  fenceHolds         : Holds
  deriving DecidableEq, Repr

/-- `OPS-42` as it stands. -/
@[req "OPS-42"]
def current : Params := { recheckInsideFence := true, fenceHolds := .episodeId }

/-- What this attempt writes into the fence column. -/
def Params.holder (p : Params) (a : Attempt) : Holder :=
  match p.fenceHolds with
  | .episodeId => .episode a.ep
  | .attemptId => .attempt a.op

/-- Where the worker is. `holding`: claimed, `OPS-8`'s hold on the machine, before the fence
transaction. `readUnfenced`: the split variant's phase between its read and its write, with what
the read said. `fenced`: the fence written on a machine read unfunded — the only phase a provider
call leaves from. `noMutation`: `OPS-41`'s abort, funded or "another actor won the race", to be
settled `succeeded`. `dispatched`: the provider call made, holding its reply or its loss. -/
inductive Phase
  | idle
  | holding (mine : ClaimNumber)
  | readUnfenced (mine : ClaimNumber) (unfunded : Bool)
  | fenced (mine : ClaimNumber)
  | noMutation (mine : ClaimNumber)
  | dispatched (mine : ClaimNumber) (reply : Option Bool)
  deriving DecidableEq, Repr

structure World where
  m       : Machine
  /-- The tenant's available balance. -/
  balance : Nat
  now     : Nat
  /-- Whole satoshis per second, `LDG-33`'s `current_customer_rate`. -/
  rate    : Nat
  /-- `protected_sats`. -/
  prot    : Nat
  episode : Option (EpisodeId × Episode)
  attempt : Option Attempt
  phase   : Phase
  nextId  : Nat
  deriving DecidableEq, Repr

/-- `OPS-41`'s test on what a transaction reads: funded iff "re-deriving `LDG-33` from what it
read now puts `runway_until` strictly in the future". -/
def World.funded (w : World) : Bool := abortDate w.m.commitment w.prot w.rate

/-- `LDG-33`'s re-derived `runway_until`, from `now`. -/
def World.rederived (w : World) : Nat := w.now + runwaySeconds w.m.commitment w.prot w.rate

def World.episodeOpen (w : World) : Bool := w.episode.any (·.2.isOpen)

/-! ## The events -/

/-- The exhaustion sweep: `LDG-14`'s "At end of runway the machine MUST be cancelled", routed on
the **stored** date and only that (`OPS-41`: "the sweep routes on the **stored** date"). It opens
the episode and enqueues the cancellation. It routes nothing while an episode is open — a second
cancellation of the same machine is what "`OPS-39`'s per-action episode key already prevents"
(`OPS-41`); joining an open episode is `pv-vwe.10`'s — or an attempt is still in flight. -/
@[req "LDG-14"]
def sweep (w : World) : World :=
  if w.phase == .idle && w.attempt.all Attempt.done && !w.episodeOpen
      && w.m.runwayUntil ≤ w.now then
    let ep : EpisodeId := ⟨w.nextId⟩
    { w with episode := some (ep, .attempting),
             attempt := some { op := ⟨w.nextId + 1⟩, ep := ep, row := freshRow },
             nextId := w.nextId + 2 }
  else w

/-- `OPS-8`: the claim, through the claim model. A row that is not `queued` is not claimed. -/
@[req "OPS-8"]
def claimStep (w : World) : World :=
  match w.phase, w.attempt with
  | .idle, some a =>
    match Claim.claim true a.row with
    | (r, some n) => { w with attempt := some { a with row := r }, phase := .holding n }
    | (_, none) => w
  | _, _ => w

/-- `OPS-42`'s conditional write, "guarded on `destroy_committed IS NULL` *or* `destroy_committed`
already holding this operation's episode id": one row where it admits, zero rows otherwise. -/
@[req "OPS-42"]
def fenceAdmits (m : Machine) (h : Holder) : Bool :=
  m.fence == none || m.fence == some h

/-- The write itself, on a machine read unfunded: the fence set and the worker `fenced`, or
"another actor won the race and the worker MUST abort the cancellation". -/
def writeFence (p : Params) (w : World) (n : ClaimNumber) (a : Attempt) : World :=
  if fenceAdmits w.m (p.holder a) then
    { w with m := { w.m with fence := some (p.holder a) }, phase := .fenced n }
  else { w with phase := .noMutation n }

/-- The fence transaction: `OPS-41`'s re-check "in the same serialized transaction that writes
`OPS-42`'s fence". Under `recheckInsideFence` it reads and writes in one step: a funded machine is
`noMutation` with no fence written, an unfunded one takes the write. Without it the transaction
is the read alone, and the write is `fenceWrite`'s later step. -/
@[req "OPS-41"]
def fenceTxn (p : Params) (w : World) : World :=
  match w.phase, w.attempt with
  | .holding n, some a =>
    if !p.recheckInsideFence then { w with phase := .readUnfenced n (!w.funded) }
    else if w.funded then { w with phase := .noMutation n }
    else writeFence p w n a
  | _, _ => w

/-- The split variant's second transaction: the fence write, deciding on what an earlier
transaction read. It exists only where the read and the write are split; under
`recheckInsideFence` there is no such step. -/
@[req "OPS-42"]
def fenceWrite (p : Params) (w : World) : World :=
  match p.recheckInsideFence, w.phase, w.attempt with
  | false, .readUnfenced n unfunded, some a =>
    if unfunded then writeFence p w n a else { w with phase := .noMutation n }
  | _, _, _ => w

/-- `LDG-62`: in its own transaction, "conditional-write the machine row guarded on
`machines.destroy_committed IS NULL`", failing `conflict` where it affects no row — "opening or
growing no commitment and moving no balance". Where it is admitted it grows the commitment from
available under "`LDG-10`'s no-negative rule" and writes the re-derived `runway_until`. -/
@[req "LDG-62"]
def extend (w : World) (sats : Nat) : World :=
  if w.m.fence != none || w.balance < sats then w
  else
    let c := w.m.commitment + sats
    { w with m := { w.m with commitment := c, runwayUntil := w.now + runwaySeconds c w.prot w.rate },
             balance := w.balance - sats }

/-- The provider call, outside every serialization (`LDG-69`), from `fenced` and nowhere else.
`applied` is the provider's fact and `reply` what came back (`ProviderOutcome`, flattened). -/
@[req "OPS-41"]
def providerDelete (w : World) (applied : Bool) (reply : Option Bool) : World :=
  match w.phase with
  | .fenced n =>
    { w with m := { w.m with destroyed := w.m.destroyed || applied }, phase := .dispatched n reply }
  | _ => w

/-- How the reply settles the attempt: `OPS-48`'s first column and `STO-3`'s written state. -/
def ofReply : Option Bool → Settled × Written
  | some true => (.gone, .succeeded)
  | some false => (.failed, .failed)
  | none => (.needsReconciliation, .needsReconciliation)

/-- The terminal transaction: `STO-3`'s guarded write on the row, and `OPS-48`'s row on the
episode with the fence cleared exactly where that row says. -/
def finish (w : World) (n : ClaimNumber) (a : Attempt) (e : EpisodeId) (st : Episode)
    (s : Settled) (wr : Written) : World :=
  let row := workerWrite Claim.current a.row { written := wr, record := 0, mine := n }
  let (st', cleared) := episodeStep currentRows st (.settled s)
  { w with attempt := some { a with row := row },
           episode := some (e, st'),
           m := { w.m with fence := if cleared then none else w.m.fence },
           phase := .idle }

/-- Settlement, from the abort or from the provider's answer. The abort also does what `OPS-41`
says of the funded case, "write that re-derived `runway_until` to the machine row", so the sweep
does not route the same machine on the next pass; the lost-race abort settles "as `OPS-41`
requires" (`OPS-42`) and is read here as the same terminal transaction, which on a machine read
unfunded stores a date no later than the one it had. -/
@[req "OPS-48"]
def settle (w : World) : World :=
  match w.phase, w.attempt, w.episode with
  | .noMutation n, some a, some (e, st) =>
    let w' := finish w n a e st .noMutation .succeeded
    { w' with m := { w'.m with runwayUntil := w.rederived } }
  | .dispatched n reply, some a, some (e, st) =>
    finish w n a e st (ofReply reply).1 (ofReply reply).2
  | _, _, _ => w

/-- `retry` (`API-64`), as `OPS-48`'s row has it: "on a `stalled` episode", "with a fresh attempt
enqueued in the same transaction as the state change; admissible in no other state". -/
@[req "OPS-48"]
def retry (w : World) : World :=
  match w.phase, w.attempt, w.episode with
  | .idle, some a, some (e, st) =>
    if a.done && st == .stalled then
      { w with episode := some (e, (episodeStep currentRows st .retry).1),
               attempt := some { op := ⟨w.nextId⟩, ep := e, row := freshRow },
               nextId := w.nextId + 1 }
    else w
  | _, _, _ => w

inductive Event
  | sweep | claim | fenceTxn | fenceWrite
  | extend (sats : Nat)
  | providerDelete (applied : Bool) (reply : Option Bool)
  | settle | retry
  deriving DecidableEq, Repr

def step (p : Params) (w : World) : Event → World
  | .sweep => sweep w
  | .claim => claimStep w
  | .fenceTxn => fenceTxn p w
  | .fenceWrite => fenceWrite p w
  | .extend s => extend w s
  | .providerDelete a r => providerDelete w a r
  | .settle => settle w
  | .retry => retry w

def run (p : Params) (w : World) : List Event → World
  | [] => w
  | e :: es => run p (step p w e) es

/-! ## Both commit orderings -/

/-- An admitted extension grows the commitment by what it took from available and writes the
re-derived date (`LDG-62`, 2026-09-05: "an extension that grew the commitment and wrote no date
left the stored one in the past"). -/
@[req "LDG-62"]
theorem extend_admitted (w : World) (sats : Nat) (hf : w.m.fence = none) (hb : sats ≤ w.balance) :
    (extend w sats).m.commitment = w.m.commitment + sats ∧
    (extend w sats).balance = w.balance - sats ∧
    (extend w sats).m.runwayUntil =
      w.now + runwaySeconds (w.m.commitment + sats) w.prot w.rate := by
  simp [extend, hf, Nat.not_lt.mpr hb]

/-- `OPS-42`: "Extension first: the worker's read sees the new commitment, `OPS-41` applies, and
it makes no provider call at all." With the read inside the fence transaction, an extension the
store admitted before it is what the re-check reads; where that grown commitment funds the
machine, the transaction decides no mutation, writes no fence, and the provider call is inert. -/
@[req "OPS-42"]
theorem extension_first (p : Params) (hp : p.recheckInsideFence = true) (w : World)
    (n : ClaimNumber) (a : Attempt) (hph : w.phase = .holding n) (ha : w.attempt = some a)
    (sats : Nat) (hf : w.m.fence = none) (hb : sats ≤ w.balance)
    (hfunded : abortDate (w.m.commitment + sats) w.prot w.rate = true) :
    (fenceTxn p (extend w sats)).phase = .noMutation n ∧
    (fenceTxn p (extend w sats)).m.fence = none ∧
    (fenceTxn p (extend w sats)).m.commitment = w.m.commitment + sats ∧
    ∀ applied reply,
      providerDelete (fenceTxn p (extend w sats)) applied reply = fenceTxn p (extend w sats) := by
  have hext : extend w sats =
      { w with m := { w.m with commitment := w.m.commitment + sats,
                                runwayUntil := w.now + runwaySeconds (w.m.commitment + sats) w.prot w.rate },
               balance := w.balance - sats } := by
    simp [extend, hf, Nat.not_lt.mpr hb]
  simp [hext, fenceTxn, hph, ha, hp, hf, World.funded, hfunded, providerDelete]

/-- `LDG-62`'s refusal: with the fence set, an extension changes nothing — no commitment, no
balance, no date. -/
@[req "LDG-62"]
theorem extend_refused_under_fence (w : World) (h : Holder) (hf : w.m.fence = some h)
    (sats : Nat) : extend w sats = w := by
  simp [extend, hf]

/-- `OPS-42`: "Fence first: the extension is refused, and the customer keeps its satoshis." A fence
transaction that reads unfunded and wins the write leaves the fence holding this attempt, and every
extension after it is `extend_refused_under_fence`'s: the commitment and the balance are what the
re-check read. -/
@[req "OPS-42"]
theorem fence_first (p : Params) (hp : p.recheckInsideFence = true) (w : World)
    (n : ClaimNumber) (a : Attempt) (hph : w.phase = .holding n) (ha : w.attempt = some a)
    (hunfunded : w.funded = false) (hadmit : fenceAdmits w.m (p.holder a) = true) (sats : Nat) :
    (fenceTxn p w).phase = .fenced n ∧
    (fenceTxn p w).m.fence = some (p.holder a) ∧
    extend (fenceTxn p w) sats = fenceTxn p w ∧
    (fenceTxn p w).m.commitment = w.m.commitment ∧ (fenceTxn p w).balance = w.balance := by
  have hft : fenceTxn p w =
      { w with m := { w.m with fence := some (p.holder a) }, phase := .fenced n } := by
    simp [fenceTxn, hph, ha, hp, hunfunded, writeFence, hadmit]
  refine ⟨by simp [hft], by simp [hft], ?_, by simp [hft], by simp [hft]⟩
  exact extend_refused_under_fence _ (p.holder a) (by simp [hft]) sats

/-! ## Destruction only after a fence transaction that read unfunded -/

/-- The `destroyed` flag flips in one step only: a provider call that applied, from `fenced`. -/
@[req "OPS-41"]
theorem destroyed_only_by_provider_from_fenced (p : Params) (w : World) (e : Event)
    (h : (step p w e).m.destroyed = true) (hw : w.m.destroyed = false) :
    ∃ n reply, e = .providerDelete true reply ∧ w.phase = .fenced n := by
  cases e with
  | providerDelete applied reply =>
    simp only [step] at h
    unfold providerDelete at h
    split at h
    · rename_i n hph
      cases applied
      · simp [hw] at h
      · exact ⟨n, reply, rfl, hph⟩
    · simp [hw] at h
  | sweep => simp only [step] at h; unfold sweep at h; split at h <;> simp_all
  | claim =>
    simp only [step] at h; unfold claimStep at h
    split at h <;> (try split at h) <;> simp_all
  | fenceTxn =>
    simp only [step] at h; unfold fenceTxn at h
    split at h <;> (try split at h) <;> (try split at h) <;> simp_all [writeFence] <;>
      (split at h <;> simp_all)
  | fenceWrite =>
    simp only [step] at h; unfold fenceWrite at h
    split at h <;> (try split at h) <;> simp_all [writeFence] <;> (split at h <;> simp_all)
  | extend s => simp only [step] at h; unfold extend at h; split at h <;> simp_all
  | settle => simp only [step] at h; unfold settle at h; split at h <;> simp_all [finish]
  | retry =>
    simp only [step] at h; unfold retry at h
    split at h <;> (try split at h) <;> simp_all

/-- Under `current`'s one-transaction rule, `fenced` is entered by the fence transaction alone,
from `holding`, on a machine whose re-check read unfunded — `OPS-41`: "after claiming the machine
(`OPS-8`) and before any provider mutation, re-read that machine's commitment and its
`runway_until` — in the same serialized transaction that writes `OPS-42`'s fence" — and it leaves
the fence holding this attempt. With `destroyed_only_by_provider_from_fenced`: destruction only
after a fence transaction whose re-check read unfunded. -/
@[req "OPS-41"]
theorem fenced_only_by_fence_txn (p : Params) (hp : p.recheckInsideFence = true) (w : World)
    (e : Event) (n : ClaimNumber) (h : (step p w e).phase = .fenced n)
    (hw : w.phase ≠ .fenced n) :
    e = .fenceTxn ∧ w.phase = .holding n ∧ w.funded = false ∧
    ∃ a, w.attempt = some a ∧ (step p w e).m.fence = some (p.holder a) := by
  cases e with
  | fenceTxn =>
    simp only [step] at h ⊢
    unfold fenceTxn at h ⊢
    split at h
    · rename_i n' a hph ha
      simp only [hp, Bool.not_true, Bool.false_eq_true, ↓reduceIte] at h ⊢
      split at h
      · simp at h
      · rename_i hfunded
        unfold writeFence at h ⊢
        split at h
        · simp at h; subst h
          exact ⟨by trivial, hph, by simpa using hfunded, a, ha, by simp [*]⟩
        · simp at h
    · exact absurd h hw
  | sweep => simp only [step] at h; unfold sweep at h; split at h <;> simp_all
  | claim =>
    simp only [step] at h; unfold claimStep at h
    split at h <;> (try split at h) <;> simp_all
  | fenceWrite => simp only [step] at h; unfold fenceWrite at h; split at h <;> simp_all
  | extend s => simp only [step] at h; unfold extend at h; split at h <;> simp_all
  | providerDelete a r =>
    simp only [step] at h; unfold providerDelete at h; split at h <;> simp_all
  | settle => simp only [step] at h; unfold settle at h; split at h <;> simp_all [finish]
  | retry =>
    simp only [step] at h; unfold retry at h
    split at h <;> (try split at h) <;> simp_all

/-- Between the fence write and the provider call nothing moves: with the fence set and the worker
`fenced`, every event but the provider call leaves the world as it is — the sweep routes nothing,
the extension is refused, the settlement has nothing to settle. -/
@[req "OPS-42"]
theorem fenced_waits_for_the_provider (p : Params) (w : World) (n : ClaimNumber) (h : Holder)
    (hph : w.phase = .fenced n) (hf : w.m.fence = some h) (e : Event)
    (he : ∀ applied reply, e ≠ .providerDelete applied reply) : step p w e = w := by
  cases e with
  | providerDelete a r => exact absurd rfl (he a r)
  | sweep => simp [step, sweep, hph]
  | claim => simp [step, claimStep, hph]
  | fenceTxn => simp [step, fenceTxn, hph]
  | fenceWrite => unfold step fenceWrite; split <;> simp_all
  | extend s => simp [step, extend, hf]
  | settle => simp [step, settle, hph]
  | retry => simp [step, retry, hph]

end Provisiond.Fence
