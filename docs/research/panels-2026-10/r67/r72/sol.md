Vote: **CANNOT ACCEPT** on the whole S1–S6 + M1–M7 candidate at `c5f897c32f7894d77a544528872176f241394d0d`. There is a verified omitted assertion amendment: `CNF-243`.

**Strongest argument for this vote.** [CNF-243](https://github.com/douglaz/provisiond/blob/c5f897c32f7894d77a544528872176f241394d0d/10-conformance-checklist.md#L3105) contains this complete sentence:

```text
After `SEC-46` records a
      confirmed termination, the affected tenants are surfaced to the operator, the re-assignment
      verb gives one of them a live account, `GET /v1/providers` then returns it, and a create
      against it succeeds.
```

Choose a healthy replacement account with a stored listing containing the named sellable offer, `read_at = t − A − ε`, where `A` is the offer-listing age. Keep the rate available, balance sufficient, cap passing or omitted, ordering capability declared, channel open and resource-offer exclusion free. Complete reassignment and the catalogue read. No successful List offers publication occurs before the create; scheduled refresh reads can fail while the stored row remains unchanged.

S1 says:

> If the tail has collected no refusal and the stored listing has a `read_at` older than the stated offer-listing age (`OVR-19`) at the admitting transaction, the create MUST be refused `provider` (`01-domain-model.md`'s error taxonomy) with `retryable: true` before any admission write, committing nothing.

The trace collects no other refusal, so the create returns HTTP 502/provider/true and opens no commitment, operation or receipt. The quoted success assertion flips. M1–M7 do not amend `CNF-243`. The inventory’s generic dismissal at `check/assertion-inventory.md:66` is therefore false.

This is a rule-3 CNF loss. It is an inventory error, not an error changing the question’s premise; it does not void this question.

**Required additional amendment — behaviour changed.** Location: `10-conformance-checklist.md`, `CNF-243`, base lines 3105–3108. Before: the complete sentence above. Replacement:

```text
After `SEC-46` records a
      confirmed termination, the affected tenants are surfaced to the operator, the re-assignment
      verb gives one of them a live account, `GET /v1/providers` then returns it, and, with a stored listing containing the named sellable offer, with its `read_at` no older than the offer-listing age (`OVR-19`) at the admitting transaction, a create against it succeeds.
```

This narrows a success fixture. It requires a behavioural amendment and was **not applied** to the reviewed candidate.

**M1–M7 assessment.** Each is necessary for its identified control and sufficient locally. Together they remain incomplete because of `CNF-243`. The base assertions below reproduce the printed before-spans, normalizing line wrapping.

| Amendment | Base assertion | Stale result and amendment assessment |
|---|---|---|
| M1 / CNF-307 | Clear recoverable faults and resend the exact request and key: admission succeeds, proving refusal left no replay receipt. | Otherwise-successful stale retry gets provider/502/true. Fresh publication restores successful same-key retry; refusal combinations remain unqualified. |
| M2 / CNF-138 | Assert that an EUR create and `extend-runway` are admitted, a deposit mints, no unsettled invoice is cancelled, and the deposit read reports `gate: null` and `lightning.cancelled: false`. | EUR create gets provider/502/true. Its explicit fresh fixture restores admission without qualifying the rate/solvency refusals or extension. |
| M3 / CNF-315 | Create against an offer with a non-zero unit: the commitment includes `first_unit` at the customer rate and the setup fee at cost. | No commitment opens. The amendment covers nonzero, floor and zero-unit commitment assertions; the insufficient-balance refusal remains unqualified. |
| M4 / CNF-163 | Two concurrent creates against a balance that can fund exactly one result in one commitment and one `insufficient_balance` — under load, not by code review. | Both otherwise-successful stale contenders can refuse provider, leaving no winner. Freshness at each admission restores the intended winner/balance-loser race. |
| M5 / CNF-166 | An otherwise sellable offer with a bound no later than provider-local today and a sellable traffic bound is admitted and opens a commitment sized to that bound. | Stale data prevents admission and commitment creation. Freshness restores the positive bounded-offer control; unsellable/absent-offer refusals remain unqualified. |
| M6 / CNF-343 | Both read an open snapshot; at the admitting conditional-write barrier exactly one wins, and the loser receives an ordinary HTTP `409 conflict`/`state` error with `retryable: false`, no `details.refusals`, no synthesized pacing or `Retry-After`, and no commitment, balance change, operation or receipt. | Stale contenders can stop before the barrier. Freshness on each create restores the race, including the ordinary losing guard response. |
| M7 / CNF-343 | A catalogue product admits independent creates. | Otherwise-successful stale catalogue creates refuse provider. Freshness restores independent admission. |

**Trace assessment.** My independently written source projection matches the coordinator outputs over the complete product in `trace-cases.json`: 2,304 create rows, including 1,728 unhealthy rows, plus 64 extension controls; zero mismatches. See the [projection receipt](/var/tmp/provisiond-panel-r72/sol/.panel-r72-review/projection-result.json). This compares source-derived outcomes; it does not test an implementation, scheduling, transaction isolation or Lean.

- **D1:** Stale unsellable/absent offers retain the false offer refusal. Present priced checks are skipped, with withheld-price amounts suppressed.
- **D2:** Stale sellable channel + solvency + absent-rate retains channel/solvency/rate ordering, channel headline pacing and rate skips for either cap choice.
- **D3:** Account when unhealthy, then offer/channel/solvency/rate when applicable. Skips retain account/offer/rate order per present check. Termination or an offer refusal makes the envelope false; subordinate pacing does not become headline pacing.
- **D4:** Healthy stale sellable, rate present, no cap: balance runs and `not_checked` is empty. A failing balance produces its existing refusal; a passing balance reaches provider/502/true. This is an evaluation assertion, so no fixture amendment is needed.
- **D5:** Clearing faults while retaining stale data still returns provider/502/true without admission writes or receipt. M1’s fresh publication permits the same request/key to admit.
- **Every unhealthy branch:** State-first precedence survives fresh/stale/no-row and sellable/unsellable/absent-offer inputs. Stale sellable data does not invent an offer refusal. No row supplies an empty set even if the live provider sells the offer. A healthy no-row trace gets the false offer refusal, retaining other faults and ordered skips.
- **Boundary and effects:** Equality with the age limit produces no age refusal. Other collected refusals prevent the new age refusal. Refusing tails make no admission writes, receipt or provider call.
- **Remaining controls:** I found no additional changed assertion in the supplied early-pipeline, extension, conditional-write or whole CNF-278 create/claim passages. Already-admitted queued/claimed setups remain distinguishable from `CNF-243`’s asserted successful create after reassignment. Admission’s stored source leaves the claim-time current-provider read in place. No additional verified Lean loss is claimed; no Lean command was run.

**Quotation repairs — each behaviour unchanged.** The following before-spans match the applied candidate uniquely. Replacement quotations match complete owner sentences with whitespace normalization only. They were not silently applied. The DOM-9 price quotation already matches its complete sentence.

Q1 — [05-persistence.md](https://github.com/douglaz/provisiond/blob/c5f897c32f7894d77a544528872176f241394d0d/05-persistence.md), S2 / STO-60 caller-publication sentence; **behaviour unchanged**.

Before:

```text
The read's caller publishes the result, outside the driver read: `PRV-50` says "The driver's List offers MUST be read-only".
```

Replacement:

```text
The read's caller publishes the result, outside the driver read: `PRV-50` says “The driver's List offers MUST be read-only under `PRV-12`'s guarantee: "Get machine MUST be read-only and free of side effects".”
```

Q2 — [03-operation-lifecycle.md](https://github.com/douglaz/provisiond/blob/c5f897c32f7894d77a544528872176f241394d0d/03-operation-lifecycle.md), S3 / OPS-51 attribution sentence; **behaviour unchanged**.

Before:

```text
`PRV-41` says “A driver MUST therefore treat an `authentication` failure as terminal for that credential, MUST NOT re-attempt it on a schedule, and MUST surface it for an operator”.
```

Replacement:

```text
`PRV-41` says “A driver MUST therefore treat an `authentication` failure as terminal for that credential, MUST NOT re-attempt it on a schedule, and MUST surface it for an operator (`OPS-26`).”
```

Q3 — [10-conformance-checklist.md](https://github.com/douglaz/provisiond/blob/c5f897c32f7894d77a544528872176f241394d0d/10-conformance-checklist.md#L3700), S6 / CNF-166 OPS-43 parenthetical; **behaviour unchanged**.

Before:

```text
(`OPS-43`: "where the provider's price has risen past what the reserve covers").
```

Replacement:

```text
(`OPS-43`: “After the sale re-test passes, and before any per-order key upload or other provider mutation, the worker MUST re-read the offer's current price from that same List offers result **in the provider's own currency** and compare it with the native price the commitment was sized from — **carried on the operation's `request_summary`, which MUST hold the accepted recurring price, its currency and its period, and the accepted setup fee and prepaid first unit, the unit with its `billing_unit.seconds`** (`LDG-2`, `LDG-67`; *the unit and its seconds added 2026-10-08, `ADR-0033`, because the machine's row copies the seconds for its first seed, `LDG-38`, `05-persistence.md`*; *the fields are named so a worker restarted before claim can perform this comparison at all*; *named 2026-09-05 — a first form cited a native figure on the commitment row, which carries only `reserved_sats`*) — and **fail the operation deterministically — before any provider mutation — where the provider's price has risen past what the reserve covers**: `conflict`, `details.reason: "price_moved"`, the shortfall in `details`, telling the caller to re-submit, and `retryable: true` on both the error and the operation view (`WIR-9b`).”).
```

**Application and coverage.** Scratch: `/var/tmp/provisiond-panel-r72/sol/.panel-r72-review/candidate/`. All 14 candidate operations applied uniquely using whitespace normalization for source wrapping; changed-file bytes match the coordinator’s applied copy.

The actual unpiped command, run in that scratch, was:

```text
python3 tools/check_coverage.py
```

Actual exit: **0**. Ratcheted uncovered: **74**, at baseline **74**, recorded **2026-10-22**. Baseline bytes remain unchanged. SEC/WIR report-only uncovered: **32**. See the [coverage receipt](/var/tmp/provisiond-panel-r72/sol/.panel-r72-review/coverage-receipt.json).

My first literal-match application stopped at S6’s wrapped anchor. An incidental coverage run on that incomplete copy exited **1**, with **76** uncovered. I restored the scratch and reapplied the entire candidate; no application failure remains. The complete-candidate result is the exit-0 result above.

`TMPDIR` remains `/var/tmp/provisiond-panel-r72/tmp`. Tracked clone files are unchanged. No full gates/lake, commit, push, provider API, delegation, background task or wait was used. The [saved review](/var/tmp/provisiond-panel-r72/sol/.panel-r72-review/review.md) was drafted before minute 25.

**Counterargument, written on request; not a vote.** The candidate preserves the base rich-tail refusals while retaining the owner’s age refusal. One could treat CNF-243’s successful create as a reassignment control that naturally uses a fresh listing; that test would pass, and the source projections support its tail mechanics. But this supplies an unstated fixture condition to a direct success assertion. A fresh witness cannot defeat the unqualified stale counterexample under this round’s rules. The fresh condition must be explicitly listed as a behavioural amendment.

Final: CANNOT ACCEPT.