All verification is done and no brief premise is wrong. Here is my answer.

## Verification at the pin

My clone is clean at c824e4fa4d612b231110bc5deb3e88b3b3e90f92. Every extract in the brief matches it: STO-56 at 05-persistence.md:1419–1487, the STO-54 boundary at 1632–1666, CNF-302 at 10-conformance-checklist.md:3022–3097 with CNF-303 at 3098, and CNF-295 at 1019–1093 with CNF-296 at 1094. The adopted B in the r81 check file is ten lines, sha256 bb7cdb82…6786, byte-identical to the printed form, and line 2 ends with `finds no` while line 3 begins `committed matching record`. The four draft texts match r81 tally lines 143–208, and that tally's explicit-pick table reads B = fable, astra, sol. Both the pinned retry paragraph and CNF-302's four restore paragraphs were added by the same commit, 12c3da0, so the forthcoming fix amends one-commit-old text in both files. Rule 6: no verified brief error changes either question's premise; nothing is void.

Two gate facts bear on the drafts. The citation gate checks a quote in the colon form `` `X`: "…" `` against X's body, so D1's STO-56 quote passes only once B has landed in STO-56. No draft writes `` `X` MUST ``, so the obligation gate is indifferent to all four.

## Q1

**D1, fable, CNF-302 after the supersession paragraph: ACCEPT as printed.** It tests the aborted-attempt clock, the committed-attempt preservation and the acknowledged repeat, and asserts nothing beyond B. Repairs worth making in a consensus round, none required: say outright that the two transactions' timestamps differ, since distinctness is only implied by "not an instant captured before the first attempt"; drop "read in that transaction", which reads as a method instruction; note that its quote binds this paragraph to B's landing, which is harmless in the combined fix.

**D2, opus, CNF-302 after the supersession paragraph: ACCEPT as printed. My final pick.** Every assertion has a pinned owner. The clock is asserted by pointer, "the value `STO-54` defines", which STO-54 states as "restore_instant is transaction_timestamp() of the newly begun transaction inserting this incident"; in the aborted arm the inserting transaction is the retry, and "a later transaction whose start time differs" makes the two paths distinguishable. "Its predecessor closed by supersession" is STO-56's "the transaction establishing the new record MUST close R by supersession and insert a distinct record naming R", and the predecessor is a fixture the preceding paragraph already supplies: "Repeat the actual restore using a backup containing an open predecessor whose ordinary close conditions are unmet." "Provenance initialized in the repeating transaction" is STO-54's marker-provenance duty: "the acknowledged transaction that establishes the restore record MUST set this column `true` on every surviving install or rescue-inventory row whose status is `queued`, `running` or `needs_reconciliation`". "Not refused merely because the repeating transaction starts later" is the negative of B's no-op MUST, not an algorithm. "Neither arm leaves two open incidents" is STO-56's partial unique index. The closing disclaimer selects nothing. One optional repair, not a condition: make the clock explicit, "its `restore_instant` the repeating transaction's own `transaction_timestamp()`, not the aborted attempt's"; I did not fold it in because the pointer form is this repository's convention and the pinned definition is unambiguous.

**D3, astra, CNF-302 after the supersession/lost-reply paragraph: CANNOT ACCEPT as printed.** The t1-abort, t2-insert, lost reply, t3-no-op chain is the best-designed clock check of the four, and the double fixture with and without an inherited R is fine. The blocking sentence is "Repeat with certified upper-bound evidence using STO-54's event-clock recipe; assert that the upper bound uses the transaction event persisted by the successful insertion and remains unchanged on matching repeats." That asserts STO-54's recipe `f=restore_instant+e_event`, which B does not require, and it needs a certified clock-error and stopping/fencing fixture that belongs to CNF-295's evidence runs. Exact repair: delete that one sentence. The bold lead-in and unbackticked `restore_instant=t2` are cosmetic; bold leads already appear inside CNF bodies.

**D4, sol, CNF-295: CANNOT ACCEPT as printed.** Two defects. It names no insertion point, and the brief requires one. Its last sentence asserts the same event-clock recipe as D3. Exact repair: delete "Also exercise the event-clock upper-bound recipe … the no-op transaction's timestamp." and insert after the CNF-295 sentence at line 1085, "Re-enter the incident and assert endpoints/references unchanged." The restore-class promotion run is within STO-54's clock definition, "For backup restore and restore-class promotion", so it is scope, not overreach. "Grace end" preserved is vacuous at establishment, since `grace_ends_at` is null until step (3).

