# Panel r21 synthesis — the Robot order budget (D1), 2026-10-06

Readers: astra, sol (codex xhigh), fable, opus (claude xhigh); clones at 6280286. All exit 0.
Citations verified against the files.

## Verdict: (d) 4–0 — accept with an alarm; no per-tenant share; no per-order price.

- (a) is the shape ADR-0034 rejected the same day: "Per-tenant shares of the request budget. Fresh
  tenants defeat shares." (fable, opus). A Sybil deposit is an entry price, not a running cost: it
  is spent on the attack's own orders (ADR-0004); total cost is max(N·M, €1.9 × days), not the sum.
- Who loses money at exhaustion: nobody. A refusal settles `failed`, releases the commitment; the
  attacker buys every attack hour at the customer rate (operator earns margin). The harm is lost
  auction sales, ≤ 20/day per account per channel — and 21 honest agents hit the same wall.
- (c) / more prepaid units: the only shape that raises the running price (24 units ≈ €46/day), but
  ADR-0033 escapes ADR-0011 only because "the provider charges the unit"; an operator-chosen minimum
  is the minimum charge ADR-0011 rejected and a second pricing surface ADR-0007 refuses. Upgrade path.

## Defects in my framing (verified)

1. The price is possibly €0, not €2: Robot limits "20 requests per day", not orders; a provider-
   rejected order is "Never debited" (12:1081). Free rejections are inducible: API-13 checks offer and
   image only for length (04:935-939); provider_options is driver-validated with no "before the order";
   N creates can race one auction offer (PRV-42: "specific physical machines"). ADR-0035 already says
   refused orders are "free to an attacker".
2. Standard channel not safely self-limiting: rejections pay no fee; Hetzner publishes zero-setup-fee
   LTD models (AX41-1-LTD, EX44-1-LTD; orderability unverified); PRV-13c forbids relying on a snapshot.
3. Three order endpoints carry the limit (server, server_market, server_addon), not two.
4. Scope (account/user/IP), rolling vs calendar, and whether rejected/test POSTs count: undocumented.
   The throttle (403 RATE_LIMIT_EXCEEDED) carries `max_request` and `interval`.
5. "Every other tenant" is false: SEC-43 already requires multiple accounts and API-57 assigns them;
   one attacker drains only its assigned accounts. (b) is an existing MUST, not an option.
6. PRV-40 contradicts itself ("nothing in this set counts" vs "refuse once exhausted"); its refusal
   has no kind on OPS-11's admission-only list; CNF-283 cites that rule anyway; PRV-44's single
   `order_budget` cannot express per-channel limits; "whole deployment" (02:879) vs "per ordering
   account" (00:380).
7. API-35's minimum (LDG-44) has no number and is absent from OVR-19.

## Gate shape — split

- opus: close the gate on Robot's own 403 for its reported `interval`; no local count (a count cannot
  match Robot's unknown counting; a 403-closed gate cannot drift). The gate is still needed: without
  it each create after exhaustion spends POST /key + order + DELETE /key against the 200/h key limit
  that rescue's temporary keys share.
- fable: count locally, spent at dispatch, rejected and test included, rolling `per`.

## Edits (union)

- PRV-40: correct facts (three endpoints, per account per channel); the gate; the refusal kind
  (`rate_limited` with `retry_after_ms`) on OPS-11's admission-only list and API-7's tail; alarm.
- PRV-44: `order_budget` moves onto `ordering_channels[]`.
- Close free burns: driver validates everything it forwards before the order request (PRV-10 sibling,
  WIR-2); at most one in-flight create per `offer_is_resource` offer (PRV-42); re-check the offer is
  listed before the POST.
- OVR-19: per-channel row; API-35/LDG-44 minimum.
- CNF-283; 08-provider-notes; a new ADR recording the residual and rejected shapes.
- Live test (opus): on server_market 20 invalid POSTs then one test=true; on server 20 test=true then
  one more; keep sending after the first 403 to learn whether the window slides.
- No Lean declaration models the budget; Admission's TailRefusal gains the entry if the kind is new.
