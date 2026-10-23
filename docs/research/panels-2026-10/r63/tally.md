# r63 tally (panel C) — 2026-10-23, panel-c dc5d40d (master 48287ec + pv-eiql)

All four exited 0: fable 7120 B, opus 7417 B, astra 5976 B, sol 6045 B. fable and opus were started by hand by the
coordinator at about 23:47Z (owner's request); the 00:01Z timers were stopped. No reader ran a gate or `lake`.
Votes first; "Against" lines were written on request and are not votes. Rules: notes.md.

## Q1 pv-s4m: promoted asynchronous standby

- fable: AMEND A, behaviour changed. A's classification, a planned switchover included; restore instant =
  `pg_last_xact_replay_timestamp()` read before the next restart; adds D (timeline check: engine exits and `api`
  refuses/exits on a timeline change with no open record); `STO-56` "restored or promoted store"; new CNF-365.
  **owner**.
- opus: AMEND A, behaviour changed. A's classification; rejects B and D ("D covers only the engine"); restore
  instant = replay timestamp read at promotion; `STO-56` gains a deployment barrier (old processes exited, promoted
  store accepts no connection before the record); ADR-0045 amends ADR-0042; new CNF-365 with a planned-switchover
  repeat. **owner**.
- astra: AMEND A, behaviour changed. "Every promotion ... including a planned switchover"; deployment barrier (stop
  every process, deny connections, record before fresh processes); restore instant = an evidenced conservative
  bound, a NULL timestamp is not zero loss, no bound = components stay stopped; adds "A candidate containing an
  open restore record MUST remain unavailable to both components". New CNF-365. **owner**.
- sol: AMEND A, behaviour changed. Same as astra minus the open-record clause; instant: the replay timestamp when
  available, otherwise an earlier verified backup point; no bound = blocked. New CNF-365. **owner**.
- **4-0 in substance:** every promotion, a planned switchover included, is a `STO-54` restore (B rejected 4-0);
  the record is committed before any component process connects; `OPS-15`'s lost-writes clause is deleted;
  new `CNF-365`; `ADR-0045`.
- **Split:** enforcement: deployment barrier (opus, astra, sol) vs plus engine/`api` timeline refusal D (fable).
  Restore instant: replay timestamp (fable, opus) vs evidenced conservative bound with a fallback (astra, sol).
  astra's open-record clause: one reader.
- No form reaches 3 of 4 under rule 1 → rule 4: confirmation round r63b on a synthesized form.
- Against (on request), all four: B would spare planned switchovers the outage, the quarantine and the token kill.

## Q2 pv-n98: the running-row pass while the record is open

- fable: ACCEPT A (Lean: completeProcedure/confirmParents guards read stepTwoMarked; theorem
  successor_sweeps_running). **mechanics**.
- opus: AMEND A, behaviour unchanged (cite OPS-5 by quote; "the restore's exceptions stay off" for "the restore
  branch"; Params.passEveryStartup guard, theorem, witness; DEF-16 control). **mechanics**.
- astra: AMEND A, behaviour changed (step (2) also holds the parents, not only the quarantine; claim needs
  stepTwoMarked only in restore mode; the model must admit fresh work after step (3)). Keeps A's running-row rule
  and CNF change. **mechanics**.
- sol: AMEND A, behaviour unchanged (same Lean corrections as astra). **mechanics**.
- **A carries 3 of 4** (fable, opus, sol); 4-0 in substance; B and C rejected 4-0.

## Q2b: a parent found running after the freeze lifted

- A1 4-0 (fable mechanics, opus mechanics, astra owner, sol owner). Edits: `OPS-15` "does not fire on a restore"
  qualified by the freeze; its parent italic; `API-58`'s copy (fable, sol); `passOp` reads the permission.

## Q3: one Run

- Yes 3-1 (fable, astra, sol); opus: no (pv-n98 could land before the owner's Q1 call).

## Brief errors (verified)

- "`promot` appears ... only in `OPS-15`": false as written (01:45, 11-open-findings, other senses). All four.
  Premise unchanged.
- The stranded-row stake: `OPS-8`'s index excludes yielded rows, and an unfinished create need not name a machine
  (astra, sol). The power-operation example stands. Premise unchanged.

## Facts the manager verified after the round (postgresql.org/docs/current)

- functions-admin: `pg_last_xact_replay_timestamp()` "If no transactions have been replayed during recovery, the
  function returns `NULL`." / "If recovery has completed then this will remain static at the time of the last
  transaction applied during recovery." / "When the server has been started normally without recovery, the
  function returns `NULL`." / "the commit or abort WAL record".
- warm-standby 26.2.8: "If the primary server crashes then some transactions that were committed may not have
  been replicated to the standby server, causing data loss." 26.2.8.1: "as when using asynchronous replication,
  the server will not fully shutdown until all outstanding WAL records are transferred to the currently
  connected standby servers." (B's feasibility for a planned switchover.)
- continuous-archiving 25.3.6: "Whenever an archive recovery completes, a new timeline is created". That page
  does not say a promotion creates one: D's premise is unverified there. fable itself notes
  `pg_control_checkpoint()` can lag after a fast promotion.

## Candidate bead (not filed; tell the coordinator)

- astra: a promotion (or any second loss) while a restore record is already open. The successor continues the
  open incident with step (2) marked, so work admitted after step (3) and lost again is not quarantined. One
  reader; beyond pv-s4m.
