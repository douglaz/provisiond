import Provisiond.Req
import Std

/-! WAL history checking interpretation for `STO-7` and `STO-54` (pv-26ju).

`STO-7`: "Before exposing a deposit destination read from the store, repeat the read-only
flush-position check with a target sampled after that read, on the same uninterrupted
PostgreSQL session." `BarrierAck` abstracts the successful position observation in this check;
it does not issue a write. It can also describe the flush observation behind an acknowledged
WAL-writing transaction. H-d uses that historical write-barrier shape only as a counterexample.
The new-connection check alone precedes later reads and supplies no `ReadBeforeTarget` for them.

Premises, not PostgreSQL proofs:
* `ReadObserved`: the read is attributed to the actual commit at its index in the read history.
  This is the platform visibility/commit-identity interpretation of reading a stored destination.
* `ReadBeforeTarget`: the sampled flush endpoint follows that commit. The platform's visibility
  and local-flush ordering, with the sample after the read, supply this; sampling chronology alone
  is not a proof of it. Source: the quoted deposit-read clause and `ADR-0045`'s flush-position
  argument. An endpoint counts abstract records, not WAL bytes.
* `SameHistory`: the histories agree record for record through the earlier commit, independently
  of positions and labels. The uninterrupted-session clause above and `STO-54`'s duties —
  "Before a standby is promoted or a replacement authoritative history is served, the deployment
  MUST stop every engine and API process using the old primary and prevent the old primary from
  serving component work again." — are its deployment basis, not facts established here. Histories may extend differently
  after this prefix; equality of complete histories is unnecessary.
* `DurablePrefix`: a report is in bounds and the actual durable records equal that history's
  prefix at the reported endpoint. It assumes observer/report correctness and continuous durable
  WAL prefixes. `STO-7`: "has flushed the primary's WAL up to the flush position the primary reports
  on that connection". Reports describe retained, not discarded, WAL.
* `SynchronousCommit`: a received acknowledgement has an actual commit record and the
  designated replica's report is beyond it. `STO-7`: "PostgreSQL acknowledges these commits only
  once the designated standby has flushed them to durable storage." It is the trusted
  deployment/platform duty, supplied separately from durable-prefix facts, never a field
  assuming replicated membership.

The model proves list membership from these premises. It does not prove PostgreSQL implementation
or SQL behavior, observer/report correctness, actual topology/configuration, process stopping or
fencing in a deployment, or every externally visible action's safety. It models neither incident
procedures nor permission to promote. `RecoveryEntry` separately carries incident entry. It does not compose with `Restore.History`, which is live engine steps.
No new runtime mechanism, trusted assumption, or implementation conformance follows from a green
gate. No rendered region is added; see `ADR-0025` for authority.
-/

namespace Provisiond.WalHistory

/-- An opaque identity token, not a position, LSN, timeline label, or transaction value. -/
structure CommitId where
  token : Nat
  deriving DecidableEq, Repr

/-- Ordered commit records. Other WAL records and byte offsets are abstracted away. -/
abbrev History := List CommitId

/-- The actual durable records and the observer's separately supplied endpoint. -/
structure Replica where
  durable : History
  reportedEnd : Nat
  deriving DecidableEq, Repr

@[req "STO-7"]
abbrev CommitAt (history : History) (index : Nat) (commit : CommitId) : Prop :=
  history[index]? = some commit

/-- Report correctness plus continuous-prefix durability; contains no selected commit. -/
@[req "STO-7"]
abbrev DurablePrefix (history : History) (replica : Replica) : Prop :=
  replica.reportedEnd ≤ history.length ∧ replica.durable = history.take replica.reportedEnd

structure Read where
  history : History
  index : Nat
  commit : CommitId
  deriving DecidableEq, Repr

structure Barrier where
  history : History
  /-- Endpoint sampled by a read-only check, or the end of a WAL-writing transaction. -/
  flushEnd : Nat
  deriving DecidableEq, Repr

@[req "STO-7"]
abbrev ReadObserved (read : Read) : Prop := CommitAt read.history read.index read.commit

@[req "STO-7"]
abbrev ReadBeforeTarget (read : Read) (barrier : Barrier) : Prop :=
  read.index < barrier.flushEnd

/-- Actual prefix agreement, not equality of timeline labels or numerical endpoints. -/
@[req "STO-7"]
abbrev SameHistory (read : Read) (barrier : Barrier) : Prop :=
  read.history.take (read.index + 1) = barrier.history.take (read.index + 1)

