# Independent settlement audit — Panel O r94b, 2026-10-31

Read complete original Q4-D and decoded comment860, all substantive r94b ballots, selected complete package and matching note. Read spec only by git show in r94b's reader clone. `tally-verify.py` independently reruns byte checks against actual M/H objects and `tally-verification.json` records the successful results. The bot's actual P1 body and commit/path/line are saved in `tally-bot-finding.json`. M is a7b6884878bc7e53dc403dd8a4383d85afac3634; H is b85af778fda2a96fb0024a07c69092665303bfbe. Live remote master and PR53 head still match. No moved-ref stop condition.

## Every occurrence of the two claims

The inventory follows complete original Q4-D and comment860, not just identifier matches. The actual target is H `.beads/issues.jsonl:101`, pv-kv2, comments[0], id860. Its original decoded text and H archive both match the supplied originals byte for byte; the external r83b/Q4-D original also matches.

Serialization attribution, once in each: archive29–30; decoded brief69–70:

```text
A serialization failure is retried as a whole transaction under OPS-49
and is not a tenant-status refusal.
```

Provider-ordering attribution, once in each: archive41–44 (named source43); decoded brief81–84 (source83):

```text
A create past
the guard can still be between the acknowledged transaction and its provider call, because
LDG-69 keeps the call outside the transaction; treat that residue as the potentially dispatched
case.
```

Related occurrences also read and preserved: whole-transaction lost-acknowledgement recheck at archive25–29 / brief65–69, and its conformance case archive88–90 / brief131–133; acknowledged-before-provider-call conformance barrier archive83–87 / brief126–130. These are adopted package instructions/assertions, not additional attributions to OPS-49/LDG-69. The original claim/acknowledgement retention at archive30–31 / brief70–71 remains at selected31–32 / brief71–72.

Selected serialization text is at package29–31 / prospective brief69–71; selected provider passage at package42–45 / brief82–85. New quotation payloads and both explicit local instructions remain. The L-NOTE archive preserves all original bytes as prefix; appended correction starts with blank99, heading100, serialization109–111 and provider117–120. Prospective brief6 receives exactly the reviewed authority-line replacement. No original archive line is rewritten.

## Source applicability and beyond-quotation words

The selected provider payload at M lifecycle817 is byte-exact:

```text
Step 9 MUST begin only after step 8's transaction is acknowledged.
```

Read full OPS-43:757–835. Step8's insertion point is before operations-row write804; acknowledgement ordering817 survives. That ordering licenses a gap after acknowledgement and before step9's provider call. The local instruction “treat that residue as the potentially dispatched” / “case.” remains explicit. Its classification and permission to settle come from Q4-D item3 under owner item19, not from the quoted ordering sentence. Item6 retains the exact acknowledged-guard/suspend-before-call trace.

Read full LDG-69:463–494 and STO-55's transaction rule. Ledger489–490 identifies OPS-42's funding read/fence-write transaction. Thus the discarded LDG quote's “that transaction” at494 refers to that funding/fence transaction. Ledger465's “While it is held” conditions the wider primitive prohibition. STO-55:257–259 explicitly calls it “this rule for / the tenant primitive alone”; STO-55:253–254 supplies the universal transaction/provider-call prohibition. API-63:1428 does repeat the old LDG attribution; that textual precedent does not expand LDG-69's own scope. No outside-scope API-63 amendment or bead is made.

Opus's former categorical “Step 8 doesn't hold the primitive” exceeds what the absence of a mandate proves; Opus explicitly withdraws it in r94b. The supported narrower claim is sufficient: OPS-43 does not require a primitive hold there. API-63:1416–1419 concerns admission/account contention and does not establish a blanket prohibition. No present vote relies on that withdrawn categorical claim.

Read full OPS-49:1925–1994. The selected whole-transaction payload is exact at1927–1928:

```text
the component MUST repeat the **whole
transaction** — never the last failed statement, and never the provider call (`OPS-12`)
```

The selected serialization payload is exact at1955–1956:

```text
A
  serialization failure is repeated at once.
```

The opening MUST is conditioned on store error/timeout; the separate bullet says “**Constraint violations and serialization failures are not store errors**”. The quoted snippets alone therefore are not claimed to establish the full adopted tenant-guard policy. Q4-D item2 itself owns the explicit following instruction “retry a serialization failure as a whole transaction and do not treat it as a tenant-status refusal.” The whole repeat unit and distinct refusal classification remain explicit in the selected text. Its lost-acknowledgement/recheck/no-null-guard policy is also Q4-D item2, with OPS-43:817–818's lost-reply repeat context, OPS-11:249's worker pre-step9 rule and STO-3's repeat-admitting write context. No store-error bound is newly applied to serialization.

