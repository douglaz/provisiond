# r84b — Panel E: ONE consensus round, Q1 and Q3 only

Read this brief and /var/tmp/provisiond-panel-r84/r84b/notes.md whole. Pin: **3109b5b44eae17e288cf52aaa976993bd8c5626c**. No candidate has been applied. Work only from this packet and your independent pinned clone. Do not read main, other panel folders, original reader folders, session/config/credential locations (~/.claude, ~/.codex, ~/.grok, auth files, kubeconfig, browser profiles), or other current-round answers. This packet reproduces every previous answer verbatim, so there is no need to open those originals.

Read-only: no source/Git/tracker/panel-record writes; no commit, push, checkout, reset, stash, clean, PR action, subagent or background work. **Run no lake build, nix develop, check-all.sh, formal gate or other Lean build.** Only lightweight deterministic calculations, with scratch files under this round's tmp/<seat>. Return a substantive answer before the 3600-second limit; aim for at most 2200 words plus any complete exact alternative.

**apply notes.md rule 6 exactly as written; this prompt adds no void rule.**

## Settled context, purpose and exact disagreements

Q2 is not re-asked. All four prior readers preferred exact Q2-A (1024 decoded UTF-8 bytes before normalization), all accepted it, no verified blocker. That is the technical selection; the new policy/compatibility limit awaits a separate owner answer. The full row and boundary paragraph appear below solely for composition. Do not vote on Q2 or assume the owner adopted it.

Q1 had final picks C=fable/opus and A=astra/sol. All four accepted A and C; three accepted B and fable rejected it as policy. Exact unresolved choice: preserve identity-string admission (A), or avoid rescue disruption by rejecting normalized /dev/ prefixes (C); B's broader slash ban remains complete below. A allows a serial literally /dev/sda to resolve as identity; C intentionally refuses that echo. No option uses caller input directly as a write path. Do not invent an undefined path-shaped grammar.

Q3 had raw final picks A=fable/opus/sol, E=astra. A/B accepted by three; E is a distinct complete alternative reviewed only by its author. The disagreement is the *exact hash test*, not only the trimming policy: original A/B ask to construct each element, "its RFC 8785 canonical bytes and SHA-256", whereas the owner fingerprints the device list. Astra's E retains A's trim set and explicitly hashes the one-element list including array brackets. The manager verified different object/list digests; the previous tally preserves the dissent rather than treating E as A. Assess the objection and E whole; do not silently repair a printed form while accepting it. Fable/opus separately note that the one-disk hash sentence does not name which value to use; decide whether the full text sufficiently specifies the test, without inventing an unread condition.

This is the owner's ONE extra round: "If there are ties, try to run the panel once more focusing on reaching consensus". Try to choose an exact form others can accept. Preserve a disagreement if it changes a protected outcome. No manager synthesis is an accepted vote. Original Q3 A/B and astra E are all printed in complete form; A/B remain unchanged so nobody's earlier vote is rewritten.

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

## Q1 complete exact alternatives

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

**Consensus Q1:** Give acceptability for A/B/C separately and one final preference, focusing on a form others can accept. Explain the strongest reason for the opposite side and whether it changes your preference. State each deliberate input-domain/echo loss. No compulsory provider maxima or undocumented serial grammar is a premise.

## Q2-A — settled technical context, no new vote

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

## Q3 complete exact alternatives

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

### Q3-E — astra complete exact alternative, initially author-reviewed only


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
      independently construct the normalized one-element device list, whose
      element is exactly `{wwn, serial, size_bytes}`, and the RFC 8785 canonical
      bytes of that list, including its enclosing array brackets. Compute
      SHA-256 over those list bytes and assert that `inventory_fingerprint`
      equals the digest encoded as 64 lowercase hex characters. The reference
      must not call the engine's trim, normalization, serialization or
      fingerprint helpers. (`RSC-46`, `API-13`)
