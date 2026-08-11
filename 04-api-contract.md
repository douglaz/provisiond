# 04 — HTTP API contract

## Surface

| Method | Path | Sync | Purpose |
|---|---|:--:|---|
| GET | `/healthz` | ✓ | Liveness. Unauthenticated. |
| GET | `/v1/providers` | ✓ | Configured accounts and their capabilities |
| GET | `/v1/providers/{account}/offers` | ✓ | Purchasable offers for one account |
| GET | `/v1/machines` | ✓ | List the caller's machines |
| POST | `/v1/machines` | | Create a machine |
| POST | `/v1/machines/adopt` | | Import an existing machine |
| GET | `/v1/machines/{id}` | ✓ | Read one machine |
| POST | `/v1/machines/{id}/actions/refresh` | | Re-read from the provider |
| POST | `/v1/machines/{id}/actions/power` | | Power on/off, reboot, hard reset |
| POST | `/v1/machines/{id}/actions/install` | | Install an image |
| POST | `/v1/machines/{id}/actions/reverse-dns` | | Set a PTR record |
| POST | `/v1/machines/{id}/actions/delete` | | Delete the machine |
| GET | `/v1/operations` | ✓ | List operations, filterable by status |
| GET | `/v1/operations/{id}` | ✓ | Poll one operation |
| POST | `/v1/operations/{id}/actions/requeue` | | Operator requeue |

**API-1** Every non-`GET` endpoint that *accepts* a valid, authorized request MUST return
`202 Accepted` with an operation view; none returns the completed result inline. Requests
rejected before enqueue return their mapped error status (`API-24`) — `400`, `401`, `404`,
`409` and `501` are all reachable on write endpoints.

**API-2** `{id}` in a path is always an internal UUID. A provider-side identifier MUST
NOT appear in a client-constructed path (`DOM-5`).

## Authentication and tenancy

**API-3** Requests MUST authenticate with a bearer token. The server MUST hold tokens
only as digests in memory and MUST compare in constant time.

**API-4** **AMENDED — it now applies to operator credentials only.** Operator tokens MUST be
supplied through the environment, named — not valued — by the configuration. A minimum length
MUST be enforced at startup (24 bytes is a reasonable floor) and duplicate tokens across
identities MUST fail startup.

The original text applied this to every token, which `ADR-0002` made impossible: a self-serve
tenant appears at runtime and cannot have been named in an environment variable at startup.
This was `F2`, recorded as unbuildable, and the split resolves it. **Customer credentials are
issued at runtime and governed by `API-32`–`API-37`.** Operator credentials remain static,
environment-supplied, and outside the tenant model entirely — which is also what keeps `API-19`
(requeue is a purchase) genuinely operator-only.

**API-5** Each token maps to exactly one tenant and an admin flag. An admin token MAY act
for another tenant by sending a tenant override header; a non-admin token MUST NOT, and
the header MUST be ignored rather than honoured for it.

**API-6** An overridden tenant identifier MUST be validated against `DOM-1` before use.

**API-7** **Authentication MUST happen before request-body validation.** An
unauthenticated caller MUST NOT be able to learn anything from validation error text, and
MUST NOT be able to make the server do parsing or policy work. See `DEF-4`.

Order of operations for every write endpoint, normatively:

1. authenticate, resolve tenant;
2. validate the idempotency key;
3. authorize the target resource against the tenant;
4. deserialize and validate the body;
5. enqueue;
6. respond `202`.

## Enrolment

Self-serve enrolment (`ADR-0002`) with no identity collected (`ADR-0005`) means the only thing
standing between a script and an unbounded table of tenant rows is this section.

**API-32** An unauthenticated enrolment endpoint MUST exist. It creates a tenant in a **pending**
state and returns an enrolment handle. It MUST NOT return a usable credential immediately.

**API-33** Credential issuance MUST be deferred by a configured delay after enrolment. The caller
retries or polls with its handle; before the delay elapses the endpoint MUST report *not yet*
rather than an error, and MUST NOT reveal the remaining time to the nearest instant (it is a free
oracle for tuning an attack).

**A delay is a real control against a naive script and a weak one against a parallel attacker**,
because concurrency makes wall-clock free. It is specified here as the operator's chosen friction,
not as the storage bound. `API-34` is the storage bound.

**API-34** A pending tenant that has not been funded within a configured time-to-live MUST be
deleted, along with its credential. This is what caps the table at *enrolment rate × TTL* rather
than letting it grow without limit, and it is the requirement to test — an implementation that
ships `API-33` without `API-34` has bought delay and no bound.

**API-35** A tenant MUST NOT graduate out of pending until a payment has been credited to it. An
unfunded tenant can do nothing under `ADR-0002` in any case, so pending is the correct place for
it to wait, and funding is the only event that proves a real customer.

**API-36** Enrolment MUST be rate-limited (`API-29`). Rate-limiting state MUST be held in memory
and MUST NOT be persisted — retaining caller addresses to defend the enrolment endpoint would
give up `ADR-0005` to protect a table.

