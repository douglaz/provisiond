# r66e notes (panel D, pv-buc, final confirmation read of R + Fence G combined): outcome rules, set BEFORE launch. 2026-10-24 ~18:55Z

Master `d78085a`. Clones at `d78085a`. One shared brief, docs/research/panels-2026-10/r66/r66e/brief.md, with no seats.
The outcome rules below are main's instructions, copied before launch. brief.md is assembled from `parts/head.md` +
`parts/combined.md`. `parts/build.py` builds combined.md from r66d brief.md 420-753 (Appendix 1-2) and 338-395 (Base),
and it asserts that every replacement hits exactly once.

## Input

The owner, verbatim, on r66d's 2-1-1 split: "I don't think we should tolerate a gross operator mistake like restoring
some backup with the system running".

Main's reading, recorded and open to the owner's overrule:
- A restore performed while any engine or `api` runs is outside what G defends.
- `STO-54`'s restore procedure states, as a step, that every engine and `api` is stopped first. This is option 4's
  rule, worded as a step.
- No app-side restore check is added.
- G's "does not cover" list names that restore as unsupported.

## Outcome rules

1. **Consensus** is 4-0 ACCEPT on the one combined text, or 3-1 where the dissent's load-bearing fact is verified
   false.
2. **A CANNOT ACCEPT must name a checked verdict it changes** (the gate copied from r66d rule 4). That is:
   - a `CNF` assertion or Lean theorem the text flips, makes unreachable or vacuous (id or name);
   - a MUST/SHOULD (file, id), with a trace that breaks it;
   - for G, also a trace in which the text admits a stale write or refuses a write it should admit.

   A CANNOT ACCEPT that names none of these is recorded and does not block.
   - **Scope clause:** a trace that needs an engine or `api` running across a restore violates span 26's MUST. It is
     not a conforming counterexample.
   - The scope is the owner's and is not re-voted. Disagreement with it is recorded and does not block.
3. **Wording-only fixes may ride into the Run.**
4. **Anything else** goes to main with the defect and the reader's replacement, and no further round is decided here.
   That covers a gated CANNOT ACCEPT verified true, and a contradiction with `d78085a` verified true with quotes on
   both sides. A verified contradiction that is wording only follows rule 3.
5. A verified brief error is reported with the tally, which names any vote whose reason rests on it.

## Labels (neutral; one brief; no seats)

| Label | Reader |
|---|---|
| a | fable |
| b | opus |
| c | astra |
| d | sol |

Readers start fresh. The brief tells none of them its label, its model or another reader's earlier vote.

## Manager decisions in the combined text

- **Span 26 (new)** is an unnumbered lead-in to "**The procedure, in this order.**", before "(1)":
  - "*Before the restore begins,* the deployment MUST stop every engine and `api` process, and MUST start neither
    component until the transaction that commits `STO-56`'s record (below) has been acknowledged".
  - It is unnumbered so that `steps_completed` (0 to 3) keeps its meaning.
  - It is unscoped ("every"), so it covers a restored server behind the same address.
  - It is checked against the promotion bullet, 05:1507-1508 "Before any component connects to the promoted store".
    Span 26 is stricter there but does not contradict it.
  - `CNF-365` is a restart promotion, so the step does not reach it.
- **Span 19 is kept unchanged.** It is G's accepted text, not an option's.
  - *For main only, not acted on:* with span 26, span 19's fresh value only limits the unsupported case. A survivor
    is refused once the record's transaction commits, and never before. `api` is never refused.
  - The not-covered line states that limit. `STO-59`'s "Without that write, an engine that survived the restore
    still holds the restored value and would match" stays, because it is accurate.
- **The `STO-59` rewording** is option 4's sol text, verbatim:
  - the heading "generation choices are fresh";
  - the freshness MUST and "Reinstating a backed-up value is not a new generation choice";
  - the `CONTEXT.md` entry.

  All four r66c drafts reworded "written twice" in substance.
- **`CNF-370`** now drives a conforming restore: start an engine; back up; stop every engine and `api`; restore. It
  asserts two things:
  - the record's transaction wrote a fresh `STO-59` value before either component started;
  - after an engine starts, every advance and record-transaction value is distinct.

  It cites `STO-54`, after r66c's note that span 19 puts the MUST there. The proxy, the held worker, the bounds, the
  survivor and the stale "[took: Reader 1's (B5)]" note are gone.
- Base F1-F9, W-1, W-2 and D1-D4 are applied in place:
  - F1 is span 23, F8 span 24 and F9 span 25.
  - Span 22 is deleted (D1).
  - F5 and D4 both land in `ADR-0047`, which was rewritten as one bullet.
  - Span 2's "see Q2" becomes "see part 2".
- Provenance notes and reader attributions are stripped, and so are "(r66's REPEATABLE READ trace)" and "(B3)".
  - Three "not spec text" notes are kept: the anchor, both timeouts, and the zero bound.
  - The anchor note now quotes "*Before the first claim:*" (r66d error 9).
