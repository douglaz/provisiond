# Panel E r72 — one whole-form read. 2026-10-26

Read AGENTS.md first. Your throwaway clone is at c5f897c32f7894d77a544528872176f241394d0d.
Apply the entire candidate in a scratch copy; run `python3 tools/check_coverage.py` unpiped;
report exit, uncovered count and baseline status. No full gates/lake (coordinator runs them),
commit, push, provider API, delegation, background task or waiting. Write only inside your clone.
Keep TMPDIR. Draft by minute 25; answer under about 14 KB.

## Settled target and why

Owner: Stored listing (Recommended), including its age setting. Main's 2026-10-26 restatement
is settled, subject to owner overrule; record: `/var/tmp/provisiond-manager/owner-q1-sync-2026-10-23.md`.

1. Refusals are never hidden by age: every base refusal verdict of CNF-278 and CNF-307 holds whatever
   the listing's age, including the settled unhealthy-account state-first precedence.
2. One new refusal only: an otherwise-admissible create whose stored listing is older than the
   offer-listing age (OVR-19) is refused provider, retryable true. This retains the owner's age setting.
3. Every base success assertion (2) changes gets an explicit fresh-listing fixture condition,
   listed as its CNF amendment. Rule 3 exempts listed amendments; omitted flips still block.

The old all-verdicts-unchanged target cannot retain the owner's age refusal. Removing that refusal
is outside this read. Q2's reviewed K1–K6 and original K-d remain settled; no re-vote.

## r71 result, carried forward

Raw 2 ACCEPT / 2 CANNOT ACCEPT. The unhealthy repair works; both dissents verified the same inherited
healthy stale-listing refusal pre-empting the tail (D1–D5, r71 tally.md:49–56). Carry those verified
findings forward. The VOID came from main's tally-prompt instruction, not notes rule 6: the shortened
CNF-307 omitted 10:1285–1300, but no premise change was established. Under rule 6 r71 was valid 2–2.

## Outcome and required answer

Vote ACCEPT / AMEND / CANNOT ACCEPT on the WHOLE candidate. Every AMEND marks behaviour unchanged
or behaviour changed and supplies exact before/replacement spans and locations. Only verified
wording/quotation/citation repair counts as ACCEPT. New assertions, fixture narrowing, payload changes
and normative exceptions are behavioural. Changed/unmarked/failed-check AMENDs count CANNOT ACCEPT.

At least 3 counted ACCEPT with no verified gated loss makes this exact whole candidate a reviewed
form that goes into the Run. Gate: flipped/unreachable/vacuous CNF assertion or Lean theorem (name it),
or broken MUST/SHOULD (owner and trace). Listed assertion amendments are exempt; omitted flips block.
Other objections affect the threshold. Quotation defects are wording repairs with verbatim owner words.
Coverage is reported, not an extra implicit loss gate. An error changing the premise voids that
question's tally only; report other errors and dependent votes. Full rules: r72 notes.md, 1–7.

Give your strongest argument and a counterargument written on request, separate from your vote.

## Provenance — unreviewed combined candidate

Archive author labels map to names in notes.md. Every S1–S6 addition is reader text, behaviour changed
relative to base; M1–M7 are coordinator text, behaviour changed. No whole-form approval is inherited.

- S1: Archive Reader 4's source/timing/input text plus that reader's exact r71 A replacing the
  S1/S1c before-span. Behaviour changed relative to r71; coordinator S1c is fully replaced.
- S2: inherited stored-row text plus Readers 3/4's DOM-9 row and Reader 2's caller sentence.
  S3–S5: Reader 4's refresh, explicit engine-process placement and settings. Unchanged from r71.
- S6: Reader 4's assertion/coverage append with that reader's exact r71 B stale-fixture replacement;
  behaviour changed relative to r71. M1–M7 are voted on too; their reasons are coordinator analysis.

No optional C, follow-up text, no-row suppression alternative or no-age-refusal form is imported.

## Complete candidate — unreviewed combined candidate

