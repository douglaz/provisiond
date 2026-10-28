# Owner decisions — panel A (r74–r76), 2026-10-28

Relayed by main through AskUserQuestion after the r76 tally (/var/tmp/provisiond-panel-r74/r76/tally.md).
Questions and answers are verbatim.

1. **pv-3jw6** — Q: "pv-3jw6: when a promoted restore can't prove how much history survived, what should the
   restore report do?" A: **"Report unknown (UO) (Recommended)"**. Option text shown: "Panel pick, 4–0 accepted as
   written. Record the window when it's proven; otherwise record "unknown" with the reason and let recovery
   proceed. Becomes ready-for-agent and the drain lane lands it."
   - The reviewed form is UO with opus's verified wording repair ("defined below" → "defined above").

2. **pv-oehp** — Q: "pv-oehp: how should the engine keep leftover connections from exhausting PostgreSQL's
   slots?" A: **"B4* as reviewed (Recommended)"**. Option text shown: "Panel pick, 3–1. Durable tickets taken
   before each connection and released only after it's provably dead. astra's point about enforcing the
   other-client limit stays a disclosed deployment obligation."
   - Rejected: "B4* plus astra's additions" and "No new machinery".

3. **pv-1i3n** — Q: "pv-1i3n: when two standbys report identical history, may either be promoted as a plain
   restart?" A: **"Yes, T-known (Recommended)"**. Option text shown: "Panel pick, 4–0 as written. Promote either as
   a restart, so tokens stay valid; all existing guards and known-violation handling stay. Becomes
   ready-for-agent."

4. **pv-c7vg** (P1) — Q: "pv-c7vg: if the engine can't verify a crashed client's leftover database session, should
   it stop new work or ignore that session?" A: **"Don't add the check"**. Option text shown: "Trust the deployment
   to keep replication on." The fuller version of the same option, shown just before: "No new control — Rely on
   the deployment never disabling synchronous replication; document it as an operator requirement. Cheapest, and
   it puts safety on infrastructure configuration."
   - So no P4C/P4R/P4C-R/V/A controller. The ruling must still land as spec text (memory
     feedback_fold_rulings_into_spec.md): the operator requirement and the misconfiguration case it leaves open.
