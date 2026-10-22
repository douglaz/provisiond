Q1: **(a)**. `RSC-33` requires “(name, path, size, type, model, serial)”. Preserve that reporting contract. `RSC-26`’s “an ordering artefact” explains why names cannot select disks; it does not justify removing observed names from diagnostic reports.

Q2: **(ii)**. Amend `RSC-23` explicitly: its character restrictions govern generated installer field values. Normalize drive selectors, resolve them, then emit validated device paths. `SEC-13` targets values “interpolated into generated installer configuration”. The lookup identifier need never enter that configuration.

Q3: Accept with these amendments:

- **6:** Require observed `name` and `path` on every device.
- **8:** Exercise both strategies; assert normalized hash serial `0xab`. With no other matching disk, lookup `0xab` aborts `integrity`: it normalizes to `ab`, distinguishing exactly one prefix removal.
- **9:** Assert an independently calculated digest using fixtures whose identifier order differs from serialized-element byte order; reordering invariance alone cannot distinguish sorting algorithms.
- **12:** Compare hashes with one versus two identical anonymous devices. Padded echoes and serials containing internal whitespace resolve through both strategies; inspect generated configuration for resolved paths.
- **Add:** With both identity fields present, assert preserved trimmed spellings and WWN preference; with a WWN that normalizes to absent, assert serial fallback.
- **Add:** A well-formed unmatched identifier aborts `integrity` without writes, through both strategies.

Q4: The strongest objection is that `RSC-23` begins “Layout validation MUST enforce”. Moreover, `RSC-26` follows “the validation is identical” with resolution conditions, which need not erase rootfs-specific input restrictions. Thus (ii) relaxes a plausible current reading and requires a deliberate amendment.