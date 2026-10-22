# Panel brief r61: pv-6p8, the wire form of a disk with no unique identifier. 2026-10-21

You are one of four independent reviewers. Your working directory is a throwaway clone of the
specification repository `provisiond-spec` at `4c0bb4c` (master). Read `AGENTS.md` first. `br show pv-6p8`
prints the bead (if `br` fails in the clone, `.beads/issues.jsonl` holds it). You MAY edit tracked files in this
clone to test a claim. Write nothing outside it (never `/tmp` or `/var/tmp`), and never commit, push or call a
provider API. Read nothing outside this clone except toolchain files. The gates exit 0 at `4c0bb4c`:
`nix develop --command bash tools/check-all.sh`, a few minutes. Run it unpiped, redirect it to a file in the
clone, and read its exit code. Keep `TMPDIR` as set. Do not delegate, background or wait on anything: do the work
yourself in this session. Have a draft answer by minute 30. Check every fact below with grep before you rely on
it: the manager has been wrong in briefs before. Read text by requirement id, not by line number.
**Answer in at most 500 words.**

## Settled (off-limits)

- `RSC-26`'s abort: "An identifier that does not resolve to exactly one device MUST abort `integrity` before any
  write."
- PR #15 (`pv-pj0`, merged as `3f14280`): `RSC-26` now says the driver "MUST omit the `raw_disk` and
  `rootfs_via_rescue` strategies from an offer's `install_strategies` where no per-device unique identifier is
  available at all for that offer", and "This omission does not make the offer unsellable." `CNF-206` tests it.
- The capability row in `01-domain-model.md`: "| rescue inventory | `rescue_ssh` (`RSC-38` boots rescue to read
  the inventory) |".
- Duplicate serials are out of scope: two devices can already carry the same string, and `RSC-26`'s
  more-than-one case aborts. Raise them only if your chosen form has to signal them.

## The question (owner-approved triage, bead pv-6p8, P2)

What does `rescue_inventory` return for a device with no unique identifier, meaning no serial and no WWN? The
options in the bead:

1. `identifier: null` for that device.
2. Omit the device from `devices`. Does the fingerprint still cover the whole set?
3. Refuse `rescue-inventory` on such a machine. That needs a static signal, since inventory is the only reader.

A fourth form is welcome if the spec supports it.

## The text it lands on

- `WIR-40`: "It returns `202` and an operation whose result carries the device inventory with **stable
  identifiers** and the `inventory_fingerprint` an install must echo back (`WIR-20`, `RSC-26`)."
- `WIR-10b`'s `rescue_inventory` result: `{"inventory": {"devices": [{"identifier": "S4EVNF0N123456", "path":
  "/dev/nvme0n1", "size_bytes": 1024209543168, "model": "SAMSUNG MZVL21T0HCLR", "type": "nvme"}], "uefi": true,
  "inventory_fingerprint": "b7f1…"}}`. No sentence states the type or nullability of `identifier`.
- `RSC-26`'s first bullet: rescue inventory returns "the block-device inventory with **stable identifiers** —
  serial and WWN — plus an opaque `inventory_fingerprint` over the whole device set".
- `RSC-26`'s last sentences (PR #15): "This is a static per-offer declaration from provider facts; rescue
  inventory (`RSC-38`) is available only after purchase, on one machine, and cannot supply it." and "If a machine
  bought under a listed strategy has rescue inventory that shows no unique identifier, that machine meets the
  abort this paragraph opens with."
- `RSC-33`: the report holds "at minimum the block-device inventory (name, path, size, type, model, serial)", and
  "This is the record that tells an operator afterwards which disk was actually overwritten."
- `RSC-38`: "its report MUST carry the same `inventory_fingerprint` an install will be checked against."
- `RSC-46`: "Matching tries the WWN first, then the serial", and "The `inventory_fingerprint` is SHA-256 over the
  RFC 8785 canonical JSON of the device list sorted by identifier, each device exactly `{wwn, serial,
  size_bytes}` with `null` where a value is absent".
- `WIR-20`: `target.identifier` "is a drive serial or WWN". `WIR-2`: "clients MUST ignore unknown response
  fields".
- `WIR-30` (quoted in `CNF-206`): "The gate reads the copy the machine took at create" (`machines.install_strategies`).
- Lean: `tools/formal/Provisiond/Rescue.lean`, namespace `Disk`. `Device.identifier` is `Option Identifier`;
  `Request.identifier` is not.

## Questions

1. Vote 1, 2, 3 or a fourth form, with your strongest argument.
2. Cost each option: what it breaks, and the requirement ids it touches (`WIR-10b`, `WIR-40`, `RSC-26`, `RSC-33`,
   `RSC-38`, `RSC-46`, `WIR-20`, `DOM-*`, Lean, others).
3. Trace each option on a mixed machine: disk A has a WWN, disk B has neither serial nor WWN. What does the
   caller see, can it install on A, and is the fingerprint over the same set the caller sees?
4. Option 3: is `machines.install_strategies` lacking both rescue strategies the static signal it needs? Can any
   option-3 form cover the machine in `RSC-26`'s last sentence, which no per-offer signal can see?
5. `RSC-46`'s "sorted by identifier": what does it mean for a device with no identifier, and when two devices
   tie? Does your pick need to fix it? Is an empty or whitespace-only serial "absent"?
6. The triage text says option 1 works because "the install side already aborts `integrity` on zero matches".
   True? A caller can't name a null device. Is a `null` or empty `target.identifier` `invalid_request` under
   `WIR-20`, or `integrity`? Does any text say?
7. `WIR-10b` has `identifier`; `RSC-33` asks for `serial`; `RSC-46` hashes `wwn` and `serial` apart. Is that gap
   in scope for this bead, or a separate one?
8. Which `CNF` item asserts your form: amend `CNF-47`, `CNF-192` or `CNF-206`, or a new one? Draft its text.
9. Make your pick's edit in your clone and run the gates. Plant the plausible bad edit for your pick, run the
   gates again, and report whether anything goes red. If nothing does, say what would catch it.
10. Labelled as written on request: the strongest argument against your own pick.
