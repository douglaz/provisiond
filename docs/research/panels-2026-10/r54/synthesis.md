# Panel r54 synthesis — triage of `pv-hsm`, what the worker's repeated sale check reads before dispatch, 2026-10-16

Readers: fable (claude-fable-5-1, xhigh), opus (claude-opus-5-5, xhigh), astra (gpt-6-astra, high), sol
(gpt-6.1-sol, xhigh); clones at `6853d62`. All exit 0. The brief waived the gates (a text question; green at
`02ed28a`).

## Does the text already settle it?

No, all four.
- `PRV-42`'s dispatch check tests presence, not terms: "the driver MUST confirm that the named offer is still
  listed before sending the order request" (02:1232-1234), against free burns (`ADR-0036`:41-44). `DOM-9`'s sale
  filter governs "The customer offer listing" (01:188), which is "advisory" (01:190). A re-listed offer with new
  terms is still listed.
- Whether `OPS-23` reaches the purchase tail is itself unsettled. Against: its stated reason is the stored record,
  "The record may have been written by an older version of the service, or edited in the store" (03:1624-1625),
  and `API-7` separates body validation from a tail that "MUST collect every applicable refusal" (04:261-262;
  fable, opus). r53's "nothing limits 'validation'" was too strong (opus). `OPS-11`'s admission-only kinds "MUST
  NOT be emitted by a worker" (03:234-236), so it cannot mean every boundary check (all four). For: `OPS-8`
  cites `OPS-23` for a live re-check, "the machine may have been installed, powered or cancelled in the gap"
  (03:196-197; opus).
- The gap is an asymmetry (opus): price (`OPS-43`), signed URL (`OPS-40`) and channel closure (`PRV-40`,
  02:1185-1191) each have their own claim-time sentence; the sale refusal, listed just before closure in the tail
  (04:266-268), has none. `PRV-40` is the precedent for re-testing a tail refusal at claim: "the worker MUST read
  the stored closure … when it claims the operation … settle the existing operation `failed`", the commitment
  "released in full under `LDG-39`'s 'Deterministic rejection before acceptance' case" (fable).
- The snapshot cannot serve `PRV-13b`: the `request_summary` row holds no traffic bound (05:384; all four).

## Who pays, and how long the window is

| Case | (A) live re-test | (B) snapshot / (C) admission-only |
|---|---|---|
| Operator redeploys with a later declared bound while creates are queued (12:367) | fails; setup and first unit "Never debited" (12:1264) | ordered |
| Offer re-listed with a traffic allowance | fails; nobody pays | ordered; overage is "operator exposure too" (02:278), with "no active reason or Fence branch" to stop it (02:286-287) |
| Provider adds a minimum term, launch Robot driver | ordered (the bound is a descriptor declaration) | ordered |

- A dispatched later term lands on `PRV-13c`'s exception path (02:578-586). The commitment "MUST NOT resize"
  (02:554-555); `LDG-63` tops it up "from available", and "Where available cannot fund the top-up, the shortfall
  is operator-borne" (12:1995-2000). So the customer's spare balance pays first, then the operator (fable, opus).
- No text bounds the admission-to-claim window. `OPS-40` leans on a deployment's "stated worst-case
  admission-to-start bound" (03:653-654); `CNF-33` requires surviving a restart between enqueue and claim
  (10:215-216). `OPS-43`'s "can be long" rests on `OPS-33`'s polling, which is post-order (03:666-669; opus,
  astra, sol).

## Claims the readers broke

1. The bead's "No money is lost either way" is false for the branch that orders (fable, opus); "Both are
   conformant today" is too strong given `PRV-31`'s "before any order" and `PRV-13b`'s "MUST NOT be sold"
   (astra, sol).
2. Brief fact 7: the error shape exists. `WIR-9`'s inner object is "the object `WIR-10b` embeds in an operation
   view" (13:118-120; `WIR-10b` 13:274), and 13:130 already defines `reason: "offer_not_sellable"`. Only
   `refusals`, `not_checked` and the retryable table are tail-only (opus, astra, sol).
3. Brief fact 2: 02:575 is in `PRV-13c`, not `PRV-13b` (opus).
4. The bead's one-month story cannot happen on the launch driver (opus). The Robot bound is a driver declaration
   (08:152-153) in an immutable descriptor (02:78), and `DOM-9`'s offer table has no field for an
   offer-reported cancellation bound although `PRV-44` lets a driver report it "on the offer instead" (02:83,
   01:162-174) — a separate gap. The fork is reachable through a redeploy that re-declares the bound and through
   `traffic_bound`, which follows the live feed (`CNF-340`, 10:3463-3464).
5. "The worker already reads the live offer" holds for price (03:671), but no sentence names the provider call,
   and one HTTP request is not guaranteed: List offers "May aggregate several provider endpoints" (02:117;
   astra, sol). `CNF-241` already says "no provider call" (10:2547-2549) while `OPS-43` requires a price
   re-read; it should say no provider mutation (astra, sol).

## Picks

| Reader | Pick | Lands on |
|---|---|---|
| fable | (A) live | `OPS-43`; extend `CNF-241` |
| opus | (A) live, the sale re-test **first**, so an offer both re-priced and unsellable gets one answer, not `price_moved` on one engine and `offer_not_sellable` on another | `OPS-43` after 03:682; extend `CNF-241` |
| astra | (A) live, before any provider mutation "including temporary-key registration" | `OPS-43`, a scope pointer in `OPS-23`; extend `CNF-241` |
| sol | (A) live, date bounds resolved against provider-local today at the check | `OPS-43`; extend `CNF-241` |

Common shape: one current List offers result serves price, presence and sale terms; the descriptor supplies its
bounds with no network I/O (02:75). Failure is `invalid_request`, `details.reason: "offer_not_sellable"`,
`retryable: false` (13:165), no `refusals` or `not_checked`, classified `failed` (`OPS-11`'s create row), the
commitment released under `LDG-39`'s "Deterministic rejection before acceptance" with nothing debited.

## Strongest case for the other side (written on request — not the readers' positions)

All four argued for (C), admission-only, or its snapshot variant:
- The sale is decided "before taking money" (02:273); the explicit later checks name price and disappearance
  only (`OPS-43`, `PRV-42`; sol).
- `PRV-31` keeps term drift out of admission, "This does not move a provider failure or a term learned after
  ordering into admission" (02:565-566), and Q25 already prices it: "Cost past the declared bound is
  operator-borne" (`ADR-0037`:294; fable, opus, astra).
- The snapshot exists because "the offer is a live listing that may have been re-priced, changed or withdrawn in
  the meantime" (03:322-323); the customer bought the listed terms (fable).
- `ADR-0039` already excludes every allowance offer, and no live-evidence procedure exists yet (02:279-281), so a
  conformance item can only assert `unlimited` (fable, opus). Against (C): `ADR-0039` rejected "Accept the
  overage with an alarm" (astra).

Every `file:line` above was checked against `6853d62`. Two reader citations were off and are corrected here:
fable's 02:74 is 02:75, and fable's 03:231 is the `install` row; the `create` row (03:232) gives the same
`failed`.
