#!/bin/bash
# (d) a barrier on the promoted store certifies nothing about a read on the old primary; (e2) LSNs across timelines
H=/var/tmp/provisiond-pgharness; R=$H/logs/exp-d.log; : > $R; . $H/lib.sh
log "## (d) cross-failover barrier counterexample"; setup; freeze
$PG/psql -X -h $SOCK -p 55432 -U app -d postgres -c "begin; insert into t values (1,'D'); insert into pad select g, repeat('x',100) from generate_series(1,50000) g; commit;" > $LOGS/d-waiter.out 2>&1 &
W=$!; wait_syncrep 1; crash_restart; wait $W
log "# a client reads D on p (its own transaction):"; qalog p "select v from t where id=1"
log "# p end of WAL before loss: insert=$(q p 'select pg_current_wal_insert_lsn()') timeline=$(q p 'select timeline_id from pg_control_checkpoint()')"
stop p immediate
start s1; start s2
for s in s1 s2; do qlog $s "select '$s' as node, pg_last_wal_receive_lsn() as receive, pg_last_wal_replay_lsn() as replay"; done
$PG/pg_ctl -D $D/s1 promote -w >/dev/null 2>&1; log "# promoted s1"; ready s1
stop s2; repoint s2 s1; start s2; wait_streaming s1 s2
qlog s1 "show synchronous_standby_names"
log "# barrier on the promoted store, as app:"; qalog s1 "insert into barrier default values returning id"
qlog s1 "select application_name, state, sync_state, flush_lsn >= pg_current_wal_flush_lsn() as acked_through_now from pg_stat_replication"
qlog s1 "select count(*) as row1_on_promoted_store from t where id=1"
qlog s2 "select count(*) as row1_on_s2 from t where id=1"
log "## (e2) old primary rejoins as a standby of s1 WITHOUT pg_rewind"
touch $D/p/standby.signal; repoint p s1; start p
sleep 5
log "# old p log lines:"; grep -E 'forked off|timeline|consistent recovery|ready to accept read' $LOGS/p.log | tail -6 >> $R
for n in p s2; do qlog $n "select '$n' as node, pg_last_wal_receive_lsn() as receive, pg_last_wal_replay_lsn() as replay, (select timeline_id from pg_control_checkpoint()) as checkpoint_tli, (select received_tli from pg_stat_wal_receiver) as received_tli"; done
qlog s1 "select 's1' as node, pg_current_wal_flush_lsn() as flush, (select timeline_id from pg_control_checkpoint()) as tli"
qlog s1 "select application_name, state from pg_stat_replication"
teardown; log "# teardown done"
