# 08 — Provider adapter notes

**This document carries no value the engine reads.** Every declaration the engine turns on —
capabilities, ordering channels and their correlators, evidence sources, the visibility and
billing-stop windows, the order budget, the cancellation bound, the rescue address family, the
attachments that survive deletion — lives in the driver's descriptor (`PRV-44`), and a driver
that declares it here and not there has declared nothing (`ADR-0018`). What lives here is why a
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
exposure — commonly charged on standard servers, undocumented as refundable, so treat it as non-refundable, **commit it before ordering and debit it only on confirmed
acceptance** (`LDG-39`). Auction servers carry no setup fee.

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
  combine it with a Windows licence rented from Hetzner. **[observed]**

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

## Cloud VPS, tag-based (DigitalOcean shape)

**Added 2026-08-13, and its absence was a finding.** `ADR-0010` made DigitalOcean a **mandatory
launch driver** and this document had no section for it — while Cherry, which the same ADR cut
from v1, had a full one. Both reviewers called it the `F29` pattern with the ink still wet: a
launch decision resting on provider facts nobody had written down. **Everything below is
`[verify]` unless marked otherwise**, and the honest state is that this driver is the least
researched of the three.

**Auth** — bearer token, JSON bodies. The official Go client is `digitalocean/godo`.
**[observed — client library]**

