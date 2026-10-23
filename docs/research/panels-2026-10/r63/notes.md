# r63 manager notes (panel C: pv-s4m, pv-n98), verified at dc5d40d (panel-c tip; 48287ec + pv-eiql), 2026-10-22

## Outcome rules (fixed before launch)

Per question (Q1 pv-s4m, Q2 pv-n98, Q2b the parent sub-vote):
1. Each reader votes ACCEPT A, AMEND A or CANNOT ACCEPT A. An AMEND counts for A only if the reader marks it
   "behaviour unchanged" and its text does not change any bullet of A's listed behaviour (I check). Otherwise
   it counts as CANNOT ACCEPT A, with the reader's form as its pick.
2. A carries if at least 3 of 4 readers ACCEPT it or AMEND it with behaviour unchanged. Its behaviour goes to
   the owner as the panel's recommendation, with the tally. The text AMENDs are merged into a final form, which
   gets a confirmation read (ACCEPT / CANNOT ACCEPT) before it becomes the Run's work order. The owner
   question quotes only behaviour the panel read.
3. A CANNOT ACCEPT must name the normative content lost or made wrong (a MUST/SHOULD with file:line, or a
   behaviour a conforming engine must or must not show), or a trace that breaks. A CANNOT ACCEPT that names
   none is recorded but does not block.
4. If no form reaches 3 of 4, I take the best-supported reader form, state the disputed point neutrally with
   its sources, and run a confirmation round on that exact form with all four readers. It goes to the owner
   with that round's tally. A 2-2 after the confirmation round goes to the owner as a split, both forms with
   their tallies.
5. A clause that draws non-converging AMENDs in two successive rounds is deleted, not reworded, unless a
   reader names the normative content the deletion loses (rule 3).
6. A verified brief error that changes a question's premise voids that question's tally; the question is
   re-asked, corrected.
7. Counter-arguments "written on request" are not votes. Relay votes first, counter-arguments labelled.

## Line refs (dc5d40d)
- STO-5 05-persistence.md:82-84. STO-56 05:1317 (record read :1321, "once per process" :1333, close rule :1337).
- STO-54 05:1466; posture :1474; sync commit :1480; step (1) :1485; step (2) :1508; step (3) :1514; record
  bullet :1520 ("continuing that incident" :1523, "A marked step does not run again" :1531, close :1541).
- OPS-15 03:352 (pass); restore para :359; record para :373; create exception :387, off-switch :408-411;
  suspend_tenant :418. OPS-5 03:156 ("stays claimed until" :158). OPS-8 03:183. OPS-47 03:135 (exit :145-146).
- OPS-43 step 8 03:744.
- Restore.lean: module doc :28 "What the model omits: the promoted-standby condition"; World.passDone :298;
  permits :332 (claim := w.locked && w.passDone); passOp :352; startupPass guard :421; afterCrash :413;
  quarantine_before_first_claim doc :764-769 ("repeats the pass before it claims").
- CNF-29 10:184; CNF-295 10:1002 (two kills); CNF-358 10:1490 (restore control). Next free: CNF-365, ADR-0045.
- grep 'promot' in requirement files: only 03:409 (OPS-15's off-switch); ADR-0042 quotes it. pv-s4m's "never
  mention a promotion" predates pv-k4l's clause: stale.
- No rule makes `api` exit or re-read the record on losing a store connection (newline-joined grep of 0*.md and
  13: only OPS-47's engine exit and 05's schema-version check "before its listener opens").

## Owner decisions (2026-10-23, via the coordinator)

- Q2 = A ("Clean up every startup"): form F' (/var/tmp/provisiond-panel-r63c/forms-final.md), 4-0 r63c.
- Q3 = A ("One Run, one PR").
- Q1 (pv-s4m): A/B replaced. Owner, verbatim: "I think we should just suppose synchronous replication". Owner's
  message and pasted research (unverified input): /var/tmp/provisiond-manager/owner-q1-sync-2026-10-23.md. New form
  S'' (strict synchronous replication; a promotion holding every acknowledged commit is a restart; STO-54 stays for
  backup/PITR) panelled in /var/tmp/provisiond-panel-r63d/. Form S' is superseded. The Q1 feasibility fact-finding
  stopped; partial notes in /var/tmp/provisiond-panel-r63c/q1-feasibility.md.
