# r65 manager notes (panel D: pv-buc only), master b90783d, 2026-10-23

Brief: brief.md here. Source tally: docs/research/panels-2026-10/r64/r64b/tally.md. Reader answers: r65/<reader>.md.
Q2 (pv-9j6) converged in r64b (M + [P], minus [Q], plus fixes 1-4) and is not in this round; it awaits the
owner's yes via the assistant.

## Outcome rules (fixed before launch)

r63's rules 1-7 (docs/research/panels-2026-10/r63/notes.md) apply. Rule 3's test is the gate: a CANNOT ACCEPT names a
checked verdict the form flips, makes unreachable or makes vacuous (CNF id or Lean theorem), or a MUST with a trace.
Otherwise it is recorded, non-blocking.

- Q1 (two forms, merged R record-first, completed E exit-at-once): each reader votes ACCEPT/CANNOT ACCEPT on both
  and picks one. A form carries at 3/4 picks with no blocking CANNOT ACCEPT. A 2-2 goes to the owner as a split
  (rule 4), with each side's strongest argument, the separating cases and the stranded-rows trace. The label is
  owner (r64, 4-0), so even a 3/4 goes to the owner as the panel's recommendation.
- A blocking CANNOT ACCEPT on R that only repairs the merged span (astra's/sol's choice) with replacement text is
  a defect to fix in the carried form; if two or more readers' repairs differ again, that is (b) another round.
- Counter-arguments written on request are not votes (rule 7).
- Q1-F (the optional fence): YES/NO on soundness, with its cost. Evidence for the owner, not a vote on R/E; it does
  not move Q1's tally. A reader showing the fence unsound (a trace where it admits a stale write or refuses a
  record it should admit) is reported with the fence, not applied.
- Pre-registered: a reader naming another cost of R's overlap or of E's stranded rows is an invited answer, not a
  brief error. Only a verified break of a separating case as stated (a row whose R or E outcome differs from the
  brief's), of `OPS-22`'s claim-number guard or of `OPS-15`'s pass guard is a brief error under rule 6, and only if
  it affected the case for the pick.
