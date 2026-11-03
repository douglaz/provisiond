# pv-9ecf — exact replacement package

Choice vector: Q1 R-MASTER; Q2a/b/c Q-QUOTE; Q2d/e Q-POINTER; Q3 S-OUT; Q4 L-NOTE.
Pin: `2e2cd94637112f20538eb26b141672fedf0ba455`. This prospective package becomes applicable only if the owner selects both open choices above; it is not adopted by the tally turn. No r97c follows.

## Preparation commit targets

Replace only comment 861's text in `.beads/issues.jsonl`, physical line 29 at the pin. Preserve all other comments, bead fields and JSONL records. Original decoded comment lines: authority 16; desired-behavior heading 53; retention directive 59; Q2a 80–81, Q2b 89–92, Q2c 266–268; Q2d 77–79 and Q2e 87–89 take their exact POINTER sentences; historical placement 296–298. Q2b's historical Current behavior occurrence at 41–44 stays unchanged. The full decoded replacement below is authoritative for this choice.

Append the exact appendix below at EOF after original line 234 of `docs/research/panels-2026-10/r89/check/tally/form-Cprime.md`. Preserve its 16085 original bytes as an exact prefix. Leave `docs/research/panels-2026-10/r89/r89b/form-Cprime.md` unchanged; no duplicate-form note is selected.
Archive the reviewed r97/r97b records under `docs/research/panels-2026-10/r97/` so the authority reference resolves. Preserve the selected note bytes and link if NOTE is chosen. Its historical date remains 2026-11-02, with the r97b decision date recorded separately as 2026-11-03. No silent note correction or new substantive rule is authorized.

## Exact reviewed landing directive

`````text
Preparation commit on branch pv-9ecf before the Run, in the same PR: replace only the executable comment-861 wording at the selected targets and its authority/retention instructions; preserve historical Current behavior quotations and all other tracker fields. The Run writes the exact selected executable replacements, leaving retained current source blocks unchanged if R-MASTER wins. Append exactly L-NOTE-append.md under docs/research/panels-2026-10/r89/check/tally/form-Cprime.md; all original bytes remain an exact prefix. Also qualify the duplicate r89/r89b/form-Cprime.md with a pointer note only if the reader supplies and accepts that exact additional text; no silent archive rewrite. Archive the reviewed r97 record to supply the authority reference. No real branch or tracker edit occurs in this panel turn.
`````

## Run handoff

Use the corrected comment 861 below, including its executable form, instead of copying original C′ wholesale. The exact substitutions are the supplied R-MASTER directive/placement/authority, Q2a/b/c Q-QUOTE, and the Q2d/e forms selected above. Historical Current behavior, historical approval quotations, retained display blocks and the old drift table are comparison records, not restoration instructions. In particular retain the complete current source at `2e2cd94637112f20538eb26b141672fedf0ba455` for every Retain block; never restore the old CNF-34 display over PR #60's install-marker fixture. Current CNF-34 span SHA-256: `d495bb8e659dcb044dde50d5c6048bdd64e6e76ffbd875f3e0f3062ef5958948`. No CNF-18 edit or new bead. Before applying, recheck drift and the required unpiped Nix gates. This tally authorizes no Run itself.

## Exact decoded replacement for comment 861

