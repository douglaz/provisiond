# Panel P r95 independent preservation audit — 2026-11-02

M=`6a3b6014f1f8b36fc21b902e507e74d8c5264e99`; H=`96a72898c7ace67790aec0bab3727eee858e2245`.
The read-only main ref check still returns exactly M/H. No moved-ref comparison or stop is needed.
`tally-verify.py` independently reads Git objects, checks external evidence against its owners,
constructs prospective files from H, and reverses every substitution to recover all surrounding bytes.
It does not run the launch preparation script. `tally-verification.json` holds the byte receipts.

For the tables, L=`03-operation-lifecycle.md`, A=`04-api-contract.md`, C=`10-conformance-checklist.md`;
B=decoded comment860 at M/H, physically `.beads/issues.jsonl:101`; D=archived
`docs/research/panels-2026-10/r83/r83b/Q4-D.md`. All original locations refer to H.
The prospective locations refer to independently constructed Q-QUOTE/L-NOTE files in `check/`.

## Every attribution and its treatment

The six complete executable blocks, each identifier and implicit reference were inspected.
`tally-occurrence-search.md` additionally lists matching lines in the complete comment and archive.
The heading locators and historical quotations outside the executable blocks are preserved as history.

| H occurrence | B / D occurrence | Evidence, classification and exact settled coverage |
|---|---|---|
| L789–790: “under OPS-11's pre-step-9 create rule” | B49–50 / D9–10 | Retained classification and money assertion. Replacement1 retains the instruction and adds OPS-11's exact classification and money sentences. |
| L814–816: “API-58's admission-time suspension flag write” | B59–61 / D19–21 | Mixed: flag is retained source; same-row contention is the new local command. Replacement6 quotes API-58's “marks the tenant `suspended` **in the admission transaction, before the `202` is returned**” and retains the complete command. |
| L818–819: “under OPS-11's pre-step-9 rule” | B63–64 / D23–24 | Retained classification and money assertion. Replacement2 retains failure/full release/no debit and quotes both source sentences. |
| L820–824: “under the same pre-step-9 rule” | B65–69 / D25–29 | Implicit retained OPS-11 attribution within the new lost-ack instruction. Replacement3 preserves the instruction and quotes the classification and ordinary worker-guard sentences. |
| L824–826: “OPS-49 says” and its two quotations | B69–71 / historical D29–30, qualified by D109–111 | Panel O's supplied whole-transaction and immediate-retry payloads are exact and unchanged. The historical summary remains visibly superseded by Panel O; P does not rewrite that historical sentence. Embedded OPS-12 is part of the source quotation. |
| L826–827: “The operation-row claim guard and acknowledgement-before-” / “step-9 rules remain required.” | B71–72 / D30–31 | Local preservation command, retained verbatim. Same-requirement step references at L788 and L820–827 identify this package's sequence. |
| A623–625: “passed OPS-43's tenant dispatch guard”; “its machine follows OPS-27's suspended-attach cancellation” | B78–80 / D37–39 | Mixed: guard/classification are new coordinated package policy; attachment is retained source. Replacement4 quotes the complete suspended-attachment paragraph without deleting the local rule. |
| A625–627: “fails under” / “OPS-43”; “step-8 tenant guard” | B80–82 / D39–41 | Coordinated new refusal/guard instruction. At M, OPS-43 has no tenant/suspension instruction; H adds it in this very package. The complete “A claim by itself does not authorize purchase” sentence is retained. |
| A627–630: “OPS-43 says” acknowledgement quotation | B82–85 / historical D41–44, qualified by D117–120 | Panel O's exact create-ordering quotation and explicit residue classification are unchanged. The historical LDG-69 attribution remains only as the historical form, qualified by O's appendix. |
| A631–633: “OPS-11 says” classification quotation | B86–88 / D45–47 | Existing quotation carries LF after “any” whereas M's source carries a space. Replacement7 explicitly repairs that byte discrepancy in executable copies; D stays historical. |
| A669: “For the claimed create's tenant-status read, refusal and dispatch race guard, see OPS-43.” | B94 / D53 | Bare owner pointer, retained. |
| A670–671: “retain OPS-27's attach and suspended-tenant cancellation” / “path, including later evidence-based attachment after the suspension parent has settled.” | B95–96 / D54–55 | Retained attachment assertion. Replacement5 retains the full express instruction and quotes the whole relevant paragraph, including the post-parent-settlement rationale. |
| A742–747: “at OPS-43's tenant dispatch guard” | B102–107 / D61–66 | New package-owned disclosure rule, retained byte-for-byte. The launch inventory's A741–742 locator is low by one; the reference is A743. |
| L791–792: “do not emit the admission-only kind” / “suspended”; C2305: “no admission-only suspended error.” | B51–52,B121 / D11–12,D77 | Local prohibition and conformance assertion, retained. They assert this package's rule rather than report a separate requirement. OPS-11's separate source says “they MUST NOT be emitted by a worker or a driver”. |
| C2300–2324 | B116–140 / D72–96 | Package-owned conformance assertions, no separate requirement attribution. Whole block and whole conformance file are byte-identical to H. |

