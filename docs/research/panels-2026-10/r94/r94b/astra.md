I change my first preference from **Q-QUOTE to Q-QUOTE-OPS43**, exactly as supplied. After reviewing Opus’s reasoning and independently checking the sources, I no longer accept Q-QUOTE’s attribution. Q-QUOTE-OPS43 preserves the explicit instructions that made Q-QUOTE attractive and cites the applicable create-ordering rule.

This is my r94b ballot, not a declaration of panel settlement. **apply notes.md rule 6 exactly as written; this prompt adds no void rule.**

| Complete Q1 form | Acceptability | First preference |
|---|---|---|
| Q-QUOTE | **CANNOT ACCEPT** — exact quotation, inaccurate referent in this context | No |
| Q-POINTER | **CANNOT ACCEPT** — its provider-ordering pointer has the same scope problem | No |
| Q-KEEP | **CANNOT ACCEPT** — no quotation-rule exemption established | No |
| Q-QUOTE-OPS43 | **ACCEPT** — applicable source, explicit instructions preserved | **Yes** |

I read the required packet, originals, occurrence inventory and every package/comment/note candidate completely. Source verification used `git show` at the explicit refs in the assigned clone. I made no changes, ran no gates, used no subagents and did not wait for peers.

**Why I change my vote**

Opus’s source-scope objection is decisive, with the narrower qualification in this brief.

At M, `12-billing-and-ledger.md:489–494`, the antecedent of the quoted “that transaction” is explicit:

> `OPS-42` requires `OPS-41`'s funding read and the  
> fence write to be **one** transaction under this primitive

The concluding quotation is:

> **the provider call happens after that transaction commits**, never inside it.

Q-QUOTE places that quotation after the create’s acknowledged step-8 transaction. Reading the whole package supplies the correct ordering elsewhere, but it does not change the quoted sentence’s original referent.

The broader LDG-69 prohibition also remains conditional. At M `12-billing-and-ledger.md:464–467`, it says:

> A deployment MUST hold `LDG-35`'s primitive for the duration of one  
> database transaction and no longer. While it is held, an implementation MUST NOT wait on a running  
> operation's hold on its machine (`OPS-8`), the completion of a child operation (`API-58`,  
> `WIR-39`), or any provider call.

STO-55 makes the distinction explicit at M `05-persistence.md:257–259`:

> `LDG-69` says "A deployment MUST hold `LDG-35`'s  
> primitive for the duration of one database transaction and no longer", which is this rule for  
> the tenant primitive alone; it holds for every transaction.

Its general prohibition appears at lines 253–254: a worker, sweep or watcher “MUST NOT hold a transaction / open across a provider, rail or rescue-host call”.

OPS-43’s specified step-8 sequence does not require taking LDG-35’s primitive. That supports the narrower conclusion that LDG-69 does not establish ordering for every conforming step-8 transaction. It does **not** prove that an implementation can never take that primitive there. Likewise, API-63’s “primitives cannot supply this” passage concerns admission/account contention; it is not such a prohibition.

The direct source at M `03-operation-lifecycle.md:817` is:

> Step 9 MUST begin only after step 8's transaction is acknowledged.

That is exactly the Q-QUOTE-OPS43 payload. The original package already retains “acknowledgement-before- / step-9 rules remain required.” Quoting the applicable rule changes the justification, not the dispatch policy.

**Strongest argument for retaining Q-QUOTE — considered, not an additional vote.** API-63 itself says at M `04-api-contract.md:1428`:

> `LDG-69` keeps the provider call outside that transaction

This is strong textual precedent for the old attribution. Together with the unchanged explicit local instructions and OPS-43 ordering, it explains why my earlier reading found Q-QUOTE acceptable. But a repeated attribution cannot enlarge LDG-69’s scope or replace the antecedent of its quotation. API-63 remains outside these edits.

I therefore accept Opus’s accuracy objection without claiming that Q-QUOTE changes a runtime verdict. Its operative suspension instructions survive; its stated source justification is inaccurate.

**Why retaining the explicit local instructions matters**

The strongest case for Q-QUOTE is sound: it preserves the adopted instructions directly, including:

> retry a serialization failure as a whole transaction and do not treat it as a tenant-status refusal.

and:

> treat that residue as the potentially dispatched  
> case.