`````text
## Agent Brief

**Category:** bug
**Summary:** pv-9ecf — adopt the approved exact paid-create form C′.

**Owner decisions and precedents:**

Owner-decisions-1030.md item 4: **"Every paid create (Recommended)"**. Option text shown:

> The switch and the per-request purchase acknowledgement cover any create that starts billing, hourly cloud VMs included. 'Orders off' means the account can't spend. Cost: cloud accounts also need the switch on, and each cloud create carries the acknowledgement. This is the 10-27 triage's pick. The exact wording gets a panel read before it lands.

Owner-decisions-1030.md item 24: **"Approve C′ (Recommended)"**.

Owner, 2026-10-28: **"For such wording questions, try to solve by getting a consensus of the panel"** (`docs/research/panels-2026-10/r89/r89b/tally.md:11`).

Original adopted form: `docs/research/panels-2026-10/r89/r89b/form-Cprime.md`, SHA-256 `be350270318a2752992a9cb199a2a56879249be99f36e7af430bcfe8a1d47a32`, reviewed at `3109b5b44eae17e288cf52aaa976993bd8c5626c`. Executable wording uses the exact per-question selections recorded in Panel R r97 under the owner’s 2026-10-28 wording rule. Item 24’s complete "Hourly cloud cases" block and item 4’s policy remain approved; the original form remains the historical approval record.

**Current behavior:**

`01-domain-model.md:570` at `3109b5b44eae17e288cf52aaa976993bd8c5626c`:

```text
**DOM-16** Ordering capabilities (`provision_virtual`, `provision_bare_metal`) for providers that bill per order MUST be conditional on an explicit per-account `allow_orders` configuration flag: the descriptor (`PRV-44`) of an account whose flag is false does not declare them, so that a misconfigured deployment cannot spend money. This is in addition to, not instead of, the per-request purchase acknowledgement
(`API-15`).
```

`02-provider-contract.md:159` at `3109b5b44eae17e288cf52aaa976993bd8c5626c`:

```text
**PRV-10** For a provider that bills on order, create MUST reject the request unless the
request carries an explicit purchase acknowledgement (`WIR-17`'s top-level
`acknowledge_purchase`), *and* the account
is configured to allow ordering. Both, not either. The configuration half is `DOM-10`'s gate on the create's ordering capability (`DOM-16`): `API-7`'s step 5d at admission and `OPS-43`'s step 3 at claim.
```

`04-api-contract.md:987` at `3109b5b44eae17e288cf52aaa976993bd8c5626c`:

```text
**API-15** A create request against an order-billed provider MUST carry an explicit
purchase acknowledgement — `WIR-17`'s top-level `acknowledge_purchase`, which the wire contract
owns — in addition to the account being configured to allow ordering (`PRV-10`). *"In its provider
options" until 2026-09-05, while `WIR-17` placed it at the top level; the wire contract wins, and a
spending authorization nested inside a driver-private object is one a strict server could not tell
from any other option.*
```

`00-overview.md:412` at `3109b5b44eae17e288cf52aaa976993bd8c5626c`:

```text
| `allow_orders`, per ordering account | `DOM-16` | boolean | yes |
```

**Desired behavior / key interfaces / acceptance criteria — executable form with Panel R r97 corrections:**

## Form C′ — Form C with the unconditional wire acknowledgement retained

This is a complete landing form. The blocks below are all its replacements and explicitly retained direct dependents. Historical amendment paragraphs outside the printed replacement ranges stay as pinned; no new decision record is being proposed.

Changes from Form C: the `WIR-17` field rules opening, `CNF-34` and the `CNF-342` acknowledgement paragraph are **Retain verbatim**, meaning this package does not edit them. For execution at `2e2cd94637112f20538eb26b141672fedf0ba455`, retain their complete current master text, including PR #60’s install-marker fixture in `CNF-34`; the printed 3109b5b blocks below are historical comparison text. Every other block is identical to Form C except for the exact quotation corrections selected in Panel R r97.

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
request carries an explicit purchase acknowledgement (top-level
`acknowledge_purchase`; wire owner: `WIR-17`), *and* the account is configured to allow ordering. Both, not either.
The configuration half is `DOM-10`'s gate on the create's ordering capability (`DOM-16`); `DOM-10` says “Every operation with a capability MUST be gated on it before the
driver is called, **including create**”. At admission, step 5d is the gate: `API-7` says “**gate a create on its ordering capability** under `DOM-10` (`PRV-10`, `DOM-16`). A refusal stops here and is not collected by the tail”. At claim, step 3 is the gate: `OPS-43` says “Repeat boundary validation under `OPS-23`: "Validation that was performed at the API boundary
   MUST be repeated in the worker before the driver is called". This includes `PRV-10`'s
   "explicit purchase acknowledgement", `PRV-8`'s "at least one SSH public key", the missing-field
   checks defined in `OPS-23`, and `DOM-10`'s gate on the create's ordering capability, which is
   `PRV-10`'s "the account is configured to allow ordering". The checks on caller-supplied fields
   run first, then the checks on fields the `api` wrote at admission, then the capability gate”.
```