**Correlator** — `tags`, a flat list of strings (not key/value, unlike Hetzner Cloud's labels),
filterable server-side via `ListByTag`. Encode the operation UUID as a single string with a fixed
prefix. The permitted character set is **[verify]** before a separator is chosen.
**[observed — `godo`]**

**Deletion** — believed immediate destroy with billing stopping at deletion, the cloud shape.
**[verify]** — and specifically **[verify]** what survives: volumes, snapshots and reserved IPs
are separately billable resources on this provider, so `PRV-13a`'s attachment model is likely to
matter *more* here than on Hetzner Cloud, not less.

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
address; `404` by the next poll, so the window was under ~25 s. **`PRV-36` governs**, and this is a
**visibility** sample only — `PRV-13b`'s delete-to-billing-stop figure for this provider is still
unmeasured and still owed. One sample is not a bound: the descriptor's `visibility_window` and
`billing_stop_window` (`PRV-44`) hold the declared values, conservative and marked unmeasured
until twenty samples exist, and `STO-53` holds the samples the engine collects afterwards.

**Image delete is not idempotent, and disagrees with the read path.** **[observed, 2026-08-31]**
First `DELETE /v2/images/{id}` → `204`. Second, immediately and again 2.5 minutes later → `422
{"id":"unprocessable_entity","message":"Can not delete an already deleted image."}`, never decaying
to `404`. `GET` on the same id at the same instant → `404`. Under `OPS-11`'s goal-state rule that
`422` is a **success**, and the driver MUST map it so.

**Key handling** — **[verify]** whether SSH keys are copied at droplet creation or read later
(`PRV-9`, `DEF-6` — the defect that produced a machine nobody could log into).

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
rather than a machine that merely looks similar. **Every provider in this set offers a
caller-controlled field** — **and that turned out to be wrong for Hetzner Robot** (see below), the
one product where a lost order costs a physical server and a non-refundable setup fee. Three of the
four offer a usable field and can filter on it server-side; Robot's only candidate is disqualified
by `PRV-30`.

| Provider shape | Field carried at create | Shape | Find it afterwards | Confidence |
|---|---|---|---|---|
| Hetzner Cloud | `labels` | `map[string]string` | `label_selector` query parameter on list | **[observed — official `hcloud-go` client, `ServerCreateOpts.Labels` and `ListOpts.LabelSelector` → `label_selector`]** |
| Hetzner Robot | ~~`comment`~~ **UNUSABLE** → per-order SSH key | key **fingerprint**, MD5-colon form (47 chars) | `GET /order/server/transaction` and `/order/server_market/transaction` list **recent** transactions; `/{id}` fetches one. **The two channels keep separate listings and a search of one is not a search of the provider** | **`comment` CONFIRMED UNUSABLE** — comments require manual provisioning (`PRV-30`), and Hetzner's own parameter table says so. **Key substitute [observed 2026-09-04 — two real auction orders, two distinct fingerprints, each matching exactly one transaction]** (`PRV-32`). Standard channel still unconfirmed with a real order |
| Cherry Servers | `tags` | `map[string]string` | returned on the server object | **[observed — official `cherrygo` client]**; server-side filtering **[verify]** |
| DigitalOcean | `tags` | `[]string` — flat strings, **not** key/value | `ListByTag` | **[observed — official `godo` client]** |

Notes that change driver code:

- **DigitalOcean tags are not key/value.** Encode the correlator as a single string with a fixed
  prefix. The permitted character set is **[verify]** before choosing a separator.
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
  | offer id vs server number | **identical, both times** — auction offer `3068756` became server `3068756`, `3068758` became `3068758`, and each listing left the feed on purchase | The auction market lists *specific machines*, not SKUs. The standard catalogue does not work this way. `PRV-42` owns what a driver does with it |
  | `earliest_cancellation_date` on delivery | **same day**, both | Confirms the cancellation note above |
  | `reservation_possible` | `false` on both | The cancellation call takes a `reserve_location` parameter that is **mandatory** where reservation is possible; you learn which case applies only by reading `GET /server/{id}/cancellation` first. The mandatory branch was not exercised |
  | `server_ip` on delivery | **`null`** — no IPv4 | Hetzner's docs: "If you do not specify the parameter, the server will be ordered without an IPv4 address by default." `addon[]=primary_ipv4` is priced separately; `RSC-45` owns what a driver must do about it |
  | after cancellation | `GET /server/{n}` → `404 SERVER_NOT_FOUND`; account list back to its prior contents | Immediate destroy, no scheduled tail |
  | the transaction afterwards | **still `status: "ready", server_number: N`** while `GET /server/N` answered `404` | The listing outlives the machine; `PRV-43` owns the consequence |
  | `cancellation_reason` | provider advertises a 9-item enum and accepted the unlisted value `"Other"` | Do not model it as a closed set |

- **Ordering is rate-limited: 20 requests per day**, on `POST /order/server/transaction` and again
  on `POST /order/server_market/transaction`; cancellation is 200 per hour.
  **[observed 2026-09-04 — Hetzner API documentation]** `PRV-40` owns what follows from it.

- **Three failed logins block the source IP for ten minutes, across the whole API** — not merely
  the endpoint that failed. **[observed 2026-09-04 — Hetzner Robot webservice documentation]**
  Authorization failures do not count toward it: four `401`s on `/order/*` left `/server` answering
  `200` immediately afterwards. **[observed 2026-09-04]** `PRV-41` owns the rule.

- **Ordering is a separate opt-in from the webservice user.** A `#ws+` webservice user authenticates
  against `/server`, `/key` and the rest while every `/order/*` path answers `401` until ordering is
  activated in Robot under *Administration → Settings → Web Service Settings → Ordering*.
  **[observed 2026-09-04]** A deployment can therefore hold credentials that manage machines and
  cannot order or reconcile them.

- **Robot's transaction listing is time-bounded** — the client library documents the last 30
  days. **[verify]** the exact window, because it is the hard limit on how long an unresolved
  ambiguous order stays automatically recoverable. After it, resolution is manual.
- Hetzner Cloud's label constraints (key/value character set, length, count) are **[verify]** —
  the Go client performs no validation of its own, so the server enforces whatever it enforces.

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

1. **Does key material get copied at create/rebuild time, or read asynchronously later?**
   Determines whether temporary key cleanup is safe immediately (`PRV-9`).
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
5. **Is ordering idempotent?** Determines how a timed-out order is reported (`PRV-11`).
6. **What is the identifier character set?** Determines the validation in `PRV-6`.
7. **Which caller-controlled field can carry a correlator at create, per ordering channel, and
   can you search by it?** Determines whether ambiguous creates resolve automatically or wait
   for a human (`PRV-26`, `PRV-27`, `OPS-27`), and is the descriptor's `ordering_channels[].correlator`
   (`PRV-33`, `PRV-38`). If the field lives on an order rather than the machine, record the
   listing window too — it bounds how long automatic recovery is possible.
8. **Does a newly ordered machine have an IPv4 address?** The descriptor's
   `rescue_address_family` (`RSC-45`).
