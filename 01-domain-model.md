# 01 — Domain model

## Entities

### Tenant

An isolation boundary. Every machine and every operation belongs to exactly one tenant.

**DOM-1** A tenant identifier MUST be 1–128 characters of ASCII letters, digits, `.`,
`_`, `:`, or `-`.

**DOM-1a** **SETTLED by `ADR-0002`: the system maintains a tenant registry.** It owns tenant
records and their lifecycle — create, suspend, resume, delete, credential replacement — because
self-serve enrolment requires a tenant writable at runtime. *The no-registry branch below is
withdrawn; it described one reference implementation, and keeping it as a live option produced
requirements written for a deployment shape this product does not have.*

- **No registry — WITHDRAWN by `ADR-0002`, kept here as the record of what was rejected.** Tenant
  identifiers are opaque; the set of tenants is whatever the
  configured credentials say (`API-4`). Adequate when tenants are operator-configured and few.
  Consequence: nothing can verify that a tenant identifier arriving in a request names a real
  tenant — only that it is well-formed — so any front service passing tenants by header
  carries the entire tenancy boundary on an unverifiable string (`API-30`, itself withdrawn with
  the shape it described).
- **Registry — the chosen branch.** The system owns tenant records and their lifecycle: create, suspend, resume,
  delete, credential rotation, and a defined answer for what happens to a suspended tenant's
  running machines. Required for self-serve enrolment, because a new tenant must be writable
  at runtime. Cost: account lifecycle is a real subsystem inside the process holding provider
  credentials.

*Note: earlier revisions of this document asserted flatly that no registry is maintained. That
was a description of one reference implementation — whose tenants came from a config file —
promoted to a property of the domain. It is not one. A self-serve deployment needs a registry
by definition.*

### Provider account

A configured set of credentials for one provider, addressed by a stable operator-chosen
`account_id`. Multiple accounts of the same provider kind MAY be configured (for
example one per region or per billing entity).

**DOM-2** `account_id` MUST be unique across the whole configuration. Startup MUST fail
on a duplicate.

**DOM-3** A provider account is a *global* resource, not a tenant-owned one. Because the
credentials it holds can reach every machine in that provider account, authorization to
act on a machine MUST come from the machine record, never from the ability to name a
provider account. See `SEC-6`.

### Machine

A machine known to the control plane, identified by an internal UUID and mapped to a
provider-side `external_id`.

| Field | Notes |
|---|---|
| `id` | Internal UUID, the only identifier clients use in URLs |
| `tenant_id` | Owning tenant |
| `provider_account` | Which configured account manages it |
| `external_id` | Provider-side identifier |
| `name` | Provider-side name or hostname |
| `kind` | `virtual` \| `bare_metal` |
| `state` | See below |
| `region` | Provider-defined location string, nullable |
| `public_ips` | Ordered; the first entry is the address used for rescue SSH |
| `metadata` | Redacted provider payload, for operator debugging |
| `created_at`, `updated_at` | Timestamps |

**DOM-4** **AMENDED.** `(provider_account, external_id)` MUST be unique **across all tenants**
(`STO-17`) — not merely within one. *The original added `tenant_id` to the key and then observed
that this "does not prevent two tenants from mapping the same external machine"; `F15` established
that permitting it lets each tenant destroy the other's server, so `STO-17` closed it and this
requirement was left stating the hole.*

**DOM-5** Clients MUST address machines only by internal UUID. `external_id` MUST NOT
appear in a URL path constructed by the client.

**DOM-6** `metadata` MUST be redacted before storage. Any object key whose lowercased
form contains `password`, `secret`, or `private_key`, or equals `token`, `api_key`,
`authorization`, or `credential`, MUST have its value replaced with a redaction marker,
recursively through objects and arrays. This list is a floor, not a ceiling.

### Machine state

A normalized state, mapped by each driver from provider-specific status strings.

