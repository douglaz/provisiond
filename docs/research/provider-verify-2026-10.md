# Provider `[verify]` facts checked against primary sources (2026-10)

Retrieved 2026-10-06. Every quote below is verbatim from the source named. "Not documented" means
the source is silent, which this note treats as UNDETERMINABLE and never as a refutation.

Pinned sources used throughout:

| Short name | Source |
|---|---|
| HC-spec | Hetzner Cloud official OpenAPI, `https://docs.hetzner.cloud/cloud.spec.json` (`openapi` 3.1.2) |
| hcloud-go | `https://github.com/hetznercloud/hcloud-go` at tag `v2.52.0` (`cea7071`) |
| hcloud-python | `https://github.com/hetznercloud/hcloud-python` at tag `v2.27.0` (`a2e8012`) |
| Robot-WS | Hetzner Robot webservice reference, `https://robot.hetzner.com/doc/webservice/en.html` |
| installimage | `https://github.com/hetzneronline/installimage` at commit `e15b5eab572bbaa1773b9b0d1d9c3448995aa5af` (2025-08-27, HEAD of default branch) |
| DO-spec | `https://github.com/digitalocean/openapi` at commit `4a87b3bd8e541f72450c426cf4ba197724b0e479` (2026-10-03) |
| godo | `https://github.com/digitalocean/godo` at commit `711bfce54774796e02c67c8e521bf6c87e00c709` (2026-10-01) |
| Cherry-spec | Cherry Servers API reference `https://api.cherryservers.com/doc/` (Redoc page with embedded OpenAPI 3.0.1) |
| cherrygo | `https://github.com/cherryservers/cherrygo` at tag `v4.2.0` (`69ef188`) |

Documentation and terms pages, cited by title in the body:

| Title used in the body | URL |
|---|---|
| Hetzner Cloud billing FAQ | `https://docs.hetzner.com/cloud/billing/faq` |
| Hetzner Volumes overview | `https://docs.hetzner.com/cloud/volumes/overview` |
| Hetzner "Guideline for locked products" | `https://docs.hetzner.com/robot/dedicated-server/troubleshooting/guideline-in-case-of-server-locking/` |
| Hetzner "30 days to the end of the month policy" | `https://docs.hetzner.com/general/billing-and-account-management/cancellation/30-days-to-the-end-of-the-month/` |
| Hetzner "Cancellations on Robot" | `https://docs.hetzner.com/general/billing-and-account-management/cancellation/cancellations-robot` |
| Hetzner Server Auction FAQ | `https://docs.hetzner.com/robot/general/server-auction-faqs/` |
| Hetzner "Billing system at Hetzner" | `https://docs.hetzner.com/general/others/new-billing-model/` |
| Hetzner T&C | `https://www.hetzner.com/legal/terms-and-conditions/` |
| Hetzner system policies (cloud, dedicated) | `https://www.hetzner.com/legal/cloud-server/`, `https://www.hetzner.com/legal/dedicated-server/` |
| Hetzner Docs "Installimage" | `https://docs.hetzner.com/robot/dedicated-server/operating-systems/installimage/` |
| Hetzner Docs "Account migration" | `https://docs.hetzner.com/managed/administration-on-konsoleh/account-migration/` |
| DO "My Droplet is sending an outgoing flood or DDoS" | `https://docs.digitalocean.com/support/my-droplet-is-sending-an-outgoing-flood-or-ddos/` |
| DO "Droplet pricing" | `https://docs.digitalocean.com/products/droplets/details/pricing/` |
| DO "Destroy Droplets" | `https://docs.digitalocean.com/products/droplets/how-to/destroy/` |
| DO "How to Manage SSH Public Keys on DigitalOcean Teams" | `https://docs.digitalocean.com/platform/teams/how-to/upload-ssh-keys/` |
| DO reserved IP pricing | `https://docs.digitalocean.com/products/networking/reserved-ips/details/pricing/` |
| DO volumes pricing | `https://docs.digitalocean.com/products/volumes/details/pricing/` |
| DO snapshots pricing | `https://docs.digitalocean.com/products/snapshots/details/pricing/` |
| DO ToS | `https://www.digitalocean.com/legal/terms-of-service-agreement` |
| Cherry docs "iPXE" | `https://www.cherryservers.com/knowledge/docs/compute/configuration-management/ipxe` |
| Cherry "Terminate a Service" | `https://www.cherryservers.com/knowledge/docs/compute/configuration-management/terminate-a-service` |
| Cherry "Payment options" | `https://www.cherryservers.com/knowledge/docs/usage-billing/payment-options` |
| Cherry FAQ | `https://www.cherryservers.com/knowledge/faq` |
| Cherry ToS | `https://www.cherryservers.com/legal/terms-of-service` |

Proposed markers use the corpus's dated form, `[observed — <source>, <date>]`, as at
`08-provider-notes.md:132-133`. A bare `[observed]` means "asserted by the reference implementation"
(`08-provider-notes.md:16`), and it is never proposed here.

## 1. Summary

