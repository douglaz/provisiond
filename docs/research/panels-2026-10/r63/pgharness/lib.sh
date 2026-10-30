# Harness library: three local PostgreSQL 18 instances (p, s1, s2). Sourced by exp-*.sh.
# Localhost only; sockets in a 0700 dir; TCP needs a password (scram). Every instance is a capped user unit.
PG=/nix/store/kxjjxz8jmggi9nbkgzc2g6vxc47nqbcz-postgresql-18.6/bin
H=/var/tmp/provisiond-pgharness
export TMPDIR=$H/tmp
SOCK=$H/sock
D=$H/data
LOGS=$H/logs
mkdir -p $TMPDIR $LOGS
port() { case $1 in p) echo 55432;; s1) echo 55433;; s2) echo 55434;; esac; }
R=${R:-$LOGS/scratch.log}           # experiment transcript (set by each script)
log() { echo "$*" >> $R; }
# q NODE SQL: superuser query, unaligned; qa = as the unprivileged role app
q()  { timeout 30 $PG/psql -X -At -h $SOCK -p $(port $1) -U postgres -d postgres -c "$2" 2>&1; }
qa() { timeout 30 $PG/psql -X -At -h $SOCK -p $(port $1) -U app -d postgres -c "$2" 2>&1; }
# qlog/qalog: log the command and its verbatim output
qlog()  { log "\$ [$1 postgres] $2"; q  $1 "$2" >> $R; }
qalog() { log "\$ [$1 app] $2"; qa $1 "$2" >> $R; }
pmpid() { head -1 $D/$1/postmaster.pid 2>/dev/null; }
ready() { for i in $(seq 1 120); do $PG/pg_isready -q -h $SOCK -p $(port $1) && return 0; sleep 0.25; done; log "NOT READY: $1"; return 1; }
start() {  # start NODE as a capped unit; log to $LOGS/NODE.log
  systemctl --user reset-failed pgh-$1 >/dev/null 2>&1
  systemd-run --user --unit=pgh-$1 --collect -p MemoryMax=1G -p MemorySwapMax=0 -p OOMPolicy=continue \
    -E TMPDIR=$TMPDIR -p StandardOutput=append:$LOGS/$1.log -p StandardError=append:$LOGS/$1.log \
    $PG/postgres -D $D/$1 >/dev/null 2>&1
  ready $1
}
stop() { $PG/pg_ctl -D $D/$1 stop -m ${2:-fast} -w -t 60 >/dev/null 2>&1; log "# stopped $1 (${2:-fast})"; }
freeze() { stop s1; stop s2; log "# FREEZE: both standbys stopped"; }
wait_syncrep() {  # wait until N backends wait in SyncRep on p
  for i in $(seq 1 80); do
    n=$(q p "select count(*) from pg_stat_activity where wait_event='SyncRep'")
    [ "$n" -ge "$1" ] 2>/dev/null && return 0; sleep 0.25; done; log "SyncRep wait not reached ($1)"; return 1; }
wait_streaming() {  # wait_streaming PRIMARY STANDBY_NAME
  for i in $(seq 1 120); do
    [ "$(q $1 "select count(*) from pg_stat_replication where application_name='$2' and state='streaming'")" = 1 ] && return 0
    sleep 0.25; done; log "NOT STREAMING: $2 on $1"; return 1; }
# kill9_backend PID: SIGKILL a backend of OUR postmaster p only (checks the parent PID first)
kill9_backend() {
  pp=$(awk '{print $4}' /proc/$1/stat 2>/dev/null)
  if [ -n "$pp" ] && [ "$pp" = "$(pmpid p)" ]; then kill -9 $1; log "# kill -9 backend $1 (parent $pp = postmaster of p)"
  else log "REFUSED kill of $1: parent '$pp' is not p's postmaster"; return 1; fi; }
