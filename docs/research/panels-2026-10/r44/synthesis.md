# Panel r44 synthesis — operation retention versus the provisioning guard on a temporary key (Q26), 2026-10-12

Readers: fable, opus (claude xhigh), astra, sol (codex xhigh); clones at 1f70010. All exit 0.

## Agreed (4–0)

- The Manager's counterexample is valid: `STO-14` can remove a settled create's row while its machine
  still reads `provisioning`, and `keyEligible`'s `!recordPresent ||` then bypasses the guard; the witness
  never combines the two.
- The guard is not moot after settlement: `OPS-27`'s confirming read does not establish key consumption;
  Cloud's Action window (V2) and DigitalOcean's `new` window (V18) are unverified; the 2026-10-11 Robot
  test deleted the key at `ready` and cancelled two seconds later, with no login, so it proves nothing about
  installed-key safety. Retention has no floor ("durations", `OVR-19`), so "days versus minutes" is not a
  spec fact.

## Split

- **Read the guard from `machines`; leave `STO-14` alone (fable, opus):** Decision 2's rule is already the
  conjunction; only the bullet's reason ("an unrecorded machine is never attached") is false for a
  retention-removed row (true for a row lost to a restore). `machines.correlator_value` (`operation_uuid` on
  Cloud/DigitalOcean, the per-order key's fingerprint on Robot) outlives retention; word the rule per
  operation, since Robot's caller key shares the operation id with the correlator key (opus). Lean:
  `(!recordPresent || settled) && !producedProvisioning`, built green in scratch copies by both.
- **Same predicate, plus a new machine-to-operation column (astra):** the correlator is not universally the
  operation UUID.
- **Retention exception (sol):** `STO-14` keeps a settled create until its machine leaves `provisioning`.
  Fable, opus and astra name this the strongest "don't build": a request-record purge reading provider
  state, unbounded retention.

Owner decision Q26: read the guard from `machines`, no `STO-14` change, no new column (ADR-0040's amendment
of 2026-10-12).