| id | provider | spec line(s) · requirement | claim | verdict | what changes in the spec |
|---|---|---|---|---|---|
| V1 | Hetzner Cloud | `01-domain-model.md:318`, `02-provider-contract.md:766` · `DOM-27`, `PRV-35` | `public_net.ipv4.blocked` / `ipv6.blocked` on the server, separate from `status` | CONFIRMED | Marker becomes `[observed — HC-spec, 2026-10-06]`. The `PRV-35` row should add that either family may be `null` and that Floating IPs carry their own `blocked`, which is not on the server |
| V2 | Hetzner Cloud | `08-provider-notes.md:57` · `PRV-9` | key material is copied at create, so deleting the temp key right after the create call is safe | PARTIAL | "At creation time" is documented. Deleting while the create Action is still `running` is not. Until a live test passes, clean up after the create Action reaches `success`, not after the call returns |
| V3 | Hetzner Cloud | `08-provider-notes.md:59` · `PRV-9`, `OPS-32` | a key resource carries a name/label the engine chooses | CONFIRMED | Marker becomes `[observed — HC-spec, 2026-10-06]`. `name` is required and caller-set, `labels` are supported, and the list endpoint filters by `name` and `label_selector` |
| V4 | Hetzner Cloud | `08-provider-notes.md:70` · none named | `enable_rescue` while already enabled: error or re-arm | UNDETERMINABLE | Needs a live test, or design around it: read `rescue_enabled` and `disable_rescue` first |
| V5 | Hetzner Cloud | `08-provider-notes.md:417` · correlator (`OPS-27`, `OPS-32`) | label key/value character set, length, count | PARTIAL | Character set and the 63-character length become `[observed — HC-spec, 2026-10-06]`. The count limit stays `[verify]`. A UUID value fits |
| V6 | Hetzner Robot | `02-provider-contract.md:767` · `PRV-35` | `locked` on each IP and subnet; server status stays `ready`/`in process` | PARTIAL | The `PRV-35` row's "documented; high" must go. `locked` is documented only as "Status of locking", and Hetzner also locks entire servers, which has no API field. An IP showing `locked:false` does not support reporting `none` |
| V7 | Hetzner Robot | `02-provider-contract.md:705`, `08-provider-notes.md:415` · `PRV-27`, `OPS-33` | transaction listing is time-bounded (30 days) | CONFIRMED | Marker becomes `[observed — Robot-WS, 2026-10-06]`. The bound is first-party: "within the last 30 days", on both channels |
| V8 | Hetzner Robot | `02-provider-contract.md:940` · `PRV-42` | auction offer id equals server number by rule | UNDETERMINABLE | Not documented. `PRV-42` needs a runtime guard: if `server_number` ≠ offer id, fall back to `PRV-32`'s search |
| V9 | Hetzner Robot | `08-provider-notes.md:104`, `03-operation-lifecycle.md:1379` · `PRV-9`, `PRV-32`, `OPS-32` | key carries an engine-chosen name; the transaction still lists the fingerprint after the key is deleted | PARTIAL | `name` is caller-set (`[observed — Robot-WS, 2026-10-06]`). Whether the listing outlives the key needs a live test. `OPS-32` keeps its "only where the listing carries it independently" clause until then |
| V10 | Hetzner Robot | `08-provider-notes.md:115` · none named | enabling rescue while already enabled: error or re-arm | UNDETERMINABLE | Design around it: `GET /boot/{n}/rescue` shows `active`, so `DELETE` first. The live test is optional |
| V11 | Hetzner Robot | `08-provider-notes.md:121` · `RSC-12` | installimage config keys and the directive that stops rescue keys being copied | PARTIAL | Directive found in the official source: `TAKE_OVER_RESCUE_SYSTEM_SSH_PUBLIC_KEYS no`. Whether the live rescue system runs that source needs a live check |
| V12 | Hetzner Robot | `08-provider-notes.md:153` · `PRV-13c`, `DOM-19` | worst case across contracts; `cancellation_date=now` when the earliest date is in the future | PARTIAL | "30 days to the end of the month" is documented as "the longest period". The API's behaviour for `now` before the earliest date is not documented, so the "handle both" rule stands |
| V13 | Hetzner (both) | `08-provider-notes.md:175` · none named | anonymous downstream customers permitted | UNDETERMINABLE | The terms are silent. Needs a written answer from Hetzner |
| V14 | DigitalOcean | `01-domain-model.md:277` · `DOM-23` | no abuse-case API, as with Hetzner | PARTIAL | The channel is settled: email, support ticket, networking disabled. That no API exists cannot be proven from public sources. `DOM-23` is unaffected either way |
| V15 | DigitalOcean | `02-provider-contract.md:768` · `PRV-35` | Droplet `locked` is documented only as preventing user actions; do not map it | CONFIRMED | Keep "do not map it" and cite the source: DO documents `locked` as true while an uncompleted action blocks the next one. The driver declares no network-restriction signal, so the status is `unknown` |
| V16 | DigitalOcean | `08-provider-notes.md:245`, `08-provider-notes.md:348` · correlator (`OPS-32`) | permitted tag character set | CONFIRMED | Marker becomes `[observed — DO-spec, 2026-10-06]`: `^[a-zA-Z0-9_\-\:]+$`, ≤255 characters. Separator is `:` or `_`. Use lowercase, because tags are case-stable |
| V17 | DigitalOcean | `08-provider-notes.md:249` · `PRV-13a`, `PRV-13b` | delete stops billing; volumes, snapshots and reserved IPs survive | PARTIAL | Per-second billing stops "when you destroy it" (60 s minimum). Survivors and their monthly cost are documented. Automated backups survive about four weeks, with no documented billing after destroy and no API delete. The driver must never enable backups |
| V18 | DigitalOcean | `08-provider-notes.md:316` · `PRV-9`, `DEF-6` | SSH keys copied at Droplet creation or read later | PARTIAL | "Embed … upon creation" is documented, and deleting a key does not remove it from existing Droplets. The in-flight window is not documented. Clean up after the Droplet is `active` |
| V19 | Cherry Servers | `08-provider-notes.md:199` · `PRV-9`, `DEF-6` | key material captured at request time or read later | UNDETERMINABLE | Not documented. Keep temporary keys until the server reaches `deployed` (or `allocated` for iPXE) |
| V20 | Cherry Servers | `08-provider-notes.md:216` · none named | iPXE is a rebuild-action variant; needs an image alongside? | PARTIAL | iPXE is a field of the `rebuild` action (and of create). Whether `image` is required is not documented. cherrygo sends `type: "reinstall"`, not `rebuild` |
| V21 | Cherry Servers | `08-provider-notes.md:342` · correlator (`OPS-27`) | tags filterable server-side | UNDETERMINABLE | No tag filter is documented. Design for a paginated list and filter on the client |
| V22 | Hetzner | `07-security-requirements.md:329` · `SEC-44`, `SEC-43` | separately registered accounts are not linked and terminated together | UNDETERMINABLE | Not documented. Needs a written answer. `SEC-43` remains a belief |
| V23 | DigitalOcean | `07-security-requirements.md:329`, `08-provider-notes.md:319` · `SEC-44`, `SEC-43` | as V22 | UNDETERMINABLE | As V22 |
| V24 | Cherry Servers | `07-security-requirements.md:329` · `SEC-44`, `SEC-43` | as V22 | UNDETERMINABLE | As V22 |

Verdict count: CONFIRMED 5, REFUTED 0, PARTIAL 10, UNDETERMINABLE 9.

## 2. Facts

### V1 — Hetzner Cloud `blocked` per address family

**Spec.** `01-domain-model.md:318`: "Hetzner Cloud exposes `blocked` separately for IPv4 and IPv6
**[verify]**". `02-provider-contract.md:766`: "`public_net.ipv4.blocked` and `public_net.ipv6.blocked` on
the server object, separate from lifecycle `status` | **[verify]**".

