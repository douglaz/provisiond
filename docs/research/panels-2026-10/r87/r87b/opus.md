I've confirmed my clone is pinned at 3109b5b and checked the bead and the cited text against it. Writing the verdict now.

**Final: Q1 F**

In plain terms: when the connection authority refuses the database updater a connection, the updater should say why and exit right away, and the deployment decides when to run it again. F does exactly that. It drops the one report field that no defined source can fill, and it names where the remaining outside field (the refusal reason) comes from. In r87 I preferred C. Astra and Sol's trace changed my mind, as explained under item 2.

| Form | Verdict |
|---|---|
| **A** | **ACCEPT WITH THIS FIX:** delete "whether another migration runner is active or scheduled,". The result is O, byte for byte. Under the brief, this does not count for printed A. |
| **B** | **CANNOT ACCEPT** |
| **C** | **CANNOT ACCEPT.** I accepted C in r87; I withdraw that (item 2). |
| **D** | **CANNOT ACCEPT** as a resolution of pv-3zzo |
| **F** | **ACCEPT** (preferred) |
| **O** | **ACCEPT** |

## The five disagreements

**1. A's peer-runner field.** Astra is right that I have no proof that no deployment could supply this. A scheduler could pass its plan to the runner, and the authority could list migrator grants. The defect is narrower than impossibility, but it is real:

- **No defined source.** A puts the MUST on `migrate` but obliges nobody to supply the input. STO-55 says "The enforcement construction is the deployment's".
- **The one available source can answer wrongly.** Suppose an earlier runner R0 crashed. Its grant stays charged: "Unknown bindings remain charged. Timeout, transport loss, process exit and rollout completion never release a grant." A refused runner that asks the authority would report R0 as "active" when R0 is dead, and the operator would wait for a process that doesn't exist.
- **"Scheduled" has no carrier at all.** The authority sees requests, not schedules.
- **The fixture can't judge it.** A's "assert the refused runner emits the `STO-55` migration diagnostic" can check that the field is present, not that it is true.

Neither Astra nor Sol argued that the field is needed. Astra's defense was "no inherent contradiction". Removing it costs no protection either of them named.

**2. C's timing.** Astra and Sol's counterexample holds: receive a refusal, wait an arbitrary finite time, then exit non-zero. C's rule ("exit non-zero for deployment retry") and its fixture both pass that trace.

- The bead asks for more than C answers. It says the deployment cannot tell "whether that entry point exits, waits, or retries, what bounds apply, or how it reports that the release cannot advance". C settles the first part only.
- My r87 analogy to the engine was weak. The engine's refusal has OPS-47's supervisor ("retries startup subject to `STO-55` admission"); `migrate` has neither that supervisor nor any stated bound.
- C's fixture asserts that no component starts "before the required migrations complete successfully". C's rule only points at STO-55, and the base says migrations are "run by the deployment before any component of a release starts". "Run" is not "completed successfully", so C's check is stronger than its rule.

F and O close both gaps. Adding the timing to C would just produce F or O minus the report, so I don't propose a repaired C.

**3. Astra's B trace.** It is valid against the printed fixture:

- Take a 10-second bound with capacity released at 9.9 s. The runner is in backoff, or its admission call is unanswered, until after 10 s. B neither promises a backoff cadence nor bounds the authority's reply.
- B's rule then requires exit: "If no confirmed reservation is obtained before the bound expires, `migrate` MUST report exhaustion and exit non-zero". The fixture demands "continuation without first exiting".
- This is not about one unlucky release time. For any release time before expiry, a conforming implementation with sparse backoff fails the success branch. So the fixture can fail a conforming implementation, and the check is unsound.
- Secondary issue: the episode ends on "a confirmed usable reservation", yet the bound excludes "connection checks after a grant". A grant whose STO-7 connection check fails is "closed unused", and B doesn't say whether that ends the episode or extends it. B's fixtures keep admission denied throughout, so they never reach this case.
- I am not counting an unprinted repair, and B's waiting cost is a separate owner question.

**4. F and O.** I read both whole. They are identical to A except for the diagnostic sentence. Every field in each can now be filled from something defined:

- `migrate` and the release come from the runner itself.
- Initial versus reconnect comes from the runner's own state.
- The reason comes from the authority's response.

F's "as the authority returned it" names that last source. That is the same discipline that justifies dropping the peer field, and the fixture can compare the output against what the test harness's authority actually returned.

One theoretical tension: if an authority echoed a credential in its reason, "as returned" and "without credentials" would pull against each other. I read "without credentials" as governing, which means redact, and the deployment controls the reason text. It doesn't block.

I prefer F over my own O because F is the more precise form and Fable already picked it. Two authors converging on one printed form beats splitting.

**5. D.** See the requested counterargument below.

## Traces under F and O (A, B and C noted where they differ)

1. **First acquisition.**
   - No reservation means no dial and no SQL: every attempt "MUST receive a distinct durable reservation before dialing".
   - The runner reports `migrate`, release N, "initial" and the reason, then exits non-zero at once. It records nothing and has nothing to release.
   - Fixture (a) checks one admission request, no new backend, the exit code, and fields the harness already knows.
   - Under A the peer field is "no" here, but R0's residual grant would make the authority's answer "yes".
   - B polls until its bound. C exits after an unconstrained delay.
