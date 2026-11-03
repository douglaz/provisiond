# Panel r100b: seat opus

I reviewed the pin `2cb8e1189310ae096e598bac798df3437be59500`. My clone is clean and still detached there. I applied notes.md rule 6 exactly as written; this prompt adds no void rule.

| Question | Final pick | ACCEPT | CANNOT ACCEPT |
|---|---|---|---|
| Q1 | **Q1-ALT** (`97035ff0…`) | Q1-ALT, Q1-QUOTE | Q1-KEEP |
| Q-ROUTE | **R-NOTE** (`d50de417…`) | R-NOTE, R-RUN | none |

**Comment 857 stays unedited under my R-NOTE pick.** My one CANNOT ACCEPT is an editorial judgment. It is not a rule-3 blocking loss.

## Q1: Q1-ALT

**1. Pick: Q1-ALT, the printed label.** It replaces `Q2-A-cited.md:62-63` (comment 857:88-89) exactly as printed in §3.

- **Does it change my r100 pick?** I can't confirm from this seat. notes.md fences my r100 output, and §6 carries no names.
- I pick ALT on its merits. If Reader C's answer was mine, this is a change: ALT wasn't printed then, and every reason C gave also holds for ALT (see point 4).

**Why ALT over QUOTE:**
- **The completion rule is per sentence.** `AGENTS.md:45` says "every sentence asserting what another requirement says carries its quote".
  - QUOTE's first sentence states what `OPS-43` steps 4 and 5 do: "runs on step 4's current List offers result, after that read and before any provider mutation". That sentence carries no quote; the quotes sit in the next sentence.
  - ALT makes the claim and its quotes one sentence.
- **The checker's unit is the sentence too.** `chunks()` in `tools/check_citations.py` splits at `.`, `!` and `?`, not at `;`.
  - I ran a scratch probe of the pinned checker. QUOTE yields two chunks, and the claim's chunk holds no quotation.
  - ALT yields one chunk holding the claim and all three compared quotations.
- **The semicolon shape is `OPS-43`'s own idiom.** It appears at `03-operation-lifecycle.md:790`, `:819` and `:824` ("…; OPS-11 says "…"") and at `:816` ("…; API-58 says").

**2. Acceptance**
- **Q1-ALT: ACCEPT.**
- **Q1-QUOTE: ACCEPT.** It carries the same three quotations and gets the same gate verdicts.
  - The separate-sentence shape is already landed elsewhere: `03:872` has "The operation settles `failed` under the create row. `OPS-11` says "…"".
  - Its only shortfall is the letter of `AGENTS.md:45`, which ALT fixes with one byte. That is a preference, not a block.
- **Q1-KEEP: CANNOT ACCEPT.** "it runs on step 4's current List offers result, after that read and before any provider mutation" states what `OPS-43` steps 4 and 5 say, and it carries none of their words.
  - `AGENTS.md:29-30` says "A claim about what another requirement says carries that requirement's own words."
  - KEEP's own-exception case covers "uses the same exception", but it does not cover the timing half.
  - The paragraph the insert extends quotes steps 4 and 5 for the same kind of claim (`03:2076-2079`).
  - This is editorial; it is not a rule-3 loss.

**3. Is it wording-only (rule 3)? Yes, and I found no verified blocking loss.**
- **Behavior:** unchanged. The adopted words stay. One `.` becomes `;`, followed by a clause quoting existing and adopted text. The exception's scope and timing are identical.
- **Requirement:** no MUST or SHOULD is added or dropped.
- **Check strength:** no declaration, theorem, guard hypothesis, fixture, conformance assertion or negative-control step changes.
- **Citation gate:** it gains three comparisons on new text. The r100b trial shows Markdown comparisons going from 366 to 369, Lean QUOTED comparisons unchanged at 146, and 22 unquoted attributions, none new.
- **Disclosed limit:** "before any provider mutation" also occurs in `OPS-43` at `03:870`. The gate would catch that quote being corrupted, but not its removal from step 5. QUOTE has the same limit.

**Verification**
- All form, brief and prospective-file hashes match.
- `Q1-QUOTE.txt` and `Q1-ALT.txt` differ in exactly one byte, at offset 172 (`.` becomes `;`).
- Readers A's and B's printed ALTs in §6 are both byte-equal to `Q1-ALT.txt`.
- The QUOTE and ALT trial diffs differ only in that line.
- The trial log figures match the packet (369/146/22, and N-S-Q1ALT fails with "FAIL: 1 unverifiable quoted attribution(s)").
- In my probe, uncorrupted ALT added 0 new findings and 3 comparisons. Corrupting each of ALT's three quotations in turn gave 1 new unverifiable attribution each time.
- The probe used scratch copies of the pinned Markdown with only the new step 5 and the insert applied. It is not a full gate run.

