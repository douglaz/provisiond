# Panel r99 — tally: Q1 settled 3–0 on Q1-QUOTE, Q3 and Q5 settled 3–0 on KEEP; Q2, Q4 and Q-REC split 2–1, going to consensus round r99b

Pin `efb40cc55ff04be693473914afd42ef68008fa15`. brief.md sha256 `424f9626b5080078c4a68aaa801b7d69a13739cac3c0b2a0576ecfa23c74d98f` and notes.md sha256
`14c98e411963fb6d60f4bb0d96fd6a9d70508b2abf353041c2ac6385a4b2b736` still match their frozen .sha256 files, and every forms.sha256 entry passes. All four reader clones are still at the pin with clean trees.

**apply notes.md rule 6 exactly as written; this prompt adds no void rule.**

Settle rule, quoted exactly: "a question is settled when at least three agree and more agree than disagree, and a tie comes to you. If grok is down, it falls back to three of four". Fable and Grok are missing, so three seats are present and all three must agree on the same exact form (3–0). Missing seats never lower the three agreements required (notes rule 5). As in r97b and r98, this tally counts final picks and records acceptance separately. Acceptance does not choose between forms (notes rule 2).

## Seats

| Reader | Exit / bytes | Classification |
|---|---|---|
| Fable | 1 / 158 (sha256 `110e3303…0ea2`) | **Missing.** The whole answer is "You've reached your Fable limit. Switch to another model, or manage usage credits at https://claude.ai/settings/usage?from=cc_cli_limit_message, to continue." No vote. |
| Opus | 0 / 10569 (sha256 `7d7d3214a0d48995124e4b45e480afdcfc6fe87ca10babad31cc715905b90580`) | **Substantive.** Read in full. It answers every question and states the rule 6 line. opus.err is empty of limit lines. |
| Astra | 0 / 7057 (sha256 `d54305769176f6a27c2106285b28d5a9ba1631cf3935238347c3154d435c4216`) | **Substantive.** Read in full. It answers every question and states the rule 6 line. Codex stdout equals the answer apart from the terminal LF. The "capacity" and "rate limit" hits in astra.err are echoed spec and prompt text, not a limit line. |
| Sol | 0 / 6640 (sha256 `5eab9d5cd64f0248f51664b32605059518d4cbe8a5b7b41d86fb317d2036f386`) | **Substantive.** Read in full. It answers every question and addresses rule 6. Codex stdout equals the answer apart from the terminal LF. The hits in sol.err are echoed prompt text. |
| Grok | no reader | **Missing.** The r99 preflight got HTTP 402 Payment Required ("Grok Build usage balance exhausted"; check/grok-preflight.*). The r99b re-probe at 05:27Z got the same 402 (r99b/check/grok-preflight.*). |

No reader opened a Q6. Opus names `01-domain-model.md:570-571` as the closest unlisted case and declines it. Astra declines the same sentence.

## Q1: the PRV-25 sentence (01:575). SETTLED: Q1-QUOTE, 3–0

| Reader | Pick | Strongest argument |
|---|---|---|
| Opus | Q1-QUOTE | "remains after its capability check" states PRV-25's own ordering (02:873, :875). It is not a new DOM-10 rule. r93 replaced the same shape ("A replay returned by API-7 step 5a never reaches this check"). r93/tally.md:25 says "The source facts being supported does not establish exemption from the quotation rule." |
| Astra | Q1-QUOTE | The sentence describes an existing ordering and outcome, so AGENTS.md:29 applies directly. Owner approval of the behavior does not create an exception to the quotation convention. |
| Sol | Q1-QUOTE | The sentence reports an existing ordering. Approval of the original wording gives it authority but not an exemption. Q1-A.md:65 "all other Q1-A text is retained" is no ruling that exempts every retained sentence. |

| Exact form | First picks | ACCEPT | CANNOT ACCEPT |
|---|---|---|---|
| Q1-QUOTE (`Q1-QUOTE.txt`, `4c0cbffbf91643afc682f63211c82ae400928e101dd9b4d48aa8e11a49d5419e`) | Opus, Astra, Sol | Opus, Astra, Sol | — |
| Q1-KEEP (`Q1-KEEP.txt`) | — | — | Opus, Astra, Sol |

