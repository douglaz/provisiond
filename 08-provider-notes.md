# 08 — Provider adapter notes

**This document carries no value the engine reads.** The declaration list belongs to `PRV-44`:
"A value the engine reads MUST come from here and never from `08-provider-notes.md`". A driver
that declares a value here and not in its descriptor has declared nothing (`ADR-0018`).
*Descriptor pointer amended 2026-10-08 (`ADR-0037`).* What lives here is why a
descriptor says what it says: the provider facts that shaped the architecture and are worth
carrying forward. **Provenance is per fact, not per document**: many notes were read out of a
reference implementation's adapters and never checked, several have since been verified against
current provider documentation and carry the date, and the DigitalOcean section below came from
neither — the reference set had no such driver. Each note carries a confidence marker, and the
marker on the individual note governs:

- **[design]** — an architectural consequence, true regardless of API details.
- **[observed]** — asserted by the reference implementation; plausible but unverified.
- **[verify]** — must be checked against current provider documentation before use.

Every adapter answers the questions in "Adding a driver" (`02-provider-contract.md`) before it is
considered complete: the answers the engine reads go in the descriptor, and the reasoning behind
each goes here. The per-provider sections below are structured around them.

## Capability matrix

The shape the reference implementation arrived at, as an illustration of how unevenly
providers cover the model. A driver's own row is its descriptor's `capabilities` (`PRV-44`); this
table is not read by anything.

| Capability | Cloud VPS | Dedicated (robot-style) | Dedicated (cherry-style) |
|---|:--:|:--:|:--:|
| List offers | yes | yes | yes |
| Create | yes | opt-in ordering | opt-in ordering |
| ~~Adopt~~ | — | — | — |
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

**Traffic allowance and overage** — **[documented 2026-10-07 — `ADR-0039`'s
provider-document and account-price reading; live counter freshness [verify]]**.
The included outbound allowance depends on location: the cited EU account price has
20 TiB, US locations at least 1 TB and AP locations at least 0.5 TB. Hetzner
charges overage in 100 MB blocks; the cited EU account price was $1.20/TB.
The counter's update interval is undocumented. These are documentary readings,
not live observations or permission to sell a Cloud offer. `ADR-0039` owns the
sale decision and the live-evidence condition.

**Auth** — bearer token. **[observed]**

**Key material at create time** — HC-spec says SSH key ids or names are injected at creation.
**[observed — HC-spec, 2026-10-06]** The create Action reaching `success` and the reset that
boots rescue are consumption-timing candidates; deletion during either interval remains
**[verify]** (research V2). Deletion eligibility: `PRV-9` (`ADR-0040`). `POST /ssh_keys` requires a caller-set `name` and accepts `labels`; `GET /ssh_keys`
supports `name` and `label_selector` filters. **[observed — HC-spec, 2026-10-06]** The sweep
may use the selector. A duplicate fingerprint is rejected. Generated rescue/correlator keys
remain fresh; caller-supplied create keys are distinct and no substitute-key policy is inferred
(V3).

**Rescue host keys** — not exposed through the API. **[observed]** Consequence: callers
MUST supply `expected_rescue_host_keys` out of band or explicitly accept first-use trust
(`SEC-23`).

**Rescue activation** — enable-rescue action, then a separate reset action to boot into
it. Enable-rescue returns a root password even when SSH keys were supplied; the
implementation ignores it. **[observed]** Ignoring it is correct — see `PRV-8`, and note
that capturing it would violate `SEC-3`.

**Rescue activation when rescue is already enabled** — read `server.rescue_enabled` and, if true,
call `disable_rescue` before re-enabling. **[observed — HC-spec, 2026-10-06]** Rescue
automatically disables on first boot or after 60 minutes unused; reset must follow enable
within that interval. Repeated-enable behavior itself remains **[verify]** (V4).

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

**Traffic by uplink** — **[documented 2026-10-07 — `ADR-0039`;
counter behavior [verify] live]**. Robot's default dedicated 1 Gbit uplink
comes with unlimited traffic; its 10 Gbit uplink has a traffic allowance
(20 TB in the cited product reading) and cannot currently be sold under
`ADR-0039`. The documented counter counts a TCP stream only after it
disconnects. A held stream could therefore outrun a reading; live testing
must establish a usable freshness bound before an allowance offer is
re-admitted. No such test is claimed here.

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

