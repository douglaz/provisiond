I prefer **A**: when admission refuses the updater’s connection, report why and exit immediately. Let the deployment invoke it again. This makes release failure observable without adding an internal retry timer.

**Final: Q1 A**

- **A ACCEPT**
- **B CANNOT ACCEPT**
- **C CANNOT ACCEPT**
- **D CANNOT ACCEPT**

These are judgments on the printed packages, not adoption. I verified the clone’s pin as `3109b5b44eae17e288cf52aaa976993bd8c5626c`, read `notes.md` whole and inspected the cited owning text and migration declarations. No files, Git state or tracker records were changed; no gates or builds were run.

1. **Acceptability and preference**

**A** supplies an explicit action, timing and report: “exit non-zero at once; it MUST NOT wait or retry admission internally.” Its release boundary and independent fixtures make that policy reviewable. It introduces no promise of eventual capacity or total rollout completion. Its diagnostic requires deployment/runner context, including the release and peer-runner status; that is additional implementation work, but I found no inherent contradiction.

**B** has a concrete rule/fixture conflict. Its rule says:

> “If no confirmed reservation is obtained before the bound expires, `migrate` MUST report exhaustion and exit non-zero.”

Its success fixture instead says:

> “with verified capacity release before expiry … continuation without first exiting”

Capacity release is not confirmed reservation acquisition. Consider a ten-second bound: the runner receives refusals, is in backoff or awaiting an authority response, and capacity becomes available at 9.9 seconds. At ten seconds it still has no confirmed reservation. The rule requires exhaustion and exit; the fixture requires continuation. Neither a particular backoff cadence nor an authority-response guarantee eliminates this permitted trace.

This is not an objection to bounded retry as a policy. The printed package demands incompatible verdicts on that trace. Making its success fixture require timely confirmed acquisition would change the reviewed fixture; I am not accepting that unprinted repair.

**C** explicitly assigns migration refusal an eventual nonzero outcome, but does not adequately settle the timing question. Its “exit non-zero for deployment retry” lacks A’s prohibition on internal waiting/retrying and B’s elapsed bound. A runner could wait internally for an arbitrary interval and then exit nonzero; C’s printed denied-capacity fixtures would pass. I cannot accept C as a complete answer to whether the invocation exits promptly or waits under a stated bound. This is incompleteness, not evidence that C deletes an existing protection.

**D** preserves the existing specification but leaves this bead’s outcome gap unresolved. I cannot accept it as the requested resolution. Deliberately leaving the policy unspecified would be a separate scope decision, not a fix.

2. **Execution traces and what the fixtures detect**

| Case from the candidate CNF-57 fixtures | A | B | C |
|---|---|---|---|
| Initial acquisition denied | Diagnostic and immediate nonzero exit; the no-internal-wait/retry assertion distinguishes the policy. | Waiting report, retries and exhaustion are tested. The early-capacity-release success branch has the conflict above. | Tests nonzero exit, but cannot distinguish prompt exit from waiting first. |
| Second runner denied before connecting | Exits without requesting the migration key. The independently admitted first runner separates admission refusal from lock contention. | Same separation; denial starts the retry episode. Both expiry and recovery branches are requested, subject to the success-fixture defect. | Correctly separates admission from SQL locking, but leaves exit timing undetected. |
| Reconnect after a completed migration | Exits; a separately invoked runner inspects history and resumes. The fixture checks that previously completed versions remain unchanged and are not applied again. | Waits within the episode, continuing if a reservation is confirmed in time, otherwise exits. The printed recovery assertion incorrectly substitutes capacity release for confirmation. | Checks eventual exit and subsequent deployment invocation, without testing internal-wait duration. |
| Already connected, waiting on the migration key | Separate admitted-connection fixture correctly rejects misclassification as admission refusal. | Explicitly checks that the admission timer does not run merely for this SQL wait. | Also distinguishes the SQL wait from physical-admission refusal. |

D adds no such outcome fixtures. That absence is not a contradiction in the unchanged base.

For capacity exhaustion, the candidate fixtures retain adequate admitted previous-release read/write sessions and require the standby needed for successful writes. This is a reachable setup: charged reservations exhaust new admission without requiring the existing sessions to disappear. The candidates then assert actual engine and `api` write success, rather than treating process survival as service success.

