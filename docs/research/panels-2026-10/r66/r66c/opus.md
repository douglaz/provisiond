The answer is written to `panel-d-r66c.md` in the clone, untracked and not committed. I ran no gate and no `lake`, and no Lean change was built. Its full text follows.

---

# Panel D, r66c — pv-buc

## Q1. Draft: compare the server's start instant beside the generation

**A decision for the owner first.** Under this draft, when the lock connection is lost because the PostgreSQL server was stopped and started, R's stop records are refused. pv-buc's own example (a create whose settle write repeats) then ends in `needs_reconciliation`, not `succeeded`. That partly reverses the outcome r66b accepted. It stays deterministic: every conforming engine refuses, so pv-buc's split between engines does not come back. A lock loss with the server still up (`CNF-366`) is unchanged.

**Why not the three example directions.**
- **Monotonic value.** Only the engine moves it, so it never changes between the survivor's last write and the backup. F3's own fixture breaks it: a worker held in `execute`, a backup, and no engine write in between. The survivor's remembered value then equals the restored one, and "less than" passes.
- **Restore epoch written by the procedure.** That is span 19 already, and the window is the time before it commits.
- **Re-reading a marker.** Before `STO-56`'s record commits there is no marker to read.

The comparand has to be one that PostgreSQL changes and no backup carries. That is `pg_postmaster_start_time()`. On postgresql.org (18, System Information Functions) it "Returns the time when the server started." A physical restore ("Recovering Using a Continuous Archive Backup") starts with "Stop the server, if it's running." and resumes with "Start the server." A standby's postmaster is not the primary's.

### 1. Spec text

