**Verdict:** The triage is right, and the hole is wider than filed. Fix it with (b), an account-level attachment pass guarded on the provider's own assignee field, plus one sentence in `PRV-45`.

**Why**

1. **The tombstone is the point of no return.**
   - A throttled listing writes no rows.
   - A provider termination or a scheduled delete never lists at all, because `PRV-45` runs only "on every delete that succeeds with the resource gone".
   - With zero rows, `STO-18` and `LDG-32` are satisfied trivially, so the machine is tombstoned and its commitment closes.
   - After that, `OPS-32` visits only machines "still retained by `STO-18`", and `API-65` acts only on rows that already exist.
2. **The bug's "settles `failed`" is out of date.** Nothing classifies a failed listing. Read literally, `OPS-11`'s acceptance bullet (03:270) gives `needs_reconciliation`, which pages an operator about a delete whose outcome is known. Resolving it `applied` (03:1075) still runs no listing.
3. **It may be every Robot delete.**
   - `PRV-45` says a date given as a day only "names the end of that day UTC", and Q18 says "Robot's `now` returns a date".
   - `PRV-13` (02:180) requires a driver to surface a scheduled cancellation's date.
   - If the Robot driver surfaces it, every Robot delete takes `OPS-48`'s scheduled row and never lists. The live test found "Immediate destroy, no scheduled tail" (08:407). Nothing in the spec says which reading applies.
4. **It is mostly an accident path.**
   - The customer pays nothing, because no attachment has a customer rate in v1 (Q18).
   - The operator pays rent with no end date, but only if batch B step 9 shows the `primary_ipv4` add-on outlives its server. That add-on is the only IP provisiond orders.
   - A tenant gains nothing. Each attempt to trigger the path costs a paid machine, under ADR-0036's limit of twenty orders a day.
   - Q18 accepted "operator rent until its `cleanup: api` cancellation". This hole never issues that cancellation.
5. **The options.**
   - **(c) fails.** The listing runs outside the gone-write transaction, so when it fails nothing is left to retry.
   - **(a) can strand the customer's balance.** *List attachments* takes a machine `external_id` (02:518), the Robot mapping is unspecified, and a cancelled server answers `404` (08:407).
     - Treated as a failure, the machine is retained forever, which `LDG-32` itself says "strands a customer's satoshis permanently" (12:334).
     - Treated as an empty listing, the assurance is false.
   - **(b) costs two reads per pass**, `GET /ip` and `GET /subnet`, which a listing for a gone server would need anyway.
     - A Robot IP's identity is its address (`POST /ip/{ip}/cancellation`), and `STO-41` records every address provisiond "has **observed** on a machine".
     - So (b) also reaches machines tombstoned before the fix, within `STO-43`'s retention.

**Defects**

- 02:528-530: no rule for a failed listing, and zero rows look the same as "never listed".
- 05:357-359 and 12:308-310: `STO-18` and `LDG-32` are satisfied trivially when there are no rows.
- 03:1367-1377: the sweep never inserts an attachment row or enqueues a release. There is also no account-level pass for attachments, unlike images and keys (03:1431, 1436).
- 12:570-573: calls a terminated machine leaving volumes behind "the ordinary case", yet nothing lists attachments on that path.
- 03:1072 with 02:544-546: the spec does not say whether Robot's `now` delete is immediate or scheduled.
- 02:518: *list attachments* is undefined for a machine that is gone.
- 04:1099-1100: "`WIR-10a`'s set gains no member" is false for a release the sweep finds.
- 10:312 and 10:1422: CNF-65 and CNF-293 test only a listing that succeeds.

**Edits**

1. **`PRV-45`:**
   - Add: "A listing that fails leaves the delete's outcome its own; `OPS-32`'s attachment pass finds what it missed."
   - Give *list attachments* an account-wide form that returns each resource of a surviving kind with its provider-side assignee.
2. **`OPS-32`:** every pass lists the account's attachments.
   - Release an unrecorded entry only when both hold:
     - its **provider-side** assignee is null or a machine recorded gone here;
     - its assignee or its `machine_addresses` identity ties it to such a machine.
   - For billable `api` entries, one transaction inserts the row and enqueues `release_attachment`. Presence is positive evidence, so no completeness guard is needed.
   - Report an entry assigned to any live `server_number`, and never release it. That matches 03:1413's treatment of unrecorded machines and keeps `OPS-29` exact.
3. **`STO-18` and `LDG-32`:** a row found after the tombstone reopens neither the tombstone nor the commitment.
   - Rows the inline listing wrote still hold the commitment (10:3270); rows found later don't.
   - Q18 gives attachments no customer rate, so a late row's rent is `LDG-75`'s operator gap until the release.
4. **`WIR-10a`** (13:263) gains the `system_reason` value `attachment_cleanup`. The column note in `05-persistence.md` points at that list rather than restating it.
5. **`08-provider-notes.md`:** state that Robot's `now` delete is immediate (08:407), or route it to `DOM-19` explicitly.
6. An amendment to ADR-0035 or ADR-0037 closes ADR-0035:79.

**Strongest "don't build"**

If step 9 shows the add-on dies with its server, v1 has no instance of this bug. But (b) is correct whatever step 9 shows. It costs two reads per pass and also catches IPs the operator added by hand.

**Lean and CNF**

Nothing in `tools/formal/` models `STO-18` or attachments. `LDG-32`'s tag (Ledger.lean:172) covers only the release arithmetic. The model must prove four things:
- after one pass, an attachment the provider still holds for a gone machine is recorded and its release enqueued;
- no release reaches an attachment held by a live server;
- a failed listing never changes a delete's status;
- without the pass, the trace [2xx delete, `rate_limited` listing, gone-write, tombstone, sweep\*] leaves the attachment unrecorded forever.

A new CNF item runs three cases, each with a surviving `primary_ipv4`: a delete whose listing is `rate_limited`, a provider termination, and a delete dated `now`. In each case it asserts:
- the delete settles `succeeded`;
- the next pass writes the row and enqueues one `system` release;
- there is no customer debit;
- a live server's IP is untouched;
- an IP that cannot be attributed is reported, not released.

CNF-65's "every delete that succeeds" becomes "every machine recorded gone".

The gates all pass at dec039f (exit 0). Two untracked scratch files are in the clone: this report as `panel-pv-ucs4-opus.md` and the gate output as `gate-baseline.log`.
