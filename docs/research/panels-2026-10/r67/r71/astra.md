**CANNOT ACCEPT the printed whole candidate.** It repairs the unhealthy-account stale-row failures, but the healthy-account age refusal changes surviving CNF-307 verdicts. Coverage passes; preservation does not.

The smallest repair I identified is **R1–R2 below, both behaviour changed**. After those changes, the identified preservation failure is removed. That is a different behavioural candidate, so it remains **CANNOT ACCEPT for this tally**, not a wording-only ACCEPT.

**Blocking trace.** Keep the recorded account status `healthy`, let scheduled refresh attempts fail without replacing the stored row, and let that row age past the limit. The row contains the requested offer, which is unsellable because its cancellation bound is absent. Supply a cap and an available rate; pass the early pipeline.

CNF-307, `10-conformance-checklist.md:1259–1262`, requires:

> On an unsellable create with a healthy account and available rate, assert a singleton offer refusal, false retryability, and both priced checks skipped for `offer_not_sellable` when a cap is supplied.

The printed S1 instead requires an early **502 `provider`, `retryable: true`**, before collection. The required **400 offer refusal**, false envelope retryability and skipped-check payload disappear. A fresh-row witness cannot discharge this stale-row counterexample.

The new S6 stale-row assertion explicitly discloses its proposed 502 result. The further loss is the contradictory result of the **unchanged CNF-307 assertion**, not the mere addition of S6.

**Strongest argument against this form — written on request; not another vote:** restricting the age refusal to healthy accounts repairs account precedence while leaving offer, channel and halt precedence vulnerable. For example, the same healthy stale-row setup with a sellable offer and closed channel replaces the required channel response with 502.

The strongest favourable argument is substantial: S1c preserves stale sellable-offer inputs for unhealthy accounts and retains independent faults instead of stopping at state alone.

The brief’s CNF-307 extract ends at line 1284; the actual item continues through line 1300. I read the continuation. This omission does **not** change or void the preservation premise.

**Independent replay of the dissent traces**

These are specification traces, not implementation tests. Use the brief’s already-verified timing and publication setup.

Notation below gives each entry’s kind, reason/gate and retryability:

- `R`: `conflict`, reason `state`, **true** — either recoverable account status.
- `T`: `conflict`, reason `state`, **false** — terminated account at admission.
- `O`: `invalid_request`, reason `offer_not_sellable`, **false**.
- `H`: `halted`, gate `solvency`, **true**.
- `N`: `halted`, gate `rate_unavailable`, **true**.
- Skip reasons: `U` = `provider_account_not_healthy`; `O` = `offer_not_sellable`; `N` = `rate_unavailable`.

Every row below has headline **HTTP 409 / `conflict` / `state`**. Termination does not change the admission reason to `account_terminated`.

| Fixture | Ordered refusal entries | Envelope retryable | Reasons for each present priced check |
|---|---|---:|---|
| `account_unreachable`, stale row containing sellable X | `R` | true | `U` |
| `credentials_rejected`, stopped credential, stale sellable X | `R` | true | `U` |
| `terminated`, no row | `T, O` | false | `U, O` |
| `terminated`, stale sellable X | `T` | false | `U` |
| Either recoverable case + solvency + supplied cap | `R, H` | true | `U` |
| Same, without a rate | `R, H, N` | true | `U, N` |
| Terminated stale sellable X + solvency + cap | `T, H` | false | `U` |
| Same, without a rate | `T, H, N` | false | `U, N` |
| Terminated no-row + solvency + cap | `T, O, H` | false | `U, O` |
| Same, without a rate | `T, O, H, N` | false | `U, O, N` |

With a supplied cap, emit all reasons for `commitment_cap`, then all reasons for `balance`. For example, the recoverable solvency/no-rate case has:

```text
(commitment_cap, provider_account_not_healthy)
(commitment_cap, rate_unavailable)
(balance, provider_account_not_healthy)
(balance, rate_unavailable)
```

Without a supplied cap, emit only the balance entries. Adding absent rate to a baseline row likewise appends `N` to refusals and `rate_unavailable` to each present check’s reasons.

