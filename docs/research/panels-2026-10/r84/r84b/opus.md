I've changed one vote from the last round. On Q3 I now prefer **E**, not A, because I'd missed a defect in the printed Q3-A and Q3-B. On Q1 I still prefer **C**, and I still accept A and B.

**What I checked.** My clone is at `3109b5b44eae17e288cf52aaa976993bd8c5626c` and clean. Every pinned passage I relied on matches its file and line. I recomputed the fixtures with my own script (`tmp/opus/calc.py`, exit 0), without using any engine code. It covered normalization under both trim sets, wire values, interior characters, the existing case (8) and all element and list digests. I ran no builds and wrote nothing outside `tmp/opus`.

## Q1 — `pv-ez8`

| Form | Verdict |
|---|---|
| Q1-A | **ACCEPT** |
| Q1-B | **ACCEPT** |
| Q1-C | **ACCEPT** (preferred) |

**My fixture checks agree with all three forms:**
- ` 0X/DeV/sda ` normalizes to `/dev/sda`, which B and C refuse.
- `/tmp/disk` and `a/b` are admitted under C and refused under B.
- `not-a-disk` is admitted under all three.
- Under A, an unmatched `/dev/sda` gets `202` and then `integrity`. A unique serial that is literally `/dev/sda` resolves by identity.
- For the saved-request injection in B and C: OPS-23 says "A field that is present but fails this repeated validation fails as its writer's bullet above says". The caller bullet gives `invalid_request` with `retryable: false`. Lines 03:2045–2046 settle the install with `disk_effect: "none"` and `rescue_exit: "none"`.

**Why I still prefer C**

1. **C catches the mistake a caller is most likely to make.** The inventory prints each device's path right next to its identifier. WIR-10b's example has `"path": "/dev/nvme0n1"` beside `identifier` (13:294), and CNF-363 (6) requires "every device carries `path`" (10:2309).
   - Under A, pasting that path into the identifier field gets `202`. It then costs a reboot: RSC-38 says "entering rescue means rebooting the machine into another operating system (`PRV-15`), and `PRV-22` makes the exit *always* ambiguous" (06:305–306).
   - The caller then gets `integrity`, whose meaning is "Digest or host-key verification failed" (01:590). C instead returns `invalid_request`, "Caller error, deterministic" (01:581), before any reboot.
2. **The two forms fail differently in the rare case.**
   - C's rare failure: a disk whose identifiers all start with `/dev/` gets a safe `400`.
   - A's rare failure: disk X is at `/dev/sda` and its serial is `/dev/sdb`. Disk Y is at `/dev/sdb`. A caller who pastes Y's path resolves X uniquely, the fingerprint still matches, and X is written.
   - That is the harm RSC-26 opens with. A's case (14) makes the behaviour behind it, a serial literally `/dev/sda` resolving, a required result.
3. **C enforces a sentence that already exists.** WIR-20 says the identifier is "a drive serial or WWN … — **not a device path**" (13:730). C enforces that for the spelling the service itself prints as a path.

**Why B is accept, not prefer.** B also refuses `a/b`, `dev/sda` and similar values. That is a wider loss than C's with no matching benefit, and it adds no safety, since `/dev/sda` is refused under both.

**What each form deliberately gives up.** These are intended policy, not blocking losses.
- **A:** nothing in the admission domain. It accepts a pointless rescue reboot for `/dev/`-path mistakes, and it accepts the wrong-disk case in point 2.
- **C:** a caller can no longer send a value whose normalized form starts with `/dev/`. The inventory still shows and hashes it ("the inventory retains that value").
  - RSC-26 says "An install request MUST carry both the chosen device's stable identifier and the `inventory_fingerprint`" (06:259). For a disk with no other identifier, that becomes impossible to satisfy.
  - RSC-26's per-offer strategy omission (06:272–274) can't see this, because a unique identifier exists.
- **B:** the same losses as C, for any `/` anywhere in the normalized value.

