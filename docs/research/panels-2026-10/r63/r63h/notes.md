# r63h manager notes (panel C, pv-s4m: what r63g left open). Clones at dc5d40d. 2026-10-23

Inputs:
- forms-r63h.md: the items, with the errata block that voids r63g's E1-E6 lines;
- owner-questions-draft.md: r63g tally's rule-8 fixes applied, and question F added;
- r63g's tally, forms, verify and answers: context only;
- results.md (harness).

## Outcome rules (fixed before launch)

1. **Valid votes.** A PICK or a NOT ACCEPTABLE counts only if it names the normative content it rests on (a MUST
   or SHOULD quoted with file:line, a forms text quoted, or, for a test, the MUST it tests) or gives a trace.
   Otherwise it is recorded and not counted. An ACCEPTABLE needs no trace.
2. **Carry test,** for NA′, NA-sol, INV-ADR′ and each test text:
   - An item carries at 3 of 4 valid PICKs, after the manager verifies the lone dissent's NOT ACCEPTABLE trace. If
     that trace shows a verified money loss, or a broken quoted MUST the form doesn't handle, the item doesn't carry.
   - An item also carries when every valid reader PICKs it or marks it ACCEPTABLE, and no valid NOT ACCEPTABLE
     survives verification.
   - A carried item is reviewed text. It is reported to the owner as settled, not asked.
3. **A known hole** means one of these: a verified money loss; a broken quoted MUST; or, for NA only, the failure
   that r63g's rule 9 already found deleting NA re-opens. That failure is H-c: cancelled requests fill the primary's
   connection slots, with no restart, once C7's cap is deleted. It is availability only.
4. **NA′ and NA-sol.**
   - If only one carries, it carries. If both qualify, the one with more PICKs carries. A tie goes to NA′, which
     changes no behaviour.
   - **The S3 coupling.** Readers answer "under S3-A, is NA-sol needed?". If 3 valid readers say yes, with a trace,
     and NA-sol passes rule 2, NA-sol's text becomes part of S3's option A as the owner sees it. Otherwise A's cost
     line states the gap: "under A, a broken database connection lets waiting saves pile up again".
   - **Fallback, if neither carries:** not deletion, because of rule 3. It becomes an owner question that states H-c,
     with NA′, NA-sol and "delete" as the options, and the panel's split.
5. **INV-ADR′.** If it fails rule 2, it is deleted: it is rationale only, so no hole follows. F4's anchor then becomes
   `OPS-32`'s read-based deletions and FSW, not the objective.
6. **FSW.**
   - **(i) Settled by reading.** Three valid readers must trace both of these:
     - draft `STO-54`'s "had a waiting backend cancelled or terminated (`STO-7`)" already makes the promotion a
       restore;
     - the party that starts it can know this after the primary is lost, using existing text.

     Then FSW is settled. It is one line to the owner, with no new text, and F4 keeps it as an audit item.
   - **(ii) Otherwise FSW is an owner question,** with the hole stated (the trace, and `05:867`'s re-issue). The
     panel's pick goes first: 3 of 4 valid PICKs, or failing that rule 2's acceptability test. Otherwise the split is
     stated plainly.
     - If readers find that `STO-54` covers it but the party can't know it, the question says so.
     - A reader's new text that would make it knowable (a new duty) is handled under rule 9. It does not become a
       third option without a round.
   - FSW-L's ADR sentence and FSW-N's text are the read texts. Fixes go under rule 9.
7. **Test texts.**
   - Each carries under rule 2 and becomes a Run review point.
   - In a pair (T3, T4, T6), a reader PICKs at most one; a second PICK counts as ACCEPTABLE.
   - If both of a pair carry, the one with more PICKs wins. Ties are fixed now: T3 goes to T3b (a concrete scenario
     that reddens build (e)), T4 to T4b (it amends the existing sentence), and T6 to T6a.
   - T4a and T4b land only if the owner picks PA-2.
   - A test that doesn't carry is dropped. The wrong build it would have caught is listed as "no check catches it":
     in the misconfiguration lines if it's a deployment's error, in the F list otherwise.
8. **Settled items aren't re-voted.** Votes on STOP, S3, PA, PT or INV-STO aren't counted. Only a verified brief
   error, or a verified money trace, reaches the owner, as a line in that question.
9. **Reader text.**
   - A fix that only deletes words becomes a Run review point.
   - A fix with new words that changes no behaviour becomes a Run review point marked "one reader's text, not
     voted".
   - A behaviour-changing fix enters no form. If three or more readers converge on the same behaviour, the
     manager's merge needs its own reading round before the owner sees it as a recommendation.
10. **Brief errors.** Each is verified by quote. A verified error voids the tally of the item it affects. A voided
    spec-internal item is treated as not carried (rules 4, 5 and 7 give the fallbacks). A voided owner item goes to
    the owner with the error stated.
11. **Narrowings and deletions** (Q5).
    - If a valid trace shows that NA's dropped bound claim, INV-ADR's broader scope, INV-STO, the per-read check that
      FSW-L forgoes, NA-sol's charge or a dropped test was protecting something that nothing left protects, and the
      loss is a known hole (rule 3), then the narrowing item doesn't carry, or the owner item states that cost.
    - Availability-only losses go to F2 or F3 and the owner's cost lines.
12. **Owner-question wording.** A verified wording fix that changes no option's behaviour is applied without a vote.
    A fix that changes what an option does is handled under rule 9.
13. **Only text a reader read** goes to the owner or into the Run.

## Manager checks before launch (done 2026-10-23 ~06:40Z)

- Every quote in forms-r63h.md was checked against its source at `dc5d40d`:
  - `05:140-145`, `05:184`, `05:195`, `05:867`, `05:1485-1486` and `05:1514-1518`;
  - `03:760`, `03:1422`, `03:1630-1635` and `03:1824-1830`;
  - `04:829-831`.
- The r63g reader quotes were grepped verbatim in astra.md (lines 31, 32 and 34), sol.md (33 and 36), opus.md (62,
  64 and 66) and fable.draft.md (49 and 51). The tally had shortened astra's C12 line, and it is given in full as
  T1-T5.
- The FSW trace's PostgreSQL facts were checked in the source, the docs and the harness:
  - `postmaster.c:2141-2172` (a fast shutdown sets `PM_STOP_BACKENDS`), `:2993` (`SignalChildren(SIGTERM, …)`) and
    `:3482` (the per-child loop);
  - `18-syncrep.c:297-308` and `:331`, `18-xact.c:1563-1567`, and `warm-standby.txt:169`;
  - H-b's terminate transcript (`3|T` visible).
- Two things are not measured, and the texts say so: the reader race (step 5) and the window's length.
- "B′ makes NA-sol unnecessary" is opus's r63g claim. The manager checked it from source; the in-flight COMMIT case
  is left open for readers.
- Not claimed: that `pg_ctl`'s default mode is fast. It is unverified here, so the owner story says "stopped with a
  fast shutdown".
