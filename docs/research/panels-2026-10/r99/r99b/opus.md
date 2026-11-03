Seat opus, r99b, pin `efb40cc55ff04be693473914afd42ef68008fa15`.

**apply notes.md rule 6 exactly as written; this prompt adds no void rule.**

| Question | Final pick | ACCEPT | CANNOT ACCEPT |
|---|---|---|---|
| Q2 | **Q2-KEEP** | Q2-KEEP, Q2-QUOTE | none |
| Q4 | **Q4-ALT** | Q4-ALT, Q4-QUOTE | Q4-KEEP |
| Q-REC | **R-NOTE-ALT** | R-NOTE-ALT, R-NOTE | R-BRIEF, R-ARCHIVE |

- **Blocking loss:** none under rule 3 in any pick. Each CANNOT ACCEPT is a conflict with `AGENTS.md` or with the record, not a blocking loss.
- **New forms:** I print no new ALT.
- **Change from my r99 pick:** I can't say directly. The seat map and this seat's r99 output are fenced, I didn't read them, and this session doesn't remember r99. Each section below says which reader my pick matches and why it would be a change.

## Q2: Q2-KEEP

**Against r99:** this matches Readers A and B. If this seat was Reader C, it is a change, for the reason below.

**Reason:** the sentence says when the retry checks `delete_machine`. `API-64` never mentions a capability check, so that claim has no `API-64` words to carry. "Its state-change/enqueue transaction" only identifies the boundary, which is a pointer under `AGENTS.md:34`: "One rule, one home; everywhere else points at it." I don't rely on r93 having left this clause alone: `r93/brief.md:231` set a scope limit and made no ruling.

**Q2-QUOTE: ACCEPT.**
- The quotation is verbatim at `04-api-contract.md:1116-1117`, and the landed bytes stay.
- r99's trial gives exit 0, and exit 1 when the quote is corrupted.
- The full stop does what the brief says, by `tools/check_citations.py:257`.

**Blocking loss:** none, because no bytes change.

**Answer to Reader C:** "state-change/enqueue" does appear in only one root requirement, `01-domain-model.md:547`. But it is built from `API-64`'s own words, "the state change, the enqueue" (`:1116`) and "both in one transaction" (`:1113`), so it can't point at a different transaction. The quotation does add a drift alarm, which is why I accept it. But it checks a side fact, adds an idempotency record the timing clause doesn't use, and has to stand as a separate sentence.

**Why Q4 differs:** Q2 names a boundary, while Q4 says what a named decision returns.

## Q4: Q4-ALT

**Against r99:** this matches Reader C. If this seat was Reader A or B, it is a change, because of the r93 precedent and the corrected sources below.

**Why quote at all:** the landed sentence has the same shape as r93's replay sentence.
- r93 replaced "A replay returned by API-7 step 5a never reaches this check" with a quotation followed by "a replay returned there never reaches this check."
- No reader accepted keeping it (`r93/tally.md:23`), and `r93/tally.md:25` says "The source facts being supported does not establish exemption from the quotation rule."

**Why ALT over QUOTE:** the sentence speaks of a defer "returned by that decision".
- QUOTE's only defer quotation is "the claim MUST defer" (`03-operation-lifecycle.md:1025`). That is the restore gate, which runs "before the fence transaction above" (`:1024`), while the decision runs "inside the fence transaction" (`:1099`).
- ALT adds the decision's own words, "The short deferrals in steps 3 and 4 are not settlements" (`:1153`).
- Step 4's "The claim defers" (`:1133`) can't replace them, because three words is below the gate's four-word floor (`tools/check_citations.py:109`).
- ALT still doesn't quote step 1 (`:1104-1105`). That leaves its evidence incomplete but doesn't narrow the rule, because the operative clause stays broad.

**Other options:**
- **Q4-QUOTE: ACCEPT.** Its words are real and only "A" becomes "a" in the landed sentence. Its defect is incomplete evidence.
- **Q4-KEEP: CANNOT ACCEPT.** It conflicts with `AGENTS.md:29`, "A claim about what another requirement says carries that requirement's own words", as r93 applied it to this shape.

**Blocking loss in Q4-ALT:** none.
- **Behaviour:** the rule is unchanged apart from "A" becoming "a".
- **Requirements:** the quoted MUSTs stay attributed to `OPS-41`, and `check_obligations` output is identical to the pin's.
- **Check strength:** it only rises. With Q1-QUOTE, compared quotes go from 360 to 365, and corrupting the new quote gives exit 1 naming `OPS-41`. No Lean, CNF or fixture changes.

**Answer to Readers A and B:** both say the operative rule is `DOM-10`'s and the sentence doesn't restate trigger conditions. That is true, but it was equally true of r93's replay sentence, and no reader accepted KEEP there. ALT also keeps the predicate outside the quotation, as they want.

The source claim isn't idle either. r99's own brief got it wrong: "the defer comes from OPS-41's restore claim gate, not its fence-transaction decision". That is the failure `AGENTS.md:31-32` warns about.

**Rule 6:** I read that note as premise-changing for r99's Q4, because it misstated the fact in dispute. Main decides. My vote rests on the corrected sources, so it stands whichever way main rules.

## Q-REC: R-NOTE-ALT

**Against r99:** this matches Reader C. If this seat was Reader A or B, it is a change, because I verified all three defects below and R-NOTE-ALT is now printed for every reader.

