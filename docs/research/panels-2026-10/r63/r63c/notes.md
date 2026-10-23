# r63c manager notes (panel C, last round): reads S' (pv-s4m) and F' (pv-n98 + A1). Clones at dc5d40d. 2026-10-23

## Outcome rules (fixed before launch)

1. Each reader votes S': ACCEPT or CANNOT ACCEPT, and F': ACCEPT or CANNOT ACCEPT. Nothing else is counted.
   A CANNOT ACCEPT must name the normative content lost or made wrong (a MUST/SHOULD quoted with file:line, or a
   behaviour a conforming engine must or must not show) or a trace that breaks, and give replacement text for that
   span only. One that names neither is recorded but does not block (r63 rule 3).
2. S' carries at 3 of 4 ACCEPT. It goes to the owner as the panel's recommendation with r63c's tally, and r63b's
   3-1 on S is noted. If S' falls short, the owner gets S (r63b, 3-1) and S' (r63c tally) side by side, with
   opus's r63b trace and the objection to S'.
3. F' carries at 3 of 4 ACCEPT. If F' falls short only on the F6 invariant bullet (the one r63b amended), that
   bullet is deleted outright, per r63 rule 5. It's a proof route, not a norm: F6 keeps the theorem's conclusion,
   and the gate checks the proof. F' minus that bullet goes to the owner, with the tally. A valid objection to
   any other span of F' goes to the owner as a split, with both texts and their tallies.
4. r63 rules 6 (a verified brief error that changes a premise voids that question's tally) and 7
   (counter-arguments are not votes) hold.
5. There is no r63d. Only text a reader read goes to the owner.

## What changed from r63b (verified at dc5d40d; tally in /var/tmp/provisiond-panel-r63b/tally.md)

- S -> S': "asynchronous" deleted in S1, S2, S5 and S8's heading (opus's trace). S2's bold sentence names "the
  standby `OVR-19` names" (05:149-150's phrase). Opus's "since `STO-7` makes only two transactions wait for it"
  is left out: it's an unquoted claim about another requirement. New S5b, CONTEXT.md:186 (astra). S7 quotes
  26.2.8.1 whole (fable) and records D (OMIT 4-0).
- F -> F': the F6 `step_quarantined_restore` bullet is replaced with the World.safe form (astra, sol, fable).
  New F8, the 03:1686-1688 pseudocode comment (opus).
