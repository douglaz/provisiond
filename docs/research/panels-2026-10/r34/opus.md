**Q18a verdict: (c) for v1, stated once in `LDG-38` for every subject.** This departs from the Manager's recommendation and yours. Build (a) when the first attachment with a customer price is sold.
**Q18b verdict: neither reading as posed. `LDG-32` already owns this rule.** 12:329–331, unchanged since `9f1f468` (2026-08-13): "It MUST NOT sell an offer whose attachments have no bounded automatic cleanup unless the operator has explicitly accepted and capped that exposure." What's left for the owner: does a kind with no declared date bound count as "no bounded automatic cleanup"?

## Why Q18a

- **The case can't be priced in v1.**
  - Three places assume "the attachment's customer rate": 0037:124, 02:245 and 02:553. Nothing defines it:
    - `machine_attachments` has no rate column (05:331–340);
    - the listing returns only `{kind, external_id, billable, cleanup}` (02:520);
    - `LDG-24` applies the margin "to machine time only" (12:1832).
  - So no attachment increment can be priced today, and no attachment can be overcharged or credited.
  - The only v1 survivor candidate is the `primary_ipv4` add-on. `RSC-45` says "order the address addon and carry its cost into the offer's price" (06:513), so it is priced as machine time. Whether it outlives the server is batch B step 9 (provider-verify:688–689).
- **Robot does return dates.** I fetched the Robot webservice docs today. `POST /ip/{ip}/cancellation` takes "Date which you want the IP cancellation to go into effect or "now" to cancel immediately", and the output's `cancellation_date` has "format yyyy-MM-dd".
  - On ordinary success, the window behind the mark is the queue wait plus one call, so at most one meter tick.
  - On automatic resolution, it is `PRV-13b`'s resolution terms.
  - Only an operator's `WIR-35` resolution is unbounded, and that delay is the operator's own.
- **(b) is not existing machinery.** No endpoint posts a usage correction; 04:32 lists only deposit attribution. The restore correction in `LDG-74` ("nothing triggers it", 12:559) has no endpoint either. So (c) is the only option that builds nothing. The set already accepts a bounded overcharge: "The residual is the sweep interval", "the maximum time a customer can be billed for a machine that is gone" (12:575–577).
- **The commitment doesn't matter, open or closed.** `LDG-31` pairs only debits with decrements, and `LDG-33` forbids growth "without an explicit authorizing action". So a credit lands in available balance either way. A commitment can close first, because a prior sweep's `released_at` is preserved (02:543).

**If the owner picks (a), here is its shape:**
- **Writer:** the transaction that stores the boundary. That transaction must then take the tenant's `LDG-35` lock.
- **Key:** a new one. `LDG-8` defines keys only for `topup` and `usage_debit` (12:131–137), and `Funding.Key`'s only correction key is `WIR-42`'s (Funding.lean:214). Derive it from (corrected entry, boundary).
- **Period:** the corrected entry's (12:879).
- **One correction per entry.** `corrects_entry_id` holds a single entry (05:565).
- **The increment that straddles the date** needs an apportionment no rule defines. Negate only entries wholly after the boundary.
- **A clamped entry:** credit the entry, not the computed debit. Credits round down (12:47), and the provider-cost accrual takes the signed native adjustment (12:2071).

## Why Q18b

- **The ADR sentence states a consequence, not a refusal:** "needs a bound … or the shortfall meets `LDG-31`'s clamp" (0037:125–127). It came from r29 `opus.md:32`: "Without one, a month-end date hits `LDG-31`'s clamp." That is `LDG-32`'s operator carve-out.
- **The live `PRV-45` sentence (02:551–554) would stop all v1 sales.** It is keyed on kinds. Robot declares "Additional IP `api`; subnet `api`" for every descriptor (02:195), and Robot can schedule those for a date (0037:46–47; the Robot docs). Without a declared bound, every Robot offer is unsellable. A declared bound can't be priced either, because the rate is undefined.
- **Safety and timing.** Refusal is safer for the operator, but `LDG-32` already makes acceptance explicit. Neither rule is needed now: no v1 order creates an attachment with a customer price.

**Q3 (scope).** Don't write "no v1 offer has one". `PRV-13a` lists them "conservatively as possible survivors pending research batch B, step 9" (02:198). Make the deferral conditional on step 9 and on a defined rate source.

## Defects in the framing

1. "`LDG-68`'s correction rule": `LDG-38` owns it (12:879); `LDG-75` agrees (12:2069).
2. "`LDG-62`/`LDG-5` correction path": `LDG-62` is a customer's runway extension (12:1901), not a correction.
3. "naming the affected usage entries": a correction names exactly one entry (05:565).
4. "orders no extra IPs": `RSC-45` allows the add-on (06:513), and batch B step 3 orders `addon[]=primary_ipv4` (provider-verify:677).
5. **It isn't attachment-only.** A `delete_machine` resolved `applied` with a past date (13:887–892) clips at the scheduled-machine boundary (12:641). The same debits stand, at a machine rate, with no credit.
6. **Both questions assume an attachment rate that doesn't exist** (see above).
7. **Date-only values.**
   - The stored date is a `timestamp` (05:339), `WIR-35`'s examples use `T00:00:00Z` (13:888, 896), and no rule says which instant or time zone a date means.
   - Read as start of day, a "now" release stores a date before the attachment's meter even starts (the machine's stop, 12:916). The customer then pays for no attachment time.
   - A month-end date stops the meter a day early if Robot's date is inclusive.
8. "In this clone's history": `f86de91` is in HEAD, so `PRV-45`'s sale ban is live text now.

## Edits

1. **`LDG-38`**, after the discard rule (12:903): "A stop boundary stored behind the subject's mark (a dated release, or a scheduled delete, resolved after its date) leaves posted increments standing; the excess runs from the boundary to the storing transaction, and nothing corrects it automatically." Cut the attachment paragraph's past-date sentence (12:655) down to a pointer.
2. **`CNF-328`** (10:3194): add a case with the mark already past the date. Assert no debit, no correction, and posted entries unchanged. Add the same case for a delete resolved `applied` with a past date.
3. **`PRV-45`** (02:551–554): replace "without it, the offer MUST NOT be sold on prepaid terms" with a pointer to `LDG-32`, and scope it to kinds the order creates. Keep the clamp sentence.
4. **`PRV-45`/`WIR-35`**: state which instant and zone a date-only provider value names. I recommend the end of that day ("owes … through the effective date").
5. **ADR-0037**: add a dated Q18 note.
6. **Separately:** the attachment rate needs a source before any attachment is customer-metered.

**Formal impact**
- **(c):** no Lean change. `post_partition` (Funding.lean:1583) already proves the discard. `lifecycle_coverage` (1822) covers only exits with `ordered : cursor ≤ at_` (1574), so a stop behind the mark falls outside it. Add a docstring line saying so.
- **Q18b:** no change. `offerSellable` is an opaque input to the purchase tail (Admission.lean:1055–1057).
- **(a):** needs a new `Key` constructor, plus its own versions of `attribution_leaves_meter_untouched` (1238) and `correction_then_post_posts_the_same` (1269).

I edited nothing. The gates pass at HEAD (`nix develop --command bash tools/check-all.sh` exited 0; all seven gates passed).
