# r84 — triage-1027 Panel E: disk identifier domain

Read this brief and `/var/tmp/provisiond-panel-r84/notes.md` whole. Your independent clone is detached at **3109b5b44eae17e288cf52aaa976993bd8c5626c**, fetched origin/master. No candidate below has been applied. This round asks Q1 (`pv-ez8`), Q2 (`pv-2j3`) and Q3 (`pv-tbrs`), the Panel E rows and E grouping of `/var/tmp/provisiond-manager/triage-1027/table.md`. That table's old line numbers are superseded by the pinned extracts below.

Read-only: do not change source, Git state, tracker or panel records; do not commit, push, checkout, reset, stash, clean, contact a PR, or start subagents/background work. **Run no `lake build`, `nix develop`, `check-all.sh`, formal gate or other Lean build.** The manager runs before/final gates in an independent check clone. Temporary calculation files may be written only in `/var/tmp/provisiond-panel-r84/tmp/<your-seat>/`. Do not read credential/session/config locations (`~/.claude`, `~/.codex`, `~/.grok`, authentication files, kubeconfig, browser profiles), other readers' outputs/clones, other panel folders, or the main checkout. Your evidence is this packet and your own pinned clone. Capture any permitted lightweight command's exit unpiped. Return a substantive final answer before the 3600-second launcher limit; aim for at most 2200 words plus any complete exact alternative.

**apply notes.md rule 6 exactly as written; this prompt adds no void rule.**

This is launch-only. No specification/tracker edit, implementation Run, PR action, merger, tally or follow-on round is authorized in this turn. A panel settlement is recorded for main; do not enact it. Models are not arguments. No other panel's questions are reopened.

## Scope, verification and composition

