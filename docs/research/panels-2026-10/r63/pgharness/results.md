# PostgreSQL 18 fault-injection harness: results (pv-s4m, panel C). 2026-10-23

PostgreSQL 18.6 (nixpkgs `postgresql_18`, /nix/store/kxjjxz8j…-postgresql-18.6). Three local instances: primary `p`
(127.0.0.1:55432) and standbys `s1` (:55433) and `s2` (:55434), streaming over a 0700 unix socket dir. On p:
`synchronous_standby_names = 'ANY 1 (s1, s2)'`, `synchronous_commit = on`, `restart_after_crash = on`,
`max_connections = 20`, `superuser_reserved_connections = 3`. Auth: local trust, TCP scram. Each instance ran as a
capped user unit (`pgh-*`, MemoryMax=1G, MemorySwapMax=0, OOMPolicy=continue). Each experiment ran in a capped
scope (MemoryMax=4G, MemorySwapMax=0) and started from a fresh `setup` (lib.sh). TMPDIR and all data were under
/var/tmp/provisiond-pgharness. "Freeze" means both standbys stopped with `pg_ctl stop -m fast`. Every instance
was stopped and every data directory deleted at the end (0 `pgh-*` units, 0 postgres processes from this store
path). Scripts: lib.sh and exp-{a,b,c,d,d2,e,f}.sh. The verbatim transcripts are below, one per script.

## Summary

| | Claim | Result | Decisive output |
|---|---|---|---|
| a | A commit waiting in SyncRep becomes visible after `kill -9` of an unrelated backend (`restart_after_crash = on`), with no standby holding it | **DEMONSTRATED** | The waiter got "terminating connection because of crash of another server process". The postmaster PID and `pg_postmaster_start_time()` were unchanged. A new connection then read `1\|D` with no standby connected. A flush-position check on that connection found 0 named standbys at or past T, and passed only once s1 returned, which then had `1\|D` |
| b | A commit becomes visible after its wait is cancelled; `statement_timeout`/`transaction_timeout` don't end the wait | **DEMONSTRATED** | It was still in `SyncRep` after 6 s under a 2 s/3 s session timeout. Then: "WARNING: canceling wait for synchronous replication due to user request / DETAIL: The transaction has already committed locally, but might not have been replicated to the standby. / INSERT 0 1", with the row visible and 0 standbys. `pg_terminate_backend` behaved the same way ("terminating connection due to administrator command") |
| c | An abandoned client leaves its backend in SyncRep, holding a slot and its locks; abandonments pile up with no restart | **DEMONSTRATED** | After `kill -9` of the client, the backend stayed in `SyncRep`, and a duplicate insert got "canceling statement due to lock timeout". 17 abandonments led to "FATAL: remaining connection slots are reserved for roles with the SUPERUSER attribute", with the postmaster PID unchanged. When s1 returned, all 17 exited and committed. TCP with `client_connection_check_interval=1s` and 1 s keepalives: still `SyncRep` after 30 s |
| d | A barrier on the promoted store certifies nothing about a read on the old primary | **DEMONSTRATED** | The client read `D` on p. p was lost, s1 promoted, and s2 streaming from s1 (`quorum`). A barrier insert on s1 returned `INSERT 0 1`, acknowledged by s2. `row1_on_promoted_store = 0` |
| d2 | Same-transaction barrier: no acknowledgement without a standby; with one, the standby holds what was read | **DEMONSTRATED** | (i) The COMMIT blocked. On primary loss the client got "connection to server was lost" and no `COMMIT` line, although its SELECT had already printed `D`. (ii) When s1 returned, the client printed `COMMIT` and s1 had `D` |
| d2 edges | A read-only transaction doesn't wait; an empty `synchronous_standby_names` makes writes local | **DEMONSTRATED** | During a freeze, `begin; select …; commit;` printed `COMMIT`. After `synchronous_standby_names = ''` and a reload, `INSERT 0 1` returned with 0 standbys |
| e2 | LSNs from different timelines aren't comparable | **DEMONSTRATED** | The old p was restarted as a standby of s1 without `pg_rewind`. Its log: "new timeline 2 forked off current database system timeline 1 before current recovery point 0/47B2898". Its replay was `0/47B2898` on TL1, against s2's `0/4004658` on TL2. A "greatest LSN" rule ranks the old p ahead, yet it lacks s1's TL2 barrier |
| e | Promoting the lagging standby loses an acknowledged commit | **DEMONSTRATED** | `INSERT 0 1` returned (acknowledged by s1, s2 stopped). After p was lost: `row7_on_s1 = 1` and `row7_on_promoted_s2 = 0` |
| e report | What a restarted standby reports | **MEASURED** | With the primary dead, both standbys returned `pg_last_wal_receive_lsn() = 0/4000000` (the segment start), whatever they had flushed. Replay differed: s1 `0/40085F8`, s2 `0/4000000`. A report built on `receive_lsn` after a restart ranks them equal |
| f | Read-only WAL check | **DEMONSTRATED, with one liveness caveat** | See below |

