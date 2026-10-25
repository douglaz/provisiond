**Brief errors** are at the end, as asked; three are significant: the restore write is timed against the wrong step, `lock_timeout` does not bound the advance as claimed, and `Claim.lean` :23 is not the guard model. Every quoted "before" span, every next-free id, the PostgreSQL 13.3.2 quotes and the quotes from `ADR-0019`, `ADR-0044`, `STO-7`, `OPS-43` and `STO-54` checked out at `d78085a`. No gate or `lake` was run, and no file was edited.

## Q1 — CANNOT ACCEPT (two spans, each a one-clause fix)

**D1. `OPS-50`'s first sentence contradicts `OPS-15`'s new paragraph.**
- `OPS-50` says "Every write transaction made in the engine process … MUST read `STO-59`'s row `FOR SHARE` as its first statement, compare it for equality with the value the engine's own startup pass wrote".
- `OPS-15` (new) says "The pass's first transaction MUST begin by replacing `STO-59`'s startup generation."
- That first transaction is itself an engine write transaction, and there is no "own value" yet. An engine that follows `OPS-50` literally reads the old value, finds a mismatch, rolls back and exits. That happens on every start, with no takeover: a write it should admit is refused. Any engine breaks one of the two MUSTs.
- Replace "Every write transaction made in the engine process" with:
  > Every write transaction the engine process makes after its startup pass's generation write has committed (`OPS-15`)

**D2. The paragraph allows the sweep inside the advance's transaction, and under REPEATABLE READ that sweep misses the commit it waited for.**
- PostgreSQL 18, 13.2.2: a repeatable read transaction "sees a snapshot as of the start of the first non-transaction-control statement in the transaction". It also says a row that was "locked" but not "actually updated" does not abort the waiter.
- Trace: the old engine E1's claim T holds `FOR SHARE` and claims row X. E2's advance takes its snapshot, then waits on T. T commits. The advance proceeds with no error. The sweep, in the same transaction, uses the old snapshot: X reads `queued` and is not swept. E1's later writes are refused and E1 exits.
- Result: X stays `running` with no worker, and holds its machine under `STO-51`'s index until the next restart.
- This breaks `OPS-15` ("MUST move every `running` operation") and `OPS-5` ("stays claimed until it settles, defers under `OPS-8`, or the startup pass finds it"). An engine that conforms to G's text fails `CNF-368`'s "the successor's sweep sees that commit".
- The set expects RR/SERIALIZABLE transactions: `OPS-49` repeats serialization failures, and `ADR-0015` keeps SERIALIZABLE available. A SERIALIZABLE pass beside READ COMMITTED workers misses X the same way, because SSI tracks only serializable transactions.
- Replace the paragraph's first sentence with:
  > The pass's first transaction MUST replace `STO-59`'s startup generation and do nothing else, and MUST commit before the pass reads any operation.

**Non-blocking defects, with replacements**
- **D3. The timeout bound.**
  - PostgreSQL 19.11.1 says `lock_timeout` "applies separately to each lock acquisition attempt". New `FOR SHARE` lockers do not queue behind the waiting UPDATE, so share holders that keep turning over can hold the advance past the bound.
  - The same page says "if `statement_timeout` is nonzero, it is rather pointless to set `lock_timeout` to the same or larger value". `STO-7` registers a `statement_timeout`.
  - The register's row is named "Startup-lock wait bound", not "retry bound".
  - Replace "It MUST run with `lock_timeout` set to `OPS-47`'s startup-lock retry bound (`OVR-19`)" with:
    > Its replacing statement MUST run with `statement_timeout` and `lock_timeout` both set to `OVR-19`'s Startup-lock wait bound.
- **D4. The restore write's timing (`STO-59`).** "as it bumps every tenant's credential generation" points at step (3), which `STO-54` places "Before the first `api` request", after the engine has started. Replace with:
  > in the transaction that commits `STO-56`'s restore record, which `STO-54` commits "before either component is started"
- **D5. `OPS-50`'s component list misses writers.** The list names "every component `OVR-17` assigns to the engine". But `OVR-17` assigns the meter, re-derivation and the solvency check to `ledger`, while saying they "run in the one engine process". The meter posts debits. The MUST's opening still covers them; `CNF-367` does not drive them. Replace with:
  > every component `OVR-17` assigns to the engine or says runs "in the one engine process"

**Is the value ever reused?** No, once D4 places the restore write.
- A timed-out advance rolls back, so nothing is written.
- An advance whose reply is lost exits "having claimed nothing", and the next pass writes a new value.
- A PITR restore, and any promotion `STO-54` classes "is a restore", go through the restore procedure, so they get the fresh write.
- A restart promotion keeps every acknowledged commit. An advance that was never acknowledged belonged to an engine that has already exited.

**Lock order:** the safety argument holds. The only open issue is liveness (D3).

**Write paths that escape `OPS-50`:** none beyond D1 and D5. The `api` process is out by design.

