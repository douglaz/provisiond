# r66d tally (panel D, pv-buc, Fence G's restore guard). 2026-10-24 ~18:35Z

Master `d78085a`. All four units exited 0, and all four answers are in. Rules: `notes.md`, set before launch.

## Outcome: (c) owner question. The vote is a 2-1-1 split.

| Reader (seat) | Vote | Gate verdict on the voted text |
|---|---|---|
| fable (Option 2's drafter) | **Option 1** as written, S2 included | ACCEPT |
| opus (Option 1) | **Option 1** as written, S2 included | CANNOT ACCEPT: two gated defects, both verified true (below) |
| astra (Option 3) | **Option 3** exactly as supplied | ACCEPT |
| sol (Option 4) | **Option 4** exactly as supplied | ACCEPT |

No text has three votes, so rule 1 (4-0, or 3-1 with the dissent's load-bearing fact false) cannot hold. Rule 2 is
not triggered, because nobody wrote a hybrid. Rule 3 applies: a split goes to the owner as an owner question,
with no further round. No verified error below moves any vote onto a single text, so none of them voids the tally.

## Per reader

**fable (seat: Option 2).**
- *Objection:* conceded the idle-survivor gap.
  - fable bounds it: `LDG-37` (12:523) "the meter writes at least one transaction per billable subject per
    interval", and `OPS-32` (03:1550-1551), both verified.
  - The bound cannot close it: "A restore whose Δ is shorter than one metering interval" (a PITR to minutes before an
    error) survives. So do shape 2, where the survivor sees no lock loss, and `api` in every shape.
- *Vote:* Option 1, S2 included. fable's reasons:
  - Every restore `STO-54` specifies starts a server. Verified: 05:1495-1496 "continuous WAL archiving" + promotion.
  - Only Option 1 checks `api` (S2).
  - It adds no state.
  - It accepts the restart cost.
- *ACCEPT,* with three non-blocking notes:
  - S2's `api` instant has no referent when no `STO-56` row is open. Verified: 05:1339 "at most one row may have
    `closed_at` null".
  - `CNF-370` (i)/(ii): the lock loss itself stops the held worker.
  - `ADR-0047` should quote the R sentence it narrows.

**opus (seat: Option 1).**
- *Objection:* conceded the core.
  - The objection is narrower than quoted:
    - `CNF-366`'s fixture ("Terminate the lock connection's backend") keeps the postmaster, so R's drill still passes.
    - A crash-restart keeps the instant (verified below).
    - On a full stop and start Option 1 does what master does now. Master's `OPS-47` says "where the connection
      carrying it is lost it MUST exit" (03:145-146, verified).
    - That path fails toward `OPS-27`, never toward a stale write.
  - Every option needs a deployment rule for shape 3.
- *Vote:* Option 1, S2 included.
- *CANNOT ACCEPT* until two one-clause fixes are applied; with them, ACCEPT.
  - **Defect A, gated:** a `CNF-367` assertion becomes false for a conforming engine.
    - Option 1 (b) changes "log loudly that it was superseded" to "log loudly which of the two differed".
    - `CNF-367` still asserts "the engine logs "superseded" and exits non-zero" (brief 658-660).
    - **Verified true.**
    - Replacement for (b)'s first After: "the engine MUST log loudly that it was superseded, naming which of the two
      differed, and exit non-zero at once".
  - **Defect B, gated:** a `CNF-366` assertion can become unreachable.
    - `CNF-366` says "the store refuses its transactions until lock-loss detection" but not how the harness makes the
      store refuse (brief 738-739). A server stop and start is a permitted way to do it.
    - Under Option 1 (b) that refuses (ii)'s settle write, so "the create `succeeded`" cannot be reached.
    - **Verified true:** nothing in `CNF-366` or the Base forbids it.
    - Replacement: "Keep the startup generation and the server's start instant (`OPS-50`) unchanged throughout these
      cases; no successor or out-of-band writer advances the generation, and no case stops and starts the server."
  - Non-blocking: `ADR-0047`'s restart-cost item should name both components and `OVR-18`'s alarm. In `CNF-370` (iv),
    "refuse the engine's store connections" should also cut the connections already open.

**astra (seat: Option 3).**
- *Objection:* conceded.
  - A full restart destroys the witness. The exit "ends any pending stop record without another attempt", so the
    create ends `needs_reconciliation`.
  - astra also concedes the connection, `pg_locks` and failure-path costs. The performance cost is unmeasured.
- *Vote:* Option 3 exactly, with Reader Z's sentence appended.
  - Its reason: the witness is a live session, which no restored data can reproduce.
  - Against Option 1, part of the reason is the timestamp-uniqueness point (Brief error 7).
- *ACCEPT.* astra explicitly accepts the declared weakening of `finished_unrecorded_exit`. There are no defects.

**sol (seat: Option 4).**
- *Objection:* conceded.
  - Trace: an `api` extension the engine never observed, then a logical reload with sessions kept. E fences the
    machine. `OPS-41` reads no record yet.
  - sol withdraws the unqualified "no app check is sound".
- *Vote:* Option 4 exactly. Its reasons:
  - It keeps R's result after a plain server restart. That is true: Option 4 adds no check.
  - It keeps one complete access obligation.
  - Option 1's coverage claim needs a qualification (Brief error 7).
- *ACCEPT.* The misconfigured trace violates the new deployment MUST, so it is not a conforming counterexample.
  `RestoreTrace.store` models no pre-record window (Restore.lean:159-161, verified).

## The flagged point, checked against PostgreSQL 18 behaviour (source)

**Does Option 3's extra connection drop on a crash-restart? YES.**
- Source: `github.com/postgres/postgres`, branch `REL_18_STABLE`.
- `src/backend/postmaster/postmaster.c`:2700-2719 `HandleFatalError` → `TerminateChildren(SIGQUIT)`, which signals
  "all other child processes to exit".
- `src/backend/tcop/postgres.c`:2989 logs "terminating connection because of crash of another server process" in
  each session.
- postmaster.c:3197-3222 logs "all server processes terminated; reinitializing" and re-creates shared memory inside the
  same postmaster.
- Every session ends, so the witness's session-scoped advisory locks go too ("held until explicitly released or the
  session ends").
- The brief's inference is true. On a crash-restart, Option 3's engine exits through "This exit ends any pending stop
  record without another attempt".

**Corollary, which resolves the brief's other open point:**
- `PgStartTime` is assigned only at postmaster.c:1371 (`PostmasterMain`) and postgres.c:4160 (single-user mode).
- The reinit path above does not touch it, and `pg_postmaster_start_time()` returns it (`utils/adt/timestamp.c`:1627).
- This matches r63f `s3-analysis.md`:53-57 at `d78085a`.
- So **Option 1 keeps R's stop records on a crash-restart** and refuses them only after a full stop and start.

## Verified brief errors (none voids the tally)

1. **"after any PostgreSQL restart"** (the Against quote, r66c's words) is too broad. It should be a full stop and
   start, not a crash-restart (above). The quote itself is accurate (opus).
2. **"Option 1 keeps it on a crash-restart reinit only if…; postgresql.org is silent".** postgresql.org is silent, but
   the source settles it: it keeps R (above; opus).
3. **Option 3's witness lost on any reinit "not checked further":** now checked, and true (above; opus).
4. **"ends `needs_reconciliation`" overstates it.**
   - `OPS-15` classifies the row there and `OPS-27` resolves it (fable).
   - Where the settle's last repeat committed and its reply was lost, the create is already `succeeded` (03:1845-1847,
     verified; astra).
   - The main case, a settle that committed nothing, is unchanged, and sol's reason stands.
5. **Option 2's ADR line "no model carries a restore, so no theorem" is false.** Restore.lean:3-6, :154
   `structure RestoreTrace`, :541 `bootRestore`, and Witnesses.lean:1191 `restore_breaks_soundness` disprove it
   (fable, astra, sol; verified). No vote rests on it.
6. **Option 3's `OVR-19` Before row** (brief 276) drops the backticks that 00-overview.md:400 has around `OPS-47`.
   Wording only (fable, opus).
7. **Option 1's "an instant the restored server does not report" goes beyond what the docs promise.**
   - The docs say only "Returns the time when the server started" (astra, sol).
   - Verified: the value is a `gettimeofday` reading at postmaster start, in microseconds (timestamp.c:1645-1656).
   - A collision needs two starts that read the identical microsecond.
   - It is true as a qualification. It is not a premise error, and it removes no shape from Option 1's coverage in
     practice.
   - Rule 6: astra's and sol's votes cite it as one reason against Option 1, and fable's and opus's votes assume
     distinctness.
8. **The r63 timeline rationale.** Option 1's `ADR-0047` line says the read was "rejected 4-0 because "the timeline read
   lags a fast promotion"". r63b/tally.md:25-26 gives that as fable's reason only. The 4-0 omit is accurate, and the
   next sentence cites the other reasons (astra). Wording only.
9. Already recorded: 05:1542 "*Before the first claim:*" (sol, confirmed).

**If the owner picks Option 1**, rule 5's logic applies: a gated CANNOT ACCEPT verified true means the defects and
opus's replacements go to main, not straight to the Run.
- The replacements are one reader's text, which the others have not read.
- Per the reviewed-forms rule, main decides whether a short reading round precedes the Run.
- Wording-only candidates, none of which changes behaviour:
  - fable's S2 referent fix: "the instant the process read at startup in the statement that reads `STO-56`'s open
    row, whether or not a row is open".
  - Error 7's caveat.
  - Error 8's attribution.

## Owner question (TL;DR)

**1. The story.**
- Engine E is running. An operator restores the database from a backup taken 10 minutes ago and forgets to stop E.
- In those 10 minutes a customer paid to extend machine M. The restored database has forgotten the payment.
- Until the restore writes its "restore in progress" record, E sees nothing wrong and cancels M.
- What, inside the app, stops E in that gap?
- The panel did not agree: 2-1-1.

**2–3. Options, most-voted first.**

- **Option 1, start instant: 2 votes** (one ACCEPT, one ACCEPT once two one-clause test-wording fixes are made).
  - *How it works:* each engine write also checks the database server's start time.
  - *Complexity:* small, about 8 spans, no new state, one value in the existing first statement. S2 also checks
    `api` writes.
  - *Cost to R:*
    - After a **full PostgreSQL stop and start**, R's pending stop records are refused.
    - `OPS-15` then classifies those rows and `OPS-27` sorts them out, never with a stale write.
    - So a full restart does what master does today.
    - R keeps its gain on crash-restarts, killed backends and network drops.
    - Every engine and `api` process exits at its first write after a full restart.
  - *Misconfigured:*
    - The survivor is refused for a physical restore and for a restored server behind the same address, `api`
      included.
    - It is not refused for a logical reload into the running server. A scoped deployment rule covers that case.
    - Refusal assumes the two starts don't read the identical microsecond on the clock.

- **Option 3, session witness: 1 vote** (ACCEPT).
  - *How it works:* a dedicated connection holds 4 locks, and every write checks they are still held.
  - *Complexity:* medium, about 20 spans: one more connection, 4 advisory locks, a `pg_locks` scan in every checked
    transaction, and a new exit. The cost of the scan is unmeasured.
  - *Cost to R:*
    - R's stop records are lost on **any** PostgreSQL restart, full or crash-restart (verified).
    - A drop of the witness connection alone also exits the engine.
  - *Misconfigured:*
    - The same as Option 1, plus logical reloads that end sessions.
    - It misses data-only reloads that keep sessions, and it does not check `api`.
    - The deployment rule is kept.

- **Option 4, deployment rule only: 1 vote** (ACCEPT).
  - *How it works:* no app check. The spec says the deployment MUST keep a surviving process off the restored store
    until the record lands.
  - *Complexity:* small, about 3 spans, nothing new.
  - *Cost to R:* none. R's records survive every restart.
  - *Misconfigured:* the survivor writes into the rewound store until the record lands, and forever if the record is
    skipped.

**4. No longer stands: Option 2, write chain (0 votes).**
- Its own drafter conceded and voted for Option 1.
- An engine that wrote nothing after the backup sails through. That is the common short point-in-time restore.
- It never checks `api`.
- Its ADR line "no model carries a restore" is false (Restore.lean).
