**Verified at `4c0bb4c`:** `RSC-33` has no WWN; `WIR-10b` says `size_bytes` and its device has no `name`; `CNF-363` does not exist yet; the Lean `Device` is `identifier` + `path` only, so no theorem moves under either option.

**1. Grid.** (a) ACCEPT. (b) ACCEPT. Preference: **(b)**.

Nothing blocks (a): `WIR-2` says "clients MUST ignore unknown response fields", the fingerprint stays `{wwn, serial, size_bytes}`, and (a)'s "changing only names leaves the fingerprint unchanged" assertion is mildly useful.

**2. Weakest point of (b).** "Nothing in the set reads a device `name`" proves too much. `model` appears only in `RSC-33` and `WIR-10b`; `type` likewise. Nothing reads them, and nobody proposes dropping them. `RSC-33` is "the record that tells an operator afterwards", not a machine input, so "unread" is no argument. What remains is redundancy: `RSC-27` says "a simple path under the device directory", so for a whole disk `name` is `path` minus the directory.

**3. Form all four could accept.** Keep the observed name as an obligation, carried by `path`, with no second field:

`RSC-33`: "…the block-device inventory (path, size, type, model, serial, WWN) and whether the firmware is UEFI — and MUST attach it to the operation result. The path is the device's name as the rescue environment reported it at that reading, under `RSC-27`'s device directory: diagnostic record, not identity (`RSC-26`)."

`WIR-10b` device and `CNF-363`: exactly as in (b).

This gives astra and sol the reporting obligation in `RSC-33`'s own words, and gives opus and me one copy of the unstable value.