These are all occurrences; there is no further retained-source summary requiring another executable substitution.
Panel O's L-NOTE contains its exact two replacements at D109–111 and D117–120 plus historical metadata.
All those bytes remain unchanged. P's dated appendix qualifies the remaining historical summaries and the
executable reflow without silently rewriting either the original D or O's appendix. The scope includes
the implicit pre-step-9 and API-58 flag references beyond the four PR findings.

## Sources, quotation bytes and provenance

All selected outer payloads compare directly, without whitespace normalization, against the source at M.
The JSON receipt includes each payload's exact byte length, SHA-256 and source lines. Complete OPS-11
and OPS-27 homes match M/H, and all brief source fences match M. Only Markdown list container indentation
is removed when matching executable blocks to their landed locations; intrinsic source whitespace stays.

| Payload | Source at M | Where carried |
|---|---|---|
| “Any create failure the worker records before any step-9 request (before any per-order key upload or order request) MUST settle `failed`, whatever its kind.” | L249, OPS-11 | Replacements1,2,3,7 |
| “The commitment is released in full under `LDG-32`” through “with no setup-fee or first-unit debit.”, complete sentence in the exact replacement files | L249, OPS-11 | Replacements1,2; local operative release/no-debit words retained |
| “The settle write keeps the ordinary worker guard” through “with no `about_to_order_at IS NULL` term.”, complete sentence in replacement3 | L249, OPS-11 | Replacement3; explicit local no-null and claim guards retained |
| “marks the tenant `suspended` **in the admission transaction, before the `202` is returned**” | A618, API-58 | Replacement6 |
| Complete paragraph beginning “**Where the machine's tenant is suspended at the moment of the attach, that same transaction also” and ending “becomes the machine's running commitment.” | L642–654, OPS-27 | Replacements4,5, each byte-exact including all LFs, backticks, emphasis and em dashes |
| “the component MUST repeat the **whole” / “transaction** — never the last failed statement, and never the provider call (`OPS-12`)” | L1927–1928, OPS-49 | Panel O instruction retained in item2 |
| “A” / “  serialization failure is repeated at once.” | L1955–1956, OPS-49 | Panel O instruction retained in item2, including LF and two spaces |
| “Step 9 MUST begin only after step 8's transaction is acknowledged.” | L817, OPS-43 | Panel O instruction retained in item3 |

The source words themselves contain the full-release and setup-fee/first-unit prohibition, so these are
not an inference from a partial classification snippet. The new suspension refusal's kind, reason,
retryability, ordering, contention and rollback behavior come from owner item3 and adopted Q4-D under
item19. Item3 says “Nothing is bought or charged.” OPS-11 does not require retryable true for this
deterministic tenant refusal; its forced-true classes name network, timeout, internal, qualifying provider
failure and cut-off conflict. The selected form leaves Q4-D's explicit false on error and view in place.

Late attachment has direct source support: OPS-27 says “This applies at **all three** entry points.”
Its complete home names successful reply verification, resolving-observed after a lost reply and
late attach after commitment release. The quoted paragraph says “the parent settles `succeeded`”
and describes “create resolving *observed* after that settlement”. The local “including later
evidence-based attachment after the suspension parent has settled” instruction remains explicit,
and the unchanged CNF block exercises it. The predicate is still suspended at attach; quotation
does not authorize unverified attachment or promise cancellation has completed.

Lost-acknowledgement rechecking, retention of prior columns, non-speculative dispatch and the
potentially-dispatched residue are adopted Q4-D instructions. Existing OPS-43 ordering and OPS-11
guard/classification context support them; source quotations alone are not substituted for them.
Panel O's explicit whole-transaction immediate retry and tenant-refusal distinction remain verbatim.

Inherited differences are disclosed precisely:

- Executable OPS-11 classification LF/space discrepancy is the reviewed replacement7.
- OPS-11's nested OPS-6 quotation has a space after “carry”; OPS-6's own home has LF there. The
  outer OPS-11 quotation is byte-exact and retains that inherited inner source text. Sol correctly
  disclosed this. Opus and Astra's claims of direct nested OPS-6 byte equality are incorrect.
  This is no changed quotation payload or semantic difference and does not alter their exact picks.
