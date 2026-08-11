# 08 — Provider adapter notes

Facts about specific provider APIs that shaped the architecture and are worth carrying
forward. **These were read out of a reference implementation's adapters, not verified
against live provider APIs.** Each note carries a confidence marker:

- **[design]** — an architectural consequence, true regardless of API details.
- **[observed]** — asserted by the reference implementation; plausible but unverified.
- **[verify]** — must be checked against current provider documentation before use.

Every adapter MUST answer the questions in "Adding a driver"
(`02-provider-contract.md`) before it is considered complete, and record the answers
here. The per-provider sections below are structured around them.

## Capability matrix

The shape the reference implementation arrived at, as an illustration of how unevenly
providers cover the model. Reproduce this table for whatever providers you implement.

| Capability | Cloud VPS | Dedicated (robot-style) | Dedicated (cherry-style) |
|---|:--:|:--:|:--:|
| List offers | yes | yes | yes |
| Create | yes | opt-in ordering | opt-in ordering |
| Adopt | yes | yes | yes |
| Delete | yes | yes (usually immediate) | yes |
| Power control | yes | yes | yes |
| Hard reset | yes | yes | **no** |
| Native rebuild | yes | **no** | yes |
| Rescue SSH | yes | yes | yes |
| Raw disk via rescue | yes | yes | yes |
| Rootfs archive via rescue | **no** | yes | **no** |
| Custom iPXE | no | no | yes |
| Reverse DNS | no | yes | no |

The lesson to preserve: **there is no useful intersection.** Every column has at least
one gap another column fills. This is why capability discovery (`DOM-10`, `OVR-2`) is
load-bearing rather than decorative.

---

## Cloud VPS providers (Hetzner Cloud shape)

**Auth** — bearer token. **[observed]**

**Key material at create time** — SSH keys must exist as account-level resources and are
referenced by id at create. The key material is copied into the new server during
creation, so the temporary key resource can be deleted immediately after the create call
returns. **[verify]** — this is the assumption that makes immediate cleanup safe
(`PRV-9`); confirm it before relying on it.

**Rescue host keys** — not exposed through the API. **[observed]** Consequence: callers
MUST supply `expected_rescue_host_keys` out of band or explicitly accept first-use trust
(`SEC-23`).

**Rescue activation** — enable-rescue action, then a separate reset action to boot into
it. Enable-rescue returns a root password even when SSH keys were supplied; the
implementation ignores it. **[observed]** Ignoring it is correct — see `PRV-8`, and note
that capturing it would violate `SEC-3`.

**Rebuild** — the rebuild endpoint takes an image but has no field for SSH keys, so the
reference adapter injected keys and any post-install payload through first-boot user
data. **[observed]** This is exactly the case `PRV-23` is about: it silently requires the
target image to run a first-boot agent, and it collides with a caller-supplied
first-boot payload. Document it or don't do it.

**Deletion** — a real API call. **[observed]**

**Status vocabulary** — running / off / starting / initializing / migrating / stopping /
deleting / rebuilding / unknown. Map to `DOM-7`. **[observed]**

---

## Dedicated servers, robot-style (Hetzner Robot shape)

**Auth** — HTTP basic. Request bodies are form-encoded, not JSON. **[observed]** Note
that this means the HTTP client needs URL-encoded form support; check that the
dependency actually provides it before pinning the feature flag — the reference
implementation named a feature that did not exist and never compiled (`DEF-14`).

**Ordering** — two distinct channels, a standard catalog and an auction market, each with
its own product-listing and order-transaction endpoints. Offer identifiers must be
namespaced so the create path can route (`DOM-9` note). Orders are transactions polled to
`ready` / `cancelled` / `in process`. **[observed]**

**Ordering is not idempotent.** A timed-out order poll MUST NOT be retried blindly
(`PRV-11`). **[design]**

**Key material** — SSH keys are account-level resources identified by fingerprint;
temporary keys are created, attached to the order or the rescue activation, and deleted
afterwards. **[observed]**

**Rescue host keys** — published in the rescue activation response and in a
"last rescue" lookup. **[observed]** This is the only provider in the reference set that
supports pinning without out-of-band material, and it is why `PRV-19` (refresh) exists.

**Rescue activation** — enable rescue with an authorized key fingerprint, then an
out-of-band hard reset to enter it. Exiting is disable-rescue plus another hard reset.
**[observed]**

