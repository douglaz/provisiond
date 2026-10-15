# Panel brief: which presented host key may a Robot session accept when the caller also supplied keys? (Q33), 2026-10-14

You are one of four independent reviewers. The working directory is a throwaway clone of the
specification repository `provisiond-spec` at `6a4644a` (branch `robot-live-2026-10-12`). Read `AGENTS.md`
first. Do not edit tracked files; write scratch files only inside this clone (never `/tmp` or `/var/tmp`).
You may run the gates (`nix develop --command bash tools/check-all.sh`, unpiped). Never call a provider API.
This owner repeatedly shows my framing wrong with a first-principles question and dissolves machinery rather
than tuning it; check this framing too, and verify every fact stated below before relying on it.

## The question

A caller asks provisiond to rescue (or install onto) a Robot server and supplies expected host keys, say one
ed25519 full key. Robot publishes SHA256 fingerprints for the rescue system's keys after boot
(`GET /boot/{n}/rescue/last`, `ADR-0041`), say ed25519, ecdsa and rsa. They overlap on ed25519. The server
then presents its **ecdsa** key, which matches a Robot fingerprint but is not the caller's key. Accept and pin
it, or refuse?

- `PRV-20` (02-provider-contract.md, amended 2026-10-12): "a presented key whose SHA256 fingerprint and
  algorithm match none of the accepted pins MUST be refused before authentication. The engine MUST pin the
  matching presented full key for the connection. Robot never falls back to first-use trust, including when
  caller keys are supplied."
- `RSC-3` (06-rescue-install.md): the table's both-supplied row "They MUST overlap. No overlap is an
  `integrity` failure"; first row "Pin exactly those"; and the 2026-10-12 amended paragraph on fingerprint
  overlap.
- `WIR-20`'s cell for `{"expected_host_keys": [...]}` (13-wire-contract.md): "Pin caller-supplied full keys".
- `Rescue.Trust.permitsPresented` (tools/formal/Provisiond/Rescue.lean, fixed by pv-f6g) admits a key in the
  caller set OR the driver set for the overlap row and deliberately does not choose; pv-f6g's ticket records
  this as an owner follow-up.
- `08-provider-notes.md` near line 73: on Hetzner Cloud a caller "MUST supply `expected_rescue_host_keys` out of
  band or explicitly accept first-use trust" — so in v1 only Robot publishes driver keys, and the
  both-supplied case may arise only on Robot. Verify, and check whether `expected_host_keys` and
  `expected_rescue_host_keys` are the same field or two.
- Whether Robot's rescue host keys are fresh per boot is still `[verify]` (ADR-0041). If they are, a caller
  can rarely know them in advance.

## What I need from you

1. Verify the facts and find every requirement that bears on the both-supplied case (`RSC-3`, `RSC-5`,
   `RSC-6`, `RSC-9`, `PRV-20`, `WIR-20`, any CNF item). Does any text already decide it?
2. When does a caller realistically supply expected keys for a Robot session (rescue vs the installed OS
   after `RSC-12`/`RSC-13`)? If rescue keys are fresh per boot, is the both-supplied case for rescue reachable
   at all, and what should a caller's keys mean there?
3. Is "only keys in both" implementable with an ordinary SSH client (e.g. restricting host-key algorithms to
   the overlapping keys), and does it fail any honest session?
4. Your vote: INTERSECTION (presented key must be a caller key AND match a provider pin), ANY-PROVIDER-PIN
   (caller keys must overlap; then any provider-pinned key is accepted), or a named OTHER (e.g. caller keys
   ignored or refused for Robot rescue) — with the requirement text it would change.
5. Then, labelled "Strongest case for the other side (written on request)", the best argument against your
   vote. It is not your position.

Under 600 words. Cite `file:line` or identifiers for every claim.
