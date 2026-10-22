**Q1: (b).** Two of (a)'s premises don't hold. `RSC-33` lists "(name, path, size, type, model, serial)" and has no WWN, so the settled WWN decision means `RSC-33` gets edited either way. `WIR-10b` uses `size_bytes`, not "size", so the wire doesn't match `RSC-33` word for word even now. `RSC-26` says "the name is not stable … `/dev/sda` is an ordering artefact", and that quote is about a path. A `name` field would just be a second copy of that unstable value. Nothing in `tools/formal/`, the checklist or `CONTEXT.md` quotes the six fields.

**Q2: (ii).** I'm moving off my round-3 pick of (i). `CNF-363` has to assert that padded and internal-whitespace echoes resolve through `rootfs_via_rescue`. Under (i), no sentence says so. A literal reader of "Layout validation MUST enforce: … no whitespace … in any config field" would refuse them. (iii) breaks `WIR-20`: "validated exactly as `raw_disk`'s `target.identifier` is". The clarification should keep the two objects apart:
- The whitespace clause governs the generated installer configuration (`SEC-13`), where a drive appears as its resolved path (`RSC-27`).
- `layout.drives[].identifier` is a lookup input that `RSC-46` normalizes.

**Q3.** Accept items 1–4, 7 and 10. Changes:
- **5:** Add a serial read as a bare `0x`. It shows `null`.
- **6:** Every device carries `path`, `wwn` and `serial`, and none carries `name`.
- **8:** Echoing `0X0xab` resolves the disk. Echoing `0XAB` aborts `integrity`, which catches an implementation that strips `0x` twice.
- **9:** Change "names or paths" to "paths".
- **11:** Add that a well-formed install aborts `integrity` with no write. `RSC-26` says "that machine meets the abort this paragraph opens with".
- **12:** "Both are hashed" means dropping one device changes the fingerprint. A padded echo resolves through both strategies, and so does an exact echo of a serial with whitespace inside it.

**Q4, the strongest argument against (ii).** `SEC-13` already limits the rule to values "interpolated into generated installer configuration", so (i) is enough as written. (ii) would re-explain in `RSC-23` what `RSC-26` ("The identifier is authoritative; the path is derived") and `RSC-46` already own. That is the second-copy drift AGENTS.md warns about under "arguments have owners". The concrete risk is a serial-derived by-id path reaching the configuration, and `RSC-27`'s "simple path under the device directory" arguably blocks it already.
