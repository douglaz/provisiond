#!/bin/bash
# (a) a commit waiting in SyncRep becomes visible after kill -9 of an unrelated backend (restart_after_crash on)
H=/var/tmp/provisiond-pgharness; R=$H/logs/exp-a.log; : > $R; . $H/lib.sh
log "## (a) crash-restart makes a waiting commit visible"; setup; freeze
qlog p "show restart_after_crash"
$PG/psql -X -h $SOCK -p 55432 -U app -d postgres -c "insert into t values (1,'D')" > $LOGS/a-waiter.out 2>&1 &
W=$!; wait_syncrep 1
qlog p "select pid, usename, wait_event, state, left(query,40) from pg_stat_activity where wait_event='SyncRep'"
qlog p "select count(*) as row1_visible_before from t where id=1"
crash_restart
wait $W; log "# waiting client's output (exit $?):"; cat $LOGS/a-waiter.out >> $R
qlog p "select * from t where id=1"
qlog p "select application_name, state, flush_lsn from pg_stat_replication"
log "# server log lines:"; grep -E 'terminated by signal|crash of another|reinitializing|ready to accept|redo done' $LOGS/p.log >> $R
# per-connection check (S3-B) on a new connection after the reinit
T=$(q p "select pg_current_wal_flush_lsn()"); log "# new connection: primary flush position T=$T, insert=$(q p 'select pg_current_wal_insert_lsn()')"
qlog p "select count(*) as named_standbys_at_or_past_T from pg_stat_replication where application_name in ('s1','s2') and flush_lsn >= '$T'"
start s1; wait_streaming p s1
for i in $(seq 1 40); do [ "$(q p "select count(*) from pg_stat_replication where application_name='s1' and flush_lsn >= '$T'")" = 1 ] && break; sleep 0.25; done
qlog p "select application_name, state, flush_lsn, flush_lsn >= '$T' as passed from pg_stat_replication"
qlog s1 "select * from t where id=1"
teardown; log "# teardown done"
