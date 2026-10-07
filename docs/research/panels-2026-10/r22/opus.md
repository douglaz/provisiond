**Verdict: (a′).** Withdraw `billing_stop_window` and `STO-53`'s `kind` column, as (a) proposes. Keep the twenty-sample procedure, which moves to `PRV-36`. Size wind-down to when the machine is recorded gone, not to when the provider accepts the delete.

**Why.** `protected_sats` (12:331-337) funds the customer's meter, and that meter stops when the engine writes the machine gone:
- `LDG-74`: "Billing stops at the observation instant" (12:510);
- `LDG-38`'s exit rule (12:873-878);
- `OPS-48`'s "`succeeded`, resource gone" (03:1026).

Whatever the provider bills after that falls on the operator: the started unit's remainder, which `ADR-0033` accepts as a residual. So no money term needs the provider's billing-stop instant, and no engine read can see it.

The interval that matters is dispatch to recorded gone, and `PRV-36`'s effective window already declares and samples it. `STO-53` writes a sample when "an ordinary mutation's effect is first read back" (05:481-483), deletes included. Nothing writes `billing_stop` rows. So (b) named the right quantity. Its fault is the second name and the second field, which bring back the conflation 02:831-834 forbids.

**Defects in the framing**

1. **"`wind_down_cost` becomes dispatch→accepted."** This under-reserves.
   - The meter keeps debiting through `deleting` until the gone-write. `LDG-37` leaves billable states to the deployment, and no text makes `deleting` non-billable.
   - `LDG-31`'s clamp then turns the gap into an operator deficiency.
   - That is the trap recorded at 02:217-227: a premise "used to shrink a number every machine's reserve depends on".
2. **"Billing stops when the provider accepts the delete."** Neither Hetzner product says so.
   - **Hetzner Cloud:** `DELETE /servers/{id}` returns an action whose status is `running|success|error`, and "If an action fails, it will contain details about the underlying error" (https://docs.hetzner.cloud/cloud.spec.json). The FAQ's "until you delete them" names no instant.
   - **Robot:** "If a product still exists on your account, we will invoice you for it … you need to actively delete or cancel it" (https://docs.hetzner.com/general/others/new-billing-model/, last changed 2026-10-01). That ties billing to existence, not to acceptance.
   - 02:264 already says "An action reporting `completed` does not establish that billing stopped".
3. **"A declared shape (`PRV-13`), observed through `ADR-0035`'s `accepted`."**
   - `PRV-44` has no field for the deletion shape (02:59-66).
   - `accepted` is reported "on every error" (ADR-0035:33). It decides ambiguity; it is not evidence of success.
   - The shape is read per call: from the action result's "effective cancellation date" (02:147), and on Robot from `cancelled` and `earliest_cancellation_date`. That is the read-and-branch `PRV-13c` asks for.
   - Declaring "stops at acceptance" as a constant would breach 02:396, which lists "cancellation immediacy" among the terms that must not be constants.
4. **"Withdraw `F18`'s twenty-deletion procedure."** `PRV-36` borrows it: "under `PRV-13b`'s procedure — the worst observed request-to-observation latency over at least twenty real mutations" (02:811-813). Withdrawing it leaves that citation pointing at nothing.
5. **"Audited by `LDG-75`'s invoice true-up."** `true_up_minor` is computed per account, currency and month (12:1942-1946), and `LDG-75` adds "no new cost writer, alarm or coverage machinery" (12:1956). It is an aggregate check, not an audit of any one machine.
6. **"What remains is only the started unit's remainder."**
   - Robot add-ons bill "per day or part thereof", while `ADR-0033`'s residual (0033:73) covers the machine only.
   - Robot IPs and subnets accept a future `cancellation_date` and report `earliest_cancellation_date` (https://robot.hetzner.com/doc/webservice/en.html). That is `PRV-13`'s scheduled shape on an attachment, yet `PRV-45` writes `released_at` on any success (02:438).
   - No latency window sees either case, so the verdict stands. But (a′) must not extend "stops at acceptance" to attachment releases.

**Answers**

- **Readers.** `PRV-44` (02:63), `PRV-13b` (02:162-170), `PRV-36` (02:831-834), `STO-53` (05:474), `CNF-292` (10:1213-1214), 08:5 and 08:305-308, `ADR-0018`:28 and :55, and the research doc (§3 and line 697).
- **Does anything size money from it?** Not by citation. The `wind_down_cost` paragraphs (02:217-282) never cite it; the only link is the word "measured" at 02:229.
- **What breaks if it goes.** Three things: `PRV-36`'s procedure citation, `CNF-292`'s clause, and the referent of 02:229.
- **Other readers.** None needs it. `PRV-29`'s freshness rule and `OPS-27` read only `PRV-36`'s window. `PRV-13c` reads the "wind-down bound" (02:403). `DOM-19` prices to the effective date.
- **DigitalOcean.** "ends when you destroy it" is verified (https://docs.digitalocean.com/products/droplets/details/pricing/). The droplet still read `active` 8 s after the `204` (08:302-304). That doesn't matter here, because the customer's meter runs until the gone-write.
- **Attachments.** Still covered by `released_at` and `LDG-32`, except the scheduled releases in defect 6. The README's withdrawn table says nothing about billing stop.
- **`ADR-0018`.** Its max-of-declared-and-observed rule survives for visibility. Only one sentence goes: "The same shape serves `PRV-13b`'s billing-stop window" (0018:28).
- **Deleting more.** With `billing_stop` gone, `STO-53`'s `kind` column has one value left, so drop it. The primary key becomes `(operation_id)` and the index `(provider_account)`. No reader filters on `kind`; Restore.lean:287 only counts passes.
- **Formal layer.** Nothing to change. `Reconcile.Windows` holds only `visibility` and `negative` (Reconcile.lean:96-99), and `Runway` takes `protected_sats` as an opaque input (Runway.lean:11). All 7 gates pass at `e43f42c`.

**Edits for (a′)**

- **`PRV-13b`:** split "measured worst-case delay before cost actually stops" in two:
  - the time until the customer's meter stops, which wind-down funds: `PRV-36`'s effective window;
  - the remainder the operator absorbs, bounded by `ADR-0033`'s declared unit `{seconds, native_floor}`.
- **`PRV-44`:** `ADR-0033`'s unit field takes the place of `billing_stop_window`.
- **02:229:** "measured confirmed-cancellation latency" becomes "`PRV-36`'s effective window".
- **`PRV-29`** (02:263-265): rewrite the third fact rather than delete it. For the machine, the gone-write; for an attachment, `released_at`; for the scheduled shape, the effective date.
- **`PRV-36`:** takes ownership of the procedure. Its "still owed" sentence becomes a dated trap record.
- **`PRV-45`:** a release whose result carries a future effective date writes no `released_at`.
- **`STO-53`:** drop the `kind` column.
- **`CNF-292`:** drop its `billing_stop_window` clause.
- **`08-provider-notes.md`:** lines 5 and 305-308, and line 248's `[verify]`, which the DigitalOcean quote answers.
- **`F18`** (11:1603-1606): add a dated note.
- **New ADR:** records the withdrawal and rejects (b) and (c). `ADR-0018`'s Status line reads "amended by" it, and the README's ADR index gets a row.
- **`README.md`:** a note under the withdrawn table, following the precedent for dropped columns at README:258.
- **Research doc:** the invoice reads in §3 and batch steps A10, B10 and C7 become checks of the billing unit and grid, not of latency.
- **Lean:** no change.