**Sources.**
- HC-spec, `/servers/{id}` GET → `server.public_net.ipv4.blocked` and `.ipv6.blocked`: "Whether the IP is
  blocked by our abuse department." Both families list `blocked` as required, and each family object
  is typed `['object', 'null']`.
- HC-spec, `server.status` enum: `running, initializing, starting, stopping, off, deleting, migrating,
  rebuilding, unknown`. It has no blocked state.
- HC-spec, `server.public_net.floating_ips`: "IDs of Floating IPs assigned to this Server." Floating IPs
  carry their own `blocked` field: "Indicates whether the [Floating IP] is blocked."
- HC-spec, `server.locked`: "True if Server has been locked and is not available to user." Separately,
  error `423 locked` means "The item you are trying to access is locked (there is already an Action
  running)."
- hcloud-go `hcloud/schema/server.go` L48–62 (`v2.52.0`):
  `Blocked bool \`json:"blocked"\`` on both `ServerPublicNetIPv4` and `ServerPublicNetIPv6`.
- hcloud-python `hcloud/servers/domain.py` L368–418 (`v2.27.0`):
  `__api_properties__ = ("ip", "blocked", "dns_ptr")`.

**Verdict.** CONFIRMED.

**Consequence.** `PRV-35`'s Hetzner Cloud row holds. Add three things to it:
- a `null` family is "not applicable", not `none`;
- a blocked Floating IP is visible only on the Floating IP object;
- server-level `locked` is not a network signal.

What a block actually does to traffic is not documented.

### V2 — Hetzner Cloud: key copied at create, so immediate deletion is safe

**Spec.** `08-provider-notes.md:54-59`: "The key material is copied into the new server during
creation, so the temporary key resource can be deleted immediately after the create call returns.
**[verify]**"

**Sources.**
- HC-spec, `POST /servers` → `ssh_keys`: "SSH key IDs (`integer`) or names (`string`) which should be
  injected into the Server at creation time."
- HC-spec, `POST /servers` description: "Returns preliminary information about the Server as well as
  an Action that covers progress of creation."
- HC-spec, `SSH Keys` tag: "They can be injected into Servers at creation time."
  `DELETE /ssh_keys/{id}`: "Deletes an SSH key. It cannot be used anymore."
- HC-spec, `enable_rescue` → `ssh_keys`: "Array of SSH key IDs which should be injected into the rescue
  system." The source does not say when.

**Verdict.** PARTIAL. Injection "at creation time" is documented. Creation is asynchronous: the call
returns while the create Action runs. Nothing says whether deleting the key during that Action is safe,
and nothing says when rescue keys are read.

**Consequence.** `PRV-9`'s "cleanup immediately after the create call returns" goes beyond the source.
Safe wording: clean up after the create Action reaches `success`. For rescue, clean up after the reset
that boots it. A live test may later tighten this.

### V3 — Hetzner Cloud: key resource carries an engine-chosen name or label

**Spec.** `08-provider-notes.md:58-59`: "Whether a key resource carries a name or label the engine
chooses is **[verify]**".

**Sources.**
- HC-spec, `POST /ssh_keys`: "Creates a new SSH key with the given `name` and `public_key`." The
  required fields are `["name", "public_key"]`, and the request also accepts `labels`.
- HC-spec, `GET /ssh_keys` filters: `name` ("matching exactly the specified name"), `fingerprint`,
  `label_selector`.
- HC-spec error example: `uniqueness_error` "SSH key with the same fingerprint already exists".

**Verdict.** CONFIRMED.

**Consequence.** Marker becomes `[observed — HC-spec, 2026-10-06]`. `OPS-32`'s sweep can query with
`label_selector`. Each temporary key must be freshly generated, since a duplicate fingerprint is
rejected.

### V4 — Hetzner Cloud: `enable_rescue` when rescue is already enabled

**Spec.** `08-provider-notes.md:70-71`.

**Sources.**
- HC-spec, `enable_rescue` lists no operation-specific errors. "Rescue Mode is automatically disabled
  when you first boot into it or if you do not use it for 60 minutes."
- `server.rescue_enabled`: "True if rescue mode is enabled."

**Verdict.** UNDETERMINABLE. Not documented.

**Consequence.** It doesn't block anything if the driver reads `rescue_enabled` and calls `disable_rescue`
first. The 60-minute auto-disable bounds how long the driver may wait between enable and reset.

### V5 — Hetzner Cloud label constraints

**Spec.** `08-provider-notes.md:417`.

**Sources.**
- HC-spec `info.description`, "Labels": "The name segment is required and must be a string of 63
  characters or less, beginning and ending with an alphanumeric character (`[a-z0-9A-Z]`) with dashes
  (`-`), underscores (`_`), dots (`.`), and alphanumerics between." "Valid label values must be a string
  of 63 characters or less and must be empty or begin and end with an alphanumeric character". "The
  `hetzner.cloud/` prefix is reserved and cannot be used."
- hcloud-go `hcloud/labels.go` (`v2.52.0`) exports `ValidateResourceLabels`. Nothing in the client
  calls it, so "the Go client performs no validation of its own" still holds.

**Verdict.** PARTIAL. The character set and length are documented. A maximum label count is not.

**Consequence.** A UUID value (36 characters: hex and `-`) is valid. The count limit stays `[verify]`.
It matters only if the engine sets many labels.

### V6 — Hetzner Robot `locked` per IP and subnet

**Spec.** `02-provider-contract.md:767`: "`locked` on each IP and subnet; server status stays
`ready`/`in process` | **[verify]** — documented; high".

**Sources.**
- Robot-WS `GET /ip` output: "locked (Boolean) Status of locking". `GET /subnet` output: "locked
  (Boolean) Status of locking".
- Robot-WS `GET /server` output fields: `server_ip, server_ipv6_net, server_number, server_name,
  product, dc, traffic, status, cancelled, paid_until, ip, subnet`. There is no lock field, and
  `status` is "Server status ("ready" or "in process")".
- Hetzner, "Guideline for locked products",
  `https://docs.hetzner.com/robot/dedicated-server/troubleshooting/guideline-in-case-of-server-locking/`:
  "Often this will be a single IP, but it can also apply to multiple IPs or even entire servers or
  storage boxes." The listed reasons include "Non-payment" as well as abuse.

**Verdict.** PARTIAL. The field exists where the row says, and server status does stay
`ready`/`in process`. Two things are not documented:
- that `locked` means the abuse lock;
- any API field for a whole-server lock.