**Reason:** I checked Reader C's three defects, and all three hold.
1. **False owner label.** R-NOTE says "The text above, with the 2026-10-31 Panel N r93 correction, is retained as the historical form approved in owner item 16". Item 16 adopted the r86b form at pin `3109b5b` (`owner-decisions-1030.md:132-133`), and r93's words came later under the wording rule (`Q1-A.md:63-65`). `r93/tally.md:62` explicitly avoids "retroactively attributing the new words to the owner".
2. **Stale authority line.** Comment 856's line 6 would still end "with the 2026-10-31 Panel N r93 wording correction." while its block carries r99's changes too. r93's package rewrote this same line (`settled-pv-5pmu.md:11`, `:48`).
3. **No bytes for an ALT.** "Its selected Qn-QUOTE.txt bytes" can't carry Q4-ALT.

**Other options:**
- **R-NOTE: ACCEPT.** It follows the right precedent and only touches records, and `Q1-A.md:63` directly above it keeps the true label. It can't carry a settled Q4-ALT as written.
- **R-BRIEF: CANNOT ACCEPT.** `Q1-A.md:64-65` says the Agent Brief "uses the following replacements" and "all other Q1-A text is retained", which would become false with no correction there. The owner also rejected "Change the brief only" in the comparable item 25 (`owner-decisions-1030.md:209-210`).
- **R-ARCHIVE: CANNOT ACCEPT.** Line 6 says "Executable form: the Desired behavior / key interfaces block below", and that block would no longer match the landed text. Neither the comment nor `Q1-A.md` would point at r99. The bead is closed at the pin, which is this option's best argument, but closing it doesn't make line 6 true.

**Blocking loss in R-NOTE-ALT:** none, because it only changes records. Step (4) must land with it: `docs/research/panels-2026-10/r99/` doesn't exist at the pin, and the note links there.

**Answer to Readers A and B:** synchronizing the brief, keeping the archive bytes and adding a dated route from the historical form are all equally true of R-NOTE-ALT. Those arguments rule out R-BRIEF and R-ARCHIVE, but they don't separate R-NOTE from R-NOTE-ALT. R-NOTE's only remaining advantage is one less edit, and r93 made that same edit.

## Brief errors

None changes a premise of Q2, Q4 or Q-REC.

1. **`r99b/brief.md:243`, the `:1113` citation.** It says `:1113` places the restore gate "ahead of the decision". The source says "Step 1 and the restore claim gate above remain ahead of this decision", and step 1 is itself part of the ordered decision, so "this decision" there means step 2's. The conclusion still holds on `:1024`, `:1099` and `:1157` ("precedes this order"). Reader C's §5 argument uses the same citation (`brief.md:583`).
2. **`r99b/brief.md:173`, a claim left standing.** The correction doesn't withdraw "the landed "that decision" spans both". That is a reading, not a fact: the singular follows "ordered fence-transaction decision", and `01-domain-model.md:566` continues "A decision that proceeds to cancellation". It affects how far QUOTE's defer quotation supports the sentence, but no bytes change and no vote of mine rests on it.
3. **`r99b/brief.md:262` and `:374`, the trial on the appended note.** The exit 0 is true but says nothing about the append, because the gate reads only root `*.md` and `docs/adr/*.md` (`tools/check_citations.py:642`, `:645`). The count confirms it: 366 = 360 + 2 + 1 + 3. r99's T2 has the same limit.
4. **`r99b/brief.md:326`, "the block below".** `forms/R-NOTE-ALT.txt` contains no block. The separate append file and its printed hash resolve this, so the tally should record both hashes.

One limit in both note forms, which is not a brief error: "the exact replacements selected in the panel record below" links to `../../r99/notes.md`, and that file holds no selections. Readers have to go on to the tally from there, whereas r93's note printed its replacements inline.

## What I checked

- **Hashes:** `brief.md`, `notes.md`, every `forms.sha256` entry and the three r99b form files all match.
- **Sources:** every quotation and citation I rely on was read at the pin, and comment 856 decodes byte-equal to the evidence file.
- **Comment 856 edit:** I tried it at byte level on scratch copies. Each span occurs once, only the comment text changes, and the note leaves the original bytes as an exact prefix.
- **Gates on my exact combination:** I ran the non-Nix gates on Q1-QUOTE + Q2-KEEP + Q4-ALT + R-NOTE-ALT, which no trial had covered.

| Gate | Result on my combination |
|---|---|
| `check_ids`, `check_obligations`, `check_coverage` | exit 0, output identical to the pin |
| `check_citations` | exit 0, 365 compared (360 at the pin), none new |
| `check_citations`, with Q4-QUOTE instead of Q4-ALT | exit 0, 364 compared |

**Not run or verified:**
- `check_formal`, `check_fixtures` and `check_regions` weren't run, because they need the Nix shell, which notes.md forbids. `DOM-10` has no `@[req "DOM-10"]` tag or nearby formal region, so I expect `check_formal` and `check_regions` to be unaffected, but that is inference. I have no evidence for `check_fixtures`. The apply turn must run the full `check-all.sh`.
- §5's "byte for byte" claim is unverified, because the originals are fenced.

**Fences:** I read no fenced file, the clone is clean at the pin, and scratch stayed in `r99b/tmp/opus`.
