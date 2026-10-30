# Exact settled Q2-A (copied from r84 brief)

### Q2-A — 1024 UTF-8 bytes before normalization

Replace API-13's disk-identifier row with:

```text
| disk identifier | a JSON string whose decoded value is at most 1024 UTF-8 bytes before `RSC-46` normalization and is non-empty after that normalization; count the decoded value's UTF-8 encoding, not its JSON escape spelling. A `null`, non-string, over-limit or empty-after-normalization `target.identifier` or `layout.drives[].identifier` MUST be refused `invalid_request` before enqueue. No separate post-normalization size cap applies. Worker repetition: `OPS-23`. Resolution: `RSC-26`. |
```

Insert within CNF-363 after case (14), before the final owner references:

```text
      **Disk identifier size boundaries.** For each caller identifier field, admit
      decoded ASCII values of 1023 and 1024 UTF-8 bytes; refuse 1025 with `400`
      `invalid_request` before enqueue, with no rescue entry or disk write. Refuse a
      1025-byte value even when trimming leaves one byte. Admit 512 copies of U+00E9
      (1024 UTF-8 bytes); refuse those copies followed by `a` (1025 bytes). Encode
      the same decoded ASCII value with literal characters and with JSON `\u0061`
      escapes: the size outcome is identical. Inject an over-limit caller value
      into a saved request: repeated validation fails `invalid_request`,
      `retryable: false`, before a driver call, with `disk_effect: "none"` and
      `rescue_exit: "none"`. Inventory still returns over-limit serials untruncated.
      (`API-13`, `OPS-23`)
```

