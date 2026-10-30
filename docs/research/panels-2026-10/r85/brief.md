# triage-1027 Panel F — r85: validation

Read this brief and `/var/tmp/provisiond-panel-r85/notes.md` whole. Your own independent
clone is pinned to origin/master **3109b5b44eae17e288cf52aaa976993bd8c5626c**. This packet contains proposals, not adopted
amendments. Evaluate the exact forms separately; no source has been amended for this round.

Read-only: do not change source, Git state, tracker or panel records; do not commit, push,
checkout, reset, stash, clean, contact a PR or start subagents/background work. Do not run
`lake build`, `nix develop`, check-all or the formal gate: the host admits at most two Lean
builds and the manager runs the repository gates separately. Temporary verification files
may be written only in `/var/tmp/provisiond-panel-r85/tmp/<your-seat>/`. Do not read credential,
session or config locations (`~/.claude`, `~/.codex`, `~/.grok`, authentication files,
kubeconfig, browser profiles), another reader's output/clone or unrelated main-checkout
content. Pinned source and this packet are the evidence. Return a substantive final answer
within the 3600-second launcher bound, aiming for at most 2400 words plus any exact replacement.
Do not wait for other readers. The manager's gate result is evidence about the unchanged pin,
not evidence that any proposed amendment passes gates or that a running system conforms.

**apply notes.md rule 6 exactly as written; this prompt adds no void rule.**

## Scope and verification

