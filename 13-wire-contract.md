# 13 — Wire contract

This document did not exist until 2026-08-12, and `F19`'s complaint stood for three audits: in
~2,600 lines there was exactly one JSON example, so every implementer would have invented a
contract and the checklist would have blessed it. Everything here is normative. Where a shape
disagrees with prose elsewhere, this document wins and the disagreement is a defect to record.

## Conventions

**WIR-1** **AMENDED.** Request and response bodies are JSON, `application/json; charset=utf-8`.
Money is an integer number of satoshis in a field suffixed `_sats` (`LDG-1`). Timestamps are
RFC 3339 UTC emitted with a `Z` suffix (never `+00:00`) at second precision; clients MUST accept
both forms. Durations chosen by callers are integer **seconds**.

Identifier types are **not** uniform, and the earlier "identifiers are UUID strings" was wrong
against `DOM-1`/`DOM-9`: machine, operation and deposit ids are UUID strings; a **tenant id**
follows `DOM-1` (1–128 chars of a wider set); a **provider account**, an **offer id** and an
**external id** are opaque provider-scoped strings; an **idempotency key** is an opaque
caller-chosen string. A field's type is whatever its defining requirement says, not UUID by
default.

**WIR-1a** **The JSON profile is I-JSON (RFC 7493) with bounded numbers.** A body MUST reject a
**duplicate object member** at any depth (not last-wins), MUST be valid UTF-8, and every JSON
number MUST be an integer within ±(2⁵³−1) with no exponent or fraction — satoshi amounts,
durations, revisions and counts are all integers, and a parser that silently rounds a large
number is a money bug. This is the profile JCS (`WIR-3`) canonicalizes within.

**WIR-2** **Unknown fields in a request body MUST be rejected** with `invalid_request` naming the
first unknown field. A tolerant reader lets a misspelled `acknowledge_destruction` pass silently
unacknowledged, and lets two implementations diverge without either noticing. Two carve-outs:
`provider_options` (`WIR-17`) is a free-form object whose interior is the driver's to validate,
not the core parser's; and **unknown query parameters are ignored**, matching `WIR-32`'s leniency
on pagination. Responses are the opposite of bodies: **clients MUST ignore unknown response
fields**, so the server can add fields without a version bump.

**WIR-3** **AMENDED.** The canonical form of a body — for idempotency comparison only — is
**RFC 8785 (JCS)** over the I-JSON of `WIR-1a`. The **idempotency fingerprint** persisted per
`(tenant, key)` (`API-12`, `API-38`, `STO-25`) is `SHA-256` of
`{uppercase method}\n{request target per WIR-5a}\n{lowercase-hex SHA-256 of the JCS body, or the
empty-body digest}`. **Method and target are part of the fingerprint**: without them, the same
idempotency key reused against a different machine or endpoint would replay the first call's
result instead of conflicting — masking or misapplying a destructive action. Any fingerprint that
is not byte-equal to the stored one, under the same `(tenant, key)`, is a `409 conflict`
(`details.reason: "idempotency_mismatch"`), never a replay. *The earlier text tied canonicalization
to a signing scheme that no longer exists (`API-39`); idempotency is now its only consumer.*

**WIR-4** **AMENDED.** Every response — success or error — carries `X-Correlation-Id` (`API-28`)
and `Access-Control-Expose-Headers: Retry-After, X-Correlation-Id`, so a browser-wasm caller can
always read the correlation id and the pacing value; every pacing value is **also** in the body
because header exposure still depends on the intermediary. A request MAY supply its own
correlation id as `X-Correlation-Id`; the server adopts it or generates one (`API-28`).
`Access-Control-Max-Age` SHOULD be at least 3600, because the `Authorization` and `Idempotency-Key`
headers force a CORS preflight per request shape (`WIR-4a`).

**WIR-4a** **The browser preflight MUST pass, and it MUST NOT be authenticated.** `Authorization`
and `Idempotency-Key` are non-safelisted, so every customer request preflights. On the
customer-facing listener the server MUST answer `OPTIONS` on every `/v1` route **before** any
authentication, with `Access-Control-Allow-Origin` per the deployment's stated origin policy
(`*` is acceptable — no cookies are used, and `Access-Control-Allow-Credentials` MUST NOT be
sent), `Vary: Origin`, `Access-Control-Allow-Methods: GET, POST, OPTIONS`, and
`Access-Control-Allow-Headers: Authorization, Content-Type, Idempotency-Key, X-Correlation-Id`.
A preflight MUST NOT be rate-limited (`API-29`) or counted against the caller's budget (`API-50`).
Without this the stated primary caller — a browser-wasm agent — cannot complete a single request,
and an auth-as-global-middleware implementation answers `401` to the preflight and locks itself
out.

## Authentication on the wire

**WIR-5** **AMENDED 2026-08-13 — one scheme, not two.** Every authenticated request carries
`Authorization: Bearer <token>` (`API-3`, `API-39`). The token is an opaque high-entropy string;
the server hashes it and compares in constant time against the stored hash — the operator token's
from the environment (`API-4`), a customer token's from the `tenants` table (`STO-21`). The token
maps to exactly one principal and an admin flag (`API-5`); nothing in the request body or path
selects the principal. *The withdrawn version specified an Ed25519 signed-request scheme for
customers; `API-39`'s reversal deleted it, and with it ~30 interoperability hazards the review had
found in the signing string. Those three requirements were swept on 2026-08-31 — the trap they
record is that an elaborate authentication scheme was guarding a non-extractable asset, and
`API-39` carries that argument in full.*

**WIR-5a** **The request target**, referenced by `WIR-3`'s fingerprint, is the origin-form path
with its query when one is present (`/v1/operations?terminal=false&limit=100`), the path alone
when none is (`/v1/machines`, never a trailing `?`). Because it now feeds only the idempotency
fingerprint and not a signature, a proxy that normalizes it is harmless as long as the server
fingerprints what it actually received; there is no cross-implementation byte-equality
requirement on it beyond that.

## The error envelope

**WIR-9** Every non-2xx response is exactly:

```json
{
  "error": {
    "kind": "insufficient_balance",
    "message": "available 41200 sats, required 72000 sats",
    "retryable": false,
    "details": {"available_sats": 41200, "required_sats": 72000},
    "correlation_id": "0198c1c2-6b7a-7d3e-9f10-2a4c6e8b0d11"
  }
}
```

`kind` is `DOM-17`'s closed set. `retryable` is normative for callers (`API-51`).

**WIR-9a** **`details` is machine-readable and its keys are defined per kind, not left to prose.**
The caller is software; routing a value through `message` (which `API-25` constrains) forces an
agent to parse English. Minimum keys:

| kind | `details` |
|---|---|
| `insufficient_balance` | `available_sats`, `required_sats` |
| `not_activated` | `activation_minimum_sats` |
| `rate_limited` | `retry_after_ms` |
| `halted` | `retry_after_ms`, `gate` (`"solvency"` \| `"rate_unavailable"`) |
| `gone` | `retained_until` — and the safe reaction is to read machines and balance, never re-issue (`DOM-21`) |
| `conflict` | `reason` (`"idempotency_mismatch"` \| `"state"` \| `"credential_already_replaced"` (`API-56`) \| `"suspension_in_flight"` (`WIR-41`) \| `"tenant_suspended"` (`API-58`) \| `"case_closed"` (`WIR-43`) \| `"signup_window_closed"` (`API-34`) \| `"deposit_already_attributed"` (`WIR-42`) \| `"cancellation_committed"` (`OPS-42`)) |
| `unsupported` | `provider_account`, `capability` (`DOM-10`) |
| `authentication` | `reason` (`"token"` \| `"unknown_principal"`) |
| `integrity` | `expected`, `observed` where disclosable (`SEC-16`) |

**WIR-9b** **`retryable` precedence.** When an error accompanies an operation view, the operation
view's `retryable` (`WIR-10`) is authoritative and the envelope's MUST equal it.
`needs_reconciliation` and `gone` are **always** `retryable: false` — re-issuing either under a
fresh idempotency key is a second purchase, not a retry (`API-51`, `OPS-20`).

## Views

**WIR-10** The **operation view** (`API-20`):

```json
{
  "id": "0198c1c2-6b7a-7d3e-9f10-2a4c6e8b0d11", "kind": "create_machine",
  "tenant": "agent-7", "status": "running", "terminal": false,
  "revision": 4, "retryable": false,
  "requested_by": "caller", "system_reason": null,
  "machine_id": null, "provider_account": "hetzner-cloud-1",
  "idempotency_key": "agent-7:create:2026-08-12T14",
  "attempts": 1, "requeues": 0,
  "committed_sats": 72000,
  "result": null, "error": null,
  "poll_after_ms": 5000,
  "created_at": "2026-08-12T14:00:11Z", "updated_at": "2026-08-12T14:00:12Z",
  "correlation_id": "0198c1c2-6b7a-7d3e-9f10-2a4c6e8b0d11"
}
```

`tenant` is required (`API-20`) and follows `DOM-1`, not UUID form. `poll_after_ms` present only
while non-terminal, mirrored by `Retry-After = ceil(poll_after_ms / 1000)` seconds (`WIR-4`,
`API-49`). `committed_sats` is present on `create`/`adopt` operations — the satoshis the
commitment reserved, so a caller reads what it spent without diffing `GET /v1/balance`.
`system_reason` non-null only when `requested_by` is `system` (`OPS-39`).

**WIR-10a** **The closed enums**, so two strict parsers agree: `kind` ∈ {`create_machine`,
`adopt_machine`, `refresh`, `rescue_inventory`, `power`, `install`, `reverse_dns`, `delete_machine`,
`suspend_tenant`}; `status` ∈ {`queued`,
`running`, `succeeded`, `failed`, `needs_reconciliation`} (`OPS-3`); `requested_by` ∈ {`caller`,
`system`, `operator`} (`OPS-39`); and **`system_reason` ∈ {`exhausted`, `late_attach_cleanup`,
`account_lost`, `tenant_suspended`, `rate_outage_bound`}, null unless `requested_by` is `system`**
(`OPS-39`, `05-persistence.md`).

*`system_reason` was added to this list on 2026-08-31. It reaches the caller in every operation
view and its value set was stated in two other documents, but this document wins over prose
elsewhere — so a strict parser had no enum for a field it receives.*

**WIR-10b** **`result` and `error` shapes.** `error`, when non-null, is exactly `WIR-9`'s inner
object (`kind`/`message`/`retryable`/`details`), without the envelope. `result`, when non-null, is
per kind and redacted (`API-22`, `DOM-18`): `create_machine`/`adopt_machine` →
`{"machine_id": "0198c1e0-3a2b-7c4d-8e9f-1b3d5f7a9c20"}`;
`install` and `rescue_inventory` → `{"inventory": {"devices": [{"identifier": "S4EVNF0N123456",
"path": "/dev/nvme0n1", "size_bytes": 1024209543168, "model": "SAMSUNG MZVL21T0HCLR",
"type": "nvme"}], "uefi": true, "inventory_fingerprint":
"b7f1c2d3e4f5a6b7c8d9e0f1a2b3c4d5e6f7a8b9c0d1e2f3a4b5c6d7e8f9a0b1"}}`
(`RSC-33`, `RSC-38`); `suspend_tenant` →
`{"cancellations": ["0198c2a0-1b2c-7d3e-8f40-5a6b7c8d9e01"]}` (`WIR-39`), one entry per machine;
`power`/`reverse_dns`/`delete_machine`/`refresh` → `{}`. An ambiguous outcome additionally records provider identifiers in `result` per `OPS-13`.

**WIR-11** The **machine view** (`CNF-176` counts this as a fixture, so a full example is given):

```json
{
  "id": "0198c1e0-3a2b-7c4d-8e9f-1b3d5f7a9c20",
  "name": "worker-1", "kind": "virtual", "state": "running",
  "region": "fsn1",
  "public_ips": ["203.0.113.7"],
  "provider_account": "hetzner-cloud-1",
  "committed_sats": 71900,
  "runway_until": "2026-09-11T14:00:00Z",
  "network_restriction": {"status": "none", "source": "provider_api", "observed_at": "2026-08-12T15:03:00Z"},
  "last_install": {"strategy": "raw_disk", "bytes_verified_by_provisiond": true, "at": "2026-08-12T14:40:00Z"},
  "rate_outage_deadline": null,
  "effective_cancellation_date": null,
  "earliest_cancellation_date": null,
  "created_at": "2026-08-12T14:03:00Z", "updated_at": "2026-08-12T15:03:00Z"
}
```

`runway_until` floats with the rate (`LDG-15`, `LDG-33`); the first `public_ips` entry is the
rescue address. `external_id` and raw provider metadata are **absent** on the customer surface
(`DOM-5`, `LDG-26`). `network_restriction` is `WIR-47`'s, and it sits **here**, beside
`runway_until`, on `LDG-15`'s reasoning: the drain and the reason for it should arrive in one
response. `last_install` is `DOM-29`'s, and is `null` on a machine nothing has installed; a client
reading `bytes_verified_by_provisiond: false` is being told this system never saw what reached the
disk, not that anything is wrong. `abuse_cases` (`WIR-43`) is absent when the machine has none.

## Endpoints

Only bodies and endpoint-specific rules are given; authentication (`WIR-5`), CORS (`WIR-4a`),
pacing, errors and idempotency are uniform per the sections above. Authenticated writes require
`Idempotency-Key` (`API-8`) and return `202` with an operation view unless listed in `API-48`.
**Enrolment is the exception**: it is unauthenticated, and it carries **no idempotency replay at
all** — an `Idempotency-Key` presented to it MUST be ignored (`API-40`, `WIR-12`). *The withdrawn
"keyed on the header alone" is a global unauthenticated key space, and the enrolment response
carries both credentials.* **Resource ids
are principal-scoped** (`WIR-36`): a lookup naming a resource outside the authenticated tenant
returns `404` and never reveals whether it exists.

