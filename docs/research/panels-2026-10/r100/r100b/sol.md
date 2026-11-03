Seat **sol**, reviewed pin `2cb8e1189310ae096e598bac798df3437be59500`.

**Final picks: Q1-ALT and R-NOTE.** These are the printed forms, without further changes.

| Question | Option | Acceptance |
|---|---|---|
| Q1 | **Q1-ALT** | **ACCEPT — final pick** |
| Q1 | Q1-QUOTE | **CANNOT ACCEPT:** the original assertion remains a separate sentence without its quotation. |
| Q1 | Q1-KEEP | **CANNOT ACCEPT:** retains that unsupported assertion without adding the source words. |
| Q-ROUTE | **R-NOTE** | **ACCEPT — final pick** |
| Q-ROUTE | R-RUN | **ACCEPT:** sufficient to carry the replacements and preserve the owner’s routing decision. |

The permitted packet anonymizes the prior ballots, so I cannot verify which was Sol’s without crossing the fence. For change tracking: my Q1 pick retains Readers A/B’s pick and changes Reader C’s; my route retains Readers A/C’s pick and changes Reader B’s.

**Q1 — Q1-ALT.** Use the exact printed replacement for `docs/research/panels-2026-10/r86/r86b/Q2-A-cited.md:62–63` (comment 857:88–89), SHA-256 `97035ff0c6bbfae893123db51d53b03bad68e512a47415554d3cf5350fe43816`.

[AGENTS.md:45](/var/tmp/provisiond-panel-r100/r100b/sol/AGENTS.md:45) requires “every sentence asserting what another requirement says carries its quote”. QUOTE leaves the original assertion outside the sentence carrying the quotations. ALT’s semicolon joins them without changing the asserted timing or exception.

Reader C’s strongest argument supports supplying the quotations: the existing exception paragraph already quotes the relevant steps, and the new sentence reports their behavior. I agree. ALT retains every quotation in QUOTE while also meeting the sentence-level completion instruction. The gate’s identical treatment of QUOTE and ALT does not establish identical editorial compliance.

I independently matched ALT’s quotations to the adopted step 5 and pinned step 4. The verified QUOTE-to-ALT difference is exactly one byte: `.` becomes `;`.

**Wording-only under rule 3: yes.** No behavior, normative obligation, conformance assertion, declaration, proof statement, guard hypothesis, fixture, or existing negative-control strength changes. Citation coverage increases: ALT makes the same additional textual comparisons as QUOTE. That increase is disclosed; it does not change the substantive verdict being specified. **Verified blocking loss: none.** My CANNOT ACCEPT judgments are editorial defects, not rule-3 losses.

**Q-ROUTE — R-NOTE.** This applies under the already-settled changed forms. Use the printed R-NOTE, SHA-256 `d50de4177d3aa9c689d1bc4e6f1ff7cd6fbb08831ae8fd5702484ce3efff43a7`, with the exact printed appendix.

Reader B’s strongest argument is correct: R-RUN is sufficient. Owner item 26 explicitly says “Comment 857 is not edited” and “No preparation commit”. R-NOTE preserves both. I prefer its forward pointer because comment 857 still identifies Q2-A-cited.md as the “Adopted exact form”; readers following that reference should be able to discover the later replacements there. Owner item 25’s “Add dated archive note” decision and the pinned archive-note precedents support this preference.

I accept the “in addition” clause as the explicit exception to R-RUN’s inherited file-nonediting language. The exact-prefix condition makes the intended operation concrete. I verified that the prospective artifact equals the pinned adopted bytes followed by exactly `R-NOTE-append.md`. The appendix also states, “This note grants no independent authority to change a requirement”.

**Wording-only: yes.** The route changes recordkeeping and instructions, with no behavior, requirement, substantive check, or negative-control strength change. **Verified blocking loss: none.** Q5’s settled KEEP means the Run carries `check/F-QUOTE.txt`.

**Comment 857 stays unedited under my R-NOTE pick.**

**Rule 6:** I verified the inherited wording inconsistency at `r100b/brief.md:217` and `:223`: R-NOTE inherits “Q2-A-cited.md are not edited” while expressly appending to that file. It is already disclosed at `:255–259`; the specific append instruction resolves it. It changes no question’s premise, and neither my vote nor the quoted route preferences depends on denying the append. I found no new premise-changing brief error. **No tally is voided on my findings.**

I verified the form hashes and trial-diff hashes, then reproduced the citation comparisons in memory using pinned checker code. QUOTE and ALT each produced 369 Markdown and 146 Lean comparisons; the supplied corruption produced exactly the expected new Q1 failure. Erasing only Lean docstring bodies left the candidate declarations and proofs identical to the pin. This was targeted verification, not a full gate run. No prohibited tools, edits, or subagents were used. Q2–Q7 remain closed; no Q8 is opened.