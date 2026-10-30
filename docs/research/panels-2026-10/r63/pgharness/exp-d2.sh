#!/bin/bash
# (d2) same-transaction barrier: read D and write a barrier row in ONE transaction; edges
H=/var/tmp/provisiond-pgharness; R=$H/logs/exp-d2.log; : > $R; . $H/lib.sh
BAR="begin; select v from t where id=1; insert into barrier default values; commit;"
prep() { setup; freeze
  $PG/psql -X -h $SOCK -p 55432 -U app -d postgres -c "insert into t values (1,'D')" > $LOGS/d2-waiter.out 2>&1 &
  W=$!; wait_syncrep 1; crash_restart; wait $W; qlog p "select v as d_visible_after_reinit from t where id=1"; }
log "## (d2-i) barrier transaction, then the primary is lost"; prep
$PG/psql -X -h $SOCK -p 55432 -U app -d postgres -c "$BAR" > $LOGS/d2-bar.out 2>&1 &
B=$!; wait_syncrep 1; sleep 2
qlog p "select pid, wait_event, left(query,60) from pg_stat_activity where wait_event='SyncRep'"
log "# barrier client output so far: [$(cat $LOGS/d2-bar.out)]"
stop p immediate; wait $B; log "# barrier client output after primary loss (exit $?):"; cat $LOGS/d2-bar.out >> $R
log "## (d2-ii) barrier transaction, then a standby returns"; prep
$PG/psql -X -h $SOCK -p 55432 -U app -d postgres -c "$BAR" > $LOGS/d2-bar.out 2>&1 &
B=$!; wait_syncrep 1; sleep 2; log "# barrier client output while frozen: [$(cat $LOGS/d2-bar.out)]"
start s1; wait $B; log "# barrier client output after s1 returns (exit $?):"; cat $LOGS/d2-bar.out >> $R
qlog s1 "select v as d_on_s1 from t where id=1"
log "## (d2-edges) during a freeze"; stop s1
s=$(date +%s.%N); qalog p "begin; select count(*) from t; commit;"; log "# read-only transaction took $(echo "$(date +%s.%N) - $s" | bc) s"
qlog p "alter system set synchronous_standby_names = ''"; qlog p "select pg_reload_conf()"; sleep 1
s=$(date +%s.%N); qalog p "insert into t values (99,'no standby')"; log "# write with synchronous_standby_names='' took $(echo "$(date +%s.%N) - $s" | bc) s"
qlog p "select count(*) as standbys from pg_stat_replication"
teardown; log "# teardown done"
