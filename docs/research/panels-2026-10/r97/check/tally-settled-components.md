# r97 settled components only — not a complete execution authority

Q2d/e and Q4 remain unresolved. Do not apply or launch the Run from this partial record.

## R-MASTER-directive.txt
`````text
Changes from Form C: the `WIR-17` field rules opening, `CNF-34` and the `CNF-342` acknowledgement paragraph are **Retain verbatim**, meaning this package does not edit them. For execution at `2e2cd94637112f20538eb26b141672fedf0ba455`, retain their complete current master text, including PR #60’s install-marker fixture in `CNF-34`; the printed 3109b5b blocks below are historical comparison text. Every other block is identical to Form C except for the exact quotation corrections selected in Panel R r97.
`````

## R-MASTER-comment-sentence.txt
`````text
CNF-34 and CNF-342’s acknowledgement paragraph are not edited by pv-9ecf: retain their complete master text at `2e2cd94637112f20538eb26b141672fedf0ba455`, including PR #60’s install-marker fixture in CNF-34. C′’s retained create coverage remains **"On separate creates"** in CNF-34 and **"complete, valid resource-offer"** in CNF-342.
`````

## R-MASTER-comment-placement.txt
`````text
**Historical approval record — original wording at 3109b5b:**

`docs/research/panels-2026-10/r89/r89b/owner-questions.md:28`:

> The wire rule remains the pin's unconditional **"`acknowledge_purchase` MUST be literal `true` (`API-15`, `PRV-10`)"** ([WIR-17](consistency/13-wire-contract.md#L665)). CNF-34's **"On separate creates"** and CNF-342's **"complete, valid resource-offer"** acknowledgement fixture also remain byte-identical to the pin. C′ keeps existing acknowledgement coverage on a modeled create that starts no provider billing, rather than silently exempting it. Paid-create coverage and the broader wire rule are compatible: the new API-15 says paid requests **"MUST carry"** acknowledgement, not that only paid requests must carry it. This broader wire/narrower provider layering already existed at the pin.

**Current execution guidance — Panel R r97:** CNF-34 and CNF-342’s acknowledgement paragraph are not edited by pv-9ecf: retain their complete master text at `2e2cd94637112f20538eb26b141672fedf0ba455`, including PR #60’s install-marker fixture in CNF-34. C′’s retained create coverage remains **"On separate creates"** in CNF-34 and **"complete, valid resource-offer"** in CNF-342.
`````

## authority-replacement.txt
`````text
Original adopted form: `docs/research/panels-2026-10/r89/r89b/form-Cprime.md`, SHA-256 `be350270318a2752992a9cb199a2a56879249be99f36e7af430bcfe8a1d47a32`, reviewed at `3109b5b44eae17e288cf52aaa976993bd8c5626c`. Executable wording uses the exact per-question selections recorded in Panel R r97 under the owner’s 2026-10-28 wording rule. Item 24’s complete "Hourly cloud cases" block and item 4’s policy remain approved; the original form remains the historical approval record.
`````

## Q2a Q-QUOTE
`````text
The configuration half is `DOM-10`'s gate on the create's ordering capability (`DOM-16`); `DOM-10` says “Every operation with a capability MUST be gated on it before the
driver is called, **including create**”. At admission, step 5d is the gate: `API-7` says “**gate a create on its ordering capability** under `DOM-10` (`PRV-10`, `DOM-16`). A refusal stops here and is not collected by the tail”. At claim, step 3 is the gate: `OPS-43` says “Repeat boundary validation under `OPS-23`: "Validation that was performed at the API boundary
   MUST be repeated in the worker before the driver is called". This includes `PRV-10`'s
   "explicit purchase acknowledgement", `PRV-8`'s "at least one SSH public key", the missing-field
   checks defined in `OPS-23`, and `DOM-10`'s gate on the create's ordering capability, which is
   `PRV-10`'s "the account is configured to allow ordering". The checks on caller-supplied fields
   run first, then the checks on fields the `api` wrote at admission, then the capability gate”.
`````

## Q2b Q-QUOTE
`````text
Until 2026-09-05, `API-15` said “purchase acknowledgement in its provider options, in addition to the account being
configured to allow ordering (`PRV-10`).” (revision `7116e90b9932211c08f2e712690cc176b56edea6`); at that same revision, `WIR-17` said “`acknowledge_purchase` MUST be literal
`true` (`API-15`, `PRV-10`).” and placed the acknowledgement at the top level in this create body: “{
  "provider_account": "hetzner-cloud-1",
  "offer": "standard:cx32",
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
}”. The wire contract wins, and a spending authorization nested inside a driver-private object is one a strict server could not tell from any other option.
`````

## Q2c Q-QUOTE
`````text
While it is still queued and unclaimed, restart with a descriptor for that account that
      removes only `list_offers`, keeping the ordering capability declared and the driver's
      List offers code path answering, so the test proves the gate exists, as `CNF-19` does (`CNF-19` says “Create is refused when the provider has not declared the matching
      provision capability — with the driver's internal ordering flag set to permissive,
      so the test proves the outer gate exists.”).
`````

## Q3 S-OUT
`````text
Leave both CNF-18 sentences unchanged. They are inherited source text C′ retains, outside this package’s added/changed-text audit under main’s 2026-11-02 18:40Z ruling. No bead.
`````
