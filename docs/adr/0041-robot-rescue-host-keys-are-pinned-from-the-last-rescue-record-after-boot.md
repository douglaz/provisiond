# Robot rescue host keys are pinned from the last-rescue record after boot

**Status:** accepted (2026-10-12 and 2026-10-13, owner decisions Q27 and Q29 of the post-PR-2 grill).

## Context

`08-provider-notes.md` said Robot rescue host keys are "published in the rescue activation response and
in a 'last rescue' lookup", marked observed. It called Robot the only provider in the reference set that
supports pinning without out-of-band material. `PRV-16` and `PRV-19` were written around that claim.

Two live sessions on 2026-10-12 contradicted half of it. The record is in
`docs/research/panels-2026-10/r45/`.

- **The activation response carries no keys.** It has `"host_key": []`, and so does
  `GET /boot/{server-number}/rescue`, both before and after the rescue system booted.
- **`GET /boot/{server-number}/rescue/last` publishes the booted session's keys** as SHA256 fingerprints
  (ECDSA, ED25519, RSA), together with a `boot_time`. In the one session that polled it, the record was
  read 90 seconds after the reset, three seconds after port 22 opened. All three fingerprints matched the
  keys the rescue system presented over SSH.
- **Before the first rescue of a server, the read answered `404`.** What a `404` means beyond "no record
  was returned" is not documented.
- **The activation is consumed at boot.** `active` read `false` at the first check, 44 seconds after the
  reset.
- **`boot_time` carries no zone.** `"2026-10-12 19:17:49"` for a boot at about 17:17:49Z fits Berlin summer
  time, and a Berlin local hour repeats once a year.
- **Robot publishes fingerprints, not complete public keys.**
- **Not established:** whether a server's rescue host keys change on every boot. Each test server was
  rescued once, and the two servers' keys differed.

## Decision

- **The presented-key match is what makes the connection safe.** The engine connects only to a host whose
  presented key matches a published SHA256 fingerprint. A stale or foreign record ends in a refused
  connection, never in trust. Freshness only decides when to connect.
- **Begin rescue reads a baseline before activating.** It reads the last-rescue record and keeps its
  `boot_time` string as the session's baseline; there is none when no record exists. Any other failure of
  that read fails begin rescue before activation, with nothing to clean up.
- **Begin rescue returns no host keys on Robot.** Activation exposes none, so `PRV-16`'s "whenever the
  provider exposes them" is met by an empty set, and the session is marked as awaiting keys.
- **`PRV-19`'s refresh accepts a changed record.** It populates the session's host keys only when the
  record lists at least one fingerprint and its `boot_time` string differs from the baseline. The strings
  are compared verbatim and never parsed as an instant.
- **The pin is the published SHA256 fingerprints.** Matching fingerprints, then pinning the presented key
  for that connection, is enough; no complete public key is needed from the provider.
- **No keys within the deadline fails closed.** If no changed record with keys appears before the rescue
  deadline, the session fails. Robot never falls back to first-use trust.

## Considered and rejected

- **First-use trust on Robot, as on Cloud and DigitalOcean.** It discards the one provider where real
  pinning is available.
- **Reading keys from the activation response.** They are not there.
- **Comparing `boot_time` with the reset as instants.** The field has no zone, a local hour repeats, and
  the comparison guards nothing the presented-key match does not (panel
  `docs/research/panels-2026-10/r46/`, split 2–2).
- **Detecting the new record by a changed fingerprint set.** If a server's rescue keys are fixed, every
  repeat rescue would be rejected.
- **Reading the baseline after activation.** A failure there leaves an activation to clean up.

## Consequences

- `08-provider-notes.md`'s claim is corrected, with the timings as observed.
- `PRV-15`, `PRV-16`, `PRV-19` and `PRV-20` are reconciled with the baseline and a fingerprint-only pin.
  `RSC-*` pinning cites it.
- A CNF item covers the cases:
  - an empty activation;
  - the baseline record served again after the reset, so the session keeps waiting;
  - a changed record that pins;
  - a first record after a no-record baseline;
  - a mismatch at connect;
  - a failed baseline read, which sends no activation;
  - keys never arriving within the deadline.
- The last-rescue reads use `GET /boot/…`, a counter separate from the `/server` reads (`ADR-0034`).
- The next live session rescues one server twice, to settle whether keys change per boot, and captures
  the `404`'s error code.
