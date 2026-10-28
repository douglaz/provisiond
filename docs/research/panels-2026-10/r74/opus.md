# r74 Panel A — opus reader (master 4662d85)

**Picks:** Q1 OTHER, Q2 U (with conditions), Q3 B, Q4 T plus collateral wording. I changed no spec, formal or tracker file, so I did not run the gate. The only file I wrote is an untracked draft, `r74-opus-draft.md`, in my clone.

PostgreSQL 18 sources I read (commit `b049b4e7`, and the PG18 docs):
- `syncrep.c`, `SyncRepUpdateSyncStandbysDefined`: "If synchronous_standby_names has been reset to empty, it's futile for backends to continue waiting. … we'd better wake them up."
- `SyncRepWaitForLSN`: the "already committed locally" WARNING is emitted only on `ProcDiePending`/`QueryCancelPending`. A waiter woken with `SYNC_REP_WAIT_COMPLETE` gets a plain success.
- `xact.c`, `RecordTransactionCommit`: "we have marked clog, but still show as running". `ProcArrayEndTransaction` runs after it.

Anything else I rely on is marked *unverified*.

## Q1 — pv-c7vg

**(a) Pick: OTHER**, in three parts:
- **A1:** bind each transaction to the backend whose new-connection check passed.
- **A2:** acknowledge a commit only once a named standby is seen to have flushed it.
- **M:** a posture monitor whose record lives outside the primary.

Condition: if the owner declines A2's per-commit read, my fallback is D without component refusal, plus A1, labelled *detection only*. D, P and Z frame the problem wrongly because they make safety depend on how fast drift is detected. Acknowledgement can depend on the observed standby flush instead.

**(b) Example and strongest reason.**
- At 10:00:00 an operator empties `synchronous_standby_names` and reloads.
- A deposit COMMIT that was waiting in `SyncRep` wakes with a plain success and no warning. Every later commit is local only.
- A monitor polling every 30 s cannot un-acknowledge any of those commits.
- Under A2, acknowledgement waits until a named standby reports the primary's flush position sampled after COMMIT returned. Async streaming catches up in milliseconds, so service continues.
- "Acknowledged ⇒ on a named standby" survives the drift, and nothing has to race the reload.

**(c) Mechanics.**

*A1 (pooler, backend switch, session settings).*
- When a new connection passes `STO-7`'s check, the component records `pg_backend_pid()` and that backend's `backend_start`. `pg_read_all_stats` is already granted (ADR-0045 H-f).
- Every later transaction reads that pair and `synchronous_commit`, pipelined with its first statement. It does so before COMMIT and before acting outside the store on anything it read.
- A backend cannot change in the middle of a transaction, so this prevents the hazard for provisiond's own transactions rather than detecting it.
- On a mismatch, or `synchronous_commit` not `on`: roll back, close the connection, alarm, and exit non-zero, as `OPS-50` does.
- It never re-checks and continues. That would be ADR-0045's "Rejected for v1: re-admitting a transaction-mode pooler with a per-transaction check".

*A2 (emptied list, already-sent COMMIT).*
- After COMMIT returns, the component reads on the same session `pg_current_wal_flush_lsn()` and the named standbys' `flush_lsn`. It acknowledges once one standby is at or past that position.
- A1 has proven `synchronous_commit` is `on`, so the commit was flushed locally first (ADR-0045 cites `xact.c:1506`).
- **Healthy posture, one writer:** the first read passes, because `pg_stat_replication` shows the same position `SyncRep` released on.
- **Healthy posture, concurrent writers:** the sampled flush position includes other sessions' waiting commits, so acknowledgement can also wait for those. That is conservative and bounded, but slower.
- The wait is `STO-7`'s standby wait: no server-side timeout, keepalives and `OPS-21` still apply, and the COMMIT's connection is retained.
- A failed read or a failed session is a lost reply (`OPS-49`). The connection is closed and never returned to the pool. The read-back runs on a new checked connection, and that check already waits for a standby to pass the local commit.

*M (evidence and alarm).*
- **Observation:** each period, on a fresh connection, the monitor reads:
  - `SHOW synchronous_standby_names`;
  - `pg_file_settings`, which shows edits not yet reloaded;
  - `pg_stat_replication.sync_state = 'quorum'` for each named standby.
  
  *Unverified:* whether this view can lag the checkpointer-updated flag that actually gates waiting.
