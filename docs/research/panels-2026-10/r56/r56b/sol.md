1. **Pick:** **1**: a separate timestamp preserves the pair’s meaning as provider data.

2. **Claims:**
   - **B1 stands** as a consolidation argument; option 1 owes consistency between the writes, enforced by their shared transaction.
   - **B2 stands:** `none` already exists in the descriptor.
   - **B3 stands:** option 1 still owes the `API-63` entry-test change and a `PRV-26` clarification. My edit leaves the pair null on `none` channels and retains any generated fingerprint in `request_summary` as operator evidence.
   
   **Decider:** A1’s provider-fact boundary: `PRV-26` requires “It MUST be opaque and unique per operation”. Adding a progress column costs less semantic change than widening that contract.

3. **What would change your mind:** A checked three-state contract for the pair, with consumer tests proving `none` never reaches lookup or machine rows and fingerprints survive independently, would change my pick.

4. **Plant:**
   - **Normative:** added `create_order_ready_at`, the guarded restart exception, channel clarification, conservative backfill, conformance cases and Lean startup/witness changes — exit **`0`**, **nothing red**.
   - **Bad:** omitted legacy backfill in Markdown and Lean, leaving previously dispatched creates null — exit **`1`**, **formal red**: `claimed_legacy_create_stays_unresolved` was refuted; citations and regions were blocked.

   Baseline exit: **`0`**. Saved `r56b-normative.diff` (normative edit; machine-local, not kept) and `r56b-plant.diff` (combined plant; machine-local, not kept). The intentionally bad edit remains. Lean belongs here because `passOp` encodes the changed startup disposition; its worker-transaction and money-release omissions remain explicit.

5. **ADR, tie-break:** **New ADR `0042`**, amending `0016`, with a dated pointer in `0035`’s rejected bullet. The [README index](https://github.com/douglaz/provisiond/blob/129217493eec9a1ad53278bbc24ae3b1b32995af/README.md#L90) uses “Amends `0016`” for a separate subsequent decision. `0035`’s inline amendments provide the alternative precedent, but this decision changes startup recovery. **Shape-independent.** Verified `0042` is absent from both the index and ADR directory.

6. **pv-qga, tie-break:** **No blocking dependency.** I expect its failed claim-time read to settle `failed`. The live worker knows it has reached no mutation; the restart path needs a durable record because that execution knowledge has died. Decide their semantics together without requiring pv-k4l’s closure before pv-qga work.