**Key material** — Robot account keys carry caller-set `name` and fingerprint; `authorized_key[]` supplies fingerprints to orders. **[observed — Robot-WS, 2026-10-06]** In the 2026-10-11 auction order, the transaction still listed the fingerprint in `authorized_key[]` after deletion of the temporary key; batch B step 6 settles that observation (`docs/research/panels-2026-10/r39/live-result.txt`). `ADR-0040` retains the per-order fingerprint correlator, and `PRV-9` retains key deletion eligibility. A newly generated per-order correlator key is distinct from a caller's create key.

**Rescue host keys** — published in the rescue activation response and in a
"last rescue" lookup. **[observed]** This is the only provider in the reference set that
supports pinning without out-of-band material, and it is why `PRV-19` (refresh) exists.

**Rescue activation** — enable rescue with an authorized key fingerprint, then an
out-of-band hard reset to enter it. Exiting is disable-rescue plus another hard reset.
**[observed]**

**Rescue activation when rescue is already enabled** — read `GET /boot/{n}/rescue` for `active` and disable with `DELETE /boot/{n}/rescue` before re-enabling. **[observed — Robot-WS, 2026-10-06]** Repeated-enable behavior remains **[verify]** (V10).

**OS installer** — Robot installimage's generated config uses `SSHKEYS_URL` for caller keys and `TAKE_OVER_RESCUE_SYSTEM_SSH_PUBLIC_KEYS no` to exclude rescue keys. **[observed — installimage e15b5ea, 2026-10-06]** `RSC-12`/`RSC-13` own the obligation. Whether the deployed rescue installer matches that source remains **[verify]** (batch B, step 7).

**Deletion** — **usually immediate.** Current standard (AX/EX/SX/DX/GEX) and auction dedicated
servers have **no minimum term**. `POST /server/{server-number}/cancellation` with
`cancellation_date=now` cancels immediately, and billing is hourly rounded up with a monthly
cap — the same shape as the cloud product, not term billing. The per-server
`earliest_cancellation_date` reflects that individual server's contract and is normally *today*
for a newly ordered machine. **[observed — verified against current Hetzner product pages and
the Robot cancellation guide, 2026-08-08]**

Consequences for a reseller: the delete-stops-cost arrow that hourly metering depends on
genuinely exists here, so no separate term SKU is needed. The **setup fee** is the real prepaid
exposure — commonly charged on standard servers, undocumented as refundable, so treat it as non-refundable. For commitment and settlement, see `LDG-39`, including "an accepted but
unresolved create MUST take the `needs_reconciliation` pending-obligation row" (amended
2026-10-08, `ADR-0035`). Auction servers carry no setup fee.

**Measured against the live API 2026-09-04, because `LDG-39` calls the fee "unrecoverable" and the
set never stated a size.** Standard catalogue setup fees range **€59 to €1349 net** across 29
orderable products; the auction market's `price_setup` is **`0.0000` on all 156 offers**.
**[observed 2026-09-04]** That range is what a single lost standard order can cost, and it is the
reason a lost order on this channel is the most expensive event the system exposes. Two further facts
from the same pull: standard prices are a **per-location array** (`prices[]`, each entry carrying
its own `price` and `price_setup`) while auction prices are flat scalars, and two catalogue
products were listed with an **empty `prices[]`** — visible in the feed and not orderable. **The
driver therefore emits one offer per priced location and omits the empty ones** (`DOM-9`, added
2026-09-05).

**The exception branch is real.** Hetzner states cancellation periods depend on the individual
contract, so a machine carries whatever terms its contract has — which is why adoption, withdrawn
from v1 by `ADR-0020`, was this branch's main road while it stood. The documented standard cancellation worst case is "30 days to the end of the month" unless the individual contract says otherwise. **[observed — Hetzner cancellation docs, 2026-10-06]** What `cancellation_date=now` does against a future earliest date remains **[verify]**: it may reject or schedule. **A driver MUST handle both**: on rejection, fall
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
  combine it with a Windows licence rented from Hetzner. **[observed]**

**Status vocabulary** — ready / in process. Everything else maps to `unknown`.
**[observed]**

---

## Dedicated servers, project-scoped (Cherry Servers shape)

**Auth** — bearer token. Server creation is scoped to a configured project id.
**[observed]**

**Key material at create time** — Cherry deployment is asynchronous. Whether the account key is read at request time or later is **[verify]** (V19). `deployed`, or iPXE `allocated`, is a consumption-timing candidate only; `PRV-9`/`ADR-0040` controls deletion eligibility.