2. **Second runner refused before connecting.**
   - R1 is admitted and holds STO-12's key. R2 is refused, never reaches the lock request, reports "initial" and exits.
   - Fixture (b) catches a second backend or a second lock waiter.
   - R1 finishes and the release proceeds.
3. **Reconnect after version k is recorded.**
   - The transport is lost, so the old grant stays charged. The replacement attempt is refused, and the runner reports "reconnect" and exits.
   - k stays recorded and k+1 stays absent.
   - After a fenced release, the deployment runs `migrate` again. It inspects the history under the key and applies k+1 once.
   - Fixture (c) catches a changed k, a k+1 applied twice, or a charge released on exit.
   - The STO-55 startup clause can't cover this case, since the process has already started.
4. **Already connected and waiting on the SQL lock.**
   - There is no refusal, so the rule doesn't apply: "This rule governs refusal before a physical connection is admitted, not a SQL advisory-lock or DDL lock wait after connection." STO-12 governs.
   - The "Separately…" control catches a runner that exits while waiting on the lock.
5. **Exhaustion while the previous release serves.**
   - STO-55 says "Existing admitted sessions may continue", and OVR-18 says "Admission exhaustion and accounting loss MUST be alarmed".
   - The fixtures hold admitted read/write sessions and an available standby, then assert that real engine and `api` writes succeed and that no `SyncRep` backend is cancelled.
   - The refusal requires no stop of the previous release. The STO-13 insertion keeps the stop-everything and backfill order.

**Elapsed time.** F and O allow zero internal waiting after a refusal. A test checks this as no second admission request and no backoff before exit, not with a stopwatch. No form, including B, bounds the wait before the authority's first reply. That is authority silence, not refusal, and it is outside this bead.

## Three dimensions, F and O against the base

All three are substantive changes, so the owner must approve. None of them qualifies for the wording exception.

- **Behavior:** a refused `migrate` must report and exit at once, and retrying internally is forbidden.
- **Normative requirement:** new MUSTs on `migrate`, plus a new deployment MUST NOT at STO-13. It strengthens "run before any component of a release starts" to "completed successfully".
- **Check strength:** CNF-57 gains three fixtures and a control where both runners are admitted. No existing assertion is removed.

**Blocking loss:** none.

- Every change is an insertion, so these quotes still resolve:
  - STO-55 line 312, quoted by OPS-47 at `03-operation-lifecycle.md:138`;
  - OPS-49's quote;
  - CNF-372's consumer list.
- The Lean declarations tagged STO-12 and STO-13 quote the `CONCURRENTLY` and one-migration sentences, which are untouched. Nothing in `tools/formal` is tagged STO-55.
- The obligation gate's `OBLIG_RE` looks for a backticked ID immediately followed by MUST. The new text contains "`migrate` MUST", which isn't an ID, and "`STO-55`. The deployment MUST NOT", where the period breaks the match.
- STO-7 still holds: exiting "at once" falls under its "short of its process exiting" exception.
- No collateral flips. The new STO-13 MUST NOT agrees with the backfill's "only then permit the first new-release component to start".
- Landing note: the STO-55 text needs two-space indentation and the CNF-57 text needs six.

## Requested counterargument: no change (not my vote)

`migrate` is just another invocation of the same binary, so its first connection is a startup. "Startup acquisition refusal exits for supervisor retry" would then already cover it, and the deployment plays supervisor.

Safety doesn't depend on the outcome either:

- a refused runner cannot dial;
- exhaustion is alarmed;
- every component refuses an older schema;
- STO-12 makes a re-run resume.

STO-55 also already accepts "indefinite replacement/startup delay".

**Why it fails:**

- OPS-47 ties "supervisor retry" to the engine's "external supervisor".
- STO-13 has `migrate` "run by the deployment" before any component starts.
- A reconnect inside a running `migrate` is not a startup.
- OPS-49 covers only "a worker, or … a periodic component running in the engine process".

The bead's gap is what the deployment should expect, not whether the result is safe.

## Rule 6 (applied exactly as written)

I found no verified brief error that changes the question's premise, so nothing is voided.

- The bead's text matches the brief's description.
- The quoted spans I spot-checked match the pin: the STO-55 block (lines 285–317), "The enforcement construction is the deployment's", and OPS-47's quote at line 138.
- The flush-left printing of the insertions is a landing detail the brief itself addresses.

None of my votes rests on a brief error.

## Owner question

> When the connection authority refuses the database updater, should it immediately print who it is, which release, first connection or reconnect, and the authority's own reason, then exit with failure and never wait or retry on its own, so the deployment runs it again later? And should the deployment be forbidden to start the new release until the migrations have completed successfully?

Adopting this means taking exact r87b Q1 **F** for pv-3zzo: the STO-55 insertion, the STO-13 release-boundary insertion and the CNF-57 cases. It adds no new identifier, OVR-19 row, ADR or formal change. If the owner prefers it without the "as the authority returned it" wording, that is **O**. The approval to launch the panel authorizes neither form.
