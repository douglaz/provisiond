# Panel r40 synthesis — what a Robot `now` delete settles as, and Robot's date zone (Q22), 2026-10-11

Readers: fable, opus (claude xhigh), astra, sol (codex xhigh); clones at dec039f. All exit 0.

## Q1–Q2: a `404` after the cancel is goal evidence; record gone at that read (4–0 on the evidence)

- Both r39 camps carried a false premise (fable; opus retracts its own): `PRV-36` (02:960) "A read showing
  the post-mutation state is evidence at any time"; a `404` after a delete is the goal state, not a contrary
  read, and `OPS-32`'s window is the create's (03:1357). The set already allows the gone close: `DOM-19`
  (01:120) "unless the resource is independently recorded gone before it"; `LDG-74` (12:528) "a driver read
  during any operation"; `OPS-48` (03:1081) one close under the first row.
- One direct read of the known account and server is enough, counting only the provider's mapped
  not-found (`SERVER_NOT_FOUND`), never a throttle or auth failure (4–0). `PRV-12` should say a read failure
  is distinct from absence (opus).
- Make the read part of the delete (opus, astra, sol): after an accepted dated cancellation the driver reads
  the machine once; not-found settles gone at that read and stops the meter there. Without it the customer
  pays up to one sweep interval that `PRV-13b`'s wind-down sum leaves out, and `LDG-31`'s clamp turns the gap
  into an operator deficiency (opus); cost: one `GET /server/{n}` per delete (200/hour). Fable: allowed
  already; a read-back MUST is optional and the sweep provides the close.
- **Split on a failed or present read-back:** scheduled with the date, never `needs_reconciliation` —
  the cancel's `200` is truthful (`PRV-29` 02:322) and the read is not the delete (fable, opus); vs stays
  uncertain / read-only reconciliation, since a present read inside the window proves no schedule
  (astra, sol).
- Not a benefit: "lets `PRV-45`'s listing run" — after the `404` the IP lists were empty; Q21(3) owns capture.

## Q3: the zone (4–0 on the shape)

- Drop "UTC" from Q18a's rule: a day-only date names the end of that day in the provider's own zone,
  converted by the driver; one owner, `PRV-13`; `PRV-45` and `WIR-35` cite it.
- Scope it to effective dates (opus, sol, astra): `earliest_cancellation_date` is a permitted date, not a
  stop instant; read as end of day, "today" lands ~20 h ahead and sends nearly every order down `PRV-13c`'s
  exception branch, against `CNF-147` (10:1329) (opus).
- Robot's zone is inferred, not observed for cancellation fields (only `created_at` showed UTC+2): record
  `Europe/Berlin` as `[verify]`; a read-only test: `GET /server/{n}/cancellation` between 22:00Z and 24:00Z
  (opus). Boundary: the next local midnight, exclusive (astra, sol: 2026-10-11 → 22:00:00Z), vs 23:59:59
  local (fable). The wire example 13:899 / CNF-328's `23:59:59Z` is wrong for Berlin.
- v1 impact is small (≤ 2 h, inside the sweep bound) once Q1 is settled; fix it anyway.

## Q4

No zone field, no second confirmation read, no Robot-wide immediacy constant (4–0). Lean: none (fable,
opus) or a calendar-label vs effective-instant distinction (astra, sol). Complete Q21(5)'s tombstone repair
including 12:653 "tombstone … clears the fence" (astra). Fix `CNF-147` (10:1328-1331), which infers
immediacy from the date (fable).
