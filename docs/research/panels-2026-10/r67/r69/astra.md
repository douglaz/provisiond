Reviewed against `c5f897c`. No gates or `lake` run; no tracked edits.

**Q1 — S-final: AMEND, behaviour unchanged. F-final: CANNOT ACCEPT. Pick S.**

S’s strongest argument is admission without a request-dependent provider read, with explicitly bounded listing age. The cost is storage and periodic refresh traffic. The purchase protection survives: `OPS-43` compares against “one current driver List offers result taken at claim”.

**S2 quotation AMEND — behaviour unchanged.** Replace its `offers` row with:

```text
| `offers` | json | the driver's List offers result (`DOM-9`: "Prices MUST be carried as strings exactly as the provider returned them.") |
```

F’s blocking trace: pass 5d; successfully read the provider; then refuse insufficient balance, halt, or local closure; commit no operation. These surviving constraints contradict that trace:

- `03`, `OPS-35`: “The provider account MUST be resolved and written to the operation record **before** any driver call.” No record exists for that write.
- `03`, `OPS-11`: admission-only kinds “are decided before any driver call”. Balance/halt are decided afterwards.
- `05:441`: “The `provider_account` write retains `OPS-35`’s "before any driver call".” F10 does not amend this.
- `CNF-31b`: “Admission-only inputs remain pre-provider, with acceptance false” and “At admission, a local `PRV-40` closure is a pre-provider refusal”. The read flips the pre-provider assertions; mutation acceptance can still remain false.

Neither F11 alternative plus F12 disposes of the schema sentence or `CNF-31b`. This remains a whole-form rejection.

**F5 quotation AMEND — behaviour unchanged.** Replace its first replacement text with Reader 4’s:

```text
`API-7` tail ("then, on create only, `rate_limited` when the offer's account and ordering channel are closed under `PRV-40`") before any provider mutation
```

Option votes, independent of form verdicts:

- **S-a leave:** it deletes “at the admitting transaction”; an earlier freshness check can age out before admission. Keep that timing protection explicit.
- **S-b leave:** “each healthy account” narrows S3’s “every account declaring `list_offers`”; the broader refresh obligation does not survive.
- **S-c leave:** retain the explicit input inventory.
- **S-d leave**, both supplied texts. No additional admission capability refusal, including with a retained fresh row.
- **F-a take Reader 3**; leave Reader 4 and printed.
- **F-b leave:** retain the broader prohibition on writes.
- **F-c take Reader 3**; leave Reader 4 and printed.
- **F-d leave; F-e leave; F9 take; F10 take.** F-e’s removed sale-test sentence would still have protection from `API-7`: “the tail MUST collect every applicable refusal once”.

Archived proposals:

- **Reader 1:** S3 leave; S4 leave; S-d leave; F11 leave.
- **Reader 2:** F11 take; F12 take; F7 take; S-d leave. F11/F12 are **behaviour-changing exceptions**, not wording repairs or a completed F repair.
- **Reader 3:** F5 leave; choose Reader 4’s alternative.
- **Reader 4:** S2 take; S6 take **as additional conformance assertions, not a behaviour-unchanged repair**; F5 take.
- **Coordinator S4 quotation correction:** take as quotation repair only; leave the alternative row’s adoption.

**Archived Reader-1 S4 quotation AMEND — behaviour unchanged.** Exact row replacement:

```text
| Offer-listing refresh (`OPS-51`) | `engine` | Reads offers at a provider, so it needs a provider credential. `STO-60`: "Every successful driver List offers read MUST publish its complete result to the account's row, replacing an existing row only when the incoming `read_at` is later." |
```

That repair does not restore the deleted “running in the engine process” placement. Keep printed S4: process placement matters because `OPS-50` says “Writes made in the api process are not checked.”

No additional gated loss established from claim checks, publication, or retained rows. `OPS-43` says “The first failing check stops subsequent checks”; claim refusals before step 4 therefore require no listing read or publication. Publish a successful step-4 result outside the driver, before step 8: `PRV-50` says “The driver's List offers MUST be read-only”; step 8 remains “the last write before the ordering call”.

A retained fresh row can admit under S; claim subsequently encounters “Gate on `list_offers` under `DOM-10`”. `CNF-364` remains reachable: its fixture removes the capability **after admission**.

*Against S:* It spends refresh traffic without customer demand, maintains another stored dataset, and can admit a stale price only to fail at claim. A coherent F repair buys fresher admission at per-create latency and provider-read cost.

**Q2 — complete K1–K6 candidate: ACCEPT.**

Options: **K-a leave; K-b leave; K-c take candidate K4/Reader 2**, leave the alternatives; **K-d take**. **Explicit completed-fixture addition: leave**; the after-release assertion is already conditional.

For K-d, use a completed transaction awaiting operator resolution; after lawful window release, automatic attachment remains forbidden. For an in-progress matched order, release does not occur: `OPS-33` says “the negative window MUST NOT run against a matched order that is still in progress”. K-d removes no guard and supplies no timeout.

The standard-channel `CNF-303` trace works:

1. Successful step 8 records the fingerprint pair; K4 asserts null where that transaction never committed.
2. Step 9 registers the generated key and distinct caller key. `PRV-9` requires every registered temporary key to “carry the operation id as its provider-side name or tag”.
3. Lost reply leads to operator attachment; K6 quotes “attaching a discovered machine to a tenant MUST be an operator action”.
4. The retained machine holds the fingerprint: `PRV-9` specifies “its per-order correlator-key fingerprint on Robot”.
5. Retention removes the operation. While the machine remains provisioning, the sweep retains **every tagged key**, including the distinct caller key: `PRV-9` says those keys “have the same eligibility”.
6. Once provisioning clears, `CNF-303` asserts deletion of “every surviving eligible registration with the row still absent”.

For the one-transaction lost-reply trace, K3 explicitly gives a `correlator: none` channel “no count”. Thus “Exactly one resource across every channel” cannot authorize attachment. The surviving resolution is “**Unresolved.** Escalate to an operator”; `PRV-33` requires “an ambiguous create on that channel MUST resolve to an operator, never to a guess”.

K’s strongest argument is durable cleanup evidence without automatic matching authority.

*Against K:* K2 adds a generated-key payload obligation on every Robot channel. That is an order-shape decision, not merely clarification of persistence.

Brief errors: Reader 2’s S-d “forever” premise fails on a retained fresh row. Its F11/F12 “behaviour unchanged” label ignores surviving owners. Reader 4’s S6 adds assertions. The old universal step-1 account-refusal premise fails at `10:2817–2820`: “let the List offers read complete, then commit termination before step 8 commits”.