- **C1 — Accept:** normalized WWN, then serial, then `null`; retain every device.
- **C2 — Accept, least confidence:** use the same normalization for matching, reporting and hashing; empty means absent.
- **C3 — Accept:** canonical-element byte ordering handles anonymous devices deterministically without changing matching priority.
- **C4 — Amend:** explicitly separate request validation from subsequent device matching.
- **C5 — Amend, (ii):** include nullable normalized `wwn`/`serial` **and `name`** to reconcile the report obligation.
- **C6 — Amend, `CNF-363`:** add both install fields, serial fallback, canonical ordering, normalization equivalence and duplicate multiplicity.
- **C7 — Accept:** update quotations; the existing resolution proof covers missing identifiers, but does not verify wire serialization or fingerprint construction.

No inherent C2/C4 contradiction: “matches nothing” describes matching, while “refused `invalid_request` before enqueue” describes admission. Explicit sequencing reconciles C4 with `RSC-26`: “An identifier that does not resolve to exactly one device MUST abort `integrity` before any write.”

C5(ii) alone remains incomplete: baseline `RSC-33` requires “(name, path, size, type, model, serial)”, whereas C5 proposes “add nullable `wwn` and `serial`” to an example also missing `name`. I also qualified `CONTEXT.md`’s “reports its disks with stable identifiers”.

[Amendments applied in the clone](/var/tmp/provisiond-panel-r61b/astra/panel-r61b.patch). Ran `nix develop --command bash tools/check-all.sh` unpiped:

| State | Exit |
|---|---:|
| Baseline | 0 |
| Amendments | 0 |
| Invented `/dev/sda` wire identifier | **0 — nothing red** |
| Missing-identifier wildcard in matching | **1 — `resolves_only_the_named_disk` fails** |
| Restored final state | 0 |

Both mutations are removed; logs remain in the clone. The new CNF is an implementation obligation, not an executed implementation test. Settled clauses remain unchanged; I independently recomputed the example fingerprint.

The owner question reopens settled alternatives and hides additional decisions. Replace it with:

> Keeping every device, using `null` for missing identity, and including every device in the fingerprint is settled. Approve normalized WWN-first identifiers; nullable normalized WWN/serial plus `name` on the wire; normalized fingerprint values sorted by canonical element bytes, retaining duplicates; `invalid_request` before enqueue for malformed disk references; expanded `CNF-363`; and existing Lean proofs with corrected quotations? Or specify which detail to revise. Valid unmatched references still abort `integrity`.

**Strongest argument against C2 (least confidence):** Normalizing the hash suppresses observed serial/WWN changes that a raw-value hash would detect. Matching equivalence alone does not prove those changes harmless.