# Robot rescue host keys are pinned from the last-rescue record after boot

**Status:** accepted (2026-10-12, owner decision Q27 of the post-PR-2 grill).

## Context

`08-provider-notes.md` said Robot rescue host keys are "published in the rescue activation response and
in a 'last rescue' lookup", marked observed. It called Robot the only provider in the reference set that
supports pinning without out-of-band material. `PRV-16` and `PRV-19` were written around that claim.

Two live sessions on 2026-10-12 contradicted half of it. The record is in
`docs/research/panels-2026-10/r45/`.

- **The activation response carries no keys.** It has `"host_key": []`, and so does
  `GET /boot/{server-number}/rescue`, both before and after the rescue system booted.
- **`GET /boot/{server-number}/rescue/last` publishes the booted session's keys** as SHA256 fingerprints
  (ECDSA, ED25519, RSA), together with a `boot_time`. They were present by the time port 22 opened, about
  sixty seconds after the reset, and all three matched the keys the rescue system presented over SSH.
- **Every rescue boot generates fresh keys**, so an earlier boot's keys never pin a later one.
- **The activation is consumed at boot.** `active` reads `false` within thirty seconds of the reset.
- **Before a boot, the last-rescue record belongs to the previous rescue session**, or answers `404`
  when there is none.
- **Robot publishes fingerprints, not complete public keys.**

## Decision

- **Begin rescue returns no host keys on Robot.** Activation exposes none, so `PRV-16`'s "whenever the
  provider exposes them" is met by an empty set, and the session is marked as awaiting keys.
- **`PRV-19`'s refresh reads the last-rescue record.** It populates the session's host keys only when the
  record's `boot_time` is later than the session's reset. A record from an earlier boot is never used.
- **The pin is the published SHA256 fingerprints.** The engine connects only to a host whose presented key
  matches one of them. Matching fingerprints, then pinning the presented key for that connection, is
  enough; no complete public key is needed from the provider.
- **No keys within the deadline fails closed.** If the record shows no keys for this boot before the
  rescue deadline, the session fails. Robot never falls back to first-use trust.

## Considered and rejected

- **First-use trust on Robot, as on Cloud and DigitalOcean.** It discards the one provider where real
  pinning is available.
- **Reading keys from the activation response.** They are not there.
- **Treating the last-rescue record as current without checking `boot_time`.** It would pin the previous
  session's keys, and the connection would then fail closed or match by accident.

## Consequences

- `08-provider-notes.md`'s claim is corrected.
- `PRV-16`, `PRV-19` and `PRV-20` are reconciled with a fingerprint-only pin, and `RSC-*` pinning cites it.
- A CNF item covers the cases: an empty activation, a stale last record before boot, keys arriving after
  boot, a mismatch, and keys never arriving within the deadline.
- The last-rescue read uses `GET /boot/…`, a counter separate from the `/server` reads (`ADR-0034`).
