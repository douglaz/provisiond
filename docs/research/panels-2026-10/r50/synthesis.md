# Panel r50 synthesis — which presented host key may a Robot session accept when the caller also supplied keys? (Q33), 2026-10-14

Readers: fable (claude-fable-5-1), opus (claude-opus-5-5), astra (gpt-6-astra), sol (gpt-6.1-sol), all at xhigh;
clones at 6a4644a. All exit 0.

## Votes

All four: **INTERSECTION** — the presented key must be one of the caller's keys and match an accepted provider
pin; the ecdsa key in the brief's example is refused.

## Facts the readers established

- **No owner text decides it.** `RSC-3`'s both-supplied row says only "They MUST overlap"; `RSC-3`'s amended
  paragraph, `PRV-20` and `CNF-355` make a provider match necessary, not sufficient. `WIR-20`'s "Pin
  caller-supplied full keys" and `RSC-3`'s "Pin exactly those" read toward intersection.
- **The Lean model already reads the other way on Robot:** after pv-f6g the overlap arm is
  `(caller ∨ driver) ∧ (¬required ∨ driver)`, which with `required = true` reduces to `driver` — any provider
  pin — despite its "without choosing" docstrings (fable, opus, sol).
- **The brief's framing was wrong on one point:** the server does not choose which key to present; the client
  does (RFC 4253 §7.1). With only the overlapping caller keys in `RSC-8`'s per-operation known_hosts, strict
  checking, and `HostKeyAlgorithms` limited to their algorithms (`rsa-sha2-512,rsa-sha2-256` for an RSA key),
  an honest server presents the overlapping key. sol verified this with local probes. An honest session fails
  only if the overlapping key is not negotiable.
- **Where it matters:** under any-provider-pin, a forged last-rescue record listing the caller's real ed25519
  fingerprint plus an attacker's ecdsa one passes the overlap check and the attacker's key is accepted; the
  caller's keys never limit what is accepted. Only intersection refuses it (fable, opus).
- **Scope:** caller expected keys mean rescue keys only (`trust` exists only on the rescue-entering install
  variants and rescue-inventory); in v1 only Robot publishes keys, and a Robot session waiting for pins aborts,
  so caller keys on Robot always land in the both-supplied row. `08-provider-notes.md`'s
  `expected_rescue_host_keys` is a stale name; the wire field is `trust.expected_host_keys` (`WIR-2` rejects
  unknown fields).
- **Reachability:** a caller can know rescue keys only from its own SSH into an earlier rescue, and only if a
  server's rescue keys stay fixed (`ADR-0041`: not established). If they are fresh per boot, every Robot request
  with caller keys fails `integrity` after activation rebooted the server — equally under both candidates. opus:
  if the planned double rescue shows per-boot keys, refuse `expected_host_keys` at admission for such drivers.

## Changes the readers name

`RSC-3` row 3 gains "On overlap, pin exactly the caller keys whose algorithm and SHA256 digest match a driver
pin" (last, so `WIR-20`'s quote stays intact), row 1 gains "and the driver published none"; `WIR-20` aligned;
`Trust.permitsPresented`'s overlap arm becomes `caller ∧ driver`, its "without choosing" docstrings go, with a
witness refusing a provider-pinned key outside the caller set and a CI control; `CNF-355`/`CNF-36` gain the
asymmetric case; `08-provider-notes.md` uses the wire name.

## Strongest case for the other side (written on request — not the readers' positions)

`ADR-0041`: "The presented-key match is what makes the connection safe." The record is one TLS-authenticated
response from the provider, which owns the hardware; a forger of it would be the provider, already able to
control the machine (provider-API compromise is outside the threat model, `07-security-requirements.md`).
Any-provider-pin keeps one keyscan → match → pin path with no algorithm-list plumbing, and `PRV-20`'s "MUST pin
the matching presented full key" reads as sufficient.
