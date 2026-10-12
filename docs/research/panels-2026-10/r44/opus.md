**Verdict: neither candidate.** The conflict is in one bullet, not in Decision 2. Keep the guard, read it from the `machines` row (which survives retention), and delete the clause that makes a vanished row enough on its own. `STO-14` stays as it is.

**Why**

- Decision 2's rule is already the conjunction: "settled or vanished, **and** no machine it produced still reads `provisioning`." Only the bullet breaks it, and its reason is "an unrecorded machine is never attached." That holds for a row lost to a restore, where no machine row exists. It is false for a row `STO-14` removed: that machine was attached and still has a row.
- The guard doesn't need the operation row. `machines.correlator_value` holds what the create wrote: `operation_uuid` on Cloud and DigitalOcean, and the per-order key's fingerprint on Robot (`05-persistence.md:266`). Both are indexed "for reconciliation lookup." One gap: Robot's caller key carries the operation id but isn't the correlator. The sweep reaches its machine through the correlator key that carries the same operation id, so the rule must be worded per operation, not per key.
- The guard is not moot after settlement. On Cloud and DigitalOcean a create can settle on the reply, the search and a confirming read while the server still reads `initializing`/`new`. Research V2 and V18 are PARTIAL and V19 is UNDETERMINABLE. ADR-0040 already rejected "'Settled' alone." Robot looks moot from one observation only.
- Two facts in the brief don't hold:
  - "Robot installs keys at order time" isn't in the repo. V9 says "No source says whether the transaction's `authorized_key[]` is a snapshot or a live join" (`provider-verify-2026-10.md:252`). The live test deleted the key at 04:06:19Z, the same second as READY, and cancelled two seconds later. Nobody logged in. It shows the order listing kept the key. It doesn't show the installed system has it, or that deleting during `in process` is safe.
  - "Retention measured in days": the register row says only "durations" (`00-overview.md:393`), and neither `STO-14` nor `STO-33` sets a floor. Provisioning has no bound either (`OPS-33`: "no documented bound"). So candidate 2's accepted consequence would depend on a deployment setting, not a rule.

**Defects**

- `docs/adr/0040-…md:40` — the bullet's reason is false for a row removed by retention.
- `02-provider-contract.md:138-139` (PRV-9) — "MUST delete a tagged key whose operation record has vanished," with no guard.
- `03-operation-lifecycle.md:1459` (OPS-32) — "a vanished record requires sweep deletion." It also restates PRV-9 instead of only citing it.
- `tools/formal/Provisiond/Rescue.lean:911,965-974` — the comments say "no row means no attached machine." The predicate's `!recordPresent ||` bypasses the guard.
- `tools/formal/Provisiond/Witnesses.lean:3034-3045` — tests "vanished" and "provisioning" separately, never together.
- `10-conformance-checklist.md:2446-2447` (CNF-303) — "Delete a tagged key whose operation row vanished," with no guard.

**Edits**

1. **ADR-0040:** add a Q26 amendment replacing the bullet: "A key whose operation record is gone is deleted once no recorded machine bearing that operation's correlator reads `provisioning`. A row lost to a restore has no such machine."
2. **PRV-9:** "The sweep MUST delete a tagged key whose operation record has vanished once no recorded machine bearing that operation's correlator reads `provisioning`. The guard is read from `machines`, which outlives `STO-14`."
3. **OPS-32:** drop "a vanished record requires sweep deletion" and cite PRV-9.
4. **Lean:** change `keyEligible` to `(!w.recordPresent || w.status == .succeeded || w.status == .failed) && !w.producedProvisioning`, and fix both comments. Add one conjunct to the witness: `{ clean with recordPresent := false, producedProvisioning := true }` keeps the key. I ran this on a scratch copy at `scratch-q26/formal`: `lake build Provisiond` completed with all 26 jobs, and both general theorems still prove. I did not run the full `check-all.sh` against it.
5. **CNF-303:** settle with the machine still in `provisioning`, let retention remove the operation row, and assert the key remains. Then clear the guard and assert the sweep deletes it.
6. **No change:** `STO-14`, and `09-known-defects.md:100`, which quotes only PRV-9's unchanged first sentence.

**Strongest "don't build": candidate 1**, the retention exception.
- It makes the job that ages out request records read machine state.
- It keeps operation rows for as long as a machine reads `provisioning`, with no bound.
- It preserves a link the `machines` row already carries.

A new machine→operation column would duplicate `correlator_value` for the same reason. Add one only if a driver turns out to have no correlator on its machine row; none of the three v1 drivers lacks one.