**OS installer** — the rescue environment ships an installer that consumes a root
filesystem archive plus a generated config file (drives, RAID, partitions, hostname,
bootloader, image path, authorized-keys source, optional post-install script). This is
the `install_rootfs_via_rescue` capability. **[verify]** — the exact config keys, and in
particular the directive that prevents the installer from copying rescue authorized keys
into the installed system (`RSC-12`), MUST be checked against the current installer
source. The reference implementation emitted a specific directive name that was not
independently verified.

**Deletion** — **usually immediate.** Current standard (AX/EX/SX/DX/GEX) and auction dedicated
servers have **no minimum term**. `POST /server/{server-number}/cancellation` with
`cancellation_date=now` cancels immediately, and billing is hourly rounded up with a monthly
cap — the same shape as the cloud product, not term billing. The per-server
`earliest_cancellation_date` reflects that individual server's contract and is normally *today*
for a newly ordered machine. **[observed — verified against current Hetzner product pages and
the Robot cancellation guide, 2026-08-08]**

Consequences for a reseller: the delete-stops-cost arrow that hourly metering depends on
genuinely exists here, so no separate term SKU is needed. The **setup fee** is the real prepaid
exposure — commonly charged on standard servers, undocumented as refundable, so treat it as
non-refundable and collect it before ordering. Auction servers carry no setup fee.

**The exception branch is real and adoption is its main road.** Hetzner states cancellation
periods depend on the individual contract, so a machine you *adopted* carries whatever terms it
came with. Two things remain **[verify]**: the universal worst case across legacy and custom
contracts, and what `cancellation_date=now` does against a server whose earliest date is in the
future — rejection, or automatic scheduling. **A driver MUST handle both**: on rejection, fall
back to scheduling at the earliest permitted date; on auto-scheduling, `DOM-19` already models
the result. Never assume; read `earliest_cancellation_date` and branch (`PRV-13c`).

> *Two corrections to this one fact, recorded because the pattern matters more than the fact.*
> *Revision 1 said Robot has no cancellation API and termination is a contract process — wrong.*
> *Revision 2 said deletion is a scheduled cancellation with a period-long tail requiring a*
> *period-sized deposit — also wrong for current servers; the "30 days to end of month" figure*
> *is a documented fallback for individual contracts that still appears on some obsolete product*
> *pages. A specification, a reviewing model and a researching model each asserted different*
> *terms for the same provider. Two of the three were wrong. This is why `PRV-13c` forbids*
> *encoding commercial terms as constants.*

**Reverse DNS** — supported. **[observed]**

**Reselling, abuse and custom images** — checked against Hetzner's published terms 2026-08-08:

- Reselling is **expressly permitted** (ToS §7.1 allows granting third parties contractual use).
  The operator remains Hetzner's sole counterparty and is fully liable for compliance and
  resulting damages. **[observed]**
- **Anonymous downstream customers: [verify].** The published terms neither require the
  reseller to identify every end user nor affirmatively bless not doing so.
- Routine abuse handling targets the offending IP after notice, deadline and manual review —
  **but that is not an isolation guarantee.** The ToS (§§2.7, 5.2, 8.3–8.4) and System Policies
  reserve the right to lock or terminate the offending server, the operator's services, **or the
  account**. Contractually, one abusive tenant can expose every tenant on the account
  (`SEC-41`). **[observed]**
- Customer-supplied OS images on dedicated hardware are **expressly allowed** via `installimage`,
  KVM/ISO or USB, with no support or compatibility warranty. Inherited prohibitions a reseller
  must pass on (`SEC-42`): no manual MAC changes, no scanning foreign networks, no source-IP
  spoofing, no cryptocurrency mining. Windows: a customer may bring its own licence but must not
  combine it with a Hetzner-leased Windows licence. **[observed]**

**Status vocabulary** — ready / in process. Everything else maps to `unknown`.
**[observed]**

---

## Dedicated servers, project-scoped (Cherry Servers shape)

**Auth** — bearer token. Server creation is scoped to a configured project id.
**[observed]**

**Key material at create time** — servers deploy asynchronously. Whether key material is
captured at request time or read later from the account-level key resource is **[verify]**
and matters a great deal: the reference implementation deleted the temporary keys
immediately after issuing the deploy and the rebuild, which if the deploy reads them
later produces machines nobody can log into (`PRV-9`, `DEF-6`).

**Rescue host keys** — not exposed. **[observed]**

**Rescue authentication** — password-based. The provider's enter-rescue-mode action takes
a caller-generated password; there is no key-based rescue. **[observed]** The reference
adapter accepted the ephemeral public key from the engine and then ignored it, which is
prohibited by `PRV-17`. Combined with the absence of host keys, first-use trust here
exposes a live root password (`SEC-24`).

