# r63f manager notes (panel C, pv-s4m: S2 consensus, S3 vote). Clones at dc5d40d. 2026-10-23

Background:
- Owner answers, verbatim: S1 "Three servers (Recommended)"; S2 "Call the panel again to try to find consensus";
  S3 "Analyze this better".
- S1 is merged into /var/tmp/provisiond-panel-r63e/forms-final.md (N3 applied; pre-merge copy kept as
  forms-final.md.bak-pre-S1).
- The S3 analysis is s3-analysis.md here. Sources are in src/ (PostgreSQL REL_18_STABLE and docs 18, Patroni
  master).
- No r63e reader proposed a compromise on S2. STOP and LOCK are offered as separable sub-questions, and every
  combination's text is written out in the brief.

## Outcome rules (fixed before launch)

1. **Valid votes.** A PICK, or a NOT ACCEPTABLE, counts only if it names the normative content it rests on (a MUST
   or SHOULD quoted with file:line) or a trace. Otherwise it is recorded and not counted. An ACCEPTABLE needs no
   trace.

2. **S2: STOP and LOCK are tallied separately.**
   - (a) A form carries at **3 of 4 valid PICKs**. The manager verifies the lone dissent's NOT ACCEPTABLE trace
     against the sources. If it shows a verified money loss, or a broken quoted MUST that the carrying form doesn't
     handle, the form doesn't carry, and the sub-question goes to the owner. Otherwise the form is reviewed text.
   - (b) If no form has 3 PICKs, a form still carries when **every valid reader PICKs it or marks it ACCEPTABLE**,
     and no valid NOT ACCEPTABLE against it survives verification. If both forms qualify, the one with more PICKs
     carries. A tie goes to the owner.
   - (c) Otherwise the sub-question goes to the owner. The split is stated plainly, with each reader's MOVE line
     and P answers.
   - (d) S2 is settled by a carried form: the owner asked for consensus, so a carried form isn't put back as a
     question. It is reported to the owner as the result.

3. **S3.**
   - (a) An option is **the panel's pick** at 3 of 4 valid PICKs, each stating that it closes s3-analysis §1's
     trace. The lone dissent is verified as in 2(a).
   - (b) If there is no 3-of-4 pick, rule 2(b)'s acceptability test applies.
   - (c) S3 always goes back to the owner as a question. The owner asked for analysis, not for the panel to pick.
     The panel's pick, if any, comes first, with its tally. Its text is then reviewed: everyone read it in this
     round.
   - (d) S3-P or S3-N can be the panel's pick only if each picking reader either shows the hole closed, or names the
     window it accepts.

4. **Reader text.** A fix that only deletes words becomes a Run review point. A fix with new words that changes no
   behaviour becomes a Run review point marked "one reader's text, not voted". A fix that changes behaviour doesn't
   enter a carried form. It goes to the owner beside the question, marked with who proposed it. If three or more
   readers' fixes converge on the same behaviour, the merge goes to the owner as the panel's fix, marked "read only
   by its proposers".

5. **Brief errors.** Each is verified by quote. A verified error voids the tally of the item it affects, and that
   item goes to the owner. A verified merge slip in forms-final.md is fixed back to the voted text as a Run review
   point.

6. **Ripple.** A missed span is verified by quote, then handled under rule 4.

7. **Only text a reader read** goes to the owner or into the Run.

## Manager checks before launch (2026-10-23)

- **S3 facts.** All verified in the sources: s3-analysis.md, sections 1-3. Points to note:
  - `PgStartTime` is assigned only in `PostmasterMain` (postmaster.c:1371) and `PostgresSingleUserMain`
    (postgres.c:4160). It is copied in launch_backend.c (code search: 5 files).
  - Patroni: `restart_after_crash` appears only in `available_parameters/0_postgres.yml` (GitHub code search, 1
    hit).
  - Patroni's `recover()` path "starting primary after failure" has no catch-up gate.
  - "Patroni ignores an in-place reinit" is labelled as an inference.
- **Time limits.** The sweep started from every deadline/timeout/kill line in 00-08, 12, 13 and CONTEXT, not from
  "commit" paragraphs. It is the brief's table. Two rows weren't in the r63e brief:
  - `statement_timeout` also ends a statement blocked behind a waiter (FL1). LOCK-B's text names only
    `lock_timeout`.
  - The migrator's DDL in `SyncRep` holds `ACCESS EXCLUSIVE` (FL2): a third lock holder, which blocks reads too.
- **No-slip checks.** `idle_in_transaction_session_timeout` can't fire during the wait (postgres18.c:4576, :4590,
  :4714). The startup-lock connection carries no write (`OPS-47`, `STO-51`). The checkout bound refuses before any
  transaction (`STO-55`).
- **Wait-event visibility (FL3).** It is a cost of LOCK-B's "while a primary backend waits with wait event
  `SyncRep`" and of S3-B's `pg_stat_replication` read (walsender.c:4031). It is stated as a fact, without a verdict.
- **Merge point.** In STO-54's sentence 2 under N3, OC's clause was kept as its own sentence. The brief asks readers
  to check it.
- **Corrections made after a review, before launch.**
  - FL4: systemd lets a `Type=notify` service extend its stop with `EXTEND_TIMEOUT_USEC` (`man systemd.service`).
    r63e's owner-questions line that a stock supervisor "can't see the wait" is wrong for systemd.
  - Fact FP: behind a transaction-mode pooler (`STO-55` `05:195-197`), (i) doesn't see a reinit. S3-B gains a
    pooler clause, S3-AB keeps RS, and s3-analysis.md is qualified to match.
- **Promotion double failure.** The manager traced a promotion followed by the loss of the promoted store. It is
  not a hole: a second promotion without both standbys' report is a restore under N3's RL list, which the
  derivation-index gap covers. So it is not in the brief.