**The id list**
- **Missing: two quotations that go stale.** The citation gate's QUOTED rule would go red on both.
  - 03:415-416 (`OPS-15`'s create exception) quotes `STO-3` saying "nothing contends with it", which span 11 deletes. Replace with:
    > This describes their predicates; an earlier engine's step-8 write cannot commit once the pass has replaced the generation (`OPS-50`).
  - 10:1518-1521 (`CNF-290`'s note) quotes `OPS-47`'s "nothing here refuses the second, and both will work the queue", which span 1 deletes. Replace the last sentence with:
    > What this drill does not exercise is the generation fence; `CNF-367`–`CNF-370` drive it (`OPS-50`).
- **Missing: `Claim.lean`'s docstring (:21-23).** It says "What the model omits: … a second engine", which is false once the superseded transition below is added.
- **Recommended: `OPS-47`'s italic note (03:149-152).** It needs a pointer: `OPS-50`'s value has a second writer.
- **Behaviour, not a pointer: `STO-54`.** Adding a write to "The procedure, in this order" changes the procedure. `STO-54` owns the procedure, so the MUST belongs there, and `STO-59` should point to it.
- **`OVR-17`:** its pointer must cover D5's rows.
- **`ADR-0022`:92:** its "stays true" can take a dated note. ADRs are not QUOTED input to the gate.

**The CNF items**
- **`CNF-367`** cannot drive "each" writer in one run, because the first refusal exits the engine. It also omits the claim and the `ledger` writers. Replacement:
  > For each engine write — the claim, step 8, a marker, a settle, a cut-off record, a defer, and each writer `OPS-50` lists — in a separate run, write a fresh value to `STO-59`'s row out of band (no second engine) just before that write's transaction: assert it commits nothing, the engine logs "superseded" and exits non-zero, and no transaction repeats or begins after the refusal.
- **`CNF-368` and `CNF-369`** cannot reach the advance as written. While the old engine holds `STO-51`'s lock, `OPS-47` says the successor must "retry for the stated bound … and then exit". A conforming engine therefore fails "its advance waits". Replacements:
  > `CNF-368`: With no engine holding `STO-51`'s lock, open a store session that reads `STO-59`'s row `FOR SHARE` and claims a `queued` operation, its transaction left open. Start an engine: assert its generation write waits; commit the session; assert the engine's sweep moves the claimed row to its `OPS-15` startup state.

  > `CNF-369`: As `CNF-368`, but hold the session past the Startup-lock wait bound: assert the engine logs loudly and exits non-zero having claimed nothing, `STO-59`'s value is unchanged, and the session's commit then succeeds.
- **`CNF-370`** does not say which engine survives. If the survivor is the one that made "a startup advance", its value already differs from the backup's, and the test passes with no restore write at all. Replacement:
  > Run engine A; back up the store; restore that backup while A runs, so the restored row holds A's value, and drive one write from A before it detects its lost lock connection: assert the restore wrote a fresh value before any component was served, A's write is refused and A exits; start an engine and assert every value written is distinct.

**The Lean names**
- **`Claim.lean`:** putting the generation into `Guards`/`workerGuard` makes a mismatch return `zeroRows`. That contradicts span 7 ("is not a zero-row write"). It would also restate `workerGuard_moved_iff` and its neighbours, which weakens more than `ADR-0047` admits.
  - Model the check instead on `engineStep`: a mismatch moves to `.exited` with the row unchanged (theorem `superseded_never_commits`).
- **`StopRecord.lean`:** the list is right, and every named declaration exists. `later_stop_exits` gains only a proof case; its statement is unchanged.

## Q2 — CANNOT ACCEPT on one span; the rest ACCEPT

**The open point: yes, the same defect.**
- Trace: the lock connection's backend is terminated at t0, and the engine sees it at t1 > t0. Between t0 and t1 a conforming engine claims, because it cannot know. That breaks R's own "MUST claim nothing more".
- G does not change this. The usual loss has no takeover, since the supervisor never runs two, so claims in that window commit. G only fires after a successor's advance.
- Replace R's clause with:
  > where the connection carrying it is lost, the engine MUST, from the moment it detects the loss, log loudly that the lock connection was lost, claim nothing more and begin no periodic pass, treat the loss as a stop of every worker not already recording one, record each under `OPS-21` within its Stop-record bound and exits, and then exit non-zero.

**The `CNF-366` fix:** right, but only with the replacement above. "as its loud log timestamps the detection" relies on a log that R's text never requires. The only loud logs in the set are at bound expiry (`OPS-21`) and store-retry exhaustion (`OPS-49`).

**Contradictions with G:** none left.
- R's "and then exit non-zero" against `OPS-50`'s "exit non-zero at once" is settled by R's added sentence: "A record that `OPS-50`'s generation check refuses ends there, unlanded".
- R's `OPS-49` addition ("keeps repeating it") and G's span 8 ("is never repeated") cover different causes.

## Brief errors
1. "`Claim.lean` (guard model, :23)": line 23 is the docstring's "a second engine. `OPS-47`'s single engine is assumed throughout". `Guards` is at :73 and `workerGuard` at :96.
2. The restore argument's "as it bumps every tenant's credential generation" is out of order: the bump is in `STO-54` step (3), "Before the first `api` request", after the components start.
3. The "explicit, alarmed startup exit on the advance's timeout" at the startup-lock bound does not hold. `statement_timeout` fires first, and `lock_timeout` bounds each wait separately (D3).
4. "startup-lock retry bound": the register's row (00-overview.md:399) is "Startup-lock wait bound".
5. Span 1 starts at 03:137, not 138. This is minor.
