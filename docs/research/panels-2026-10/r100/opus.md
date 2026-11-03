# Panel r100: opus reader answer

Rule applied: **apply notes.md rule 6 exactly as written; this prompt adds no void rule.** I found no brief error that voids a question; the three I verified are listed at the end.

| Question | Final pick | ACCEPT | CANNOT ACCEPT |
|---|---|---|---|
| Q1 | **Q1-QUOTE** | Q1-QUOTE | Q1-KEEP |
| Q2 | **Q2-QUOTE** | Q2-QUOTE | Q2-KEEP |
| Q3 | **Q3-QUOTE** | Q3-QUOTE, Q3-KEEP | none |
| Q4 | **Q4-KEEP** | Q4-KEEP, Q4-QUOTE | Q4-ASIS |
| Q5 | **Q5-KEEP** | Q5-KEEP, Q5-QUOTE | none |
| Q6 | **Q6-QUOTE** | Q6-QUOTE, Q6-KEEP | none |
| Q7 | **Q7-KEEP** | Q7-KEEP, Q7-QUOTE | none |
| Q-ROUTE | **R-NOTE** | R-NOTE, R-RUN | none |
| Q8 | not opened | n/a | n/a |

Each CANNOT ACCEPT above is a rule conflict or a formatting defect. None is a rule 3 blocking loss, because none changes a checked verdict, and I quote no MUST or SHOULD against those forms.

**Comment 857 stays unedited under R-NOTE.**

## Q1: the `OPS-23` insert