**Rescue host keys** — not exposed. **[observed]**

**Rescue authentication** — password-based. The provider's enter-rescue-mode action takes
a caller-generated password; there is no key-based rescue. **[observed]** The reference
adapter accepted the ephemeral public key from the engine and then ignored it, which is
prohibited by `PRV-17`. Combined with the absence of host keys, first-use trust here
exposes a live root password (`SEC-24`).

**Hard reset** — not available; power actions are power-on / power-off / reboot only. The
adapter must return `unsupported` rather than substituting a reboot (`PRV-14`).
**[observed]**

**iPXE** — script base64-encoded into a rebuild-shaped action, and also accepted at create. **[observed — Cherry-spec, 2026-10-06]** Whether an image is required alongside remains **[verify]**; Cherry-spec names the action `rebuild`, while cherrygo sends `reinstall`. Cherry remains outside v1 (V20).

**User data** — base64-encoded by the API contract. **[observed]**

**Rebuild** — an action with image, hostname, ssh keys, user data, and provider-specific
disk and RAID options passed through. **[observed]**

**Deletion** — a real API call. **[observed]**

---

---

## Cloud VPS, tag-based (DigitalOcean shape)

**Traffic pool and metrics** — **[documented 2026-10-07 — `ADR-0039`;
provider counter freshness and attribution [verify] live]**. DigitalOcean
pools included transfer at team level and quotes $0.01/GiB overage. Its
per-Droplet public metric is an Mbps time series, not a byte counter
attributed to that Droplet's share of the pool. Those documentary facts
do not establish how fresh a bound-enforcing counter would be. The
Droplet offers stay withheld under `ADR-0039` pending the live test.

**Added 2026-08-13, and its absence was a finding.** `ADR-0010` made DigitalOcean a **mandatory
launch driver** and this document had no section for it — while Cherry, which the same ADR cut
from v1, had a full one. Both reviewers called it the `F29` pattern with the ink still wet: a
launch decision resting on provider facts nobody had written down. **Everything below is
`[verify]` unless marked otherwise**, and the honest state is that this driver is the least
researched of the three.

**Auth** — bearer token, JSON bodies. The official Go client is `digitalocean/godo`.
**[observed — client library]**

**Correlator** — `tags`, a flat list of strings (not key/value, unlike Hetzner Cloud's labels),
filterable server-side via `ListByTag`. **[observed — `godo`]** Encode the operation UUID as a
single string with a fixed prefix. Tags permit `^[a-zA-Z0-9_\-\:]+$` up to 255 characters.
**[observed — DO-spec, 2026-10-06]** Use lowercase and `:` or `_` as a separator; tags are
case-stable. `PRV-48`: "It MUST NOT call `DELETE /v2/droplets?tag_name=` with a correlator tag".

**Deletion** — the delete reply and destroy are distinct; provider billing stops at destroy.
**[documented 2026-10-06 — `docs/research/provider-verify-2026-10.md`, V17 and §3]**
For customer meter boundaries see `LDG-38`/`LDG-74`; for accepted provider tails see `LDG-75`
and `ADR-0037`. **[observed — DO-spec, 2026-10-06]** Reserved IPs, floating IPs, snapshots, volumes and volume snapshots survive with `cleanup: api`; backups survive about four weeks with `cleanup: manual`, while billing after destroy remains **[verify]**. `PRV-13a`/`PRV-44` own the descriptor declaration; `PRV-13a` says "A DigitalOcean driver MUST NOT set `backups: true` on create".
*Billing interpretation amended 2026-10-08 (`ADR-0037`).*

**Rescue** — **SETTLED 2026-08-31: there is no API to enter it. The driver MUST NOT declare
`rescue_ssh`, `install_rootfs_via_rescue` or `install_raw_disk_via_rescue`.** **[observed —
live API probe and two independent documentation passes, 2026-08-31]**

The recovery environment exists and is SSH-reachable once running: DigitalOcean documents that
network and SSH are enabled automatically, that keys present on the droplet **at creation** are
imported, and that the rescue system presents different host keys. **SSH reachability was never the
blocker. Automated activation is** — booting from the recovery ISO is a control-panel action only.

The evidence, because `PRV-30`'s lesson is that absence of a documented side effect is not evidence
of absence, and this is the inverse claim:

- The documented droplet action types are `enable_backups`, `disable_backups`,
  `change_backup_policy`, `reboot`, `power_cycle`, `shutdown`, `power_off`, `power_on`, `restore`,
  `password_reset`, `resize`, `rebuild`, `rename`, `change_kernel`, `enable_ipv6`, `snapshot`. No
  recovery action appears. A grep of the published OpenAPI specification finds no occurrence of
  `recovery`, `rescue` or `iso` in any droplet context, and `godo`'s `DropletActionsService` exposes
  no such method.
- **Probed live:** `{"type":"enable_recovery"}` and `{"type":"recovery"}` both return
  `404 {"id":"not_found","message":"The specified action type is not available."}` against an
  unlocked, `active` droplet. Genuine unknown-action rejections rather than lock contention.
- No substitute exists: `rebuild` overwrites the disk rather than booting beside it, root disks are
  not detachable volumes, and `user_data` runs inside the normal OS on first boot.

`ADR-0013` records what follows — the differentiator survives here by the custom-image route
instead, so `ADR-0010`'s framing takes a caveat rather than a correction. **This closes `F32`.**

**Custom images — the differentiator's route on this provider.** **[observed — live end-to-end test,
2026-08-31]** `POST /v2/images` takes `{name, url, region}` and DigitalOcean **fetches** the URL;
there is no upload path in the public API. Formats raw/qcow2/VHDX/VDI/VMDK, gzip or bzip2, no ISO,
≤100 GB. `tags` is accepted on create and returned on the image object, which is what makes it
usable as `OPS-32`'s correlator. The image polls `NEW → pending → available`, and is then usable by
`POST /v2/droplets` or by a `rebuild` action.

