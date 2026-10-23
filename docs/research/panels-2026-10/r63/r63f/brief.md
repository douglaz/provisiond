# Panel brief r63f: S2 consensus and S3 vote (pv-s4m, synchronous replication). 2026-10-23

You are one of four independent reviewers. Your working directory is a fresh throwaway clone of `provisiond-spec`
at `dc5d40d`. Read `AGENTS.md` first. You MAY edit tracked files in the clone to test a claim. Write nothing outside
it. Never commit, push, call a provider API, or run `br`. **Run no gate and no `lake`.** Keep `TMPDIR` as set. Do
not delegate, background or wait on anything. Have a draft by minute 12.

Web lookups are allowed only for these, and you must quote what you use:
- `postgresql.org/docs`;
- `github.com/postgres/postgres` and `raw.githubusercontent.com/postgres/postgres`;
- `patroni.readthedocs.io`;
- `github.com/patroni/patroni` and `raw.githubusercontent.com/patroni/patroni`.

The manager's copies of the sources (PostgreSQL `REL_18_STABLE`, docs 18, Patroni `master`) are in
`/var/tmp/provisiond-panel-r63f/src/`, read-only. `18-xact.c`, `18-syncrep.c` and `postgres18.c` are the 18 copies.

The owner sent two questions back:
- **S2:** "Call the panel again to try to find consensus".
- **S3:** "Analyze this better".

This round tries for consensus on S2 and votes on S3. Nothing after it reads text: a form that doesn't carry here
goes to the owner as a split.

## Settled (not for re-vote)

- The owner's decisions, verbatim:
  - Q1: "I think we should just suppose synchronous replication".
  - S1: "Three servers (Recommended)".
  - Q2 is form F', and Q3 is one Run.
- From r63e, these stand: CORE (except C9's `[S2]` sentence and C13's sentence), RS (unless S3-B below replaces
  its gate), OC, WR, RL, and N3. The merged
  three-server text is `/var/tmp/provisiond-panel-r63e/forms-final.md`. Read its STO-7 and STO-54 sections.
  - One merge point to check: N3-2 replaced the first half of STO-54's second sentence. The manager kept OC's
    clause ("The engine comes up on it under `STO-5`'s restart rule, unless a restore record …") as its own
    sentence.
  - If any merge in that file changes a voted meaning, report it under Brief errors.
- In both S2 forms, all four r63e readers agreed on these points of substance:
  - A commit's wait for a standby is outside the store-call deadline and outside `OPS-49`'s Store-retry bound.
  - DL-3 stands: `OVR-19` gains "| Pooled-connection keepalives | `STO-7` | durations | yes |".

## Facts (the manager verified each against the source)

- **FA1** (r63d): `statement_timeout` and `transaction_timeout` are disabled before a commit's wait.
- **FA2** (r63d): a backend waiting in `SyncRep` never notices that its client has gone. It keeps its locks and its
  connection slot. 18-xact.c:1563-1564: "we have marked clog, but still show as running in the procarray and
  continue to hold locks".
- **FL1, `lock_timeout` vs `statement_timeout`.** A statement blocked behind a waiter's lock can be cut by either.
  - runtime-config-client, on `lock_timeout`: "Abort any statement that waits longer than the specified amount of
    time while attempting to acquire a lock on a table, index, row, or other database object."
  - And: "Note that if statement_timeout is nonzero, it is rather pointless to set lock_timeout to the same or larger
    value, since the statement timeout would always trigger first."
  - `OPS-49` makes both a store error: `03:1839` "'Too slow' is `statement_timeout`", and `03:1847` "A
    `lock_timeout` is a store error for this purpose".
- **FL2, the migrator is another lock holder.**
  - `STO-13` (`05:1398-1401`): "DDL that takes `ACCESS EXCLUSIVE` MUST run under a stated `lock_timeout` and retry
    count (`OVR-19`) … so that the time `api` queues behind a migration is bounded — the table lock still queues
    every later statement on that table behind it while held."
  - explicit-locking, on `ACCESS EXCLUSIVE`: "Conflicts with locks of all modes (ACCESS SHARE, …)". And: "Once
    acquired, a lock is normally held until the end of the transaction."
  - So a DDL whose commit waits on the standbys holds `ACCESS EXCLUSIVE` the whole time (FA2). Every statement on
    that table, reads included, queues behind it.
