**Final: Q1 O**

I prefer the complete printed O: report the refusal and exit immediately, leaving reinvocation to deployment. It preserves A’s timing, release boundary and fixtures without requiring peer-runner information whose source the current contract does not define.

| Exact form | Judgment |
|---|---|
| A | **ACCEPT** |
| B | **CANNOT ACCEPT** |
| C | **CANNOT ACCEPT** |
| D | **CANNOT ACCEPT** |
| F | **ACCEPT** |
| O | **ACCEPT — preferred** |

These are separate acceptability judgments, not a combined tally or adoption. I read `notes.md` whole and verified HEAD as `3109b5b44eae17e288cf52aaa976993bd8c5626c`. No files, Git state, tracker or panel records were changed; no gates or builds were run.

**Diagnostics and the exact alternatives**

**A:** I retain acceptance, but qualify my earlier reasoning. Its requirement to identify “whether another migration runner is active or scheduled” introduces an information obligation without defining its source. [STO-55](https://github.com/douglaz/provisiond/blob/3109b5b44eae17e288cf52aaa976993bd8c5626c/05-persistence.md#L285) says “Bind grants to component/attempt identity” and “The enforcement construction is the deployment’s”; neither supplies peer status.

The counterexample defeats using charges as liveness: R1 crashes, its grant remains charged, and R2 is refused. STO-55 says “Timeout, transport loss, process exit and rollout completion never release a grant.” Reporting R1 as active solely from that charge would be wrong.

That does **not** prove no deployment can supply truthful scheduling or execution context independently of database admission. A imposes additional integration work; it does not inherently contradict the base. Its fixture must compare the diagnostic with actual deployment context, not infer liveness from reservations. I prefer O because that additional information is unnecessary to report the refused invocation.

**F:** Accept exactly. Its “admission-refusal reason as the authority returned it, without credentials” ties the diagnostic to the actual refusal. Both parts apply: this is not permission to dump credential-bearing responses. A deployment-controlled authority can provide a credential-free reason. F adds no peer-status obligation or timer.

**O:** Accept exactly. It requires the actual “admission-refusal reason, without credentials” without additionally prescribing that reason’s returned form. I prefer this smaller diagnostic obligation. F and O remain different candidates; accepting both does not merge them.

Removing A’s peer field relinquishes **A’s proposed additional observability**. It removes no pinned requirement or existing checked assertion. That is a substantive difference between candidates, not an editorial repair made to clear a review.

**B:** The printed rule and recovery fixture demand incompatible outcomes on the stated trace. B’s proposed STO-55 says:

> “If no confirmed reservation is obtained before the bound expires, `migrate` MUST report exhaustion and exit non-zero.”

Its proposed CNF-57 says:

> “with verified capacity release before expiry … continuation without first exiting”

At first refusal, start a ten-second episode. Repeated refusals lead to backoff or a pending authority call. Verified capacity release occurs at 9.9 seconds, but no reservation is confirmed before ten seconds. The rule requires exhaustion and exit; the recovery assertion requires continuation. Capacity availability does not establish acquisition. The packet supplies neither response timing nor backoff guarantees.

Allowing exit in that recovery fixture would weaken its printed continuation assertion; extending the episode would weaken its exhaustion bound. Neither is an accepted repair here. There is no collateral baseline verdict flip: this conflict belongs to B’s new rule and fixture.

“Confirmed usable reservation” also needs care. B excludes “transport or connection checks after a grant,” so it cannot mean a connection has already passed those checks. [STO-7](https://github.com/douglaz/provisiond/blob/3109b5b44eae17e288cf52aaa976993bd8c5626c/05-persistence.md#L194) says an unsuccessful check means “the connection is closed unused.” Reading “usable” as reservation authorization can reconcile these sentences, but cannot cure the capacity-release fixture conflict.

**C:** Its exact “exit non-zero for deployment retry” permits refusal, an arbitrary finite internal pause, then nonzero exit. Its fixture checks the exit but states no timing rejection for that pause. Assigning the later invocation to deployment does not itself prohibit waiting before the current invocation exits.

That could be an intentional, owner-approved contract. I cannot accept it as this question’s complete timing answer. This is a strength choice, not a contradiction with a pinned MUST or a claim that C removes an existing protection. I do not silently import “at once” from A/F/O.

**D:** I cannot accept leaving the outcome unresolved as the resolution of `pv-3zzo`. An intentional scope decision remains available to the owner, but would leave the gap open.

**Traces and fixture verdicts**

1. **First acquisition.** Admission refuses before a grant authorizes dialing. A/F/O require the diagnostic and immediate nonzero exit; B starts its bounded retry episode; C requires nonzero exit without explicit promptness; D adds no migration-specific outcome. Fixture (a) observes the denied attempt, absence of dial/SQL, diagnostic where required, process result and absence of migration completion.

   A/F/O’s “at once” is a prohibition on deliberate waiting/retrying after refusal, not a numerical wall-clock deadline. One authority call alone does **not** establish promptness: a process could sleep afterward. The fixture needs evidence of the refusal-handling path as well as call counts and exit. These forms do not bound the authority’s first response or overall rollout duration.

2. **Second runner denied before connection.** R1 holds the migration key; R2 is refused its own physical connection. R2 never reaches an SQL lock request. Fixture (b) distinguishes this from connected contention by observing no R2 dial or SQL while R1 remains independently admitted. A/F/O exit, B retries within its episode, and C exits without specifying the pre-exit interval.

3. **Reconnect after a recorded version.** Migration V completes and is recorded; transport fails before the next migration; replacement admission is refused. A/F/O exit without undoing V. The old grant remains charged under STO-55’s quoted retention rule. After properly evidenced release, a separately invoked runner obtains a fresh reservation and resumes through history inspection. Fixture (c) detects erased history, false completion caused by refusal, reapplication of V and release-on-exit errors. B instead permits continuation in the same invocation after timely confirmed admission, subject to its printed fixture defect.

4. **Already-connected migration-key waiting.** This is not admission refusal. [STO-12](https://github.com/douglaz/provisiond/blob/3109b5b44eae17e288cf52aaa976993bd8c5626c/05-persistence.md#L1529) requires a lock on “a fixed key distinct from `STO-51`’s” across “inspecting the history, applying a migration and recording its completion.” The separate admitted-pair fixture detects misclassification as refusal; B additionally tests that this wait does not start its admission timer. Existing CNF-57’s assertion that “the engine’s startup lock is untouched” remains.

5. **Exhaustion while the previous release serves.** Charged reservations fill C while adequate admitted previous-release sessions remain available. STO-55 permits “Existing admitted sessions may continue.” With the required standby available, the candidate fixtures demand actual engine and `api` write success. They detect stopping or disrupting the old release to accommodate migration admission; mere process survival would not satisfy them. They also require retained uncertain charges and evidence-based capacity release.

For B, sustained refusal exercises diagnostics, backoffs, invalid-setting rejection and a single unreset elapsed bound. Later pending admission calls cannot extend that bound. Its recovery branch is the defective part identified above. C’s fixture can observe eventual failure; a harness timeout does not manufacture a normative timing bound. D’s absence of new tests is not a contradiction.

**Protected obligations and independent change judgments**

The existing protections remain material:

- STO-55 requires a “distinct durable reservation before dialing” and prohibits “bypass and redial under one reservation.” No candidate permits retry to reuse an old grant.
- STO-7 says the deployment “MUST NOT cancel or terminate a primary backend while it waits for a standby … other than by shutting the primary down.” No candidate authorizes eviction to make room. A/F/O introduce no sent-COMMIT deadline; B says its bound “MUST NOT cancel a sent COMMIT or release a grant.”
- [STO-13](https://github.com/douglaz/provisiond/blob/3109b5b44eae17e288cf52aaa976993bd8c5626c/05-persistence.md#L1595) requires the exceptional backfill to stop previous components and “only then permit the first new-release component to start.” The service-success fixtures use a concurrent-safe release; they do not override exceptional ordering.
- [OPS-49](https://github.com/douglaz/provisiond/blob/3109b5b44eae17e288cf52aaa976993bd8c5626c/03-operation-lifecycle.md#L1925) scopes its retry population to “a worker, or … a periodic component running in the engine process.” It supplies no migrator retry loop.

The wording-exception dimensions are independently substantive:

| Dimension | Assessment |
|---|---|
| Behavior | A/F/O require immediate reported failure; B permits bounded internal continuation; C specifies failure while leaving pre-exit delay open. D changes nothing. |
| Normative requirement | A/F/O add reporting and the explicit successful-migration release boundary. B additionally mandates a validated registered bound. C explicitly assigns migration refusal an outcome. D adds nothing. |
| Check strength | A/B/C/F/O add distinguishing CNF-57 fixtures; their timing and diagnostic strengths differ. D preserves existing strength. |

Textual inspection found no existing theorem or conformance verdict made unreachable or vacuous. `Migration.lean` models migration shape; `Restore.lean`’s `migrateCreate` and `claimed_legacy_create_stays_unresolved` concern backfill population and restart classification. No candidate changes those statements, hypotheses or populations. This is not a formal-build result.

**Requested counterargument for no change — not my vote**

STO-55 already says “Startup acquisition refusal exits for supervisor retry”; initial migration acquisition could be read broadly as startup. Existing admission prevents unauthorized dialing, STO-13 requires components to “exit non-zero” on an older required schema, OVR-18 says “Admission exhaustion and accounting loss MUST be alarmed,” and STO-12 supplies tracked resumability. These protections can preserve safety while deployment tooling chooses failure handling.

The initial-startup reading still does not settle reconnect after a recorded migration. Alternatively, the owner can deliberately leave that outcome to deployment. Neither position requires inventing a deployment timeout absent from the contract.

**Rule 6**

No verified brief error changes the missing-outcome premise; I identify no basis to void this tally. Candidate defects remain reportable without becoming a new void rule. Sol’s prior B acceptance relied on treating release before expiry as sufficient recovery; the trace above defeats that reason. Prior statements that C exits “at once,” or that C/F/O need no owner approval, must not carry forward.

**Owner approval: For `pv-3zzo`, adopt exact r87b Q1 O—amending `STO-55`, `STO-13` and `CNF-57`—so a refused updater reports why and stops immediately, and deployment invokes it again later?** This adds no parameter, identifier, ADR or formal declaration. Panel-launch approval did not authorize this policy.