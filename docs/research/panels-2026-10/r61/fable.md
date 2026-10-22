**Vote: option 1, `identifier: null`.** The spec already encodes it: `RSC-46` hashes `{wwn, serial, size_bytes}` "with `null` where a value is absent", and the Lean `Device.identifier` is `Option Identifier`. Only the wire example lacked the form.

**Costs.**
- Option 1 touches `WIR-10b` (type sentence, second device in the example), `WIR-40` (one sentence), `WIR-20` and a new `API-13` row (null or empty is `invalid_request`), `RSC-33`, `RSC-38`, `RSC-46` (sort key), `CNF-363`, one Lean theorem. Nothing withdrawn.
- Option 2 contradicts `RSC-26`'s "over the whole device set" and `RSC-46`'s null case, and hides a disk from `RSC-33`'s record of "which disk was actually overwritten". It needs a hash the caller cannot reproduce.
- Option 3 adds a gate and an error kind to `WIR-40`, `DOM-10`'s capability row, `03`'s admission rows, and leaves `RSC-26`'s last-sentence machine unanswered.

**Mixed machine.** The caller sees A with its WWN and B with `identifier: null`. An install naming A resolves and writes. The fingerprint covers both devices, exactly the list the caller sees, and removing B changes it.

**Option 3's signal.** A machine with `install_strategies` lacking both rescue strategies is a static signal, but `01-domain-model.md` gates inventory on `rescue_ssh` alone and the inventory is still the operator's record. The `RSC-26` last-sentence machine was sold under a listed strategy, so no per-offer signal sees it. No option-3 form covers it, which rules option 3 out.

**`RSC-46` sort.** "Sorted by identifier" gives a null device no position and ties no order, and two implementations would hash differently. I replaced the key with each element's RFC 8785 serialization, a total order under which equal elements are interchangeable. Empty after trimming is absent, stated there.

**Triage claim.** True only for a string that matches nothing. Nothing said what a `null` or empty `target.identifier` is. I put it in `API-13` as `invalid_request` before enqueue, with `WIR-20` pointing there. `integrity` would misreport a malformed body as a stale inventory.

**`identifier` versus `serial`/`wwn`.** `WIR-10b` now defines `identifier` as the WWN else the serial, matching "MUST prefer WWN". Carrying both fields on the wire is a separate bead. `RSC-33` now names serial and WWN, each `null` where absent.

**CNF.** New `CNF-363`, placed after `CNF-206`. It asserts: both devices listed, B null; fingerprint differs without B; install on A writes; null or empty identifier is `invalid_request` before enqueue; a string no device carries aborts `integrity`; the report lists B.

**Gates.** Pick applied, full gate exit 0, log in `gate-pick.log`. Bad edit one: `matching` treats a `none` device as matching any identifier. Formal went red at `resolves_only_the_named_disk` and at the new `unidentified_device_never_resolves`, exit 1. Bad edit two: prose saying an empty identifier names the null device. Every Python gate stayed green. Only `CNF-363` catches that, since no gate reads semantics; a fenced fixture would at least be parsed, and `WIR-10b`'s example is inline and unchecked by `check_fixtures.py`.

**Against my pick, as written on request.** Every rescue client must now handle a nullable field and a device it can see but never name. A null device still carries path, size and model, which invites a client to fall back to naming by path, the exact defect `RSC-26` exists to kill. Option 3 would keep such a machine out of the rescue flow entirely, and `install_strategies` already exists as its signal for the declared case.
