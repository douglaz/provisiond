**Result: one conditional conflict found.** It's in the settlement instructions and only matters if a reader verifies a premise-changing error. I found no other conflict in the scope, the exact forms, the landing instructions or the required answers.

**Conflicting passages**
- `notes.md:30` (rule 6): "A verified brief error that changes the question's premise voids its tally; re-ask it corrected."
- `brief.md:13` and `notes.md:33`: "apply notes.md rule 6 exactly as written; this prompt adds no void rule". Also `brief.md:88`: "Report any premise-changing error under rule 6 exactly."
- `notes.md:4–5`: "r87b consumes the one consensus round; a remaining tie/no settlement goes to main/the owner. Do not launch r87c."
- `notes.md:28` (rule 4): "Never more than one consensus round for this question."

**The conflict:** suppose an r87b reader verifies a premise-changing error. Applying rule 6 "exactly as written" then voids r87b's tally and requires a corrected re-ask. That re-ask would be another panel round, which "Do not launch r87c" and rule 4 forbid. `notes.md:16–18` explicitly reconciles rule 4's launch-only sentence with this launch, but nothing reconciles rule 6's re-ask.

**Minimum repair:** add one sentence to the `notes.md` preamble, after "Do not launch r87c.", outside the verbatim rules:
> "If rule 6 voids r87b's tally, the corrected question goes to main/the owner with the void reason; that is not a further panel round."

This doesn't change when rule 6 voids a tally, so "this prompt adds no void rule" still holds. The opposite choice, allowing a corrected rerun, also removes the conflict. It would override two explicit statements, though, so it's the larger change. Main or the owner chooses between them.

**Checked and found consistent:**
- **Answer labels:** rule 1 asks for ACCEPT / CANNOT ACCEPT on A and B only. The brief asks for three answer values on all six forms. `brief.md:76` ("Conditional acceptance does not count for the printed form") turns the extra value into non-acceptance, and that can't change a rule-2 result.
- **Brief on stdin:** `notes.md:38–40` says each reader "receives the complete common brief on stdin", and every unit has `StandardInput=null`. Both hold only if the unit's command feeds the brief to the reader itself (`sh -c '… < brief.md'`). Using `StandardInput=file:` instead would break the null setting. This is a launch detail.
- **Grok:** `notes.md:8–10` and rule 5 agree. A fresh probe returning 402 means the three-of-four fallback. A prelaunch "Not signed in" still stops the launch.
- **F's own note:** its frozen closing line says "The only difference from A is the diagnostic field". That's looser than `brief.md:60–61`, since F makes two changes inside that sentence. It's frozen candidate prose, though, and F's header ("except the diagnostic sentence") is accurate.
- **Tallies:** the r87 preference and acceptability tallies at `brief.md:24–27` match the four verbatim answers.
- **F and O against A:** the differences are exactly the ones stated in disagreement 4.
- **Landing:** the sites and indentation fit every form's internal "above" and "below" references, and B's OVR-19 row placement matches.
