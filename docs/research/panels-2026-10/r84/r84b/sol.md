My final preferences are **Q1-A and Q3-E, exactly as printed**. I revise my earlier Q3-A/B acceptances because their exact hash-oracle sentence selects the element’s digest.

I read notes.md whole, verified pin `3109b5b44eae17e288cf52aaa976993bd8c5626c`, checked the owning passages, and ran independent deterministic calculations. The worktree is clean. No builds, source changes, tracker actions or delegation occurred. Q2 receives no new vote.

**Q1**

| Unchanged form | Verdict |
|---|---|
| A | **ACCEPT — preferred** |
| B | **ACCEPT** |
| C | **ACCEPT** |

A gives a precise test of identity resolution while preserving the admission domain. The controlling distinction is RSC-26’s **“The identifier is authoritative; the path is derived.”** Its failure rule is **“An identifier that does not resolve to exactly one device MUST abort `integrity` before any write.”** ([RSC-26](https://github.com/douglaz/provisiond/blob/3109b5b44eae17e288cf52aaa976993bd8c5626c/06-rescue-install.md#L265))

A exercises the relevant outcomes separately: unmatched `/dev/sda` is admitted and subsequently fails resolution; a unique serial literally equal to `/dev/sda` resolves by identity. The generated installer configuration uses the resolved device’s path.

The deliberate domain and echo losses are:

| Form | Deliberate change |
|---|---|
| A | No new input-domain or identity-echo exclusion. An unmatched `/dev/sda` can cause rescue entry before its integrity failure. |
| B | Every caller value whose normalization contains `/` becomes inadmissible, including an echo of a unique serial `a/b`. |
| C | Every caller value whose normalization starts `/dev/` becomes inadmissible, including an echo of a unique serial `/dev/sda`. `/tmp/disk` and `a/b` remain admissible. |

For B or C, a disk with no alternative admissible identifier becomes unselectable despite remaining visible in inventory. These are substantive, expressly printed policy changes. They also change unmatched inputs in the excluded domain from admission followed by resolution failure to pre-enqueue `400 invalid_request`.

I find no contradictory remaining positive fixture. CNF-363 expressly scopes its cases with **“Use otherwise-admissible fixtures”**, while its serial-only case says **“echoing it resolves that disk through both strategies.”** B and C narrow the qualifying fixture domain; that compatibility loss must remain disclosed. ([CNF-363 setup](https://github.com/douglaz/provisiond/blob/3109b5b44eae17e288cf52aaa976993bd8c5626c/10-conformance-checklist.md#L2295), [serial-only case](https://github.com/douglaz/provisiond/blob/3109b5b44eae17e288cf52aaa976993bd8c5626c/10-conformance-checklist.md#L2310))

The saved-request refusals in B/C also have pinned owner support. OPS-23 says **“A field that is present but fails this repeated validation fails as its writer’s bullet above says”**; its caller-field bullet specifies **“`invalid_request` naming the field, with `retryable: false`”**, and validation precedes the install markers. ([OPS-23](https://github.com/douglaz/provisiond/blob/3109b5b44eae17e288cf52aaa976993bd8c5626c/03-operation-lifecycle.md#L2018))

The strongest counterargument against A is operational disruption. RSC-38 says **“entering rescue means rebooting the machine into another operating system”** and describes how a failure **“can strand a customer's machine there with nothing serving.”** C prevents that disruption for the recognizable `/dev/` mistake. ([RSC-38](https://github.com/douglaz/provisiond/blob/3109b5b44eae17e288cf52aaa976993bd8c5626c/06-rescue-install.md#L304))

That benefit makes C acceptable, but does not change my preference. I prefer preserving identity-string admission and testing its resolution directly. This judgment assumes neither a provider maximum nor an undocumented serial grammar.

**Final: Q1-A, unchanged.** Its strongest argument is preserving identity echoes while explicitly testing the matching-fingerprint, unique-resolution and resolved-path requirements. C remains an acceptable deliberate admission restriction with the losses above.

**Q3**

| Unchanged form | Verdict |
|---|---|
| A | **CANNOT ACCEPT** |
| B | **CANNOT ACCEPT** |
| E | **ACCEPT — preferred** |

A/B’s trimming policies are individually coherent. Their complete printed forms fail on the hash-oracle sentence.

The full blocking trace is:

1. RSC-46 specifies **“The `inventory_fingerprint` is SHA-256 over the RFC 8785 canonical JSON of the device list.”** ([RSC-46](https://github.com/douglaz/provisiond/blob/3109b5b44eae17e288cf52aaa976993bd8c5626c/06-rescue-install.md#L321))
2. A/B instead instruct the reference to construct **“each normalized `{wwn, serial, size_bytes}` element, its RFC 8785 canonical bytes and SHA-256”**, then assert the fingerprint against that digest.
3. The element and enclosing list produce different verified digests. For the permitted serial-only fixture normalized to `ab`:

```text
Required list bytes:
[{"serial":"ab","size_bytes":1024,"wwn":null}]
SHA-256:
8a7ab8eb85404e4ef4022bdf6f1cfc768b029d7f68271f0f60c931d494b72641

Element bytes:
{"serial":"ab","size_bytes":1024,"wwn":null}
SHA-256:
b2fa45b2bdac148628b4ec507afb927aafd8d8c51a5389e5a1a35a8d117bbc05
```

A conforming list fingerprint fails the literal element-digest assertion. This changes a checked verdict; it is separate from the intended trimming choice.

My prior answer calculated the correct list hashes but overlooked that different referent in the printed checklist sentence. I withdraw those unchanged-form acceptances. **E supplies the correction explicitly**, including array brackets, the list-level SHA-256 and lowercase hexadecimal output. No further replacement is needed.

I independently checked E’s complete boundary behavior:

- U+0009 through U+000D and U+0020 surrounding `0XAb` produce wire value `0XAb` and normalized value `ab`. Their wire echoes and `ab` match the unique identity.
- Each trimming character alone becomes absent: caller refusal and inventory `null`.
- U+0008, U+000E, U+001F, U+007F and U+00A0 remain at the edges. With these retained leading characters, the later `0x` is not leading and remains.
- Interior occurrences survive. In particular, `0X Ab` normalizes to ` ab`: prefix removal does not trigger another trim.
- ` 0x0XAB ` normalizes to `0xab`, preserving the existing single-prefix behavior.
- The serial-only and WWN-only list calculations work under E’s trimming set and under B’s alternative set. Their list bytes and SHA-256 values reproduce the supplied reference calculations.

These checks follow the pinned order **“trim ASCII whitespace, ASCII-lowercase, then strip exactly one leading `0x`”**, while preserving the wire rule **“the strings as read, trimmed of ASCII whitespace, or `null` where normalization leaves nothing.”** ([RSC-46](https://github.com/douglaz/provisiond/blob/3109b5b44eae17e288cf52aaa976993bd8c5626c/06-rescue-install.md#L312))

E covers `target.identifier`, `layout.drives[].identifier`, inventory WWN and inventory serial. Its helper prohibition makes the reference independent of the engine’s trim, normalization, serialization and fingerprint implementations.

**The unspecified one-disk fixture value does not block E.** The exact identity value remains a fixture-author choice; once chosen, E unambiguously specifies how to construct that report’s expected list bytes and digest. I do **not** assume an unstated requirement that this separate hash check use the vertical-tab example or every preceding boundary input. That is a coverage limitation rather than a contradictory expected result. The existing CNF-363 assertion **“Assert the fingerprint equals an independently computed hash over both disks”** also remains intact. ([CNF-363 case (2)](https://github.com/douglaz/provisiond/blob/3109b5b44eae17e288cf52aaa976993bd8c5626c/10-conformance-checklist.md#L2303))

The strongest counterargument against E’s trimming policy is identity collapse. B preserves edge U+000B as content; E removes it. E can therefore merge previously distinguishable identities into ambiguous matches, and makes a U+000B-only identity absent. Wire displays and fingerprints also change for those inputs. I accept these as deliberate consequences of the exact chosen trim set. B’s trimming policy remains acceptable in principle; my rejection of unchanged B rests on its hash-oracle defect.

Under notes rule 6, I found **no verified premise-changing brief error**. The element/list defect in unchanged Q3-A/B is an **other brief error**, and my rejections of those forms rest on it. I do not declare either question’s tally void.

**Final: Q3-E, unchanged.** It retains the preferred explicit trim set and specifies the owner’s list-level fingerprint correctly. My acceptance adds no fixture-value requirement or unstated amendment.