**WIR-12** **AMENDED twice** `POST /v1/enrol` — unauthenticated (`API-32`), **no
`Idempotency-Key`**. Body `{}`. Response `200`, and **this is the only time either secret is ever
transmitted**:

```json
{
  "handle": "0198c1f0-4b3c-7d5e-9a0b-2c4e6a8c0e30",
  "tenant_id": "t-0198c1f0",
  "status": "not_yet",
  "issuable_at": "2026-08-13T14:30:00Z",
  "expires_at": "2026-08-16T14:00:00Z",
  "spending_token": "pvd_s_7Qk2mXbW9tR4vL8nZaC3yH6eJ1gP5dF0sK7wN2xB4uT",
  "recovery_credential": "pvd_r_3mYq8LbN5tX2vK9pZfC6yH4eJ7gR1dW0sM3wQ5xA8uV",
  "disclosures": [
    {"code": "store_both_secrets", "text": "These are shown once. Store the recovery credential where your everyday agent cannot reach it; it is the only thing that can revoke a stolen token."},
    {"code": "no_identity_recovery", "text": "Losing both is a lost balance. There is no identity to recover against and no refund."},
    {"code": "signup_expiry", "text": "An unfunded signup expires at the expires_at returned above. A credit below the activation minimum does not extend it; such a credit is retained and re-attributable, never refunded."}
  ]
}
```

Both secrets are stored **hashed only** (`STO-34`) and the token does nothing until `issuable_at`
(`API-33`). *Two withdrawn versions: the first registered a caller public key; the second minted
the token later and returned it **once** from `WIR-13`, which cannot survive a lost response — the
server marks it delivered, keeps only a hash, and a funded customer is locked out of a tenant
nobody can reach.* **Enrolment carries no idempotency replay at all** (`API-40`): the key space
was global and unauthenticated, so two callers choosing the same low-entropy key received the same
handle — and under the withdrawn model that handle was what returned the credentials.
Both secrets now arrive in the enrolment response itself (`API-33`), so `WIR-13` returns status
only; the replay rule is withdrawn regardless, because a shared handle is a shared identity. A duplicate signup is free and `API-34` reaps it;
a leaked capability is not.

**WIR-13** **AMENDED** `GET /v1/enrol/{handle}` — unauthenticated, **status only, no secrets
ever**: `{"status": "not_yet" | "pending" | "active"}`.
**`issuable_at` and `expires_at` MUST NOT appear here.** Both are returned once, in the
enrolment response (`WIR-12`), to the caller that created the signup; echoing `issuable_at` on an
unauthenticated handle-addressable endpoint hands an attacker the exact instant to start polling,
which is the timing oracle `API-33` forbids. **`expires_at` is that same oracle by another route**
and is dropped here for that reason: both instants are the signup's creation time plus a stated
constant — `API-33`'s delay and `API-34`'s time-to-live — so publishing either one yields the
other by subtraction, and the redaction was defeating itself.
No delay-derived `Retry-After` (`API-33`, `API-49`'s exception). This is how a pending tenant
observes activation (`API-52`).

**WIR-38** `POST /v1/recovery/revoke` — authenticated by the **recovery credential**, never by the
spending token (`API-56`). Body `{}`; response `200` with a fresh
`{"spending_token": "pvd_s_9Rn4pYcX2vT7kM1qZbD5wH8eJ3gL6fA0sN2xB7uV", "credential_generation": 7, "revoked_at": "2026-08-14T09:12:00Z"}`. Synchronous — a pure credential action with no
provider mutation — and added to `API-48`'s list on that basis. The tenant, its machines, its
balance and its commitments are untouched.

**`credential_generation` is the tenant's generation after this revocation** (`API-56`,
`05-persistence.md`), and it is not decoration: revocations are serialized, so a second one
invalidates the token the first minted, and a delayed first response would otherwise hand its
caller a dead token it cannot distinguish from a live one. A caller that sees a generation higher
than its own token's MUST re-revoke rather than use that token.

**WIR-39** `POST /v1/tenants/{tenant_id}/actions/suspend` — **operator-only** (`WIR-34`),
`{"acknowledge_destruction": true}`, since it cancels the tenant's fleet (`API-58`, `SEC-45`).
Returns `202` with an ordinary **operation view** of kind `suspend_tenant` (`WIR-10a`), whose
`result` is `{"cancellations": ["0198c2a0-1b2c-7d3e-8f40-5a6b7c8d9e01"]}` — one entry per machine, each an ordinary child operation
(`OPS-39`), so partial failure and `needs_reconciliation` stay visible per machine and are read
through the existing `GET /v1/operations` surface.

*No "termination record" entity is introduced.* An earlier draft returned an id for one, which had
no schema, no store and no read endpoint — the `commitments`-table gap for the fourth time. A
parent operation already has all three.

**WIR-42** `POST /v1/deposits/{id}/actions/attribute` — **operator-only** (`WIR-34`), body
`{"tenant_id": "t-0198c1f0", "operator_ref": "opref-7d41c9"}`, synchronous `200`. Credits a deposit whose tenant
was reaped (`API-34`) to a live tenant — **which MAY be `pending`**, the ordinary case since a
returning customer enrols afresh, and the credit then counts toward `API-35`'s activation minimum
like any other — **by posting one `correction` pair per settled payment** (`LDG-7`, `LDG-5`) — each a negative
entry naming the original credit it corrects and a positive one to the named tenant, keyed on that
payment's identity (`LDG-8`), all committed in one transaction under deposit-level idempotency.
**One pair is not enough**: `LDG-55` lets both destinations of a single deposit settle, producing
two original credits, and `LDG-5` requires a correction to name the entry it corrects — so a
single pair would strand one credit or lose its traceability. *A second `topup` would mint satoshis: the original payment already credited
one when it settled, so re-crediting inflates the float and breaks `LDG-17` by exactly the deposit
amount* — it is a ledger transfer, not a flag, or the money would be
attributed everywhere except the balance.

**The attribution MUST be persisted on the retained deposit** (`deposits.attributed_tenant_id`,
`05-persistence.md`, `STO-29`), and it governs every payment that settles **after** the call.
`LDG-55` keeps the other destination payable, so a deposit attributed today can settle again
tomorrow, and that later payment has no wrong credit to correct and no live tenant of its own to
find. It is credited to the attributed tenant **directly, as an ordinary `topup`** (`LDG-7`) — not
as a `correction` pair, because there is nothing to reverse: the satoshis arrived once and are
credited once, so `LDG-17` still balances. The correction pairs remain the treatment for payments
that had **already settled** when the operator called, whose credits went to the reaped tenant and
must be moved. Without the persisted target that later payment lands unattributed and needs a
second operator call to find it, which is the human-noticing step attribution exists to remove.