- **The documented "same OS family" restriction on rebuild is not enforced by the API.** One droplet
  went `ubuntu-24-04-x64` → `fedora-43-x64` → a custom Alpine image registered as
  `distribution: "Unknown OS"`; both rebuilds returned `201`, both actions reached `completed` (28s
  and 16s), and the droplet's reported image changed each time. **Do not design around the API
  enforcing it** (`PRV-13c`).
- **A URL carrying a query string imported without difficulty** — 175 MiB reached `available` in
  ≤22 s. DigitalOcean's `?dl=0` warning is about hosts that need the parameter to serve the file,
  not about the importer parsing the URL. *`ADR-0013` re-hosts anyway, for integrity and to keep a
  signed URL away from a third party — not because of this.*
- **Guest requirements are strict:** BIOS only, ext3/ext4, cloud-init ≥0.7.7 with `ConfigDrive`
  ahead of `NoCloud`, `sshd` enabled. Without a supported init system the droplet gets no key and no
  network configuration and is unreachable, with no rescue path to fix it.
- **Storage bills at $0.06/GB/month** and images are account-wide — not a Projects resource, so
  there is no scoping below the team.

**Delete visibility — read-after-write is eventually consistent.** **[observed — n=1, 2026-08-31]**
`DELETE /v2/droplets/{id}` returned `204`; a `GET` 8 s later returned `200 "active"` with a live
address; `404` by the next poll, so this observation was under ~25 s. This is a **visibility**
sample only, not a measured bound or a billing-stop sample. The procedure belongs to `PRV-36`:
"the worst observed request-to-observation latency over at least twenty real mutations"; the
descriptor is `PRV-44` and observations are `STO-53`.
*Amended 2026-10-08 (`ADR-0037`): the separate billing-stop measurement obligation is withdrawn.*

**Image delete is not idempotent, and disagrees with the read path.** **[observed, 2026-08-31]**
First `DELETE /v2/images/{id}` → `204`. Second, immediately and again 2.5 minutes later → `422
{"id":"unprocessable_entity","message":"Can not delete an already deleted image."}`, never decaying
to `404`. `GET` on the same id at the same instant → `404`. Under `OPS-11`'s goal-state rule that
`422` is a **success**, and the driver MUST map it so.

**Key handling** — DO-spec documents key embedding at Droplet creation and that deleting an
account key leaves existing Droplet keys. **[observed — DO-spec, 2026-10-06]** In-flight
consumption timing remains **[verify]**; `active` is a timing candidate. Deletion eligibility:
`PRV-9` (`DEF-6`, `ADR-0040`).

**Account termination scope** — **[verify]** whether DigitalOcean links and terminates related
accounts together (`SEC-44`). `SEC-43`'s spread-tenants-across-accounts control is a belief until
this is answered for every provider it spans.

