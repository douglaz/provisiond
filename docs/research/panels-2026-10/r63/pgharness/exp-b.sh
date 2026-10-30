#!/bin/bash
# (b) cancel / terminate of a SyncRep wait makes the commit visible; statement_timeout / transaction_timeout don't end it
H=/var/tmp/provisiond-pgharness; R=$H/logs/exp-b.log; : > $R; . $H/lib.sh
log "## (b) cancelled wait"; setup; freeze
$PG/psql -X -h $SOCK -p 55432 -U app -d postgres -c "set statement_timeout='2s'" -c "set transaction_timeout='3s'" -c "insert into t values (2,'B')" > $LOGS/b-waiter.out 2>&1 &
W=$!; wait_syncrep 1; sleep 6
qlog p "select pid, wait_event, state, round(extract(epoch from now()-query_start)) as secs_waiting, (select setting from pg_settings where name='statement_timeout') from pg_stat_activity where wait_event='SyncRep'"
log "# waiter's session settings: statement_timeout=2s, transaction_timeout=3s (psql -c 'set ...')"
qlog p "select count(*) as row2_visible_before from t where id=2"
qlog p "select pg_cancel_backend(pid) from pg_stat_activity where wait_event='SyncRep'"
wait $W; log "# waiter's output after pg_cancel_backend (exit $?):"; cat $LOGS/b-waiter.out >> $R
qlog p "select * from t where id=2"
qlog p "select count(*) as standbys from pg_stat_replication"
$PG/psql -X -h $SOCK -p 55432 -U app -d postgres -c "insert into t values (3,'T')" > $LOGS/b-waiter2.out 2>&1 &
W=$!; wait_syncrep 1
qlog p "select pg_terminate_backend(pid) from pg_stat_activity where wait_event='SyncRep'"
wait $W; log "# waiter's output after pg_terminate_backend (exit $?):"; cat $LOGS/b-waiter2.out >> $R
qlog p "select * from t where id=3"
teardown; log "# teardown done"