**No existing verdict flips.** CNF-363 cases (1)–(13) and the WIR fixtures (`S4EVNF0N123456`, `eui.002538b111223344`) contain no `/`. CNF-363 is already limited to "otherwise-admissible fixtures" (10:2295).

The only shared loss is CNF-200's phrase "exactly as raw-disk does". Parity survives through CNF-363 (14)'s "In each caller identifier field" (B, C) and "both strategies" (A).

**Interaction with Q3.** Under E's trim set, a vertical tab + `/dev/sda` normalizes to `/dev/sda`, so C refuses it. Under B's trim set it is admitted and then aborts with `integrity`. Both follow the printed rules.

**Strongest argument for A, and why it doesn't move me.** A keeps the identifier an opaque string, and every identifier the inventory displays stays sendable. C reserves part of the string space by how it's spelled, and the per-offer omission can't detect a disk that has become unreachable as a result.

That is real, and it's why I accept A. It doesn't change my preference. The rarity that makes a `/dev/`-prefixed serial unlikely also makes C's loss small, and C's failure is a refusal with no reboot. A's matching rare failure writes to the wrong disk. If A gets enough preferences to settle, I don't block it.

**Requested counterargument (not a vote).** C covers only one spelling of a path. Bare `sda`, `nvme0n1` or a by-id basename still cost a rescue round trip under C. So C buys less reboot avoidance than its framing suggests, in exchange for a permanent reserved prefix in an identifier space that is otherwise opaque.

**Blocking losses for Q1:** none for any form.

**Final: Q1-C.** It is the narrowest admission restriction that refuses the inventory's own path spelling before rescue. Condition: it is a deliberate new admission refusal, and should be recorded as policy.

## Q3 — `pv-tbrs`

| Form | Verdict |
|---|---|
| Q3-A | **CAN ACCEPT WITH THIS EXACT FIX:** the fix is Q3-E, a separate form. I cannot accept A as printed. |
| Q3-B | **CAN ACCEPT WITH THIS EXACT FIX:** Q3-B′, defined below. I cannot accept B as printed. |
| Q3-E | **ACCEPT** (preferred) |

**I'm correcting my previous vote.** Last round I accepted A. I treated its fingerprint sentence's only weakness as not naming the fixture value. Astra's objection is correct, and I missed it.

**The defect in A and B as printed.** Their oracle sentence is: "independently construct each normalized `{wwn, serial, size_bytes}` element, its RFC 8785 canonical bytes and SHA-256, and assert the fingerprint against those expected bytes and digest".
- The only noun "its" can refer to is "element". So the expected digest is SHA-256 of the element's bytes.
- RSC-46 says "The `inventory_fingerprint` is SHA-256 over the RFC 8785 canonical JSON of the device list" (06:321). CNF-363 (2) uses the same oracle (10:2303).
- My recomputed digests:

| Report | Correct (list bytes) | Literal reading (element bytes) |
|---|---|---|
| Serial-only | `8a7ab8eb…b72641` | `b2fa45b2…7bbc05` |
| WWN-only | `251725a8…b3fd82` | `6ecdd543…36c457` |

- So under the literal reading, a conformant engine fails the new assertion. An engine that hashes the bare element of a one-device inventory passes it.
- That is a new conformance assertion contradicting its owner, which counts as a blocking loss under rule 3. It is a drafting defect, not intended policy.
- Separately, "assert the fingerprint against those expected bytes" compares a 64-character hex string with canonical bytes, which isn't a defined comparison.

Reading "its" as "the list" would be the unstated repair the brief forbids.

**E is A with only that sentence fixed.** A word-level diff of A against E changes nothing but the oracle sentence. Both inserts are otherwise identical, including the RSC-46 definition.

E's sentence names "the normalized one-element device list", its canonical bytes "including its enclosing array brackets", and SHA-256 "over those list bytes". It then compares the digest "encoded as 64 lowercase hex characters", which matches RSC-46's wire form.

