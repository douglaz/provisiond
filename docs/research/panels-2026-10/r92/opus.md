**Seat: opus.** I made no source, Git, tracker or PR changes and ran no Lean. My only scratch files are in `tmp/opus/`.

## Verified facts this answer rests on

1. **The adopted form's CNF-365 changes its own base only by insertion.** I compared the form's CNF-365 with `10-conformance-checklist.md:1184–1220` at `3109b5b`, the commit it was printed against. The only difference is `35a36,60`: the two "Unknown restart eligibility" paragraphs plus blank lines.
   - The sentence "assert unknown history bound and an explicit nonnumeric report" is unedited base text that the form reprinted. Panel I (r88) did not write it.
   - It came from pv-3jw6 (r74). That same package adopted STO-54's "publish each known bound" sentence.
2. **The checklist changed only once between `3109b5b` and the pin.** The file at `3109b5b` equals the one at `832a219`. From there to the pin, the only change is pv-zuu5's hunk (old lines 1205–1206 became 1205–1214).
3. **R-BOTH is exactly the three-way merge of the two decisions.** I ran `git merge-file` with the pin as ours, `3109b5b` as base and the adopted form as theirs. It reported 0 conflicts, and its output is byte-identical to `candidates/R-BOTH.md`. Against the pin, R-BOTH is a pure insertion (`43a44,68`). Against the adopted form, it differs only in the reporting arm.
4. **The STO-54 landing site is unchanged.** `05-persistence.md` is byte-identical between `3109b5b` and the pin, and the adopted block begins with pin lines 1652–1669 exactly.
5. **No theorem covers the report.** `tools/formal/Provisiond/Restore.lean` lists "`STO-54`'s step (1) beyond the freeze (the possible-loss report, …)" among the things it omits.
6. **The packet matches the pin.** The tracker rows, pv-zuu5's committed brief (equal to the triage table's brief), the pin-context quotes and the brief's three printed blocks all match the pin or the candidate files. The form's SHA-256 is `84b5e77d…902b`.

## Q1 — LANDING ONLY

**What each decision says.**
- **Item 9** approved: "pv-zuu5 … go[es] to ready-for-agent with the exact briefs in the table". That brief says "The report publishes that upper endpoint and its clock/provenance assumptions, identifies the lower endpoint as unknown, and states that no finite duration is established; omitting the known bound or inventing a finite duration fails the case". It adds "using `STO-54` as the owner rather than defining another reporting policy."
- **Item 18** says: "Adopt C-UNKNOWN: pause automatic recovery until trustworthy evidence arrives or a person approves a restore … amend STO-54 and CNF-365 as printed". The adopted STO-54 block says "Unknown possible-loss reporting endpoints on an operator-authorized restore are separate: they use the reporting rules below and do not delay that restore's incident creation, procedure or startup".
- **The rules below** (STO-54, `05-persistence.md:1729–1730`) say: "Otherwise publish each known bound, identify every unknown endpoint and state that no finite duration is established; identify clock/provenance assumptions for known bounds." Line 1731 adds: "Missing reporting evidence does not hold incident creation, the existing restore procedure or component startup".

**Four different unknowns, with different inputs.**
- **Unknown restart eligibility** (C-UNKNOWN): an applicable restart condition, such as no waiting-backend cancellation, "cannot be established". Its input is evidence about the old primary's event history. Its effect is no automatic promotion or restore, and notice to the operator.
- **Unknown lower endpoint b:** there is no certificate that every commit acknowledged before b survived. An idle standby that replayed no record is the example. Its input is replay or prefix evidence. Its effect is `lost_window_starts_at` = null.
- **Unknown upper endpoint f:** there is no verified event-clock bound together with stopping/fencing evidence. Its effect is `loss_end_at` = null.
- **Unknown duration:** this is derived. Whenever either endpoint is unknown, the report must state that "no finite duration is established".

These are independent. In C-UNKNOWN's hidden-event fixture, eligibility stays unknown, yet once an operator authorizes the restore, f can still be certified from fencing and event-clock evidence. Restart-eligibility evidence and report evidence are separate inputs.

**Same-fixture test.** Fixture F is pv-zuu5's: an operator restore of an idle restarted standby, b uncertifiable, f certified. Three candidate reports:
- **R1** publishes f and its provenance, names the lower endpoint unknown, and says no finite duration.
- **R2** says unknown and no finite duration, but omits f.
- **R3** invents a finite duration.

