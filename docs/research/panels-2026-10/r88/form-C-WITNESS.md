# C-WITNESS — Require independently durable historical evidence

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

  **Historical promotion evidence.** Before a primary incarnation first serves component work,
  the deployment MUST establish an independently durable record of that incarnation and its
  inherited history status. The evidence service and its retained records MUST survive loss
  of the primary, its local disks and its local logs; placing another copy on that primary
  does not meet this requirement. The deployment MUST name the trusted issuer, the validation
  procedure and the failure domains on which this evidence depends. Records MUST be
  authenticated, protected against undetected deletion, reordering and substitution, and
  bound to the database identity, the source-primary incarnation, the two named standbys and
  the actual WAL ancestry to which each assertion applies. Matching timeline labels or larger
  numerical positions alone do not establish that binding.

  Before the deployment delivers any cancellation or termination signal to a primary backend,
  or signals an orderly or fast shutdown of the primary, it MUST obtain acknowledgement of an
  independently durable intent record identifying the affected incarnation and the possible
  waiting-backend effect. A failed or unacknowledged intent write MUST prevent that controlled
  signal. This recording does not permit an otherwise forbidden cancellation or termination.
  The evidence procedure MUST cover every such path, including privileged administration and
  whole-primary shutdown. Uncontrolled process death, host crash, immediate shutdown and power
  loss MUST leave an identifiable unresolved coverage interval unless independent evidence
  excludes a waiting-backend cancellation or termination throughout that interval. An
  incarnation MUST be recorded as active before it can serve component work, so its abrupt
  disappearance cannot be mistaken for a clean completed interval. A missing event record,
  without complete coverage, MUST NOT be interpreted as evidence that no event occurred.

  At promotion, the procedure MUST validate the retained evidence through the old primary's
  fencing boundary. A clean-history certificate MUST identify that boundary, its authenticated
  issuer, complete coverage of the affected source-primary incarnation/history and the
  inherited classification facts and uncertainties on which this promotion depends. It MUST
  establish that no relevant waiting backend was cancelled or terminated, including by
  shutdown. An independently enforced invariant that rules out such an event can establish
  this negative fact only if its coverage and non-bypass throughout that history are themselves
  established. Polling absence, unavailable-primary logs, equal end reports, an alarm, an
  unclosed intent or an unsupported operator assertion cannot establish it. A conservative
  intent may be resolved as not having affected a waiter only with authenticated, continuously
  covered evidence of that fact; a known actual cancellation or termination is never erased.

  A known waiting-backend cancellation or termination remains the restore case above, including
  when shutdown permitted that termination. With no known disqualifying condition, missing,
  failed, invalid, conflicting or incomplete historical evidence makes restart eligibility
  unknown. Automatic failover MUST leave the store without a primary in that case and MUST
  report the missing fact to the operator; it MUST NOT create or run a restore. The operator
  may authorize a restore under the procedure below, or wait for evidence sufficient to
  establish a restart. A promotion MUST NOT be classified as a restart while eligibility is
  unknown. Evidence continuity and unresolved uncertainty MUST be carried across incarnation
  changes on which a later restart depends; a new incarnation identifier alone supplies no
  clean-history certificate. Elapsed time, equal reports, later catch-up, or later inclusion
  of the affected commit removes neither a known historical condition nor an uncovered
  interval. This addition introduces no expiry or catch-up reset.

  Complete clean evidence permits the equal-report restart path above when its other conditions
  hold. The existing deployment duties for synchronous configuration and connection routing
  remain trusted duties; this addition requires no runtime replication-configuration or
  topology-drift controller. Historical eligibility evidence does not establish possible-loss
  report endpoints, and unknown report endpoints do not bar an operator-authorized restore
  once its existing startup prerequisites are met. This evidence contract proves no external
  action safe and reconstructs no lost provider resource.
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

  **Historical evidence contract.** Exercise the deployment's independently durable history
  evidence service. In separate fixtures lose the primary, its local disks and its logs after
  (a) a waiting backend was individually cancelled or terminated and (b) a waiting backend was
  terminated by shutdown. In each fixture leave both named standbys reporting the same actual
  old-history end. Establish the cancellation/termination by an independent test observation,
  retain the authentic off-primary records and require the procedure to evaluate them without
  the test's independent observation. Assert known restore classification only where the
  retained records validly establish the event; otherwise assert unknown eligibility. In
  either case assert no automatic promotion and an operator notice. An intent reporting only
  a possible effect cannot establish an actual termination. The individually forbidden action
  remains a deliberately nonconforming fixture. An operator's
  subsequent restore follows the existing stopped-components procedure and acknowledges its
  incident record before startup. This is a classification drill, not a reproduction of the
  unmeasured fast-shutdown read/action schedule.

  In separate cases fail the independent intent write before a controlled backend signal and
  before a controlled primary-shutdown signal; assert no such signal is delivered. Prove the
  active-incarnation record predates component service. Exercise abrupt process/host loss and
  loss of the evidence path while a wait is possible: without independent complete coverage,
  assert unknown eligibility, no automatic promotion and the operator notice. Remove or corrupt
  records, leave an intent unclosed, interrupt coverage, substitute another database or primary
  incarnation, supply equal labels/positions on different actual ancestry, and substitute an
  unauthenticated clean assertion. Each must fail to establish clean history. Lose the primary
  and its logs in every evidence-survival case; a local copy cannot pass the check.

  Retain a known historical termination and separately an unresolved coverage gap, then allow
  standby catch-up and equal reports; neither becomes clean. Carry each status into a successor
  incarnation whose restart depends on that history and assert it is not silently reset. For
  the clean positive control, provide a complete valid certificate through fencing, no open
  restore record and every other restart condition; with equal actual-history end reports,
  promote each standby in separate runs and assert restart, no restore record and no restore
  credential-generation bump. Preserve the ordinary startup-generation advance. Finally let an
  operator authorize a restore while both loss-report endpoints lack evidence; assert null
  endpoints, an explicit unknown report and the existing restore procedure, without waiting for
  historical evidence to manufacture reporting bounds. (`STO-54`)

  (`STO-5`, `STO-7`,
  `STO-54`, `OPS-15`) *Added 2026-10-23 (`pv-s4m`; panel r63, `docs/research/panels-2026-10/r63/`; owner decisions Q1 “I think we should just suppose synchronous replication”; S1 “Three servers (Recommended)”; S3 “B: check each new connection (Recommended)”; P “Wait (Recommended)”; `ADR-0045`): added the promotion, connection-check and operator-choice drill.*
```
