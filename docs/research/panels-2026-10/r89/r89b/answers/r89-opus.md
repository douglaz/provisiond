I'm the opus seat. My pick is a complete alternative, C′: Form C with the wire acknowledgement rule kept as it is at the pin. I can't accept any of A–D as printed, because all four make `WIR-17`'s acknowledgement rule conditional, and nothing the owner decided calls for that.

**Final: C′** (complete exact form at the end)

| Form | Verdict | Reason |
|---|---|---|
| A | CANNOT ACCEPT | `WIR-17` narrowing; no hourly cloud case |
| B | CANNOT ACCEPT | `WIR-17` narrowing; scope text repeated at nine sites |
| C | CANNOT ACCEPT | `WIR-17` narrowing; otherwise my pick |
| D | CANNOT ACCEPT | `WIR-17` narrowing; scope text repeated at nine sites |

Preference among the printed forms, kept separate from acceptance: C > A > D > B.

## 1. Packet check (rule 6)

- I compared all 18 pinned evidence blocks against my clone at `3109b5b`, and every one matches exactly.
- All four retained blocks in A–D match the pin, and `form-{A..D}.md` match the brief.
- C is exactly A plus the "Hourly cloud cases" paragraph, and D is exactly B plus the same paragraph.
- **No brief error changes the premise, so rule 6 does not void anything.**
- One inaccuracy that doesn't change the premise: the brief says the property "is tied to the creates a capability permits". That is true of `DOM-16`. But `PRV-10`, `API-15` and `WIR-17` say "For a paid create", which classifies each create separately. My blocking point comes from that text, not from the brief's sentence.

## 2. Blocking loss under rule 3, common to A–D

**The rule.** At the pin, `13-wire-contract.md:665–666` (`WIR-17`) says "`acknowledge_purchase` MUST be literal `true` (`API-15`, `PRV-10`)". That applies to every create. Every form makes it "For a paid create (`DOM-16`), …", and B and D spell the condition out in full.

**The case it breaks.** The set models creates that start no billing:
- `CNF-315` tests "a zero recurring price and a null floor".
- `CNF-316` says "Accept an order on an offer whose `first_unit` is zero".
- `12-billing-and-ledger.md:1242–1243` covers "a positive `seconds` at a zero recurring price".

**Trace.** A zero-price offer with setup fee `"0"`, `allow_orders: true`, and `acknowledge_purchase: false`:
- **At the pin:** `API-7` step 5 rejects it with `400 invalid_request`, `/acknowledge_purchase`. There is one possible verdict.
- **Under A–D:** "starts new provider billing … hourly or other recurring machine rental" can be read two ways for a zero-price rental:
  - Reading 1: a rental at zero price is still billing, so the create is paid and still gets 400.
  - Reading 2: nothing is charged, so the create isn't paid. Then no rule rejects it and it is admitted without the acknowledgement. `OVR-6`'s "billable actions" does not cover it either.
- Two engines can each cite the text and disagree, which is the kind of defect pv-9ecf was filed to fix.

**It also changes check order.** To apply the conditional rule at step 5, the api needs the offer's price. `API-7` reads offer data only later, in the tail: "the offers the check reads are the provider account's stored offer listing …, read in that snapshot". Under reading 2, the acknowledgement check effectively becomes a per-offer runtime check before that snapshot is read.

**Collateral narrowing of two checks.**
- `CNF-34` goes from "On separate creates" to "On separate paid creates".
- `CNF-342`'s fixture goes from "resource-offer create" to "paid resource-offer create".
- In both, a stored zero-price create with its acknowledgement removed no longer has to fail at `OPS-43` step 3.

**Why this is beyond the decision.** The owner decided which creates the acknowledgement must cover ("any create that starts billing"). They did not decide to exempt any create. The brief does not disclose this flip.

**Repair.** Keep `WIR-17:665–666`, `CNF-34` and `CNF-342`'s paragraph exactly as at the pin.
- An unconditional wire rule requires a superset of `API-15`'s paid creates, so nothing conflicts.
- No verdict then depends on classifying an individual create. The acknowledgement is always required by `WIR-17`, and the `allow_orders` half is `DOM-10`'s gate on the account-level capability.
- `CNF-34`'s quote of `WIR-17` stays byte-intact.
- The pin already had `API-15` scoped more narrowly than `WIR-17`, so this adds no new mismatch.

## 3. Missed sites