All these refused creates commit **nothing**: no commitment, balance, machine, operation or receipt write, and no provider call. Subordinate halt delays do not give the state headline pacing. The stopped credential receives no scheduled retry.

The aggregation agrees with WIR-9b, `13-wire-contract.md:226–228`:

> `retryable` MUST be true iff every refusal entry's `retryable` is true.

**S1c and the surviving combinations**

For every unhealthy status, the offer inputs are exactly:

| Stored state | Input read | Offer entry after state |
|---|---|---|
| Stale row containing sellable X | That row and X | None |
| Stale row containing unsellable X | That row and X | `invalid_request` / `offer_not_sellable`, false |
| Present row omitting X | That row; X is absent | Same offer entry |
| No row | Empty offers set | Same offer entry |

Freshness does not manufacture an offer refusal for an unhealthy account. Actual absence or unsellability does.

API-7, `04-api-contract.md:273–275`, supplies the relevant existing rule:

> An offer absent from the offers the check reads is an unsellable offer for every rule in this tail

Consequently, no-row does **not** require another source or suppression of the offer entry. State-only output might seem preferable because it avoids conflating unavailable catalogue data with a bad offer, but that alternative changes the stated absence rule and drops an independent refusal. It is not a quotation repair.

The exact unchanged combination at `10-conformance-checklist.md:1253–1255` says:

> An unhealthy create account + sellable offer + solvency halt with a supplied cap: `409`, state then solvency, cap and balance unchecked because `provider_account_not_healthy`; repeat with no rate as well and require the rate refusal and both reasons for each skipped check.

S1c preserves this with a stale row containing sellable X: `R,H` or `T,H`, followed by `N` when appropriate. The missing-row fixture is an absent-offer case, not a sellable-offer witness.

I found no independent CNF-278 verdict loss in its account-loss, catalogue, metering, release, episode, assignment or barrier assertions. The unhealthy create headline remains 409 state for stale and missing rows. The claim barriers remain applicable to creates already admitted; S1 does not replace the claim-time read.

CNF-307 is nevertheless not preserved whole:

- The healthy stale unsellable case above changes its required response.
- Healthy stale channel and halt cases lose their required collection results.
- At `10:1281–1283`, CNF-307 says: “With a rate and healthy account and sellable offer, omitting the cap leaves balance evaluated and `not_checked: []`.” The healthy stale-row gate prevents that evaluation.
- At `10:1292–1293`, it says: “Clear recoverable faults and resend the exact request and key: admission succeeds, proving refusal left no replay receipt.” Recovering account status while retaining its stale sellable row leaves an additional refusal under S1.

Extensions and the earlier common-pipeline results are unaffected. Unhealthy-account combinations retain offer/channel/halt collection under S1c.

**S6 and the combined operational duties**

The healthy stale-row assertion demonstrates S1’s new refusal, but also exposes the preservation conflict. The stored-price/claim-price assertion is achievable: change the provider fixture’s offered price while the admission row remains within age, admit from that row, and obtain the higher-price driver result at claim. A newer result already published before the admission snapshot would not demonstrate that assertion.

The claim result follows the quoted OPS-43 condition at `03-operation-lifecycle.md:864–867`:

> where the provider's price has risen past what the reserve covers

A higher-price read at claim also participates in the proposed publication duty. Keeping admission’s earlier snapshot fixed does not authorize suppressing that publication.

The remaining appended assertions exercise the intended no-demand cadence, credential-stop exception, dispatch timestamp, reverse-completion ordering and failed-read retention. Read together, publication and reverse-order assertions must preserve the later-dispatched result; an older completion is not permission to overwrite it.

Important combined effects:

- S1 reads account status, listing and offer-derived inputs in the admission snapshot. Concurrent publication changes later snapshots, not that one.
- S3’s exception attaches to the stopped **credential**, not every unhealthy account. Non-authentication failures retain the row while scheduled reads continue.
- S4 explicitly places refresh in the engine process. OPS-50, `03:1984–1993`, covers “every write transaction made in the engine process” and requires it to “read `STO-59`'s row `FOR SHARE` as its first statement”; “Where the values differ, the transaction MUST roll back”.
- Caller-side publication preserves the prescribed driver read-only excerpt. For publication occurring in an API process, OPS-50 explicitly says: “Writes made in the api process are not checked.”
- Dispatch ordering prevents an earlier-dispatched late completion from replacing the newer row. It does not justify refreshing `read_at` at completion.