The retained attachment route is supported by OPS-27 lifecycle642–643:

```text
**Where the machine's tenant is suspended at the moment of the attach, that same transaction also
enqueues a system cancellation**
```

Lifecycle611–612 names resolving-observed and late attach. Applying that route to Q4-D's newly defined potentially-dispatched class remains the adopted package's instruction; none of the new quotation snippets supplies or changes that suspension policy.

## Every adopted assertion and its selected landing

The following inventory follows Q4-D's original items and the original brief's remaining sections. Original means original package lines; Q is selected full Q-QUOTE-OPS43; B is prospective decoded comment. This table was checked against the complete originals and full substitution equality. That equality protects every unaffected byte, rather than only the displayed assertions.

| Original assertion and placement | Original | Q | B |
|---|---:|---:|---:|
| Item 1 insertion after account refusal, before step 2; plain tenant read before channel closure and boundary validation | 3, 6–12 | 3, 6–12 | 43, 46–52 |
| Suspended tenant gives `conflict` / `tenant_suspended`, nonretryable on both views | 6–8 | 6–8 | 46–48 |
| No provider request, including List offers/key upload; failed/full release/no setup or first-unit debit | 8–10 | 8–10 | 48–50 |
| Preserve `requested_by` and `system_reason`; no admission-only `suspended`; later guard closes race | 10–12 | 10–12 | 50–52 |
| Item 2 placement after account check, before operation write; same-transaction conditional tenant-row write | 15, 18–19 | 15, 18–19 | 55, 58–59 |
| Contention with admission flag; earlier read or earlier-check lock insufficient | 19–21 | 19–21 | 59–61 |
| Suspension wins: rollback, exact refusal/views, failed/full release/no debit/no step 9 | 21–24 | 21–24 | 61–64 |
| First failed transaction commits neither marker nor correlator | 24–25 | 24–25 | 64–65 |
| Lost acknowledgement: whole-transaction guard recheck, preserve earlier values, recorded pre-step-9 failure, no null settlement term | 25–29 | 25–29 | 65–69 |
| Whole-transaction serialization retry; distinct from tenant refusal | 29–30 | 29–31 | 69–71 |
| Operation claim guard and acknowledgement-before-step-9 retained | 30–31 | 31–32 | 71–72 |
| Item 3 full replacement boundaries; guard-passed create potentially dispatched and MUST be allowed to settle; attach cancellation | 34, 37–39 | 35, 38–40 | 75, 78–80 |
| Claim alone insufficient; early-read refusal and guard defeat prevent purchase | 39–41 | 40–42 | 80–82 |
| Acknowledged/pre-call residue remains potentially dispatched | 41–44 | 42–45 | 82–85 |
| No administrative failure/release of uncertain order; deterministic worker pre-step-9 exception and OPS-11 quotation | 44–47 | 45–48 | 85–88 |
| Item 4 placement and OPS-43 pointer; OPS-27 route, including late evidence after parent settlement | 50–56 | 51–57 | 91–97 |
| Item 5 replacement boundaries; no fleet-gone promise; authorization ends at guard; account for machines from potentially dispatched orders | 58–63 | 59–64 | 99–104 |
| Terms/operator documentation explain earlier authorization, later completion and cancellation; no recall/success promise | 63–66 | 64–67 | 104–107 |
| Item 6 insertion after additional Q1 store cases if adopted, otherwise before amendment | 69 | 70 | 113 |
| Active admission/unclaimed/claim race: exact failure/views, no request/purchase/debit, full release, original origin, no admission-only error | 72–77 | 73–78 | 116–121 |
| Early read sees active: same refusal, only preceding nonmutating reads, no step 9 or first marker/correlator; race both winners | 79–83 | 80–84 | 123–127 |
| Acknowledged guard then suspension before call: potentially dispatched, settlement, suspended-attach cancellation and late evidence | 82–86 | 83–87 | 126–130 |
| Lost acknowledgement: deterministic failure, preserved columns, full release, no speculative dispatch, claim guard every settlement | 88–90 | 89–91 | 132–134 |
| Auction, standard/`correlator: none`, temporary-key coverage | 91–92 | 92–93 | 135–136 |
| Unhealthy-account priority; healthy-account tenant-before-channel priority; no request | 94–96 | 95–97 | 138–140 |
| Unspecified pinned text unchanged | 1 | 1 | 41, 158–162 |
| Category, summary, fixed policy, owner evidence, historical Current behavior | Original brief 1–37 | — | 1–37 |
| Authority line: historical adopted artifact versus corrected executable blocks | Original brief 6 | — | 6 |
| Rejected buy/charge/cancel; retained dispatched-order route; no A/D combination; warning-loss/dissent record | Original brief 143–163 | — | 144–164 |
| Historical drift receipts and PR51/base statement | Original brief 165–175 | — | 166–176 |

