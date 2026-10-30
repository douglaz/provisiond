### Q1-A — preserve the admission domain; make resolution explicit (minimal repair)

No API-13 or RSC-26 edit. Replace CNF-200 whole with:

```text
- [ ] **CNF-200** — On an otherwise-admissible rootfs install, submit `/dev/sda` as
      `layout.drives[0].identifier` against an inventory in which no WWN or serial normalizes
      to that string. Assert admission with `202`, followed by `integrity` at inventory
      resolution in rescue and no disk writes. With a unique stable identifier instead,
      assert the generated installer configuration uses the path resolved from that
      identifier against the matching inventory fingerprint. (`API-13`, `RSC-26`, `RSC-22`, `WIR-20`)
```

Replace CNF-363 case (14), from “(14) Use” through its quoted RSC-26 sentence, with:

```text
      (14) Use a well-formed unmatched identifier, separately `not-a-disk` and `/dev/sda`,
      against an inventory in which neither matches any WWN or serial: both strategies
      admit the request with `202`, then abort `integrity` at inventory resolution in
      rescue with no disk writes. Separately give exactly one disk the serial `/dev/sda`,
      with no conflicting WWN; echoing it resolves that disk under both strategies and
      the generated installer configuration uses only its resolved path. (`RSC-26`)
```