### Replace: API-15 — `04-api-contract.md:987–992` at the pin

```markdown
**API-15** A paid create request (`DOM-16`) MUST carry an explicit purchase
acknowledgement — top-level `acknowledge_purchase`; wire owner: `WIR-17` — in addition to the account being configured to allow ordering (`PRV-10`). *Until 2026-09-05, `API-15` said “purchase acknowledgement in its provider options, in addition to the account being
configured to allow ordering (`PRV-10`).” (revision `7116e90b9932211c08f2e712690cc176b56edea6`); at that same revision, `WIR-17` said “`acknowledge_purchase` MUST be literal
`true` (`API-15`, `PRV-10`).” and placed the acknowledgement at the top level in this create body: “{
  "provider_account": "hetzner-cloud-1",
  "offer": "standard:cx32",
  "region": "fsn1",
  "hostname": "worker-1",
  "image": null,
  "ssh_public_keys": ["ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIexamplekeyxxxxxxxxxxxxxxxxxxxxxxxx"],
  "user_data": null,
  "labels": {"team": "batch"},
  "runway_seconds": 2592000,
  "max_commitment_sats": 90000,
  "acknowledge_purchase": true,
  "provider_options": {}
}”. The wire contract wins, and a spending authorization nested inside a driver-private object is one a strict server could not tell from any other option.*
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
      List offers code path answering, so the test proves the gate exists, as `CNF-19` does (`CNF-19` says “Create is refused when the provider has not declared the matching
      provision capability — with the driver's internal ordering flag set to permissive,
      so the test proves the outer gate exists.”). Assert the worker
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

**Retained, rejected and out of scope:**

`docs/research/panels-2026-10/r89/r89b/owner-questions.md:16`:

> A smaller package obtained by deleting the hourly block or adding retentions to A would be a different, unreviewed form, so none is offered as a reviewed alternative.

**Historical approval record — original wording at 3109b5b:**

`docs/research/panels-2026-10/r89/r89b/owner-questions.md:28`:

> The wire rule remains the pin's unconditional **"`acknowledge_purchase` MUST be literal `true` (`API-15`, `PRV-10`)"** ([WIR-17](consistency/13-wire-contract.md#L665)). CNF-34's **"On separate creates"** and CNF-342's **"complete, valid resource-offer"** acknowledgement fixture also remain byte-identical to the pin. C′ keeps existing acknowledgement coverage on a modeled create that starts no provider billing, rather than silently exempting it. Paid-create coverage and the broader wire rule are compatible: the new API-15 says paid requests **"MUST carry"** acknowledgement, not that only paid requests must carry it. This broader wire/narrower provider layering already existed at the pin.

**Current execution guidance — Panel R r97:** CNF-34 and CNF-342’s acknowledgement paragraph are not edited by pv-9ecf: retain their complete master text at `2e2cd94637112f20538eb26b141672fedf0ba455`, including PR #60’s install-marker fixture in CNF-34. C′’s retained create coverage remains **"On separate creates"** in CNF-34 and **"complete, valid resource-offer"** in CNF-342.

`docs/research/panels-2026-10/r89/r89b/owner-questions.md:42`:

> This is additional implementation-conformance text, not a repository runtime test or permission to buy a real cloud machine. The block explicitly says **"it does not authorize sale of a live offer withheld under `PRV-13b` or `PRV-31`"**. Existing resource-offer exclusion, low-balance, replay and worker assertions remain; CNF-364 gains explicit true authorizations so removing only list_offers still reaches its intended gate. The exact form changes no Lean declaration, proof statement, guard, gate script, negative control, persistence format or check ordering. No newly proposed runtime cases have been executed.

`docs/research/panels-2026-10/r89/r89b/tally.md:28`:

> C′ differs operatively from C only by retaining WIR-17's field-rules opening, CNF-34 and CNF-342's acknowledgement paragraph. Its other blocks match C exactly.

**Drift facts:**

Compared every replacement and retained block named by C′ between its reviewed pin and the freshly fetched base. The sites below have unchanged text.

| Form site | At `3109b5b44eae17e288cf52aaa976993bd8c5626c` | At `832a2197aec28e63bd6d0bf70996171cd0dbd6f7` | Change |
|---|---|---|---|

| DOM-16 | `01-domain-model.md:570` (through 571) | `01-domain-model.md:570` (through 571) | None |
| PRV-10 | `02-provider-contract.md:159` (through 162) | `02-provider-contract.md:159` (through 162) | None |
| API-15 | `04-api-contract.md:987` (through 992) | `04-api-contract.md:987` (through 992) | None |
| configuration row | `00-overview.md:412` (through 412) | `00-overview.md:412` (through 412) | None |
| Create matrix row | `08-provider-notes.md:31` (through 31) | `08-provider-notes.md:31` (through 31) | None |
| DEF-17 historical scope paragraph | `09-known-defects.md:163` (through 165) | `09-known-defects.md:163` (through 165) | None |
| WIR-17 field rules opening | `13-wire-contract.md:665` (through 666) | `13-wire-contract.md:665` (through 666) | None |
| CNF-18 | `10-conformance-checklist.md:124` (through 135) | `10-conformance-checklist.md:124` (through 135) | None |
| CNF-19 | `10-conformance-checklist.md:137` (through 139) | `10-conformance-checklist.md:137` (through 139) | None |
| CNF-34 | `10-conformance-checklist.md:256` (through 279) | `10-conformance-checklist.md:256` (through 279) | None |
| CNF-55 | `10-conformance-checklist.md:340` (through 359) | `10-conformance-checklist.md:340` (through 359) | None |
| CNF-182 Robot test-mode case | `10-conformance-checklist.md:2371` (through 2376) | `10-conformance-checklist.md:2371` (through 2376) | None |
| CNF-342 acknowledgement paragraph | `10-conformance-checklist.md:4311` (through 4320) | `10-conformance-checklist.md:4311` (through 4320) | None |
| CNF-364 setup and retained list-offers assertions | `10-conformance-checklist.md:140` (through 154) | `10-conformance-checklist.md:140` (through 154) | None |
| CNF-344 channel declaration is no capability grant | `10-conformance-checklist.md:4358` (through 4363) | `10-conformance-checklist.md:4358` (through 4363) | None |

Read-only `git show 983a9dc52b9f72ecf34e204ad6103b85940fe996` comparison: its checklist change is in CNF-365; it touches no text C′ replaces or retains. The complete site comparisons are also recorded in `docs/research/panels-2026-10/r89/landing-drift.json`.
`````