**`operator_ref` MUST be an opaque reference to a record kept outside this system** — a ticket id,
not a name, an email, or a transcript. *An earlier draft called it `evidence` and described it as
the operator's record of why it believed the claimant, which invites exactly the identifying and
contact data `ADR-0005` and `STO-21` categorically prohibit — and this endpoint is synchronous, so
no terminal-state purge would ever remove it.* Attribution MUST be idempotent per deposit: a
second call naming a different tenant is `409`, never a re-credit.

**WIR-41** `POST /v1/tenants/{tenant_id}/actions/resume` — **operator-only**, body `{}`,
**synchronous** `200` with the tenant's status: it clears the suspension flag and touches no
provider, so it mints no operation and is in `API-48`'s list. It does **not** restore cancelled
machines; those are gone (`OPS-39`), and the tenant's balance and ledger are untouched throughout.

**Resume MUST be refused while the tenant's `suspend_tenant` parent is unsettled** — `409`
`conflict` with `details.reason: "suspension_in_flight"` (`WIR-9a`). `API-58` requires that parent
to keep re-sweeping until a pass finds no un-cancelled machine, so clearing the flag under a live
fan-out lets a machine the tenant legitimately created *after* the resume be discovered by the
still-running sweep and cancelled — the tenant is un-suspended and its new machines die anyway,
for a reason nothing in the record explains. **The parent operation's own state is the fence**, so
no generation counter is introduced — the record that says whether the fan-out is still running
already exists. The operator retries the resume once
that operation settles, which it does without assistance — `API-58` forbids it ending in
`needs_reconciliation` or requiring an operator — and follows it through
`GET /v1/operations` (`WIR-39` returns its id).

**WIR-14** `POST /v1/deposits` (`API-43`, `API-44`) — body: `{"amount_sats": 250000}`.
Response `200`:

```json
{
  "id": "0198c1d0-5c4d-7e6f-8a1b-3d5f7a9c1e40",
  "requested_sats": 250000,
  "activation_minimum_sats": 100000,
  "expires_at": "2026-08-13T14:00:00Z",
  "lightning": {"invoice": "lnbc2500u1pnq7x8xpp5qqqsyqcyq5rqwzqfqqqsyqcyq5rqwzqfqqqsyqcyq5rqwzqfqypqdq5w3jhxapqd9h8vmmfvdjscqzzsxqyz5vq", "floor_sats": 1000, "enforced": true},
  "onchain":   {"address": "bc1qexampleaddressxxxxxxxxxxxxxxxxxxxxxxxxxx", "floor_sats": 20000, "enforced": false},
  "disclosures": [
    {"code": "onchain_expiry_unwatched", "text": "After expires_at the address stays payable but is no longer watched; funds sent after expiry may be lost."},
    {"code": "double_pay_no_refund", "text": "Paying both destinations credits both. Nothing is refundable, ever."},
    {"code": "below_activation_minimum", "text": "A credited balance below activation_minimum_sats leaves the tenant pending and is not refundable."},
    {"code": "orphan_recovery_is_operator_only", "text": "If your signup expires before you fund it, a credit already received is retained but can only be re-attributed by contacting the operator with this deposit id. There is no self-serve recovery, because we store nothing that identifies you."}
  ]
}
```

`enforced` states which expiry is a mechanism and which a promise (`LDG-54`); the Lightning
invoice's own embedded expiry MUST equal `expires_at`. Both rails carry a `floor_sats` (`LDG-52`).
`activation_minimum_sats` is the threshold below which a paid balance still cannot activate
(`API-35`, `LDG-44`) — disclosed so an agent never sends unrefundable money below it blind. Each
`disclosures` entry carries a machine-readable `code` and human `text` (`CNF-131`).

**WIR-15** `GET /v1/deposits/{id}` — the same body plus
`"credits": [{"rail": "lightning", "amount_sats": 250000, "credited_at": "2026-08-13T14:07:31Z"}]` (one entry per
settled payment, `LDG-55` — plural on purpose), `"credited_sats"` (their sum), and
`"expired": false`.

**WIR-16** **AMENDED** `GET /v1/balance` (`API-47`):

```json
{
  "balance_sats": 322000,
  "available_sats": 250000,
  "committed_sats": 72000,
  "commitments": [
    {"machine_id": "0198c1e0-3a2b-7c4d-8e9f-1b3d5f7a9c20", "operation_id": null, "reserved_sats": 71900, "runway_until": "2026-09-11T14:00:00Z"},
    {"machine_id": null, "operation_id": "0198c1c2-6b7a-7d3e-9f10-2a4c6e8b0d11", "reserved_sats": 100, "runway_until": null}
  ],
  "earliest_runway_until": "2026-09-11T14:00:00Z"
}
```

**AMENDED 2026-08-31 — the `commitments` array is opt-in.** `GET /v1/balance` returns the three
totals and `earliest_runway_until` by default; the per-commitment array appears only with
`?commitments=true` and is then cursor-paginated like every other collection (`WIR-32`). Every other
list in this contract is clamped to 200 and this one was unbounded, on the endpoint `API-49`
deliberately steers agents to poll at the finest advertised cadence — so a five-hundred-machine
tenant shipped five hundred entries on every poll, forever. The invariant below is checkable on the
full opt-in listing, where it means something, rather than on a truncated page, where it never
holds.

A commitment entry carries **both** `machine_id` and `operation_id`, either of which may be null:
an in-flight create opens its commitment (`LDG-11`) before any machine exists, so it is named by
`operation_id` with a null `machine_id` — and the invariant `committed_sats == Σ reserved_sats`
and `available_sats == balance_sats − committed_sats` (`LDG-9`) hold only because such entries are
included. `earliest_runway_until` is the minimum non-null `runway_until` over all non-deleted
billable machines including `cancellation_scheduled`, and is `null` when there are none.

**WIR-17** **AMENDED** `POST /v1/machines` — create:

```json
{
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
}
```

`ssh_public_keys` MUST be non-empty (`PRV-8`, `API-13`). `acknowledge_purchase` MUST be literal
`true` (`API-15`, `PRV-10`). `image` (nullable, a catalog identifier), `user_data` (nullable,
≤1 MiB, `API-13`) and `labels` (string→string; the correlator's reserved key is the driver's, `PRV-26`, and a caller
label colliding with it MUST be rejected, `OPS-38`) are the create inputs
the other requirements accept and this body previously omitted — under `WIR-2` a conforming server
would otherwise reject them. `runway_seconds` is `PRV-13d`'s caller-chosen runway; a value **below**
the wind-down floor MUST be **rejected** `invalid_request` with `details.min_runway_seconds`, never
silently raised — silently reserving more of a caller's money than it asked for is a money bug.
`max_commitment_sats` (optional) caps spend: if the computed commitment exceeds it the request
fails `invalid_request` (not `insufficient_balance`) **before** any commitment opens, so an agent
can bound a purchase priced at an attacker-influenceable rate (`LDG-41`).

