Reviewed against `b90783d`. No gates or `lake` run.

**Q1. R: ACCEPT. E: ACCEPT. Pick without G: R.** S4 is decisive without misconfiguration: R preserves the pre-marker install’s known failure. S3 also preserves an accepted dated cancellation instead of requiring an operator.

**Fixes 1–9: all right. E’s placement: wrong editorially**, without changing its verdict. Move its addition after the paragraph ending “`OPS-15` classifies the row as interrupted”, as R does. Both fixtures should explicitly say “after detection” where they prohibit further transactions, claims or passes; neither form closes the blind interval.

**S5, worker reading:** R records/defers post-pass rows if the bounds and other exits permit; another worker’s zero-row settlement does not stop those workers. E leaves unfinished rows `running` until E2 restarts.

**S5, engine reading:** R retains records landed before its first zero-row settled-state exit; the remainder can strand as under E. E exits at detection. Sent transactions retain either possible server outcome.

**Against my pick:** R prolongs overlap with a successor: existing periodic passes can continue, and operation guards do not protect every machine write. E ends that overlap at detection. Neither addresses provider calls made before detection.

**Q2. ADOPT G. Sound: YES as a database fence.** The comparison and share lock must remain in the same transaction as the protected writes, through commit. PostgreSQL says: “A shared lock blocks other transactions from performing `UPDATE`”. [Row locks](https://www.postgresql.org/docs/18/explicit-locking.html#LOCKING-ROWS).

- **(a)** An earlier guarded write does not prevent post-advance dispatch: step 8 acknowledges; E2 advances; E1 dispatches step 9. Also, `OPS-32`’s image/key cleanup acts from reads, outside the claimed-worker marker argument.
- **(b)** There is no guaranteed time to successful takeover. Configured `lock_timeout`/`statement_timeout` bound attempts; idle timeouts and keepalives help reap partitioned holders. A `SyncRep` holder can persist indefinitely: “transaction locks continue to be held until the transfer is confirmed”. [Synchronous replication](https://www.postgresql.org/docs/18/warm-standby.html#SYNCHRONOUS-REPLICATION). `OPS-49` does not explicitly cover startup.
- **(c)** Stale-write exclusion needs one authoritative shared database and a generation that is not reused. It does not depend on supervisor correctness or detection timing. Availability still depends on settings; database promotion/history assumptions remain.
- **(d)** **Yes.** It adopts the substance of `ADR-0019`’s rejected, correct option: “guard the claim itself on `engine_epoch = mine`”. That differs from the broken self-stamped guard the ADR deleted.
- **(e)** **No change:** R still preserves S1–S4 when no takeover occurs.
- **(f)** `OPS-15` and `OPS-5` definitely belong. Add `OPS-6`, `OPS-49`, `STO-6`, `CONTEXT.md`, `CNF-290`, the changed `CNF-362` quotation, new conformance cases, schema and formal owners. Specify startup failure/retry behavior; review `STO-7`/`STO-55`/`OVR-19` for the wait contract. The advisory lock itself remains “not a fence”; amend `OPS-47`’s broader “nothing here refuses the second”.

**Q3.** The strongest argument against rejecting A is that reacquisition restores a current ownership checkpoint and refuses recording while E2 holds the lock. My answer: that checkpoint cannot fence another connection loss or provider dispatch. The row/claim guards already choose the winning record; A additionally rejects valid records when E1’s own unreaped session refuses it.

**DON’T ADOPT A; sound: YES as the proposed checkpoint**, with refusal explicitly added as an exit to R. Assess soundness against that amended contract and adoption cost against plain R; comparison with E establishes neither. A prevents writes the existing guards would admit—correct records, without an additional incorrect write excluded. **Under G: moot.**

Q3’s opening rule is missing: it starts “exits at once”. My verdict assumes successful reacquisition retains the new session lock through recording.

**Brief errors**

- **“On a `correlator: none` channel nothing separates the forms” is false.** Lose the lock after acknowledged step 8, before step 9. R records `failed`; E’s restart takes the set-column reconciliation path. `PRV-33`: “A create failure recorded before step 9 is not an ambiguous create here”; `OPS-15`: “a set column takes that ordinary path”.
- **The blanket provider-call outcome is false.** `OPS-11`’s refresh row says “Always `failed`”. The absorbed-read cases also preserve success rather than entering reconciliation.
- **S1 and S5 overstate R’s recording guarantee.** `OPS-21`: “whichever ends first ends the record”. Store-retry bound 5, Stop-record bound 60 and store recovery at t=6 still permit exit at t=5. The worker reading removes one exit, not exhaustion or later stops.
- **G sketch 5 omits startup exceptions.** `OPS-15`: refresh “MUST be settled `failed`”; null-column creates “MUST be settled `failed`, on a restart only”; the parent “MUST be returned to `queued`”.
- **A succeeding “only after an in-place restart” is false.** Terminating or reaping E1’s old session suffices without restarting PostgreSQL: `STO-51` says “released when its session ends”.
- **“No infrastructure setting has to be right” is too absolute.** `STO-54` still requires “the old primary MUST NOT serve a component again”. G does not fence two writable database histories.