All three class Q1-QUOTE as wording-only. No seat claims a rule 3 blocking loss. Settled text: `Q1-QUOTE.txt`, sha256 `4c0cbffbf91643afc682f63211c82ae400928e101dd9b4d48aa8e11a49d5419e`. It replaces the `Q1-OLD.txt` span (sha256 `e339d2da45ec1e737a219aa0e4486188ffd47cf3a78e85d712935e0b73be9645`). Because Q1 settled on a non-KEEP form, Q-REC applies. Nothing is applied until Q-REC settles.

## Q2: the API-64 transaction (01:547-548). SPLIT 2–1

| Reader | Pick | Strongest argument |
|---|---|---|
| Opus | Q2-QUOTE | The rule depends on one fact about API-64, that the state change and the enqueue are a single transaction. It states that fact in a coined term: "state-change/enqueue" appears in no root requirement except 01:547. API-64's own words (04:1116-1117) put the fact in the gate's reach. Opus calls this its closest call and accepts KEEP. |
| Astra | Q2-KEEP | The operative assertion is DOM-10's own placement rule. "API-64 operator retry" names the operation, and "state-change/enqueue transaction" names the boundary. This applies AGENTS.md:34 "One rule, one home; everywhere else points at it." |
| Sol | Q2-KEEP | "Its state-change/enqueue transaction" names the transaction before which the new check runs. It does not specify that transaction's atomicity or idempotency. |

| Exact form | First picks | ACCEPT | CANNOT ACCEPT |
|---|---|---|---|
| Q2-QUOTE (`2b46b8b8…adc6`) | Opus | Opus, Astra, Sol | — |
| Q2-KEEP (`e3d78fbf…82f8`) | Astra, Sol | Opus, Astra, Sol | — |

Both forms are accepted by all three, but the final picks split 2–1 and acceptance does not choose a form. Q2 goes to r99b.

## Q3: "classified by OPS-11" (01:560-561). SETTLED: Q3-KEEP, 3–0

| Reader | Pick | Strongest argument |
|---|---|---|
| Opus | Q3-KEEP | It points at the owner (AGENTS.md:34) and states none of OPS-11's content. The quoted lead never mentions a capability refusal, and it says less than the source's row at 03:250. |
| Astra | Q3-KEEP | "is classified by OPS-11" delegates classification to its owner and does not choose an outcome. |
| Sol | Q3-KEEP | Same delegation. KEEP avoids repeating the classifier's introduction. |

| Exact form | First picks | ACCEPT | CANNOT ACCEPT |
|---|---|---|---|
| Q3-QUOTE (`7119ff65…82b`) | — | Opus, Astra, Sol | — |
| Q3-KEEP (`d8a232a6…0c`) | Opus, Astra, Sol | Opus, Astra, Sol | — |

Settled: `Q3-KEEP.txt`, sha256 `d8a232a628594f4bd1f261fcf2b3cf8fb7477ec0369e4a9598c06a66d9525f0c`. No bytes change.

## Q4: OPS-41's no-call success or defer (01:565-566). SPLIT 2–1

| Reader | Pick | Strongest argument |
|---|---|---|
| Opus | Q4-ALT (opus.md, `tmp/opus/Q4-ALT.txt`) | "returned by that decision" has the same shape as r93's "returned by API-7 step 5a", so it cannot accept KEEP. Q4-QUOTE's quotes are real but incomplete: the ordered decision's own defers (steps 3 and 4) are unquoted. The ALT adds OPS-41's "The short deferrals in steps 3 and 4 are not settlements" (03:1153). Opus discloses that the ALT does not quote step 1 and leaves "that decision" as landed. |
| Astra | Q4-KEEP | The operative rule is DOM-10's "takes no capability check". It applies to outcomes obtained from the preceding gates and does not prescribe their predicates. |
| Sol | Q4-KEEP | The sentence sets which outcomes take DOM-10's new check. It names them conditionally and does not restate their triggering conditions. |

| Exact form | First picks | ACCEPT | CANNOT ACCEPT |
|---|---|---|---|
| Q4-QUOTE (`06392de5…10d`) | — | Opus, Astra, Sol | — |
| Q4-KEEP (`230d598c…c4`) | Astra, Sol | Astra, Sol | Opus |
| Q4-ALT (`tmp/opus/Q4-ALT.txt`, `c12991b321e6e9abc74e67dfebba3f16554ee8048ff09a0ca0895933614fa318`) | Opus | Opus | read by no other seat |