**(f) details.**
- As `app`, `pg_stat_replication` shows pid, usesysid, usename and application_name, and every other column NULL.
- `app` can execute `pg_current_wal_insert_lsn()`, `pg_current_wal_flush_lsn()` and `pg_current_wal_lsn()`.
- `SHOW synchronous_commit` gives `on`, `SHOW synchronous_standby_names` gives `ANY 1 (s1, s2)`, and
  `SHOW restart_after_crash` gives `on`. All are readable by `app`.
- `app` can `SET synchronous_commit = local`, and `SET LOCAL synchronous_commit = on`.
- A SECURITY DEFINER function owned by a NOLOGIN role granted `pg_read_all_stats` gives `app` the standbys'
  `flush_lsn`.
- Both targets reached a standby's `flush_lsn` within about 10 ms on a busy and on an idle primary. On the idle
  primary, insert, flush and both standbys sat at the same LSN for 40 s.
- While frozen, a read-only check with a 3 s client timeout left **0** `SyncRep` backends. Three write-on-connect
  checks whose clients timed out left **3**.
- **Liveness caveat (source, not observed):** `pg_current_wal_insert_lsn()` returns `XLogBytePosToRecPtr`
  (xlog.c:9488). At a page boundary that points "to where the first xlog record on that page would go", past the
  page header. A standby's flush ends before that header. So on an idle primary whose last record ends exactly at a
  page boundary, an insert-position target is never reached until more WAL is written. The flush position
  (`XLogBytePosToEndRecPtr` semantics) has no such case.
- **Safety:** a flush target is safe because, with `synchronous_commit` never below `local`, a commit is flushed
  locally before it becomes visible. Under `off` it would not be.

## Transcripts

### exp-a.sh

```
## (a) crash-restart makes a waiting commit visible
# SETUP: p, s1, s2 up; s1:streaming:quorum s2:streaming:quorum; synchronous_standby_names=ANY 1 (s1, s2)
# stopped s1 (fast)
# stopped s2 (fast)
# FREEZE: both standbys stopped
$ [p postgres] show restart_after_crash
on
$ [p postgres] select pid, usename, wait_event, state, left(query,40) from pg_stat_activity where wait_event='SyncRep'
2350254|app|SyncRep|active|insert into t values (1,'D')
$ [p postgres] select count(*) as row1_visible_before from t where id=1
0
# postmaster pid before crash: 2349676; start time: 2026-10-23 05:34:34.475319+00
# kill -9 backend 2350281 (parent 2349676 = postmaster of p)
# postmaster pid after crash: 2349676; start time: 2026-10-23 05:34:34.475319+00
# waiting client's output (exit 2):
WARNING:  terminating connection because of crash of another server process
DETAIL:  The postmaster has commanded this server process to roll back the current transaction and exit, because another server process exited abnormally and possibly corrupted shared memory.
HINT:  In a moment you should be able to reconnect to the database and repeat your command.
server closed the connection unexpectedly
	This probably means the server terminated abnormally
	before or while processing the request.
connection to server was lost
$ [p postgres] select * from t where id=1
1|D
$ [p postgres] select application_name, state, flush_lsn from pg_stat_replication
# server log lines:
2026-10-23 05:34:34.519 UTC [2349676] LOG:  database system is ready to accept connections
2026-10-23 05:34:46.205 UTC [2349676] LOG:  client backend (PID 2350281) was terminated by signal 9: Killed
2026-10-23 05:34:46.207 UTC [2349676] LOG:  all server processes terminated; reinitializing
2026-10-23 05:34:47.116 UTC [2350307] LOG:  redo done at 0/40085C8 system usage: CPU: user: 0.00 s, system: 0.00 s, elapsed: 0.00 s
2026-10-23 05:34:47.243 UTC [2349676] LOG:  database system is ready to accept connections
# new connection: primary flush position T=0/4008668, insert=0/4012180
$ [p postgres] select count(*) as named_standbys_at_or_past_T from pg_stat_replication where application_name in ('s1','s2') and flush_lsn >= '0/4008668'
0
$ [p postgres] select application_name, state, flush_lsn, flush_lsn >= '0/4008668' as passed from pg_stat_replication
s1|streaming|0/4012000|t
$ [s1 postgres] select * from t where id=1
1|D
# teardown done
```

