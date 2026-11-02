# Independent r96 tally audit — 2026-11-02

Pin M = f8a30457eb84b3077e7580732bef665b3763aae1. Both origin/master and pv-gvc still resolve to M. There is no moved-ref comparison or stop condition. All direct Git reads use the panel's check/repo or read-only rev-parse on the main checkout. `tally-verify.py` records independent byte checks in `tally-verification.json`; it does not import or execute the preparation script.

## Exact occurrences and complete reference inventory

The committed archive and external frozen r83 file are exactly the same 2,644 bytes, 35 lines. The package in archived r83 brief Q1-B also matches. Comment853 decoded directly from M's tracker reproduces that package in its Desired behavior and Acceptance criteria blocks. The JSONL physical row is 94; the issue is pv-gvc and the sole comment's id is 853. Decoded line numbers below are not physical JSONL line numbers.

There is one target in each: comment853:57–59, frozen package:31–33, and committed archive:31–33. Each is addressed: the executable comment and Run package replace the target; the archive retains the approved target as history and appends its dated replacement. The external frozen file remains untouched. No other live summary attribution requires a replacement.

| Reference / actual wording | Comment853 | Frozen package and its byte-identical archive | Disposition and coverage |
|---|---|---|---|
| API-58 / CNF-202 landing instructions | 24 / 35 | 1 / 9 | Destination owners; the transaction and test duties are this package's own amendments. No source-content summary. |
| DOM-20-containing insertion anchor, ending `that kind stays an admission-time rejection of a *caller's* write (\`DOM-20\`).` | 24 | 1 | Locator quoting API-58, not a new summary of DOM-20. Retained wrapping discrepancy is disclosed below. |
| LDG-32 support, `see LDG-32, "the create fails deterministically"` | 27 | 4 | Already quoted attribution supporting the package's own full-release transaction duty. Source at 12-billing-and-ledger.md:312; retained unchanged. |
| Tenant's LDG-35 primitive | 30 | 7 | Bare ownership pointer within the package's own ordering rule. No assertion that LDG-35 supplies the entire new order. Retained. |
| WIR-10's operation-kind set | 39–40 | 13–14 | List pointer, with no duplicated enumeration or prose count. The precise closed-enum home is WIR-10a, 13-wire-contract.md:288. Family-level label imprecision is inherited and disclosed by r83 and all present readers, not silently fixed. |
| `LDG-32 says "the create fails deterministically"` | 45 | 19 | Explicit summary attribution already carrying the exact source words. Retained unchanged. |
| Queued API-64 retry | 48 | 22 | Fixture/owner pointer. API-64's amendment says `requested_by: operator` (04-api-contract.md:1107). No new source summary. |
| `follows OPS-43's tenant-status refusal` | 57–59, owner at58 | 31–33, owner at32 | Sole live unquoted summary. Q-QUOTE retains it and supplies the exact current source payload in the same sentence. Prospective comment:57–61; executable package:31–35. Archive replacement payload:53–57. |
| Historical `OPS-11 classifies as admission-only and forbids a worker to emit` | 18, continued19 | Absent (only the last sentence's ending is used as the insertion locator) | Actual summary embedded inside an explicitly dated, exact API-58 source quotation, comment13–19, at 3109b5b:626–632. The source evidence itself carries the historical words. Preserve it as historical evidence; it is not new Run text. OPS-11:257–262 includes `they MUST NOT be emitted by a worker or a driver`. |
| Historical DOM-20 admission-only continuation | 19 | Full passage absent; ending locator at1 | Same historical source evidence and taxonomy pointer; no prospective correction. |
| Historical OPS-39; WIR-9a/WIR-10b | 13;16 | Absent | Owner pointers inside that same historical fence; no additional summaries. |
| Owner answer, ordering, exclusion and r83 owner-question excerpts | 6;65–87 | Absent | Approval/provenance evidence, not requirement summaries. Current authority line is replaced with the reviewed Q-QUOTE line; all other history stays exact. |
| Drift claims naming 3109b5b and 832a219 | 91–94 | Absent | Both complete-file equalities verify for their explicitly historical pair. They do not claim current M equals either ref. Retained. |

This inventory includes every requirement-summary occurrence, quoted or unquoted, and distinguishes all other named references. Each live summary is either already quoted or corrected by the settled substitution. The historical summary is deliberately retained as a quotation of historical source, not relabelled as a new independent summary.

## Every assertion of the replaced sentence

| Assertion | Ownership and source | Q-QUOTE preservation |
|---|---|---|
| Claimed create first picked up while the tenant is suspended | Package's case scope, frozen31–32 | Every original word retained, package31–32 / prospective comment57–58. |
| Worker tenant-status refusal governed by OPS-43 | Claim about OPS-43; current source 03-operation-lifecycle.md:786–788, quoted in full by the settled replacement | Original `follows` clause retained at package32 / comment58, followed by exact quote at package32–34 / comment58–60. |
| `not a purchase` | Package's own adopted case expectation, not words claimed to be a direct OPS-43 quotation. Item13 adopts the exact Q1-B case, coordinated with item3's stop-before-buying policy and item19's landing order. Current OPS-43 corroborates it: `Make no provider\n   request, including List offers or a per-order key upload.` (:788–789). | Original words remain at package32 / comment58, before the added parenthetical. |
| `it is not required to succeed merely because its claim defeated the administrative write` | Package's own adopted race clarification, frozen32–33. OPS-43 does not discuss the administrative write. API-58:665–666 supplies `loses this race and settles through that worker instead`. Claim victory selects the settling worker, not a successful outcome. | Every word retained at package34–35 / comment60–61. |

The last clause removes a ground for insisting on success; it does not mandate failure for every claim winner. Full OPS-43 precedence remains controlling: `The first failing check stops subsequent checks; its owning classification governs disposition.` (:854). The account read/refusal at :776–784 precedes the tenant read. An unhealthy account plus suspension can fail with the account reason, as existing CNF-202:2322–2324 explicitly tests. Opus's counterexample refutes a context-free universal reading of the original, not the selected repair or the panel premise. Q-QUOTE adds no override, healthy-account fixture, blanket failure rule or deferred-operation repair. It preserves the case expectation in its existing ordered-check context. A create that passed the dispatch guard before suspension remains the separately specified potentially dispatched case.

The new quotation's conflict/reason/retryable values supply evidence for the already referenced refusal; they do not add a new worker test, assert instruction or verdict. Existing CNF-202:2299–2305 already tests that otherwise-valid worker refusal. This is why the added evidence is wording-only in check strength.

## Surrounding assertions and exclusions

`tally-verify.py` proves the entire executable package is M's frozen bytes with exactly one target substitution, and the comment changes only that target plus authority line6. Thus all surrounding assertions remain byte-identical:

| Frozen package lines | Retained obligations / checks |
|---|---|
| 3–7 | Same guarded transaction closes commitment and releases full remainder; no setup-fee or first-unit debit; generation check then tenant primitive then status write then release; zero-row short circuit. |
| 11–15 | Independent store fixtures; no normal-queue reachability claim; source-list caller-kind coverage; never-claimed queued operation, suspended tenant, unsettled parent. |
| 15–19 | One row; failed/conflict/reason; caller origin retained; null system reason; no provider request; nonzero reserve/setup/prepaid unit; full release and neither debit. |
| 21–25 | One guard varied per fresh fixture: system origin, operator retry, real running claim, active tenant, settled parent; other terms true; zero rows; unchanged operation/origin/error; no administrative commitment/provider effect. |
| 26–27 | Stale old-parent write after resume and fresh suspension remains unauthorized. |
| 29–31 | Both race orders; administrative-first prevents claim; claim-first prevents administrative failure, preserves returned claim number and leaves settlement to worker. |
| 33–35 (now35–37) | Existing held-power scheduling case retained; no normally eligible create substituted. |

No deferred-operation guard term, previously claimed/deferred queued fixture, guard predicate repair or other item13 exclusion is added. No declaration, proof, guard hypothesis, source gate, baseline or negative control changes. pv-bxh and closed pv-kv2 remain outside scope.

## Byte audit and explicit limitations

All selected source payload checks use raw UTF-8 bytes, preserving LF, punctuation and intrinsic three-space continuation indentation. At future CNF placement add six spaces to each line as its outer list-container indent; remove exactly those six to compare. No other normalization is allowed. The quote is 172 bytes, SHA-256 `239566222f807e93b379fc3e3af012b581c54c29b1cbef97b4174657c012abf5`, exactly M's OPS-43:786–788. It is identical in the replacement, executable package, prospective comment and note. It excludes the later nested OPS-11/LDG quotations; no claim of their direct equality is made.

The two unchanged LDG-32 payloads match M:312 exactly. The authority's owner answer matches owner item13 exactly. The note's wording-rule payload matches the manager brief's 2026-10-28 quotation exactly. Its original fence matches frozen31–33 including line breaks; its replacement fence equals Q-QUOTE exactly. Its leading two LF bytes and final LF are preserved. The prospective archive equals all original 2,644 bytes followed by the reviewed 1,295-byte note; existing lines1–35 remain a byte-exact prefix. It becomes prefix-identical, not whole-file identical, to the external frozen original.

The retained historical Current behavior fence is byte-identical to its explicitly named 3109b5b source. The r83 owner-question fences and item13 exclusion/item19 tail payloads verify against their named records. Two inherited display quotations are NOT byte-exact, and were not silently repaired: the insertion locator joins the source's LF between `that` and `kind`; the rejected-option excerpt joins the owner record's LF/four-space continuation after `A:`. Readers disclosed both. They are unchanged locator/approval displays, not additional live requirement-summary repairs. These findings do not justify claiming all retained display quotations are exact. Every newly introduced selected quotation is exact.

Complete relevant homes were independently extracted from Git objects and compared with supplied evidence, including complete OPS-43, API-58, CNF-202, LDG-32/35, WIR-10/10a, API-64, OPS-11, DOM-20, WIR-9a/10b, OPS-39 and STO-3. PR65 adds both the step1 refusal and step8 tenant guard; the quote is absent in its parent. The r83 record expressly coordinated Q1 with the future Q4 refusal; item19's order is satisfied by PR65. No claim that old r83 already had this refusal is accepted.

The citation trial exit0 concerns a disposable application of the old package. `tools/check_citations.py`'s ATTRIB at :234–236 requires backticked identifiers; these new package attributions use bare identifiers. Its summary-verb scope is also narrower than AGENTS. The green trial is not evidence of the manual quotation duty or these bare-ID payloads' correctness. Manual byte checks above supply that evidence.

## Rule6 and reader disagreements

apply notes.md rule 6 exactly as written; this prompt adds no void rule.

No verified brief error changes the question's premise. Non-void corrections: target ranges should end at comment59/package33, not60/34; source body ends936 followed by blank937; the `three assertions` shorthand omits separately counted case scope; the purported exact insertion locator contains a source LF reflow. Sol's final answer's drift range97–100 is inaccurate: the actual drift section is91–94. No preference rests on these mistakes. Astra/Sol had intermediate verification-script assertions fail, then identified/disclosed the display reflows; their complete final answers are substantive, stdout matches, exit0. Sol's temporary source-copy parity output initially missed pathname headers; direct comparison here includes them where present. No missing-seat inference follows from these corrected local probes.

Opus rejects Q-POINTER for potentially strengthening a store-race test into an instruction to execute/assert worker refusal, and narrowing its class statement to `this test's` create; Astra/Sol accept it as equivalent. That is an actual candidate disagreement, not a dissent on Q-QUOTE. The unchanged original has explanatory declaratives; Q-POINTER adds explicit `assert` language. This supports Opus's caution, but no verdict on it is needed to settle the unanimously preferred exact Q-QUOTE. No synthesized pointer repair is adopted. All reject Q-KEEP's claimed exemption: `follows OPS-43's tenant-status refusal` describes source content.

All three accept the exact Q-QUOTE authority and matching L-NOTE appendix. Each calls both picks wording-only separately for behavior, owner-item13/Q1-B meaning and check strength. Independent verification agrees: only evidence/provenance is added, all operative words stay, no assertion is weakened and no excluded fix is added. The wording precedent appears under PR handling; applying it to this pre-Run wording finding is explicitly authorized by this tally's user instruction. No owner question is needed.

L-NOTE's repository link resolves from r83/check to panels-2026-10/r96/notes.md only when the reviewed r96 record is archived alongside it. That dependency is part of the settled landing choice. The .txt appendix does not render as Markdown and gates do not enforce that link; the apply turn must preserve and check it explicitly. No source archive, tracker or branch is changed by this tally.
