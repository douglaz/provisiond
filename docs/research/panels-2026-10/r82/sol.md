For Q1, I choose the exact merged form below in **CNF-302**. For Q2, I prefer **REPLACE**, while accepting both exact alternatives. I found no verified premise-changing brief error under notes.md rule 6.

| Draft, with its proposed landing | Exact-text acceptance | Required repair |
|---|---|---|
| D1; CNF-302 | **CANNOT ACCEPT** | Make the aborted outcome explicit and verified; require distinct observed transaction timestamps; replace the comparison with an earlier captured instant as detailed below. |
| D2; CNF-302 | **ACCEPT** | None. |
| D3; CNF-302 | **ACCEPT** | None. |
| D4; CNF-295 | **ACCEPT** | None. |

D1 does not explicitly require distinct transaction timestamps. Its connection-drop instruction also needs a verified aborted outcome, rather than treating transport loss as the verdict. Replace its opening sentence with:

> Separately drive establishment for one actual restore with one retained id in two runs, using distinct observed transaction_timestamp() values for the first attempt and retry: in the first, force the first transaction to abort, lose its reply, and verify that no record with that id or other changes from that transaction committed; in the second, let the first transaction commit and lose its reply.

Also replace **“and not an instant captured before the first attempt”** with **“and not the aborted first transaction’s timestamp”**. The original negative comparison needs an additional distinctness fixture: coincidental equality with an earlier captured value would not itself violate the inserting-transaction definition.