**My checks on E, all of which hold:**
- **Trimmed characters:** for each of U+0009 through U+000D and U+0020, `0XAb` surrounded by that character gives wire value `0XAb` and normalized value `ab`. A value made only of that character is absent: shown `null` in the inventory, refused when a caller sends it.
- **Retained neighbours:** U+0008, U+000E, U+001F, U+007F and U+00A0 at the edges are kept and block the `0x` strip (for example, U+0008 + `0xab` + U+0008).
- **Interior characters:** kept. `0X`+VT+`Ab` normalizes to VT+`ab`, with no re-trim after the prefix strip.
- **Order:** lowercasing comes before prefix removal. ` 0x0XAB ` still gives wire `0x0XAB` and hash `0xab`, as case (8) requires.
- **Scope:** both caller fields and both inventory fields are covered, matching the `null` rules in API-13's row and RSC-46.
- **Independence:** the reference is barred from using the engine's trim, normalization, serialization and fingerprint helpers.

**Does the text name the fixture value?** Fable and I raised this last round. I find the full text sufficient. The per-character sentence asserts "the normalized hash value is `ab`" for every listed character, including U+000B. The fingerprint is the only place that hash value can be observed, and E's sentence says how to build the expected digest.
- Under E's trim set, all six surrounded fixtures have the same expected list bytes.
- An engine that keeps U+000B would produce `00bf39db…336d60` or `f26dd8f1…504de5`, and fails that assertion.
- So the unnamed value can't let the wrong rule pass. Nothing has to be invented to reach that reading.

**Q3-B′ (exact fix).** Take Q3-B unchanged, except in its CNF-363 paragraph. There, replace the span from "independently construct each normalized" through "those expected bytes and digest." with E's span, verbatim, from "independently construct the normalized one-element device list" through "encoded as 64 lowercase hex characters.".

I accept B's trim set as policy; only its oracle sentence blocks it. One non-blocking weakness remains in B and B′: neither states the hash value for the U+000B fixture. Under B, that case is told apart only through the wire value and resolution, which rule 3 does not treat as a contradiction.

**Why E.** Four of the previous readers chose A's trim set: fable, sol and I preferred A, and astra's E uses the same set. E keeps that set exactly and changes only the sentence that, read literally, contradicts RSC-46. Anyone who preferred A's policy loses nothing by moving to E.

**Policy cost of E,** shared with A and disclosed rather than blocking: a serial whose only distinguishing feature is a vertical tab at the edge now matches its plain neighbour. Any collision becomes a duplicate and aborts with `integrity`, which fails safe.

**Requested counterargument (not a vote).** This is background, not verified in the packet. The widely published meaning of "ASCII whitespace" (WHATWG Infra, and a mainstream standard-library check of the same name) excludes U+000B. An implementer who calls that function would diverge from E on the one fixture that tells the two rules apart. B′ keeps the term and the common predicate aligned.

**Final: Q3-E.** It has A's trim set and a fingerprint oracle that matches RSC-46's "SHA-256 over the RFC 8785 canonical JSON of the device list". It is the only printed Q3 form with no verified blocking defect.

## Composition, Lean and rule 6

- **Composition:** C, Q2-A (context only) and E fit together.
  - C's paragraph goes after the API-13 table.
  - Q2-A replaces only the API-13 row.
  - E inserts into RSC-46 before "Before comparison,", and adds its CNF-363 paragraph after the size paragraph.
  - No Q2 or E fixture normalizes to anything beginning with `/dev/`.
- **Lean:** nothing changes. `Identifier` and `fingerprint` are natural numbers (`Rescue.lean:298, 316–319`), and `resolve` doesn't model admission, normalization or hashing.
- **Rule 6:** I found no premise-changing brief error, and no other brief error. The Q3 element-versus-list problem is a defect in the candidate text, which the brief prints faithfully and flags. My move from A to E rests on that defect, which I verified with the digests above.
