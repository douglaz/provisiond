1. **Pick:** **1**—keep permission to begin ordering separate from the provider artifact retained for investigation.

2. **Claims:**
   - **B1 — broken as an equivalence claim.** Persistence describes the pair as “what the create wrote into the provider”; `PRV-33` permits “`correlator: none`”. A set timestamp with a null pair can therefore be correct, not disagreement. The existing `API-63` entry convention does stand.
   - **B2 — stands.** The descriptor already admits `none`, and `OPS-38` says “A create that recorded none has no count”. Encoding that word in the operations pair still requires explicitly distinguishing absence of an artifact from absence of step 8.
   - **B3 — stands.** The additional column and write-once machinery cost something. Option 1 still owes a channel-content clarification in `PRV-26` and replacement of `API-63`’s entry test.
   
   **A3 decides my pick:** retain Robot’s unverified fingerprint as operator evidence without making its encoding control dispatch. My edit specifies that retention and excludes it from automatic cardinality. A1 overstates the changes needed: the machine pair and its index need no sentinel handling if the sentinel never reaches machines.

3. **What would change your mind:** An existing normative rule retaining the unverified per-order fingerprint independently of the pair, together with explicit exclusion of `('none', NULL)` from every automatic correlator consumer, would move me to option 2.

4. **Plant:**
   - **Intended edit:** added `about_to_order_at`, guarded and acknowledged step 8, atomic startup failure/release, restore exclusion, conservative migration, and correlator clarification; **exit 0, nothing red**.
   - **Bad edit:** changed timestamp retention to “MUST be cleared with `request` on the payload purge”; **exit 0, nothing red**.
   
   Baseline also exited **0**. `Restore.passOp` required a Lean change; I added restart, restore, set-timestamp, and missing-restore-guard witnesses. `irreversible` required no change. Purge remains outside that model; a modeled purge transition with a timestamp-preservation invariant would catch the planted defect.

   Saved cumulative edits in `r56b-plant.diff` (machine-local, not kept), with the good version separately in `r56b-good.diff` (machine-local, not kept). The bad edit remains planted.

5. **ADR, tie-break:** **New ADR**, amending `0016`, with a dated pointer in `0035`’s rejected bullet. README’s `0019` entry uses “Amends `0016`”; although `0035` has inline amendments, this changes startup disposition rather than acceptance classification. Shape-independent. **`0042` is unused in the index and ADR filenames.**

6. **pv-qga, tie-break:** **No blocking dependency.** I expect **`failed` for the step-4 read failure before any mutation**. A live worker can record that outcome from its execution; restart recovery needs durable information. Decide their boundaries together, but neither requires the other bead to close before work begins.