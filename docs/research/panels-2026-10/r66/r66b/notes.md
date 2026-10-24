# r66b manager notes (panel D: pv-buc, one merged Fence G + Form R text), 2026-10-24

Brief: brief.md here. Base: docs/research/panels-2026-10/r66/{brief,tally,notes}.md and the r66 reader answers.
Readers clone at **`d78085a`** (master). Next free ids at `d78085a`: `ADR-0047`, `OPS-50`, `STO-59`, `CNF-366`
(R's); G's items `CNF-367`..`CNF-370`.

Owner, verbatim: R: "Yes, R (Recommended)". Fence G: "Adopt; one combined Run". Fence A is dropped.

## Outcome rules (fixed before launch; same as r66)

r63's rules 1-7 (docs/research/panels-2026-10/r63/notes.md) apply, restated:

- **Rule 3, the gate:** a CANNOT ACCEPT names a checked verdict the text flips, makes unreachable or makes vacuous
  (CNF id or Lean theorem), or a MUST/SHOULD with a trace that breaks it, and gives replacement text for that span
  only. For G it also counts with a trace in which the text admits a stale write (an old engine's write committing
  after the advance) or refuses a write it should admit (no takeover happened). Otherwise recorded, non-blocking.
  Wording is not counted.
- **Rule 6, per question:** a verified brief error that changes a question's premise voids that question only.
- **Rule 7:** counter-arguments written on request are not votes.
- **Consensus (every question):** 4-0, or 3-1 where the dissent's load-bearing fact is verified false at `d78085a`
  by the manager (grep or quote). A cost, scope or preference dissent cannot be verified false, so 3-1 with one is
  NOT consensus. No consensus = rule 4: a split to the owner, each side's strongest argument, the separating case.
- **Rule 5:** a clause with non-converging AMENDs across two successive rounds is deleted, not reworded. Watch:
  G's lost-reply sentence (r66's "unlanded") and R's `OPS-47` loss clause were first amended in r66; if r66b's
  repairs of either do not converge, the lost-reply sentence is deleted, and R's loss clause goes to the owner
  (it is R's core and cannot be deleted without reopening R).

### Q1 (merged G) and Q2 (R with G)
- Each carries with ACCEPT by the consensus test and no blocking CANNOT ACCEPT.
- A blocking defect with replacement text: if the repairs of one span converge (same text, or one reader's text
  the others do not contest), the repaired text goes to a confirmation read (r66c) before the Run; if two or more
  readers' repairs differ, (b) another round.
- Non-blocking notes are recorded, NOT merged.
- An id a reader shows missing with a quote joins the Run's list without a vote only if it is a pointer or
  quotation update that changes no behaviour; otherwise it is a defect under the gate.
- "R contradicts G or the text around it" counts only with quotes from both sides.
- Both carry → the combined Run is ready (Q3 permitting).

### Q3 (STO-13 rollback to an engine binary without `OPS-50`'s check)
- A choice between options (A) and (B), not ACCEPT/CANNOT ACCEPT. Consensus (as above) on one option: that option
  goes into the Run's text, reported to the owner. Any split: to the owner (rule 4), each side's strongest argument.
- Asked because r66 readers did not agree: sol wrote "Rollback to such a binary is inadmissible"; astra "prevent
  such a version from restarting against this store"; fable and opus did not raise `STO-13`.

### Out of scope (recorded, not voted)
- `PRV-29` names no automatic resolver for a non-create `needs_reconciliation`: the bead is to be filed in the
  pv-buc branch by the Run-prep manager.
- `pv-1ylh` (`OPS-22` worker-vs-engine exit on a zero-row record).

## Span check (before launch)

Every "before" span line, every insertion anchor and every quotation of existing text in brief.md was checked at
`d78085a` with `git show d78085a:<file> | grep -F` on single source lines, not flattened: a wrapping span is checked
line by line (list: spancheck.tsv; result: spancheck.out, `count|file|lines|text`). 67 strings, all found; every
before-span line and anchor is unique; two quotations recur ("records no error" 03:1790,1806; "before either
component is started" 05:1338,1515,1556), which is fine for a quotation. Line hints corrected from the output
(span 6 03:355-356; span 22 05:1432). Not checkable in the repo: the PostgreSQL quotes (13.3.2 lock quotes; sol's
"A value of zero (the default) disables the timeout"; opus's "applies separately to each lock acquisition attempt").

## Reader labels (manager only; the brief uses neutral labels)

brief.md's Reader 1 = r66 fable, Reader 2 = r66 opus, Reader 3 = r66 astra, Reader 4 = r66 sol (r66/<reader>.md).

## Deviations to report

- Rule 5 watch: r66's tally says non-convergence next round deletes. These notes delete the lost-reply sentence
  but send R's loss clause to the owner, since deleting it would undo the owner's R.
- `OPS-15`'s first new sentence is the manager's: anchored to "the engine's first write transaction after taking
  `STO-51`'s lock", not to "the pass's first transaction", so a restore startup's `STO-54` step (2) write cannot
  precede the advance. Marked in the brief.
