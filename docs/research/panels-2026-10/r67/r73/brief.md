# Panel E r73 — H primary, U fallback

Read AGENTS.md first. Base/clone: c5f897c32f7894d77a544528872176f241394d0d. Independently apply EACH complete form to a scratch copy and run `python3 tools/check_coverage.py` unpiped; report exit, uncovered count and unchanged-baseline status per form. Keep TMPDIR; write only in your clone. No full gates/lake (coordinator runs them), commits, pushes, provider calls, delegation, background tasks or waiting. Draft by minute 25; answer under 16 KB.

The stored-listing choice and age setting are settled, subject to owner overrule. Q2 remains reviewed K1–K6 + original K-d. Target: (1) every base CNF-278/307 refusal holds at every listing age, including unhealthy state-first precedence; (2) only otherwise-admissible stale stored-listing creates gain provider/retryable true refusal, after collection and before writes; (3) affected successes get fresh fixtures, via H’s blanket default or U’s per-item union.

r72: valid 1 ACCEPT / 3 CA, including one changed AMEND. Carry verified findings without re-verifying: policy holds (1)/(2); CNF-99/299/243 missed success fixtures; CNF-343 continued-race scope was ambiguous. Its exact union is unreviewed. Main directs H’s checklist header to avoid an enumeration missing further successes. Both forms below are **unreviewed combined candidate**; no old votes carry.

Give separately for H and U: ACCEPT / AMEND / CANNOT ACCEPT, strongest argument, and a separately labelled counterargument written on request. Every AMEND explicitly marks **behaviour unchanged** or **behaviour changed**, giving exact before/replacement spans and locations. Only verified wording/quotation/citation repairs count ACCEPT; added assertions, narrowed fixtures, exceptions and payload changes are behavioural. Changed/unmarked/failed-check AMEND counts CA. End with your preference if both are acceptable.

Per form, ≥3 counted ACCEPT and no verified gated loss = reviewed form. If both reach ≥3, readers’ stated preferences pick; tie goes H. Neither reaches 3: neither enters Run; retain exact repairs/dissent for a scoped whole-form read or a non-converging scope/behaviour decision to owner. No unread synthesis substitutes. Gate: a flipped/unreachable/vacuous CNF assertion or Lean theorem (name), or broken MUST/SHOULD (owner + trace). Declared target-(2)/fixture changes are exempt; unlisted flips block. Other objections affect the count. Quotation defects are verified wording repairs; coverage is reported, not an implicit extra gate. A verified premise-changing brief error voids that question's tally only. Full rules: docs/research/panels-2026-10/r67/r73/notes.md.

Explicitly answer: does H cover EVERY success, including proceeds, first send, generic writes, shared winning races, release probes and creates used to reach later assertions? Name any miss. Does H narrow ANY refusal assertion (target 1)? Distinguish earlier setup from a later refusal; inspect retained M8’s explicit continued losing-guard fixtures. A stale age refusal cannot demonstrate a guard. Trace D1–D5, every unhealthy branch, healthy no-row and healthy stale/no-other-refusal with no skipped projections: entries/skips, retryability, pacing, evaluation, amounts, writes and calls. Check strict quoting sentence by sentence: a claim about another requirement carries its verbatim words; bare see references are references only; no MUST outside owner.

Coordinator receipts (not votes): check/sweep.json/.md lists all 352 active items, 112 conservative create paths (45 direct/67 generic or downstream), nine explicitly qualified U items and 103 U omissions. Some injected/driver cases bypass admission; when reached through create H covers that earlier setup. U omissions are disclosed, not a stop; challenge the inventory and header scope. Each applied form: coverage exit 0, 74 uncovered, baseline identical. check/traces.md/trace-cases.json: each has 2304 create + 64 extension projections, zero skipped; only target-(2) policy differences. Source projections, not implementation proof; base comparisons hold offer facts fixed, no-row means absent offer.

