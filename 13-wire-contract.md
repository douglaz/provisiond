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
customers (`WIR-6`–`WIR-8`); `API-39`'s reversal deleted it, and with it ~30 interoperability
hazards the review had found in the signing string.*

**WIR-5a** **The request target**, referenced by `WIR-3`'s fingerprint, is the origin-form path
with its query when one is present (`/v1/operations?terminal=false&limit=100`), the path alone
when none is (`/v1/machines`, never a trailing `?`). Because it now feeds only the idempotency
fingerprint and not a signature, a proxy that normalizes it is harmless as long as the server
fingerprints what it actually received; there is no cross-implementation byte-equality
requirement on it beyond that.

**WIR-6** **WITHDRAWN 2026-08-13.** Was the Ed25519 signed byte string. Customer auth is a bearer
token (`API-39`); there is no signed request, no timestamp header, no canonical signing target.
The panel's findings against this requirement — deployment binding, path canonicalization, body
malleability, Ed25519 strictness — are moot because the construct is gone.

**WIR-7** **WITHDRAWN 2026-08-13.** Was clock-skew tolerance for the signature timestamp. No
timestamp is signed. **TLS remains the confidentiality layer** (`API-27`); a bearer token is a
secret in transit and MUST NOT appear in a URL, a log line, or an operation record (`SEC-3`,
`API-25`).

**WIR-8** **WITHDRAWN 2026-08-13 — superseded, not deleted.** Was Ed25519 key rotation. There are
no customer keys; **credential replacement is `WIR-38`**, authorized by the recovery credential
(`API-55`, `API-56`). *An intermediate version of this requirement said rotation was out of v1
scope because a stolen credential "cannot extract value" — that reasoning was wrong. A customer
credential authorizes `install` and `delete`, so theft costs data and machines, not just balance.*

## The error envelope

**WIR-9** Every non-2xx response is exactly:

```json
{
  "error": {
    "kind": "insufficient_balance",
    "message": "available 41200 sats, required 72000 sats",
    "retryable": false,
    "details": {"available_sats": 41200, "required_sats": 72000},
    "correlation_id": "0198c1c2-..."
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
| `conflict` | `reason` (`"idempotency_mismatch"` \| `"state"`) |
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
`adopt_machine`, `refresh`, `preflight`, `power`, `install`, `reverse_dns`, `delete_machine`}; `status` ∈ {`queued`,
`running`, `succeeded`, `failed`, `needs_reconciliation`} (`OPS-3`); `requested_by` ∈ {`caller`,
`system`, `operator`} (`OPS-39`).

**WIR-10b** **`result` and `error` shapes.** `error`, when non-null, is exactly `WIR-9`'s inner
object (`kind`/`message`/`retryable`/`details`), without the envelope. `result`, when non-null, is
per kind and redacted (`API-22`, `DOM-18`): `create_machine`/`adopt_machine` → `{"machine_id": "<uuid>"}`;
`install` and `preflight` → `{"preflight": {"devices": [{"identifier": "...", "path": "...",
"size_bytes": 0, "model": "...", "type": "..."}], "uefi": true, "inventory_fingerprint": "..."}}`
(`RSC-33`, `RSC-38`); `power`/`reverse_dns`/`delete_machine`/`refresh` → `{}`. An ambiguous outcome additionally records provider identifiers in `result` per `OPS-13`.

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
  "effective_cancellation_date": null,
  "earliest_cancellation_date": null,
  "created_at": "2026-08-12T14:03:00Z", "updated_at": "2026-08-12T15:03:00Z"
}
```

`runway_until` floats with the rate (`LDG-15`, `LDG-33`); the first `public_ips` entry is the
rescue address. `external_id` and raw provider metadata are **absent** on the customer surface
(`DOM-5`, `LDG-26`).

## Endpoints