### exp-b.sh

```
## (b) cancelled wait
# SETUP: p, s1, s2 up; s1:streaming:quorum s2:streaming:quorum; synchronous_standby_names=ANY 1 (s1, s2)
# stopped s1 (fast)
# stopped s2 (fast)
# FREEZE: both standbys stopped
$ [p postgres] select pid, wait_event, state, round(extract(epoch from now()-query_start)) as secs_waiting, (select setting from pg_settings where name='statement_timeout') from pg_stat_activity where wait_event='SyncRep'
2354014|SyncRep|active|6|0
# waiter's session settings: statement_timeout=2s, transaction_timeout=3s (psql -c 'set ...')
$ [p postgres] select count(*) as row2_visible_before from t where id=2
0
$ [p postgres] select pg_cancel_backend(pid) from pg_stat_activity where wait_event='SyncRep'
t
# waiter's output after pg_cancel_backend (exit 0):
SET
SET
WARNING:  canceling wait for synchronous replication due to user request
DETAIL:  The transaction has already committed locally, but might not have been replicated to the standby.
INSERT 0 1
$ [p postgres] select * from t where id=2
2|B
$ [p postgres] select count(*) as standbys from pg_stat_replication
0
$ [p postgres] select pg_terminate_backend(pid) from pg_stat_activity where wait_event='SyncRep'
t
# waiter's output after pg_terminate_backend (exit 2):
WARNING:  canceling the wait for synchronous replication and terminating connection due to administrator command
DETAIL:  The transaction has already committed locally, but might not have been replicated to the standby.
server closed the connection unexpectedly
	This probably means the server terminated abnormally
	before or while processing the request.
connection to server was lost
$ [p postgres] select * from t where id=3
3|T
# teardown done
```

### exp-c.sh

```
## (c) abandoned clients
# SETUP: p, s1, s2 up; s1:streaming:quorum s2:streaming:quorum; synchronous_standby_names=ANY 1 (s1, s2)
# stopped s1 (fast)
# stopped s2 (fast)
# FREEZE: both standbys stopped
# postmaster pid 2355506; max_connections=20, superuser_reserved_connections=3
# kill -9 client psql 2359195 (our child)
$ [p postgres] select pid, usename, wait_event, state from pg_stat_activity where wait_event='SyncRep'
2359199|app|SyncRep|active
$ [p postgres] set lock_timeout='1s'; insert into t values (10,'dup')
SET
ERROR:  canceling statement due to lock timeout
CONTEXT:  while inserting index tuple (0,2) in relation "t_pkey"
# kill -9 client psql 2361654 (our child)
# kill -9 client psql 2361893 (our child)
# kill -9 client psql 2361920 (our child)
# kill -9 client psql 2361948 (our child)
# kill -9 client psql 2361972 (our child)
# kill -9 client psql 2362226 (our child)
# kill -9 client psql 2362239 (our child)
# kill -9 client psql 2362251 (our child)
# kill -9 client psql 2362290 (our child)
# kill -9 client psql 2362328 (our child)
# kill -9 client psql 2362356 (our child)
# kill -9 client psql 2362368 (our child)
# kill -9 client psql 2362380 (our child)
# kill -9 client psql 2362398 (our child)
# kill -9 client psql 2362410 (our child)
# kill -9 client psql 2362422 (our child)
# attempt 27 refused:
psql: error: connection to server on socket "/var/tmp/provisiond-pgharness/sock/.s.PGSQL.55432" failed: FATAL:  remaining connection slots are reserved for roles with the SUPERUSER attribute
# abandoned waiters created in the loop: 16 (plus id 10)
$ [p postgres] select count(*) as syncrep_backends from pg_stat_activity where wait_event='SyncRep'
17
# postmaster pid now 2355506 (was 2355506): no restart
$ [p postgres] select count(*) as syncrep_backends_after_release from pg_stat_activity where wait_event='SyncRep'
0
$ [p postgres] select count(*) as rows_visible from t where id between 10 and 40
17
$ [p postgres] alter system set client_connection_check_interval='1s'
ALTER SYSTEM
$ [p postgres] alter system set tcp_keepalives_idle=1
ALTER SYSTEM
$ [p postgres] alter system set tcp_keepalives_interval=1
ALTER SYSTEM
$ [p postgres] alter system set tcp_keepalives_count=2
ALTER SYSTEM
$ [p postgres] select pg_reload_conf()
t
# stopped s1 (fast)
# FREEZE again
$ [p postgres] select pid, client_addr, wait_event, (select setting from pg_settings where name='client_connection_check_interval') from pg_stat_activity where wait_event='SyncRep'
2362620|127.0.0.1|SyncRep|1000
# kill -9 client psql 2362614 (our child)
$ [p postgres] select pid, client_addr, wait_event, state, round(extract(epoch from now()-query_start)) as secs from pg_stat_activity where wait_event='SyncRep'
2362620|127.0.0.1|SyncRep|active|30
# teardown done
```

