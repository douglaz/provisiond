**Q1 — AMEND A; behaviour changed. Owner:** requiring a full incident for a lossless switchover is a scope decision. Keep A’s `OPS-15` deletion.

Replace the `STO-5` note:

> *A restore from backup or promotion of an asynchronous standby is outside this restart guarantee. `STO-54` governs bringing either component up on that store (`ADR-0023`, `ADR-0045`).*

Replace A’s new `STO-54` paragraph:

> **Promotion of an asynchronous standby, including a planned switchover, is a restore.** Before promotion, the deployment MUST block component access to the candidate store and prevent supervisor admission. It MUST terminate every old engine and `api` process. Administrative access MUST commit the restore record before component access and supervisor admission are released; only fresh component processes may connect.
>
> The deployment MUST record an evidenced conservative recovery-point timestamp and publish the corresponding maximum possible lost interval numerically. A last-replay transaction timestamp may supply that evidence when available; otherwise use an earlier verified backup recovery point. Without a justified numerical bound, component admission remains blocked. This number never substitutes for the procedure.

The connection ordering is feasible with that admission barrier; automatic restart alone supplies none. The proposed instant is usable conditionally, not universally: PostgreSQL describes a “commit or abort” record and states, “If no transactions have been replayed during recovery, the function returns `NULL`.” ([PostgreSQL recovery functions](https://www.postgresql.org/docs/18/functions-admin.html#FUNCTIONS-RECOVERY-INFO))

Use new `CNF-365`:

> Repeat `CNF-295` on a promoted asynchronous standby. Separately lose the acknowledged step-8 write and the claim write. Race supervisor restart and an existing `api` pool’s reconnect against promotion: assert neither accesses the candidate before the record commits, and every admitted process is fresh. Assert the affected creates become `needs_reconciliation`, retain their commitments, and produce no second order. Repeat a lossless planned switchover through the same procedure. Verify ordinary restart after incident closure.

Touches: `STO-5`, `STO-54`, `OPS-15`, `CNF-365`, `ADR-0045`; align `CONTEXT.md` and `ADR-0042`’s quotations.

**Q2 — AMEND A; behaviour unchanged from A. Mechanics:** incident completion cannot discharge a successor process’s startup obligation. Keep A’s Markdown and rehearsal changes, subject to Q2b. Replace its formal-model bullet:

> `World.stepTwoMarked` holds the persistent incident mark. `passDone` records this process’s pass; `afterCrash` clears it and preserves `stepTwoMarked`.
>
> `permits.claim := w.locked && w.passDone && (!w.fault.isRestore || w.stepTwoMarked)`.
>
> `startupPass` processes `running` rows once per process. It additionally performs the initial quarantine only for an unmarked restore step (2), then marks that step. Add events admitting fresh operations and applying provider actions after step (3), so the reported crash trace is expressible. Preserve `quarantine_before_first_claim`’s no-second-order conclusion; update its invariant and documentation for fresh queued work.

The restart qualification prevents an ordinary restart waiting for a nonexistent restore mark. The current procedure events cannot introduce the post-mark create in the question.

Touches: `OPS-15`, `STO-54`, `CNF-295`, `Restore.lean`, `Witnesses.lean`.

**Q2b — AMEND A: A1; behaviour changed from the blanket restore wording. Owner:** requiring renewed human approval after the agreed thaw is a product choice. `STO-54` says “the freeze lifts at `grace_ends_at`” and adds “until the operator has confirmed or cancelled every waiting parent”.

Replace A’s parent clause and `OPS-15`’s blanket restore-parent sentence:

> During an open incident, a `suspend_tenant` parent waits for operator confirmation while the freeze for this exception holds. Once that freeze has lifted, the startup pass MUST return a parent found `running` to `queued`; the open record alone MUST NOT require renewed confirmation.

Replace `OPS-15`’s later italic restore qualification with:

> *subject to the restore-freeze rule above.*

Replace `API-58`’s italic restore qualification with:

> *on restore, the startup outcome follows `OPS-15`.*

Touches: `OPS-15`, `API-58`, `CNF-295`, `Restore.lean`, `Witnesses.lean`; test a parent interrupted after thaw while another obligation keeps the incident open.

**Q3 — Yes, one Run — mechanics:** both beads change the same startup branch and need joint `OPS-15`/`STO-54` rehearsal.

**Against my picks — written on request.**

- **Q1:** B can spare planned switchovers quarantine, downtime and token replacement by proving complete replay after quiescing writers. A imposes substantial disruption even when no application state was lost.
- **Q2:** Splitting the pass introduces persistent and process-local state with different lifetimes. An incomplete formal amendment could look convincing while never admitting the fresh work that exposes the defect.
- **Q2b:** A2 follows the existing blanket wording more directly. A1 requires confidence that approval and freeze completion survive crashes without accidentally authorizing a parent whose fan-out the operator reversed.
- **Q3:** Separate Runs would isolate the deployment policy from the startup correction, making each easier to review and revert.

**Brief errors.**

- The literal `promot` assertion is overbroad: `rg -n 'promot' 01-domain-model.md 11-open-findings.md` also finds unrelated domain and checklist promotions. These supply no standby rule.
- The stranded-row statement needs qualification: `rg -n 'yielded_at IS NULL' 03-operation-lifecycle.md` shows the index excludes yielded rows; `rg -n 'nullable; set on completion for create' 05-persistence.md` shows an unfinished create need not name a machine. The power-operation witness still establishes delete starvation.