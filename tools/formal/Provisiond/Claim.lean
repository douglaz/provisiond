import Provisiond.Types
/-! `ADR-0022`'s claim model: the `operations` row as its guards see it, the claim, the worker's
write and the defer as guarded writes, the settlement transaction under `OPS-49`'s
whole-transaction retry, and the engine's claim step. The first **reference model**
(`CONTEXT.md`).

What the model omits: `OPS-15`'s startup pass and `OPS-27`'s resolution writes (made by no
execution; `pv-vwe.5`), `API-58`'s fan-out transition (`pv-vwe.6`), `OPS-11`'s classification of a
provider outcome into the state the worker writes (a closed table, `pv-vwe.2`), `available_at`,
the error classes `OPS-49` says "are not store errors and do not consume the bound" (a
`StoreOutcome.refused` here is always a store error in that sense), the bound on repeating a
refused claim (`engineClaim` claims again from `idle` without counting), and a second engine —
`OPS-47`'s single engine is assumed throughout, as `OPS-6` says the number "is not a fence against
a second engine". -/

namespace Provisiond.Claim

inductive Status
  | queued | running | succeeded | failed | needsReconciliation
  deriving DecidableEq, Repr

/-- The states `STO-3`'s worker write moves an operation to — "every settled-state write, and a
worker moving its own operation into `needs_reconciliation`". `queued` and `running` are not among
them: the set has no worker write to either, and the type says so rather than a hypothesis.
`needs_reconciliation` is not a settled state (`OPS-3`), which is why this is not named one. -/
inductive Written
  | succeeded | failed | needsReconciliation
  deriving DecidableEq, Repr

def Written.status : Written → Status
  | .succeeded => .succeeded
  | .failed => .failed
  | .needsReconciliation => .needsReconciliation

theorem Written.status_ne_running (s : Written) : s.status ≠ .running := by
  cases s <;> simp [Written.status]

/-- The `operations` row as the guards read it. `record` stands for the columns a worker's write
carries beside the status, abstracted to one value: `STO-3`'s "the written columns are not
distinct from what is being written" compares it. `revision` "strictly increases on every
client-visible change (`API-53`)", and a status change is one. -/
structure Row where
  status   : Status
  claim    : ClaimNumber
  record   : Nat
  revision : Nat
  deriving DecidableEq, Repr

/-- A worker's write: the state it moves to, the columns it writes, the number it holds. -/
structure WorkerWrite where
  written : Written
  record  : Nat
  mine    : ClaimNumber
  deriving DecidableEq, Repr

/-- The terms `STO-3`'s worker guard gained by dated amendment, each a parameter so that removing
one is a one-token change a witness theorem exercises. `claimTerm` is `claim_number = mine`, on
both branches; `repeatBranch` is the second branch, which "admits the row this same execution's
write already produced". Both are `ADR-0022`'s, 2026-09-12. -/
structure Guards where
  claimTerm    : Bool
  repeatBranch : Bool
  deriving DecidableEq, Repr

/-- `STO-3` as it stands: both terms present. -/
@[req "STO-3"]
def current : Guards := { claimTerm := true, repeatBranch := true }

/-- The row count a conditional write reports (`OPS-22`), with the branch that produced it:
`moved` is one row on the first branch, `repeated` one row on the second, `zeroRows` is
"something that was not this execution moved the operation". -/
inductive WriteResult
  | moved | repeated | zeroRows
  deriving DecidableEq, Repr

/-- The claim term, or `true` where the guard lacks it. -/
def holds (g : Guards) (r : Row) (mine : ClaimNumber) : Bool :=
  !g.claimTerm || r.claim == mine