/-- Observed success only: durable report interpretation is a separate premise. -/
@[req "STO-7"]
abbrev BarrierAck (barrier : Barrier) (replica : Replica) : Prop :=
  barrier.flushEnd ≤ replica.reportedEnd

@[req "STO-7"]
abbrev Replicated (commit : CommitId) (replica : Replica) : Prop :=
  commit ∈ replica.durable

private theorem commit_in_durable_prefix {history : History} {replica : Replica}
    {index : Nat} {commit : CommitId}
    (hRecord : CommitAt history index commit) (hEnd : index < replica.reportedEnd)
    (hPrefix : DurablePrefix history replica) : Replicated commit replica := by
  apply List.mem_of_getElem? (i := index)
  rw [hPrefix.2, List.getElem?_take_of_lt hEnd]
  exact hRecord

/-- BarrierAck ∧ SameHistory ⇒ Replicated, with visibility, ordering and report semantics explicit.
H-d (`hd_admitted_without_history`) refutes the statement without `hHistory`; a target preceding
the read (`stale_target_admitted`) refutes it without `hOrder`. -/
@[req "STO-7"]
theorem barrier_same_history_replicated {read : Read} {barrier : Barrier} {replica : Replica}
    (hRead : ReadObserved read) (hOrder : ReadBeforeTarget read barrier)
    (hAck : BarrierAck barrier replica) (hHistory : SameHistory read barrier)
    (hDurable : DurablePrefix barrier.history replica) : Replicated read.commit replica := by
  have hRecord : CommitAt barrier.history read.index read.commit := by
    unfold CommitAt
    rw [← List.getElem?_take_of_succ, ← hHistory, List.getElem?_take_of_succ]
    exact hRead
  exact commit_in_durable_prefix hRecord (Nat.lt_of_lt_of_le hOrder hAck) hDurable

/-- Receipt is modeled independently of replication. A replication-warning reply is not receipt. -/
structure Ack where
  commit : CommitId
  index : Nat
  received : Bool
  deriving DecidableEq, Repr

@[req "STO-7"]
abbrev Acknowledged (ack : Ack) : Prop := ack.received = true

/-- External synchronous-commit semantics for the designated replica.
This is an index bound, not membership in the replica's durable records. -/
@[req "STO-7"]
abbrev SynchronousCommit (history : History) (replica : Replica) (ack : Ack) : Prop :=
  CommitAt history ack.index ack.commit ∧ ack.index < replica.reportedEnd

/-- Acknowledged-commit membership follows from the independent synchronous premise and a
truthful continuous durable prefix. `local_ack_admitted_without_sync` refutes this without
`hSync`; no promotion policy is inferred. -/
@[req "STO-7"]
theorem acknowledged_in_designated_prefix {history : History} {replica : Replica} {ack : Ack}
    (hAck : Acknowledged ack)
    (hSync : Acknowledged ack → SynchronousCommit history replica ack)
    (hPrefix : DurablePrefix history replica) : Replicated ack.commit replica := by
  obtain ⟨hRecord, hEnd⟩ := hSync hAck
  exact commit_in_durable_prefix hRecord hEnd hPrefix

-- Concrete event snapshots. Tokens name commits independently of their list indices.
private def root : CommitId := ⟨10⟩
private def deposit : CommitId := ⟨20⟩
private def other : CommitId := ⟨30⟩
private def barrierWrite : CommitId := ⟨40⟩

/-- H-d: read deposit on the old branch; promote a branch lacking it; a later write barrier
on that branch is acknowledged and durably present. The numerical ordering still passes.
This trace demonstrates what would happen without the history premise, not a permitted
deployment. -/
private def hdRead : Read := ⟨[root, deposit], 1, deposit⟩
private def hdBarrier : Barrier := ⟨[root, other, barrierWrite], 3⟩
private def hdReplica : Replica := ⟨[root, other, barrierWrite], 3⟩

@[req "STO-7"]
theorem hd_admitted_without_history :
    ReadObserved hdRead ∧ ReadBeforeTarget hdRead hdBarrier ∧
    BarrierAck hdBarrier hdReplica ∧ DurablePrefix hdBarrier.history hdReplica ∧
    CommitAt hdBarrier.history 2 barrierWrite ∧ Replicated barrierWrite hdReplica ∧
    ¬ SameHistory hdRead hdBarrier ∧ ¬ Replicated hdRead.commit hdReplica := by
  decide

@[req "STO-7"]
theorem hd_refused_with_history (hHistory : SameHistory hdRead hdBarrier) : False := by
  have h := hd_admitted_without_history
  exact h.2.2.2.2.2.2.2 (barrier_same_history_replicated h.1 h.2.1 h.2.2.1
    hHistory h.2.2.2.1)

