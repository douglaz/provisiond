**Verdict:** store and render the recording instant, drop the request's `observed_at`; the brief's recommendation is wrong and the Manager's is right.

**Why**

The set already decides what an observation instant on the machine row means. `05-persistence.md:278` for `state_observed_at`: "the meter stops at this instant, never at the unknown instant the provider acted, because provisiond polls rather than watches". ADR-0038:34-35 defines the provider half the same way, "whether a flag is set, and when it was read", and it can be nothing else: Hetzner's `blocked` carries no instant (`02-provider-contract.md:909`). ADR-0038:37 renders both halves in one field, "its `observed_at` is that source's", so the operator half must carry the same meaning, when provisiond learned it. The time on Hetzner's lock notice is exactly the "instant the provider acted" the set declines on the provider side. Answering Q2: the provider side is our read time, the two must agree, and the brief's instant makes them disagree.

Readers (Q1). Nothing branches on `observed_at`; every hit is a definition or rendering (`01:335`, `05:271-273`, `13:322`, `13:1222-1223`, CNF-233, CNF-250). The agent stops on `status` alone (`01-domain-model.md:348-354`), and its remedy, delete (`DOM-26`), does not depend on how long the block has lasted. The one reader of the time is the operator chasing a stale record, and ADR-0038:64 names what they need: "The rendered `observed_at` shows the record's age". That is the age of the record, which a notice date cannot give. "Since when is the network blocked" has a home already: the notice behind `operator_ref`, and the case, which is "provisiond's provider-neutral record of one notice" (`CONTEXT.md:211`). Putting the notice's date on the machine is a second home.

A re-record is the freshness signal the stale-record cost needs: an operator who re-checks Hetzner and records again moves the time forward with no new input. With a supplied instant the operator must invent one, which is the recording instant anyway.

**Defects in the brief's framing**

- "The recording time is already in `SEC-32`'s audit record". False. `07-security-requirements.md:288-290` lists correlation id, tenant, identity, override, operation id and kind, target, outcome. No instant, and SEC-33 puts the record where no view reads it. Under the brief's shape the recording instant is reachable by nobody.
- "Refuse a future instant; default to the recording time when omitted". Two rules and a validation branch for a field with no reader, and backdating still needs a third (an instant before `created_at`). A record made today with a month-old instant arrives looking stale and invites the delete ADR-0038:62-64 warns of.
- Clock. A typed instant from an email under Hetzner's clock and timezone shares a column with the server clock. WIR-47's own sibling verb avoids this: revise-deadline takes only `respond_by` (`13:1217`) and the server stamps `revised_at` (`05:1152`).
- Replays (`13:771-774`). The stored body is the replay; a client re-reading its clock for a supplied instant gets 409 under the same key. A typo'd instant needs a correcting re-record; with the recording instant no typo exists.
- Uncited precedent. WIR-50 carries an operator-supplied `observed_at` and echoes it (`13:1251`, `13:1264`) with no definition (`05:1072`), while API-63 uses "the recording instant" for every effect (`04:1348`). Same gap, different route.

**Smaller shape (Q3)**

Body `{"status": "restricted", "operator_ref": "opref-7d41d2"}`; the server writes `operator_recorded_at` from the transaction clock. Withdrawal stays `{"status": "unknown"}`. A repeat record overwrites both operator columns. No request instant, no validation, no default.

**Edits (Q4)**

- `13-wire-contract.md:1211-1215`: new body above; "the operator's record time is the recording transaction's clock, because the set dates an observation by when provisiond learned it (`STO-48`); the notice's own date lives behind `operator_ref`; a repeat record moves it forward". Render rule at 1222: "`observed_at` is the positive observation's: the provider's read time, else the operator's record time".
- ADR-0038: dated note under the Q15 clarification. Rejected: the notice's instant, with the `STO-48` reason and the three rules it would need.
- `05-persistence.md:271-273`: `operator_recorded_at` "the recording transaction's clock, written by `WIR-47`; cleared by a withdrawal"; `provider_observed_at` "when the flag was read".
- `01-domain-model.md:335`: "the provider's read time and the operator's record time (`05-persistence.md`, `WIR-47`)"; drop the `STO-44` cite.
- CNF-233 (`10:2856`): add the trace: operator record at t1, view renders t1 as committed, never a body value; a second record at t3 renders t3. CNF-250 per Q15.
- `11-open-findings.md`: a finding on WIR-50's undefined `observed_at`.
- Formal: none. `Admission.lean:139` holds the verb only; the Lean `observed_at` hits are rate observations (`Claim.lean:128`, `Fence.lean:87`). ADR-0038:85 holds.