**What this section is for.** `OVR-14` makes DigitalOcean the proof that the driver contract
abstracts anything at all. That proof is only worth having if the driver is built against
recorded facts rather than assumptions about "the cloud shape" — which is exactly how the Robot
`comment` field survived three audits.

## Correlators: the caller-controlled identifier each provider offers

Checked 2026-08-11, because `OPS-27` reconciliation depends on being able to ask a provider
*"did my lost request create anything?"* and get an answer that names the specific operation
rather than a machine that merely looks similar. The provider field and retrieval method are
listed below. Robot's free-text candidate was disqualified by `PRV-30`; its per-order key
fingerprint is the correlator. Cherry has no documented server-side tag filter (V21).

| Provider shape | Field carried at create | Shape | Find it afterwards | Confidence |
|---|---|---|---|---|
| Hetzner Cloud | `labels` | `map[string]string` | `label_selector` query parameter on list | **[observed — official `hcloud-go` client, `ServerCreateOpts.Labels` and `ListOpts.LabelSelector` → `label_selector`]** |
| Hetzner Robot | ~~`comment`~~ **UNUSABLE** → per-order SSH key | key **fingerprint**, MD5-colon form (47 chars) | `GET /order/server/transaction` and `/order/server_market/transaction` list **recent** transactions; `/{id}` fetches one. **The two channels keep separate listings and a search of one is not a search of the provider; both list orders "within the last 30 days" [observed — Robot-WS, 2026-10-06]** | **`comment` CONFIRMED UNUSABLE** — comments require manual provisioning (`PRV-30`), and Hetzner's own parameter table says so. **Key substitute [observed 2026-09-04 — two real auction orders, two distinct fingerprints, each matching exactly one transaction]** (`PRV-32`). Standard channel still unconfirmed with a real order |
| Cherry Servers | `tags` | `map[string]string` | returned on the server object | **[observed — official `cherrygo` client]**; no documented server-side tag filter; page project list and filter client-side (V21) |
| DigitalOcean | `tags` | `[]string` — flat strings, **not** key/value | `ListByTag` | **[observed — official `godo` client]** |

Notes that change driver code:

- **DigitalOcean tags are not key/value.** Encode the correlator as a single string with a fixed
  prefix. Use lowercase tags, valid `:` or `_` separators, and the DO-spec character and length limits above. Never use `DELETE /v2/droplets?tag_name=` with a correlator tag (`PRV-48`).
- **Robot's `comment` field is confirmed unusable, 2026-08-13.** Hetzner states that supplying a
  comment on a standard or auction order sends it to **manual processing**. That is a
  decision-changing side effect (`PRV-30`), so the field is out — for correlation and for
  everything else. This was `F29`, carried as `[verify]` through three audits and now resolved
  against the design's assumption.
- **The substitute is a per-order throwaway SSH key** (`PRV-32`), whose fingerprint acts as the
  stamp, and **both conditions verified against client libraries on 2026-08-13 and against the live
  API on 2026-09-04 — auction channel only, standard still open (`F37`)**. The order transaction returns the
  authorized keys with fingerprints — `hrobot-rs` deserializes
  `#[serde(rename = "authorized_key")] authorized_keys: Vec<InitialProductSshKey>` where
  `InitialProductSshKey` carries `fingerprint`, and `appscode/go-hetzner` independently declares
  `Transaction.AuthorizedKey` → `AuthorizedKey.Fingerprint`. **[observed — two independent
  clients, 2026-08-13]** And `authorized_key[]` is structured, mandatory-in-effect data (the other
  arm of the auth choice is `password`), not free text, so a distinct value per order has no
  mechanism to summon a human the way a comment does.
- **Robot orders have a `test` mode, and this was missed until 2026-08-13.** Setting `test=true`
  makes the API **simulate** the purchase and return a `Cancelled` transaction. **[observed —
  `hrobot-rs` encodes the flag explicitly; `appscode/go-hetzner` declares `Test bool
  \`url:"test"\``]** It is useful for the order path and useless for the resolution path, and the
  distinction cost a real order to learn.

  **RESOLVED 2026-09-04 — a simulated transaction is NOT listed.** A `test=true` order returned
  `201` with `status: "cancelled"`, and both `GET /order/server/transaction` and
  `/order/server/transaction/{id}` then answered `404 NOT_FOUND "no transactions found"` for it.
  **[observed 2026-09-04]** So test mode covers request shape, authorization and the correlator
  being accepted — and none of the transaction listing, which is the half `PRV-32` exists for. The
  `[verify]` that stood here is answered in the direction that costs money: the listing half needs
  a real order (`PRV-34` amended, `F37`).

  **The cheap way to buy one is the auction channel**, where `price_setup` is `0.0000` across every
  offer and billing is hourly: two real auction orders placed and cancelled immediately on
  2026-09-04 cost about €0.16 in total. **[observed 2026-09-04]**
