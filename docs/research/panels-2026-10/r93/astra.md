**Q1 final pick: Q-QUOTE. Q2 final pick: L-NOTE.** Both picks are **WORDING-ONLY**, assessed against the already adopted Q1-A—not against master before that adoption.

I read the complete packet and named evidence. I made no changes, ran no gates, contacted no PR, and started no background work or subagents.

**Q1 acceptability**

| Exact form | Verdict | Reason |
|---|---|---|
| Q-QUOTE | **ACCEPT — final preference** | Preserves both explicit instructions and supplies exact source words for the attributed facts. |
| Q-POINTER | **ACCEPT** | Removes local explanatory assertions, but preserves their operative consequences through the retained ordering, exclusion and owning requirements. This is less explicit than Q-QUOTE. |
| Q-KEEP | **CANNOT ACCEPT** | Its required exemption is unproved. Factual accuracy does not exempt these attributions from the quotation rule. |

The picked replacements, without reflow:

```text
API-7 step 5a says "an equal fingerprint under the
    same `(principal, key)` returns the stored result, a different one fails `conflict`."; a replay returned there never reaches this check.
```

```text
API-65 says "On a row whose `cleanup` is `manual` there is no driver call to make: it
writes `released_at` and answers `200` with the row, minting no operation,"; a manual attachment release takes no capability check under this timing rule.
```

The manual-release no-check instruction comes from **item 16’s adopted timing rule**, specifically original Q1-A line 14, reinforced by its final paragraph:

```text
this timing rule adds no gate
to refresh, a manual attachment release, or the capability-less methods named by PRV-4.
```

That is an exact substring of original lines 41–42. API-65 supplies the no-driver-call/no-operation facts quoted above; it does **not** supply the no-capability-check instruction. Q-QUOTE preserves that instruction outside the quotation and identifies its actual owner. The first paragraph’s admitted-operation scope is API-cleanable release; the final paragraph expressly excludes manual release. The added qualification identifies the existing timing rule’s scope; it does not introduce an exception allowing that rule to check manual releases.

Q-POINTER loses the **local explicit replay-bypass sentence** and the first paragraph’s **local explicit manual no-check/no-operation explanation**. Those textual losses should be recorded. Nevertheless, the replay result quoted above, combined with the unchanged placement after steps 1–5c, still excludes a returned replay from this check. The unchanged final-paragraph exclusion expressly preserves manual release’s treatment; API-65 preserves its no-operation fact. I identify no changed normative or checked verdict from this redistribution. I prefer Q-QUOTE because it preserves the approved explicit explanations as well.

Q-KEEP cannot satisfy its condition. At master, `AGENTS.md:29–32` reads:

```text
**Quote the sentence.** A claim about what another requirement says carries that requirement's own
words. `` `WIR-30` says "The gate reads the copy the machine took at create" `` is checkable;
"`WIR-30` forbids resolving eligibility that way" is an assertion, and assertions of that shape were
false repeatedly on 2026-09-03 — `ddd3df0` and `254fc24` carry the cases and what each one cost.
```

The original sentences attribute behavior to API-7 and API-65. Their substantive support does not establish inapplicability.

**Q2 acceptability**

| Exact landing | Verdict | Record assessment |
|---|---|---|
| L-BRIEF | **CANNOT ACCEPT** | Preserves historical bytes and corrects execution, but leaves the separately encountered, still-flagged archive presenting the old form without an on-file historical/correction notice. |
| L-BOTH | **CANNOT ACCEPT** | Silently replaces the very text that records exact panel/owner approval. The replacement would be accurate operational wording but inaccurate evidence of what was approved. |
| L-NOTE | **ACCEPT — final preference** | Preserves the historical original, marks its status explicitly, and identifies the precise operative correction. |

My L-BRIEF objection concerns record clarity and completeness of this correction; it is not a claim of a changed runtime or Lean verdict.

