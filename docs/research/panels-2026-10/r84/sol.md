I reviewed every printed Panel E form against `3109b5b44eae17e288cf52aaa976993bd8c5626c`. **Review result: PASS as explicit policy alternatives. Final preferences: Q1-A, Q2-A, Q3-A.** Acceptance does not mean equal preference.

Applying notes.md rule 6 exactly as written: I found no verified brief error that changes a question’s premise. I found no blocking contradiction; the substantive policy losses identified below are deliberately printed choices.

**Q1 — admission versus resolution**

| Exact form | Verdict | Preference |
|---|---|---|
| Q1-A | **ACCEPT** | **Preferred** |
| Q1-B | **ACCEPT** | Broader admission restriction than needed |
| Q1-C | **ACCEPT** | Acceptable narrower restriction |

A resolves the ambiguity without inventing syntax that is necessary for disk-write safety. The pinned admission row requires “a JSON string, non-empty after normalization (`RSC-46`)” ([API-13, 04-api-contract.md:974](https://github.com/douglaz/provisiond/blob/3109b5b44eae17e288cf52aaa976993bd8c5626c/04-api-contract.md#L974)). The decisive resolution property is “The identifier is authoritative; the path is derived” ([RSC-26, 06-rescue-install.md:266](https://github.com/douglaz/provisiond/blob/3109b5b44eae17e288cf52aaa976993bd8c5626c/06-rescue-install.md#L266)). Consequently, allowing `/dev/sda` as an identifier string does not authorize using it as the write path.

A’s fixtures distinguish the important outcomes: unmatched `/dev/sda` receives `202`, reaches inventory resolution in rescue, and aborts `integrity` without writes; a unique serial literally equal to `/dev/sda` resolves by identity. The old CNF-200 wording, “is rejected,” supplies no admission phase ([10-conformance-checklist.md:2243](https://github.com/douglaz/provisiond/blob/3109b5b44eae17e288cf52aaa976993bd8c5626c/10-conformance-checklist.md#L2243)). A makes that phase explicit while retaining the resolved-path protection.

B and C are coherent additional availability policies. Their `400 invalid_request` refusals avoid rescue entry for the prohibited strings, and their saved-request fixtures also check worker enforcement. Their verified substantive loss is the inability to echo some legitimate inventory identifiers:

- B excludes every normalized identifier containing `/`, including `a/b`.
- C excludes normalized `/dev/` prefixes, including a unique serial `/dev/sda`; it retains `a/b`.

That narrows the applicability of CNF-363’s positive assertion, “echoing it resolves that disk through both strategies” ([10-conformance-checklist.md:2311](https://github.com/douglaz/provisiond/blob/3109b5b44eae17e288cf52aaa976993bd8c5626c/10-conformance-checklist.md#L2311)). Its setup already says “Use otherwise-admissible fixtures” ([10-conformance-checklist.md:2295](https://github.com/douglaz/provisiond/blob/3109b5b44eae17e288cf52aaa976993bd8c5626c/10-conformance-checklist.md#L2295)), so this is a disclosed admission-domain change rather than a contradictory remaining fixture. Inventory retention does not restore caller access to an excluded value.

No admission ban is needed to prevent treating caller input as a write path. A ban can nevertheless be chosen to avoid disruption from recognizable mistakes. C targets that benefit more narrowly than B; neither prevents every unmatched identifier from reaching rescue.

**Requested counterargument against Q1-A:** A knowingly permits an avoidable reboot for a common mistaken input. The consequence matters: “entering rescue means rebooting the machine into another operating system,” and an ambiguous exit can strand it there ([RSC-38, 06-rescue-install.md:305](https://github.com/douglaz/provisiond/blob/3109b5b44eae17e288cf52aaa976993bd8c5626c/06-rescue-install.md#L305)). C trades away fewer legitimate identifiers than B while avoiding that particular disruption.

**Q2 — identifier size**

| Exact form | Verdict | Preference |
|---|---|---|
| Q2-A | **ACCEPT** | **Preferred: 1024 decoded UTF-8 bytes before normalization** |
| Q2-B | **ACCEPT** | Explicitly accepts body-sized padding |
| Q2-C | **ACCEPT** | Adds a more restrictive normalized domain |
| Q2-D | **ACCEPT** | Explicitly chooses body-only protection |

I prefer A because one raw decoded-value limit bounds admitted field size and subsequent storage and repeated processing, without separately excluding normalized identifiers between 257 and 1024 bytes. It does **not** guarantee that receipt or initial JSON parsing stops at 1024 bytes: the global body cap remains relevant before admission.

The observation points and units are unambiguous:

- **A:** decoded string’s UTF-8 encoding, before normalization; maximum 1024 bytes.
- **B:** normalized string’s UTF-8 encoding; maximum 256 bytes, with raw input bounded only by the body.
- **C:** both observations, at their respective printed limits.
- **D:** no independent identifier length observation that produces a field-specific refusal.

JSON escape spelling does not change these field-size outcomes. The supplied U+00E9 examples correctly distinguish UTF-8 bytes from character counts.

The losses are substantive:

- **A:** an exact inventory wire echo exceeding 1024 bytes is inadmissible. A 1025-byte padded caller value is refused even if normalization leaves `a`.
- **B:** an inventory echo whose normalized value exceeds 256 bytes is inadmissible. Long padding remains admissible within the body cap, so normalized-key size is bounded while raw field processing can remain large.
- **C:** combines both exclusions.
- **D:** retains length compatibility within the body cap but gives up an independent field bound.

A shorter equivalent spelling may sometimes rescue an over-limit echo; that is not universally available, particularly because normalization strips exactly one prefix. None of these forms truncates inventory values.

These choices also narrow the positive scope of “Padded echoes and serials with whitespace inside them resolve through both strategies” ([CNF-363, 10-conformance-checklist.md:2322](https://github.com/douglaz/provisiond/blob/3109b5b44eae17e288cf52aaa976993bd8c5626c/10-conformance-checklist.md#L2322)). A and C deliberately move over-limit padded inputs to admission refusal; B and C exclude over-limit normalized serials. The new boundary paragraphs disclose those changed outcomes.

Both printed numbers are defensible **as support-policy limits**, with the exclusions accepted explicitly. Neither establishes coverage of every provider’s identifiers. I would not describe either as a hardware maximum. The 256-byte normalized limit buys a smaller matching-key domain; that additional restriction is why I prefer A over B or C.

D is acceptable because it explicitly makes the exception in API-13, the delegated field-limit owner. It changes the practical protection behind SEC-29’s “individual fields MUST be capped per `API-13`” ([07-security-requirements.md:280](https://github.com/douglaz/provisiond/blob/3109b5b44eae17e288cf52aaa976993bd8c5626c/07-security-requirements.md#L280)); it should not be presented as supplying the same independent bound.

The saved-request outcomes are consistent with “Validation that was performed at the API boundary MUST be repeated in the worker before the driver is called” ([OPS-23, 03-operation-lifecycle.md:2018](https://github.com/douglaz/provisiond/blob/3109b5b44eae17e288cf52aaa976993bd8c5626c/03-operation-lifecycle.md#L2018)), including its caller-field failure classification and pre-rescue timing.

**Requested counterargument against Q2-A:** There is no provider guarantee behind 1024. A can make a machine’s sole unique inventory identifier unusable, and rejects harmless padding despite an existing finite body bound. D preserves that compatibility; B preserves large padding while bounding normalized keys.

**Q3 — exact trimming set**

| Exact form | Verdict | Preference |
|---|---|---|
| Q3-A | **ACCEPT** | **Preferred** |
| Q3-B | **ACCEPT** | Coherent alternative retaining U+000B |

Both definitions and their fixtures are internally consistent. I prefer A’s continuous U+0009–U+000D range plus U+0020, including removal of invisible edge vertical tabs. This preference assumes no outside library’s behavior.

The owning sequence remains “trim ASCII whitespace, ASCII-lowercase, then strip exactly one leading `0x`” ([RSC-46, 06-rescue-install.md:314](https://github.com/douglaz/provisiond/blob/3109b5b44eae17e288cf52aaa976993bd8c5626c/06-rescue-install.md#L314)). My independent calculation used explicit code-point sets and ASCII folding, without engine helpers:

- For every member of the selected trimming set, surrounding `0XAb` produces wire value `0XAb` and normalized value `ab`. The character alone normalizes to absence.
- Under B, U+000B surrounding `0XAb` remains on the wire. ASCII folding produces `\u000b0xab\u000b`; the leading vertical tab prevents prefix removal. Its echo matches, while `ab` does not.
- U+000B alone is absent under A and non-empty under B.
- The listed retained neighbors—U+0008, U+000E, U+001F, U+007F and U+00A0—remain present. Interior occurrences of every tested character survive.
- Bare `0X` still normalizes to absence. The existing nested-prefix fixture still normalizes ` 0x0XAB ` to `0xab`, stripping only one prefix.

These results apply equally to both caller fields and both inventory identity fields. They preserve the distinction between trimmed as-read wire display and normalized fingerprint content.

The vertical-tab fixtures produced these exact canonical UTF-8 inputs, shown with JSON escapes literal:

```text
A serial: [{"serial":"ab","size_bytes":1024,"wwn":null}]
A WWN:    [{"serial":null,"size_bytes":1024,"wwn":"ab"}]
B serial: [{"serial":"\u000b0xab\u000b","size_bytes":1024,"wwn":null}]
B WWN:    [{"serial":null,"size_bytes":1024,"wwn":"\u000b0xab\u000b"}]
```

Their SHA-256 digests matched every supplied reference hash. Neither form contains a fixture contradicting its own definition or the existing null/prefix rules.

**Requested counterargument against Q3-A:** An edge vertical tab might be meaningful identifier content. Removing it can collapse otherwise distinct serials, making selection ambiguous and causing an integrity refusal; B preserves that distinction. A and B also necessarily produce different wire displays and fingerprints for the discriminating fixtures. Those are substantive choices, not editorial equivalence.

**Composition and formal properties**

My acceptable combinations are exactly the unchanged printed forms in:

`{Q1-A, Q1-B, Q1-C} × {Q2-A, Q2-B, Q2-C, Q2-D} × {Q3-A, Q3-B}`.

My preferred combination is **Q1-A + Q2-A + Q3-A**, without revised wording.

The selected Q3 definition determines normalization before Q1’s syntax predicate and Q2’s normalized-size observation. For example, under Q3-B, edge vertical tabs remain: Q1-C’s prefix predicate can therefore differ from its result under Q3-A. That follows the exact predicates; it is not an undefined “path-shaped” exception. The printed size fixtures use spaces, which both Q3 forms trim.

No printed form changes a formalized resolution clause or requires theorem weakening. The model’s identifier is `n : Nat` ([Rescue.lean:298](https://github.com/douglaz/provisiond/blob/3109b5b44eae17e288cf52aaa976993bd8c5626c/tools/formal/Provisiond/Rescue.lean#L298)); its resolution definition checks fingerprint and match multiplicity ([Rescue.lean:351](https://github.com/douglaz/provisiond/blob/3109b5b44eae17e288cf52aaa976993bd8c5626c/tools/formal/Provisiond/Rescue.lean#L351)). The proposed string admission and normalization policies do not alter those abstract definitions or verdicts.

All lightweight checks and calculation assertions exited 0. The final worktree was clean. No builds, edits, tracker changes, or panel-record writes were performed.