My acceptance of D2 treats **“its predecessor”** as an open-predecessor fixture. It does not require every restore to have one: [STO-56](https://github.com/douglaz/provisiond/blob/c824e4fa4d612b231110bc5deb3e88b3b3e90f92/05-persistence.md#L1439) says, “Where the restored store has no open incident, the new record has `supersedes_incident_id` `null`.”

D3 and D4 explicitly select the event-clock recipe for their certified-evidence runs. That is acceptable fixture selection. Making that recipe compulsory for every certified upper bound would overreach [STO-54](https://github.com/douglaz/provisiond/blob/c824e4fa4d612b231110bc5deb3e88b3b3e90f92/05-persistence.md#L1660), whose words are “can supply f=restore_instant+e_event.”

The existing drafts’ immediate lost-commit-reply repeats can encounter zero step marks. My merged form adds a later repeat against nonzero marks, making a reset-to-zero implementation distinguishable. This is additional conformance coverage of adopted B’s **“preserving its step marks and original restore instant”**, not an additional product obligation.

Insert the following **after CNF-302’s supersession/lost-reply paragraph**, whose final sentence ends **“produce two open incidents or silently continue using predecessor step marks.”**, and **before its install-case table** ([insertion boundary](https://github.com/douglaz/provisiond/blob/c824e4fa4d612b231110bc5deb3e88b3b3e90f92/10-conformance-checklist.md#L3087)):

```markdown
      **Establishment retry clock.** Exercise the following arms for one actual restore per run,
      retaining the same new incident id N for all its establishment retries. Run each arm
      with no inherited open incident and with an inherited open predecessor R whose ordinary
      close conditions are unmet. Satisfy the existing stopping/fencing prerequisites. Use null
      `lost_window_starts_at` and `loss_end_at` with a non-null incident-keyed
      `history_evidence_ref` retaining the unknown-endpoint reasons. Read each establishment
      transaction's `transaction_timestamp()` in that transaction; use distinct observed values
      t1, t2 and, for the later repeat below, t3.

      In the aborted-first-attempt arm, force the transaction at t1 to abort and lose its
      reply. Verify in the store that N is absent and none of that transaction's changes
      committed. Retry with N in a newly begun transaction at t2 and let it commit. Assert
      exactly one N with `restore_instant` = t2, not t1.

      In the committed-first-attempt arm, let the transaction at t1 commit N and lose its
      reply. Repeat with N in a transaction at t2 and assert an acknowledged matching guarded
      no-op preserving t1 and the step marks, without refusal merely because t2 differs from t1.

      Keep both components stopped until the insertion or its matching repeat is acknowledged.
      With R, assert that the abort left R unchanged and open, and that the successful insertion
      retains R, closes it by supersession and names it in N's `supersedes_incident_id`.
      For every matching no-op in this case, assert no additional incident or supersession and
      preservation of the committed N's restore instant, predecessor, step marks, grace end,
      endpoint fields and evidence reference.

      After the acknowledged insertion or repeat in each arm, follow the existing procedure
      until step (2)'s mark commits. Stop both components without another actual restore, repeat
      establishment with N at t3, and assert a matching guarded no-op preserving the now nonzero
      step marks as well as the other persisted fields above. Acknowledge that repeat before
      restarting either component. This case selects no comparison algorithm. (`STO-54`, `STO-56`)
```

This catches retaining t1 after an abort, replacing a committed instant with a retry’s timestamp, refusing an otherwise matching repeat solely because those timestamps differ, performing another supersession, and clearing committed step marks.

The fixture prerequisites retain their existing owners:

- [STO-54](https://github.com/douglaz/provisiond/blob/c824e4fa4d612b231110bc5deb3e88b3b3e90f92/05-persistence.md#L1636): “restore_instant is transaction_timestamp() of the newly begun transaction inserting this incident” and “The transaction begins after the existing stopping/fencing requirements are satisfied.”
- [STO-56](https://github.com/douglaz/provisiond/blob/c824e4fa4d612b231110bc5deb3e88b3b3e90f92/05-persistence.md#L1432): the establishing transaction “MUST close R by supersession and insert a distinct record naming R”.
- [STO-56](https://github.com/douglaz/provisiond/blob/c824e4fa4d612b231110bc5deb3e88b3b3e90f92/05-persistence.md#L1452): “The endpoints and reference MUST be written with the row; continuations MUST NOT recompute them.”
- For D2’s provenance assertion, [STO-54](https://github.com/douglaz/provisiond/blob/c824e4fa4d612b231110bc5deb3e88b3b3e90f92/05-persistence.md#L1714) assigns the establishing transaction: “MUST set this column `true` on every surviving install or rescue-inventory row whose status is `queued`, `running` or `needs_reconciliation`.”

The merged text adds no specification gate and no certified-bound recipe requirement.

For Q2, my exact-form judgments are:

| Alternative | Acceptance | Preference |
|---|---|---|
| KEEP: “finds no committed matching record” | **ACCEPT** | Acceptable |
| REPLACE: “finds no committed record with that id” | **ACCEPT** | **Preferred** |

**Behaviour change: NO.** Reading either alternative with B’s preserved clauses gives the same outcomes:

| Trace | Outcome under either wording |
|---|---|
| T1 aborts; no committed N exists; T2 inserts | Persist T2’s instant. |
| T1 commits N at t1; matching T2 has distinct timestamp t2 | Guarded no-op retaining t1 and marks. |
| Committed N exists, but its asserted predecessor or restore instant mismatches | Refuse with both components stopped. |

These outcomes follow from adopted B’s **“for the newly begun transaction inserting it”**, **“preserving its step marks and original restore instant”**, and **“A mismatch in the committed id's restore instant or predecessor MUST be refused with both components stopped.”** The replacement leaves those words intact.

**Requirement change: NO.** By this I mean an obligation change, following notes.md rule 3. The replacement makes absence explicitly about the retained id. It preserves B’s matching-record duty: **“MUST affect that record as a guarded no-op, not create or supersede another record”**, alongside the quoted mismatch refusal. It does not authorize treating an incompatible same-id record as a successful match.

The original phrase protects the distinction between establishment without a committed match and repetition against an existing matching incident. Its **“matching”** qualification also signals compatibility, whose refusal consequence remains explicit elsewhere in B. REPLACE retains that protection while removing the disputed reading in which a same-id payload mismatch counts as absence. I do not elevate that rival reading into a verified contradictory-MUST verdict; the supplied checked verdict establishes no unavoidable overlap.

**Check-strength change: NO.** Every expected result in the merged case is identical under KEEP and REPLACE. The nonzero-mark fixture strengthens the separately authorized Q1 coverage; that strengthening does not come from Q2’s wording replacement. No theorem, fixture, negative control or conformance assertion needs weakening for REPLACE.

Both unpiped gate invocations on the unchanged-pin verification copy exited **0**. The reader clone remains clean at the specified commit. These runs checked specification artifacts; they did not execute runtime conformance.

Final Q1: exact merged form printed above; CNF-302; after the supersession/lost-reply paragraph ending “predecessor step marks.” and before the install-case table  
Final Q2: REPLACE; behaviour change NO; requirement change NO; check-strength change NO