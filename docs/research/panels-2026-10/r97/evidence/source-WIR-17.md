**WIR-17** **AMENDED** `POST /v1/machines` — create:

```json
{
  "provider_account": "hetzner-robot-1",
  "offer": "market:12345",
  "region": "fsn1",
  "hostname": "worker-1",
  "image": null,
  "ssh_public_keys": ["ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIexamplekeyxxxxxxxxxxxxxxxxxxxxxxxx"],
  "user_data": null,
  "labels": {"team": "batch"},
  "runway_seconds": 2592000,
  "max_commitment_sats": 90000,
  "acknowledge_purchase": true,
  "provider_options": {}
}
```

This create uses `WIR-30`'s `"market:12345"` Robot default-uplink offer; the
running operation (`WIR-10`) and resulting machine (`WIR-11`) show the same
purchase at later stages. `WIR-30` says "the commitment is priced at accept
time"; its earlier listing quote is indicative.

`ssh_public_keys` MUST be non-empty (`PRV-8`, `API-13`). `acknowledge_purchase` MUST be literal
`true` (`API-15`, `PRV-10`). `image` (nullable, a catalog identifier), `user_data` (nullable,
≤1 MiB, `API-13`) and `labels` (string→string; the correlator's reserved key is the driver's, `PRV-26`, and a caller
label colliding with it MUST be rejected, `OPS-38`) are the create inputs
the other requirements accept and this body previously omitted — under `WIR-2` a conforming server
would otherwise reject them. `runway_seconds` is `PRV-13d`'s caller-chosen runway; a value **below**
the wind-down floor MUST be **rejected** `invalid_request` with `details.min_runway_seconds`, never
silently raised — silently reserving more of a caller's money than it asked for is a money bug.
`max_commitment_sats` (optional) caps spend: if the computed commitment exceeds it the request
fails `invalid_request` (not `insufficient_balance`) **before** any commitment opens, so an agent
can bound a purchase priced at an attacker-influenceable rate (`LDG-41`). `WIR-9a` owns its
cap details; `API-7` owns tail combination and ordering.

*`WIR-18` — `POST /v1/machines/adopt` — is withdrawn with adopt (`ADR-0020`). It returns as a
synchronous operator route in `API-48`'s list, answering with the machine view.*

