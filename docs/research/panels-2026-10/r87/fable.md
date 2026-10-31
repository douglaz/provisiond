**Plain-terms answer.** The gap is real, and closing it costs nothing the set has not already paid for the engine. The only place the pinned set interprets "Startup acquisition refusal exits for supervisor retry" is OPS-47 at `03-operation-lifecycle.md:136`, which quotes it for the engine running "under an external supervisor that retries startup subject to `STO-55` admission". The migrator has no supervisor. STO-13 has the deployment run it as a step before any component starts, and OVR-17's closed component list does not name it. So a refused `migrate` has no stated outcome at the pin. The set's existing answer for every pre-service acquisition refusal is fail fast, let the external retrier retry, and leave the admission accounting untouched. That is the right answer here too. An internal wait adds a second retry layer and a parameter nobody has priced.

**Final: Q1 exact alternative A′**, which is package A with one diagnostic field replaced, printed in full at the end.

- **A CANNOT ACCEPT** as printed.
- **B CANNOT ACCEPT** as printed.
- **C ACCEPT** as printed.
- **D CANNOT ACCEPT.**

Preference order: A′, then C. B and D are not preferred. Acceptability and preference are separate above.

**Why A fails as printed.** Its diagnostic "MUST identify ... whether another migration runner is active or scheduled". The process has no input from which to know either. "Scheduled" is a deployment fact `migrate` never sees. "Active" could only mean "the authority holds an unreleased migrator grant", and STO-55 keeps charges for dead attempts by design, so in fixture (c) the runner's own residual grant would make it report another runner as active. A MUST the process cannot truthfully meet is not executable, and the fixture sentence "assert the refused runner emits the `STO-55` migration diagnostic" has no source of truth for that field. Everything else in A is sound. B carries the same field.

**Why B fails beyond that.** It adds a deployment parameter and an in-process wait, which is a delay and resource-cost preference the owner has not taken. It duplicates the deployment's own retry, the mechanism the set chose for the engine when the pv-oehp decision accepted "indefinite replacement/startup delay" through supervisor retry. Its timer is also ambiguous in one reachable case: the episode "ends only on obtaining a confirmed usable reservation", yet the bound excludes "connection checks after a grant", so when a granted connection fails STO-7's new-connection check and is "closed unused", the text does not say whether the episode is over or still running.

**Why C passes, and what it leaves.** C lands the policy at the owner, points from STO-13, and adds fixtures that distinguish the lock wait. It does not say "at once" and states no bound, so an implementation that waits internally for a while and then exits conforms. The fixture detects only eventual exit: a never-exiting runner hangs the test, a runner that waits a while passes. That is the same property the engine's startup clause has in the base, so C is not worse than the set's precedent, but it answers the row's "with what bound and observable failure report" with no bound and no report.

**Why D fails.** No sentence in the pin says the startup clause covers `migrate`, and the one quotation of it binds it to the engine. Calling the omission intentional leaves the bead open as filed.

## Traces

**Initial acquisition.** The authority refuses before any dial. No grant exists, so nothing is charged by this attempt and the exit releases nothing. Under A′ and C the runner exits non-zero. Under B it polls with backoff until its bound. Fixture (a) detects the policy if the harness owns the authority: it counts admission requests, checks the primary for no new backend, and reads the exit. A′'s "at once" is observable as exactly one request and exit before any capacity release. B's "single unreset elapsed bound" is observable by refusing throughout and asserting exit at first refusal plus bound regardless of request count.

**Second runner denied before connection.** Runner one holds STO-12's key mid-migration. Runner two asks for a reservation and is refused. It never holds a connection, so it never requests the key. Fixture (b) detects this through the absence of a second backend and a second lock waiter. All three packages separately admit both runners and assert the second waits on the key, which is the right control for the already-connected case.

**Reconnect after a recorded completed migration.** Migration k is recorded. The transport dies. The old backend's grant stays charged, since "Timeout, transport loss, process exit and rollout completion never release a grant". The replacement request is refused. The runner exits. Fixture (c) detects the policy and the accounting: the version table shows k recorded and k+1 absent, charges persist through exit, and a later invocation after fenced release resumes at k+1 without re-applying k, which CNF-57's existing no-op re-run already demands.

