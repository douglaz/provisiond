### Q3-E — astra complete exact alternative, initially author-reviewed only


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

