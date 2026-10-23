## S2

**STOP: PICK A** (I voted B in r63e and have moved)
- **Why A.** The record transaction already sent still lands. Its commit is flushed and marked in clog before the wait (xact.c:1506, :1518, then :1567). The left-behind backend keeps waiting (FA2), and `STO-7` forbids cancelling it.
- **What B adds.** B saves only the engine's connection slots. `05:189-191` ("fit inside `max_connections`") fails under both forms, because an `api` replica stopped during a stall leaves its own waiting backends behind. I found no `api` drain rule.
- **OTHER (B): ACCEPTABLE.**
  - If B's pause applies per record, B can still exit during a stall. `03:1764` counts "the repeats of which `OPS-49` says 'do not consume the bound'", so lock-timeout repeats can run out the bound while other commits wait.
  - Ripple: `0044:46-49` quotes both sentences that B rewrites, and C13 doesn't amend `ADR-0044`.
- **MOVE:** a trace where an engine commit left waiting after the engine exits loses money.
- **P:**
  - P1: KEPT.
  - P2: KEPT. The alarm for the wait moves to `OVR-18` (C6).
  - P3: KEPT for a record already sent. LOST for one not yet sent, which is the existing "A kill or crash records nothing".
  - P4: KEPT through LOCK-B.

**LOCK: PICK B, with replacement text**
- **OTHER (A): ACCEPTABLE.** It breaks no MUST and loses no money, but P4 is LOST. The trace:
  1. An `api` write waits in `SyncRep` holding `LDG-35`.
  2. Engine metering exhausts the bound, and "the engine MUST exit non-zero" (`03:1829`).
  3. That exit leaves the engine's waiting commits behind.
  4. Each successor's metering meets the same lock and exits again.
- **Opus's text is too loose.** Every healthy commit passes through `SyncRep` for one round trip, so "while a primary backend waits with wait event `SyncRep`" is often true on a busy primary with healthy standbys.
  - A lock held elsewhere then keeps timing out without consuming the bound, and no stall alarm fires. That is "an unalarmed loop on a held primitive" (`03:1851`).
  - It also misses `statement_timeout` (FL1), and the engine can't see other roles' wait events (FL3).
- **Replacement for `03:1846-1850`:** "A `lock_timeout` or `statement_timeout` does not consume the bound while neither standby `OVR-19` names has flushed the primary's WAL up to the flush position the primary reported when the repeat began (`pg_stat_replication`, which the engine's role MUST be able to read: `pg_read_all_stats`); `OVR-18`'s stalled-standby alarm is that loop's alarm."
  - This condition holds only during a real stall, which `OVR-18` alarms, and it also covers the migrator (FL2).
- **MOVE:** a rule that forbids giving the engine's role that privilege.
- **P:**
  - P1: KEPT.
  - P2: MOVED to `OVR-18`'s stalled-standby alarm.
  - P3: KEPT, because `03:1764` still counts these repeats.
  - P4: KEPT.

**Ripple (both forms):** `05:1398-1401` says "so that the time `api` queues behind a migration is bounded". But a DDL commit now waits while holding `ACCESS EXCLUSIVE` (FL2). Add "; a commit's wait for the standby (`STO-7`) is outside that bound".

## S3

**PICK: S3-A**
- **It closes the §1 trace.** With the setting off, postmaster.c:3185-3188 logs "shutting down because \"restart_after_crash\" is off". RS then gates the next start.
- **The cost I accept:**
  - A backend crash is a full outage until the primary restarts and a standby catches up.
  - During a stall, RS then refuses the engine's connections until it exhausts `OPS-49`'s bound, which is P4's loop.
  - Nothing says who restarts the primary, so add ", and the deployment restarts it".

**OTHER:**
- **S3-B: ACCEPTABLE.**
  - During any stall, the primary's flush position is ahead of both standbys (xact.c:1506), so every new connection waits.
  - Any engine restart during a stall then exhausts `OPS-49`'s bound ("covers connection"). That is the same loop, with a broader trigger.
  - I recommend adding: "the check's wait is outside the store-call, Store-retry and startup-lock bounds".
- **S3-AB: ACCEPTABLE.**
- **S3-P: NOT ACCEPTABLE.** With `on`, the postmaster never exits, so Patroni's `recover()` never runs. Patroni's docs name the leak: "transaction changes become visible for other backends".
- **S3-N: NOT ACCEPTABLE.** The §1 trace re-issues an address, which breaks `05:867` ("never re-issued"), and the deposit is lost.

## Brief errors

- **s3-analysis H2:** the crash test is at postmaster.c:2592-2593, not :2593-2594.
- **s3-analysis §4(ii):** with `primary_start_timeout = 0` and no failover possible, ha.py:662 skips "starting primary after failure". Patroni instead runs ha.py:692, "starting as readonly because i had the session lock". That path is still ungated, so the conclusion stands.
- **forms-final, STO-54:** the merge keeps the meaning. But the "[S1 merge: …]" note sits inside the normative text and must not ship.