# kill9_client PID: SIGKILL a psql client started by this script (checks it is our child and is psql)
kill9_client() {
  pp=$(awk '{print $4}' /proc/$1/stat 2>/dev/null); exe=$(readlink /proc/$1/exe 2>/dev/null)
  if [ "$pp" = "$$" ] && [ "${exe##*/}" = psql ]; then kill -9 $1; log "# kill -9 client psql $1 (our child)"
  else log "REFUSED kill of $1: parent '$pp' exe '$exe'"; return 1; fi; }
# crash_restart: kill -9 an unrelated bystander backend on p, wait for the reinit
crash_restart() {
  $PG/psql -X -q -h $SOCK -p 55432 -U app -d postgres -c "select pg_sleep(600) /*bystander*/" > $LOGS/bystander.out 2>&1 &
  for i in $(seq 1 40); do
    bp=$(q p "select pid from pg_stat_activity where query like '%/*bystander*/%' and pid<>pg_backend_pid() and usename='app'")
    [ -n "$bp" ] && break; sleep 0.25; done
  log "# postmaster pid before crash: $(pmpid p); start time: $(q p 'select pg_postmaster_start_time()')"
  kill9_backend $bp
  sleep 1; ready p
  log "# postmaster pid after crash: $(pmpid p); start time: $(q p 'select pg_postmaster_start_time()')"
}
teardown() {
  for n in p s1 s2; do
    [ -f $D/$n/postmaster.pid ] && $PG/pg_ctl -D $D/$n stop -m immediate -w -t 30 >/dev/null 2>&1
    systemctl --user stop pgh-$n >/dev/null 2>&1; systemctl --user reset-failed pgh-$n >/dev/null 2>&1
  done; true; }
setup() {
  teardown; rm -rf $D $SOCK; mkdir -p $D $SOCK; chmod 700 $SOCK
  umask 077; echo 'harness-superuser-pw' > $H/pw; echo '127.0.0.1:55432:postgres:app:app-pw' > $H/pgpass; umask 022
  : > $LOGS/p.log; : > $LOGS/s1.log; : > $LOGS/s2.log
  $PG/initdb -D $D/p -U postgres --auth-local=trust --auth-host=scram-sha-256 --pwfile=$H/pw >/dev/null 2>&1
  cat >> $D/p/postgresql.conf <<EOF
listen_addresses = '127.0.0.1'
port = 55432
unix_socket_directories = '$SOCK'
wal_level = replica
max_wal_senders = 10
synchronous_standby_names = 'ANY 1 (s1, s2)'
synchronous_commit = on
restart_after_crash = on
max_connections = 20
superuser_reserved_connections = 3
shared_buffers = 32MB
hot_standby = on
wal_keep_size = 256MB
EOF
  start p
  q p "set synchronous_commit = local; create table t(id int primary key, v text); create table barrier(id bigserial primary key, at timestamptz default now()); create table pad(i int, filler text); create role app login password 'app-pw'; grant select, insert, update, delete on t, barrier, pad to app; grant usage on sequence barrier_id_seq to app;" >/dev/null
  for s in s1 s2; do
    $PG/pg_basebackup -h $SOCK -p 55432 -U postgres -D $D/$s -X stream >/dev/null 2>&1
    printf "port = %s\nprimary_conninfo = 'host=%s port=55432 user=postgres application_name=%s'\n" $(port $s) $SOCK $s >> $D/$s/postgresql.conf
    touch $D/$s/standby.signal; start $s
  done
  wait_streaming p s1; wait_streaming p s2
  log "# SETUP: p, s1, s2 up; $(q p "select string_agg(application_name||':'||state||':'||sync_state, ' ') from pg_stat_replication"); synchronous_standby_names=$(q p 'show synchronous_standby_names')"
}
# repoint NODE to stream from PRIMARY_NODE (restart needed)
repoint() { printf "primary_conninfo = 'host=%s port=%s user=postgres application_name=%s'\n" $SOCK $(port $2) $1 >> $D/$1/postgresql.conf; }