Authorship: Reader 1–4 are archive author labels. S1/S6 are Reader 4 including exact A/B; S2 is Reader 4 plus Readers 3/4 DOM-9 row and Reader 2 caller sentence; S3–S5 are Reader 4. All S additions change base behaviour. Reader 4 Q1–Q3 whole-sentence quotation repairs (behaviour unchanged) are integrated verbatim in S2/S3/S6. H header is coordinator; U M1–M7 coordinator, R99/R299 Reader 3, R243 Reader 4; M8 Reader 2; all fixture changes are behaviour changed. H drops M1–M7 and R99/299/243: the header supplies their successes. H keeps exact M8: continued losing guard probes are not supplied by a success-only default; redundant release wording stays verbatim.

Each form is printed independently in full below. U is the unchanged r72 next-read-candidate union, rendered after its Q1–Q3 repairs; archived parts/U.md bytes are identical to r72, and check/printed-forms.json + preparation.out prove final bytes identical. Locations below use zero-based Python character offsets [start,end) in base files, not byte offsets. For after/before insertions use the end/start, respectively. All anchors are in /var/tmp/provisiond-panel-r73/check/printed-forms.json; use its anchors sequentially, or apply base offsets descending within each file. All receipt paths are relative to /var/tmp/provisiond-panel-r73/. No other form’s span is implicit.

## Form H — unreviewed combined candidate

### S1 — 04-api-contract.md; Reader 4 (credits above); behaviour changed
after base character span [22918,22978); lines 264–264. Text:
```text
On create, the offers the check reads are the provider account's stored offer listing (`05-persistence.md`, `offer_listings`), read in that snapshot, and the tail prices the commitment and takes the offer snapshot from it. On create, the tail reads the stored listing regardless of age, or an empty offers set if no listing is stored. If the tail has collected no refusal and the stored listing has a `read_at` older than the stated offer-listing age (`OVR-19`) at the admitting transaction, the create MUST be refused `provider` (`01-domain-model.md`'s error taxonomy) with `retryable: true` before any admission write, committing nothing. Every offer-derived input used to size the commitment or populate `request_summary` comes from the named offer in that same stored listing, including recurring price, currency, period, setup fee, `install_strategies`, and any offer-reported billing unit or cancellation bound. Descriptor-declared inputs come from the descriptor the `api` runs with. See `PRV-44`, `PRV-13b` and `05-persistence.md`.
```

### S2 — 05-persistence.md; Reader 4 (credits above); behaviour changed
before base character span [59289,59302); lines 570–570. Text:
```text
### `offer_listings`

**STO-60** `read_at` is the dispatch instant of the successful driver List offers call. Every successful driver List offers read MUST publish its complete result to the account's row, replacing an existing row only when the incoming `read_at` is later. A failed read MUST leave the row unchanged. The read's caller publishes the result, outside the driver read: `PRV-50` says “The driver's List offers MUST be read-only under `PRV-12`'s guarantee: "Get machine MUST be read-only and free of side effects".” See `OPS-51`.

| Column | Type | Notes |
|---|---|---|
| `provider_account` | text | primary key |
| `read_at` | timestamp | see `STO-60` |
| `offers` | json | the driver's List offers result (`DOM-9`: "Prices MUST be carried as strings exactly as the provider returned them.") |
```

### S3 — 03-operation-lifecycle.md; Reader 4 (credits above); behaviour changed
after base character span [169684,169735); lines 2001–2001. Text:
```text
**OPS-51** A refresh pass MUST read every account declaring `list_offers` at least once per stated offer-listing refresh interval, except while that credential is subject to the authentication stop. `PRV-41` says “A driver MUST therefore treat an `authentication` failure as terminal for that credential, MUST NOT re-attempt it on a schedule, and MUST surface it for an operator (`OPS-26`).”
```

### S4 — 00-overview.md; Reader 4 (credits above); behaviour changed
after base character span [21295,21401); lines 296–296. Text:
```text
| Offer-listing refresh (`OPS-51`) | `engine`, running in the engine process | See `OPS-50`. |
```

