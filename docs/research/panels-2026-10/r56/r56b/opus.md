I pick option 1, a new `order_cleared_at` column. The edit passes every gate (exit 0). The plant turns the citations gate red (exit 1). Both edits are in `r56b-plant.diff`.

**1. Pick: 1.** A dedicated, write-once `order_cleared_at` column. Option 2 would let money depend on the pair being null on exactly the channel where nothing is written into the provider.

**2. Claims**
- **B1 broken.** 05:382 says the pair is "what the create wrote into the provider (`PRV-26`)". `PRV-33` puts the absence in the descriptor ("declares the absence as that channel's `correlator: none`"), not in the row. The column and the pair record different facts, so on a `none` channel they cannot disagree. `API-63` was the only reader of the pair as the step-8 record, and it now reads the column.
- **B2 broken.** The stored kinds are "`operation_uuid` where a free field exists, `ssh_key_fingerprint` on Robot" (05:382). The descriptor's words are `operation_id | per_order_key | none` (02:79). `none` would be a new value in the column.
- **B3 stands in part.** Under option 1, `API-63` owed the fix, and the edit makes it. `PRV-26`'s "Whichever it is, the kind and the value MUST be recorded" still has no `none`-channel case, but that gap predates option 1 and no longer decides money. No `COALESCE` is needed: release order meets condition 7.
- **A3 decided it.** 05:382's unscoped "`ssh_key_fingerprint` on Robot" conflicts with `PRV-32`'s "MUST declare no correlator and `PRV-33` governs". Under option 2, an author who "fixes" that to null settles dispatched orders `failed`.

**3. What would change my mind:** a quote in `PRV-9`, `PRV-32` or `PRV-33` that settles what a `none` channel stores at step 8, plus a CNF item asserting the pair is non-null after step 8 on every channel.

**4. Plant**
1. **Edit:** new 05 column row and a line in its startup-pass list; `OPS-43` step 8 (the write, guarded on `(id, running, claim_number)`, acknowledged before step 9); `API-63`'s test moved to the column; `OPS-15` exception, restart only and off under an open restore record; `OPS-45` pointer; `STO-54` promotion sentence; `CNF-29` and `API-63`'s CNF item; ADR-0042. **Exit 0, nothing red.**
   - **Lean: yes, it belongs there.** `passOp`'s `.running, _ => .needsReconciliation` contradicted the new text. I added the record to the model, the create arm, the guard `createExceptionOnRestart`, two theorems, three witnesses and a `ci.yml` row. Flipping that row locally gave exactly one red, on the targeted witness.
2. **Plant** (the `OPS-43` step 8/9 and 05-row hunks): the write moves to step 9's dispatch, "as `OPS-45`'s markers are set". **Exit 1, citations red:** two Lean docstring quotes of step 8 are found nowhere. It went red only because the plant deleted the quoted sentences. I reason, without having run it, that editing only the 05 row would stay green; a Lean quote of that row would catch it.
3. ADR-0042 is intent-to-add (`git add -N`), so the index changed but nothing is committed.

**5. ADR: a new ADR-0042** ("Amends `0016`"), plus a dated pointer in ADR-0035, as that ADR already does with "## Amendment — 2026-10-09: … (from ADR-0037)". ADR-0035 rejected the marker because it "cannot tell a key upload from an order or a rejection from an acceptance". Only this column's null settles anything, and null comes before both, so that rejection doesn't reach it. The answer doesn't depend on the shape.
- **0042 is free:** `docs/adr/` ends at 0041 and a grep for `0042` finds nothing. README's index stops at `0025`, so it proves nothing here and is stale.

**6. pv-qga: no blocking dependency.** pv-qga is a failure a live worker classifies while it knows it is at step 4. `OPS-45` says "an operation interrupted rather than classified is `OPS-15`'s". I expect pv-qga to settle `failed`: once a crash at step 4 settles `failed`, a timeout at the same step can't be worse. Link the two as `related`.

**Needs your decision:** the `STO-54` sentence makes every promotion of the asynchronous standby a full restore incident. That closes a gap older than pv-k4l and may deserve its own bead. I also changed "`suspend_tenant` is the other exception" to "another", since there are now three.
