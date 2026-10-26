**Final: ACCEPT; coverage 0/74; none**

## 1. Verdict and arguments

**ACCEPT the whole candidate, no AMEND.** Every CNF-278 and CNF-307 verdict at c5f897c survives, no Lean theorem is touched, and every quotation checks verbatim.

**Strongest argument for.** The repaired S1 makes the stale/absent-listing refusal a healthy-only pre-tail step, and S1c closes the gap r70's opus repair left open by naming the unhealthy account's source. Together they put every unhealthy create back into the unchanged tail at 04:264–266, whose first entry is "`conflict`/`state` for create against a provider account not `healthy`". The 409 headline, the three-status assertion at 10:2789–2792, and the envelope rules at 10:1223–1226 therefore fall out of base text. The no-row case needs no new rule: 04:273–274 already says "An offer absent from the offers the check reads is an unsellable offer for every rule in this tail", so an empty set is the existing absence branch, never a 502. Lean's `purchaseTail` takes `offerSellable` and account status as inputs and models no listing age (Admission.lean:1113–1340), so nothing there flips or goes vacuous; `createPurchaseTail` models only step 5d before the tail.

**Strongest argument against — written on request; not another vote.** S1 reuses the kind `provider`, whose taxonomy row at 01:587 means "Provider returned an error response", for a purely local stale-row condition. S1c gives a recoverable account with no row an `offer_not_sellable` entry whose `retryable: false` tells the caller the offer "cannot be bought on the same request" when the truth is that nothing has been read yet; the envelope goes false although recovery plus one refresh would admit it. STO-60's "Every successful driver List offers read MUST publish" also captures api-process catalogue reads, which OPS-50 at 03:1996 leaves unfenced ("Writes made in the api process are not checked"). None of these changes a checked verdict; all were recorded in r69/r70.

**Brief errors.** None changes the premise. Two notes: the brief's CNF-278 extract trims the lead-in "free balance passed this item.* " from 10:2788 (otherwise byte-identical; CNF-307 and API-7 extracts are byte-identical); and the S6 replace anchor spans a line wrap at 10:3696–3697, so exact-string matching finds it 0 times and whitespace-normalized matching finds it once. The owner record cited is headed for pv-s4m but carries the pv-tcs and pv-ytv rulings at its lines 255–256.

## 2. r70 dissent traces re-run (verified setup: age 60 s, interval 20 s, row read_at 12:00:00, create 12:01:01)

In every row the S1 healthy predicate is false, so the tail runs on S1c's source. No write, no receipt, no provider call in any row (04:287–288).

| Fixture | Source read | Ordered entries (entry retryable) | Headline | Envelope | `not_checked` (cap if supplied, balance) |
|---|---|---|---|---|---|
| `account_unreachable`, interval reads failed | stale row, X sellable | state (true) | 409 conflict/state | true | provider_account_not_healthy |
| `credentials_rejected` + credential stop | same stale row, refreshes exempt | state (true) | 409 conflict/state | true | same; no scheduled retry |
| `terminated`, no row ever | empty set | state (false), offer_not_sellable (false) | 409 conflict/state | false | provider_account_not_healthy, offer_not_sellable |
| `terminated`, stale row, X sellable | stale row | state (false) | 409 conflict/state | false | provider_account_not_healthy |
| recoverable + stale X + solvency + cap | stale row | state (true), solvency (true) | 409 state; no pacing at top level | true | provider_account_not_healthy on both |
| same + no rate | stale row | state, solvency, rate (all true) | 409 state | true | provider_account_not_healthy, rate_unavailable on both |
| terminated + stale X + solvency + cap (+ no rate) | stale row | state (false), solvency (true) [, rate (true)] | 409 state | false | as above |
| any of the above without `max_commitment_sats` | same | same entries | same | same | balance only, same reasons |

r70's 502/true never appears. These are the 10:1253–1255 combination exactly ("`409`, state then solvency, cap and balance unchecked because `provider_account_not_healthy`; repeat with no rate as well and require the rate refusal and both reasons"). Reason order follows 13:163–165.

## 3. S1c: what is read

- **Stale present, X sellable:** the row as stored; no offer entry; state alone. Age is not a fault for an unhealthy account.
- **Stale present, X unsellable (PRV-13b/PRV-31):** state, then offer_not_sellable, per 04:266–268.
- **Present row missing the requested id:** absent from the offers read, so offer_not_sellable follows state (04:273–274).
- **No row:** empty set, so offer_not_sellable follows state. Same entry as the previous case, by the same absence clause.

