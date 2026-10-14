Reviewed Q33 at `6a4644a`: **FAIL—ambiguous pin-set contract (blocker). Vote: INTERSECTION; refuse the ECDSA key.**

`RSC-3` says “Pin exactly those”; `WIR-20` says “Pin caller-supplied full keys”; `RSC-3` additionally requires “The actual Robot connection MUST match an accepted provider pin”. Read cumulatively, these already support intersection. `PRV-20`’s “match none of the accepted pins MUST be refused before authentication” establishes necessity, not permission to accept every match. But the both-supplied row says only “They MUST overlap”. `CNF-355` likewise says “require the actual Robot connection to match a provider pin”, leaving the disputed caller-membership check unstated.

The model actually accepts the example: [Rescue.lean:168](https://github.com/douglaz/provisiond/blob/6a4644a614d95591c51f02ca0b5686162985b3a2/tools/formal/Provisiond/Rescue.lean#L168) computes union AND provider membership for Robot, reducing to provider membership after overlap. Its omission is deliberate; `pv-f6g`, comment 561, explicitly records the conflicting caller-pin reading.

Other constraints do not settle that choice:

- `RSC-5`: “MUST NEVER be silently downgraded” (`CNF-37`).
- `RSC-6`: “compare the algorithm and SHA256 digest” (`CNF-38`).
- `RSC-9`: “derived from the boot timeout” (`DEF-5`, `CNF-39`).
- Additional relevant references: `RSC-4`, `RSC-7`, `RSC-8`, `API-13`, `DOM-11`, `PRV-15`–`PRV-19`, `SEC-22`–`SEC-23`, `WIR-40`, `CNF-36`; failure disposition: `OPS-11`, `OPS-45`, `CNF-279`.

The captured provider fingerprints match the recorded SSH keys ([live-session3.txt:26](https://github.com/douglaz/provisiond/blob/6a4644a614d95591c51f02ca0b5686162985b3a2/docs/research/panels-2026-10/r45/live-session3.txt#L26)); per-boot freshness remains unestablished (`ADR-0041`). Robot alone supplies rescue pins within `ADR-0010`’s launch set: Cloud’s [published schema](https://docs.hetzner.cloud/cloud.spec.json) has no host-key field; DigitalOcean “MUST NOT declare” `rescue_ssh` (`08-provider-notes.md:280`).

`expected_rescue_host_keys` occurs only in `08-provider-notes.md:73`. It appears to mean the same concept, but **only `trust.expected_host_keys` is a defined wire field**, not two supported fields or aliases: `WIR-2` says “Unknown fields in a request body MUST be rejected”.

`RSC-13`’s “authorized key for the installed system” authenticates the user; it is not a server host key. `RSC-12` excludes the “ephemeral rescue credential”. Neither moves this trust decision to post-install SSH. `WIR-20`/`WIR-40` supply trust before `PRV-15`’s mandatory “reboot or reset”. Consequently, if rescue keys are fresh and unpredictable, successful advance supply has no documented practical path. Previously learned stable rescue keys would make it useful; the current boot’s key cannot predict a fresh next boot. Otherwise, use `WIR-20`’s `use_provider_keys`.

Intersection is implementable: filter caller keys by provider fingerprints, put only survivors in private known-hosts, enable strict checking, and restrict host-key algorithms accordingly. The example can negotiate Ed25519. Algorithm restriction alone does not verify identity. Honest sessions can fail if the overlapping key is unavailable or unsupported; overlap does not guarantee negotiability. ([OpenSSH](https://man.openbsd.org/ssh_config#HostKeyAlgorithms), [RFC 4253 §7.1](https://www.rfc-editor.org/rfc/rfc4253.html#section-7.1))

Amend `RSC-3`: “When both sources exist, the presented key MUST be a caller-supplied key matching an accepted provider pin.” Align `WIR-20`/`PRV-20`, `permitsPresented`, witnesses and `CNF-36`/`CNF-355`; correct the stale Cloud field name.

**Strongest case for the other side (written on request)**

ANY-PROVIDER-PIN treats overlap as corroborating server identity while allowing algorithm flexibility. Provider-API compromise is explicitly excluded (`07-security-requirements.md:21`); `ADR-0041` says “The pin is the published SHA256 fingerprints”. Unpredictable rescue keys make caller pinning largely unusable. This is not my position.

Both required unpiped gates passed; tracked files unchanged.