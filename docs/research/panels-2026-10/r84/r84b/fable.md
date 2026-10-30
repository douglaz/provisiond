Verification done. Pin matches, every quoted passage and line number in the brief is byte-identical to my clone, and my own script reproduces all four list digests plus the element digest. I also read the two tracker rows and the pv-6p8 record, which bear directly on Q1. Here is my answer.

**Verification.** Clone at 3109b5b, clean. Scratch under `r84b/tmp/fable/calc.py`, exit 0. No build, no gate, no write. Independent results: list bytes `[{"serial":"ab","size_bytes":1024,"wwn":null}]` hash to `8a7ab8eb…b72641`; element bytes `{"serial":"ab","size_bytes":1024,"wwn":null}` hash to `b2fa45b2…7bbc05`. The A-WWN, B-serial and B-WWN list digests also match the prior answers. Normalization fixtures for all six trim characters, the five retained neighbours, interior characters, case (8) and VT-only all behave as A, B and E print them.

## Q1, pv-ez8

| Form | Verdict |
|---|---|
| A | ACCEPT, preferred |
| B | CANNOT ACCEPT (policy objection, no gate contradiction, no checked verdict flips) |
| C | ACCEPT |

**Final: Q1-A.** I move from C to A. Three verified facts changed my preference, and none of them is new policy argument.

First, A is the pinned reading, not a candidate reading. The tracker row `pv-ez8` itself frames the question as admission "(a new `API-13` rule) or at resolution (`integrity`, as `RSC-26` reads now)". The implementer's follow-up on `pv-6p8` (comment 802) read CNF-200's "rejected" as "admission followed by an integrity abort with no write: the new API-13 row admits a non-empty path-shaped string". A writes that reading into CNF-200 and case (14) with no new MUST.

Second, the pinned admission row was a 4-0 decision eight days ago whose record says in terms: "A well-formed string that matches nothing still aborts `integrity`" (pv-6p8 agent brief, item 7). C narrows that decision on a 2-2 preference split. A new refusal is the amendment that needs the votes. The minimal repair is the resting point when the votes are not there, and it leaves the owner free to add C's paragraph later as a policy decision, exactly as the owner reserved Q2's size limit.

Third, the choice protects no outcome that differs. RSC-26 says "The identifier is authoritative; the path is derived" (06:266), and the Lean projection `Resolution.path` reads the path only off the resolved device. A and C write the same bytes to the same disks in every case. The difference is one reboot shape versus one reserved prefix.

**Strongest reason for C, and whether it pulls me back.** A `/dev/sda` paste is the one mistake the old RSC-26 text taught callers to make, and under A it costs a reboot into rescue with PRV-22's "*always* ambiguous" exit (06:306). That cost is real and the r61b panel accepted it as grounds for refusing empties. It does not pull me back, because the pinned set already accepts the same reboot for every other unmatched well-formed string, and C catches only the `/dev/` spelling, so bare `sda` and `nvme0n1` still reboot. A small, partial operational win does not justify writing an OS-specific prefix into an opaque-identity rule on a tie.

**Deliberate losses, per form.**
- **A:** the `/dev/sda` typo is admitted at `202` (04:248 install row) and reboots before aborting `integrity`. A's case (14) also requires a positive fixture in which a serial literally `/dev/sda` resolves by identity. No echo is lost. CNF-200 loses the phrase "exactly as raw-disk does" and case (14) loses its RSC-26 quotation; both are common to all three forms.
- **B:** every unique identifier whose normalized form contains `/` becomes unnameable, including `a/b`; RSC-26's "An install request MUST carry both the chosen device's stable identifier and the `inventory_fingerprint`" (06:258) has no satisfiable request for such a disk while its strategy stays listed. The class is wider than the mistake it targets, which is my policy objection.
- **C:** the same loss for identifiers beginning with `/dev/` after normalization, including ` 0X/DeV/sda `, and a second normative check in API and worker. Fixtures are consistent, including the `a/b` and `/tmp/disk` admissions.

C remains acceptable to me, and I state plainly that its refusal is a policy add-on the owner can take separately.

## Q3, pv-tbrs

| Form | Verdict |
|---|---|
| A, unchanged | CAN ACCEPT WITH THIS EXACT FIX: the fix is E as printed |
| B, unchanged | CAN ACCEPT WITH THIS EXACT FIX: B′ printed below |
| E | ACCEPT, preferred |

**Final: Q3-E.** E is A's trim set with the hash sentence corrected, so it is the form every A voter can accept without changing their trimming vote.

**The element/list objection is correct, and I missed it.** RSC-46 says "The `inventory_fingerprint` is SHA-256 over the RFC 8785 canonical JSON of the device list, each element exactly `{wwn, serial, size_bytes}`" (06:321–322). A and B instruct the reference to "construct each normalized `{wwn, serial, size_bytes}` element, its RFC 8785 canonical bytes and SHA-256, and assert the fingerprint against those expected bytes and digest". The antecedent of "its" is the element. For the serial-only fixture with hash value `ab`, the element digest is `b2fa45b2…` and the list digest is `8a7ab8eb…`. An engine conformant to RSC-46 returns the list digest and fails the sentence read literally. The tester's only way out is to substitute the list silently, which is the second-copy drift AGENTS.md forbids. This is an unintended changed verdict, not intended policy: every reference digest the A authors printed was a list digest. In my original answer I verified those list digests and read "its" as the list. That was an unprinted repair, and I withdraw the unqualified acceptance of A and B.

