## Q23a — accept, with a threat model; on a destroyed machine the clamp records phantom cost, not operator loss

Why:
- It is `LDG-74`'s existing residual: "The residual is the sweep interval … the maximum time a customer can be billed for a machine that is gone" (12:579). The stored date ends it (`LDG-38`, 12:651), at latest at the end of the provider day (02:197). That holds even when the sweep is throttled.
- Robot destroyed the server at +1 s. Time past the read-back is therefore metered, not provider-billed (invoice `[verify]`).
  - With headroom in the commitment, the customer pays it.
  - On an exhausted commitment it becomes `clamp_overflow`, which "records who bore a cost or exposure, not whether a provider is still owed" (`LDG-66`). The invoice then replaces `LDG-75`'s accrual of it.
- The operator only loses real money if the machine is still present after `now`. The *present* branch (02:190) has exactly the same exposure.
- A tenant can induce it if Robot's `GET /server/{n}` counter is shared, which is `[verify]` (08:440–458). v1 has no request reserve (`ADR-0034` Q19 deferred it), and Q10 lets refreshes re-read while reads fail.
  - The attacker gains nothing. A victim tenant pays at most one provider day per delete. That is money, unlike Q20b, where the harm was only delay.
  - Revisit if batch B shows a per-account counter.

Defects:
- 02:190–194 never says who bears time past wind-down, while Q22's Rejected list (ADR-0037:227) calls it a gap.
- `LDG-31`'s reachability list (12:281) omits this path.

Edits:
- After 02:194, add: "On that branch the meter runs to `LDG-38`'s stop boundary; time past wind-down is `LDG-74`'s sweep-interval residual, ended no later than the stored date, and beyond the commitment it is `LDG-31`'s clamp."
- Add this path to 12:281.
- `CNF-64`: exhaust the commitment and fail the read-back. Assert a `clamp_overflow` record, nothing taken from available, and a stop at the date.
- An ADR-0037 Q23a note recording the threat model.

Don't build:
- Funding a day (or the sweep interval) in wind-down. It holds back every Robot customer's runway just to make a charge for a destroyed machine collectable. The interval alone doesn't bound a throttled sweep either.
- A meter stop at the read-back. It is ADR-0037's rejected "billing stops at acceptance" and contradicts `DOM-19`'s "continuing cost". On an auto-scheduled future date it gives a tenant free running time behind a read failure it can try to cause.

## Q23b — yes, a contradiction, created by Q21; make `PRV-49` the one home and withdraw the cap explicitly

Why:
- Q18 sold the add-on as "operator rent until its `cleanup: api` cancellation" (ADR-0037:167), which satisfied `LDG-32`.
- Q21 accepted rent "with no end date" (ADR-0037:204).
- `LDG-32` (12:329–331) still requires "explicitly accepted and capped". The acceptance exists, but there is no cap. None is possible without the discovery Q21 rejected.
- `cleanup: api` doesn't satisfy it either. An unlisted row is never released, and `PRV-49` (02:218–229) says these paths lack "complete automatic discovery and cleanup".
- The root defect is two homes for one rule. `PRV-13b` (02:234) already delegates to `PRV-49`, and `LDG-32`'s copy drifted (the `SEC-46` pattern). No CNF or API row enforces the cap.

Edits:
- Replace the sentence at 12:329–331 with "Whether an offer may be sold with a billable attachment that can outlive its machine is `PRV-49`'s." `PRV-49` is stricter in every other case, so only the Robot carve-out loses a cap it never had.
- Record in ADR-0037 that this is a semantic change: the residual is uncapped and rests on its threat model.
- The alternative that keeps the cap is to stop selling every `primary_ipv4` offer, because provider termination reaches auction orders too.

Don't build: an orphan-IP sweep or rent counter just to create a cap. That is the discovery Q21 rejected.

## Q23c — store the start of that day in the provider's zone, price "through" it to its end, rule in `PRV-13`

Why:
- "Permitted-from" means the first instant a `now` cancellation is accepted, which is the start of `D`. A `D` equal to provider-today has therefore passed. There is no `LDG-33` term (12:349), and the machine takes the ordinary branch (02:534), as Q22 intended.
- `05-persistence.md:270` keeps its `timestamp` type, and `PRV-13c`/`LDG-33` still compare instants. Keeping a date would push the conversion into every consumer.
- A future `D` forces a cancellation dated `D`, and `PRV-13`'s effective-date rule ends that at the end of `D`. "Cost through" must reach that end. Otherwise `LDG-33`'s term and `LDG-63`'s "bounded per machine by `PRV-31`'s declared worst case" (12:1981) are a day short.
- That is the exception branch, which v1 can't reach (`LDG-38`). So this is spec correctness, not v1 money. Q22's prohibition still governs the stored value and the branch test.

Defects:
- No text names the instant; 02:200–202 says only what it is not.
- `r39/live-result.txt:13` shows the same date in UTC and Berlin, so it can't tell the zones apart.
- `CNF-63` (10:313–317) asserts only negatives, so a UTC-midnight reading passes it.
- `CNF-147` (10:1366) says "Size the commitment from the machine's read `earliest_cancellation_date`". That contradicts `PRV-31`'s "it MUST NOT resize the commitment" (02:508–509).

Edits:
- After 02:202, add: "A day-only `earliest_cancellation_date` is stored as the start of that day in the same zone; cost through a date not yet passed runs to that day's end, as above."
- `CNF-63`, first fixture: at 2026-10-30T23:30:00Z with `D=2026-10-31`, assert the stored value is 2026-10-30T23:00:00Z, there is no term, and the machine takes the ordinary branch.
- `CNF-63`, second fixture: with `D=2026-11-01`, assert the term prices through 2026-11-01T23:00:00Z.
- `CNF-147`: replace the sizing sentence with "price the earliest-date term; the commitment is unchanged".
- Q22's planned read across Berlin midnight should also check that `earliest_cancellation_date` changes at that midnight.

Don't build: a `date` column with arithmetic in every consumer, or a descriptor zone field (Q22 rejected that).
