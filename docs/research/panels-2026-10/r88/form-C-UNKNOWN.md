# C-UNKNOWN — Define refusal when restart eligibility cannot be established

Candidate only; not adopted. All unprinted source text stays byte-identical.

## Exact owner form

In `STO-54`, replace only `05-persistence.md:1652–1669` with the following entire block. The existing formal-interpretation paragraph and restore procedure follow unchanged.

```markdown
- **Promoting the standby that holds every acknowledged commit is a restart** (*added 2026-10-23, `ADR-0045`*).
  After every engine and `api` process connected to the old primary has stopped, both standbys `OVR-19` names
  report the end of the WAL each has flushed on the old primary's timeline, and a standby whose reported end is at least as far ahead as the other's is promoted (either may be chosen when they are equal): every acknowledged commit was
  flushed by one of them, and both hold a prefix of one WAL sequence, so every standby at the maximal reported end holds them all and its promotion
  loses none. The
  engine comes up on it under `STO-5`'s restart rule, unless a restore record (`STO-56`) is open there, in which case a process that starts is
  continuing that incident (below). Before any component connects to the promoted store, the deployment MUST stop
  every engine and `api` process that was connected to the old primary, and the old primary MUST NOT serve a
  component again: it may hold commits the standby lacks ("Some transactions may not show as committed on the
  standby, even though they show as committed on the primary"), so it rejoins only as a standby of the promoted
  store. `OVR-19` then names the other standby and the rejoining old
  primary, and writes continue once the other standby streams from the promoted store. Any other promotion —
  without both standbys' report, with a report on another timeline, or of a standby whose reported end is behind the other's, of a standby `STO-7` does not name, or after the primary committed without one of them, served a component before it had caught
  up, or had a waiting backend cancelled or terminated (`STO-7`) — is a restore: the procedure below runs on it, and
  `STO-56`'s record is committed into the promoted store before either component is started.
  Only an operator starts a
  promotion that is a restore: an automatic failover promotes only as a restart, and otherwise leaves the store
  without a primary until both standbys report or an operator decides.

  **Unknown restart eligibility.** For a contemplated promotion, evaluate the restart-promotion
  conditions above for the affected source-primary incarnation/history through the old
  primary's fencing boundary. A condition is established only by evidence valid for that
  database, incarnation and actual WAL ancestry, or by a trusted deployment invariant whose
  uninterrupted coverage establishes the fact. Equal numerical ends alone establish neither
  actual common history nor the absence of a waiting-backend cancellation or termination.
  Classify a known disqualifying condition under the existing restore rule even if another
  fact is unknown. Otherwise restart eligibility is unknown if at least one applicable
  restart condition cannot be established. It is established only when every applicable
  condition is established and none is disqualifying. Continuing an already open restore
  incident remains continuation, not a new restart decision.

  In particular, evidence that no waiting backend was cancelled or terminated MUST cover the
  affected incarnation/history, including shutdown-induced termination and inherited conditions
  and uncertainty on which the contemplated restart depends, through fencing. A trustworthy
  negative assertion requires an authenticated source and complete event coverage, or an
  independently enforced no-event invariant with established coverage and non-bypass. Its
  database/incarnation/ancestry binding and its coverage MUST be verifiable without the lost
  primary or its logs. A missing record, sampled absence, an alarm, unverified operator belief,
  or successful later catch-up is not negative evidence. Conflicting, incomplete, lost or
  invalid evidence leaves that condition unknown unless a disqualifying fact is already known.
  This paragraph specifies no new evidence service or runtime replication-configuration or
  topology-drift controller; existing trusted deployment duties remain in force. A deployment
  unable to supply the negative evidence may use the operator boundary below.

  Automatic failover MUST NOT promote while restart eligibility is unknown and MUST report the
  unresolved condition to the operator. It MUST leave the store without a primary and MUST NOT
  perform a restore. The operator may wait for sufficient valid evidence to establish a restart,
  or authorize a restore under the procedure below; operator belief alone cannot reclassify
  unknown as established. A promotion with unknown restart eligibility MUST be treated as a
  restore when authorized, with the existing incident and startup prerequisites. A known
  violation remains a violation; this rule neither permits it nor turns it into uncertainty.
  A known historical waiting-backend cancellation or termination remains a restore condition,
  including a shutdown-induced termination permitted by the shutdown exception. Time, new
  incarnation identifiers, equal reports or later catch-up do not expire that condition or
  resolve an uncovered historical interval. A later decision MUST retain unresolved inherited
  facts on which it depends rather than treating a new incarnation as clean by default.

  Established eligibility preserves the equal-report restart path above when its other
  conditions hold. Unknown possible-loss reporting endpoints on an operator-authorized restore
  are separate: they use the reporting rules below and do not delay that restore's incident
  creation, procedure or startup once its existing prerequisites are satisfied.
```

## Exact check form

In `10-conformance-checklist.md`, replace the entire `CNF-365` item at lines 1184–1220 with this entire item.

```markdown
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
```