- **Robot's correlator does not live on the machine.** It goes on the order, and the resulting
  server carries no caller field at create — `server_name` is settable only afterwards, via
  `POST /server/{server-number}`, which is precisely the follow-up call `PRV-26` forbids relying
  on. So Robot reconciles through the transaction list, not through machine search.
- **Measured on two real auction orders, 2026-09-04.** Both were ordered, delivered and cancelled
  immediately; the account was returned to its prior state. **[observed 2026-09-04]**

  | What | Observed | Why it is recorded |
  |---|---|---|
  | `in process` → `ready` | **7 min 24 s** and **4 min 03 s** | `OPS-33` says robot-style orders "poll through an `in process` state with no documented bound". These are the first real numbers; they differ by nearly 2×, which is the argument against hard-coding one |
  | offer id vs server number | **identical, both times** — auction offer `3068756` became server `3068756`, `3068758` became `3068758`, and each listing left the feed on purchase | The auction market lists *specific machines*, not SKUs. The standard catalogue does not work this way. `PRV-42` records this observation; its separate admission rule says "At most one create may be in flight per `offer_is_resource` offer, across tenants." `ADR-0040` resolves lost replies by fingerprint |
  | `earliest_cancellation_date` on delivery | **same day**, both | Confirms the cancellation note above |
  | `reservation_possible` | `false` on both | The cancellation call takes a `reserve_location` parameter that is **mandatory** where reservation is possible. The planned delete path includes `GET /server/{id}/cancellation` first. Whether explicitly sending `reserve_location=false` succeeds without that pre-read remains **[verify]** (batch B); the mandatory branch was not exercised |
  | `server_ip` on delivery | **`null`** — no IPv4 | Hetzner's docs: "If you do not specify the parameter, the server will be ordered without an IPv4 address by default." `addon[]=primary_ipv4` is priced separately; `RSC-45` owns what a driver must do about it |
  | after cancellation | `GET /server/{n}` → `404 SERVER_NOT_FOUND`; account list back to its prior contents | Immediate destroy, no scheduled tail |
  | the transaction afterwards | **still `status: "ready", server_number: N`** while `GET /server/N` answered `404` | The listing outlives the machine; `PRV-43` owns the consequence |
  | `cancellation_reason` | provider advertises a 9-item enum and accepted the unlisted value `"Other"` | Do not model it as a closed set |

- **Auction add-on cancellation observed 2026-10-11 (`ADR-0037`, Q21/Q22).** Offer
  `3084954` was ordered with `addon[]=primary_ipv4` at 03:47:38Z and delivered as ready
  server `3084954` at 04:06:19Z (18 min 41 s). Equal offer/server identifiers add a V8
  observation, not an identity rule; `ADR-0040`'s correlator remains necessary. Before
  cancellation, `GET /server/{n}` returned its `ip` and `subnet`; account `GET /ip` and
  `GET /subnet` associated the main IPv4 and included /64 with that server. The runner read
  `GET /server/{n}/cancellation` before posting `cancellation_date=now` and
  `reserve_location=false`; Robot returned HTTP 200 and
  `cancellation_date: 2026-10-11`. The server and main/add-on IPv4 were absent at +1 second;
  the included /64 was checked absent at +20 seconds. `ADR-0037` records a subsequent
  45-minute IPv4 watch; the summary log contains only its initial lines and no minute-by-minute
  subnet watch. This is an API absence observation, not invoice billing evidence.
  Batch B step 9 is settled for this auction add-on only. The planned no-pre-read cancellation
  and reservation-possible branch, separately ordered IPs/subnets, catalogue orders,
  provider-initiated termination and invoice remain unverified. Robot's cancellation date zone
  is proposed as **`Europe/Berlin` [verify]**: the key's `created_at` in this transaction
  matches that zone's offset, but it does not verify the cancellation fields. `PRV-13` owns
  the effective-date conversion.