Opus states that its CANNOT ACCEPT on KEEP is not a rule 3 blocking loss. All three class their picks wording-only. Q4 goes to r99b. See rule 6 below.

## Q5: the methods PRV-4 names (01:577). SETTLED: Q5-KEEP, 3–0

| Reader | Pick | Strongest argument |
|---|---|---|
| Opus | Q5-KEEP | The landed text is the form AGENTS.md:40-43 and :45-46 ask for: "every list or count names its source instead of restating it". QUOTE writes "The three" and the whole list into DOM-10. |
| Astra | Q5-KEEP | It is a list-owner pointer (AGENTS.md:40 "Cite the list; let it hold the number"). |
| Sol | Q5-KEEP | It points to the owning list without its membership or count. DOM-10 already says "the ones `PRV-4` names" (01:516-517). |

| Exact form | First picks | ACCEPT | CANNOT ACCEPT |
|---|---|---|---|
| Q5-QUOTE (`eb1d82e1…482b`) | — | Astra, Sol | Opus (a rule conflict, not a blocking loss, by its own account) |
| Q5-KEEP (`49a3adf3…fb27`) | Opus, Astra, Sol | Opus, Astra, Sol | — |

Settled: `Q5-KEEP.txt`, sha256 `49a3adf34de880cb20d3b47eeee30f58f7b7aeb5958a8e667feeb6ce71fb3f27`. No bytes change.

## Q-REC: how the record follows. APPLIES (Q1 settled non-KEEP). SPLIT 2–1

| Reader | Pick | Strongest argument |
|---|---|---|
| Opus | R-NOTE-ALT (opus.md; append `tmp/opus/Q-REC-ALT-append.md`) | R-NOTE has three record defects. (1) Its note calls the r93-corrected text "the historical form approved in owner item 16", but item 16 approved only the original, and r93 corrected it under the wording rule (Q1-A.md:63-65). (2) It leaves comment 856's line 6 naming only r93, though r93's own package updated that line (r93/settled-pv-5pmu.md:11, :48-50). (3) "Qn-QUOTE.txt bytes" cannot carry a settled ALT. R-BRIEF repeats what owner item 25 rejected ("Change the brief only"). |
| Astra | R-NOTE | It keeps the executable block in sync and leaves a dated explanation where the historical form lives. Comment 856 labels its block "Executable form" (line 6). |
| Sol | R-NOTE | It keeps the original archive bytes, keeps the executable brief in sync, and links the historical form to the later correction, continuing Q1-A.md:63. |

| Exact form | First picks | ACCEPT | CANNOT ACCEPT |
|---|---|---|---|
| R-NOTE (`6e6a167b…413b`, append `02dcd93d…a298`) | Astra, Sol | Opus, Astra, Sol | — |
| R-BRIEF (`33e383dd…ad40`) | — | Astra, Sol | Opus |
| R-ARCHIVE (`15d02817…f635`) | — | Astra | Opus, Sol |
| R-NOTE-ALT (opus.md; append `445f69c220bfcdefd455fb6447c2c5e93b76d16274a9c051e21b0423358b02ea`) | Opus | Opus | read by no other seat |

Q-REC goes to r99b. Disclosure carried there: R-NOTE's step (1) says "its selected Qn-QUOTE.txt bytes", so it names no bytes for a settled Q4-ALT.

## Rule 6

**Q4: the brief's note is verified wrong.** The brief says "Note that the defer comes from OPS-41's restore claim gate, not its fence-transaction decision" and "QUOTE carries OPS-41's words for each outcome". At the pin, the ordered fence-transaction decision (03:1099, "**The worker decides in this order, inside the fence transaction**") has its own no-call success and defers:
- step 1 (03:1104): "The worker makes no provider call and settles the attempt `succeeded`";
- step 3 (03:1122): "the worker MUST return the attempt to `queued`";
- step 4 (03:1133): "The claim defers";
- 03:1153: "The short deferrals in steps 3 and 4 are not settlements".