L-NOTE retains every original archive byte, applies the Q-QUOTE pair once within the Agent Brief’s Desired behavior block, and replaces its authority line exactly:

```text
**Owner decision:** “Approve A (Recommended)” (`owner-decisions-1030.md`, item 16). Historical adopted form: `docs/research/panels-2026-10/r86/r86b/Q1-A.md`. Executable form: the Desired behavior / key interfaces block below, with the 2026-10-31 Panel N r93 wording correction.
```

The complete chosen appendix follows. The initial blank line is part of the supplied appendix:

````text

## Wording correction — 2026-10-31 (Panel N r93)

The text above is retained as the historical form approved in owner item 16.
The executable pv-5pmu Agent Brief uses the following replacements under the
owner's 2026-10-28 wording rule; all other Q1-A text is retained.

Replacement for the replay sentence:

```text
API-7 step 5a says "an equal fingerprint under the
    same `(principal, key)` returns the stored result, a different one fails `conflict`."; a replay returned there never reaches this check.
```

Replacement for the manual-release clause:

```text
API-65 says "On a row whose `cleanup` is `manual` there is no driver call to make: it
writes `released_at` and answers `200` with the row, minting no operation,"; a manual attachment release takes no capability check under this timing rule.
```

Source pin: `3d1fca55e64056e5ad6bc9ac3edcc308ecf04073`.
Review head: `fde983c1794e8d4727f22bc87d1d6ee7f407eca5`.
Panel record: `../../r93/notes.md`.
````

Retaining the offending historical sentences does not make their original composition compliant. L-NOTE preserves evidence of that defect, expressly distinguishes history from execution, and supplies the corrected, quoted replacements in the same document. That is materially different from Q-KEEP’s continued use of the uncorrected form.

The relative record link resolves to `docs/research/panels-2026-10/r93/notes.md`. I verified that this path **does not exist at the review head**. A later authorized landing must archive this panel record at that location and accurately record settlement. The appendix’s present-tense statement about the executable brief must become true in that landing. This is acceptance of the specified prospective package, not a claim that its dependencies already exist.

If Q-KEEP’s exemption had been proved, the defined Q2 landings would all be no-ops and Q2 would have no meaningful implementation distinction. That condition is not met here.

**Separate change assessments**

| Pick | Behavior | Requirement | Check strength | Classification |
|---|---|---|---|---|
| Q-QUOTE | Same replay bypass, manual exclusion and execution order | Preserves the adopted obligations; adds accurate attribution | No changed declaration, guard, fixture, conformance outcome or negative control identified | **WORDING-ONLY** |
| L-NOTE | Same executable behavior | Same operative package, with truthful historical authority | No check alteration; archive evidence remains intact | **WORDING-ONLY** |

The owner’s 2026-10-28 exception can authorize the later correction **after exact-form consensus and verification**. This individual ballot does not establish consensus. Neither pick requires a new substantive owner decision. Item 16’s original adoption of additional ordering was substantive; this correction does not retroactively classify that adoption as editorial.

**Verification**

Here, **M** means master `3d1fca55e64056e5ad6bc9ac3edcc308ecf04073`; **H** means review head `fde983c1794e8d4727f22bc87d1d6ee7f407eca5`.

