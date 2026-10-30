### Q1-B — disallow slash anywhere in the normalized caller identifier

Insert after the API-13 table and before its amendment note:

```text
For `target.identifier` and every `layout.drives[].identifier`, a value whose `RSC-46`
normalization contains U+002F (`/`) MUST be refused `invalid_request` before enqueue.
This is a caller-input restriction even when an inventory WWN or serial contains that
character; the inventory retains that value. Worker repetition: `OPS-23`.
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
      (14) In each caller identifier field, separately submit `/dev/sda`, `a/b`, and
      ` 0X/dev/sda `: each is refused `400` `invalid_request` before enqueue, with no
      rescue entry or disk write, including when a unique inventory serial equals
      the normalized input. Inject each value into a saved install request: repeated
      validation fails `invalid_request`, `retryable: false`, before any driver call,
      with `disk_effect: "none"` and `rescue_exit: "none"`. Separately use an otherwise-
      admissible `not-a-disk` matching no WWN or serial: both strategies admit with
      `202`, then abort `integrity` at inventory resolution in rescue with no disk writes.
      (`API-13`, `OPS-23`, `RSC-26`)
```

