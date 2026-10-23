## Q1 (pv-s4m) — AMEND A, behaviour changed

A's classification stands: a standby promoted after a crash is a store at `T − Δ`, and `RestoreTrace` already models it ("a store Δ steps behind it with the provider's facts unchanged"). Three amendments: D is added, the instant is made precise, and A's `api` sentence becomes a rule instead of a conceded hazard.

Instant: usable. `pg_last_xact_replay_timestamp()` is the primary's clock, static after promotion, `NULL` after the next normal start, so it is read before that. An idle tail only widens Δ.

"Before any process connects": doable only if the endpoint flip waits for the record write. `OPS-47`'s supervisor restarts the engine within seconds and nothing checks the order. That is the naive boot `STO-54` says it "exists to prevent". D closes it, and closes the same hole for a backup restore.

B deferred: feasible (quote in `ADR-0045`) but needs a verified-position runbook and a second escape in D. Minor upgrades are in-place restarts, so switchovers are rare.

Touches `STO-5`, `STO-54`, `STO-56`, `OPS-15`, `CNF-365`, `ADR-0045`, `Restore.lean` doc. **Owner**: every switchover pays the full procedure.

Drafted text, `STO-54` after the posture bullets:

> **A promoted asynchronous standby is a restore.** PostgreSQL says “If the primary server crashes then some transactions that were committed may not have been replicated to the standby server, causing data loss”; a standby promoted after its primary failed lands at `T − Δ` by another route, a planned switchover included. Its restore instant is what `pg_last_xact_replay_timestamp()` returns on the promoted server before it is next restarted — “If recovery has completed then this will remain static at the time of the last transaction applied during recovery”; “When the server has been started normally without recovery, the function returns `NULL`” — and an idle tail before the failure lengthens Δ, the safe direction. The deployment MUST commit the restore record (`STO-56`) into the promoted store before exposing it to either component, and the timeline checks that it did: PostgreSQL creates a new timeline “Whenever an archive recovery completes”, which a restore from backup, a failover and a switchover each are and a restart is not. The engine records the store's timeline (`pg_control_checkpoint()`'s `timeline_id`) in the store at each start; where the timeline it reads differs from the one recorded and no restore record is open, it MUST exit non-zero having done no work, `OPS-47`'s refusal. `api` MUST refuse the same way at its startup read, and MUST exit when a connection it opens reports a timeline other than that read's. A first boot has no recorded timeline.

`STO-5`: A's note. `STO-56`: "written into the restored store" → "written into the restored or promoted store". `OPS-15`: A's deletion. `Restore.lean` module doc: "the promoted-standby condition" → "the timeline check".

`CNF-365` (new): **The promotion rehearsal.** `CNF-295`'s lost-interval witnesses with the standby lagging: kill the primary before the standby receives them, promote. Start the engine with no record: assert it exits non-zero, the ordered create is untouched, no order repeats. Start an `api` replica: assert it serves nothing; a replica serving across the promotion: assert it exits. Commit the record, run the procedure: assert `CNF-295`'s four witnesses and `restore_instant` equal to the replay timestamp. Repeat as a planned switchover with the record: same assertions. Restart on the same timeline: assert no refusal.

`ADR-0045` records B's route back: “the server will not fully shutdown until all outstanding WAL records are transferred to the currently connected standby servers” (26.2.8.1).

## Q2 (pv-n98) — ACCEPT A

`OPS-5`: a `running` operation stays claimed until it "settles, defers under `OPS-8`, or the startup pass finds it". B leaves both rows claimed by nobody until a restart after close, possibly days: commitment held, the delete deferring forever. C quarantines a create queued after step (3), which never ran in Δ. A's split is what `STO-54` already says: the marks are of the three steps, and step (2) names `queued` rows.

Lean additions to A: `completeProcedure`'s and `confirmParents`' guards read `stepTwoMarked`; `startupPass` sets both flags; add `successor_sweeps_running`: after `.crash, .lock, .startupPass` no row is `running` except a frozen `suspend_tenant` parent.

Touches `OPS-15`, `STO-54`, `Restore.lean`, `CNF-295`. **Mechanics**.

## Q2b — A1

`STO-54` gives the exception its own lift: "it stays off until the operator has confirmed or cancelled every waiting parent". That condition is a subset of `STO-56`'s close rule, so the clause has effect only if the exception can fire while the record is open. A2 makes it dead text. `OPS-15`'s reason for waiting, "the fan-out it would resume may have been reversed inside the interval", is false of a parent claimed after step (3).

Edits: `OPS-15` "And the `suspend_tenant` exception below does not fire on a restore" → "does not fire while `STO-54`'s freeze holds it off"; its italic "*on a restart; after a restore it waits*" likewise; `API-58`'s copy "after a restore it waits for one" likewise; `passOp`'s `suspendTenant` arm reads the exception permission instead of `f.isRestore && p.exceptionFrozen`. **Mechanics**.

## Q3

One Run: both edit `OPS-15`'s record paragraph and `STO-54`, and n98's Lean split should land first so s4m's doc edit sits on it.

## Against my picks (written on request)

**Q1.** D adds a stored row, a per-connection read and an `api` exit rule to a set that deleted the epoch fence (`ADR-0019`, "The lock is not a fence"). A kills every token on a switchover PostgreSQL documents as lossless; B's branch is one sentence and the owner may want it now.

**Q2.** "A marked step does not run again" was written flat. Splitting the pass into a marked quarantine and an unmarked sweep adds a predicate the Lean must carry and `CNF-295` must drive. B is what the model proves today, and stranded rows free at the first restart after close.

**Q2b.** A parent re-queued by the exception resumes a fan-out while `OPS-27` may still be reconciling Δ; the conservative reading costs one operator confirmation.

**Q3.** One Run carries an ADR, a Lean split and a new CNF item in one Round budget; a red Lean gate blocks s4m's text.

## Brief errors

- "`promot` appears in the requirement files only in `OPS-15`'s off-switch": `grep -n -i promot *.md` also hits `01-domain-model.md:45` ("promoted to a property of the domain") and `11-open-findings.md` (tier promotions). Other senses, but the literal claim is false.
- Not an error, an omission the brief's D question needed: `pg_control_checkpoint()` reports the last checkpoint's timeline, so a fast promotion's first seconds can still show the old one; the record write precedes exposure anyway.

Everything else checked: `STO-5`, `STO-54`, `STO-56`, `OPS-5`, `OPS-8`, `OPS-15`, `OPS-47`, `Restore.lean`, `CNF-295`, `CNF-358` quotes, the `api` no-exit fact, and the free ids.