### exp-d.sh

```
## (d) cross-failover barrier counterexample
# SETUP: p, s1, s2 up; s1:streaming:quorum s2:streaming:quorum; synchronous_standby_names=ANY 1 (s1, s2)
# stopped s1 (fast)
# stopped s2 (fast)
# FREEZE: both standbys stopped
# postmaster pid before crash: 2376089; start time: 2026-10-23 05:36:55.838169+00
# kill -9 backend 2376589 (parent 2376089 = postmaster of p)
# postmaster pid after crash: 2376089; start time: 2026-10-23 05:36:55.838169+00
# a client reads D on p (its own transaction):
$ [p app] select v from t where id=1
D
# p end of WAL before loss: insert=0/47BC3B0 timeline=1
# stopped p (immediate)
$ [s1 postgres] select 's1' as node, pg_last_wal_receive_lsn() as receive, pg_last_wal_replay_lsn() as replay
s1|0/4000000|0/4000000
$ [s2 postgres] select 's2' as node, pg_last_wal_receive_lsn() as receive, pg_last_wal_replay_lsn() as replay
s2|0/4000000|0/4000000
# promoted s1
# stopped s2 (fast)
$ [s1 postgres] show synchronous_standby_names
ANY 1 (s1, s2)
# barrier on the promoted store, as app:
$ [s1 app] insert into barrier default values returning id
1
INSERT 0 1
$ [s1 postgres] select application_name, state, sync_state, flush_lsn >= pg_current_wal_flush_lsn() as acked_through_now from pg_stat_replication
s2|streaming|quorum|t
$ [s1 postgres] select count(*) as row1_on_promoted_store from t where id=1
0
$ [s2 postgres] select count(*) as row1_on_s2 from t where id=1
0
## (e2) old primary rejoins as a standby of s1 WITHOUT pg_rewind
# old p log lines:
2026-10-23 05:37:10.955 UTC [2376889] LOG:  primary server contains no more WAL on requested timeline 1
2026-10-23 05:37:10.955 UTC [2376818] LOG:  new timeline 2 forked off current database system timeline 1 before current recovery point 0/47B2898
2026-10-23 05:37:10.955 UTC [2376889] LOG:  primary server contains no more WAL on requested timeline 1
2026-10-23 05:37:10.955 UTC [2376818] LOG:  new timeline 2 forked off current database system timeline 1 before current recovery point 0/47B2898
2026-10-23 05:37:15.960 UTC [2376889] LOG:  primary server contains no more WAL on requested timeline 1
2026-10-23 05:37:15.960 UTC [2376818] LOG:  new timeline 2 forked off current database system timeline 1 before current recovery point 0/47B2898
$ [p postgres] select 'p' as node, pg_last_wal_receive_lsn() as receive, pg_last_wal_replay_lsn() as replay, (select timeline_id from pg_control_checkpoint()) as checkpoint_tli, (select received_tli from pg_stat_wal_receiver) as received_tli
p|0/4000000|0/47B2898|1|1
$ [s2 postgres] select 's2' as node, pg_last_wal_receive_lsn() as receive, pg_last_wal_replay_lsn() as replay, (select timeline_id from pg_control_checkpoint()) as checkpoint_tli, (select received_tli from pg_stat_wal_receiver) as received_tli
s2|0/4004658|0/4004658|1|2
$ [s1 postgres] select 's1' as node, pg_current_wal_flush_lsn() as flush, (select timeline_id from pg_control_checkpoint()) as tli
s1|0/4004658|2
$ [s1 postgres] select application_name, state from pg_stat_replication
s2|streaming
p|startup
# teardown done
```

