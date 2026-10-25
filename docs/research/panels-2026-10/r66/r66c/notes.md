# r66c notes (panel D, pv-buc, Fence G): outcome rules, set BEFORE launch. 2026-10-24 ~16:30Z

Master `d78085a`. Clones at `d78085a`. Brief: docs/research/panels-2026-10/r66/r66c/brief.md. Source of the task and plan:
/var/tmp/provisiond-manager/r66c-handoff.md (consumed by this round).

## Inputs

- Owner, verbatim. Restore gap: "Draft 2) using the panel and assess complexity" (option 2 = an app-side check: the
  engine itself detects that the store went backwards and exits). Rollback: "Us this scenario real? The project isn't
  built yet" (answer: no; drop the `STO-13` transition clause, r66b span 22, and r66b's Q3). Standing preference:
  safety enforced in the app over infra configuration, and "what happens if there is a misconfiguration?"
- r66b tally: docs/research/panels-2026-10/r66/r66b/tally.md. Q2 (R) 4-0 ACCEPT; G's restore window raised by three readers.

## Labels

- r66c readers: unit/file names fable, opus, astra, sol (never in the brief). The brief calls each "you".
- r66b's readers are named in the brief as **Reader W, X, Y, Z** = r66b's fable, opus, astra, sol. Letters chosen to
  avoid the appendix's "Reader 1-4" (r66's readers in its [took] notes), trace letters (a)-(c), and Form/Fence E, G, R.
- Q2 items are F1-F9, wording items W-1, W-2, Q3 strip items D1-D4 (no clash with r66/r66b's B-labels).
- Inside the appendix, "Q1/Q2/Q3" mean r66b's questions; the brief says so.

## Outcome rules

**Q1 (drafting, not a vote).**
1. Every cost claim in a draft (columns, rows, per-transaction work, CNF items, Lean, span count) is verified by the
   tally manager against the draft's own text before it reaches the owner.
2. A draft is unsound only with a trace against its own text (a stale write it admits, or an admitted write it
   refuses, or a CNF verdict a conforming engine fails). A dislike is recorded, not counted.
3. "No app-side check is sound" counts only with a reason (a trace or a constraint, quoted).
4. Drafts go to the owner side by side with their complexity ratings and verified costs, and each one's answer on
   whether the r66b barrier is still needed. The tally recommends at most; the owner decides.
5. Nothing from Q1 enters the Run without a reading round of the picked text.

**Q2 (confirmation read, r66b's rules).** ACCEPT or CANNOT ACCEPT per F-item, under the gate copied into the brief
(r66b rule 3: a CANNOT ACCEPT needs a loss that changes a checked verdict). Consensus: 4-0, or 3-1 with the dissent
verified false. Rule 5: an item that fails to converge across two amend rounds is deleted. Rule 6: a verified brief
error voids that question only. Rule 7 as r66b. W-1, W-2 are wording, applied and listed, not voted. F3's ACCEPT
endorses `CNF-370` as the fixture for span 19 as written (post-record case); it does not endorse a deployment barrier.

**Q3 (confirming the drop).** A "yes, something depends on it" needs a quote. A verified dependent joins the drop
(D-list) without a vote. The `ADR-0047` premise sentence: kept unless a reader shows it false with a quote; "nothing"
is the fallback.

## Deviations from the task's Q2 list (recorded per the task)

1. **F1 adds `CNF-362`'s quotation at 10:1682.** The after-return list (03:1807) is quoted verbatim in `CNF-362`
   (header 10:1614), so the `OPS-21` edit needs a lockstep quotation update there. No other non-research hit.
2. **F4 adds the `ADR-0025`:118-119 Lean parameter** (`generationCheck : Bool` on the model carrying `engineStep`, and
   the witness `superseded_commits_without_check`), replacing r66b's "No field is added to `Guards`/`workerGuard`".
   The task's Q2 list omits it; the r66b tally carries it as behaviour for r66c. Included for that reason.
   (Line fix: the tally's "ADR-0025:117-118" is 118-119 at d78085a.)

## Not adopted (r66b non-blocking notes; stated in the brief, not voted)

X's `STO-54` step (1) writer note; W's notes 1-3; X's `CNF-367`/`CNF-369` additions; Y's and Z's Lean freshness
hypothesis (`gen_random_uuid()` is "a version 4 (random) UUID"). Z's "CONTEXT.md:520-527 is rationale" is also left
for the Run's ADR text.

## Manager's choices in the brief

- `ADR-0047` gets a one-line premise in place of "the `STO-13` boundary with Q3's answer", grounded in the owner's
  answer; `AGENTS.md`:4 is cited only for "the repository holds only the specification".
- F5 and F9 add no new claim: F5 quotes ADR-0019:80-81 for scope and cost; F9 says only that `OPS-47` no longer carries
  the quoted words, with a pointer to `ADR-0047`.
- Q1 tells the restore-to-another-server shape and asks each draft which side of F7's "one writable database history"
  it falls on, so the story does not contradict F7.
- Next free ids for Q1 drafts (git grep at d78085a, outside docs/research and .beads, 0 hits each): `STO-60`, `OPS-51`,
  `CNF-371`, `ADR-0048`.

## Settings

Word cap about 2,000 words, excluding drafted spec text. `timeout 3600`; "Have a draft answer by minute 30".

## Span check

`spancheck.tsv` (72 rows) -> `spancheck.out` (`n|hits|file|lines|span`), one fragment per line, `grep -nF -e`:
- 26 rows against `git show d78085a:<file>`: every one hits exactly one line, at the cited line (03:1741, 1742, 1807;
  10:1682, 1519; 05:1338, 1340 x2, 1507, 1508 x2, 1514, 1515; 0019:80 x2, 81; 0025:65, 66, 67, 118, 119;
  README:304, 305, 306; 02:142; AGENTS.md:4).
- 32 rows against r66b brief.md (the Appendix text) and 14 against r66b tally.md (the three barrier texts, F3's
  `CNF-370`, F2's and F8's afters): all hit. Two wrapped fragments were split and re-checked.
- Zero-hit rows: 0.
- Appendix verbatim: `diff` of r66b brief.md 34-306 and 314-369 against the brief's Appendix 1 and 2: identical.
- `wc -c brief.md` = 45294 (< 131072).
- Correction on the way: the story first attributed "in the transaction that commits `STO-56`'s record" to span 19;
  it is the Appendix's `STO-59` text (span 19 says "The transaction that commits that record MUST also write"). Fixed.

## Label note for the tally (added after launch; brief.md unchanged)

"W-1"/"W-2" are wording-item labels, not Reader W. W-2 is Reader W's note 4 (the `PRV-9`/`OPS-32` term); Reader W's notes 1-3 are the ones not adopted.
