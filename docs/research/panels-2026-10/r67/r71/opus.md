Saved at `/var/tmp/provisiond-panel-r71/opus/.scratch-r71/answer.md`. Only the untracked `.scratch-r71/` directory was added; no tracked files changed, no commit.

# Panel E r71 — opus

## 1. Verdict: **ACCEPT** (the whole printed S1–S6; no AMEND)

**Strongest argument.** With S1 limited to healthy accounts and S1c added, an unhealthy account is never age-checked. Its create always reaches the tail. The tail's first entry is then the account's `conflict`/`state`, taken from the collection snapshot, whatever the row's age.
- `CNF-278` holds for stale, fresh and absent rows: "a create naming it is `409` `state`" and "Assert the refusal on **all three** unhealthy statuses".
- `CNF-307`'s "termination makes the envelope `retryable: false`" holds. The terminated `state` entry is false, and `WIR-9b` says "the envelope's `retryable` MUST be true iff every refusal entry's `retryable` is true".
- S1c adds no exception to API-7's "An offer absent from the offers the check reads is an unsellable offer for every rule in this tail". An empty set goes through that existing branch.
- `CNF-278` and `CNF-307` are byte-identical after applying the candidate (diffed 10:1210–1284 and 10:2729–2845).

**The target is impossible under the settled direction if "verdict" is read strictly.** The r69 owner question says "Missing or stale data refuses the create." So under S1, a healthy account with a stale or absent row gets 502 `provider`/`true` before the tail. If "verdict" covers every fixture, including a healthy stale row, these healthy `CNF-307` assertions now need a fresh row:
- the healthy singletons in 10:1210–1220
- the channel combination at 1231–1239
- 1240–1243 and 1247–1252
- the healthy cases at 1259–1264, 1267–1268 and 1281–1283

Any stored-listing form has this property, because any refusal changes those responses.

**How I read "verdict" instead.** I read it as the outcome on fixtures that meet the item's own isolation:
- "Exercise create and extend-runway after the common pipeline"
- "For each fault alone"
- combinations that name their faults

That is the same implicit exclusion that keeps steps 5b, 5c and 5d out of those cases today (API-7: "Steps 1–5d still stop at their first refusal"). On that reading nothing flips. What separates this from r70 is reachability:
- **Healthy accounts:** a fresh row is the normal state. Proposed `OPS-51` reads every account "at least once per stated offer-listing refresh interval", and proposed S5 makes that interval "shorter than the offer-listing age". Every healthy fixture stays reachable.
- **r70's unhealthy accounts:** a stale row was the normal state for `credentials_rejected` (`PRV-41`: "MUST NOT re-attempt it on a schedule") and usually for `terminated`. Once the age passed, `CNF-278`'s 409 became unreachable.

This is not a premise error that voids the tally: `check/traces.md` explicitly starts the healthy cases "after that availability check".

**Strongest argument against — written on request; not another vote.**
- The S1 refusal is not a numbered step. "The common pipeline" literally means steps 1–5, "common to every authenticated write". So the unchanged `CNF-307` now carries an unstated listing-age condition, and a fresh-row witness is being used to dismiss a stale-row counterexample.
- Nothing tests S1c. A build that reproduces r70 (502 for an unhealthy stale row) passes every assertion as long as the tester uses fresh rows. The preservation this round exists for has no conformance test.
- The Lean declaration `createPurchaseTail` (`@[req "API-7"]`, `Admission.lean:1165`) still models "Step 5d composed before the create's tail", with nothing in between. S1 changes the Markdown without changing that declaration, against AGENTS.md's "Change the declaration and the Markdown together". `ErrorKind.provider` already exists, so the Run can add a healthy-and-stale input there.

## 2. r70 dissent traces against this candidate

Setup is r70's: age 60 s, interval 20 s, the row's `read_at` is 12:00:00 with X sellable, and the create is at 12:01:01. The row is therefore stale.

Abbreviations:
- **ST** = `conflict`/`state`
- **SO** = `halted`/`solvency`
- **RU** = `halted`/`rate_unavailable`
- **ONS** = `invalid_request`/`offer_not_sellable`
- **pan** = `provider_account_not_healthy`

In every case below:
- The status is not `healthy`, so no pre-tail refusal fires.
- Nothing is written: no commitment, balance, machine, operation, `STO-35` receipt or `offer_listings` row.
- No provider call is made.
- The headline has no pacing; SO keeps its `retry_after_ms` in its own entry.