### exp-d2.sh

```
## (d2-i) barrier transaction, then the primary is lost
# SETUP: p, s1, s2 up; s1:streaming:quorum s2:streaming:quorum; synchronous_standby_names=ANY 1 (s1, s2)
# stopped s1 (fast)
# stopped s2 (fast)
# FREEZE: both standbys stopped
# postmaster pid before crash: 2377948; start time: 2026-10-23 05:37:38.208469+00
# kill -9 backend 2378540 (parent 2377948 = postmaster of p)
# postmaster pid after crash: 2377948; start time: 2026-10-23 05:37:38.208469+00
$ [p postgres] select v as d_visible_after_reinit from t where id=1
D
$ [p postgres] select pid, wait_event, left(query,60) from pg_stat_activity where wait_event='SyncRep'
2378629|SyncRep|begin; select v from t where id=1; insert into barrier defau
# barrier client output so far: []
# stopped p (immediate)
# barrier client output after primary loss (exit 2):
BEGIN
WARNING:  terminating connection due to immediate shutdown command
 v 
---
 D
(1 row)

INSERT 0 1
server closed the connection unexpectedly
	This probably means the server terminated abnormally
	before or while processing the request.
connection to server was lost
## (d2-ii) barrier transaction, then a standby returns
# SETUP: p, s1, s2 up; s1:streaming:quorum s2:streaming:quorum; synchronous_standby_names=ANY 1 (s1, s2)
# stopped s1 (fast)
# stopped s2 (fast)
# FREEZE: both standbys stopped
# postmaster pid before crash: 2378904; start time: 2026-10-23 05:37:54.670711+00
# kill -9 backend 2379389 (parent 2378904 = postmaster of p)
# postmaster pid after crash: 2378904; start time: 2026-10-23 05:37:54.670711+00
$ [p postgres] select v as d_visible_after_reinit from t where id=1
D
# barrier client output while frozen: []
# barrier client output after s1 returns (exit 0):
BEGIN
 v 
---
 D
(1 row)

INSERT 0 1
COMMIT
$ [s1 postgres] select v as d_on_s1 from t where id=1
D
## (d2-edges) during a freeze
# stopped s1 (fast)
$ [p app] begin; select count(*) from t; commit;
BEGIN
1
COMMIT
# read-only transaction took  s
$ [p postgres] alter system set synchronous_standby_names = ''
ALTER SYSTEM
$ [p postgres] select pg_reload_conf()
t
$ [p app] insert into t values (99,'no standby')
INSERT 0 1
# write with synchronous_standby_names='' took  s
$ [p postgres] select count(*) as standbys from pg_stat_replication
0
# teardown done
```

### exp-e.sh

