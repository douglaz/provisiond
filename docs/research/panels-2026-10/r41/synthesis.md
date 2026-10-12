# Panel r41 synthesis — three owner questions left by the branch review (Q23a–c), 2026-10-11

Readers: opus (claude xhigh), astra, sol (codex xhigh); clones at 82bc3d8. Fable's seat failed on its usage
limit ("You've reached your Fable limit"); three readers answered.

## Q23a — a failed read-back leaves time past wind-down unfunded: split 2–1

- **Fund it (astra, sol):** add to `PRV-13b`'s wind-down the worst dated tail of an ordinary cancellation —
  for a same-day, day-only answer, through the provider-local day's end (call deadline, a long DST day).
  The sweep interval is not a bound: the sweep "MUST yield to `rate_limited`" (03:1446) and needs a complete
  pass and a direct confirmation, so `LDG-74`'s "maximum time a customer can be billed" (12:579) needs
  qualifying too. A tenant-induced read failure is conditional on Robot's counter scope (`[verify]`).
- **Accept with a threat model (opus):** it is `LDG-74`'s existing residual, ended no later than the
  stored date (`LDG-38`, 12:651). Robot destroyed the server at +1 s, so time past the read-back is metered,
  not provider-billed: with headroom the customer pays it; on an exhausted commitment it is `LDG-31`'s
  `clamp_overflow`, which "records who bore a cost or exposure, not whether a provider is still owed"
  (`LDG-66`) — no operator money. Real operator loss needs the machine still present after `now`, the same
  exposure as the present branch. Funding a day holds back every Robot customer's runway to make a charge
  for a destroyed machine collectable. Edits: say so after 02:194, add the path to `LDG-31`'s reachability
  list (12:281), a `CNF-64` exhausted-commitment fixture, an ADR note.
- All three: no meter stop at a failed read (failure proves no absence; it is the rejected "billing stops
  at acceptance").

## Q23b — `LDG-32` versus `PRV-49`: a contradiction (3–0)

- Q21 accepted rent "with no end date"; `LDG-32` demands "explicitly accepted and capped"; no cap exists or
  can without the discovery Q21 rejected, and `cleanup: api` does not bound cleanup of an unlisted row.
- **Name the uncapped exception (opus, astra):** opus — `PRV-49` becomes the one home ("Whether an offer
  may be sold with a billable attachment that can outlive its machine is `PRV-49`'s"), recording in ADR-0037
  that the residual is uncapped and rests on its threat model; astra — qualify `LDG-32` "Except for the
  explicitly accepted residual in `PRV-49`", and `PRV-13b`'s "MUST be able to bound its own exposure" the
  same way; align `CNF-354`.
- **Gate instead (sol):** "accident only" lacks evidence for catalogue orders and provider termination;
  establish automatic removal on every sold path or stop selling paths without that evidence. (Opus: the
  only cap-preserving alternative is to stop selling every `primary_ipv4` offer.)

## Q23c — the instant of a day-only `earliest_cancellation_date`: split 2–1

- **Start of that day in the provider's zone, stored as a timestamp (opus, astra):** "permitted from" is the
  first instant a `now` cancellation is accepted; a `D` equal to provider-today has passed (no `LDG-33` term,
  ordinary branch). "Cost through" a future `D` runs to the end of `D` (the forced cancellation dated `D`
  ends there under `PRV-13`'s effective-date rule) (opus). Rule in `PRV-13`; CNF-63 fixtures (Berlin:
  `2026-10-31` → `2026-10-30T23:00:00Z`); fix `CNF-147`'s "Size the commitment from the machine's read
  `earliest_cancellation_date`", which contradicts `PRV-31`'s "MUST NOT resize the commitment" (opus).
- **Keep a provider-local civil date (sol):** a `date` type, `PRV-13c` compares provider-local dates.
- Tonight's Berlin-midnight read should also check that `earliest_cancellation_date` changes at that
  midnight (opus).
