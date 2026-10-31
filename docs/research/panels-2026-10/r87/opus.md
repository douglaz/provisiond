**Final: Q1 C.**

When the connection authority refuses the database-update program a connection, the program should exit non-zero and let the deployment run it again. That is already what a starting engine or `api` does. A program that already has its connection and is waiting for the other updater's lock was never refused, and every form leaves it alone. C says this with the fewest new obligations.

A has the right policy, but its required diagnostic asks the refused program for a fact it cannot know. B's bounded internal wait is a coherent policy, but it has the same diagnostic flaw and adds a delay and a new parameter the owner has not chosen. D leaves a lost connection that a running `migrate` must replace (the reconnect case) with no outcome at all.

## 1. Acceptance

- **A — CANNOT ACCEPT** as printed.
- **B — CANNOT ACCEPT** as printed.
- **C — ACCEPT** (preferred).
- **D — CANNOT ACCEPT.**
- **A′ (printed in full at the end) — ACCEPT.** It is a distinct form and not my preference.

**Why A and B fail.** Both STO-55 insertions say: "The diagnostic MUST identify … whether another migration runner is active or scheduled".
- A runner refused before its first connection has no database session, so it cannot see who holds `STO-12`'s key.
- The only other source is the admission authority, whose "enforcement construction is the deployment's" (`05-persistence.md:299`).
- The authority's charges don't mean a live process. STO-55 says: "Unknown bindings remain charged. Timeout, transport loss, process exit and rollout completion never release a grant" (`:290–291`).
- "Scheduled" is the deployment's plan, and nothing passes it to the runner.

Concrete failure: runner R1 crashes after recording a migration, and its grant stays charged. The deployment invokes R2, which is refused. R2 must say whether another runner is active. "Active" would be false, and "not active" has no evidence behind it.

A's fixture (b) then requires "the refused runner emits the `STO-55` migration diagnostic". B requires both diagnostics to "carry every `STO-55` migration-diagnostic field". So each candidate's own test asserts an output the specification gives no way to produce.

B also has a smaller ambiguity: its episode ends on "a confirmed usable reservation", yet the bound covers "not transport or connection checks after a grant".

**Why C is enough on prompt exit.** C maps refusal to "exit non-zero for deployment retry". That is the same indicative wording the base uses for startup ("exits for supervisor retry"). `OPS-47` reads that wording as putting the retry with someone else: "an external supervisor that retries startup subject to `STO-55` admission" (`03-operation-lifecycle.md:135–138`). Giving the retry to the deployment rules out an internal admission retry by the runner, just as the base rules one out for the engine.

What C leaves open is small:
- It has no "at once", so a runner could pause before exiting. That changes no charge; the base startup clause has the same gap.
- Its list is closed. A `migrate` connection that is neither the first nor a replacement isn't named. `STO-12` requires no such connection, so this doesn't block.

**Why D fails.** See §4.

## 2. Traces

**(i) Initial acquisition.** The authority refuses and no reservation exists. STO-55 says every attempt "MUST receive a distinct durable reservation before dialing", so there is no dial and no SQL. No version is recorded.
- A: report, then exit once. B: a waiting report, backoff retries within the bound (each one its own admission call), then exit. C: exit non-zero. D: undefined.
- Fixture (a) catches each policy. A: one admission call, then exit. B: several calls across the bound, then the continuation if capacity is released before expiry. C: exit, then a normal re-run after release.

