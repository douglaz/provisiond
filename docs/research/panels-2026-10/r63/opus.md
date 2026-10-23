# Panel C answer (r63): pv-s4m and pv-n98

On Q1 I amend A and call it an owner decision. On Q2 I amend A as mechanics. On Q2b I pick A1. On Q3, no. I ran no gate and no `lake`, so the Lean changes below are proposed edits and nothing has proved them. The answer is 886 words, headers included, and is also saved at `/var/tmp/provisiond-panel-r63/opus/panel-c-answer.md`.

## Q1: AMEND A (behaviour changed)

**The hole in A.** A's MUST still lets an `api` replica that started before the promotion reconnect after the record commits. `STO-56` says “The startup read above is taken once per process”, so that replica serves without ever reading the record.

**What a deployment can actually do.** Stop both components, and open the promoted store to them only after the record commits. `OPS-47` already makes the engine exit when it loses the lock's connection, so its supervisor's restarts only have to be kept off the promoted store until then. A failover manager that repoints connections at promotion cannot meet this.

**The instant is usable only if it is read at promotion.** PostgreSQL (functions-admin.html) returns `NULL` “When the server has been started normally without recovery”. Its value is the time of “the commit or abort WAL record”. If the primary was idle, the value falls before the cut, which is the safe side.

**Why not B or D.** B would add a branch just to prove a rare switchover lost nothing. D covers only the engine, and `api` is where the hole is.

Drafted changes:
- **`STO-54`, A's new bullet:** replace everything from "its restore instant is" to the end with “its restore instant is what `pg_last_xact_replay_timestamp()` returns on it when it is promoted, read before it is first restarted, and the record is committed into it as `STO-56` orders.”
- **`STO-56`:** after "before either component is started", insert “— on a promoted standby, after every process of either component that ran on the failed primary has exited, and before the promoted store accepts a connection from either —”.
- **`OPS-15`:** A's deletion stands.
- **`ADR-0045`:** amends `ADR-0042`, which quotes the deleted clause twice.
- **`Restore.lean`'s module doc:** stops listing "the promoted-standby condition" as omitted, because a promotion is a `RestoreTrace`.
- **New `CNF-365`: "A promoted asynchronous standby is a restore."** With both components running, claim one create and enqueue a second, then cut the standby off the replication stream. Let the first create commit step 8 and order, and let the second be claimed and order. Run `CNF-295`'s lost-interval witnesses, then kill the primary and promote the standby by the deployment's procedure. Assert:
  - no process that ran on the primary connects to the promoted store;
  - the record commits before either component starts there, and its instant is the `pg_last_xact_replay_timestamp()` value read at promotion;
  - both creates are `needs_reconciliation` with their commitments open, neither `failed` nor ordered again;
  - `CNF-295`'s restore assertions hold.

  Repeat as a planned switchover. (`STO-5`, `STO-54`, `STO-56`, `OPS-15`)

**Touches:** `STO-5`, `STO-54`, `STO-56`, `OPS-15`, `ADR-0042`, `ADR-0045`, `CNF-365`, and `Restore.lean`'s module doc.
**Owner:** every switchover then kills every token and quarantines every queued create.

## Q2: AMEND A (behaviour unchanged)

Step (2) names only `queued` rows.
- **B** strands a `running` row for as long as the record is open, so that machine's delete keeps deferring under `OPS-8`.
- **C** breaks “A marked step does not run again”.

The model already reaches the bug: a power operation is claimed after step (2), the engine crashes, `passDone` survives the crash, and the row stays `running`. A adds no theorem that Engine B fails, so under `DEF-16` the gate would go green without a negative control.

Drafted changes:
- **`OPS-15`:**
  - Replace "nothing but this pass … (`OPS-5`)" with “`OPS-5` says a `running` operation “stays claimed until it settles, defers under `OPS-8`, or the startup pass finds it (`OPS-15`)”, and a dead worker does neither of the first two.”
  - Replace "the pass takes the restore branch:" with "the restore's exceptions stay off:". The restore branch includes the queued quarantine, which A's previous sentence just excluded.
- **`STO-54`:** add “The quarantine is the step; `OPS-15` owns the pass over `running` rows and when it runs.”
- **`Restore.lean`:** A's changes, plus:
  - `passOp`'s `suspend_tenant` parent arm reads `(permits p w).run .suspendTenantException`. Today it encodes A2.
  - Re-key `step_quarantined_restore`'s `passDone → quarantined` to the step (2) mark.
  - Add a guard, `Params.passEveryStartup`, and a theorem, `successor_sweeps_running`: after a crash, the lock and a pass, every `running` op is a waiting parent.
  - Add a witness that refutes the theorem with the guard off, using the power-operation trace above.
- **`CNF-295`:** after A's bullet, add “and a delete queued on the power operation's machine is then claimed; and again after `grace_ends_at`, with every waiting parent confirmed, kill the engine with a confirmed parent claimed: the successor returns it to `queued` and it resumes with no second confirmation.”

**Touches:** `OPS-15`, `STO-54`, `CNF-295`, `Restore.lean`, `Witnesses.lean`.
**Mechanics:** only how far the step (2) mark reaches is unclear.

## Q2b: A1

- `OPS-15` gives its reason for the wait: “the fan-out it would resume may have been reversed inside the interval”. That does not apply to a parent claimed after the freeze lifted.
- `STO-54` gives the exception an end.
- `OPS-15` says “on a restart it MUST NOT require an operator” (`SEC-45`).

A2 would leave such a crash waiting on a human until the record closes.

Edits:
- **`OPS-15`:** “does not fire on a restore:” becomes “does not fire on a restore while `STO-54`'s freeze holds it off:”.
- **`OPS-15`'s parent paragraph:** “*after a restore it waits, above*” becomes “*after a restore it waits while that freeze holds, above*”.
- **`passOp`:** as in Q2.

**Mechanics.**

## Q3

No. pv-n98 is mechanics and can land now, while pv-s4m waits on the owner's Q1 call, and the two edit different sentences.

## Against my picks (written on request)

- **Q1:** a planned switchover kills every customer's token even though a clean one provably lost nothing. The stop obligation is also unenforced, the same kind of deployment obligation as `OPS-47`'s. D would turn the engine's half into a refusal.
- **Q2:** a create claimed after the restore and crashed before step 8 goes to `needs_reconciliation` instead of `failed`. Its money stays frozen until an operator acts.
- **Q2b:** A2 matches the create exception's "lasts for the whole open incident", and the pass then needs no freeze state.

## Brief errors

- "`promot` appears … only in `OPS-15`" is false as written. The word also appears in `01-domain-model.md:45` and `11-open-findings.md`, in an unrelated sense. `grep -n promot 01-domain-model.md 11-open-findings.md` shows both.
- I checked every other quote in the brief at `dc5d40d` and they hold. That covers `STO-5`, `STO-54`, `STO-56`, `OPS-5`, `OPS-8`, `OPS-15`, `OPS-47`, `Restore.lean`, `CNF-295`, `CNF-358`, `ADR-0023`, and the next free ids.

Running `br show` left an untracked `.beads/beads.db.fsqlite-migration-state` in the clone.