### S5 — 00-overview.md; Reader 4 (credits above); behaviour changed
after base character span [29073,29187); lines 386–386. Text:
```text
| Offer-listing age | `API-7` | finite, positive duration | yes |
| Offer-listing refresh interval | `OPS-51` | finite, positive duration, shorter than the offer-listing age | yes |
```

### S6 — 10-conformance-checklist.md; Reader 4 (credits above); behaviour changed
replace base character span [328018,328069); lines 3695–3696. Text:
```text
absent from the stored offer listing
```

### S6 — 10-conformance-checklist.md; Reader 4 (credits above); behaviour changed
after base character span [328330,328415); lines 3699–3699. Text:
```text
Separately let a `healthy` account's stored listing contain the named sellable offer and be older than the offer-listing age, with no other refusal condition: the create is refused `provider`, `retryable: true`, after tail collection and before any admission write, with no provider call. Separately re-list the named offer, inside the age, at a higher price sufficient to exceed what the admitted reserve covers, leaving the stored listing unchanged until admission: the create is admitted at the stored price, and the claim fails `conflict` with `details.reason: "price_moved"` (`OPS-43`: “After the sale re-test passes, and before any per-order key upload or other provider mutation, the worker MUST re-read the offer's current price from that same List offers result **in the provider's own currency** and compare it with the native price the commitment was sized from — **carried on the operation's `request_summary`, which MUST hold the accepted recurring price, its currency and its period, and the accepted setup fee and prepaid first unit, the unit with its `billing_unit.seconds`** (`LDG-2`, `LDG-67`; *the unit and its seconds added 2026-10-08, `ADR-0033`, because the machine's row copies the seconds for its first seed, `LDG-38`, `05-persistence.md`*; *the fields are named so a worker restarted before claim can perform this comparison at all*; *named 2026-09-05 — a first form cited a native figure on the commitment row, which carries only `reserved_sats`*) — and **fail the operation deterministically — before any provider mutation — where the provider's price has risen past what the reserve covers**: `conflict`, `details.reason: "price_moved"`, the shortfall in `details`, telling the caller to re-submit, and `retryable: true` on both the error and the operation view (`WIR-9b`).”). With no customer requests, assert each account declaring `list_offers` is read within each stated offer-listing refresh interval, except while its credential is subject to the authentication stop. Assert no scheduled retry for a stopped credential. After successful reads, assert publication of the complete result with `read_at` equal to the dispatch instant. Complete two reads in reverse dispatch order and assert the row retains the later read's `read_at` and offers. Fail a read and assert the existing row is unchanged. See `STO-60` and `OPS-51`.
```

### M8 — 10-conformance-checklist.md; Reader 2; behaviour changed
replace base character span [362592,362774); lines 4106–4107. Text:
```text
Kill the winner after step 8 commits and keep it unresolved across engine restart and assert further creates lose on every replica; settle it and assert the exclusion releases. Each of these further creates, including any create used to show the release, uses a stored listing containing the named sellable offer, with its `read_at` no older than the offer-listing age (`OVR-19`) at the admitting transaction.
```

### H — 10-conformance-checklist.md; coordinator; behaviour changed
before base character span [2072,2089); lines 32–32. Text:
```text
**Stored offer listings in the items below** (2026-10-26): An item that asserts or relies on a create being admitted or succeeding, including a create used to show a release, without specifying the stored listing's age, runs on a stored listing that contains the named offer and has a `read_at` no older than the stated offer-listing age at the admitting transaction (see `OVR-19`). This default qualifies only the admission or success assertion and any create used to reach it; an item asserting a refusal without specifying the stored listing's age asserts it whatever that age. For the stale-listing refusal case, see `CNF-166`.
```

## Form U — unreviewed combined candidate