**Landing.** CNF-302, because the case extends the sentence already there, "A lost transaction reply must not produce two open incidents or silently continue using predecessor step marks", and inherits that paragraph's open-predecessor fixture. CNF-295 is a defensible home but a different form.

**Exact insertion point.** In 10-conformance-checklist.md at the pin, immediately after line 3087, which ends `silently continue using predecessor step marks.`, as a new paragraph at the item's six-space indent, one blank line above it and one blank line between it and the table that starts at line 3089. Any amendment marker follows the fix Run's convention and is not part of the case text.

**Complete final text, D2 verbatim:**

```text
For one actual restore, lose the establishment transaction's connection before it commits,
so that no record with the retained id exists, and repeat establishment with that id in a
later transaction whose start time differs: assert exactly one record with that id, its
`restore_instant` the value `STO-54` defines, its predecessor closed by supersession and
provenance initialized in the repeating transaction, and neither component started before
that transaction is acknowledged. Separately let establishment commit, drop its reply and
repeat with the same id: assert the repeat is acknowledged as a guarded no-op preserving the
stored instant, predecessor and step marks, that it is not refused merely because the
repeating transaction starts later, and that the components then start and continue that
incident. Neither arm leaves two open incidents. This case selects no predecessor-comparison
algorithm.
```

**Wrong results this case catches.**
- **A retry that reuses a pre-selected instant** after an abort persists a value other than the retry transaction's timestamp. Arm one fails it because the start times differ.
- **An upsert that rewrites the committed instant** with the repeat's own timestamp. Arm two fails it on "preserving the stored instant".
- **A repeat that compares its own timestamp to the stored one and refuses.** This is the misimplementation behind r81's Reading 1. Arm two fails it on "not refused merely because the repeating transaction starts later".
- **A repeat that inserts a second record or supersedes the committed one.** Both arms fail it on "exactly one record", "preserving … predecessor" and "Neither arm leaves two open incidents".

**Criticism of all four drafts, separate from the pick.** Each asserts step-mark preservation on a repeat made before either component starts, where `steps_completed` is 0, so none can tell a no-op from an upsert that rewrites `steps_completed` to 0. B's sentence binds any repeat with a committed matching record, so one further repeat after step (1) is marked would make that clause bite. I left it out because the owner's question scoped the establishment retry; the consensus round or the owner can add that clause without touching B.

## Q2

**KEEP: ACCEPT. REPLACE: ACCEPT. Preference: REPLACE.**

The one trace on which the two texts could differ: committed N with predecessor R and instant t1, then a repeat with id N asserting predecessor R′ ≠ R.
- KEEP, "matching" read as identity: the insert condition is false, the guarded no-op's guard fails, and B's "A mismatch in the committed id's restore instant or predecessor MUST be refused" applies. Outcome: refuse.
- KEEP, "matching" read as the full payload: the insert condition is true, so "it MUST insert" and "MUST be refused" both bind on the same trace. No implementation satisfies both, which is opus's r81 objection and the r81 tally's "rival readings" verdict.
- REPLACE: the insert condition is false. Outcome: refuse, identical to the first line.

On every other trace, absent id or present-and-matching, both texts agree under every reading. So the replacement changes no behaviour and no requirement: under the only reading in which B's obligations are jointly satisfiable the obligation set is identical, and the reading it forecloses has no satisfiable obligation set to change. It changes no check's strength: no conformance item or Lean docstring quotes the span, the phrase "finds no committed" occurs nowhere at the pin, the formal references to STO-56 concern `grace_ends_at` and the open record, and D1's quote is of the following sentence, untouched by the edit.

What the original phrase protects is vocabulary only: "matching" also appears in "committed matching record exists" and "its matching no-op repeat" in the same paragraph. After REPLACE the three branches read cleanly, no committed record with that id inserts, a committed matching record is a guarded no-op, and a mismatch in the committed id's instant or predecessor refuses; the remaining "matching" sits where the guard lives. That is why I prefer the replacement, though B as printed is acceptable and the pointer in STO-56's "establishment with that id" already anchors the identity reading.

Final Q1: D2; CNF-302; new paragraph immediately after line 3087 ("…silently continue using predecessor step marks."), one blank line each side, before the table at line 3089
Final Q2: REPLACE; behaviour change NO; requirement change NO; check-strength change NO