Q-QUOTE-OPS43 retains both. Choosing it loses none of the reason Astra/Sol preferred an explicit package over pointers.

For serialization, OPS-49’s whole-transaction MUST at M `03-operation-lifecycle.md:1926–1928` is conditioned on a store call that “errors or times out”. Its separate exception at lines 1953–1956 says:

> **Constraint violations and serialization failures are not store errors** and do not consume  
> the bound.

and:

> A  
>   serialization failure is repeated at once.

The quoted form does not make serialization failures bounded store errors. Its local instruction explicitly preserves the adopted whole-transaction retry and tenant-refusal distinction. The distinction is supplied by Q4-D’s adopted policy, not derived from those OPS-49 quotations alone.

On **Q-POINTER**, I still find the contextual serialization reading persuasive: “repeated at once” belongs to the transaction-repetition home, with an explicit exception for timing/bound accounting. I do not read it as permission to repeat only a failed statement. Opus correctly identifies the deletion of the explicit local words, but that deletion alone does not demonstrate a changed normative outcome after incorporating the owner’s complete rule. I therefore do **not** report a verified rule-3 blocking loss on this ground.

Nevertheless, Q-POINTER’s:

> For provider-call ordering, see LDG-69.

directs this create-ordering question to the same insufficiently scoped source. That accuracy objection independently makes its complete form unacceptable to me. No unreviewed pointer repair is proposed.

For **Q-KEEP**, M `AGENTS.md:29–30` says:

> A claim about what another requirement says carries that requirement's own  
> words.

Neither a true underlying ordering fact nor historical owner adoption proves an exemption. Q-KEEP supplies none and retains the attribution problem. Its conditional note is reference material only; I do not treat it as an authorized landing.

**Separate preservation judgments**

These comparisons are against owner item19’s adopted package, including its deliberately relinquished publication duty.

| Selected form or landing | Behavior | Requirements | Check strength |
|---|---|---|---|
| **Q-QUOTE-OPS43** | **WORDING-ONLY.** Refusal, retry, dispatch-residue, settlement and attachment instructions remain. | **WORDING-ONLY.** The applicable existing ordering MUST is quoted; the adopted local obligations and disclosure remain. | **WORDING-ONLY.** Item6 is byte-identical. No theorem, declaration, guard hypothesis, fixture, negative control or conformance assertion is changed by these substitutions. |
| **Carried L-NOTE with note-Q-QUOTE-OPS43.md** | **WORDING-ONLY.** The corrected executable comment carries the same policy. | **WORDING-ONLY.** Authority is distinguished from historical approval; the appendix qualifies the preserved archive. | **WORDING-ONLY.** Neither the authority correction nor appendix changes the acceptance criteria. |

No positive duty to publish the existing-fleet warning is restored. Item5 remains byte-identical, including its existing:

> The terms and operator documentation MUST explain  
> that an order authorized for dispatch before suspension may still reach the provider and  
> complete afterwards

and its prohibition on promising recall or successful cancellation. This is the owner’s chosen disclosure, not an A/D combination.

There is no blocking-loss claim for my selected form and no collateral verdict flip identified. My rejection of Q-QUOTE and Q-POINTER is an accuracy objection, not an assertion that a checked runtime verdict changes.

**Original assertion inventory and landing**

The inventory below follows original Q4-D items1–6 and the original brief’s remaining sections. **Q** means the supplied complete `options/Q-QUOTE-OPS43.md`; **B** means its complete prospective comment. Except for the two quoted substitutions and B6’s authority correction, comparison against the originals is byte-identical.