Decoded comment UTF-8 SHA-256 (including its original terminal-LF convention): `0aa180115ac0f706860c216f60160f1068a1fcdcc7e64b5207c33daf02e54bbc`. Exact companion file: `option-pointer-agent-brief.md`. Executable form SHA-256: `c782dbfa7ec9db145f34705c699bf63d4cf544dac38f8bec1ca65243dc795a55`; exact companion `option-pointer-run-form.md`.

## Archive result

Append exactly these 695 bytes, SHA-256 `40480a93445c3699dce04eac8687193d037dec03ed46fdaa49f9773a983d55d2`, with two initial LF bytes and one terminal LF. Resulting archive SHA-256: `ebf5de10cdebba5297239ac528d6c81c61f86e5e15e7baff97f9cb5c4ae0928d`. The historical equality comparison with the untouched duplicate would fail; its original receipt still describes the original prefix. No validator or receipt is altered to hide this.

`````text


## Dated execution note — 2026-11-02, Panel R r97

The form above records exactly what Panel J and owner item 24 approved at 3109b5b; its original bytes remain unchanged. For execution in pv-9ecf, use the corrected Agent Brief comment 861 and the exact selected replacements in the [Panel R r97 record](../../../r97/notes.md). The owner’s wording precedent is “For such wording questions, try to solve by getting a consensus of the panel”. This note grants no independent authority to change an assertion, fixture or approved policy. Items 4 and 24, including the complete “Hourly cloud cases” block, retain their meaning; any substantive unresolved conflict returns to the owner.
`````

Next step after both owner answers: an apply turn makes the preparation commit on branch pv-9ecf, followed by the Run turn.
