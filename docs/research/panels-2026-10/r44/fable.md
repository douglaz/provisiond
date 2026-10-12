**Verdict:** Neither candidate. A vanished row counts as *settled*; the provisioning conjunct reads the machine row, which retention never touches. Fix one false rationale sentence and the Lean predicate. Leave `STO-14` alone.

**Why**

- `PRV-9`'s rule sentence already says "settled or vanished **and** no machine it produced still reads `provisioning`". Its verbatim copies in `OPS-32`, `DEF-6` and ADR-0040 Decision 2 agree. The contradiction lives only in the rationale "because no machine from an unrecorded operation can be attached", which is false for retention: the machine was attached before the row aged out. The r31 panel added that bullet with no scenario; the case it fits is a backup restore under `STO-54`, where the machine row is gone too.
- The guard does not need the operation row. `machines.correlator_value` holds the operation id on Cloud and DigitalOcean per `PRV-26`, and the per-order key's fingerprint on Robot per `PRV-32`, indexed "for reconciliation lookup". Every tagged key carries the operation id per `PRV-9`. The Manager's "association must survive" is already true, and the brief's op-id column is unnecessary.
- Is the key needed after settlement? Robot: the order carries a copy, and the r39 live result lists the full key object after deletion. A Robot create attaches only after the transaction reads `ready` with a server number and `OPS-27`'s confirming read, so it never settles mid-install. The live test cancelled the server two seconds after deleting the key, so it proves nothing about reachability. Cloud: "injected at creation" is documented; the Action window is V2 PARTIAL. DigitalOcean: "embed upon creation" is documented; the `new` window is V18 PARTIAL. Cherry, where `DEF-6` originated, is not a v1 driver per `OVR-14`. So the guard covers an unverified window of minutes on two providers, and ADR-0040 chose to hold it until the live batches. Delete the guard and `producedProvisioning` when V2 and V18 run green; this question disappears with them. Not before, since that re-litigates ADR-0040 on no evidence.
- "Retention age measured in days" is not in the spec. `OVR-19` lists "Retention windows … durations" with no floor. Candidate 2 makes the sweep flip at an unbounded knob and reopens `DEF-6` for any deployment whose age is shorter than a deploy window. Candidate 1 couples an `api` request-record purge to a provider cache state that may never clear. The conjunctive rule depends on neither.
- `provisioning` is a weak proxy: `DOM-7` buckets "migrated" there, so a Cloud live migration months later reads it. Harmless under the conjunctive rule, and one more reason to delete the guard later rather than invest in it.

**Defects**

1. `02-provider-contract.md:139` rationale false after retention.
2. `docs/adr/0040-…md:40` same bullet.
3. `tools/formal/Provisiond/Rescue.lean:972` `keyEligible` lets a vanished row override the guard, contradicting the `PRV-9` sentence it is tagged with; docstring at `:965` repeats the false rationale.
4. `tools/formal/Provisiond/Witnesses.lean:3044` no witness for the conjunction, as the Manager found.
5. `03-operation-lifecycle.md:1459` "a vanished record requires sweep deletion" is unconditional.
6. `10-conformance-checklist.md:2447` the vanished-row trace has no provisioning machine.

**Edits**

- `PRV-9:139`: "A vanished operation record counts as settled. The machine a key produced is the one whose `correlator_value` is the key's operation id or the fingerprint of a key tagged with it; that column outlives `STO-14`'s deletion of the row, so the guard does."
- ADR-0040:40: same, as a dated Q26 amendment.
- `Rescue.lean:972`: `(!w.recordPresent || w.status == .succeeded || w.status == .failed) && !w.producedProvisioning`; fix docstrings at `:965` and `:1017`.
- `Witnesses.lean:3044`: add `{ settled with recordPresent := false, producedProvisioning := true }` retained. Built in a scratch copy under `nix develop`: both modules compile, theorems and `decide` witness pass.
- `OPS-32:1459`: "a vanished record counts as settled; the guard still reads the machine row".
- `CNF-303:2447`: age the settled create's row out under `STO-14` while its machine reads `provisioning`; assert the key remains; clear the guard by observation; assert deletion.

**Don't build:** no retention exception or deferral, no new association record or machine column, no retention-age floor. The association exists today, and a request-record purge must never decide the fate of a provider-side credential.
