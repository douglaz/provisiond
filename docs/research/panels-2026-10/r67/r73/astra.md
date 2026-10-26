**H: ACCEPT. U: CANNOT ACCEPT.** I reviewed each complete printed form against `c5f897c32f7894d77a544528872176f241394d0d`. No AMEND is proposed.

**H — strongest argument.** The header’s “asserts or relies on a create being admitted or succeeding” covers implicit admission dependencies, while “only the admission or success assertion and any create used to reach it” confines the fixture qualification. It supplies fresh admission fixtures without making later claim-time failures depend on fresh listings. Retained M8 separately covers the continued losing probes.

**U — strongest argument.** Its explicit fixtures still do not meet target (3). A concrete omission is `CNF-364`, whose opening instruction is:

> Admit a complete create on an account that declares `list_offers` and the ordering capability.

U supplies no fresh-listing condition for that admission. With a healthy account, sellable stored offer, sufficient balance, available rate, open channel and no other refusal, let that listing become stale. S1 refuses `provider` before an operation exists, so the subsequent claim-time capability test cannot be reached through that fixture. H supplies the missing admission condition.

This is a fixture-completeness objection affecting my vote, **not an additional gated loss**: the immediate stale refusal is the declared target-(2) change. I do not classify every inventory omission as a broken assertion.

**Independent application and coverage**

Both scratch copies were built independently from the base and matched the printed forms’ applied bytes. I ran `python3 tools/check_coverage.py` directly, unpiped, in each.

| Form | Exit | Ratcheted uncovered | Baseline status |
|---|---:|---:|---|
| H | 0 | 74 | Byte-identical to base |
| U | 0 | 74 | Byte-identical to base |

Both also reported 32 SEC/WIR requirements outside the ratcheted count. Receipts: [application.json](/var/tmp/provisiond-panel-r73/astra/.panel-r73/application.json). Coverage is reported evidence, not an extra acceptance gate.

TMPDIR remained unchanged. All writes were inside this clone. No full gates, Lean execution, commits, pushes, provider calls, delegation, background tasks or waits were performed.

**H’s success and refusal scope**

**Yes: H covers every affected create success or admission dependency; I found no miss.** Its scope does not depend on the sweep’s enumeration.

- **“Proceeds” and first-send success:** the carried `CNF-99` and `CNF-299` findings fall within “asserts or relies on”; the header supplies their create-success fixtures without revisiting those findings.
- **Generic writes:** `CNF-57` says “assert no `api` write is refused”. A create exercised by that assertion receives the default.
- **Shared winning races:** `CNF-163` requires “one commitment and one `insufficient_balance`”; `CNF-343` requires “exactly one wins”. Both competing creates are used to reach the shared winning-race assertion, so the default supplies both admission fixtures.
- **Release probes:** the header expressly includes “a create used to show a release”; M8 additionally supplies the explicit fixture for its release probe.
- **Creates used to reach later assertions:** the scope includes the admitted operations needed for queued, claimed, restarted and subsequently failed cases. Injected-state or driver-only tests need not execute admission; if they construct their fixture through create, that earlier admission is covered.

I reconciled the active identifiers against `check/sweep.json` and challenged its distinction between required admissions and optional fixture construction. Its conservative inventory is useful; its omission count is not a count of independently demonstrated failures.

**No target-(1) refusal is narrowed by H’s success default.** The header explicitly preserves an unspecified-age refusal “whatever that age”. Freshness at an earlier successful admission does not impose freshness at a later claim, termination, restart or resolution.

There **is** an explicit refusal-fixture restriction in H as a whole: M8’s continued losing creates in `CNF-343`. Its exact sentence begins:

> Each of these further creates, including any create used to show the release, uses a stored listing containing the named sellable offer…

That restriction is declared, applies to the continued exclusion probes, and is necessary to make them reach the guard. It is not a blanket restriction on `CNF-278` or `CNF-307`.

A stale `provider` refusal alone is never evidence that a conditional-write guard works. The fresh, otherwise eligible branches must actually reach the barrier and demonstrate the guard’s specified result. For the initial shared race, H supplies that common fixture; for continued losing probes, M8 supplies it explicitly.

I read complete `CNF-278`, including the independent account fixtures, metering and episode cases, queued operator retry, reload, activation/reassignment and recording refusals. The header neither combines those independent fixtures nor substitutes admission freshness for any later assertion.

**Complete refusal projection**

I carried the verified policy findings forward and audited every row of the supplied projection expansion against the source rules. The audit traversed the complete create and extension products in `check/trace-cases.json`, with no skipped projections: [projection-and-quotes.json](/var/tmp/provisiond-panel-r73/astra/.panel-r73/projection-and-quotes.json).

