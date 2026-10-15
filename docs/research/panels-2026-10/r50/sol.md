**Vote: INTERSECTION. Refuse that ECDSA key; negotiate the shared Ed25519 key.**

`WIR-20` says “Pin caller-supplied full keys”; `RSC-3` says “Pin exactly those” and “The actual Robot connection MUST match an accepted provider pin”. My cumulative reading already requires intersection. However, the both-supplied row says only “They MUST overlap”, leaving the selection implicit. `PRV-20`’s “match none of the accepted pins MUST be refused before authentication” supplies a necessary condition, not blanket permission to accept every provider key.

The formal Robot branch actually reduces to provider membership: `(C ∨ P) ∧ P = P` ([Rescue.lean:168](https://github.com/douglaz/provisiond/blob/6a4644a614d95591c51f02ca0b5686162985b3a2/tools/formal/Provisiond/Rescue.lean#L168)). Its “without choosing which set is pinned” disclaimer and `pv-f6g`, comment 561, deliberately preserve this question. Green gates therefore do not resolve it.

Relevant surrounding owners include `PRV-15/16/19`, `DOM-11`, `RSC-4/7/8`, `API-13`, `SEC-22/23`, and `WIR-2/40`. `RSC-5` prohibits being “silently downgraded to first-use trust”; `RSC-6` compares “algorithm and SHA256 digest”; `RSC-9` derives waiting from “the boot timeout”. Conformance includes `CNF-36` (“Every row”), `CNF-37` (“never downgraded”), `CNF-38` (“comparison is canonical”), `CNF-39` (“wait deadline scales”), and `CNF-355` (“require the actual Robot connection to match a provider pin”). None explicitly tests this asymmetric presentation. Abort consequences also involve `OPS-11/45`, `PRV-18/21/22`, `RSC-18/19`, and `CNF-31a/279`.

Robot alone publishes rescue pins among the documented v1 drivers (`ADR-0010`; `08-provider-notes.md:72,129,280`). The notes’ `expected_rescue_host_keys` denotes the same concept, but the wire spelling is `trust.expected_host_keys` (`WIR-20`); `WIR-2` says “Unknown fields in a request body MUST be rejected”. They are not separate accepted fields. `RSC-12`’s “ephemeral rescue credential” and `RSC-13`’s “authorized key for the installed system” concern login credentials, represented separately as `authorized_keys` (`13-wire-contract.md:698`).

A realistic caller could supply independently authenticated rescue keys retained from an earlier boot **if they persist**. If every boot generates unpredictable fresh keys, the ordinary preboot request cannot know them; both-supplied rescue trust has no normal successful path. Rotation remains unverified (`ADR-0041:27`). Ordinarily use `use_provider_keys`; supplied expectations should constrain the upcoming rescue identity, rather than describe the installed OS (`WIR-20`).

Intersection needs ordinary SSH settings: filter caller keys against provider fingerprints, populate private known_hosts with that subset, enable strict checking, and restrict negotiation—here `HostKeyAlgorithms=ssh-ed25519`. Algorithm restriction alone cannot pin key bytes ([ssh_config(5)](https://man.openbsd.org/ssh_config#HostKeyAlgorithms)). Local probes verified the shared key, rejected different Ed25519 bytes, and failed when Ed25519 was disabled (results:3,13,21 (reader scratch file `results.json`, not kept)). Thus an honest session can fail when its shared key is unnegotiable; algorithm preference alone need not cause failure.

Amend `RSC-3`’s caller-only and both-supplied rows: “With both sources, the presented full key MUST belong to the caller set and match an accepted provider pin.” Align `WIR-20` and `Trust.permitsPresented`; add asymmetric `CNF-36/355` cases.

**Strongest case for the other side (written on request)**

ANY-PROVIDER-PIN treats overlap as corroborating one rescue identity, with Robot attesting its alternative keys equally (`ADR-0041:43`). It avoids algorithm-dependent honest failures. That policy requires changing `WIR-20`’s “Pin caller-supplied full keys” into a consistency-check promise. This is not my position.

Both unpiped gate runs passed; tracked files remain unchanged.