| Original assertion or instruction | Location in selected package / comment |
|---|---|
| Unspecified pinned text remains unchanged; all insertion/replacement boundaries, including item6’s placement relative to additional Q1 store cases | Q1 and item headings Q3,15,35,51,59,70 / B41 and B43,55,75,91,99,113 |
| Item1: tenant plain read after account refusal, before channel closure and boundary validation | Q6–12 / B46–52 |
| Item1: `conflict`, `tenant_suspended`, `retryable: false` on error and operation view | Q7–8 / B47–48 |
| Item1: no provider request, including List offers/key upload; failed settlement, full release, no setup-fee or first-unit debit | Q8–10 / B48–50 |
| Item1: original `requested_by` and `system_reason`; no admission-only `suspended`; later guard closes the early-read race | Q11–12 / B51–52 |
| Item2: same-transaction conditional tenant-row write, contention with admission suspension, earlier read/lock insufficient | Q18–21 / B58–61 |
| Item2: suspension-wins rollback; exact refusal on both views; failed/full release/no debit; no step9 | Q21–24 / B61–64 |
| Item2: first failed transaction commits neither marker nor correlator | Q24–25 / B64–65 |
| Item2: lost-acknowledgement repeat rechecks tenant guard; preserves previously committed marker/correlator; records pre-step9 failure; no null-column settlement term | Q25–29 / B65–69 |
| Item2: whole-transaction serialization retry and distinction from tenant refusal | Q29–31 / B69–71; retained explicitly after exact quotations |
| Item2: operation-row claim guard and acknowledgement-before-step9 | Q31–32 / B71–72 |
| Item3: guard-passed create potentially dispatched and allowed to settle; suspended-attach cancellation | Q38–40 / B78–80 |
| Item3: claim alone does not authorize purchase; early suspension read and suspension-winning guard prevent purchase | Q40–42 / B80–82 |
| Item3: acknowledged/pre-call residue remains potentially dispatched | Q42–45 / B82–85; applicable OPS-43 quotation replaces LDG-69 attribution |
| Item3: no never-claimed administrative failure/release of uncertain order; deterministic worker-recorded pre-step9 exception and retained OPS-11 quotation | Q45–48 / B85–88 |
| Item4: OPS-43 ownership pointer; OPS-27 attachment/cancellation, including later evidence attachment after parent settlement | Q54–56 / B94–96 |
| Item5: no fleet-gone promise; authorization boundary; accounting for every machine, including potentially dispatched orders; required earlier-authorization disclosure; no recall/successful-cancellation promise | Q62–67 / B102–107 |
| Item6: independent valid active-tenant admission, healthy account/open channel, unclaimed suspension/claim race; exact refusal and both retryability views; no request/purchase/debit; full release, original origin, no admission-only error | Q73–78 / B116–121 |
| Item6: early read sees active, suspension before guard; same refusal with preceding nonmutating reads permitted; no step9 or first marker/correlator commit | Q80–82 / B123–125 |
| Item6: both guard/suspension orders; acknowledged guard then suspension before call permits settlement; cancellation in attach transaction if still suspended; late attachment after parent settlement | Q82–87 / B125–130 |
| Item6: lost acknowledgement then suspension before repeat; deterministic failure, retained columns, full release, no speculative dispatch, worker claim guard | Q89–91 / B132–134 |
| Item6: auction, standard/`correlator: none`, and temporary-key descriptor coverage | Q92–93 / B135–136 |
| Item6: unhealthy account wins over tenant refusal; with healthy account, suspended tenant wins over closed channel; no request in either case | Q95–97 / B138–140 |
| Brief category, summary, fixed policy, owner evidence and historical Current behavior | B1–37; only B6’s reviewed authority line changes |
| Brief rejected buy/charge/cancel choice, retained dispatched-order path, no A/D combination/repaired or partial D, unchanged-text instruction, public-warning loss and owner/dissent records | B144–164 |
| Brief historical drift receipts and PR51 base statement | B166–176 |

The beyond-source instructions have their original homes. Q4-D, adopted by item19, supplies the tenant guard/race policy, tenant-refusal distinction, lost-acknowledgement tenant recheck, potentially-dispatched classification and permission to settle. Neither LDG-69 nor OPS-49 independently supplies that suspension policy.

The retained supporting sources are applicable:

- OPS-43, M lifecycle817–818: “Step 9 MUST begin only after step 8's transaction is acknowledged” and a lost acknowledgement “MUST take `OPS-49`'s "repeat the **whole transaction**" path, never speculative dispatch.”
- OPS-11, M lifecycle249: “Any create failure the worker records before any step-9 request (before any per-order key upload or order request) MUST settle `failed`, whatever its kind.”
- OPS-27, M lifecycle642–643: “**Where the machine's tenant is suspended at the moment of the attach, that same transaction also / enqueues a system cancellation**”. Its entry-point discussion at 608–624 includes resolving-observed and late attachment. The package applies this retained attachment path to its adopted class.

**Independent byte receipts and exact selected landing**

