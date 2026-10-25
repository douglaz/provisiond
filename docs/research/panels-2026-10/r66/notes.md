# r66 manager notes (panel D: pv-buc combined form, Form R + Fence G), 2026-10-24

Brief: brief.md here. Sources: docs/research/panels-2026-10/r65/r65b/{brief,tally,notes}.md, the r65b reader answers, and
owner-q1-sync-2026-10-23.md:198-204. Reader answers: r66/<reader>.md.

Master moved during drafting: PR #24 (pv-9j6) merged as `d78085a`. Readers clone at **`d78085a`**. Spans are quoted from
`b90783d`; each MUST be verified unchanged at `d78085a` (`grep -F`) before launch. Line hints are `d78085a`. PR #24 took `ADR-0046`, so the next free ADR
is `ADR-0047`; next free ids at `d78085a`: `OPS-50`, `STO-59`, `CNF-366`.

Owner, verbatim (owner-q1-sync-2026-10-23.md:202-204): R: "Yes, R (Recommended)". Fence G: "Adopt; one combined
Run". R is held until G's text is drafted and read; then one Run implements both. Fence A dropped.

## Outcome rules (fixed before launch)

r63's rules 1-7 (docs/research/panels-2026-10/r63/notes.md) apply, with r65b's readings, restated:

- **Rule 3, the gate:** a CANNOT ACCEPT names a checked verdict the text flips, makes unreachable or makes vacuous
  (CNF id or Lean theorem), or a MUST/SHOULD with a trace that breaks it, and gives replacement text for that span
  only. Otherwise it is recorded, non-blocking. Wording is not counted.
- **Rule 6, per question:** a verified brief error that changes a question's premise voids that question's tally
  only. Other questions stand.
- **Rule 7:** counter-arguments written on request are not votes.
- **Consensus (every question):** 4-0, or 3-1 where the dissent's load-bearing fact is verified false at `d78085a`
  by the manager (grep or quote). Only a factual claim can be checked-and-wrong; a cost, scope or preference dissent
  cannot be verified false, so 3-1 with such a dissent is NOT consensus. No consensus = rule 4: a split to the
  owner, each side's strongest argument, the separating case.
- **Rule 5:** a clause with non-converging AMENDs across two successive rounds is deleted, not reworded.

### Q1 (Fence G's text)
- G's text carries with ACCEPT by the consensus test and no blocking CANNOT ACCEPT.
- For G, a blocking CANNOT ACCEPT also counts when it gives a trace in which the drafted text admits a stale write
  (an old engine's write committing after the advance) or refuses a write it should admit (no takeover happened).
- A blocking defect with replacement text: if the readers' repairs of one span converge (the same text, or one
  reader's text the others do not contest), the repaired text goes to a confirmation read (r66b) before the Run. If
  two or more readers' repairs of one span differ, that is (b), another round.
- Non-blocking notes are recorded, NOT merged (a merge would be unreviewed).
- The id-completeness answers are evidence for the Run's instruction; an id a reader shows missing with a quote is
  added to the Run's list without a vote only if it is a pointer or quotation update that changes no behaviour;
  otherwise it is a defect under the gate.

### Q2 (Form R read whole with G)
- R as amended carries with ACCEPT by the consensus test and no blocking CANNOT ACCEPT.
- "R contradicts G or the text around it" counts only with quotes from both sides; a verified contradiction is a
  blocking defect and goes through the repair rule above.
- The `CNF-366` sol fix (it changes only the checked assertion) gets its rule-2 confirmation read here. A reader who
  calls it wrong gives replacement text; it blocks only under the gate.
- The open point on `OPS-47`'s "is lost" clause: answers are evidence. A change is merged only if it passes the gate.

### Out of scope (recorded, not voted)
- No requirement names who automatically resolves a non-create `needs_reconciliation` (`PRV-29` names no writer):
  to be filed as a bead. A reader's answer on it is evidence only.
- `OPS-22` worker-vs-engine exit on a zero-row record: separate bead candidate; not voted.

## Launch record (2026-10-24 04:30Z)

Brief written; every quoted "before" span checked at `d78085a` (whitespace-normalised `in` test, all OK, each anchor
unique). Clones r66/{fable,opus,astra,sol} at `d78085a`.
Known brief gap: pointer-only ids carry no
quoted before/after (readers asked whether any is behaviour); the Run's instruction must supply them.