### S1 — 04-api-contract.md; Reader 4 (credits above); behaviour changed
after base character span [22918,22978); lines 264–264. Text:
```text
On create, the offers the check reads are the provider account's stored offer listing (`05-persistence.md`, `offer_listings`), read in that snapshot, and the tail prices the commitment and takes the offer snapshot from it. On create, the tail reads the stored listing regardless of age, or an empty offers set if no listing is stored. If the tail has collected no refusal and the stored listing has a `read_at` older than the stated offer-listing age (`OVR-19`) at the admitting transaction, the create MUST be refused `provider` (`01-domain-model.md`'s error taxonomy) with `retryable: true` before any admission write, committing nothing. Every offer-derived input used to size the commitment or populate `request_summary` comes from the named offer in that same stored listing, including recurring price, currency, period, setup fee, `install_strategies`, and any offer-reported billing unit or cancellation bound. Descriptor-declared inputs come from the descriptor the `api` runs with. See `PRV-44`, `PRV-13b` and `05-persistence.md`.
```

### S2 — 05-persistence.md; Reader 4 (credits above); behaviour changed
before base character span [59289,59302); lines 570–570. Text:
```text
### `offer_listings`

**STO-60** `read_at` is the dispatch instant of the successful driver List offers call. Every successful driver List offers read MUST publish its complete result to the account's row, replacing an existing row only when the incoming `read_at` is later. A failed read MUST leave the row unchanged. The read's caller publishes the result, outside the driver read: `PRV-50` says “The driver's List offers MUST be read-only under `PRV-12`'s guarantee: "Get machine MUST be read-only and free of side effects".” See `OPS-51`.

| Column | Type | Notes |
|---|---|---|
| `provider_account` | text | primary key |
| `read_at` | timestamp | see `STO-60` |
| `offers` | json | the driver's List offers result (`DOM-9`: "Prices MUST be carried as strings exactly as the provider returned them.") |
```

### S3 — 03-operation-lifecycle.md; Reader 4 (credits above); behaviour changed
after base character span [169684,169735); lines 2001–2001. Text:
```text
**OPS-51** A refresh pass MUST read every account declaring `list_offers` at least once per stated offer-listing refresh interval, except while that credential is subject to the authentication stop. `PRV-41` says “A driver MUST therefore treat an `authentication` failure as terminal for that credential, MUST NOT re-attempt it on a schedule, and MUST surface it for an operator (`OPS-26`).”
```

### S4 — 00-overview.md; Reader 4 (credits above); behaviour changed
after base character span [21295,21401); lines 296–296. Text:
```text
| Offer-listing refresh (`OPS-51`) | `engine`, running in the engine process | See `OPS-50`. |
```

### S5 — 00-overview.md; Reader 4 (credits above); behaviour changed
after base character span [29073,29187); lines 386–386. Text:
```text
| Offer-listing age | `API-7` | finite, positive duration | yes |
| Offer-listing refresh interval | `OPS-51` | finite, positive duration, shorter than the offer-listing age | yes |
```

### S6 — 10-conformance-checklist.md; Reader 4 (credits above); behaviour changed
replace base character span [328018,328069); lines 3695–3696. Text:
```text
absent from the stored offer listing
```

