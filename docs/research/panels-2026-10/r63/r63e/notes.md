# r63e manager notes (panel C, Q1 pv-s4m, the LAST round). Clones at dc5d40d. 2026-10-23

r63d tally: /var/tmp/provisiond-panel-r63d/tally.md. CORE fell 1-3 on the primary-restart gap. E1, E2 and E3 are
KEEP (4-0, 4-0, 3-1). RF = R (4-0), F' UNCHANGED (4-0). They stand under the brief-error ruling in tally.md. r63e
reads S''' (the base, two servers), N3 (three servers) and a 2-or-3 recommendation. **There is no r63f.**

## Outcome rules (fixed before launch)

1. The votes are counted separately: CORE (ACCEPT / CANNOT ACCEPT); spans RS, DL, OC, WR and RL (KEEP / DELETE
   each); N3 (ACCEPT / CANNOT ACCEPT); NREC (2 / 3). A CANNOT ACCEPT or a DELETE counts only if it names the
   normative content lost or made wrong (a MUST/SHOULD quoted with file:line, or a behaviour a conforming engine
   must or must not show), or a trace that breaks it, and gives replacement text for that span only. Otherwise it
   is recorded and does not count. A KEEP or ACCEPT with an amendment counts only if its behaviour is unchanged.
   Such amendments are merged as Run review points.
2. CORE carries at 3 of 4 ACCEPT. If it falls short, each span a valid objection names is handled this way:
   - If two or more objectors' replacement texts converge on the same behaviour, the merge goes to the owner as
     the panel's fix, marked "read only by its proposers".
   - Otherwise the span is deleted, unless a reader names the normative content the deletion loses. Then it goes
     to the owner as a split, with the texts and tallies.
3. A new span stays at 3 of 4 KEEP. If it falls short, it takes the fallback written in the brief, unless a reader
   names normative content the fallback loses. Then it goes to the owner with both texts and tallies.
   - RS has no fallback: its absence breaks 05:867 and 04:830, as three r63d readers showed. So an RS that falls
     short goes to the owner, and E2's carve-out "other than by shutting the primary down" goes with it.
   - DL's fallback is "to the owner, with r63d's C1 as the alternative".
4. N3 is reviewed text at 3 of 4 ACCEPT. Otherwise the three-server option goes to the owner with its open
   objections, and choosing it needs one more reading round. That round is the owner's call, not an r63f.
5. NREC: 3 or 4 of 4 is the panel's recommendation. A 2-2 split is no recommendation, and both reasons are
   relayed.
6. E1-E3, R and F' are settled. A reader's claim that S''' breaks one is verified by quote. If the fix only deletes
   words, it becomes a Run review point. Anything else goes to the owner.
7. Ripple: a missed span is verified by quote. If the fix only deletes words, it becomes a Run review point.
   - A fix that needs new words but changes no behaviour becomes a Run review point marked "one reader's text, not
     voted".
   - A fix that changes behaviour goes to the owner.
8. The facts (FE1, FE2) are not votes. r63 rule 6 holds: a verified brief error voids the tally it affects, and
   since no round follows, that item goes to the owner. r63 rule 7 holds. Only text a reader read goes to the owner
   or into the Run.

## Manager checks before launch (2026-10-23, against the sources in /var/tmp/provisiond-panel-r63e/src/)

- xact.c:1605-1609: a commit waits only `if (wrote_xlog && markXidCommitted)`. While it waits it has "marked clog,
  but still show[s] as running in the procarray and continue[s] to hold locks".
- syncrep.c:158 `Assert(InterruptHoldoffCount > 0)` and :341 `WaitLatch(MyLatch, WL_LATCH_SET |
  WL_POSTMASTER_DEATH, -1, ...)`. syncrep.c has no `CHECK_FOR_INTERRUPTS`.
- postgres.c: Execute (:2335-2371) and Sync (:5140-5149) reach `finish_xact_command` (:2913), which calls
  `disable_statement_timeout()` before `CommitTransactionCommand()`. xact.c disables `TRANSACTION_TIMEOUT` (:2414)
  before `RecordTransactionCommit()` (:2422).
- Patroni replication_modes: "blocking all client write requests until at least one synchronous replica comes
  up". Also: "compare its LSN with the LSN on at least one node". And: "will not promote a standby unless it is
  certain that the standby contains all transactions that may have returned a successful commit status".
- functions-admin: `pg_last_wal_receive_lsn()` "received and synced to disk by streaming replication ... If
  streaming replication is disabled, or if it has not yet started, the function returns NULL." So N3 says "the
  end of the WAL each has flushed" and names no function.
- Spec: `00:400` already has a keepalive row ("Startup-lock connection keepalives"), so DL-3's row follows that
  precedent. `00:405` has "Synchronous standby name ... identifier | yes" (startup-validated), which is why span
  WR exists. `ADR-0023:158-170` names the crash loop that DL answers. The claim model has no promotion
  (Claim.lean:318-323), so C15 is a docstring edit; FE1 checks that.
