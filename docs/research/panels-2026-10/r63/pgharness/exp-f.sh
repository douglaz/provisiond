#!/bin/bash
# (f) the read-only WAL check as an unprivileged role; SHOW visibility; target termination; freeze behaviour
H=/var/tmp/provisiond-pgharness; R=$H/logs/exp-f.log; : > $R; . $H/lib.sh
ms() { echo $(( ($(date +%s%N)-$1)/1000000 )); }
log "## (f) read-only WAL check"; setup
qalog p "select * from pg_stat_replication"
qalog p "select pg_current_wal_insert_lsn(), pg_current_wal_flush_lsn(), pg_current_wal_lsn()"
for g in synchronous_commit synchronous_standby_names restart_after_crash; do qalog p "show $g"; done
qalog p "set synchronous_commit = local; show synchronous_commit"
qalog p "begin; set local synchronous_commit = on; show synchronous_commit; commit"
qlog p "set synchronous_commit = local; create role statsreader nologin; grant pg_read_all_stats to statsreader; create function standby_flushed(target pg_lsn) returns boolean language sql stable security definer set search_path = pg_catalog as \$\$ select exists (select 1 from pg_stat_replication where application_name in ('s1','s2') and flush_lsn >= target) \$\$; alter function standby_flushed(pg_lsn) owner to statsreader; revoke execute on function standby_flushed(pg_lsn) from public; grant execute on function standby_flushed(pg_lsn) to app;"
qalog p "select standby_flushed(pg_current_wal_flush_lsn()) as via_function"
poll() {  # poll TARGET LIMIT_MS -> prints ms until true, or 'timeout'
  s0=$(date +%s%N); while :; do
    [ "$(qa p "select standby_flushed('$1')")" = t ] && { ms $s0; return; }
    [ $(ms $s0) -ge $2 ] && { echo timeout; return; }; sleep 0.05; done; }
qa p "insert into t values (50,'busy')" >/dev/null
TI=$(qa p "select pg_current_wal_insert_lsn()"); TF=$(qa p "select pg_current_wal_flush_lsn()")
log "# right after a commit: insert target $TI -> $(poll $TI 20000) ms; flush target $TF -> $(poll $TF 20000) ms"
log "# idle primary, sampled every 5 s (insert | flush | standby flush):"
for i in $(seq 1 8); do log "  $(q p "select pg_current_wal_insert_lsn()||' | '||pg_current_wal_flush_lsn()||' | '||coalesce((select string_agg(application_name||'='||flush_lsn, ' ' order by application_name) from pg_stat_replication),'-')")"; sleep 5; done
TI=$(qa p "select pg_current_wal_insert_lsn()"); TF=$(qa p "select pg_current_wal_flush_lsn()")
log "# idle: insert target $TI -> $(poll $TI 20000); flush target $TF -> $(poll $TF 20000)"
# freshness: how fast flush_lsn reflects a commit
qa p "insert into t values (51,'fresh')" >/dev/null
log "# immediately after a commit: $(q p "select pg_current_wal_flush_lsn()||' vs '||string_agg(application_name||'='||flush_lsn, ' ') from pg_stat_replication")"
log "## (f-freeze) read-only check vs write-on-connect check while frozen"; freeze
TF=$(qa p "select pg_current_wal_flush_lsn()")
log "# read-only check, 3 s client timeout: $(poll $TF 3000)"
qlog p "select count(*) as syncrep_backends_after_readonly_checks from pg_stat_activity where wait_event='SyncRep'"
for i in 1 2 3; do
  $PG/psql -X -h $SOCK -p 55432 -U app -d postgres -c "insert into barrier default values" > $LOGS/f-w.out 2>&1 &
  W=$!; sleep 2; kill9_client $W; wait $W 2>/dev/null; done
qlog p "select count(*) as syncrep_backends_after_3_write_checks from pg_stat_activity where wait_event='SyncRep'"
teardown; log "# teardown done"
