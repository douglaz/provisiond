### B — Bounded internal retry, then diagnostic exit

**STO-55 insertion**, exact text:

```text
**Migration admission refusal.** For `migrate`, this rule applies instead of the startup
acquisition-refusal outcome above. For initial physical connection acquisition by `migrate`,
acquisition by a runner scheduled alongside another runner, and reconnect, the deployment MUST
state a finite, positive Migration admission-retry bound. `migrate` MUST validate it before
attempting admission and refuse to run with a missing or out-of-range value. On the first
admission refusal in an acquisition episode, `migrate` MUST report that it is waiting and the
refusal reason, then retry admission with backoff within that bound. The episode starts at
the first refusal and ends only on obtaining a confirmed usable reservation or exiting;
elapsed time includes further admission calls and backoff, and a refusal never resets it.
Every dial still requires its own distinct reservation. Every denied attempt sends no dial
and no SQL. If no confirmed reservation is obtained before the bound expires, `migrate` MUST
report exhaustion and exit non-zero. A later invocation is a deployment retry; see `STO-12`
for version inspection, serialization and resumability. A refusal MUST NOT be recorded as a
completed migration and does not undo previously recorded completed migrations.
The diagnostic MUST identify `migrate`, the release being attempted, whether this was initial
acquisition or reconnect, whether another migration runner is active or scheduled, and the
admission-refusal reason, without credentials.
This bound covers admission refusal only, not transport or connection checks after a grant,
SQL advisory-lock or DDL lock waits, migration execution or a commit's standby wait. Those
retain their existing rules; see `STO-7`, `STO-12` and `STO-13`. It MUST NOT cancel a sent
COMMIT or release a grant. The grant-retention and release rules above still apply on process
exit or transport loss; neither is evidence that an old backend ended. Refusal does not
require stopping the previous release or terminating any individual backend to make room.
```

**STO-13 release-boundary insertion**, exact text:

```text
For physical connection-admission refusal by the `migrate` entry point and deployment retry,
see `STO-55`. The deployment MUST NOT start any component of the new release until the
required migrations have completed successfully. The stop-everything and backfill exceptions
below retain their existing order.
```

**OVR-19 added row, immediately after the migration lock_timeout row**, exact text:

```text
| Migration admission-retry bound | `STO-55` | finite, positive duration | no — validated by `migrate` before admission |
```

**CNF-57 independent cases**, exact text:

```text
**Migration physical-admission refusal.** Run independent fixtures for (a) the first
`migrate` connection; (b) a second runner scheduled while an admitted runner holds `STO-12`'s
migration key, with the second runner denied its own physical connection before it can
request that key; and (c) a runner that has recorded one completed migration, then loses its
transport and is denied admission for a replacement connection before its next migration.
Use a release allowed to migrate with the previous release running. Retain adequate admitted
read/write sessions for the previous-release service assertions independently of the denied
migration attempt. Exhaust component admission capacity C (`STO-55`) with charged reservations,
without cancelling or terminating an individual `SyncRep` backend. In each fixture identify
the denied physical attempt and assert it makes no dial and sends no SQL; no new-release
component starts before the required migrations complete successfully, and that refusal
records no migration completion. Previously recorded
completed versions remain unchanged. The previous release's engine and `api` keep serving
through their admitted sessions; assert an engine write and an `api` write succeed with the
required standby available. Retain all uncertain/residual charges through refusal and any
runner exit. Release capacity only with `STO-55`'s existing fencing and backend-absence evidence.
For each fixture, keep admission denied across multiple calls/backoffs through the stated
Migration admission-retry bound. Assert both the initial waiting and exhaustion diagnostics
carry every `STO-55` migration-diagnostic field, no dial/SQL for denied attempts, a single
unreset elapsed bound, and non-zero exit by exhaustion. Then repeat each fixture with
verified capacity release before expiry: assert a fresh distinct reservation before the dial,
continuation without first exiting, and no completed version applied again. The new release
starts only after required migrations complete successfully. Reject missing, zero, negative
and non-finite bound settings before admission. A separately invoked deployment retry after
exhaustion obeys the same rules. Separately, give both runners confirmed admitted connections
and contend on the migration key: assert the second waits on the key under `STO-12`; the
admission-refusal timer does not run merely because it waits there. No standby wait is cut
off by this bound. Keep the existing concurrent-index and stop-everything cases.
(`STO-55`, `STO-12`, `STO-13`, `STO-7`, `OVR-19`)
```

This package adds a deployment parameter and internal wait cost. It bounds a refusal episode, not total migration runtime, SQL lock waiting or a sent COMMIT. It does not promise eventual capacity, nor bound a successful authority reply that never returns before any refusal. No particular duration or backoff cadence is selected here. Evaluate whether that is a complete enough executable contract or needs a separately reviewed form.