| Text | R1 | R2 | R3 |
|---|---|---|---|
| STO-54 rule (unchanged by both decisions) | complies | violates "publish each known bound" | violates "only when both endpoints are known" |
| Landed CNF-365 (item 9) / R-BOTH | pass | fail | fail |
| Old sentence in the form | pass, or fail under a strict "no numbers at all" reading | pass | fail |

The texts disagree. The owner decisions do not:
- **Item 18 does not demand that R2 pass.** Its own STO-54 block sends reporting to "the reporting rules below", and under those rules R2 is noncompliant.
- **Item 18 does not demand that R1 fail.** That needs the strict reading of "nonnumeric", which contradicts STO-54. Neither decision amends that part of STO-54, and a checklist item can't carry a second reporting policy (AGENTS.md, "One rule, one home").
- **The sentence came from an earlier decision.** pv-3jw6 adopted the STO-54 sentence and the "nonnumeric" arm together, so "nonnumeric" most plausibly meant no numeric duration. pv-zuu5 recorded the ambiguity ("can reject that report or allow a report that omits the certified upper endpoint") and resolved it toward STO-54.
- **Panel I kept reporting out of scope.** Its triage row says "Keep known violation, unknown eligibility, and unknown loss-report endpoints distinct". The r88 tally says "All forms preserve … the report-endpoint separation".
- **The owner was never asked about the report.** Item 18's question and option text concern restart. The owner question cites "CNF-365 at `10-conformance-checklist.md:1184–1220`", which is the `3109b5b` line range.
- **The overlap was anticipated.** PR #53's committed brief already said "if the form no longer applies as written, stop and report that condition".

No same-fixture verdict separates the decisions' meanings. The disagreement is a stale whole-item boundary.

## Q2 — R-BOTH

- **R-BOTH as the final combined implementation:** ACCEPT.
- **HOLD as a temporary hold:** ACCEPT. It is master byte for byte and loses nothing, but it doesn't implement item 18, and I find no conflict that would need it.

**ITEM9: MEANING PRESERVED / WORDING REBASED.** Not one byte of the landed pv-zuu5 text changes.

**ITEM18: MEANING PRESERVED / WORDING REBASED.**
- Item 18's whole change to CNF-365, relative to its base, was the 25 inserted lines. R-BOTH carries them byte for byte, and the fixed STO-54 block is untouched.
- The only printed item-18 text that is absent is one unedited base sentence. Item 9 had already replaced it on master with a stronger version.

**Authority: WORDING RULE.** I checked the three things the wording rule excludes against the combined approved state, meaning the pin plus item 18:
- **Behaviour:** none beyond item 18's. R-BOTH edits only CNF, and the STO-54 block is fixed.
- **Requirement:** no MUST or SHOULD changes. STO-54's reporting text and STO-56 are byte-identical.
- **Check strength:** every addition relative to master is authorized by item 18. Every difference from item 18's printed text is item 9's approved strengthening, already landed.

Applying item 18 literally would be the substantive change: it flips the landed R2 verdict from fail to pass, weakening item 9. Item 18's new obligations rest on the owner's approval, not on the wording rule. The wording rule settles only which literal text gives way at the boundary.

### Preservation audit

Line numbers are R-BOTH as it would land at line 1184.

**pv-zuu5 (item 9):**
- **Fixture.** 1204–1207: "Repeat with an idle restarted standby that has replayed no transaction record and no retained fallback proof, leaving the lower history endpoint unknown, but supply valid retained event-clock and stopping/fencing evidence certifying an upper endpoint under `STO-54`."
- **Criterion 1 (persistence).** 1207–1210: "Assert that the incident persists `lost_window_starts_at` as null and `loss_end_at` as that certified upper endpoint, with a non-null incident-keyed `history_evidence_ref` identifying the retained evidence and the unknown-lower-endpoint reason".
- **Criterion 2 (report).** 1210–1212: "assert that the operator report publishes the certified upper endpoint and its clock/provenance assumptions, identifies the lower endpoint as unknown and states that no finite duration is established". Then 1213–1214: "A report omitting the certified upper endpoint or inventing a finite loss duration fails this case."
- **Existing restore procedure.** 1214: "Follow with the existing restore procedure."
- **Criterion 3 (other arms).**
  - 1214–1215: "Repeat with no verified event-clock bound and assert an unknown upper bound."
  - 1215–1216: "Do not use a restart time or a backup name to fill an unknown history bound."
  - 1217–1220: certified evidence for each known endpoint, null for each unknown one, non-null reference.
  - The other promotion arms (1184–1203, 1222, 1224) and continuation (1226: "Assert continuation of that same incident") are unchanged.
