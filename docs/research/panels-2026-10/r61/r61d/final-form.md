# pv-6p8: reviewed final form (panels r61, r61b, r61c, r61d, r61e, r61f; owner 2026-10-22)

Question: what does `rescue_inventory` return for a disk with no serial and no WWN? Base: master `4c0bb4c`.
Panel records: `/var/tmp/provisiond-panel-r61{,b,c,d,e,f}/` (brief.md plus one answer file per reader; r61e's
tally is in `/var/tmp/provisiond-panel-r61e/tally.md`).

**Owner decision (2026-10-22): "Yes, in this bead (Recommended)".** The inventory also shows each disk's `wwn` and
`serial`, either of which may be null, on `WIR-10b`, and `RSC-33` names both.

**Nothing is open.** `name` (item 4) split 2-2 in r61d. The owner answered "Try to get a consensus". In r61e all four
readers marked both variants ACCEPT, and in r61f all four picked variant (b). Every item below is reviewed.

## The form, by landing id

1. **Option 1 (r61 4-0).** Every disk the rescue environment reports stays in `devices` and in the fingerprint.
   - Lands on: `WIR-10b`, `RSC-26` first bullet.
   - Rejected: omitting the disk; refusing the inventory.
2. **Wire form (r61c 4-0).** Each device carries `identifier`, `wwn` and `serial`.
   - Each value is the string as read, trimmed of ASCII whitespace, and `null` where `RSC-46`'s normalization leaves
     nothing.
   - `identifier` is byte-equal to `wwn` if that is non-null, else `serial`, else `null`.
   - The rule's home is `RSC-46`, and `WIR-10b` cites it.
   - The `WIR-10b` example gains a second device with all three fields `null`.
   - Lands on: `WIR-10b`, `RSC-46`.
3. **The values are shown as read, not normalized (r61c 4-0).** Normalization strips one leading `0x`, so it
   doesn't give the same result when applied twice. A serial `0x0xAB` shown normalized as `0xab` would normalize
   again to `ab` when echoed, and match nothing.
4. **No `name` field (r61d 2-2; r61e both variants 4 ACCEPT; r61f 4-0 for (b)).**
   - `RSC-33`'s minimum becomes "(path, size, type, model, serial, WWN)". No further sentence is added.
   - `WIR-10b`'s device carries no `name`.
   - WWN joins the list by owner decision.
   - Reason (r61f, all four): no reader showed that a separate `name` tells an operator anything beyond `path`.
     Both readers who preferred `name` conceded this in r61e.
   - Rejected:
     - Variant (a), a separate `name` field: all four accepted it, but no one picked it.
     - fable's `RSC-33` sentence calling the path the device's name: opus CANNOT, because it is an unquoted
       attribution to `RSC-26` and widens `RSC-27`.
     - opus's `WIR-10b` mapping sentence: fable CANNOT, because a bridging sentence is second-copy drift.
     - sol's optional `MAY carry name`: fable and opus CANNOT. The set has no response field left to the
       implementation's choice, and `CNF-363` could assert nothing.
   - Lands on: `RSC-33`.
5. **`RSC-46` normalization (r61c 4-0).**
   - The steps are: trim ASCII whitespace, ASCII-lowercase, then strip exactly one leading `0x`.
   - A value that is empty after normalization is absent and matches nothing.
   - Matching and the fingerprint use the normalized values, with `null` where a value is absent.
   - Lands on: `RSC-46`.
6. **Fingerprint order (r61b 4-0).** "sorted by identifier" becomes: sorted by each element's RFC 8785
   serialization, compared as UTF-8 byte strings. Identical elements are kept, one per device. The hashed element
   stays `{wwn, serial, size_bytes}`. Lands on: `RSC-46`.
7. **Admission (r61b 4-0).** A new row: "disk identifier: a JSON string, non-empty after `RSC-46`'s
   normalization".
   - A `null`, non-string or empty-after-normalization `target.identifier` or `layout.drives[].identifier` is
     refused `invalid_request` before enqueue.
   - A well-formed string that matches nothing still aborts `integrity`.
   - Reason (opus, citing `RSC-38`): "`PRV-22` makes the exit *always* ambiguous, so a failure can strand a
     customer's machine there".
   - Lands on: `API-13` (new row), with a pointer in `WIR-20`.
8. **`RSC-23` scope (r61d 4-0, option ii).** State that `RSC-23`'s "no whitespace, CR, LF, or NUL in any config
   field" governs the generated installer configuration. There a drive appears as its resolved path (`SEC-13`,
   `RSC-27`).
   - A `layout.drives[].identifier` is a lookup input that `RSC-46` normalizes.
   - Padded echoes, and serials with whitespace inside them, resolve on both strategies.
   - Write it as a pointer to `SEC-13`/`RSC-26`/`RSC-46`, not a re-explanation. Opus's labelled argument against
     (ii) was second-copy drift.
   - Lands on: `RSC-23`.
