# Panel R r97b: opus seat answer

**apply notes.md rule 6 exactly as written; this prompt adds no void rule.**

**Final: Q2d = Q-KEEP, Q2e = Q-KEEP, Q4 = L-NOTE**, with exactly `L-NOTE-append.md` and no note on the duplicate form.

I've changed my Q4 preference from r97 (L-BRIEF → L-NOTE); the reasons are under Q4. My Q2d/e picks are the same as in r97, now with more evidence.

## Acceptability of every exact form

| Question | Form | Verdict |
|---|---|---|
| Q2d | Q-KEEP | **ACCEPT**, first pick |
| Q2d | Q-POINTER | **ACCEPT** |
| Q2d | Q-QUOTE | **CANNOT ACCEPT** |
| Q2e | Q-KEEP | **ACCEPT**, first pick |
| Q2e | Q-POINTER | **ACCEPT** |
| Q2e | Q-QUOTE | **CANNOT ACCEPT** |
| Q4 | L-NOTE + exact `L-NOTE-append.md`, no duplicate-form note | **ACCEPT**, first pick |
| Q4 | L-BRIEF | **ACCEPT** |
| — | `authority-replacement.txt` | **ACCEPT** |

Why I reject Q-QUOTE (my own r97 reason, not a requested counterargument, and not a rule-3 blocking loss):
- The quoted literal-true sentence doesn't show "top-level", which is the only thing in the pointer that evidence would need to support.
- It sits after the allow-ordering clause, so it reads as WIR-17 being evidence for the account half.
- In Q2e, combined with the fixed Q2b quote, API-15 would contain the same WIR-17 MUST twice.

No reader picked Q-QUOTE first, so this changes no settlement.

## Q2d: PRV-10's first sentence

**For KEEP:** the sentence states PRV-10's own MUST. "`WIR-17`'s top-level `acknowledge_purchase`" names a field by its home, which is what AGENTS:34 asks for: "One rule, one home; everywhere else points at it." AGENTS:29–32 and :45–46 cover sentences "asserting what another requirement says", like "`WIR-30` forbids…", which describe another rule's normative content. This phrase doesn't describe WIR-17's rule. It points at it, and you can check it there: at M, WIR-17's create body has `"acknowledge_purchase": true` at the top level, next to `"provider_options": {}` (`13-wire-contract.md:673`), and its MUST is at 683–684. This argument doesn't depend on the wording being inherited or on a gate passing.

**For POINTER:** the explicit label makes the pointer's job harder to misread as a summary of WIR-17. That gain is real but small:
- POINTER still states "top-level" without attribution, so it is no easier to check than KEEP.
- "owner:" used as a label appears in no root spec file. I grepped all `0*.md`/`1*.md`, `CONTEXT.md` and `README.md` at M.
- `CONTEXT.md:20` lists "owner" among the words to avoid for the Operator. "wire owner" means something else, but it brings that word into a sentence about the operator's account setting.
- Item 24 approved the KEEP bytes exactly. Q-KEEP is a byte-exact prefix of C′'s PRV-10 block (checked). Changing approved wording with no compliance reason only widens the gap between the approved and executed text that the record then has to explain.

## Q2e: API-15's first sentence

**For KEEP:** this one already states ownership in words: "`WIR-17`'s top-level `acknowledge_purchase`, which the wire contract owns". That matches the spec's usual "`X` owns …" form (e.g. `04-api-contract.md:280` "`WIR-9a` owns `not_checked`"; `00-overview.md:448`).

**For POINTER:** it would make ownership explicit, but KEEP already does. POINTER swaps a spelled-out ownership clause for a label. In `04-api-contract.md`, the noun "owner" otherwise means the person behind a tenant (lines 200, 564, 620, 852). Q-KEEP is a byte-exact prefix of C′'s API-15 block.

Both KEEP forms keep:
- paid-create scope and the explicit acknowledgement;
- the top-level field, its wire owner and the account opt-in;
- what follows each sentence: C′'s PRV-10 continues with " Both, not either.", and API-15 keeps "in addition to".