I verified:

- The source-packet’s pinned source blocks match their `git show M:path` ranges exactly. AGENTS, lifecycle, API, ledger, persistence and findings are byte-identical between M and H.
- H’s archived Q4-D equals the supplied original: **6,606 bytes**, SHA-256 `bd57b4e09cfbedfb955fff449748433f12867749525c43f8ee0c9c552e9c4ae7`. The archive is absent at M.
- H `.beads/issues.jsonl:101`, `pv-kv2`, `comments[0]`, id860 equals the supplied original brief: **10,661 bytes**, SHA-256 `43250b5bea7ca4b4df595a94ecaaa28d4769aa33c90ac1b94ff5e940b65cb6b5`.
- Applying each non-KEEP candidate’s exact note replacements to the original reproduces its complete package; adding its exact authority replacement reproduces its complete comment. Reversing those changes reproduces both originals. Q-KEEP is identity.
- Item5 and all of item6 remain byte-identical in every candidate.

| New quotation payload | Independently verified source | Result |
|---|---|---|
| Whole-transaction quotation | M lifecycle1927–1928 | Exact, including LF |
| Serialization quotation | M lifecycle1955–1956 | Exact, including LF and two spaces |
| LDG provider quotation | M ledger494 | Exact bytes; applicability fails as explained above |
| OPS43 provider quotation | M lifecycle817 | Exact bytes and applicable |

The retained OPS-11 quotation has LF after “any” where the source has a space. I confirmed that precise difference, accept it as disclosed, and propose no normalization. Item5’s locator and the historical owner quotation have their separately disclosed reflow differences. The historical Current behavior blocks match their named `3109b5b…` sources exactly; the historical file-equality receipts against `832a219…` also verify.

My exact selection is the supplied files, unchanged:

| Artifact | SHA-256 |
|---|---|
| [Q-QUOTE-OPS43.md](/var/tmp/provisiond-panel-r94/r94b/options/Q-QUOTE-OPS43.md) | `ba7ddd938d8b7f0defe1616f1b0868bdf5361f8291bc3ad056336134ceacdbf4` |
| [prospective-agent-Q-QUOTE-OPS43.md](/var/tmp/provisiond-panel-r94/r94b/options/prospective-agent-Q-QUOTE-OPS43.md) | `d14a8a5680f319221789d3e151a4ae9e744cad8eb3c01bcbd4addbf75e830c7c` |
| [note-Q-QUOTE-OPS43.md](/var/tmp/provisiond-panel-r94/r94b/options/note-Q-QUOTE-OPS43.md) | `31f743fac08408f2798ffbf4553310144082f89199b91c6f823ea76e7d914c4b` |

I propose no new form or combination. L-NOTE preserves every original archive byte as a prefix and appends that exact note, including its leading LF and intentional parent-r94 metadata. The resulting archive would be **7,688 bytes**, SHA-256 `b1a08789423da142a4bb0d2d87cdb92fe813c7460f80e545101bc74c20171682`.

The comment receives exactly the supplied B6 authority correction. Archiving r94’s notes/settled correction remains part of the carried landing: `docs/research/panels-2026-10/r94/notes.md` is absent at H, so the relative link needs that stated dependency. This ballot does not certify a fresh live-ref launch check.

**Rule6 findings, separately from candidate disagreement**

The earlier “source facts supported” description overstated LDG-69’s support. My changed Q-QUOTE verdict rests on correcting that attribution. This does not change the question’s premise: the task remains correction of retained-rule wording while preserving the adopted policy, and an applicable alternative source was expressly permitted.

Opus’s categorical “Step 8 doesn't hold the primitive” is stronger than the verified evidence. The narrower, sufficient conclusion is that the specified step does not require it. I do not rely on the categorical version.

Neither issue voids the tally under rule6. The disclosed whitespace differences and archive-link dependency likewise do not change the premise. Candidate accuracy disagreements are not additional void rules.

Fable’s limit response and grok’s HTTP402 remain missing seats, not votes. This is my fresh acceptance of the complete Q-QUOTE-OPS43 form; it must not be inferred from my r94 vote. If the sole consensus round does not settle an exact form, the remaining question goes to the owner.

Q1 FINAL: Q-QUOTE-OPS43; carried Q2: L-NOTE.