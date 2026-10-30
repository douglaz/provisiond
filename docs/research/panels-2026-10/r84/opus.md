I've recorded a verdict on every printed form. I accept each form except Q2-D. My picks are **Q1-C, Q2-A and Q3-A**. I found no verified brief error, so rule 6 voids nothing.

**How I checked.** My clone is at `3109b5b44eae17e288cf52aaa976993bd8c5626c` and clean. Every quoted passage and line number in the brief matches the pinned files. A grep of `git diff 08191bb 3109b5b` over the owning files found no changed lines touching identifiers, RSC-46, SEC-29, API-13, CNF-200 or CNF-363. I recomputed the four vertical-tab fingerprints and every normalization and byte-count fixture with my own script (`tmp/opus/calc.py`, exit 0). All four SHA-256 values in the brief match exactly. No form changes a Lean declaration: `Rescue.lean:298` models an identifier as a natural number, `resolve` (`:351–357`) receives a request that was already admitted, and admission, normalization and length are not modelled. I ran no builds.

## Q1 — `pv-ez8`

| Form | Verdict |
|---|---|
| Q1-A | **ACCEPT** |
| Q1-B | **ACCEPT** |
| Q1-C | **ACCEPT** |

**Preferred: Q1-C.**

**Why C.** No form ever turns the caller's string into a device path, so a ban isn't needed to protect the write. Two things still make the narrow `/dev/` ban worth having:

1. **It stops a reboot that achieves nothing.** RSC-38 says entering rescue "means rebooting the machine into another operating system (`PRV-15`), and `PRV-22` makes the exit *always* ambiguous, so a failure can strand a customer's machine there with nothing serving" (`06-rescue-install.md:305–307`). Under A, a caller who pastes `/dev/sda` accepts that risk for an install that is certain to abort with `integrity`. `/dev/sda` is the exact form RSC-26 used to have callers name (`06:247–248`), so this is the most predictable mistake.
2. **It closes one way the wrong disk could be chosen.** Suppose disk X sits at `/dev/sda` and has the serial `/dev/sdb`, and disk Y sits at `/dev/sdb`. A caller who means "the disk at `/dev/sdb`" gets X under A, because the identifier wins. A's new case (14) makes resolving a `/dev/sda` serial a required conformance result. C refuses every value whose normalized form starts with `/dev/`. The check runs after lowercasing and after the one `0x` strip, so ` 0X/DeV/sda ` is caught, and it is caught on the same normalized form that matching uses.

**What C costs (a deliberate policy change, not an editorial fix).**
- It adds a new admission refusal.
- A disk whose every identifier normalizes to something starting with `/dev/` can no longer be targeted. The inventory still shows it and still hashes it, which the inserted paragraph keeps ("the inventory retains that value"). An install naming it gets `400` before enqueue rather than resolving.
- RSC-26 says an install "MUST carry both the chosen device's stable identifier and the `inventory_fingerprint`" (`06:258–259`). For such a disk that becomes impossible to satisfy. That isn't a contradiction: RSC-26 promises no echo guarantee, and duplicate identifiers already leave disks untargetable.
- RSC-26's per-offer strategy omission (`06:272–274`) doesn't account for identifiers that are present but refused, so such an offer can list a strategy that no install can use.
- No existing CNF verdict flips. I checked CNF-363 (1)–(13) and WIR fixtures `13-wire-contract.md:293–297, 720, 727`; none uses a `/` in an identifier.

**B's extra cost.** B refuses `/` anywhere, so it makes more legitimate values untargetable. What it adds over C (`a/b`, `dev/sda`, `disk/by-id/...`) is unlikely to be a real mistake. It is safe but over-broad, which is why it's accept-not-prefer.

**A** matches the pinned owners exactly. API-13 refuses only "a `null`, non-string or empty-after-normalization" value (`04:974`), and RSC-26 makes the integrity abort the outcome (`06:268–269`). It changes no policy.

**Requested counterargument (against C).** A prefix ban protects nothing on the write path, because "The identifier is authoritative; the path is derived" (`06:265–266`). C adds a reserved domain that both the API and the worker must keep. It refuses a value the service itself displayed. And it doesn't touch bare `sda` or `nvme0n1`, which still cost a rescue round trip. A is the only form that leaves every displayed identifier echoable.

**Blocking losses:** none for any form.

## Q2 — `pv-2j3`

| Form | Verdict |
|---|---|
| Q2-A | **ACCEPT** |
| Q2-B | **ACCEPT** |
| Q2-C | **ACCEPT** |
| Q2-D | **CANNOT ACCEPT** |

**Preferred: Q2-A** (1024 UTF-8 bytes before normalization).

**Why A.**
- No field cap can stop the service from receiving and parsing a long string; only the body cap does that. What a field cap actually decides is what gets admitted, stored in the record that OPS-23 re-checks, and compared. A bounds the field as received.
- WIR-1a requires a body to "be valid UTF-8" under I-JSON (`13:22–23`). That makes "the decoded value's UTF-8 encoding" well-defined: there are no lone surrogates.
- A also bounds the normalized value at 1024 or less, so C's extra 256 normalized cap brings no safety gain and only refuses more identifiers.
- B leaves the raw field limited only by the body: ~2 MiB of padding around `a` is admitted and stored. That is the plain-terms story left unaddressed, though B is coherent.

**Fixture arithmetic.** 512 × U+00E9 = 1024 bytes, plus `a` = 1025. 128 × U+00E9 = 256 bytes, plus `a` = 257. An escaped 1025-byte value is about 6.2 KB, well under the body cap. The boundary paragraphs in A, B and C are each consistent with their own row.