| Case | Entries in order (retryable) | Headline | Envelope | `not_checked`, in order |
|---|---|---|---|---|
| 1 `account_unreachable`, stale row with X | ST(true) | 409 conflict `state` | true | cap:pan†, balance:pan |
| 2 `credentials_rejected` + credential stop, stale row; no scheduled read | ST(true) | 409 `state` | true | cap:pan†, balance:pan |
| 3 `terminated`, no row → `[]` | ST(false), ONS(false) | 409 `state` | false | cap:pan†, cap:offer_not_sellable†, balance:pan, balance:offer_not_sellable |
| 3′ `terminated`, stale row with X | ST(false) | 409 `state` | false | cap:pan†, balance:pan |
| 3″ recoverable status, no row | ST(true), ONS(false) | 409 `state` | false | as 3 |
| 4 case 1 or 2 + solvency halt + cap | ST(true), SO(true) | 409 `state` | true | cap:pan, balance:pan |
| 4-norate | ST, SO, RU (all true) | 409 `state` | true | cap:pan, cap:rate_unavailable, balance:pan, balance:rate_unavailable |
| 4-terminated | ST(false), SO(true)[, RU(true)] | 409 `state` | false | as 4, or as 4-norate |
| 4-no row (any status) | ST, ONS(false), SO[, RU] | 409 `state` | false | pan, offer_not_sellable[, rate_unavailable] for each check |

† only when `max_commitment_sats` is supplied.

**Against the base:**
- Cases 1, 2, 3′ and 4 match `CNF-307`'s singleton cases, 10:1220–1226 and 10:1253–1255.
- The no-row cases are 10:1258–1262's "account, offer, solvency, rate", plus its terminated repetition.
- None returns r70's 502/true.

**Healthy counterparts:** a stale or absent row gives 502 `provider`, `retryable: true`, with no `refusals` or `not_checked`. It commits nothing, so the same key is evaluated again.

## 3. S1c

**What is read.** For an unhealthy account, the tail reads the stored row's whole `offers` list with no age test. If there is no row, it reads `[]`. The `PRV-13b`/`PRV-31` re-test uses that row and the snapshot's date. An offer entry follows ST exactly when X is absent or unsellable, and that entry is always ONS(false).

| Unhealthy fixture | Entries | Envelope (recoverable / terminated) |
|---|---|---|
| Stale row, X present and sellable | ST | true / false |
| Stale row, X present and unsellable | ST, ONS | false / false |
| Row present without X | ST, ONS | false / false |
| No row | ST, ONS | false / false |

**10:1253–1255** ("unhealthy create account + sellable offer + solvency halt with a supplied cap") is cases 4 and 4-norate above. It can be built on all three statuses:
1. Publish a row while the account is healthy.
2. Change the status. Nothing deletes the row: a failed read leaves it unchanged, a stopped credential gets no read, and termination removes nothing.

With `[]`, the fixture is not a "sellable offer" under API-7's absence sentence. It is the existing unsellable combination.

**No verdict changes.**
- `CNF-278` checks only the headline 409 `state`, which holds in every row state.
- `CNF-307`'s "retain envelope `retryable: true` when all other entries are retryable" is conditional. An ONS entry makes its condition false; it does not contradict the conclusion.

**Alternative** (behaviour changed: a normative exception; I do not propose it). Replace S1c with:

> For an account whose status in that snapshot is not `healthy`, the tail reads its stored listing regardless of age; where no listing is stored, the offer check is not made for this create and adds no refusal or skip reason.

Effects:
- No row becomes a singleton ST: envelope true for a recoverable status, false for terminated, with pan reasons only.
- The other three fixtures and 10:1253–1255 are unchanged.

**Its strongest argument:** an account that fails at first contact answers ONS/false, which says "The offer cannot be bought on the same request". Yet the same key would be admitted after recovery plus one refresh.

**Against it:**
- It needs an exception to "for every rule in this tail".
- It would hide a never-listed id, against `CNF-307`'s "without hiding independent faults".

## 4. S6 with S1–S5