### S6 — 10-conformance-checklist.md; Reader 4 (credits above); behaviour changed
after base character span [328330,328415); lines 3699–3699. Text:
```text
Separately let a `healthy` account's stored listing contain the named sellable offer and be older than the offer-listing age, with no other refusal condition: the create is refused `provider`, `retryable: true`, after tail collection and before any admission write, with no provider call. Separately re-list the named offer, inside the age, at a higher price sufficient to exceed what the admitted reserve covers, leaving the stored listing unchanged until admission: the create is admitted at the stored price, and the claim fails `conflict` with `details.reason: "price_moved"` (`OPS-43`: “After the sale re-test passes, and before any per-order key upload or other provider mutation, the worker MUST re-read the offer's current price from that same List offers result **in the provider's own currency** and compare it with the native price the commitment was sized from — **carried on the operation's `request_summary`, which MUST hold the accepted recurring price, its currency and its period, and the accepted setup fee and prepaid first unit, the unit with its `billing_unit.seconds`** (`LDG-2`, `LDG-67`; *the unit and its seconds added 2026-10-08, `ADR-0033`, because the machine's row copies the seconds for its first seed, `LDG-38`, `05-persistence.md`*; *the fields are named so a worker restarted before claim can perform this comparison at all*; *named 2026-09-05 — a first form cited a native figure on the commitment row, which carries only `reserved_sats`*) — and **fail the operation deterministically — before any provider mutation — where the provider's price has risen past what the reserve covers**: `conflict`, `details.reason: "price_moved"`, the shortfall in `details`, telling the caller to re-submit, and `retryable: true` on both the error and the operation view (`WIR-9b`).”). With no customer requests, assert each account declaring `list_offers` is read within each stated offer-listing refresh interval, except while its credential is subject to the authentication stop. Assert no scheduled retry for a stopped credential. After successful reads, assert publication of the complete result with `read_at` equal to the dispatch instant. Complete two reads in reverse dispatch order and assert the row retains the later read's `read_at` and offers. Fail a read and assert the existing row is unchanged. See `STO-60` and `OPS-51`.
```

### M1 — 10-conformance-checklist.md; coordinator; behaviour changed
replace base character span [109057,109185); lines 1292–1293. Text:
```text
Clear recoverable faults and, for create, publish a stored listing containing the named sellable offer, with its `read_at` no older than the offer-listing age (`OVR-19`) at the admitting transaction; resend the exact request and key: admission succeeds, proving refusal left no replay receipt.
```

### M2 — 10-conformance-checklist.md; coordinator; behaviour changed
replace base character span [99163,99362); lines 1165–1167. Text:
```text
For the EUR create, use a stored listing containing the named sellable offer, with its `read_at` no older than the offer-listing age (`OVR-19`) at the admitting transaction. Assert that an EUR create and `extend-runway` are admitted, a deposit mints, no unsettled invoice is cancelled, and the deposit read reports `gate: null` and `lightning.cancelled: false`.
```

### M3 — 10-conformance-checklist.md; coordinator; behaviour changed
replace base character span [66947,67083); lines 805–806. Text:
```text
For the commitment assertions in this item, use a stored listing containing the named sellable offer, with its `read_at` no older than the offer-listing age (`OVR-19`) at the admitting transaction. Create against an offer with a non-zero unit: the commitment includes `first_unit` at the customer rate and the setup fee at cost.
```

### M4 — 10-conformance-checklist.md; coordinator; behaviour changed
replace base character span [326156,326318); lines 3674–3675. Text:
```text
Two concurrent creates, each using a stored listing containing the named sellable offer, with its `read_at` no older than the offer-listing age (`OVR-19`) at the admitting transaction, against a balance that can fund exactly one result in one commitment and one `insufficient_balance` — under load, not by code review.
```

### M5 — 10-conformance-checklist.md; coordinator; behaviour changed
replace base character span [327497,327663); lines 3690–3691. Text:
```text
With a stored listing containing the named sellable offer, with its `read_at` no older than the offer-listing age (`OVR-19`) at the admitting transaction, an otherwise sellable offer with a bound no later than provider-local today and a sellable traffic bound is admitted and opens a commitment sized to that bound.
```

### M6 — 10-conformance-checklist.md; coordinator; behaviour changed
replace base character span [362265,362585); lines 4102–4105. Text:
```text
For this race, each create uses a stored listing containing the named sellable offer, with its `read_at` no older than the offer-listing age (`OVR-19`) at the admitting transaction. Both read an open snapshot; at the admitting conditional-write barrier exactly one wins, and the loser receives an ordinary HTTP `409 conflict`/`state` error with `retryable: false`, no `details.refusals`, no synthesized pacing or `Retry-After`, and no commitment, balance change, operation or receipt.
```

