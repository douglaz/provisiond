# Verification of the external review (2026-10-23), claim by claim (pv-s4m, panel C)

Input: /var/tmp/provisiond-manager/external-review-2026-10-23.md (the review, verbatim). Checked against the spec
(master and branch `panel-c`, both at `dc5d40d`), the panel draft /var/tmp/provisiond-panel-r63e/forms-final.md
("draft"), PostgreSQL 18 docs and source (r63f/src, r63g/src), Patroni docs (r63f/src) and the harness
(/var/tmp/provisiond-pgharness/results.md, cited as H-a … H-f).

Classes: **NEW** = correct and new; **COVERED** = correct and already covered (named where); **WRONG**.

## Finding 1: `api` cancellation piles up `SyncRep` backends with no restart. NEW (the deadline half is COVERED)

- The spec licenses the abandonment. `05:142-144`: "a connection abandoned mid-transaction — by a timeout, a
  cancelled worker or a lost reply — MUST be reset before it returns to the pool". Draft `STO-7`: "a store call
  whose client-side deadline expires closes its connection".
- **COVERED, the deadline half.** Both S2' texts take the standby wait out of the store-call deadline. A: "is
  excluded from that call's store-call and Store-retry deadlines". B: "no client-side deadline cuts it short".
- **NEW, the cancellation half.** Neither text says anything about a request whose client goes away, or whose
  handler is cancelled, after it has sent COMMIT. A backend left in `SyncRep` never notices (H-c). `STO-55`'s pools
  count pool connections, not server backends ("each `api` replica's pool holds one per admitted request").
- **The draft removes the only bound there was.** C7 deletes `05:186-188` "**Synchronous-commit transactions are
  capped per replica** (`OVR-19`), so a stalled standby (`STO-7`) occupies at most that many connections".
- **The fix needs no new parameter.** If a sent COMMIT is never abandoned, its connection stays checked out until the
  reply arrives. `STO-55`'s write budget is then the per-replica bound, and its refusal already stops admission:
  "A request that obtains no connection within a stated checkout bound (`OVR-19`) is refused `overloaded` … before
  any transaction begins". Precedent wording: `OPS-21` `03:1791` "The settle write that records a stop after
  `execute` returns MUST NOT be cancelled or abandoned by that stop."
- **NEW (availability only):** "restart backoff or freeze circuit breaker". Backends that an exited process left
  behind are outside every pool (r63f Run point, `05:189-192`). No reader found money at risk in that.

## Finding 2: a barrier fails across a failover. COVERED by the draft; the same-transaction fix is sound

- **The counterexample is correct for a barrier in another transaction** (H-d: the barrier committed on the
  promoted store, a standby acknowledged it, and the earlier read is absent there).
- **The draft already defeats it, as a deployment duty.** Draft `STO-54`: "Before any component connects to the
  promoted store, the deployment MUST stop every engine and `api` process that was connected to the old primary".
  The process holding D in memory dies before it can reach the new primary.
- **Same-transaction fix: sound** by WAL order.
  - A row the transaction can see was committed before its snapshot. So its commit record precedes the barrier's.
  - The barrier's wait ends only when a standby's flush passes the barrier's own end (syncrep.c `SyncRepWakeQueue`).
  - A transaction cannot span two servers: if the connection dies, there is no acknowledgement.
  - Measured in H-d: during a freeze, the barrier's COMMIT blocks. Stopping the primary gives a connection error and
    never an acknowledgement. Releasing a standby gives the acknowledgement, and that standby has D.
- **Caveat (COVERED):** a barrier proves nothing if `synchronous_standby_names` is empty, because the commit then
  doesn't wait (H-d edge). The deployment rule is "the primary never serves with `synchronous_standby_names` empty".

## §7: promotion safety

- **The lagging standby: COVERED.**
  - Draft `STO-54`: "Any other promotion — without both standbys' report, or of the one not further ahead … — is a
    restore".
  - C12: "With one standby unreachable, assert the procedure promotes neither as a restart."
  - The reviewer had only the question doc's summary, "promote the standby further ahead".
  - H-e: promoting the lagging standby loses an acknowledged commit.