**WIR-18** `POST /v1/machines/adopt` — **operator-only** (`API-18`, `WIR-34`): bearer auth, body
`{"tenant_id": "t-0198c1f0", "provider_account": "hetzner-robot-1", "external_id": "2345678",
"runway_seconds": 2592000,
"acknowledge_purchase": true}`. A customer-authenticated request to this route returns `404`
(`WIR-34`), not `authentication` — its existence is not customer-observable.

**WIR-19** `POST /v1/machines/{id}/actions/power` — `{"action": "on" | "off" | "reboot" |
"hard_reset"}`. The last requires the `hard_reset` capability (`DOM-10`).

**WIR-20** **AMENDED — the install body is a closed discriminated union, one variant per `DOM-13`
pairing, and it carries every field the rescue engine needs from the caller.** The withdrawn body
showed only `rootfs_via_rescue` and omitted the raw-disk target device (`RSC-26`), the host-key
trust decision (`RSC-3`/`RSC-4`), the layout (`RSC-22`) and the installed keys (`RSC-13`) — so
three of four strategies were unsendable and the security-critical trust choice had no field.

Common to every variant: `acknowledge_destruction: true` (`API-14`) and `on_failure` ∈
{`exit_rescue` (**default**), `leave_in_rescue`}. **The two rescue-entering variants —
`rootfs_via_rescue` and `raw_disk` — additionally carry a required `trust` object**, exactly one of
three, not two. `provider_native` enters no rescue and has no host key to pin, so it carries none —
and a `provider_native` body that supplies one is an unknown field for that variant, rejected
`invalid_request` by `WIR-2` (its row below):

| `trust` | Meaning |
|---|---|
| `{"use_provider_keys": true}` | Pin the host keys the driver publishes at rescue activation. **Abort `integrity` if none appear** before `RSC-9`'s deadline |
| `{"expected_host_keys": ["ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIhostkeyxxxxxxxxxxxxxxxxxxxxxxxx"]}` | Pin caller-supplied keys (`RSC-3`) |
| `{"accept_unpinned": true}` | First-use trust, the explicit per-request opt-in `SEC-22` requires |

**The provider-keys variant was missing and its absence was a silent security downgrade.** It is
`RSC-3`'s *strongest* row and the only one reachable on Hetzner Robot, where rescue host keys are
published at activation and a customer cannot know them out of band (`08-provider-notes.md`). With
only two variants, every install on the flagship product had to declare `accept_unpinned` — the
security-critical decision in the whole workflow, downgraded by a body schema. Per variant:

```json
{ "strategy": "rootfs_via_rescue",
  "source": {"type": "rootfs_tarball", "url": "https://images.example.net/debian-12-amd64.tar.zst", "sha256": "3b1f2c9a5d7e4082b6c1d3e5f7a90b2c4d6e8f0a1b3c5d7e9f0a2b4c6d8e0f13", "format": "zstd"},
  "authorized_keys": ["ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIexamplekeyxxxxxxxxxxxxxxxxxxxxxxxx"],
  "layout": { "drives": [{"identifier": "S4EVNF0N123456"}], "inventory_fingerprint": "b7f1c2d3e4f5a6b7c8d9e0f1a2b3c4d5e6f7a8b9c0d1e2f3a4b5c6d7e8f9a0b1", "raid": {"enabled": false, "level": null}, "partitions": [{"mount": "/boot", "size": "1G", "fs": "ext3"}, {"mount": "/", "size": "all", "fs": "ext4"}], "bootloader": "grub" },
  "post_install_script": null,
  "trust": {"use_provider_keys": true},
  "on_failure": "exit_rescue",
  "acknowledge_destruction": true }
```

- `raw_disk`: `source.type` `raw_disk` (`url`, `sha256`, `compression` ∈ {`none`, `gzip`, `xz`,
  `zstd`, `bzip2`}), a required **`target`** object — `{"identifier": "S4EVNF0N123456",
  "inventory_fingerprint": "b7f1c2d3e4f5a6b7c8d9e0f1a2b3c4d5e6f7a8b9c0d1e2f3a4b5c6d7e8f9a0b1"}`,
  where `identifier` is a drive serial or WWN and the fingerprint is the one `RSC-38`'s rescue
  inventory returned — **not a device path** (`RSC-26`) —
  optional `grow_partition` (boolean, default `false`, `RSC-31`), and no `authorized_keys`
  (`RSC-14` forbids injecting into an opaque image).
- `provider_native`: `source.type` is `catalog` (`image`); no `layout`, no `trust` (no rescue is
  entered); it MAY carry `authorized_keys`.

**Every `layout.drives[].identifier` is validated exactly as `raw_disk`'s `target.identifier`
is** (`RSC-26`): resolved against a freshly re-read inventory, matched to exactly one device, and
aborted `integrity` before any write on zero or multiple matches. A rootfs install partitions
disks, so naming them by unstable path destroys the same data.

`rootfs_tarball` and `raw_disk` `sha256` are required and exactly 64 hex (`DOM-14`); `catalog`
carries no digest — this system does not touch those bytes (`SEC-16`). A `url`
subject to `OPS-40`'s two validity gates fails `invalid_request` with `details.url_expires_at`
when it cannot outlive the install.

**WIR-21** `POST /v1/machines/{id}/actions/reverse-dns` — `{"ip": "203.0.113.7", "ptr":
"mail.example.org"}`; `"ptr": null` clears the record. The `ip` MUST be one of the machine's
assigned addresses.

**WIR-22** `POST /v1/machines/{id}/actions/delete` — `{"acknowledge_destruction": true}`.

**WIR-23** `POST /v1/machines/{id}/actions/refresh` — body `{}`.

**WIR-24** **AMENDED** `POST /v1/machines/{id}/actions/extend-runway` —
`{"additional_seconds": 604800, "max_commitment_sats": 90000}`. `LDG-62`'s action; **no provider
mutation**, so synchronous: `200` with the updated machine view, its commitment increased at the
current rate in the same transaction as the authorization check. Because the response is not an
operation, its durable idempotency is explicit: **the commitment change and an idempotency record
(fingerprint, status, the exact response body) MUST commit in one transaction**, so a replay of
the same `(tenant, Idempotency-Key)` returns the stored body and reserves nothing again; a
different fingerprint under that key is `409` (`API-11`, `STO-25`). `API-48`'s closed list is
AMENDED to include it — recorded there.

**WIR-25** `GET /v1/machines`, `GET /v1/machines/{id}` — machine views; the list is
cursor-paginated (`WIR-32`): `{"machines": [], "next_cursor": null}`. The example shows an empty
page; each element is `WIR-11`'s machine view, elided here rather than placeheld (`WIR-37`).

**WIR-26** `GET /v1/operations?terminal=false&status=queued,running&limit=100&cursor=b3AtY3Vyc29yLTAxOThjMWUw` — the fleet poll
(`API-49`): `{"operations": [], "next_cursor": null, "poll_after_ms": 5000}`, each element
`WIR-10`'s operation view and elided on the same terms. `terminal=false`
MUST be supported; `status` accepts a comma-separated set; `terminal` and `status` combine as an
intersection, and an empty intersection is an empty page, not an error. The list-level
`poll_after_ms` governs the fleet poll; a single-operation poll obeys that operation's own value
(`WIR-10`).

