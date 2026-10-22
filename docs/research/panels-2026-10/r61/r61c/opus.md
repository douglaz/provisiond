**Q1: (A), as read.** Normalization runs on whatever the caller echoes back, so the value shown must be one that survives normalizing a second time. Under (A) that holds by construction, because trimming is idempotent. Under (B) it fails: a serial `0x0xAB` is shown as `0xab`, which then normalizes to `ab` and matches nothing. `wwn` and `serial` carry the same form. `identifier` is byte-equal to `wwn` if non-null, else `serial`, else `null`. That rule lives in `RSC-46`, and `WIR-20` and `WIR-10b` cite it.

**Q2: accept.** `0X5000` → `5000`. `" 0x "` → empty, so absent, so refused.

**Q3: (b), plus WWN.** `RSC-33` now lists "(path, size, type, model, serial, WWN)". `path` already carries the name. `RSC-46` hashes `{wwn, serial, size_bytes}`, but `RSC-33`'s minimum never listed WWN.

**Q4: no edit.** The engine writes the resolved path into the installer config, not the identifier. The live case is a serial with whitespace inside it. If `RSC-23` reaches it, `rootfs_via_rescue` refuses what `raw_disk` accepts, against `RSC-26`'s "the validation is identical". That fails closed, so report it only.

**Q5: amend.** Add: "a serial read as ` 0x0XAB ` is shown as `0x0XAB`, in `identifier` and in `serial`, and echoing that resolves it". As drafted, nothing in the item told (A) from (B). Also write "a bare `0x` or `0X`", which pins lowercasing before the strip.

**Q6.**
- **Edited:** `RSC-46`, `RSC-33`, `WIR-10b` (it gains a device with no serial and no WWN), the `RSC-46` citation in `WIR-20`, `CNF-363`, and the two Lean docstrings.
- **Not drafted:** the `API-13` row and the `WIR-40`/`RSC-26`/`CONTEXT.md` qualifiers. So `CNF-363` asserts a refusal that no `API-13` row states yet.
- **Gates:** the baseline exited 0. My first edit exited 1: citations caught my unquoted "normalized as `RSC-46` says". After the fix it exited 0, and again after the `0X` amendment.
- **Plant:** a `WIR-10b` example whose `identifier` is not byte-equal to its `serial`. It stayed at 0, so no gate checks fields against each other inside an example.
- **Also:** `RSC-46`'s false claim "`WIR-20` and `WIR-10b` cite this" was green at `4c0bb4c`.

**Q7 (strongest case against my pick, written on request).** Under (A), serials `ABC` and `abc` show as two identifiers, while matching treats them as one. Picking either hits the more-than-one abort, with no cause visible in the listing. Under (B) the duplicate is visible. It fails closed, but the listing misleads.
