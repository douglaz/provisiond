**Verdicts**

1. Neither, as a rule. The attempt settles on the reply (a date → `scheduled`); the machine is recorded gone on evidence, from `scheduled` included. The set already says both. No requirement changes; the record and three CNF sentences do.
2. Yes. One direct `not_found` is the confirmation `OPS-32` itself demands, once past the *create's* window. No new rule.
3. "The end of that day in the zone the provider stamps its dates in", converted by the driver, owned by `PRV-13`. For v1 it moves a stop by at most 2 h, inside the sweep's bound. Fix it anyway: it is a false universal with two normative copies and no machine owner.
4. Build nothing: no `now` rule, no read-back MUST, no state, no descriptor field. Text edits only, no Lean.

**Why**

Q1. `DOM-19` (01:118-120): `cancellation_scheduled` "unless the resource is independently recorded gone before it (`LDG-74`, `API-63`), which is evidence, not the acceptance"; `STO-8a` (05:365-369) repeats it. `OPS-48`'s last row (03:1081) records gone "by any of `LDG-74`'s triggers — a refresh, a driver read during any operation, `OPS-32`'s complete pass … in any open state, `scheduled` included", and "Where that write and an attempt's terminal write are one transaction, as a delete's own 'already gone' answer is, they are one close under the first row". So a driver that reads back `404` inside the delete settles `succeeded`, resource gone, at the observation; one that does not settles `scheduled`, and the sweep's re-read closes it under the repaired row (Q21(5)). `gone_closes_and_clears` (Tables.lean:453-456) already proves the close from every open state. The r39 split was attempt versus machine, not two rules.

Costs. Hetzner bills the started hour either way (08:138-139). Customer: without a read-back, up to one sweep interval at the customer rate per `now` delete, `LDG-74`'s "money parameter" (12:575); with it, nothing. Operator: a read-back spends one of `GET /server`'s 200/h per delete, the budget Q20 spares (ADR-0034:136-148). "Lets `PRV-45`'s listing run" buys nothing observed: `GET /ip` and `GET /subnet` for the gone server answered `[]` (live-result 04:06:22, 04:06:41); Q21(3)'s capture-while-present is the fix there.

Both camps carry a false premise. Scheduled: "a read inside `PRV-36`'s window is not evidence" — `PRV-36` (02:960-962): "A read showing the post-mutation state is evidence at any time, and MUST NOT be reverted by a later contrary read"; a `404` is the delete's goal state, not contrary. Gone: "a failed read stays `needs_reconciliation`" — the cancel answered `200`; `OPS-11` (03:232) reserves that state for an *ambiguous* failure, so a failed extra read settles the attempt on the reply, scheduled.

Q2. `OPS-32` (03:1379) and `LDG-74` (12:527-531, "confirmed by a direct re-read, since a listing narrows candidates and never establishes one") make the direct read the confirmation; one is the rule. The window that applies to absence is the create's, "measured from the end of the create call's wait" (03:1357), never the delete's. Bound: Robot's create window is at least its worst observed delivery lag (19 min here: 03:47:38 order reply → 04:06:19 ready), so the live `404` at 04:06:22 sat at that edge. A machine cancelled seconds after delivery is recorded gone when the window elapses, by the same read. A failed read "writes no absence" (03:1368-1369).

Q3. Verified: `created_at "2026-10-11 05:47:37"` for 03:47:37Z is UTC+2, Europe/Berlin CEST. Robot's day ends 21:59:59Z (CEST) or 22:59:59Z (CET), 1-2 h before the UTC day ends, and a `now` after 22:00Z answers tomorrow's date. "UTC" is therefore a looser ceiling, in the customer's disfavour by 1-2 h when nothing observes the machine first, which the sweep bounds. For a provider west of UTC it would stop the meter before the provider's day ends, operator-borne. The driver already parses `yyyy-MM-dd` and the stored column is a `timestamp` (05:269); the zone is API encoding, not one of `PRV-13c`'s commercial terms (02:490-491), so a descriptor field is machinery. Home: `PRV-13`, owner of "MUST surface the effective cancellation date in its action result" (02:179-180); `PRV-45` and `WIR-35` point at it.

Q4. If the owner wants the +1 s stop regardless, it is one sentence in `PRV-13` ("MUST read the machine once after an accepted cancellation; `not_found` is `LDG-74`'s observation"), priced at one read per delete. Q20's own rejection, "adds a path the sweep already provides", argues against it.

**Defects**

- 02:544-546 and 13:900-902: two normative copies of the day-only rule, none on the machine path.
- 13:899 and 10:3262-3263: `2026-10-31T23:59:59Z` for Robot's `2026-10-31`; Berlin is CET then, so `22:59:59Z`.
- 10:1328-1331 (`CNF-147`): "where that date is today … cancellation is immediate and billing stops" infers immediacy from the date; billing stops at the observation.
- 03:1072 and 10:1896-1897 (`CNF-271`, "stay until … tombstoned"): Q21(5)'s pending repair; Q22 depends on it.
- 08:407: "Immediate destroy, no scheduled tail" reads the reply, which is a dated acceptance; the read is the evidence.

**Edits**

1. 02:180, `PRV-13`: "The result carries an instant. A date given as a calendar day only names the end of that day in the zone the provider stamps its dates in; the driver converts it. Robot's `cancellation_date` (`yyyy-MM-dd`) is one, and Robot stamps Europe/Berlin (`08`). A `now` cancellation never reads as a start of day; a timestamp keeps its instant. Acceptance settles the attempt; the machine is gone only by `LDG-74`'s evidence, a read inside the delete included (`OPS-48`)."
2. 02:544-546, 13:900-902: replace with "`PRV-13` says a day-only date names 'the end of that day in the zone the provider stamps its dates in'"; 13:899 → `22:59:59Z`.
3. ADR-0037:142-144: dated amendment (2026-10-11, Q22): zone, owner `PRV-13`.
4. 08:138-141, 08:407: the 2026-10-11 observation (`cancellation_date: "2026-10-11"`, `404` at +1 s through 45 min); the `created_at` sample as the zone's evidence.
5. 10:304-305, `CNF-63`: day converts in the driver's zone; a `not_found` read-back settles the first row at the observation; a failed read-back settles scheduled, never `needs_reconciliation`.
6. 10:1328-1331 reworded to the observation; 10:3262-3263 → `22:59:59Z`, "not noon, the start, or the UTC day's end".

Lean: nothing. No model of instants or zones exists (Meter.lean and Period.lean are the recurrence and period splits), and the scheduled→gone close is already proved once Q21(5) deletes `Event.tombstone` (Tables.lean:358) and the edge at Render.lean:59.
