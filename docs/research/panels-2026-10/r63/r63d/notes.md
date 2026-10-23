# r63d manager notes (panel C, Q1 re-formed after the owner's decision). Clones at dc5d40d. 2026-10-23

Owner on Q1 (pv-s4m), verbatim: "I think we should just suppose synchronous replication". The input is in
/var/tmp/provisiond-manager/owner-q1-sync-2026-10-23.md (the owner's pasted research, checked below, not trusted).
Q2 = A (F') and Q3 = A are settled. S' is superseded.

## Outcome rules (fixed before launch)

1. Votes, each counted separately:
   - CORE: ACCEPT or CANNOT ACCEPT.
   - E1, E2, E3: KEEP or DELETE each.
   - RF: R or F.
   - F': UNCHANGED or CHANGE.
   A CANNOT ACCEPT, a DELETE or a CHANGE must name the normative content lost or made wrong (a MUST/SHOULD quoted
   with file:line, or a behaviour a conforming engine must or must not show) or a trace that breaks it, and give
   replacement text for that span only. Otherwise it is recorded and does not count. A KEEP with an amendment counts
   as KEEP only if its behaviour is unchanged.
2. CORE carries at 3 of 4 ACCEPT. If it falls short, converging replacement texts are merged and r63e reads the
   merge. A span that draws non-converging amendments in both r63d and r63e is deleted, unless a reader names the
   normative content the deletion loses.
3. An E clause stays at 3 of 4 KEEP. If it falls short, r63e reads it with the KEEP readers' trace stated
   neutrally. If it falls short again there, it is deleted.
4. RF: 3 of 4 is the panel's pick. Otherwise it goes to the owner as a split, with both texts and tallies.
5. F' is unchanged at 3 of 4 UNCHANGED. A valid CHANGE that falls short of that goes to r63e.
6. Ripple: a reader's missing span is verified by quote. If the fix only deletes the contradicted words, it goes to
   the Run as a review point. A fix that needs new words goes to r63e.
7. The fact questions (FA1, FA2, FC1, FC2) are not votes. They feed the owner's 2-versus-3-nodes question and the
   E clauses' traces.
8. r63 rules 6 and 7 hold. At most one more round (r63e); splits left after it go to the owner. Only text a reader
   read goes to the owner or into the Run.

## Sources verified by the manager (2026-10-23, curl)

- postgresql.org/docs/current: warm-standby 26.2.8, 26.2.8.1, 26.2.8.3, 26.2.8.4; runtime-config-wal
  `synchronous_commit`; monitoring-stats wait event `SyncRep`. Quotes are in brief.md.
- PostgreSQL source, from the official mirror github.com/postgres/postgres master:
  - `src/backend/replication/syncrep.c` (cancel/die handling, `WaitLatch` flags).
  - `src/backend/tcop/postgres.c` `finish_xact_command` (`disable_statement_timeout()` before
    `CommitTransactionCommand()`; simple-query path only checked).
  - `src/backend/utils/init/postinit.c` `StatementTimeoutHandler` (sends SIGINT).
- patroni.readthedocs.io/en/latest/replication_modes.html: strict mode, the cancelled-backend note, "at least three
  Postgres data nodes".
- The owner's research checked: the zero-loss claim for acknowledged commits is true (26.2.8.4's guarantee); the
  cancelled-backend edge case is true (Patroni note; syncrep.c warning). The 2- and 3-node table matches Patroni's
  "use at least three Postgres data nodes to ensure write availability if one host fails". Settings such as
  `FIRST 1 (standby1)` are an example, not a requirement.

## Dropped before launch (manager)

- A log-based condition ("a promotion after the old primary logged the cancelled-wait warning is a restore"): it
  can't be checked once the old primary's disk is gone. So every unplanned failover would become a restore, which
  defeats the owner's decision. Prevention clauses E1 and E2 replace it.
