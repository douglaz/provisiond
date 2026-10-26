**CANNOT ACCEPT the printed S1–S6 candidate at `c5f897c`.** The unhealthy-account repair works, but the remaining healthy-account freshness refusal changes surviving `CNF-307` verdicts. The smallest repair below is **behaviour changed**, so it supplies no counted ACCEPT for the printed form.

All source locations below refer to the base commit.

1. **Whole-form finding**

The strongest argument for this form is that it connects stored-source admission, complete publication, dispatch-based freshness, independent refresh and claim-time price checking. S1c also repairs the stale unhealthy-account cases without inventing an age-generated offer refusal.

**Strongest argument against this form — written on request; not another vote:** [CNF-307, lines 1259–1262](https://github.com/douglaz/provisiond/blob/c5f897c32f7894d77a544528872176f241394d0d/10-conformance-checklist.md#L1259) says:

> On an unsellable create with a healthy account and available rate, assert a singleton offer refusal, false retryability, and both priced checks skipped for `offer_not_sellable` when a cap is supplied.

Use a healthy account whose stored row is stale and contains an unsellable named offer. Let scheduled refreshes fail without an operator changing its recorded status. The printed S1 returns **502 `provider`, retryable true, before collection**. The assertion requires **400 `invalid_request`/`offer_not_sellable`, retryable false**, with its refusal and skipped-check entries.

This is a further loss beyond S6’s disclosed stale-listing availability assertion: freshness hides an independently required refusal. A fresh-row witness cannot dispose of it.

The same problem affects the healthy combination at `10:1234–1239`:

> Combine a healthy, sellable create with closure, solvency halt, absent rate, optional cap and short balance: require channel before solvency/rate

With a stale row, printed S1 supplies 502 instead of the channel headline and channel/solvency/rate entries. The healthy repetitions at `10:1267–1269` also lose their collected results.

There is no verified brief error changing the premise, and no reason to void the question’s tally.

2. **Re-run of the dissent traces**

These are source traces against the applied candidate, not implementation tests. I reused the verified r70 setup and mechanics.

Notation:

- `A`: **409 `conflict`**, `reason: "state"`.
- `O`: **400 `invalid_request`**, `reason: "offer_not_sellable"`.
- `S`: **503 `halted`**, `gate: "solvency"`.
- `R`: **503 `halted`**, `gate: "rate_unavailable"`.
- Parentheses give each entry’s `retryable`.
- Skip reasons: `H` = `provider_account_not_healthy`; `O` = `offer_not_sellable`; `R` = `rate_unavailable`.

| Fixture | Ordered refusal entries | Envelope retryable | Reasons for each present priced check |
|---|---|---:|---|
| `account_unreachable`, stale sellable X | `A(true)` | true | H |
| `credentials_rejected`, stopped credential, stale sellable X | `A(true)` | true | H |
| `terminated`, no row | `A(false), O(false)` | false | H, O |
| `terminated`, stale sellable X | `A(false)` | false | H |
| Either recoverable status, stale sellable X, solvency halt, supplied cap | `A(true), S(true)` | true | H |
| Same, absent rate | `A(true), S(true), R(true)` | true | H, R |
| `terminated`, no row, solvency halt, supplied cap | `A(false), O(false), S(true)` | false | H, O |
| Same, absent rate | `A(false), O(false), S(true), R(true)` | false | H, O, R |
| `terminated`, stale sellable X, solvency halt, supplied cap | `A(false), S(true)` | false | H |
| Same, absent rate | `A(false), S(true), R(true)` | false | H, R |

Every row has headline **409 / `conflict` / `state`**. For the other baseline rows, removing the rate appends `R(true)` and adds the rate skip reason without changing envelope retryability.

With a supplied cap, `not_checked` contains commitment cap before balance, with the displayed reasons in order. Without a cap, only balance appears. No suppressed check appears as passed or as a priced refusal; no cap or balance amounts are exposed.

Every refusing create commits **no commitment, balance, machine, operation or receipt**, and makes **no provider call**. Refresh calls and status writes in the preparation are separate actions. Subordinate halt pacing does not supply pacing to the state headline.

The exact sellable-offer combination at `10:1253–1255` survives on stale rows:

> An unhealthy create account + sellable offer + solvency halt with a supplied cap: `409`, state then solvency, cap and balance unchecked because `provider_account_not_healthy`; repeat with no rate as well and require the rate refusal and both reasons for each skipped check.

3. **S1c and preservation**

For any unhealthy collection-snapshot status:

| Stored source | What is read | Does an offer refusal follow state? |
|---|---|---|
| Stale row containing sellable X | That row, unchanged | No |
| Stale row containing unsellable X | That row, unchanged | Yes: `invalid_request`/`offer_not_sellable` |
| Present row omitting X | That row | Yes: the same offer refusal |
| No row | Empty offers set | Yes: the same offer refusal |

Age alone contributes neither an offer refusal nor a skip reason.

The existing `API-7` sentence at `04:273–275` is decisive:

> An offer absent from the offers the check reads is an unsellable offer for every rule in this tail, including cap and balance suppression and the `WIR-9a` `offer_not_sellable` refusal and `not_checked` entries.

Thus no row is an additional offer fault under the chosen source definition. It is not a sellable-offer singleton-account fixture merely because the live provider might sell X.

No different source or suppression exception is needed. The strongest argument for suppression would be avoiding a permanent offer refusal caused merely by missing cached evidence during a recoverable outage. However, that alternative changes the quoted absence rule. A fresh provider lookup would also violate the chosen admission source and provider-call boundary.

I found no separate `CNF-278` verdict loss from S1c: its unhealthy create headline survives for stale and missing rows. The administrative, metering, assignment and already-admitted claim barriers retain their conditions and outcomes. This does **not** clear the healthy `CNF-307` losses above.

4. **S6 and the combined duties**

The added refresh/publication assertions demonstrate the main new sequences: no customer demand, credential stop, dispatch timestamp, reverse completion and failed-read retention. Taken together, they do not require an older successful read to overwrite a newer row.

The publication sentence, identified as **proposed STO-60**, is:

> Every successful driver List offers read MUST publish its complete result to the account's row, replacing an existing row only when the incoming `read_at` is later.

The remaining issues and boundaries are:

- **Healthy stale fixture:** it demonstrates the proposed availability refusal, but does not amend the surviving healthy fault combinations. Printed S1 also conflicts with CNF-166’s retained unsellable-offer outcomes at `10:3684–3688`; a healthy missing-row fixture likewise cannot reach its retained never-listed-offer outcome at `10:3695–3699`.
- **Stored-price/claim-price fixture:** it is coherent if “re-list” changes the provider’s catalogue without a completed-and-published intervening driver read before admission. Admission uses the still-fresh stored price; claim obtains the higher current price. `OPS-43`’s quoted trigger is “where the provider's price has risen past what the reserve covers”. Treating the preparation as an already-published higher-price read would invalidate the fixture.
- **Snapshot and timing:** S1 fixes the account status and listing to the admission snapshot, and evaluates age at the admitting transaction. Its offer-derived inputs share that source; descriptor inputs use the running API’s descriptor. S6 does not directly exercise every input field or a publication racing that snapshot.
- **Stop scope:** S3’s exception is “except while that credential is subject to the authentication stop”. An unhealthy recorded status alone is not that exception. Refresh therefore still covers unhealthy accounts whose credentials are not stopped.
- **Caller and placement:** publication belongs outside the driver read. S4 explicitly places refresh in the engine process; its publication transactions remain subject to `OPS-50`. That requirement says “Where the values differ, the transaction MUST roll back”. The new publication duty supplies no bypass.
- **S1c coverage:** S6 does not explicitly control the unhealthy source fixtures in the table above. Direct regression assertions would improve coverage; this is distinct from the verified verdict loss.

I establish no Lean theorem failure. No Lean declaration was changed or executed. The tail model’s stated scope, `Admission.lean:1058–1060`, is snapshot facts and explicitly omits prices, locks, receipts, HTTP serialization and actual writes. It cannot establish correctness of the new freshness stage.

5. **Exact repairs**

**AMEND A — behaviour changed.** Location: S1, `API-7`, after base `04:264`; replace the freshness sentence **and S1c**.

Before:

```text
Where the account's `STO-47` status in that snapshot is `healthy` and its listing is absent or has a `read_at` older than the stated offer-listing age (`OVR-19`) at the admitting transaction, the create MUST be refused `provider` (`01-domain-model.md`'s error taxonomy) with `retryable: true` before the tail, committing nothing. For an account whose status in that snapshot is not `healthy`, the tail reads its stored listing regardless of age, or an empty offers set if no listing is stored.
```

Replacement:

```text
On create, the tail reads the stored listing regardless of age, or an empty offers set if no listing is stored. If the tail has collected no refusal and the stored listing has a `read_at` older than the stated offer-listing age (`OVR-19`) at the admitting transaction, the create MUST be refused `provider` (`01-domain-model.md`'s error taxonomy) with `retryable: true` before any admission write, committing nothing.
```

This preserves every collected refusal combination, including healthy stale combinations. Healthy missing rows produce the existing absent-offer refusal. A stale, otherwise admissible create still receives the proposed availability refusal.

**AMEND B — behaviour changed.** Location: S6, `CNF-166`, first inserted sentence after base `10:3699`.

Before:

```text
Separately let a `healthy` account's stored listing be older than the offer-listing age: the create is refused `provider`, `retryable: true`, with no provider call.
```

Replacement:

```text
Separately let a `healthy` account's stored listing contain the named sellable offer and be older than the offer-listing age, with no other refusal condition: the create is refused `provider`, `retryable: true`, after tail collection and before any admission write, with no provider call.
```

A+B are the smallest semantic repair I found. After applying and reviewing that repaired whole form, **I would ACCEPT it**: existing refusal results survive, and the newly proposed availability refusal applies after otherwise successful collection. This is a different behavioural candidate, not acceptance of printed r71.

**Optional AMEND C — behaviour changed, added assertion.** This addresses direct S1c coverage rather than another demonstrated verdict loss. In S6, replace its closing span:

```text
See `STO-60` and `OPS-51`.
```

with:

```text
Separately use each unhealthy status with a stale row containing the named sellable offer, a stale row containing an unsellable named offer, a row omitting the named offer, and no row. Assert the `conflict`/`state` entry first and an additional `invalid_request`/`offer_not_sellable` entry exactly when the named offer is unsellable or absent. Repeat with solvency halt, absent rate, and supplied and omitted caps; assert retryability, ordered skipped-check reasons, and no admission writes or provider calls. See `STO-60` and `OPS-51`.
```

All before spans were verified to apply exactly once. A+B were applied to a separate repaired scratch copy; C’s insertion was checked separately.

6. **Actual coverage and strict quotations**

I applied all seven operations comprising complete S1–S6 to [the scratch copy](/var/tmp/provisiond-panel-r71/sol/.r71-review/scratch), then ran:

```text
python3 tools/check_coverage.py
```

**Unpiped result: exit 0; 74 ratcheted uncovered.** The baseline stayed byte-identical to both its saved pre-run bytes and the original clone. A+B independently also returned **0 / 74**, with the baseline unchanged. Both complete `CNF-278` and `CNF-307` items remained byte-identical in both copies.

I checked the candidate’s quotations with fixed-string `rg`, normalizing whitespace only, against their attributed requirement bodies from `git show c5f897c:<file>`:

| Candidate quotation | Base owner/location | Result |
|---|---|---|
| S2 read-only excerpt | `PRV-50`, `02:123–124` | exit 0 |
| S2 price-string sentence | `DOM-9`, `01:185` | exit 0 |
| S3 authentication-stop excerpt | `PRV-41`, `02:1246–1248` | exit 0 |
| S6 price-rise excerpt | `OPS-43`, `03:863–864` | exit 0 |

The complete PRV-50 and PRV-41 source sentences were also verified. Their prescribed candidate excerpts remain intact. The proposed STO-60 publication quotation above was checked whole, including its replacement condition.

No quotation repair is needed. S1c and the replacement source sentences introduce API-7 rules rather than attributing obligations to another requirement. The register entries introduce settings; the remaining `See` pointers do not assert another owner’s content. [Quotation evidence](/var/tmp/provisiond-panel-r71/sol/.r71-review/quote-checks.json) and [exact repairs](/var/tmp/provisiond-panel-r71/sol/.r71-review/repairs.json) remain inside this clone.

Final: CANNOT ACCEPT; coverage 0/74; S1, S1c, S6.