S6 does **not directly demonstrate S1c’s unhealthy stale/missing-row branches**. A dedicated assertion would improve conformance coverage of those behaviours, including the recoverable false-envelope case when `O` follows state. That is a test gap, not an additional blocking-loss claim or an automatic coverage failure. Adding that assertion would itself be a disclosed behavioural amendment.

I inspected the relevant admission declarations. No Lean failure is claimed, and no Lean command was run. In particular, the tail functions do not model listing age; their continued proofs would not establish preservation across this new pre-tail branch.

**Exact minimal repair**

Both amendments below are **behaviour changed**. They preserve stored listing as the source and remove the conflicting age-based admission refusal.

**R1 — behaviour changed.** `04-api-contract.md`, API-7; S1 sentences 2–3, inserted after base line 264.

Before:

> Where the account's `STO-47` status in that snapshot is `healthy` and its listing is absent or has a `read_at` older than the stated offer-listing age (`OVR-19`) at the admitting transaction, the create MUST be refused `provider` (`01-domain-model.md`'s error taxonomy) with `retryable: true` before the tail, committing nothing. For an account whose status in that snapshot is not `healthy`, the tail reads its stored listing regardless of age, or an empty offers set if no listing is stored.

Replacement:

> The tail reads the stored listing regardless of whether its `read_at` is older than the stated offer-listing age (`OVR-19`), or an empty offers set if no listing is stored.

Effect: unhealthy cases retain their results; healthy stale rows reach the existing tail; healthy missing rows yield the existing absent-offer refusal. No alternative offer source is introduced.

**R2 — behaviour changed.** `10-conformance-checklist.md`, CNF-166; first added S6 sentence, after base line 3699.

Before:

> Separately let a `healthy` account's stored listing be older than the offer-listing age: the create is refused `provider`, `retryable: true`, with no provider call.

Replacement: **delete that sentence**, retaining the following stored-price/claim-price assertion and all remaining S6 text.

Moving the age refusal after collection would not fully repair the candidate: the successful-admission assertion would still have a stale-row counterexample. If retaining the new healthy stale-row refusal is mandatory, it is incompatible with the settled preservation target.

I applied R1–R2 separately and verified their exact replacement matches. The printed and repaired copies both retain CNF-278 and CNF-307 byte-for-byte. The repair also passes coverage at **0/74**. Exact spans are saved in [.r71-repair-spans.json](/var/tmp/provisiond-panel-r71/astra/.r71-repair-spans.json).

**Coverage and strict quotation results**

The entire printed S1–S6 candidate was applied in [.r71-scratch](/var/tmp/provisiond-panel-r71/astra/.r71-scratch). I ran, unpiped:

```text
python3 tools/check_coverage.py
```

Actual result: **exit 0; 74 ratcheted uncovered; 515 requirements; 409 covered**. `tools/coverage-baseline.json` remained byte-identical between HEAD, the original clone and scratch. No baseline increase, full suite or `lake` run occurred.

All candidate quotation checks used fixed-string `grep`, normalizing whitespace only:

| Span | Base source | Exit |
|---|---|---:|
| S2 PRV-50 excerpt | `02-provider-contract.md:123–124` | 0 |
| S2 DOM-9 price sentence | `01-domain-model.md:185` | 0 |
| S3 PRV-41 excerpt | `02-provider-contract.md:1246–1248` | 0 |
| S6 OPS-43 price excerpt | `03-operation-lifecycle.md:864–866` | 0 |

The prescribed S2/S3 excerpts are retained. I found no strict quotation defect requiring repair. S1c and R1 establish offer-source behaviour directly; they do not paraphrase another owner’s requirement. R2 deletes an assertion. Neither repair introduces a quotation of proposed STO-60 or copies another owner’s MUST.

Final: CANNOT ACCEPT; coverage 0/74; R1, R2.