- **Ordering is rate-limited: 20 requests per day** on each documented order endpoint:
  `POST /order/server/transaction`, `POST /order/server_market/transaction` and
  `POST /order/server_addon/transaction`. Robot reports `403 RATE_LIMIT_EXCEEDED` with
  `max_request` and `interval`; cancellation is documented at 200 per hour.
  **[observed 2026-10-09 — Hetzner Robot webservice reference]** `PRV-40` owns the local gate.
  **[verify]** Whether Robot counts by account, webservice user or source address;
  whether its window rolls or resets by calendar day; whether rejected and `test=true`
  requests count; and whether requests after a 403 move the window. No live counting
  observation is claimed.

- **Robot endpoint limits.** The [Robot webservice reference](https://robot.hetzner.com/doc/webservice/en.html),
  retrieved 2026-10-10 and rechecked for the added paths 2026-10-11, documents the
  following method/path limits. These are documented limits, not measured shared counters
  or live availability guarantees.

  | Method and path in the reference | Documented request limit |
  |---|---|
  | `GET /server`; `GET /server/{server-number}` | 200 per hour, documented on each path |
  | `GET`, `POST`, `DELETE /server/{server-number}/cancellation` | 200 per hour, documented on each method |
  | `POST /reset/{server-number}` | 50 per hour |
  | `GET /order/server/transaction`, `GET /order/server/transaction/{id}`, `GET /order/server_market/transaction`, `GET /order/server_market/transaction/{id}`, `GET /order/server_addon/transaction`, `GET /order/server_addon/transaction/{id}` | 500 per hour, documented on each path |
  | `GET /boot/{server-number}` | 500 per hour |
  | `GET`, `POST`, `DELETE /boot/{server-number}/rescue`; `GET /boot/{server-number}/rescue/last` | 500 per hour, documented on each method/path |
  | `GET`, `POST`, `DELETE /boot/{server-number}/linux`; `GET /boot/{server-number}/linux/last`; `GET`, `POST`, `DELETE /boot/{server-number}/vnc`; `GET`, `POST`, `DELETE /boot/{server-number}/windows` | 500 per hour, documented on each method/path |
  | `GET /ip`, `GET /ip/{ip}`, `GET /subnet`, `GET /subnet/{net-ip}` | 5000 per hour, documented on each path |
  | `GET`, `POST`, `DELETE /ip/{ip}/cancellation`; `GET`, `POST /subnet/{net-ip}/cancellation`; `DELETE /subnet/{ip}/cancellation` | 200 per hour, documented on each method/path |

  **[verify]** For every row and every listed method/path: whether its count is per
  provider account, webservice user or source IP; whether server-number paths share a
  counter across machines; and whether distinct methods or paths share a counter.
  Reset's scope, including per-account versus per-server, is unknown. The separate
  order-POST daily limits above remain distinct. Batch B records the planned checks.

- **Three failed logins block the source IP for ten minutes, across the whole API** — not merely
  the endpoint that failed. **[observed 2026-09-04 — Hetzner Robot webservice documentation]**
  Authorization failures do not count toward it: four `401`s on `/order/*` left `/server` answering
  `200` immediately afterwards. **[observed 2026-09-04]** `PRV-41` owns the rule.

- **Ordering is a separate opt-in from the webservice user.** A `#ws+` webservice user authenticates
  against `/server`, `/key` and the rest while every `/order/*` path answers `401` until ordering is
  activated in Robot under *Administration → Settings → Web Service Settings → Ordering*.
  **[observed 2026-09-04]** A deployment can therefore hold credentials that manage machines and
  cannot order or reconcile them.

- **Robot's transaction listing is time-bounded** — both ordering channels document "within the last 30 days". **[observed — Robot-WS, 2026-10-06]** Rolling versus calendar alignment remains **[verify]**; for the automatic-recovery horizon, see `OPS-33`. After the listing horizon, unresolved orders go to operator resolution.
- Hetzner Cloud label key segments and nonempty values begin and end with an alphanumeric character; dashes, underscores and dots are allowed inside, and each is at most 63 characters. The `hetzner.cloud/` prefix is reserved. **[observed — HC-spec, 2026-10-06]** A UUID value fits. The label count remains **[verify]** (V5).

**A correction to an earlier note in this document, because the pattern matters more than the
fact.** It read: *"Robot's order request carries a field literally named
`i_want_to_spend_money_to_purchase_a_server`. `API-15`'s explicit purchase acknowledgement is not
this specification being paranoid — it is a pattern the provider itself arrived at."*

**The provider did not arrive at it.** That identifier is `hrobot-rs`'s *Rust field name*; the
wire parameter is plain `test`, as `appscode/go-hetzner`'s `Test bool \`url:"test"\`` shows.
The naming — and the `ImSeriousAboutSpendingMoney` enum around it — is the Rust author's joke, and
this document attributed a client library's API design to Hetzner. The underlying encouragement
stands and is arguably stronger: **hrobot-rs defaults to test mode**, so a caller must opt in to
spending money. `API-15` remains well-founded; it just has a different author than claimed.

## Writing a new adapter

Answer these before writing code. Where an answer is a value the engine reads, it goes in the
descriptor (`PRV-44`) and the reasoning goes here; the rest is recorded here:

1. **What evidence establishes key consumption timing, and can a temporary key carry an operation-id name or tag?** Record unmeasured timing as `[verify]`. Deletion eligibility: `PRV-9`. Ask whether duplicate caller fingerprints are rejected, without inventing a generated substitute. Keep a generated rescue/correlator key separate from the caller's create key.
2. **Does the provider publish rescue SSH host keys, and if so, when — at activation, or
   only after the rescue system boots?** Determines whether pinning works without
   out-of-band material, and how long the refresh loop must wait (`PRV-16`, `RSC-9`).
3. **Which of `PRV-13`'s three deletion shapes is this — immediate destroy, scheduled
   cancellation, or an out-of-band process?** Determines whether `delete_machine` may be
   declared, and whether "deleted" means "billing stopped." For scheduled cancellation, find
   the provider's earliest-permitted-date field; the worst case per offer is the descriptor's
   `cancellation_bound` (`PRV-31`).
3a. **What else keeps billing after the machine is gone?** Volumes, snapshots, backups,
   reserved addresses — the descriptor's `surviving_attachments`, each with whether the API can
   release it (`PRV-13a`, `PRV-45`).
4. **Is rescue key-based or password-based?** Determines whether first-use trust should be
   permitted for this provider at all (`SEC-24`).
4a. **What does enable-rescue do on a machine already in rescue — error, or re-arm it?** A machine
   can already be there: after an engine crash `RSC-19` says "The route back is to activate rescue
   again", and an install dispatched at a machine an earlier operation left in rescue arrives the
   same way. Determines whether that route exists on this provider, or whether the second operation
   instead fails at activation, leaving `PRV-18`'s "clean up after itself on partial failure" to
   handle what it can; temporary-key deletion follows `PRV-9` (`PRV-15`, `RSC-38`).
5. **Is ordering idempotent?** Determines how a timed-out order is reported (`PRV-11`).
6. **What is the identifier character set?** Determines the validation in `PRV-6`.
7. **Which caller-controlled field can carry a correlator at create, per ordering channel, and
   can you search by it?** Determines whether ambiguous creates resolve automatically or wait
   for a human (`PRV-26`, `PRV-27`, `OPS-27`), and is the descriptor's `ordering_channels[].correlator`
   (`PRV-33`, `PRV-38`). If the field lives on an order rather than the machine, record the listing window and leave a margin for unknown alignment. For `offer_is_resource`, the offer names one machine; `ADR-0040` still resolves by per-order fingerprint and the matched transaction's delivered number.
8. **Does a newly ordered machine have an IPv4 address?** The descriptor's
   `rescue_address_family` (`RSC-45`).

## Written provider inquiries (not sent)

The authoritative inquiry list is in `docs/research/provider-verify-2026-10.md`, *Written inquiries*. It covers anonymous downstream customers (V13), linked account termination (V22–V24), auction identity (V8; nonblocking under `ADR-0040`), Cherry ToS §17.4, and Cloud `server.locked` (`ADR-0038`). All remain `[verify]`; no response is claimed.

## Survivor declarations from provider research

`PRV-13a` holds the declaration table and `PRV-44` owns its descriptor field. The source
evidence is research §3 (2026-10-06). The 2026-10-11 auction order found its `primary_ipv4`
add-on and included /64 absent after cancellation; separately ordered Robot Additional IP
and subnet survival remains `[verify]`. DigitalOcean backup billing after destroy remains
`[verify]`. Cherry remains
outside v1; its survivor uncertainty is in research §3.