- **Bound:** the window runs from the reload taking effect to the monitor's record being durable outside the primary. It is at most the period plus the query timeout. An unreadable posture counts as unverified from the last verified read.
- **Record:** kept in the failover controller's durable state. It is the evidence source for `STO-54`'s "after the primary committed without one of them". Components do not read it, because under A1+A2 refusing adds no safety.
- **Resumption:**
  1. Restore the list, reload, and verify on a fresh connection.
  2. Wait until a named standby passes the primary's flush position sampled after that verification. Every commit made during the drift is then on a standby.
  3. The record closes the interval.

*Trust boundary:* A1 and A2 trust only PostgreSQL's reports to provisiond's own sessions. M and its record are trusted as part of the deployment.

*Strongest races.*
- **A1:** none inside a transaction. Sessions other than provisiond's are unprotected.
- **A2:** with the list intact, a waiting commit "still show[s] as running", so other sessions cannot see it. With the list emptied, local commits are visible before replication.
  - Actions taken on a read alone are therefore exposed for the async lag: `OPS-32`'s image deletion, the `pv-v4gp` class.
  - Later writes confirm the prefix, and deposits have their own check.
- **M:** the whole window before detection. M prevents nothing.

**(d) Clauses.** All are *behaviour changed*.

1. In `STO-7`, after the new-connection paragraph:

   > **A transaction runs on the backend its check passed** (*pv-c7vg*): the component records the identity of the backend whose check passed — `pg_backend_pid()` and its `backend_start` — and every later transaction on that connection reads that identity and `synchronous_commit` before it sends COMMIT or acts outside the store on anything it read. A different identity, or `synchronous_commit` not `on`, rolls the transaction back, closes the connection, and the process logs loudly and exits non-zero; it is evidence of a topology `STO-55` forbids, not a mode it serves.
   > **A commit is acknowledged once a standby reports it**: after COMMIT returns, the component reads on the same session the flush position the primary reports and the named standbys' reported flush positions; the commit is acknowledged only when one of them is at or past it. Until then it is a standby wait (above); a read that errors or a session that fails first is a lost reply (`OPS-49`), and the connection is closed, not returned to the pool, so the read-back runs on a new connection under the check above.

2. In `STO-7`, replace "a lost reply is only ever a dead transport (`OPS-49`), or a commit returned with PostgreSQL's replication warning" with "…, a commit returned with PostgreSQL's replication warning, or a commit whose standby confirmation failed". `OPS-49`'s "the only lost reply is a dead transport, or a commit returned with PostgreSQL's replication warning (`STO-7`)" gets the same third case.

3. In `OVR-18`, add a condition alarmed on the same model:

   > the replication posture `STO-7` requires not verified within the posture-check period, or unreadable

4. In `STO-54`, after "after the primary committed without one of them", add:

   > — which the deployment establishes from its posture record kept outside the primary; an interval that record does not show verified counts as one

5. New `OVR-19` row: Replication-posture check period | `OVR-18`, `STO-7` | duration | no, the deployment's monitor.

6. A new CNF item (`STO-7`, `OVR-18`), with one negative control per run:
   - **Drift on a retained connection:** stop both standbys, empty the list, reload, and write. Assert:
     - no `api` success and no engine step after the write;
     - no cancel or terminate;
     - the alarm fires within the period;
     - both writes are acknowledged once one standby starts.
   - **Already-sent COMMIT:** a COMMIT waiting in `SyncRep` when the list is emptied is not acknowledged until a standby reports it.
   - **Unsafe before first use:** the list is already empty at startup. Same assertions.
   - **Healthy, unchanged settings:** with a single writer, one confirmation read and no added wait. With concurrent writers, every commit is acknowledged and none becomes a lost reply.
   - **One standby legitimately unavailable:** writes are acknowledged through the other, and only the standby alarm fires.
   - **Observer failure:** withholding the monitor's results raises the alarm. Withholding the confirmation read produces a lost reply.
   - **Pooler backend reassignment:** route new connections through a transaction-mode pooler and, after they pass their checks, restart the primary in place. Assert no COMMIT on an unbound backend, plus closure, exit and alarm.

**What conformance can prove:** the component's gating and the alarm. **What only deployment controls establish:** who can edit and reload configuration, sessions other than provisiond's, and retention of the posture record.

