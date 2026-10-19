**Q1. Yes.** `OPS-21` says "`PRV-13c`'s post-order read in that settlement pass, so a stop during any of them is the cancellation being recorded", and "The worker classifies a recorded cancellation under `OPS-11`". `PRV-13c` says it "MUST NOT enter `OPS-11`'s classifier and MUST NOT change the create's settlement." `CNF-362`'s Placement control ("separately during its post-order read") contradicts `CNF-356`, not `CNF-147`; the brief names the wrong item. `CNF-356` says "with only `earliest_cancellation_date` null in the failed case. Assert no `needs_reconciliation`". `CNF-147` is the delete read-back, which belongs to pv-ilb.

**Q2. (a).** The search and confirming read are cut-off because their failure already gives `needs_reconciliation` (`OPS-27`). By the same reasoning, this read's failure gives `succeeded`. `ADR-0037` (Q31) already rejected (b)'s shape: "a failure that waits in `needs_reconciliation`".
- **`OPS-21`:** the verification sentence drops the post-order read ("so a stop during either"). Added: "A stop the engine survives after that confirming read succeeds and before `execute` returns does not cancel `execute`: the worker still makes `PRV-13c`'s post-order read in that settlement pass, the stop ends that read at once as a failed post-order read, and the settle write records the stop as a stop after `execute` returns". Then a `PRV-13c` quote and an amendment note.
- **`CNF-362`:** the Placement control drops the post-order read. A new case asserts one read, `succeeded`, a null date, setup fee and first unit debited once, and no `cut_off`.
- **`ADR-0044`:** its Decision quote is updated and a rejected option added.
- **Untouched:** `PRV-13c`. No Lean docstring quotes these sentences.

**Q3. Wrong.** `OPS-27` says "that transaction MUST include the column write with the machine row". The date is part of what the settle write records, so the read is inside `execute`. The branch's mistake was treating "inside `execute`" as "cut-off".

**Q4. The date is null** ("otherwise null"). Nothing collides:
- the discard on "interruption by engine exit or crash" covers only the exits;
- the read is made once and never repeated, so "MUST make the one post-order read" holds;
- `PRV-5`'s trigger is "every Robot `403 RATE_LIMIT_EXCEEDED`", which a stop is not.

**Q5. No.** The principle carries over; my text does not. `PRV-13`'s read decides the settlement (gone or scheduled, and whether the meter stops). This read only fills a nullable column. `CNF-362`'s "stopped during their provider call after dispatch" may not reach `PRV-13`'s read.

**Q6.** With option (a) every gate passes, exit 0.
- **Plant A** (reversal in `OPS-21` only): `citations` goes red ("attributes to OPS-21 a phrase OPS-21 does not contain").
- **Plant B** (reversal in both `OPS-21` and `CNF-362`): exit 0, every gate green, as at `647ed9b`. `CNF-362`'s case, read against `CNF-356`, is the only check.

**Q7. Against (a):** (b) is cheap. Q31's cost was "a spent hour would stall every delivered server". A deploy parks only the creates in flight, at most the worker count. A kill in that window already parks them: `CNF-362`'s After-return control sends them to `OPS-15`. (a) also has the worker make a provider call after a stop.

---
The edit is uncommitted in the clone. The answer, patch and gate logs are in `.r59/`. `br show` also left an untracked `.beads/beads.db.fsqlite-migration-state`.