```

Everything else remains pinned.

## Verified hash comparison, not an engine run

RSC-46 says "The `inventory_fingerprint` is SHA-256 over the RFC 8785 canonical JSON of the device list" (06-rescue-install.md:321). For A's vertical-tab serial-only one-device fixture, normalized serial is `ab`:

- List canonical UTF-8 bytes: `[{"serial":"ab","size_bytes":1024,"wwn":null}]`; SHA-256 `8a7ab8eb85404e4ef4022bdf6f1cfc768b029d7f68271f0f60c931d494b72641`.
- Element canonical UTF-8 bytes: `{"serial":"ab","size_bytes":1024,"wwn":null}`; SHA-256 `b2fa45b2bdac148628b4ec507afb927aafd8d8c51a5389e5a1a35a8d117bbc05`.

These are independently recomputed in the manager's original tally calculation. Original four list hashes are correct; the issue is the exact CNF sentence's referent, not those hashes. No standard/library definition determines the trim choice. No length hardware guarantee is asserted.

**Consensus Q3:** Give acceptability for unchanged A/B/E separately and a final preference focused on a form others can accept. Check the element/list objection, exact fixture scope, U+000B and neighbors, interior preservation, wire/null rules, prefix order and independent list bytes. If a change is needed beyond a printed form, give a complete exact replacement rather than accepting it with an unstated amendment.

## Prior reader answers — verbatim historical record

The following four blocks are complete original answers, unchanged. Their Q2 votes and combinations are prior history, not questions in r84b. Reader-local links name historical clones; use your own clone instead. The answer delimiters are packet framing, not part of their text.


--- BEGIN ORIGINAL FABLE ANSWER ---
**Verdicts:** Q1 prefer C, accept A and C, cannot accept B. Q2 prefer A, accept A, B and C, cannot accept D. Q3 prefer A, accept A and B. No printed form changes a checked verdict, a Lean declaration or a gate outcome; every CANNOT ACCEPT below is a policy objection and is labelled as one. No brief error voids a tally.

**Verification.** My clone is at 3109b5b44eae17e288cf52aaa976993bd8c5626c and clean. Every pinned extract matches its file and line numbers. All three tracker rows are open and labelled needs-triage. The four reference digests recompute exactly from the stated canonical byte strings, and sorted compact JSON round-trips them byte for byte. No Lean declaration is tagged API-13, RSC-46, SEC-29, OPS-23, RSC-23, CNF-200 or CNF-363, and the two Lean docstring quotations of RSC-46 are sentences no form touches. Against the gates: no form adds a quotation shape the citation gate checks, the only straight double marks added are the paired `"none"` values that the pinned OPS-23 already carries, every cited identifier exists, CNF coverage can only rise, and Q3's `{wwn, serial, size_bytes}` span is the field-set shape the fixture gate already skips. No build was run, as instructed. pv-wfld is closed at the pin, so the injected-value assertions in Q1-B, Q1-C and Q2 rest on pinned text: OPS-23 at 03:2033 says "A field that is present but fails this repeated validation fails as its writer's bullet above says", the caller bullet gives `invalid_request` with `retryable: false`, and 03:2045–2046 settle the install `failed` with `disk_effect: "none"` and `rescue_exit: "none"`.

## Q1, pv-ez8

| Form | Verdict |
|---|---|
| A | ACCEPT |
| B | CANNOT ACCEPT |
| C | ACCEPT, preferred |

Safety needs no ban. RSC-26 at 06:266 says "The identifier is authoritative; the path is derived", and the Lean projection `Resolution.path` at Rescue.lean:337 reads the path off the resolved device only. No form changes what is written. What a ban buys is the reboot: RSC-38 at 06:305–306 says "entering rescue means rebooting the machine into another operating system", and this set already accepted that cost as grounds for pre-enqueue refusal when r61b refused empty identifiers. Copying the inventory's neighbouring `path` field is the one mistake the service can recognise. C refuses exactly that shape with `invalid_request`, which the taxonomy at 01:581 defines as "Caller error, deterministic", instead of `integrity`, defined at 01:590 as "Digest or host-key verification failed", delivered after a reboot with PRV-22's always-ambiguous exit.

C's cost is a serial beginning with `/dev/`, which becomes unnameable although the inventory shows it, and RSC-26's offer-level omission cannot see this because a unique identifier is available. C prints that deliberately. I know of no firmware or virtualisation serial of that shape, which is background knowledge, not packet evidence. C's fixtures are consistent with its paragraph: ` 0X/DeV/sda ` trims, lowercases and strips to `/dev/sda` and is refused; `a/b`, `/tmp/disk` and `not-a-disk` are admitted at `202`, which 04:248 gives for install, then abort `integrity`; a unique serial `a/b` resolves.

A is faithful to r61b's rule that a well-formed string matching nothing aborts `integrity`, and it adds no rule. Its fixtures are consistent: `/dev/sda` is admitted then aborts with no write, and a disk whose serial is literally `/dev/sda` resolves by identity. Its cost is the reboot above for the one recognisable mistake, plus a 422 for a caller typo. Acceptable.

B: CANNOT ACCEPT. No gate contradiction and no checked verdict flips. The objection is the exclusion class. A slash anywhere excludes serials that virtualised providers can derive from volume names, and buys nothing for the story beyond C, since both refuse `/dev/sda`. RSC-26 at 06:258–259 says "An install request MUST carry both the chosen device's stable identifier and the `inventory_fingerprint` it was chosen from"; under B no admissible request exists for such a disk while its strategy stays listed. B's fixtures are internally consistent.

Requested counterargument against C: it writes an OS-specific heuristic over an opaque string into a MUST table, and it carves an exception out of a 4-0 panel decision that only empties are refused before enqueue. A keeps one rule and lets the one checked outcome, abort before any write, do the work.

Loss common to all three, not blocking: CNF-200's phrase "exactly as raw-disk does" disappears, and the parity assertion survives only through CNF-363's both-strategies rule. Each form also drops case (14)'s RSC-26 quotation, which is a checked citation, not a verdict.

## Q2, pv-2j3

| Form | Verdict |
|---|---|
| A, 1024 bytes raw | ACCEPT, preferred |
| B, 256 bytes normalized | ACCEPT |
| C, both | ACCEPT |
| D, body cap only | CANNOT ACCEPT |

Normalization never lengthens a value: trimming and prefix stripping shorten it, and ASCII-lowercasing preserves byte length. A raw cap therefore bounds the parsed value, the stored value and the matching key at one observation point, which is how every other row works. An echo of an inventory value has raw length equal to the trimmed as-read value, so A refuses an echo only when the trimmed serial or WWN exceeds 1024 bytes. B refuses echoes above 256 normalized bytes, a strictly larger exclusion, while admitting two mebibytes of padding; its own fixture admits a 1025-byte padded value. C adds B's bound to A's, so it excludes everything B excludes for a key-size benefit I cannot name. A is the least restrictive form that still bounds the input.

On the numbers, as background knowledge and not packet evidence: ATA and NVMe serials are 20 bytes, NAA WWNs are 16 or 32 hex digits, NVMe NGUIDs are 32 hex digits, and Linux udev's SCSI serial buffers are 256 bytes. 256 covers every format I know with no margin; 1024 covers them with fourfold margin. Both are defensible without a provider guarantee. The margin is why I prefer A.

Fixture consistency holds in A, B and C. 512 copies of U+00E9 are 1024 bytes and 128 copies are 256; appending `a` crosses each limit by one; literal and `\u0061` spellings decode identically. All three keep inventory values untruncated and use OPS-23's pinned kind and settlement for an injected value.

Lost capability shared by A, B and C, reported as a printed policy: a disk whose only identifier exceeds the cap is visible, uniquely identified and unnameable, and RSC-26's offer-level omission cannot see it. No CNF asserts such an echo, so no verdict flips.

D: CANNOT ACCEPT. SEC-29 at 07:280–281 says "individual fields MUST be capped per `API-13`". D satisfies that in letter only by writing "no separate field-size cap" into API-13, which makes SEC-29's second clause vacuous for the one field that can be two mebibytes, and the tracker row's own example, a 1.9 MiB identifier stored and compared in the worker, becomes conformant. Notes rule 7 says not to weaken a disputed rule to clear a review. No gate verdict changes; this is a policy objection.

Requested counterargument against A: the pinned table's other string rows count "characters" while A counts decoded UTF-8 bytes, a second counting convention, and if the owner wants the tightest defensible key bound, C's 256 is it, at the price of defending two numbers.

## Q3, pv-tbrs

| Form | Verdict |
|---|---|
| A, with U+000B | ACCEPT, preferred |
| B, without U+000B | ACCEPT |

Both definitions are exact, both fixture sets agree with their own definition and with the pinned null and prefix rules, and both reference digests verify. Under A, a vertical-tab-wrapped `0XAb` trims to `0XAb`, lowercases to `0xab`, strips to `ab` and hashes as `ab`; its echo and `ab` both match. Under B nothing trims, the value lowercases to VT`0xab`VT, the leading character is VT so no prefix is stripped, the echo matches and `ab` matches nothing, exactly as B's fixture says. U+0008, U+000E, U+001F, U+007F and U+00A0 at the edges are retained and block the strip under both. Case folding precedes prefix removal in both. VT-only is refused before enqueue under A and admitted under B, each consistent with its definition and with the pinned row at 04:974, "empty-after-normalization `target.identifier` or `layout.drives[].identifier` MUST be refused `invalid_request` before enqueue". Interior characters are preserved in both, matching case (13).

I prefer A because the trim exists to remove invisible firmware padding, and vertical tab is invisible padding. B's own fixture shows the trap it keeps: a serial only its exact echo can match. A's set is a contiguous range plus space, easy to state and to check. Two r61c readers proposed it and the tracker row names it.

Requested counterargument against A: the phrase "ASCII whitespace" has a widely published exact definition that excludes U+000B, and a mainstream standard-library predicate of the same name agrees, so defining the phrase differently invites an implementer to call that predicate and diverge on the one discriminating fixture. B keeps the term and the common predicate aligned. Background, not premise.

Two observations, neither blocking. Neither form trims U+0000, so a NUL-padded serial stays non-null and unnormalized under both, consistent with how both retain U+0008. Neither form's fingerprint sentence names which value the one-disk reports carry; the manager's calculation reads it as the vertical-tab case, the only discriminating one, and I read it the same way.

**Composition and brief errors.** C, A and A compose without overlap. Q1-C's paragraph follows the API-13 table and Q2-A replaces only the row. Q2-A's paragraph follows case (14) and Q3-A's follows it, before CNF-363's owner line. Every Q2 and Q3 fixture satisfies Q1-C and Q2-A, since nothing begins with `/dev/` and nothing exceeds 1024 bytes. Q1-C and Q2-A both carry "Worker repetition: `OPS-23`", a harmless duplication inside one owner. Any other accepted combination composes the same way; no Q1 form depends on the Q2 or Q3 choice. Applying notes rule 6 as written: I found no brief error, premise-changing or otherwise. Every quotation and line reference I checked is accurate, including the RSC-38 reboot sentence at 06:305–306, the RSC-46 fingerprint sentence at 06:321–323, and CNF-363 case (2) at 10:2303.

--- END ORIGINAL FABLE ANSWER ---

--- BEGIN ORIGINAL OPUS ANSWER ---
I've recorded a verdict on every printed form. I accept each form except Q2-D. My picks are **Q1-C, Q2-A and Q3-A**. I found no verified brief error, so rule 6 voids nothing.

**How I checked.** My clone is at `3109b5b44eae17e288cf52aaa976993bd8c5626c` and clean. Every quoted passage and line number in the brief matches the pinned files. A grep of `git diff 08191bb 3109b5b` over the owning files found no changed lines touching identifiers, RSC-46, SEC-29, API-13, CNF-200 or CNF-363. I recomputed the four vertical-tab fingerprints and every normalization and byte-count fixture with my own script (`tmp/opus/calc.py`, exit 0). All four SHA-256 values in the brief match exactly. No form changes a Lean declaration: `Rescue.lean:298` models an identifier as a natural number, `resolve` (`:351–357`) receives a request that was already admitted, and admission, normalization and length are not modelled. I ran no builds.

## Q1 — `pv-ez8`

| Form | Verdict |
|---|---|
| Q1-A | **ACCEPT** |
| Q1-B | **ACCEPT** |
| Q1-C | **ACCEPT** |

**Preferred: Q1-C.**

**Why C.** No form ever turns the caller's string into a device path, so a ban isn't needed to protect the write. Two things still make the narrow `/dev/` ban worth having:

1. **It stops a reboot that achieves nothing.** RSC-38 says entering rescue "means rebooting the machine into another operating system (`PRV-15`), and `PRV-22` makes the exit *always* ambiguous, so a failure can strand a customer's machine there with nothing serving" (`06-rescue-install.md:305–307`). Under A, a caller who pastes `/dev/sda` accepts that risk for an install that is certain to abort with `integrity`. `/dev/sda` is the exact form RSC-26 used to have callers name (`06:247–248`), so this is the most predictable mistake.
2. **It closes one way the wrong disk could be chosen.** Suppose disk X sits at `/dev/sda` and has the serial `/dev/sdb`, and disk Y sits at `/dev/sdb`. A caller who means "the disk at `/dev/sdb`" gets X under A, because the identifier wins. A's new case (14) makes resolving a `/dev/sda` serial a required conformance result. C refuses every value whose normalized form starts with `/dev/`. The check runs after lowercasing and after the one `0x` strip, so ` 0X/DeV/sda ` is caught, and it is caught on the same normalized form that matching uses.

**What C costs (a deliberate policy change, not an editorial fix).**
- It adds a new admission refusal.
- A disk whose every identifier normalizes to something starting with `/dev/` can no longer be targeted. The inventory still shows it and still hashes it, which the inserted paragraph keeps ("the inventory retains that value"). An install naming it gets `400` before enqueue rather than resolving.
- RSC-26 says an install "MUST carry both the chosen device's stable identifier and the `inventory_fingerprint`" (`06:258–259`). For such a disk that becomes impossible to satisfy. That isn't a contradiction: RSC-26 promises no echo guarantee, and duplicate identifiers already leave disks untargetable.
- RSC-26's per-offer strategy omission (`06:272–274`) doesn't account for identifiers that are present but refused, so such an offer can list a strategy that no install can use.
- No existing CNF verdict flips. I checked CNF-363 (1)–(13) and WIR fixtures `13-wire-contract.md:293–297, 720, 727`; none uses a `/` in an identifier.

**B's extra cost.** B refuses `/` anywhere, so it makes more legitimate values untargetable. What it adds over C (`a/b`, `dev/sda`, `disk/by-id/...`) is unlikely to be a real mistake. It is safe but over-broad, which is why it's accept-not-prefer.

**A** matches the pinned owners exactly. API-13 refuses only "a `null`, non-string or empty-after-normalization" value (`04:974`), and RSC-26 makes the integrity abort the outcome (`06:268–269`). It changes no policy.

**Requested counterargument (against C).** A prefix ban protects nothing on the write path, because "The identifier is authoritative; the path is derived" (`06:265–266`). C adds a reserved domain that both the API and the worker must keep. It refuses a value the service itself displayed. And it doesn't touch bare `sda` or `nvme0n1`, which still cost a rescue round trip. A is the only form that leaves every displayed identifier echoable.

**Blocking losses:** none for any form.

## Q2 — `pv-2j3`

| Form | Verdict |
|---|---|
| Q2-A | **ACCEPT** |
| Q2-B | **ACCEPT** |
| Q2-C | **ACCEPT** |
| Q2-D | **CANNOT ACCEPT** |

**Preferred: Q2-A** (1024 UTF-8 bytes before normalization).

**Why A.**
- No field cap can stop the service from receiving and parsing a long string; only the body cap does that. What a field cap actually decides is what gets admitted, stored in the record that OPS-23 re-checks, and compared. A bounds the field as received.
- WIR-1a requires a body to "be valid UTF-8" under I-JSON (`13:22–23`). That makes "the decoded value's UTF-8 encoding" well-defined: there are no lone surrogates.
- A also bounds the normalized value at 1024 or less, so C's extra 256 normalized cap brings no safety gain and only refuses more identifiers.
- B leaves the raw field limited only by the body: ~2 MiB of padding around `a` is admitted and stored. That is the plain-terms story left unaddressed, though B is coherent.

**Fixture arithmetic.** 512 × U+00E9 = 1024 bytes, plus `a` = 1025. 128 × U+00E9 = 256 bytes, plus `a` = 257. An escaped 1025-byte value is about 6.2 KB, well under the body cap. The boundary paragraphs in A, B and C are each consistent with their own row.

**Losses I'm disclosing, rather than treating the cap as free.**
- **A:** a disk whose trimmed displayed identifier is over 1024 bytes becomes untargetable (`400` before enqueue, where today it would resolve). A padded echo near the cap is also refused. CNF-363 (13), "Padded echoes … resolve" (`10:2322–2323`), would flip only if a tester picked a near-cap fixture. No verdict flips at ordinary fixture sizes.
- **B and C:** the same loss, but at more than 256 normalized bytes, so a wider band of displayed identifiers is lost.
- **A, B and C:** the inventory still returns long values untruncated, and RSC-26's anchor clause "Every disk reported … MUST remain in the inventory and in the fingerprint" (`06:255–256`) is kept.

**Are 1024 and 256 defensible?** Both are policy headroom, not provider maxima. 256 matches API-13's neighbouring identifier rows (`04:966, 970`). 1024 loses fewer echoes for a bound that is still trivial next to the body cap, so I prefer it.

**Why I can't accept D.**
- **Policy:** D leaves the identifier bounded only by the body, which is the gap `pv-2j3` was opened to close.
- **Owner claim:** D's sentence "This row is the explicit field-size exception for `SEC-29`" presumes SEC-29 requires a per-field cap. It then grants an exception that SEC-29's words don't provide. SEC-29 says "individual fields MUST be capped per `API-13`" (`07-security-requirements.md:280–281`). A non-owner granting exceptions to an owner's MUST is the second-copy drift AGENTS.md warns about.
- **Contestable:** this rests on reading SEC-29 as requiring a cap on every field. The other reading — SEC-29 just delegates to API-13 — is supported by API-13 already leaving `provider options` without a size (`04:972`).

**Requested counterargument (against A).** A's cap counts padding, so the same identity can be admitted or refused depending on whitespace the caller added. B caps exactly what RSC-46 compares. And 1024 has no provider evidence behind it either.

## Q3 — `pv-tbrs`

| Form | Verdict |
|---|---|
| Q3-A | **ACCEPT** |
| Q3-B | **ACCEPT** |

**Preferred: Q3-A** (trim U+0009–U+000D and U+0020).

**Fixture checks (independently computed, all hold).**
- **Q3-A:** vertical tab + `0XAb` + vertical tab shows on the wire as `0XAb` and normalizes to `ab`. Both the echo and `ab` resolve the disk. A vertical tab on its own is empty after normalization: shown `null` in inventory, refused when a caller sends it.
- **Q3-B:** the same value shows as `"\u000b0XAb\u000b"` and normalizes to `"\u000b0xab\u000b"`. The leading tab stops the `0x` from being stripped, so `ab` matches nothing. A vertical tab on its own is non-empty.
- **Other edge characters:** U+0008, U+000E, U+001F, U+007F and U+00A0 at the edges are kept under both forms and block the `0x` strip, e.g. `"\u00080xab\u0008"`.
- **Interior characters** are kept: `0X␋Ab` becomes `"\u000bab"`, and `0X Ab` becomes `" ab"`. Normalization never re-trims after the prefix strip.
- **Lowercasing before prefix removal** holds under both forms.
- **Both caller fields and both inventory fields** are covered. Neither form contradicts the existing null or prefix rules or CNF-363 (5), (8) and (10). For (8), I get ` 0x0XAB ` → `0xab`, and `0XAB` → `ab`, a non-match, as the case requires.
- **Fingerprints:** `8a7ab8eb…b72641`, `251725a8…b3fd82`, `00bf39db…336d60` and `f26dd8f1…04de5` all match the brief byte for byte.

**Why A.**
- U+0009–U+000D plus space is one contiguous, easily tested set. Carving vertical tab alone out of the control characters around it needs a reason that nothing in the pinned set supplies.
- Under A, a caller value made only of invisible characters is refused before enqueue. Under B, a lone vertical tab is admitted, then reboots the machine into rescue and aborts with `integrity`. That is the same pointless disruption as in Q1.
- Under A, an edge vertical tab collapses to the same normalized value as its plain neighbour. Any collision becomes a duplicate and aborts with `integrity`, which fails safe.

**Requested counterargument (against A).** This is background, not verified in the packet. B matches the most widely published meaning of the exact term "ASCII whitespace", which RSC-46 already pairs with "ASCII-lowercase": that's WHATWG Infra's definition and Rust's `is_ascii_whitespace`. So builders who implemented the pinned text that way stay conformant under B but not under A, and no real serial pads with a vertical tab.

**Non-blocking weakness in both forms.** The fingerprint-oracle sentence doesn't name its fixture value. A tester could hash a plain `ab` and never exercise the edge vertical tab in the hash. The wire and resolution assertions still distinguish the two rules.

**Blocking losses:** none. **Lost verdicts:** none. Whichever is chosen, builders using the other rule become non-conformant. That's the purpose of the change, and I'm disclosing it as a deliberate policy choice.

## Combinations

All 3 × 3 × 2 = 18 combinations of the forms I accept compose exactly as the brief lays them out:
- Q1-B/C insert a paragraph between the API-13 table and its note.
- Q2 replaces only the row.
- Q3 inserts into RSC-46.
- Each CNF-363 paragraph goes in the stated order.

Where they interact, the behaviour is defined:
- **Q1-C with Q3:** a vertical tab + `/dev/sda` is refused under Q3-A, but admitted and then aborted with `integrity` under Q3-B. Both are consistent.
- **Q2-B/C with Q3:** the normalized length depends on Q3's set. Q2's fixtures use only spaces, ASCII and é, so their outcomes don't change.

Q1-B/C and Q2's row both say "Worker repetition: `OPS-23`". The duplicate pointer is harmless.

**Brief errors:** none verified; I relied on no outside premise. Model identity played no part in these verdicts.

--- END ORIGINAL OPUS ANSWER ---

--- BEGIN ORIGINAL ASTRA ANSWER ---
My final preferences are **Q1-A, Q2-A, and the complete Q3 alternative E below**. Acceptance is separate:

| Question | Exact form | Verdict |
|---|---|---|
| Q1 | A | **ACCEPT — preferred** |
| Q1 | B | **ACCEPT** |
| Q1 | C | **ACCEPT** |
| Q2 | A | **ACCEPT — preferred** |
| Q2 | B | **ACCEPT** |
| Q2 | C | **ACCEPT** |
| Q2 | D | **ACCEPT** |
| Q3 | A | **CANNOT ACCEPT** |
| Q3 | B | **CANNOT ACCEPT** |
| Q3 | E, supplied below | **ACCEPT — preferred** |

I read the brief and notes whole, verified the pin and relevant source passages, and independently calculated normalization boundaries, UTF-8 lengths and fingerprints. No builds, edits, tracker changes or delegated work occurred. The final working tree is clean.

**Q1: prefer A; accept the printed policy restrictions in B and C.**

An admission ban is unnecessary for preventing caller-controlled device-path selection. RSC-26 says, **“The identifier is authoritative; the path is derived.”** It separately requires **“An identifier that does not resolve to exactly one device MUST abort `integrity` before any write.”** ([06-rescue-install.md:264](https://github.com/douglaz/provisiond/blob/3109b5b44eae17e288cf52aaa976993bd8c5626c/06-rescue-install.md#L264), [line 268](https://github.com/douglaz/provisiond/blob/3109b5b44eae17e288cf52aaa976993bd8c5626c/06-rescue-install.md#L268))

A preserves that distinction and tests both relevant cases: an unmatched `/dev/sda` fails during resolution; a unique serial literally equal to `/dev/sda` resolves by identity. Its generated configuration must use the resolved path. This is preferable to inferring a serial’s meaning from its spelling.

B and C are acceptable **substantive admission restrictions**, with these collateral flips:

- **B:** a unique serial containing `/`, including `a/b`, becomes unusable through its exact echo. An unmatched slash-containing input changes from admission followed by resolution failure to `400 invalid_request` before enqueue.
- **C:** those flips apply only when normalization produces the `/dev/` prefix. `a/b` and `/tmp/disk` remain admissible.
- For either restriction, if the disk has no alternative admissible identifier, the caller loses the ability to select it despite its retained inventory identity.

These losses are explicit in the proposed owner paragraphs, not hidden changes to resolution. Neither restriction establishes that all mistaken device-path inputs will be caught.

**Requested counterargument:** A permits a recognizable mistake to interrupt the installed OS. RSC-38 explicitly says **“entering rescue means rebooting the machine into another operating system”** ([06-rescue-install.md:305](https://github.com/douglaz/provisiond/blob/3109b5b44eae17e288cf52aaa976993bd8c5626c/06-rescue-install.md#L305)). B or C avoids that disruption for its rejected domain. That operational benefit is real even though no destructive write occurs.

I found no additional blocking loss in Q1’s exact forms.

**Q2: prefer A’s exact 1024 decoded UTF-8 bytes before normalization.**

| Form | Gain | Deliberate loss or remaining exposure |
|---|---|---|
| A | Bounds admitted caller values, including padding, with one field limit. | Exact inventory echoes exceeding 1024 decoded UTF-8 bytes fail, even when normalization would make them short. |
| B | Bounds normalized matching keys to 256 UTF-8 bytes. | Longer normalized identities cannot be submitted; padding remains bounded only by the body cap. |
| C | Bounds both admitted raw values and normalized keys. | Combines A’s padding/echo exclusions with B’s narrower identity domain. |
| D | Preserves the broadest length admission domain and makes the exception explicit. | Supplies no independent disk-field resource budget; long stored caller values and padding remain possible within the body cap. |

A’s 1024 is defensible as a **chosen service budget**, not as a provider compatibility guarantee. The same distinction makes 256 defensible as a policy choice, but I see no supplied reason to prefer its additional exclusion of normalized identities between 257 and 1024 bytes. A already bounds those matching keys indirectly because the specified normalization cannot increase UTF-8 length.

A field cap does not guarantee that receiving or JSON-parsing an oversized value is avoided: enforcement occurs on the decoded value. Its dependable benefit is limiting values admitted for subsequent storage and processing.

Inventory output remains untruncated under every form. Exact echo failure does not invariably make a disk inaccessible: an alternative admissible identity or equivalent spelling may exist. Where none exists, the new cap makes that disk unselectable.

The retained conformance cases remain satisfiable. CNF-363 scopes them to **“otherwise-admissible fixtures”**, while case (7) checks **“echoing it resolves that disk through both strategies.”** ([10-conformance-checklist.md:2295](https://github.com/douglaz/provisiond/blob/3109b5b44eae17e288cf52aaa976993bd8c5626c/10-conformance-checklist.md#L2295), [line 2310](https://github.com/douglaz/provisiond/blob/3109b5b44eae17e288cf52aaa976993bd8c5626c/10-conformance-checklist.md#L2310)) The new restrictions narrow which echoes qualify; that compatibility loss should be recorded explicitly.

D deliberately resolves the field-cap ambiguity through the owning row. SEC-29 says fields **“MUST be capped per `API-13`”** ([07-security-requirements.md:280](https://github.com/douglaz/provisiond/blob/3109b5b44eae17e288cf52aaa976993bd8c5626c/07-security-requirements.md#L280)); D explicitly makes body-only treatment the rule for this field. I accept that printed exception without treating it as equivalent to a separate cap.

The multibyte and padding boundaries calculate correctly. Worker rejection fixtures also agree with OPS-23’s **“Validation that was performed at the API boundary MUST be repeated in the worker before the driver is called”** and its caller-field outcome **“`invalid_request` naming the field, with `retryable: false`.”** ([03-operation-lifecycle.md:2018](https://github.com/douglaz/provisiond/blob/3109b5b44eae17e288cf52aaa976993bd8c5626c/03-operation-lifecycle.md#L2018), [line 2030](https://github.com/douglaz/provisiond/blob/3109b5b44eae17e288cf52aaa976993bd8c5626c/03-operation-lifecycle.md#L2030))

**Requested counterargument:** Nothing supplied establishes that 1024 admits every legitimate provider serial. D avoids introducing this particular compatibility break, and the global body limit already bounds ordinary submitted requests. A’s operational benefit must justify rejecting some otherwise valid identities and padded echoes.

I found no additional blocking loss in Q2’s exact forms.

**Q3: both trimming policies work, but both exact checklist insertions have a fingerprint-oracle defect.**

Both candidates instruct the reference to construct:

> each normalized `{wwn, serial, size_bytes}` element, its RFC 8785 canonical bytes and SHA-256, and assert the fingerprint against those expected bytes and digest.

That literally selects the **element’s** canonical bytes and digest. RSC-46 instead specifies:

> The `inventory_fingerprint` is SHA-256 over the RFC 8785 canonical JSON of the device list

([06-rescue-install.md:321](https://github.com/douglaz/provisiond/blob/3109b5b44eae17e288cf52aaa976993bd8c5626c/06-rescue-install.md#L321))

The distinction changes the checked verdict. For A’s serial-only fixture:

```text
Required list:
[{"serial":"ab","size_bytes":1024,"wwn":null}]
SHA-256:
8a7ab8eb85404e4ef4022bdf6f1cfc768b029d7f68271f0f60c931d494b72641