**Consequence.** `PRV-35`'s "documented; high" overstates the source. `PRV-35` says "the provider is
authoritative" where a driver reports. On Robot, all IPs at `locked:false` cannot support `none`,
because a server-level lock is invisible to the API. The row should declare at most a partial signal,
and the machine should otherwise read `unknown`.

### V7 — Robot transaction listing window

**Spec.** `02-provider-contract.md:705`: "the listing window is still `[verify]`".
`08-provider-notes.md:414-416`: "the client library documents the last 30 days. **[verify]** the exact
window".

**Sources.** Robot-WS: `GET /order/server/transaction` says "Overview of all server orders within the
last 30 days". `GET /order/server_market/transaction` says the same. `GET /order/server/transaction/{id}`
is "Query a specific order transaction", with no window stated.

**Verdict.** CONFIRMED. The source is first-party and says 30 days.

**Consequence.** The marker becomes `[observed — Robot-WS, 2026-10-06]`. Whether the 30 days is rolling or calendar-aligned is
not stated, so `OPS-33`'s automatic-recovery horizon should keep a margin, for example 29 days. A
by-id fetch is not documented as bounded, but it needs the id that a lost reply never delivered.

### V8 — Robot auction offer id equals server number "by rule"

**Spec.** `02-provider-contract.md:938-940`: "that it holds by rule rather than by coincidence is
`[verify]` before a driver depends on it."

**Sources.** Robot-WS `GET /order/server_market/product`: "id (Integer) Product ID". Nothing relates it
to `server_number`. The page's own illustrative `server_market` transaction example shows product
`"id":277254` with `"server_number":107239`. That is sample data, so it neither confirms nor refutes the
rule.

**Verdict.** UNDETERMINABLE. Not documented.

**Consequence.** `PRV-42` should be guarded. When the identity read finds a server, assert
`server_number == offer id` on the transaction. On a mismatch, treat the channel as catalogue-like and use
`PRV-32`'s fingerprint search. A written answer from Hetzner would settle the rule.

### V9 — Robot temporary key: engine-chosen name, and listing after key deletion

**Spec.** `08-provider-notes.md:103-105`; `03-operation-lifecycle.md:1377-1379`.

**Sources.**
- Robot-WS `POST /key` input: `name`: "SSH key name"; `data`: "SSH key data in OpenSSH or SSH2 format".
  Error `409 KEY_ALREADY_EXISTS`.
- Robot-WS order input: `authorized_key[]`: "One or more SSH key fingerprints". Transaction output:
  "authorized_key (Array) Array with supplied public SSH keys". The example carries
  `"name":"key1","fingerprint":…`.
- No source says whether the transaction's `authorized_key[]` is a snapshot or a live join to the key
  resource.

**Verdict.** PARTIAL. The name half is confirmed. The persistence half is not documented.

**Consequence.** The name is `[observed — Robot-WS, 2026-10-06]`. `OPS-32`'s Robot exception stands until the live test (batch
B, step 6) shows the fingerprint still listed after `DELETE /key/{fp}`.

### V10 — Robot rescue activation when already active

**Spec.** `08-provider-notes.md:115-116`.

**Sources.** Robot-WS `POST /boot/{server-number}/rescue` errors: `400 INVALID_INPUT`,
`404 SERVER_NOT_FOUND`, `404 BOOT_NOT_AVAILABLE`, `500 BOOT_ACTIVATION_FAILED`. No "already active" error
is listed. `GET /boot/{n}/rescue` and `DELETE /boot/{n}/rescue` both return `active`.

**Verdict.** UNDETERMINABLE. Not documented.

**Consequence.** Read `active` and `DELETE` before re-enabling. The live test is optional.

### V11 — installimage keys and the no-takeover directive

**Spec.** `08-provider-notes.md:118-125`: the exact config keys, "and in particular the directive that
prevents the installer from copying rescue authorized keys into the installed system (`RSC-12`)".

**Sources.**
- installimage `functions.sh` L956–971:
  ```
  sshkeys_url=$(grep -m1 -e ^SSHKEYS_URL "${1}" | awk '{print $2}')
  ...
  local take_over_rescue_system_ssh_public_keys="$(grep -m 1 '^TAKE_OVER_RESCUE_SYSTEM_SSH_PUBLIC_KEYS' "$1" | awk '{ print tolower($2) }')"
  ...
  if [[ "$OPT_USE_SSHKEYS" != '1' ]] && [[ "${OPT_TAKE_OVER_RESCUE_SYSTEM_SSH_PUBLIC_KEYS:-yes}" == 'yes' ]] && [[ -s /root/.ssh/robot_user_keys ]]; then
    export OPT_SSHKEYS_URL='/root/.ssh/robot_user_keys'
  ```
- installimage `get_options.sh` L60–61: "-K <path/url> Install SSH-Keys from file/URL" and
  "-t <yes|no> Take over rescue system SSH public keys".
- installimage `install.sh` L425–455: keys are fetched from `OPT_SSHKEYS_URL` and appended by
  `copy_ssh_keys`.
- Hetzner Docs "Installimage" (`https://docs.hetzner.com/robot/dedicated-server/operating-systems/installimage/`,
  last changed 2020-05-18) documents `DRIVE1`, `SWRAID`/`SWRAIDLEVEL`, `HOSTNAME`, `/autosetup`. It does
  not mention the takeover directive.

**Verdict.** PARTIAL.
- Confirmed in the official source:
  - the directive is `TAKE_OVER_RESCUE_SYSTEM_SSH_PUBLIC_KEYS no` in the config, or `-t no`;
  - takeover defaults to `yes`;
  - setting `SSHKEYS_URL` also suppresses takeover.
- Not settled:
  - whether the rescue system runs this commit;
  - whether `/root/.ssh/robot_user_keys` holds exactly the activation key.

**Consequence.** `RSC-12`'s configuration should emit both lines: `SSHKEYS_URL` pointing at the caller's
keys, which `RSC-13` requires, and `TAKE_OVER_RESCUE_SYSTEM_SSH_PUBLIC_KEYS no`. The redundancy is
deliberate. The marker becomes `[observed — installimage e15b5ea, 2026-10-06]`, with the live check of batch B, step 7.

### V12 — Robot cancellation worst case, and `now` before the earliest date

**Spec.** `08-provider-notes.md:151-157`.