**`STO-59`** (replaces the Appendix's paragraph):
> **STO-59** **ADDED 2026-10-24 (`ADR-0047`) — the startup generation is one row, compared with the server's start instant.** The store MUST hold exactly one row carrying the **startup generation**. `OPS-15`'s startup pass replaces it with a fresh random UUID (`gen_random_uuid()`) in a transaction of its own, and the replacing statement returns it with `pg_postmaster_start_time()`; that pair is what `OPS-50` compares. It is not a counter and is never compared for order: every check is equality. The row has two writers, `OPS-15`'s advance and the transaction that commits `STO-56`'s record (`STO-54`), and each writes a fresh `gen_random_uuid()`; a restore that brings back the value its backup held does not write it. The start instant has no writer in this specification: PostgreSQL says `pg_postmaster_start_time()` "Returns the time when the server started", and a physical restore begins "Stop the server, if it's running" and resumes with "Start the server", so an engine that survived it holds an instant the restored server does not report, whatever the restored row holds. This row is the fence `STO-51`'s lock is not.

This replaces "A value MUST NOT be written to the row twice, including across a restore from backup" (trace (c)). It also drops "Without that write … would match": the write no longer carries physical restores.

**`OPS-50`** (Appendix text, F7 applied):
- **(a)** Before: "MUST read `STO-59`'s row `FOR SHARE` as its first statement, compare it for equality with the value the engine's own startup pass wrote, and hold that lock until it commits." After: "MUST read `STO-59`'s row `FOR SHARE` as its first statement, compare it and `pg_postmaster_start_time()` for equality with the pair its own startup pass's advance returned (`STO-59`), and hold that lock until it commits."
- **(b)** Before: "the engine MUST log loudly that it was superseded and exit non-zero at once". After: "the engine MUST log loudly which of the two differed and exit non-zero at once". After "and is never repeated." add: "A server that was stopped and started cannot be told from a restored one, so after any such start a surviving engine's writes, `OPS-47`'s stop records included, are refused and `OPS-15` classifies their rows."
- **(c) S2, separable.** Before: "Writes made in the api process are not checked." After: "Every write transaction made in the `api` process MUST compare `pg_postmaster_start_time()` for equality with the instant the process read with `STO-56`'s open row, and where they differ MUST roll back, log loudly and exit non-zero; it reads no generation and takes no lock on `STO-59`'s row. Its reads are not checked."
- **(d)** After F7's sentence add: "Nor does it see, before `STO-56`'s record commits, a restore that starts no server, such as a logical reload into a running one (`STO-54`)."

**`OPS-15`** (the Appendix's new paragraph). Before: "Its replacing statement MUST run with `statement_timeout` and `lock_timeout`". After: "Its replacing statement MUST return the new generation with `pg_postmaster_start_time()` (`STO-59`) and MUST run with `statement_timeout` and `lock_timeout`".

**`STO-54`, span 19.** Before: "so an engine that survived the restore holds a value the restored store does not." After: "so that once the record has committed, a survivor is refused even after a restore that starts no server (`OPS-50`). For a restore that does not start the server it restores into, until that transaction has been acknowledged the deployment MUST prevent either component, including a process that survived the restore, from using the restored store." The second sentence is Reader Z's text, scoped (item 6).

**`STO-56`** (S2 only). After "Both components read the open row before anything else they do" add "; `api` reads `pg_postmaster_start_time()` with it (`OPS-50`)".

**`CONTEXT.md`, Startup generation:** "the `STO-59` value each startup pass replaces, compared together with the server's start instant; equality only; each write is fresh".

**`ADR-0047`** adds a paragraph:
- The start instant closes the restore window for every restore that starts a server.
- To `ADR-0019`'s "keeps a column, a counter and a guard term alive to do it": S adds no column and no counter, and no term beyond G's own.
- To `CONTEXT.md`'s "Never reintroduce a guard whose compared value has a single writer that is also the thing being guarded": the instant's writer is the server.
- How S differs from r63's timeline read, rejected 4-0 because "the timeline read lags a fast promotion" (`r63b/tally.md`:25): the start instant is fixed for a postmaster's life and never lags. The same tally's "an unverified signal backing a MUST on both components" and "the timeline observation is unspecified" are answered by the documented quote and by naming the statement that reads it.
- The restart cost and the gaps (items 3–4).

**`CNF-370`** (replaces F3's text):
> **CNF-370** — **A survivor's write into a restored store commits nothing.** Start an engine and hold one of its workers in `execute`; take a base backup. (i) Stop the server, restore the backup in place and start it, and admit the engine's connections before the restore commits `STO-56`'s record. (ii) As (i), but through a proxy the harness controls refuse the engine's store connections until the record has committed. (iii) Restore onto a second server, keep the engine's lock connection open to the first, and move the proxy carrying its other connections to the second, closing them. (iv) As (ii), with a logical dump reloaded into the running server in place of the physical restore. In each case make the Stop-record and Store-retry bounds longer than the interval, start no other engine, then release the worker. Assert that no transaction of the surviving engine commits into the restored store, that it logs which value differed and exits non-zero, that in (ii) and (iv) the record's transaction wrote a fresh generation before either component started (`STO-54`), and that every value written by an advance or by a restore record's transaction is distinct. With S2: (v) an `api` process started before the backup receives a write request after (i)'s restore: it commits nothing and exits non-zero.

Holding a worker in `execute` guarantees a write in every case, which answers trace (b). In (i) and (iii) only the start instant can refuse that write. (ii) is F3's case, and (iv) tests span 19's value after a restore that starts no server.

### 2. Cost
- **Rows and columns:** none.
- **Per transaction:** one more value in the statement G already sends first. It is read server-side, with no extra round trip and no lock. S2 adds one unlocked read per `api` write transaction, which can be folded into its first statement.
- **Behaviour:**
  - After any full server stop and start, R's stop records are refused and `OPS-15` classifies their rows. F1's superseded exit is what makes that an exit.
  - `CNF-366` is unaffected: it terminates a backend, which does not restart the postmaster.
  - With S2, `api` exits at its first write after a server start. That changes the case `STO-7` describes ("Every connection after a restart of the primary is new, whether the restart was in place or after a crash, so it is checked"), where `api` used to carry on.
- **Existing drills:** `CNF-365` crashes the primary and restarts it in place, which is a server start. It asserts only that "no component uses a connection before a standby has flushed". The flush check runs before S's read, so that assertion stays reachable. Its "crash one backend" case is a reinit, which S leaves unchanged.
- **CNF:** `CNF-370` is replaced; no new id.
- **Lean:** F4's `generationCheck` covers the pair. If `superseded_never_commits` is stated over any stored value other than the engine's, a restore needs nothing new. Otherwise it needs one witness pair, `restored_never_commits` / `restored_commits_without_check`.
- **Spans:** about eight (`STO-59`, `OPS-50` ×4 edits, `OPS-15`, span 19, `STO-56`, `CNF-370`, `CONTEXT.md`, `ADR-0047`).

### 3. Misconfiguration
- **Components started before the record.** A survivor is refused. A process *started* in the window finds no record and comes up as a restart, which `STO-56`'s existing "before either component is started" forbids. A supervisor restarting a refused survivor is such a start. S is never worse than the Appendix: in place, R already exits the survivor into its supervisor.
- **The record's transaction leaves out the fresh value.** A survivor of a physical restore is still refused; a survivor of a logical reload is not.
- **The clock is wrong.** The check is equality only, so skew or a backward step changes nothing. Only an exact microsecond repeat of the old server's start instant would match, for example a clock pinned to a constant. Then only span 19's value refuses, and only after the record commits.
- **The backup is older than the survivor's pass:** the generation differs too, so the write is refused on both counts. **Newer:** the start instant refuses it. **From another cluster:** the start instant differs.
- **Storage reverted under a running postmaster (no stop):** not refused before the record. That a crash-reinit leaves the start time unchanged comes from r63f's reading of the PostgreSQL source (`s3-analysis.md` H4), not from postgresql.org. If that reading is wrong, the only effect is a false positive (records refused after a backend crash), never a stale write.

### 4. Still not covered
- **A logical reload into the running server, before the record.** The server does not restart and the lock session survives (Brief errors). The barrier is scoped to this case.
- **A storage revert or a VM memory snapshot** under a running postmaster.
- **The other-server shape.** Writes that reach the restored server are refused, so the restored history is inside F7's "one writable database history". Writes on connections still on the old server commit there, into a second history outside that line, and the provider calls they license go out. `STO-54`'s "the old primary MUST NOT serve a component again" covers promotion only; a restore onto another server has no matching rule.
- **Promotion.** Covered in both classes, because the promoted server's postmaster is not the old primary's. S does not depend on the stop rule (05:1507-1508). Keep the rule anyway: it is what covers `api` reads, the old primary's own commits and calls already licensed. For the engine, the rule becomes enforced rather than trusted.
- **`api`.** With S2, its reads are still unchecked, token authentication included: a surviving `api` before step (3) still honours a token revoked in Δ on a read, though any write that read leads to is refused. Without S2, none of its writes are checked.
- **Provider calls already licensed** (`OPS-50`'s list).

### 5. Complexity: small
One server-supplied value is added to the comparison G already makes: no row, column, lock or ordering. Most of the change is prose and one `CNF`.

### 6. Barrier
- **Physical restores and promotions:** no barrier is needed for the refusal. `STO-56`'s existing start-order rule stays, and it already governs a refused survivor's restart.
- **A restore that starts no server:** still needs one. Use **Reader Z's** text, scoped as in span 19 above, since it alone names both components and "a process that survived the restore". Without S2, extend it to `api` for every restore.

## Q2
All nine are ACCEPT; none meets the gate.
- **F1 ACCEPT.** There is no other verbatim copy of 03:1741-1742 or 03:1807: `grep "later-stop exit"` finds only 1742, 1807 and 10:1682. `StopRecord.lean`:231-232 quotes only 1741's first clause, which F1 leaves alone. Non-blocking: 03:1877, "A later stop and exhaustion both leave restart recovery to `OPS-15`", names two exits, but it is not a closed list.
- **F2 ACCEPT.**
- **F3 ACCEPT** as span 19's fixture. Non-blocking: it cites `STO-56` for the fresh value, but span 19 puts that MUST in `STO-54`.
- **F4 ACCEPT.** It meets 0025:118-119 and leaves `Guards` alone, as the Appendix's Lean bullet (Reader 2) wanted.
- **F5 ACCEPT.** 0019:80-81 reads "Correct, and cheap. Rejected because it buys a defence for the case" / "this ADR puts out of scope, and keeps a column, a counter and a guard term alive to do it."
- **F6 ACCEPT.** The Before text contradicts span 12: CNF-290's restart drill does move the generation.
- **F7 ACCEPT.** `grep -c "MUST NOT serve"` gives 1, at 05:1508, inside the promotion bullet.
- **F8 ACCEPT.**
- **F9 ACCEPT.** No `.lean` file contains "deployment obligation", so no hypothesis docstring goes stale.

**Contradictions:** none found between F1–F9, the Appendix and `d78085a`.

## Q3
**Dependents:** none beyond D1–D4. What I searched:
- the Appendix for "STO-13" (span 22, `OPS-50`, the not-covered bullet, `ADR-0047`) and for "Q3" (span 22's "Q3 decides what follows this sentence", B8's [took], the same bullet, `ADR-0047`); all of these fall under D1–D4;
- F1–F9: only F7 touches `STO-13`, and that is D2;
- `d78085a`, with `grep -n "STO-13"`. `STO-13`'s "**Rollback is the previous binary against the current schema**" (05:1430) is not a dependent, because every future previous binary makes the check. `lean-01.md`:443 paraphrases `OPS-47` as "makes supervision a deployment obligation", which stays true after span 1.

**D4: keep.** An ADR records what was dropped, and `impl-report-01.md`'s scope line, "no implementation was produced", supports the owner's answer.

## Brief errors
1. **"In place. The restore replaces the database behind E's connections, so E's lock connection drops."** That holds only for a physical restore ("Stop the server"). pg_restore `--clean` will "issue commands to `DROP` all the objects that will be restored", and `STO-51`'s lock "carries no row" (05:91). So, inferring from those two quotes, a logical reload into the running server leaves E's lock session up. That is a third shape, in place with no loss, and it is the case my draft leaves open.
2. **Errors in the Appendix's quotations, not the brief's:**
   - "*Before the first claim*" (05:1542): the repository has "*Before the first claim:*", so `grep -F` with the asterisks fails.
   - "Row-level locks are released at transaction end" cuts off "… or during savepoint rollback, just like table-level locks." This is harmless, because the generation read comes before any savepoint.
   - "rejected only on scope" is wrong; F5 fixes it.

Every other `d78085a` quotation, line hint and id in the brief checks out. 02:142 is in `PRV-9` and 00:316 is in `OVR-17`. The highest ids in use are `STO-58`, `OPS-49` and `CNF-365`, and the last ADR is 0046. The "zero disables the timeout" quote is right on postgresql.org for both `statement_timeout` and `lock_timeout`.
