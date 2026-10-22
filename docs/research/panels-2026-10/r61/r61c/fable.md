**Q1: (A), as read.** `identifier` is the WWN as reported, else the serial, trimmed of ASCII whitespace; `null` where normalization leaves nothing. `wwn` and `serial` carry the same form. Beyond sol's `0x0xAB`: under (A) an echo matches by construction, since normalize(shown) equals normalize(read) whatever the function is. (B) holds only if normalization is idempotent, and strip-once is not. (A) also keeps the `S4EVNF0N123456` fixtures in `WIR-10b` and `WIR-20` valid, and shows the operator the string on the disk label, which `RSC-33` says the report is for.

**Q2: accept.** "Compared case-insensitively" named no canonical string for the hash.

**Q3: (b).** `RSC-33` now reads "(path, size, type, model, serial, WWN)". `path` carries the name; WWN added because it goes on the wire and `RSC-26` prefers it.

**Q4: yes.** It is a `layout` field, and `RSC-23` lists "every drive a stable identifier" in the same rule. No contradiction: under (A) a verbatim echo never carries padding, so the trim serves `target.identifier` and inventory values. One sentence in `RSC-46` says so, quoting `RSC-23`. Residual, not this bead: a serial with interior whitespace is nameable by `raw_disk` but not by `rootfs_via_rescue`.

**Q5: accept, plus one line** after the serial-only sentence: "a serial read as `0x0xAB` is shown as `0x0xAB`, and echoing it resolves the disk." It is the only sentence that separates (A) from (B). The item also needs its citation list for the coverage gate.

**Q6.** Edited `RSC-46`, `RSC-33`, `WIR-10b` (nullable `wwn`/`serial`, a null device, one paragraph owning the wire form), `WIR-20`, `WIR-40`, `CONTEXT.md`, the `API-13` row, `CNF-363`, two Lean docstrings. `Rescue.lean`'s "stable identifiers — serial and WWN" quote stands, since `RSC-26` is untouched. First run: exit 1. The citations gate rejected my own "`WIR-10b` says which form…" as an unquoted attribution. Reworded to a pointer. Second run: exit 0, seven PASS. Bad edit: misquoted `RSC-23` inside `RSC-46`. Exit 1, citations FAIL "attributes to RSC-23 a phrase RSC-23 does not contain", six PASS. Reverted.

**Q7, as written.** (A) puts a string on the wire that nothing compares. Two devices can show `0X5000…` and `0x5000…` yet be one identity, so a client that sorts or dedups on the shown value disagrees with the fingerprint. (B) shows one canonical string per identity, and the `0x0xAB` defect is cured by making normalization idempotent (strip every leading `0x`), a one-word change to `RSC-46` instead of a second form on the wire.