**(e) Collateral.** No checked verdict flips.
- CNF-296's `SyncRep` waits, its one-standby success and its fresh-connection setting all stay reachable.
- CNF-365's topology inspection stays.
- No Lean module models replication; the only mention is prose at `Claim.lean:321`.
- ADR-0045's "nothing in provisiond sees it" becomes history.

**(f) Owner costs.**
- A2 adds a round trip per write commit, plus a wait for interim WAL under concurrency.
- A1 adds one pipelined read per transaction.
- Exiting on a mismatch turns a forbidden pooler into an outage. The alternative is to alarm and close without exiting.
- The monitor needs a connection slot and a period.
- Clause 4 has no discharge. Without one, any unverified interval makes every later promotion of that primary a restore. A verified catch-up could discharge it, and that is sound by the prefix argument, but it is the owner's choice and I do not propose it here.

## Q2 — pv-3jw6

**(a) Pick: U**, with three conditions:
- `restore_instant` keeps its existing meaning: the time of the restore event itself.
- The surviving-history boundary goes in a new field.
- Only a bounded result is permitted. With no evidence, no record is written and nothing starts, which is E's hold.

**(b) Example and strongest reason.**
- s2 is unreachable, and the operator promotes s1 as a restore.
- s1's `pg_last_xact_replay_timestamp()` reads 10:00:03.2 on the old primary's clock. The allowance is 1 s, and the record commits at 10:20:00.
- The published window is [10:00:02.2, 10:20:01].

Strongest reason: the formal home already fixes `restore_instant` as the event's clock time.
- `RestoreTrace` says "`now` is the restore instant", and sets `restoreInstant := t.now`.
- `step_three_writes_grace` says "whatever the restore instant `w.now` is".
- `pv-gip.12` reads it the same way.

Candidate E puts a history boundary into that same field.

**(c) Evidence.**
- **Lower end:**
  - The docs describe the timestamp as "the time at which the commit or abort WAL record for that transaction was generated on the primary", and say it "will remain static" after recovery.
  - Alternatively, the same record can be read from retained WAL up to the timeline switch point.
  - It is on the old primary's clock and is not in WAL order, so it is only a lower bound after an allowance, never "the lost instant".