Only bodies and endpoint-specific rules are given; authentication (`WIR-5`), CORS (`WIR-4a`),
pacing, errors and idempotency are uniform per the sections above. Authenticated writes require
`Idempotency-Key` (`API-8`) and return `202` with an operation view unless listed in `API-48`.
**Enrolment is the exception**: it is unauthenticated and has no tenant to scope by, so its
idempotency is keyed on the header alone and it MUST NOT *require* one (`API-40`). **Resource ids
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
  "spending_token": "pvd_s_7Qk2mXbW9tR4vL8nZaC3yH6eJ1gP5dF0sK7wN2xB4uT",
  "recovery_credential": "pvd_r_3mYq8LbN5tX2vK9pZfC6yH4eJ7gR1dW0sM3wQ5xA8uV",
  "disclosures": [
    {"code": "store_both_secrets", "text": "These are shown once. Store the recovery credential where your everyday agent cannot reach it; it is the only thing that can revoke a stolen token."},
    {"code": "no_identity_recovery", "text": "Losing both is a lost balance. There is no identity to recover against and no refund."},
    {"code": "signup_expiry", "text": "An unfunded signup expires at expires_at. A credit below the activation minimum does not extend it; such a credit is retained and re-attributable, never refunded."}
  ]
}
```

Both secrets are stored **hashed only** (`STO-34`) and the token does nothing until `issuable_at`
(`API-33`). *Two withdrawn versions: the first registered a caller public key; the second minted
the token later and returned it **once** from `WIR-13`, which cannot survive a lost response — the
server marks it delivered, keeps only a hash, and a funded customer is locked out of a tenant
nobody can reach.* **Enrolment carries no idempotency replay at all** (`API-40`): the key space
was global and unauthenticated, so two callers choosing the same low-entropy key received the same
handle — and the handle yields the credentials. A duplicate signup is free and `API-34` reaps it;
a leaked capability is not.

**WIR-13** **AMENDED** `GET /v1/enrol/{handle}` — unauthenticated, **status only, no secrets
ever**: `{"status": "not_yet" | "pending" | "active", "issuable_at": "...", "expires_at": "..."}`.
No delay-derived `Retry-After` (`API-33`, `API-49`'s exception). This is how a pending tenant
observes activation (`API-52`).

**WIR-38** `POST /v1/recovery/revoke` — authenticated by the **recovery credential**, never by the
spending token (`API-56`). Body `{}`; response `200` with a fresh
`{"spending_token": "...", "revoked_at": "..."}`. Synchronous — a pure credential action with no
provider mutation — and added to `API-48`'s list on that basis. The tenant, its machines, its
balance and its commitments are untouched.

**WIR-39** `POST /v1/tenants/{id}/actions/suspend` and `.../resume` — **operator-only**
(`WIR-34`), `{"acknowledge_destruction": true}` on suspend, since it cancels the tenant's fleet
(`API-58`, `SEC-45`). Returns `202` with a **termination record** id whose child cancellations are
ordinary operations (`OPS-39`), so partial failure and `needs_reconciliation` are visible per
machine rather than hidden behind one status.

**WIR-14** `POST /v1/deposits` (`API-43`, `API-44`) — body: `{"amount_sats": 250000}`.
Response `200`:

```json
{
  "id": "0198c1d0-5c4d-7e6f-8a1b-3d5f7a9c1e40",
  "requested_sats": 250000,
  "activation_minimum_sats": 100000,
  "expires_at": "2026-08-13T14:00:00Z",
  "lightning": {"invoice": "lnbc2500u1p...", "floor_sats": 1000, "enforced": true},
  "onchain":   {"address": "bc1qexampleaddressxxxxxxxxxxxxxxxxxxxxxxxxxx", "floor_sats": 20000, "enforced": false},
  "disclosures": [
    {"code": "onchain_expiry_unwatched", "text": "After expires_at the address stays payable but is no longer watched; funds sent after expiry may be lost."},
    {"code": "double_pay_no_refund", "text": "Paying both destinations credits both. Nothing is refundable, ever."},
    {"code": "below_activation_minimum", "text": "A credited balance below activation_minimum_sats leaves the tenant pending and is not refundable."}
  ]
}
```

`enforced` states which expiry is a mechanism and which a promise (`LDG-54`); the Lightning
invoice's own embedded expiry MUST equal `expires_at`. Both rails carry a `floor_sats` (`LDG-52`).
`activation_minimum_sats` is the threshold below which a paid balance still cannot activate
(`API-35`, `LDG-44`) — disclosed so an agent never sends unrefundable money below it blind. Each
`disclosures` entry carries a machine-readable `code` and human `text` (`CNF-131`).

**WIR-15** `GET /v1/deposits/{id}` — the same body plus
`"credits": [{"rail": "lightning", "amount_sats": 250000, "credited_at": "..."}]` (one entry per
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
≤1 MiB, `API-13`) and `labels` (string→string, reserved keys per `DOM-6`) are the create inputs
the other requirements accept and this body previously omitted — under `WIR-2` a conforming server
would otherwise reject them. `runway_seconds` is `PRV-13d`'s caller-chosen runway; a value **below**
the wind-down floor MUST be **rejected** `invalid_request` with `details.min_runway_seconds`, never
silently raised — silently reserving more of a caller's money than it asked for is a money bug.
`max_commitment_sats` (optional) caps spend: if the computed commitment exceeds it the request
fails `invalid_request` (not `insufficient_balance`) **before** any commitment opens, so an agent
can bound a purchase priced at an attacker-influenceable rate (`LDG-41`).

**WIR-18** `POST /v1/machines/adopt` — **operator-only** (`API-18`, `WIR-34`): bearer auth, body
`{"tenant_id": "...", "provider_account": "...", "external_id": "...", "runway_seconds": 2592000,
"acknowledge_purchase": true}`. A customer-authenticated request to this route returns `404`
(`WIR-34`), not `authentication` — its existence is not customer-observable.

**WIR-19** `POST /v1/machines/{id}/actions/power` — `{"action": "on" | "off" | "reboot" |
"hard_reset"}`. The last requires the `hard_reset` capability (`DOM-10`).

**WIR-20** **AMENDED — the install body is a closed discriminated union, one variant per `DOM-13`
pairing, and it carries every field the rescue engine needs from the caller.** The withdrawn body
showed only `rootfs_via_rescue` and omitted the raw-disk target device (`RSC-26`), the host-key
trust decision (`RSC-3`/`RSC-4`), the layout (`RSC-22`) and the installed keys (`RSC-13`) — so
three of four strategies were unsendable and the security-critical trust choice had no field.

Common to every variant: `acknowledge_destruction: true` (`API-14`); `on_failure` ∈
{`exit_rescue` (**default**), `leave_in_rescue`}; and a **`trust`** object — exactly one of three,
not two:

| `trust` | Meaning |
|---|---|
| `{"use_provider_keys": true}` | Pin the host keys the driver publishes at rescue activation. **Abort `integrity` if none appear** before `RSC-9`'s deadline |
| `{"expected_host_keys": [...]}` | Pin caller-supplied keys (`RSC-3`) |
| `{"accept_unpinned": true}` | First-use trust, the explicit per-request opt-in `SEC-22` requires |

**The provider-keys variant was missing and its absence was a silent security downgrade.** It is
`RSC-3`'s *strongest* row and the only one reachable on Hetzner Robot, where rescue host keys are
published at activation and a customer cannot know them out of band (`08-provider-notes.md`). With
only two variants, every install on the flagship product had to declare `accept_unpinned` — the
security-critical decision in the whole workflow, downgraded by a body schema. Per variant:

```json
{ "strategy": "rootfs_via_rescue",
  "source": {"type": "rootfs_tarball", "url": "https://...", "sha256": "<64 hex>", "format": "zstd"},
  "authorized_keys": ["ssh-ed25519 AAAA..."],
  "layout": { "drives": ["/dev/nvme0n1"], "raid": {"enabled": false}, "partitions": [ ... ], "bootloader": "grub" },
  "post_install_script": null,
  "trust": {"use_provider_keys": true},
  "on_failure": "exit_rescue",
  "acknowledge_destruction": true }