- **FL3, another role's wait event is hidden.** pgstatfuncs.c:37 defines `HAS_PGSTAT_PERMISSIONS(role)` as
  `has_privs_of_role(GetUserId(), ROLE_PG_READ_ALL_STATS) || has_privs_of_role(GetUserId(), role)`. Without it,
  :651-654 set "<insufficient privilege>" and null `wait_event_type` and `wait_event` (`nulls[6]`, `nulls[7]`).
  The set doesn't say which database roles the engine, `api` and the migrator use.
- **FL4, a stock supervisor can be told to wait.** `man systemd.service`, on `TimeoutStopSec=`: "Pass "infinity" to
  disable the timeout logic." And: "If a service of Type=notify/Type=notify-reload sends "EXTEND_TIMEOUT_USEC=...",
  this may cause the stop time to be extended beyond TimeoutStopSec=. … the service manager will allow the service
  to continue to stop, provided the service repeats "EXTEND_TIMEOUT_USEC=..." within the interval specified".
  So under systemd, an engine that sees its own commit waiting can extend its stop, and only for that long.
  r63e's owner question said a stock supervisor "can't see the wait". For systemd, that is wrong. Other
  supervisors were not checked.

### Every time limit and kill rule in the set, checked against a waiting commit

| Rule | Does it cut a commit waiting on the standbys? | Can it end a write blocked behind such a commit? |
|---|---|---|
| `statement_timeout`, `transaction_timeout` (`STO-7` `05:136-138`, `00:408`) | No (FA1) | `statement_timeout`: yes, as a store error (FL1) |
| `idle_in_transaction_session_timeout` (`05:168`) | No. postgres.c starts its timer only when it sends ReadyForQuery inside a transaction block (:4576, :4590) and disables it when input arrives (:4714). The waiter is executing its commit | No: a blocked statement is active, not idle |
| `lock_timeout` (`05:137`, `OPS-49` `03:1847`) | No: the waiter holds locks, it doesn't wait for them | **Yes** (S2, locked rows) |
| Store-call client deadline (`05:140`, `03:1839`) | Exempt in both forms | No: it is never shorter than the server's timeouts |
| Store-retry bound (`OPS-49` `03:1828-1830`, `00:401`) | Exempt in both forms (DL-2) | **Yes**, through the two rows above |
| Stop-record bound and supervisor kill (`OPS-21` `03:1738`, `:1763-1773`, `00:402`) | **Yes** today (S2, stopping) | Yes: measured from the stop |
| Startup-lock wait bound (`OPS-47`, `00:399`) | No. The lock sits "on a connection outside the pool" (`OPS-47`) and is "released when its session ends" (`STO-51`). No write runs on that connection | No |
| Pool checkout bound (`STO-55` `05:178-181`) | No | No: refused `overloaded` "before any transaction begins" |
| Migration `lock_timeout` and retry count (`STO-13` `05:1398`, `00:407`) | No (the migrator's DDL commit waits like any other) | **Yes**, for the migrator. And a waiting DDL blocks every other statement on its table (FL2) |
| Provider-call deadline (`00:421`) | No: no transaction is held across a provider call (`STO-55` `05:161-162`) | No |
| `OVR-18` alarms, `/healthz` (`00:334`, `04:7`) | No: they alarm, and kill nothing (r63e FE2) | No |

## S2: while both standbys are unreachable, may the engine still quit?

**The story.** Both standbys stop answering at 10:00, and every write waits. At 10:05 one of two things happens.
Either a deploy stops the engine, or an engine write keeps timing out on a row that a frozen write has locked, and
the Store-retry bound runs out. Under A the engine quits on time, and the frozen writes it leaves behind keep their
connections and locks until a standby returns. Under B the engine doesn't quit: the stop hangs until a standby
returns, and lock time-outs during the freeze don't use up the bound.

r63e split two ways:
- **Stopping:** A, astra and sol; B, fable and opus.
- **Locked rows:** A, astra and sol; B, opus. Fable didn't address it.
- **Compromises:** none. No r63e reader proposed one. The two crossings below exist because the questions are
  separable, not because a reader proposed them.

### The strongest case for each side, in the r63e readers' own words

**A (astra), verbatim:** "C9's "without the engine exiting" and C13's "DL answers its crash loop" fail under
contention: transaction A holds `LDG-35` while waiting for replication; engine transaction B repeatedly times out
acquiring that lock. `03-operation-lifecycle.md:1847` says "A `lock_timeout` is a store error"; `:1829` requires
"the engine MUST exit non-zero". DL excludes A's standby wait, not B's lock wait." And on DL: "This preserves bounded
shutdown but does not solve abandoned-backend accumulation or the contention trace above".

**A (sol), verbatim:** "an `api` extension stalls in `SyncRep` holding the tenant lock; engine metering repeatedly
encounters `lock_timeout`. … That exits the process hosting any other stalled engine writer." And: "`OPS-21` remains
incompatible with the categorical deadline exemption. … these exits can still leave waiting backends outside pools,
whereas `05-persistence.md:191` requires allocations to "fit inside `max_connections`"."

**B (opus), verbatim:** "DL's "Why" says `ADR-0023`'s crash loop no longer follows. S''' misses two spans that still
produce it". On `OPS-49`: "A backend in `SyncRep` keeps its locks (FA2), and so does one orphaned by any exit during a
stall. An engine write for that tenant, or the successor's startup pass, then times out on the lock, exhausts the
bound and exits. That is the loop again."

**B (fable), verbatim:** "A stop during a stall exits the engine mid-wait, which DL-1's "no client-side deadline cuts
it short" denies." Fable's replacement text: "together, but not a commit's wait for the standby (`STO-7`), during
which the record is neither abandoned nor the engine killed".

### What the original time-outs protect, in the set's own words

Answer P below for each of these.

- **P1, the store-call deadline.** `ADR-0022`: "the server decides every statement's fate before the client does,
  and the only lost reply is a dead transport."
- **P2, the Store-retry bound.**
  - `OPS-49`: "the engine MUST exit non-zero into its supervisor, where `OVR-18`'s alarm is watching".
  - "It is a money parameter: on exhaustion the outcome in hand is thrown away and `OPS-15` classifies the row as
    interrupted".
  - On locks: "a lock timeout outside any bound is an unalarmed loop on a held primitive."
- **P3, the Stop-record bound and the supervisor's wait.** `ADR-0044`: "That write needs protection from the
  cancellation being recorded, and a duration independent of store-error accounting: serialization repeats could
  otherwise continue indefinitely. A supervisor that kills earlier than that duration defeats the opportunity to
  record."
- **P4, the outage `ADR-0023` rejected.** `ADR-0023:158-170`: "the retry re-commits and re-stalls until the bound
  exhausts, the engine exits, and the successor's startup pass — which writes — stalls the same way. A crash loop
  across the whole safety layer".
- **New since then:** C6 makes `OVR-18` alarm a stalled standby directly: "and a stalled synchronous standby, on
  which every write waits (`STO-7`)."

### The forms, in full. Pick one per sub-question; every combination's text is written below

**STOP-A, stay stoppable** (sol's and astra's texts):
- `05:141-143` gains: "A standby wait has no server-side timeout and is excluded from that call's store-call and
  Store-retry deadlines; a dead transport during it is found by the connection's TCP keepalives (`OVR-19`).
  `OPS-21`'s stop bounds still apply."
- `03:1830` (`OPS-49`): "The bound covers connection, execution, commit, read-back and backoff together" becomes
  "… together, but not a commit's wait for the standby (`STO-7`),".
- `OPS-21` is unchanged.
- Known cost (sol): every exit during a stall leaves waiting backends outside the pools. In a long stall,
  `05:191`'s "fit inside `max_connections`" stops holding.

**STOP-B, wait it out** (DL-1 and DL-2 as all four read them in r63e, and opus's `OPS-21` text):
- `05:143` gains, after "(`OPS-49`).": "A commit's wait for the standby is the exception (*added 2026-10-23,
  `ADR-0045`*): it has no server-side timeout, and no client-side deadline cuts it short. A backend waiting there
  never notices that its client has gone, and would keep its locks and its connection slot outside every pool
  (`STO-55`). So the wait ends when the standby confirms or the primary shuts down, and a dead transport during it
  is found by the connection's TCP keepalives (`OVR-19`)."
- `03:1830`: "… together, but not a commit's wait for the standby, which no client-side deadline cuts short
  (`STO-7`),".
- `OPS-21`, at `03:1763-1773`:
  - The first sentence becomes "The Stop-record bound is measured from the stop, counts every repeat including
    serialization failures, and never resets; time a commit spends waiting for a standby (`STO-7`) does not count
    toward it." This is the manager's text for r63e's Run review point, and it is new.
  - "covers connection, execution, commit, read-back and backoff together" gains ", but not a commit's wait for the
    standby (`STO-7`)".
  - The supervisor sentence becomes "The deployment's supervisor MUST wait at least the Stop-record bound, and any
    commit's wait for the standby, after a stop before it kills the engine."
  - `00:402`'s row quotes the two amended sentences.
- Known cost: a stop during a stall hangs until a standby returns, and the supervisor's kill must wait with it. Under
  systemd the engine can extend its own stop time (FL4). Other supervisors were not checked.

**LOCK-A, contention may still exit:** `OPS-49`'s `lock_timeout` rule is unchanged.
- C9's `[S2]`: "Assert an engine write and an `api` write each wait in `SyncRep`,". After the alarm: "Exercise a
  contending engine write and assert `OPS-49`'s bounded retry and exit."
- C13's sentence (astra): "DL removes deadline-driven abandonment during the standby wait; lock-contention
  exhaustion can still restart the engine."

**LOCK-B, contention behind a waiter doesn't count:** `03:1846-1850` (`OPS-49`) gains opus's text: "A `lock_timeout`
while a primary backend waits with wait event `SyncRep` (`STO-7`) does not consume the bound; `OVR-18`'s
stalled-standby alarm is that loop's alarm."
- C9's `[S2]`: "Assert an engine write and an `api` write each block without the engine exiting,".
- C13's sentence: "and DL answers its crash loop."
- Check this against FL1 (a `statement_timeout` also ends a blocked statement), FL2 (the migrator) and FL3
  (visibility). Give replacement text if this text needs it.

## S3: PostgreSQL's self-restart after a backend crash

Read `/var/tmp/provisiond-panel-r63f/s3-analysis.md` whole. Check its facts H1-H4 and section 3. Report any wrong
one under Brief errors.

**The options.** Each is written in the three-server form.

- **S3-A, turn the self-restart off** (opus, r63e).
  - `STO-7` gains, before RS: "The deployment turns `restart_after_crash` off, so a backend crash stops the
    primary." RS is unchanged.
  - `CNF-365` gains: "Then, with both standbys stalled while a write waits, crash a single backend, and assert no
    component reads the recovered commit before a standby has it."
- **S3-B, check each connection; this replaces RS's deployment gate** (manager's text, new). RS's sentence becomes:
  "A component MUST NOT use a new store connection until one of the standbys `OVR-19` names has flushed the
  primary's WAL up to the flush position the primary reports on that connection: a commit that was waiting for a
  standby when the primary stopped, or reinitialized after a backend crash, is "marked fully committed once the
  primary database recovers", whether or not a standby has it, and a backend crash ends every connection."
  - `CNF-365`'s last check becomes: "Then, with both standbys stalled while a write waits, crash a single backend,
    and separately restart the primary in place; assert each time that no component uses a connection to it until
    a standby has caught up."
  - STO-54's RL clause "served a component before it had caught up" then refers to this sentence.
  - **Fact FP, the pooler.** `STO-55` (`05:195-197`): "A pooler in transaction mode MAY front the pools only on two
    conditions", and "a later transaction may run on a different backend". Behind such a pooler, a crash kills the
    backends, but a component's connection to the pooler can stay open, so the component sees no new connection.
    S3-B therefore also gains: "A transaction-mode pooler (`STO-55`) is then allowed only if it runs the same check
    on each new server connection before it uses that connection." The alternatives are to forbid the pooler, or
    to pick S3-AB. With `off`, a crash stops the primary, and RS's deployment gate then holds every connection at
    the restart, which a pooler can't hide.