**Sources.**
- Hetzner T&C §2.6 (`https://www.hetzner.com/legal/terms-and-conditions/`): "The contract may be
  terminated by either party with 30 days' notice to the end of the month … Differing periods of notice
  may apply to the Customers depending on the description of relevant services."
- Hetzner Docs "30 days to the end of the month policy": "This is the longest period of cancellations.
  For many of our products, you will be able to cancel your contract earlier."
- Hetzner Docs "Cancellations on Robot" (last change 2026-08-06), under dedicated servers: "You can only
  cancel immediately." and "We bill by the hour and never exceed the monthly price cap (except for
  additional hardware and licenses)."
- Robot-WS `POST /server/{n}/cancellation`: `cancellation_date`: "Date to which the server should be
  cancelled or "now" to cancel immediately". The errors listed are `404`, `409 CONFLICT` (already
  cancelled, or active transfer), `409 SERVER_CANCELLATION_RESERVE_LOCATION_FALSE_ONLY` and `500`. None
  covers a date before `earliest_cancellation_date`.

**Verdict.** PARTIAL.
- Documented: the standard worst case is 30 days to the end of the month, up to about 61 days, and
  Hetzner calls it "the longest period".
- Not documented:
  - individual or custom contracts, which the T&C leave open;
  - the API's answer to `now` before the earliest date.

