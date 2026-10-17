All nine facts verified. Framing correction: gap 2 is mostly forced. `OPS-23` says validation "MUST be repeated in the worker before the driver is called" (03:1671-1672); 03:1677-1679 makes the sale re-test its only exception. Step 2 is a driver call, so `OPS-23`'s checks, `PRV-10` included, already precede it. Only `PRV-47` is unplaced, being "in the driver" (02:159).

**1. What the text forces**
- Account: "the last write before the ordering call" (04:1408-1409), "with no provider mutation" (04:1414). Both placements satisfy it; `CNF-278`'s "no provider call" (10:2349) is stricter than its owner.
- Fields: `OPS-23` before step 2. `PRV-47` bars only the order request (02:159); a key uploaded first "blocks the caller's next same-key create" (02:151).
- Absent offer: 03:693-695 bars mutation only; the failure paragraph opens "If the re-test finds the offer unsellable" (03:697). With descriptor `traffic_bound` null, "An offer with no declared traffic bound MUST NOT be sold" (02:282) applies; with a declared bound, nothing does.
- Nothing else is missing; `PRV-9`'s duplicate-key refusal is step 5 itself.

**2. Picks**
- (a) A step-1 plain read of `STO-47`, account refusal before closure refusal as in `API-7`'s tail (04:264-269); `API-63`'s conditional write stays after step 4. Only the termination verb fails queued creates (04:1363-1365) and neither recoverable status appears in 04, so a create claimed under `credentials_rejected` would run step 2 on dead credentials and surface a provider error, not `conflict`/`state` (13:163). Moving the write before step 2 widens the "potentially dispatched" window (04:1416-1418) across a Robot round trip.
- (b) `OPS-23` and `PRV-10` at step 1. `PRV-47` at the head of step 5, "before any provider mutation, including a per-order key upload". Both name `invalid_request`, `retryable: false`, settling `failed`; `internal` is ambiguous (03:262-263) and would park an undispatched create in `needs_reconciliation`, paging "a human for a typo" (03:243).
- (c) In `OPS-43`: the first failing step settles the operation; no later step runs. Admission has "Steps 1–5c still stop at their first refusal" (04:287); claim cannot collect, its error carrying "neither `details.refusals` nor `details.not_checked`" (03:703-704); `CNF-241` assumes it (10:2589-2592).

**3. Absent offer**
`invalid_request`/`offer_not_sellable`, `retryable: false`, `failed` under the create row, released under `LDG-39` (12:1264). It reuses 03:697-711 and `CNF-241` (10:2582-2583) unchanged. Against `not_found`: `DOM-21` says it "invites a re-send" (01:599-600), wrong for a vanished auction machine. Against Q17c: that response "is specific to the resource-offer guard" (04:294). A returning catalogue offer needs a new request anyway (`API-11`, 04:929).
Admission is equally silent: body validation checks "1–256 characters" (04:959), the tail refuses "not sellable under `PRV-13b` or `PRV-31`" (04:266-267) from a snapshot "without ... provider call" (04:261-263), and nothing names that snapshot's source or an absent id's outcome. Home: `API-7`'s tail, one clause "or not listed by the driver"; `DOM-9` (01:189-192) and `OPS-43` (03:672-673) already quote that verdict, so claim inherits it.

**4. Dependencies**
`pv-qga` depends on pv-14b: the precedence sentence lands first; `pv-qga` then classifies a step-2 read failure in `OPS-11` and `CNF-31b`, so not merged. `pv-nd6` and `pv-2s6` are independent: they define step 3's inputs, and an absent offer has no offer-reported value to dispute.

**5. Drafts**
`CNF-278`, fourth: "Record the account unhealthy before a queued create is claimed; assert it fails `account_terminated` at `OPS-43`'s step 1 with no provider call. Then claim a create with a sellable, unchanged-price offer, commit the termination after step 1 and before the correlator entry, and assert `account_terminated` with no provider mutation; the List offers read is permitted. Then commit it after the entry and before the call, and assert the attempt is treated as potentially dispatched, neither failed nor released."
`CNF-342`: "On a `per_order_key` channel, remove the named auction offer from the listing after admission and before claim; assert the step-2 read runs, no key upload or order request follows, and the operation settles `failed`, `invalid_request`, `offer_not_sellable`, `retryable: false`, commitment released in full. Repeat for a catalogue offer, same outcome."

**Strongest case for the other side (written on request)**
Two account checks are a second copy of one rule, observable only through a provider error `pv-qga` may classify `failed` anyway; the lazier edit is one phrase in `CNF-278`, "no provider mutation". And `offer_not_sellable` tells a caller the offer "cannot be bought" (13:165) when a catalogue offer may return within the hour; `conflict`/`state` carries Q17c's "the offer leaves the listing" (`ADR-0036`:102).