- **S1** `04-api-contract.md`, `API-7`: after «without an extra lock, ceiling slot, write or provider call.» insert:
  > On create, the offers the check reads are the provider account's stored offer listing (`05-persistence.md`, `offer_listings`), read in that snapshot, and the tail prices the commitment and takes the offer snapshot from it. On create, the tail reads the stored listing regardless of age, or an empty offers set if no listing is stored. If the tail has collected no refusal and the stored listing has a `read_at` older than the stated offer-listing age (`OVR-19`) at the admitting transaction, the create MUST be refused `provider` (`01-domain-model.md`'s error taxonomy) with `retryable: true` before any admission write, committing nothing. Every offer-derived input used to size the commitment or populate `request_summary` comes from the named offer in that same stored listing, including recurring price, currency, period, setup fee, `install_strategies`, and any offer-reported billing unit or cancellation bound. Descriptor-declared inputs come from the descriptor the `api` runs with. See `PRV-44`, `PRV-13b` and `05-persistence.md`.

- **S2** `05-persistence.md`, new subsection: before «### `tenants`» insert:
  > ### `offer_listings`
  >
  > **STO-60** `read_at` is the dispatch instant of the successful driver List offers call. Every successful driver List offers read MUST publish its complete result to the account's row, replacing an existing row only when the incoming `read_at` is later. A failed read MUST leave the row unchanged. The read's caller publishes the result, outside the driver read: `PRV-50` says "The driver's List offers MUST be read-only". See `OPS-51`.
  >
  > | Column | Type | Notes |
  > |---|---|---|
  > | `provider_account` | text | primary key |
  > | `read_at` | timestamp | see `STO-60` |
  > | `offers` | json | the driver's List offers result (`DOM-9`: "Prices MUST be carried as strings exactly as the provider returned them.") |

- **S3** `03-operation-lifecycle.md`, new requirement after `OPS-50`: after «its guarantee covers one writable database history.» insert:
  > **OPS-51** A refresh pass MUST read every account declaring `list_offers` at least once per stated offer-listing refresh interval, except while that credential is subject to the authentication stop. `PRV-41` says “A driver MUST therefore treat an `authentication` failure as terminal for that credential, MUST NOT re-attempt it on a schedule, and MUST surface it for an operator”.

- **S4** `00-overview.md`, `OVR-17`'s table: after «| `OPS-32`'s account sweep | `engine` | Lists resources at a provider, so it needs a provider credential |» insert:
  > | Offer-listing refresh (`OPS-51`) | `engine`, running in the engine process | See `OPS-50`. |

- **S5** `00-overview.md`, `OVR-19`'s register: after «| Refresh freshness window | `DOM-8` | finite, positive duration at least twice the account-sweep interval | yes |» insert:
  > | Offer-listing age | `API-7` | finite, positive duration | yes |
  > | Offer-listing refresh interval | `OPS-51` | finite, positive duration, shorter than the offer-listing age | yes |

- **S6** `10-conformance-checklist.md`, `CNF-166`: «absent from every source admission could read» → «absent from the stored offer listing»; and after «Cap and balance do not run; there is no commitment, purchase write or provider order.» insert:
  > Separately let a `healthy` account's stored listing contain the named sellable offer and be older than the offer-listing age, with no other refusal condition: the create is refused `provider`, `retryable: true`, after tail collection and before any admission write, with no provider call. Separately re-list the named offer, inside the age, at a higher price sufficient to exceed what the admitted reserve covers, leaving the stored listing unchanged until admission: the create is admitted at the stored price, and the claim fails `conflict` with `details.reason: "price_moved"` (`OPS-43`: "where the provider's price has risen past what the reserve covers"). With no customer requests, assert each account declaring `list_offers` is read within each stated offer-listing refresh interval, except while its credential is subject to the authentication stop. Assert no scheduled retry for a stopped credential. After successful reads, assert publication of the complete result with `read_at` equal to the dispatch instant. Complete two reads in reverse dispatch order and assert the row retains the later read's `read_at` and offers. Fail a read and assert the existing row is unchanged. See `STO-60` and `OPS-51`.

### M1: CNF-307 (`10:1292`), coordinator text — behaviour changed

Before (verbatim base):

```text
Clear recoverable faults and resend the exact request and key: admission succeeds, proving refusal
      left no replay receipt.
```

Replacement (proposal):

```text
Clear recoverable faults and, for create, publish a stored listing containing the named sellable offer, with its `read_at` no older than the offer-listing age (`OVR-19`) at the admitting transaction; resend the exact request and key: admission succeeds, proving refusal left no replay receipt.
```

Coordinator reason: D5: otherwise-successful replay now refuses a stale listing. Only the successful retry fixture is narrowed; all refusal combinations remain age-independent.

### M2: CNF-138 (`10:1165`), coordinator text — behaviour changed