**Already-connected SQL lock wait.** Governed by STO-12, not by any package. Each package's control case asserts the second runner waits on the key. B's claim that "the admission-refusal timer does not run merely because it waits there" is observable only by waiting past the bound and asserting no exit.

**Exhaustion while the previous release serves.** The previous release's pools are already admitted sessions, and "Existing admitted sessions may continue". Each fixture asserts an engine write and an `api` write succeed on retained sessions and that no `SyncRep` backend is cancelled. This detects that the migrator's exit neither releases nor cancels anything, provided the harness provokes no reconnect in the previous release during the test, which the fixtures' "independently of the denied migration attempt" wording covers.

## Deletion and weakening check

A, B and A′ are pure insertions. No existing sentence changes, so no quotation, theorem or fixture loses its anchor. C replaces the block at `05-persistence.md:312` with its six original sentences intact plus one inserted sentence. I verified that OPS-47's quotation at `03-operation-lifecycle.md:138` and both quotes inside the block still match the pin. The obligation gate's pattern matches nothing in any candidate paragraph. No rendered-region marker touches the three landing sites. No Lean docstring quotes the refusal block. The STO-13 declarations quote the `CONCURRENTLY` sentences and the backfill population sentence, none of which any package touches, and Migration.lean models migration shape only.

Two substantive additions deserve naming. A and A′ add a new deployment MUST NOT at STO-13, that no component of the new release starts "until the required migrations have completed successfully". The base says only that `migrate` is "run by the deployment before any component of a release starts", and a component started early self-corrects by exiting on an older schema. The new sentence strengthens "run" to "completed successfully". It agrees with the backfill order and ADR-0024 and generalizes an assertion CNF-57 already makes for the backfill. B adds an OVR-19 row and a validated parameter. Neither contradicts a checked verdict, but both are substantive under rule 3, not editorial.

A landing detail: the STO-55 insertions must carry the bullet's two-space continuation indentation that lines 312 to 317 use. The brief prints them unindented. The STO-13 anchor at line 1576 is correct.

## Requested counterargument for no change

The set already makes a refused migrator harmless: it cannot dial without a grant, exhaustion is alarmed at OVR-18, every component refuses an unmigrated schema and exits into its supervisor, and STO-12 makes any re-run resume. Whether `migrate` exits or waits, the release cannot advance unsafely, and the deployment's own job timeout bounds any wait. The exit code of a deployment step is tooling, like the invocation cadence the brief itself leaves outside. The engine's startup clause carries no bound either, so demanding one for `migrate` is asymmetric. The reply is that the bead is about a deployment being unable to tell which behavior to expect, and safety is not the question. This is a counterargument, not my vote.

**Premise check.** Every quoted span in the brief is byte-identical to my pin, the line anchors are right, and the bead is open with the needs-triage label in the pinned tracker. OPS-47's quotation strengthens the brief's premise rather than contradicting it. No candidate contradicts its own test except through the unknowable diagnostic field in A and B. One residual outside this bead: no package states what `migrate` does when a granted connection fails STO-7's check, when STO-13's lock_timeout retry count is exhausted, or when a statement errors. That is a follow-on finding, not a defect of this question.

## Owner questions

1. Does the owner want an observable failure report from `migrate` at all? That is the fork between A′ and C. Both exit at once without a parameter; only A′ requires a diagnostic and the explicit STO-13 release-boundary MUST.
2. B's "Migration admission-retry bound" and its in-process wait are a new delay and resource-cost preference. Nobody has adopted it. If the owner wants an internal wait, B needs a re-reviewed form that resolves the failed-unused-grant episode question.

## Exact alternative A′

Identical to A except the diagnostic sentence in the STO-55 insertion. Landing sites and indentation as the brief specifies for A.

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
acquisition or reconnect, and the admission-refusal reason as the authority returned it,
without credentials.
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

No new parameter, identifier or ADR. The only difference from A is the diagnostic field, so A′ and A are distinct forms for the tally.
