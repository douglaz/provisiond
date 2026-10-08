Files: L `12-billing-and-ledger.md`, P `02-provider-contract.md`, R `docs/research/provider-verify-2026-10.md`, C `10-conformance-checklist.md`, S `05-persistence.md`, W `tools/formal/Provisiond/Witnesses.lean`.

**Verdict: A.** The operator absorbs the started unit. Narrow `LDG-37` and correct `PRV-13b`; B and C bill a number provisiond cannot compute.

**Why.** If `deleting` is billable, latency is already the customer's. That is unstated, since `LDG-37` mandates only `stopped` and `cancellation_scheduled` (L:471). The exit closes at the gone-write's "observation instant" (L:510, L:873), which comes after Hetzner's "until you delete them" (R:570). What remains is rounding, and the set already routes it. The entries carry native cost (`LDG-31`), the invoice supplies the gap and `true_up_minor` measures it per month (L:1941, L:1950), and margin is "resolvable per provider account or product class" (L:1678). Assume `customer_rate` = (1+m) × hourly price (`LDG-23` doesn't say; monthly÷hours widens this) and a creation-anchored grid. At m = 20% the operator then loses only on lives of 0–50, 60–100, 120–150, 180–200 and 240–250 minutes, and never past 1/m = 5 h. The worst case is one unit per machine, or two under a wall-clock grid. Per tenant it is that × `SEC-39`'s "machines created per interval" (`07-security-requirements.md:209–212`), which has no default integer. Robot is also capped at 20 orders/day for the whole deployment (P:875). The caps cut the other way: "never more than the monthly price" (R:593) and "capped at 672 hours" (R:421). The meter passes neither through.

**Defects**

1. **The grid is unknown.** R:568 and R:593 are silent on it.
   - Creation-anchored and invoice-month ceilings differ only across the provider's local-time month (L:1950). A wall-clock grid differs on any life that straddles an hour.
   - Batch A's single life (R:651–661) can't separate them. A create at hh:50 and delete at hh+1:10 can: wall-clock bills 2 h.
   - B is undefined until then, and at the cap B charges rounding the provider never applied.
2. **DigitalOcean is not "second".** The minimum is "60 seconds or $0.01, whichever is higher" (R:421).
   - Below $0.60/h the cent binds, not "less than a minute" (R:553).
   - Batch C is "under $0.01" (R:688), so step 7's invoice lines will read the floor and carry no latency.
   - A money floor is not a declarable unit.
3. **The Robot add-on day is the note's own inference**, "not stated" (R:560). Attachments need per-kind units: Floating IPs are billed "the appropriate fraction" (R:574), and Volumes are hourly (R:585).
4. **B contradicts `Provisiond.Witnesses.exit_closes_each_tail`** (W:2060), which expects `[(0,7),(7,9),(20,24)]`.
   - A unit-end exit at 9 puts the mark past 20, and "A seed at or before the subject's latest mark is discarded" (L:868–869).
   - Exits to a nonbillable state (C:2742) stop no provider billing.
   - B overturns `ADR-0011`'s decided exit closure (`docs/adr/0011…:85`). A changes no Lean declaration.
5. **B degenerates to A on the failure paths.**
   - A quarantined exit "MUST post no usage debit" (L:1017).
   - An outage charges "the customer nothing" (L:1308).
   - The clamp makes the excess a deficiency (L:275).
   - A provider-terminated machine is metered to observation (L:510), so B adds an hour after an unknown instant.
   - For `cancellation_scheduled`, the grid's relation to the effective date is unknown.
6. **`LDG-37`'s "provider wins" (L:461) already reads as B.** `00-overview.md:288` provides for a usage-API source, and billed hours import the rounding. An invoice-time figure post-dates `LDG-32`'s release, and the excess "MUST NOT be taken from available balance" (L:275). Your reading of L:477 is right.
7. **The measurement.** "Noise" holds only for an invoice-derived figure: the expected maximum of 20 uniform phases is 20/21 of a unit. The engine samples "when the engine first observed its effect" (S:477), which is absence, and "resource absent, and billing stopped are three different facts" (P:263).
8. **The reserve.** Under A it needs no unit term. It sizes a customer commitment (P:192), and a term nothing debits is released unused. R:550 holds only under B. Under B the term is required, or exhaustion clamps the remainder back onto the operator.
9. **The other shapes.**
   - **Charging at entry** breaks the seed, which "carries no seconds and posts nothing" (L:870; W:2021).
   - **A per-span minimum** charges several units per provider life, and `ADR-0011:88` rejects that shape: it "overcharges partial use".
   - **Margin** cannot cover lives under 1/(1+m) h. Disclose the unit; don't promise cover.
10. **The descriptor.** `PRV-13c` permits a declared term (`cancellation_bound`). Under A nothing reads it, and C:118–119 requires "a working code path behind it". The unit goes in `08-provider-notes.md`.
11. **The ADRs.** `ADR-0007:30`'s "bursty and unattended" rejects a subscription; it does not name a market. `ADR-0029:109` says only "can charge one more period for a cancellation the outage delayed".

**What A edits**
- `LDG-37`: elapsed seconds only, and whether `deleting` is billable.
- `PRV-13b` and `STO-53`, with a dated `F18` note: `billing_stop_window` runs from dispatch to the gone observation, which is what `STO-53` already samples, and the remainder is operator-borne and outside the reserve.
- `LDG-75`: list it among the gaps.
- `SEC-39`: its ceiling is the rounding bound.
- `08-provider-notes.md`, and an ADR rejecting B and C.
- Research §3, plus batches A and C.