Besides the search list, I inspected: `PRV-4` (02:29), `PRV-34` (02:1046), 04:1018, the descriptor fixture at 13:1016–1030, `OVR-6` (00:46–47), `SEC-39` (07:205–264), CONTEXT.md:321–323 ("order-shaped provider", which means where the correlator lives, not a billing scope), and README `SEC-26` (a withdrawn description). Nothing else in live text quotes the changed `DOM-16` phrases ("not instead of", "cannot spend money", "does not declare them").

- **All forms:** I found no missed site that conflicts. `OVR-6` is a related umbrella phrase ("billable actions MUST require an explicit per-request acknowledgement") that needs no edit. Under the pin's `WIR-17`, which C′ keeps, it is satisfied for every create. CONTEXT.md is an optional glossary, so leaving out a "paid create" entry isn't a miss.
- **B and D:** No missed site, but the predicate is copied into nine places and the copies already differ:
  - "Neither a setup fee nor immediate payment is required for this condition to apply"
  - "without requiring a setup fee or immediate payment" (overview row)
  - "; neither … required for this condition to apply" (`CNF-342`)

  AGENTS.md says "One rule, one home; everywhere else points at it", and holds up `SEC-46` as the example of a copy that drifted. B and D replace four undefined phrasings with nine defined-in-place ones. That's a maintenance cost, not a rule-3 loss. B and D's `DEF-17` also adds a scope sentence that sounds normative to a historical defect record.

## 4. Traces

**(a) Hourly cloud create, no setup fee, `allow_orders: false`, acknowledgement `true`.**
- Wording: `DOM-16` says `provision_virtual` "permits a paid create" (hourly rental, "neither a setup fee nor immediate payment is required"). So the descriptor withholds it, `GET /v1/providers` omits it, and `API-7` step 5d / `DOM-10` refuses with `501 unsupported`, the account and capability in `details`, and `retryable: false`. The low-balance order and same-key replay in `CNF-55`'s base text are unchanged.
- Assertions:
  - **A/B:** `CNF-55`'s first case doesn't name an account type. Its claim-time case uses a resource offer, which is Robot auction, itself hourly with `price_setup` 0 (08:405–407). An engine that treats cloud as unpaid still passes `CNF-18` by declaring the capability, and it can pass `CNF-55` if the case runs on Robot. Nothing forces a `provision_virtual` fixture.
  - **C/D/C′:** the hourly paragraph asserts `details.capability: "provision_virtual"`, 501 at 5d, zero driver create calls and zero billing starts.

**(b) Hourly create, `allow_orders: true`, acknowledgement absent or `false`.**
- Wording: `API-15` ("A paid create request … MUST carry") plus `WIR-17` literal-true give 400 at step 5, before 5d and before the tail.
- Assertions: at the pin, the checklist's only `acknowledge_purchase` hits are `CNF-34` (lines 258 and 261, worker side), `CNF-55` (line 343, acknowledgement true) and `CNF-342` (line 4317, worker side). **No case anywhere tests a create admission with the acknowledgement absent or false.** C/D/C′ add one, plus a positive control that reaches the driver exactly once.

**(c) Claim-time restart (C/D/C′).** `OPS-43` step 1 reads status (local), step 2 reads the channel closure (local), then step 3 runs caller fields, then api fields, then the capability gate, giving `unsupported` before step 4's List offers read. The `LDG-39` "Deterministic rejection before acceptance" row means a full release with no debit. The claim that a catalogue offer holds no exclusion is consistent with `PRV-42`/`STO-58`, which apply only to `offer_is_resource`.

**(d) Stored acknowledgement removed (C/D/C′).** The step-3 caller-field check, via `OPS-23` ("Validation that was performed at the API boundary MUST be repeated"), gives `invalid_request` on `/acknowledge_purchase`. Under C′ this holds for every create, because `WIR-17` stays unconditional.

## 5. Other changes, none blocking