**E, checked clause by clause.**
- **RSC-46 insertion:** identical to A's. Trim set U+0009–U+000D plus U+0020, maximal prefix and suffix only, applied to normalization and to the as-read wire values.
- **Six trim characters:** each wrapped `0XAb` shows `0XAb`, hashes as `ab`, and both echo and `ab` resolve. Verified. The character alone is empty after normalization: refused before enqueue by API-13's pinned "empty-after-normalization" clause (04:974); shown `null` by RSC-46's "`null` where normalization leaves nothing" (06:319–320).
- **Neighbours:** U+0008, U+000E, U+001F, U+007F, U+00A0 at the edges are retained and leave `0x` non-leading, so nothing is stripped. Verified, both forms.
- **Interior:** `0X` VT `Ab` normalizes to VT `ab`; `0X Ab` to ` ab`. Preserved, as case (13) requires.
- **Prefix order:** lowercase precedes the single strip; ` 0x0XAB ` still gives `0xab` and `0XAB` gives `ab`, so case (8) holds.
- **Independent list bytes:** E hashes "the RFC 8785 canonical bytes of that list, including its enclosing array brackets" and compares to "the digest encoded as 64 lowercase hex characters", matching RSC-46's "On the wire the fingerprint is 64 lowercase hex characters" (06:324). Sorting is trivial for one element. The reference may not call engine helpers.

**Does the full text specify the hash test without naming the value?** Yes, sufficiently. The per-character clause asserts "the normalized hash value is `ab`". Matching behaviour is asserted separately by "both its wire echo and `ab` resolve", so the hash-value claim is observable only through the fingerprint. The one-disk sentence then supplies the reference construction and the element shape. A suite that implements the paragraph therefore must compute an expected list fingerprint containing `ab` for each wrapped fixture. The remaining gap is that the one-disk sentence alone also permits a plain `ab` fixture, which would exercise the shape but not the trim. That is a test-strength note; rule 3 says "An absent new runtime test alone is not a contradiction." I do not propose a fifth form for it, because a form nobody else has read cannot settle in this round.

**B′, the exact fix for B.** RSC-46 insertion: B's, unchanged. Replace B's CNF-363 paragraph with:

```text
      **Whitespace boundaries.** Apply `RSC-46`'s exact trimming set to the caller
      fields and to both inventory WWN and serial. For each of U+0009, U+000A,
      U+000C, U+000D and U+0020, independently surround `0XAb` with that character:
      the as-read wire value is `0XAb`, the normalized hash value is `ab`, and both
      its wire echo and `ab` resolve the unique disk under both install strategies.
      A caller value consisting only of one of those characters is refused
      `invalid_request` before enqueue; an inventory value consisting only of it
      is absent and shown `null`. U+000B is retained: with a serial-only disk whose
      serial is U+000B + `0XAb` + U+000B, its wire echo resolves that disk but `ab`
      matches nothing and aborts `integrity` with no disk write. U+000B alone is
      non-empty for caller admission and on the wire. U+0008, U+000E, U+001F,
      U+007F and U+00A0 at the edges are also retained on the wire and in normalized
      values; their presence prevents stripping a later `0x` that is not leading.
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

B′ changes only the hash sentences. Its U+000B fixture normalizes to VT`0xab`VT, whose list digest is the `00bf39db…` value already verified. One non-blocking tension for B and B′: CNF-363 cases (5) and (10) say "whitespace-only" without qualifier, and under B a VT-only value is admitted and shown. Both cases rest on API-13's "empty-after-normalization (`RSC-46`)", so RSC-46's definition governs and there is no contradiction, but the word reads oddly.

**Requested counterargument against E.** "ASCII whitespace" has a widely published exact meaning that excludes U+000B, and a mainstream standard-library predicate of that name agrees, so a builder who implemented the pinned text with that predicate is conformant today and non-conformant under E on the one discriminating fixture. B′ keeps the term and the common predicate aligned. Background knowledge, not a packet premise, and not a vote.

**Blocking losses.** Q1: none. Q3: the A/B hash sentence, traced above, makes a new conformance assertion literally unsatisfiable by an RSC-46-conformant engine. E and B′ remove it. No Lean declaration is touched by any form; `Identifier.n : Nat` and `Inventory.fingerprint : Nat` do not model strings or hashing.

**Rule 6.** Applied as written. I verified every pinned extract, line reference, hash and tally statement in the brief and found no error, premise-changing or otherwise. No vote of mine rests on a brief error.

**Composition.** E's RSC-46 insertion is A's, so Q1-A plus settled Q2-A plus Q3-E compose exactly as my original C/A/A analysis did, with Q1-A adding no API-13 text. No Q1 form depends on the Q3 choice under A, since A adds no grammar that normalization could feed.