QUOTE's quoted defer, "the claim MUST defer", is at 03:1025, in the restore claim gate. OPS-41 places that gate ahead of the decision (03:1113, "Step 1 and the restore claim gate above remain ahead of this decision"). The brief's source excerpts printed none of steps 1, 3 or 4.

**Does the error change Q4's premise?**
- Opus says yes, and asks for Q4 to be re-asked with steps 1, 3 and 4 printed.
- Astra says no. Both printed forms keep the broad no-check rule for any returned defer, so the correction changes neither the forms nor their scope. Its vote relies on that broad scope, not on the note.
- Sol says no. It read the note as naming the selected quote's source, and its vote does not rest on the note.

Manager's reading: the error is about how complete QUOTE's evidence is. It does not touch the landed span, the KEEP form or any form's bytes. The two KEEP votes say they do not rest on it, and opus's ALT is a response to it. So it bears on QUOTE against the ALT, not on whether the sentence needs a quote. **I do not void Q4's tally.** Q4 is split anyway, so r99b is its one consensus round, and r99b prints the corrected sources and this correction in full. If main judges the error premise-changing, r99b's Q4 counts as the corrected re-ask instead, and a split there would get its own single consensus round.

**Other brief errors (not premise-changing):**
- Q4: "QUOTE … keeps the landed sentence's bytes after them" is not literally true. QUOTE changes the landed "A" to "a" (astra, sol; verified against Q4-OLD.txt, which begins `A no-call`). Q1-QUOTE likewise replaces "PRV-25's" with "that". No vote rests on either.
- §3: the method is printed as the full `git diff b5f71e7 efb40cc`, but `check/sweep-diff.txt` holds only the Markdown hunks and omits `.beads/issues.jsonl` (sol; verified: 3 file diffs in the file, 4 files in `git diff --stat`). The prose beside it does name the jsonl change. No vote rests on it.
- §2: the block labeled AGENTS.md:29-32 and :45-46 also prints :34-43 (opus; true, the slice was 29-46). No vote rests on it.
- Comment 856's block is at lines 31-68, inside the text fence at :30 and :69. This was corrected before launch.

No vote is named as resting on a brief error, except that opus says any Q4-QUOTE acceptance resting on the note would rest on an error. No seat's Q4-QUOTE acceptance cites the note as its reason.

## Reader facts checked at the pin

- **Opus:** "state-change/enqueue" occurs in no root `*.md` outside docs/ except 01:547 — true. "restore claim gate" (03:1113) and "fence transaction" (03:1099) are OPS-41's own terms — true. PRV-25 at 02:873, :875 — true. r93/tally.md:25 "The source facts being supported does not establish exemption from the quotation rule" — true. r93/brief.md:231 is a scope limit, and assertion-map.md:276 is "Unchanged bytes." — true. r86b/Q1-A.md:63-65 is the r93 note, and :65 says "all other Q1-A text is retained" — true. Owner item 25 rejected "Change the brief only" (owner-decisions-1030.md, item 25, Sol's option) — true. r93/settled-pv-5pmu.md:11 says decoded line 6 receives the authority-line replacement, :48 is its heading and :50 its old text — true, with :50 rather than :48 for the old text. Comment 856 line 6 ends "with the 2026-10-31 Panel N r93 wording correction." — true. ADR-0023:311 carries the owner sentence — true. R-NOTE-append.md does say "The text above, with the 2026-10-31 Panel N r93 correction, is retained as the historical form approved in owner item 16", while Q1-A.md:63 applies that label to the original text only — true. The hashes of tmp/opus/Q4-ALT.txt and tmp/opus/Q-REC-ALT-append.md match opus.md. Both files end in one LF, and the append begins with two LFs. Opus's gate runs are its own scratch runs, and check_fixtures and check_regions were not verified, by its own account. They are not packet results.
- **Astra and sol:** the Q4-QUOTE quotations at 03:1003-1004 and :1025 are exact — true. 03:1133 and :1153 — true. Comment 856 line 6 is byte-equal to evidence — true.
- No reader claim checked was found wrong.

## Broken packet claims (rule 6: none voids a tally, by the manager's reading above)