- **`DOM-16` drops ", not instead of,".** "In addition to" together with `PRV-10`'s "Both, not either" keeps the obligation. Restoring it would be harmless, but I left C's text as printed.
- **"cannot spend money" becomes "cannot start that billing".** This is a rationale clause and nothing quotes it.
- **The matrix row becomes "see `DOM-16`".** The table "is not read by anything".
- **`CNF-364` gains `allow_orders: true` and acknowledgement `true`.** This is a fixture clarification and loses nothing.
- **"Catalogue offer" isn't a defined term.** "Holds no resource-offer exclusion" makes the meaning recoverable. "An offer whose `offer_is_resource` is false" would be tighter.
- **The hourly case runs on one cloud driver.** Running it for each driver would be stronger but isn't required.
- **Positive-control fixture.** It must also declare `list_offers` and have a fresh stored listing and free 5c ceiling slots. "Keep all unrelated … admission conditions satisfied" covers that.
- **`CNF-182`.** Placing an order "with the acknowledgement absent" can only be a driver-level test, because provisiond's API rejects that at step 5. That predates every form. Under A–D's conditional `WIR-17`, a test-mode Robot order that "starts no billing" could also read as unpaid, which is another side of §2. C′ avoids it.
- **No Lean impact.** `Admission.lean`'s step-5d model takes declaration as a supplied Boolean, and no theorem encodes the scope.

## 6. Counterargument (on request) and pick

The strongest case for the wording-only footprint (A): the checklist isn't a gate, and `DOM-16`'s definition alone already makes an engine that treats cloud as unpaid non-conforming. `CNF-55`'s new heading "A paid create (`DOM-16`)" already scopes the existing case to every paid create. The triage row asked only for an explicit property. The hourly paragraph adds about 30 lines, a new fixture idea ("simulated billing starts"), and assertions that partly repeat `CNF-55`'s base text inside the same item. That is more text to keep in sync for a requirement the definition already settles.

**My pick is still C′.** A and B have no case that forces a cloud `provision_virtual` fixture, so the owner's exact failure story stays untested. No checklist case at the pin rejects a create admission whose acknowledgement is absent or false. C′ closes both gaps with the defined term (one home for the scope) and without the `WIR-17` narrowing.

## Evidence

I did not run `lake`, the formal gate or `check-all.sh`. On copies under `tmp/opus/`, I ran `check_ids`, `check_obligations`, `check_coverage` and `check_citations` for the pin, A, B, C, D and C′:

- **Same results everywhere:** ids, obligations and coverage exit 0. The citation quote pass reports "353 compared; 6, none new against baseline 6".
- **Not gate results:** `check_citations` then exits 2 because `.lake/index.jsonl` doesn't exist without the formal build, and `check_fixtures` exits 1 because `markdown_it` isn't installed outside nix. Both happen at the pin too.

I made no changes to the source, Git state or tracker.

---

## Form C′ — Form C with the unconditional wire acknowledgement retained

This is a complete landing form. The blocks below are all its replacements and explicitly retained direct dependents. Historical amendment paragraphs outside the printed replacement ranges stay as pinned; no new decision record is being proposed.

Changes from Form C: the `WIR-17` field rules opening, `CNF-34` and the `CNF-342` acknowledgement paragraph become **Retain verbatim** at their pinned bytes. Every other block is identical to Form C.

### Replace: DOM-16 — `01-domain-model.md:570–571` at the pin

```markdown
**DOM-16** A **paid create** is a create that starts new provider billing to the
operator, whether an upfront charge or hourly or other recurring machine rental; neither a
setup fee nor immediate payment is required. For each provider account, an ordering capability
(`provision_virtual` or `provision_bare_metal`) that permits a paid create MUST be conditional
on an explicit per-account `allow_orders` configuration flag: the descriptor (`PRV-44`) of an
account whose flag is false does not declare that capability, so that a misconfigured deployment
cannot start that billing. This is in addition to the per-request purchase acknowledgement
(`API-15`).
```

### Replace: PRV-10 — `02-provider-contract.md:159–162` at the pin

```markdown
**PRV-10** For a paid create (`DOM-16`), create MUST reject the request unless the
request carries an explicit purchase acknowledgement (`WIR-17`'s top-level
`acknowledge_purchase`), *and* the account is configured to allow ordering. Both, not either.
The configuration half is `DOM-10`'s gate on the create's ordering capability (`DOM-16`):
`API-7`'s step 5d at admission and `OPS-43`'s step 3 at claim.
```

### Replace: API-15 — `04-api-contract.md:987–992` at the pin

```markdown
**API-15** A paid create request (`DOM-16`) MUST carry an explicit purchase
acknowledgement — `WIR-17`'s top-level `acknowledge_purchase`, which the wire contract
owns — in addition to the account being configured to allow ordering (`PRV-10`). *"In its provider
options" until 2026-09-05, while `WIR-17` placed it at the top level; the wire contract wins, and a
spending authorization nested inside a driver-private object is one a strict server could not tell
from any other option.*
```