| Material | Exact source and result |
|---|---|
| Replay quotation | M `04-api-contract.md:209–210`: exact bytes, including the embedded newline and **four leading spaces** before `same`. |
| Manual quotation | M `04-api-contract.md:1109–1110`: exact bytes, including newline before `writes`, **no indentation**, and trailing comma inside the quotation. |
| AGENTS quotations/rules | M `AGENTS.md:29–32`, `34–38`, `45–46`: checked against actual source. The quoted block above preserves its line breaks. |
| Cross-ref equality | The **entire** `AGENTS.md` and `04-api-contract.md` files are byte-identical between M and H. This includes API-7 and API-65. |
| Historical Q1-A | H `docs/research/panels-2026-10/r86/r86b/Q1-A.md:1–59` equals `evidence/Q1-A-original.md` byte for byte. SHA-256: `db7f2b55cf4f49fcc22e6b57d6efc72daaa158817faff1cf2ad67981c19f28e3`. |
| Agent Brief | H `.beads/issues.jsonl:15`, pv-5pmu `comments[0].text`, equals `evidence/agent-brief-original.md` byte for byte, including trailing newlines. No other bead was inspected. |
| Owner authority | H `docs/research/panels-2026-10/r86/owner-decisions.md:5–11` matches supplied item 16. Historical owner-questions §1 also matches its archived counterpart. |
| Candidate derivation | Q-QUOTE and Q-POINTER equal the original with exactly their specified pair substituted. Q-KEEP equals the original. |
| Prospective Agent Brief | In-memory verification confirms each Q-QUOTE replacement occurs once in Desired behavior; the authority line occurs once; reversing these substitutions reproduces every original byte. |
| Appendix | Printed verbatim from `/var/tmp/provisiond-panel-r93/note-Q-QUOTE.md:1–24`, including its initial blank line. Both note variants were read whole. |
| Current implementation state | M lacks the proposed DOM-10 paragraphs and the proposed API-7/OPS-23 pointer insertions. |

**Explicit byte failures:** the evidence reply’s displayed API-7/API-65 quotations are reflowed and therefore are **not** byte-identical quotations. Its displayed replay sentence is also reflowed. The exact strings in `stop-result.json`, the Q-QUOTE candidate and its appendix match their sources. I found no mismatch in the supplied pinned passage blocks.

The stop evidence establishes an unresolved finding in that captured snapshot. It supplies neither a candidate vote nor evidence of current live PR state.

**Assertion-preservation map**

Let **O** denote H’s archived `docs/research/panels-2026-10/r86/r86b/Q1-A.md`; **Q** denotes the supplied complete `Q-QUOTE.md`. Locations below identify the actual preserved spans, rather than reconstructing other requirements’ meanings.

