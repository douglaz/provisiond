### A — Exit on refusal, diagnostic and deployment retry

**STO-55 insertion**, exact text:

```text
**Migration admission refusal.** If `STO-55` admission refuses a physical connection attempt
by the `migrate` entry point, including initial acquisition, acquisition by a runner scheduled
alongside another runner, or reconnect, `migrate` MUST report the refusal and exit non-zero
at once; it MUST NOT wait or retry admission internally. A later invocation is a deployment
retry; see `STO-12` for version inspection, serialization and resumability. The denied attempt
MUST send no dial and no SQL. It MUST NOT record a migration as completed because of that
refusal, and the refusal does not undo previously recorded completed migrations.
The diagnostic MUST identify `migrate`, the release being attempted, whether this was initial
acquisition or reconnect, whether another migration runner is active or scheduled, and the
admission-refusal reason, without credentials.
This rule governs refusal before a physical connection is admitted, not a SQL advisory-lock
or DDL lock wait after connection. It introduces no deadline for a sent COMMIT or standby
wait; see `STO-7`. The grant-retention and release rules above still apply on process exit or
transport loss; neither is evidence that an old backend ended. Refusal does not require
stopping the previous release or terminating any individual backend to make room.
```

**STO-13 release-boundary insertion**, exact text:

```text
For physical connection-admission refusal by the `migrate` entry point and deployment retry,
see `STO-55`. The deployment MUST NOT start any component of the new release until the
required migrations have completed successfully. The stop-everything and backfill exceptions
below retain their existing order.
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
Assert the refused runner emits the `STO-55` migration diagnostic and exits non-zero at
once, without an internal admission wait/retry. A separately invoked deployment retry after
verified capacity release uses a fresh reservation and resumes through `STO-12`'s version
history. No completed migration is applied again and the release starts only after the
required migrations complete successfully. Separately, give both runners confirmed admitted
connections and contend on the migration key: assert the second waits on the key under
`STO-12` rather than taking the admission-refusal exit. Keep the existing concurrent-index
and stop-everything cases. (`STO-55`, `STO-12`, `STO-13`, `STO-7`)
```

No new parameter. This package defines the entry point result once an admission refusal has been received; it does not add a deadline for the authority to respond. Deployment invocation cadence remains outside the amendment. It adds a diagnostic and an explicit STO-13 release-boundary MUST beyond C; C tests that start order without adding that sentence.

