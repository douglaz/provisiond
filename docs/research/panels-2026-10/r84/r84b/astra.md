My preferences for this consensus round are **Q1-C and Q3-E, exactly as printed**. I read the brief and notes whole, verified the clone at `3109b5b44eae17e288cf52aaa976993bd8c5626c`, checked the owning passages, and independently calculated the normalization cases and hashes. The worktree remains clean. No builds, writes, delegation or external research occurred.

**Q1 — acceptability and consensus preference**

| Unchanged form | Verdict |
|---|---|
| Q1-A | **ACCEPT** |
| Q1-B | **ACCEPT** |
| Q1-C | **ACCEPT — preferred** |

For this consensus round, I change the historical astra preference from A to **C**. The strongest reason is the operational consequence of admitting the recognizable `/dev/` mistake. RSC-38 says entering rescue “means rebooting the machine into another operating system” and that a failure can strand it “with nothing serving.” Avoiding that disruption justifies C’s narrowly specified restriction, provided its compatibility loss is acknowledged as policy. ([06-rescue-install.md:305](https://github.com/douglaz/provisiond/blob/3109b5b44eae17e288cf52aaa976993bd8c5626c/06-rescue-install.md#L305))

This does not establish that `/dev/` strings are intrinsically unsafe identities. RSC-26 says **“The identifier is authoritative; the path is derived.”** All printed forms retain that protection. ([06-rescue-install.md:264](https://github.com/douglaz/provisiond/blob/3109b5b44eae17e288cf52aaa976993bd8c5626c/06-rescue-install.md#L264))

The deliberate domain and echo effects are:

- **A:** introduces no new admission exclusion. An otherwise-admissible unmatched `/dev/sda` reaches rescue and aborts; a unique serial literally `/dev/sda` remains selectable. Its cost is permitting the disruptive unmatched request.
- **B:** rejects every caller value whose normalization contains `/`, including `a/b`, `/tmp/disk` and `/dev/sda`. Matching inventory values remain visible, but their echoes become inadmissible. If no admissible equivalent spelling or alternative identifier exists, the disk becomes unselectable.
- **C:** applies those losses only to normalized strings beginning `/dev/`. It preserves admission for `/tmp/disk` and `a/b`, including selection by a unique serial `a/b`. A serial `/dev/sda` is deliberately no longer selectable through its echo.

B remains acceptable as an explicit policy, but its broader exclusion has no demonstrated benefit sufficient to prefer it over C.

For B/C, the changed trace is substantive: a matching excluded identity moves from successful resolution to `400 invalid_request` before enqueue; an unmatched excluded identity moves from `202` followed by rescue-time `integrity` to immediate refusal. Inventory retention does not restore access to the excluded identity. Nor does the existing offer rule automatically remove such a strategy: RSC-26’s omission condition is **“where no per-device unique identifier is available at all for that offer”**; these examples still have a unique identifier. ([06-rescue-install.md:271](https://github.com/douglaz/provisiond/blob/3109b5b44eae17e288cf52aaa976993bd8c5626c/06-rescue-install.md#L271))

These are disclosed policy losses, not contradictions hidden in the remaining conformance fixtures. CNF-363 begins **“Use otherwise-admissible fixtures”** before its positive echo assertion, **“echoing it resolves that disk through both strategies.”** B/C narrow that admissible domain explicitly. ([10-conformance-checklist.md:2295](https://github.com/douglaz/provisiond/blob/3109b5b44eae17e288cf52aaa976993bd8c5626c/10-conformance-checklist.md#L2295))

The printed worker checks also have an existing owner: OPS-23 says validation **“MUST be repeated in the worker before the driver is called,”** and its present-but-invalid clause applies the caller-field outcome, `invalid_request` with `retryable: false`. Its install settlement explicitly gives `disk_effect: "none"` and `rescue_exit: "none"`. ([03-operation-lifecycle.md:2018](https://github.com/douglaz/provisiond/blob/3109b5b44eae17e288cf52aaa976993bd8c5626c/03-operation-lifecycle.md#L2018))

**Requested counterargument:** A preserves opaque identity semantics without reserving an OS-specific prefix. C refuses something the inventory itself displayed, can make a uniquely identified disk inaccessible, and still allows other mistaken strings to trigger rescue. This remains the strongest argument for A. It does not change my present preference: the narrowly bounded disruption prevention is worth C’s explicitly printed loss. I assume no undocumented serial grammar or provider compatibility guarantee.

**Final: Q1-C, unchanged.** Its strongest argument is avoiding rescue entry for this exact normalized prefix while retaining other slash-containing identities. Acceptance includes the deliberate `/dev/` echo loss; it does not imply that all mistaken device references are caught.

**Q3 — acceptability and consensus preference**

| Unchanged form | Verdict |
|---|---|
| Q3-A | **CANNOT ACCEPT** |
| Q3-B | **CANNOT ACCEPT** |
| Q3-E | **ACCEPT — preferred** |

A/B’s trimming policies are coherent. Their unchanged fingerprint-test sentence is the blocker. Both instruct the tester to construct:

> each normalized `{wwn, serial, size_bytes}` element, its RFC 8785 canonical bytes and SHA-256

The grammatical referent of “its” is the **element**. RSC-46 instead says:

> The `inventory_fingerprint` is SHA-256 over the RFC 8785 canonical JSON of the device list

([06-rescue-install.md:321](https://github.com/douglaz/provisiond/blob/3109b5b44eae17e288cf52aaa976993bd8c5626c/06-rescue-install.md#L321))

The complete failure trace is:

1. Choose a permitted serial-only one-disk report, size 1024, whose normalized serial is `ab`.
2. The owner requires these canonical list bytes:

   ```text
   [{"serial":"ab","size_bytes":1024,"wwn":null}]
   ```

   Their independently recomputed SHA-256 is:

   ```text
   8a7ab8eb85404e4ef4022bdf6f1cfc768b029d7f68271f0f60c931d494b72641
   ```

3. A/B’s element bytes are:

   ```text
   {"serial":"ab","size_bytes":1024,"wwn":null}
   ```

   Their independently recomputed SHA-256 is:

   ```text
   b2fa45b2bdac148628b4ec507afb927aafd8d8c51a5389e5a1a35a8d117bbc05
   ```

4. A conforming implementation returning the list digest fails the printed element-digest comparison. An implementation returning the element digest could pass that new assertion while violating RSC-46.

That is an **unintended changed conformance verdict**, not a trimming-policy choice. Calling the surrounding report “one-disk” does not insert array brackets into the instructed hash input. Accepting A/B by silently supplying those brackets would accept a different form.

E supplies the exact repair: **“canonical bytes of that list, including its enclosing array brackets”**, followed by SHA-256 and comparison to the lowercase hexadecimal fingerprint. I accept E whole without additional wording.

**Exact fixture scope.** E does not specify which identifier value the separate serial-only and WWN-only one-disk reports must contain. Consequently, I do **not** read it as mandating a separate list-hash test for every preceding character, or specifically for vertical tab. A tester could choose plain `ab` there.

That limitation does not block E. Its preceding sentences explicitly prescribe the boundary behavior, including the **“normalized hash value”** for each trimming-set member; its separate sentence prescribes an independent list-digest test. Both obligations are sufficiently specified to execute. Requiring their complete cross-product would be an additional coverage requirement. Notes rule 3 says **“An absent new runtime test alone is not a contradiction.”** My acceptance contains no hidden requirement to use a particular value in that separate test.

My deterministic checks confirm:

- **A/E trimming set:** each printed trimming character surrounding `0XAb` produces wire value `0XAb` and normalized value `ab`. The character alone normalizes to absence.
- **B’s U+000B distinction:** vertical-tab-wrapped `0XAb` remains wrapped on the wire and normalizes to `\u000b0xab\u000b`. Its echo matches; `ab` does not. U+000B alone remains non-empty.
- **Printed excluded neighbors:** U+0008, U+000E, U+001F, U+007F and U+00A0 remain at the edges and prevent removal of a later, non-leading `0x`.
- **Interior preservation:** tested interior characters survive. For example, `0X` + U+000B + `Ab` normalizes to U+000B + `ab`, including under E. There is no second trimming pass.
- **Prefix order:** ` 0x0XAB ` normalizes to `0xab`, retaining the second prefix. Bare `0X` normalizes to absence.
- **Wire/null distinction:** wire values retain their trimmed as-read spelling unless full normalization leaves nothing; normalized comparison/hash values additionally undergo ASCII folding and one-prefix removal.

These checks follow RSC-46’s exact order, **“trim ASCII whitespace, ASCII-lowercase, then strip exactly one leading `0x`,”** and its wire rule, **“strings as read, trimmed of ASCII whitespace, or `null` where normalization leaves nothing.”** ([06-rescue-install.md:314](https://github.com/douglaz/provisiond/blob/3109b5b44eae17e288cf52aaa976993bd8c5626c/06-rescue-install.md#L314))

I independently reproduced the supplied serial-only and WWN-only list digests under both trim policies, using explicit character sets and no engine helpers. Those successful calculations establish the list results; they do not repair A/B’s wording.

**Requested counterargument:** E’s inclusion of U+000B can erase meaningful edge content, collapse otherwise distinct identities, or turn a vertical-tab-only identity into absence. B preserves those distinctions. Conversely, B requires exact retained-content echoes and produces different fingerprints. These are deliberate policy differences; no supplied provider fact or library convention settles them. I prefer E’s contiguous trimming range, while retaining the ordinary ambiguity refusal: RSC-26 says **“An identifier that does not resolve to exactly one device MUST abort `integrity` before any write.”** ([06-rescue-install.md:268](https://github.com/douglaz/provisiond/blob/3109b5b44eae17e288cf52aaa976993bd8c5626c/06-rescue-install.md#L268))

**Final: Q3-E, unchanged.** It preserves A’s explicit trimming policy while making the hash test agree exactly with the owner. Acceptance does not silently expand the separate one-disk fixture’s value coverage.

**Composition and rule 6**

I reviewed **Q1-C + Q3-E** with the printed Q2-A material solely as composition context. Their insertion locations do not overlap. Under E, vertical-tab padding is removed before C’s prefix predicate; thus vertical-tab-wrapped `/dev/sda` is refused. The printed Q2 boundary values do not acquire a `/dev/` prefix. This is no Q2 vote or assumption of adoption.

The inspected formal resolution model abstracts identifiers and fingerprints as natural numbers; its `resolve` definition checks fingerprint equality and match multiplicity. These string-policy choices require no weakening of those inspected declarations. No build or gate result is claimed.

Applying notes rule 6 exactly: **I found no verified premise-changing brief error.** The A/B element-versus-list defect is an **other brief error**, already exposed by this round’s packet; my Q3-A and Q3-B rejections rest on it. The unspecified separate hash-fixture value is a disclosed coverage limitation, not a further blocking error. I declare no tally void and make no settlement or adoption claim.