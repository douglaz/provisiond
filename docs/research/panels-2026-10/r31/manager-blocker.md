STATUS: blocked

Selected and claimed `pv-ucs.9` only. Review base: `22c78fbed4e1440c8e81fec402ef6f3f23f538aa`, 2026-10-08. The ticket remains `in_progress`; comment 261 records the owner questions below. No new beads, specification edits, implementation, or `task.md` were produced. The next Run must stay on this ticket until it is closed, then go idle.

The caller's step 4 requires stopping for specification ambiguity. The research follow-through needs owner decisions about resolution evidence and temporary-key lifetime before an Implementer can receive a complete brief. These questions do not reopen the accepted ADRs.

**Auction identity resolution: the proposed guard leaves the negative branch unspecified.**

Documents and passages:

- `docs/research/provider-verify-2026-10.md`, V8, lines 245–247: “When the identity read finds a server, assert `server_number == offer id` on the transaction. On a mismatch, treat the channel as catalogue-like and use `PRV-32`'s fingerprint search.” This is also the ticket's instruction.
- `02-provider-contract.md`, `PRV-42`, lines 965–977: “resolution MUST be an identity read rather than a search, and the correlator is unnecessary.” Its table maps “absent, past `PRV-36`'s effective visibility window” to resolved-absent.
- The same requirement, lines 979–994: “it is not bounded by a transaction listing's retention”; “it needs no ordering permission”; and “that it holds by rule rather than by coincidence is `[verify]` before a driver depends on it.”
- `03-operation-lifecycle.md`, `OPS-27`, resolution table: the resolved-absent commitment effect is “Closed and released in full (`LDG-32`)”.

Readings with different behavior:

1. Add V8's check only when the identity read finds a server, retaining the existing negative identity path. A missing offer-number resource can then resolve absent without checking a transaction. Whether a found resource can resolve when its transaction cannot be obtained is also unspecified.
2. Keep the prior-verification precondition, or require transaction evidence before relying on either identity outcome. Without verified identity, perform fingerprint resolution, including after a negative identity read. This requires retaining the correlator and gives up the unconditional retention/permission independence on that path.

Counterexample to the first reading: order offer A, lose the reply, and have the provider deliver server B, where B differs from A. After the visibility window, `GET /server/A` returns not found. V8's positive-read guard never runs; the unchanged table permits releasing the commitment while B exists. This is a hypothetical trace the unverified identity premise does not exclude, not a claim that Hetzner has been observed doing it.

Owner clarification needed: does V8 replace or supplement the prior-verification precondition? May a negative identity read resolve absent before equality is established? What is the outcome if the transaction is unavailable, expired, or has no server number yet? Specify whether the auction order must retain its per-order fingerprint for this fallback.

Recommendation, not adopted: retain the per-order fingerprint and require verified identity for the shortcut. Otherwise use fingerprint resolution for both positive and negative identity reads; unavailable evidence leaves resolution unresolved, with the existing operator and bounded-negative-window treatment. Record the identity shortcut's evidence prerequisite explicitly instead of claiming unconditional independence from the transaction listing.

**Temporary-key cleanup: provider consumption and operation status give conflicting deletion instructions.**

Documents and passages:

- `02-provider-contract.md`, `PRV-9`, lines 115–118: the driver “MUST NOT remove them until the provider has actually consumed the key material”.
- `03-operation-lifecycle.md`, `OPS-32`, lines 1411–1416: a tagged key whose “operation is not `running`” “is **deleted**, on the same footing as an image”; “A key whose operation is still `running` is in use and MUST NOT be touched.” The following Robot exception addresses fingerprint survival, not pending consumption.
- `docs/research/provider-verify-2026-10.md`, V2: “clean up after the create Action reaches `success`”; V18's summary: “Clean up after the Droplet is `active`”; V19: “Keep the temporary key until the server reaches `deployed` (or `allocated` for iPXE”. The ticket selects these delayed cleanup boundaries.
- `docs/adr/0035-a-failure-after-the-provider-accepted-a-mutation-is-ambiguous.md`, Decision: “A failure of an operation whose mutating request the provider accepted is ambiguous, whatever its kind.” The current `OPS-27` likewise says: “After acceptance, zero or many resources, a failed search, or any non-authoritative search MUST leave the create in `needs_reconciliation`”.

Readings with different behavior:

1. Apply the new consumption boundaries only to the driver's ordinary cleanup; leave the sweep's non-running test intact. After an accepted create's poll fails, the operation is `needs_reconciliation`, and the sweep deletes the key even though the asynchronous provider can still need it.
2. Apply the consumption prerequisite to sweep cleanup too, amending its explicit non-running deletion rule. A pending or unknown consumer keeps its key. This needs a defined release condition for failures, unresolved operations, and missing operation records, so that the rule neither deletes a needed key nor silently promises eventual cleanup without evidence.

Owner clarification needed: must the sweep share the delayed-consumption guard? Which evidence permits deletion when successful consumption cannot be observed, including a definitively refused/cancelled create or a missing operation record? This determines external key lifetime and whether a customer's machine can finish booting with access; it is not merely a wording choice.

Recommendation, not adopted: non-running status alone must not authorize deletion. Require evidence of consumption or authoritative evidence that no consumer remains; retain and surface unknown cases. Preserve the separate Robot fingerprint-survival restriction. Amend the owning requirements and conformance together after the owner chooses the behavior.

No adviser consultation was started: these are specification-behavior questions reserved to the owner by step 4, not implementation choices advisers may settle. No advisers were listed as unavailable, and none were skipped for quota. No implementation decision was made.