### Replace: configuration row — `00-overview.md:412–412` at the pin

```markdown
| `allow_orders`, per provider account with an ordering capability that permits a paid create (`DOM-16`) | `DOM-16` | boolean | yes |
```

### Replace: Create matrix row — `08-provider-notes.md:31–31` at the pin

```markdown
| Create | see `DOM-16` | see `DOM-16` | see `DOM-16` |
```

### Replace: DEF-17 historical scope paragraph — `09-known-defects.md:163–165` at the pin

```markdown
Requeue re-executed the original request verbatim. For a paid create (`DOM-16`), that is a
second purchase, gated by nothing beyond the same tenant token that placed the first one.
```

### Retain verbatim: WIR-17 field rules opening — `13-wire-contract.md:665–666` at the pin

```markdown
`ssh_public_keys` MUST be non-empty (`PRV-8`, `API-13`). `acknowledge_purchase` MUST be literal
`true` (`API-15`, `PRV-10`). `image` (nullable, a catalog identifier), `user_data` (nullable,
```

### Retain verbatim: CNF-18 — `10-conformance-checklist.md:124–135` at the pin

```markdown
- [ ] **CNF-18** — **AMENDED 2026-09-08 (`ADR-0018`) — the table is `DOM-10`'s, and the descriptor's
      fields are rows too.** For every driver, every declared capability has a working code path,
      and every implemented operation with a capability entry in `DOM-10`'s table has its
      capability declared. Table-driven over that table, one case per (driver, capability) pair;
      the three capability-less methods are `CNF-20`'s and are not rows here. **Then iterate the
      descriptor** (`PRV-44`), one case per (driver, field): a declared value has a working code
      path behind it — a declared ordering channel is searched, a declared evidence source is read,
      a declared surviving attachment kind is listed, and each ordering channel carries
      its own validated `order_budget` — and a field with nothing to declare says so
      explicitly rather than being absent. An ordering capability withheld under `DOM-16` is outside the implemented-implies-declared rows for that account; `CNF-19` and `CNF-55` cover its gate. (`DOM-15`, `DOM-10`, `PRV-4`, `PRV-44`)
      *Amended 2026-10-09 (`ADR-0036`): the order-budget field is iterated per channel.*
      *Amended 2026-10-22 (`pv-p3k`; panel r62, `docs/research/panels-2026-10/r62/`; owner decision 2026-10-22): applied the reviewed ordering-capability change.*
```

### Retain verbatim: CNF-19 — `10-conformance-checklist.md:137–139` at the pin

```markdown
- [ ] **CNF-19** — Create is refused when the provider has not declared the matching
      provision capability — with the driver's internal ordering flag set to permissive,
      so the test proves the outer gate exists. (`DOM-10`, `DEF-10`)
```

### Retain verbatim: CNF-34 — `10-conformance-checklist.md:256–279` at the pin

```markdown
- [ ] **CNF-34** — Validation is enforced in the worker even when the stored request bypasses
      the API layer. On separate creates, store records missing a caller-supplied field —
      `acknowledge_purchase` (`WIR-17`: "`acknowledge_purchase` MUST be literal `true`") — and
      an api-filled admission field, using the accepted-price fields in `request_summary`
      (`OPS-43`: "the accepted recurring price, its currency and its period"). For the caller field assert `invalid_request` with
      `details.field: "/acknowledge_purchase"` and `retryable: false`; for the api-filled
      field assert `conflict`, `details.reason: "incomplete_record"` and `retryable: true`.
      Assert the same kind, applicable reason and `retryable` on the error and the operation
      view (`WIR-9b`), `failed`, no driver call, and the create's commitment released in full
      with no setup-fee or first-unit debit.
      Repeat the caller-field case on an install, using `API-14`'s "explicit destructive
      acknowledgement". Assert `invalid_request` with `details.field: "/acknowledge_destruction"` and `retryable: false`
      on the error and view, `failed`, no driver call, both marker columns still null,
      `disk_effect: "none"` and `rescue_exit: "none"`. The install fixture uses that caller
      acknowledgement; an api-filled install case applies only if the release names a field the
      `api` writes at install admission, and the fixture must identify that field. It asserts
      `conflict`/`incomplete_record`, `retryable: true` and the same untouched-install outcome.
      Complete-record controls on create and install proceed. (`OPS-23`, `OPS-43`, `API-14`,
      `WIR-17`, `WIR-9a`, `WIR-9b`, `OPS-11`, `OPS-45`, `LDG-39`)
      *Amended 2026-10-17 (`pv-14b`; panel r55, `docs/research/panels-2026-10/r55/`):
      added missing-field fixtures, error/view agreement, commitment release,
      install marker outcomes and complete-record controls.*

      *Amended 2026-10-22 (`pv-ss4`; panel r62, `docs/research/panels-2026-10/r62/`): applied the reviewed field-pointer form and validation ordering.*
```

