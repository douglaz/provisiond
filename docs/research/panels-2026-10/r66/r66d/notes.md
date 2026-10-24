# r66d notes (panel D, pv-buc, Fence G's restore guard): outcome rules, set BEFORE launch. 2026-10-24 ~18:10Z

Master `d78085a`. Clones at `d78085a`. Brief: docs/research/panels-2026-10/r66/r66d/brief.md (template) and
brief-<reader>.md (template + one seat line). Source: docs/research/panels-2026-10/r66/r66c/tally.md (Q1 owner question).

## Input

Owner, verbatim, on which restore guard (1 start instant, 2 write chain, 3 session witness, 4 deployment rule only):
"try to reach a consensus". Earlier: "Draft 2) using the panel and assess complexity"; standing preference for
safety in the app over infra configuration, "what happens if there is a misconfiguration?"

## Outcome rules

1. **Consensus** is 4-0 on one exact text, or 3-1 where the dissent's load-bearing fact is verified false.
2. **A hybrid** counts as consensus only if every reader votes for the same exact text (a 3-1 on a hybrid counts
   only if the dissent votes the hybrid's text too, i.e. never by rule 1's second branch alone).
3. **A tie or a split** goes to the owner as an owner question, without another round.
4. **ACCEPT gate** (r66c Q2's, copied): a CANNOT ACCEPT needs a loss that changes a checked verdict: a `CNF`
   assertion or Lean theorem the text flips, makes unreachable or vacuous (id or name), or a MUST/SHOULD (file, id)
   with a trace that breaks it; for G also a trace in which the text admits a stale write or refuses a write it
   should admit. One that names none is recorded and does not block.
5. **Straight to the Run** only when rule 1 holds on one exact text and every reader voting for it gives ACCEPT
   (or each gated CANNOT ACCEPT is verified false). Consensus on a text with a gated CANNOT ACCEPT verified true:
   consensus on the option, not straight to the Run; the defect and the reader's replacement go to main.
6. A verified brief error is reported with the tally, which names any vote whose stated reason rests on it.

## Labels and seats (deviation: the task's one brief, plus one seat line per reader)

Readers start fresh, so ask 1 needs a seat. brief-<reader>.md = one line + brief.md. Seats by r66c answer:
opus -> Option 1 (drafted), fable -> Option 2 (drafted), astra -> Option 3 (drafted), sol -> Option 4 (argued no
app-side check is sound, kept the deployment rule). The brief names options only; r66b's readers stay Reader W-Z.

## Manager assemblies (each option's exact text)

- Option 1 = opus.md 18-49 verbatim, **S2 included** (it is in the text as written, marked "separable").
- Option 2 = fable.md 9-22 verbatim; no deployment rule (its item 6).
- Option 3 = astra.md 5-143 verbatim **plus** Reader Z's sentence appended at the end of span 19 (its item 6 picks
  Reader Z's text; its spec text places none).
- Option 4 = Reader Z's sentence appended at the end of span 19 (where "that transaction" binds; the same place
  Option 1 puts its scoped copy) + sol.md 42-52's `STO-59` rewording + F3's `CNF-370` unchanged (sol.md 40).
- Base text under every option: r66c brief.md 127-226 (F1-F9, W-1, W-2, D1-D4; accepted 4-0 in r66c, applied,
  not re-voted) and 240-573 (Appendices 1-2, r66b's merged text).

## Settings

Word cap about 1,200 words excluding drafted text. `timeout 3600`; "draft answer by minute 25".

## Span check

`spancheck.tsv` (32 rows) -> `spancheck.out` (`n|hits|file|lines|fragment`), one fragment per line, `grep -nF -e`:
- 7 rows against `git show d78085a:<file>`: each hits exactly one line, at the cited line (03:950, 951; 05:89, 90,
  1507, 1508, 1542).
- 25 rows against the r66c sources (opus/fable/sol/astra.md quotes, tally.md quotes incl. the postgresql.org ones,
  r66c brief.md for F7 and Reader Z's sentence): all hit. Row 29 ("its guarantee covers one writable") hits 2 lines
  of r66c brief.md (57 the story, 181 F7 itself): expected.
- Fixed on the way: "machine's" -> "machine’s" (the source's curly apostrophe); five wrapped fragments split.
- Carried blocks, `diff` against their sources: head = parts/head.md; Option 1 = opus.md 18-49; Option 2 = fable.md
  9-22; Option 3 = astra.md 5-143; Option 4 = sol.md 40-52; Base = r66c brief.md 137-206 and 213-222; Appendices =
  r66c brief.md 240-573. All identical. Each brief-<reader>.md minus its 2-line seat header = brief.md.
- `wc -c`: brief.md 68836 (< 131072).
