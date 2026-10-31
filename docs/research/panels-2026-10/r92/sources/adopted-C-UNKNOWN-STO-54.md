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