### Replace: CNF-55 — `10-conformance-checklist.md:340–359` at the pin

```markdown
- [ ] **CNF-55** — A paid create (`DOM-16`) is rejected without both the
      per-request purchase acknowledgement and the account-level opt-in. On an account whose
      `allow_orders` is false, assert `GET /v1/providers` lists it without its ordering
      capability, and that a create carrying `acknowledge_purchase: true` is refused at `API-7`'s
      step 5d: HTTP `501`, `unsupported`, `details.provider_account` and `details.capability`
      naming the account and that capability, `retryable: false`, and, with a balance too low for
      the create, no `details.refusals` or `details.not_checked` and no operation or commitment.
      A same-key, same-body replay of a create admitted before the flag was turned off returns its
      stored result. Admit a complete resource-offer (`offer_is_resource`) create with
      `allow_orders` true, and assert this create's exclusion for its provider account, ordering
      channel and offer id is held at admission (`PRV-42`, `STO-58`). While it is still queued
      and unclaimed, restart with only that flag changed to false, and assert the worker
      refuses it at `OPS-43`'s step 3 with the same kind, `details`
      and `retryable: false` on both the error and the operation view, `failed`, the commitment
      released in full with no setup-fee or first-unit debit, this create's settlement freeing
      that same held resource-offer exclusion (`STO-58`), and no provider request, including
      no List offers read. (`API-15`, `PRV-10`, `DOM-10`, `DOM-16`, `API-7`, `OPS-43`, `WIR-9a`,
      `WIR-9b`, `LDG-39`)

      **Hourly cloud cases.** Each admission case uses a fresh idempotency key. Use an
      otherwise valid, sellable hourly cloud catalogue offer
      with a positive recurring provider price and no setup fee, on a healthy assigned provider
      account implementing `provision_virtual`. Keep all unrelated sale, price, balance and
      admission conditions satisfied in the fixture. The driver is internally permissive and
      would start hourly billing if its create method were called; count its create calls and
      simulated billing starts. This fixture supplies the sale evidence needed for the test;
      it does not authorize sale of a live offer withheld under `PRV-13b` or `PRV-31`.
      With `allow_orders: false` and `acknowledge_purchase: true`, assert the provider listing
      omits `provision_virtual` and a fresh-key create fails at `API-7`'s step 5d with HTTP `501`,
      `unsupported`, `details.provider_account` naming that account,
      `details.capability: "provision_virtual"`, and `retryable: false`. Assert no operation,
      commitment or provider request, zero driver create calls and zero simulated billing starts.
      With `allow_orders: true`, separately omit `acknowledge_purchase` and set it to `false`.
      Each request fails HTTP `400`, `invalid_request`, `details.field: "/acknowledge_purchase"`,
      `retryable: false`, without an operation, commitment or provider request, and with zero
      driver create calls and zero simulated billing starts. A fresh-key control with both
      `allow_orders: true` and `acknowledge_purchase: true` reaches the fixture driver's create
      exactly once and records exactly one simulated hourly billing start.
      Separately admit this hourly catalogue create while both are true; while queued and
      unclaimed, restart with only `allow_orders` changed to false. Assert rejection at
      `OPS-43`'s step 3 with `unsupported`, the same account and capability details and
      `retryable: false` on both the error and operation view, `failed`, commitment released in
      full with no setup-fee or first-unit debit, no provider request including no List offers
      read, zero driver create calls and zero simulated billing starts. This catalogue offer
      holds no resource-offer exclusion. On a separate admitted hourly create with
      `allow_orders: true`, remove only its stored `acknowledge_purchase` before claim. Assert
      `OPS-43`'s step-3 `invalid_request`, `details.field: "/acknowledge_purchase"`,
      `retryable: false` on the error and view, `failed`, full commitment release with no
      setup-fee or first-unit debit, no provider request including no List offers read, zero
      driver create calls and zero simulated billing starts. (`WIR-17`, `OPS-23`, `OPS-11`)

      *Amended 2026-10-22 (`pv-p3k`; panel r62, `docs/research/panels-2026-10/r62/`; owner decision 2026-10-22): applied the reviewed ordering-capability change.*
```