The 10:1253–1255 sellable combination is tested above and unchanged. CNF-307's "fault alone" singleton for an unhealthy account needs a row containing sellable X, exactly as the base needed the offer to be sellable in "the offers the check reads"; the base never defined that source, so no base verdict exists for a no-row fixture independent of the owner's settled direction. CNF-278's "all three unhealthy statuses" assertion holds for fresh row, stale row and no row, because the headline is entry 0 and entry 0 is always state.

**Alternative if no row must suppress the entry (not my vote; behaviour changed):** replace S1c's clause "or an empty offers set if no listing is stored" with "and, where no listing is stored, collects no offer refusal and no `offer_not_sellable` skip reason". Effect: terminated/no-row becomes state alone (envelope still false); recoverable/no-row becomes state alone with envelope true; every other row above is unchanged. Strongest argument for it: it keeps the recoverable account's envelope honest about retry after recovery and avoids asserting unsellability from no data. Against it: it is a new normative exception to 04:273–274's "for every rule in this tail", unreviewed, outside the settled stored-listing direction, and it hides the data gap from the caller.

## 4. S6 with S1–S5

- **Healthy stale fixture:** demonstrates S1's disclosed pre-tail refusal (502, true, no provider call) without touching CNF-278/307, which assert nothing about a healthy stale listing. Its interaction with surviving items is fixture-only: every create fixture now needs a row inside the age, as the base needed a sellable offer in the source.
- **Stored price / claim price:** sound. OPS-43 step 6 compares "that same List offers result" taken at claim (03:787, 03:855), so admission at the stored price and a claim `price_moved` at 03:865 need no suppressed publication.
- **No-demand refresh, stopped credential, dispatch timestamp, reverse publication, failed read:** each demonstrates one STO-60 or OPS-51 duty at its stated scope ("while ... subject to the authentication stop" in both S3 and S6). Reverse completion has one outcome because STO-60 replaces "only when the incoming `read_at` is later". Neither narrows nor widens.
- **Timing, stop scope, placement, caller, order together:** S1 reads "in that snapshot" inside the LDG-35 transaction; S4's "running in the engine process" puts the refresh's writes under OPS-50; STO-60's caller publication includes claim-time reads in the engine and catalogue reads in api, with only the latter outside the fence and bounded by the later-read_at rule. Consistent.
- **Does S1c need a further assertion?** Nothing demonstrates the unhealthy stale-row and no-row sources by name. I do not AMEND, since an added assertion is behavioural under the rules. Suggested follow-up bead text for CNF-307, after 10:1226: "For the unhealthy-account cases, repeat with the stored listing older than the offer-listing age and with no stored listing: the former changes nothing; the latter adds `offer_not_sellable` after the account entry with its skip reason and no `provider` refusal." Coverage-neutral.
- **Flipped, unreachable or vacuous:** none found. No Lean declaration names a listing, age or source.

## 5. Coverage, actually run

Applied all seven operations from `parts/candidate.json` to `.r71-scratch` inside my clone; all fourteen Markdown files are byte-identical to the coordinator's scratch. Ran `python3 tools/check_coverage.py` there, unpiped.

| Result | Value |
|---|---|
| exit code | 0 |
| ratcheted uncovered | 74 |
| baseline limit | 74 |
| `coverage-baseline.json` sha256 before and after | d7d4e8a4…305b, byte-identical in scratch and clone |

Clone working tree otherwise clean; only the untracked scratch directory exists.

## 6. Strict quoting

Fixed-string grep over whitespace-normalized c5f897c files: S2's PRV-50 excerpt "The driver's List offers MUST be read-only" (02:123), S2's DOM-9 sentence (01:185), S3's PRV-41 excerpt (02:1246–1248, its "(`OPS-26`)" pointer outside the quotation), S6's OPS-43 excerpt (03:865) all match. S1 and S1c assert no other requirement's behaviour; their `STO-47`, `OVR-19` and taxonomy references locate data and settings, and the trailing See pointers are bare. S4 and S6's `STO-60`/`OPS-51` pointers are bare. No MUST is copied into a second owner. Every quotation of proposed STO-60 I rely on is the whole sentence "Every successful driver List offers read MUST publish its complete result to the account's row, replacing an existing row only when the incoming `read_at` is later." (proposed text, not base). One vocabulary note, not a defect: CONTEXT.md's Offer entry avoids "listing" as a synonym for an offer; the candidate's "offer listing" means the List offers result, as DOM-9's "customer offer listing" already does.

Final: ACCEPT; coverage 0/74; none