9. **Qualifiers (r61b).** "stable identifiers" becomes "a stable identifier where a disk has one".
   - Lands on: `WIR-40`, `RSC-26` first bullet, and `CONTEXT.md` (*Rescue inventory*: "reports its disks with
     stable identifiers").
10. **Missing citations (verified).** `RSC-46` says "`WIR-20` and `WIR-10b` cite this", but `13-wire-contract.md`
    has no `RSC-46` at `4c0bb4c`. Lands on: `WIR-20` and `WIR-10b`, each citing `RSC-46`.
11. **Lean (r61b 4-0): no new theorem.** The existing `resolves_only_the_named_disk` went red on every
    "null matches anything" plant. Update the docstrings that quote changed text:
    - `Rescue.lean` `Disk.Identifier` quotes "**stable identifiers** — serial and WWN" (`RSC-26` first bullet).
    - `Rescue.lean` `Disk.Inventory` says "two device sets do not share one". This is false once two same-sized
      anonymous disks hash alike.
    - `Witnesses.lean` `duplicateInventory` quotes "sorted by identifier".
12. **Test (r61b 4-0 on placement; r61d 4-0 on content).** New **`CNF-363`**, after `CNF-206`. `CNF-47`, `CNF-192`
    and `CNF-206` are unchanged. Use otherwise-admissible fixtures with unique chosen identifiers. It must assert:
    1. **Listing.** A has distinct WWN and serial; B has neither. Both are listed, and B's `identifier`, `wwn` and
       `serial` are all `null`. A shows both fields, and `identifier` = its WWN (WWN preference).
    2. **Fingerprint value.** It equals an independently computed `RSC-46` hash over both disks. Pick fixtures
       whose identifier order differs from the canonical-byte order.
    3. **Installs on A.** A `raw_disk` install naming A, and a `rootfs_via_rescue` install whose `layout.drives`
       names A, both resolve A and write nothing to B.
    4. **B changes.** Removing or resizing B between the inventory and the install aborts `integrity`, with no
       bytes written.
    5. **Empty values.** B's serial whitespace-only, or a bare `0x`/`0X`, is shown `null`. A WWN that normalizes
       to empty falls back to the serial.
    6. **Fields present.** Every device carries `path`, `wwn`, `serial` and `identifier`. Nothing asserts
       `name`.
    7. **Serial-only disk.** It shows its serial as `identifier` and `serial`, and an echo resolves it through
       both strategies.
    8. **`0x0XAB`.** A serial read as ` 0x0XAB ` is shown `0x0XAB` and hashed as `0xab`. Echoing `0x0XAB` (or
       `0X0xab`) resolves it. `0XAB`, `0xab` or `ab` matches nothing and aborts `integrity`. This catches
       stripping the prefix twice.
    9. **Order and paths.** Reordering the devices leaves the fingerprint unchanged. So does changing only paths.
    10. **Refused before enqueue.** `invalid_request`: a `null`, a non-string, an empty or whitespace-only string,
        or a bare `0x`/`0X`, in `target.identifier` or any `layout.drives[].identifier`.
    11. **No identifiers anywhere.** On a machine where no device has one, the inventory succeeds with all fields
        `null`, and any well-formed install aborts `integrity` with no write.
    12. **Identical anonymous devices.** Two of them both appear, and dropping one changes the fingerprint.
    13. **Whitespace on both strategies.** Padded echoes, and serials with whitespace inside them, resolve
        through both. The generated installer configuration carries only resolved paths.
    14. **Unmatched identifier.** A well-formed identifier that matches nothing aborts `integrity`, with no
        writes, through both strategies.

    Cite at least `WIR-10b`, `WIR-20`, `WIR-40`, `RSC-23`, `RSC-26`, `RSC-33`, `RSC-46`, `API-13`. `RSC-46`
    gets its first checklist citation, so lower the coverage ratchet (fable saw uncovered 76 → 75).

## Gate warnings for the drain instruction

- **Unquoted attributions fail the citation gate.** In r61c both fable's clone ("`WIR-10b` says which form…") and
  opus's clone ("normalized as `RSC-46` says") went red. Quote the sentence, or write a bare pointer.
- **A stale docstring quote fails the citation gate.** opus (r61b) and astra (r61c) proved it. That gate enforces
  item 11.
- **No gate checks `WIR-10b`'s inline example.** `tools/check_fixtures.py` reads fenced ```json blocks only.
  Readers planted three bad examples: `/dev/sda` in place of `null` (r61/r61b), an `identifier` not equal to its
  `serial` (opus r61c), and a `null` `identifier` beside a present serial (sol r61c). All three passed every gate.
  Only `CNF-363` would catch them, so the reviewers must read the example by hand.

## Not in this form (unreviewed or out of scope)

- astra and sol (r61c) would pin "ASCII whitespace" as U+0009–U+000D plus U+0020. Only two readers proposed it,
  and it changes a definition `RSC-46` already uses. A candidate bead if the term's ambiguity is judged
  behavioural.
- No reader proposed a gate that cross-checks the inline example. A check-strength bead is possible.