### Retain verbatim: CNF-182 Robot test-mode case — `10-conformance-checklist.md:2371–2376` at the pin

```markdown
- [ ] **CNF-182** — The Robot driver's order test flag **defaults to test mode**, and a real
      purchase requires an explicit spend intent that is set exactly once, where `API-15`'s
      acknowledgement and `PRV-10`'s `allow_orders` both hold. Asserted by placing an order with
      the acknowledgement absent and confirming the API returns a `Cancelled` transaction and no
      server. **A driver defaulting to "real purchase" turns every mistaken conformance run into a
      bought server.** (`PRV-34`, `API-15`, `PRV-10`)
```

### Retain verbatim: CNF-342 acknowledgement paragraph — `10-conformance-checklist.md:4311–4320` at the pin

```markdown
      Separately omit the caller-supplied purchase acknowledgement from the stored record:
      admit a complete, valid resource-offer (`offer_is_resource`) create and assert this
      create's exclusion for its provider account, ordering channel and offer id is held at
      admission (`PRV-42`, `STO-58`), then remove only the stored caller-supplied acknowledgement
      before worker claim and validation (`OPS-23`). Assert rejection at
      `OPS-43`'s step 3, "Repeat boundary validation under `OPS-23`": `invalid_request` with
      `details.field: "/acknowledge_purchase"`, `retryable: false` on the error and operation view, `failed`, commitment
      released in full with no setup-fee or first-unit debit, this create's settlement freeing
      that same held resource-offer exclusion (`STO-58`), and no provider request at all,
      including no List offers read.
```

### Replace: CNF-364 setup and retained list-offers assertions — `10-conformance-checklist.md:140–154` at the pin

```markdown
- [ ] **CNF-364** — **The claim-time List offers read is gated on `list_offers`.** Admit a
      complete resource-offer (`offer_is_resource`) create on an account that declares
      `list_offers` and the ordering capability, with `allow_orders: true` and the request
      carrying `acknowledge_purchase: true`. Assert this create's exclusion for its provider
      account, ordering channel and offer id is held at admission (`PRV-42`, `STO-58`).
      While it is still queued and unclaimed, restart with a descriptor for that account that
      removes only `list_offers`, keeping the ordering capability declared and the driver's
      List offers code path answering, so the test proves the gate exists, as `CNF-19` does. Assert the worker
      refuses the create at `OPS-43`'s step 4: `unsupported` with `details.provider_account`
      naming the account and `details.capability: "list_offers"`, `retryable: false` on both the
      error and the operation view, no `details.refusals` or `details.not_checked`, `failed`, the
      commitment released in full with no setup-fee or first-unit debit, this create's settlement
      freeing that same held resource-offer exclusion (`STO-58`), and no List offers read,
      per-order key upload or order request. (`DOM-10`, `OPS-43`, `OPS-11`, `LDG-39`, `WIR-9a`,
      `WIR-9b`)
      *Amended 2026-10-22 (`pv-009`; panel r62, `docs/research/panels-2026-10/r62/`): applied the reviewed claim-time capability gate and refusal checks.*
```

### Retain verbatim: CNF-344 channel declaration is no capability grant — `10-conformance-checklist.md:4358–4363` at the pin

```markdown
- [ ] **CNF-344** — **Amended 2026-10-12 (`ADR-0037`, Q28).** **Each channel declares its own order budget.** Enumerate the
      descriptor's ordering channels and assert each has a positive `limit` and finite,
      positive `per`; no top-level `order_budget` substitutes for a missing channel
      entry. Verify the declared limit documents capacity; Robot's reported `403 RATE_LIMIT_EXCEEDED` raises `PRV-5`'s alarm naming account and request path (and channel where useful) and closes the local gate. No local request count raises that alarm.
      Another channel's mere declaration authorizes no new ordering capability.
      (`PRV-44`, `PRV-40`, `DOM-10`)
```

The same text is at `/var/tmp/provisiond-panel-r89/tmp/opus/form-Cprime.md`.