OPS-43 quotes two PRV-10 phrases, "explicit purchase acknowledgement" and "the account is configured to allow ordering". Both still appear unchanged in every Q2d form.

**Why KEEP gives the panel the best chance of settling:** it is already the majority pick (Opus and Sol), every present reader accepts it, and it doesn't depart from the approved bytes at all.

## Q4: landing

**For L-BRIEF:** both archive copies keep their whole-file hashes. The receipt in `r89/check/tally/verification.json` (Cprime `be350270…`) stays literally true. So does the archive's `r89b/check/validate.py` assertion that the duplicate equals the original. I checked both.

**For L-NOTE, which I now prefer:**
- **It follows the project's landed precedent.** The r96 dated wording note was appended to `r83/check/settled-Q1-B.txt` (PR #66, cc953fc). It links `../../r96/notes.md`, the same notes.md convention this appendix uses. r96's receipts record both the original-prefix hash (`37db59ef…`) and the new whole-file hash (`f72d58f4…`), which is how that precedent handled the cost I raised in r97. I also picked L-NOTE in r94, where it settled 3–0.
- **The hash the authority line cites stays true.** It cites `r89b/form-Cprime.md` at `be350270…`, and L-NOTE leaves that copy untouched.
- **The appended copy keeps its original bytes.** They remain an exact prefix (checked); the new whole-file SHA would be `ebf5de10…`.
- **No gate is affected.** Every gate reads only root `*.md` and `docs/adr/*.md`, never `docs/research`.
- **It warns readers of the archived form.** That form says "**Retain verbatim** at their pinned bytes" (line 5). Followed literally at M, that would delete PR60's fixture. The note tells anyone reading that form that it is not the execution instruction.

**Costs that remain:** the r89 receipt's hash now describes only the prefix, and readers of the r89b copy don't see the note. The authority line already labels that copy historical.

**Appendix checked:**
- 695 bytes, SHA-256 `40480a93…`, starting with two LF bytes; the packet's copy is identical.
- Its quoted line "For such wording questions, try to solve by getting a consensus of the panel" appears exactly at `r89b/tally.md:11`.
- "Panel J" matches the heading of `r89b/owner-questions.md`.
- It doesn't quote the d/e wording, so it works with either Q2d/e outcome.

## Verification

- **Refs:** `origin/master` and `pv-9ecf` in `/home/user/projects/provisiond-spec` were still M when I started and when I finished, so the moved-ref stop doesn't apply. My clone is at M with no changes.
- **Packet:** `brief.md` and `notes.md` hashes match the manifest.
- **Candidate bytes:** every Q2d/e text in the brief matches its `Q2*.txt` file. Both Q-QUOTE payloads (67 B) are exact raw substrings of WIR-17 at M. 7116e90 is b278433's parent.
- **Wording-only:** for all three picks, behavior, requirements (item 4, item 24 and C′'s assertions) and check strength are all **WORDING-ONLY**. KEEP is C′'s approved bytes, unchanged. L-NOTE is an append to an archive file that no gate reads, and it adds no assertion, fixture, Lean statement or negative control.

## Rule 6

I found no brief error that changes a question's premise. Three non-blocking observations; I've repaired none of them:
1. At M there is no `docs/research/panels-2026-10/r97/`, so the appendix link only resolves if the same PR archives r97, which L-NOTE requires. It points to r97's rules file, following the same convention as the precedent.
2. The note is dated "2026-11-02, Panel R r97", but the d/e and Q4 choices are made in r97b on 2026-11-03. It is still accurate as the name of the panel.
3. `validate.py` runs against the external `/var/tmp/provisiond-panel-r89` paths, not the archive. In the archive it is a record, not something that gets rerun.

None of my votes depends on any of these.

I wrote scratch files only under `tmp/opus/` and made no source, Git, tracker or panel-record changes. I ran no gates or lake, and called no providers or subagents.

**Final: Q2d=Q-KEEP, Q2e=Q-KEEP, Q4=L-NOTE.** The other forms I accept are Q2d/e Q-POINTER and Q4 L-BRIEF; the ones I can't accept are Q2d/e Q-QUOTE.