**WIR-27** `GET /v1/operations/{id}` — one operation view. Past retention: `410` with kind
`gone`, `details.retained_until` (`DOM-21`).

**WIR-28** **AMENDED** `POST /v1/operations/{id}/actions/requeue` — **operator-only** (`API-19`,
`WIR-34`), body `{"reason": "order confirmed lost at the provider", "acknowledge_duplicate_purchase": true, "request": {}}`
(`OPS-34`), where `request` is elided in this example and carries a fresh payload in the original
endpoint's shape — the create body of `WIR-17`, the install body of `WIR-20`, and so on. The system
verifies the fresh payload against the stored summary and refuses on any mismatch. `acknowledge_duplicate_purchase` MUST be
literal `true` when the operation's kind places an order — the fresh payload's own
`acknowledge_purchase` does **not** satisfy `OPS-20`'s "second, distinct" acknowledgement, because
requeueing a create is a purchase decision, not a retry.

**WIR-35** `POST /v1/operations/{id}/actions/resolve` — **operator-only** (`API-19`, `WIR-34`),
the reconciliation verbs `OPS-31` mandates and no endpoint carried (this was the operator half of
`F19`). Body is a discriminated union: `{"resolution": "observed", "external_id": "2345678",
"kept_duplicate": "2345679", "operator_ref": "opref-7d41c9"}` attaches a discovered resource
(`OPS-27`);
`{"resolution": "absent", "operator_ref": "opref-7d41ca"}` records that nothing was created and releases
the commitment (`LDG-32`); `{"resolution": "abandoned", "operator_ref": "opref-7d41cb"}` gives up.
**`operator_ref` carries the same constraint as `WIR-42`'s**: an opaque reference to a record kept
outside this system, never a name, address or contact string (`ADR-0005`, `STO-21`). *The
reviewers flagged the field on `WIR-42`; it was here too, and an operation record is retained
under `OPS-25` long enough for it to matter.* `external_id` is
required for `observed`. It is distinct from requeue and is the only road out of the unresolved
row (`OPS-33`). **Synchronous** — it records an operator decision against an existing operation
and mints no provider mutation — returning `200` with the updated operation view, under
`API-48`'s exemption and `STO-35`'s idempotency record. Minting an operation *about* an operation
is a recursion `API-1` never intended.

**WIR-40** **RENAMED 2026-08-31** `POST /v1/machines/{id}/actions/rescue-inventory` — `RSC-38`'s
inventory pass. Body
carries the same **`trust`** object as an install (`WIR-20`), plus the same `on_failure` ∈
{`exit_rescue` (**default**), `leave_in_rescue`}, and nothing else. It enters rescue over
SSH, so it faces the identical host-key decision — an empty body could express neither a pinned
key nor the explicit unpinned opt-in `SEC-22` requires, making it unusable on a strict driver or a
silent trust downgrade on a lax one — and it faces the identical *exit* decision: a run that
fails partway has left the machine in rescue, and without this field the machine's state after a
failed run is unspecified. `PRV-22` makes the rescue exit itself always ambiguous, so
`exit_rescue` is the default and `leave_in_rescue` is the caller keeping the session for
investigation.

It returns `202` and an operation whose result carries the device inventory with **stable
identifiers** and the `inventory_fingerprint` an install must echo back (`WIR-20`, `RSC-26`). It
enters and exits rescue and writes nothing. This exists because a caller previously had no way to
see the disk inventory *before* committing to a destructive write — the information arrived
attached to the result of the operation that had already destroyed the disk.

**WIR-29** `GET /v1/providers` — customer auth returns only the accounts assigned to the tenant
(`DOM-3`, `API-17b`); operator auth returns all configured accounts.
`{"providers": [{"account": "hetzner-robot-1", "kind": "hetzner_robot", "allow_orders": true,
"capabilities": ["provision_bare_metal", "rescue_ssh", "list_offers"]}]}` (`OVR-2`, `DOM-16`,
`DOM-22`).

**WIR-30** **AMENDED** `GET /v1/providers/{account}/offers` — customer prices only (`LDG-26`), an
unassigned account `404`s (`WIR-36`):

```json
{"offers": [{
  "id": "standard:cx32", "name": "CX32", "kind": "virtual", "regions": ["fsn1"],
  "recurring_price": {"amount_sats": 120, "period": "hour"},
  "setup_fee_sats": 0,
  "min_runway_seconds": 3600,
  "quoted_at": "2026-08-13T14:00:00Z", "binding": false,
  "max_rate_outage_seconds": 21600,
  "install_strategies": ["provider_native", "raw_disk"],
  "max_image_bytes": 107374182400,
  "guest_requirements": null
}]}
```

**`install_strategies` is the offer's subset of `DOM-13`'s strategies, and it gates them.** The
account's `capabilities` (`WIR-29`) say what the driver can do at all; eligibility for a
rescue-based install is a property of the **offer**, because an auction listing and a standard
product at the same provider can differ on it. The fixture above is a cloud VPS, which is why it
omits `rootfs_via_rescue`: no cloud product in the reference set offers one
(`08-provider-notes.md`). An install naming a strategy absent from its
machine's recorded list MUST be rejected as `invalid_request` before the operation is enqueued,
exactly as an invalid pairing is. The list MUST be present on every offer; an empty list means no
install is available for that offer. **The gate reads the copy the machine took at create —
`machines.install_strategies` (`05-persistence.md`) — not the offer as it stands at install time**,
because an offer is a live listing that can change or disappear between the two, and re-resolving
it either fails an install on a machine that is running and paid for or answers from terms its
owner never bought. `offer_id` remains the provenance record of which offer that copy came from.
An **adopted** machine has no offer to copy from, so **adoption derives and persists a list of its
own** — empty where it cannot establish one, refusing every strategy. It does **not** fall back to
the provider account's declared capabilities (`DOM-10`): capabilities are per account and eligibility
is per product, so the account of an operator who runs one rescue-capable box would authorize a
disk-wiping install on an adopted machine that cannot take one (`05-persistence.md`).

`max_image_bytes` is `RSC-40`'s enforced ceiling on a caller-supplied image, checked against the
stream and aborting the transfer when exceeded; it is the only thing about the image provisiond
checks, because interpreting the content would put a parser for hostile binary inside the
credential-holding process. `guest_requirements` is **prose** the caller relays to whoever built
the image — null where the strategy imposes none, and non-null for `provider_catalogue`, where the
provider converts and boots the image and its own rules decide whether the machine comes up at all
(`RSC-43`). Prose deliberately: an agent can compute against a byte count and cannot compute
against "cloud-init configured with the correct datasource order", which only the image's author
can guarantee. *Structured what the agent must compute, prose what it must understand.*