1. Q4 note: "the defer comes from OPS-41's restore claim gate, not its fence-transaction decision" and "QUOTE carries OPS-41's words for each outcome" (false; see above).
2. Q4, and also Q1: "keeps … bytes" (the case of the first letter changes).
3. §3: sweep-diff.txt omits the `.beads/issues.jsonl` hunk.
4. §2: the label omits :34-43.

## Scope

Nothing was applied. The repo, branch pv-5pmu, PR #69, the tracker and every bead are untouched. Settled forms so far: Q1-QUOTE, Q3-KEEP and Q5-KEEP. They are applied only with Q2, Q4 and Q-REC once those settle in r99b, or come back from the owner.

---

# Consensus round r99b — tally: Q4 settled 3–0 on Q4-ALT, Q-REC settled 3–0 on R-NOTE-ALT; Q2 still split 2–1 (now QUOTE over KEEP), going to the owner

Pin `efb40cc55ff04be693473914afd42ef68008fa15`. r99b/brief.md sha256 `1188d2241f798ee085b6ba4eb7bb0b8a32240de53d6f01a6b0d232ab93cb3002` and r99b/notes.md sha256 `30c6f52d7c56be481a2f2f530551bcb470006f4b12cdb7162d23acf659d33e64` still match their frozen .sha256 files. All three reader clones (r99b/{opus,astra,sol}) are at the pin with clean trees.

**apply notes.md rule 6 exactly as written; this prompt adds no void rule.**

Settle rule as before: three seats present, so a question settles only 3–0 on the same exact form. Final picks count, and acceptance does not choose a form. r99b is notes rule 4's one consensus round, so there is no r99c: a question still split goes to the owner.

## Seats

