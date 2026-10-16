The fork is real, but the bead's own story can't reach it on the launch driver. I pick (A) for other reasons. The same text is saved as `scratch-pv-hsm-review.md` in the clone (598 words by `wc -w`). I edited no tracked files and didn't run the gates.

## Corrections to the brief

- **Fact 2:** 02:575 is in `PRV-13c`, not `PRV-13b`.
- **Fact 7 is half wrong.** The inner error is "the object `WIR-10b` embeds in an operation view" (13:118-120), so 13:130's `reason: "offer_not_sellable"` shape already covers a worker error. Only `refusals`/`not_checked` and the retryable table (13:158-166) belong to the tail alone.
- **The bead's "No money is lost either way" is false** for the branch that dispatches an order.
- **On the launch driver, the one-month story can't happen.** The descriptor is "a typed, immutable value" (02:78), the Robot bound is a driver declaration (08:152-153), and `DOM-9`'s offer has no cancellation-bound field (01:162-174). So (A) and (B) both dispatch.
  - A driver that reports the bound "on the offer instead" (`PRV-44`) would fork. But `DOM-9` has no field to hold 05:384's "offer-reported bound". That is a separate gap.

## 1. Redundancy: not settled

- **`PRV-42` doesn't settle it.** "still listed" (02:1232-1233) is a presence check against free burns (ADR-0036:41-44). The sale filter governs "The customer offer listing" (01:188).
- **`OPS-23` is ambiguous.**
  - Against it reaching the tail: `API-7` separates "validate the body" (step 5) from a tail that "MUST collect every applicable refusal" (04:261-262). `OPS-23`'s stated reason is the stored record (03:1624-1625). r53's "nothing limits 'validation'" was too strong.
  - For it reaching the tail: `OPS-8` cites `OPS-23` for a live re-read, "the machine may have been installed, powered or cancelled in the gap" (03:196-197).
- **The gap is an asymmetry.** Price (`OPS-43`), signed URL (`OPS-40`) and channel closure (`PRV-40`, 02:1185-1191) each have their own claim-time sentence. The sale refusal is listed right before closure (04:266-268) and has none.

## 2. Pick: (A)

Two cases reach the fork:
- **A redeploy** that re-declares a bound while creates are still queued. `LDG-33` names "a descriptor re-declared after acceptance" (12:367).
- **`traffic_bound`**, which comes from the provider feed and isn't in the snapshot. `CNF-340` says it "follows current terms rather than a compiled constant" (10:3463-3464). 02:575 says so only for allowance offers.

## 3. Landing

**Home: `OPS-43`**, which already re-reads the offer (03:671). Insert after 03:682:

> The same read, against the descriptor the worker runs with, MUST first re-test the offer under `PRV-13b` and `PRV-31`; an unsellable offer gets no price comparison and fails before any provider mutation with `invalid_request`, `details.reason: "offer_not_sellable"`, `retryable: false`, its commitment released under `LDG-39`'s "Deterministic rejection before acceptance".

- **Ordering the checks:** the "first … no price comparison" clause prevents a new fork. Without it, a re-listing that both raises the price and makes the offer unsellable could give `price_moved` on one engine and `offer_not_sellable` on another.
- **`OPS-11` classification:** `failed`. `invalid_request` is not admission-only (03:234-236).
- **`CNF`:** extend `CNF-241`. Re-declaring either bound, or a feed reporting an allowance, must fail with no order and nothing debited.
- **The provider call:** no sentence names one today (03:671, 02:1232). "The same read" makes it one List offers call, which carries price and `traffic_bound`. `PRV-31` reads the descriptor and needs no call.

## 4. Who pays

| Case | (A) | (B) / (C) |
|---|---|---|
| Provider adds a minimum term (launch driver) | dispatches | dispatches |
| Operator re-declares a later bound | fails, "Never debited" (12:1264) | dispatches |
| Offer re-listed with a traffic allowance | fails, nobody pays | operator pays the overage |

- **A dispatched minimum term:** `protected_sats` absorbs the cost and the commitment "MUST NOT resize" (02:554-555). The customer's runway goes first, then the operator pays the rest (ADR-0037:294).
- **A dispatched allowance offer:** overage is "operator exposure" (02:278), and the set says "no active reason or Fence branch" exists to stop it (02:286-287). The cost has no bound.
- **Admission-to-claim window:** no text bounds it. The only stated figure is `OPS-40`'s per-deployment "worst-case admission-to-start bound" (03:653-654). Don't rely on `OPS-43`'s "can be long" (03:666-669): it rests on `OPS-33`'s polling, which happens after the order.

## 5. Strongest case for the other side (written on request): (C)

- The sale is decided "before taking money" (02:273).
- The set already treats the listing as one that "may have been re-priced, changed or withdrawn" (03:322-323).
- `PRV-31` keeps term drift out of admission (02:565-566), and Q25 already prices it.
- `ADR-0039` already excludes every allowance offer.
- `OPS-43` has been narrowed once before (03:684-689).
