- [ ] **CNF-365** — **Promotion after the primary is lost** (`ADR-0045`). With both components
  running, let one create
  commit step 8 and order, and claim a second. Kill the primary and promote a named standby whose reported end is at least as far ahead as the other's, with no open restore record and every other restart-promotion condition satisfied, by the deployment's procedure, with a standby streaming from the promoted store. Assert that every engine and `api` process connected
  to the old primary has stopped before any component connects to the promoted store, and that the old primary
  serves no component; that both rows are on the promoted store; that no restore record is written; and that the
  successor's startup pass takes `OPS-15`'s restart branch. Then, with both standbys stalled while a write waits,
  crash the primary, restart it in place, then separately crash one backend while a write
  waits, and each time assert no component uses a connection before a standby has flushed at or past the flush
  position it reported. For both components: With healthy replication, withhold position-query results through the connection-attempt
  deadline. Assert closure without use or fallback, no check-issued writes, and no check-created `SyncRep` backend.
  Inspect the deployed topology for transaction-mode pooling.
  With one standby unreachable, assert the
  procedure promotes neither as a restart
  and none until an operator decides, while that standby's report stays unavailable.
  With one standby on another timeline, assert the
  procedure promotes neither as a restart and automatic failover promotes neither standby at all,
  including as a restore, before an operator decides, regardless of whether the numerical reports
  are equal (`STO-54`: “Only an operator starts a promotion that is a restore”). Stop one standby, make an acknowledged write, stop the other, lose the
  primary, restart both standbys, and assert the procedure promotes the one holding that write, then repeat with the standbys' roles swapped.
  Promote a lagging standby as an operator restore with verified prefix/clock evidence and
  assert the incident stores certified bounds. Repeat with an idle restarted standby that has
  replayed no transaction record and no retained fallback proof: assert unknown history bound
  and an explicit nonnumeric report, followed by the existing restore procedure. Repeat with no
  verified event-clock bound and assert an unknown upper bound. Do not use a restart time or a
  backup name to fill an unknown history bound.
  For these operator-restore arms, supply certified evidence for each asserted known
  `lost_window_starts_at` or `loss_end_at`; store null for each unknown endpoint and retain a
  non-null incident-keyed `history_evidence_ref`
  identifying evidence or unknown-endpoint reasons (`STO-54`, `STO-56`).

  Repeat with both named standbys reporting the same flushed end on the old primary's timeline, no open restore record and every other restart-promotion condition satisfied, once promoting each standby. Assert restart classification, no restore record and no tenant credential-generation bump from the restore procedure. Preserve the engine's ordinary startup-generation advance.

  Repeat with equal numerical reports on different timelines and with an unavailable report; neither case may use the equal-position path. With unequal reports on the same history, the greater end may use the restart path only with all other conditions satisfied; selecting the behind standby requires an operator's restore. Repeat equal reports after the primary committed without either named standby, and separately after a waiting backend was cancelled or terminated, each made known to the deployment's procedure: equality permits neither promotion as a restart. Automatic failover does not perform these restores; an operator's restore follows the stopped-components procedure and commits its record with acknowledgement before component startup.

  Repeat equal reports with an open restore record. Assert continuation of that same incident. A marked step does not repeat; with step (3) unmarked, its credential-generation bump still occurs when that step is completed, and with step (3) already marked it is not repeated. Equality neither closes the record nor waives any outstanding incident obligation.

  **Unknown restart eligibility.** Construct two fixtures with identical surviving standby
  reports on the same actual old-primary history and no open incident. In the first, establish
  complete trustworthy negative evidence of no waiting-backend cancellation or termination;
  satisfy every other restart condition. Promote each equal standby in a separate run and
  assert restart classification, no restore record and no restore credential-generation bump,
  preserving the ordinary startup-generation advance. In the second, arrange a waiting-backend
  termination independently observed by the test, then lose the primary and its logs and hide
  the event evidence from the promotion procedure; the surviving reports are the same as in
  the first fixture. Assert unknown eligibility, operator notice and no automatic promotion.
  Do not give the procedure the test's hidden oracle or label its unknown state as a known
  violation. In a separate known-event case supply valid event evidence and assert the existing
  restore classification, including when the termination was caused by primary shutdown.

  Repeat unknown eligibility with no event in fact but lost or incomplete coverage, mismatched
  database/incarnation/ancestry evidence, an unauthenticated clean assertion and conflicting
  records. Missing logs or an assertion without continuous coverage cannot pass. Retain a known
  termination and separately an unknown interval across later catch-up, equal reports and an
  incarnation change on which the next restart depends; neither is silently reset. In each
  unknown fixture assert no restore begins automatically; let an operator explicitly authorize
  one and assert the stopped-components procedure and an acknowledged incident record before
  startup. This is not a fast-shutdown read/action reproduction. Finally authorize a restore
  with no certified loss-report endpoints and assert null endpoints and an explicit unknown
  report, followed by the existing procedure without a wait for reporting evidence. (`STO-54`)

  (`STO-5`, `STO-7`,
  `STO-54`, `OPS-15`) *Added 2026-10-23 (`pv-s4m`; panel r63, `docs/research/panels-2026-10/r63/`; owner decisions Q1 “I think we should just suppose synchronous replication”; S1 “Three servers (Recommended)”; S3 “B: check each new connection (Recommended)”; P “Wait (Recommended)”; `ADR-0045`): added the promotion, connection-check and operator-choice drill.*