```
## (e) lagging-standby promotion
# SETUP: p, s1, s2 up; s1:streaming:quorum s2:streaming:quorum; synchronous_standby_names=ANY 1 (s1, s2)
# stopped s2 (fast)
# s2 stopped (lagging); s1 streaming
$ [p app] insert into t values (7,'acknowledged')
INSERT 0 1
# commit returned in 88 ms, acknowledged by s1
$ [p postgres] select application_name, flush_lsn, flush_lsn >= pg_current_wal_flush_lsn() as has_it from pg_stat_replication
s1|0/40085F8|t
# stopped s1 (fast)
# stopped p (immediate)
$ [s1 postgres] select 's1' as node, pg_last_wal_receive_lsn() as receive, pg_last_wal_replay_lsn() as replay, (select status from pg_stat_wal_receiver) as walrcv
s1|0/4000000|0/40085F8|
$ [s2 postgres] select 's2' as node, pg_last_wal_receive_lsn() as receive, pg_last_wal_replay_lsn() as replay, (select status from pg_stat_wal_receiver) as walrcv
s2|0/4000000|0/4000000|
$ [s1 postgres] select count(*) as row7_on_s1 from t where id=7
1
# promoted s2 (the lagging one)
$ [s2 postgres] select count(*) as row7_on_promoted_s2 from t where id=7
0
# teardown done
```

### exp-f.sh

```
## (f) read-only WAL check
# SETUP: p, s1, s2 up; s1:streaming:quorum s2:streaming:quorum; synchronous_standby_names=ANY 1 (s1, s2)
$ [p app] select * from pg_stat_replication
2382039|10|postgres|s1||||||||||||||||
2382148|10|postgres|s2||||||||||||||||
$ [p app] select pg_current_wal_insert_lsn(), pg_current_wal_flush_lsn(), pg_current_wal_lsn()
0/40009C0|0/4000000|0/4000000
$ [p app] show synchronous_commit
on
$ [p app] show synchronous_standby_names
ANY 1 (s1, s2)
$ [p app] show restart_after_crash
on
$ [p app] set synchronous_commit = local; show synchronous_commit
SET
local
$ [p app] begin; set local synchronous_commit = on; show synchronous_commit; commit
BEGIN
SET
on
COMMIT
$ [p postgres] set synchronous_commit = local; create role statsreader nologin; grant pg_read_all_stats to statsreader; create function standby_flushed(target pg_lsn) returns boolean language sql stable security definer set search_path = pg_catalog as $$ select exists (select 1 from pg_stat_replication where application_name in ('s1','s2') and flush_lsn >= target) $$; alter function standby_flushed(pg_lsn) owner to statsreader; revoke execute on function standby_flushed(pg_lsn) from public; grant execute on function standby_flushed(pg_lsn) to app;
SET
CREATE ROLE
GRANT ROLE
CREATE FUNCTION
ALTER FUNCTION
REVOKE
GRANT
$ [p app] select standby_flushed(pg_current_wal_flush_lsn()) as via_function
f
# right after a commit: insert target 0/401EE68 -> 9 ms; flush target 0/401EE68 -> 10 ms
# idle primary, sampled every 5 s (insert | flush | standby flush):
  0/401EE68 | 0/401EE68 | s1=0/401EE68 s2=0/401EE68
  0/401EEA0 | 0/401EEA0 | s1=0/401EEA0 s2=0/401EEA0
  0/401EEA0 | 0/401EEA0 | s1=0/401EEA0 s2=0/401EEA0
  0/401EEA0 | 0/401EEA0 | s1=0/401EEA0 s2=0/401EEA0
  0/401EEA0 | 0/401EEA0 | s1=0/401EEA0 s2=0/401EEA0
  0/401EEA0 | 0/401EEA0 | s1=0/401EEA0 s2=0/401EEA0
  0/401EEA0 | 0/401EEA0 | s1=0/401EEA0 s2=0/401EEA0
  0/401EEA0 | 0/401EEA0 | s1=0/401EEA0 s2=0/401EEA0
# idle: insert target 0/401EEA0 -> 9; flush target 0/401EEA0 -> 8
# immediately after a commit: 0/401EF88 vs s1=0/401EF50 s2=0/401EF50
## (f-freeze) read-only check vs write-on-connect check while frozen
# stopped s1 (fast)
# stopped s2 (fast)
# FREEZE: both standbys stopped
# read-only check, 3 s client timeout: timeout
$ [p postgres] select count(*) as syncrep_backends_after_readonly_checks from pg_stat_activity where wait_event='SyncRep'
0
# kill -9 client psql 2384236 (our child)
# kill -9 client psql 2384257 (our child)
# kill -9 client psql 2384292 (our child)
$ [p postgres] select count(*) as syncrep_backends_after_3_write_checks from pg_stat_activity where wait_event='SyncRep'
3
# teardown done
```
