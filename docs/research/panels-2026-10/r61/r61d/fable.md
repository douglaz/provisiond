**Checked.** At `4c0bb4c`, `RSC-33` reads "(name, path, size, type, model, serial)" with no WWN, so the brief's "`RSC-33` names both" is false. `RSC-33` needs an amendment regardless.

**Q1: (b).** The edit is free: `RSC-33` must be amended to name WWN, and dropping `name` rides along. Nothing in the set reads a device `name`. `WIR-20` takes an identifier, `RSC-27` validates the resolved path, and `RSC-46` excludes paths "because they are the unstable part". A `name` is a second copy of that unstable part. `RSC-33`'s purpose is "the record that tells an operator afterwards which disk was actually overwritten", and path, serial and WWN are that record.

**Q2: (ii).** I switch from (iii). `SEC-13` states the rule's purpose: "validation for line breaks, NUL, and whitespace where the format is whitespace-delimited (`RSC-23`)". The identifier never enters that format. `RSC-26` says "The identifier is authoritative; the path is derived", and `CNF-13` tests "Installer-config fields". Decisive: under (iii) an interior-space serial is refused on `rootfs_via_rescue` and resolved on `raw_disk`, contradicting `RSC-26`'s "the validation is identical".

**Q3.** Accept, with:
- 6: every device carries `path`, `wwn`, `serial`, `identifier`; nothing asserts `name`.
- 8: add that echoing `0XAB` or `ab` matches nothing and aborts `integrity` after enqueue, not `invalid_request`. That pins "exactly one" strip and the well-formed non-match rule.
- 12: the padded echo and an interior-space serial both resolve through both strategies. The generated installer configuration carries the resolved path, and `CNF-13` still refuses whitespace there.

**Q4.** `RSC-23` puts "every drive a stable identifier" and "no whitespace, CR, LF, or NUL in any config field" in one sentence, so the identifier is already a layout-validated field and (ii) carves an exception the text does not draw. A padded echo is a client bug, and refusing it `invalid_request` at admission is a cheaper failure than normalizing it away silently. The weakness: `raw_disk`'s `target` has no `RSC-23`, so (iii) buys strictness on one strategy only.
