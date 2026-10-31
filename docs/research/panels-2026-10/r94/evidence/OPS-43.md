**OPS-43** **The provider's price MUST be re-checked at claim, and the order refused where the
commitment no longer covers it.** A create is priced and its commitment sized when the API accepts
it; the purchase happens later, in a worker. `WIR-30` says an offer price is "an indicative quote
… `binding` is `false`", and the auction channel is a live market with other bidders in it, so the
provider's own price can move in that window — which on the dedicated product can be long, since
`OPS-33` records that robot-style orders poll through an `in process` state with no documented
bound.

**Sale re-test at claim.** At claim (`OPS-5`), before any provider mutation, the worker MUST
re-test the create's named offer for sale under `PRV-13b` and `PRV-31`, applying `API-7`'s
create-tail verdict: "`invalid_request`/`offer_not_sellable` when the named offer is
not sellable under `PRV-13b` or `PRV-31`, or absent from the offers the check reads".
The inputs are the descriptor the worker runs with
(`PRV-44`: "The descriptor is a typed, immutable value") and one current driver List offers
result taken at claim. Date bounds MUST resolve against provider-local today at the time of
the check.

The worker MUST order the following steps as listed:

1. Read the provider account's stored status (`STO-47`). This is a plain read, not a
   conditional-write guard; the guard remains the conditional write at step 8. If the status
   is not `healthy`, fail `conflict`, with `API-63`'s “`details.reason: "account_terminated"`
   where the status is `terminated` and `"state"` for the two recoverable statuses, since
   presenting an unreachable account as a permanent termination is false, and with
   `retryable: false` for `"account_terminated"` and `retryable: true` for `"state"` on both the
   error and the operation view”. Make no
   provider request and release the commitment in full under `LDG-39`'s "Deterministic rejection
   before acceptance" case.
2. Read the stored channel closure (`PRV-40`: "the worker MUST read the stored closure for that
   account and ordering channel when it claims the operation (`OPS-5`), before any provider
   request, including a per-order key upload").
3. Repeat boundary validation under `OPS-23`: "Validation that was performed at the API boundary
   MUST be repeated in the worker before the driver is called". This includes `PRV-10`'s
   "explicit purchase acknowledgement", `PRV-8`'s "at least one SSH public key", the missing-field
   checks defined in `OPS-23`, and `DOM-10`'s gate on the create's ordering capability, which is
   `PRV-10`'s "the account is configured to allow ordering". The checks on caller-supplied fields
   run first, then the checks on fields the `api` wrote at admission, then the capability gate.
4. Gate on `list_offers` under `DOM-10`, then obtain the current driver List offers result.
5. Check for the named offer's absence from that result, applying the create-tail verdict quoted
   above; if present, re-test the named offer for sale on that result and the running descriptor.
6. Compare its price using that same List offers result, as below. An unsellable offer gets no
   price comparison.
7. Run `PRV-47`'s driver validation: "the driver MUST validate every value it forwards to the
   provider, including provider options". For the rejection's error, see `PRV-47`.
8. Perform `API-63`'s conditional write on `STO-47`'s row, in the correlator transaction:
   "the worker MUST repeat the admission check as a conditional write on `STO-47`'s row guarded
   on `healthy`". It remains "the last write before the ordering call" (`API-63`).
   In this same transaction, on every ordering channel, including `correlator: none`, the worker
   MUST set `operations.about_to_order_at` to `COALESCE(about_to_order_at, <transaction time>)`
   guarded on `(id, status = running, claim_number = mine)` (`STO-3`; `OPS-6`:
   "every write that worker makes to the operation MUST carry `claim_number = mine`").
   The write MUST NOT be guarded on the column being null: a whole-transaction repeat after a
   lost reply affects one row and changes nothing. If this operation-row write affects zero rows,
   something else moved the operation: step 9 MUST NOT run and the worker MUST exit. This differs
   from the zero-row `STO-47` check above, of which `API-63` says "where it affects no row MUST
   fail the operation deterministically". A first attempt that fails that check commits no
   `about_to_order_at`. If an earlier step-8 transaction committed but its reply was lost, and an
   account-status write makes the account non-`healthy` before the whole-transaction repeat,
   the repeat can fail that check with the column already set. The create still settles `failed`
   under `OPS-11`'s create row: `OPS-11` says "Any create failure the worker records before any step-9 request (before any per-order key upload or order request) MUST settle `failed`, whatever its kind."
   Step 9 MUST begin only after step 8's transaction is acknowledged. A lost acknowledgement
   MUST take `OPS-49`'s "repeat the **whole transaction**" path, never speculative dispatch.
9. Perform the per-order key upload, then the order. Here **per-order key upload** means every
   temporary key registration required for this create (`PRV-9`: "the driver MUST register and
   attach them as temporary provider-side resources").

*Amended 2026-10-17 (`pv-k4l`; panels r56 and r56b, `docs/research/panels-2026-10/r56/` and `docs/research/panels-2026-10/r56/r56b/`): made step 8 write the column under the worker guard and await acknowledgement before step 9.*

*Amended 2026-10-21 (`pv-p1y`): pointed step 7's rejection at `PRV-47`.*

*Amended 2026-10-21 (`pv-xer`; owner decision of 2026-10-21): extended step 1's quote of `API-63`
to its `retryable` values.*

The first failing check stops subsequent checks; its owning classification governs disposition.
Claim-time refusals are not collected: the error carries neither `details.refusals` nor
`details.not_checked`. The order differs from admission: a create both closed and unsellable
fails `rate_limited` at claim (`PRV-40`: "If the channel is closed at that read, the worker MUST
make no provider request and settle the existing operation `failed` with `rate_limited`") but
`offer_not_sellable` at admission, where `API-7` orders "`invalid_request`/`offer_not_sellable`"