Before (verbatim base):

```text
Assert that an EUR create and `extend-runway` are admitted, a deposit mints, no unsettled
      invoice is cancelled, and the deposit read reports `gate: null` and
      `lightning.cancelled: false`.
```

Replacement (proposal):

```text
For the EUR create, use a stored listing containing the named sellable offer, with its `read_at` no older than the offer-listing age (`OVR-19`) at the admitting transaction. Assert that an EUR create and `extend-runway` are admitted, a deposit mints, no unsettled invoice is cancelled, and the deposit read reports `gate: null` and `lightning.cancelled: false`.
```

Coordinator reason: USD-unrated/EUR-covered success control: a stale EUR listing would otherwise add provider refusal. No rate/solvency refusal fixture is qualified.

### M3: CNF-315 (`10:805`), coordinator text — behaviour changed

Before (verbatim base):

```text
Create against an offer with a non-zero unit: the commitment includes `first_unit` at the
      customer rate and the setup fee at cost.
```

Replacement (proposal):

```text
For the commitment assertions in this item, use a stored listing containing the named sellable offer, with its `read_at` no older than the offer-listing age (`OVR-19`) at the admitting transaction. Create against an offer with a non-zero unit: the commitment includes `first_unit` at the customer rate and the setup fee at cost.
```

Coordinator reason: Positive commitment and zero-unit controls require admission; stale otherwise-successful creates open no commitment. The insufficient-balance refusal retains every age.

### M4: CNF-163 (`10:3674`), coordinator text — behaviour changed

Before (verbatim base):

```text
Two concurrent creates against a balance that can fund exactly one result in
      one commitment and one `insufficient_balance` — under load, not by code review.
```

Replacement (proposal):

```text
Two concurrent creates, each using a stored listing containing the named sellable offer, with its `read_at` no older than the offer-listing age (`OVR-19`) at the admitting transaction, against a balance that can fund exactly one result in one commitment and one `insufficient_balance` — under load, not by code review.
```

Coordinator reason: The asserted one winner opens no commitment if its listing is stale. Keep both contenders fresh through their respective admission snapshots; serialization and the losing balance refusal remain checked.

### M5: CNF-166 (`10:3690`), coordinator text — behaviour changed

Before (verbatim base):

```text
An otherwise sellable offer with a bound no later than provider-local today and a
      sellable traffic bound is admitted and opens a commitment sized to that bound.
```

Replacement (proposal):

```text
With a stored listing containing the named sellable offer, with its `read_at` no older than the offer-listing age (`OVR-19`) at the admitting transaction, an otherwise sellable offer with a bound no later than provider-local today and a sellable traffic bound is admitted and opens a commitment sized to that bound.
```

Coordinator reason: The positive bounded-offer admission assertion otherwise fails on age. All unsellable and never-listed refusal fixtures remain unqualified.

### M6: CNF-343 (`10:4102`), coordinator text — behaviour changed

Before (verbatim base):

```text
Both read an open snapshot; at the admitting conditional-write barrier exactly
      one wins, and the loser receives an ordinary HTTP `409 conflict`/`state`
      error with `retryable: false`, no `details.refusals`, no synthesized pacing
      or `Retry-After`, and no commitment, balance change, operation or receipt.
```

Replacement (proposal):

```text
For this race, each create uses a stored listing containing the named sellable offer, with its `read_at` no older than the offer-listing age (`OVR-19`) at the admitting transaction. Both read an open snapshot; at the admitting conditional-write barrier exactly one wins, and the loser receives an ordinary HTTP `409 conflict`/`state` error with `retryable: false`, no `details.refusals`, no synthesized pacing or `Retry-After`, and no commitment, balance change, operation or receipt.
```

Coordinator reason: The race asserts a winner, which otherwise cannot reach the conditional-write barrier on a stale listing. This listed fixture condition applies to both contenders; it discloses the restriction on the race control as well as its success assertion.

### M7: CNF-343 (`10:4108`), coordinator text — behaviour changed

Before (verbatim base):

```text
A catalogue product admits independent creates.
```

Replacement (proposal):

```text
With each create using a stored listing containing the named sellable offer, with its `read_at` no older than the offer-listing age (`OVR-19`) at the admitting transaction, a catalogue product admits independent creates.
```

Coordinator reason: Independent catalogue admissions otherwise acquire the new age refusal. The catalogue/exclusion distinction remains checked.

## Source context — verbatim c5f897c

