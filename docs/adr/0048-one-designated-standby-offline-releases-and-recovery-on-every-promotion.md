# One designated standby, ordinary pools, offline releases and recovery on every promotion

**Status:** accepted (2026-11-04). The requirement edits precede this record.
Amends `ADR-0015`, `ADR-0016`, `ADR-0023`, `ADR-0024` and `ADR-0045`. The pointer in
`ADR-0019` records initial deployment scope only and withdraws none of its content.
`ADR-0047`'s startup-generation protection remains in force.

## Decision and owners

For the supported initial profile, see `05-persistence.md`. This decision places more `api` copies
outside that profile while retaining `STO-6`: "`api` MAY run as any number of replicas against the
shared store."
Overlapping releases and automatic promotion are outside the profile.

`STO-7` owns synchronous durability: "The deployment MUST NOT let the primary acknowledge a
provisiond state-changing transaction, a migration or a recovery-incident transaction without the
designated standby". For connection/read safeguards, uninterrupted sessions, standby maintenance
and the isolated maintenance-backup exception, see `STO-7`. No new runtime configuration-drift
controller is introduced.

For ordinary pools, phase-appropriate connection budgets, database/OS resource sizing, local
checkout refusal and saturation recovery, see `STO-55`. The external durable connection-grant
authority is removed. `STO-55` states the retained uncertainty boundary: "Pool checkout failure,
connection failure and failed connection checks MUST NOT be interpreted as proof that a previously
sent COMMIT rolled back or that a previously dispatched provider mutation did not execute."

`STO-54` owns incident entry: "Every promotion or replacement of authoritative history MUST enter
the recovery-incident procedure, including a promotion expected to preserve every acknowledged
commit." `STO-54` also states: "Promotion MUST be operator initiated."
The startup boundary is `STO-54`'s: "The promoted or restored primary MUST have the required
synchronous standby before the transaction establishing the incident is acknowledged. Neither
application component may start before that transaction is acknowledged."
For migration placement, `STO-54` states: "The `migrate` entry point MAY run against the restored
or promoted store after the replacement standby is established and before the incident record
commits; it is not a component for this rule, and no component starts before that commit."
Continuation follows `STO-54`: "A process successor that finds an open incident MUST continue it
using the persisted step marks." For supersession, see `STO-56`: "no predecessor step mark
satisfies a new step".
For ordinary restarts, `STO-54` states: "In-place process and primary restarts on unchanged intact
authoritative history remain ordinary restarts when no incident is open, subject to the existing
startup and connection safeguards." For possible-loss bounds, evidence, recovery contents and
limits, see `STO-54` and `STO-56`.

`STO-12` retains "two runners cannot interleave", "Completion is recorded only after the build
succeeds", and "A statement PostgreSQL refuses inside a transaction block is its own migration,
run outside one, and it MUST be resumable." `STO-13` owns release sequencing: "The deployment MUST stop all
previous-release components, prevent their restart, and establish that their old sessions cannot
continue writing before migration begins." For supported schemas, shared-predicate declarations,
historical backfills and the DDL lock timeout, see `STO-13`. For index builds, `STO-12` states:
"A migration that uses `CONCURRENTLY` retains this invalid-index and crash-resume path even during
an offline release; ordinary offline index builds may be transactional."

Lifecycle companions are `OPS-47` and `OPS-49`; alarms and deployment procedures are registered in
`OVR-18` and `OVR-19`. For the withdrawal of `CNF-372`, see README's withdrawn index; for
saturation/recovery and promotion/bootstrap fixtures, see `CNF-373` and `CNF-365` in
`10-conformance-checklist.md`. The formal checking interpretations are `WalHistory`, `RecoveryEntry` and
`Migration` under `tools/formal/`; they do not establish runtime conformance.

## Reversals and supersession

This decision reverses the rejections of two servers and every promotion as a restore in
`ADR-0045`'s rejected options, the general stop/migrate/start release rejected in `ADR-0024`, and
the two-node stall rejected with synchronous replication on every commit in `ADR-0023`.
`ADR-0047` supplies the precedent form: "This decision reverses that rejection."
For synchronous business commits, see `STO-7`; the increased outage cost is now accepted explicitly.

The former `STO-54` "Unknown restart eligibility" rule from pv-by1w is superseded together with
the entire promotion-eligibility branch. Maximal and equal report selection no longer authorizes
an ordinary restart: `STO-54` states "No promotion is classified as an ordinary restart."
`CNF-365` retains the operator-restore arm, "Promote a lagging standby as an operator restore with
verified prefix/clock evidence and assert the incident stores certified bounds", and its evidence
rules: "For these operator-restore arms, supply certified evidence for each asserted known
`lost_window_starts_at` or `loss_end_at`; store null for each unknown endpoint and retain a
non-null incident-keyed `history_evidence_ref` identifying evidence or unknown-endpoint reasons".
For unknown reporting endpoints, see `STO-54`: "A bound without valid evidence is unknown, not an
invented recovery time."

The grant-authority part of pv-3zzo's migration admission-refusal amendment is superseded. Its
diagnostic fields carry over to PostgreSQL's own connection refusals in `STO-13`'s
"**Migration connection failure.**" paragraph: “The diagnostic MUST identify `migrate`, the
release being attempted, whether this was initial acquisition or reconnect, and the failure reason
as PostgreSQL or the connection layer returned it, for example SQLSTATE `53300` "sorry, too many
clients already", without credentials.” For refusal/failure exit behavior, `STO-13` states:
"`migrate` MUST report the failure and exit non-zero at once; it MUST NOT wait or retry the
connection internally." For deployment retry, `STO-13` states: "A later invocation is a deployment
retry; see `STO-12` for version inspection, serialization and resumability." For those fixtures,
see `CNF-57`.

## Availability and customer-visible costs

The former trade is recorded in `ADR-0023`: "A quorum of two standbys (`ANY 1 (s1, s2)`) tolerates
one standby's loss at the cost of a third node and returns the stall when the second goes."
The designated-standby trade follows `STO-7`: "while it is unavailable, state-changing commits
wait." This decision accepts greater downtime and operator work in exchange for removing the
separate durable reservation ledger. `STO-55` states the sizing limit: "The sum of current pool
limits is therefore not a guaranteed upper bound on server occupancy across process lifetimes."
The accepted outage includes `STO-55`'s "Connection exhaustion MAY prevent application progress
and fresh observer access" and "No spare observer SQL connection or fixed recovery duration is
guaranteed." For primary shutdown during saturation recovery, see `STO-55` and `STO-7`.
Machines at providers keep billing during this control-plane outage.

This decision replaces mixed-release service obligations with offline releases and explicit
binary/schema compatibility; for those rules, see `STO-13`. A failed migration can extend the
outage under `STO-13`'s "The deployment MUST NOT start a new-release component until every required
migration has completed successfully."

Even a lossless promotion incurs customer-visible costs under `STO-54`: "every spending token dies
and each customer re-issues through the recovery credential", and "every `queued` create, install
and rescue inventory is moved to `needs_reconciliation`". For conservative marker provenance,
selective freezes, recovery grace and operator incident work, see `STO-54` and `STO-56`. These are
deliberate costs of removing the eligibility mechanism, not evidence that every promotion loses
acknowledged data. `STO-56` states the freeze boundary: "keeping this record open does not prolong
that freeze." The accepted costs do not buy complete entitlement reconstruction: `STO-54` states
"**an extension lost in Δ is not rebuilt**"; for other unrepaired losses, see that owner.

The prior ADRs, reviews and experiments remain history. This amendment supplies specification and
formal checking evidence only; it claims no running implementation, PostgreSQL or provider validation.