**Losses I'm disclosing, rather than treating the cap as free.**
- **A:** a disk whose trimmed displayed identifier is over 1024 bytes becomes untargetable (`400` before enqueue, where today it would resolve). A padded echo near the cap is also refused. CNF-363 (13), "Padded echoes … resolve" (`10:2322–2323`), would flip only if a tester picked a near-cap fixture. No verdict flips at ordinary fixture sizes.
- **B and C:** the same loss, but at more than 256 normalized bytes, so a wider band of displayed identifiers is lost.
- **A, B and C:** the inventory still returns long values untruncated, and RSC-26's anchor clause "Every disk reported … MUST remain in the inventory and in the fingerprint" (`06:255–256`) is kept.

**Are 1024 and 256 defensible?** Both are policy headroom, not provider maxima. 256 matches API-13's neighbouring identifier rows (`04:966, 970`). 1024 loses fewer echoes for a bound that is still trivial next to the body cap, so I prefer it.

**Why I can't accept D.**
- **Policy:** D leaves the identifier bounded only by the body, which is the gap `pv-2j3` was opened to close.
- **Owner claim:** D's sentence "This row is the explicit field-size exception for `SEC-29`" presumes SEC-29 requires a per-field cap. It then grants an exception that SEC-29's words don't provide. SEC-29 says "individual fields MUST be capped per `API-13`" (`07-security-requirements.md:280–281`). A non-owner granting exceptions to an owner's MUST is the second-copy drift AGENTS.md warns about.
- **Contestable:** this rests on reading SEC-29 as requiring a cap on every field. The other reading — SEC-29 just delegates to API-13 — is supported by API-13 already leaving `provider options` without a size (`04:972`).

**Requested counterargument (against A).** A's cap counts padding, so the same identity can be admitted or refused depending on whitespace the caller added. B caps exactly what RSC-46 compares. And 1024 has no provider evidence behind it either.

## Q3 — `pv-tbrs`

| Form | Verdict |
|---|---|
| Q3-A | **ACCEPT** |
| Q3-B | **ACCEPT** |

**Preferred: Q3-A** (trim U+0009–U+000D and U+0020).

**Fixture checks (independently computed, all hold).**
- **Q3-A:** vertical tab + `0XAb` + vertical tab shows on the wire as `0XAb` and normalizes to `ab`. Both the echo and `ab` resolve the disk. A vertical tab on its own is empty after normalization: shown `null` in inventory, refused when a caller sends it.
- **Q3-B:** the same value shows as `"\u000b0XAb\u000b"` and normalizes to `"\u000b0xab\u000b"`. The leading tab stops the `0x` from being stripped, so `ab` matches nothing. A vertical tab on its own is non-empty.
- **Other edge characters:** U+0008, U+000E, U+001F, U+007F and U+00A0 at the edges are kept under both forms and block the `0x` strip, e.g. `"\u00080xab\u0008"`.
- **Interior characters** are kept: `0X␋Ab` becomes `"\u000bab"`, and `0X Ab` becomes `" ab"`. Normalization never re-trims after the prefix strip.
- **Lowercasing before prefix removal** holds under both forms.
- **Both caller fields and both inventory fields** are covered. Neither form contradicts the existing null or prefix rules or CNF-363 (5), (8) and (10). For (8), I get ` 0x0XAB ` → `0xab`, and `0XAB` → `ab`, a non-match, as the case requires.
- **Fingerprints:** `8a7ab8eb…b72641`, `251725a8…b3fd82`, `00bf39db…336d60` and `f26dd8f1…04de5` all match the brief byte for byte.

**Why A.**
- U+0009–U+000D plus space is one contiguous, easily tested set. Carving vertical tab alone out of the control characters around it needs a reason that nothing in the pinned set supplies.
- Under A, a caller value made only of invisible characters is refused before enqueue. Under B, a lone vertical tab is admitted, then reboots the machine into rescue and aborts with `integrity`. That is the same pointless disruption as in Q1.
- Under A, an edge vertical tab collapses to the same normalized value as its plain neighbour. Any collision becomes a duplicate and aborts with `integrity`, which fails safe.

**Requested counterargument (against A).** This is background, not verified in the packet. B matches the most widely published meaning of the exact term "ASCII whitespace", which RSC-46 already pairs with "ASCII-lowercase": that's WHATWG Infra's definition and Rust's `is_ascii_whitespace`. So builders who implemented the pinned text that way stay conformant under B but not under A, and no real serial pads with a vertical tab.

**Non-blocking weakness in both forms.** The fingerprint-oracle sentence doesn't name its fixture value. A tester could hash a plain `ab` and never exercise the edge vertical tab in the hash. The wire and resolution assertions still distinguish the two rules.

**Blocking losses:** none. **Lost verdicts:** none. Whichever is chosen, builders using the other rule become non-conformant. That's the purpose of the change, and I'm disclosing it as a deliberate policy choice.

## Combinations

All 3 × 3 × 2 = 18 combinations of the forms I accept compose exactly as the brief lays them out:
- Q1-B/C insert a paragraph between the API-13 table and its note.
- Q2 replaces only the row.
- Q3 inserts into RSC-46.
- Each CNF-363 paragraph goes in the stated order.

Where they interact, the behaviour is defined:
- **Q1-C with Q3:** a vertical tab + `/dev/sda` is refused under Q3-A, but admitted and then aborted with `integrity` under Q3-B. Both are consistent.
- **Q2-B/C with Q3:** the normalized length depends on Q3's set. Q2's fixtures use only spaces, ASCII and é, so their outcomes don't change.

Q1-B/C and Q2's row both say "Worker repetition: `OPS-23`". The duplicate pointer is harmless.

**Brief errors:** none verified; I relied on no outside premise. Model identity played no part in these verdicts.
