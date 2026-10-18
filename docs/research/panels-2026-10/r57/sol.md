1. **B**, with an explicit store-error exclusion. This is a classification of a recorded failure; its home is `OPS-11`: “On failure, the system MUST classify”. Keep the restart exception separate.

2. **Claims 1–6:**  
   **1:** Commit and acknowledged progress differ. `OPS-43` says “Step 9 MUST begin only after step 8's transaction is acknowledged.” Commit → lost reply leaves the column set while the worker remains at step 8. `OPS-49` requires “repeat the **whole transaction**”; exhaustion exits rather than classifying that store failure. No create-defer counterexample found. Keep the ordinary settlement guard.  
   **2–3:** Preserve reported kinds; include cut-off `conflict`; change retryability only for newly reclassified failures. Release atomically, without fee/unit debits or pending obligations, and free the resource-offer exclusion. `STO-3` requires the status write to “precede[] every money write in the transaction”.  
   **4:** A free before-step-8 Boolean admits contradictory accepted/before inputs. Constrain those inputs explicitly; preserve `accepted_never_failed`.  
   **5:** A unnecessarily broadens scope. C’s analogy fails: `PRV-13c` says “MUST NOT change the create's settlement”; this amendment chooses its settlement.  
   **6:** Keep the named beads separate. `pv-p1y` still owns the missing kind, although B removes its status divergence.

3. **Edits owed:** `OPS-11`’s split row and acceptance-scope wording; `OPS-21`’s “cancellation MUST be treated as an ambiguous outcome” exception; **`OPS-45`’s execution-knowledge discussion**; synchronize `OPS-43`/`OPS-23` classifier quotations without changing their settled rules. Extend `LDG-32`/`LDG-39` through references to the live case.

   Amend `CNF-31a`, `CNF-31b`, and **`CNF-323`**, which repeats “a pre-send `network` failure remains ambiguous”. Add cases covering affected kinds, cancellation, retryability, atomic release/repeat, exclusion release, no mutation/reconciliation, and post-step-8 controls.

   Prefer a **new ADR**, indexed in README, with pointers from 0035/0042; retain Q11’s order-request case. Update `Tables.lean`, totality/acceptance theorems and `Witnesses.lean`; add a rule switch and `ci.yml` mutation requiring the intended witness’s refutation.

4. **Experiment:** a Markdown create row settling `failed` after a preceding null-column read passed every gate. Baseline/mutated/restored exits: **0/0/0**; tracked files restored. Retained patch (`/var/tmp/provisiond-panel-r57/sol/r57-wrong-null-read.patch`, not committed) and log (`/var/tmp/provisiond-panel-r57/sol/r57-wrong-null-read-gates.log`, not committed). A control must reject cached-null → step-8 commit → order → timeout; separately catch omission of cut-off `conflict` and disabling B.

5. I found no required equivalent pre-read. Robot cancellation “MUST NOT issue `GET /server/{n}/cancellation` as a pre-read” (`PRV-13`); PTR compares the “machine's recorded value” (`PRV-25`); attachment listing follows “every delete that succeeds with the resource gone” (`PRV-45`). A demonstrated driver-internal case deserves a separate bead.

6. **Status-quo advocate:** Keep it parked. `OPS-11` warns that “defaulting to `failed` invites a caller to retry a mutation that may have happened”. Conservative parking avoids duplicate purchases when progress accounting fails; `OPS-33` already requires bounded commitment release.