### M7 — 10-conformance-checklist.md; coordinator; behaviour changed
replace base character span [362781,362828); lines 4108–4108. Text:
```text
With each create using a stored listing containing the named sellable offer, with its `read_at` no older than the offer-listing age (`OVR-19`) at the admitting transaction, a catalogue product admits independent creates.
```

### R99 — 10-conformance-checklist.md; Reader 3; behaviour changed
replace base character span [59801,60119); lines 721–724. Text:
```text
**A sub-quorum pass with
      a fresh window**: for the create-success assertion in this case, use a stored listing
      containing the named sellable offer, with its `read_at` no older than the offer-listing
      age (`OVR-19`) at the admitting transaction. With a window that produces a rate, run
      one pass below `LDG-59`'s quorum and assert that creates and re-derivations proceed at
      the rate in force, that no `LDG-40` halt fires and no `LDG-64` outage opens, and that
      the next accepting pass recomputes the rate.
```

### R299 — 10-conformance-checklist.md; Reader 3; behaviour changed
replace base character span [92992,93521); lines 1093–1099. Text:
```text
Saturate one replica's
      write checkouts and assert the next write, under a key never sent before, is refused
      `overloaded`, 503, with `retry_after_ms`, that `STO-35` holds no receipt for that key, and
      that a read still succeeds under the separate read budget. After capacity returns,
      for the successful first-send retry of a create, publish a stored listing containing
      the named sellable offer, with its `read_at` no older than the offer-listing age
      (`OVR-19`) at the admitting transaction; resend the same key and assert it succeeds as
      a first send. Then repeat with a key whose first send committed before its reply was
      lost, and assert the re-send after the refusal returns the existing operation (`API-11`).
```

### R243 — 10-conformance-checklist.md; Reader 4 (credits above); behaviour changed
replace base character span [276630,276874); lines 3105–3108. Text:
```text
After `SEC-46` records a
      confirmed termination, the affected tenants are surfaced to the operator, the re-assignment
      verb gives one of them a live account, `GET /v1/providers` then returns it, and, with a stored listing containing the named sellable offer, with its `read_at` no older than the offer-listing age (`OVR-19`) at the admitting transaction, a create against it succeeds.
```

### M8 — 10-conformance-checklist.md; Reader 2; behaviour changed
replace base character span [362592,362774); lines 4106–4107. Text:
```text
Kill the winner after step 8 commits and keep it unresolved across engine restart and assert further creates lose on every replica; settle it and assert the exclusion releases. Each of these further creates, including any create used to show the release, uses a stored listing containing the named sellable offer, with its `read_at` no older than the offer-listing age (`OVR-19`) at the admitting transaction.
```

## Full base refusal contexts

### CNF-307 — whole base item, 10:1210–1300