**What S6 demonstrates, and what it does not:**
- **Healthy stale row → `provider`/true with no provider call.** This demonstrates S1. It does not test a healthy account with no row, the 502 status, or "committing nothing".
- **Admission at the stored price, then claim `price_moved`.** Correct against `OPS-43` (`conflict`, `details.reason: "price_moved"`, `retryable: true`).
- **Refresh, credential stop, timestamp, reverse-order and failed-read assertions.** These match proposed `OPS-51` and proposed `STO-60` without narrowing either. Proposed `STO-60` (S2 text, not base) reads: "Every successful driver List offers read MUST publish its complete result to the account's row, replacing an existing row only when the incoming `read_at` is later." Together with "reverse dispatch order", that settles what "the later read's" means.
- **S1c has no assertion.** That is the gap named in §1. Adding one would change behaviour, so I don't make my vote depend on it.

**No flips found.**
- **CNF items.** No assertion is flipped, made unreachable or made vacuous.
  - `CNF-278`'s barriers and account-read cases need a fresh row only at admission. Its "the List offers read is permitted" is untouched.
  - `CNF-364` admits with `list_offers` declared.
  - In `CNF-166`, the never-listed sentence is the healthy, fresh, single-fault case. The new "Separately" sentence is the stale-row fault.
  - The claim-path "writes nothing" controls (10:1719, 1755) are kill controls, unaffected.
- **Lean.** The `@[req "API-7"]` theorems include `undeclared_ordering_stops_before_tail`, `empty_iff_admitted`, `ordered_without_duplicates`, `envelope_is_conjunction` and `account_retryability`. None says a declared ordering reaches the tail, so none is falsified. The `createPurchaseTail` drift is recorded in §1. I did not run lake.

**Snapshot and timing:** status, row and age come from one snapshot, measured "at the admitting transaction". The `STO-47` conditional write is unchanged.

**Credential-stop scope:** per credential, matching `PRV-41`'s "terminal for that credential". Terminated and unreachable accounts are still refreshed.

**Placement and publication caller:**
- The refresh runs in the engine process, so its publication is a write fenced by `OPS-50`.
- A superseded engine's read is lost when it rolls back and exits. That is the same window as `OPS-50`'s "A refused generation check ends recording without another attempt".
- Proposed `STO-60` also covers the claim worker's step-4 read. The worker can publish before step 8, which keeps `API-63`'s "the last write before the ordering call" (verified in 04).

**Recorded objections, not blocking (fixing either changes behaviour):**
- **(a) Refresh interval.** Proposed S5 only requires the interval to be "shorter than the offer-listing age". A read dispatched at t is stamped `read_at` t. So when interval + read duration > age, a healthy row is stale from t+age until t+interval+read duration, and creates in that gap get a spurious 502. A fix would add "…by at least the provider-call deadline".
- **(b) Accounts without `list_offers`.** A healthy account that declares ordering but not `list_offers` never gets a row. Every create on it gets 502/true permanently, under a `provider` kind defined as "Provider returned an error response".

## 5. Coverage (actually run)

I applied S1–S6 to `.scratch-r71/s/` with an anchor script. All five edited files are `cmp`-identical to the coordinator's `check/scratch/`; that only confirms my transcription matches theirs.

```
$ python3 tools/check_coverage.py   # unpiped, cwd = scratch
uncovered (ratcheted): 74
OK: 74 uncovered, at or below baseline 74 (set 2026-10-22)
EXIT=0
```

`tools/coverage-baseline.json` stayed byte-identical (`cmp` passed; sha256 `d7d4e8a4…4305b`). Proposed `STO-60` and `OPS-51` are covered through `CNF-166`.

## 6. Strict quoting

Each quote was checked with a fixed-string grep against c5f897c, whitespace normalized:

| Quote | Location | Owner (correctly attributed) |
|---|---|---|
| "Prices MUST be carried as strings exactly as the provider returned them." | 01:185 | `DOM-9` |
| "The driver's List offers MUST be read-only" | 02:123 | `PRV-50` |
| "A driver MUST therefore treat an `authentication` failure as terminal for that credential, MUST NOT re-attempt it on a schedule, and MUST surface it for an operator" | 02:1246 | `PRV-41` |
| "where the provider's price has risen past what the reserve covers" | 03:865 | `OPS-43` |

- The rest of the candidate uses bare pointers.
- S1c says nothing about what another requirement says.
- The quoted MUSTs are attributed quotes, not second owners.
- "Offer listing" is not the banned word: CONTEXT.md bans "listing" only as a synonym for **Offer**, and "customer offer listing" already appears in the base at 01:188.

Wording notes, not vote conditions:
- Proposed `OPS-51`'s "that credential" has no antecedent; the sentence only names "every account".
- "The authentication stop" is defined only by the `PRV-41` quote that follows it.

Final: ACCEPT; coverage 0/74; none
