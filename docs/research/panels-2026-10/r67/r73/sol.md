**H: ACCEPT. U: CANNOT ACCEPT.** These are independent whole-form votes on the printed r73 candidates against `c5f897c32f7894d77a544528872176f241394d0d`. No amendments proposed.

| Form | Independent scratch application | Coverage exit | Uncovered | Baseline |
|---|---|---:|---:|---|
| H | Complete; applied bytes match receipt | 0 | 74 ratcheted; 32 SEC/WIR reported separately | Byte-identical |
| U | Complete; applied bytes match receipt | 0 | 74 ratcheted; 32 SEC/WIR reported separately | Byte-identical |

I ran `python3 tools/check_coverage.py` unpiped in each complete scratch copy. The initial literal-anchor attempt stopped at wrapped whitespace; I rebuilt from clean copies with whitespace-tolerant anchors before checking the complete forms. Scratch copies remain under [`.panel-r73`](/var/tmp/provisiond-panel-r73/sol/.panel-r73). TMPDIR was preserved. Tracked files remain unchanged; no full gates, Lake, commits, provider calls or delegation.

**H — strongest argument.** Its scope follows the asserted behavior rather than an inventory of item numbers: “asserts or relies on a create being admitted or succeeding” includes implicit admissions and earlier creates needed for downstream assertions. The limiting sentence—“This default qualifies only the admission or success assertion and any create used to reach it”—prevents freshness from spreading across every subcase of a mixed item. Retained M8 supplies the continued losing probes that this success default cannot supply.

**H — counterargument, requested; not a vote.** A global default requires careful reading in mixed success/refusal items, especially races. Per-item fixtures make those assumptions more visible. That is a maintainability objection, but I found no concrete success outside H’s scope or target-(1) refusal narrowed by its default.

**U — strongest argument for CANNOT ACCEPT.** The union remains incomplete for target (3), beyond the carried CNF-99/299/243 findings. Direct examples include:

- CNF-364: “Admit a complete create on an account that declares `list_offers` and the ordering capability.”
- CNF-241: “With the offer still sellable and the price unchanged or lower, it proceeds.”
- CNF-151: “Exactly the endpoints in `API-48`’s list are synchronous; every other write returns `202` with an operation.”

U supplies no stored-listing age condition for those create admissions or their earlier setup. Its listed repairs therefore do not complete the requested success-fixture amendment.

I am **not claiming that every disclosed U omission independently proves a gated loss**. A fresh fixture remains possible, and some conservative inventory paths use injected records or driver-only execution. My U vote rests on incomplete explicit fixture coverage. I found no additional verified unlisted gated loss.

**U — counterargument, requested; not a vote.** Existing success tests can choose fresh listings without spelling out their age, so these omissions need not make every lawful execution unreachable. U also makes its amended fixtures locally visible and preserves the carried policy conclusions. That supports treating it as workable with implicit assumptions; it does not satisfy the requested explicit fixture coverage.

**Does H cover every affected success? Yes; I found no miss.** Its wording covers the requested categories:

| Category | Scope assessment |
|---|---|
| Proceeds controls | “asserts or relies on” covers admission preceding CNF-241’s quoted proceeds assertions. |
| First sends | Covers the original successful create before replay, plus successful first-send recovery after an admission refusal. |
| Generic writes | Covers the create member of generic successful-write assertions, including CNF-151’s quoted `202` assertion. |
| Shared winning races | Covers the participating creates needed to establish the successful race outcome, including CNF-163 and CNF-343. |
| Release probes | Explicitly includes “a create used to show a release”; M8 redundantly retains that condition. |
| Creates reaching later assertions | Covers earlier API admissions needed to reach queued, claimed, restarted, settled or subsequently failing creates. It imposes no freshness condition at that later assertion. |

I checked the inventory’s active-item identifiers and order against the checklist. Its counts remain conservative source analysis, not a count of mandatory API executions. For example, an existing-machine test such as CNF-98—“Remaining runway is readable from the machine view before exhaustion”—can optionally construct its machine through create. Conversely, stored-record and driver cases can bypass admission. H covers an earlier create whenever that construction is used; its completeness does not depend on the selected-path enumeration.

**Does H narrow any refusal assertion?** It narrows **no CNF-278/307 target-(1) refusal assertion**. Earlier successful setup receives freshness; the later refusal retains its asserted conditions. The header expressly says that an unspecified refusal “asserts it whatever that age.”

There is a deliberate restriction outside that target: M8’s continued CNF-343 losing probes. Its exact text says, “Each of these further creates, including any create used to show the release, uses a stored listing containing the named sellable offer,” with admission-time freshness. That restriction is necessary: a stale-listing `provider` refusal cannot demonstrate the retained resource-offer exclusion. The initial shared race uses the success setup; the continued losing probes use explicit M8.

