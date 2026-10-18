1. **(a) New `OVR-19` Stop-record bound**, finite and positive, covering cancellation through recording, including the first write and serialization churn; the supervisor must allow it. **(b) Compose `Claim`/`Tables`, with witnesses** that compute classification and guarded recording before exit. **(c) Add CI mutations** removing recording, shielding and the bound; require the intended witness to fail.

   **03:1764 does not force one attempt.** Cancellation before entering a loop is not cancellation “during the retry loop.” Explicitly shield the originating cancellation; the first store error enters retries. Preserve subsequent loop cancellation and exhaustion as exits.

2. **S1 breaks:** `OPS-49` says serialization failures “do not consume the bound” and “A serialization failure is repeated at once.” Endless serialization failures defeat the proposed sum.

   **S2 breaks:** `Claim.lean` already says “No claim follows the exit: `exited` is absorbing under every outcome.” Recording can be computed rather than assumed; this still proves nothing about an engine.

   **S3’s “only” breaks:** removing the prototype’s bound produced Lean’s diagnostic “Tactic `decide` proved that the proposition … is false.”

   **L3 overreaches:** `AGENTS.md` says “one negative-control step per gate that has one”; this establishes controls per gate, without establishing semantic coverage of every rule. L1 and L2 stand.

3. Change **(a)** upon finding an existing total cancellation-to-record bound covering serialization churn; **(b)** upon finding an existing model already checking that composition; **(c)** if existing CI controls already reject these exact mutants.

4. **Yes.** `OPS-49`’s trigger, “A suspension parent waiting on its children”, excludes cancellation before the first child exists.

   “When `execute` for a `suspend_tenant` parent is cancelled outside the retry loop, the worker MUST return it to `queued` with `available_at` advanced using the guarded defer, preserving completed fan-out for its next claim, subject to the recording bound and `OPS-49`’s exits.”

5. **`execution_cancelled`**, asserted in `CNF-361` and every recorded cut-off `conflict`. It describes execution cancellation across kinds, including an install that parks after its marker. The qualifier distinguishes an execution from an end-date cancellation; `cancellation_committed` retains `WIR-9a`’s “Repeating does not revoke a committed cancellation”.

6. Baseline and temporary composition passed all gates (**0**). Planted **`bounded := false`**: **formal failed (1)** because `bounded_serialization_witness` was false; citations/regions were blocked. [Failure log](/var/tmp/provisiond-panel-r58b/sol/r58b-probe-bad-gates.log). Reverted the complete probe; final gates passed (**0**) and tracked files are unchanged. This checks the modeled policy; runtime cancellation and store-fault CNF tests must check the engine.