`max_rate_outage_seconds` is `LDG-64`'s bound, disclosed before purchase because past it a
machine is cancelled regardless of its runway. Prices are integers of satoshis, already margined by
the one pricing function (`LDG-23`, `LDG-24`)
at the same rounding as commitment creation. **An offer price is an indicative quote converted at
read time; `binding` is `false` and the commitment is priced at accept time (`LDG-27`) and MAY
differ** — a caller bounding spend uses `WIR-17`'s `max_commitment_sats`, not the quote. The
provider's currency, price string and raw metadata MUST NOT appear.

**WIR-31** `GET /healthz` — `200 {"status": "ok"}`, unauthenticated but rate-limited (`API-29`),
and MUST NOT disclose version, uptime, queue depth or anything else a caller can fingerprint.

**WIR-43** `GET /v1/abuse-cases`, `GET /v1/abuse-cases/{id}` and
`POST /v1/abuse-cases/{id}/statements` (`API-59`, `DOM-23`) — customer-facing, **synchronous**,
minting no operation (`API-48`). `GET /v1/abuse-cases` is cursor-paginated like every other
collection (`WIR-32`) and takes **`?state=open|closed|all`, defaulting to `open`**.

**An unrecognised `state` value is `invalid_request`, not ignored.** This is the one documented
exception to `WIR-2`'s rule that unknown query parameters are ignored, and it is narrow on purpose:
`DOM-24` requires the collection to return closed cases on request, because closing is the only
signal an autonomous caller gets that it may stop polling. Silently returning the open set to a
caller that asked for the closed one answers the wrong question with a `200`, which is the failure
mode `WIR-2`'s leniency cannot distinguish from success.

**One projection, rendered in three places, and statements are not part of it.** The case summary —
every field below except `statements` — is what the collection returns, what the machine view
embeds, and what the detail read carries; the detail read alone adds `statements`. The machine view
embeds `abuse_cases` as an **array** of summaries, not a single object: two notices about one
machine are two cases (`STO-39`), and a singular field would have to pick one. Keeping the
statement history out of the machine and collection reads also stops an unbounded append-only list
being materialised by every poll of an unrelated machine. **The key is omitted entirely when the
machine has no case**, which is why `WIR-11`'s machine fixture does not carry it — stated here
because `WIR-37` requires an elision to be described in prose rather than left to inference. A case
detail read:

```json
{
  "id": "0198c1d0-7a2b-7c3d-8e4f-5a6b7c8d9e01",
  "machine_id": "0198c1d0-1234-7abc-8def-0123456789ab",
  "state": "open",
  "allegation": "A third party reports SSH brute-force attempts originating from this machine's public address on 2026-08-12 at about 21:40 UTC.",
  "warned_consequence": "If this is not resolved, the provider may block this machine's network access.",
  "respond_by": "2026-08-13T12:00:00Z",
  "opened_at": "2026-08-12T23:10:00Z",
  "statements": [
    {"id": "0198c1d0-9f8e-7d6c-8b5a-4938271605f4", "seq": 1, "submitted_at": "2026-08-13T02:15:00Z", "body": "A container image we deployed was compromised. We stopped it at 02:05 UTC and rotated the host keys."}
  ],
  "outcome": null
}
```

A submission is `{"body": "..."}` and nothing else, and returns **`201`** with the created statement
(`id`, `seq`, `submitted_at`) so the caller can tell a retry from a second reply. **The body MUST be
capped at a stated size** (4096 bytes is the deployment default) and is stored verbatim,
uninspected: pattern-scrubbing free text is unreliable, untestable, and mangles legitimate replies.
`ADR-0005`'s exposure is bounded instead by `STO-42`'s purge and by `WIR-44`'s rule on what may
leave. Submitting is refused with `409` `conflict`, `details.reason: "case_closed"`, once the case
is `closed`. After the purge, a redacted statement renders with `"body": null` and its timing
intact.

**Like every other write, a submission carries `Idempotency-Key` (`API-8`), and because the
response is not an operation its durable idempotency is explicit**: the statement row and an
idempotency record (fingerprint, status, the exact response body) MUST commit in one transaction —
`WIR-24`'s rule, adopted by reference rather than restated, and required here for a sharper reason
than usual. A retried submission that is not deduplicated appends a **second permanent statement**
to a list `STO-40` forbids anyone to delete, and the caller is an autonomous agent with a retry
loop.

**The provider's case reference, statement link, wording, and the parties it named do not appear
here** (`WIR-45`). `allegation`, `consequence` and `outcome` are the operator's own prose
(`DOM-23`). *This does not conceal which provider hosts the machine: `provider_account` is already
in the machine view (`WIR-11`) and `WIR-29` returns the account kind. An earlier draft said
"nothing in this view names the provider — not the company", which contradicted both and tested as
`CNF-224`.*

**WIR-44** `POST /v1/abuse-cases`, `.../actions/close` and `.../actions/record-transmission` —
**operator-only** (`WIR-34`), **synchronous**, each carrying `Idempotency-Key` under `WIR-24`'s
one-transaction rule. Open takes a `machine_id` — resolved first through `WIR-46` where the notice
gives an address rather than a machine — together with the operator's `allegation`, `consequence`
and `respond_by`, and returns `201` with the case. Close takes an `outcome`, returns `200` with the
closed case, and **purges the statement bodies in the same transaction** that sets `state`,
`outcome` and `closed_at` (`STO-42`); a close that commits before the purge leaves raw text behind
a case that reports itself closed.

**The operator reads cases through `WIR-33`'s tenant override** on the customer routes, which is
how every other operator read of tenant-scoped data works. No separate operator collection is
specified, and the cost is real: there is no cross-tenant "which cases are awaiting me" list, so an
operator tracks outstanding notices the way it learned about them — in its inbox.

**Transmission MUST be recorded as an explicit act**, because forwarding a tenant's words verbatim
is the operator's per-case decision (`ADR-0012`) and a decision that leaves no trace is one the
conformance checklist cannot test:

```json
{"sent_verbatim": false, "statement_ids": ["0198c1d0-9f8e-7d6c-8b5a-4938271605f4"], "sent_statement": "A container image the customer deployed was compromised. It was stopped at 02:05 UTC and host keys were rotated."}
```

Recording transmission returns `200` with the updated case, as close does. **`sent_verbatim: true`
means `sent_statement` is byte-for-byte one of the named statements.** The
fixture above is the composed case, and it is composed precisely because the tenant's own text says
*"we deployed"* and *"we stopped it"* — first person, about a customer the operator must not
name to a third party. *An earlier version of this fixture carried the same rewritten prose under
`sent_verbatim: true`, which is the flag asserting the opposite of what the example showed.*

**Composing is the default and `sent_verbatim: true` is the exception**, never the absence of a
field. The record is visible to the tenant in its own case: they are the tenant's words, and a
customer is entitled to know which of them were repeated to a third party.