The relevant existing permission is [STO-55](https://github.com/douglaz/provisiond/blob/3109b5b44eae17e288cf52aaa976993bd8c5626c/05-persistence.md#L308): “Existing admitted sessions may continue.” Its accounting constraint is “Timeout, transport loss, process exit and rollout completion never release a grant.” Accordingly, a denied request need not allocate any grant, and exiting the refused runner cannot free an earlier uncertain or residual grant. The candidates’ capacity-release steps must operate on previously charged reservations using the prescribed evidence.

The fixtures are conformance instructions, not evidence that a running implementation has passed them.

3. **Deletion, weakening and protected verdicts**

**A and B insert text; they delete no existing sentence.** Their STO-55 additions supply migration-specific outcomes, reporting, completion-history treatment and exclusions. Their STO-13 insertion supplies the explicit boundary:

> “The deployment MUST NOT start any component of the new release until the required migrations have completed successfully.”

B additionally supplies the retry parameter, validation and episode semantics. Its changed outcome is substantive: a refused invocation can remain alive and later continue.

**C replaces the refusal block but reproduces its existing protections**, adding the migration scope sentence. The retained clauses still assign startup exit, API overload and worker/periodic store-error handling; retain stop-record bounds; and prohibit terminating an individual waiting backend to make room. Its defect is the unresolved timing contract, not a removed clause.

**D changes no verdict or obligation.**

I found no existing conformance assertion or theorem made unreachable or vacuous by these packages. B’s identified conflict is between its *new* rule and *new* success fixture. A/C add coverage; D’s missing new coverage is not a blocking loss under notes rule 3.

The following constraints remain material:

- **Connection accounting — STO-55, `05-persistence.md`:** “Ingress MUST prohibit bypass and redial under one reservation.” The release condition requires “fencing every delayed arrival/retry and fresh privileged direct-primary evidence, read in a fresh transaction, that the bound backend ended.” A later deployment invocation or B’s later admission call cannot reuse a reservation or erase uncertain charges.
- **Startup-lock independence — STO-12, `05-persistence.md`:** the runner’s lock uses “a fixed key distinct from `STO-51`’s”. Existing CNF-57 requires that “the engine’s startup lock is untouched”. The added fixtures retain that case and add a separately admitted pair; refusal before connection cannot replace or satisfy the lock-contention check.
- **Standby waits — STO-7, `05-persistence.md`:** “short of its process exiting, a deadline or a cancellation … MUST NOT release its connection before the reply arrives or the transport is found dead.” A expressly introduces no standby/COMMIT deadline; B excludes those waits and says its bound “MUST NOT cancel a sent COMMIT or release a grant.” C changes physical refusal outcomes only. None authorizes clearing an old backend to obtain migration capacity.
- **Exceptional release order — STO-13, `05-persistence.md`:** a shared-predicate release “MUST stop every component of the previous release before the first component of the new one starts”. The backfill separately requires stopping previous-release components, filling the column, “and only then permit the first new-release component to start”. A/B expressly preserve these exceptions. Their statement that refusal does not require stopping the previous release adds no permission to restart an already stopped exceptional release. The new service-success fixtures explicitly use a release allowed to migrate concurrently.
- **Retry-loop scope — OPS-49, `03-operation-lifecycle.md`:** “Where a store call by a worker, or by a periodic component running in the engine process” defines the loop’s population. None of the packages exports it to `migrate`.

Textual inspection of [Migration.lean](https://github.com/douglaz/provisiond/blob/3109b5b44eae17e288cf52aaa976993bd8c5626c/tools/formal/Provisiond/Migration.lean) confirms that `transactional_holds_nothing_refused`, `large_index_is_standalone` and `no_home_without_standalone_rule` concern migration shape. [Restore.lean](https://github.com/douglaz/provisiond/blob/3109b5b44eae17e288cf52aaa976993bd8c5626c/tools/formal/Provisiond/Restore.lean#L646) defines `migrateCreate` and `claimed_legacy_create_stays_unresolved`; the corresponding witness distinguishes legacy backfill outcomes. These packages change neither those declarations nor their hypotheses or represented populations. No formal weakening is needed, and no conformance identifier belongs there.

4. **Requested counterargument for no change — not my vote**

The strongest argument is that [STO-55](https://github.com/douglaz/provisiond/blob/3109b5b44eae17e288cf52aaa976993bd8c5626c/05-persistence.md#L312) already says “Startup acquisition refusal exits for supervisor retry”, while its admission population expressly includes “migrators and waiting runners”. One could interpret every runner’s initial acquisition as startup and treat deployment reinvocation as supervisor retry, avoiding additional policy and reporting requirements.

That interpretation is insufficient for reconnect: the invocation has already started and recorded a migration. Nor does population membership determine the refusal outcome. [STO-13](https://github.com/douglaz/provisiond/blob/3109b5b44eae17e288cf52aaa976993bd8c5626c/05-persistence.md#L1555) places `migrate` “before any component of a release starts”; it does not explicitly equate its acquisition phases with component startup.

I found no verified existing rule that settles the whole question. B’s candidate inconsistency does not overturn the premise that the pinned migration-refusal outcome is missing. Under notes rule 6, I therefore identify no premise-changing brief error requiring this question to be voided. I make no tally.

5. **Owner question**

**For pv-3zzo, adopt the exact r87 Q1 package A—STO-55 insertion, STO-13 release boundary and CNF-57 cases—so a refused updater reports why and stops immediately, leaving the deployment to invoke it again?**

That choice accepts possible repeated deployment invocations and potentially indefinite overall release delay while capacity remains unavailable. B instead purchases an internally waiting process, repeated authority calls and a deployment-selected duration; its printed fixture conflict prevents accepting that exact package. Panel authorization adopted neither cost preference.