**API-37** **There is no credential recovery, and this MUST be stated to the caller at issuance.**
No identity is collected, so there is nothing to prove ownership with; any recovery mechanism
would be an account-takeover mechanism wearing a helpful name. A lost credential means a lost
balance. The caller is software and can store a secret reliably — but it MUST be told that it
has to.

> **Open decision: what kind of credential.** The above assumes a server-generated bearer token
> held as a digest (`API-3`). The alternative is for the caller to supply a **public key** at
> enrolment and sign its requests, so that this system stores no customer secret at all and a
> full database compromise yields nothing an attacker can act with. That is materially stronger
> here than it would be elsewhere, because `ADR-0001` puts the public surface in the same process
> as credentials to every customer's machine, and it turns `API-37`'s "no recovery" into the
> customer's own key backup. Its cost is a request-signing specification — canonicalisation, a
> nonce, clock-skew tolerance. Recorded rather than decided.

## Idempotency

**API-8** Every write request MUST carry a caller-generated idempotency key header.

**API-9** The key MUST be 8–200 characters of ASCII letters, digits, `.`, `_`, `:`, or
`-`.

**API-10** Idempotency MUST be scoped to `(tenant, key)`. A key collision across tenants
MUST NOT be observable by either tenant — not as a conflict, not as a shared operation,
and not as an internal error.

**API-11** Re-sending the same key with a byte-equivalent request MUST return the
existing operation. Re-sending it with a different request MUST fail `409 Conflict` and
MUST NOT create a second operation.

**API-12** Equivalence MUST be computed over a canonical serialization of the stored and
incoming requests, not over raw request bytes, so that key ordering and whitespace do not
produce spurious conflicts.

## Validation

Validation happens at the boundary *and* again in the worker (`OPS-23`).

**API-13** The following MUST be enforced before an operation is enqueued:

| Field | Rule |
|---|---|
| hostname | 1–253 characters, no CR or LF |
| offer identifier | 1–256 characters |
| `external_id` (adopt) | 1–256 characters, and a provider-appropriate character set (`PRV-6`) |
| SSH public keys | at most 64, each ≤16 KiB, each recognizably an OpenSSH public key |
| expected rescue host keys | at most 16, each a complete OpenSSH public host key |
| iPXE script | ≤128 KiB, begins with the iPXE shebang |
| catalog image | 1–256 characters |
| user data / post-install script | ≤1 MiB |
| provider options | MUST be a JSON object |
| image URL | ≤8192 bytes, no fragment, no embedded credentials, scheme `https` (or `http` only where explicitly enabled), host in the allowlist when one is configured |
| digest | exactly 64 hex characters (`DOM-14`) |
| strategy/image pairing | per `DOM-13` |
| host-key policy | pinned keys and "accept unpinned" MUST be mutually exclusive |
| request body size | globally capped (2 MiB is a reasonable default) |

**API-14** An install request MUST carry an explicit destructive acknowledgement, and a
delete request MUST carry one. Absent or false MUST fail `400`. This is per request, and
is not satisfied by authentication, by idempotency, or by having sent one previously.

**API-15** A create request against an order-billed provider MUST carry an explicit
purchase acknowledgement in its provider options, in addition to the account being
configured to allow ordering (`PRV-10`).

**API-16** A reverse-DNS request MUST be rejected unless the supplied address is present
in the machine's recorded address list, and the hostname MUST be 1–253 characters with no
CR or LF.

## Authorization

**API-17** Every machine-scoped endpoint MUST resolve the machine *within the caller's
tenant* and MUST return `404` — not `403` — when it does not exist there. Existence of
another tenant's machine MUST NOT be observable.

**API-17a** **The same rule applies to operations, and it is easy to miss because operations
are not machine-scoped.** `GET /v1/operations/{id}` MUST resolve within the caller's tenant and
return `404` otherwise; `GET /v1/operations` MUST be tenant-filtered before pagination. An
operation record carries the tenant, the provider account, the result and the error — enough to
enumerate another customer's estate from a stolen or guessed identifier. Specifying pagination
without specifying isolation is how this gets missed.

**API-17b** **Creation needs an authorization rule, and it is the only operation that has no
target to authorize against.** Every other verb is gated by a machine record the tenant already
owns. Create is gated by nothing: a tenant names a provider account and spends the operator's
money in it. `allow_orders` and a per-request purchase acknowledgement prevent *accidents*, not
*unauthorized* spending, and `DOM-3` says naming an account MUST grant nothing — which create
currently contradicts.

A deployment MUST therefore define, before accepting creates from more than one tenant:

- **which provider accounts a tenant may create in** — an explicit assignment, not "all
  configured ones"; and
- **that tenant's spending authority** — a ceiling per interval (`SEC-39`), a prepaid balance,
  or an operator approval step.

Absent both, any tenant can order unbounded billable hardware in any configured account, and no
other requirement in this document stops it.

**API-18** Adoption MUST require proof that the caller is entitled to the machine. Being
able to name a provider account and an external identifier is not proof: the credentials
belong to the operator, not the tenant, and every tenant can name them. Acceptable
mechanisms, in rough order of preference:

- an operator-maintained assignment of external machine identifiers to tenants, checked
  before adoption;
- a challenge the caller must place on the machine (a token in a well-known file or a DNS
  record) that the control plane verifies;
- restricting adoption to admin tokens acting on a tenant's behalf.

A deployment MUST choose one and MUST document it. See `DEF-1`.

**API-19** Requeue MUST be restricted to operators. A tenant token MUST NOT be able to
requeue an operation, because requeue can re-issue a purchase (`OPS-20`).

**API-30** Where a front service proxies customer requests using one admin identity plus the
tenant-override header (`API-5`), the override is the *entire* tenancy boundary for the
product, and this system cannot check it. `API-6` validates the identifier's character set
(`DOM-1`); whether it can validate that the tenant *exists* depends entirely on which branch of
`DOM-1a` the deployment chose. **With no registry, it cannot** — a well-formed identifier is
indistinguishable from a correct one, and this requirement applies in full. **With a registry,
this objection largely dissolves**: the override becomes checkable, and the remaining risk is
the ordinary one that the front service resolves the wrong tenant, which the registry cannot
detect but which is no longer unbounded. Deployments choosing a registry MAY treat the options
below as satisfied by the registry itself, and need not additionally implement one.

**A registry is not a complete answer.** It proves an override names an *existing* tenant. It
cannot detect the case that actually happens — a cached header, a reused connection, a wrong
variable — where the front service confidently selects the *wrong existing* tenant. Only
per-tenant proof carried from the client closes that, and `API-30`'s options below are about
the first problem, not the second. Every request legitimately carries admin plus override, so there is no anomalous case to
alarm on. A proxy bug — a cached header, a reused connection, a wrong variable — silently maps
one customer's request onto another customer's machines, and nothing here notices.

A deployment using this pattern MUST therefore do one of:

- **Sign per tenant.** The front service signs each forwarded request with a per-tenant key
  this system holds and verifies. Preferred: it makes the override falsifiable.
- **Keep a synced allowlist.** This system maintains an out-of-band-synchronised set of valid
  tenant identifiers and rejects overrides outside it. This is a tenant registry, so a
  deployment choosing it MUST select `DOM-1a`'s registry branch explicitly.
- **Accept and document.** Record explicitly that the front service's proxy is the single
  point of tenancy enforcement, that this system's tenancy tests (`CNF-4`–`CNF-7`) prove
  nothing about it, and that the front service needs its own equivalents.

**API-31** Where the front service proxies with one admin identity, every audit record here
reads "admin override" (`SEC-32`), which makes the trail useless for attributing an action to
a customer. The front service MUST keep its own request→customer audit log, joinable to these
records by correlation id (`API-28`).

## Operation views

**API-20** The operation view returned to clients MUST include: id, tenant, idempotency
key, kind, status, machine id, provider account, result, error, attempt count, and
timestamps.

**API-21** The operation view MUST NOT include the stored request payload. It can contain
signed image URLs and other caller secrets that need not be echoed back.

**API-22** Result and error payloads MUST be redacted (`DOM-6`, `DOM-18`) before they are
stored, not merely before they are rendered.

**API-23** `GET /v1/operations` MUST support filtering by status and MUST support
pagination. Listing everything in `needs_reconciliation` is an operational necessity
(`OPS-26`).

## Errors

A single envelope for every failure:

```json
{
  "error": {
    "kind": "invalid_request",
    "message": "human readable, safe to show an operator",
    "retryable": false,
    "details": {}
  }
}
```

**API-24** `kind` MUST come from the closed set in `DOM-17`, and the HTTP status MUST be
derived from it by the mapping in that table. Handlers MUST NOT choose statuses
independently.

**API-25** `message` MUST NOT contain a credential, a private key, a signed URL, or an
unredacted provider response.

## Listing and pagination

**API-26** `GET /v1/machines` MUST be tenant-scoped, MUST clamp any caller-supplied limit
to a sane range, and SHOULD offer a cursor rather than an offset.

## Transport

**API-27** Reachability follows the separation form chosen under `OVR-10`. In the
separate-service form the lifecycle API MUST be reachable only over a private network. In the
single-component form the public surface is reachable by customers by definition, and the
deployment MUST instead:

- terminate TLS such that no credential traverses an untrusted hop in clear text;
- expose *only* the customer-facing routes publicly, keeping operator and reconciliation routes
  on a separate listener or network (`API-19` requeue in particular is operator-only and is a
  purchase);
- treat `OVR-10a`'s in-code credential boundary as the compensating control, since network
  isolation is no longer providing one.

A deployment MUST record which form it chose. "Private network" is not a property this
specification can assume once the customer is the caller.

**API-28** Every request SHOULD carry a correlation identifier, generated if absent, and
that identifier MUST appear in the operation record and in every log line emitted while
handling the request.

**API-29** The service SHOULD rate-limit per tenant (`OPS-24`). Unauthenticated requests
MUST be rate-limited.
