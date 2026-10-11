**Verdicts**
1. A Robot `now` delete settles as gone when seen gone. The two readings are one state machine that differs by a single `GET /server/{n}`. The real decision is that a dated delete MUST read the machine once.
2. One direct read is enough. If the read finds the server or fails, the delete settles as scheduled, never `needs_reconciliation`.
3. The day ends in the provider's zone. `PRV-13` should own the rule, scoped to *effective* dates. That Robot's day is local is inferred, not observed.
4. Build no zone field and no second read. No Lean change.

**Q1**
- **The spec already settled the shape.** 08:407 (two samples) records "`404 SERVER_NOT_FOUND` … Immediate destroy, no scheduled tail".
- **I retract the premise opus argued for "scheduled" in r39.** `PRV-36` says "A read showing the post-mutation state is evidence at any time" (02:960).
  - A `404` is goal evidence, not contrary evidence. "Contrary" names a later read that would revert it.
  - `OPS-32`'s window is "measured from the end of the create call's wait" (03:1357), so it doesn't cover a delete.
- **No new state rule is needed.**
  - `DOM-19` already allows "independently recorded gone before it" (01:120).
  - `LDG-74` lists "a driver read during any operation" as a trigger (12:528).
  - `OPS-48` says the gone-write and the terminal write "are one close under the first row" (03:1081).
- **What not reading costs:**
  - The customer pays for up to one sweep interval, which `LDG-74` calls "the maximum time a customer can be billed for a machine that is gone" (12:576).
  - `PRV-13b`'s wind-down sum (02:212) leaves that tail out. `LDG-31`'s clamp then turns the gap into an operator deficiency, which is `ADR-0037`'s own trap (:29).
  - `cancellation_scheduled` would claim "Still running, still reachable" (01:109) for a server that is gone.
- **What gone costs the operator:** the rest of Robot's started hour (Decision 5, :48; `LDG-75`). That loss is already accepted.
- **What reading costs:** one `GET` against Robot's 200 per hour. It also gives an `STO-53` sample (05:506) for Robot's unmeasured window.
- **Not a benefit:** that this "lets `PRV-45`'s listing run". After the `404` the listing is empty either way (`ip_in_list=[]`), and Q21(3) owns capture.

**Q2**
- **One read is enough.** The delete's own direct read satisfies `OPS-32`'s "re-read directly" (03:1379). Only the pinned not-found code for that `(account, external_id)` counts as absence; `rate_limited` does not.
- **Defect:** `PRV-12` (02:156) never says read failures are distinct from absence, though get-attachment does (02:523).
- **Defect:** 08 pins no Robot goal-state code for a cancel, which `OPS-11` requires.
- **Your lean's textual basis is real.** `OPS-11` treats an accepted mutation as ambiguous "whatever the later error kind or status" (03:271). Read literally, a failed confirming read would reach `needs_reconciliation`.
  - Carve it out in `PRV-13`: the write path's report is "truthful immediately" (`PRV-29`, 02:322), so the read's failure is not the delete's failure.

**Q3**
- **The fact is inferred.** Only `created_at` was observed in local time. Every day-only field was read at 04:06Z, which is the same day in both zones.
  - A read-only test that tells them apart: `GET /server/<an unrelated pre-existing server>/cancellation` between 22:00Z and 24:00Z, or between 23:00Z and 24:00Z after 2026-10-25.
- **The rule:** use the zone the provider dates in, recorded in 08 as a `PRV-5` translation. Until then, UTC is a later bound for Robot and errs only against the customer.
- **v1 impact is negligible.**
  - Once Q1 is settled, a day-only date only bounds the failed-read fallback near Robot's midnight, by at most min(2 h, one sweep interval).
  - It also bounds a server still present after its cancel, but `CNF-147` says "no launch product reaches the branch by default" (10:1334).
  - Attachments have no customer rate in v1.
- **Bigger defect:** `PRV-45`'s normative "names the end of that day UTC" (02:545) and `ADR-0037`:142 apply to every day-only date. That includes `earliest_cancellation_date` (05:270), which has no conversion owner.
  - Read as end of day, "today" lands about 20 h ahead.
  - With `PRV-13e`'s hourly default, "materially in the future" means "a few hours plus wind-down" (02:425).
  - So nearly every order would branch to the exception path, which contradicts `CNF-147` (10:1329).

**Q4**
- **The strongest "don't build":** no read at all, and let the sweep close it (`CNF-64`). It loses because the wind-down sum misses that tail, and the fix costs one `GET`.
- **Edits:**
  1. **`PRV-13`** (02:180), after its date sentence: "…then read the machine once (`PRV-12`); its failure is not the delete's (`PRV-29`). Not-found settles the first shape (`LDG-74`); presence or failure settles the second with that date. A day-only effective date ends that day in the provider's zone (08); an earliest date on or before the provider's today permits `now`."
  2. **`PRV-12`:** "A read failure, `rate_limited` included, MUST be distinct from absence."
  3. **`PRV-45`** (02:544-546) and **`WIR-35`** (13:900-902): cite `PRV-13` instead of restating the rule.
  4. **`CNF-328`:** assert the conversion in the zone 08 declares (`22:59:59Z` for `Europe/Berlin`). Change it only once that zone is verified.
  5. **`ADR-0037`:** add a dated amendment that drops "UTC" and scopes the rule to effective dates.
  6. **08:407:** add the 2026-10-11 run as the third sample, record `Europe/Berlin` as `[verify]`, and pin the codes.
- **`CNF-63`:**
  - a not-found read closes the episode `resource_gone` in the terminal transaction and stops the meter at the read;
  - a present server, or a `rate_limited` read, gives `cancellation_scheduled` with the date.
- **`CNF-147`:** an earliest date of today stays off the exception branch.
- **Lean:** none.