- **Pick:** Q1-QUOTE.
- **Wording-only:** yes. It adds one sentence of quotation, and no rule, declaration or fixture changes. It adds three gate comparisons and weakens nothing.
- **Strongest reason:** the paragraph this insert extends carries `OPS-43`'s words for this same kind of claim, and the insert says it "uses the same exception" (`03-operation-lifecycle.md:2076-2079`).
  - "it runs on step 4's current List offers result, after that read and before any provider mutation" states what two `OPS-43` steps do. That is `AGENTS.md:29-30` directly.
  - It is also the shape r99 settled QUOTE 3–0 (`PRV-25`'s ordering and outcome).
- **Limit:** "before any provider mutation" also appears at `03:870`, so the gate would catch a corrupted quote but not its removal from step 5. The other two quotations carry the claim.
- **Why not KEEP:** the first half of the sentence is `OPS-23`'s own exception, but the second half is not.

## Q2: `Admission.lean:317-319`

- **Pick:** Q2-QUOTE.
- **Wording-only:** yes. It changes a docstring only, with no declaration, proof statement or guard hypothesis touched.
- **Open objection:** astra and sol's objection stays on record, neither resolved nor worsened. r86b `opus.md:102` called the adopted docstring edit a semantic narrowing, but that belongs to the owner-adopted text, not to this addition.
- **Strongest reason:** the two neighbouring guard entries each carry their rule's words (`Admission.lean:312-315`, `:321-323`). The pinned line 318 does too.
  - The old words must go, because the Run removes them from `API-7`. The choice is whether to replace them with new words or with a paraphrase.
  - The KEEP case calls this a model summary, but "step 5d gates a create…" speaks about `API-7`. Only "Off, …" speaks about the model.
  - Under KEEP this entry would have no checked tie to `API-7`.

## Q3: `Admission.lean:1181-1182`

- **Pick:** Q3-QUOTE.
- **Wording-only:** yes. It changes a docstring only.
- **Strongest reason:** "step 5d takes no gate" is a claim about `API-7`, and it sits on the clause that decides what `orderingDeclared` means for an absent offer (r86b `brief.md:1591`). The `true` convention depends on that sentence, so if `API-7` changes it, the EXISTS rule will now report it.
- **Reader note:** the parenthetical comes after "supplied `true`" but supports only the step-5d half. The sentence already says which half is which, so it doesn't mislead. I accept KEEP because the clause is partly a model convention.

## Q4: the 05 `request_summary` row

- **Pick:** Q4-KEEP.
- **Wording-only:** yes. One newline becomes one space, with every word unchanged. r86b `fable.md:59` already said it "must be joined on landing, a formatting matter".
- **Strongest reason:** the clause is the row's own field definition naming its source, the "Cite the owner" pointer shape (`AGENTS.md:34`).
  - The owner kept this shape in item 27, and the same row points the same way elsewhere ("(`OPS-13`)", `05-persistence.md:523`).
  - QUOTE is true and checkable, but it puts a 20-word quote inside nested parentheses in a 1982-character table row, and it adds little.
- **Why not ASIS:** the first half of the row would end at "copied from the" with no closing pipe. The stray second line would start without a pipe but end with one (my check of `trial-T-ASIS.diff`). The persistence table's definition would be cut mid-sentence. It passes the gates I could run, but it's a real defect.

## Q5: `OPS-43` step 3 admission clause

- **Pick:** Q5-KEEP.
- **Wording-only:** yes, with no byte change.
- **Strongest reason:** this clause carries out a landed duty, so it isn't a report about another requirement. `OPS-23` says "A release that adds a required field MUST state whether the caller supplies it or the `api` writes it at admission" (`03:2072-2074`). The brief's KEEP case doesn't cite this sentence.
- **Cost of QUOTE:** it would also replace the F-QUOTE bytes the owner recorded by SHA in item 26 with F-QUOTE-Q5, nesting an `API-7` quotation inside `PRV-10`'s quotation of step 3. It passes the gate and I accept it, but nothing here justifies that change.

## Q6: `OPS-43` step 5 settlement clause

- **Pick:** Q6-QUOTE.
- **Wording-only:** yes. Both quotations are `OPS-11`'s existing text (`03:249`), and no obligation changes.
- **Strongest reason:** the landed settlement paragraph covers only "If the offer is absent from that result or the re-test finds it unsellable" (`03:869`).
  - The adopted text doesn't extend that paragraph to the new kind-mismatch branch.
  - For a kind mismatch, this clause is the only statement of the release, and adopted step 5 never names `OPS-11`.
  - So "the same existing" settlement isn't a pointer to an owner, and QUOTE supplies that owner.
- **Counterweight:** for an absent offer, `03:872-884` already carries the words, which is why I accept KEEP. See brief error 1.

## Q7: the `CNF-19` directive

- **Pick:** Q7-KEEP.
- **Wording-only:** yes, with no byte change.
- **Strongest reason:** this is the checklist's standing way to reuse another item's case. For example, "`CNF-279`'s pinned-key abort" (`10-conformance-checklist.md:3184`), "`CNF-277`'s outage fixtures" (`:3045`) and "`CNF-362`'s later-stop assertions" (`:1801`). "pre-List-offers" only says which of `CNF-55`'s two refusals is meant.
- **Weakness in QUOTE:** its words support "step 3", while the words matching "pre-List-offers" are "no List offers read" (`:373-374`). It's true and gate-checked, so I accept it, but it doesn't quote the word in question.

## Q-ROUTE

- **Pick:** R-NOTE. It applies because Q4-KEEP and the QUOTE forms change bytes.
- **Wording-only:** yes. It touches records only. No gate reads `docs/research/` (no match in `tools/` or `.github/`), and my rerun of T-KEEP, T-ALL and the QUOTE trials used no note.
- **Strongest reason:** comment 857 line 6 still sends readers to Q2-A-cited.md as the "Adopted exact form", and the Run will land different bytes. Since item 26 keeps the comment unedited, a dated note in that file is the only forward pointer at the place readers land.
  - It matches the owner's choice in item 25 ("Add dated archive note").
  - It matches the `Q1-A.md:61` and `:86` and `Q4-D.md:100` and `:127` precedents, including their `../../rNN/notes.md` pointer shape. `r99/notes.md` exists at the pin.
  - It adds no preparation commit, so item 26 holds.

## Q8

Not opened. I agree with the "considered and not listed" reading. The closest case is `Q2-A-cited.md:102`, "`OPS-23`'s incomplete_record result". It names a result in the owner's own term (`03:2052`) and makes no further claim.

## Verification

- **Forms and sources:** form hashes, spans and line maps match, and comment 857 is byte-equal to the beads text at the pin. Each `Qn-OLD` occurs exactly once in both the adopted text and comment 857, and the note preserves the original bytes as an exact prefix.
- **Citation trial rerun:** I reran it in scratch and every comparison count in §9 reproduces. My diffs for T-ASIS, T-KEEP, T-ALL, T-Q5 and T-Q6 are byte-equal to the packet's.
- **Stub index:** the real lake index is in a fenced directory, so I used an empty one. NAMES therefore fails with 49 unresolved names at T0, and my rerun's citation exit is 1 on every trial. T-ALL's only differences from T0 are the counts, so NAMES adds nothing new there. I read the single-form trials by their counts rather than diffing each log.
- **Later quotations:** the packet's controls corrupt only each first quotation. I also corrupted Q1's second and third and Q2's and Q6's second, and each one fails the gate.
- **Other gates:** `check_ids`, `check_obligations` and `check_coverage` exit 0 on every applied trial, with logs identical to T0 on T-ASIS and T-ALL.
- **Not run:** `check_fixtures` (it needs `markdown_it` under Nix), Lean and `check_regions`, all fenced. So no full candidate gate exists yet, and the Run must produce one. No Markdown region cites the two touched declarations.

## Brief errors (rule 6)

None of these changes a question's premise, and none voids a tally.

1. **Q6: "the same release claim" and "a third copy".** Steps 1 and 8 (`03:790`, `:819`) quote only the commitment half. `OPS-11`'s exclusion sentence appears only at `03:249`. The brief also omits `03:869-884`, `OPS-43`'s own settlement paragraph for an absent or unsellable offer. The question and forms still stand, and my vote doesn't rest on this. A vote reasoning that steps 1 and 8 already quote the whole claim would rest on it.
2. **§2 "scans":** the gate reads `docs/adr/*.md` as sources, not as QUOTED input (`tools/check_citations.py:32`). `docs/research/` stays out either way.
3. **R-NOTE form text:** "Exactly as R-RUN" literally inherits R-RUN's "Q2-A-cited.md are not edited". The "in addition" clause and the prefix condition resolve it, so this is harmless but worth reading carefully.

The clone is clean and still at the pin. My only writes are under `tmp/opus` (124M, including three trial clones).