- **Patroni quorum mode equals the draft's rule for this topology: COVERED.** From the Patroni docs: "to ensure that
  at all times any subset of voters that can achieve quorum includes at least one node with the latest successful
  commit" and "we need to compare its LSN with the LSN on at least one node (quorum=1 in the /sync key)". With
  `ANY 1` of two standbys, that is one more report, so both standbys report.
- **"MUST refuse automatic promotion": NEW behaviour choice.** The draft lets a promotion without both reports
  proceed as a restore, and the restore procedure accepts the lost interval. The reviewer would forbid it outright.
  That trades write availability. → owner question Q-P.
- **Timelines: NEW.**
  - The draft argues "both hold a prefix of one WAL sequence". Nothing makes the report carry a timeline.
  - H-e2: an old primary started as a standby without `pg_rewind` stays on the old timeline. The PG docs say
    "Whenever an archive recovery completes, a new timeline is created to identify the series of WAL records
    generated after that recovery."
  - H-e2 measured it. The old primary, restarted as a standby of the promoted s1 without `pg_rewind`, logged "new
    timeline 2 forked off current database system timeline 1 before current recovery point 0/47B2898". It reported
    replay `0/47B2898` on TL1, against s2's `0/4004658` on TL2. A "further ahead by LSN" rule picks it, although it
    lacks every TL2 commit.
  - H-e, same family: with the primary dead, each restarted standby reported `pg_last_wal_receive_lsn() =
    0/4000000` whatever it had flushed (s1 replay `0/40085F8`, s2 `0/4000000`). The report has to be the end of WAL
    each holds on the old primary's timeline. `receive_lsn` after a restart isn't that.
- **Fencing: COVERED.**
  - Draft `STO-54`: "the old primary MUST NOT serve a component again … it rejoins only as a standby of the promoted
    store", plus the stop rule above.
  - The PG docs: "you must have a mechanism for informing the old primary that it is no longer the primary. This is
    sometimes known as STONITH … which will lead to confusion and ultimately data loss" (failover.txt).
- **"Promotion … not simply as a restart": WRONG** about this spec's vocabulary. "Restart" is the engine's
  startup branch. `CONTEXT.md:183-186`: "never a **restart**: a restart loses no committed work and the startup pass
  settles what was in flight". It doesn't mean a PostgreSQL restart.

## §8: misconfiguration and visibility

- **What `SHOW` gives an unprivileged role** (H-f): `synchronous_commit` gives `on`, `synchronous_standby_names`
  gives `ANY 1 (s1, s2)`, and `restart_after_crash` gives `on`. All three are readable without privilege.
  `pg_stat_replication` shows that role only pid, usesysid, usename and application_name.
- **`SET LOCAL synchronous_commit = on`: COVERED.**
  - Any role can lower `synchronous_commit` (H-f). So "no connection lowers `synchronous_commit`" is a rule on the
    components.
  - `STO-7`'s first sentence makes the component apply it: "Connection-scoped settings MUST be applied to *every*
    pooled connection".
  - The one exception is a transaction-mode pooler, where the settings go on the role (`05:196`). S3-B's
    no-pooler rule removes it.
  - Adding `SET LOCAL` would **collide with C8**, which deletes "`SET LOCAL synchronous_commit` are compatible".
    Not adopted.
- **"Checks must detect change over time": NEW.** `CNF-296` (draft C9) checks only "a freshly checked-out
  connection". A `synchronous_standby_names` emptied by reload makes every commit local at once (H-d edge), and
  provisiond can't see it. → follow-up bead.

## §5: the read-only WAL check

- **Sound, given privilege.**
  - Without `pg_read_all_stats` the role sees no `flush_lsn`, so the check fails closed.
  - A SECURITY DEFINER function owned by a NOLOGIN role granted `pg_read_all_stats` works for `app` (H-f).
  - The target was reached in about 10 ms on a busy and on an idle primary.
