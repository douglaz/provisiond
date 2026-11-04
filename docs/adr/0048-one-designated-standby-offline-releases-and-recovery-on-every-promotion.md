# One designated standby, ordinary pools, offline releases and recovery on every promotion

**Status:** accepted (2026-11-04). The requirement edits precede this record.
Amends `ADR-0015`, `ADR-0016`, `ADR-0023`, `ADR-0024` and `ADR-0045`. The pointer in
`ADR-0019` records initial deployment scope only and withdraws none of its content.
`ADR-0047`'s startup-generation protection remains in force.

## Decision and owners

The supported initial profile is recorded in `05-persistence.md`: one engine, one `api` copy,
one PostgreSQL primary and one designated synchronous physical standby in separate failure
domains. More `api` copies are outside this initial profile; the multi-replica safety guarantees
remain, including `STO-6`: "`api` MAY run as any number of replicas against the shared store."
Running one copy does not remove concurrent requests or the need for transactional serialization.
Overlapping releases and automatic promotion are outside the profile.

`STO-7` owns synchronous durability: "The deployment MUST NOT let the primary acknowledge a
provisiond state-changing transaction, a migration or a recovery-incident transaction without the
designated standby". Its connection/read safeguards, uninterrupted-session exclusion and narrowly
isolated maintenance-backup exception remain at that owner. Standby rebuilding on intact primary
history is maintenance; the documented physical bootstrap must work without first committing an
application or incident row. No new runtime configuration-drift controller is introduced.

`STO-55` owns ordinary pools, phase-appropriate sizing, local checkout refusal and saturation
recovery: "The sum of current pool limits is therefore not a guaranteed upper bound on server
occupancy across process lifetimes." The external durable connection-grant authority is removed.
The deployment limits reconnect/restart growth, alarms database failure and may require primary
shutdown to recover. Observer access and bounded outage duration are not guaranteed. Commit
uncertainty and provider reconciliation remain required; a failure to acquire a connection is no
proof that an earlier transaction rolled back or an external mutation did not execute.

`STO-54` owns incident entry: "Every promotion or replacement of authoritative history MUST enter
the recovery-incident procedure, including a promotion expected to preserve every acknowledged
commit." Promotion is operator initiated. Replacement standby, any necessary migration,
acknowledged incident establishment and component startup occur in that order. A process successor
on the same history continues an open incident; a new promotion or history replacement follows
supersession in `STO-56`: "no predecessor step mark satisfies a new step". Same-history intact
restarts with no open incident stay ordinary restarts. Known and unknown possible-loss bounds,
their evidence and the existing recovery contents and limits remain at those owners.

`STO-12` retains "two runners cannot interleave", "Completion is recorded only after the build
succeeds", and "A statement PostgreSQL refuses inside a transaction block is its own migration,
run outside one, and it MUST be resumable." `STO-13` owns release sequencing: "The deployment MUST stop all
previous-release components, prevent their restart, and establish that their old sessions cannot
continue writing before migration begins." For supported schemas, shared-predicate declarations and historical backfills, see `STO-13`. Ordinary transactional index
builds are permitted; an actual concurrent build retains its standalone and invalid-index handling.
The DDL lock timeout still bounds locks held by operator or leftover sessions.

Lifecycle companions are `OPS-47` and `OPS-49`; alarms and deployment procedures are registered in
`OVR-18` and `OVR-19`. The conformance inventory is `10-conformance-checklist.md`; `CNF-372` is
withdrawn, and `CNF-373` covers the changed saturation/recovery promise. `CNF-365` owns promotion
and bootstrap fixtures. The formal checking interpretations are `WalHistory`, `RecoveryEntry` and
`Migration` under `tools/formal/`; they do not establish runtime conformance.

## Reversals and supersession

This decision reverses the rejections of two servers and every promotion as a restore in
`ADR-0045`'s rejected options, the general stop/migrate/start release rejected in `ADR-0024`, and
the two-node stall rejected with synchronous replication on every commit in `ADR-0023`.
`ADR-0047` supplies the precedent form: "This decision reverses that rejection."
Synchronous business commits remain; the increased outage cost is now accepted explicitly.

The former `STO-54` "Unknown restart eligibility" rule from pv-by1w is superseded together with
the entire promotion-eligibility branch. Maximal and equal report selection no longer authorizes
an ordinary restart. The operator-restore arm and its evidence rules in `CNF-365` are retained;
unknown reporting endpoints do not acquire a finite value merely because entry is unconditional.

The grant-authority part of pv-3zzo's migration admission-refusal amendment is superseded. Its
diagnostic fields carry over to PostgreSQL's own connection refusals in `STO-13`'s
"**Migration connection failure.**" paragraph: "The diagnostic MUST identify `migrate`, the
release being attempted, whether this was initial acquisition or reconnect, and the failure reason
as PostgreSQL or the connection layer returned it", without credentials. The migration still
exits non-zero at once on a refused or failed connection, and a later deployment invocation retries
from recorded history. For those fixtures, see `CNF-57`.

## Availability and customer-visible costs

The former profile could continue writing after losing one of its standby pair. The designated
standby profile instead waits and can become unavailable on that loss. Abandoned waiting backends
can exhaust connection capacity across process lifetimes; ordinary pool sizing accepts that outage
instead of maintaining a separate durable reservation ledger. An operator may need host-level
control or primary shutdown, and no fixed recovery time is promised. Machines at providers keep
billing during this control-plane outage.

Every release interrupts both application components for migration. Explicit binary/schema
compatibility replaces the former directional version rule and mixed-release service obligations.
A failed migration can extend that outage until a later deployment invocation succeeds.

Even a lossless promotion now incurs recovery's customer-visible and operator costs: spending-token
invalidation and reissue, quarantine of irreversible queued work, conservative marker provenance,
recovery grace and incident work. These are deliberate costs of removing the eligibility mechanism,
not evidence that every promotion loses acknowledged data. The retained selective freezes have their
existing grace endpoint; an open incident does not become an indefinite hold for complete entitlement
reconstruction. Recovery still cannot recreate facts absent from every surviving source.

The prior ADRs, reviews and experiments remain history. This amendment supplies specification and
formal checking evidence only; it claims no running implementation, PostgreSQL or provider validation.