**Consequence.** `PRV-13c`'s "read `earliest_cancellation_date` and branch" stands. The universal worst
case can be declared as 30 days to the end of the month unless the contract says otherwise. The `now`
behaviour needs a server whose earliest date is in the future, and current products give none ("You
can only cancel immediately"). It is untestable on new orders and may be moot for them.

### V13 — Hetzner: anonymous downstream customers

**Spec.** `08-provider-notes.md:175-176`.

**Sources.** Hetzner T&C §7.1: "The Customer is entitled to grant third parties a contractual term of
use to any services the Customer orders from Hetzner. In this case, the Customer nevertheless remains
the sole contractual partner." §7.3: "if the data provided by the third party is incorrect or
incomplete … the Customer assumes full liability". §2.3 covers the customer's own data only. The system
policies for cloud and dedicated servers say nothing on end-user identity.

**Verdict.** UNDETERMINABLE. The terms are silent, as the spec already says.

**Consequence.** The marker stays `[verify]`. It needs a written answer (see the written-inquiry list).

### V14 — DigitalOcean: no abuse-case API

**Spec.** `01-domain-model.md:277-281`.

**Sources.**
- DO-spec at `4a87b3b`. `abuse` occurs only in `specification/resources/inference/models/*`, as
  "Optional end-user identifier to help with abuse monitoring". No resource exists for abuse cases.
- godo at `711bfce`: no `abuse` identifier.
- DO support, "My Droplet is sending an outgoing flood or DDoS"
  (`https://docs.digitalocean.com/support/my-droplet-is-sending-an-outgoing-flood-or-ddos/`, last
  verified 13 Jul 2026): "your Droplet's normal internet access has been disabled, but you can still
  access it through the Recovery Console." It also says: "open a support ticket".

**Verdict.** PARTIAL. The notice channel (email or ticket) and the remedy (networking disabled) are
documented, and the public API has no abuse resource. That no such API exists anywhere cannot be shown
from public sources.

**Consequence.** None for `DOM-23`. The spec already says a wrong answer "widens an option rather than
breaking a rule".

### V15 — DigitalOcean Droplet `locked`

**Spec.** `02-provider-contract.md:768`.

**Sources.**
- DO-spec `specification/resources/droplets/models/droplet.yml` L38–41: "A boolean value indicating
  whether the Droplet has been locked, preventing actions by users."
- DO-spec `specification/DigitalOcean-public.v2.yaml` L291–295: "If a Droplet action is uncompleted it
  may block the creation of a subsequent action for that Droplet, the locked attribute of the Droplet
  will be true and attempts to create a Droplet action will fail with a status of 422."
- godo `droplets.go` L70: `Locked bool \`json:"locked,bool,omitempty"\``.
- The disabled-networking state in V14 has no documented API field.

**Verdict.** CONFIRMED. The spec's reason ("would report every in-flight resize as a block") is now
first-party.

**Consequence.** Drop the `[verify]` and cite L291–295. The DO driver declares no network-restriction
signal, so `PRV-35`'s `unknown` applies.

### V16 — DigitalOcean tag character set

**Spec.** `08-provider-notes.md:245`, `08-provider-notes.md:348`.

**Sources.** DO-spec `specification/resources/tags/models/tags.yml` L11–23: "Tags may contain letters,
numbers, colons, dashes, and underscores. There is a limit of 255 characters per tag." The pattern is
`'^[a-zA-Z0-9_\-\:]+$'`, with `maxLength: 255`. "Tag names are case stable, which means the
capitalization you use when you first create a tag is canonical."

**Verdict.** CONFIRMED.

**Consequence.** Marker becomes `[observed — DO-spec, 2026-10-06]`. `pv:<uuid>` is valid. Do not use `.` or `/`.

`DELETE /v2/droplets?tag_name=` deletes every Droplet with the tag (`droplets_destroy_byTag.yml`). The
driver must never call it with a correlator tag.

### V17 — DigitalOcean deletion, billing stop and survivors

**Spec.** `08-provider-notes.md:248-251`.

**Sources.**
- DO Docs "Droplet pricing" (`https://docs.digitalocean.com/products/droplets/details/pricing/`, last
  verified 25 Aug 2026): "Bundled-plan CPU Droplets are billed per second with a minimum charge of 60
  seconds or $0.01, whichever is higher. Usage is capped at 672 hours (28 days) per month." It also
  says: "Billing begins when you create the Droplet and ends when you destroy it." For v5 Droplets: "do
  not have a monthly usage cap", and "Public IPv4 addresses for Droplets with v5 configurations are
  billed separately".
- DO-spec `models/associated_resource.yml` L18–22, `cost`: "The cost of the resource in USD per month
  if the resource is retained after the Droplet is destroyed." The response keys are `reserved_ips`,
  `floating_ips`, `snapshots`, `volumes`, `volume_snapshots`.
- DO-spec `droplets_destroy_withAssociatedResourcesSelective.yml` L5–12: "Any associated resource not
  included in the request will remain and continue to accrue changes [sic] on your account."
- DO Docs "Destroy Droplets" (last verified 13 Jul 2026): "Destroying a Droplet does not destroy its
  automated backups. Automated backups remain for four weeks after creation and then expire."
- DO-spec `images_delete.yml` L5–6: "To delete a snapshot or custom image". Backups are not named.

**Verdict.** PARTIAL.
- Confirmed:
  - billing stops at destroy;
  - which attachments survive, and that they bill.
- Not documented:
  - whether retained backups bill after destroy;
  - any API path to delete a backup.

**Consequence.**
- `surviving_attachments` for DO is reserved IPs, floating IPs, snapshots, volumes and volume snapshots,
  each `cleanup: api` through the destroy-with-associated-resources endpoints or each resource's own
  DELETE.
- Backups go in as `manual`. The simpler rule is that the driver never sets `backups: true`.

### V18 — DigitalOcean: SSH keys copied at creation

**Spec.** `08-provider-notes.md:316-317`.

**Sources.**
- DO-spec `droplet_create.yml` L38–40: "An array containing the IDs or fingerprints of the SSH keys
  that you wish to embed in the Droplet's root account upon creation."
- DO Docs "How to Manage SSH Public Keys on DigitalOcean Teams" (last verified 13 Jul 2026): "Deleting
  an SSH key from a team only removes the ability to create new Droplets with that key already added. It
  does not remove that SSH key from any Droplet's SSH configuration."
- DO-spec `ssh_keys/models/sshKeys.yml`: required `public_key` and `name`. Keys have no tags.

**Verdict.** PARTIAL. Copy at creation is documented. The window between `202` and first boot is not,
because the guest reads keys at boot.

**Consequence.** Delete the temporary key after the Droplet reaches `active`, or after the create action
completes. `PRV-9`'s name requirement is met through `name`.

### V19 — Cherry Servers: key captured at request or read later

**Spec.** `08-provider-notes.md:198-202`.

**Sources.** Cherry-spec `POST /v1/projects/{projectId}/servers` → `ssh_keys`: "List of ssh keys `id`
identifiers". `DELETE /v1/ssh-keys/{keyId}` has only the summary "Delete a ssh key". The server object
carries `ssh_keys`, and `GET /v1/servers/{serverId}/ssh-keys` exists. Nothing states when the key is
read. Cherry's FAQ says Linux servers "are provisioned within 15 to 30 minutes".

**Verdict.** UNDETERMINABLE. Not documented.

**Consequence.** Keep the temporary key until the server reaches `deployed` (or `allocated` for iPXE;
see cherrygo `servers.go` L26–40). This is the conservative reading of `PRV-9` and `DEF-6`. Cherry keys
carry a caller-set `label`.

### V20 — Cherry Servers iPXE

**Spec.** `08-provider-notes.md:216-218`.

**Sources.**
- Cherry-spec `POST /v1/servers/{serverId}/actions` → `type`: "`reboot`,`power-on`,`power-off`,
  `rebuild`,`enter-rescue-mode`,…". Its `ipxe` field: "Only for `rebuild` action. Base64-encoded iPXE
  template blob. The decoded content must start with #!ipxe." Its `image` field: "Only for `rebuild`
  action. Image `slug`." Only `type` is required.
- Cherry-spec create: `ipxe` is also a create field, along with `persist_ipxe`: "Set `true` to keep iPXE
  permanently enabled".
- cherrygo `servers.go` L139–153: `ReinstallServerFields` has `Image string \`json:"image"\`` without
  `omitempty`, so it is always sent. L341: `ServerAction{Type: "reinstall"}`.
- Cherry docs "iPXE"
  (`https://www.cherryservers.com/knowledge/docs/compute/configuration-management/ipxe`): "the ISO will
  be automatically disconnected after five minutes". In the portal, iPXE is chosen as the "OS Image"
  ("Custom iPXE install").

**Verdict.** PARTIAL.
- Confirmed: iPXE is a variant of the rebuild action, and also a create option.
- Not documented: whether an `image` must accompany it.
- The official client and the API reference disagree on the action name (`reinstall` vs `rebuild`).

**Consequence.** The marker on "rebuild-shaped" becomes `[observed — Cherry-spec, 2026-10-06]`. The image question and the
action name need a live call (batch D). Cherry is out of v1 (`ADR-0010`), so nothing blocks.

### V21 — Cherry Servers: server-side tag filtering

**Spec.** `08-provider-notes.md:342`.

**Sources.**
- Cherry-spec `GET /v1/projects/{projectId}/servers` query parameters: `limit, offset, bgp_status,
  bgp_enabled, bgp_available, bgp_active, bgp_connected, backup_storage_activated, state, status,
  search` ("Search by public IP address or hostname"), `fields`. None filters by tag.
- Cherry-spec: the server schema carries `tags` (`additionalProperties: string`).
- cherrygo `api_call_options.go` L10–19: `GetOptions` has no tag field, only arbitrary `QueryParams`.

**Verdict.** UNDETERMINABLE. No filter is documented.

**Consequence.** Correlator lookup on Cherry should page through the project's servers and match `tags`
on the client.

### V22–V24 — Account linkage (`SEC-44`)

**Spec.** `07-security-requirements.md:329-333`. For DigitalOcean also `08-provider-notes.md:319-321`.

**Sources.**
- Hetzner T&C §2.7: "A further important reason which may result in us locking or terminating the
  Customer's services or account without notice". Hetzner Docs "Account migration"
  (`https://docs.hetzner.com/managed/administration-on-konsoleh/account-migration/`): "these accounts
  will remain separate and both will continue to exist". That sentence is about not merging accounts
  across interfaces. Nothing in either source addresses linked termination.
- DO ToS (last updated 22 Aug 2026): "we reserve the right, in our sole discretion, to terminate your
  access to all or any part of the Websites and/or Services at any time". §4.4 contemplates resale
  ("including via resale"). Nothing addresses related accounts.
- Cherry ToS §16.1 and §16.3 provide suspension, then termination after 30 days. §2.4: "You may resell
  the Services. Please contact [email] for more details." Nothing addresses related accounts.

**Verdict.** UNDETERMINABLE for each provider. Not documented.

**Consequence.** `SEC-43` remains "a belief, not a defence" (`SEC-44`'s words). Only a written provider
answer can settle it; no test on an account can show what a provider will do.

## 3. `PRV-13b` — when billing stops after deletion

**The main point for the requirement.** `billing_stop_window` is a latency in seconds from request to
billing stop. Hetzner (Cloud and Robot) rounds partial hours up, and Robot bills add-ons per day "or
part thereof". On those products a delete at any latency still pays for the rest of the started unit:
up to an hour, or up to a day. That is a property of the unit, so a twenty-sample latency measurement
cannot reveal it. The reserve's wind-down term therefore needs the rounding unit as well as the latency.

DigitalOcean bills per second, so its post-delete cost is the latency itself. Its 60-second/$0.01
minimum binds only on Droplets that live less than a minute.

The units come from the documents below. The latencies still need `F18`'s measurement.

| Provider | Granularity (documented) | Stops at | Survives deletion and keeps billing | Not documented |
|---|---|---|---|---|
| Hetzner Cloud | hourly, partial hours rounded up, monthly cap | server deletion | Primary IPs (hourly; detached, not deleted, unless `auto_delete`), Floating IPs (monthly, prorated), Volumes (hourly, monthly cap), Snapshots (per GB-month, prorated). Backups are deleted with the server | delete-to-stop latency; `auto_delete` value on an auto-created Primary IP |
| Hetzner Robot | hourly, partial hours rounded up, monthly cap; add-ons "per day or part thereof"; licences full calendar months | immediate cancellation (`cancellation_date=now`) | additional IPs and subnets *may* survive ("You may need to cancel these separately"; cancellable by API: `POST /ip/{ip}/cancellation`, `POST /subnet/{net-ip}/cancellation`). Licences carry a month-end billing tail; nothing says they outlive the server, and the driver orders none | whether IPs auto-cancel with the server; whether the `primary_ipv4` order add-on is a day-billed "add-on" (this note's inference, not stated) |
| DigitalOcean | per second, minimum 60 s or $0.01 | destroy | reserved and floating IPs, snapshots, volumes, volume snapshots (API reports each one's monthly `cost` if retained); backups retained about 4 weeks | whether retained backups bill; v5 public-IPv4 line after destroy |
| Cherry Servers | on-demand "Hourly" from team balance; fixed-term monthly or annual, prepaid and not refunded | portal: "Your service will be canceled immediately" | "IP addresses, load balancers, and backup storage … continue to run and use your account balance until independently canceled" (the docs say "such as", so the list is not exhaustive) | hourly rounding unit; conflict with ToS §17.4 (below) |

**Hetzner Cloud.**
- Billing FAQ (`https://docs.hetzner.com/cloud/billing/faq`):
  - "If you delete your cloud server before the end of the billing month, we will only bill you for the
    hourly rate."
  - "We always round up the hourly usage of a server. If you create a server just for a few minutes, we
    will still bill you for one whole hour."
  - "We will bill you for your servers until you delete them, independent of their state."
  - "If you want to stop paying for a Primary IP, you need to delete it."
  - "We will bill you for Snapshots per gigabyte per month. If a Snapshot only exists for a fraction of
    a month, then we will only bill you for this fraction."
  - "If you use your Floating IP for less than a month, we will bill you for the appropriate fraction
    of it."
- HC-spec `DELETE /servers/{id}`: "This immediately removes the Server from your account … Any
  resources attached to the server (like Volumes, Primary IPs, Floating IPs, Firewalls, Placement
  Groups) are detached while the server is deleted."
- HC-spec Primary IP `auto_delete`: "If enabled the [Primary IP] will be deleted once the assigned
  resource gets deleted", `default: False`. Server create's `public_net.ipv4`: "If omitted and
  enable_ipv4 is true, a new ipv4 Primary IP will automatically be created". That automatically created
  IP's `auto_delete` is not documented.
- HC-spec Images tag: backup images are "Bound to exactly one Server. If you delete the Server, you also
  delete all backups bound to it."
- Hetzner Docs, Volumes: "Volumes have a monthly price cap and are billed hourly."

Declare `surviving_attachments`: Primary IP (`api`, unless `auto_delete` is read back true), Floating IP
(`api`), Volume (`api`), Snapshot (`api`).

**Hetzner Robot.**
- "Billing system at Hetzner" (`https://docs.hetzner.com/general/others/new-billing-model/`, last change
  2026-10-01):
  - "We round up partial hours. The total cost is never more than the monthly price."
  - "We exclude from hourly billing … products with a monthly term, such as licenses; and products we
    bill per day or part thereof, such as colocation and add-ons."
- "Cancellations on Robot": "We automatically cancel additional hardware (e.g., drives) unless you book
  it separately." For IPs and subnets: "Our billing is based on how long you used the IP or subnet."
- Server Auction FAQ: "The cancellation period for these servers is usually immediately." It also says
  that extra IPs, hardware and add-ons: "You may need to cancel these separately."

Declare additional IPs and subnets as possible `api` survivors until batch B, step 9 settles it. The
descriptor's unit is an hour for the server, and should be taken as a day for anything ordered as an
add-on.

**DigitalOcean.** Quotes are in V17. Further sources:
- Reserved IP pricing (last verified 25 Jun 2025): "Reserved IPv4 addresses cost $5.00 per month ($0.01
  per hour) when reserved but not assigned to a Droplet". "You are not billed unless you accrue $1 or
  more per reserved IP."
- Volumes pricing: "Charges accrue hourly for as long as the volume exists. You are charged for volumes
  whether or not they are attached to a Droplet."
- Snapshots pricing: "$0.06 per GB per month … There is a minimum charge of $0.01".

**Cherry Servers.**
- "Terminate a Service": "if you terminate a server, tertiary services, such as IP addresses, load
  balancers, and backup storage, will be disconnected from the related server, but will continue to run
  and use your account balance until independently canceled."
- Payment options: "All on-demand services are billed on a "pay per use" basis."
- FAQ: "Do I still incur charges on inactive bare metal servers? Yes".
- ToS §17.2: "No refund will be provided by Cherry Servers for any remaining prepaid fixed subscription
  term". So the driver must order the hourly cycle only.
- **Unresolved conflict.** ToS §17.4: "The Agreement may be terminated by giving notice to the other
  Party at least 30 (thirty) days before the end of the relevant payment period. In such case the Client
  will be liable to pay all relevant Access Fees on a pro-rata basis for each day of the current period".
  The docs say on-demand is "pay per use" and cancellation is immediate. Whether §17.4 reaches hourly
  servers is UNDETERMINABLE.
- The API has DELETE for IPs, storages, backup storages and load balancers, so those survivors are
  `api`.

## 4. Lines skipped (meta-mentions and already resolved)

- `01-domain-model.md:280`: a comment on V14's marker ("matters only if it turns out false").
- `02-provider-contract.md:625`: `PRV-30` is already confirmed ("no longer `[verify]`").
- `02-provider-contract.md:761`: the header of `PRV-35`'s table. Its rows are V1, V6 and V15.
- `08-provider-notes.md:17`: the marker convention.
- `08-provider-notes.md:237`: the blanket "`[verify]` unless marked otherwise" over the DigitalOcean
  section. Each fact under it carries its own marker, and the `[verify]` ones are V14–V18 and V23.
- `08-provider-notes.md:352`: `F29` is resolved ("now resolved against the design's assumption").
- `08-provider-notes.md:375`: test mode is resolved ("The `[verify]` that stood here is answered").
- `11-open-findings.md:873`: the `F29` record of the resolved claim.
- `11-open-findings.md:1116`: a pointer to `PRV-35` ("`[verify]`"). The facts are V1 and V6.
- `CONTEXT.md:435`: the glossary entry defining the marker.
- `executive-summary.md:368`: a pointer to the DigitalOcean section's state.
- `executive-summary.md:412`: a reading instruction naming the markers.
- `README.md:113`, `README.md:114`: the marker convention.

## 5. Needs a live account

Batched so that one session per provider settles several facts. Written inquiries are separate,
because no account action can settle them.

**Batch A — Hetzner Cloud (one smallest server, about €0.01)**
1. Create a fresh ED25519 key with `name=pv-test-<uuid>` and label `pv-op=<uuid>`. Confirm that
   `GET /ssh_keys?label_selector=pv-op==<uuid>` returns it (V3).
2. `POST /servers` with that key and **no** `public_net.ipv4`. Record the create Action id.
3. While the Action is still `running`, `DELETE /ssh_keys/{id}` (V2).
4. Wait for the Action's `success`, then try SSH with the key. Success means deletion during the Action
   is safe.
5. Read `public_net.ipv4.id` from `GET /servers/{id}`, then `GET /primary_ips/{that id}`. Record
   `auto_delete` on the automatically created IPv4 (`PRV-13b`).
6. Create a second key. Call `enable_rescue` with it, then call `enable_rescue` again with a third key
   (V4). Record the error, or which key works after `reset`.
7. Call `enable_rescue` with a key, `DELETE` that key, then `reset`. Try SSH into rescue (V2, rescue
   timing).
8. Add labels to the server one at a time until the API rejects one. Record the count and the error
   (V5).
9. Delete the server. Note the UTC times of the `DELETE` and of the `deleting` → `404` transition.
10. When the next invoice's usage statement arrives (up to 28 days after month end), read the server's
    billed hours (`PRV-13b`).

**Batch B — Hetzner Robot (one auction order, about €0.08, ordering enabled)**
1. `POST /key` with `name=pv-<uuid>` (V9). Read it back.
2. `GET /order/server_market/product`. Pick the cheapest offer and record its `id`.
3. Order it with `authorized_key[]=<fp>`, `addon[]=primary_ipv4` and `test=false`. Without the add-on
   the server is delivered with no IPv4 (`server_ip: null`), and steps 7–8 would need IPv6 egress
   from the test host. The add-on also exposes the day tail in steps 9–10 (`PRV-13b`).
4. Poll until `ready`. Check `server_number == offer id` (V8, one more sample).
5. `DELETE /key/{fp}` (V9).
6. `GET /order/server_market/transaction`. Check that `authorized_key[]` still shows the fingerprint (V9).
7. `POST /boot/{n}/rescue` with a key, `reset`, and SSH in. Run
   `grep -n TAKE_OVER_RESCUE_SYSTEM_SSH_PUBLIC_KEYS` over the installimage scripts in the rescue system.
   Compare `/root/.ssh/robot_user_keys` with the activation fingerprint (V11).
8. With rescue still active, `POST /boot/{n}/rescue` again with a different key (V10). Record the
   response, then `GET /boot/{n}/rescue`.
9. `POST /server/{n}/cancellation` with `cancellation_date=now`. Record the UTC time. Check `GET /ip`
   for whether the add-on IPv4 outlives the server.
10. On the next invoice, read the hours billed for the server and the days for any add-on (`PRV-13b`).

**Batch C — DigitalOcean (one `s-1vcpu-512mb` Droplet, under $0.01)**
1. Create a key named `pv-<uuid>`. Create a Droplet with it and tag `pv:<uuid>`. Record the time of the
   `202`.
2. While `status` is `new`, `DELETE /v2/account/keys/{id}` (V18).
3. When `active`, try SSH with the key. Success means deletion before boot is safe.
4. `GET /v2/droplets?tag_name=pv:<uuid>`. Confirm the tag round-trips in the case it was written (V16).
5. `GET /v2/droplets/{id}/destroy_with_associated_resources`. Record the keys and `cost` values
   (`PRV-13a`).
6. `DELETE /v2/droplets/{id}`. Record the UTC time.
7. Repeat steps 1–6 twenty times for `F18`'s billing-stop sample. Read each Droplet's line on the
   invoice (`PRV-13b`).

**Batch D — Cherry Servers (one hourly server; out of v1, so lowest priority)**
1. Create a key with `label=pv-<uuid>`. `POST` a server on the hourly cycle with the key and
   `tags={"pv-op":"<uuid>"}`.
2. Immediately `DELETE /v1/ssh-keys/{id}` (V19).
3. When `deployed`, try SSH. Success means the key was captured at request time.
4. `GET /v1/projects/{p}/servers?tags[pv-op]=<uuid>` and `?pv-op=<uuid>`. Check whether either filters
   (V21).
5. `POST /actions` with `{"type":"rebuild","ipxe":<b64>}` and no `image`. Then the same with
   `"type":"reinstall"`. Record both responses (V20).
6. Attach an extra IP, then `DELETE /v1/servers/{id}`. Confirm the IP still exists and is billed. Read
   the team-balance debits for the server's last hour, and for any day-based tail that would show
   §17.4 applies (`PRV-13b`).

**Written inquiries (support tickets, not tests)**
1. Hetzner, DigitalOcean and Cherry: "Do you link and terminate separately registered accounts that
   share a payment method, contact address or beneficial owner?" (V22–V24, `SEC-44`).
2. Hetzner: "May a reseller serve end users it has not identified?" (V13).
3. Hetzner: "Is an auction offer's `id` always the delivered `server_number`?" (V8).
4. Cherry: "Does ToS §17.4's notice period apply to hourly (on-demand) servers?" (`PRV-13b`).
