I favor **(b), with a restart-only `OPS-15` exception**.

1. Today the story necessarily escalates: `OPS-15` says “move every `running` operation to `needs_reconciliation`”; `OPS-38` says “A create that recorded none has no count” and is “Unresolved”; `OPS-27` says “Escalate to an operator,” with commitment “Released per `OPS-33`.” `PRV-33` describes the window as “bounded by operator response time.” Nevertheless, `OPS-33` requires “the window MUST still be bounded”: escalation does not authorize indefinite reservation. `OPS-45` explicitly “does **not** reach `create`.” This is a proposed behavior change, not an existing contradiction.

Facts 4–5 hold: `PRV-33` declares “`correlator: none`,” whereas `05-persistence.md:382` describes “what the create wrote into the provider,” without specifying that channel’s entry. `API-63` nevertheless asserts “with no entry … does not dispatch.”

Fact 6 needs qualification: `OPS-6` already requires “every write that worker makes to the operation MUST carry `claim_number = mine`”; `STO-55` forbids holding a transaction “open across a provider … call.” Ordering and durability are not wholly unspecified; the entry’s status guard and acknowledgement-before-dispatch rule are not explicitly spelled out.

2. Soundness requires: **any provider mutation implies a committed step-8 entry**. Existing foundations are `OPS-43`’s “order the following steps as listed,” including keys at step 9; `STO-5`’s “no loss” on restart; and `OPS-47`’s “exactly one process.” Add:

- An entry on every channel, never cleared, surviving payload purge; no dispatch until the entire step-8 transaction is durably acknowledged. Lost acknowledgement permits transaction recovery, never speculative dispatch (`OPS-49`: “repeat the **whole transaction**”).
- Step 8 guarded on operation status `running` and the worker’s claim number, alongside account health; zero rows means no dispatch. Startup must test absence **inside** its conditional settlement, atomically with commitment release (`STO-3`, `LDG-35`). Startup wins: the worker cannot pass. Worker wins: the entry prevents deterministic settlement.
- No inference after restore: `OPS-15` warns the operation “may have settled at the provider inside the lost interval”; `STO-54` identifies an open restore record as “continuing that incident, not restarting.” Nor does this fence arbitrary overlapping engines: `OPS-47` says “The lock is not a fence.” Legacy rows lacking the recording guarantee must remain conservative.

3. Proposed representation: `(NULL,NULL)` means no admission entry; `('none',NULL)` records admission without a verified provider correlator. Never search that sentinel or copy it as a machine’s provider correlator. Keep step 8 where settled.

Land recording in `OPS-43`, `API-63`, `PRV-26`/`PRV-33`, the operation columns and `STO-3`; settlement in `OPS-15`, with explicit precedence in `OPS-11`. Update `tools/formal/Provisiond/Restore.lean:336` and conformance coverage for acknowledgement loss, overtaking and restore.

For this story: `failed`, error `internal` naming restart, `retryable: true` (`OPS-15`’s refresh precedent; `DOM-17`: “safe and sensible”). Preserve `OPS-16`’s “MUST NOT overwrite an error already recorded.” Extend `LDG-39`’s “Deterministic rejection before acceptance” row to include this interruption: release fully, no fee/unit debit.

The `OPS-11` reading must expressly distinguish startup recovery from worker classification. A recorded step-4 timeout still follows its current ambiguity rule.

Replace `API-63`’s test with: under the new recording contract, outside restore, a non-null `correlator_kind`, including `none`, means potentially dispatched; null means step 8 has not committed. A present `none` entry remains subject to `PRV-33`’s “MUST resolve to an operator.”

4. This escapes `ADR-0035`’s rationale: “cannot tell a key upload from an order or a rejection from an acceptance” is irrelevant when absence proves neither mutation began. A set entry establishes no acceptance. It remains dispatch state in substance. **Amend `ADR-0035` explicitly**; no new ADR is necessary. Its rejected pre-send-`network` reclassification remains outside this amendment.

5. Decide the policy alongside `pv-qga`, retain separate beads, without a hard dependency. Recovery and recorded failure are different paths. Do not silently broaden this exception: `CNF-31b` requires “pre-send `network` … `needs_reconciliation` despite `details.accepted: false`.” Whether that changes belongs to `pv-qga`.

**Strongest case for the other side (written on request)**

Not my position: choose (a). `CONTEXT.md` defines a correlator as what a create “writes or leaves behind at the provider.” A local `none` sentinel overloads that concept, complicating searches and copies (`PRV-26`, `OPS-27`, `05-persistence.md`). A dedicated marker states the engine fact directly and preserves that boundary.