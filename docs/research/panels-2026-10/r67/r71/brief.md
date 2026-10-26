# Panel E r71: whole-form preservation candidate. 2026-10-26

You are one of four independent readers in a fresh throwaway clone of `provisiond-spec` at
`c5f897c32f7894d77a544528872176f241394d0d`. Read `AGENTS.md` first. Apply the entire candidate to a
scratch copy in your clone and run the coverage check below, unpiped. Do not run the full gate suite or
`lake`; the coordinator runs the required full gates. Write only inside your clone; no commit, push,
provider API, delegation, background task or waiting. Keep TMPDIR as set. Draft by minute 25; answer
under about 14 KB. The shared brief contains no seat-specific instructions.

## Settled direction, precedence and target

The owner chose **Stored listing (Recommended)** for Q1 `pv-tcs`. Q2 `pv-ytv` is already settled:
**K1–K6 and K-d (Recommended)**, exactly r69's original K-d at brief.md:361–362, without the later
fixture amendment. Q2 needs no further read. Record: `/var/tmp/provisiond-manager/owner-q1-sync-2026-10-23.md`.

Main has settled r70's precedence question as **PRESERVATION**, from the recorded specification on
2026-10-26, subject to the owner's overrule. The owner's stored-listing ruling did not ask to change
the recorded checks. Main's basis is the verbatim `CNF-278` and `CNF-307` source context below,
especially 10:2789–2792, 10:1225–1226 and 10:1253–1255. Read those words as the reason for the
settled priority, not a new direction vote.

**Target: every CNF-278 and CNF-307 verdict at c5f897c is unchanged under the repaired form.**
Read those items whole in your clone. Do not accept a fresh-row witness as disposing of an unchanged
assertion's stale-row counterexample. Do not silently add a listing-age condition to either item.
If this exact candidate cannot meet the target, say so and supply the smallest exact repair, or explain
why it is impossible under the settled direction. The new healthy-account availability assertion in S6
is explicitly proposed; test its interaction with the surviving items too.

## Outcome and required marks

Vote **ACCEPT / AMEND / CANNOT ACCEPT on the whole candidate**. Every AMEND must explicitly mark
**behaviour unchanged** or **behaviour changed**, give the exact before/replacement spans and source
locations, and distinguish your verdict on the printed candidate from your verdict after your repair.
Only a verified wording/quotation/citation repair that changes no stated behaviour counts as ACCEPT.
Added assertions, normative exceptions and payload changes are behavioural regardless of the mark.
Changed, unmarked or failed-verification AMENDs count as CANNOT ACCEPT; preserve their exact text.

At least three counted ACCEPTs with no verified blocking loss make this exact whole candidate a
**reviewed form that goes into the Run**. A blocking loss changes a checked verdict: a CNF assertion or
Lean theorem flipped, made unreachable or vacuous (name it), or a MUST/SHOULD with owner, location and
breaking trace. An explicitly listed assertion amendment is disclosed, not an omitted loss; identify
any further flip. Other objections are recorded and still affect the ACCEPT threshold. Strict quotation
defects are wording repairs, reported with the owner's verbatim words. Coverage is checked and reported;
it is not silently added to this enumerated loss gate. A verified brief error changing this question's
premise **voids that question's tally only**. Rules were fixed before launch in r71 `notes.md`.
No unread combination is cleared by earlier snippet votes. No re-vote of direction or Q2.

## Provenance: unreviewed combined candidate

Reader numbers below are archive author labels, not this round's identities. Source: r70
`parts/candidate.json`, `brief.md`, and `tally.md:75–99`. None of this combination has been reviewed whole.

- **Reader text:** S1's inherited stored-source/timing/input inventory, S3–S5 and the original S6 come
  from archived Reader 4. S2 retains the shared Reader 3/4 DOM-9 row repair and Reader 2's exact caller
  sentence. S6 retains archived Reader 4's added coverage assertions.
- **Reader text:** apply Reader 2's exact r70 S1 replacement restricting the early unavailable-listing
  refusal to a healthy account, and exact S6 replacement making its stale-row fixture healthy.
  These are behavioural repairs relative to r70, not wording-only acceptance conditions.
- **Coordinator text, S1c:** one new sentence, directly after that S1 replacement, defines the unhealthy
  account's offer source: use the stored row even if stale, or an empty offers set when absent.
  S1 below prints that sentence in full. No other new coordinator requirement or assertion is added.

S4 keeps its explicit engine-process placement. No earlier S-a/b/c/d, failed placement replacement,
fresh-read substitution, conditional CNF-278 narrowing, or Q2 amendment is included.

## Complete S candidate — unreviewed combined candidate