- The pointer-only list's "`CNF-362`'s quotation, if `OPS-21`'s quoted list changes" becomes "`CNF-362`'s quotation is
  span 23's". Its "**Check:**" question to r66b's readers is dropped.
- Left as is: the Lean bullet's "r65b's Form E fix-8 list". The list is enumerated inline.

## Known wording items for the Run (rule 3 if a reader raises them)

- **`ADR-0047` does not name the decision span 26 is dated to.**
  - Span 26 carries "*added 2026-10-24, `ADR-0047`*", but `ADR-0047`'s description only "States the not-covered
    cases".
  - The Run should have `ADR-0047` record span 26's step and quote the owner's dated words verbatim.
- **`CNF-370` never creates a choice "whose effects a restore removed".** No advance happens between the backup and
  the restore. A reader asking for a restart between the two is raising check strength, not triggering the gate, so
  it may ride into the Run.

## Order

The brief was drafted before this file and re-assembled after it. The rules are main's words, so nothing was
tailored to the brief.

## r66d brief errors: disposition

1. "after any PostgreSQL restart" scope: option-comparison prose, not carried. The brief makes no restart claim.
2. "keeps it on a crash-restart reinit only if": Option 1 only, not carried.
3. Option 3's witness "not checked further": Option 3 only, not carried.
4. "ends `needs_reconciliation`" overstatement: comparison prose, not carried.
5. Option 2's "no model carries a restore" ADR line: Option 2 only, gone.
6. Option 3's `OVR-19` Before-row backticks: Option 3 only, gone.
7. Option 1's start-instant uniqueness: Option 1 only, gone.
8. Option 1's r63 timeline attribution: Option 1 only, gone.
9. 05:1542 "*Before the first claim:*": fixed in the anchor note.

r66d's non-blocking notes:
- fable's S2 referent, fable's `CNF-370` (i)/(ii), fable's `ADR-0047` narrowing and opus's `CNF-370` (iv) are
  Option 1 only, and gone.
- opus's defects A and B are Option 1 only, and gone. Under the combined text a server stop and start leaves the
  generation unchanged, so `CNF-366` is untouched.

r66c's Q2 notes:
- opus's F3 cite is fixed (`CNF-370` cites `STO-54`).
- fable's stale B5 note is removed.
- opus's F1 "not a closed list" is unchanged and non-blocking.
- astra's and sol's "written twice" is fixed by the `STO-59` rewording.
- Q3's D4 rewordings from fable and astra go to the Run as wording.

## Settings

The word cap is about 1,000 words excluding replacement text. Runs use `timeout 3600`, with "draft answer by minute
25".

## Span check

`spancheck.tsv` (83 rows) is checked by `parts/spancheck.py`. Output in `spancheck.out`, one row per line:
`n|hits|lines|file:cited|OK/FAIL|inbrief`.
- Each fragment is one physical source line, checked with `grep -F` semantics (substring) against
  `git show d78085a:<file>`.
- **All 83 rows: OK.** Each hits at least once, and at the cited line where one is cited. The fragments cover:
  - every Before block in spans 1-12 and 14-17 and in R's `OPS-47`;
  - every inline `d78085a` quote: STO-7, OPS-43, OVR-17, OVR-19, ADR-0019/0022/0025/0044, AGENTS.md:4, README.md
    304-306, 03:359/1741-1742/1773/1807/1879, 10:1511-1512/1519-1521/1682, 05:99/1336/1519/1542/1556/1557,
    00:316/338/399, CONTEXT.md:108, Claim.lean:22-24/430, and "Accept either outcome".
- Fixed on the way. These were the table's wrong splits or cites. No brief text changed.
  - 0019:80 holds "Rejected because it buys a defence for the case" and :81 the rest.
  - ADR-0022's quoted phrase is all on :92.
  - 0025's witness quote is all on :119.
  - "Any other promotion" is at 05:1512, and "is a restore: the procedure below runs on it" at 05:1514. The brief's
    "(05:1514-1515)" cite of the clause "is a restore … before either component is started" stands.
- The "NOTINBRIEF" rows are wrapped in the brief: 1, 13 and 54 were confirmed after whitespace normalisation. Rows 71
  and 72 are cites, not quotes.
- Quotes of new text were checked against brief.md, whitespace-normalised:
  - "treat the loss as a stop of every worker not already recording one" (2 hits: R `OPS-47`, `OPS-21`);
  - "The loss is not a later stop" (3);
  - "A refused generation check ends recording … reply lost." (2: `OPS-50`, `OPS-21`).
- External, not in the repo: the postgresql.org quotes ("A shared lock blocks …", "Row-level locks are released …",
  "applies separately to each lock acquisition attempt", "A value of zero (the default)" / "disables the timeout"). They
  were carried unchanged from r66b-r66d.
- Labels: after assembly, combined.md was grepped for `Q1|Q2|Q3|STO-13|span 22|S2|Option|Reader|r66|r65|took|(B[0-9]`.
  - Left: span 22's deletion line, which names `STO-13` on purpose.
  - Left: "r65b's Form E fix-8 list" (above).
- `wc -c` brief.md 30777.
