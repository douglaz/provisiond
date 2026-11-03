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
