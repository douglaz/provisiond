# r68 notes (panel E confirmation round: pv-tcs, pv-ytv): outcome rules, set BEFORE the brief. 2026-10-25

Master `c5f897c`. Clones at `c5f897c`. One shared brief, docs/research/panels-2026-10/r67/r68/brief.md, with no seats.
Input: docs/research/panels-2026-10/r67/tally.md, "What r68 reads". Outcome (b) for both r67 questions; this round
reads exact texts and decides what goes to the owner as the one two-part question from r67/notes.md:
(a) Q1, F-final vs S-final; (b) Q2, "apply K-final?".

Forms read: **Q1 S-final** (Reader 4's S text), **Q1 F-final** (Reader 2's F text + Reader 4's `PRV-40` span +
an `OPS-1` span drafted by the coordinator, marked unreviewed), **Q2 K-final** (Reader 4's K text, with the
`CNF-278` step-8 fix). Every other r67 reader text is an option, with its author label, stated neutrally.

## Settled by r67 (not re-voted)

- Form N is out of Q2: 0 picks of 4, and a verified `PRV-26` loss (02:895-897). A reader who wants a null-pair
  shape may give it as a third shape with exact text; it is recorded and does not block K-final.
- Q1 goes to the owner whatever this round finds (r67 owner label: cost and latency are the owner's).

## Outcome rules (r63 rules 1-7 form; rule 3 = the gate)

Per question (Q1, Q2). Each form read is judged on its own.
1. Each reader votes ACCEPT, AMEND or CANNOT ACCEPT on **each** form read (Q1: S-final and F-final; Q2: K-final),
   and on Q1 picks one (or names a third shape with its exact text). **Every AMEND carries an explicit mark,
   "behaviour unchanged" or "behaviour changed"**, plus exact replacement text for its span only.
   - An AMEND marked "behaviour unchanged" counts as ACCEPT if the manager checks that its text changes no
     behaviour the form lists. Its wording rides into the Run.
   - An AMEND marked "behaviour changed", unmarked, or failing that check counts as CANNOT ACCEPT, with the
     reader's text recorded. It then blocks only under rule 3.
   - Each option (S-a.., F-a.., K-a..) gets "take" or "leave" from each reader. An option merges into its form
     only at 3 of 4 "take" with no gated CANNOT ACCEPT against it. Otherwise the form goes as printed.
2. A form is **owner-ready** at 3 of 4 ACCEPT (counted AMENDs included) with no blocking CANNOT ACCEPT. Merged
   "behaviour unchanged" AMENDs and merged options need no further read. The owner question quotes only
   behaviour the panel read.
3. **The gate.** A CANNOT ACCEPT blocks only if it names a loss that changes a checked verdict:
   - a `CNF` assertion or Lean theorem the form flips, makes unreachable or makes vacuous (id or theorem name);
   - or a MUST/SHOULD (file, requirement id) with a trace that breaks it.
   A CANNOT ACCEPT that names none is recorded and does not block. Wording a reader dislikes is not counted.
   Pre-registered: a form flipping a `CNF` assertion **that the form itself lists as amended** is not a gated
   loss; a flipped assertion it does not list is. A verified breach of `AGENTS.md`'s quoting rule ("Quote the
   sentence", "Cite the owner") is a wording defect: the manager fixes it with the owner's verbatim words, reports
   it, and it does not block.
4. **A verified gated loss on a final form (decided now):**
   - on K-final, or on the form the panel picks for Q1: one scoped round (r68b) on that span only, with the
     readers' fix if their texts converge in substance, or the clause deleted under rule 5. The owner question
     waits for it.
   - on the Q1 form the panel does not pick: no extra round. The owner question names that form's verified
     defect and the readers' fix, and says a scoped round follows if the owner picks it.
   - If neither Q1 form is owner-ready, or Q1's picks split 2-2, Q1 goes to the owner as a split, both forms
     with their tallies and defects.
5. A clause that draws non-converging AMENDs in two successive rounds (r67 and r68) is deleted, not reworded,
   unless a reader names the normative content the deletion loses (rule 3).
6. A verified brief error that changes a question's premise voids **that question's** tally only; it is
   re-asked, corrected. Other brief errors are reported with the tally, naming any vote whose reason rests on one.
7. Counter-arguments "written on request" are not votes. Relay votes first, counter-arguments labelled.

Owner labels: Q1 goes as "panel recommends <pick>, <n> of 4", never as settled, with each form's strongest
argument and the cost points (r67 tally "Against my pick"). Q2 goes as "panel recommends applying K-final" if
K-final is owner-ready.

## The one owner question (after the tally)

One question, two parts, per r67/notes.md: (a) Q1, F-final or S-final; (b) Q2, apply K-final? Plain-terms story
first (the re-listed auction offer for Q1, corrected to `OPS-43`'s "where the provider's price has risen past what
the reserve covers"; the standard-channel lost reply for Q2), recommendation first, then the ids each lands on.

## Reader labels (manager only; the brief uses neutral labels)

brief.md's Reader 1 = r67 fable, Reader 2 = r67 opus, Reader 3 = r67 astra, Reader 4 = r67 sol
(/var/tmp/provisiond-panel-r67/<reader>.md). r68 readers start fresh; the brief tells none of them its label,
its model or any earlier vote count.

## Coordinator decisions in the brief (each marked in it; readers vote on them)

- **`PRV-40` span: Reader 4's.** tally.md states no preference between Reader 3's and Reader 4's spans, which
  differ only by "the create's". Reader 4's is taken because "the create's" ties the permitted read to the
  refused create `PRV-40` names. Rendered with the clause order fixed so "with `rate_limited` and
  `retry_after_ms`" stays on the refusal.
- **`OPS-1` span (F-final): drafted by the coordinator, UNREVIEWED.** A new second sentence, so the first stays
  verbatim (impl-report-01.md:174 quotes it); it quotes F-final's new `API-7` words.
- **03:276-277 quote sync (F-final): drafted by the coordinator, UNREVIEWED.** The italic record quotes
  `PRV-40`'s "before any provider call" in the present tense ("says"); F-final updates the quote.
- **Reader 2's `OVR-10a` cite** is corrected: the trait clause is deleted and "See `OVR-9` for the route."
  added, since "`engine`'s narrow trait" restates `OVR-9` without its words.
- **K's `PRV-32` lead-in** "That declaration is the descriptor's `correlator: none`." is dropped from K-final: it
  says what `PRV-33` does without `PRV-33`'s words, and Reader 4's sentence already says "including one
  declared `correlator: none`". Reader 2's verbatim lead-in is option K-a.
- **S-final's `OVR-19` rows** are the coordinator's rendering of Reader 4's "Register S's age under `API-7`,
  and refresh interval under `OPS-51`".
- **S-final's `CNF-166` case** "`OPS-43`'s claim-time check then refuses it" gets `OPS-43`'s verbatim words.
- **Reader 2's `OPS-33`-window case** (option K-d) gets `OPS-33`'s verbatim words.
- Ids: `STO-60`, `OPS-51` and `CNF-371` are unused in the spec at `c5f897c` (highest STO-59, OPS-50, CNF-370).

## Settings

Readers: fable claude-fable-5-1 xhigh, opus claude-opus-5-5 xhigh, astra gpt-6-astra high, sol gpt-6.1-sol xhigh.
Units panel-r68-{fable,opus,astra,sol}. `timeout 3600`, draft answer by minute 25, answer cap 900 words excluding
replacement text. Launch recipe: /var/tmp/provisiond-manager/r68-handoff.md.

## Order

These rules were written before the brief. Nothing in them was tailored to the brief's wording.

## Quote and span check (done before launch; re-run with the commands below)

Script /var/tmp/provisiond-panel-r68/check/qcheck.py (output check/qcheck.out). It applies every S/F/K span of
brief.md to branches S, F and K of the throwaway clone check/clone (off `c5f897c`), then checks quotes and cites.
- **Spans: 25 of 25 «before»/anchor strings hit exactly once** in their file (whitespace-normalised), "SPANS ALL OK"; the option strings F-b and F-c (both texts) also hit once. F9 is applied on branch F; its new quote is a substring of F8.
- **Line cites: 34 checked**, one CITE-MISS, a false positive: "(00:216)" cites `OVR-10a`'s location, not the
  quote next to it. The run fixed three cites before this one: `PRV-33` "never to a guess" is at 02:1048-1049, "The
  driver declares the absence" is at 02:1053-1054, and 05:360 is now named for the index quote.
- **Quotes: every quote of `c5f897c` text is found.** The 25 remaining "misses" are not repo quotes:
  - the brief's own vocabulary ("behaviour unchanged", "F1 as printed", …);
  - r67 reader texts, each grep-checked against /var/tmp/provisiond-panel-r67/*.md (verbatim; two differ only in
    whitespace, and Reader 4's "the create’s"/"S’s" are printed with straight apostrophes).
- **Strict quoting sweep:** /var/tmp/provisiond-gates/pv-buc-verify/ratchet-sweep.py clone c5f897c S|F|K
  (check/sweep-{S,F,K}.out). quote-MISS 0 on all three. The "restates" hits, read by hand:
  - S, 5 hits: the `OVR-17` row's and `OVR-19` rows' id columns, the existing table convention; and S1's "stated
    offer-listing age (`OVR-19`)", the register convention (03:146, 05:232). Pass.
  - F, 2 hits: F1's "; see `DOM-17`" is a bare pointer, and the sweep does not split at ";". The second is
    `CNF-283`'s "refused by the `API-7` tail before any provider mutation": `c5f897c`'s words with "call" changed.
    It is **disclosed in the brief** at F5 for the readers.
  - K, 1 hit: K3's "(see `PRV-33`)", a bare pointer. Pass.
  - The options (not applied) were checked by hand: S-a, S-b, S-c, F-a, K-a, K-b and K-d each quote verbatim or
    use a bare pointer, and none puts a MUST outside its owner.
- Model-name grep over brief.md: `grep -wiE 'fable|opus|astra|sol|gpt|claude|codex|anthropic|openai'` must print
  nothing (Reader 1-4 labels only).
- brief.md is 35.3 KB.

## Quota (checked before launch)

- 2026-10-25T09:13:25Z, `timeout 60 claude -p "/usage" </dev/null` (rc 0): session 19% (resets 13:49Z), week (all
  models) **98%** (resets Oct 28 00:59Z), Fable week 59% (resets Oct 28 00:59Z).
- Week 98% is at or above the 95% stop line: **NOT launched.** No clones, no scripts, no units.

- 2026-10-25T20:28:27Z, `timeout 60 claude -p "/usage" </dev/null` (rc 0), after the owner switched accounts: session **8%** (resets Oct 26 01:10Z), Fable week **0%** (resets Oct 27 02:00Z). Week (all models) was **not shown** in this command's output; main reports that it read below 95% before launching this manager. Neither reported percentage reaches the 95% stop line; proceeding with launch.
