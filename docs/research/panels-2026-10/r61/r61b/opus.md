I made C1–C7 in the clone with my picks, C5 (ii) and `CNF-363`, and the gates pass on that edit (exit 0). B's `null` replaced by `/dev/sda` still passes every gate; a stale Lean docstring quote fails the citations gate. The answer is 433 words and is also saved as `answer.txt`, with the edit as `clean.patch`.

**Q1**
- **C1: amend.** "Normalized" means lowercased, so the example's identifier must be lowercase (see Q2).
- **C2: amend.** Fix the order (see Q2), and say "ASCII-lowercased" so `CNF-363`'s hash can be reproduced.
- **C3: accept, bytes alone.** The hashed `{wwn, serial, size_bytes}` has no `identifier`, and elements that tie are identical.
- **C4: accept.** I drop my round-1 dissent. The `integrity` abort comes only after a reboot into rescue, and `RSC-38` says "`PRV-22` makes the exit *always* ambiguous".
- **C5: (ii).** I switched from (i).
  - Under C1, a WWN disk's serial never reaches the wire, yet `RSC-33` lists "serial".
  - Take A (WWN W, serial S) and B (serial S only). Their identifiers show as W and S, yet naming S matches two serials and aborts. Only a wire `serial` shows that in advance.
- **C6: `CNF-363`, amended.** It also refuses an empty `layout.drives[].identifier` and a bare `0x`.
- **C7: accept.** The Lean model already has `Device.identifier` as an `Option`, `Request.identifier` as not one, and `matching` filtering on `== some id`.

**Q2**
- C1 and C2 say "lowercased", but `WIR-10b` shows `"identifier": "S4EVNF0N123456"`.
- C2 lists "(trimmed, `0x` stripped, lowercased)", but `RSC-46` says "compared case-insensitively, and stripped of a leading `0x`". In C2's order, "0X5000" keeps its prefix.
- `RSC-46` says "`WIR-20` and `WIR-10b` cite this", but `13-wire-contract.md` had no `RSC-46` at `4c0bb4c`. I added the citation to both.
- `CONTEXT.md` says "reports its disks with stable identifiers". I amended it to "where a disk has one".
- Open: `RSC-23` says "no whitespace, CR, LF, or NUL in any config field". If an identifier counts as a config field, that refuses padding `RSC-46` trims.

**Q3**
- Clean edit, 7 files: exit 0.
- Plant A, B's `null` replaced by `"/dev/sda"`: exit 0, every gate passes.
- Plant B, a `Witnesses.lean` docstring left quoting "sorted by identifier": exit 1, citations FAIL.

So a gate enforces C7's docstrings, and only `CNF-363` guards the example.

**Q4** Incomplete: it hides the type widening, the fingerprint change and the C5 bracket. Rewrite:
> Some disks, mostly consumer or virtual, report no serial and no WWN. Today the inventory cannot show one.
> (a) **Recommended:** list such a disk with `identifier: null` and keep it in the fingerprint. No install can name it, and a blank identifier is refused before any reboot. Clients see `identifier` become string-or-null, a change `WIR-2`'s ignore-unknown-fields rule doesn't cover. They also gain `wwn` and `serial` fields, and fingerprints change.
> (b) Omit it: a swapped disk escapes the fingerprint.
> (c) Refuse inventory: the machine's other disks become uninstallable too.

**Q5 (written on request, against C5 (ii))** The bead asks only how to show a null, and `WIR-2` makes adding fields later free. (ii) widens the scope and still leaves `RSC-33`'s `name` off the wire, so it doesn't fully meet "`RSC-33`/`RSC-38` agree" either.
