### Q1-C — refuse only the normalized `/dev/` prefix (narrower restriction)

Insert after the API-13 table and before its amendment note:

```text
For `target.identifier` and every `layout.drives[].identifier`, a value whose `RSC-46`
normalization begins with the ASCII string `/dev/` MUST be refused `invalid_request`
before enqueue. This is a caller-input restriction even when an inventory WWN or serial
begins with that string; the inventory retains that value. Other non-empty normalized
strings remain subject to the disk-identifier row and `RSC-26`. Worker repetition: `OPS-23`.
```

Replace CNF-200 whole with:

```text
- [ ] **CNF-200** — An otherwise-admissible rootfs install with `/dev/sda` in
      `layout.drives[0].identifier` is refused `400` `invalid_request` before enqueue,
      with no rescue entry or disk write. A rootfs install with a unique admissible
      stable identifier uses only the path resolved against its inventory fingerprint.
      (`API-13`, `RSC-26`, `RSC-22`, `WIR-20`)
```

Replace CNF-363 case (14), including its old RSC-26 quotation, with:

```text
      (14) In each caller identifier field, separately submit `/dev/sda` and
      ` 0X/DeV/sda `: each is refused `400` `invalid_request` before enqueue with no
      rescue entry or disk write, including when a unique inventory serial equals
      the normalized input. Inject each value into a saved install request: repeated
      validation fails `invalid_request`, `retryable: false`, before any driver call,
      with `disk_effect: "none"` and `rescue_exit: "none"`. Separately use `not-a-disk`,
      `/tmp/disk` and `a/b` against an inventory in which each matches no WWN or serial:
      both strategies admit with `202`, then abort `integrity` at inventory resolution
      in rescue with no disk writes. A unique serial `a/b` still resolves by identity.
      (`API-13`, `OPS-23`, `RSC-26`)
```

