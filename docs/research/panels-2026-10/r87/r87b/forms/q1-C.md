### C — Narrow explicit startup-refusal scope, no new reporting/bound

**STO-55 replacement**, exact text:

```text
Startup acquisition refusal exits for supervisor retry; `api` returns `overloaded` before any
transaction; worker/periodic acquisition refusal is an `OPS-49` store error (`OPS-49`: "An
attempt denied by `STO-55` admission is a store error for this loop and sends no SQL").
For `migrate`, the startup acquisition-refusal outcome applies on initial physical connection
acquisition, acquisition by a runner scheduled alongside another runner, and reconnect:
exit non-zero for deployment retry.
Stop-record refusals consume existing bounds and send no SQL. No individual `SyncRep` backend
may be cancelled or terminated to make room; primary shutdown remains `STO-7`'s exception,
"other than by shutting the primary down".
```

**STO-13 pointer insertion**, exact text:

```text
For physical connection-admission refusal by `migrate`, see `STO-55`.
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
Assert each refused runner exits non-zero for deployment retry and no denied attempt dials
or sends SQL. After verified capacity release, invoke `migrate` again with a fresh reservation
and assert normal version inspection and completion under `STO-12`, before the new release's
components start. Separately, admit both runners and assert the second waits on `STO-12`'s
key rather than treating that lock wait as physical connection-admission refusal. Keep the
existing concurrent-index and stop-everything cases. (`STO-55`, `STO-12`, `STO-13`)
```

This is a smaller explicit scope amendment plus conformance. It supplies no new diagnostic format, report, retry duration or OVR-19 row. Its migration-only exit preserves the existing non-migration startup clause; say whether that sufficiently specifies prompt exit or leaves an internal wait loophole. Existing exhaustion/accounting alarms remain.