| Assertion in adopted O | Landing in selected complete form |
|---|---|
| Existing mapping rows and error sentence retained; insertion before amendment note | O:3 unchanged at Q:3. M `01-domain-model.md:515–519` and `521–538` remain untouched. |
| Caller/operator scope: power on/off, reboot, hard reset, every install strategy, rescue inventory, reverse DNS, delete/cancel, API-cleanable attachment release | O:6–8 unchanged at Q:6–8. |
| Admission capability check before enqueue | O:8 unchanged at Q:8. |
| After API-7 steps 1–5c and all endpoint-local validation/admissibility; immediately before first transaction write | O:9–10 unchanged at Q:9–10. |
| Running API descriptor; no provider request | O:10–11 unchanged at Q:10–11. |
| Failure produces no operation, endpoint-state write or money write | O:11–12 unchanged at Q:11–12. Agent Brief acceptance criterion also unchanged. |
| Returned replay bypasses the check | O:12–13 replaced at Q:12–13 by the complete quoted replay replacement. Explicit bypass remains. |
| API-64 retry checks `delete_machine` before state-change/enqueue transaction | O:13–14 retained byte for byte within Q:13–14. |
| Manual release has no driver operation | O:14 replaced at Q:14–15 by exact API-65 no-call/no-operation quotation. |
| Manual release takes no capability check | Explicit replacement at Q:15; reinforced by unchanged exclusion at Q:42–43. |
| Suspend parent has no per-machine admission check; children checked at claim | O:15–16 unchanged at Q:16–17. |
| Worker recheck with worker descriptor; includes no-HTTP enqueue, operator retries and delete-enqueued attachment releases | O:18–20 unchanged at Q:19–21. |
| After claim/serialization; before first driver call and either marker | O:21–22 unchanged at Q:22–23. |
| Caller fields, API fields, other local validation including eligibility and signed URL, then capability | O:22–25 unchanged at Q:23–26. |
| First failure stops later checks | O:25 unchanged at Q:26; Agent Brief acceptance criterion unchanged. |
| Existing failure classifier and unsupported result | O:25–26 unchanged at Q:26–27; existing DOM-10 error sentence retained. |
| No commitment/rate/solvency check introduced for non-purchase | O:26–27 unchanged at Q:27–28. |
| Cancellation restore claim gate and ordered fence decision precede capability check | O:29–30 unchanged at Q:30–31. |
| No-call success and defer bypass capability checking | O:30–31 unchanged at Q:31–32. |
| Proceeding cancellation checks after acknowledged fence transaction, before call/write-started marker | O:31–33 unchanged at Q:32–34. |
| Existing failed-attempt/episode disposition; no extra automatic attempt or cleared fence | O:33–34 unchanged at Q:34–35. |
| Internal enqueue has no enqueue-time capability check | O:35 unchanged at Q:36. |
| Operator retry ceiling and system exemption retain scope | O:35–36 unchanged at Q:36–37. |
| Capability selected by mapping | O:38 unchanged at Q:39. |
| Rescue install strategy check before `rescue_ssh`, both before rescue; inventory checks `rescue_ssh` | O:38–40 unchanged at Q:39–41. |
| Identical-PTR success remains after capability check | O:40 unchanged at Q:41. |
| No capability inferred from eligibility list | O:40–41 unchanged at Q:41–42. |
| Refresh, manual-release and capability-less-method exclusions | O:41–42 unchanged at Q:42–43. |
| API-7 pointer and placement after step 5d | O:45–49 unchanged at Q:46–50. |
| OPS-23 pointer, including OPS-40/OPS-41 ordering reference, before amendment notes | O:51–56 unchanged at Q:52–57. |
| No create-gate movement; existing pre-rescue classifier/marker meanings | O:58 unchanged at Q:59. |
| Observable-phase assessment sentence | O:58 retained at Q:59, with the interpretive limitation below. |
| Exact historical approval | All O bytes remain the archive prefix; appendix distinguishes correction. Agent Brief authority line distinguishes historical and executable forms. |

No adopted operative assertion is removed by my selected pair. No normative or checked verdict is weakened or made unreachable. This is a textual/semantic verification, not a gate-run claim.

**Brief error and rule 6**

The retained categorical phase-change sentence is overbroad if it implies that unsupported admission was previously permitted. M `00-overview.md:23–24` contains this exact substring:

```text
the server MUST NOT
accept an operation a provider has not declared support for.
```

Historical `owner-questions-original.md:23` already records:

> The packet's statement that early checking changes a formerly permitted unsupported acceptance phase was too broad; the corrected premise and the ballots already account for that.

The added ordering can change the observable refusal point of an implementation that previously delayed this check; it does not establish that accepting unsupported work was previously conforming. Q-QUOTE changes neither phase nor precedence relative to adopted Q1-A.

Applying rule 6 exactly: this error **does not change either present question’s premise**—the quotation defect and historical/executable distinction remain real. It therefore does not void either ballot. Neither preference relies on the erroneous reading. I found no other premise-changing contradiction.

**Requested counterargument—not a vote**

Against Q-QUOTE: the longer quotations duplicate source material and make the paragraph harder to maintain; Q-POINTER better minimizes repetition while preserving behavior. The manual qualification might also be read in isolation as narrower than the original. I prefer Q-QUOTE because the complete form preserves the explicit instruction and its existing scope while identifying the correct source of each proposition.

Against L-NOTE: an appended notice can be overlooked, the original defects remain visible, and the record link is not yet present. L-BRIEF minimizes archive intervention. Nevertheless, L-NOTE is the only offered landing that both preserves the exact approval evidence and makes the correction discoverable within the flagged archive itself. Its later landing must satisfy the stated record dependency.

Final: Q1=Q-QUOTE; Q2=L-NOTE; Q1=WORDING-ONLY; Q2=WORDING-ONLY