**Hard reset** — not available; power actions are power-on / power-off / reboot only. The
adapter must return `unsupported` rather than substituting a reboot (`PRV-14`).
**[observed]**

**iPXE** — supported, script base64-encoded into a rebuild-shaped action. **[verify]** —
whether an iPXE boot really is a rebuild action variant, and whether it requires an image
alongside, should be confirmed.

**User data** — base64-encoded by the API contract. **[observed]**

**Rebuild** — an action with image, hostname, ssh keys, user data, and provider-specific
disk and RAID options passed through. **[observed]**

**Deletion** — a real API call. **[observed]**

---

---

## Correlators: the caller-controlled identifier each provider offers

Checked 2026-08-11, because `OPS-27` reconciliation depends on being able to ask a provider
*"did my lost request create anything?"* and get an answer that names the specific operation
rather than a machine that merely looks similar. **Every provider in this set offers a
caller-controlled field**, and three of the four can filter on it server-side.

| Provider shape | Field carried at create | Shape | Find it afterwards | Confidence |
|---|---|---|---|---|
| Hetzner Cloud | `labels` | `map[string]string` | `label_selector` query parameter on list | **[observed — official `hcloud-go` client, `ServerCreateOpts.Labels` and `ListOpts.LabelSelector` → `label_selector`]** |
| Hetzner Robot | `comment` on the order | free text | `GET /order/server/transaction` and `/order/server_market/transaction` list **recent** transactions; `/{id}` fetches one | **[observed — endpoint list and `hrobot-rs` `list_recent_product_transactions()`]** |
| Cherry Servers | `tags` | `map[string]string` | returned on the server object | **[observed — official `cherrygo` client]**; server-side filtering **[verify]** |
| DigitalOcean | `tags` | `[]string` — flat strings, **not** key/value | `ListByTag` | **[observed — official `godo` client]** |

Notes that change driver code:

- **DigitalOcean tags are not key/value.** Encode the correlator as a single string with a fixed
  prefix. The permitted character set is **[verify]** before choosing a separator.
- **Robot's correlator does not live on the machine.** It goes on the order, and the resulting
  server carries no caller field at create — `server_name` is settable only afterwards, via
  `POST /server/{server-number}`, which is precisely the follow-up call `PRV-26` forbids relying
  on. So Robot reconciles through the transaction list, not through machine search.
- **Robot's transaction listing is time-bounded** — the client library documents the last 30
  days. **[verify]** the exact window, because it is the hard limit on how long an unresolved
  ambiguous order stays automatically recoverable. After it, resolution is manual.
- Hetzner Cloud's label constraints (key/value character set, length, count) are **[verify]** —
  the Go client performs no validation of its own, so the server enforces whatever it enforces.

A pleasing incidental confirmation: Robot's order request carries a field literally named
`i_want_to_spend_money_to_purchase_a_server`. `API-15`'s explicit purchase acknowledgement is not
this specification being paranoid — it is a pattern the provider itself arrived at.

## Writing a new adapter

Answer these before writing code, and record the answers here:

1. **Does key material get copied at create/rebuild time, or read asynchronously later?**
   Determines whether temporary key cleanup is safe immediately (`PRV-9`).
2. **Does the provider publish rescue SSH host keys, and if so, when — at activation, or
   only after the rescue system boots?** Determines whether pinning works without
   out-of-band material, and how long the refresh loop must wait (`PRV-16`, `RSC-9`).
3. **Which of `PRV-13`'s three deletion shapes is this — immediate destroy, scheduled
   cancellation, or an out-of-band process?** Determines whether `delete_machine` may be
   declared, and whether "deleted" means "billing stopped." For scheduled cancellation, find
   the provider's earliest-permitted-date field.
3a. **What else keeps billing after the machine is gone?** Volumes, snapshots, backups,
   reserved addresses (`PRV-13a`).
4. **Is rescue key-based or password-based?** Determines whether first-use trust should be
   permitted for this provider at all (`SEC-24`).
5. **Is ordering idempotent?** Determines the requeue policy for creates (`OPS-20`).
6. **What is the identifier character set?** Determines the validation in `PRV-6`.
7. **Which caller-controlled field can carry a correlator at create, and can you search by
   it?** Determines whether ambiguous creates resolve automatically or wait for a human
   (`PRV-26`, `PRV-27`, `OPS-27`). If the field lives on an order rather than the machine,
   record the listing window too — it bounds how long automatic recovery is possible.