| State | Meaning |
|---|---|
| `requested` | Ordered but not yet allocated by the provider |
| `provisioning` | Being built, deployed, or migrated |
| `running` | Powered on and allocated |
| `stopped` | Powered off |
| `rescue` | Running the provider's rescue environment |
| `rebuilding` | Native rebuild or reimage in progress |
| `deleting` | Deletion accepted, not yet complete |
| `cancellation_scheduled` | Cancellation accepted for a future date. **Still running, still reachable, still billing.** |
| `deleted` | Gone, or locally tombstoned |
| `failed` | Provider reports a terminal failure |
| `unknown` | Driver could not map the provider status |

**DOM-7** A driver MUST map an unrecognized provider status to `unknown` rather than
guessing. `unknown` is a legitimate outcome and MUST NOT block an operation that does
not depend on state.

**DOM-19** A machine whose deletion was accepted for a future date (`PRV-13`'s second shape)
MUST be `cancellation_scheduled`, never `deleted`, until that date passes. Marking it
`deleted` at accept time records a falsehood: the machine is still running, the customer can
still reach it, and the operator is still paying for it. The effective cancellation date MUST
be stored alongside the state, and any system reselling the machine MUST treat the window
between acceptance and that date as continuing cost.

**DOM-8** Machine state is a *cache* of provider truth, refreshed by explicit refresh
operations and opportunistically after actions. The system MUST NOT treat it as
authoritative when deciding whether a destructive action is safe; that decision belongs
to the caller, expressed through the destructive acknowledgement (`API-14`).

### Offer

A purchasable configuration: a cloud server type, a standard dedicated product, or an
auction/market listing.

| Field | Notes |
|---|---|
| `id` | Driver-scoped offer identifier, opaque to clients |
| `name` | Human-readable |
| `kind` | `virtual` \| `bare_metal` |
| `regions` | Where the offer can be placed |
| `currency`, `hourly_price`, `monthly_price` | Nullable; prices are strings to avoid float rounding |
| `metadata` | Raw provider payload |

**DOM-9** Prices MUST be carried as strings exactly as the provider returned them.
Parsing them into floating point loses money.

Where a provider has more than one ordering channel, the driver SHOULD namespace offer
identifiers so the create path can route on them (for example `standard:` and `market:`
prefixes). This is a driver-internal convention; clients treat the identifier as opaque.

### Operation

A durable record of one requested mutation. This is the central entity of the system;
see `03-operation-lifecycle.md`.

### Rescue session

Ephemeral connection details for a provider's rescue environment: address, port,
username, authentication material, any host keys the provider published, an opaque
cleanup token, and an optional expiry.

**DOM-11** A rescue session carries a live credential. It MUST NOT be persisted, MUST
NOT be logged, and MUST NOT appear in an operation result or error. Its in-memory
representation MUST redact the credential in any debug or display formatting, and
SHOULD zero the credential when dropped.

**DOM-12** **WITHDRAWN — folded into `DOM-11`**, which already prohibits persisting a rescue
session at all. A round-trip rule for a type that must never be serialized was specifying the
behaviour of a path the same document forbids. *`DEF-9`'s defect stands as a prohibition.*

## Image sources and installation strategies

The two are separate axes. An *image source* says what to install; a *strategy* says
how to get it onto the disk.

| Image source | Fields |
|---|---|
| `catalog` | `image` — a provider catalog identifier |
| `rootfs_tarball` | `url`, `sha256`, `format` (`tar`, `gzip`, `bzip2`, `xz`, `zstd`) |
| `raw_disk` | `url`, `sha256`, `compression` (`none`, `gzip`, `xz`, `zstd`, `bzip2`) |
| `ipxe` | `script` |
| ~~`iso`~~ | **WITHDRAWN 2026-08-12** — see `DOM-22` |

| Strategy | Meaning |
|---|---|
| `rootfs_via_rescue` | Boot rescue, fetch a root filesystem archive, run the provider's OS installer with a generated layout config |
| `raw_disk` | Boot rescue, stream a raw image to a named block device |
| `provider_native` | Use the provider's own rebuild or boot API |

**DOM-13** Only these pairings are valid; everything else MUST be rejected with an
invalid-request error before the operation is enqueued:

| Strategy | Valid image sources |
|---|---|
| `rootfs_via_rescue` | `rootfs_tarball` |
| `raw_disk` | `raw_disk` |
| `provider_native` | `catalog`, `ipxe` (~~`iso`~~ withdrawn, `DOM-22`) |

A valid pairing is necessary and not sufficient. Capabilities are per **provider account**
(`DOM-10`), but rescue-install eligibility is a property of the **offer** — an auction listing and
a standard product at the same provider can differ — so the offer's `install_strategies`
(`13-wire-contract.md`, `WIR-30`) gates this table as well, and a strategy absent from it MUST be
rejected the same way.

**DOM-14** A digest MUST be required for `rootfs_tarball` and `raw_disk`, and MUST be
exactly 64 hexadecimal characters, compared case-insensitively.

## Capability model

Capabilities are the contract between clients and drivers. A driver declares the set of
things it actually supports operationally — not the set of things the provider's API
documents.

| Capability | Grants |
|---|---|
| `provision_virtual` | Creating virtual machines |
| `provision_bare_metal` | Creating/ordering dedicated machines |
| `adopt_existing` | Importing an existing machine under management |
| `delete_machine` | Deleting/cancelling a machine |
| `power_control` | Power on, power off, soft reboot |
| `hard_reset` | Out-of-band hard reset |
| `native_rebuild` | Rebuild from the provider catalog |
| `rescue_ssh` | Activating a rescue environment reachable over SSH |
| `install_rootfs_via_rescue` | The provider's OS installer accepts a root filesystem archive |
| `install_raw_disk_via_rescue` | A raw image can be streamed to a block device in rescue |
| ~~`custom_ipxe`~~ | **DEFERRED from v1** by the `DOM-22` precedent — no launch driver declares it |
| `list_offers` | Enumerating purchasable offers (`DOM-22`) |
| `reverse_dns` | Setting PTR records for assigned addresses |

**DOM-10** Every operation MUST be gated on the corresponding capability before the
driver is called, **including create**. There MUST be no operation whose only gate is
a driver-internal check. A capability check failure MUST return an "unsupported" error
naming the provider account and the capability.

Mapping from operation to required capability:

| Operation | Required capability |
|---|---|
| create machine, `kind = virtual` | `provision_virtual` |
| create machine, `kind = bare_metal` | `provision_bare_metal` |
| adopt | `adopt_existing` |
| refresh | none — every driver MUST implement machine lookup |
| power on/off/reboot | `power_control` |
| hard reset | `hard_reset` |
| install, `provider_native` + `catalog` | `native_rebuild` |
| install, `provider_native` + `ipxe` | `custom_ipxe` |
| list offers | `list_offers` |
| preflight | `rescue_ssh` (`RSC-38` boots rescue to read the inventory) |
| install, `rootfs_via_rescue` | `install_rootfs_via_rescue` |
| install, `raw_disk` | `install_raw_disk_via_rescue` |
| reverse DNS | `reverse_dns` |
| delete | `delete_machine` |

**DOM-22** Three edits to the capability model on 2026-08-12, closing the rest of `F10`:

- **`remote_console` is withdrawn.** Console proxying is a stated non-goal (`00-overview.md`),
  so the capability had no operation behind it and never could — a declared capability with no
  reachable code path is exactly what `DOM-15` calls a defect.
- **`attach_iso` and the `iso` image source are withdrawn from v1.** No driver operation for
  attaching boot media was ever specified, and no launch-set provider (`ADR-0010`) exposes
  arbitrary caller-supplied ISO attachment. The pairing returns only with a specified driver
  operation behind it.
- **`list_offers` is added.** The offers endpoint previously documented itself as having no
  capability, which contradicted `OVR-2`'s rule that capability is discoverable rather than
  inferred — a caller had no way to know whether an empty offer list meant "nothing for sale"
  or "cannot enumerate".

**DOM-15** A capability that is declared but whose code path returns "unsupported" is a
defect. Declaration and implementation MUST agree; the conformance checklist tests this
(`10-conformance-checklist.md`).

**DOM-16** Ordering capabilities (`provision_virtual`, `provision_bare_metal`) for
providers that bill per order SHOULD be conditional on an explicit per-account
`allow_orders` configuration flag, so that a misconfigured deployment cannot spend
money. This is in addition to, not instead of, the per-request purchase acknowledgement
(`API-15`).

## Error taxonomy

One closed set of error kinds, used by drivers, the rescue engine, and the API alike.

| Kind | Meaning | HTTP |
|---|---|---|
| `invalid_request` | Caller error, deterministic | 400 |
| `not_found` | Named resource does not exist | 404 |
| `conflict` | State or idempotency conflict | 409 |
| `unsupported` | Capability not declared or not implemented | 501 |
| `authentication` | Caller or provider credential rejected | 401 |
| `rate_limited` | Caller or provider throttled | 429 |
| `provider` | Provider returned an error response | 502 |
| `network` | Transport failure reaching the provider | 502 |
| `timeout` | Operation exceeded its deadline | 502 |
| `integrity` | Digest or host-key verification failed | 422 |
| `internal` | Defect in this system | 500 |
| `insufficient_balance` | Available balance cannot fund the required commitment (`LDG-9`) | 402 |
| `not_activated` | Tenant exists but is still pending funding (`API-35`) | 403 |
| `halted` | Refused because a solvency or rate-availability gate is failing (`LDG-20`, `LDG-40`) | 503 |
| `gone` | Resource existed and was removed by retention (`STO-14`, `STO-33`) | 410 |
| `suspended` | Tenant is suspended; only the maintenance actions remain (`API-58`) | 403 |

**DOM-21** The `gone` row was added 2026-08-12, by the append-only rule rather than by a handler
inventing a status. A caller polling an operation id past the retention horizon would otherwise
receive `not_found` — indistinguishable from "never existed," which for an autonomous caller
suggests the write was lost and invites a re-send. `gone` says the opposite: it existed, it
reached a terminal state, and the record aged out; the safe reaction is to consult the machine
list and balance, never to re-issue.

**DOM-20** Five rows in the table above were added after the original taxonomy was written:
`insufficient_balance`, `not_activated` and `halted` by this requirement, `gone` by `DOM-21`, and
`suspended` by `API-58`. `DOM-17`'s set is closed and `API-24`
forbids a handler choosing a status independently, so before the first three existed **four BLOCKING
conformance items asserted a rejection this taxonomy could not express** — `CNF-95` (insufficient
balance), `CNF-78` (tenant still pending), `CNF-69` (ceiling), `CNF-101` (solvency halt) — and
every one of them would have arrived at the caller as `invalid_request` / 400.

That distinction matters more here than in an ordinary API. The caller is an autonomous agent,
and **"top up" and "fix your request" are different actions.** Collapsing them means a correctly
formed create that merely needs money is indistinguishable from a malformed one, so the agent's
only recovery is to mutate its request and retry — which is how a retry loop becomes a duplicate
purchase.

**DOM-17** Every error MUST carry a kind, a human-readable message, a boolean
`retryable`, and a structured `details` object. `retryable` describes whether repeating
the *same request* is safe and sensible. **It is normative guidance to callers** (`API-51`) —
never authorization for an automatic service retry, and no substitute for `API-19`'s operator-only
requeue. It MUST NOT be
used by the system to retry automatically (`OPS-12`).

**DOM-18** `details` MUST be redacted with the same rules as `DOM-6` before it is stored
or returned. In particular, a provider response body captured into `details` MUST be
redacted regardless of whether the response was a success or a failure. See `DEF-3`.
