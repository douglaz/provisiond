#!/bin/bash
# (c) an abandoned client leaves its backend in SyncRep holding a slot and its locks; abandonments pile up with no restart
H=/var/tmp/provisiond-pgharness; R=$H/logs/exp-c.log; : > $R; . $H/lib.sh
log "## (c) abandoned clients"; setup; freeze
PM=$(pmpid p); log "# postmaster pid $PM; max_connections=$(q p 'show max_connections'), superuser_reserved_connections=$(q p 'show superuser_reserved_connections')"
$PG/psql -X -h $SOCK -p 55432 -U app -d postgres -c "insert into t values (10,'C')" > $LOGS/c-w10.out 2>&1 &
W=$!; wait_syncrep 1; kill9_client $W; wait $W 2>/dev/null; sleep 3
qlog p "select pid, usename, wait_event, state from pg_stat_activity where wait_event='SyncRep'"
qlog p "set lock_timeout='1s'; insert into t values (10,'dup')"
n=0; for i in $(seq 11 40); do
  $PG/psql -X -h $SOCK -p 55432 -U app -d postgres -c "insert into t values ($i,'C')" > $LOGS/c-w.out 2>&1 &
  W=$!; ok=0
  for j in $(seq 1 20); do
    [ "$(q p "select count(*) from pg_stat_activity where wait_event='SyncRep' and query like 'insert into t values ($i,%'")" = 1 ] && { ok=1; break; }
    kill -0 $W 2>/dev/null || break; sleep 0.25; done
  if [ $ok = 1 ]; then kill9_client $W; wait $W 2>/dev/null; n=$((n+1)); else wait $W; log "# attempt $i refused:"; cat $LOGS/c-w.out >> $R; break; fi
done
log "# abandoned waiters created in the loop: $n (plus id 10)"
qlog p "select count(*) as syncrep_backends from pg_stat_activity where wait_event='SyncRep'"
log "# postmaster pid now $(pmpid p) (was $PM): no restart"
start s1; wait_streaming p s1; sleep 2
qlog p "select count(*) as syncrep_backends_after_release from pg_stat_activity where wait_event='SyncRep'"
qlog p "select count(*) as rows_visible from t where id between 10 and 40"
# TCP variant
qlog p "alter system set client_connection_check_interval='1s'"
qlog p "alter system set tcp_keepalives_idle=1"
qlog p "alter system set tcp_keepalives_interval=1"
qlog p "alter system set tcp_keepalives_count=2"
qlog p "select pg_reload_conf()"
stop s1; log "# FREEZE again"
PGPASSFILE=$H/pgpass $PG/psql -X -h 127.0.0.1 -p 55432 -U app -d postgres -c "insert into t values (100,'TCP')" > $LOGS/c-tcp.out 2>&1 &
W=$!; wait_syncrep 1
qlog p "select pid, client_addr, wait_event, (select setting from pg_settings where name='client_connection_check_interval') from pg_stat_activity where wait_event='SyncRep'"
kill9_client $W; wait $W 2>/dev/null; sleep 30
qlog p "select pid, client_addr, wait_event, state, round(extract(epoch from now()-query_start)) as secs from pg_stat_activity where wait_event='SyncRep'"
teardown; log "# teardown done"