### API-7: collection sentence (`04-api-contract.md:262–264`)

```text
**Rich purchase tails (create and extend-runway only; amended 2026-10-04, `ADR-0030`).** After steps 1–5d, the tail MUST
collect every applicable refusal once, from one read-only snapshot inside the existing `LDG-35`
transaction, without an extra lock, ceiling slot, write or provider call.
```

### API-7: offer absence sentences (`04-api-contract.md:273–275`)

```text
An offer absent from the offers the check reads is an unsellable offer for every rule in this
tail, including cap and balance suppression and the `WIR-9a` `offer_not_sellable` refusal and
`not_checked` entries. No additional lookup is made for this verdict.
```

### CNF-307: whole item, through its actual end (`10-conformance-checklist.md:1210–1300`)

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

### CNF-278: complete create refusal and admission/claim barrier passage (`10-conformance-checklist.md:2788–2824`)

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

### PRV-50: complete source sentence (`02-provider-contract.md:123–124`)

```text
**PRV-50** The driver's List offers MUST be read-only under `PRV-12`'s guarantee:
"Get machine MUST be read-only and free of side effects".
```

### PRV-41: complete source sentence (`02-provider-contract.md:1246–1248`)

```text
A driver MUST therefore treat an `authentication` failure as
terminal for that credential, MUST NOT re-attempt it on a schedule, and MUST surface it for an
operator (`OPS-26`).
```

## Trace obligations: challenge the complete form

Coordinator source projections: `/var/tmp/provisiond-panel-r72/check/` files `traces.md`,
`trace-cases.json`, `assertion-inventory.md`. They are not tests, proofs or votes; challenge them.

- D1: healthy stale unsellable/absent offer, rate available, cap supplied/omitted: offer refusal,
  false retryability, ordered skips, no hidden amounts.
- D2: healthy stale sellable + channel closure + solvency + absent rate, both cap choices:
  channel headline/pacing, ordered independent entries and rate skips.
- D3: add channel to unsellable + solvency + rate faults; healthy and every unhealthy status,
  rate present/absent, cap supplied/omitted: entry/skip order and retryability.
- D4: healthy stale sellable, available rate, no cap: balance runs, not_checked empty. A then
  refuses provider if all checks pass. D4 asserts evaluation, not admission; no amendment proposed.
  Test that claim; do not skip balance or silently infer freshness.
- D5: clear faults, retry exact request/key, stale otherwise-successful create: provider refusal
  persists without writes/receipt. M1's explicit fresh fixture then succeeds. Test both.
- EVERY unhealthy branch: status × stale/fresh/no row × sellable/unsellable/absent offer ×
  channel/solvency/rate/cap. Stale sellable must not invent offer refusal; no row reads empty even
  if the live provider sells X. Terminated, or recoverable plus absent offer: envelope false.
- Healthy no-row: now 400 invalid_request / offer_not_sellable, retryable false, NOT 502 provider
  as in r71. Against base this is its absent-offer verdict with offer facts held fixed; base did
  not specify a stored-row policy. Include all other faults, skips and hidden-price suppression.
- Healthy stale with no other refusal: all applicable priced checks run, then provider/502/true
  before any admission write or provider call. At equality with the age limit, no age refusal.
- Every other CNF-307 combination and early/extension/conditional-write control, plus CNF-278's
  whole create/claim barriers. Admission reads stored data; claim still reads the provider.
  All refusing tails: no admission writes, receipt or provider call.

For EACH M1–M7: complete and necessary? Name its base assertion and changed verdict. Inspect elsewhere
for omitted age-sensitive success assertions. Distinguish already-admitted setup and CNF-340's can-reach
admission from an unqualified success assertion. Challenge the inventory; unchanged bytes or a fresh
witness do not defeat an unqualified stale counterexample. Any further fixture amendment needs exact
spans marked behaviour changed. Preserve the target's base refusals at every age.

Strict quoting: claims about another requirement carry its verbatim words and all operative conditions;
quote whole sentences; bare See pointers may remain. Distinguish proposals from base quotes and check
before-spans at c5f897c. Inherited reader excerpts stay exact; PRV-50/41 whole sentences are above.
Supply exact quotation repairs with behaviour classification.

End with: Final: ACCEPT / AMEND (behaviour unchanged or behaviour changed) / CANNOT ACCEPT.
Report coverage command, actual exit, uncovered count, baseline status and any application failure.