```

- `raw_disk`: `source.type` `raw_disk` (`url`, `sha256`, `compression` ∈ {`none`, `gzip`, `xz`,
  `zstd`, `bzip2`}), a required **`target`** object — `{"identifier": "<serial or WWN>",
  "inventory_fingerprint": "<from RSC-38 preflight>"}`, **not a device path** (`RSC-26`) —
  optional `grow_partition` (boolean, default `false`, `RSC-31`), and no `authorized_keys`
  (`RSC-14` forbids injecting into an opaque image).
- `provider_native`: `source.type` ∈ {`catalog` (`image`), `ipxe` (`script`)}; no `layout`, no
  `trust` (no rescue is entered); `catalog` MAY carry `authorized_keys`.

`rootfs_tarball` and `raw_disk` `sha256` are required and exactly 64 hex (`DOM-14`); `ipxe` and
`catalog` carry no digest — this system does not touch those bytes (`SEC-16`, `DOM-22`). A `url`
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
cursor-paginated (`WIR-32`): `{"machines": [...], "next_cursor": null}`.

**WIR-26** `GET /v1/operations?terminal=false&status=...&limit=100&cursor=...` — the fleet poll
(`API-49`): `{"operations": [...], "next_cursor": null, "poll_after_ms": 5000}`. `terminal=false`
MUST be supported; `status` accepts a comma-separated set; `terminal` and `status` combine as an
intersection, and an empty intersection is an empty page, not an error. The list-level
`poll_after_ms` governs the fleet poll; a single-operation poll obeys that operation's own value
(`WIR-10`).

**WIR-27** `GET /v1/operations/{id}` — one operation view. Past retention: `410` with kind
`gone`, `details.retained_until` (`DOM-21`).

**WIR-28** **AMENDED** `POST /v1/operations/{id}/actions/requeue` — **operator-only** (`API-19`,
`WIR-34`), body `{"reason": "...", "acknowledge_duplicate_purchase": true, "request": { ...a fresh
payload in the original endpoint's shape... }}` (`OPS-34`). The system verifies the fresh payload
against the stored summary and refuses on any mismatch. `acknowledge_duplicate_purchase` MUST be
literal `true` when the operation's kind places an order — the fresh payload's own
`acknowledge_purchase` does **not** satisfy `OPS-20`'s "second, distinct" acknowledgement, because
requeueing a create is a purchase decision, not a retry.

**WIR-35** `POST /v1/operations/{id}/actions/resolve` — **operator-only** (`API-19`, `WIR-34`),
the reconciliation verbs `OPS-31` mandates and no endpoint carried (this was the operator half of
`F19`). Body is a discriminated union: `{"resolution": "observed", "external_id": "...",
"kept_duplicate": "...", "evidence": "..."}` attaches a discovered resource (`OPS-27`);
`{"resolution": "absent", "evidence": "..."}` records that nothing was created and releases the
commitment (`LDG-32`); `{"resolution": "abandoned", "evidence": "..."}` gives up. `external_id` is
required for `observed`. It is distinct from requeue and is the only road out of the unresolved
row (`OPS-33`). **Synchronous** — it records an operator decision against an existing operation
and mints no provider mutation — returning `200` with the updated operation view, under
`API-48`'s exemption and `STO-35`'s idempotency record. Minting an operation *about* an operation
is a recursion `API-1` never intended.

**WIR-40** `POST /v1/machines/{id}/actions/preflight` — `RSC-38`'s read-only inventory pass. Body
`{}`; returns `202` and an operation whose result carries the device inventory with **stable
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
  "quoted_at": "2026-08-13T14:00:00Z", "binding": false
}]}
```

Prices are integers of satoshis, already margined by the one pricing function (`LDG-23`, `LDG-24`)
at the same rounding as commitment creation. **An offer price is an indicative quote converted at
read time; `binding` is `false` and the commitment is priced at accept time (`LDG-27`) and MAY
differ** — a caller bounding spend uses `WIR-17`'s `max_commitment_sats`, not the quote. The
provider's currency, price string and raw metadata MUST NOT appear.

**WIR-31** `GET /healthz` — `200 {"status": "ok"}`, unauthenticated but rate-limited (`API-29`),
and MUST NOT disclose version, uptime, queue depth or anything else a caller can fingerprint.

## Listeners, limits and fixtures

**WIR-34** **Operator-only routes** (`WIR-18`, `WIR-28`, `WIR-35`, and the operator forms of
`WIR-29`/`WIR-30`) MUST be served only on the operator listener (`API-27`), MUST NOT carry the
customer CORS headers of `WIR-4a`, and MUST return `404` — never `authentication` — to a
customer-authenticated request, so their existence is not customer-observable.

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
