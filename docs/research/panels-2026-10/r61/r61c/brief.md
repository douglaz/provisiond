# Panel brief r61c: pv-6p8, the last open details. 2026-10-22

You are one of four independent reviewers. Your working directory is a throwaway clone of the
specification repository `provisiond-spec` at `4c0bb4c` (master). Read `AGENTS.md` first. `br show pv-6p8`
prints the bead (if `br` fails in the clone, `.beads/issues.jsonl` holds it). You MAY edit tracked files in this
clone to test a claim. Write nothing outside it (never `/tmp` or `/var/tmp`), and never commit, push or call a
provider API. Read nothing outside this clone except toolchain files. The gates exit 0 at `4c0bb4c`:
`nix develop --command bash tools/check-all.sh`, a few minutes. Run it unpiped, redirect it to a file in the
clone, and read its exit code. Keep `TMPDIR` as set. Do not delegate, background or wait on anything: do the work
yourself in this session. Have a draft answer by minute 25. Check every fact below with grep before you rely on
it: the manager has been wrong in briefs before. Read text by requirement id, not by line number.
**Answer in at most 350 words.**

## Background

The bead asks what `rescue_inventory` returns for a device with no serial and no WWN. Two rounds of four readers
have settled most of the form. Don't reopen these.

## Settled (off-limits)

- **Every device stays.** Every reported device stays in `devices` and in the fingerprint, with `identifier: null`
  where it has neither a WWN nor a serial. Round 1 was 4-0 for this.
- **Empty means absent.** A value that is empty after `RSC-46`'s normalization is absent and matches nothing.
  The fingerprint hashes normalized values, with `null` where a value is absent.
- **Sort order.** The fingerprint's device list is sorted by each element's RFC 8785 serialization, compared as
  UTF-8 byte strings. Identical elements stay, one per device. This replaces `RSC-46`'s "sorted by identifier".
  Round 2 was 4-0.
- **Malformed identifiers are refused early.** A new `API-13` row covers `target.identifier` and every
  `layout.drives[].identifier`. One that is `null`, not a string, or empty after normalization is refused
  `invalid_request` before enqueue. A well-formed string that matches nothing still aborts `integrity`. Round 2
  was 4-0; opus withdrew its dissent, citing `RSC-38`'s "`PRV-22` makes the exit *always* ambiguous, so a
  failure can strand a customer's machine there".
- **One new conformance item.** A new `CNF-363` follows `CNF-206`, and `CNF-47`, `CNF-192` and `CNF-206` stay as
  they are. Round 2 was 4-0.
- **No new Lean theorem.**
  - Quoting docstrings get updated: `Rescue.lean` quotes "**stable identifiers** — serial and WWN",
    `Witnesses.lean` quotes "sorted by identifier", and `Rescue.lean` claims "two device sets do not share one".
    The last is false once two same-sized anonymous disks hash alike.
  - Opus showed the citations gate goes red on a stale quote.
- **Missing citations get added.** `WIR-20` and `WIR-10b` gain the `RSC-46` citation. `RSC-46` claims "`WIR-20`
  and `WIR-10b` cite this", but `13-wire-contract.md` contains no `RSC-46`.
- **Two sentences get qualified.** `CONTEXT.md`'s "reports its disks with stable identifiers" and `WIR-40`'s
  "**stable identifiers**" become "where a disk has one".
- **The owner decides one thing separately.** Whether nullable `wwn` and `serial` go on the wire in this bead
  (round 2: 3-1 for yes) is the owner's scope call. Answer Q3 assuming yes.

## Open

**Q1. Which string does `identifier` carry?** Round 2 split 2-2:
- **(A) As read** (fable, sol): the WWN as the rescue environment reported it, else the serial, trimmed of ASCII
  whitespace. It is `null` where neither survives normalization. Matching and the fingerprint use the normalized
  form.
- **(B) Normalized** (astra; opus with a fix to the example): the normalized value. `WIR-10b`'s example
  `"S4EVNF0N123456"` becomes lowercase.
- **The case for (A):** `RSC-46` strips "a leading `0x`", once. Under (B), a serial `0x0xAB` is shown as `0xab`.
  Echoed back, it normalizes again to `ab` and matches nothing. That comes from sol, derived from the text.

Pick one, or name a third. Under the owner's likely "yes", do `wwn` and `serial` carry the same form?

**Q2. Normalization order** (opus, sol): "trimmed of ASCII whitespace, ASCII-lowercased, then stripped of one
leading `0x`". `RSC-46` reads "trimmed of ASCII whitespace, compared case-insensitively, and stripped of a
leading `0x`", which leaves `0X5000` unclear. Accept or amend.

**Q3. `name`.** `RSC-33` asks for "(name, path, size, type, model, serial)". `WIR-10b`'s device has `path` and no
`name`. Pick one:
- (a) add `name` (astra, sol);
- (b) amend `RSC-33`'s minimum to `path`, which already carries the name;
- (c) leave it to a separate bead.

**Q4. `RSC-23`** (opus): "no whitespace, CR, LF, or NUL in any config field". Is a `layout.drives[].identifier` a
config field? If so, it refuses the padding `RSC-46` trims. Does this bead need to say anything?

**Q5. The `CNF-363` draft**, merged from round 2's additions. Accept, or amend it in one line:

> **A disk with no serial and no WWN is listed, hashed and never nameable.** On a machine with disk A carrying a
> WWN and disk B carrying neither, a rescue-inventory result lists both, B with `identifier`, `wwn` and `serial`
> all `null`, and its `inventory_fingerprint` is `RSC-46`'s hash over both. A `raw_disk` install naming A with
> that fingerprint resolves A and writes nothing to B; so does a `rootfs_via_rescue` install whose
> `layout.drives` names A. Removing or resizing B between the inventory and the install aborts `integrity` with
> no bytes written. Repeat with B's serial whitespace-only: the same. A disk carrying only a serial shows it as
> its `identifier`, and echoing that value back resolves the disk. An install whose `target.identifier`, or any
> `layout.drives[].identifier`, is `null`, empty, whitespace-only or a bare `0x` is refused `invalid_request`
> before enqueue. On a machine where no device has an identifier, the inventory succeeds and lists every device
> with `null`. Two identical anonymous devices both appear, and both are hashed.

**Q6.** Make your Q1–Q5 edits (`RSC-46`, `WIR-10b`, `RSC-33`, `CNF-363`) in your clone and run the gates. Then
plant one bad edit and report whether anything goes red.

**Q7.** Labelled as written on request: the strongest argument against your Q1 pick.
