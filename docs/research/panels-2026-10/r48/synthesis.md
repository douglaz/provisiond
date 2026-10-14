# Panel r48 synthesis — keep or drop Robot's post-order cancellation read (Q31), 2026-10-14

Readers: fable (claude-fable-5-1), opus (claude-opus-5-5), astra (gpt-6-astra), sol (gpt-6.1-sol), all at xhigh;
clones at 3639a80. All exit 0.

## Votes

| Reader | Vote |
|---|---|
| astra | KEEP; add create-time reads to Q28's threat model and a failed-read fixture to `CNF-356` |
| sol | KEEP; same two additions |
| fable | OTHER, "keep-absorbed": keep the read as one attempt at the create's settlement; any failure, `rate_limited` included, leaves `PRV-31`'s declared bound as the priced term, raises `PRV-5`'s alarm and is not retried; a later accepted cancellation's response supplies the date |
| opus | DROP-FOR-ROBOT: take the per-machine date from the accepted cancellation response at delete time; withdraw `PRV-13`'s "That separate post-order read remains required" |

## Facts the readers established (verified where marked)

- **The spec never says where the read runs or what its failure does.** No lifecycle requirement writes
  `machines.earliest_cancellation_date` (`05-persistence.md` column: "**read** not assumed"); `OPS-27` settles a
  create without it; `OPS-11`'s read-failure exception covers only `PRV-13`'s delete read-back. (Verified.)
  astra and sol read a failure as sending the delivered create to `needs_reconciliation` (`PRV-5` "Known
  acceptance MUST remain `true` on every later error"; `OPS-11`), which a blinded counter cannot resolve;
  fable and opus show that holds only if the read runs inside the accepted create, and that anywhere else the
  column stays null and `LDG-33`'s term prices nothing — "a drop by accident" (opus).
- **Cost of keeping:** `ADR-0036` caps orders at "20 requests per day" per endpoint with no hourly pacing;
  across `server` and `server_market`, at most about 40 reads in one hour, about 20% of the 200/h counter,
  more only if deliveries from earlier days bunch (`OPS-33`: in-process orders have no documented bound).
  Every read follows an order whose first unit the tenant paid for, unlike Q28's four free paths.
- **Value of keeping:** `PRV-31` forbids resizing the commitment, so the read can only move satoshis from
  advertised runway into `protected_sats`: at most min(usable commitment, cost through the date) per
  deviating machine. No sampled machine has deviated (`08-provider-notes.md`, 2026-09-04 orders; r45).
- **What catches a deviation without it:** the accepted cancellation POST's response carries
  `earliest_cancellation_date` (r45 `live-session2.txt`: the session-2 cancellation GET was refused 403 and the
  date came from the POST); `LDG-63` tops up and surfaces a shortfall as operator-borne; `LDG-75`'s invoice row
  supplies anything missed. The sweep's `GET /server` carries no cancellation date.
- **Brief corrections:** `CNF-356` does not itself test the read; the "every delivered server" evidence is two
  2026-09-04 orders plus r40's reads, not r45.

## Strongest case for the other side (written on request — not the readers' positions)

- Against keep (astra, sol, fable): in v1 the exception branch is unreachable at purchase by `PRV-31`'s own
  sale rule; the read checks a declaration against an event never observed, cannot act on what it finds, and
  the free cancellation response returns the same date later.
- Against drop (opus): only the post-order read learns of a deviation while the customer's committed
  satoshis can still pay for it; and if Robot ever rejects `now`, scheduling needs a stored date. Keep plus a
  failure-absorbing rule fixes the failure path at ~20% of one hour's counter on paid orders.

## Convergence

Three of four keep the read; fable and opus (the latter in its counter-case) both say keep is workable only
with a stated place and a failure-absorbing rule, which astra and sol's failure fixture would test.
