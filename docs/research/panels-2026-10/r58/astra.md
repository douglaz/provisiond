**Pick A, with bounded recording and a suspension-parent exception.** Preserve OPS-49’s exits. A surviving cancellation outside that loop must enter guarded settlement. Retain worker position, shield settlement from the initiating cancellation, and bound cleanup/recording, including the store-retry budget. A cancelled parent defers. Avoid discarding evidence that releases a customer’s commitment.

**The bead has not established B’s conformance.** The algorithm routes `outcome = execute(op)` through classification and settlement. OPS-22’s “A **worker** recording a settled state MUST” constrains writes, not whether cancellation produces an outcome. Crucially, ADR-0022 says “cancellation under `OPS-21` is an outcome the owning worker records”. OPS-5 says a running operation “stays claimed until it settles, defers under `OPS-8`, or the startup pass finds it”. B is defensible as process interruption, not clearly as an ordinary handled outcome. CNF-361’s “assert nothing about one it does not” supplies no permission.

Claims 1–7:

1. Crash divergence is real: CNF-361 says “a restart in that same window instead enters `needs_reconciliation`”. That does not justify discarding live knowledge. “Only graceful stops” is unestablished: OPS-21 specifies no trigger.
2. OPS-45’s “a failure a worker recorded” distinguishes recording from interruption, not cancellation from failure. Pv-9j6 compares conflicting classifications of the **same recorded failure**: “it records a cut-off `conflict`”.
3. Real wording conflict: OPS-21’s “except for the create case below” overlooks install’s “for any failure at all” marker exception—and refresh’s “Always `failed`”. Route cancellation through the complete classifier.
4. Conditional on prohibiting every recorded cutoff. C must explicitly supersede ADR-0022’s quoted contract. Retain ADR-0043’s non-cancellation create rule; closing pv-f7a depends on eliminating every recordable cutoff.
5. Yes, for discarded, still-running work: OPS-15 says “nothing but a restart can leave a `running` row with no worker behind it”. A surviving engine cannot orphan it.
6. Only for identical durable state. OPS-49 itself allows “the row is already written, the money already posted once”; its last lost reply can leave nothing for startup to classify. Preserve the loop.
7. Yes against unqualified A: the parent is “Never `needs_reconciliation`, and never `failed` as a whole”; OPS-15 says “MUST be returned to `queued`”. Explicit guarded deferral solves the surviving-process case.

Decide **with pv-f7a**: recording needs a valid wire reason. Decide pv-9j6 separately; its marker conflict also affects network/timeouts and survives C.

**Edits owed:** OPS-21 and worker algorithm; OVR-19’s validated drain bound; WIR-9a’s cutoff reason and fixture; CNF-361’s mandatory recording, reason and first-step-8-commit cases; CNF-294’s cancellation/lost-reply cases; CNF-31a/b’s cancellation matrix; CNF-272’s parent deferral; bound-validation conformance. Use a **new ADR** for cross-kind cancellation, with README indexing and pointers from ADR-0022/0043. Add a cancellation/drain model composing Claim/Tables, its import, Witnesses traces, and a rendered OPS-21 region through Render; retain `Failure.cutOff`. Add `ci.yml` controls for skipped recording and unbounded draining.

**Experiment:** baseline, [the unbounded MUST mutation](/var/tmp/provisiond-panel-r58/astra/r58-unbounded.patch), and restored-tree gates all exited **0**. [No gate rejected it](/var/tmp/provisiond-panel-r58/astra/r58-mutant-gates.log). Tracked files are restored. Negative controls should catch healthy-store abandonment, indefinite draining and forced parent failure while preserving crash/retry-loop exits.

**B advocate:** Let runtimes choose whether shutdown drains; startup supplies conservative recovery, and the negative window bounds retention.

**C advocate:** Treat interruptions uniformly, eliminate optional cleanup writes and cutoff reasons, and reuse startup recovery.

Before step 8, outcomes converge only after restart; release timing still differs. OPS-33 also specifies an “operator search, not an automatic one” on uncorrelated channels.