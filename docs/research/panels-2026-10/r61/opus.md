I vote for **option 1**: a device with no WWN and no serial comes back with `"identifier": null`. The edit is made in the clone and the gates pass (exit 0, before and after; logs are in `gate-*.log`).

**1. Vote.** Options 2 and 3 can't cover every case. `WIR-10b` gives the two rescue-entering install strategies the same `inventory` shape, so an install on disk A still reports disk B and still needs a way to show it. `RSC-26`'s last sentence assumes inventory works on a machine that "shows no unique identifier". The Lean model already fits option 1: `Device.identifier` is an `Option`, and `matching` keeps only `d.identifier == some id`.

**2. Cost of each option.**
- **Option 1** edits `WIR-10b`, `WIR-40`, `RSC-26`'s first bullet, `RSC-33` and `RSC-46`. A client that types `identifier` as a string breaks. The Lean needs nothing.
- **Option 2** contradicts `RSC-26` ("over the whole device set") unless the hashed set and the shown set differ, and the Lean `Inventory` would then need two lists. It also cuts down `RSC-33`'s report, so a machine where no disk has an identifier returns `devices: []` and looks diskless.
- **Option 3** has to change the settled capability row ("`rescue_ssh` (`RSC-38` boots rescue…)") and still needs option 1 or 2 for install results.

**3. Mixed machine (A has a WWN, B has neither).**
- **Option 1:** the caller sees A and B, with B null. It can install on A, and the fingerprint covers the same set it sees.
- **Option 2:** the caller sees only A. It can install on A, but the fingerprint covers A and B, a set the caller never saw.
- **Option 3:** the offer has an identifier, so the gate never fires. Refusing at run time would hide A as well.

**4. Static signal.** `machines.install_strategies` lacking both rescue strategies is a per-offer signal. `RSC-26`'s last-sentence machine "bought under a listed strategy" has both strategies in its recorded copy, so no form of option 3 can see it.

**5. Sort order.** "Sorted by identifier" is undefined for a null device, and ties fall back to enumeration order, which is the path order `RSC-46` excludes as "the unstable part". I changed it to "sorted by each device's own canonical JSON bytes", which is a total order. On blanks, no text said whether an empty serial is absent, and `RSC-26` treats empty serials as colliding. My edit to `RSC-46` says: "A value that is `null` or empty after this normalization is absent and matches nothing."

**6. The triage claim** is half true. Zero matches does abort. But before my edit, `RSC-46` trimmed both sides, so a caller sending `" "` got **exactly one** match on a machine whose only blank-serial disk had no WWN, and the install went ahead. No text makes a null or empty `target.identifier` `invalid_request`: `API-13` has no identifier row, and `WIR-20` says only "is a drive serial or WWN". After my edit it matches nothing, so it aborts `integrity`.

**7.** The `identifier` vs `serial`/`wwn` gap is a separate bead. Adding fields later is cheap because `WIR-2` says "clients MUST ignore unknown response fields".

**8. New `CNF-363`**, placed after `CNF-206`. Draft text:

> On a machine with disk A carrying a WWN and disk B carrying neither a WWN nor a serial, a rescue-inventory result lists both, B with `"identifier": null`, and its `inventory_fingerprint` equals SHA-256 over the canonical JSON of both devices. A `raw_disk` install naming A with that fingerprint resolves A and writes nothing to B. An install whose `target.identifier` is empty or whitespace-only aborts `integrity` with no bytes written. Repeat with B's serial whitespace-only: the result is the same. The install's own `RSC-33` report lists B with a `null` identifier.

**9. Gates and planted edits.**
- **Lean plant:** I changed `matching` so null devices also match. The gates went red: `Rescue.lean:410`, `resolves_only_the_named_disk`.
- **Markdown plant:** I deleted the new "absent" sentence from `RSC-46`. The gates stayed green; only `CNF-363`'s whitespace clause would catch it.
- With the pick restored, the final run exits 0. I also updated the `Witnesses.lean` docstring that quoted "sorted by identifier".

**10. Against my pick.** It changes an existing field's type, and `WIR-40`'s "**stable identifiers**" now covers a value that can be null. A caller also sees a disk it can't target and gets no reason why. My answer is that no conforming response exists for that machine today, so every option changes the contract.
