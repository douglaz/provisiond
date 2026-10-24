**Q1 — r64b at `b90783d`: R: CANNOT ACCEPT as written. E: ACCEPT. Pick: R, with the correction below.** Preserving verified outcomes through recoverable store interruptions justifies a bounded recording period.

**Blocker:** R’s added sentence treats every worker still in `execute` as a recorded cancellation. Trace: lose the lock during a verified create’s post-order read. Taking that sentence literally produces cut-off `conflict`/`needs_reconciliation`. But [03-operation-lifecycle.md](https://github.com/douglaz/provisiond/blob/b90783d2e6ef99ea0599c05e6d7ca0f5e28eb387/03-operation-lifecycle.md), `OPS-21`, says:

> A stop the engine survives after a create's settle-time confirming read succeeds, or after a delete's cancellation is accepted with an effective date, and before `execute` returns MUST NOT cancel `execute`.

`CNF-362` requires “no `needs_reconciliation` and no `cut_off`” for that trace. R must preserve this outcome.

Replacement spans only:

- In R’s `OPS-21` addition, replace “For a worker in `execute` it is the cancellation being recorded” with: “For a worker still in `execute`, the cancellation, absorbed-read and parent rules below apply”.
- In R’s `CNF-366` case (i), replace “while a worker is in `execute`” with: “while a non-parent worker is in `execute`, outside `OPS-21`’s absorbed-read cases”.

**Against my pick:** R prolongs overlap with a misconfigured E2. E2 can recover E1’s rows before E1 records them, and existing periodic passes can continue. The operation guard protects settlement; it does not establish exclusive engine ownership. E ends that extra activity on detection.

**The owner’s question:** Checking the lost lock before recording discards R’s intended records; a separate “still held?” read also races with takeover.

For database work, one proposed check is a shared generation row, checked under a transaction lock through every claim/write, with takeover advancing it exclusively. PostgreSQL says “A shared lock blocks other transactions from performing `UPDATE`”. [PostgreSQL 18](https://www.postgresql.org/docs/18/explicit-locking.html#LOCKING-ROWS)

That proposal amends `OPS-47`’s two-engine scope, adds ownership machinery under `STO-51`/`STO-3`, and needs stale-owner exits in `OPS-21`/`OPS-22`. It deliberately reopens `ADR-0019`. Costs include coordination on engine transactions and lost stale outcomes. It still cannot revoke provider calls already admitted; complete exclusion needs process fencing or provider-enforced fencing.

**Q2**

**M: ACCEPT with [P], without [Q].** The marker branch and transaction-read requirement implement the stated classification boundary.

**[P]: YES.** It makes the prose match `!f.accepted` and preserves `accepted_never_failed`; `OPS-11` says an accepted mutation “MUST NOT” classify `failed`.

**[Q]: NO.** “No recorded failure” omits [P]’s acceptance exception. Its unqualified universal exceeds M’s guarded rule.

**Read whole, does M contradict anything around it?** No further contradiction found on conforming traces with [P]. The supplied theorem’s false goal-state field is necessary, and the cut-off witness remains independent of the goal-state flip.

**Brief errors**

- **The successful `correlator: none` create story is unavailable.** `OPS-27` requires successful correlator verification before settlement and says “any non-authoritative search MUST leave the create in `needs_reconciliation`”. Its no-verified-correlator row says “Escalate to an operator”. Such a create already needs an operator under R; E does not newly impose that outcome.
- **R’s Q1b universal is false.** Besides the absorbed-read exception quoted above, `OPS-21` says of the parent’s defer: “It records no error.” Every worker in `execute` does not record a cut-off `conflict`.
- **Correction 5 overstates “ends unrecorded”.** `CNF-362` says “Accept either outcome” for an in-flight transaction, including that it committed. Failover need not erase the record, although this does not separate R and E.
- **E does not guarantee “only its successor connects”.** E acts when loss “is detected”. Before detection, E1 can reconnect and retry; the brief itself acknowledges that interval.
- **The overlap trace attributes the zero-row exit to E1 as a whole.** `OPS-22` assigns it to “the worker”, which must “leave the record alone, and exit”; it does not require immediate whole-engine exit.