**Pick A, bounded and scoped.** A cancellation that returns control outside `OPS-49` should reach classification and guarded recording before controlled exit, subject to explicit failure exits. Protect recording outside the retry loop; register and validate a finite drain bound. Parent cancellation retains restart recovery. The worker’s knowledge that step 9 never began remains useful even though a crash loses it.

Against the brief’s numbered claims:

1. **True about crashes.** `CNF-361`: “a restart in that same window instead enters `needs_reconciliation`.” Before step 8, B also delays release until startup; the difference is not solely error kind.
2. **The distinction exists; permission does not follow.** `OPS-45` says “an operation interrupted rather than classified is `OPS-15`’s”. pv-9j6 explicitly says “it records a cut-off `conflict`”: its disagreement concerns two classifications of a recorded failure.
3. **Confirmed textual conflict.** `OPS-21` says “except for the create case below”; `OPS-11`’s install row permits `failed` “for any failure at all” with clear markers. [Tables.installRow](/var/tmp/provisiond-panel-r58/sol/tools/formal/Provisiond/Tables.lean:165) agrees with the install row.
4. **Conditional consequence, not evidence for C.** Universal C would require withdrawing `OPS-11`’s “An `OPS-21` cancellation of `execute` stays a cut-off `conflict`.” Shutdown-only C would leave other cancellation paths and pv-f7a alive.
5. **Correct if cancellation abandons the worker.** `OPS-15`: “nothing but a restart can leave a `running` row with no worker behind it.”
6. **Scoped true for identical durable state.** `OPS-49` already qualifies recovery with “unless the bound's last repeat committed and its reply was lost”. This does not establish equivalence between recording and discarding.
7. **Valid against unqualified A.** `OPS-11`’s parent is “Never `needs_reconciliation`, and never `failed` as a whole.” A needs an explicit parent exception.

**B’s present conformance is unproven.** The algorithm routes `execute` outcomes through `classify`; `OPS-21` calls cancellation an “ambiguous outcome”. `ADR-0022` even assumes “cancellation under `OPS-21` is an outcome the owning worker records”. Conversely, `OPS-22`’s “A **worker** recording a settled state MUST” conditions a write rather than mandates one. `OPS-5` keeps the operation “claimed until it settles, defers under `OPS-8`, or the startup pass finds it”. Actual interruption is supported; deliberately discarding a surviving cancellation remains insufficiently explicit.

This adds no suspension trigger: `API-58` says a claimed create “MUST be allowed to settle rather than abandoned mid-order”.

Decide **pv-f7a together**: retain `conflict`; add a reason such as `execution_cancelled`. Keep **pv-9j6 separate**: recorded pre-dispatch timeouts expose its disagreement too.

**Edits owed:** `OPS-21` and algorithm; `OVR-19`; `WIR-9a` plus fixture; `CNF-361` recording, acknowledgement and deadline cases; `CNF-31a/b` cancellation cases; parent and drain controls alongside `CNF-29`, `CNF-194`, `CNF-294`; a new ADR, pointers from `ADR-0022`/`0043`, README index; a Lean cancellation model composing Claim/Tables, its import and paired witnesses; `ci.yml` mutations removing recording and bound enforcement. Preserve settled classifications.

**Experiment:** I left an intentionally unbounded MUST at [OPS-21:1714](/var/tmp/provisiond-panel-r58/sol/03-operation-lifecycle.md:1714). Baseline and mutated gates both exited **0**; no gate went red. Negative controls should reject discarded cancellations with a working store and recording handlers exceeding their bound, through the named witness.

**B advocate:** Permit both safe shutdown strategies; avoid mandatory shutdown writes and accept temporary commitment retention.

**C advocate:** Treat cancellation uniformly as process interruption. Reuse restart recovery, avoid cancellation shielding, and retire the cut-off error surface.