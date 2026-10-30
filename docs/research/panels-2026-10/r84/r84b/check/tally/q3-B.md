### Q3-B — the same local definition excluding U+000B (narrower trimming set)

Insert in RSC-46 immediately after its bold heading and before “Before comparison,”:

```text
Here ASCII whitespace means exactly U+0009, U+000A, U+000C, U+000D and U+0020;
trimming removes only a maximal prefix and suffix of those code points, never interior
characters or any other code point. U+000B is not whitespace here. This definition
applies to normalization and to trimming the as-read wire values in this requirement.
```

Insert in CNF-363 after its numbered cases and the selected size paragraph, before its final owner-reference line:

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
      independently construct each normalized `{wwn, serial, size_bytes}` element,
      its RFC 8785 canonical bytes and SHA-256, and assert the fingerprint against
      those expected bytes and digest. The reference must not call the engine's
      trim, normalization, serialization or fingerprint helpers. (`RSC-46`, `API-13`)
```

