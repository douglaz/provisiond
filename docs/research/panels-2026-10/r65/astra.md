Reviewed the r65 forms against `b90783d`, without gates or Lean builds.

**R (merged): CANNOT ACCEPT as written. E (completed): ACCEPT. Pick: R, with the narrow test repair below.** R preserves outcomes already established by the worker without claiming that the startup lock fences writes.

**R blocker — `10-conformance-checklist.md`, proposed `CNF-366`:** its landing assertions omit the independent Store-retry exit. Trace: an earlier stop starts recording at t=0; Stop-record bound=60; Store-retry bound=5; lock loss at t=1; the store refuses transactions until t=6. This satisfies “accepts writes again within the Stop-record bound,” yet requires exit at t=5. `03-operation-lifecycle.md`, `OPS-21` says “whichever ends first ends the record”; existing `CNF-362` asserts exit “when the first bound ends.” Proposed `CNF-366` instead demands that the record land before exit.

**The merge: wrong only in that test fixture; the absorbed-read and parent repairs are right.**

Replacement for `CNF-366`’s “Where a write repeats…” sentence:

> For cases (i)–(iii) and (vi), arrange that the record can land before either the Stop-record bound or the Store-retry bound expires, with no later stop. Where a write repeats, the store refuses its transactions until lock-loss detection and then accepts writes with sufficient time remaining under both bounds.

**Against my pick:** R prolongs the interval in which a misconfigured successor overlaps the old engine. Existing periodic work and dispatched provider requests can continue. E ends that overlap sooner after detection and has a simpler shutdown policy.

**Fence G: sound YES, as a database fence.** After the generation advances, it rejects stale claims even before E1 detects lock loss; earlier claims and provider requests remain possible. Cost: locking every engine write, takeover contention and discarded stale outcomes. PostgreSQL confirms: “A shared lock blocks other transactions from performing `UPDATE`.” [PostgreSQL 18](https://www.postgresql.org/docs/18/explicit-locking.html#LOCKING-ROWS) It implements the principle of `ADR-0019`’s rejected “guard the claim itself on `engine_epoch = mine`”; it is not the defective self-stamped predicate.

**Fence A: sound YES, as a reacquisition checkpoint only.** Cost: another connection/lock decision and possible rejection by E1’s unreaped session; it does not fence pre-detection claims or provider calls.

**Brief errors:**

- The introduction repeats “a kill or a failover records nothing under both,” contradicting correction 5. `CNF-362`: “Accept either outcome: the transaction committed … or it did not.”
- S1’s E outcome requires an additional refused-write premise. `OPS-49` permits “the row is already written, the money already posted once” after a lost reply. Repeating a settle write does not establish that it remains `running`.
- S1/S2’s guaranteed automatic recovery is too strong. `OPS-27` explicitly includes “the listing window has expired” among findings that “Escalate to an operator.” A verified correlator alone does not guarantee successful later resolution.
- S5’s “each holds its machine” is overbroad. `OPS-8`’s index includes `yielded_at IS NULL`; an interrupted yielded install does not hold that index slot. The stranded-row hazard remains for unfinished, unyielded machine operations.
- Fence A’s “only records it refuses” claim is false: a cut-off ambiguous mutation and E2’s sweep can both produce `needs_reconciliation` (`OPS-11`: “if the failure is *ambiguous*”; `OPS-15`: “move every `running` operation to `needs_reconciliation`”).

S3 permits automatic resolution where evidence exists—`OPS-45`: “where the driver can produce it”—but guarantees neither automation nor an operator. S4’s stated trace is supported.