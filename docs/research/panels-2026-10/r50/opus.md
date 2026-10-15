# Q33: when a Robot caller also supplies host keys, which presented key may the session accept?

My vote is **INTERSECTION**: the presented key must be one of the caller's keys and must also match a provider pin. No owner text decides this today. I didn't run the gate because I changed no tracked files.

**1. What the text says**
- **There is one field.** It is `trust.expected_host_keys` (`13-wire-contract.md:681`), and `WIR-40` reuses the same `trust` object. `API-13` requires "each a complete OpenSSH public host key". The name `expected_rescue_host_keys` at `08-provider-notes.md:73` exists nowhere on the wire.
- **Only Robot publishes keys.** Cloud and Cherry say "not exposed" (`08:72`, `:223`), and DigitalOcean has no rescue API (`08:280`).
- **Row 1 of `RSC-3` can't happen on Robot.** A Robot session still waiting for pins aborts (`PRV-20`; `sessionDecision` in `Rescue.lean`). So caller keys on Robot always land in row 3, and in v1 only Robot reaches row 3.
- **The brief's Lean claim needs a correction.** With `providerPinsRequired = true`, the overlap arm `(c || d) && (!req || d)` reduces to `d`. The model therefore already admits ANY-PROVIDER-PIN on Robot, but it states only necessary conditions, so it settles nothing.
- **No owner text decides it.**
  - `RSC-3` (`06-rescue-install.md:93-94`), `PRV-20` and `CNF-355` make a provider match *necessary*. None makes it sufficient.
  - The text that only points at `RSC-3` leans toward INTERSECTION. `WIR-20` says "Pin caller-supplied full keys", and ANY-PROVIDER-PIN breaks that in the ecdsa scenario.
  - Row 1's "Pin exactly those" never says the driver published none.
  - Comment 561 on pv-f6g records this reading as an owner follow-up.

**2. When a caller can supply keys**
- **Never for the installed OS.** Provisiond's sequence ends at end rescue (`06:53-55`), and `RSC-12`/`RSC-13` cover authorized keys, not host keys.
- **Provisiond can't hand the caller rescue keys either.** Robot publishes only fingerprints while `API-13` requires full keys, and no wire field returns the presented key.
- **The only source is the caller's own SSH into an earlier rescue.** That helps only if a server's rescue keys stay fixed, which `ADR-0041` marks "Not established".
- **If the keys are fresh per boot, the case is effectively unreachable.** Every Robot request carrying caller keys then fails `integrity`, after activation has already rebooted the server (`06:38-45`). That hurts both candidates equally. It decides whether to refuse the field at admission, not which key to accept.

**3. Can a stock SSH client do "only keys in both"?** Yes:
- `RSC-8`'s per-operation known_hosts file gets only the caller keys whose algorithm and SHA256 match a provider pin.
- Set `StrictHostKeyChecking yes`.
- Set `HostKeyAlgorithms` to those keys' algorithms only.

Under RFC 4253 §7.1 the client's list decides the algorithm, so the server presents ecdsa only if the engine offered ecdsa. The brief's scenario comes from client configuration. One trap: an `ssh-rsa` key needs `rsa-sha2-512,rsa-sha2-256` in that list. No honest session fails, because the booted server's own record lists the overlapping key.

**The attack:** a forged record lists the caller's real ed25519 fingerprint plus an attacker's ecdsa one, and the attacker presents ecdsa. Only INTERSECTION refuses it. Under ANY-PROVIDER-PIN, caller keys never limit which key is accepted; they can only make the session fail.

**4. Vote: INTERSECTION.** The changes it needs:
- **`RSC-3`:**
  - Row 3 gains a closing sentence: "On overlap, pin exactly the caller keys whose algorithm and SHA256 digest match a driver pin." Putting it last keeps `WIR-20`'s quote at `13-wire-contract.md:690` intact.
  - Row 1 gains "and the driver published none".
  - The sentence at `06:93-94` stays. It becomes redundant but is still true, and `13-wire-contract.md:681` quotes it.
- **`Rescue.lean`:**
  - The overlap arm becomes `caller.contains presented && driver.contains presented`, and the `providerPinsRequired` condition in it disappears.
  - Every "without choosing" docstring goes: `Rescue.lean:28`, `:113` and `:157`, and `Witnesses.lean:3063`.
  - Add the witness `permitsPresented current true [⟨1⟩] [⟨1⟩, ⟨2⟩] false ⟨2⟩ = false`, in `pinnedConn`'s shape, with a CI control.
  - The strings at `ci.yml:938-939` change too.
- **`CNF-355`:** add the ecdsa case.
- **Contingent:** if the planned double rescue shows per-boot keys, refuse `expected_host_keys` at admission for drivers whose pins change every boot.

**5. Strongest case for the other side (written on request).** `ADR-0041` says "The presented-key match is what makes the connection safe." The record is one TLS-authenticated response from the provider, which owns the hardware and is already trusted, so one overlapping key vouches for the whole record. INTERSECTION only protects against a forged record, and in practice the forger would be the provider, which controls the machine anyway. `PRV-20`'s "MUST pin the matching presented full key" reads as sufficient. ANY-PROVIDER-PIN also keeps one path (keyscan → match → pin) for both trust variants, with no algorithm-list plumbing.

I saved this answer as `panel-q33-opus.md` in the clone, untracked.