- **S1** `04-api-contract.md`, `API-7`: after «without an extra lock, ceiling slot, write or provider call.» insert:
  > On create, the offers the check reads are the provider account's stored offer listing (`05-persistence.md`, `offer_listings`), read in that snapshot, and the tail prices the commitment and takes the offer snapshot from it. Where the account's `STO-47` status in that snapshot is `healthy` and its listing is absent or has a `read_at` older than the stated offer-listing age (`OVR-19`) at the admitting transaction, the create MUST be refused `provider` (`01-domain-model.md`'s error taxonomy) with `retryable: true` before the tail, committing nothing. For an account whose status in that snapshot is not `healthy`, the tail reads its stored listing regardless of age, or an empty offers set if no listing is stored. Every offer-derived input used to size the commitment or populate `request_summary` comes from the named offer in that same stored listing, including recurring price, currency, period, setup fee, `install_strategies`, and any offer-reported billing unit or cancellation bound. Descriptor-declared inputs come from the descriptor the `api` runs with. See `PRV-44`, `PRV-13b` and `05-persistence.md`.

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
  > Separately let a `healthy` account's stored listing be older than the offer-listing age: the create is refused `provider`, `retryable: true`, with no provider call. Separately re-list the named offer, inside the age, at a higher price sufficient to exceed what the admitted reserve covers, leaving the stored listing unchanged until admission: the create is admitted at the stored price, and the claim fails `conflict` with `details.reason: "price_moved"` (`OPS-43`: "where the provider's price has risen past what the reserve covers"). With no customer requests, assert each account declaring `list_offers` is read within each stated offer-listing refresh interval, except while its credential is subject to the authentication stop. Assert no scheduled retry for a stopped credential. After successful reads, assert publication of the complete result with `read_at` equal to the dispatch instant. Complete two reads in reverse dispatch order and assert the row retains the later read's `read_at` and offers. Fail a read and assert the existing row is unchanged. See `STO-60` and `OPS-51`.

## Source context — verbatim c5f897c, not extra amendments

The blocks below are direct source extracts. Source ranges, not coordinator paraphrases, own their lists.
The full `CNF-278` item remains in your clone; its other cases must also retain their verdicts.

### API-7: tail, including offer absence and unchanged ordering (`04-api-contract.md:262–292`)

```text
**Rich purchase tails (create and extend-runway only; amended 2026-10-04, `ADR-0030`).** After steps 1–5d, the tail MUST
collect every applicable refusal once, from one read-only snapshot inside the existing `LDG-35`
transaction, without an extra lock, ceiling slot, write or provider call. `details.refusals`
(`WIR-9a`) MUST be ordered: the request's own resource refusal (`conflict`/`state` for create
against a provider account not `healthy`, or `conflict`/`cancellation_committed` for extension);
then, on create only, `invalid_request`/`offer_not_sellable` when the named offer is
not sellable under `PRV-13b` or `PRV-31`, or absent from the offers the check reads;
then, on create only, `rate_limited` when the offer's account and ordering channel
are closed under `PRV-40`;
`halted`/`solvency`; `halted`/`rate_unavailable`; the commitment-cap refusal (`WIR-17`, `WIR-24`);
`insufficient_balance`. See `ADR-0030` for the order's rationale and `LDG-40` for halt retention.
An offer absent from the offers the check reads is an unsellable offer for every rule in this
tail, including cap and balance suppression and the `WIR-9a` `offer_not_sellable` refusal and
`not_checked` entries. No additional lookup is made for this verdict.
Both halted entries may appear; no duplicate
means no repeated refusal/check, not unique kind strings. The cap and balance checks MUST NOT
run without a rate, nor for create against an unhealthy account or unsellable offer:
`WIR-30` says "an account whose
`STO-47` status is not `healthy` `404`s on this route too". `WIR-9a` owns `not_checked`,
including cap presence, reasons and ordering. Each refusal is exactly
`WIR-9`'s inner error object, with no nested refusal list. Entry 0 is the headline: HTTP status,
`kind`, `message` and per-kind details MUST match it; top-level details additionally carry the
aggregate keys. Only top-level `retryable` may differ, under `WIR-9b`. Pacing belongs to the
headline: its `details.retry_after_ms` and `Retry-After` follow the existing per-kind rules and
`WIR-4`; each entry keeps its own required pacing. No maximum is taken and a subordinate
entry MUST NOT supply pacing to a headline kind that does not require it. A refused tail MUST
commit nothing and write no `STO-35` receipt (`WIR-3`), so clearing faults and resending the same
request/key evaluates afresh. Admission retains the conditional-write guards in `API-63`,
`LDG-62` and `PRV-42`; collection does not replace them with read-only guards. These are admission refusals
(`OPS-11`), never lists in operation views. Steps 1–5d still stop at their first refusal; see
those steps for their rationale. Deposit behavior and other tails are unchanged.
```

### CNF-307: read this entire unchanged item (`10-conformance-checklist.md:1210–1284`)

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
```

### CNF-278: catalogue and create assertions, then claim barriers (`10-conformance-checklist.md:2788–2824`)

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

## r70 stale-row trace and r71's answer

Reuse r70 `tally.md`'s verified source mechanics and history; do not re-verify them. Its common setup:
account A declares ordering and list-offers capabilities, tenant assigned while healthy, age 60 seconds,
refresh interval 20 seconds. A successful read dispatched at 12:00:00 publishes sellable offer X at
12:00:01. No later successful read precedes a fresh-key create at 12:01:01; early checks pass.

1. Recorded account-unreachable at 12:00:10; interval reads fail, retaining the row. r70's S1 answered
   pre-tail 502. In r71 the healthy-only predicate is false, and S1c reads the stale row. With X sellable
   and no other faults, the existing tail supplies a singleton 409 state, retryable true.
2. Authentication failure at 12:00:20 stops that credential; recorded credentials-rejected at :21.
   No scheduled retry is needed. r71 follows the same stale-row tail, retaining 409 state/true.
3. On an independent fixture, terminate before any successful listing. r71 enters the tail with an
   empty offers set: state first, then invalid_request/offer_not_sellable. The terminated state entry
   is false and the envelope remains false. A terminated stale-row fixture with X sellable has state
   alone/false. Neither returns r70's early 502/true.
4. Add solvency halt and a supplied cap to either recoverable stale-row/sellable-X case: 409, state then
   solvency; priced checks skipped for account health. Add absent rate: rate follows solvency and both
   skip reasons remain. No age-generated offer refusal is inserted for a stale row containing sellable X.

These are the coordinator's predictions for the **new** candidate, not additional verified r70 findings
or implementation tests. Source rules for the predictions are quoted above. The empty-set case is the
existing absent-offer branch of API-7 printed above: an absent offer is unsellable, rather than a
sellable-offer fixture with an extra arbitrary offer refusal. A stored row can itself contain an
unsellable offer or omit X; then offer_not_sellable follows state even if the row is fresh or stale.
Do not treat an unhealthy account as a reason to stop collecting independent offer/channel/halt faults.

Preparation traces for every CNF-278/CNF-307 case are in r71 `check/traces.md`, with generated
`trace-cases.json`. They are review aids, not a proof that the specification is implemented.
The coordinator's exact-candidate coverage result is in `check/coverage-result.json`; perform your own
run. Reuse r70's verified 74/exit-0 historical result; do not re-run old candidates.

## Required independent answer

1. Give the whole-candidate verdict and strongest argument. Also give the strongest argument against
   this form, explicitly labelled **written on request; not another vote**. Supply exact replacements
   with the required behaviour mark for every AMEND. Identify any brief error and whether it changes
   the premise. A quotation defect is not itself permission to change the settled behaviour.
2. **Re-run the r70 dissent traces against this repaired candidate**, using the already verified setup:
   account_unreachable with a stale row; credentials_rejected plus credential stop and a stale row;
   terminated with no row; and the solvency + supplied-cap variant. Report ordered refusal entries,
   headline HTTP/kind/reason, each entry's retryability, envelope retryability, skipped checks, and writes
   or provider calls. Include the no-rate repetition and the terminated stale-row counterpart.
3. **Coordinator offer-check sentence S1c:** determine exactly what is read for missing and stale rows;
   does an offer entry follow state, and which one? Try stale present/sellable, stale present/unsellable,
   present row missing the requested id, and no row. Test the unchanged sellable-offer combination at
   10:1253–1255 explicitly. Test whether any CNF-278/CNF-307 verdict changes; do not narrow their assertions
   to a convenient fixture. If no row must instead use another source or suppress an entry, give exact
   text, its effect on all these cases, and the strongest argument for that alternative.
4. **New conformance assertions:** read all of S6 with S1–S5, including its healthy stale-row fixture,
   stored-price/claim-price assertion and appended no-demand refresh, stopped-credential, timestamp,
   reverse-publication and failed-read assertions. Do they demonstrate the new duties without silently
   narrowing or widening them? Does S1c need a further assertion? Name any flipped/unreachable/vacuous
   surviving assertion, theorem or normative duty and its trace. Check admission snapshot/timing,
   credential-stop scope, process placement, publication caller and dispatch order together.
5. **Coverage — actually run it:** apply the complete S1–S6 above to a scratch copy in your clone and run
   `python3 tools/check_coverage.py`, unpiped. Report actual exit code, ratcheted uncovered count and whether
   `tools/coverage-baseline.json` stayed byte-identical. Do not raise the baseline, infer a run from
   preparation, or substitute a previous candidate. If unable to run, say so. No full gate suite needed.
6. **Strict quoting:** every candidate sentence saying what another requirement does or is must carry
   its verbatim words; a bare See pointer is exempt. Do not copy a MUST into a second normative owner.
   Check every quotation against c5f897c with fixed-string grep, normalizing whitespace only. Check S1c
   and your replacements too. Retain the prescribed S2/S3 source excerpts; their complete source
   sentences are printed above. Any quotation of proposed STO-60 must include its whole publication
   sentence, including the replacement condition, and be identified as proposed text, not base text.

End: `Final: <whole-candidate verdict>; coverage <actual exit>/<uncovered count>; <exact span ids or none>`.