## Three separate preservation findings

Behavior: instructions still refuse suspension-first before step9, allow acknowledged-guard-first uncertain residue to settle, enqueue suspended-attach cancellation including late evidence, and recheck the tenant guard on lost-acknowledgement whole-transaction repeat while retaining already committed columns. No uncertainty is administratively failed through the never-claimed path. Ordering/account priority, no-request cases, origin stamps, retryability, release/debits, auction/correlator:none and temporary-key coverage remain.

Requirements: only explanatory source/quoting and reviewed historical/executable authority wording change. The two local operative instructions remain explicit. Q4-D item5, including its terms/operator disclosure and prohibition on promising recall/successful cancellation, is byte-identical. Actual owner item19 was read by git show H:docs/research/panels-2026-10/r83/owner-decisions.md: it says “knowingly accepts the loss of API-58's positive publication duty for the existing-fleet warning” and “No A/D combination, repaired D or partial D.” Neither the candidate nor L-NOTE restores that duty; neither imports Q4-A or changes the adopted disclosure.

Check strength: the complete original item6 is byte-identical in the selected package and comment, including every race, failure, retryability, no-request, no-purchase/debit, full-release, origin, priority, descriptor and attachment assertion listed above. No Lean declaration/statement/guard, fixture, negative control or normative assertion is weakened. No concrete blocking loss or collateral verdict flip is identified. Gates on unchanged M are separate baseline evidence, not proof of wording semantics.

## Every quotation: exact receipts and disclosed differences

`tally-verification.json` records full exact source-block parity and new payload hashes, preserving LF/indentation/emphasis/backticks. Whole-transaction127B, serialization46B and OPS43-provider66B payloads match their source bytes. The discarded LDG-provider78B payload also matches bytes; its semantic referent fails.

The retained OPS-11 payload at original archive46–47 / brief86–87 has LF after “any” where lifecycle249 has a space. Replacing only that LF with a space yields exact source bytes. It is not silently normalized or reported byte-identical. All three readers explicitly accept this pre-existing disclosed wrap. Item5's beginning locator likewise has a space where API731–732 has LF after `**A`; item4's textual locator omits leading bold markup. They remain unambiguous and unchanged. The historical item3 quotation is reflowed versus the owner record; the short owner-choice/rejection/retained-route strings match that record. The historical Current behavior fenced blocks match their named3109b5b sources exactly; original historical complete-file equality receipts against832a219 are verified. The retained “All unspecified pinned text remains unchanged.” is an exact substring of Q4-D line1. No claim of whole-brief quotation byte identity is made across the disclosed historical wraps.

No verified error changes this question's premise. The old “source facts supported” description and earlier Astra/Sol combined-source justification for Q-QUOTE are disproved insofar as they claimed LDG-69 itself governs every create-step8 transaction. Both readers withdraw that acceptance in r94b. The brief expressly permits the applicable alternative source and retains the same wording task. Apply notes.md rule6 exactly as written; this prompt adds no void rule. No tally is voided, no vote excluded, no extra void criterion introduced.

## Exact-form agreement and artifact integrity

Opus/Astra/Sol freshly ACCEPT and prefer the identical supplied Q-QUOTE-OPS43 package, corresponding complete Agent Brief and exact matching appendix. Each explicitly says WORDING-ONLY for behavior, requirements and check strength, and no restoration of the relinquished warning duty. All reject every other supplied complete form; requested counterarguments are not votes. No manager synthesis or unseen metadata repair. L-NOTE is carried, not re-asked. Its dependency is to archive r94/notes.md and the settled correction with the PR53 apply; that notes path is absent at H.

`tally-artifacts.json` identifies full prospective comment/archive/note and settlement hashes. The prospective comment reverses to every original byte by undoing exactly the two substitutions and authority line. Prospective archive preserves every6606 original byte then appends exactly the reviewed1082-byte note. Initial script assertion caught an incorrect draft final-line count before writing the settlement; actual prospective final line is125. No candidate bytes were changed.

No tracker, PR, bead, main checkout, other panel or other-session unit mutation. STATE.md is deliberately not updated: the current user's explicit write allowlist supersedes the common update instruction. Only permitted settlement/prospective/check/tally files are written. Next step is a PR53 apply turn, not another consensus round.