- **It leaves no waiter.** While frozen, the read-only check timed out cleanly with **0** `SyncRep` backends. A
  write-on-connect check left one per attempt: 3 attempts, 3 backends (H-f). The reviewer's row "Can enforce a
  bounded polling timeout safely: Yes, if the transaction remains read-only" holds.
- **WRONG in one detail: the insert position as the target.**
  - `pg_current_wal_insert_lsn()` is `XLogBytePosToRecPtr` (xlog.c:9488). At a page boundary that returns the
    position "where the first xlog record on that page would go", past the page header.
  - So on an idle primary whose last record ends on a boundary, no standby's flush reaches it until more WAL
    arrives. This is from source; the harness never hit it.
  - The flush position always terminates. It is safe when no connection is below `synchronous_commit = local`:
    xact.c flushes the commit before it is marked visible. So the target is the flush position, as S3-B's text
    already says.

## §3: S3-B's limits

- **Fail closed: NEW in words.** S3-B says "MUST NOT use a new store connection until …" and states no failure path.
- **The transaction-mode pooler: COVERED.** The question doc's "The pooler gap", `05:195-197`.
- **Already-validated connections: COVERED.**
  - A later cancel or terminate of another backend's wait shows its commit on a validated connection. Draft E1/E2
    forbid both: "No component sends PostgreSQL a cancel request" and "The deployment MUST NOT cancel or terminate a
    primary backend while it waits … other than by shutting the primary down".
  - **New residual, analysis only, not measured:** E2 allows a fast shutdown. That ends every wait (26.2.8.1, "Users
    will stop waiting if a fast shutdown is requested"). A validated connection whose own SIGTERM hasn't yet been
    processed could, in principle, read such a commit in that sub-millisecond window. A same-transaction barrier
    closes it.
- **S3-B's write-on-connect variant breaks Finding 1's bound.** During a freeze it leaves one `SyncRep` waiter per
  connect attempt. The read-only variant doesn't (H-f).

## §6: which actions need an acknowledged transaction

| Row | Verdict |
|---|---|
| Initial deposit mint | COVERED: the mint is a write, acknowledged under all-synchronous `STO-7` |
| Idempotent funding retry | COVERED by the S3 fix; it is the S3 trace (`04:830` "MUST return the **same** deposit") |
| Balance / status GET | Open → owner question Q-R |
| Purchase admission | COVERED: `STO-27` "MUST be serialized per tenant"; a write |
| Provider mutation | COVERED. `OPS-43` owns step 8: "Step 9 MUST begin only after step 8's transaction is acknowledged" (`03:760`). `OPS-45`: "The engine MUST persist a write-started marker … before that phase runs" (`03:1422`). The claim commits before `execute` (`STO-55`: no transaction "across a provider, rail or rescue-host call") |
| Payment credit | COVERED: `STO-30`'s credit is a write |
| Reconciliation | COVERED: every provider-facing step is behind a guarded write (`STO-3`) |
| Provider reads / monitoring | Agree: no barrier |
| Outbound notifications | No v1 surface: `04:1203` "No webhook, stream, long-poll or change feed ships in v1" |

**Why the engine is covered.** Every engine provider mutation follows a commit acknowledged after the reads that
authorize it. On one WAL history, a later acknowledged commit certifies everything visible before it. Draft
`STO-54`'s stop rule keeps a process from spanning two histories.

## Other claims

- "The published STO-7 still specifies `synchronous_commit = local`": COVERED (draft `05:147-153`, C13 amends
  `ADR-0023`).
- "B cannot prevent the broader connection-exhaustion problem": COVERED (r63f, opus's reason for A).
- "A transaction-mode pooler normally pins a server backend for an explicit transaction": correct (it isn't a spec
  claim).
- "The barrier must generate real WAL … not a temporary or unlogged-table write, a read-only COMMIT": correct.
  xact.c: "we only want to wait if this backend assigned an xid and wrote WAL. No need to wait if an xid was
  assigned due to temporary/unlogged tables". H-d edge: a read-only COMMIT returns at once during a freeze.