**(ii) Second runner refused before connecting.** R1 is admitted and holds the key inside a migration transaction. R2 is refused, never reaches the advisory-lock request, and so is not in `STO-12`'s wait.
- A and C: R2 exits, R1 finishes, and the release proceeds.
- B: R2 waits. If capacity is released, it dials on a fresh reservation, waits on the key (a SQL wait that does not run B's timer), then finds every version recorded and does nothing.
- Fixture (b) catches this. It must time R2's refusal inside R1's transaction-scoped hold, and "while an admitted runner holds `STO-12`'s migration key" says so.

**(iii) Reconnect after a recorded migration.** The runner's transport drops. The old backend and its grant stay charged, because transport loss never releases one and release needs fencing plus fresh direct-primary evidence. The replacement attempt is refused.
- A and C: exit. The re-run after verified release inspects the history under the key and skips the recorded migration.
- B: wait, then continue in the same process.
- Fixture (c)'s "No completed migration is applied again" (A) and "normal version inspection and completion" (C) catch a runner that cannot resume.

**(iv) Lock wait after connecting.** No admission refusal happens, so every form leaves this to `STO-12` and `STO-13`. Each form's "Separately …" assertion fails a runner that treats the lock wait as a refusal (an exit in A or C, a running timer in B). The existing "assert one waits on `STO-12`'s key" stays.

**(v) Exhaustion while the previous release serves.**
- Capacity C is full of charged reservations. The previous engine and `api` keep writing on sessions they already hold ("Existing admitted sessions may continue", `:309`).
- No individual `SyncRep` backend is cancelled, and `OVR-18` alarms the exhaustion.
- The fixtures assert those writes succeed and no new-release component starts. Under A and B that rests on the new explicit MUST. Under C it rests on the base `STO-13`: migrations "MUST be … applied by the deployable's own `migrate` entry point, run by the deployment **before any component of a release starts**".
- No fixture assumes a refusal allocates a grant, and none releases one on exit: "Retain all uncertain/residual charges through refusal and any runner exit."

**What the fixtures can measure.**
- A's "at once" is measurable as a single admission call. Promptness has no number, so it cannot be timed.
- C's "exits non-zero for deployment retry" catches a runner that never exits. A runner that asks again before exiting shows up in the authority's log.
- B's single unreset bound is measurable as the time from first refusal to exit, with refusals in between.

## 3. Deletions and weakening

- **A and A′:** insertions only. Every existing STO-55 sentence stays, so these quotes still resolve:
  - `OPS-47`: "Startup acquisition refusal exits for supervisor retry"
  - `OPS-49`: "worker/periodic acquisition refusal is an `OPS-49` store error"
  - CNF-372's consumer list
- **A's new `STO-13` MUST** only strengthens. It matches the backfill's "only then permit the first new-release component to start" and the shared-predicate stop, and it says both keep their order.
- **Exit "at once" fits `STO-7`.** `STO-7` says: "short of its process exiting, a deadline or a cancellation … MUST NOT release its connection" (`:179`). Process exit is the stated exception, and A adds no deadline.
- **B:** "applies instead of the startup acquisition-refusal outcome above" changes `migrate`'s outcome only if that clause ever reached `migrate`. No current test covers `migrate` there, since CNF-372's "Exercise startup refusal and supervisor retry" names no `migrate` case, so no checked verdict flips. The new OVR-19 row follows the existing "no — the migrator's, read at `migrate`" row.
- **C:** all six base lines stay verbatim and one sentence is added. The only change is that `migrate`'s retrier is the deployment, not a supervisor.
- **D:** loses nothing; the gap stays open.
- **Formal layer:** nothing in `tools/formal` is tagged `STO-55`. `Admission.lean` tags API, WIR, SEC and LDG ids. `Migration.lean` checks migration shape. The `STO-13` backfill theorems (`Restore.lean:646–655`, `Witnesses.lean:1284`) model the backfill, not refusal. No option makes a theorem unreachable or vacuous.
- **CNF-57:** no assertion is removed; the insertions go before "Then the concurrent index step".
- **Rule 3:** no option has a blocking loss. The A/B defect is in their new text, not a lost base obligation.
- **Landing (mechanical, not a vote point):** the printed STO-55 texts are flush-left, but the refusal block is a two-space continuation inside "The sum fits…". Landing must keep that indentation.

## 4. Requested counterargument (not my vote)

**The case for D.** ADR-0024 makes `migrate` "one binary, one more way to invoke it". Each invocation is a process starting, so its first connection is startup acquisition and "Startup acquisition refusal exits" already covers the first and the second runner. `STO-12`'s resumability makes a re-run safe. The deployment sees the exit status, and `OVR-18` alarms "Admission exhaustion". STO-55 already accepts "indefinite replacement/startup delay" (`:323`). CNF-372 already checks grants for "migrators and waiting runners".

**Why it fails.**
1. "Supervisor retry" names a retrier. `OPS-47` binds it to the engine's supervisor, while `STO-13` says `migrate` is "run by the deployment", and `00-overview.md:137` puts it before "a release's components start".
2. A reconnect inside a running `migrate` is not startup. `OPS-49` is scoped to "a worker, or by a periodic component running in the engine process", and `api`'s request path does not apply. The "indefinite … delay" sentence even allows a `migrate` that waits forever, which is the bead's own gap.

**Premise check.** No brief error changes the question's premise, so rule 6 voids nothing. Every quoted block matches the pin, and the brief's "no formal declaration" claim holds.
- B's "instead of" wording assumes the startup clause otherwise reaches `migrate`, which the brief rightly says no quote shows. The wording is harmless.
- A's and B's diagnostic conflicts with their own fixture (b), as shown in §1.
- The brief leaves out `OPS-47`'s gloss on "supervisor", which supports its premise.

## 5. Owner question

If C or A′ settles, no owner question is needed: neither adds a delay or resource cost. The refused runner exits at once, as startup already does. B's internal wait and its new "Migration admission-retry bound" are the only new delay or parameter. If unsettled, ask:

> When the connection authority refuses the database update program, should it fail at once and let the deployment re-run it (**C**)? The same, plus a required message naming the program, the release, initial-or-reconnect and the authority's reason (**A′**)? Or keep asking for a configured time first (**B**, whose diagnostic needs repair before it can be accepted)?

## A′ — exact alternative (ACCEPT, not preferred)

A′ is A with one clause deleted from the diagnostic sentence. Placement is identical to A.

**STO-55 insertion:**

```text
**Migration admission refusal.** If `STO-55` admission refuses a physical connection attempt
by the `migrate` entry point, including initial acquisition, acquisition by a runner scheduled
alongside another runner, or reconnect, `migrate` MUST report the refusal and exit non-zero
at once; it MUST NOT wait or retry admission internally. A later invocation is a deployment
retry; see `STO-12` for version inspection, serialization and resumability. The denied attempt
MUST send no dial and no SQL. It MUST NOT record a migration as completed because of that
refusal, and the refusal does not undo previously recorded completed migrations.
The diagnostic MUST identify `migrate`, the release being attempted, whether this was initial
acquisition or reconnect, and the admission-refusal reason, without credentials.
This rule governs refusal before a physical connection is admitted, not a SQL advisory-lock
or DDL lock wait after connection. It introduces no deadline for a sent COMMIT or standby
wait; see `STO-7`. The grant-retention and release rules above still apply on process exit or
transport loss; neither is evidence that an old backend ended. Refusal does not require
stopping the previous release or terminating any individual backend to make room.
```

**STO-13 insertion:**

```text
For physical connection-admission refusal by the `migrate` entry point and deployment retry,
see `STO-55`. The deployment MUST NOT start any component of the new release until the
required migrations have completed successfully. The stop-everything and backfill exceptions
below retain their existing order.
```

**CNF-57 cases:**

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

A′ adds no OVR-19 row, identifier, ADR or formal change.
