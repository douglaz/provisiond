# r65b manager notes (panel D: pv-buc only), master b90783d, 2026-10-24

Brief: brief.md here. Source: docs/research/panels-2026-10/r65/{brief,tally}.md and the handoff
/var/tmp/provisiond-manager/r65b-handoff.md. Reader answers: r65b/<reader>.md.

Owner, verbatim (owner-q1-sync-2026-10-23.md:188-196): R vs E "double check it again"; Fence G "call the panel to
double check this"; Fence A "try to get a consensus here".

## Outcome rules (fixed before launch, 2026-10-24T02:37Z)

r63's rules 1-7 (docs/research/panels-2026-10/r63/notes.md) apply, with these readings.

- **Rule 3, the gate (from r65/notes.md):** a CANNOT ACCEPT names a checked verdict the form flips, makes
  unreachable or makes vacuous (CNF id or Lean theorem), or a MUST/SHOULD with a trace that breaks it, and gives
  replacement text for that span only. Otherwise it is recorded, non-blocking. Wording is not counted.
- **Rule 6, per question:** a verified brief error that changes a question's premise voids that question's tally
  only. Other questions stand.
- **Rule 7:** counter-arguments written on request are not votes.
- **Consensus (every question):** 4-0, or 3-1 with a checked-and-wrong dissent. "Checked-and-wrong" means the
  dissent's load-bearing fact is verified false at b90783d by the manager (grep or quote). Only a factual claim
  can be checked-and-wrong: a cost, scope or preference dissent (for example "G reopens ADR-0019") cannot be
  verified false, so 3-1 with such a dissent is NOT consensus. No consensus = rule 4: a split to the owner, each
  side's strongest argument, the separating case.

### Q1 (R vs E, the rule-2 confirmation read)
- Each form carries only with ACCEPT by the consensus test and no blocking CANNOT ACCEPT.
- The pick carries by the consensus test. The label is owner (r64, 4-0), so it goes to the owner either way, as
  the panel's recommendation.
- The tally uses each reader's pick **without G**. A pick stated as conditional on G is evidence for the owner,
  not a vote.
- **Fixes (R 1-7, E 8-9):** this round is their rule-2 confirmation read. A fix a reader calls wrong needs
  replacement text; a wrong fix that changes behaviour is a blocking defect only if it passes the gate. Rule 5: a
  clause with non-converging AMENDs across two successive rounds is deleted, not reworded. If two or more readers'
  repairs of one span differ, that is (b), another round.
- The S5 traces under both OPS-22 readings are evidence. The OPS-22 inconsistency itself is not voted here; it is
  a separate item for the assistant (behaviour, so a bead candidate).
- Pre-registered: a reader naming another cost of R's overlap or E's stranded rows is an invited answer, not a
  brief error. Only a verified break of a separating case as stated (a row whose R or E outcome differs from the
  brief's), of OPS-22's claim-number guard or of OPS-15's pass guard is a brief error under rule 6, and only if it
  affected the case for the pick.

### Q2 (Fence G: ADOPT / DON'T ADOPT)
- ADOPT carries by the consensus test. Soundness YES/NO is reported with it.
- "G unsound" counts only with a trace in which G admits a stale write or refuses a record it should admit.
  Without one it is recorded, non-blocking.
- Answers on the id list, the dispatch question, the partition wait and the ADR-0019 question are evidence for the
  owner and for the spec text a later round drafts. No full G text is voted this round.

### Q3 (Fence A: ADOPT / DON'T ADOPT, R only)
- ADOPT carries by the consensus test. Soundness YES/NO is reported with it; "A unsound" needs a trace as for G.
- **Moot rule:** Q3 is recorded as **moot**, not as a split, only if Q2 reaches consensus ADOPT **and** at least
  3 of 4 readers say A is moot under G. Otherwise Q3's vote stands as tallied.
- A applies with R only: if Q1's pick carries E by consensus, Q3 is also recorded as moot.

## Launch record (written after launch; the rules above are unchanged)

Launched 2026-10-24T02:40:36Z; all four active at 02:42Z with output arriving.
Known nit, not a premise error (rule 6 does not apply): R's fix-3 anchor quotes
"…classifies the row as interrupted”." with a curly close quote from r65's tally; master 03:1770 has a straight `"`.
