STATUS: blocked

pv-ucs.10 cannot be briefed without the owner clarification explicitly required by item 12. The ticket is claimed `in_progress`; its notes record this blocker. No other bead was selected or changed. No specification or gate implementation was changed, and no Implementer brief was written.

## Owner question: successful-create temporary-key cleanup timing

Source: `docs/adr/0040-a-lost-auction-order-is-resolved-by-its-fingerprint-and-a-temporary-key-outlives-an-unsettled-operation.md`, Decision 2:

> A temporary key is deleted only once its operation has settled or vanished, and no machine it produced still reads `provisioning`.

Its Consequences say:

> A caller's key held by an unresolved operation blocks that caller's next create on the same account, because providers reject a duplicate fingerprint.

`02-provider-contract.md`, `PRV-9`, repeats the eligibility condition:

> A temporary key MUST be deleted only once its operation has settled or vanished, and no machine it produced still reads `provisioning`.

It also says:

> This common eligibility rule governs driver cleanup and `OPS-32`'s sweep for create and rescue; provider-consumption timings may justify earlier deletion only after a separate amendment.

Neither passage specifies whether an ordinary successful create must attempt key deletion when that eligibility condition becomes true, or may leave all successful-create cleanup to the next sweep. The unresolved-operation consequence does not explicitly exclude a collision after successful settlement.

Related text does not resolve this:

- `03-operation-lifecycle.md`, `OPS-32`: “a key resource carrying an operation id as its name or tag (`PRV-9`) is deleted by the sweep only when `PRV-9`'s eligibility rule permits it”. This gives the sweep a cleanup path, without making it only a failure/crash backstop for successful creates.
- `10-conformance-checklist.md`, `CNF-303`: “After settlement, retain a key while a machine produced by that operation still reads `provisioning`; delete it when that guard clears.” This does not identify the cleanup path or its timing when a successful create is already eligible at settlement.
- `tools/formal/Provisiond/Rescue.lean`, `Session.keyEligible` and `Session.step`: settlement changes the modeled operation status; a separate eligible `sweepRemovesCredential` event removes the registration. This model supplies no successful-create cleanup-timing obligation.

Two readings produce different behavior:

1. **Eligibility only, sweep cleanup permitted.** A successful create whose machine is no longer `provisioning` may retain the caller's registered public key until the next account sweep. A second create using that key on the same provider account can encounter a duplicate-fingerprint refusal during this interval.
2. **Prompt driver cleanup, sweep as fallback.** Once the successful create is settled and its produced machine is no longer `provisioning`, the driver must attempt deletion promptly. The caller need not wait for the periodic sweep when that cleanup succeeds. An unresolved operation, a still-provisioning machine, or failed cleanup can still retain the key.

**Recommended clarification:** choose reading 2 and explicitly state the cleanup timing and failure fallback in an owner amendment to ADR-0040, owned normatively by PRV-9. Preserve the existing eligibility guards. Clarify whether failed cleanup leaves the successful create's result intact and relies on OPS-32, so the Implementer does not invent that consequence. This is a recommendation, not an adopted requirement. If the owner instead intends reading 1, say so explicitly and permit the collision explanation to include the interval after successful settlement.

## Scope and consultation

The caller expressly directed: “If the ADR does not settle deletion at settlement, BLOCK with the passage.” This is a question of specified behavior, not gate tooling or wording. No advisers were called: a model vote cannot supply the missing owner decision. No adviser was listed as out of quota in this Run's prompt, so none was skipped on that basis.

ADR-0037 was read in full, including every amendment and Q23a–c; ADR-0034, ADR-0039, ADR-0040 and the r41 synthesis were also read in full. The settled decisions are not being reopened. Investigation stopped at the explicit item-12 block; this report does not claim completion of the requested full-corpus reading or the ticket repairs.

## Verification and handoff

Both the initial and closing `nix develop --command bash tools/check-all.sh` runs were unpiped, exited zero, and passed every gate. No provider API was called. No CI negative-control rehearsal was performed: no repair or gate change was implemented, and there is no completed implementation to admit to review. The future Implementer must rehearse the CI rows in one repository-contained copy, restore it between rows, and delete it afterwards, as the caller required.

Only pv-ucs.10's status and notes, their Beads export, and this report were intentionally changed. The ticket remains open for the owner clarification and the eventual implementation; no commits were made.