- LDG-32 and LDG-39 nested payloads do match their direct billing homes.
- Historical owner-item3 excerpt is reflowed; item5's historical locator elides a source LF between
  `**A` and `suspension`. Neither is claimed byte-exact or silently normalized. Both complete
  historical Current behavior fences match their named historical Git commit.

The selected quotations remain explicitly attributed to their source homes. They reproduce source
arguments as quotations rather than create a second independently worded rationale. Repetition and
future drift are real maintenance costs, the readers' requested counterargument; they do not change
the quoted rule or its owner. The citation gate requires backticked IDs for its attribution patterns;
these bare-ID quotations are reviewed by byte audit here, not claimed newly gate-enforced.

## Every adopted assertion and its surviving home

The settled file's complete executable package is exactly `Q-QUOTE.md`; its numbered item identifies
where each assertion lands in that settled text. Locations below additionally identify the actual
prospective spec and decoded comment. Each sentence was checked against original D and Panel O;
the reverse-substitution proof protects every unmodified byte.

| Assertion and identifying surviving words | Settled package item | Prospective spec / B lines |
|---|---|---|
| Account refusal first; “Next read this operation's tenant status.” | 1, after unchanged account paragraph | L776–788 / B46–48 |
| “This read precedes channel closure and boundary validation.” | 1 | L788 / B48 |
| Existing create fails conflict, tenant_suspended, false “on both the error” / “and operation view.” | 1 | L786–788 / B46–48 |
| “Make no provider” / “request, including List offers or a per-order key upload.” | 1 | L788–789 / B48–49 |
| “Settle failed with full commitment” and full release/no setup-fee or first-unit debit, plus exact source support | 1, replacement1 | L789–790 / B49–50 |
| “requested_by and system_reason as originally recorded”; no admission-only suspended kind | 1 | L790–792 / B50–52 |
| “This is a plain read; the dispatch guard below closes the race after it.” | 1 | L792 / B52 |
| Conditional tenant-row write, same step-8 transaction, guarded on not suspended | 2 | L813–814 / B58–59 |
| Same-row contention with API-58 flag; “a plain read or a lock confined to the earlier claim-time check” / “is not a substitute” | 2, replacement6 | L814–816 / B59–61 |
| Suspension zero-row guard: rollback and exact conflict/reason/false on error/view; failed settlement, full release/no debit | 2, replacement2 | L816–819 / B61–64 |
| “No step-9 key upload or order may begin.” | 2 | L819 / B64 |
| First failed transaction commits neither about_to_order_at nor correlator | 2 | L819–820 / B64–65 |
| Lost-ack whole-transaction repeat “rechecks this guard too” | 2 | L820–821 / B65–66 |
| Suspension defeats repeat: keep previously committed columns unchanged and settle recorded failure | 2 | L821–824 / B66–69 |
| “do not add a null-column term to” / “the settlement guard”, with exact source guard quotation | 2, replacement3 | L823–824 / B68–69 |
| Whole-transaction immediate serialization retry; “do not treat it as a tenant-status refusal” | 2, Panel O text unchanged | L824–826 / B69–71 |
| “The operation-row claim guard and acknowledgement-before-” / “step-9 rules remain required.” | 2 | L826–827, existing L828–842 sequence / B71–72 |
| Past-guard create “is potentially dispatched and MUST be allowed to settle rather than” / “abandoned mid-order” | 3 | A623–625 / B78–80 |
| “A claim by” / “itself does not authorize purchase”; early read and losing guard prevent purchase | 3 | A637–639 / B92–94 |
| Acknowledged but not-yet-called residue remains potentially dispatched, with exact OPS-43 ordering quote | 3, Panel O text unchanged | A639–642 / B94–97 |
| “Never fail or release such an uncertain order through the never-claimed administrative” / “write.” | 3 | A642–643 / B97–98 |
| Actual recorded deterministic pre-step9 failure still fails | 3, replacement7 | A643–644 / B98–99 |
| Suspended-at-attach predicate, same-transaction system cancellation, origin and delete-episode routing, all source entry points | 3 and 4, replacements4,5 | A625–637,A682–694 / B80–92,B107–119 |
| Explicit “including later evidence-based attachment after the suspension parent has settled” | 4 | A681–694 / B106–119 |
| Guard pointer for claimed-create read/refusal/race | 4 | A680 / B105 |
| Public exception: pre-authorized order may complete; resulting machine subject to cancellation | 5 unchanged | A765–770 / B125–130 |
| “They MUST NOT” promise recall or completed cancellation | 5 unchanged | A769–770 / B129–130 |
| Valid active admission, healthy account/open channel; leave unclaimed; suspend; claim before fan-out | 6 unchanged | C2300–2302 / B139–141 |
| Failed/conflict/reason/false on both; no request/purchase/fee/unit debit; full release; original origin; no admission-only kind | 6 unchanged | C2302–2305 / B141–144 |
| Early read active then suspension before guard; same refusal; only prior non-mutating reads | 6 unchanged | C2307–2308 / B146–147 |
| No step9; no first-transaction timestamp/correlator commit | 6 unchanged | C2309 / B148 |
| Race guard against suspension in both orders | 6 unchanged | C2309–2310 / B148–149 |
| Guard wins, commits and acknowledged; suspend before call; potentially dispatched/allowed to settle | 6 unchanged | C2310–2312 / B149–151 |
| System cancellation in attach transaction if still suspended; late evidence after parent settled | 6 unchanged | C2312–2314 / B151–153 |
| Lost acknowledgement then suspension before repeat; deterministic failure, old columns unchanged, full release, no speculative dispatch | 6 unchanged | C2316–2318 / B155–157 |
| “Retain the worker claim guard in every settlement.” | 6 unchanged | C2318 / B157 |
| Auction and standard-channel correlator:none and per-order temporary keys | 6 unchanged | C2319–2320 / B158–159 |
| Unhealthy account wins over suspended tenant | 6 unchanged | C2322–2323 / B161–162 |
| Healthy account+suspended tenant+closed channel gives tenant_suspended; no request in either precedence case | 6 unchanged | C2323–2324 / B162–163 |

