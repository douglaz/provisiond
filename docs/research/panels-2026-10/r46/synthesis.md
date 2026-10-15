# Panel r46 synthesis — telling a fresh Robot last-rescue record from a stale one (Q29), 2026-10-12

Readers: fable, opus (claude xhigh), astra, sol (codex xhigh); clones at da3e268. All exit 0.

## Agreed (4–0)

- Evidence corrections to `ADR-0041` and `08-provider-notes`: `active: false` was first read 44 s after the
  reset (not "within thirty seconds"); port 22 opened at 87 s and the record was read at 90 s (not "about
  sixty"); "every rescue boot generates fresh keys" is unverified (each server was rescued once); the
  pre-boot record "belonging to the previous session" was never observed (the only pre-boot read answered
  `404`), and the `404`'s meaning is undocumented.
- The Manager's two repairs are independent of this question: `Trust.permitsPresented` (membership) and
  `CNF-283`'s alarm (cite `PRV-5`).
- No durable baseline: `DOM-11` "MUST NOT be persisted"; a crash interrupts the operation (`OPS-15`).

## Split 2–2

- **Adopt (b), compare before/after (fable, opus):** safety rests on `PRV-20`'s presented-key match; a
  stale or foreign record ends in `integrity`, failing open only for a holder of that boot's private host
  key, i.e. an account-credential holder, which `07-security-requirements.md` does not defend against;
  (a) does not stop that actor either. Opus: compare `boot_time` verbatim as a string (a fingerprint
  detector fails every repeat rescue if keys are fixed per server), require at least one fingerprint, read
  the baseline before activation (a failure needs no cleanup). Fable: compare the opaque pair, read after
  activation.
- **Reject (b) (astra, sol):** a changed record is not evidence that our reset produced it (an intervening
  boot, a delayed intermediate record); equal second-resolution strings reject a fresh boot in the repeated
  hour. Sol: (a) with field-specific Berlin evidence, accepting an ambiguous time when every interpretation
  is later than the reset. Astra: (b) only with its assumptions stated.

Owner decision Q29: by change, as opus states it — baseline before activation, `boot_time` compared
verbatim, at least one fingerprint, safety stated as the presented-key match (`ADR-0041`, rewritten in
place on this branch).