None of these questions is settled at the pin. All three JSONL rows remain open/needs-triage (`check/beads-at-pin.json`). Relevant owner passages and conformance passages are reproduced verbatim below. Their relevant text also remains unchanged across `08191bb..3109b5b` (manager's `check/verification.md`). The table does not prescribe a path grammar, numeric size, or whitespace set; it asks for those choices. The candidate caps below are proposed policy values, **not verified provider hardware maxima**. No outside library's whitespace semantics is a premise.

Each candidate is a complete exact patch for its own question: blocks labelled replacement are literal replacement text; blocks labelled insertion are literal new text at the specified location. Everything else stays pinned. Q1 replaces CNF-200 and CNF-363 case (14), and may insert an API-13 paragraph. Q2 replaces only API-13's disk-identifier table row and inserts a size-boundary paragraph within CNF-363. Q3 inserts one definition sentence in RSC-46 and a whitespace paragraph within CNF-363. Q2's paragraph precedes Q3's; both follow case (14) and precede CNF-363's final owner-reference line. Thus a chosen form from each question composes without overwriting another's text. A novel cross-question combination that changes these exact forms is a distinct form needing its own read, not an accepted manager synthesis.

Source ownership remains API-13 for caller syntax and field limits, RSC-46 for normalization, and RSC-26 for device resolution. SEC-29 retains its bare API-13 pointer; the forms add no second numeric copy there. Inventory fields are never truncated by any Q2 form; those forms govern caller fields only. Please identify any lost normative or checked verdict, including inability to echo an inventory value, rather than assuming a cap is free. The Lean extracts below model disk identity as a natural number and fingerprint as a natural number; they do not implement string normalization or a length grammar. No Lean change or theorem weakening is proposed. If you find a formalized clause that a form actually changes, cite it and supply the necessary exact change instead of silently changing that property.

## Pinned owning and checking passages

### `04-api-contract.md:958–981`

```text
## Validation

Validation happens at the boundary *and* again in the worker (`OPS-23`).

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
```

### `07-security-requirements.md:280–281`

```text
**SEC-29** Request bodies MUST be size-capped globally, and individual fields MUST be
capped per `API-13`.
```

### `06-rescue-install.md:245–288`

```text
**RSC-26** **AMENDED — naming a device is not enough, because the name is not stable.** The
target block device MUST be named explicitly by the caller and the engine MUST NOT guess one.
**But `/dev/sda` is an ordering artefact that can differ across boots, between the rescue
environment and the installed system, and after any hardware change** — so a caller that reads an
inventory today and installs tomorrow can name a device that has since become a different disk.
On a two-disk machine that is the customer's data, destroyed, with every requirement in this
document satisfied.

**The target MUST therefore be bound to identity, not to a name:**

- **`RSC-38` makes rescue inventory its own operation** returning the block-device
  inventory with **a stable identifier where a disk has one** — serial and WWN — plus an opaque
  `inventory_fingerprint` over the whole device set. Every disk reported by the rescue environment
  MUST remain in the inventory and in the fingerprint, including a disk with no identifier.
- **An install request MUST carry both** the chosen device's stable identifier and the
  `inventory_fingerprint` it was chosen from (`WIR-20`).
- **The worker MUST re-read the inventory immediately before any disk I/O** and abort with
  `integrity` — before writing a single byte — if the fingerprint differs, if the named identifier
  is absent, or if the inventory fails to parse (`RSC-34` keeps the raw capture).

`RSC-27`'s path validation still applies to whatever device path the identifier resolves to at
write time. **The identifier is authoritative; the path is derived.**

**An identifier that does not resolve to exactly one device MUST abort `integrity` before any
write.** Zero matches is the stale-inventory case; **more than one is the dangerous case** —
duplicate or empty serials are real on consumer and virtualised disks, and "pick the first" there
is the same coin-flip over which disk gets destroyed that naming `/dev/sda` was. The driver MUST
prefer WWN where the provider exposes it and MUST omit the `raw_disk` and `rootfs_via_rescue`
strategies from an offer's `install_strategies` where no per-device unique identifier is available
at all for that offer. This is a static per-offer declaration from provider facts; rescue inventory
(`RSC-38`) is available only after purchase, on one machine, and cannot supply it. `WIR-30` says
"`install_strategies` is the offer's subset of `DOM-13`'s strategies, and it gates them".
This omission does not make the offer unsellable. If a machine bought under a listed strategy has rescue inventory that
shows no unique identifier, that machine meets the abort this paragraph opens with.

**This binds every strategy that names a disk, not only `raw_disk`, and the validation is
identical**: resolve each `layout.drives[].identifier` against a freshly re-read inventory, match
exactly one device, and abort `integrity` before any write on zero or multiple matches
(`WIR-20`). `RSC-22`'s installer layout
carries a `drives` list, and those are device names with exactly the same instability — a rootfs
install that partitions `/dev/sda` after the ordering shifted destroys the same customer data, and
scoping the rule to raw-disk would have left the launch product's primary install path on the
unstable identifier. Every caller-supplied disk reference MUST be a stable identifier checked
against the same `inventory_fingerprint`.
```

### `06-rescue-install.md:312–330`

```text
**RSC-46** **Identifier normalization and the fingerprint's canonical form.** Before comparison,
an identifier — a caller's `target.identifier`, a `layout.drives[].identifier`, or a value read
from the inventory — is normalized in this order: trim ASCII whitespace, ASCII-lowercase, then
strip exactly one leading `0x`. A value that is empty after normalization is absent and matches
nothing. Matching uses the normalized values and tries the WWN first, then the serial; a WWN
match and a serial match naming different devices aborts `integrity` before any write (`RSC-26`).
Each device on the wire carries `identifier`, `wwn` and `serial`. The `wwn` and `serial` values
are the strings as read, trimmed of ASCII whitespace, or `null` where normalization leaves
nothing. The `identifier` is byte-equal to `wwn` if that is non-null, else `serial`, else `null`.
The `inventory_fingerprint` is SHA-256 over the RFC 8785 canonical JSON of the device list, each
element exactly `{wwn, serial, size_bytes}` using normalized values and `null` where a value is
absent. The list is sorted by each element's RFC 8785 serialization, compared as UTF-8 byte
strings. Identical elements are kept, one per device. Device paths are excluded, because they
are the unstable part. On the wire the fingerprint is 64 lowercase hex characters.
(`WIR-20`, `WIR-10b`)

*Amended 2026-10-22 (`pv-6p8`, panels r61–r61f; owner decision 2026-10-22): made normalization
ordered, excluded empty values from matching, specified the as-read wire fields and sorted
canonical fingerprint elements while preserving multiplicity.*
```

### `10-conformance-checklist.md:2243–2245`

```text
- [ ] **CNF-200** — A rootfs install naming a drive by unstable device path is rejected; the layout
      carries stable identifiers checked against the inventory fingerprint, exactly as raw-disk
      does. (`RSC-26`, `RSC-22`, `WIR-20`)
```

### `10-conformance-checklist.md:2295–2333`

```text
- [ ] **CNF-363** — Rescue inventory retains disks without identifiers. Use otherwise-admissible
      fixtures with unique chosen identifiers; every machine on which an install case runs,
      including the machine with no identifiers, has a recorded `install_strategies` listing
      the strategy used. Run install cases through both `raw_disk` (`target.identifier`) and
      `rootfs_via_rescue` (`layout.drives[].identifier`), except the malformed-input checks,
      which exercise both fields before enqueue.
      (1) List disk A with distinct WWN and serial and disk B with neither. Both appear; B's
      `identifier`, `wwn` and `serial` are all `null`. A shows both fields and its `identifier`
      equals its WWN. (2) Assert the fingerprint equals an independently computed hash over both
      disks (`RSC-46`), using fixtures whose identifier order differs from canonical-byte order.
      (3) Install naming A: both strategies resolve A and write nothing to B. (4) Remove B or,
      separately, resize B between inventory and install: both strategies abort `integrity`
      before writing any bytes.
      (5) Repeat with B's serial whitespace-only, `0x`, and `0X`: each is shown `null`. A WWN
      normalizing to empty falls back to the serial. (6) Assert every device carries `path`,
      `wwn`, `serial` and `identifier`. (7) A serial-only disk shows its serial as both
      `identifier` and `serial`; echoing it resolves that disk through both strategies.
      (8) Read a serial as ` 0x0XAB `: assert it is shown `0x0XAB` and hashed as `0xab`.
      Echoing `0x0XAB` or `0X0xab` resolves it through both strategies; `0XAB`, `0xab` and `ab`
      each match nothing and abort `integrity` with no write through both strategies.
      (9) Reordering the devices leaves the fingerprint unchanged; changing only paths also
      leaves it unchanged. (10) In `target.identifier` and in any `layout.drives[].identifier`,
      a `null`, a non-string, an empty or whitespace-only string, or a bare `0x` or `0X` is
      refused `invalid_request` before enqueue.
      (11) On a machine where no device has an identifier, inventory succeeds with every
      device's `identifier`, `wwn` and `serial` all `null`; any well-formed install through
      either strategy aborts `integrity` with no write. (12) Two identical anonymous devices
      both appear, and dropping one changes the fingerprint. (13) Padded echoes and serials
      with whitespace inside them resolve through both strategies; the generated installer
      configuration carries only resolved paths. (14) Use a well-formed unmatched identifier
      that is not path-shaped: both strategies abort `integrity` with no writes. `RSC-26` says
      "An identifier that does not resolve to exactly one device MUST abort `integrity` before
      any write."
      (`WIR-10b`, `WIR-20`, `WIR-40`, `RSC-23`, `RSC-26`, `RSC-33`, `RSC-46`, `API-13`)
      *Added 2026-10-22 (`pv-6p8`; panels r61–r61f, `docs/research/panels-2026-10/r61/`): covers
      anonymous inventory members, wire fields, canonical fingerprints and identifier admission
      and resolution through both rescue install strategies.*
- [ ] **CNF-207** — A rootfs install body round-trips `partitions`, `raid.level` and per-drive
      identifiers through the parser. This fixture was silently broken by a fix in the previous
```

### `03-operation-lifecycle.md:2018–2046`

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
```

### `01-domain-model.md:575–582`

```text
## Error taxonomy

One closed set of error kinds, used by drivers, the rescue engine, and the API alike.

| Kind | Meaning | HTTP |
|---|---|---|
| `invalid_request` | Caller error, deterministic | 400 |
| `not_found` | Named resource does not exist | 404 |
```

### `tools/formal/Provisiond/Rescue.lean:295–329`

```text
/-- A stable identifier: `RSC-26`'s first bullet has `RSC-38`'s pass return the inventory with
"**a stable identifier where a disk has one** — serial and WWN", and the model reduces one to its
identity. -/
structure Identifier where n : Nat deriving DecidableEq, Repr

/-- One block device in an inventory. The identifier is an `Option` and two devices may carry the
same one, because `RSC-26` says "duplicate or empty serials are real on consumer and virtualised
disks". The path is what the rescue environment named it by on this reading, which `RSC-26` calls
"an ordering artefact that can differ across boots". -/
structure Device where
  identifier : Option Identifier
  path       : String
  deriving DecidableEq, Repr

/-- The report `RSC-38`'s pass returns, of which that requirement says only that "its report MUST
carry the same `inventory_fingerprint` an install will be checked against": the device set, and the
fingerprint `RSC-26`'s first bullet calls "an opaque `inventory_fingerprint` over the whole device
set". `RSC-46` computes it and says "Device paths are excluded, because they are the unstable
part", so two device sets that differ only in paths share one; the computation is that
requirement's and is not modelled here. -/
structure Inventory where
  devices     : List Device
  fingerprint : Nat
  deriving DecidableEq, Repr

/-- `RSC-26` requires an install request to carry both "the chosen device's stable identifier and
the `inventory_fingerprint` it was chosen from (`WIR-20`)". -/
structure Request where
  identifier  : Identifier
  fingerprint : Nat
  deriving DecidableEq, Repr

/-- What the resolution yields. Every refusal is one value: `RSC-26` says "abort with `integrity` —
before writing a single byte" of all of them. -/
inductive Resolution
```

### `tools/formal/Provisiond/Rescue.lean:345–357`

```text
/-- `RSC-26`: "The worker MUST re-read the inventory immediately before any disk I/O" and
"abort with `integrity` — before writing a single byte — if the fingerprint differs, if the named
identifier is absent, or if the inventory fails to parse", and "An identifier that does not resolve
to exactly one device MUST abort `integrity` before any write". The inventory this reads is its own
input and not the one the request was chosen from; `none` is the one that "fails to parse". -/
@[req "RSC-26"]
def resolve (req : Request) : Option Inventory → Resolution
  | none => .abortIntegrity
  | some inv =>
    if inv.fingerprint == req.fingerprint then
      match matching inv req.identifier with
      | [d] => .resolved d
      | [] => .abortIntegrity
```

### `tools/formal/Provisiond/Rescue.lean:371–396`

```text

/-- "Zero matches is the stale-inventory case". -/
@[req "RSC-26"]
theorem zero_matches_aborts (req : Request) (inv : Inventory)
    (h : matching inv req.identifier = []) : resolve req (some inv) = .abortIntegrity := by
  simp only [resolve]; split <;> simp [h]

/-- "more than one is the dangerous case" — two or more matches abort rather than choosing. -/
@[req "RSC-26"]
theorem duplicate_identifier_aborts (req : Request) (inv : Inventory) (a b : Device)
    (rest : List Device) (h : matching inv req.identifier = a :: b :: rest) :
    resolve req (some inv) = .abortIntegrity := by
  simp only [resolve]; split <;> simp [h]

/-- `RSC-26` aborts "if the fingerprint differs": the request carries the fingerprint it was
chosen from, and the resolution reads a fresh inventory's own. -/
@[req "RSC-26"]
theorem changed_fingerprint_aborts (req : Request) (inv : Inventory)
    (h : inv.fingerprint ≠ req.fingerprint) : resolve req (some inv) = .abortIntegrity := by
  simp [resolve, h]

/-- "or if the inventory fails to parse (`RSC-34` keeps the raw capture)". -/
@[req "RSC-26"]
theorem unparsed_inventory_aborts (req : Request) : resolve req none = .abortIntegrity := rfl

/-- A stale request against a re-ordered inventory never resolves to a different disk than the
```

## Q1 — when a caller supplies a device path (`pv-ez8`)

**Plain-terms story.** A caller copies `/dev/sda` into the disk-identifier field instead of copying the disk's serial. Suppose no disk's serial or WWN equals that string. One service refuses before putting the install in the queue. Another accepts it, boots the machine into rescue, then discovers that it matches no disk and stops without writing. Both avoid the destructive write, but only the second has interrupted the installed OS. The existing checklist word “rejected” does not distinguish those outcomes. Do not assume a serial can never literally contain `/dev/sda`; use explicit fixtures and decide how that case should behave too.

**Verified basis.** API-13's row says “a JSON string, non-empty after normalization (`RSC-46`)” (`04-api-contract.md:974`), and RSC-26 says “An identifier that does not resolve to exactly one device MUST abort `integrity` before any write” (`06-rescue-install.md:268–269`, line break as in extract). CNF-200 says “is rejected” (`10-conformance-checklist.md:2243`); CNF-363 case (14) says “that is not path-shaped” (`10-conformance-checklist.md:2324–2325`). The rescue disruption is not conjectured disk damage: RSC-38 says “entering rescue means rebooting the machine into another operating system” (`06-rescue-install.md:305–306`). No form makes a caller string the device path used for I/O.

### Q1-A — preserve the admission domain; make resolution explicit (minimal repair)

No API-13 or RSC-26 edit. Replace CNF-200 whole with:

```text
- [ ] **CNF-200** — On an otherwise-admissible rootfs install, submit `/dev/sda` as
      `layout.drives[0].identifier` against an inventory in which no WWN or serial normalizes
      to that string. Assert admission with `202`, followed by `integrity` at inventory
      resolution in rescue and no disk writes. With a unique stable identifier instead,
      assert the generated installer configuration uses the path resolved from that
      identifier against the matching inventory fingerprint. (`API-13`, `RSC-26`, `RSC-22`, `WIR-20`)
```

Replace CNF-363 case (14), from “(14) Use” through its quoted RSC-26 sentence, with:

```text
      (14) Use a well-formed unmatched identifier, separately `not-a-disk` and `/dev/sda`,
      against an inventory in which neither matches any WWN or serial: both strategies
      admit the request with `202`, then abort `integrity` at inventory resolution in
      rescue with no disk writes. Separately give exactly one disk the serial `/dev/sda`,
      with no conflicting WWN; echoing it resolves that disk under both strategies and
      the generated installer configuration uses only its resolved path. (`RSC-26`)
```

### Q1-B — disallow slash anywhere in the normalized caller identifier

Insert after the API-13 table and before its amendment note:

```text
For `target.identifier` and every `layout.drives[].identifier`, a value whose `RSC-46`
normalization contains U+002F (`/`) MUST be refused `invalid_request` before enqueue.
This is a caller-input restriction even when an inventory WWN or serial contains that
character; the inventory retains that value. Worker repetition: `OPS-23`.
```

Replace CNF-200 whole with:

```text
- [ ] **CNF-200** — An otherwise-admissible rootfs install with `/dev/sda` in
      `layout.drives[0].identifier` is refused `400` `invalid_request` before enqueue,
      with no rescue entry or disk write. A rootfs install with a unique admissible
      stable identifier uses only the path resolved against its inventory fingerprint.
      (`API-13`, `RSC-26`, `RSC-22`, `WIR-20`)
```

Replace CNF-363 case (14), including its old RSC-26 quotation, with:

```text
      (14) In each caller identifier field, separately submit `/dev/sda`, `a/b`, and
      ` 0X/dev/sda `: each is refused `400` `invalid_request` before enqueue, with no
      rescue entry or disk write, including when a unique inventory serial equals
      the normalized input. Inject each value into a saved install request: repeated
      validation fails `invalid_request`, `retryable: false`, before any driver call,
      with `disk_effect: "none"` and `rescue_exit: "none"`. Separately use an otherwise-
      admissible `not-a-disk` matching no WWN or serial: both strategies admit with
      `202`, then abort `integrity` at inventory resolution in rescue with no disk writes.
      (`API-13`, `OPS-23`, `RSC-26`)
```

### Q1-C — refuse only the normalized `/dev/` prefix (narrower restriction)

Insert after the API-13 table and before its amendment note:

```text
For `target.identifier` and every `layout.drives[].identifier`, a value whose `RSC-46`
normalization begins with the ASCII string `/dev/` MUST be refused `invalid_request`
before enqueue. This is a caller-input restriction even when an inventory WWN or serial
begins with that string; the inventory retains that value. Other non-empty normalized
strings remain subject to the disk-identifier row and `RSC-26`. Worker repetition: `OPS-23`.
```

Replace CNF-200 whole with:

```text
- [ ] **CNF-200** — An otherwise-admissible rootfs install with `/dev/sda` in
      `layout.drives[0].identifier` is refused `400` `invalid_request` before enqueue,
      with no rescue entry or disk write. A rootfs install with a unique admissible
      stable identifier uses only the path resolved against its inventory fingerprint.
      (`API-13`, `RSC-26`, `RSC-22`, `WIR-20`)
```

Replace CNF-363 case (14), including its old RSC-26 quotation, with:

```text
      (14) In each caller identifier field, separately submit `/dev/sda` and
      ` 0X/DeV/sda `: each is refused `400` `invalid_request` before enqueue with no
      rescue entry or disk write, including when a unique inventory serial equals
      the normalized input. Inject each value into a saved install request: repeated
      validation fails `invalid_request`, `retryable: false`, before any driver call,
      with `disk_effect: "none"` and `rescue_exit: "none"`. Separately use `not-a-disk`,
      `/tmp/disk` and `a/b` against an inventory in which each matches no WWN or serial:
      both strategies admit with `202`, then abort `integrity` at inventory resolution
      in rescue with no disk writes. A unique serial `a/b` still resolves by identity.
      (`API-13`, `OPS-23`, `RSC-26`)
```

**Question Q1.** Which exact form can you accept, and which do you prefer? A preserves current admission and clarifies the test; B introduces a slash-free domain; C introduces only the `/dev/` prefix ban. Is any admission ban needed when resolution never uses the supplied string as a device path? Account for legitimate serials excluded and rescue disruption avoided. If none works, give a complete exact alternative, including phase, error, domain and all changed case text. Do not turn “path-shaped” into an undefined new term.

## Q2 — how large a disk identifier may be (`pv-2j3`)

**Plain-terms story.** An install request can contain a serial almost as large as the whole request body. Even if trimming reduces it to `a`, the service has received and parsed the long string. One builder wants a small per-field limit; another relies on the body limit because the identifier row gives no number. A raw-value cap bounds that input but may refuse a long inventory echo; a normalized-value cap bounds matching keys but permits much longer padding within the body limit. These are different contracts, not a unit conversion.

**Verified basis.** SEC-29 says “Request bodies MUST be size-capped globally, and individual fields MUST be capped per `API-13`” (`07-security-requirements.md:280–281`). The complete API-13 table above states “globally capped (2 MiB is a reasonable default)” for the request body, while the identifier row has no numeric bound (`04-api-contract.md:974,978`). OPS-23 says “Validation that was performed at the API boundary MUST be repeated in the worker before the driver is called” (`03-operation-lifecycle.md:2018–2019`). The proposed values below have no claimed provider maximum behind them; assess their cost and whether a different reviewed exact number is needed.

All Q2 forms preserve Q1's separately selected paragraph, if any. No Q2 form caps or truncates inventory WWNs or serials. In the tests below all fixtures satisfy the selected Q1 form and other body constraints, and positive fixtures have unique matching inventory serials and a matching fingerprint. “Admit” means `202`, not successful disk installation solely from passing the size test.

### Q2-A — 1024 UTF-8 bytes before normalization

Replace API-13's disk-identifier row with:

```text
| disk identifier | a JSON string whose decoded value is at most 1024 UTF-8 bytes before `RSC-46` normalization and is non-empty after that normalization; count the decoded value's UTF-8 encoding, not its JSON escape spelling. A `null`, non-string, over-limit or empty-after-normalization `target.identifier` or `layout.drives[].identifier` MUST be refused `invalid_request` before enqueue. No separate post-normalization size cap applies. Worker repetition: `OPS-23`. Resolution: `RSC-26`. |
```

Insert within CNF-363 after case (14), before the final owner references:

```text
      **Disk identifier size boundaries.** For each caller identifier field, admit
      decoded ASCII values of 1023 and 1024 UTF-8 bytes; refuse 1025 with `400`
      `invalid_request` before enqueue, with no rescue entry or disk write. Refuse a
      1025-byte value even when trimming leaves one byte. Admit 512 copies of U+00E9
      (1024 UTF-8 bytes); refuse those copies followed by `a` (1025 bytes). Encode
      the same decoded ASCII value with literal characters and with JSON `\u0061`
      escapes: the size outcome is identical. Inject an over-limit caller value
      into a saved request: repeated validation fails `invalid_request`,
      `retryable: false`, before a driver call, with `disk_effect: "none"` and
      `rescue_exit: "none"`. Inventory still returns over-limit serials untruncated.
      (`API-13`, `OPS-23`)
```

### Q2-B — 256 UTF-8 bytes after normalization; raw input bounded by the body

Replace API-13's disk-identifier row with:

```text
| disk identifier | a JSON string whose `RSC-46` normalized value is non-empty and at most 256 UTF-8 bytes; count the normalized value's UTF-8 encoding, not its JSON escape spelling. There is no separate pre-normalization field-size cap: the decoded input is bounded by the request-body cap. A `null`, non-string, over-limit or empty-after-normalization `target.identifier` or `layout.drives[].identifier` MUST be refused `invalid_request` before enqueue. Worker repetition: `OPS-23`. Resolution: `RSC-26`. |
```

Insert within CNF-363 after case (14), before the final owner references:

```text
      **Disk identifier size boundaries.** For each caller identifier field, admit
      normalized ASCII values of 255 and 256 UTF-8 bytes; refuse 257 with `400`
      `invalid_request` before enqueue, with no rescue entry or disk write. Admit
      1025 decoded bytes consisting of spaces around `a`, within the body cap.
      Admit 128 copies of U+00E9 (256 UTF-8 bytes); refuse those copies followed by
      `a` (257 bytes). Encode the same decoded ASCII value with literal characters
      and with JSON `\u0061` escapes: the size outcome is identical within the body
      cap. Inject a value normalizing above 256 bytes into a saved request:
      repeated validation fails `invalid_request`, `retryable: false`, before a
      driver call, with `disk_effect: "none"` and `rescue_exit: "none"`. Inventory
      still returns serials whose normalized values exceed the cap untruncated.
      (`API-13`, `OPS-23`)
```

### Q2-C — both 1024 bytes before and 256 bytes after normalization

Replace API-13's disk-identifier row with:

```text
| disk identifier | a JSON string whose decoded value is at most 1024 UTF-8 bytes before `RSC-46` normalization and whose normalized value is non-empty and at most 256 UTF-8 bytes; count each value's UTF-8 encoding, not its JSON escape spelling. A `null`, non-string, either-limit-exceeding or empty-after-normalization `target.identifier` or `layout.drives[].identifier` MUST be refused `invalid_request` before enqueue. Worker repetition: `OPS-23`. Resolution: `RSC-26`. |
```

Insert within CNF-363 after case (14), before the final owner references:

```text
      **Disk identifier size boundaries.** For each caller identifier field, admit
      normalized ASCII values of 255 and 256 UTF-8 bytes within the raw cap; refuse
      257. With normalized value `a`, admit decoded values of 1023 and 1024 bytes
      padded with spaces; refuse 1025. Every refusal is `400` `invalid_request`
      before enqueue, with no rescue entry or disk write. Admit 128 copies of
      U+00E9 (256 UTF-8 bytes); refuse those copies followed by `a` (257 bytes).
      Encode the same decoded ASCII value with literal characters and with JSON
      `\u0061` escapes: field-size outcomes are identical within the body cap.
      Inject a raw-limit violation and, separately, a normalized-limit violation
      into saved requests: each fails repeated validation `invalid_request`,
      `retryable: false`, before a driver call, with `disk_effect: "none"` and
      `rescue_exit: "none"`. Inventory still returns over-limit serials untruncated.
      (`API-13`, `OPS-23`)
```

### Q2-D — explicit body-cap-only exception (minimal admission change)

Replace API-13's disk-identifier row with:

```text
| disk identifier | a JSON string, non-empty after normalization (`RSC-46`); disk identifiers have no separate field-size cap before or after normalization and are bounded only by the request-body cap. This row is the explicit field-size exception for `SEC-29`. A `null`, non-string or empty-after-normalization `target.identifier` or `layout.drives[].identifier` MUST be refused `invalid_request` before enqueue. Worker repetition: `OPS-23`. Resolution: `RSC-26`. |
```

Insert within CNF-363 after case (14), before the final owner references:

```text
      **Disk identifier size boundaries.** Configure and record a body cap. For
      each caller identifier field, admit an otherwise-admissible body below that
      cap with a decoded identifier of 1025 UTF-8 bytes, and separately with a
      value normalized to 257 bytes. Admit a padded identifier longer than 1024
      decoded bytes that normalizes to `a`, within the body cap. Exercise bodies
      at the configured body cap and above it under the global body-size rule;
      no disk-identifier-specific length refusal is introduced. Inject a saved
      caller identifier of 1025 UTF-8 bytes: worker validation does not reject it
      for field length and still performs the other admission checks before the
      driver call. Inventory values are returned untruncated. (`API-13`, `SEC-29`, `OPS-23`)
```

**Question Q2.** Which exact cap, units and observation points can you accept, and which form do you prefer? A adds a raw cap, B caps only normalized values, C adds both, and D states the body-only exception in the owner. Identify what is gained and lost, including long inventory echoes and padding. Are 1024 and/or 256 defensible without provider-specific guarantees? If not, provide one complete exact replacement row and exact boundary paragraph with your number and units. A form with a different number is a distinct form; do not count a generic vote for “a cap” as agreement on any printed form.

## Q3 — which edge characters are trimmed (`pv-tbrs`)

**Plain-terms story.** A disk reports a serial with an invisible vertical-tab character before and after `0XAb`. One implementation removes those edge characters, shows `0XAb`, and matches `ab`. Another keeps them, shows them in the JSON string, and hashes a different normalized serial. The same physical report then gets two fingerprints. An independent reference hash needs an exact trimming rule before either implementation can be judged. No external library comparison is assumed in this story: the two possible rules are printed below.

**Verified basis.** RSC-46 says “trim ASCII whitespace, ASCII-lowercase, then strip exactly one leading `0x`” and that wire strings are “trimmed of ASCII whitespace” (`06-rescue-install.md:314,319`). It also says the fingerprint hashes elements “using normalized values and `null` where a value is absent” (`06-rescue-install.md:321–323`). The complete definition above contains no code-point list. CNF-363 case (2) calls for “an independently computed hash” (`10-conformance-checklist.md:2303`). The proposal defines the term in RSC-46 once, covering both its existing uses; no second normative definition is added to the API or wire document.

### Q3-A — U+0009 through U+000D, plus U+0020 (minimal local definition)

Insert in RSC-46 immediately after its bold heading and before “Before comparison,”:

```text
Here ASCII whitespace means exactly U+0009, U+000A, U+000B, U+000C, U+000D and U+0020;
trimming removes only a maximal prefix and suffix of those code points, never interior
characters or any other code point. This definition applies to normalization and to
trimming the as-read wire values in this requirement.
```

Insert in CNF-363 after its numbered cases and the selected size paragraph, before its final owner-reference line:

```text
      **Whitespace boundaries.** Apply `RSC-46`'s exact trimming set to the caller
      fields and to both inventory WWN and serial. For each of U+0009, U+000A,
      U+000B, U+000C, U+000D and U+0020, independently surround `0XAb` with that
      character: the as-read wire value is `0XAb`, the normalized hash value is
      `ab`, and both its wire echo and `ab` resolve the unique disk under both
      install strategies. A caller value consisting only of that character is
      refused `invalid_request` before enqueue; an inventory value consisting
      only of it is absent and shown `null`. U+0008, U+000E, U+001F, U+007F and
      U+00A0 at the edges are retained on the wire and in normalized values;
      their presence prevents stripping a later `0x` that is not leading.
      Interior occurrences of every tested character are preserved. Separately
      test serial-only and WWN-only one-disk reports, `size_bytes: 1024`:
      independently construct each normalized `{wwn, serial, size_bytes}` element,
      its RFC 8785 canonical bytes and SHA-256, and assert the fingerprint against
      those expected bytes and digest. The reference must not call the engine's
      trim, normalization, serialization or fingerprint helpers. (`RSC-46`, `API-13`)
```

### Q3-B — the same local definition excluding U+000B (narrower trimming set)

Insert in RSC-46 immediately after its bold heading and before “Before comparison,”:

```text
Here ASCII whitespace means exactly U+0009, U+000A, U+000C, U+000D and U+0020;
trimming removes only a maximal prefix and suffix of those code points, never interior
characters or any other code point. U+000B is not whitespace here. This definition
applies to normalization and to trimming the as-read wire values in this requirement.
```

Insert in CNF-363 after its numbered cases and the selected size paragraph, before its final owner-reference line:

```text
      **Whitespace boundaries.** Apply `RSC-46`'s exact trimming set to the caller
      fields and to both inventory WWN and serial. For each of U+0009, U+000A,
      U+000C, U+000D and U+0020, independently surround `0XAb` with that character:
      the as-read wire value is `0XAb`, the normalized hash value is `ab`, and both
      its wire echo and `ab` resolve the unique disk under both install strategies.
      A caller value consisting only of one of those characters is refused
      `invalid_request` before enqueue; an inventory value consisting only of it
      is absent and shown `null`. U+000B is retained: with a serial-only disk whose
      serial is U+000B + `0XAb` + U+000B, its wire echo resolves that disk but `ab`
      matches nothing and aborts `integrity` with no disk write. U+000B alone is
      non-empty for caller admission and on the wire. U+0008, U+000E, U+001F,
      U+007F and U+00A0 at the edges are also retained on the wire and in normalized
      values; their presence prevents stripping a later `0x` that is not leading.
      Interior occurrences of every tested character are preserved. Separately
      test serial-only and WWN-only one-disk reports, `size_bytes: 1024`:
      independently construct each normalized `{wwn, serial, size_bytes}` element,
      its RFC 8785 canonical bytes and SHA-256, and assert the fingerprint against
      those expected bytes and digest. The reference must not call the engine's
      trim, normalization, serialization or fingerprint helpers. (`RSC-46`, `API-13`)
```

These are explicit local definitions, not assertions about a named standard or programming language. The smallest repair found is the single owning definition plus discriminating fixtures. Leaving the term undefined has no supplied independent hash oracle; if you consider no change defensible, cite the existing exact owner that determines the full code-point set and give the fixtures' resulting bytes.

**Question Q3.** Can you accept A, B, or an exact alternative, and which do you prefer? Check U+000B, its neighbors, unchanged interior characters, `null` versus non-empty, case folding before prefix removal, both caller fields, both inventory fields, wire display and independent fingerprint bytes. If a fixture in either form contradicts its own definition or the existing null/prefix rules, identify it precisely rather than silently repairing it.

## Independent vertical-tab fingerprint calculation

Manager calculation in `check/fingerprint-reference.json`, not an engine run. The one-device fixtures use only ASCII/control strings, nulls and the integer 1024; sorted compact JSON with the RFC-required control escapes supplies their exact canonical byte strings. Each displayed byte string below is the literal UTF-8 canonical input, with JSON escape sequences left literal. The other whitespace/boundary fixtures remain required by each exact form.

- Q3-A, serial-only: normalized value `"ab"`; canonical input `[{"serial":"ab","size_bytes":1024,"wwn":null}]`; SHA-256 `8a7ab8eb85404e4ef4022bdf6f1cfc768b029d7f68271f0f60c931d494b72641`.
- Q3-A, wwn-only: normalized value `"ab"`; canonical input `[{"serial":null,"size_bytes":1024,"wwn":"ab"}]`; SHA-256 `251725a8a8cfb350f22a6c3e2c8fdae0f725bd6f7f75b36b4d1dbb1651b3fd82`.
- Q3-B, serial-only: normalized value `"\u000b0xab\u000b"`; canonical input `[{"serial":"\u000b0xab\u000b","size_bytes":1024,"wwn":null}]`; SHA-256 `00bf39db1976286c56c1403bb1603a6bf969927d0b5a96c47a15370586336d60`.
- Q3-B, wwn-only: normalized value `"\u000b0xab\u000b"`; canonical input `[{"serial":null,"size_bytes":1024,"wwn":"\u000b0xab\u000b"}]`; SHA-256 `f26dd8f15deaded4c3bef4ec4a1b3e6771efcf5c9cb376e25e9179ac7b504de5`.

## Final response required

For Q1 (A/B/C), Q2 (A/B/C/D), and Q3 (A/B), separately return ACCEPT / CANNOT ACCEPT on **every exact form**, a final preferred form, the strongest reason against your own preference (labelled requested counterargument), and any verified blocking loss or brief error with owner quote and pinned file:line. Preserve preference versus acceptance. If no printed form is acceptable, supply your complete exact patch; a sketch or an unread merge cannot settle the question. If choices interact, state the exact acceptable combinations and why. An absent implementation-level test is not proof the pinned specification contradicts itself. No builds; this round evaluates exact prose and lightweight deterministic calculations only.