- **S3-AB, both:** S3-A's sentence, with RS kept as it is, plus S3-B's sentence without its pooler clause.
- **S3-P, rely on clusterware:** no text.
- **S3-N, leave it:** no text. `ADR-0045` records the window as accepted.

## Answer

**S2**, for STOP and for LOCK separately:
- Your **PICK**, A or B.
- **OTHER:** ACCEPTABLE, or NOT ACCEPTABLE with the trace that makes the other text break a quoted MUST or lose
  money.
- **MOVE:** one line. What fact or trace would change your pick?
- **P:** for each of P1-P4, under your pick, is the protection KEPT, MOVED (say to what), or LOST?
- Replacement text only where a form, as written, breaks something you quote.

**S3:**
- Your **PICK**: S3-A, S3-B, S3-AB, S3-P or S3-N.
- Whether your pick closes the trace in s3-analysis.md §1, and the one cost you accept.
- OTHER: for each option you didn't pick, ACCEPTABLE or NOT ACCEPTABLE, with the trace.

**Rules for every answer:**
- A vote counts only if it names the normative content (a MUST/SHOULD quoted with file:line) or the trace it rests
  on. Wording preferences aren't counted.
- **Ripple:** list only the spans the forms contradict and miss, quoted with file:line.
- List wrong facts under **Brief errors**, with the quote that shows each one. That includes the facts above, the
  table, s3-analysis.md and the forms-final.md merge.

**Total: at most 600 words.**