```text
- [ ] **CNF-307** — **Rich purchase-tail refusals.** Exercise create and extend-runway after
the common pipeline, with a fresh key each time. For each fault alone assert a singleton
`details.refusals` whose singleton is exactly a `WIR-9` inner object, matching
the headline and its HTTP status: unhealthy create account or fenced extension `409`
`conflict` (reason `state` or `cancellation_committed`); unsellable create offer
`400` `invalid_request` (`reason: offer_not_sellable`, no cap or balance amount);
closed create ordering channel `429` `rate_limited` (`retry_after_ms`);
solvency halt or absent rate `503`
`halted` (gate `solvency` or `rate_unavailable`); cap exceeded `400` `invalid_request`
(`max_commitment_sats`, `required_sats`); balance short `402` `insufficient_balance`
(`available_sats`, `required_sats`). Assert `WIR-9a`'s per-refusal retryability and required pacing, including each
recoverable account status (`true`) and a terminated account (`false`), each from the
collection snapshot. For the sellable-offer unhealthy-account combinations below,
repeat with `account_unreachable`, `credentials_rejected` and `terminated`:
the first two account entries are retryable and retain envelope `retryable: true`
when all other entries are retryable; termination makes the envelope
`retryable: false`.
(*Amended 2026-10-04, `pv-gip.26`, S2.*)
No entry contains a nested list, no check/refusal repeats, and every refusing tail writes
no commitment, balance, machine, operation or receipt and makes no provider call.

A closed create ordering channel alone is `429 rate_limited` with
`retry_after_ms` in its entry and headline, `Retry-After`, and retryable true;
the same request/key re-evaluates after the closure clears. The stored closure
adds no `not_checked` reason and does not withhold a price. Combine a healthy,
sellable create with closure, solvency halt, absent rate, optional cap and short
balance: require channel before solvency/rate; `rate_unavailable` skips both
cap and balance when a cap is supplied, and balance alone when no cap is
supplied. Retain any
other applicable skip reasons in their defined order.
With an available rate,
exercise channel + solvency + cap + balance and channel + balance. Vary subordinate
delays: a longer halt delay under a channel headline never replaces the channel's
own pacing. The closure never affects an extension or early-pipeline refusal.

Fence + solvency + absent rate: HTTP `409`, entries fence/solvency/rate in that order;
with a supplied cap, cap and balance each unchecked because `rate_unavailable`; headline has no synthesized
pacing. Solvency + short balance with a rate: HTTP `503`, envelope `retryable: false`,
entries solvency (`retryable: true`) then balance (`retryable: false`), with the balance's
amounts only in the balance entry; solvency's own pacing appears at the top level and in
the solvency entry. Give the subordinate
rate entry a longer delay in a solvency+rate case and assert headline pacing is unchanged.
Cap + short balance: HTTP `400`, cap before balance, envelope false and `not_checked: []`.
An unhealthy create account + sellable offer + solvency halt with a supplied cap: `409`, state then solvency, cap and balance
unchecked because `provider_account_not_healthy`; repeat with no rate as well and require
the rate refusal and both reasons for each skipped check. A skipped check never appears
as a priced refusal or as passed. A fenced extension with a rate still evaluates cap and
balance; empty `not_checked` proves they ran even though the resource refused.

On an unsellable create with a healthy account and available rate, assert a
singleton offer refusal, false retryability, and both priced checks skipped for
`offer_not_sellable` when a cap is supplied. Omit the cap and assert only balance
is skipped. Even if cap and balance would fail at a hidden price, neither
priced refusal nor cap or balance amount derived from that price may appear
in the headline details or a refusal entry. Combine a recoverable account, unsellable offer,
solvency halt and absent rate: order account, offer, solvency, rate; headline
`409`/`state`, retryable account entry but false envelope retryability, and every applicable skip reason
appears once per present check in account, offer, rate order. Repeat with
healthy and terminated accounts, rate available and absent, and a supplied and
omitted cap. A priced extension retains its existing checks; the create-only
sale guard never refuses it or adds an `offer_not_sellable` skip reason.

Add the closed channel to that account + offer + solvency + absent-rate case:
order account, offer, channel, solvency, rate, each once. The false offer entry
makes envelope retryability false even though a recoverable account and channel
are retryable; a terminated account also makes it false. A longer channel delay
under either account or offer headline MUST NOT supply headline pacing.
Repeat with a sellable offer and recoverable/terminated accounts to show a
channel entry can be subordinate to the account without hiding independent faults.

Repeat the sellable-offer absent-rate and unhealthy-account cases without `max_commitment_sats`: only balance
appears in `not_checked`, with every applicable reason and no cap refusal. With a rate and
healthy account and sellable offer, omitting the cap leaves balance evaluated and
`not_checked: []`.
(*Amended 2026-10-04, `pv-gip.26`, `ADR-0030`.*)

*Amended 2026-10-09 (`ADR-0039`, `ADR-0030`'s Q12 amendment): the
create-only offer refusal and its skipped price checks qualify the
account, rate and optional-cap combinations above.*
*Amended 2026-10-09 (`ADR-0036`, `ADR-0030`'s Q12 amendment):
the create-only channel entry and its headline/subordinate pacing join the combinations.*

Clear recoverable faults and resend the exact request and key: admission succeeds, proving refusal
left no replay receipt. Check singleton/no-rate `not_checked` as well as the empty list
when priced checks ran. Authenticate, authorize, validate body/key, replay, suspend and
exhaust the ceiling independently before the tail: retain the first early result with no
rich list or extra ceiling slot. Deposit refusals and operation-view errors retain their
existing shape. Race admission against the existing account/fence conditional-write guards;
rich collection must not weaken either guard. (`API-7`, `API-63`, `WIR-9`, `WIR-9a`,
`WIR-9b`, `WIR-4`, `WIR-17`, `WIR-24`, `WIR-30`, `PRV-13b`, `PRV-31`,
`LDG-35`, `LDG-62`, `STO-35`, `OPS-11`)
```

