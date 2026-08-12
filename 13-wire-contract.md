# 13 — Wire contract

This document did not exist until 2026-08-12, and `F19`'s complaint stood for three audits: in
~2,600 lines there was exactly one JSON example, so every implementer would have invented a
contract and the checklist would have blessed it. Everything here is normative. Where a shape
disagrees with prose elsewhere, this document wins and the disagreement is a defect to record.

## Conventions

**WIR-1** Request and response bodies are JSON, `application/json; charset=utf-8`. Money is an
integer number of satoshis in a field suffixed `_sats` (`LDG-1`). Timestamps are RFC 3339 UTC
with second precision. Identifiers are UUID strings. Durations chosen by callers are integer
**seconds**.

**WIR-2** **Unknown fields in a request body MUST be rejected** with `invalid_request` naming the
first unknown field. A tolerant reader lets a misspelled `acknowledge_destruction` pass silently
unacknowledged, and lets two implementations diverge without either noticing. Responses are the
opposite: **clients MUST ignore unknown response fields**, so the server can add fields without a
version bump.

**WIR-3** The canonical form of a body — for signing (`WIR-6`) and for idempotency comparison
(`API-12`, `CNF-24`) — is **RFC 8785 (JCS)**. Key order, whitespace and number formatting
differences never distinguish two requests.

**WIR-4** Every response carries `X-Correlation-Id` (`API-28`). Responses that carry
`Retry-After` also carry `Access-Control-Expose-Headers: Retry-After, X-Correlation-Id` — a
browser-wasm caller cannot read non-safelisted headers without it, which is why every pacing
value is also in the body. `Access-Control-Max-Age` SHOULD be at least 3600: `API-39`'s signature
headers force a CORS preflight per request shape, and preflights MUST NOT count against the
caller's budget (`API-50`).

## Authentication on the wire

**WIR-5** Two schemes, disjoint by principal (`API-3`):

