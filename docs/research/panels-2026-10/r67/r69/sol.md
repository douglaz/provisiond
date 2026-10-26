Read at `c5f897c`, using the JSONL fallback. No files changed; no gates, `lake`, provider calls or delegation.

**Q1: S-final — AMEND, behaviour unchanged**, solely the S2 quotation repair below. **F-final — CANNOT ACCEPT. Pick S:** bounded stored data removes provider latency from admission and amortizes reads on busy accounts, at the cost of storage and continuous refresh.

F’s blocking trace: F1 passes 5d, successfully reads offers, then refuses insufficient balance or local closure without an operation. Surviving losses:

- `03-operation-lifecycle.md`, `OPS-35`: “The provider account MUST be resolved and written to the operation record **before** any driver call.”
- The same file, `OPS-11`: “they are decided before any driver call”.
- `05-persistence.md`: “The `provider_account` write retains `OPS-35`'s "before any driver call".”
- `CNF-31b`: “Admission-only inputs remain pre-provider, with acceptance false” and “a local `PRV-40` closure is a pre-provider refusal”.

F10 edits another owner. Neither F11 alternative, even with F12, disposes of the schema or `CNF-31b` loss.

**Options:** S-a leave; S-b leave; S-c leave; S-d leave both supplied texts, including with a retained fresh listing. F-a take Reader 3, leave Reader 4/printed; F-b leave; F-c take Reader 3, leave Reader 4/printed; F-d leave; F-e leave; F9 take; F10 take (**behaviour changed**, insufficient alone).

**Archives:** R1 S3 leave; S4 leave; S-d leave; F11 leave. R2 F11 take, F12 take, F7 take; S-d leave. R3 F5 leave. R4 S2 take, S6 take, F5 take. Coordinator-corrected historical S4 leave. R2 F11/F12 are **behaviour changed** exceptions; R2 F7 and R4 S6 are **behaviour changed** assertion additions. These votes do not merge alternatives or certify a combined F repair.

I retain S1’s “at the admitting transaction” freshness guard, S2’s “A failed read MUST leave the row unchanged”, and S4’s “running in the engine process”. S-b narrows “every account declaring `list_offers`” to “healthy” accounts and substitutes “Failed or incomplete reads MUST NOT advance `read_at`” for full-row preservation. Historical S4 drops explicit process placement; `OPS-50` covers “every write transaction made in the engine process”. F-b narrows the all-write limit to purchase writes; leave it. F-d’s removed qualifier survives F1’s “On create”; F-e’s sale protection survives the unchanged `API-7` verdict, “not sellable under `PRV-13b` or `PRV-31`, or absent from the offers the check reads”.

No additional gated loss established. Claim’s “Make no provider request” (`OPS-43`) survives. Successful-read publication fits after step 4 and before step 8’s “last write before the ordering call”; `PRV-50` says “The driver's List offers MUST be read-only”, so publication belongs outside the driver.

Exact wording AMENDs, each **behaviour unchanged**:

- **S2**, replace its `offers` row:

```text
| `offers` | json | the driver's List offers result (`DOM-9`: "Prices MUST be carried as strings exactly as the provider returned them.") |
```

- **F5**, replace its first replacement text:

```text
`API-7` tail ("then, on create only, `rate_limited` when the offer's account and ordering channel are closed under `PRV-40`") before any provider mutation
```

- **Archived R1 S4**, replace its row to repair the attribution only; my option vote remains leave:

```text
| Offer-listing refresh (`OPS-51`) | `engine` | Reads offers at a provider, so it needs a provider credential. `STO-60`: "Every successful driver List offers read MUST publish its complete result to the account's row, replacing an existing row only when the incoming `read_at` is later." |
```

Against S: Its “stored offer listing” can admit a create later refused at claim; idle accounts still incur refresh traffic. Fresh admission avoids that stale-price admission and storage duty.

**Q2: K candidate K1–K6 — ACCEPT.** K-a leave; K-b leave; K-c take candidate K4/Reader 2, leave Readers 1/3; K-d take (**behaviour changed**, additional assertion).

**Fixture:** sufficiently conditional; no amendment needed. For an operator-confirmed in-progress match, `OPS-33` says “the negative window MUST NOT run against a matched order that is still in progress”: no release occurs. That execution cannot reach K-d’s suffix. After lawful release, the suffix checks continued operator handling; it grants no earlier release.

**Retention trace:** generate K2’s “throwaway key unique to that order” locally. Write the pair at step 8, preserving 05:441’s “Written in `API-63`'s correlator transaction, which is `OPS-43`'s step 8”. Acknowledge that transaction before registration: `OPS-43` says “Step 9 MUST begin only after step 8's transaction is acknowledged”. Register both tagged keys successfully, then order with both.

After the lost reply, K6 uses “attaching a discovered machine to a tenant MUST be an operator action”; retain “its per-order correlator-key fingerprint on Robot” (`PRV-9`) on the machine. Settle while `provisioning`, then remove the operation through retention. **Every tagged key remains**, including the distinct caller key: `PRV-9` says “A vanished operation record satisfies only the settlement condition” and “Every temporary key tagged with that operation id, including a caller key distinct from Robot's correlator key, has the same eligibility”. `CNF-303` supplies “Read the guard through retained `machines.correlator_value`”; after observation clears `provisioning`, its assertion is “the sweep deletes every surviving eligible registration with the row still absent”.

**Lost-reply trace:** exactly one fingerprint-bearing standard transaction still gets K3’s “has no count”. It cannot enter `OPS-27`’s “Exactly one resource across every channel” automatic-attachment row. K5 checks escalation; `PRV-33` says “an ambiguous create on that channel MUST resolve to an operator, never to a guess”. After lawful release, `OPS-33` still says “the search it bounds is an **operator** search, not an automatic one”. K’s strongest argument is durable cleanup evidence without granting matching authority.

Against K: K2’s “throwaway key unique to that order” adds provider resources on an unverified channel; it supplies cleanup evidence without improving automatic recovery.

**Errors:** archived R2 S-d’s “forever” is false: retain a fresh row across capability removal; S1 tests “Where no listing is stored, or its `read_at` is older”. Claim later meets “Gate on `list_offers` under `DOM-10`” (`OPS-43`). The archived BU labels corrected above conflate exceptions/assertions with wording. `CNF-278` explicitly says “let the List offers read complete, then commit termination before step 8 commits”; that is a post-read step-8 refusal, with K4’s null pair where step 8 did not commit.