### CNF-278 — whole create/claim passage, 10:2788–2824

```text
**Then assert the account stops being sellable**: `GET
/v1/providers` omits it for an assigned tenant, and a create naming it is `409` `state` —
including a create issued against a catalogue read taken **before** the termination, since the
listing is advisory. Assert the refusal on **all three** unhealthy statuses and on **both**
catalogue routes — the collection and `/providers/{account}/offers` (`WIR-30`).
**Barrier case, and it is the one a lock alone fails**: hold a meter tick
that has already read the machine as billable, commit the termination, then release the tick —
it must post nothing, because `LDG-38` re-reads billability inside the serialization rather
than trusting what it read before. **Second barrier**: admit a create that passes the health
check, commit the termination before its commitment opens, and assert the create is refused —
the create **conditional-writes** `STO-47`'s row guarded on `healthy` in the transaction that opens
the commitment, and a mere read there is not enough under snapshot isolation. **Third**: leave
a create `queued` and unclaimed naming the account, commit the termination, and assert it is
`failed` with `details.reason: "account_terminated"` and its commitment released — a worker
that claims it afterwards dispatches against revoked credentials and freezes the customer's
money for `OPS-33`'s window. **Fourth**: claim a create, commit the termination before its
step-8 transaction commits (`about_to_order_at` still null), and assert it fails `account_terminated`
with `retryable: false` on both the error and the operation view (`API-63`: “with
`retryable: false` for `"account_terminated"` and `retryable: true` for `"state"` on both the
error and the operation view”) and with no provider mutation;
the List offers read is permitted;
then commit the termination *after* step 8 commits (`about_to_order_at` set) and before the call, and assert the
termination treats that attempt as potentially dispatched — neither failed nor released, and
resolved through `OPS-36`'s late attach.
**Account-read cases:** admit a create and leave it `queued` and unclaimed, record
`credentials_rejected` before claim, then claim it; repeat with `account_unreachable` on
another account. Assert `OPS-43`'s step 1, "Read the
provider account's stored status", fails it `conflict` with `details.reason: "state"` and
`retryable: true` on both the error and the operation view, `failed`, no provider request
and full commitment release. On a fresh account, claim a
create, let the List offers read complete, then commit termination before step 8 commits (`about_to_order_at` null). Assert `conflict`, `details.reason: "account_terminated"`,
`retryable: false` on both the error and the operation view, `failed`, full commitment
release, and no provider mutation: no per-order key upload and no order request.
Repeat the step-8 barriers and account-read cases with an auction-channel descriptor and
a standard-channel (`correlator: none`) descriptor; assert the column's null/set test on
both, and each failing case's `retryable` value above, making no assertion about the
correlator pair on the latter.
```

Read complete CNF-278 in your clone too, including its independent fixtures and surrounding status/recording cases. The quoted create/claim passage above includes every barrier and account-read case through the next heading.
