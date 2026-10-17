1. **Today: the story reaches an operator.** `OPS-43` places “every temporary key registration” at step 9. Nevertheless, `OPS-15` requires “every `running` operation” to enter `needs_reconciliation`; `OPS-38` says a create recording none “has no count” and is “**Unresolved**.” `OPS-27` then says “Escalate to an operator,” with commitment “Released per `OPS-33`.” `PRV-33` explicitly names “operator response time.”

Facts 1–3 hold: the exceptions do not cover this create, and `OPS-45` says an interruption “is `OPS-15`’s, whatever the markers hold.”

Facts 4–5 hold: `PRV-33` declares descriptor-level “`correlator: none`”; the operation columns describe “what the create wrote into the provider” (`05-persistence.md:382`), without defining that channel’s entry. Yet `API-63` treats “no entry” as “does not dispatch.”

**Fact 6 is overstated.** `OPS-6` already requires “every write” to carry `claim_number = mine`; `OPS-49` requires whole-transaction retries covering “commit, read-back and backoff”; `STO-7` specifies `synchronous_commit = local`. Together with step ordering, these support durability. The missing explicit contract is the step-8 **status guard, successful acknowledgment and dispatch authorization**, rather than durability machinery generally.

2. **Soundness requires an atomic exclusion, not merely an earlier read.** Proposed obligations:

- Every channel records dispatch permission in step 8’s transaction, before *any* step-9 mutation.
- The record is monotonic and survives purge; uncertain commit acknowledgment never authorizes dispatch.
- Step 8 checks `(running, claim_number = mine)` and aborts without dispatch when overtaken. Repeating the transaction must be idempotent.
- Startup conditionally settles only a still-`running` create whose record remains absent **in that same transaction**. Otherwise a worker could set it between inspection and settlement.
- Existing claimed operations cannot acquire “never dispatched” meaning merely through a new column’s default; migration must conservatively exclude them (`STO-13`).

Already supplied are ordered steps (`OPS-43`: “as listed”), the claim term (`OPS-6`), and restart durability (`STO-5`: “no loss”). Add the explicit conditions above to `STO-3`/`OPS-43`.

Absence **cannot prove this across restore**: `OPS-15` says a row “may have settled at the provider inside the lost interval.” Disable the exception throughout an open restore incident (`STO-54`: “continuing that incident, not restarting”). This does not promise fencing against the disconnected engine that `OPS-47` explicitly calls “out of scope.”

3. **Pick (a), with settlement owned by `OPS-15`.** A dedicated write-once create dispatch marker preserves the distinction between local execution and a provider-searchable correlator. Leave step 8 where it is.

For this story, propose `failed`, an `internal` error naming the restart, and `retryable: true` on error and operation view; preserve pre-existing errors under `OPS-16` (“MUST NOT overwrite”). The precedent for the synthetic kind is `OPS-15`’s refresh exception: “the nearest of `DOM-17`’s kinds.” Retryability expresses “safe and sensible” repetition (`DOM-17`), without requeueing the old operation (`OPS-4`: “a fresh operation”).

Explicitly give this startup exception precedence over `OPS-11`’s “`network`, `timeout`, or `internal`” ambiguity rule. Assign `LDG-39`’s “Deterministic rejection before acceptance” row: “Never debited; released with the commitment.”

Land on `OPS-15`, `STO-3`, the operation schema, `OPS-43`, `API-63`, and clarifying references in `OPS-11`/`OPS-45`; update `CNF-29`, relevant termination checks, and `OPS-15`’s formal declarations.

Replace `API-63`’s entry test with the committed marker: absent means dispatch is forbidden; present means potentially dispatched. Neither implies provider acceptance. Retain restore qualification.

4. **Amend `ADR-0035`.** Its objection—“cannot tell a key upload from an order or a rejection from an acceptance”—does not defeat an *unset-only* inference. A set marker decides nothing about classified failures. However, “A durable dispatch marker on create” was explicitly rejected; record the narrower purpose through an amendment. The pre-send-network rejection was expressly “beyond the question,” not a merits determination.

5. **Decide together; keep separate beads without a dependency.** `pv-qga` concerns recorded failures under `OPS-11`; this proposal concerns interrupted execution under `OPS-15`. Their different outcomes are mechanically consistent but deserve explicit owner acceptance. Neither requires resolving the other, and merging would obscure distinct verification obligations.

**Strongest case for the other side (written on request)**

Choose (b): `API-63` already gives the correlator entry dispatch significance. Defining `none` as an explicit entry could complete that existing representation without another column. It needs the same atomicity, acknowledgment and restore protections; shape (a) additionally maintains two related records. This is the strongest objection to my choice.