**Admission traces, common to H and U.** I carried the verified r72 policy findings and checked the r73 projections without skipping cases. The local [projection audit](/var/tmp/provisiond-panel-r73/sol/.panel-r73/projection-review.json) records every projection from `check/trace-cases.json`: 2,304 create and 64 extension projections per form, with zero skipped. Independently derived ordered entry lists matched the base/H/U projections throughout. This is source analysis, not implementation or Lean execution.

The controlling S1 condition remains: “If the tail has collected no refusal” before applying the stale-listing refusal. Accordingly:

| Case | Entries and result | Evaluation, pacing and amounts |
|---|---|---|
| **D1:** healthy, stale, unsellable offer | Singleton offer refusal: `400 invalid_request`, false retryability. | Present priced checks are skipped for `offer_not_sellable`; no priced result or amount; no pacing. |
| **D2:** healthy, sellable, closed channel + solvency + absent rate | Channel, solvency, rate; `429` headline; true envelope retryability. | Supplied cap and balance skip for `rate_unavailable`; omitted cap produces no cap skip. Channel owns headline pacing, including against a longer subordinate delay. |
| **D3:** unsellable + channel + solvency, varying status, rate and cap | Account first when unhealthy, then offer, channel, solvency, rate when absent. Healthy begins with offer. | Offer makes envelope retryability false. Each present priced check has applicable reasons in account/offer/rate order. No priced amounts or synthesized headline pacing. |
| **D4:** healthy, stale, sellable, no other refusal | Empty collection, followed by `provider`, `retryable: true`, before admission writes. | Available priced checks ran; no stale skip reason is invented. No admission write, receipt or request-driven provider call. |
| **D4, short balance** | Balance refusal remains `402 insufficient_balance`, false retryability. | Balance ran and carries its required amounts. Age does not replace the collected refusal. |
| **D5:** clear recoverable faults and resend | A remaining stale listing gives D4’s age refusal. H’s default or U’s M1 supplies freshness for the asserted successful retry. | The refusing request left no receipt. The successful fresh retry performs normal admission and receipt writes. |

For **every unhealthy branch**, all ages and effective offer states retain account-first `409 conflict/state`. The recoverable account entry is true; termination’s is false. Sellable-offer combinations collect applicable channel, solvency and rate entries without evaluating cap or balance. Unsellable or absent offers additionally collect the false offer entry. With a supplied cap, both priced checks record every applicable account/offer/rate reason; without it, only balance does. Neither stale age nor a longer subordinate delay displaces the state headline.

For **healthy no-row**, S1 supplies “an empty offers set if no listing is stored.” This is absent-offer input, not an otherwise-admissible stale purchase: offer refusal remains first, false retryability; independent channel/solvency/rate entries remain collectible, and priced checks remain skipped with applicable reasons. The base comparison holds absent-offer facts fixed.

For **healthy, sellable, rate-available combinations**, cap and balance run despite channel or solvency refusals. Failed supplied cap precedes failed balance. Required cap/balance amounts remain in their own entries; only the headline entry supplies headline details. An omitted cap creates neither a cap refusal nor a cap skip.

For **extensions**, all supplied projections remain unchanged: fence, solvency, rate, cap and balance retain their existing order and evaluation. Account health, offer sale state, channel closure and listing age introduce no create-only extension refusal or skip reason.

Across every refusing admission projection, commitment, balance, machine, operation and receipt writes remain absent, with zero tail provider calls. The only policy differences are the declared otherwise-admissible stale-create refusals. Equality with the age limit passes the “older than” test; greater age fails it.

**CNF-278 setup and later failures remain distinct.** I read the complete item, including “on independent account fixtures,” the surrounding recording cases and every create/claim barrier.

H freshens an earlier admitted create needed to reach queued or claimed state. Later account-read failures retain `state` and recoverable retryability; termination failures retain `account_terminated`, false retryability and commitment release. A termination after the List offers read still permits that earlier read while prohibiting provider mutation. The post-step-8 case retains its potentially-dispatched treatment rather than becoming a freshness test. The age default does not replace any status, conditional-write or dispatch-boundary assertion.

**Strict quotation and ownership check.** Sentence by sentence, I found no introduced quotation or ownership defect:

- S2 carries the verbatim PRV-50 sentence and DOM-9 price sentence.
- S3 carries the verbatim PRV-41 authentication-stop sentence.
- S6 carries the verbatim OPS-43 price-comparison sentence.
- S1 introduces policy within API-7; STO-60 and OPS-51 introduce their requirements at their owners.
- The overview rows define placement/settings. H’s and the fixture spans’ bare references remain references.
- No added normative MUST occurs outside its owner except inside an attributed quotation.

No wording repair is needed. Coverage is reported separately from the enumerated loss gate; no formal-suite pass is claimed.

**Preference: H.**