Item5 and item6 compare byte-for-byte with H. No positive existing-fleet warning-publication duty is
restored: item5's only affirmative terms/documentation instruction is “MUST explain” the pre-authorized
order exception, followed by the explicit prohibitions. Original D's chosen text is not combined with A.
No assertion is removed, weakened, made unreachable or vacuous. No formal declaration, proof statement,
guard hypothesis, fixture, gate, baseline, negative control or normative owner home changes. pv-gvc and
pv-bxh remain outside scope. Quoting already-binding requirements adds source evidence, not a new duty.

## Rule 6 and factual qualifications

No verified brief error changes this question's premise, so no tally is void. The A741–742 locator is
wrong; the actual block is A742–747, guard reference A743. No vote rests on that locator. The checker
calls summary paraphrases legitimate prose within its deliberately limited lexical scope; AGENTS'
“every sentence asserting what another requirement says carries its quote” is the governing review
instruction. Bare-ID quotations are also outside the gate's pattern coverage, as Opus observes.
Panel O's narrower previous wording settlement grants no blanket exemption for other summaries.
Item19's historical “unchanged” is preserved; the later wording-rule authority and dated notes record
the wording-only qualification. Neither requires reopening the knowingly accepted publication-duty loss.

Opus and Astra's incorrect direct nested-OPS6 byte-equality claim is corrected above. Sol reports the
actual inherited mismatch, and all three accept exactly the same source-faithful outer OPS-11 payload.
It does not create a second exact form or a verified blocking loss. Opus's “weaker” description of
Q-POINTER is its maintenance/preservation preference alongside an explicit ACCEPT, not a substantive
rejection. No requested counterargument is counted as a dissent. Reader tracebacks were temporary
verification-script errors followed by complete successful substantive answers, not terminal seat failures.

## Landing and limits

Q-QUOTE/L-NOTE is wording-only in behavior, requirements/owner meaning and check strength. All three
agreeing readers expressly say so, and the independent audit agrees. The owner's rule is “For such
wording questions, try to solve by getting a consensus of the panel”. Both questions have the same
three explicit picks and ACCEPTs. No owner question or r95b is needed.

The settled exact substitutions update L/A, comment860's corresponding snippets and authority line,
and append the exact dated note after D's Panel O appendix. D's existing bytes remain an exact prefix;
there is no original archive replacement. The reviewed r95 record including `notes.md` must be archived
so the note's `../../r95/notes.md` link resolves. The bead stays closed; no other row, field or comment
may change. Artifacts and diffs are prospective only; this tally adopts nothing into the branch/tracker.

Baseline/final full gates run unpiped on unchanged H in the panel's own check/repo. They establish
baseline health, not semantic preservation or application of the prospective substitutions. The apply
turn must run its own gates on the actual changed text and recheck refs/source bytes before applying.
