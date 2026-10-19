1. **(a) New `OVR-19` row:** a startup-validated, finite positive **shutdown-record bound**, measured from cancellation without resets; the supervisor must allow it. This bounds serialization retries excluded from the store bound. Preserve `OPS-49`’s rules and exits; deadline expiry supplies a subsequent cancellation.

   **(b) Lean composition with witnesses:** classify through `Tables`, write/defer through `Claim`, distinguish ordinary exit from permitted abandonment, and render the exit/deadline rule. Prove consequences across traces, without assuming recording occurred.

   **(c) New CI controls:** disable recording/shielding and deadline enforcement separately, requiring corresponding witnesses to fail.

   **1764:** No automatic one-attempt rule. “cancelled during the retry loop” must mean a subsequent cancellation event, not re-delivery of the initiating cancellation. Explicitly shield the latter.

2. **Claims broken:**

   **S1:** `OPS-49`: “Constraint violations and serialization failures are not store errors” and “do not consume the bound”; “A serialization failure is repeated at once.” Repeated serialization failures can avoid entering the counted store-error loop altogether.

   **S2:** `Claim.lean` already says “No claim follows the exit: `exited` is absorbing under every outcome.” Process transitions are already modeled; assuming successful recording is unnecessary.

   **S3’s “only”:** `ADR-0025` requires “the bad trace is refused with the guard and admitted without it.” That can detect a missing modeled deadline. Runtime conformance remains necessary; checklist prose executes nothing.

   **L3’s universal:** `AGENTS.md` says “one negative-control step per gate that has one”, not per requirement. Structural gates can reject prose without a dedicated model. This change merits semantic controls independently.

3. **Reversal facts:** **(a)** an existing absolute deadline covering cancellation through recording, including serialization retries; **(b)** a prototype needing recording itself as a hypothesis rather than deriving it; **(c)** existing mutations demonstrably rejecting the new bad traces.

4. **Yes.** `OPS-49`’s trigger is “A suspension parent waiting on its children”; unfinished fan-out need not qualify.

   “A cancelled `suspend_tenant` parent, including one interrupted during fan-out, MUST record its deferral before engine exit by returning to `queued` with `available_at` advanced under the ordinary status-and-claim guard, subject to the recording bound and preserved store-retry exits.”

5. **`execution_cancelled`** distinguishes execution interruption from `cancellation_committed`. “Use **cancel** whenever an end date is involved” does not prohibit qualified execution cancellation. Apply it to every recorded cut-off, including an install parked past its marker; assert it in `CNF-361`.

6. [Planted](/var/tmp/provisiond-panel-r58b/astra/r58b-mutant.patch) a deadline that “restarts after each serialization failure.” **No gate went red:** baseline, mutation and restored-tree runs exited **0**. Reverted; tracked diff empty. A rendered deadline rule and no-reset witness should reject this specification mistake; runtime conformance must inject repeated serialization failures and assert exit against the original deadline.