- **Criterion 4 (gates)** is the manager's process, not text.

**C-UNKNOWN's old report sentence, by component:**
- **"idle restarted standby … no retained fallback proof"** survives in 1204–1205, with the fixture narrowed to certified f.
- **"assert unknown history bound"** survives as 1207–1208 (lower endpoint null) and 1211–1212 (lower endpoint "identifies … as unknown"). The upper side is 1214–1215.
- **"explicit nonnumeric report"** survives, under the duration reading, as 1212 and 1213–1214. The case with both endpoints unknown is 1248–1250: "assert null endpoints and an explicit unknown report".
- **"followed by the existing restore procedure"** survives in 1214.
- **The strict reading does not survive,** and neither does R2's pass. Both were changed by item 9's landing, which is already on master, not by R-BOTH relative to master. I name them as the one difference from item 18's printed text.

**C-UNKNOWN's new paragraphs:** byte-identical at 1228–1250.
- **Positive control** (1228–1233): "Promote each equal standby in a separate run and assert restart classification, no restore record and no restore credential-generation bump, preserving the ordinary startup-generation advance".
- **Hidden event with identical survivor inputs** (1233–1237): "Do not give the procedure the test's hidden oracle or label its unknown state as a known violation".
- **Known event, including shutdown:** 1237–1239.
- **Lost or incomplete coverage, mismatched, unauthenticated or conflicting evidence** (1241–1243): "Missing logs or an assertion without continuous coverage cannot pass".
- **Retention** (1243–1245): "neither is silently reset".
- **No automatic restore; explicit operator authorization; stopped components; acknowledged record before startup:** 1245–1248.
- **Final no-certified-endpoints restore with no wait for reporting evidence:** 1248–1250.

**Both decisions:**
- Every older assertion is unchanged: 1184–1226 equals pin 1184–1226.
- The provenance at 1252–1253 is unchanged. Following the adopted form, it becomes its own paragraph.
- No guard, theorem, formal declaration or gate negative control changes.
- The STO-54 meaning is the fixed block.
- **Loss:** none relative to master. Relative to item 18's printed text, only the R2/strict-reading flips listed above.

## (a) Requested counterargument (not my vote)

**The argument.** Item 18 says "adopt exactly … as printed". One could read the old arm's fixture as an idle standby with no upper evidence, so both endpoints unknown, and "explicit nonnumeric report" as an explicit check of the report in that fixture. In R-BOTH, the idle-standby repeat with both endpoints unknown (1214–1215) explicitly asserts only "an unknown upper bound". The explicit unknown-report check survives only in C-UNKNOWN's restore fixture after unknown eligibility (1248–1250). That moves a check between fixtures, which is a strength question, so the owner would be required.

**Why I don't accept it.**
- The repeat inherits the arm's report assertions, and 1217–1220 still governs null endpoints and the reasons.
- That wording is master text, which pv-zuu5's Round 1 review accepted under item 9. R-BOTH doesn't create it, and HOLD has it too.
- No reading makes item 18 require the omission of a certified bound.

## (b) Brief errors (notes.md rule 6)

I found none that changes the premise, so nothing is voided. Two imprecisions, neither of which my vote rests on:
1. **Paragraph structure.** The brief says R-BOTH inserts "before the trailing owner/provenance paragraph". At the pin, the "(`STO-5`, …" citation lines continue the open-record paragraph. The insertion's blank line is what makes them a separate paragraph, exactly as the adopted form does. The printed bytes are correct.
2. **Excerpt range.** The STO-54 range "1638–1823" is an excerpt; STO-54 continues after line 1823.

Q1 FINAL: LANDING ONLY
Q2 FINAL: R-BOTH; ITEM9: MEANING PRESERVED / WORDING REBASED; ITEM18: MEANING PRESERVED / WORDING REBASED; AUTHORITY: WORDING RULE