Individual element:
{"serial":"ab","size_bytes":1024,"wwn":null}
SHA-256:
b2fa45b2bdac148628b4ec507afb927aafd8d8c51a5389e5a1a35a8d117bbc05
```

I independently reproduced every supplied vertical-tab **list** digest. Those calculations are correct; they do not repair the exact proposed checklist text. Reading “its” generously as the enclosing list would require an unstated repair. I therefore cannot accept either printed form unchanged.

Otherwise, the boundary fixtures are internally consistent:

- A trims U+000B; B retains it. Under B, U+000B alone remains non-empty and the wrapped serial normalizes to `"\u000b0xab\u000b"`.
- Both preserve the printed neighboring excluded characters and all tested interior occurrences.
- ASCII case folding precedes removal of one leading `0x`; retained leading controls prevent that removal.
- Trimmed wire strings preserve case, while comparison/hash values undergo full normalization.
- The checks cover both caller fields and both inventory identity fields.

These outcomes follow RSC-46’s **“trim ASCII whitespace, ASCII-lowercase, then strip exactly one leading `0x`”** and **“A value that is empty after normalization is absent and matches nothing.”** ([06-rescue-install.md:314](https://github.com/douglaz/provisiond/blob/3109b5b44eae17e288cf52aaa976993bd8c5626c/06-rescue-install.md#L314))

**Requested counterargument:** Choosing A’s trimming set can collapse identities distinguished only by edge U+000B. B preserves that distinction and permits an identity consisting solely of that character. No supplied provider evidence proves either choice universally preferable.

**Complete exact alternative Q3-E**

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
      independently construct the normalized one-element device list, whose
      element is exactly `{wwn, serial, size_bytes}`, and the RFC 8785 canonical
      bytes of that list, including its enclosing array brackets. Compute
      SHA-256 over those list bytes and assert that `inventory_fingerprint`
      equals the digest encoded as 64 lowercase hex characters. The reference
      must not call the engine's trim, normalization, serialization or
      fingerprint helpers. (`RSC-46`, `API-13`)
```