The following describes the whole product, including every unhealthy status, listing-age/source branch, optional cap and independent fault combination—not merely the named examples.

For **both forms**, collect applicable entries in this order:

`account/fence → offer → channel → solvency → rate → cap → balance`.

For create, collect these skip reasons in order:

`provider_account_not_healthy → offer_not_sellable → rate_unavailable`.

Apply that reason list first to the supplied cap check, then to balance. Omitted cap means neither a cap refusal nor a cap skip. With no reasons, balance runs and a supplied cap runs—even when channel or solvency has already refused.

| Projection | Entries and evaluation | Retryability and pacing |
|---|---|---|
| **D1:** healthy, stale, unsellable | Offer refusal; cap when present and balance skipped for offer; no priced amounts | HTTP 400, false; no synthesized pacing |
| **D2:** healthy, sellable, closed channel + solvency + absent rate | Channel, solvency, rate; present priced checks skipped for rate | HTTP 429, true; headline uses channel’s own delay, not a longer subordinate delay |
| **D3:** unsellable + channel + solvency, every account status, rate present/absent, cap present/absent | Unhealthy account entry when applicable, then offer/channel/solvency/rate when applicable; skip reasons account/offer/rate in their defined order | Healthy headline 400; unhealthy headline 409/state. Envelope false because offer is false; subordinate pacing never supplies headline pacing |
| **D4:** healthy, sellable, rate available, no cap | Balance evaluated; `not_checked: []`. Short balance retains its balance refusal; adequate balance proceeds to age decision | Short balance: 402/false. Otherwise stale: provider/502/true after evaluation |
| **D5:** faults cleared, same request/key | Stale still refuses after collection; fresh success reaches normal admission. Earlier refusal left no receipt | Stale: provider/502/true. H defaults success fresh; U M1 explicitly supplies freshness |
| **Healthy, no row** | Empty offers set produces offer refusal; cap when present and balance skipped for offer | 400/false, not an age-based provider refusal |
| **Healthy, stale, no other refusal** | Empty collected refusal list; priced checks have run; then provider refusal before writes | 502/true; no synthesized pacing |

**Every unhealthy branch:** `account_unreachable`, `credentials_rejected` and `terminated`, crossed with fresh/stale/no-row and sellable/unsellable/absent offer facts, retains state-first HTTP 409. Recoverable account entries are true; termination is false. An absent or unsellable effective offer adds a false offer entry. A stale sellable row does not become an offer refusal merely through age. Channel, solvency and absent-rate entries remain collectible beneath the account headline. Account/offer/rate suppression prevents cap and balance evaluation and associated amounts.

**Amounts and pacing:** the projection receipts summarize these fields, so I also checked the source requirements. For a concrete priced case with required commitment 100, cap 80 and available balance 70, cap and balance refusals retain their respective amount pairs; a solvency headline does not acquire the subordinate balance amounts. Suppressed checks produce neither those entries nor their priced amounts. Each pacing-bearing entry retains its own delay; only the headline’s delay controls headline pacing and `Retry-After`.

**Writes and calls:** every collected refusal and the new age refusal commits no commitment, balance, machine, operation or receipt and makes no tail provider call. A fresh eligible success makes normal admission writes and its receipt. This says nothing against the separate provider reads expressly permitted later at claim.

**Extensions:** all extension projections retain fence/solvency/rate/cap/balance behavior. Create-only account, listing, offer and channel facts do not affect them. A fence does not suppress priced checks when a rate exists; absent rate does. Fence retryability is false, and the envelope remains the conjunction of its entries.

Equality with the stated age is fresh: S1 tests “older than”, not equal to. These are source projections, not implementation proof.

**Quotation and ownership check**

No additional quotation repair was identified in the proposed clauses. The embedded PRV-50, DOM-9, PRV-41 and OPS-43 quotations match their owner text, normalizing whitespace only. S1’s new MUST is within API-7; the storage and refresh MUSTs are within STO-60 and OPS-51. Quoted MUSTs remain attributed quotations. The header’s bare “see” references do not assert additional owner wording.

I verified no additional unlisted CNF loss or broken MUST/SHOULD. I make no Lean execution or full-gate claim.

**Counterargument to H — requested, not a vote.** A blanket default requires careful assertion-level reading: applying freshness to an entire mixed item could erase stale-refusal coverage, while overlooking the shared race could let an age error masquerade as a guard result. The limiting sentence and exact M8 resolve those concerns sufficiently for acceptance.

**Counterargument to U — requested, not a vote.** An implementer could infer that an instruction to admit a create includes satisfying the new age prerequisite, making many omissions harmless in practice. Also, optional driver fixtures need not pass through admission. That is the strongest defense of U, but it does not meet this round’s explicit target that affected successes receive fresh fixtures.

**Preference: H.** U is not acceptable to me as printed.