**1. Pick:** Option 1, a new column, because the pair's content on a `none` channel is unspecified today and only option 2 makes dispatch depend on it.

**2. Claims (option 2's):**

- **B1 stands in part.** The sentence is real (04:1423-1425), but "two records that must never disagree" is the set's normal shape: `offer_id`, `install_strategies` and `billing_unit_seconds` are written "in the same transaction as `offer_id`" (05:259-261).
- **B2 broken.** The pair does not speak the descriptor's language: its values are "`operation_uuid` where a free field exists, `ssh_key_fingerprint` on Robot" (05:382), not `operation_id | per_order_key`. And `PRV-26` closes the set: "The operation UUID … a per-order artifact … Nothing else." (02:866-868). `none` would be a third recorded value `PRV-26` forbids.
- **B3 broken.** The content is undefined under both shapes. `API-63` owed one sentence under option 1 and my edit pays it. `PRV-26` owes nothing: a channel that "MUST declare no correlator" (02:964) has no artifact to record, so the pair stays null and no reader needs it.

**Deciding claim: A3.** `PRV-9`'s key is uploaded on every Robot channel, so a standard-channel order does bear a fingerprint. Option 2 must either mandate `('none', NULL)`, dropping that fingerprint as `PRV-33` evidence, or record `ssh_key_fingerprint`, which `OPS-38` counts "over every correlator the operation recorded". Option 1 never has to legislate it.

**3. What would change my mind:** a sentence in 05:382 or `PRV-26` already fixing the pair's value on a `correlator: none` channel. Today no such text exists.

**4. Plant** (`r56b-plant.diff`, 93 lines):

1. Good edit: column `operations.correlator_transaction_at` (05), written at `OPS-43` step 8, read by a third `OPS-15` exception on a restart only, `API-63`'s entry test and `STO-3`'s startup bullet moved to it. Exit 0, nothing red.
2. Plant: a later author folds the create into the refresh sentence and writes "it survives a restore like any other, and the pass reads it on either boot". Exit 0, nothing red.
3. Saved as `r56b-plant.diff`.
4. Nothing caught either edit. The Lean model still says `| .running, _ => needsReconciliation` (`Restore.lean` 335) and `Fence.lean`'s `interrupt` sends a holding attempt to `needsReconciliation`, and the citation gate only checks that docstring quotes still exist. Per `ADR-0025` this belongs in Lean: a `Params` flag, a `sent` field on `Op`, a restart-only arm in `passOp`, and a restore-trace theorem that a create never settles `failed`, with its witness in the guard list at `ci.yml` line 685. That theorem would have gone red on the plant.

**5. ADR:** new `ADR-0042`, indexed "Amends `0016`", with a dated pointer in `ADR-0035`'s rejected bullet. The bullet's argument, "its marker cannot tell a key upload from an order", does not reach a record read only unset, so the question differs. Independent of the shape. Note: `README.md`'s index ends at `0025`, so `0042` is free there and in `docs/adr/`, but the index is sixteen ADRs stale.

**6. pv-qga:** no blocking dependency. A timed-out step-4 read is a failure the worker records, which is `OPS-11`'s path, and the worker knows it never reached step 8. The record is evidence for an interrupted create only. I expect pv-qga settles `failed`, since `pv-k4l` makes the crash case `failed` and a recorded read failure cannot fare worse than a crash.