- **Operator**: `Authorization: Bearer <token>`.
- **Customer**: a signed request, three headers —
  `X-Provisiond-Key` (the tenant's Ed25519 public key, 32 bytes, base64 standard with padding),
  `X-Provisiond-Timestamp` (integer Unix seconds),
  `X-Provisiond-Signature` (Ed25519 signature, base64 standard with padding).

**WIR-6** **The signed byte string** (`API-39`) is the UTF-8 encoding of six lines joined by
`\n`, no trailing newline:

```
provisiond-v1
{METHOD}
{path with query, exactly as sent, e.g. /v1/operations?terminal=false&limit=100}
{X-Provisiond-Timestamp value}
{Idempotency-Key value, or empty string when the request carries none}
{lowercase hex SHA-256 of the JCS-canonical body, or of the empty string for bodyless requests}
```

The version line is domain separation: a signature for this protocol verifies for nothing else.
The signature algorithm is **Ed25519 (RFC 8032)** — deterministic, no nonce to mismanage, and
native in every environment the caller compiles to.

**WIR-7** Clock skew tolerance is a stated deployment parameter, **default ±300 seconds**. A
timestamp outside it fails `authentication` with a message naming the server's current time, so
an agent with a wrong clock can correct itself. Replay within the window is bounded by the
idempotency cache for writes (`API-8`, `STO-25`) and is read-only for GETs; **TLS is the
confidentiality layer** (`API-27`) — the signature authenticates, it does not encrypt.

**WIR-8** Enrolment (`POST /v1/enrol`) is signed with the key being registered — the proof of
possession `API-39` requires. Key rotation is a signed request adding a second key with a
mandatory overlap window; both keys verify during the overlap.

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

`kind` is `DOM-17`'s closed set. `retryable` is normative for callers (`API-51`). `details` keys
are per-kind and additive.

## Views

**WIR-10** The **operation view** (`API-20`):

```json
{
  "id": "0198c1c2-...", "kind": "create_machine",
  "status": "running", "terminal": false,
  "revision": 4, "retryable": false,
  "requested_by": "caller", "system_reason": null,
  "machine_id": null, "provider_account": "hetzner-cloud-1",
  "idempotency_key": "agent-7:create:2026-08-12T14",
  "attempts": 1, "requeues": 0,
  "result": null, "error": null,
  "poll_after_ms": 5000,
  "created_at": "2026-08-12T14:00:11Z", "updated_at": "2026-08-12T14:00:12Z",
  "correlation_id": "0198c1c2-..."
}
```

`poll_after_ms` present only while non-terminal, mirrored by `Retry-After` (`API-49`).
`system_reason` non-null only when `requested_by` is `system` (`OPS-39`).

**WIR-11** The **machine view**: `id`, `name`, `kind` (`virtual`|`bare_metal`), `state`
(`DOM-7`'s enum), `region`, `public_ips` (ordered, first is the rescue address),
`provider_account`, `created_at`, `updated_at`, and the money fields —
`committed_sats` (remaining commitment), `runway_until` (floats with the rate, `LDG-15`,
`LDG-33`), `effective_cancellation_date` (nullable), `earliest_cancellation_date` (nullable).
`external_id` and raw provider metadata are **absent** on the customer surface (`DOM-5`,
`LDG-26`).

## Endpoints

Only bodies and endpoint-specific rules are given; authentication, pacing, errors and
idempotency are uniform per the sections above. All writes require `Idempotency-Key` (`API-8`)
and return `202` with an operation view unless listed in `API-48`.

**WIR-12** `POST /v1/enrol` — signed with the key it registers. Body:
`{"public_key": "<base64>"}`. Response `200`:
`{"handle": "<uuid>", "status": "pending"}`. No credential is ever returned; the caller's key
**is** the credential (`API-39`).

**WIR-13** `GET /v1/enrol/{handle}` — before the issuance delay elapses:
`{"status": "not_yet"}` with no delay-derived `Retry-After` (`API-33`, `API-49`'s exception).
After: `{"status": "pending" | "active", "tenant_id": "<id>"}` — the activation observability
`API-52` requires. Reachable while pending (`API-43`).

**WIR-14** `POST /v1/deposits` (`API-43`, `API-44`) — body: `{"amount_sats": 250000}`.
Response `200`:

```json
{
  "id": "0198c1d0-...",
  "requested_sats": 250000,
  "expires_at": "2026-08-13T14:00:00Z",
  "lightning": {"invoice": "lnbc2500u1p...", "enforced": true},
  "onchain":   {"address": "bc1q...", "floor_sats": 20000, "enforced": false},
  "disclosures": [
    "After expires_at the address remains payable but is no longer watched; funds sent after expiry may be lost.",
    "Paying both destinations credits both. Nothing is refundable, ever."
  ]
}
```

`enforced` states which expiry is a mechanism and which is a promise (`LDG-54`). The
`disclosures` array is normative content, not decoration (`CNF-131`).

**WIR-15** `GET /v1/deposits/{id}` — the same body plus
`"credits": [{"rail": "lightning", "amount_sats": 250000, "credited_at": "..."}]`, one entry per
settled payment (`LDG-55` — plural on purpose).

**WIR-16** `GET /v1/balance` (`API-47`):

```json
{
  "balance_sats": 322000,
  "available_sats": 250000,
  "committed_sats": 72000,
  "commitments": [{"machine_id": "0198c1e0-...", "reserved_sats": 72000}],
  "earliest_runway_until": "2026-09-11T14:00:00Z"
}
```

**WIR-17** `POST /v1/machines` — create:

```json
{
  "provider_account": "hetzner-cloud-1",
  "offer": "standard:cx32",
  "region": "fsn1",
  "hostname": "worker-1",
  "ssh_public_keys": ["ssh-ed25519 AAAA..."],
  "runway_seconds": 2592000,
  "acknowledge_purchase": true,
  "provider_options": {}
}
```

`ssh_public_keys` MUST be non-empty (`PRV-8`, `API-13`). `acknowledge_purchase` MUST be literal
`true` (`API-15`, `PRV-10`). `runway_seconds` is `PRV-13d`'s caller-chosen runway, floored at the
wind-down bound.

**WIR-18** `POST /v1/machines/adopt` — **operator-only** (`API-18`): bearer auth, body
`{"tenant_id", "provider_account", "external_id", "runway_seconds", "acknowledge_purchase": true}`.
Tenant credentials are rejected outright.

**WIR-19** `POST /v1/machines/{id}/actions/power` — `{"action": "on" | "off" | "reboot" |
"hard_reset"}`. The last requires the `hard_reset` capability (`DOM-10`).

**WIR-20** `POST /v1/machines/{id}/actions/install` — strategy and source per `DOM-13`'s
pairings, plus the destructive acknowledgement (`API-14`):

```json
{
  "strategy": "rootfs_via_rescue",
  "source": {"type": "rootfs_tarball", "url": "https://...", "sha256": "9f...", "format": "zstd"},
  "acknowledge_destruction": true
}
```

A signed `url` is subject to `OPS-40`'s two validity gates.

**WIR-21** `POST /v1/machines/{id}/actions/reverse-dns` — `{"ip": "203.0.113.7", "ptr":
"mail.example.org"}`. The `ip` MUST be one of the machine's assigned addresses.

**WIR-22** `POST /v1/machines/{id}/actions/delete` — `{"acknowledge_destruction": true}`.

**WIR-23** `POST /v1/machines/{id}/actions/refresh` — empty body `{}`.

**WIR-24** `POST /v1/machines/{id}/actions/extend-runway` — `{"additional_seconds": 604800}`.
This is `LDG-62`'s action. It causes **no provider mutation**, so it is synchronous: `200` with
the updated machine view, its commitment increased at the current rate in the same transaction as
the authorization check. `API-48`'s closed list is AMENDED to include it — by this document,
recorded there.

**WIR-25** `GET /v1/machines`, `GET /v1/machines/{id}` — machine views; the list is
cursor-paginated (`API-26`): `{"machines": [...], "next_cursor": null}`.

**WIR-26** `GET /v1/operations?terminal=false&status=...&limit=100&cursor=...` — the fleet poll
(`API-49`): `{"operations": [...], "next_cursor": null, "poll_after_ms": 5000}`. `terminal=false`
MUST be supported; `status` accepts a comma-separated set.

**WIR-27** `GET /v1/operations/{id}` — one operation view. Past retention: `410` with kind
`gone` (`DOM-21`).

**WIR-28** `POST /v1/operations/{id}/actions/requeue` — **operator-only** (`API-19`), body
`{"reason": "...", "request": { ...a fresh payload in the original endpoint's shape... }}`
(`OPS-34`). The system verifies the fresh payload against the stored summary and refuses on any
mismatch.

**WIR-29** `GET /v1/providers` — `{"providers": [{"account": "hetzner-robot-1", "kind":
"hetzner_robot", "capabilities": ["provision_bare_metal", "rescue_ssh", "list_offers", ...]}]}`
(`OVR-2`, `DOM-22`).

**WIR-30** `GET /v1/providers/{account}/offers` — customer prices only (`LDG-26`):
`{"offers": [{"id": "standard:cx32", "kind": "virtual", "regions": ["fsn1"], "hourly_price_sats":
120, "setup_fee_sats": 0}]}`. Prices are integers of satoshis, already margined (`LDG-23`,
`LDG-24`); the provider's currency, price string and raw metadata MUST NOT appear.

**WIR-31** `GET /healthz` — `200 {"status": "ok"}`, unauthenticated, and MUST NOT disclose
version, uptime, queue depth or anything else an unauthenticated caller can fingerprint.

## Limits

**WIR-32** `API-26`'s "sane range" is: `limit` clamped to **1–200, default 50** — closing that
item of `F18`. A caller-supplied value outside the range is clamped, not rejected; pagination is
not a place where strictness helps anyone.
