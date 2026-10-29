**Your seat: Option 4. In r66c the reader in your seat argued that no app-side check is sound and kept the deployment rule (Option 4).**

# Panel brief r66d (panel D): one restore guard for Fence G, by consensus — pv-buc. 2026-10-24

You are one of four independent reviewers. Your working directory is a fresh throwaway clone of the specification
repository `provisiond-spec` at `d78085a` (master). Read `AGENTS.md` first. `br show pv-buc` prints the bead (if `br`
fails, `.beads/issues.jsonl` holds it). You MAY edit tracked files in this clone to test a claim. Write nothing
outside it (never `/tmp` or `/var/tmp`). Never commit, push or call a provider API. **Run no gate and no `lake`**.
Keep `TMPDIR` as set. Do not delegate, background or wait on anything. Have a draft answer by minute 25. A web
lookup is allowed only for postgresql.org documentation, quoted.

**Where this stands.** Fence G (a startup generation every engine write checks) and Form R (a lost lock connection
is a stop the engine records) are r66b's merged text: **Appendix 1 and 2** at the end, verbatim; your clone does not
contain it. Round r66c accepted 4-0 the carried fixes F1–F9, W-1, W-2 and the drop D1–D4 (the **Base** section,
applied on top of the Appendix, not re-voted). r66c also drafted four answers to G's restore window. The owner, asked
which to use, said verbatim: **"try to reach a consensus"**. Earlier the owner said "Draft 2) using the panel and
assess complexity", and prefers safety enforced in the application over deployment configuration: "what happens if
there is a misconfiguration?"

**Labels.** Reader W, X, Y, Z are r66b's readers. Inside the Appendix, "Reader 1"–"Reader 4" are an earlier round's
readers and "Q1"–"Q3" are r66b's questions. Spans are numbered as in the Appendix. **Check every claim this brief
makes before you rely on it**; report each error under "Brief errors". Line numbers are `d78085a` hints. Every
quotation of `d78085a` text in this brief was checked with `grep -F` line by line. Known, already recorded: the
Appendix's manager note quotes "*Before the first claim*"; 05:1542 has "*Before the first claim:*".

## The window, in three shapes

E is running. A backup is taken after E's startup pass, so it holds E's generation g. The store is restored from it
and E is never stopped. Until the restore's transaction commits `STO-56`'s record with a fresh value (span 19), E's
`FOR SHARE` read finds g and its equality check passes, so E can write into the rewound store: for example a
cancellation of a machine whose runway extension the restore erased. Three ways it happens:

1. **A physical restore**, which stops and starts PostgreSQL ("Stop the server, if it's running." ... "Start the
   server.", postgresql.org 18, continuous archiving). E's lock connection drops; R has E record stops, and those
   records are writes that can land before the restore record.
2. **A restore onto another server behind the same address.** E's lock connection may stay on the old server, so E
   sees no loss. Writes that stay on the old server are a second history, outside F7's "one writable database
   history"; writes that reach the restored server are inside it.
3. **A logical reload into the running server** (pg_restore "connects to that database and restores archive contents
   directly into the database"; `--data-only` restores "Table data, large objects, and sequence values"). `STO-51`'s
   lock is "a **session-scoped advisory lock** on a fixed key," / "released when its session ends" (05:89-90), so
   E's lock session stays up and E notices nothing.

## Verified facts (r66c tally, checked against `d78085a` and postgresql.org 18)

- **Options 1 and 3 refuse R's stop records after any full PostgreSQL stop and start.** `OPS-15` then classifies the
  rows, so pv-buc's own create-settle example ends `needs_reconciliation`, not `succeeded`: R loses its headline
  case whenever the lock loss came from a full restart. Option 1 keeps it on a crash-restart reinit only if the start
  time survives a reinit; postgresql.org is silent, an earlier round read it from the PostgreSQL source, and either
  reading adds only false positives, never a stale write. Option 3's witness is a session, so it is lost on any
  reinit too (manager's inference from "held until explicitly released or the session ends"; not checked further).
- **Option 2 misses an idle survivor**: one that had no engine write acknowledged after the backup runs on until the
  restore record commits a fresh generation, and forever if the record is skipped.
- **Option 3's extra connection, when it drops, exits without recording stops** ("This exit ends any pending stop
  record without another attempt.").
- **3 of 4 r66c readers keep the deployment rule alongside any check** (Reader Z's text; Option 1 scoped to restores
  that start no server). Only Option 2's drafter drops it.
- **`OPS-41` does not close the window.** It already has "A worker claiming **any**" / "exposure-reducing
  cancellation MUST read the restore record (`STO-56`) at each such claim" (03:950-951), but before the record
  commits there is nothing to read.
- All four keep the promotion stop rule "Before any component connects to the promoted store, the deployment MUST
  stop" / "every engine and `api` process that was connected to the old primary" (05:1507-1508). All four reword
  `STO-59`'s "written twice" in substance (restoring bytes is not a write; trace (c)).

## The four options (exact texts follow in full below)

| | 1. Start instant | 2. Write chain | 3. Session witness | 4. Deployment rule only |
|---|---|---|---|---|
| Mechanism | `pg_postmaster_start_time()` read with the generation, equality on the pair; S2 adds an `api` write check | table of (generation, seq); engine remembers its highest acked seq; each checked tx reads that row (missing = backwards, exit), each write inserts the next | a dedicated session holds 4 advisory locks = a random 128-bit signature; each checked tx reads `pg_locks` for them | Reader Z's sentence at the end of span 19; `STO-59` reworded |
| New state | none | 1 table, 1 row per engine write per lifetime | 1 connection, 4 locks, a new exit | none |
| Per transaction | 1 server value in the existing first statement | 1 index read + 1 insert (foldable) | a `pg_locks` scan in every checked tx | none |
| Spans, rating | ~8, small | ~9, medium | ~20, medium | ~3, small |
| Covers | shapes 1, 2 (restored side), promotion; `api` writes with S2 | any shape where the survivor had a write acknowledged after the backup | shapes 1, 2 (restored side), promotion, and logical reloads that end sessions or recreate the database | every shape, if the deployment obeys |
| Misses | shape 3, storage reverts under a live server | idle survivors; `api` | data-only reloads that keep sessions; `api` | nothing in the app |
| Deployment rule | kept, scoped to shape 3 | none | kept (Reader Z's) | it is the guard |
| **Misconfigured** (store opened early, record skipped) | survivor refused in shapes 1, 2; not in 3 | refused only if it had a post-backup acked write; else writes, forever if skipped | as 1, plus reloads that end sessions | survivor writes into the rewound store until the record lands, forever if skipped |

### Strongest argument and objection, quoted

- **Option 1.** For: "One server-supplied value is added to the comparison G already makes: no row, column, lock or
  ordering." Against (r66c tally): "after **any** PostgreSQL restart, R's stop records are refused and `OPS-15`
  classifies the" / "rows, so pv-buc's create-settle example ends `needs_reconciliation`, partly undoing R as r66b
  accepted it 4-0." Also its own text: "Nor does it see, before `STO-56`'s record commits, a restore that starts no
  server, such as a logical reload into a running one (`STO-54`)."
- **Option 2.** For: "the only thing that is certain to differ between a hot backup and a surviving engine is what the
  engine wrote after it." Against, its own text: "An engine that acknowledged no write after the backup: its memory is
  the restored store's, and it runs until `STO-54`'s record commits a fresh generation." And Option 4's trace: "An API
  transaction extends a machine’s runway. Even if that transaction increments a store-wide counter, E has not observed
  the new counter."
- **Option 3.** For: "Omitting or delaying the fresh-generation/incident write does not admit a surviving engine to
  either described restored server." Against: its own "An ordinary PostgreSQL restart also destroys the witness and
  forces an engine restart: intentional additional unavailability.", the lost stop records above, and PostgreSQL on
  `pg_locks`: "could have some impact on database performance if this view is very frequently accessed".
- **Option 4.** For: "A remembered watermark can detect a rewind past something the engine observed. It cannot
  establish that no unobserved state was lost." Against (r66c tally, the owner's misconfiguration test):
  "Misconfigured: the survivor writes into the rewound store until the record lands, forever if it is skipped."

## What to answer

1. **Answer the strongest objection** to the option your seat drafted or backed in r66c (the line above the title
   names it). Rebut it with a trace or a quote, or concede it.
2. **Vote** for one option, 1–4, or for one hybrid whose exact text you write in full (before/after spans, in the
   form the options use). **A hybrid counts only if all four readers vote for the same text, word for word**, so
   prefer an existing option unless a hybrid is clearly better. "Option 1 without S2" or "Option 2 plus Reader Z's
   sentence" is a hybrid: write its text.
3. **ACCEPT or CANNOT ACCEPT** the exact text you voted for, read whole: the option on top of the Base and the
   Appendix. **The gate:** a CANNOT ACCEPT must name a loss that changes a checked verdict: a `CNF` assertion or Lean
   theorem the text flips, makes unreachable or vacuous (id or name), or a MUST/SHOULD (file, id) with a trace that
   breaks it; for G also a trace in which the text admits a stale write or refuses a write it should admit. Quote
   each defect and give replacement text for it only. One that names none of these is recorded and does not block.
   A 4-0 vote with four ACCEPTs on one exact text goes straight to the implementation Run.

## Answer

**About 1,200 words, not counting drafted text.** Sections: **1. Objection**, **2. Vote** (with the hybrid's full text
if any), **3. ACCEPT / CANNOT ACCEPT** (defects quoted, gate named, replacement), **Brief errors** (each wrong fact,
with the grep or quote).

## Option 1: start instant (the r66c text verbatim; S2 is included as written)

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

## Option 2: write chain (the r66c text verbatim; no deployment rule)

### 1. Spec text

- **`STO-60`** (05, new paragraph after `STO-59`'s, before `### Engine choice` at 05:99):
  "**STO-60** **ADDED 2026-10-24 (`ADR-0047`) — the write chain: an engine write proves the store still holds the last write the engine saw acknowledged.** The store MUST hold a table of **write-chain rows**, each the startup generation (`STO-59`) and a sequence number, unique together. `OPS-15`'s generation-advance transaction deletes every row after its replacing statement and inserts `(the new value, 0)`. The engine keeps in memory the highest number whose commit it has seen acknowledged; each write transaction `OPS-50` checks inserts the next number, and a repeat under `OPS-49` takes a fresh one. No writer but the advance updates or deletes a row. A restore from backup returns the table at the backup's rows, so an engine that acknowledged a write the backup lacks finds its row missing: that is what `OPS-50`'s chain read sees. The compared row has writers other than the engine that checks it, the next pass and the restore, which is what makes the check one (`CONTEXT.md`, "Epoch")."
- **`OPS-50`** (Appendix 1). After "and hold that lock until it commits." insert: "As its second statement it MUST read `STO-60`'s row for the highest sequence number whose commit this engine has seen acknowledged; a write transaction then inserts its own row, and a read transaction that licenses a dispatch inserts nothing. A missing row is a mismatch under this requirement, logged as the store having gone backwards, with the same roll back and exit. This read compares the store with the engine's memory, not with itself: a store restored from a backup taken after this engine's startup pass holds `STO-59`'s value, and only a write this engine made after that backup can show the rewind." In **What it does not cover**, after "`OPS-32` after its read." add: "An engine that acknowledged no write after the backup: its memory is the restored store's, and it runs until `STO-54`'s record commits a fresh generation."
- **`OPS-15`** (Appendix 1 paragraph). Before: "MUST contain only the replacement of `STO-59`'s startup generation." After: "MUST contain only the replacement of `STO-59`'s startup generation and then `STO-60`'s reset."
- **`STO-59`** (Appendix 1), trace (c). Before: "A value MUST NOT be written to the row twice, including across a restore from backup: `STO-54`'s procedure writes a fresh value in the transaction that commits `STO-56`'s record, which is written "before either component is started". Without that write, an engine that survived the restore still holds the restored value and would match." After: "No advance and no restore record's transaction (`STO-54`) MAY write a value the row has held before; the value a restore brings back is the backup's, not a write under this sentence, and the transaction that commits `STO-56`'s record replaces it. An engine that survived the restore holds the backup's value and would match: before that transaction commits, `STO-60`'s chain refuses it where the backup lacks one of its acknowledged writes; after it, this row does."
- **Span 19** (`STO-54`, 05:1557): keep as written; append "Before that transaction commits, a survivor's writes are refused by `STO-60`'s chain where the backup lacks one of its acknowledged writes (`OPS-50`)."
- **`STO-6`**: the Appendix's pointer gains "and `STO-60`'s table".
- **`CNF-370`**, a delta on F3's text, appended: "Then run two pre-record cases with the restore holding `STO-56`'s record transaction open until the engine has exited and the proxy admitting the engine's connections as soon as the restored store accepts them. (a) The held worker acknowledged one write after the backup (an `OPS-45` marker): assert its cut-off record commits nothing, the engine logs that the store went backwards and exits non-zero before the record commits, and `STO-60` holds no row above the backup's. Run (a) once more with the proxy keeping the lock connection on the original server and routing new connections to the restored one: assert the same refusal on the first write that reaches the restored store. (b) No engine write acknowledged after the backup: assert every write the survivor commits before the record carries a number above the backup's highest, and that its first write after the record is refused by `STO-59` and exits it non-zero."
- **`CNF-371`**: "Start an engine; let one write acknowledge; delete `STO-60`'s highest row out of band, with no second engine and no restore; drive one path `CNF-367` lists: it commits nothing, the engine logs that the store went backwards and exits non-zero; at restart the advance leaves the table at one row and the pass proceeds."
- **`ADR-0047`**: records `STO-60`, the cost below as the price of the restore case `ADR-0019` put out of scope, the residual, and that no model carries a restore, so no theorem.
- **`CONTEXT.md`**: entry **Write chain**: "`STO-60`'s rows, one per engine write; the engine checks that the last one it saw acknowledged is still there; the restore and the next pass are its other writers."
- **`Claim.lean`** docstring (span 17): add "a store restored from backup (`STO-60`'s chain is not modelled)".

## Option 3: session witness (the r66c text verbatim, plus the deployment rule its item 6 picks)

Its item 6 keeps Reader Z's text but its spec text places none. As voted here, Option 3 also appends Reader Z's
sentence at the end of span 19, exactly as Option 4 does.

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

## Option 4: deployment rule only (manager assembly from the r66c answer's item 6 and its `STO-59` repair)

- **Span 19 (`STO-54`)**: append at its end Reader Z's sentence, where "that transaction" is the one span 19 names:
  "Until that transaction has been acknowledged, the deployment MUST prevent either component, including a process
  that survived the restore, from using the restored store."
- **`CNF-370`**: F3 as accepted (Base), unchanged. **`STO-59`** and the Appendix's `CONTEXT.md` entry: the r66c text
  below, verbatim (it starts at its `CNF-370` paragraph).

My `CNF-370` is **F3 unchanged**. Its held worker makes a record write reachable, and its controlled admission places that write after the fresh generation commits. A conforming G implementation can pass it. It supplies no evidence for refusal before that commit.

For the separate freshness ambiguity, I would make this exact repair relative to Appendix `STO-59`:

> **Before, heading:** “the startup generation is one row, and no value is written to it twice.”
>
> **After:** “the startup generation is one row, and generation choices are fresh.”
>
> **Before:** “A value MUST NOT be written to the row twice, including across a restore from backup:”
>
> **After:** “Every startup advance and restore-record transaction MUST choose a random UUID distinct from the values chosen by earlier startup advances and restore-record transactions, including choices whose effects a restore removed. Reinstating a backed-up value is not a new generation choice.”

The following restore-transaction explanation remains. Apply the same distinction to the Appendix’s `CONTEXT.md` entry, replacing “never written twice” with “freshly chosen by each startup advance and restore-record transaction”. This repairs terminology; it does not close the window.

## Base: F1–F9, W-1, W-2 and D1–D4 (accepted 4-0 in r66c; applied on top of the Appendix; not re-voted)

- **F1. `OPS-21`'s two closed exit lists, and `CNF-362`'s quotation, in lockstep** (behaviour; Reader X, uncontested).
  R's `OPS-21` sentence quotes `OPS-50`'s refusal, but neither closed list names the exit.
  - 03:1741-1742. Before: "subject to the" / "bounded abandonment and later-stop exits below." After: "subject to
    the bounded abandonment, later-stop and superseded (`OPS-50`) exits below."
  - 03:1807. Before: "the Store-retry bound's exhaustion exit, the lost-reply case" After: "the Store-retry bound's
    exhaustion exit, the superseded exit (`OPS-50`), the lost-reply case".
  - `CNF-362` quotes 03:1807 verbatim at 10:1682. The same insertion is made inside that quotation.
- **F2. R's `OPS-47`** (Appendix 2; wording, Reader X). Before: "record each under `OPS-21` within its Stop-record
  bound and exits, and then exit non-zero." After: "record each under `OPS-21` within its Stop-record bound, subject
  to its exits, and then exit non-zero."
- **F3. `CNF-370`** (behaviour; Reader X). It replaces the Appendix's `CNF-370`: "Start an engine and hold one of its
  workers in `execute`; back up. Through a proxy the harness controls, refuse the engine's store connections from
  then until the restore has committed `STO-56`'s record. Make the Stop-record and Store-retry bounds longer than
  that interval, and start no other engine. Then admit its connections. Assert the restore record's transaction
  wrote a fresh value before either component started (`STO-56`), that the survivor's next write (its settle or
  cut-off record) commits nothing and the engine exits non-zero, and that every value written by an advance or by a
  restore record's transaction is distinct." **Read it as the fixture for span 19 as written**: the survivor's write
  comes after the record commits, a case G must handle whatever Q1 picks. The proxy is a harness device, not a
  deployment rule. An ACCEPT here does not endorse a barrier; Q1's drafts give their own `CNF-370` delta.
- **F4. Lean** (behaviour; Reader X). `ADR-0025` says "**Every guard that a dated amendment added is a parameter of
  the model that carries it**, and the" / "module holds two theorems: the bad trace is refused with the guard and
  admitted without it." (0025:118-119). The Appendix's "No field is added to `Guards`/`workerGuard`" leaves the
  witness nothing to switch off. Before (Appendix 1, Lean, `Claim.lean`): "No field is added to
  `Guards`/`workerGuard` (Reader 2)." After: "The check is a parameter of the model that carries `engineStep`,
  `generationCheck : Bool`. `superseded_never_commits` holds with it on, and the witness
  `superseded_commits_without_check` admits the bad trace with it off."
- **F5. Span 13 and `ADR-0047`** (wording). The `ADR-0019` option ends at :81 ("this ADR puts out of scope, and keeps
  a column, a counter and a guard term alive to do it."), and its rejection is on scope and on cost.
  - Span 13. Before: "a dated note after the option ending "Correct, and cheap." (0019:80): "*2026-10-24: this option
    was rejected on scope; `ADR-0047` reopens the scope and adopts it, widened to every engine write (`OPS-50`,
    `STO-59`).*"" After: "a dated note after the option, which ends "a guard term alive to do it." (0019:81):
    "*2026-10-24: `ADR-0047` reopens this option and adopts it, widened to every engine write (`OPS-50`,
    `STO-59`).*""
  - `ADR-0047`. Before: "which was rejected only on scope ("Correct, and cheap.", 0019:80)". After: "which
    `ADR-0019` rejected on scope and on cost: "Rejected because it buys a defence for the case this ADR puts out of
    scope, and keeps a column, a counter and a guard term alive to do it." (0019:80-81); `ADR-0047` states the cost
    G pays in their place".
- **F6. Span 16's replacement** (wording; Reader Y: it contradicted span 12, whose late write "commits nothing … (`OPS-50`
  once the generation has moved"). Before (span 16's After): "What this drill does not exercise is the generation
  fence; `CNF-367`–`CNF-370` drive it (`OPS-50`).*" After: "For the dedicated generation-fence drills, see
  `CNF-367`–`CNF-370` (`OPS-50`).*" Span 16's Before (10:1519-1521) is unchanged.
- **F7. `OPS-50`'s two-copies sentence** (wording; Reader Y: the quoted rule at 05:1508 sits in the promotion bullet
  only). Before (Appendix 1, `OPS-50`): "Nor does it fence two writable copies of the database, which `STO-54`
  excludes: "the old primary MUST NOT serve a component again", or an engine binary that makes no check
  (`STO-13`)." After: "Nor does it fence two writable copies of the database; its guarantee covers one writable
  database history." (The `STO-13` clause also goes with Q3's drop, D2.)
- **F8. `README.md`:304-306** (quotation update: span 1 removes the words it quotes). Before:
  ```
  That the process is one is, in `OPS-47`'s words, "a
  deployment obligation and not a property this specification enforces"
  (`ADR-0019`).
  ```
  After: "That the process is one is, in `OPS-47`'s words, "a deployment obligation" (`ADR-0019`); `OPS-50` refuses
  a superseded engine's writes (`ADR-0047`)."
- **F9. `ADR-0025`:64-67** (quotation update). The bullet quotes `OPS-47`'s "a deployment obligation and not a" /
  "property this specification enforces" (:65-66), words span 1 removes. Add after "a signature shows the dependence.
  A model that omits a second engine says so in its docstring." (:67): "*2026-10-24: `OPS-47` no longer carries these
  words; see `ADR-0047`.*"

**Wording, applied and listed, not voted:**

- **W-1** `OPS-15` (Appendix 1): "This transaction alone is exempt from `OPS-50`'s generation read." is deleted, and
  the paragraph's first sentence ends "…the replacement of `STO-59`'s startup generation (`OPS-50`'s exception)."
  (Reader X: the sentence restates `OPS-50`'s prefix.)
- **W-2** `OPS-50` (Appendix 1): "(`OPS-32`'s cleanup)" becomes "(the key deletion `PRV-9` gives `OPS-32`'s sweep)"
  (Reader W). `PRV-9` (02:142): "registered at the provider MUST be deleted by `OPS-32`'s sweep when, and only when,
  its operation".

**Not adopted** (r66b non-blocking notes, recorded, not voted): Reader X's `STO-54` step (1) writer note; Reader W's
notes 1–3; Reader X's `CNF-367`/`CNF-369` additions; Reader Y's and Reader Z's Lean freshness hypothesis.

The repository holds only the specification (`AGENTS.md`:4: "Nothing that implements the specified system belongs
here."), and the owner's answer is that the project is not built yet. So no build without `OPS-50`'s check exists to
roll back to or to run beside the first build with it. The transition clause and r66b's Q3 are dropped. The manager
stripped these dependents:

- **D1.** Span 22 (Appendix 1, `STO-13`) is deleted whole.
- **D2.** `OPS-50`'s ", or an engine binary that makes no check (`STO-13`)" goes (F7 replaces that sentence).
- **D3.** The not-covered bullet "An engine binary that makes no check (`STO-13`, Q3)." is deleted.
- **D4.** `ADR-0047`. Before: "the `STO-13` boundary with Q3's answer". After: "that no transition from an engine
  without the check is specified, because on the owner's answer no build predates `OPS-50`".

## Appendix 1: Fence G as merged in r66b (verbatim)

**The design.** (1) One row, `STO-59`, holds the startup generation. Each startup pass replaces it with a fresh
random UUID in a transaction of its own, committed and acknowledged before anything else in the pass; a restore
writes a fresh one in the transaction that commits `STO-56`'s record. Every check is equality. (2) Every other
engine-process write transaction reads that row `FOR SHARE` first and compares it with its own pass's value, holding
the lock to commit. A mismatch rolls back and the engine exits non-zero at once, never repeating. (3) The advance
waits on every open share lock, bounded by `statement_timeout` and `lock_timeout` set to the Startup-lock wait bound.
On timeout the new engine exits non-zero having claimed nothing.

PostgreSQL 18, 13.3.2: "A shared lock blocks other transactions from performing `UPDATE`" and "Row-level locks are
released at transaction end". **Lock order:** the generation read precedes `LDG-35`'s primitive, and the advance is
a transaction holding only the generation row, so it waits on share holders and holds nothing they wait for: no
cycle. Because the advance commits before the sweep's transaction begins, the sweep's snapshot is taken after every
share holder the advance waited on has committed (r66's REPEATABLE READ trace).

### New text

- **`STO-59`** (05, a new paragraph after `STO-51`'s, before `### Engine choice` at 05:99): "**STO-59** **ADDED
  2026-10-24 (`ADR-0047`) — the startup generation is one row, and no value is written to it twice.** The store MUST
  hold exactly one row carrying the **startup generation**. `OPS-15`'s startup pass replaces it with a fresh random
  UUID (`gen_random_uuid()`) in a transaction of its own. It is not a counter and is never compared for order:
  every check is equality (`OPS-50`). A value MUST NOT be written to the row twice, including across a restore from
  backup: `STO-54`'s procedure writes a fresh value in the transaction that commits `STO-56`'s record, which is
  written "before either component is started". Without that write, an engine that survived the restore still holds
  the restored value and would match. This row is the fence `STO-51`'s lock is not."
  **[took: Reader 1's and Reader 2's anchor, `STO-56`'s record transaction; the MUST lives in `STO-54` (Reader 2, Reader 3, Reader 4).]**

- **`OPS-50`** (03, after `OPS-49`'s last bullet): "**OPS-50** **ADDED 2026-10-24 (`ADR-0047`) — every engine write
  checks the startup generation, and a mismatch exits.** Except for `OPS-15`'s generation-advance transaction, every
  write transaction made in the engine process — a claim (`OPS-5`), a worker's writes (`OPS-22`, `OPS-43` step 8,
  `OPS-45`'s markers, `OPS-42`'s machine-row writes), a settle or cut-off record (`OPS-21`), an `OPS-8` defer, every
  component `OVR-17` assigns to the engine, `OPS-27` and `OPS-32` included, and the `ledger` components `OVR-17` says
  "run in the engine process" — MUST read `STO-59`'s row `FOR SHARE` as its first statement, compare it for equality
  with the value the engine's own startup pass wrote, and hold that lock until it commits. A component that acts on
  the provider from reads (`OPS-32`'s cleanup) MUST make the check in the read transaction that licenses the
  dispatch. Where the values differ, the transaction MUST roll back, and the engine MUST log loudly that it was
  superseded and exit non-zero at once, beginning no other transaction. A mismatch is not a store error (`OPS-49`)
  and is never repeated. A refused generation check ends recording without another attempt; an earlier attempt may
  already have committed with its reply lost. Writes made in the api process are not checked. **What it does not
  cover:** a provider call licensed by a check that committed before `OPS-15`'s advance goes out — step 9 after step
  8 (`OPS-43`: "Step 9 MUST begin only after step 8's transaction is acknowledged"), an install's destructive phase
  after one marker, end-rescue, `PRV-9`/`PRV-18` temporary-key deletion, `OPS-32` after its read. Nor does it fence
  two writable copies of the database, which `STO-54` excludes: "the old primary MUST NOT serve a component again",
  or an engine binary that makes no check (`STO-13`)."
  - **[took: Reader 4's "Except for `OPS-15`'s generation-advance transaction," (B1).** It is a prefix and leaves the
    sentence whole. Reader 1's "other than the generation write that begins" and Reader 3's "generation-replacement" say
    the same thing. Reader 2's "after … has committed" moves the ordering into `OPS-50`, which `OPS-15` now states.]
  - **[took: Reader 4's lost-reply sentence (B7), the shorter of the two.** It replaces r66's "A record pending under
    `OPS-21` ends there, unlanded, as an exit does." Reader 3's version says the same in two sentences.]
  - **[B10]:** r66's "— and its row reaches `needs_reconciliation` or one of `OPS-15`'s exceptions" is deleted
    (Reader 4: `CNF-303` requires deletion "with the row still absent").
  - The `OPS-8` defer (Reader 1) and the `ledger` components (Reader 2) were r66's non-blocking notes. They are added to the
    list because `CNF-367` drives every listed write. `OVR-17`'s words, at 00-overview:316, are "the three `ledger`
    rows run in the engine process".

- **`OPS-15`**, a new paragraph after its first, which ends "pass is needed; nothing but a restart can leave a
  `running` row with no worker behind it." (03:359): "The engine's first write transaction after taking `STO-51`'s
  lock MUST contain only the replacement of `STO-59`'s startup generation. Its commit MUST be acknowledged before
  the engine begins any other write transaction, the remainder of the pass, or any worker or periodic component. This transaction alone is exempt from `OPS-50`'s generation read. Its
  replacing statement MUST run with `statement_timeout` and `lock_timeout` both set to `OVR-19`'s Startup-lock wait
  bound. That statement waits on every open `FOR SHARE` of the row (`OPS-50`), so every earlier engine's write
  either committed before it, and is swept here, or is refused after it. On that timeout or any store error,
  including a lost reply on its commit, the engine MUST log loudly and exit non-zero having claimed nothing; this
  exit is not `OPS-49`'s retry, which covers workers and periodic components. **Liveness:** a `SyncRep` holder
  (`STO-7`: "A standby wait has no server-side timeout"), or share holders that keep turning over, can hold the
  advance until that exit, which `OVR-18` alarms; the supervisor's restart is the retry."
  - **[took: Reader 4's three sentences for B1+B2,** paired with Reader 4's `OPS-50` prefix. They are the smallest text that
    carries everything r66's tally asks for: its own transaction, nothing else in it, commit acknowledged before the
    sweep, claims and periodic components. Reader 2's single sentence omits the acknowledgement and the periodic
    components. Reader 3's adds a lock-ordering clause and a fourth sentence. **The manager's change, not a reader's:**
    the first sentence is anchored to the engine's first write after the lock, not to "the pass's first
    transaction", because `STO-54`'s step (2) writes "*Before the first claim*" (05:1542) on a startup with an
    open restore record, and a write before the advance would have no own value to compare against.]
  - **[took: Reader 2's timeout sentence (B9).** Reader 2: `lock_timeout` "applies separately to each lock acquisition
    attempt", and `STO-7` registers a `statement_timeout`; setting both bounds the whole wait. Reader 4's fix is the type
    change below. It is needed too, and does not conflict.]
  - **A zero bound:** PostgreSQL says of `lock_timeout` and `statement_timeout` that "A value of zero (the default)
    disables the timeout" (Reader 4's quote, postgresql.org; check it). `OVR-19`'s row becomes "finite, positive" (below),
    so a zero is out of range, and `OVR-19` says startup MUST "refuse to run on a missing or out-of-range value". A
    zero bound therefore stops startup before any advance; it never disables the advance's timeout.

- **`ADR-0047`** (new, one ADR for R and G): records R's decision. States that G **reverses `ADR-0019`'s
  rejection** of "guard the claim itself on `engine_epoch = mine`", which was rejected only on scope ("Correct, and
  cheap.", 0019:80), and that G widens it to every engine write and closes the race with `FOR SHARE`. States the
  not-covered cases, the `STO-13` boundary with Q3's answer, the timeout typing, and that `finished_unrecorded_exit`
  is weakened by one disjunct (below), against `ADR-0044`'s "No existing theorem is weakened".
- **`CONTEXT.md`**: a new entry, **Startup generation**: "the `STO-59` value each startup pass replaces; equality
  only; never written twice".

### Amended spans (before → after). Spans 2, 3, 4, 5, 7, 8, 9, 12, 13 and 14 are r66's, unchanged.

1. `OPS-47` (03:137-139). Before:
   ```
   **That is a deployment obligation and not a
   property this specification enforces** (`OVR-19`): where two engines run, nothing here refuses the
   second, and both will work the queue.
   ```
   After: "**That is a deployment obligation** (`OVR-19`). Where two engines run, no write of the first commits once
   the second's startup pass has committed a new `STO-59` generation (`OPS-50`); provider calls the first already
   licensed still go out." *(Changed from r66: "has replaced" becomes "has committed", because an advance that
   rolls back supersedes nothing (Reader 3).)*
2. `OPS-47` (03:146). Before: "**The lock is not a fence**: no write is guarded on it," After: "**The lock is not a
   fence**: no write is guarded on it (the generation is, `OPS-50`),". (R's loss clause replaces the sentence before
   it; see Q2.)
3. `OPS-6` (03:176-177). Before:
   ```
   claimed — and is not a fence against a second engine, of which `OPS-47` says "where two engines
   run, nothing here refuses the second".
   ```
   After: "claimed — and is not a fence against a second engine; that is `OPS-50`'s generation check."
4. 03:1735-1737 prose. Before:
   ```
   (`STO-3`). `OPS-42`'s fence writes a machine row and carries no such guard, which is why `OPS-47`
   says "where two engines run, nothing here refuses the second, and both will work the queue"
   instead of implying otherwise.
   ```
   After: "(`STO-3`). `OPS-42`'s fence writes a machine row and carries no such guard; against a second engine it
   carries `OPS-50`'s generation check, as every engine write does."
5. `OPS-5` (03:159). Before: "or the startup pass finds it (`OPS-15`)." After: "or the startup pass finds it
   (`OPS-15`). The claiming step's transaction makes `OPS-50`'s generation check first."
6. `OPS-15` (03:355-356). Before:
   ```
   any claim, the engine MUST move every `running` operation to `needs_reconciliation` — with one
   writer, any `running` row at startup is interrupted —
   ```
   After: "any claim, the engine MUST move every `running` operation to `needs_reconciliation` — after the
   generation advance below no earlier engine's write commits (`OPS-50`), so any `running` row at startup is
   interrupted —"
7. `OPS-22` (03:1832-1833). Before:
   ```
   leave the record
   alone, and exit.
   ```
   After: "leave the record alone, and exit. A write that `OPS-50`'s generation check refuses is not a zero-row
   write: the engine exits at once (`OPS-50`)."
8. `OPS-49` (03:1843-1844). Before:
   ```
   where `OVR-18`'s alarm is
   watching.
   ```
   After: "where `OVR-18`'s alarm is watching. A refused generation check (`OPS-50`) is not a store error and is
   never repeated."
9. `STO-51` (05:91-92). Before:
   ```
   and says
   nothing about any write that already happened.
   ```
   After: "and says nothing about any write that already happened. The fence is `STO-59`'s generation (`OPS-50`)."
10. `STO-3` (05:29-30). Before:
    ```
    — after `LDG-35`'s
      primitive is taken where the settlement needs it, since that lock is the transaction's entry —
    ```
    After: "— after `OPS-50`'s generation read and then `LDG-35`'s primitive where the settlement needs it, since
    those locks, in that order, are the transaction's entry —"
11. `STO-3` (05:48-49). Before:
    ```
    It runs
      before the process makes any claim, so nothing contends with it.
    ```
    After: "It runs after `OPS-15`'s generation advance and before the process makes any claim, so no earlier
    engine's write commits beside it (`OPS-50`)."
12. `CNF-290` (10:1511-1512). Before:
    ```
    and that the old process's late settled-state write affects **no row** and exits it
          (`STO-3`, `OPS-22`).
    ```
    After: "and that the old process's late settled-state write commits nothing and exits it (`OPS-50` once the
    generation has moved; `STO-3`, `OPS-22` otherwise)."
13. `ADR-0019` (0019:78-80): unchanged, with a dated note after the option ending "Correct, and cheap." (0019:80):
    "*2026-10-24: this option was rejected on scope; `ADR-0047` reopens the scope and adopts it, widened to every
    engine write (`OPS-50`, `STO-59`).*"
14. `CONTEXT.md`:108. Before: "_Avoid_: attempt, attempt count, generation, epoch (withdrawn)," After: "_Avoid_:
    attempt, attempt count, generation (that is the startup generation), epoch (withdrawn),".

**New in this round: the quotations r66 found stale (B-missing), and the behaviour ids.**

15. `OPS-15`'s create exception (03:415-416), which quotes `STO-3`'s words that span 11 removes. Before:
    ```
    This describes their predicates, not an in-scope second engine: `STO-3` says
    "nothing contends with it".
    ```
    After: "This describes their predicates; an earlier engine's step-8 write cannot commit once the pass has
    advanced the generation (`OPS-50`)." **[took: Reader 2's.** It is the shortest, and it quotes nothing that could go
    stale. Reader 1's quotes span 11's new words, and Reader 4's replaces three sentences.]
16. `CNF-290`'s note (10:1519-1521), which quotes `OPS-47`'s words that span 1 removes. Before:
    ```
    What this drill must not be
          read to prove is that a second engine cannot write: `OPS-47` says "where two engines run,
          nothing here refuses the second, and both will work the queue".*
    ```
    After: "What this drill does not exercise is the generation fence; `CNF-367`–`CNF-370` drive it (`OPS-50`).*"
    **[took: Reader 2's.** Reader 4's is the same claim without the ids. Reader 1's and Reader 3's add a residual claim.]
17. `Claim.lean` docstring (:22-24). Before:
    ```
    refused claim (`engineClaim` claims again from `idle` without counting), and a second engine.
    `OPS-47`'s single engine is assumed throughout, as `OPS-6` says the number "is not a fence against
    a second engine". -/
    ```
    After: "refused claim (`engineClaim` claims again from `idle` without counting), and a second engine beyond
    `OPS-50`'s generation check, which `superseded_never_commits` models. Otherwise `OPS-47`'s single engine is
    assumed, as `OPS-6` says the number "is not a fence against a second engine". -/" (Span 3 keeps those words in
    `OPS-6`.)
18. `ADR-0022`:82 ("The guarded status write is the transaction's first statement"): a dated note at the end of
    that paragraph: "*2026-10-24: `ADR-0047` changes this order; `OPS-50`'s generation read precedes the guarded
    status write.*" **[took: Reader 4's**, the one that is dated.] `ADR-0022`:92-93 ("`OPS-47`'s "where two engines run,
    nothing here refuses the second"" / "stays true."): a dated note after "stays true.": "*2026-10-24: `OPS-47` no
    longer says this; an earlier engine's writes are refused once a later engine's pass advances the generation
    (`ADR-0047`, `OPS-50`).*" (Reader 1, Reader 2.)
19. **`STO-54`, behaviour (B3).** In "The procedure survives its own interruption", after "whatever ended its
    predecessor." (05:1557) add: "The transaction that commits that record MUST also write a fresh `STO-59` startup
    generation (`OPS-50`), so an engine that survived the restore holds a value the restored store does not." A
    promotion that is a restore runs the same procedure (05:1514-1515). `STO-56` gets a pointer only.
20. **`OVR-18`, behaviour (the alarm).** After "`ADR-0023`): the recovery point exceeding its threshold, and either
    named standby being unavailable (`STO-7`)." (00-overview:338) add: "**Two exits are alarmed on the same model**
    (added 2026-10-24, `ADR-0047`): an engine's superseded exit (`OPS-50`), and its startup exit on the generation
    advance's timeout (`OPS-15`)."
21. **`OVR-19`, behaviour (the timeout).** Before: "| Startup-lock wait bound | `OPS-47` | duration | yes |"
    (00-overview:399). After: "| Startup-lock wait bound | `OPS-47`, `OPS-15` | finite, positive duration; also the
    generation advance's `statement_timeout` and `lock_timeout` (`OPS-15`) | yes |". This also forbids a zero bound
    for `OPS-47`'s lock retry. That bound was untyped "duration" before.
22. **`STO-13`, behaviour (B8).** After "is `STO-54`'s restore." (05:1432, before "**A change to a predicate") add:
    "**`OPS-50`'s check fences only engines that make it.** The release that adds it MUST stop every engine of the
    previous release before its own first engine starts, so its first startup advance has no unchecked engine
    beside it. A previous-release engine still running makes no generation check and is not refused." Q3 decides
    what follows this sentence. **[took: the core shared by Reader 3's and Reader 4's texts.** The rollback clause, on which
    they differ, is Q3.]

**Pointer-only amendments (one appended `OPS-50`/`STO-59` pointer each; no behaviour).** `STO-1` (claim contract);
`STO-6` (primitive list: the row and its `FOR SHARE`); `STO-56` (its record's transaction carries `STO-54`'s fresh
value); `OVR-17` (each engine writer, the `ledger` components included, carries `OPS-50`); `ADR-0016`; `CONTEXT.md`:
520-527, saying why the generation is not the withdrawn epoch: the row has writers other than the engine that checks
it, the next pass and the restore (Reader 1); `CNF-362`'s quotation, if `OPS-21`'s quoted list changes. **Check:** is
any of these behaviour, not a pointer? Is an id still missing?

### New conformance items

- **`CNF-367`** — In a separate run for each engine write path `OPS-50` lists, advance the generation out of band
  (no second engine) after that engine's startup advance, then drive the selected path: it commits nothing; the
  engine logs "superseded" and exits non-zero; no transaction repeats. **[took: Reader 4's, which replaces only the
  setup (B6). Reader 2's is a full rewrite of the item.]**
- **`CNF-368`** — With no engine holding `STO-51`'s lock, open a store session that reads `STO-59`'s row
  `FOR SHARE` and claims a `queued` operation, its transaction left open. Start an engine: assert its generation
  write waits; commit the session; assert the engine's sweep moves the claimed row to its `OPS-15` startup state.
- **`CNF-369`** — As `CNF-368`, but hold the session past the Startup-lock wait bound: assert the engine logs
  loudly and exits non-zero having claimed nothing, `STO-59`'s value is unchanged, and the session's commit then
  succeeds. **[took: Reader 2's harness fixture for both (B4).** Reader 1's is the same shape. Reader 3's and Reader 4's need a
  staged lock-connection loss, and the harness reaches the same advance with less. With no engine holding the
  lock, the exit cannot come from `STO-51`'s refusal (Reader 3's concern).]
- **`CNF-370`** — Start an engine; back up; keep it running with no restart; restore from that backup with the
  engine surviving and reaching the restored store before any engine starts on it. Assert the restore wrote a fresh
  value before either component started (`STO-56`), the survivor's next write is refused and it exits non-zero, and
  every value ever written to the row is distinct. **[took: Reader 1's (B5).** It pins the survivor to the backup's
  value, as Reader 3 and Reader 4 ask. Reader 2's is equivalent.]

### Lean (named, not built)

- `Claim.lean`: the check is modelled on `engineStep` (:430): a mismatch moves the engine to `.exited` with the row
  unchanged, so it is not a `zeroRows` outcome (span 7). No field is added to `Guards`/`workerGuard` (Reader 2). A new
  theorem `superseded_never_commits` states that no claim by a superseded engine commits after the advance, with
  `ADR-0025`'s witness pair: "the bad trace is refused with the guard and admitted without it" (Reader 4). The docstring
  changes as span 17 says.
- `StopRecord.lean`: `Event` gains `| superseded`, which ends the record as `laterStop` does. It applies through
  r65b's Form E fix-8 list, with `superseded` in place of `lockLost` (`schedule`, `schedule_bounded`,
  `later_stop_exits` plus a `superseded_exits` beside it, the three `selection` splits, `money_posts_at_most_once`'s
  docstring). `superseded_exits` keeps `exit_store`'s lost-reply alternative (Reader 3, Reader 4). It weakens
  `finished_unrecorded_exit` by one disjunct, which `ADR-0047` states.

### What G does not cover (stated plainly)

- A provider call licensed by a check that committed **before** the takeover goes out (the list in `OPS-50`).
- Two writable copies of the database (`STO-54`). G fences one database history only.
- An engine binary that makes no check (`STO-13`, Q3).
- Liveness: a `SyncRep` holder, or share holders that keep turning over, delay the takeover until `OPS-15`'s exit.

## Appendix 2: Form R as merged in r66b (verbatim)

R carries r65's fixes 1–7, confirmed in r65b. Form E's fixes 8 and 9 do not apply to R. Below is R's text with
r66's repairs in it.

- **`OPS-47`** keeps master's "hold it for its lifetime". Before (03:145-146):
  ```
  where the connection carrying
  it is lost it MUST exit.
  ```
  After: "where the connection carrying it is lost, the engine MUST, from the moment it detects the loss, log loudly
  that the lock connection was lost, claim nothing more and begin no periodic pass, treat the loss as a stop of every
  worker not already recording one, record each under `OPS-21` within its Stop-record bound and exits, and then exit
  non-zero. The loss is not a later stop: a record already pending when the loss is seen continues under its own
  Stop-record bound and exits." **[took: Reader 2's.** Reader 1's is the same text plus "(`OVR-19`'s keepalives bound
  it)", a claim this round would have to check. Reader 3's and Reader 4's say the same thing in different sentences.]
- **`OPS-21`**, after "thrown away and `OPS-15` classifies the row as interrupted"." (03:1773): "A loss of the
  connection carrying `OPS-47`'s startup lock is not a later stop: `OPS-47` says “treat the loss as a stop of every
  worker not already recording one”. For a worker still in `execute`, this requirement's cancellation rules apply,
  including the stop that “MUST NOT cancel `execute`” and the parent's defer, which “records no error”; for one whose
  `execute` has returned, its settle write records it; it ends no record already pending. A stop that arrives after
  the engine detects the loss and before that record lands is a later stop. `OPS-50` says “A refused generation
  check ends recording without another attempt; an earlier attempt may already have committed with its reply
  lost.”" **[took: Reader 4's "after the engine detects the loss", and Reader 4's quotation in place of r66's "ends there,
  unlanded" sentence.]**
- **`OPS-49`**, its retry-loop bullet (ending "subject to its exceptions and the lost-reply case above.", 03:1879)
  gains: "`OPS-47` says of a lost lock connection “The loss is not a later stop”: a worker repeating a record when
  the loss is seen keeps repeating it."
- `ADR-0019`'s restatement takes `OPS-47`'s new words, with a dated note. `ADR-0047` records the decision.
- `StopRecord.lean`: no new constructor for the loss. `Event`'s doc comment gains: "A lost lock connection is the
  originating stop or no event: `OPS-21` says it “is not a later stop”."
- **Stated by the text:** with no stop pending, the loss is a stop the engine survives for each worker in
  `execute`. A non-parent worker is cancelled and records a cut-off `conflict` under its row (`OPS-11`). The
  exceptions are a create past its confirming read and a delete past its accepted dated cancellation: the stop
  "MUST NOT cancel" them, and they settle as `CNF-362`'s read cases do. A cancelled `suspend_tenant` parent records
  the defer, with no error.
- New **`CNF-366`**: "**A lost startup-lock connection is a stop of every worker, not a later stop.** `OPS-47` says
  “The loss is not a later stop”. Keep the startup generation unchanged throughout these cases; no successor or
  out-of-band writer advances it. Terminate the lock connection's backend: (i) with no stop pending, while a
  non-parent worker is in `execute`, outside `CNF-362`'s absorbed-read cases; (ii) with no stop pending, while a
  create's after-return settle write repeats under `OPS-49`; (iii) while an earlier stop's cut-off record repeats
  under `OPS-49`. For cases (i)–(iii) and (vi), arrange that the record can land before either the Stop-record bound
  or the Store-retry bound expires, with no later stop. Where a write repeats, the store refuses its transactions
  until lock-loss detection and then accepts writes with sufficient time remaining under both bounds. Assert: no
  claim and no periodic pass begins after the engine detects the loss, as its loud log timestamps the detection;
  case (i) records a cut-off `conflict` classified against its row (`OPS-11`); the settle write and the earlier
  record land, the create `succeeded` with its money posted once; the engine exits non-zero only after the records
  land. (iv) Deliver a stop after the engine detects the loss, before a record lands: assert `CNF-362`'s later-stop
  assertions, including “Accept either outcome”. (v) With every transaction a store error after the loss, assert
  exit within the Stop-record bound measured from the stop being recorded (the loss as the engine sees it, or the
  earlier stop), the loud log, and `OPS-15` at restart, including its exceptions. (vi) Repeat `CNF-362`'s cases for
  a create past its confirming read, a delete past its accepted dated cancellation, and a `suspend_tenant` parent at
  successive fan-out positions and waiting on its children, with the loss as the stop and no stop pending, asserting
  their `CNF-362` outcomes: no `needs_reconciliation` and no `cut_off` for the reads, the defer with no error for
  the parent, and exit only after the settle write or defer lands."
  - Changes from r66: the generation sentence (Reader 3); "after the engine detects the loss" in the assertion, which
    the mandated loud log now timestamps, and in (iv) (Reader 4); "every transaction a store error" in (v), since
    `OPS-50` now uses "refuses" for a mismatch (Reader 1).