Seat map from r99b/check/labels.json: Reader A = astra, Reader B = sol, Reader C = opus. The readers did not see this map, and each said so (each says it can't tell which r99 ballot was its own).

| Seat | Exit / bytes | Classification |
|---|---|---|
| Fable | 1 / 158 (sha256 `110e3303…`) | **Missing.** The whole answer is the limit line "You've reached your Fable limit. …" (rule 5). No vote. |
| Opus | 0 / 10498 (sha256 `498cbd007a06b733de2e4bbee9ca81c4bc6dfd7168e30aa1b89177a0b6ee3f3e`) | **Substantive.** Read in full. It answers Q2, Q4 and Q-REC and states the rule 6 line. opus.err is empty. |
| Astra | 0 / 6831 (sha256 `693aa1a19d204c5c4b1320d93c9a717e66a1c99531da9ab2e8c3471d0907a0f3`) | **Substantive.** Read in full. It answers all three questions and states the rule 6 line. astra.out equals astra.md apart from the final LF. The two limit-line hits in astra.err (:420, :1174) are the reader echoing brief §5's quote of r99's Fable answer. The "limit" hits in astra.md are prose ("limitation", "Verification and limits"). |
| Sol | 0 / 6150 (sha256 `35d83b95763176017dc57959f308eea0af7b0616a14fe81934563d2bae1ead14`) | **Substantive.** Same checks as astra. The sol.err hits (:420, :1305) are the same echo. |
| Grok | no reader | **Missing.** HTTP 402 "Grok Build usage balance exhausted" (r99b/check/grok-preflight.*). |

## Q2: the API-64 retry clause (01:547-548). STILL SPLIT 2–1, now QUOTE over KEEP → owner

| Seat | r99 pick | r99b pick | Strongest argument |
|---|---|---|---|
| Astra (A) | KEEP | **Q2-QUOTE** | The transaction's identity is a source fact. API-64 says "the state change, the enqueue and the idempotency record commit together" (04:1116-1117). QUOTE makes that checkable, leaves the timing clause unchanged, and costs nothing. KEEP's ownership argument is sound, so it accepts KEEP. |
| Sol (B) | KEEP | **Q2-QUOTE** | Quoting the owner of the transaction description "removes an avoidable interpretive dispute without changing placement or adding transaction semantics". The quote doesn't support the check placement, which is DOM-10's own rule, so it accepts KEEP. |
| Opus (C) | QUOTE | **Q2-KEEP** | The sentence says when the retry checks delete_machine, and API-64 never mentions a capability check. "Its state-change/enqueue transaction" only names the boundary, which is a pointer under AGENTS.md:34, "One rule, one home; everywhere else points at it". It is built from API-64's own words (04:1113, :1116), so it can't point at another transaction. QUOTE checks a side fact and adds an idempotency record that the timing clause doesn't use. Q2 names a boundary, while Q4 says what a named decision returns. |

| Exact form | r99b picks | ACCEPT | CANNOT ACCEPT |
|---|---|---|---|
| Q2-QUOTE (`2b46b8b8…4adc6`) | astra, sol | all three | none |
| Q2-KEEP (`e3d78fbf…82f8`) | opus | all three | none |

All three seats switched sides, so the split is unchanged in shape: 2–1 with every seat accepting both forms. No verified rule-3 blocking loss in either form (all three). **Not settled.** Under notes rule 4 it goes to the owner: r99b/owner-question.md.

## Q4: the OPS-41 outcomes sentence (01:565-566). SETTLED: Q4-ALT, 3–0

| Seat | r99 pick | r99b pick | Strongest argument |
|---|---|---|---|
| Astra (A) | KEEP | **Q4-ALT** | The subject "A no-call success or defer returned by that decision" attributes outcomes to another requirement. A new consequence doesn't remove the embedded attribution, as r93's replay sentence shows (r86b/Q1-A.md:70-71). ALT adds the decision's own "The short deferrals in steps 3 and 4 are not settlements" (03:1153). It cannot accept KEEP under the quotation convention. |
| Sol (B) | KEEP | **Q4-ALT** | QUOTE's "the claim MUST defer" is the restore claim gate (03:1025). ALT's extra quote reaches the ordered decision's own short deferrals (03:1153). It accepts KEEP and QUOTE. |
| Opus (C) | ALT | **Q4-ALT** | Same shape as r93's replay sentence, where no reader accepted KEEP (r93/tally.md:23, :25). QUOTE's only defer quotation sits before the fence transaction (03:1024) while the decision runs inside it (03:1099). Step 4's "The claim defers" is below the gate's four-word floor (tools/check_citations.py:109). r99's own wrong note shows the source claim is not idle (AGENTS.md:31-32). |

| Exact form | r99b picks | ACCEPT | CANNOT ACCEPT |
|---|---|---|---|
| Q4-ALT (`c12991b3…a318`) | astra, sol, opus | all three | none |
| Q4-QUOTE (`06392de5…d10d`) | none | all three | none |
| Q4-KEEP (`230d598c…44f4c3`) | none | sol | astra, opus |

No verified rule-3 blocking loss in Q4-ALT (all three). All three say ALT still doesn't quote step 1's own no-call success (03:1104-1105) and so is not exhaustive. It narrows nothing, because the operative clause stays broad. **Settled: Q4-ALT, 3–0.**

**Rule 6 on r99's Q4 note** (r99/brief.md:408, withdrawn at r99b/brief.md:170-184): all three seats now judge the error **premise-changing**. Astra and sol say so outright, and opus says so "for r99's Q4" and leaves the ruling to main. I accept that reading and withdraw my r99 view that the tally was not void. Under rule 6, r99's Q4 tally is void, and r99b's Q4 is the corrected re-ask. All three say this does not void r99b's ballot. Opus adds that its vote rests on the corrected sources and stands whichever way main rules. Either way the result is the same: Q4-ALT, 3–0.

## Q-REC: how the record carries the settled corrections. SETTLED: R-NOTE-ALT, 3–0

| Seat | r99 pick | r99b pick | Strongest argument |
|---|---|---|---|
| Astra (A) | R-NOTE | **R-NOTE-ALT** | R-NOTE names only "selected Qn-QUOTE.txt bytes", so it can't land Q4-ALT. ALT also separates the item-16 approval from the later corrections (Q1-A.md:63-65) and updates comment 856's "Executable form" line 6. |
| Sol (B) | R-NOTE | **R-NOTE-ALT** | Same three defects. Sol also reversed exactly ALT's comment-856 substitutions and got the pinned comment back. |
| Opus (C) | R-NOTE-ALT | **R-NOTE-ALT** | It verified all three defects: R-NOTE's owner label is false (item 16 adopted r86b at 3109b5b, owner-decisions-1030.md:132-133, and r93/tally.md:62 avoids "retroactively attributing the new words to the owner"); line 6 goes stale (r93 rewrote the same line, settled-pv-5pmu.md:11, :48); and R-NOTE has no bytes for an ALT. A/B's arguments rule out R-BRIEF and R-ARCHIVE, not R-NOTE-ALT. |

| Exact form | r99b picks | ACCEPT | CANNOT ACCEPT |
|---|---|---|---|
| R-NOTE-ALT (`23c4c1f8…a720`) + append R-NOTE-ALT-append.md (`445f69c2…02ea`) | astra, sol, opus | all three | none |
| R-NOTE (`6e6a167b…413b`) | none | opus | astra, sol (as the plan for an ALT settlement) |
| R-BRIEF (`33e383dd…ad40`) | none | none | all three |
| R-ARCHIVE (`15d02817…f635`) | none | none | all three |

No verified rule-3 blocking loss (all three; it only changes records). Opus: step (4) must land with the note, because `docs/research/panels-2026-10/r99/` doesn't exist at the pin and the note links there. **Settled: R-NOTE-ALT, 3–0, with its printed append.**

## Reader claims checked at the pin

- **Opus, brief error 1:** r99b/brief.md:243 says `:1113` places the restore gate "ahead of the decision". `03:1113` is "Step 1 and the restore claim gate above remain ahead of this decision", and it sits inside step 2 (step 2 begins at 03:1108). So "this decision" there is step 2's, not the whole ordered decision. **True.** The conclusion still holds on 03:1024 ("before the fence transaction above") and 03:1157 ("precedes this order"). My r99 tally's Q4 paragraph above has the same imprecision. Not premise-changing: no vote rests on it.
- **Opus, brief error 2:** r99b/brief.md:173 leaves "the landed 'that decision' spans both" standing as a reading. **True.** No vote rests on it.
- **Opus, brief error 3:** the r99b trial with the append (brief :262, :374) says nothing about the append, because check_citations reads only root `*.md` and `docs/adr/*.md` (tools/check_citations.py:642, :645). **True.** trial-alt.json: A-Q4ALT 365 compared, A-ALL 366, and the +1 is Q2-QUOTE's quote. r99's T2 has the same limit. The appended note's quotes are checked by no gate.
- **Opus, brief error 4:** brief :326 prints R-NOTE-ALT with "append exactly the block below", but forms/R-NOTE-ALT.txt contains no block. **True.** These are settled form bytes, so they stay. The brief binds the block to r99b/forms/R-NOTE-ALT-append.md at :329 with its hash. The settled package records both hashes and names that file as "the block below".
- **Opus, a limit (not an error):** the note's "Panel record: `../../r99/notes.md`" holds no selections, so a reader has to go on to the tally. **True.** The archive in step (4) must therefore include tally.md and the settled package next to notes.md.
- Opus: four-word floor at tools/check_citations.py:109; AGENTS.md:29 and :34; owner-decisions-1030.md:132-133 (item 16) and :209-210 (item 25); Q1-A.md:63-65. **All true.**
- Astra: DOM-10 at 01:547 and :566; Q1-A.md:63 and :70-71; owner item 25 at owner-decisions-1030.md:209-210. **All true.**
- Sol: API-64's quote at 04:1116-1117 matches only after whitespace normalization, because it crosses a line break; step 1's wording at 03:1104-1105; 03:1133 and :1153. **All true.**
- Opus's non-Nix gate runs on Q1-QUOTE + Q2-KEEP + Q4-ALT + R-NOTE-ALT (check_ids, check_obligations and check_coverage identical to the pin; check_citations 365) are its own scratch runs, not packet results. check_formal, check_fixtures and check_regions were not run by any reader.
- **No reader claim checked was found wrong.**

## New questions

None. Every seat says it opens no Q6. Q1, Q3 and Q5 stay closed.

## Result

- Settled: Q1-QUOTE (r99), Q3-KEEP (r99), Q5-KEEP (r99), **Q4-ALT (r99b)**, **Q-REC R-NOTE-ALT with its append (r99b)**.
- Split: **Q2**, QUOTE (astra, sol) against KEEP (opus). All three accept both, and none claims a blocking loss. It goes to the owner: r99b/owner-question.md.
- Missing: Fable (limit line), Grok (402).
- Nothing applied. The repo, pv-5pmu, PR #69, the tracker and every bead are untouched.