**4. Answer to the other side's strongest argument (Reader C, for QUOTE)**
- **"The paragraph this insert extends carries `OPS-43`'s words" (`03:2076-2079`).** True, and it supports ALT better. That paragraph keeps its quotes inside the asserting sentence: "…at `OPS-43`'s step 5, "Check for the named offer's absence from that result", are exceptions…: they run on the result of `OPS-43`'s step 4, "Obtain the current driver List offers result", after that read." QUOTE moves the quotes into a separate sentence; ALT keeps them in the claim's sentence.
- **"The shape r99 settled QUOTE 3–0 (`PRV-25`)."** r99's settled Q1-QUOTE (`/var/tmp/provisiond-panel-r99/Q1-QUOTE.txt`, `4c0cbff…`) landed at `01-domain-model.md:575` as one sentence: "`PRV-25` says "…" and "…"; that identical-PTR success remains after its capability check." The quotation and the claim are joined by a semicolon. That is ALT's shape, not QUOTE's.
- **The "Limit"** (the step-5 phrase also appearing at `03:870`) applies equally to both forms.
- Nothing C wrote favors the separate sentence.

## Q-ROUTE: R-NOTE

**1. Pick: R-NOTE.** Q-ROUTE applies because Q2-QUOTE, Q3-QUOTE, Q4-KEEP, Q6-QUOTE and the Q1 pick all change bytes. With Q5 on KEEP, the `PRV-10` form is `check/F-QUOTE.txt` (`2393f71e…`). Whether it changes my r100 pick: same caveat as Q1.

**Why R-NOTE:**
- **Comment 857 still points readers to the old bytes.** Its line 6 reads: "Adopted exact form: `docs/research/panels-2026-10/r86/r86b/Q2-A-cited.md`".
  - Item 26 keeps comment 857 unedited, so that file is where a reader following the brief lands.
  - Under R-RUN, that file shows spans the Run will not land, and nothing there or in comment 857 points to r100. The note is the only forward pointer available.
- **The owner already made this choice in item 25:** "Add dated archive note (Recommended)" was chosen and "Change the brief only" was rejected. R-RUN corresponds to the rejected option.
- **The note's shape is landed.** It matches `r86b/Q1-A.md:61` and `:86` and `r83b/Q4-D.md:100` and `:127`, including the `../../rNN/notes.md` pointer form.
- **Checked:**
  - The pinned file ends with "```\n\n".
  - The pinned bytes followed by `R-NOTE-append.md` hash to `0e665520…`, the prospective file.
  - From `r86/r86b`, `../../r100/notes.md` resolves to where R-RUN's archive puts the record.

**2. Acceptance**
- **R-NOTE: ACCEPT.**
  - R-NOTE's opening "Exactly as R-RUN" literally imports R-RUN's "Q2-A-cited.md are not edited". I read the more specific clause, "in addition the Run appends exactly R-NOTE-append.md … all original bytes remaining an exact prefix", as the exception. "Not edited" then means the original bytes don't change, which the note says of itself ("its original bytes remain unchanged").
  - The prefix condition can be checked mechanically, so the bytes the Run must produce are unambiguous.
  - I don't print an ALT: a new label in the only consensus round would split the pick over a wrinkle whose result is already fixed.
- **R-RUN: ACCEPT.** It carries the same authority and keeps item 26. It just leaves the stale pointer in place.

**3. Is it wording-only? Yes, and I found no blocking loss.**
- R-NOTE touches records only. No file under `tools/` or `.github/` mentions `docs/research` (a `git grep` at the pin finds nothing).
- The citation checker reads only root `*.md` and `docs/adr/*.md` (`check_citations.py:642-645`).
- The requirement edits are exactly the settled forms, which R-RUN also carries.
- The note grants no authority: "This note grants no independent authority to change a requirement".

**4. Answer to the other side's strongest argument (Reader B, for R-RUN).** B says item 26 adopts "Comment 857 is not edited" and "No preparation commit", and R-RUN preserves both.
- R-NOTE preserves both too. The append is a Run step, there is no preparation commit, and comment 857 is untouched. B verified this and accepts R-NOTE, so item 26 doesn't separate the two forms.
- B also calls R-RUN "sufficient". It is sufficient for authority. It is not sufficient for a reader who starts from comment 857 line 6, which is the case item 25 decided.

## Brief errors (rule 6)

I found none in the r100b packet that changes a premise, so no question is voided.

- r100's brief slices at lines 424-490 and 874-922 each occur byte-for-byte exactly once in the r100b brief.
- §4 items 1–3 check out at r100 `brief.md:70`, `:262` and `:818`, and in the R-NOTE text.
- The cited `owner-decisions-1030.md:226-228` and r98 `brief.md:201–203` match.
- **A factual note, not a brief error** (the packet makes no claim about it): Reader C's precedent "the shape r99 settled" is in fact the one-sentence semicolon shape (`01-domain-model.md:575`). C's Q1 reason partly rests on it, but it does not touch Q1's premise.

## Process

- Read only. I used no Nix, lake, `check-all.sh`, br, Git mutation or subagents. I did not run `trial_b.py` (it reads `/home/user/projects/provisiond-spec`).
- I read no fenced file and no reader output. Outside the packet I read r99's `Q1-QUOTE.txt` (owner item 27 cites its hash) and `r99b/forms/R-NOTE-ALT*.txt` (the brief cites that path). Both are form files, not reader outputs.
- Scratch is only in `r100b/tmp/opus` (4.6M: pinned Markdown copies, the pinned `check_citations.py` and `check_obligations.py`, and the probe script).