- **Upper end:** `restore_instant` plus the allowance, because the two clocks differ. ADR-0047 stops every component before the restore begins, so no component commit on the old history can follow it.
- **Interrupted procedure:** the docs say "When the server has been started normally without recovery, the function returns `NULL`". So the value must be captured into the record before anything starts.
- **Missing evidence:** an idle standby that replayed nothing also returns NULL, so this case is ordinary.
  - Fall back to the WAL.
  - Failing that, hold until an operator supplies a verifiable earlier instant (for example the base backup's START TIME) or restores a backup whose instant is known.
  - The cost is small, because these promotions are already operator-only.

**(d) Clauses.**

1. In `STO-54` step (1), replace "the lost window `T − Δ` is stated as a number and published to the operator" with (*behaviour changed*):

   > the lost window is published to the operator as two instants: from `T − Δ` — the commit or abort time the restored or promoted store reports for the last transaction it replayed from the history it continues (PostgreSQL's `pg_last_xact_replay_timestamp()`, read before that store restarts or serves anything, or that record read from the retained WAL up to its timeline's switch point), less the stated clock allowance (`OVR-19`) — to the record's restore instant, the transaction time of the transaction that commits `STO-56`'s record, plus that allowance. Both are read from the record and never re-computed. Where no such transaction is known, no record is written and neither component starts until an operator supplies a verifiable earlier instant or chooses a backup whose instant is known; the restart instant is never used.

2. In `STO-56`, add the column `lost_window_starts_at`, not null and written with the row, its meaning owned by `STO-54` (*behaviour changed*, schema).
3. In `STO-56`, add "`restore_instant` is the transaction time of the row's insert (`STO-54`)" (*behaviour changed*: the prose never defined it, although the Lean models it this way).
4. New `OVR-19` row: Restore clock allowance | `STO-54` | duration | no, a human row.
5. In CNF-295, "names `T − Δ`" becomes "names `T − Δ`, the record's restore instant as the window's end" (*behaviour changed*).
6. CNF-365 gains (*behaviour changed*):

   > Promote, as an operator's restore, the standby with the unavailable report; assert `lost_window_starts_at` is its last replayed transaction's time less the allowance; repeat with that store restarted and its switch segment removed before capture: no record, no component start.

**Traces.**
- **Known boundary:** the example in (b).
- **Missing boundary:** the hold.
- **Interrupted procedure:** the successor reads both instants from the record.
- **Ordinary backup restore:** the same definition, applied at the recovery target.
- **Grace:** stays anchored at step (3).
- **Equal positions (Q4):** a restart, so no record is written.

**(e) Collateral.** Nothing flips. Lean's `Record` does not model the new column; that is a coverage note. E as sketched would need `RestoreTrace.store`, `afterCrash` and the module doc restated.

**(f) Owner cost.** A schema column, an allowance parameter, and an operator hold when evidence is missing.

## Q3 — pv-oehp

**(a) Pick: B**, with PostgreSQL's per-role `CONNECTION LIMIT` as B's accounting authority.

**(b) Example and strongest reason.**
- While replication is healthy, dead transports leave orphaned backends whose COMMITs have not flushed yet. r63h trace 1 says "only the primary's connection slots bound it".
- A freeze then strands them.
- With the `api` role's limit set to its pools at maximum overlap plus 6, the server refuses new connections after the sixth orphan, and the operator's slots are untouched.

Strongest reason: all the accounting lives in the server, so no external state can be lost.

**(c) Mechanics, against B's checklist.**
- **Identity and unknown case:** each backend is its own reservation, and every backend of the role counts.
- **Race:** the docs say "if two new sessions start at about the same time when just one connection 'slot' remains for the role, it is possible that both will fail", so errors fall toward refusal. *Unverified:* that it never over-admits, and whether a refused attempt briefly holds a non-reserved slot.
- **Lost state:** none.
- **Release:** the backend exits after the stall ends. Server keepalives end idle orphans.
- **Superusers:** "the limit is never enforced for superusers", so component roles must not be superusers.
- **Exhaustion:** "too many connections for role" is `STO-7`'s failed connection attempt, which becomes `STO-55`'s `overloaded`. The engine restarts under `OVR-18`'s liveness alarm.
- **Operator and monitor access:** `reserved_connections`/`pg_use_reserved_connections` (*unverified*) and `superuser_reserved_connections`.
- **Preserved:** nothing cancels a waiter, so stop-on-time and the `SyncRep` prohibition stand.

**Capacity safety vs. availability.**
- **Capacity safety** holds given non-superuser roles and the unverified race above: Σ role limits + migrator + reserved slots ≤ `max_connections`.
- **Availability** is narrower: a role can open new connections only while its orphans are fewer than its allowance. Live connections, reads and operator access remain.

**(d) Clauses.** All are *behaviour changed*.

1. In `STO-55`, replace "During a stall, … (`pv-oehp`)" with:

   > Backends an exited process or a dead transport leaves hold slots outside the pools; PostgreSQL's per-role connection limit bounds them. Each component class connects as its own login role, none a superuser, whose `CONNECTION LIMIT` is its pools at the rollout's maximum overlap plus a stated residual allowance (`OVR-19`); those limits, the migrator's, and the reserved slots for the operator and the posture monitor fit inside `max_connections`. A connection refused for its role's limit is a failed connection attempt (`STO-7`); nothing cancels or terminates a backend to make room.

2. `OVR-18`: alarm a role that is at its limit.
3. `OVR-19`: add "Residual allowance per component role" and "Server TCP keepalives". Restate the budget row as the sum of role limits plus reserved slots.
4. A CNF repeated-stall drill:
   - **Setup:** two `api` replicas and the engine, with an `api` allowance of 2.
   - **Steps:**
     1. With replication healthy, drop transports during COMMITs held before their local flush by a deferred constraint trigger calling `pg_sleep`. This reaches trace 1's orphans instead of bypassing them.
     2. Freeze both standbys.
     3. Kill a replica and the engine with waits outstanding.
     4. Start a rollout replica.
   - **Assertions:**
     - every sample shows the role's backends ≤ its limit;
     - a refusal reads "too many connections for role";
     - the operator can connect;
     - nothing is cancelled or terminated;
     - withholding the monitor's read raises the alarm and leaves enforcement intact;
     - restarting the monitor or the components changes nothing;
     - releasing one standby clears the orphans, and new connections succeed.

**(e) Collateral.** None. CNF-296's "holds no more of that replica's backends than its pool" is unaffected.

**(f) Owner costs.**
- Allowance slots, or smaller pools.
- No service once the allowance is used up.
- A separate role per component class.
- If the lock connection shares the engine role, engine orphans can block a successor engine's lock.

## Q4 — pv-1i3n

**(a) Pick: T**, with the collateral below landing in the same edit.

**(b) Example and strongest reason.** On an idle system both standbys report 0/5000060 on timeline 1. Their prefixes are identical, so either one "holds them all", and bumping every credential protects nothing.

**(c) Unchanged:** stopping and fencing, the per-timeline flushed-end report (H-e), continuation of an open record, operator-only restores, and "writes continue once the other standby streams".

**(d) Clauses.**
- T's two `STO-54` replacements, as printed (*behaviour changed*).
- "so that one holds them all" becomes "so the promoted one holds them all" (*behaviour unchanged*).
- The STO-5 pointer at `:96` becomes "Promoting a standby `STO-54`'s report puts at least as far ahead as the other is a restart" (*behaviour unchanged*). Left alone, it implies a tie is a restore.
- CNF-365's title, and "promote the standby `STO-54`'s report puts further ahead" at `:1108`, become "a standby … at least as far ahead as the other" (*behaviour changed*).
- The doc comment at `Restore.lean:30` (*behaviour unchanged*).
- T's fixture as printed (*behaviour changed*). If Q1's M is adopted, also: "Repeat with equal reports after the posture record shows an unverified interval on the old primary: assert restore classification" (*behaviour changed*).

**(e) Collateral.** CNF-365's first fixture cannot run as written when the reports tie, and a tie is likely after killing the primary with healthy replication. T makes it reachable. No Lean theorem encodes the comparison.

**(f) Owner choice.** None beyond the tie policy itself.

## Does this document contradict itself?

1. **Q2's E conflates two instants.** The Lean declarations quoted above and `pv-gip.12` make `restore_instant` the event's clock time, and E stores a history boundary in it. Q2's premise is unchanged, because the gap in `T − Δ` for a promoted store still stands. Only E is affected.
2. **Q3's framing.** "A replacement process can open another pool" during a stall clashes with `STO-7`: "A check that errors, cannot see a standby's position, or has not passed is a failed connection attempt: the connection is closed unused". The unbounded class comes from trace 1's orphans, created before the freeze. The premise is unchanged.
3. **Q4's T is incomplete.** Left alone, the STO-5 pointer and CNF-365 contradict it. That is a defect in the sketch, not in the premise.
4. **Q1's pooler framing.** The brief has the deployment "insert a pooler" while a checked connection "remain[s] open", but a pooler cannot be interposed into an established direct connection. `STO-55` places the hazard on connections opened through the pooler: "a crash of the primary ends its backends but not the component's connection to the pooler, so `STO-7`'s new-connection check would never run". The premise is unchanged.
5. **Within my own proposals:** no conflict.
   - A2 still lets local commits happen, so `STO-54`'s classification stays conservative.
   - Q1's monitor takes a reserved slot inside Q3's budget.
   - Q2's hold never touches Q4's restart path.
   - Q1's mismatch exit happens before COMMIT, so it leaves no waiting backends.

## Requested counterarguments (not my vote)

- **Q1 — requested counterargument, not my vote:** every write pays a round trip to survive a misconfiguration the deployment owns, and a failed statistics read turns a healthy commit into a lost reply. ADR-0045 already refused per-transaction checks. Strict configuration management (Patroni-style strict mode, `ALTER SYSTEM` reserved to superusers) plus D's alarm is the proportionate answer.
- **Q2 — requested counterargument, not my vote:** restore-class promotions are rare and run by an operator, who can state a number. A column, an allowance and a hold are machinery for a report a human already reads.
- **Q3 — requested counterargument, not my vote:** allowance slots sit idle in normal operation, and orphans can starve a successor engine. ADR-0045 accepted this limit, and shutting the primary down clears every orphan legitimately. That is Z.
- **Q4 — requested counterargument, not my vote:** a tie is what a broken measurement looks like (H-e: both standbys reported 0/4000000 whatever they held). Keeping R costs credentials only on idle failovers.
