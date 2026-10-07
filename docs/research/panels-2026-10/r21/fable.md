**Verdict: (d), once its price is true** — repair `PRV-40`'s counting so a slot cannot be burned for free, then accept and alarm as `ADR-0034` did for the sibling budget; (b) when demand exists; not (a), not (c).

**Why.** Nothing the system owes spends this budget: `OPS-28` (03:641) says resolution is "restricted to searching and MUST NOT mutate", requeue is withdrawn (README:241), and Robot's order GETs and cancellation have their own limits (500/hour, 200/hour). So exhaustion costs new sales on one account for one window and no operator money; there is nothing for a reserve to protect. Against an anonymous attacker only a price moves the running cost, and you ruled on shares today: `ADR-0034`:57 rejects "Per-tenant shares of the request budget. Fresh tenants defeat shares", and :64 takes the tenant-against-tenant residual as "accepted, priced to the attacker, and alarmed on exhaustion". (a) is that rejected option. What is broken is that the attacker's price is zero, not €2/day, and that is a counting defect.

**Defects in the framing**

1. **The price is €0.** Robot limits "20 requests per day", not orders (https://robot.hetzner.com/doc/webservice/en.html, `POST /order/server_market/transaction`, "Request limit"). A provider-rejected order costs the tenant nothing: `LDG-39` (12:1081) "Deterministic rejection before acceptance | Never debited; released with the commitment"; `ADR-0033`:30 "released in full wherever the provider never charged". Tenants can induce rejections:
   - `API-13` checks `image` and offer only for length (04:936, 939).
   - `provider_options` is "a free-form object whose interior is the driver's to validate" (13:31), with no "before the order request".
   - Nothing stops N creates naming one auction offer, although `PRV-42` (02:915) says the market "lists *specific physical machines*". Concurrent workers all pass `OPS-43`'s re-read (03:613) and one order is accepted.
   - `ADR-0035`:54 already concedes refused orders are "up to twenty a day per account, free to an attacker".
2. **"Self-limiting" fails the same way.** €59 × 20 = €1,180 holds for accepted orders only; a rejected standard order pays no fee. No zero-fee standard product existed on 2026-09-04 (08:141), but `PRV-13c` (02:395) forbids relying on that.
3. **Three endpoints, not two.** `POST /order/server_addon/transaction` carries the same limit; `PRV-40` (02:876) says "two".
4. **Scope and window are undocumented.** The reference never says per account, rolling or calendar, or whether `test=true` counts. The throttle body carries `max_request` and `interval` ("Time interval in seconds"), so the driver can read both. Assume every POST counts until measured.
5. **`PRV-40` has no spend event, window, kind or step.** `CNF-283` (10:1270) says "enforced at admission"; if admission spends, a create that later fails `price_moved` burns a local slot free. `OPS-11`'s admission-only list (03:229) has no kind for it, `API-7`'s tail (04:262) has no entry, and `ceiling_exceeded` means "per-principal" (01:562).
6. **(a) is not "a `SEC-39` ceiling".** Those are per principal per hour (07:209); twenty a day is under one an hour, so a share needs a second interval and an account-and-channel key.
7. **The deposit is an entry price, not a running cost.** It is sunk on payment (`ADR-0004` §1) and spent on the attack's own orders. With share k and minimum M the attacker posts ⌈20/k⌉·M once, which then funds the attack: k=2, M=€10 is €100 for 52 days at €1.92/day.
8. **€2/day is right for accepted orders** (08:379–380: two orders "about €0.16"; ×1.2 ×20 = €1.92, assuming a 20% margin). The operator earns €0.32 of it, and the attacker's commitment (`PRV-13b`) recycles on each delete.
9. **An honest burst exhausts it.** The 21st auction create per account per window is refused with no attacker, and a `PRV-34` test order against a production account spends a slot too. The refusal must be a disclosed state regardless.

**Third shapes**

- **Unit count per offer** is the only one that moves the running price (n=24: €46/day; n=720: €1,382/day, the standard channel's wall). It is (c) under `ADR-0033`'s name: that ADR escapes `ADR-0011`'s "overcharges partial use" only because "the provider charges the unit" (:65), and `PRV-44` (02:67) holds provider facts. Record it as the upgrade path.
- **Pacing:** one slot per 72 minutes; a loop takes each; price unchanged; an honest three-server order waits 3.6 hours.
- **Committed runway:** released on delete (`LDG-32`), so it is capital.
- **History share:** uses only the ledger, so no `ADR-0005` conflict, but one aged tenant drains it; it needs (a) inside it.

**Don't build (a).** Harm is bounded by honest demand: at €50 a month and 20% margin a lost order is €10 a month, and Robot demand today is zero. (a) costs a counter keyed tenant × account × channel × day, a wire refusal, conformance items and Lean ceilings, to raise an entry price whose base (`API-35`) has no number.

**Edits**

- `PRV-40`: per account per order endpoint; spent when the order request is dispatched, rejected and test ones included; rolling `per`; the refusal's kind (`rate_limited` with `retry_after_ms`, no new kind) and its `API-7` tail entry; alarm on exhaustion.
- `PRV-42`: one live create per offer where `offer_is_resource`.
- `PRV-10` or a sibling, `WIR-2`: the driver validates everything it forwards before the order request.
- `PRV-44`, `OVR-19` (00:380): budget per channel; add `API-35`'s minimum, which 00:350 already requires.
- `OPS-11`, `CNF-283`, `08-provider-notes.md` ([verify] items in 4).
- `Provisiond.Admission`: `TailRefusal`, `purchaseTail`, `TailRefusal.rank`. No `Ceiling` change.
- New ADR recording the residual and the rejected options.

Not verified live: whether Robot counts rejected or test POSTs, its window, and what it answers to an invalid `image` or an already-sold offer. Gates not run; nothing edited.