/-- Protected counterpart: read deposit, sample after it on the same history, observe a standby
flushed through that endpoint. The replication conjunct is derived using the positive theorem. -/
private def protectedBarrier : Barrier := ⟨[root, deposit, barrierWrite], 3⟩
private def protectedReplica : Replica := ⟨[root, deposit, barrierWrite], 3⟩

@[req "STO-7"]
theorem barrier_positive :
    ReadObserved hdRead ∧ ReadBeforeTarget hdRead protectedBarrier ∧
    BarrierAck protectedBarrier protectedReplica ∧ SameHistory hdRead protectedBarrier ∧
    DurablePrefix protectedBarrier.history protectedReplica ∧
    Replicated hdRead.commit protectedReplica := by
  have hRead : ReadObserved hdRead := by decide
  have hOrder : ReadBeforeTarget hdRead protectedBarrier := by decide
  have hAck : BarrierAck protectedBarrier protectedReplica := by decide
  have hHistory : SameHistory hdRead protectedBarrier := by decide
  have hPrefix : DurablePrefix protectedBarrier.history protectedReplica := by decide
  exact ⟨hRead, hOrder, hAck, hHistory, hPrefix,
    barrier_same_history_replicated hRead hOrder hAck hHistory hPrefix⟩

/-- An earlier new-connection check is not a barrier for a later read, even on one history. -/
private def staleBarrier : Barrier := ⟨hdRead.history, 1⟩
private def staleReplica : Replica := ⟨[root], 1⟩

@[req "STO-7"]
theorem stale_target_admitted :
    ReadObserved hdRead ∧ SameHistory hdRead staleBarrier ∧
    BarrierAck staleBarrier staleReplica ∧ DurablePrefix staleBarrier.history staleReplica ∧
    ¬ ReadBeforeTarget hdRead staleBarrier ∧ ¬ Replicated hdRead.commit staleReplica := by
  decide

@[req "STO-7"]
theorem stale_target_refused (hOrder : ReadBeforeTarget hdRead staleBarrier) : False := by
  exact stale_target_admitted.2.2.2.2.1 hOrder

/-- A same-history observation cannot protect the read until a standby reaches its endpoint. -/
@[req "STO-7"]
theorem unflushed_barrier_admitted :
    ReadObserved hdRead ∧ ReadBeforeTarget hdRead protectedBarrier ∧
    SameHistory hdRead protectedBarrier ∧ DurablePrefix protectedBarrier.history staleReplica ∧
    ¬ BarrierAck protectedBarrier staleReplica ∧ ¬ Replicated hdRead.commit staleReplica := by
  decide

@[req "STO-7"]
theorem unflushed_barrier_refused (hAck : BarrierAck protectedBarrier staleReplica) : False := by
  exact unflushed_barrier_admitted.2.2.2.2.1 hAck

/-- A false report can satisfy all the position comparisons while durable data is missing. -/
private def falseReplica : Replica := ⟨[root], 3⟩

@[req "STO-7"]
theorem false_report_admitted :
    ReadObserved hdRead ∧ ReadBeforeTarget hdRead protectedBarrier ∧
    SameHistory hdRead protectedBarrier ∧ BarrierAck protectedBarrier falseReplica ∧
    ¬ DurablePrefix protectedBarrier.history falseReplica ∧
    ¬ Replicated hdRead.commit falseReplica := by
  decide

@[req "STO-7"]
theorem false_report_refused (hPrefix : DurablePrefix protectedBarrier.history falseReplica) :
    False := by
  exact false_report_admitted.2.2.2.2.1 hPrefix

private def ackHistory : History := [root, deposit]
private def depositAck : Ack := ⟨deposit, 1, true⟩

/-- Trusted-configuration limit: a local acknowledgement after replication is disabled. The
earlier connection check cannot supply synchronous-commit semantics for this later commit. -/
private def localReplica : Replica := staleReplica

@[req "STO-7"]
theorem local_ack_admitted_without_sync :
    Acknowledged depositAck ∧ DurablePrefix ackHistory localReplica ∧
    ¬ SynchronousCommit ackHistory localReplica depositAck ∧
    ¬ Replicated depositAck.commit localReplica := by
  decide

@[req "STO-7"]
theorem local_ack_refused_with_sync
    (hSync : Acknowledged depositAck → SynchronousCommit ackHistory localReplica depositAck) :
    False := by
  exact local_ack_admitted_without_sync.2.2.2
    (acknowledged_in_designated_prefix rfl hSync local_ack_admitted_without_sync.2.1)

end Provisiond.WalHistory
