# r63g manager notes (panel C, pv-s4m: external review intake). Clones at dc5d40d. 2026-10-23

Inputs:
- the external review, verbatim, at /var/tmp/provisiond-manager/external-review-2026-10-23.md. Readers do NOT get
  it: they get verify.md, which holds the verified facts, and results.md;
- the manager's verification: verify.md;
- the harness, /var/tmp/provisiond-pgharness/results.md: PostgreSQL 18.6 with three instances, every experiment
  demonstrated;
- the forms: forms-r63g.md, on top of r63e/forms-final.md;
- the draft owner questions: owner-questions-draft.md.

## Outcome rules (fixed before launch)

1. **Valid votes.** A PICK or a NOT ACCEPTABLE counts only if it names the normative content it rests on (a MUST
   or SHOULD quoted with file:line, or a forms text quoted) or gives a trace. Otherwise it is recorded and not
   counted. An ACCEPTABLE needs no trace.
2. **NA, PT and INV are spec-internal items.**
   - An item carries at 3 of 4 valid PICKs. The manager verifies the lone dissent's NOT ACCEPTABLE trace. If it
     shows a verified money loss, or a broken quoted MUST the form doesn't handle, the item doesn't carry.
   - An item also carries when every valid reader PICKs it or marks it ACCEPTABLE, and no valid NOT ACCEPTABLE
     survives verification.
   - For INV, ADR and STO are the two forms. If both qualify, the one with more PICKs carries. A tie goes to the
     owner.
   - A carried item is reviewed text. It is reported to the owner as settled, not asked.
   - **A clause that doesn't carry is deleted** (NA, PT, INV-STO). Its dissent is reported to the owner in one
     line.
3. **STOP, S3 and PA always go to the owner,** with the panel's pick first: 3 of 4 valid PICKs, or failing that
   rule 2's acceptability test. Otherwise the split is stated plainly. Each pick is reported with its tally and the
   reviewer's pick.
4. **Reader text.**
   - A fix that only deletes words becomes a Run review point.
   - A fix with new words that changes no behaviour becomes a Run review point marked "one reader's text, not
     voted".
   - A behaviour-changing fix doesn't enter any form. If three or more readers converge on the same behaviour, the
     manager's merge goes to a reading round (r63h) before the owner sees it as a recommendation.
   - **A manager synthesis of any kind needs its own round.**
5. **Brief errors.** Each is verified by quote. A verified error voids the tally of the item it affects, and that
   item goes to r63h, or to the owner if it is an owner item. A verified slip in forms-r63g.md is fixed back to the
   voted text as a Run review point.
6. **Ripple.** A missed span is verified by quote, then handled under rule 4.
7. **Only text a reader read** goes to the owner or into the Run.
8. **Owner-question wording.** A verified wording fix that changes no option's behaviour is applied without a vote.
   A fix that changes what an option does is handled under rule 4.
9. **Deleted safeguards.**
   - If a valid reader trace shows that a safeguard the forms delete was protecting something the replacement
     doesn't, the deleting item doesn't carry (rule 2), or goes to the owner with that cost (rule 3).
   - The safeguards are: RS's deployment gate, C7's cap, `restart_after_crash = off`, the transaction-mode pooler
     allowance, and `CNF-56`'s backend-reassignment assertion.

## Manager checks before launch

- Every harness claim in forms-r63g.md and verify.md was checked against results.md's transcripts.
- The privilege facts were measured as `app` (H-f). The insert-target liveness caveat was read in source
  (xlog.c:9488, `XLogBytePosToRecPtr`). The harness did not observe it, and the text says so.
- The fast-shutdown window is analysis only, and is labelled as such.
- Readers must not start database instances. This is a production host, and the measurements are done.