/-- `STO-3`, the worker's write: guarded on `(id, status = running, claim_number = mine) OR (id,
status = target, claim_number = mine, the written columns are not distinct from what is being
written)`. -/
@[req "STO-3"]
def workerGuard (g : Guards) (r : Row) (w : WorkerWrite) : WriteResult :=
  if r.status == .running && holds g r w.mine then .moved
  else if g.repeatBranch && r.status == w.written.status && holds g r w.mine
      && r.record == w.record then .repeated
  else .zeroRows

/-- The worker's write applied. `revision` "advance[s] only on the first branch". -/
@[req "STO-3"]
def workerWrite (g : Guards) (r : Row) (w : WorkerWrite) : Row :=
  if workerGuard g r w = .moved then
    { r with status := w.written.status, record := w.record, revision := r.revision + 1 }
  else r

/-- `STO-3`'s fifth guarded write, `OPS-8`'s defer: `running` back to `queued`, guarded on `(id,
status = running, claim_number = mine)`. Zero rows means "already deferred or already claimed
again; the worker moves on". -/
@[req "OPS-8"]
def defer (g : Guards) (r : Row) (mine : ClaimNumber) : Row :=
  if r.status == .running && holds g r mine then
    { r with status := .queued, revision := r.revision + 1 }
  else r

/-- `OPS-5`, `OPS-6`: the claim marks `running`, increments the number and returns it to the
worker, in one indivisible step. `admitted = false` is the claim `STO-51`'s index refuses
(`OPS-8`), which "never left `queued` and does not advance the number". -/
@[req "OPS-6"]
def claim (admitted : Bool) (r : Row) : Row × Option ClaimNumber :=
  if admitted && r.status == .queued then
    let n : ClaimNumber := ⟨r.claim.n + 1⟩
    ({ r with status := .running, claim := n, revision := r.revision + 1 }, some n)
  else (r, none)

/-! ## The claim term -/

/-- With the claim term, a worker's write carrying a number the row does not hold is inert. -/
@[req "OPS-6"]
theorem stale_write_inert (g : Guards) (hg : g.claimTerm = true) (r : Row) (w : WorkerWrite)
    (h : r.claim ≠ w.mine) : workerWrite g r w = r := by
  simp [workerWrite, workerGuard, holds, hg, h]

/-- With the claim term, a defer carrying a number the row does not hold is inert. -/
@[req "OPS-8"]
theorem stale_defer_inert (g : Guards) (hg : g.claimTerm = true) (r : Row) (mine : ClaimNumber)
    (h : r.claim ≠ mine) : defer g r mine = r := by
  simp [defer, holds, hg, h]

/-- `OPS-6`'s firing case, over every row and write: after a later claim, every write of every
earlier holder — worker write or defer — is inert, because the claim's number is strictly above
any number an earlier execution was returned. -/
@[req "OPS-6"]
theorem later_claim_makes_earlier_writes_inert (g : Guards) (hg : g.claimTerm = true) (r : Row)
    (hq : r.status = .queued) (w : WorkerWrite) (earlier : w.mine.n ≤ r.claim.n) :
    workerWrite g (claim true r).1 w = (claim true r).1 ∧
    defer g (claim true r).1 w.mine = (claim true r).1 := by
  have hne : (claim true r).1.claim ≠ w.mine := by
    simp only [claim, hq]
    intro h
    have := congrArg ClaimNumber.n h
    simp at this
    omega
  exact ⟨stale_write_inert g hg _ w hne, stale_defer_inert g hg _ w.mine hne⟩

/-- A refused claim does not advance the number (`OPS-6`). -/
@[req "OPS-6"]
theorem refused_claim_advances_nothing (r : Row) : claim false r = (r, none) := by
  simp [claim]

/-- Nor does a claim on a row that is not `queued`: `OPS-6` says the claim "MUST select the oldest
`queued` operation", so a `running` row is never claimed again while it runs. -/
@[req "OPS-6"]
theorem claim_needs_queued (r : Row) (h : r.status ≠ .queued) : claim true r = (r, none) := by
  simp [claim, h]

/-! ## The repeat branch -/

theorem workerGuard_moved_iff (g : Guards) (r : Row) (w : WorkerWrite) :
    workerGuard g r w = .moved ↔ r.status = .running ∧ holds g r w.mine = true := by
  unfold workerGuard; split <;> (try split) <;> simp_all

theorem workerWrite_of_moved (g : Guards) (r : Row) (w : WorkerWrite)
    (hm : workerGuard g r w = .moved) :
    workerWrite g r w =
      { r with status := w.written.status, record := w.record, revision := r.revision + 1 } := by
  simp [workerWrite, hm]

/-- `OPS-22`: "A repeated write after a lost reply (`OPS-49`) affects one row and changes
nothing, and is success." The row after a worker's write, `revision` included, is a fixed point
of that same write, with or without the repeat branch: the branch decides what the worker is
told, not what the row becomes. -/
@[req "OPS-22"]
theorem repeat_changes_nothing (g : Guards) (r : Row) (w : WorkerWrite) :
    workerWrite g (workerWrite g r w) w = workerWrite g r w := by
  have hs := w.written.status_ne_running
  by_cases hm : workerGuard g r w = .moved
  · rw [workerWrite_of_moved g r w hm]
    have : workerGuard g
        { r with status := w.written.status, record := w.record, revision := r.revision + 1 } w
        ≠ .moved := by
      simp [workerGuard_moved_iff, hs]
    simp [workerWrite, this]
  · simp [workerWrite, hm]

/-- With the repeat branch, the repeat of a write that moved the row is one row: `repeated`. -/
@[req "STO-3"]
theorem repeat_admitted (g : Guards) (hb : g.repeatBranch = true) (r : Row) (w : WorkerWrite)
    (hm : workerGuard g r w = .moved) : workerGuard g (workerWrite g r w) w = .repeated := by
  have hs := w.written.status_ne_running
  have hh := ((workerGuard_moved_iff g r w).mp hm).2
  rw [workerWrite_of_moved g r w hm]
  unfold workerGuard; split <;> (try split) <;> simp_all [holds]

/-- Without it, the repeat of the worker's own write is zero rows, which `OPS-22` reads as
"something that was not this execution moved the operation" — the engine exits on its own commit.
The pair, for the branch `ADR-0022` added. -/
@[req "STO-3"]
theorem repeat_refused_without_branch (g : Guards) (hb : g.repeatBranch = false) (r : Row)
    (w : WorkerWrite) (hm : workerGuard g r w = .moved) :
    workerGuard g (workerWrite g r w) w = .zeroRows := by
  have hs := w.written.status_ne_running
  rw [workerWrite_of_moved g r w hm]
  unfold workerGuard; split <;> (try split) <;> simp_all

/-! ## The transaction and its retry -/

/-- A settlement transaction: the guarded status write, then the money writes (`STO-28`,
`STO-45`, `OPS-27`'s rows) abstracted to the amounts they post. The status write is first by
construction. -/
structure Txn where
  status : WorkerWrite
  money  : List Int
  deriving Repr

/-- The store as the transaction sees it: the row and the ledger's posted total. -/
structure Store where
  row    : Row
  ledger : Int
  deriving DecidableEq, Repr

/-- `STO-3`: "The guarded status write precedes every money write in the transaction and
short-circuits the rest" — the money writes run on the first branch only. On the second branch the
transaction is the one this execution already committed, and it "changes nothing". -/
@[req "STO-3"]
def runTxn (g : Guards) (s : Store) (t : Txn) : Store × WriteResult :=
  match workerGuard g s.row t.status with
  | .moved => ({ row := workerWrite g s.row t.status, ledger := s.ledger + t.money.sum }, .moved)
  | res => (s, res)

/-- One try at the transaction under one store outcome. `refused` rolled back and said so;
`committed false` is the durable commit whose reply died in transport, so the store moved and the
worker learned nothing; `committed true` is the ordinary case. -/
def tryOnce (g : Guards) (s : Store) (t : Txn) : StoreOutcome → Store × Option WriteResult
  | .refused => (s, none)
  | .committed false => ((runTxn g s t).1, none)
  | .committed true => let (s', res) := runTxn g s t; (s', some res)

/-- `OPS-49`: "the component MUST repeat the **whole transaction** ... for a stated bound". The
list is the outcomes the store deals successive tries; its length is the bound, and running out
of it is exhaustion, `none`: the worker learned nothing and the engine exits. What the store holds
then is whatever the tries committed — after a lost reply on the last try the row is written and
the money posted once (`exhaustion_after_lost_reply`, in the witnesses), so `OPS-49`'s "the
outcome in hand is thrown away and `OPS-15` classifies the row as interrupted" describes the
tries that never committed. The provider call is not in this loop by construction: `t.status` is
the outcome already in hand, and nothing here calls anything. -/
@[req "OPS-49"]
def retryWhole (g : Guards) (s : Store) (t : Txn) :
    List StoreOutcome → Store × Option WriteResult
  | [] => (s, none)
  | o :: os =>
    match tryOnce g s t o with
    | (s', some res) => (s', some res)
    | (s', none) => retryWhole g s' t os

/-- The alternative `OPS-49` prohibits — "never the last failed statement" — made definable so it
can be refuted rather than assumed. After a lost reply the worker re-issues the statement that
was in flight, the last money write, alone on a fresh connection, and reports done. A refused
try repeats the whole transaction here, which is generous to the alternative: nothing landed, so
nothing distinguishes the two on that path. -/
def retryLast (g : Guards) (s : Store) (t : Txn) :
    List StoreOutcome → Store × Option WriteResult
  | [] => (s, none)
  | .refused :: os => retryLast g s t os
  | .committed true :: _ => let (s', res) := runTxn g s t; (s', some res)
  | .committed false :: _ =>
    let s' := (runTxn g s t).1
    ({ s' with ledger := s'.ledger + t.money.getLastD 0 }, some .moved)

theorem retryWhole_fixed (g : Guards) (s : Store) (t : Txn) (os : List StoreOutcome)
    (h : workerGuard g s.row t.status ≠ .moved) : (retryWhole g s t os).1 = s := by
  induction os with
  | nil => rfl
  | cons o os ih =>
    have hrun : runTxn g s t = (s, workerGuard g s.row t.status) := by
      unfold runTxn; split <;> simp_all
    cases o with
    | refused => simpa [retryWhole, tryOnce] using ih
    | committed acked => cases acked <;> simp [retryWhole, tryOnce, hrun, ih]

/-- `OPS-49` under `STO-3`: across every sequence of store outcomes, the money posts once or not
at all — never twice. The status term alone gives this: once the row has moved it is no longer
`running`, so no later try takes the first branch and the status write short-circuits the money
writes. The repeat branch is not needed for it; that branch decides whether the worker is told
`repeated` or `zeroRows` (`repeat_admitted`, `repeat_refused_without_branch`). -/
@[req "OPS-49"]
theorem posts_at_most_once (g : Guards) (s : Store) (t : Txn) (os : List StoreOutcome) :
    (retryWhole g s t os).1.ledger = s.ledger ∨
    (retryWhole g s t os).1.ledger = s.ledger + t.money.sum := by
  by_cases hm : workerGuard g s.row t.status = .moved
  · have hrun : runTxn g s t =
        ({ row := workerWrite g s.row t.status, ledger := s.ledger + t.money.sum }, .moved) := by
      simp [runTxn, hm]
    have hafter : ∀ os', (retryWhole g
        { row := workerWrite g s.row t.status, ledger := s.ledger + t.money.sum } t os').1.ledger =
        s.ledger + t.money.sum := by
      intro os'
      have hfix := retryWhole_fixed g
        { row := workerWrite g s.row t.status, ledger := s.ledger + t.money.sum } t os'
        (by simp [workerWrite_of_moved g _ _ hm, workerGuard_moved_iff,
                  t.status.written.status_ne_running])
      rw [hfix]
    induction os with
    | nil => left; rfl
    | cons o os ih =>
      cases o with
      | refused => simpa [retryWhole, tryOnce] using ih
      | committed acked => cases acked <;> simp [retryWhole, tryOnce, hrun, hafter]
  · left; rw [retryWhole_fixed g s t os hm]

/-- The prohibited alternative double-posts: a durable commit whose reply was lost, then the last
statement re-issued alone, posts the transaction's total and its last amount again. -/
@[req "OPS-49"]
theorem retryLast_double_posts (g : Guards) (s : Store) (t : Txn)
    (hm : workerGuard g s.row t.status = .moved) :
    (retryLast g s t [.committed false]).1.ledger =
      s.ledger + t.money.sum + t.money.getLastD 0 := by
  simp [retryLast, runTxn, hm]

/-! ## The claim's own lost reply -/

/-- The engine's claim state: between claims, holding a number, or exited for the supervisor. -/
inductive Engine
  | idle | holding (n : ClaimNumber) | exited
  deriving DecidableEq, Repr

/-- `OPS-49`: "A lost reply on the claim itself is fatal, not retried blind." A refused claim
rolled back and the engine claims again from `idle`; a lost reply leaves a `running` row whose
number no worker holds — "a claim repeated after a lost reply strands a `running` row with no
worker, which `OPS-15` says 'nothing but a restart can' do" — and the engine exits. -/
@[req "OPS-49"]
def engineClaim (r : Row) : StoreOutcome → Row × Engine
  | .refused => (r, .idle)
  | .committed false => ((claim true r).1, .exited)
  | .committed true =>
    match claim true r with
    | (r', some n) => (r', .holding n)
    | (r', none) => (r', .idle)

/-- The engine's step: only `idle` claims. `exited` has no successor but itself, so no claim
follows a lost reply on a claim: there is no transition out of `exited` for one to be. -/
@[req "OPS-49"]
def engineStep (e : Engine) (r : Row) (o : StoreOutcome) : Row × Engine :=
  match e with
  | .idle => engineClaim r o
  | .holding n => (r, .holding n)
  | .exited => (r, .exited)

/-- A lost reply on the claim is a transition to `exited`, and the row it strands is `running`. -/
@[req "OPS-49"]
theorem lost_claim_reply_exits (r : Row) (hq : r.status = .queued) :
    (engineStep .idle r (.committed false)).2 = .exited ∧
    (engineStep .idle r (.committed false)).1.status = .running := by
  simp [engineStep, engineClaim, claim, hq]

/-- No claim follows the exit: `exited` is absorbing under every outcome. -/
@[req "OPS-49"]
theorem exited_never_claims (r : Row) (o : StoreOutcome) :
    engineStep .exited r o = (r, .exited) := rfl

end Provisiond.Claim
