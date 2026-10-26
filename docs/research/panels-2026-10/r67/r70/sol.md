**CANNOT ACCEPT.** The combined candidate introduces an unlisted flip in `CNF-278`: an unhealthy-account create with an expired stored listing returns `provider` before reaching the checked `409 state` refusal. S6 explicitly amends `CNF-166`; it does not disclose this additional assertion change.

**Blocking trace.** [CNF-278, lines 2788–2792](https://github.com/douglaz/provisiond/blob/c5f897c32f7894d77a544528872176f241394d0d/10-conformance-checklist.md#L2788) states:

> **Then assert the account stops being sellable**: `GET /v1/providers` omits it for an assigned tenant, and a create naming it is `409` `state` — including a create issued against a catalogue read taken **before** the termination, since the listing is advisory.

Its next sentence includes “Assert the refusal on **all three** unhealthy statuses”.

A reachable counterexample is:

1. A successful List offers read stores a sellable offer at `t0`. The account declares `list_offers` and its ordering capability.
2. A subsequent refresh encounters an authentication failure. The credential stops; the operator records `credentials_rejected`. The failed read leaves the earlier listing intact.
3. At an admitting transaction later than `t0 + offer-listing age`, an activated, assigned tenant submits a valid create with a fresh key. Steps 1–5d pass. The credential remains stopped, so the expired listing is lawful under S3’s “except while that credential is subject to the authentication stop”.
4. S1 requires:

> Where no listing is stored, or its `read_at` is older than the stated offer-listing age (`OVR-19`) at the admitting transaction, the create MUST be refused `provider` (`01-domain-model.md`'s error taxonomy) with `retryable: true` before the tail, committing nothing.

The response therefore changes from the checked `409 state` to `provider`. This needs neither a scheduled authentication retry nor a publication failure. Fresh-listing unhealthy-account witnesses remain reachable; the counterexample concerns the expired-listing case.

**Strongest argument against taking the candidate — written on request, not another vote:** the newly asserted stale-listing refusal changes an existing account-status verdict without listing the affected assertion among the amendments.

The strongest argument for taking it is that the remaining combination is coherent and the independently measured coverage regression is repaired. The blocker needs a narrow, explicit disposition rather than another decision about stored listings.

The interactions otherwise hold together:

- **Admission and timing:** S1 retains “read in that snapshot” and “at the admitting transaction”. Its “Every offer-derived input” sentence ties commitment sizing and `request_summary` to the same stored offer; descriptor inputs have their separately stated source. I found no additional mixed-snapshot loss.
- **Credential scope:** S3 preserves the credential-specific exception. The quoted source at `02-provider-contract.md:1246–1248` includes “terminal for that credential, MUST NOT re-attempt it on a schedule”. It does not require refreshes to bypass that stop.
- **Process placement:** S4 retains “`engine`, running in the engine process”. The existing `OPS-50` scope includes “every write transaction made in the engine process”. I found no new escape from that placement or generation-check scope.
- **Caller publication and ordering:** proposed STO-60 says, in full, “Every successful driver List offers read MUST publish its complete result to the account's row, replacing an existing row only when the incoming `read_at` is later.” Together with the caller clarification, this permits publication outside the driver read and prevents an older dispatched read from overwriting a later one.
- **Age and interval:** S5 registers finite, positive durations with the refresh interval shorter than the age. Failed reads and credential stops can still leave an expired listing. That refusal is disclosed; its additional effect on `CNF-278` is the omitted loss identified above.

I judged the appended S6 text as **new conformance assertions**. Its no-demand refresh, stopped-credential, dispatch-timestamp, reverse-completion and failed-read witnesses are reachable together. The reverse-order assertion supplies the replacement condition for the preceding publication assertion.

The higher-price witness is also reachable: change the provider’s offered price after the stored read, admit before another successful driver read, then perform the current read at claim. It does not require withholding publication of a successful pre-admission read. Its quotation, “where the provider's price has risen past what the reserve covers”, matches `OPS-43` at `03-operation-lifecycle.md:865`. I found no separate unreachable witness or vacuous control in the append, and no additional Lean-theorem flip from the scoped text read. I did not run Lean.

If S1’s freshness precedence is retained, the following is an exact proposed repair. It remains **unreviewed**:

**S7 — AMEND, behaviour changed**, `10-conformance-checklist.md`, `CNF-278`, line 2789.

Replace:

```text
and a create naming it is `409` `state` —
```

with:

```text
and, with a stored offer listing present and no older than the stated offer-listing age at the admitting transaction, a create naming it is `409` `state` —
```

This adds a fixture condition and narrows the existing assertion. It cannot ride as a wording repair. Retaining this repair requires a scoped whole-form repair read; preserving the existing unconditional assertion instead requires a decision about S1’s precedence.

Strict quotation checks used fixed-string `rg` against `git show c5f897c:<file>`, normalizing whitespace only. All candidate attributed excerpts matched:

| Span | Owner and base location | Matched words |
|---|---|---|
| S2 row | `DOM-9`, `01-domain-model.md:185` | “Prices MUST be carried as strings exactly as the provider returned them.” |
| S2 caller clarification | `PRV-50`, `02-provider-contract.md:123–124` | “The driver's List offers MUST be read-only” |
| S3 | `PRV-41`, `02-provider-contract.md:1246–1248` | “A driver MUST therefore treat an `authentication` failure as terminal for that credential, MUST NOT re-attempt it on a schedule, and MUST surface it for an operator” |
| S6 | `OPS-43`, `03-operation-lifecycle.md:865–867` | “where the provider's price has risen past what the reserve covers” |

The shortened excerpts do not insert a false terminal period into the quoted source. I found no strict quotation repair or premise-changing brief error. S7 adds a condition to its own conformance assertion and makes no attribution to another requirement.

I applied **all original S1–S6** under `.r70-review/scratch` and ran `python3 tools/check_coverage.py` there, unpiped:

```text
requirements: 515 | covered by >=1 CNF item: 409 (79%)
uncovered (ratcheted): 74
OK: 74 uncovered, at or below baseline 74
```

Actual exit: **0**. The baseline remained byte-identical to `c5f897c`. A separate scratch copy containing proposed S7 also returned **74 uncovered, exit 0**. Tracked specifications remain unchanged; no full gate suite or `lake` was run.

Final: CANNOT ACCEPT; 74 uncovered / exit 0; S7 (CNF-278).