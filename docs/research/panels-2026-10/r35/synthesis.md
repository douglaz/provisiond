# Panel r35 synthesis — review of the proposed Q18b fix (an attachment kind with no declared bound), 2026-10-10

Readers: opus, astra, sol, fable; clones at 8c3087e. All exit 0.

## Verdict: 4–0 reject my fix. Delete the attachment effective-date bound from v1; record it as a
## precondition of any attachment customer price, beside Q18a's automatic credit.

- The bound prices nothing: its only reserve use is "priced at that attachment's customer rate through its
  worst-case effective date" (02:244-246), and no attachment rate exists (no rate column; `LDG-24` margin
  "to machine time only"); the count is decided per instance at deletion. Its only consumer is a sale gate
  checking that it was declared — "a field declared so a gate can check it exists is a ritual" (fable).
- "Kinds the order creates" is not a pre-create input (all four); the descriptor is per driver.
- My "immediate release declares zero" contradicts Q18a: a day-only date is the end of that day, and
  Robot's `now` cancellation returns a date, so a Robot release bills through 23:59:59Z (all four).
- `LDG-32`'s "explicitly accepted and capped" exists only at 12:330 — no verb, row, cap or CNF; the clamp
  is not it (the clamp caps the customer, not the operator) (all four).
- v1 trace: a Robot order WITHOUT the IPv4 add-on creates nothing billable — sellable. WITH
  `primary_ipv4` (priced into the machine, `RSC-45`): whether it outlives the server is batch B step 9.

## Split: the IPv4-add-on path before the live test

- Sell now (fable, opus): with no attachment rate the customer is never charged for it; any surviving
  day is an operator cost `LDG-75` already accepts ("Robot add-ons billed per day or part thereof");
  `cleanup: api` meets `LDG-32`.
- Verify first (astra, sol): classify and verify Primary IPv4 survival before selling the add-on path;
  the IPv6 path is sellable now.

## Edits (fable's list, the closest to all four)

Delete `attachment_cancellation_bound` (02:82-83) and `PRV-45`'s bound/refusal sentences (02:551-555);
`PRV-13b`'s `billable_attachments` term: no v1 value, enabling an attachment rate requires the automatic
credit (Q18a), a per-kind worst-case date bound and a per-offer declaration of created kinds; revert
`LDG-33`'s term; delete CNF-328's untestable bound sentence; ADR-0037 dated clarification; `LDG-32`,
`PRV-13b`'s sale rule and `API-7` untouched (fable) — opus would also narrow `LDG-32`'s sale sentence to
"The sale gate is `PRV-13b`'s" (removing the unspecified carve-out).
