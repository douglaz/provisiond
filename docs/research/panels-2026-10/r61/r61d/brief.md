# Panel brief r61d: pv-6p8, two splits and the test list. 2026-10-22

You are one of four independent reviewers. Your working directory is a throwaway clone of the
specification repository `provisiond-spec` at `4c0bb4c` (master). Read `AGENTS.md` first. You MAY edit tracked
files in this clone to test a claim. Write nothing outside it (never `/tmp` or `/var/tmp`), and never commit,
push or call a provider API. Read nothing outside this clone except toolchain files. Gates are optional this
round. If you edit, run `nix develop --command bash tools/check-all.sh` unpiped, redirect it to a file in the
clone, and read its exit code. Keep `TMPDIR` as set. Do not delegate, background or wait on anything. Have a draft
answer by minute 20. Check every fact below with grep before you rely on it: the manager has been wrong in briefs
before. **Answer in at most 300 words.**

## Settled (off-limits)

Bead pv-6p8 asks what `rescue_inventory` returns for a disk with no serial and no WWN. Three rounds and the owner
settled the following.

- Every disk stays in `devices` and in the fingerprint.
- Each device carries `identifier`, `wwn` and `serial`. The owner chose to put `wwn` and `serial` on the wire,
  and `RSC-33` names both.
- **The wire form (r61c, 4-0).** Each value is the string as read, trimmed of ASCII whitespace, and `null` where
  normalization leaves nothing. `identifier` is `wwn` if that is non-null, else `serial`, else `null`.
- **`RSC-46` normalization (r61c, 4-0).** Trim, ASCII-lowercase, then strip exactly one leading `0x`. Matching
  and the hash use the normalized form, and a value that is empty after normalization is absent. The device list
  is sorted by each element's RFC 8785 serialization, compared as UTF-8 byte strings, with duplicates kept.
- **Admission.** A new `API-13` row refuses a `target.identifier` or `layout.drives[].identifier` that is `null`,
  not a string, or empty after normalization, with `invalid_request` before enqueue. A well-formed string that
  matches nothing aborts `integrity`.
- **Tests and citations.** A new `CNF-363` follows `CNF-206`. There is no new Lean theorem; quoting docstrings
  are updated. The missing `RSC-46` citations are added to `WIR-20` and `WIR-10b`. "Stable identifiers" in
  `WIR-40`, `RSC-26`'s first bullet and `CONTEXT.md` is qualified with "where a disk has one".

## Q1. `name` (r61c split 2-2)

`RSC-33` asks for "(name, path, size, type, model, serial)". `WIR-10b`'s device has `path` (`"/dev/nvme0n1"`)
and no `name`.

- (a) Add a `name` field, for example `"nvme0n1"` (astra, sol). `RSC-33` stays as it is, and the wire meets it
  word for word.
- (b) Amend `RSC-33`'s minimum to "(path, size, type, model, serial, WWN)" (fable, opus). `path` already
  carries the name, and `RSC-26` calls the name "an ordering artefact".

Pick one and give your strongest argument.

## Q2. `RSC-23` (r61c split three ways)

`RSC-23` says "Layout validation MUST enforce: … no whitespace, CR, LF, or NUL in any config field".
`RSC-22` builds "the installer's configuration from a structured layout". `RSC-26` says the validation is
identical for every strategy that names a disk.

- (i) No edit (opus). The engine writes the resolved path into the installer configuration, not the identifier.
- (ii) Clarify `RSC-23`: its whitespace rule governs the generated installer configuration, where a drive is the
  resolved device path. A caller's `layout.drives[].identifier` is a lookup input that `RSC-46` normalizes
  (astra, sol).
- (iii) `RSC-23` does cover the identifier. Add one sentence to `RSC-46` quoting `RSC-23` (fable).

The consequence:
- Under (iii), a padded echo through `rootfs_via_rescue` is refused. So is a serial with whitespace inside it,
  which `raw_disk` accepts.
- Under (ii), both resolve.

Pick one.

## Q3. `CNF-363`'s required assertions (the manager merged round 3's amendments)

Accept the list or amend it, in one line per change. Adjust items 6 and 12 to your Q1 and Q2 picks.

Use fixtures that are otherwise admissible, with unique chosen identifiers.

1. Disk A has a WWN; disk B has neither a WWN nor a serial. Both are listed. B has `identifier`, `wwn` and
   `serial` all `null`.
2. The fingerprint is `RSC-46`'s hash over both disks.
3. A `raw_disk` install naming A with that fingerprint resolves A and writes nothing to B. So does a
   `rootfs_via_rescue` install whose `layout.drives` names A.
4. Removing or resizing B between the inventory and the install aborts `integrity` with no bytes written.
5. If B's serial is whitespace-only, the result is the same as if it had none.
6. If Q1 is (a), every device carries `name` and `path`.
7. A serial-only disk shows its serial as `identifier` and as `serial`. Echoing it resolves the disk through both
   strategies.
8. A serial read as ` 0x0XAB ` is shown as `0x0XAB`. Echoing it resolves the disk.
9. Reordering the devices leaves the fingerprint unchanged. So does changing only names or paths.
10. These are refused `invalid_request` before enqueue: a `null`, a non-string, an empty or whitespace-only
    string, or a bare `0x`/`0X`, in `target.identifier` or in any `layout.drives[].identifier`.
11. On a machine where no device has an identifier, the inventory succeeds and every device shows `null`.
12. Two identical anonymous devices both appear, and both are hashed. The padded-echo case follows your Q2 pick.

## Q4

Written on request: the strongest argument against your Q2 pick.
