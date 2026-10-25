I reviewed `d78085a` and the supplied Appendix. **F1–F9: ACCEPT.** My Q1 draft closes the two described routes into a restored server, but does not promise detection of a logical overwrite that preserves existing PostgreSQL sessions.

**Q1. Draft: an engine-held store-session witness**

**1. Exact spec text**

Use a separate PostgreSQL session holding a randomly named advisory-lock signature. The engine checks that signature on the server executing each transaction. Unlike `STO-59`, this witness is not restored database data.

PostgreSQL documents session advisory locks as “held until explicitly released or the session ends” and “stored in a shared memory pool.” Its `pg_locks` view exposes their keys, database, holder PID and granted state. These are the properties this proposal uses. [Advisory locks](https://www.postgresql.org/docs/18/explicit-locking.html#ADVISORY-LOCKS), [pg_locks](https://www.postgresql.org/docs/18/view-pg-locks.html)

The following changes apply **after F1–F9 and W-1/W-2**.

**New `OPS-51`, after `OPS-50`:**

> **OPS-51 — Every engine write checks a store-session witness.** After taking the startup lock and before its first write transaction, the engine MUST establish a separate, dedicated PostgreSQL session outside its pool. This is the **store-session witness**. It MUST NOT be the connection carrying the startup lock.
>
> The engine MUST generate a fresh random 128-bit signature in process memory. Encode its four 32-bit words as four exclusive, session-scoped advisory locks, using four distinct implementation-reserved first keys and the signature words as their respective second keys. Those first-key namespaces MUST be disjoint from every other advisory-lock namespace the implementation uses. Acquire all four locks without waiting; any acquisition failure closes the witness session and exits startup non-zero.
>
> The engine MUST retain the signature, witness backend PID and database OID in memory. Before proceeding, it MUST verify the signature from the connection holding the startup lock. A failed verification or setup error exits startup non-zero without advancing the generation.
>
> A **witness check** reads `pg_catalog.pg_locks` on the PostgreSQL backend executing the checked transaction. It passes only where the current database OID equals the retained database OID and all four expected advisory locks are present for that database and retained PID, with `granted = true`, exclusive mode and the two-integer key representation. A cached result or a result obtained on another connection does not satisfy the check.
>
> Every engine write transaction, including the generation-advance transaction, MUST pass this check before making any persistent change. Every engine read transaction licensing a provider dispatch MUST also pass it. The check and the transaction it licenses MUST execute on the same uninterrupted PostgreSQL backend.
>
> An absent signature MUST cause rollback before any business write or dispatch is licensed. The engine MUST log a **store-session-loss exit**, exit non-zero, and begin no further transaction. Detection that the witness connection was lost has the same exit, including when no worker is active. The process MUST NOT reconnect the witness or acquire its signature again. An ordinary pooled connection may be replaced; its transactions still make the check.
>
> A missing signature is not a store error and is never retried. An error obtaining the check’s result licenses no work and follows the applicable startup-error or bounded store-error path; it MUST NOT be treated as a successful check.
>
> This exit ends any pending stop record without another attempt. A transaction already sent retains its server-decided fate, including a commit whose reply was lost.
>
> **Scope:** this check detects loss of, or departure from, the server session established at startup. It covers database restoration requiring that session to end, and access to a restored or promoted server that lacks it. It does not detect a logical overwrite of the same database while that session and its advisory locks survive. It does not check writes made in `api`.

**Appendix `OPS-50`, replace:**

> “MUST read `STO-59`’s row `FOR SHARE` as its first statement”

with:

> “MUST check `OPS-51`’s witness and read `STO-59`’s row `FOR SHARE` in its first statement”

The existing generation comparison and share-lock lifetime remain applicable.

**Appendix `OPS-15`, replace its new first sentence, as amended by W-1:**

> “The engine’s first write transaction after taking `STO-51`’s lock MUST contain only the replacement of `STO-59`’s startup generation (`OPS-50`’s exception).”

with:

> “The engine’s first write transaction after taking `STO-51`’s lock MUST contain only `OPS-51`’s witness check followed by the replacement of `STO-59`’s startup generation (`OPS-50`’s exception).”

**Appendix `STO-59`:**

Replace the heading’s “no value is written to it twice” with “generation choices are fresh”.

Replace:

> “A value MUST NOT be written to the row twice, including across a restore from backup:”

with:

> “Startup advances and restore-record transactions MUST choose fresh UUIDs, without reusing a UUID chosen by an earlier such transaction. Reinstating the stored bytes of a backup is not such a choice:”

Replace:

> “Without that write, an engine that survived the restore still holds the restored value and would match.”

with:

> “For the interval before the restore-record transaction commits, see `OPS-51`.”

In the Appendix’s **Startup generation** glossary entry, replace “never written twice” with “freshness is defined by `STO-59`”. This resolves trace **(c)** without changing generation equality into ordering.

**`OPS-21` and its `CNF-362` quotation, after F1:**

Replace:

> “bounded abandonment, later-stop and superseded (`OPS-50`) exits below”

with:

> “bounded abandonment, later-stop, superseded (`OPS-50`) and store-session-loss (`OPS-51`) exits below”

Replace:

> “the superseded exit (`OPS-50`), the lost-reply case”

with:

> “the superseded exit (`OPS-50`), the store-session-loss exit (`OPS-51`), the lost-reply case”

Make the latter replacement inside `CNF-362`’s quotation too.

**Connection accounting and alarms:**

In `STO-55`, replace:

> “`OPS-47`’s lock connection is outside both.”

with:

> “`OPS-47`’s lock connection and `OPS-51`’s witness connection are outside both.”

In its connection-budget paragraph, add the witness connection beside the lock connection in both the deployment total and the engine’s startup refusal calculation.

Replace `OVR-19`’s row:

> `| Startup-lock connection keepalives | OPS-47 | durations | yes |`

with:

> `| Startup-lock and store-session-witness connection keepalives | OPS-47, OPS-51 | durations | yes |`

In Appendix span 20, replace “Two exits are alarmed on the same model” with “The following exits are alarmed on the same model”, and append the store-session-loss exit to its list.

**`CNF-370`, delta to F3:**

Replace its proxy/setup sentences with:

> Perform this case as a logical data-only restore into the same running PostgreSQL database, preserving the startup-lock and store-session-witness sessions. Through a proxy controlled by the harness, block every engine pooled-connection transaction from the backup until the restore-record transaction is acknowledged. Keep the worker in `execute` until then, and make both recording bounds longer than the blocked interval. Start no other engine. Then admit the pooled connections and release the worker.

Keep F3’s assertions. This deliberately preserves the witness so the drill still reaches **G’s post-record refusal**, rather than passing through an earlier witness-loss exit.

**New `CNF-371`:**

> **CNF-371 — A survivor cannot write through a missing store-session witness.** Start an engine, hold a worker in `execute`, and back up after its generation advance. Restore while withholding the restore-record transaction and preserving the backup’s generation value. Drive the engine against the restored database before that record exists.
>
> Run separately with an in-place physical restore, a restore on another server while the original startup-lock and witness sessions remain alive on the old server, and a promotion classified as a restore. Assert that no survivor write commits into the restored or promoted database, no checked read there licenses a provider dispatch, and the engine logs and exits non-zero upon witness-loss detection or its first failed witness check. Exercise each checked engine path.
>
> Repeat the in-place case with no worker active: require the exit and absence of writes, not a “next write”.
>
> Controls: replacing an ordinary pooled connection against the original witnessed database permits a valid write; losing only the startup-lock connection retains `CNF-366`’s outcomes; losing the witness alone produces the store-session-loss exit. An unreadable witness check licenses no work. Include the witness connection in the startup connection-budget refusal case. (`OPS-51`, `STO-55`, `OVR-19`)

In Appendix 2’s `CNF-366`, after the unchanged-generation fixture sentence, add:

> Keep the store-session witness alive and its signature present throughout these cases.

**New `ADR-0048`, decision text:**

> The engine checks a live PostgreSQL session witness independently of the persisted startup generation. This closes the survivor window for session-destroying restores and movement to another server without waiting for a restore-record write. The witness is separate from the startup-lock connection so ordinary loss of that lock retains Form R’s recording behaviour.
>
> The additional connection, advisory locks, per-transaction lock-manager inspection and store-session-loss exit are accepted costs of this proposal. Logical overwrite preserving the witness, unchecked `api` writes, fresh-process startup before the incident record, and concurrent writable histories remain outside this check.
>
> The formal stop-record conclusion gains a store-session-loss disjunct in addition to Fence G’s superseded disjunct.

**2. What it costs**

No persistent column, row, counter or external service. It adds one engine connection, the lock signature defined in `OPS-51`, and a `pg_locks` inspection per checked transaction. Combining that inspection with the generation read avoids an additional round trip on ordinary checked transactions.

The inspection is not free: PostgreSQL notes that frequent `pg_locks` queries can affect performance through lock-manager synchronization. This needs measurement against the intended transaction rate. [pg_locks implementation notes](https://www.postgresql.org/docs/18/view-pg-locks.html)

It leaves `STO-59`’s “not a counter” choice intact. Against `ADR-0019`’s rejected cost—“a column, a counter and a guard term”—this adds a different guard and a live connection rather than restoring the counter.

The draft’s amendment list changes roughly twenty requirement/conformance spans, plus glossary and ADR text.

Lean changes, **named only**:

- Add an independent `storeSessionCheck : Bool` parameter beside F4’s generation parameter.
- Add `missing_store_session_never_commits` and `missing_store_session_commits_without_check`.
- State the external hypothesis precisely: the restored server lacks the original witness signature. Do not prove that by assuming the desired refusal.
- Add `storeSessionLost` to `StopRecord.Event`, propagate it through the schedule and selection cases, and add `store_session_loss_exits`.
- Preserve `exit_store`’s lost-reply alternative; explicitly add the new disjunct to `finished_unrecorded_exit`.

**3. Misconfiguration behaviour**

For physical archive recovery, PostgreSQL’s procedure begins “Stop the server, if it’s running.” The old witness session therefore cannot survive that recovery. A restored server elsewhere likewise does not acquire the original server’s memory-resident locks. This is an inference from the documented recovery and lock lifetimes, not a persistent restore marker. [Archive recovery](https://www.postgresql.org/docs/18/continuous-archiving.html#BACKUP-PITR-RECOVERY)

Consequently:

- Omitting or delaying the fresh-generation/incident write does not admit a surviving engine to either described restored server.
- Clock errors and backup age do not affect the comparison.
- An ordinary PostgreSQL restart also destroys the witness and forces an engine restart: intentional additional unavailability.
- A wrong endpoint fails unless it is the original witnessed database.
- A logical overwrite preserving the witness **can evade this check**. This is a material limit, not a fail-closed case.

**4. What it still does not cover**

**Two servers:** the restored side refuses the survivor, but its transactions on the old witnessed server can still pass. The overall shape remains **outside F7’s one-writable-history guarantee**. This proposal does not fence the old primary.

**Promotion:** access to the promoted server fails the witness check, including promotion classified as a restore. Keep `STO-54`’s rule: “the deployment MUST stop every engine and `api` process that was connected to the old primary”. The witness neither checks `api` nor retracts previously licensed provider calls.

**Surviving `api`:** uncovered, consistently with Appendix `OPS-50`: “Writes made in the api process are not checked.” New processes also have no surviving memory to distinguish an unmarked restored database.

**Trace (b):** the no-worker physical case exits without a next write; `CNF-371` explicitly tests that outcome.

**Logical restore:** PostgreSQL supports “Restore only the data, not the schema (data definitions) or statistics.” Such restoration need not destroy the witness session. A remembered counter also cannot establish a universal rewind guarantee when the restored value equals the last value the engine observed; unobserved `api` history may have disappeared. [pg_restore](https://www.postgresql.org/docs/18/app-pgrestore.html)

Thus this draft meets the two supplied server-replacement traces, **not an unrestricted guarantee over every restore method**.

**5. Complexity: medium**

The protocol is local and avoids ordered persisted state, but adds a failure-sensitive connection, a transaction-entry check, and another explicit recording exit.

**6. Is the deployment barrier still needed?**

**Yes, for the complete recovery procedure. Choose Reader Z’s text:**

> “Until that transaction has been acknowledged, the deployment MUST prevent either component, including a process that survived the restore, from using the restored store.”

The draft supplies independent protection for surviving engines in its covered methods when that barrier is misconfigured. The barrier remains necessary for surviving `api`, fresh starts, and logical overwrite preserving the witness. The promotion stop rule remains necessary as well.

**Q2. F1–F9**

These verdicts concern the Appendix **before the additional Q1 amendments above**.

| Item | Verdict | Reason |
|---|---|---|
| **F1** | **ACCEPT** | Both `OPS-21` exit lists and `CNF-362`’s quotation gain the same superseded exit. This matches the Appendix’s “A refused generation check ends recording without another attempt”. |
| **F2** | **ACCEPT** | “subject to its exits” correctly preserves bounded abandonment, later stops and generation refusal while requiring R’s recording. |
| **F3** | **ACCEPT** | The held worker supplies a recordable path; the fixture places its write after the fresh generation commits. Its distinctness assertion concerns generation choices, not restoration of backup bytes. |
| **F4** | **ACCEPT** | The switchable parameter supplies the refused/admitted pair required by `ADR-0025`: “the bad trace is refused with the guard and admitted without it”. |
| **F5** | **ACCEPT** | The verified option ends with “a guard term alive to do it.” Both scope and cost appear in the rejection. |
| **F6** | **ACCEPT** | The dedicated-drill pointer no longer denies what amended `CNF-290` can exercise through “`OPS-50` once the generation has moved”. |
| **F7** | **ACCEPT** | It states the actual boundary without treating the promotion-specific old-primary prohibition as a universal restore barrier. |
| **F8** | **ACCEPT** | Its retained quotation, “a deployment obligation”, survives span 1. The old longer quotation does not. |
| **F9** | **ACCEPT** | A dated correction is appropriate for the historical ADR quotation. It does not remove the requirement to expose assumptions in theorem signatures. |

**Contradictions: none found among F1–F9.** F3 does not repair `STO-59`’s separate “written twice” wording; Q1’s explicit replacement does. That outstanding wording is not a contradiction introduced by F3.

**Q3. Dropped transition clause**

**None found beyond D1–D4.** I searched the root specifications, relevant ADRs and formal models for `STO-13`, rollback, previous-release binaries, unchecked engines, and the proposed G identifiers, and inspected the Appendix’s Q3 references.

Existing `STO-13` says “Rollback is the previous binary against the current schema”; its separate `about_to_order_at` migration restriction and associated conformance case concern that column’s introduction. They do not depend on G’s dropped transition clause.

**D4: change**, retaining the owner’s decision without turning repository scope into evidence about binaries elsewhere:

> “No transition from a pre-`OPS-50` engine is specified. The owner stated on 2026-10-24, ‘The project isn’t built yet’; `OPS-50` is part of the initial implementation contract.”

**Brief errors**

- **The “two shapes” classification is incomplete unless restricted to server/session-replacing restoration.** `STO-54` broadly says “A store restored from backup”; it does not restrict restoration to physical recovery. PostgreSQL’s documented data-only logical restore supplies the additional same-server, surviving-session case described above.
- **“Specifications only” does not itself establish that no earlier build exists elsewhere.** `AGENTS.md` says “Nothing that implements the specified system belongs here”, a repository-content rule. The owner’s statement supplies the relevant authority. The README additionally describes the historical reference implementation as “unbuilt, untested”; this supports, rather than contradicts, the owner’s answer.
- **The Appendix’s historical F5 error is confirmed:** `rg` finds “Correct, and cheap” at `ADR-0019:80`, followed by the rejection continuing through “a guard term alive to do it” at line 81. F5 repairs it.

The cited requirement quotations checked out. The clone contains no r66b panel record, so the vote totals and reader attributions remain supplied provenance rather than independently corroborated facts.

No gates or `lake` ran; no tracked files changed.