Everything else remains pinned.

**Composition, formal scope and rule 6**

My exact acceptable combinations are:

```text
Q1 ∈ {A, B, C}
Q2 ∈ {A, B, C, D}
Q3 = E as printed above
```

The preferred combination is **A / A / E**. The positive fixtures can satisfy each selected admission domain, and E changes neither Q1 nor Q2 text.

No Lean change is necessary. The pinned model uses `Identifier.n : Nat` and `Inventory.fingerprint : Nat`; its resolution definition and named abort theorems do not encode these string-domain choices. The candidates preserve the modeled resolution rule, whose owner says **“An identifier that does not resolve to exactly one device MUST abort `integrity` before any write.”** ([Rescue.lean:295](https://github.com/douglaz/provisiond/blob/3109b5b44eae17e288cf52aaa976993bd8c5626c/tools/formal/Provisiond/Rescue.lean#L295), [line 345](https://github.com/douglaz/provisiond/blob/3109b5b44eae17e288cf52aaa976993bd8c5626c/tools/formal/Provisiond/Rescue.lean#L345))

Applying notes.md rule 6 exactly: the Q3 candidate-oracle error does **not** change the question’s premise that the trimming set is unspecified. It is an “other brief error”; both of my Q3 printed-form rejections rest on it. I identify no premise-changing brief error and do not declare a tally void or conduct a tally.
--- END ORIGINAL ASTRA ANSWER ---

--- BEGIN ORIGINAL SOL ANSWER ---
I reviewed every printed Panel E form against `3109b5b44eae17e288cf52aaa976993bd8c5626c`. **Review result: PASS as explicit policy alternatives. Final preferences: Q1-A, Q2-A, Q3-A.** Acceptance does not mean equal preference.

Applying notes.md rule 6 exactly as written: I found no verified brief error that changes a question’s premise. I found no blocking contradiction; the substantive policy losses identified below are deliberately printed choices.

**Q1 — admission versus resolution**

| Exact form | Verdict | Preference |
|---|---|---|
| Q1-A | **ACCEPT** | **Preferred** |
| Q1-B | **ACCEPT** | Broader admission restriction than needed |
| Q1-C | **ACCEPT** | Acceptable narrower restriction |

A resolves the ambiguity without inventing syntax that is necessary for disk-write safety. The pinned admission row requires “a JSON string, non-empty after normalization (`RSC-46`)” ([API-13, 04-api-contract.md:974](https://github.com/douglaz/provisiond/blob/3109b5b44eae17e288cf52aaa976993bd8c5626c/04-api-contract.md#L974)). The decisive resolution property is “The identifier is authoritative; the path is derived” ([RSC-26, 06-rescue-install.md:266](https://github.com/douglaz/provisiond/blob/3109b5b44eae17e288cf52aaa976993bd8c5626c/06-rescue-install.md#L266)). Consequently, allowing `/dev/sda` as an identifier string does not authorize using it as the write path.

A’s fixtures distinguish the important outcomes: unmatched `/dev/sda` receives `202`, reaches inventory resolution in rescue, and aborts `integrity` without writes; a unique serial literally equal to `/dev/sda` resolves by identity. The old CNF-200 wording, “is rejected,” supplies no admission phase ([10-conformance-checklist.md:2243](https://github.com/douglaz/provisiond/blob/3109b5b44eae17e288cf52aaa976993bd8c5626c/10-conformance-checklist.md#L2243)). A makes that phase explicit while retaining the resolved-path protection.

B and C are coherent additional availability policies. Their `400 invalid_request` refusals avoid rescue entry for the prohibited strings, and their saved-request fixtures also check worker enforcement. Their verified substantive loss is the inability to echo some legitimate inventory identifiers:

- B excludes every normalized identifier containing `/`, including `a/b`.
- C excludes normalized `/dev/` prefixes, including a unique serial `/dev/sda`; it retains `a/b`.

That narrows the applicability of CNF-363’s positive assertion, “echoing it resolves that disk through both strategies” ([10-conformance-checklist.md:2311](https://github.com/douglaz/provisiond/blob/3109b5b44eae17e288cf52aaa976993bd8c5626c/10-conformance-checklist.md#L2311)). Its setup already says “Use otherwise-admissible fixtures” ([10-conformance-checklist.md:2295](https://github.com/douglaz/provisiond/blob/3109b5b44eae17e288cf52aaa976993bd8c5626c/10-conformance-checklist.md#L2295)), so this is a disclosed admission-domain change rather than a contradictory remaining fixture. Inventory retention does not restore caller access to an excluded value.

No admission ban is needed to prevent treating caller input as a write path. A ban can nevertheless be chosen to avoid disruption from recognizable mistakes. C targets that benefit more narrowly than B; neither prevents every unmatched identifier from reaching rescue.

**Requested counterargument against Q1-A:** A knowingly permits an avoidable reboot for a common mistaken input. The consequence matters: “entering rescue means rebooting the machine into another operating system,” and an ambiguous exit can strand it there ([RSC-38, 06-rescue-install.md:305](https://github.com/douglaz/provisiond/blob/3109b5b44eae17e288cf52aaa976993bd8c5626c/06-rescue-install.md#L305)). C trades away fewer legitimate identifiers than B while avoiding that particular disruption.

**Q2 — identifier size**

| Exact form | Verdict | Preference |
|---|---|---|
| Q2-A | **ACCEPT** | **Preferred: 1024 decoded UTF-8 bytes before normalization** |
| Q2-B | **ACCEPT** | Explicitly accepts body-sized padding |
| Q2-C | **ACCEPT** | Adds a more restrictive normalized domain |
| Q2-D | **ACCEPT** | Explicitly chooses body-only protection |

I prefer A because one raw decoded-value limit bounds admitted field size and subsequent storage and repeated processing, without separately excluding normalized identifiers between 257 and 1024 bytes. It does **not** guarantee that receipt or initial JSON parsing stops at 1024 bytes: the global body cap remains relevant before admission.

The observation points and units are unambiguous:

- **A:** decoded string’s UTF-8 encoding, before normalization; maximum 1024 bytes.
- **B:** normalized string’s UTF-8 encoding; maximum 256 bytes, with raw input bounded only by the body.
- **C:** both observations, at their respective printed limits.
- **D:** no independent identifier length observation that produces a field-specific refusal.

JSON escape spelling does not change these field-size outcomes. The supplied U+00E9 examples correctly distinguish UTF-8 bytes from character counts.

The losses are substantive:

- **A:** an exact inventory wire echo exceeding 1024 bytes is inadmissible. A 1025-byte padded caller value is refused even if normalization leaves `a`.
- **B:** an inventory echo whose normalized value exceeds 256 bytes is inadmissible. Long padding remains admissible within the body cap, so normalized-key size is bounded while raw field processing can remain large.
- **C:** combines both exclusions.
- **D:** retains length compatibility within the body cap but gives up an independent field bound.

A shorter equivalent spelling may sometimes rescue an over-limit echo; that is not universally available, particularly because normalization strips exactly one prefix. None of these forms truncates inventory values.

These choices also narrow the positive scope of “Padded echoes and serials with whitespace inside them resolve through both strategies” ([CNF-363, 10-conformance-checklist.md:2322](https://github.com/douglaz/provisiond/blob/3109b5b44eae17e288cf52aaa976993bd8c5626c/10-conformance-checklist.md#L2322)). A and C deliberately move over-limit padded inputs to admission refusal; B and C exclude over-limit normalized serials. The new boundary paragraphs disclose those changed outcomes.

Both printed numbers are defensible **as support-policy limits**, with the exclusions accepted explicitly. Neither establishes coverage of every provider’s identifiers. I would not describe either as a hardware maximum. The 256-byte normalized limit buys a smaller matching-key domain; that additional restriction is why I prefer A over B or C.

D is acceptable because it explicitly makes the exception in API-13, the delegated field-limit owner. It changes the practical protection behind SEC-29’s “individual fields MUST be capped per `API-13`” ([07-security-requirements.md:280](https://github.com/douglaz/provisiond/blob/3109b5b44eae17e288cf52aaa976993bd8c5626c/07-security-requirements.md#L280)); it should not be presented as supplying the same independent bound.

The saved-request outcomes are consistent with “Validation that was performed at the API boundary MUST be repeated in the worker before the driver is called” ([OPS-23, 03-operation-lifecycle.md:2018](https://github.com/douglaz/provisiond/blob/3109b5b44eae17e288cf52aaa976993bd8c5626c/03-operation-lifecycle.md#L2018)), including its caller-field failure classification and pre-rescue timing.

**Requested counterargument against Q2-A:** There is no provider guarantee behind 1024. A can make a machine’s sole unique inventory identifier unusable, and rejects harmless padding despite an existing finite body bound. D preserves that compatibility; B preserves large padding while bounding normalized keys.

**Q3 — exact trimming set**

| Exact form | Verdict | Preference |
|---|---|---|
| Q3-A | **ACCEPT** | **Preferred** |
| Q3-B | **ACCEPT** | Coherent alternative retaining U+000B |

Both definitions and their fixtures are internally consistent. I prefer A’s continuous U+0009–U+000D range plus U+0020, including removal of invisible edge vertical tabs. This preference assumes no outside library’s behavior.

The owning sequence remains “trim ASCII whitespace, ASCII-lowercase, then strip exactly one leading `0x`” ([RSC-46, 06-rescue-install.md:314](https://github.com/douglaz/provisiond/blob/3109b5b44eae17e288cf52aaa976993bd8c5626c/06-rescue-install.md#L314)). My independent calculation used explicit code-point sets and ASCII folding, without engine helpers:

- For every member of the selected trimming set, surrounding `0XAb` produces wire value `0XAb` and normalized value `ab`. The character alone normalizes to absence.
- Under B, U+000B surrounding `0XAb` remains on the wire. ASCII folding produces `\u000b0xab\u000b`; the leading vertical tab prevents prefix removal. Its echo matches, while `ab` does not.
- U+000B alone is absent under A and non-empty under B.
- The listed retained neighbors—U+0008, U+000E, U+001F, U+007F and U+00A0—remain present. Interior occurrences of every tested character survive.
- Bare `0X` still normalizes to absence. The existing nested-prefix fixture still normalizes ` 0x0XAB ` to `0xab`, stripping only one prefix.

These results apply equally to both caller fields and both inventory identity fields. They preserve the distinction between trimmed as-read wire display and normalized fingerprint content.

The vertical-tab fixtures produced these exact canonical UTF-8 inputs, shown with JSON escapes literal:

```text
A serial: [{"serial":"ab","size_bytes":1024,"wwn":null}]
A WWN:    [{"serial":null,"size_bytes":1024,"wwn":"ab"}]
B serial: [{"serial":"\u000b0xab\u000b","size_bytes":1024,"wwn":null}]
B WWN:    [{"serial":null,"size_bytes":1024,"wwn":"\u000b0xab\u000b"}]
```

Their SHA-256 digests matched every supplied reference hash. Neither form contains a fixture contradicting its own definition or the existing null/prefix rules.

**Requested counterargument against Q3-A:** An edge vertical tab might be meaningful identifier content. Removing it can collapse otherwise distinct serials, making selection ambiguous and causing an integrity refusal; B preserves that distinction. A and B also necessarily produce different wire displays and fingerprints for the discriminating fixtures. Those are substantive choices, not editorial equivalence.

**Composition and formal properties**

My acceptable combinations are exactly the unchanged printed forms in:

`{Q1-A, Q1-B, Q1-C} × {Q2-A, Q2-B, Q2-C, Q2-D} × {Q3-A, Q3-B}`.

My preferred combination is **Q1-A + Q2-A + Q3-A**, without revised wording.

The selected Q3 definition determines normalization before Q1’s syntax predicate and Q2’s normalized-size observation. For example, under Q3-B, edge vertical tabs remain: Q1-C’s prefix predicate can therefore differ from its result under Q3-A. That follows the exact predicates; it is not an undefined “path-shaped” exception. The printed size fixtures use spaces, which both Q3 forms trim.

No printed form changes a formalized resolution clause or requires theorem weakening. The model’s identifier is `n : Nat` ([Rescue.lean:298](https://github.com/douglaz/provisiond/blob/3109b5b44eae17e288cf52aaa976993bd8c5626c/tools/formal/Provisiond/Rescue.lean#L298)); its resolution definition checks fingerprint and match multiplicity ([Rescue.lean:351](https://github.com/douglaz/provisiond/blob/3109b5b44eae17e288cf52aaa976993bd8c5626c/tools/formal/Provisiond/Rescue.lean#L351)). The proposed string admission and normalization policies do not alter those abstract definitions or verdicts.

All lightweight checks and calculation assertions exited 0. The final worktree was clean. No builds, edits, tracker changes, or panel-record writes were performed.
--- END ORIGINAL SOL ANSWER ---

## Final response contract for this round

Return Q1 and Q3 separately. For Q1 A/B/C and Q3 A/B/E, state ACCEPT / CAN ACCEPT WITH THIS EXACT FIX / CANNOT ACCEPT for every unchanged form. An exact fix is a separate form, not an accept of the old form. Finish each question with Final: <one exact preferred form>, preferably one others can accept, and its strongest argument/conditions. Give one requested counterargument without turning it into a vote. Cite any verified blocking loss with owner words and full trace; distinguish intended policy from an unintended changed verdict. State any premise-changing or other brief error under notes rule 6. Do not vote on Q2. No builds or source changes. No second consensus round is planned.
