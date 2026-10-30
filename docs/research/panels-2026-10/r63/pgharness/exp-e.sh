#!/bin/bash
# (e) promoting the lagging standby loses an acknowledged commit; what each standby reports after a restart
H=/var/tmp/provisiond-pgharness; R=$H/logs/exp-e.log; : > $R; . $H/lib.sh
log "## (e) lagging-standby promotion"; setup
stop s2; log "# s2 stopped (lagging); s1 streaming"
s0=$(date +%s%N); qalog p "insert into t values (7,'acknowledged')"; log "# commit returned in $(( ($(date +%s%N)-s0)/1000000 )) ms, acknowledged by s1"
qlog p "select application_name, flush_lsn, flush_lsn >= pg_current_wal_flush_lsn() as has_it from pg_stat_replication"
stop s1; stop p immediate
start s2; start s1; sleep 2
for s in s1 s2; do qlog $s "select '$s' as node, pg_last_wal_receive_lsn() as receive, pg_last_wal_replay_lsn() as replay, (select status from pg_stat_wal_receiver) as walrcv"; done
qlog s1 "select count(*) as row7_on_s1 from t where id=7"
$PG/pg_ctl -D $D/s2 promote -w >/dev/null 2>&1; log "# promoted s2 (the lagging one)"; ready s2
qlog s2 "select count(*) as row7_on_promoted_s2 from t where id=7"
teardown; log "# teardown done"
