My final preferences are **Q1-A, Q2-A, and the complete Q3 alternative E below**. Acceptance is separate:

| Question | Exact form | Verdict |
|---|---|---|
| Q1 | A | **ACCEPT — preferred** |
| Q1 | B | **ACCEPT** |
| Q1 | C | **ACCEPT** |
| Q2 | A | **ACCEPT — preferred** |
| Q2 | B | **ACCEPT** |
| Q2 | C | **ACCEPT** |
| Q2 | D | **ACCEPT** |
| Q3 | A | **CANNOT ACCEPT** |
| Q3 | B | **CANNOT ACCEPT** |
| Q3 | E, supplied below | **ACCEPT — preferred** |

I read the brief and notes whole, verified the pin and relevant source passages, and independently calculated normalization boundaries, UTF-8 lengths and fingerprints. No builds, edits, tracker changes or delegated work occurred. The final working tree is clean.

**Q1: prefer A; accept the printed policy restrictions in B and C.**

An admission ban is unnecessary for preventing caller-controlled device-path selection. RSC-26 says, **“The identifier is authoritative; the path is derived.”** It separately requires **“An identifier that does not resolve to exactly one device MUST abort `integrity` before any write.”** ([06-rescue-install.md:264](https://github.com/douglaz/provisiond/blob/3109b5b44eae17e288cf52aaa976993bd8c5626c/06-rescue-install.md#L264), [line 268](https://github.com/douglaz/provisiond/blob/3109b5b44eae17e288cf52aaa976993bd8c5626c/06-rescue-install.md#L268))

A preserves that distinction and tests both relevant cases: an unmatched `/dev/sda` fails during resolution; a unique serial literally equal to `/dev/sda` resolves by identity. Its generated configuration must use the resolved path. This is preferable to inferring a serial’s meaning from its spelling.

B and C are acceptable **substantive admission restrictions**, with these collateral flips:

- **B:** a unique serial containing `/`, including `a/b`, becomes unusable through its exact echo. An unmatched slash-containing input changes from admission followed by resolution failure to `400 invalid_request` before enqueue.
- **C:** those flips apply only when normalization produces the `/dev/` prefix. `a/b` and `/tmp/disk` remain admissible.
- For either restriction, if the disk has no alternative admissible identifier, the caller loses the ability to select it despite its retained inventory identity.

These losses are explicit in the proposed owner paragraphs, not hidden changes to resolution. Neither restriction establishes that all mistaken device-path inputs will be caught.

**Requested counterargument:** A permits a recognizable mistake to interrupt the installed OS. RSC-38 explicitly says **“entering rescue means rebooting the machine into another operating system”** ([06-rescue-install.md:305](https://github.com/douglaz/provisiond/blob/3109b5b44eae17e288cf52aaa976993bd8c5626c/06-rescue-install.md#L305)). B or C avoids that disruption for its rejected domain. That operational benefit is real even though no destructive write occurs.

I found no additional blocking loss in Q1’s exact forms.

**Q2: prefer A’s exact 1024 decoded UTF-8 bytes before normalization.**

| Form | Gain | Deliberate loss or remaining exposure |
|---|---|---|
| A | Bounds admitted caller values, including padding, with one field limit. | Exact inventory echoes exceeding 1024 decoded UTF-8 bytes fail, even when normalization would make them short. |
| B | Bounds normalized matching keys to 256 UTF-8 bytes. | Longer normalized identities cannot be submitted; padding remains bounded only by the body cap. |
| C | Bounds both admitted raw values and normalized keys. | Combines A’s padding/echo exclusions with B’s narrower identity domain. |
| D | Preserves the broadest length admission domain and makes the exception explicit. | Supplies no independent disk-field resource budget; long stored caller values and padding remain possible within the body cap. |

A’s 1024 is defensible as a **chosen service budget**, not as a provider compatibility guarantee. The same distinction makes 256 defensible as a policy choice, but I see no supplied reason to prefer its additional exclusion of normalized identities between 257 and 1024 bytes. A already bounds those matching keys indirectly because the specified normalization cannot increase UTF-8 length.

A field cap does not guarantee that receiving or JSON-parsing an oversized value is avoided: enforcement occurs on the decoded value. Its dependable benefit is limiting values admitted for subsequent storage and processing.

Inventory output remains untruncated under every form. Exact echo failure does not invariably make a disk inaccessible: an alternative admissible identity or equivalent spelling may exist. Where none exists, the new cap makes that disk unselectable.

The retained conformance cases remain satisfiable. CNF-363 scopes them to **“otherwise-admissible fixtures”**, while case (7) checks **“echoing it resolves that disk through both strategies.”** ([10-conformance-checklist.md:2295](https://github.com/douglaz/provisiond/blob/3109b5b44eae17e288cf52aaa976993bd8c5626c/10-conformance-checklist.md#L2295), [line 2310](https://github.com/douglaz/provisiond/blob/3109b5b44eae17e288cf52aaa976993bd8c5626c/10-conformance-checklist.md#L2310)) The new restrictions narrow which echoes qualify; that compatibility loss should be recorded explicitly.

D deliberately resolves the field-cap ambiguity through the owning row. SEC-29 says fields **“MUST be capped per `API-13`”** ([07-security-requirements.md:280](https://github.com/douglaz/provisiond/blob/3109b5b44eae17e288cf52aaa976993bd8c5626c/07-security-requirements.md#L280)); D explicitly makes body-only treatment the rule for this field. I accept that printed exception without treating it as equivalent to a separate cap.

The multibyte and padding boundaries calculate correctly. Worker rejection fixtures also agree with OPS-23’s **“Validation that was performed at the API boundary MUST be repeated in the worker before the driver is called”** and its caller-field outcome **“`invalid_request` naming the field, with `retryable: false`.”** ([03-operation-lifecycle.md:2018](https://github.com/douglaz/provisiond/blob/3109b5b44eae17e288cf52aaa976993bd8c5626c/03-operation-lifecycle.md#L2018), [line 2030](https://github.com/douglaz/provisiond/blob/3109b5b44eae17e288cf52aaa976993bd8c5626c/03-operation-lifecycle.md#L2030))

**Requested counterargument:** Nothing supplied establishes that 1024 admits every legitimate provider serial. D avoids introducing this particular compatibility break, and the global body limit already bounds ordinary submitted requests. A’s operational benefit must justify rejecting some otherwise valid identities and padded echoes.

I found no additional blocking loss in Q2’s exact forms.

**Q3: both trimming policies work, but both exact checklist insertions have a fingerprint-oracle defect.**

Both candidates instruct the reference to construct:

> each normalized `{wwn, serial, size_bytes}` element, its RFC 8785 canonical bytes and SHA-256, and assert the fingerprint against those expected bytes and digest.

That literally selects the **element’s** canonical bytes and digest. RSC-46 instead specifies:

> The `inventory_fingerprint` is SHA-256 over the RFC 8785 canonical JSON of the device list

([06-rescue-install.md:321](https://github.com/douglaz/provisiond/blob/3109b5b44eae17e288cf52aaa976993bd8c5626c/06-rescue-install.md#L321))

The distinction changes the checked verdict. For A’s serial-only fixture:

```text
Required list:
[{"serial":"ab","size_bytes":1024,"wwn":null}]
SHA-256:
8a7ab8eb85404e4ef4022bdf6f1cfc768b029d7f68271f0f60c931d494b72641

Individual element:
{"serial":"ab","size_bytes":1024,"wwn":null}
SHA-256:
b2fa45b2bdac148628b4ec507afb927aafd8d8c51a5389e5a1a35a8d117bbc05
```

I independently reproduced every supplied vertical-tab **list** digest. Those calculations are correct; they do not repair the exact proposed checklist text. Reading “its” generously as the enclosing list would require an unstated repair. I therefore cannot accept either printed form unchanged.

Otherwise, the boundary fixtures are internally consistent:

- A trims U+000B; B retains it. Under B, U+000B alone remains non-empty and the wrapped serial normalizes to `"\u000b0xab\u000b"`.
- Both preserve the printed neighboring excluded characters and all tested interior occurrences.
- ASCII case folding precedes removal of one leading `0x`; retained leading controls prevent that removal.
- Trimmed wire strings preserve case, while comparison/hash values undergo full normalization.
- The checks cover both caller fields and both inventory identity fields.

These outcomes follow RSC-46’s **“trim ASCII whitespace, ASCII-lowercase, then strip exactly one leading `0x`”** and **“A value that is empty after normalization is absent and matches nothing.”** ([06-rescue-install.md:314](https://github.com/douglaz/provisiond/blob/3109b5b44eae17e288cf52aaa976993bd8c5626c/06-rescue-install.md#L314))

**Requested counterargument:** Choosing A’s trimming set can collapse identities distinguished only by edge U+000B. B preserves that distinction and permits an identity consisting solely of that character. No supplied provider evidence proves either choice universally preferable.

**Complete exact alternative Q3-E**

Insert in RSC-46 immediately after its bold heading and before “Before comparison,”:

```text
Here ASCII whitespace means exactly U+0009, U+000A, U+000B, U+000C, U+000D and U+0020;
trimming removes only a maximal prefix and suffix of those code points, never interior
characters or any other code point. This definition applies to normalization and to
trimming the as-read wire values in this requirement.
```

Insert in CNF-363 after its numbered cases and the selected size paragraph, before its final owner-reference line:

```text
      **Whitespace boundaries.** Apply `RSC-46`'s exact trimming set to the caller
      fields and to both inventory WWN and serial. For each of U+0009, U+000A,
      U+000B, U+000C, U+000D and U+0020, independently surround `0XAb` with that
      character: the as-read wire value is `0XAb`, the normalized hash value is
      `ab`, and both its wire echo and `ab` resolve the unique disk under both
      install strategies. A caller value consisting only of that character is
      refused `invalid_request` before enqueue; an inventory value consisting
      only of it is absent and shown `null`. U+0008, U+000E, U+001F, U+007F and
      U+00A0 at the edges are retained on the wire and in normalized values;
      their presence prevents stripping a later `0x` that is not leading.
      Interior occurrences of every tested character are preserved. Separately
      test serial-only and WWN-only one-disk reports, `size_bytes: 1024`:
      independently construct the normalized one-element device list, whose
      element is exactly `{wwn, serial, size_bytes}`, and the RFC 8785 canonical
      bytes of that list, including its enclosing array brackets. Compute
      SHA-256 over those list bytes and assert that `inventory_fingerprint`
      equals the digest encoded as 64 lowercase hex characters. The reference
      must not call the engine's trim, normalization, serialization or
      fingerprint helpers. (`RSC-46`, `API-13`)
```

Everything else remains pinned.

**Composition, formal scope and rule 6**

My exact acceptable combinations are:

```text
Q1 ∈ {A, B, C}
Q2 ∈ {A, B, C, D}
Q3 = E as printed above
```

The preferred combination is **A / A / E**. The positive fixtures can satisfy each selected admission domain, and E changes neither Q1 nor Q2 text.

No Lean change is necessary. The pinned model uses `Identifier.n : Nat` and `Inventory.fingerprint : Nat`; its resolution definition and named abort theorems do not encode these string-domain choices. The candidates preserve the modeled resolution rule, whose owner says **“An identifier that does not resolve to exactly one device MUST abort `integrity` before any write.”** ([Rescue.lean:295](https://github.com/douglaz/provisiond/blob/3109b5b44eae17e288cf52aaa976993bd8c5626c/tools/formal/Provisiond/Rescue.lean#L295), [line 345](https://github.com/douglaz/provisiond/blob/3109b5b44eae17e288cf52aaa976993bd8c5626c/tools/formal/Provisiond/Rescue.lean#L345))

Applying notes.md rule 6 exactly: the Q3 candidate-oracle error does **not** change the question’s premise that the trimming set is unspecified. It is an “other brief error”; both of my Q3 printed-form rejections rest on it. I identify no premise-changing brief error and do not declare a tally void or conduct a tally.