**WIR-45** **The provider's case reference, statement link, own wording, and any third party it
named MUST NOT appear on the customer surface** — not in a field, not in prose, not in an error
`details`, not in a log line a customer can read. This is `WIR-30` and `LDG-26`'s rule (provider
price, currency and raw metadata never reach a customer) applied to the one remaining inbound
channel, and it is stricter than either, because the statement link is a **single-use bearer
credential whose use concludes the operator's deadline**: handed to an autonomous caller, a poll
loop ends the operator's window in the first second, with no human ever deciding to answer.
`SEC-39`'s reasoning — a control that assumes a human reading it is not a control — arriving at a
new surface.

**This bans the notice, not the provider.** Which provider account hosts a machine is already
customer-visible (`WIR-11`'s `provider_account`, `WIR-29`'s `kind`), and a rule that tried to
conceal it would contradict two shipped fixtures while protecting nothing — the hazard is the
bearer link and the third parties, not the company's existence.

**WIR-46** `GET /v1/address-resolution?address={address}&observed_at={timestamp}` — **operator-only**
(`WIR-34`), synchronous, `SEC-54`'s answer on the wire. `address` is normalised to `STO-41`'s
canonical form before matching and an unparseable one is `invalid_request`; `observed_at` is an
`WIR-1a` timestamp.

```json
{
  "address": "203.0.113.7",
  "observed_at": "2026-08-12T21:40:00Z",
  "candidates": [
    {"machine_id": "0198c1d0-1234-7abc-8def-0123456789ab", "tenant_id": "t-0198c1f0", "first_seen": "2026-08-04T09:12:00Z", "last_seen": "2026-08-12T22:00:00Z", "machine_state": "deleted"}
  ],
  "horizon_start": "2026-05-16T00:00:00Z"
}
```

**`candidates` is ordered by `first_seen` ascending and MAY be empty or hold several** — that is
the point of `SEC-54`, and a client MUST NOT treat a single-element array as certainty. Each entry
carries the observation window it matched on, so the operator can see how tightly the instant is
bracketed. `horizon_start` is the oldest instant this deployment can answer for (`STO-43`); an
`observed_at` before it returns an empty `candidates` **and** an explicit
`"out_of_horizon": true`, because "we have no record" and "it was nobody's" are different answers
and only one of them means the machine was not ours.

**WIR-47** `POST /v1/machines/{id}/actions/record-network-restriction` and
`POST /v1/abuse-cases/{id}/actions/revise-deadline` — **operator-only** (`WIR-34`), **synchronous**,
minting no operation (`API-61`), each carrying `Idempotency-Key` under `WIR-24`'s
one-transaction rule.

Recording a restriction takes `{"status": "disabled", "observed_at": "2026-08-13T02:40:00Z"}` and
returns `200` with the machine view. It sets `source` to `operator_notice` and **MUST be refused
with `409` `conflict`, `details.reason: "state"`, where the driver reports this provider**
(`PRV-35`) — the provider is authoritative there, and an operator value that shadows a readable
fact is the two-homes drift this design was reorganised to avoid.

Revising a deadline takes `{"respond_by": "2026-08-20T12:00:00Z"}` and returns `200` with the case,
appending the previous value (`STO-44`). It is refused with `409` `conflict`,
`details.reason: "case_closed"`, on a closed case. **There is no verb that rewrites
`warned_consequence`**, and its absence is the design (`STO-44`).

The machine view's `network_restriction` object is `{"status", "source", "observed_at"}`
(`DOM-27`), and it renders `"status": "unknown"` with a null `observed_at` where nobody has looked.
**A client MUST NOT read `unknown` as `none`.** The same object is joined into the case projection
at render time from the machine — never copied into `abuse_cases`, which is what keeps two open
cases from carrying two answers.

**WIR-48** `POST /v1/tenants/{tenant_id}/actions/assign-provider-account` — **operator-only**
(`WIR-34`), **synchronous** `200`, minting no operation (`API-62`), carrying `Idempotency-Key` under
`WIR-24`'s one-transaction rule. Body
`{"provider_account": "hetzner-cloud-2", "mode": "add", "operator_ref": "opref-7d41d0"}`, where
`mode` ∈ {`add`, `replace`} and `replace` removes every current assignment. Returns the tenant's
assignment list as `WIR-29` would render it.

`operator_ref` carries the same constraint as `WIR-42`'s and `WIR-35`'s: an opaque reference to a
record kept outside this system, never a name, address or contact string (`ADR-0005`, `STO-21`).

**Naming an account the deployment does not have configured is `invalid_request`**; naming one not
flagged assignable is `conflict` with `details.reason: "state"`. Assigning a tenant to an account
that `SEC-46` has recorded as confirmed-terminated is also `conflict` — the failure this verb exists
to repair should not be reachable by using it.

## Listeners, limits and fixtures

**WIR-34** **Operator-only routes** (`WIR-18` adopt, `WIR-28` requeue, `WIR-35` resolve, `WIR-39`
suspend, `WIR-41` resume, `WIR-42` attribute, `WIR-44`'s three abuse-case verbs, `WIR-46`
address-resolution, `WIR-47`'s record-network-restriction and revise-deadline, `WIR-48`
assign-provider-account, and the operator forms of `WIR-29`/`WIR-30`) MUST be served only on the operator listener (`API-27`), MUST NOT carry the
customer CORS headers of `WIR-4a`, and MUST return `404` — never `authentication` — to a
customer-authenticated request, so their existence is not customer-observable.

**The `404` is method-scoped where a path is split across listeners.** `/v1/abuse-cases` is the
first such path — customer `GET`, operator `POST` — so a customer `POST` there is `404`, not `405`,
and the customer `GET` is unaffected. *Enumerated rather than left to inference: this list is read
as closed, which is why the abuse routes are named in it rather than assumed to inherit.*

**WIR-33** **The tenant-override header is `X-Provisiond-Tenant`** (a `DOM-1` tenant id). It is
honoured only with an operator bearer token holding the admin flag (`API-5`); presented by a
customer token it is **ignored, not rejected** (`API-6`). It never appears on the customer
listener's allow-list (`WIR-4a`).

**WIR-32** **AMENDED** `API-26`'s "sane range" — applied to **every** cursor-paginated endpoint,
machines and operations alike: `limit` clamped to **1–200, default 50**. An out-of-range integer
is clamped; a `limit` that is not a base-10 integer is `invalid_request`. Cursors are opaque and
principal-scoped (`WIR-36`); a cursor from another tenant is `invalid_request`, never honoured.

**WIR-36** **Every resource id is principal-scoped.** A machine, operation, deposit or enrolment
handle that does not belong to the authenticated principal (or the override tenant of `WIR-33`)
returns `404`, identical to a nonexistent id — the unguessability of a UUID is not authorization
(`API-17a`). An admin override keys on the **effective** tenant, so flipping it cannot hand a
caller another tenant's cursor or resource.

**WIR-37** **Fixtures are complete and valid** (`CNF-176`): every JSON example in this document
parses under `WIR-1a` with real-shaped values — full UUIDs, `Z`-suffixed timestamps, 64-hex
digests — so the examples are test inputs, not illustrations. Placeholder `...` inside an object
is prohibited; where a sub-object is elided the example says so in prose outside the JSON.