The owner authorized panels D–G in parallel: “Do all in parallel”. This turn verifies and
launches one reading round only: no implementation, tracker change, adoption, PR action,
merge or consensus round. The three beads are open in the JSONL at the pin. The table's
line numbers were refreshed below. Comparing the current owner passages with 08191bb
(the triage's starting master) found no settlement of these questions. The durable restore
provenance rule is newer than that triage and is included explicitly; fixtures below use
restore_markers_untrusted false. No claim that all install errors render none is intended.

The pv-wfld disposition is outside this vote. The existing present-value failure sentence
is quoted under Q3; keep its writer-based kind and retryability. Do not turn the historical,
unvoted suggestion that internal should win into an owner ruling. All error messages in the
example pairs are illustrative human prose; assertions concern kind, retryable and details.

## Pinned evidence, verbatim

Source owner: `WIR-2`; `13-wire-contract.md:28–39` at `3109b5b44eae17e288cf52aaa976993bd8c5626c`, verbatim.

```text
**WIR-2** **Unknown fields in a request body MUST be rejected** with `invalid_request`. The field named in
`details.field` MUST be selected under `WIR-9a`, including when the same validation step also
rejects known fields. A tolerant reader lets a misspelled `acknowledge_destruction` pass silently
unacknowledged, and lets two implementations diverge without either noticing. Two carve-outs:
`provider_options` (`WIR-17`) is a free-form object whose interior is the driver's to validate,
not the core parser's; and **unknown query parameters are ignored**, matching `WIR-32`'s leniency
on pagination. Responses are the opposite of bodies: **clients MUST ignore unknown response
fields**, so the server can add fields without a version bump.

*Amended 2026-10-22 (`pv-ss4`; panel r62, `docs/research/panels-2026-10/r62/`): applied the reviewed field-pointer form and validation ordering.*

**WIR-3** **AMENDED.** The canonical form of a body — for idempotency comparison only — is
```

Source owner: `WIR-9 / WIR-9a`; `13-wire-contract.md:121–144` at `3109b5b44eae17e288cf52aaa976993bd8c5626c`, verbatim.

```text

`kind` is `DOM-17`'s closed set. `retryable` is normative for callers (`API-51`). The inner
`error` object is exactly `kind`/`message`/`retryable`/`details` and nothing else, because it is
the object `WIR-10b` embeds in an operation view, which carries its own `correlation_id`.

**WIR-9a** **`details` is machine-readable and its keys are defined per kind, not left to prose.**
The caller is software; routing a value through `message` (which `API-25` constrains) forces an
agent to parse English. Minimum keys:

| kind | `details` |
|---|---|
| `insufficient_balance` | `available_sats`, `required_sats` |
| `invalid_request` / `offer_not_sellable` on create | `reason: "offer_not_sellable"`; no cap or balance result or amount derived from the withheld offer's price |
| `invalid_request` naming a field (`WIR-2`, `OPS-23`, `PRV-47`) | `field`: an RFC 6901 JSON Pointer into the request body (`"/acknowledge_purchase"`, `"/provider_options/location"`), also where the named field is absent. Where one validation step rejects several fields (an `API-7` step, `OPS-23`'s repeated check of caller-supplied fields, or `PRV-47`'s validation), the least escaped pointer, compared by unsigned UTF-16 code units, the order RFC 8785 (`WIR-3`) sorts member names in |
| `not_activated` | `activation_minimum_sats` |
| `rate_limited` | `retry_after_ms` |
| `ceiling_exceeded` | `ceiling` (which one, from `SEC-39`'s stated set), `limit`, `interval_seconds`, `retry_after_ms` (to the end of the current interval) |
| `halted` | `retry_after_ms`, `gate` (`"solvency"` \| `"rate_unavailable"`) |
| `overloaded` | `retry_after_ms` (`STO-55`; added 2026-09-12) |
| `gone` | `retained_until` — and the safe reaction is to read machines and balance, never re-issue (`DOM-21`) |
| `conflict` | `reason` (`"idempotency_mismatch"` \| `"state"` \| `"credential_already_replaced"` (`API-56`) \| `"suspension_in_flight"` (`WIR-41`) \| `"tenant_suspended"` (`API-58`) \| `"case_closed"` (`WIR-43`) \| `"signup_window_closed"` (`API-34`) \| `"deposit_already_attributed"` (`WIR-42`) \| `"cancellation_committed"` (`OPS-42`) \| `"price_moved"` (`OPS-43`; with `shortfall_native` and `currency`) \| `"account_terminated"` (`API-63`) \| `"incomplete_record"` (`OPS-23`) \| `"cut_off"` (`OPS-21`)) |
| `unsupported` | `provider_account`, `capability` (`DOM-10`) |
| `authentication` | `reason` (`"token"` \| `"unknown_principal"`) |
| `integrity` | `expected`, `observed` where disclosable (`SEC-16`) |
```

Source owner: `WIR-9a / WIR-9b`; `13-wire-contract.md:195–236` at `3109b5b44eae17e288cf52aaa976993bd8c5626c`, verbatim.

```text

**On an `install` operation's error, `details.disk_effect` is required whatever the kind** (*added
2026-09-15, `pv-x8r`*): `none` where this operation is established to have written nothing to the
target disk — `OPS-45`'s write-started marker unset on `rootfs_via_rescue` or `raw_disk`, or a
`provider_native`/`provider_catalogue` rejection the provider did not act on;
`destructive_boundary_crossed` on `rootfs_via_rescue` or `raw_disk` once that marker is set, which
tells the caller not to assume its prior contents survived and does not assert that the install
completed; `unknown` after a `provider_native`/`provider_catalogue` dispatch whose effect nothing
established. It is rendered from the operation's marker columns and outlives the payload purge with
them (`OPS-45`). `status` alone never says which: `RSC-3`'s abort with the disk untouched and an
installer's rejection of a layout it had begun partitioning for both settle `failed`, and without
this key they are identical on the wire. `retryable` is `DOM-17`'s question about the same request,
not this one — a rejected layout re-sent unchanged is refused again, and `disk_effect` does not make
it sensible.

**On an `install` or `rescue_inventory` operation's error, `details.rescue_exit` is required whatever
the kind** (*added 2026-09-15*): `none` only where no rescue session was opened, `clean` where the
driver's end-rescue call returned success, `unknown` where it failed or the operation died before
reaching it — `OPS-45`'s second marker, rendered as `disk_effect` renders the first. With `unknown`
the error also carries `rescue_address` and `rescue_port` (`RSC-19`): the machine is the tenant's own
and its address is already on `WIR-11`. It never carries a recovery-key path; the file is named by
the operation id and the directory is the operator's (`RSC-20`).

**Restore marker provenance is durable (`STO-54`).** On an install or rescue-inventory operation's
error, `disk_effect` (install) and `rescue_exit` (both kinds) are rendered `unknown` where
`restore_markers_untrusted` is `true` or transitionally `null`, whatever the marker columns hold.
Where it is `false`, the ordinary marker rendering above applies. An `unknown` `rescue_exit` retains
the address-and-port requirements above; those fields are not replaced with `unknown`. Neither
incident closure nor an ordinary restart with no open restore record changes the provenance used for
rendering.

*Amended 2026-10-22 (`pv-ss4`; panel r62, `docs/research/panels-2026-10/r62/`; owner decision 2026-10-22): applied the reviewed field-pointer form and validation ordering.*

**WIR-9b** **`retryable` precedence** (*amended 2026-10-04, `ADR-0030`*). For `API-7`'s rich purchase-tail refusal, the envelope's
`retryable` MUST be true iff every refusal entry's `retryable` is true. Each entry retains its
per-refusal value from `WIR-9a`. When an error accompanies an operation view, the operation
view's `retryable` (`WIR-10`) is authoritative and the envelope's MUST equal it.
`needs_reconciliation` and `gone` are **always** `retryable: false` — re-issuing either under a
fresh idempotency key is a fresh operation, not a retry: a second purchase on a create, a second
destructive write on an install (`API-51`).

*Amended 2026-10-08 (`ADR-0035`):* `API-51` requires a reconciliation-pending rate-limited
```

Source owner: `WIR-20`; `13-wire-contract.md:684–710` at `3109b5b44eae17e288cf52aaa976993bd8c5626c`, verbatim.

```text
**WIR-20** `POST /v1/machines/{id}/actions/install` — **AMENDED — the install body is a closed
discriminated union, one variant per `DOM-13`
pairing, and it carries every field the rescue engine needs from the caller.** The withdrawn body
showed only `rootfs_via_rescue` and omitted the raw-disk target device (`RSC-26`), the host-key
trust decision (`RSC-3`/`RSC-4`), the layout (`RSC-22`) and the installed keys (`RSC-13`) — so
three of four strategies were unsendable and the security-critical trust choice had no field.

Common to every variant: `acknowledge_destruction: true` (`API-14`). *`on_failure` ∈ {`exit_rescue`,
`leave_in_rescue`} was common to every variant until 2026-09-15 (`RSC-18`, withdrawn); a body
carrying it is `WIR-2`'s unknown field, `invalid_request`.* **The two rescue-entering variants —
`rootfs_via_rescue` and `raw_disk` — additionally carry a required `trust` object**, exactly one of
three, not two. `provider_native` enters no rescue and has no host key to pin, so it carries none —
and a `provider_native` body that supplies one is an unknown field for that variant, rejected
`invalid_request` by `WIR-2` (its row below):

| `trust` | Meaning |
|---|---|
| `{"use_provider_keys": true}` | Pin driver-published keys or fingerprints, including pins arriving after boot (`PRV-16`, `PRV-19`). If required pins have not arrived by `RSC-9`'s deadline, `RSC-3` says "Abort with an `integrity` error". For Robot, `PRV-20` says "If eligible pins have not arrived by `RSC-9`'s deadline … connection fails `integrity`" |
| `{"expected_host_keys": ["ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIhostkeyxxxxxxxxxxxxxxxxxxxxxxxx"]}` | `RSC-3` says "Caller supplied expected host keys and the driver published none". `RSC-3` says "Pin exactly those. Strict checking." `RSC-3` says "On overlap, the engine MUST pin exactly the caller keys whose algorithm and SHA256 digest match a driver pin, MUST offer SSH only their host-key algorithms (for an RSA key, `rsa-sha2-512,rsa-sha2-256`), and MUST refuse before authentication a presented key that matches a driver pin but is not one of the caller's keys." For Robot, `RSC-3` says "The actual Robot connection MUST match an accepted provider pin, even when a caller key is supplied." |
| `{"accept_unpinned": true}` | First-use trust where available; `PRV-20` says "An awaiting Robot session cannot become eligible for first-use trust, even with the caller's explicit first-use opt-in" |

*Amended 2026-10-12 (`ADR-0041`): Robot's provider pins arrive after boot as
fingerprints; the caller full-key form remains available.*

**The provider-keys variant was missing and its absence was a silent security downgrade.** It is
`RSC-3`'s provider-keys row and the ordinary one on Hetzner Robot, where provider
fingerprints become eligible through refresh after reset (`PRV-19`, `ADR-0041`). Caller-supplied
```

Source owner: `WIR-20`; `13-wire-contract.md:726–748` at `3109b5b44eae17e288cf52aaa976993bd8c5626c`, verbatim.

```text
- `raw_disk`: `source.type` `raw_disk` (`url`, `sha256`, `compression` ∈ {`none`, `gzip`, `xz`,
  `zstd`, `bzip2`}), a required **`target`** object — `{"identifier": "S4EVNF0N123456",
  "inventory_fingerprint": "774651ea4106f48eeb2c3168486b267d5f773ccc77d10d8f489842eaff5419c9"}`,
  where `identifier` is a drive serial or WWN and the fingerprint is the one `RSC-38`'s rescue
  inventory returned — **not a device path** (`RSC-26`) —
  optional `grow_partition` (boolean, default `false`, `RSC-31`), and no `authorized_keys`
  (`RSC-14` forbids injecting into an opaque image).
- `provider_native`: `source.type` is `catalog` (`image`); no `layout`, no `trust` (no rescue is
  entered); it MAY carry `authorized_keys`.
- `provider_catalogue` (**ADDED 2026-09-02**): `source.type` is `raw_disk` — the same `url`,
  `sha256` and `compression` a rescue raw-disk install sends, because it is the same caller input
  delivered by a different mechanism (`DOM-13`, `DOM-28`). No `layout` and no `target`: the provider
  converts the image and decides the disk (`RSC-43`). No `trust`: no rescue is entered, so there is
  no host key to pin, and a body supplying one is an unknown field for this variant and is rejected
  `invalid_request` by `WIR-2`. No `authorized_keys`, on `RSC-14`'s reasoning: the filesystem inside
  a caller-supplied image is unknown, so keys cannot be injected generically and silently ignoring
  them would be worse. *`provider_native` MAY carry them and the difference is the image, not the
  mechanism — it names an image from the **provider's own catalogue**, which the provider supports
  and provisions keys into as a documented feature of the same rebuild call. A caller's imported
  image has no such guarantee, and the provider's key injection may or may not find anything to
  write to.* The `sha256` is required and is what `RSC-39`
  verifies **in transit**; it attests nothing about what the provider writes (`DOM-28`, `SEC-16`),
  and `machines.last_install` records that distinction on the machine (`DOM-29`).
```

Source owner: `WIR-35`; `13-wire-contract.md:906–913` at `3109b5b44eae17e288cf52aaa976993bd8c5626c`, verbatim.

```text
**WIR-35** `POST /v1/operations/{id}/actions/resolve` — **operator-only** (`WIR-34`),
the reconciliation verbs `OPS-31` mandates and no endpoint carried (this was the operator half of
`F19`). Body is a discriminated union: `{"resolution": "observed", "external_id": "2345678",
"kept_duplicate": "2345679", "operator_ref": "opref-7d41c9"}` attaches a discovered resource
(`OPS-27`);
`{"resolution": "absent", "operator_ref": "opref-7d41ca"}` records that nothing was created and releases
the commitment (`LDG-32`); `{"resolution": "abandoned", "operator_ref": "opref-7d41cb"}` gives up.
**AMENDED 2026-09-02 — two more members, for the kinds that act on a machine that already exists —
```

Source owner: `API-13 / API-14`; `04-api-contract.md:962–985` at `3109b5b44eae17e288cf52aaa976993bd8c5626c`, verbatim.

```text
**API-13** The following MUST be enforced before an operation is enqueued:

| Field | Rule |
|---|---|
| hostname | 1–253 characters, no CR or LF |
| offer identifier | 1–256 characters |
| SSH public keys | at most 64, each ≤16 KiB, each recognizably an OpenSSH public key |
| expected rescue host keys | at most 16, each a complete OpenSSH public host key |
| catalog image | 1–256 characters |
| user data / post-install script | ≤1 MiB |
| provider options | MUST be a JSON object |
| image URL | ≤8192 bytes, no fragment, no embedded credentials, scheme `https` (or `http` only where explicitly enabled), host in the allowlist. **For a `provider_catalogue` install the allowlist is mandatory and an empty one refuses the request** (`SEC-19`, `RSC-39`), since provisiond itself is the client there; on the rescue strategies an empty list still means any host and is a startup warning. *"When one is configured" applied the fail-open reading to both paths and was withdrawn 2026-09-02* |
| disk identifier | a JSON string, non-empty after normalization (`RSC-46`); a `null`, non-string or empty-after-normalization `target.identifier` or `layout.drives[].identifier` MUST be refused `invalid_request` before enqueue. Resolution: `RSC-26`. |
| digest | exactly 64 hex characters (`DOM-14`) |
| strategy/image pairing | per `DOM-13` |
| host-key policy | pinned keys and "accept unpinned" MUST be mutually exclusive |
| request body size | globally capped (2 MiB is a reasonable default) |

*Amended 2026-10-22 (`pv-6p8`, panels r61–r61f; owner decision 2026-10-22): added admission of
disk identifiers before enqueue.*

**API-14** An install request MUST carry an explicit destructive acknowledgement, and a
delete request MUST carry one. Absent or false MUST fail `400`. This is per request, and
is not satisfied by authentication, by idempotency, or by having sent one previously.
```

Source owner: `RSC-4`; `06-rescue-install.md:101–102` at `3109b5b44eae17e288cf52aaa976993bd8c5626c`, verbatim.

```text
**RSC-4** Caller-supplied keys and the first-use-trust opt-in MUST be mutually exclusive
in the request (`API-13`).
```

Source owner: `PRV-47`; `02-provider-contract.md:166–176` at `3109b5b44eae17e288cf52aaa976993bd8c5626c`, verbatim.

```text
**PRV-47** **Added 2026-10-09 (`ADR-0036`).** Before any provider mutation for a create,
the driver MUST validate every value it forwards to the provider, including provider options,
and MUST reject invalid values without any provider mutation for that create, including a
per-order key upload or order request. This validation is in the
driver, after the API's body validation, because the driver knows the provider's accepted values.
A caller-supplied value this validation rejects fails `invalid_request` naming the rejected value's
field, with `retryable: false` on both the error and the operation view (`WIR-9b`). A value this system wrote rather than the caller, such as `PRV-9`'s operation id as a temporary key's "provider-side name or tag" or `PRV-32`'s per-order throwaway SSH key, that this validation rejects fails `internal` (`DOM-17`); `OPS-11`'s create row gives its `retryable`. `OPS-11` says
"Any create failure the worker records before any step-9 request (before any per-order key upload
or order request) MUST settle `failed`, whatever its kind" and "The commitment is released in full
under `LDG-32` … with no setup-fee or first-unit debit".

```

Source owner: `PRV-5`; `02-provider-contract.md:39–50` at `3109b5b44eae17e288cf52aaa976993bd8c5626c`, verbatim.

```text
**Amended 2026-10-08 (`ADR-0035`): every driver error MUST carry `details.accepted`.**
It is `true` once the provider answered successfully to the request performing this operation's
mutation, and `false` where the driver establishes that request was not accepted (including a
read-only operation with no mutation). For create this is the ordering request associated with
its correlator (`PRV-26`), never a preceding key upload. Other mutations need no correlator:
`PRV-26` says "This applies to create and to nothing else."
A failure before any byte of the mutating request was sent MUST report `details.accepted: false`.
A driver that cannot determine acceptance MUST report `details.accepted: null` with the mutating
request's own failure mapped as above (`network`, `timeout`, or `provider` with its status), using
`internal` only where no mapping applies. It MUST NOT report a later request's failure in place
of the mutating request's own, omit `details.accepted`, or substitute `false` for unknown
acceptance. Known acceptance MUST remain `true` on every later error, whatever its kind.
```

Source owner: `OPS-11`; `03-operation-lifecycle.md:248–250` at `3109b5b44eae17e288cf52aaa976993bd8c5626c`, verbatim.

```text
| install | `needs_reconciliation` for `network`, `timeout`, `provider`, `internal`, `conflict`, and `integrity` **once the write-started marker is set** (`OPS-45`). `failed` for the deterministic caller errors `invalid_request`, `not_found`, `unsupported`, `authentication` and `rate_limited` **where no rescue session was left open** (the paragraph below), **and for any failure at all while `OPS-45`'s two markers say the disk is untouched and no rescue session was left open** — including `integrity` before the connection, which is `RSC-3`'s host-key abort. An install that got further than that may have begun overwriting a disk, or may have left the machine in rescue; one that did neither, provably did neither. **`failed` past the write-started marker, where rescue exited cleanly, asserts that the install did not complete and nothing about the disk** (*2026-09-15, `pv-x8r`*): the deterministic caller kinds stay `failed` there because the engine knows what it did — an installer that rejected the layout it had begun partitioning for is a known outcome — and `needs_reconciliation` is the state for an outcome nobody knows (`CONTEXT.md`), whose only truthful verb here would be `abandoned`, which settles `failed` after a human looked. It does not mean `not_applied`, which `OPS-31` refuses there. What the disk holds is `OPS-45`'s marker's fact, rendered to the caller as `WIR-9a`'s `disk_effect`; the state does not carry it. |
| create | Any create failure the worker records before any step-9 request (before any per-order key upload or order request) MUST settle `failed`, whatever its kind. The boundary is the worker invoking the first step-9 per-order key upload or order call. It is the worker's position: this rule MUST NOT read `about_to_order_at`, nor any snapshot or cached copy of it. The settle write keeps the ordinary worker guard (`STO-3`; `OPS-6`: "every write that worker makes to the operation MUST carry `claim_number = mine`"), with no `about_to_order_at IS NULL` term. The error MUST keep its reported kind. For `network`, `timeout`, `internal`, `provider` with a 5xx or no upstream status, and a cut-off `conflict`, it MUST carry `retryable: true` on both the error and the operation view; a failure classified `failed` without this pre-step-9 rule keeps its stated `retryable`. An `OPS-21` cancellation of `execute` stays a cut-off `conflict`. The commitment is released in full under `LDG-32` ("A commitment MUST be closed, and its remaining amount released in full") and `LDG-39` ("**Never debited**; released with the commitment (`LDG-32`)"), with no setup-fee or first-unit debit. Settlement takes the `LDG-35` primitive, then follows `STO-3`: "The guarded status write precedes every money write in the transaction and short-circuits the rest". Where the create holds a resource-offer exclusion, it is freed under `STO-58`: "Its lifetime follows the winning create's outcome settlement". Before step 9 no provider mutation has been requested (`PRV-50`). From step 9 onward, including a key-upload failure or an order-call failure before any byte was sent: `needs_reconciliation` if the failure is *ambiguous*, otherwise `failed`. |
| power, reverse-DNS, delete, release attachment | Subject to the goal-state success rule, any failure the worker records while `OPS-45`'s write-started marker is unset, where no rescue session was opened or the one opened was closed without error, MUST settle `failed`, whatever its kind (`OPS-45`, which owns the rule), unless the mutation is known to have been accepted (`details.accepted` is `true`). Otherwise `needs_reconciliation` if the failure is *ambiguous*, otherwise `failed`. A release is a delete of a smaller thing (`PRV-45`) and classifies exactly as one. |
```

Source owner: `OPS-45`; `03-operation-lifecycle.md:1489–1513` at `3109b5b44eae17e288cf52aaa976993bd8c5626c`, verbatim.

```text
**Entering rescue is itself a mutation, so a second marker is required and the two are read
together.** Activating rescue reboots the machine into another operating system (`PRV-15`) and
`PRV-22` makes *failure* of the exit always ambiguous — so "nothing was written" is not on its own
"nothing happened". The engine MUST therefore also record **whether the rescue session it opened
was closed without error** — `rescue_exited_cleanly` (`05-persistence.md`), three-valued: **null**,
the column before its first write, which says no session was opened (*reworded 2026-09-19; it read
"where begin rescue was never dispatched"*); **false, written before begin rescue (`PRV-15`) is
dispatched**, as the write-started marker is written before its phase, and standing while the
session is open, where the exit fails and where the operation dies before reaching it; **true**
when the driver's end-rescue call returns success. A dead process writes nothing, which is why
`false` precedes the session and not the exit: it is what lets `OPS-15`'s pass render `rescue_exit:
"unknown"` (`RSC-19`, `WIR-9a`). `false` is the conservative value as much as the open-session one:
a process that dies between that write and the dispatch leaves `false` over a machine that was
never rebooted into rescue, and the column does not separate that row from one whose session is
still open. Null is the only value that means no session was opened, and `false` moves to `true`
and never back. **A driver's report that it cleaned up after a partial activation (`PRV-18`) does
not move this marker**: the engine did not open the session and did not close it. On failed
deactivation `PRV-18` reports "the identifier of the rescue environment left behind"; on failed
eligible-key deletion it reports "the identifier of the key left behind". `PRV-18` also says "A key
deliberately retained while deletion is ineligible is not a failed cleanup." Those reports are
operator-facing facts, not the engine's record of its own execution. *Until 2026-09-16 this read "set when the driver's
end-rescue call returns success, left unset when it fails or when the operation dies" — the
classifier's two-way question standing where the column's three values belonged, and no sentence
said when the column was written; a never-attempted exit was a third case until `RSC-18` was
withdrawn, 2026-09-15. Four readers converged on the pre-dispatch write.*
```

Source owner: `OPS-23`; `03-operation-lifecycle.md:2018–2054` at `3109b5b44eae17e288cf52aaa976993bd8c5626c`, verbatim.

```text
**OPS-23** Validation that was performed at the API boundary MUST be repeated in the
worker before the driver is called. The record may have been written by an older version
of the service, or edited in the store. Validation is cheap; a wrong install is not. **A field a
previous-release `api` may not have written is a deterministic failure in the worker, never a
passed check** (added 2026-09-12, `ADR-0024`): a create admitted without `OPS-43`'s accepted-price
fields fails before dispatch rather than dispatching at whatever the offer says now.

For create, install, power and delete, a missing required field MUST fail as follows:

- A field the `api` itself writes when it admits the operation fails `conflict`, with
  `details.reason: "incomplete_record"` and `retryable: true` on both the error and the operation
  view. The accepted-price fields above are such fields; the worker-written correlator is not.
- A field the caller must supply fails `invalid_request` naming the field, with
  `retryable: false` on both the error and the operation view.

A field that is present but fails this repeated validation fails as its writer's bullet above says, on both the error and the operation view, and settles as these missing-field failures do.

These missing-field failures settle `failed` under `OPS-11`. On a create they come at `OPS-43`'s
step 3, and `OPS-11` says "Any create failure the worker records before any step-9 request (before any per-order key upload or order request) MUST settle `failed`, whatever its kind."
Power and delete take its last row's "any failure the worker records while `OPS-45`'s write-started marker
is unset", and its install row gives `failed`
"for any failure at all while `OPS-45`'s two markers say the disk is untouched and no rescue
session was left open". On a create, the commitment is
released in full under `LDG-39`'s "Deterministic rejection before acceptance" case, whose fee
and first-unit outcome is "**Never debited**; released with the commitment (`LDG-32`)".
Install, power and delete release no commitment here. On an install, these checks MUST run
before either `OPS-45` marker is written: its rescue marker is "**false, written before begin
rescue (`PRV-15`) is dispatched**". The install settles `failed` with `disk_effect: "none"`
and `rescue_exit: "none"` (`WIR-9a`: "`none` where this operation is established to have written
nothing to the target disk" and "`none` only where no rescue session was opened"). A release
that adds a required field MUST state whether the caller supplies it or the `api` writes it
at admission.

The worker's claim-time absence check and sale re-test at `OPS-43`'s step 5, "Check for the named
offer's absence from that result", are exceptions to this requirement's "before the driver is
called": they run on the result of `OPS-43`'s step 4, "Obtain the current driver List offers
result", after that read.
```

Source owner: `CNF-34`; `10-conformance-checklist.md:256–274` at `3109b5b44eae17e288cf52aaa976993bd8c5626c`, verbatim.

```text
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
```

Source owner: `CNF-342`; `10-conformance-checklist.md:4293–4310` at `3109b5b44eae17e288cf52aaa976993bd8c5626c`, verbatim.

```text
- [ ] **CNF-342** — **Bad forwarded values and absent offers cause no provider mutation.**
      Run on `CNF-241`'s `correlator: per_order_key` ordering channel. Use stored creates
      carrying provider-forwarded values that pass API boundary validation but the driver
      rejects, including a provider-options object containing a value the provider does not
      accept. For each, assert the driver rejects it at `OPS-43`'s step 7, "Run `PRV-47`'s
      driver validation", with no provider mutation: no per-order key upload and no order
      request. The List offers read is permitted. For each, also assert `invalid_request` with `details.field` holding the rejected value's
      RFC 6901 pointer (one under `/provider_options` for the provider-options value, such as
      `"/provider_options/location"`), `retryable: false` on both the error and the operation view, no `details.refusals` or `details.not_checked`, `failed`, the commitment released in
      full with no setup-fee or first-unit debit, and the resource-offer exclusion freed where the
      create holds one. Repeat these step-7 cases on a standard channel (`correlator: none`) with
      the same assertions.
      Add a stored create carrying provider-options members `a/b` and `a~b`, both rejected by the driver, and assert `details.field: "/provider_options/a~0b"`, the least escaped pointer in `WIR-9a`'s order; unescaped, `a/b` sorts first. With a fixture
      driver that rejects a value this system wrote, such as the operation id as a temporary key's
      name (`PRV-9`), on an otherwise valid create, assert `internal` and `retryable: true` on both
      the error and the operation view, `failed`, and the same no-mutation and release outcomes. For a stored create carrying a
      provider-forwarded value that API boundary validation rejects, assert it fails at
      `OPS-43`'s step 3 instead, with no provider request at all.
```

## Q1 — pv-y1zy: which fields enter the pointer set?

Plain-terms failure story: a caller sends two conflicting ways to trust a rescue machine.
One server points at the whole trust object; another points at a member. Likewise a typo
in a strategy can be reported as the typo itself or as a supposedly unknown variant field,
and one bad key in a list can name the list or its element. Sorting cannot resolve a
choice made before sorting. This is an inference from the quoted pointer row and body
shapes; it does not claim the current spec has adopted one of these rejected-field sets.

The triage row asks to define the set before applying the existing least-escaped-pointer
order, with exact examples and one owner. A and B implement that direction with different
sets. D repairs only the demonstrated trust group, discriminators and create-key array;
its other sets remain as open as the current rule. C is the minimal/no-change position: the current row remains the whole rule and the
implementation chooses a valid rejected-field set before sorting it. C deliberately does
not promise portable parent/member/element selection. Judge whether that discretion is
actually defensible, rather than reading C as if it contained A's new rules.

### Q1-A — members and indexed elements

Replace the current invalid_request naming-a-field table row at WIR-9a with this complete
row and append these paragraphs immediately after the minimum-keys table (before its
amendment notes). The table's other rows are unchanged.

```text
| `invalid_request` naming a field (`WIR-2`, `OPS-23`, `PRV-47`) | `field`: an RFC 6901 JSON Pointer into the request body (`"/acknowledge_purchase"`, `"/provider_options/location"`), also where the named field is absent. Where one validation step rejects several fields (an `API-7` step, `OPS-23`'s repeated check of caller-supplied fields, or `PRV-47`'s validation), the least escaped pointer, compared by unsigned UTF-16 code units, the order RFC 8785 (`WIR-3`) sorts member names in |

For this row, determine the rejected-field set before ordering its pointers. A rejected
value's own member is named, including when that required member is absent. A value of the
wrong JSON type names that member rather than hypothetical children. When several present
members violate an exactly-one or mutually-exclusive group, every present member of that
group is rejected; when a required exactly-one group has no member, the containing object
is rejected. If a discriminated union's discriminator is absent or invalid, that discriminator
is rejected, and no variant-member rejection is inferred merely from being unable to select
a variant. A member belonging to no variant remains an independent unknown-field rejection;
a member recognized by at least one variant is not unknown solely because the discriminator
is invalid. Other independent failures in the same validation step remain in the set.
An invalid array element names its indexed position, with a decimal index and no leading
zeroes; a failed constraint on the array as a whole names the array. For a rejected member
within an object element, use that member's pointer. Escape each pointer under RFC 6901 and
apply the row's existing order to the complete set. Do not add an ancestor pointer solely
because a selected descendant failed. These rules select fields within the
invalid_request category; they do not select between error kinds.
```

Append this exact paragraph to CNF-342, after its existing escaped-pointer case and before
the existing system-written-value fixture. A includes the exact fixture-file addition
printed below at docs/research/panels-2026-10/r85/q1-fixtures.json; there is no undrafted
fixture artifact to design after this vote.

```text
      Add field-selection cases F1–F4 from docs/research/panels-2026-10/r85/q1-fixtures.json,
      using otherwise valid fixture context and asserting the machine-readable error fields
      in each fixture's A object: F1 rejects both trust members
      and names /trust/accept_unpinned; F2 names /strategy without inventing variant-member
      errors; F3 names /resolution; F4 names /ssh_public_keys/1. Repeat F1 with an independent
      unknown top-level member aaa and assert /aaa; repeat with trust absent and assert
      /trust. For array length failure use 65 otherwise valid keys and assert /ssh_public_keys.
      No request enqueues an operation or mutates the provider. Retain the existing escaped
      pointer ordering cases. (`WIR-9a`, `WIR-2`, `WIR-20`, `WIR-35`, `API-13`)
```

### Q1-B — containers for combinations and arrays

Use the same exact landing points as A, with this complete replacement row and paragraphs:

```text
| `invalid_request` naming a field (`WIR-2`, `OPS-23`, `PRV-47`) | `field`: an RFC 6901 JSON Pointer into the request body (`"/acknowledge_purchase"`, `"/provider_options/location"`), also where the named field is absent. Where one validation step rejects several fields (an `API-7` step, `OPS-23`'s repeated check of caller-supplied fields, or `PRV-47`'s validation), the least escaped pointer, compared by unsigned UTF-16 code units, the order RFC 8785 (`WIR-3`) sorts member names in |

For this row, determine the rejected-field set before ordering its pointers. A rejected
value's own member is named, including when that required member is absent. A value of the
wrong JSON type names that member rather than hypothetical children. A failed exactly-one
or mutually-exclusive group rejects its containing object, rather than any of the group's
members. If a discriminated union's discriminator is absent or invalid, that discriminator
is rejected, and no variant-member rejection is inferred merely from being unable to select
a variant. A member belonging to no variant remains an independent unknown-field rejection;
a member recognized by at least one variant is not unknown solely because the discriminator
is invalid. Other independent failures in the same validation step remain in the set.
A failed array constraint, including an invalid element or a rejected member within an
object element, rejects the array rather than an indexed position. Escape each pointer
under RFC 6901 and apply the row's existing order to the complete set. Array promotion
is applied once to the directly invalid element or member, never recursively through
containing arrays. Do not otherwise add ancestor pointers solely because a selected
descendant failed. These rules select
fields within the invalid_request category; they do not select between error kinds.
```

And this exact CNF-342 paragraph:

```text
      Add field-selection cases F1–F4 from docs/research/panels-2026-10/r85/q1-fixtures.json,
      using otherwise valid fixture context and asserting the machine-readable error fields
      in each fixture's B object: F1 rejects the trust object
      and names /trust; F2 names /strategy without inventing variant-member
      errors; F3 names /resolution; F4 names /ssh_public_keys. Repeat F1 with an independent
      unknown top-level member aaa and assert /aaa; repeat with trust absent and assert
      /trust. For array length failure use 65 otherwise valid keys and assert /ssh_public_keys.
      No request enqueues an operation or mutates the provider. Retain the existing escaped
      pointer ordering cases. (`WIR-9a`, `WIR-2`, `WIR-20`, `WIR-35`, `API-13`)
```

### Q1-C — retain the current rule

The entire replacement row is exactly the existing row below. Add no rejected-set rule,
consumer restatement or conformance assertion choosing between the example pointers.

```text
| `invalid_request` naming a field (`WIR-2`, `OPS-23`, `PRV-47`) | `field`: an RFC 6901 JSON Pointer into the request body (`"/acknowledge_purchase"`, `"/provider_options/location"`), also where the named field is absent. Where one validation step rejects several fields (an `API-7` step, `OPS-23`'s repeated check of caller-supplied fields, or `PRV-47`'s validation), the least escaped pointer, compared by unsigned UTF-16 code units, the order RFC 8785 (`WIR-3`) sorts member names in |
```

### Q1-D — repair only the demonstrated cases

At the same WIR-9a landing points as A/B, use this complete row and case-specific paragraph:

```text
| `invalid_request` naming a field (`WIR-2`, `OPS-23`, `PRV-47`) | `field`: an RFC 6901 JSON Pointer into the request body (`"/acknowledge_purchase"`, `"/provider_options/location"`), also where the named field is absent. Where one validation step rejects several fields (an `API-7` step, `OPS-23`'s repeated check of caller-supplied fields, or `PRV-47`'s validation), the least escaped pointer, compared by unsigned UTF-16 code units, the order RFC 8785 (`WIR-3`) sorts member names in |

For the rescue-entering WIR-20 install variants, rejecting several present trust alternatives
rejects every present alternative member; rejecting an empty trust object rejects /trust.
If strategy is absent or invalid, reject /strategy and infer no variant-member rejection
merely from the inability to select a variant. An independent top-level member belonging
to no install variant is still rejected. For WIR-35, apply that discriminator rule to
/resolution. For WIR-17's ssh_public_keys, a rejected element names its indexed position
(/ssh_public_keys/0 for the first element); a wrong array type, absent required array or
failed array-wide bound names /ssh_public_keys. Indices are decimal without leading zeroes.
Apply the row's existing escaped-pointer order to these fields and any independently
rejected fields in the same step. These case-specific rules do not define a new rejected-set
rule for other groups, unions or arrays, and select fields only within invalid_request.
```

Append the exact Q1-A-CNF paragraph above at the same CNF-342 point and add the same exact
q1-fixtures.json file below. D has A's results for the printed fixtures; it does not generalize
them to unmentioned groups, discriminators or arrays. This reuse specifies the entire
conformance addition, not a future choice of wording.

### Exact consumer pointers in Q1-A/B/D

For A/B/D add the following exact standalone paragraph at each of these landing points:
in WIR-20 immediately before “Common to every variant:”; in WIR-35 immediately before
“**The union is closed *per operation kind*”; after API-13's field table and before its
amendment note; and after RSC-4's existing paragraph and before RSC-5. These are owner
pointers only. Q1-C adds none. The already quoted WIR-2 pointer is unchanged.

```text
For `details.field`, see `WIR-9a`.
```

### Exact request/error pairs

Fixture context: the named account, offer, machine and operation exist and the principal is
authorized. All relevant non-body checks pass, all shown keys are valid except the intentional
fault, and the image host is allowed. F1's target is otherwise admissible at body validation;
no inventory is fetched in these rejecting requests. F3 addresses a create operation in
needs_reconciliation, so observed is a legitimate resolution variant once spelled correctly.
These are admission errors before any operation is enqueued; the install-operation marker
keys do not apply to these examples. Inner errors are printed, with the envelope's correlation
id omitted. Messages are illustrative, not new prescribed strings. A/B/D assert exactly their
machine-readable fields. Under C no single one of the differing F1/F4 pointers is mandated.

For Q1-A/B/D, add `docs/research/panels-2026-10/r85/q1-fixtures.json` with exactly these contents (the A/B objects are alternative expected errors; the conformance paragraph selects its form; D selects A):

```json
[
  {
    "id": "F1",
    "endpoint": "POST /v1/machines/fixture-machine/actions/install",
    "request": {
      "strategy": "raw_disk",
      "source": {
        "type": "raw_disk",
        "url": "https://images.example.net/disk.img",
        "sha256": "0000000000000000000000000000000000000000000000000000000000000000",
        "compression": "none"
      },
      "target": {
        "identifier": "S4EVNF0N123456",
        "inventory_fingerprint": "7777777777777777777777777777777777777777777777777777777777777777"
      },
      "trust": {
        "expected_host_keys": [
          "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIAABAgMEBQYHCAkKCwwNDg8QERITFBUWFxgZGhscHR4f"
        ],
        "accept_unpinned": true
      },
      "acknowledge_destruction": true
    },
    "A": {
      "kind": "invalid_request",
      "message": "validation failed",
      "retryable": false,
      "details": {
        "field": "/trust/accept_unpinned"
      }
    },
    "B": {
      "kind": "invalid_request",
      "message": "validation failed",
      "retryable": false,
      "details": {
        "field": "/trust"
      }
    }
  },
  {
    "id": "F2",
    "endpoint": "POST /v1/machines/fixture-machine/actions/install",
    "request": {
      "strategy": "not_a_strategy",
      "source": {
        "type": "raw_disk",
        "url": "https://images.example.net/disk.img",
        "sha256": "0000000000000000000000000000000000000000000000000000000000000000",
        "compression": "none"
      },
      "target": {
        "identifier": "S4EVNF0N123456",
        "inventory_fingerprint": "7777777777777777777777777777777777777777777777777777777777777777"
      },
      "trust": {
        "use_provider_keys": true
      },
      "acknowledge_destruction": true
    },
    "A": {
      "kind": "invalid_request",
      "message": "validation failed",
      "retryable": false,
      "details": {
        "field": "/strategy"
      }
    },
    "B": {
      "kind": "invalid_request",
      "message": "validation failed",
      "retryable": false,
      "details": {
        "field": "/strategy"
      }
    }
  },
  {
    "id": "F3",
    "endpoint": "POST /v1/operations/fixture-operation/actions/resolve",
    "request": {
      "resolution": "not_a_resolution",
      "external_id": "2345678",
      "operator_ref": "opref-7d41c9"
    },
    "A": {
      "kind": "invalid_request",
      "message": "validation failed",
      "retryable": false,
      "details": {
        "field": "/resolution"
      }
    },
    "B": {
      "kind": "invalid_request",
      "message": "validation failed",
      "retryable": false,
      "details": {
        "field": "/resolution"
      }
    }
  },
  {
    "id": "F4",
    "endpoint": "POST /v1/machines",
    "request": {
      "provider_account": "fixture-account",
      "offer": "fixture-offer",
      "region": "fixture-region",
      "hostname": "worker-1",
      "image": null,
      "ssh_public_keys": [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIAABAgMEBQYHCAkKCwwNDg8QERITFBUWFxgZGhscHR4f",
        17
      ],
      "user_data": null,
      "labels": {},
      "runway_seconds": 2592000,
      "max_commitment_sats": 90000,
      "acknowledge_purchase": true,
      "provider_options": {}
    },
    "A": {
      "kind": "invalid_request",
      "message": "validation failed",
      "retryable": false,
      "details": {
        "field": "/ssh_public_keys/1"
      }
    },
    "B": {
      "kind": "invalid_request",
      "message": "validation failed",
      "retryable": false,
      "details": {
        "field": "/ssh_public_keys"
      }
    }
  }
]
```

**F1 — `POST /v1/machines/fixture-machine/actions/install`**

Request:
```json
{
  "strategy": "raw_disk",
  "source": {
    "type": "raw_disk",
    "url": "https://images.example.net/disk.img",
    "sha256": "0000000000000000000000000000000000000000000000000000000000000000",
    "compression": "none"
  },
  "target": {
    "identifier": "S4EVNF0N123456",
    "inventory_fingerprint": "7777777777777777777777777777777777777777777777777777777777777777"
  },
  "trust": {
    "expected_host_keys": [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIAABAgMEBQYHCAkKCwwNDg8QERITFBUWFxgZGhscHR4f"
    ],
    "accept_unpinned": true
  },
  "acknowledge_destruction": true
}
```

A inner error:
```json
{
  "kind": "invalid_request",
  "message": "validation failed",
  "retryable": false,
  "details": {
    "field": "/trust/accept_unpinned"
  }
}
```

B inner error:
```json
{
  "kind": "invalid_request",
  "message": "validation failed",
  "retryable": false,
  "details": {
    "field": "/trust"
  }
}
```

**F2 — `POST /v1/machines/fixture-machine/actions/install`**

Request:
```json
{
  "strategy": "not_a_strategy",
  "source": {
    "type": "raw_disk",
    "url": "https://images.example.net/disk.img",
    "sha256": "0000000000000000000000000000000000000000000000000000000000000000",
    "compression": "none"
  },
  "target": {
    "identifier": "S4EVNF0N123456",
    "inventory_fingerprint": "7777777777777777777777777777777777777777777777777777777777777777"
  },
  "trust": {
    "use_provider_keys": true
  },
  "acknowledge_destruction": true
}
```

A inner error:
```json
{
  "kind": "invalid_request",
  "message": "validation failed",
  "retryable": false,
  "details": {
    "field": "/strategy"
  }
}
```

B inner error:
```json
{
  "kind": "invalid_request",
  "message": "validation failed",
  "retryable": false,
  "details": {
    "field": "/strategy"
  }
}
```

**F3 — `POST /v1/operations/fixture-operation/actions/resolve`**

Request:
```json
{
  "resolution": "not_a_resolution",
  "external_id": "2345678",
  "operator_ref": "opref-7d41c9"
}
```

A inner error:
```json
{
  "kind": "invalid_request",
  "message": "validation failed",
  "retryable": false,
  "details": {
    "field": "/resolution"
  }
}
```

B inner error:
```json
{
  "kind": "invalid_request",
  "message": "validation failed",
  "retryable": false,
  "details": {
    "field": "/resolution"
  }
}
```

**F4 — `POST /v1/machines`**

Request:
```json
{
  "provider_account": "fixture-account",
  "offer": "fixture-offer",
  "region": "fixture-region",
  "hostname": "worker-1",
  "image": null,
  "ssh_public_keys": [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIAABAgMEBQYHCAkKCwwNDg8QERITFBUWFxgZGhscHR4f",
    17
  ],
  "user_data": null,
  "labels": {},
  "runway_seconds": 2592000,
  "max_commitment_sats": 90000,
  "acknowledge_purchase": true,
  "provider_options": {}
}
```

A inner error:
```json
{
  "kind": "invalid_request",
  "message": "validation failed",
  "retryable": false,
  "details": {
    "field": "/ssh_public_keys/1"
  }
}
```

B inner error:
```json
{
  "kind": "invalid_request",
  "message": "validation failed",
  "retryable": false,
  "details": {
    "field": "/ssh_public_keys"
  }
}
```

Independent-unknown check for A/B: F1 with additional top-level aaa: 1 selects /aaa by the
existing ordering rule. Missing trust selects /trust. Sixty-five otherwise valid create
keys fail the array-wide bound and select /ssh_public_keys. These are additional complete
fixture transformations of the printed request bodies, with all other values unchanged.

Question: which exact A/B/C/D form can you accept, and which do you prefer? Test the zero-member
case, an invalid discriminator together with a truly unknown field, nested object elements,
array-wide failure versus element failure, and the existing escaped-order case. If A/B/D
would require a consumer change despite the existing WIR-2 owner pointer quoted above,
provide that exact edit; do not silently duplicate a rule elsewhere. No form adds a
new request field. Identify any uncovered combination rather than asserting universal
coverage. A merged amendment that no one has read is a distinct form.

## Q2 — pv-xzre: caller and generated values rejected together

Plain-terms failure story: the caller supplies a location that the provider will not accept.
The service also generates a temporary key name that the same validator rejects. Fixing the
location alone leaves the generated-name defect. Returning a caller error tells the caller
to revise its input; returning a service error reports a different kind and retry flag.
The quoted single-origin sentences demand different results but do not name a mixed-origin
winner. The no-mutation/full-release result is held constant in every amendment below.

A directly adds precedence when both origins fail, following the table's request for a
category decision before pointer selection. B gives the caller category precedence. C is a
narrower conceptual alternative to a mixed-origin priority rule: forbid a mixed-origin step
and validate generated values first. It introduces a staging requirement and may be more
implementation-constraining. It is not presented as an editorial clarification. The minimal
no-change position D leaves the conflicting single-origin wording as printed, with no new
mixed-origin outcome; accept it only if you can give a coherent reading satisfying both
quoted sentences, and explicitly say whether it leaves kind/retryable implementation-defined.
No preference for internal was owner-adopted.

For A–C replace only the two PRV-47 origin-disposition sentences beginning “A caller-supplied
value” and ending “its `retryable`.” The next existing sentence beginning “`OPS-11` says” and
its full settlement/release quotations remain verbatim. Do not change OPS-11 or the purchase
tail's WIR-9b aggregation; this is one pre-step-9 driver validation error, not an API-7 tail.
Pointer selection in these forms is conditional on invalid_request and must work under any
accepted Q1 form. A system-written provider-side name is not a request-body JSON pointer.

### Q2-A — system-written rejection wins the mixed category

```text
A validation that rejects only caller-supplied values fails `invalid_request`, naming a
rejected caller-supplied value's field under `WIR-9a`, with `retryable: false` on both the
error and the operation view (`WIR-9b`). A validation that rejects only values this system
wrote rather than the caller, such as `PRV-9`'s operation id as a temporary key's
"provider-side name or tag" or `PRV-32`'s per-order throwaway SSH key, fails `internal`
(`DOM-17`); `OPS-11`'s create row gives its `retryable`. An internal validation error
MUST NOT carry `details.field`.

When the same driver-validation step rejects both origins, the create MUST fail `internal`,
with `retryable: true` on both the error and the operation view. The error MUST NOT carry
`details.field`; that key names a rejected request-body field for an `invalid_request`, not
a system-written value. Category selection precedes pointer selection. No additional field
listing the other rejected values is introduced. Ordinary redaction and `details.accepted`
requirements still apply.
```

Append this exact paragraph to CNF-342 after its existing system-written-value fixture:

```text
      Add paired stored-create fixtures whose caller provider_options.location is a string
      accepted at API admission but rejected by the fixture driver's accepted-value rule.
      The paired fixture additionally makes the driver reject the generated temporary-key
      provider-side name, with all other generated values valid. The fixture uses a per-order
      key channel and rejects in step 7 before any mutation. In the caller-only control,
      assert invalid_request, details.field /provider_options/location, retryable false,
      and details.accepted false. In the system-only control, assert internal, retryable true,
      details.accepted false and no details.field. In every case assert error/view agreement,
      failed, no key upload or order request, commitment released in full with no setup-fee
      or first-unit debit, and any held resource-offer exclusion freed.
      In the paired mixed-origin fixture assert internal, retryable true, details.accepted
      false, no details.field and no additional rejected-values field. (`PRV-47`, `OPS-11`,
      `WIR-9a`, `WIR-9b`, `PRV-5`)
```

### Q2-B — caller rejection wins the mixed category

```text
A validation that rejects only caller-supplied values fails `invalid_request`, naming a
rejected caller-supplied value's field under `WIR-9a`, with `retryable: false` on both the
error and the operation view (`WIR-9b`). A validation that rejects only values this system
wrote rather than the caller, such as `PRV-9`'s operation id as a temporary key's
"provider-side name or tag" or `PRV-32`'s per-order throwaway SSH key, fails `internal`
(`DOM-17`); `OPS-11`'s create row gives its `retryable`. An internal validation error
MUST NOT carry `details.field`.

When the same driver-validation step rejects both origins, the create MUST fail
`invalid_request`, with `retryable: false` on both the error and the operation view.
`details.field` MUST be selected under `WIR-9a` from the rejected caller-supplied fields
only; system-written values do not enter that pointer set. Category selection precedes
pointer selection. No additional field listing the other rejected values is introduced.
Ordinary redaction and `details.accepted` requirements still apply.
```

At the same CNF-342 landing point append:

```text
      Add paired stored-create fixtures whose caller provider_options.location is a string
      accepted at API admission but rejected by the fixture driver's accepted-value rule.
      The paired fixture additionally makes the driver reject the generated temporary-key
      provider-side name, with all other generated values valid. The fixture uses a per-order
      key channel and rejects in step 7 before any mutation. In the caller-only control,
      assert invalid_request, details.field /provider_options/location, retryable false,
      and details.accepted false. In the system-only control, assert internal, retryable true,
      details.accepted false and no details.field. In every case assert error/view agreement,
      failed, no key upload or order request, commitment released in full with no setup-fee
      or first-unit debit, and any held resource-offer exclusion freed.
      In the paired mixed-origin fixture assert invalid_request, retryable false,
      details.field /provider_options/location, details.accepted false and no additional
      rejected-values field. (`PRV-47`, `OPS-11`, `WIR-9a`, `WIR-9b`, `PRV-5`)
```

### Q2-C — separate stages, generated values first

```text
The driver MUST perform this validation in two stages before any provider mutation for the
create: first validate all system-written values, then, only if they pass, validate the
caller-supplied values. A rejected system-written value fails `internal` (`DOM-17`), with
`retryable` from `OPS-11`'s create row on both the error and the operation view; the error
MUST NOT carry `details.field`. A rejected caller-supplied value fails `invalid_request`,
with `retryable: false` on both the error and the operation view (`WIR-9b`), naming a
rejected caller-supplied field selected under `WIR-9a`. The system-written stage includes
`PRV-9`'s operation id as a temporary key's "provider-side name or tag" and `PRV-32`'s
per-order throwaway SSH key where these values are forwarded. No mixed-origin validation
step is permitted. Ordinary redaction and `details.accepted` requirements still apply.
```

At the same CNF-342 landing point append:

```text
      Add paired stored-create fixtures whose caller provider_options.location is a string
      accepted at API admission but rejected by the fixture driver's accepted-value rule.
      The paired fixture additionally makes the driver reject the generated temporary-key
      provider-side name, with all other generated values valid. The fixture uses a per-order
      key channel and rejects in step 7 before any mutation. In the caller-only control,
      assert invalid_request, details.field /provider_options/location, retryable false,
      and details.accepted false. In the system-only control, assert internal, retryable true,
      details.accepted false and no details.field. In every case assert error/view agreement,
      failed, no key upload or order request, commitment released in full with no setup-fee
      or first-unit debit, and any held resource-offer exclusion freed.
      In the paired mixed-origin fixture assert internal, retryable true, details.accepted
      false, no details.field and no additional rejected-values field. (`PRV-47`, `OPS-11`,
      `WIR-9a`, `WIR-9b`, `PRV-5`)
      Also observe validation-stage order: the rejected generated value stops the
      system-written stage before caller-value validation, and caller-only validation begins
      only after the system-written stage passes. (`PRV-47`)
```

### Q2-D — no source or fixture amendment

Retain the existing two sentences exactly; add no precedence or mixed-origin fixture:

```text
A caller-supplied value this validation rejects fails `invalid_request` naming the rejected value's
field, with `retryable: false` on both the error and the operation view (`WIR-9b`). A value this system wrote rather than the caller, such as `PRV-9`'s operation id as a temporary key's "provider-side name or tag" or `PRV-32`'s per-order throwaway SSH key, that this validation rejects fails `internal` (`DOM-17`); `OPS-11`'s create row gives its `retryable`.
```

### Paired fixture, exact inner errors

Use F4's complete create body with ssh_public_keys replaced by just its valid first key and
provider_options replaced by {"location":"fixture-rejected-location"}. That complete body
is admitted because the driver-specific string is type-valid and all other body/context
checks pass. In the caller-only run, the generated provider-side key name is accepted. In
the paired run, the fixture driver's generated-name rule rejects that name as well. This is
a synthetic driver rule, not a claim about a live provider. A system-only control uses
{"location":"fixture-accepted-location"} and the same generated-name rejection. No body
field pretends to contain the system-generated name. The driver knows both defects in A/B;
C must reject at its system-written stage and skip the caller stage on that paired run.

Caller-only (A/B/C):
```json
{"kind":"invalid_request","message":"validation failed","retryable":false,"details":{"field":"/provider_options/location","accepted":false}}
```
System-only and mixed under A/C:
```json
{"kind":"internal","message":"validation failed","retryable":true,"details":{"accepted":false}}
```
Mixed under B:
```json
{"kind":"invalid_request","message":"validation failed","retryable":false,"details":{"field":"/provider_options/location","accepted":false}}
```
In the system-only control B returns the same internal error as A/C. All fixture results
settle failed and preserve the no-mutation/release assertions in the exact CNF paragraphs.
No new details key, second error, refusal list or provider value is returned. The generated
name itself is never disclosed. These examples show all required keys for this synthetic
local validation failure, rather than dropping the existing details.accepted requirement.

Question: which exact category form and fixture can you accept, and which do you prefer?
Does a chosen retry flag obey the quoted worker-failure row without implying an automatic
retry? What can a caller actually fix after the mixed error? Name any loss a precedence or
stage rule introduces. Keep acceptance of A/B/C/D separate from the strongest argument you
were asked to make against your own preference.

## Q3 — pv-hups: finish install validation before both markers?

Plain-terms failure story: an install was admitted with the destructive acknowledgement,
then its stored value becomes false before the worker reads it. The worker writes its
“rescue may have started” marker, but has not yet called the driver. It now repeats body
validation and rejects the bad acknowledgement. Calling that outcome “no rescue” conflicts
with the conservative marker it already wrote. The quoted marker rule explicitly discusses
a crash between the write and dispatch; no actual rescue boot is needed for this issue.

The question is the referent of “these checks”, not whether present fields are revalidated
or how writer-based failures are classified. A directly makes the before-both-markers rule
cover all OPS-23 repeated checks. B is the minimal fixture-only form if the quoted current
sentences already entail this. C is a narrower textual amendment at the present-value
sentence rather than rewriting the general timing sentence. All three include the same
complete fixture paragraph, so no option relies on an undrafted future test.

### Q3-A — explicit all-repeated-check timing

Replace only the following existing span:

```text
On an install, these checks MUST run
before either `OPS-45` marker is written:
```

with:

```text
On an install, every check repeated under this requirement, whether it checks for a missing
required field or validates a present caller-supplied or api-written value, MUST finish
before either `OPS-45` marker is written:
```

Everything after the colon remains unchanged, including the rescue-marker quotation and
the settlement/rendering sentences. Append the exact CNF paragraph below to CNF-34 just
before “Complete-record controls on create and install proceed.”

### Q3-B — normative text unchanged; add the same fixture

No OPS-23 replacement. Append the exact CNF paragraph below at that same CNF-34 point.
B is a substantive addition to conformance coverage even if you find no normative change.
It is not a promise to correct or erase an already-written conservative marker.

### Q3-C — local present-value timing amendment

Replace only the existing one-sentence present-value paragraph beginning “A field that is
present but fails this repeated validation” with this complete paragraph:

```text
A field that is present but fails this repeated validation fails as its writer's bullet above
says, on both the error and the operation view, and settles as these missing-field failures
do. On an install, this present-value validation MUST finish before either `OPS-45` marker
is written.
```

The existing timing/settlement paragraph otherwise remains unchanged. Append the same
exact CNF paragraph at the same CNF-34 point.

### Q3 common exact conformance addition (A/B/C)

```text
      Repeat the install caller-field fixture with acknowledge_destruction present but
      false in the stored request, after admission with a valid true value. Use ordinary
      trusted marker provenance (restore_markers_untrusted false) and initially null marker
      columns. Assert the repeated validation completes before either marker write and
      rejects invalid_request, details.field /acknowledge_destruction, retryable false on
      error and operation view, failed, no driver call, both markers still null, disk_effect
      none and rescue_exit none. Instrument a proposed execution that writes the rescue
      marker false before this validation, then tries to validate before begin-rescue
      dispatch: assert this execution violates the required ordering even though dispatch
      has not occurred. Do not clear the marker or synthesize rescue_exit none from false
      to make that proposed execution pass. Repeat for a present-but-invalid api-written
      install field only if the release names such a field; identify it and retain
      conflict/incomplete_record, retryable true and the same before-both-markers assertions.
      No api-written install field is invented for the fixture. The complete-record control
      proceeds past validation. (`OPS-23`, `OPS-45`, `API-14`, `WIR-9a`, `WIR-9b`)
```

This fixture observes required ordering on executions starting before validation. It is not
a newly specified recovery path for a corrupted or nonconforming already-false marker.
An implementation that permits the illustrated marker-first execution fails this check;
the fixture does not instruct it to clear a marker, settle failed against an uncertain
marker, or hide restore provenance. For api-written install fields the conditional matches
the existing quoted CNF-34 fixture; this packet identifies no concrete api-written
install field and invents none. Post-connection host-key, inventory and image
checks are not the API-boundary checks repeated under OPS-23; no proposal moves those
checks ahead of the observations they need. The unchanged restore-provenance override
quoted above still applies outside this trusted-provenance fixture.

Question: does the current normative text already unambiguously cover present-but-invalid
caller/api values before both markers, or is A/C needed? Which exact form, including the
fixture, can you accept? Verify the marker-first attempted execution and retain the existing
writer-based kind/retryability. If all A/B/C are unacceptable, give the complete minimal
replacement you can accept; do not reopen the disposition settled by the present-value clause.

## Required answer shape

For each question separately give:
1. Final preference by exact form label, and ACCEPT / CANNOT ACCEPT for every offered form.
   A proposed fix is a distinct form: write its complete replacement and fixture, and do
   not count acceptance of an amended form as acceptance of the printed one.
2. The strongest reason for your choice, a concrete request/worker trace and exact pin
   references. Distinguish text already settled from a new normative or test obligation.
3. The strongest argument against your own preference, explicitly labelled requested
   counterargument rather than your vote. Name any preservation risk or missing narrower form.
4. Any false premise or internal contradiction in this packet, with its effect on your vote.

Evaluate the forms as a whole, including their fixtures and landing points. Ask whether a
new invariant, API error field or validation stage is needed at all. Do not weaken a tested
rule to make an option pass. Do not implement the forms or run Lean. No unread manager
combination will count as reviewed. The five-seat settling and missing-seat rules are in
notes.md; Grok is missing with a sole preflight 402, so this launch uses four readers.
