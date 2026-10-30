# Panel L r91: opus reader

**Preferred form: C.** The pinned clone was left unchanged and nothing was committed; every run happened in scratch copies under `tmp/opus/`.

| Form | Verdict | Strongest reason |
|---|---|---|
| **A** | **CANNOT ACCEPT** | It also rejects straight spans that sit wholly inside code. That turns down ordinary prose the base handles correctly, and its "use curly outer marks" hint doesn't apply there. On every bead case it catches nothing C misses. |
| **B** | **CANNOT ACCEPT as printed** | I found a nested-value corruption inside B's stated scope that it misses silently. Its docstring claim "Matching backtick runs are paragraph-local" is false where the comparison actually runs. |
| **C** | **ACCEPT** | It catches every nested-value corruption I planted, in every attributed shape, and fails loudly. The corpus stays green after the two-mark migration. It adds code and touches nothing in extraction or comparison. |
| **N** | **CANNOT ACCEPT** | The misses are reproduced, and safety still depends on authors remembering the convention. N also leaves CNF-302's citation of CNF-300 completely uncompared today. |

## The raw question

**Unconverted, the cheap rule rejects a valid current citation.** It catches the bead's nested-value corruptions in every attributed shape. But CNF-302's citation of CNF-300 at `10-conformance-checklist.md:3096–3097`, whose content is correct, fails on both A and C:

`FAIL: 10-conformance-checklist.md:3096: CNF-300 straight quotation closes inside inline code; use curly outer marks (“…”).`

**With the two-mark migration the corpus is green.** I confirmed the migration changes exactly two characters: `"`→`“` at 3096 and `"`→`”` at 3097. The migrated bytes are a different input. They don't show that the old punctuation is still accepted: it isn't, under A or C.

**Extraction is not necessary** for the bead's defect, which concerns attributed citations. B covers more ground, but as printed it has its own silent gap.

## What I ran

- **Verifier:** `python3 /var/tmp/provisiond-panel-r91/verify.py --source "$PWD" --work /var/tmp/provisiond-panel-r91/tmp/opus/verification` exited 0.
  - Real CLI on each clean candidate tree: exit 0 for N, A, B and C.
  - Unconverted CNF-302 under A and C: exit 1, with the diagnostic above.
  - Embedded CI control: exit 0 for A, B and C.
  - N's straight possessive probe: `account_terminatd` 0, `"stat"` 0, `three recoverable` 0. N misses all three.
- **Patches:** the printed patches equal `candidates/*/exact.patch`. Applying them to `git archive HEAD` reproduces every candidate file byte for byte. N is identical to the base.
- **Existing tests:**
  - Regenerating `check_quote_content`'s cases from the pinned routine gives exactly the 246 cases in the JSON.
  - All 41 inherited PASS lines are present on A, B and C; the only new line is `PASS: nested inline-code citations…`.
  - Only these functions changed: A and C touch `load_lean_docstrings` and `main`; B touches `chunks`, `quotations` and `main`. The matcher functions are untouched.
  - Baseline reads are identical everywhere: Markdown 6/6, Lean 0, EXISTS 0, unquoted 22/22.
- **Non-vacuity:**
  - A's and B's CI controls, run against N's checker, both exit 1: A fails at its straight-form assertion `(1, 0)`, B at its straight-corruption assertion `(1, 0)`. C's control is byte-identical to A's.
  - Removing code-span detection or the guard makes A's and C's self-test FAIL. Flattening B's extraction makes B's self-test FAIL.
- **JSON artifacts:** I processed all 497 attribution records, 504 chunks and 573 raw spans with scripts, and read the subsets that matter by eye: the 6 `passes: false` baseline records and the straight spans containing backticks. I did not read every record by eye.

### Plants through the real CLI

These are at the live OPS-43 citation of API-63, in each form's own tree. Exits are listed as N / A / B / C. Logs are in `tmp/opus/plant-logs/<plant>.<form>.log`, with a summary in `plants.json`.

| Plant | Straight outer marks | Curly outer marks |
|---|---|---|
| says, exact | 0 / **1** / 0 / **1** | 0 / 0 / 0 / 0 |
| says, `account_terminatd` | 0 / 1 / 1 / 1 | 1 / 1 / 1 / 1 |
| says, `"stat"` | 0 / 1 / 1 / 1 | 1 / 1 / 1 / 1 |
| says, `three recoverable` | 1 / 1 / 1 / 1 | 1 / 1 / 1 / 1 |
| possessive, the same three corruptions | 0 / 1 / 1 / 1 | 1 / 1 / 1 / 1 |
| noun-that and colon, the same three corruptions | N 0 except noun-that `three` = 1; A/B/C all 1 | 1 / 1 / 1 / 1 |

- The says-form row reproduces the bead's original probe at the pin: `account_terminatd` exits 0 and `three recoverable` exits 1 on N.
- I also planted `retryable: true`→`false`, which follows the same pattern.
- The diagnostics are the right ones, not an unrelated baseline finding:
  - A and C straight: `API-63 straight quotation closes inside inline code; use curly outer marks (“…”).` at line 778.
  - B, and all curly forms: `attributes to API-63 a phrase API-63 does not contain`, printing the changed value (for example `"account_terminatd"`).
- In the noun-that form, A prints three diagnostics (lines 778, 779, 781) where C prints one. A's extras come from its wholly-inside-code rule.

### Adversarial cases

| Case | N | A | B | C |
|---|---|---|---|---|
| **1.** CNF-302: `"none"`→`"nne"`, `"unknown"`→`"unknwn"`, `aborted`→`abortd` | 0 | 1 | 1 | 1 |
| **2.** Code span cut by SPLIT, with `account_terminatd` | 0 | 1 | **0** | 1 |
| **3.** Straight value wholly inside code after a speech verb | 0 | **1** | 0 | 0 |
| **4.** Lean EXISTS nested quotes (`Rescue.lean:978`, `Witnesses.lean:3767–3769`), `"unknown"`→`"unknwn"` | 0 | 0 | **1** | 0 |

1. **CNF-302.** N doesn't compare this citation at all: its owned flat span is short. A/C (migrated) and B compare it, and print `attributes to CNF-300 a phrase CNF-300 does not contain`.
2. **B's silent miss.** I changed `fail `conflict`` to `fail `e.g. conflict`` before the citation, with straight outer marks. The B log shows 353 comparisons: the citation dropped out entirely.
   - Mechanism: SPLIT cuts after `e.g.` inside the code span. `find()` calls `quotations(sent)` per chunk, so B pairs backticks inside the chunk, not the paragraph.
   - The chunk's leading ``conflict` `` pairs with `` `API-63` ``'s opening backtick, which shifts every later code span. The outer opener then looks as if it's inside code, so B doesn't extend. Flat pairing yields a short first span, and nothing is compared.
   - A and C compute code spans once over the whole text, so they still fire.
   - In the current corpus, exactly one chunk's local pairing differs from its paragraph's, and it has no straight marks. So the corpus is unaffected, but B's scope claim is broken.
3. **A's false positive.** I added `` `API-63` says "the last write before the ordering call" fails with `"state"`. `` at line 803. A rejects it with the curly-mark hint, though there is no outer quotation to make curly.
   - A's own self-test asserts that `` `API-63` says `"alpha beta gamma delta"` `` is rejected. The base compares that shape and accepts it.
   - 192 current chunks carry straight-marked values wholly inside code. Only one follows a speech attribution (`AGENTS.md:30`), and it's TEACHING, so it is skipped.
4. **Lean EXISTS quotes.** These two straight-in-straight quotations are already in the corpus. They're unattributed, so only EXISTS reads them, and only B's EXISTS sees the whole quote.
   - The Lean colon form behaves the same way at function level: only B's `exists()` reports the corruption.

## Per-form assessment

**C.** The guard computes code spans over the whole document, or over each Lean docstring block with correct line offsets. Ownership matches `find()`:
- speech or noun-that attribution for later quotes;
- possessive and colon only when directly adjacent;
- colon in Markdown only;
- TEACHING skipped in both kinds, history skipped per candidate in Markdown and per chunk in Lean.

Every bead corruption fails, in every shape and in both one- and two-backtick spans. On all my plants C matches A exactly, except case 3. The quotation-wholly-inside-code path keeps its existing comparison. The docstring is accurate, and the remaining "other balanced nested" limitation stays disclosed.

Its cost is real: correctly quoted straight-nested citations become a syntax error, one site has to be migrated, and EXISTS-only Lean nested quotes stay unchecked as before. Optional hardening, not a condition: the CI control could also assert that the printed phrase contains the planted value.

**A.** Everything C does, plus the wholly-inside-code rejection, which detects nothing extra and blocks legitimate prose. A gate that fires on correct prose is the kind of gate this checker's own docstring warns gets deleted.

**B.** B's strengths:
- no migration is needed;
- the diagnostic names the wrong phrase;
- the full CNF-302 citation is compared;
- coverage extends to Lean EXISTS and the Lean colon form.

The corpus diff against N changed only three spans, all of them intended nested quotations. Against that:
- it changes `chunks()`, `quotations()` and EXISTS, which every rule shares;
- its new failure mode is silent, which is exactly what the bead complains about;
- its docstring misstates where backticks are paired.

A repair is possible: compute code spans over the whole text and pass them into `quotation_spans` from `find()`/`exists()`, or state the per-chunk limitation in the docstring. I have not written or verified a complete patch, so no repaired B is offered for counting.

**N.** Every straight-form plant is green, and CNF-302's citation gets no comparison today.

## Checked verdicts lost or changed

**No rule-3 blocking loss in A, B or C.** No baseline entry, Lean declaration, theorem, conformance assertion, MUST/SHOULD, inherited fixture or existing CI control changes.

Changes:
- **CNF-302's citation of CNF-300** goes from uncompared to compared in A, B and C; the Markdown comparison count goes from 353 to 354. This strengthens the gate.
- **A and C:** the old straight punctuation at 3096–3097 now exits 1. This is a collateral syntax flip.
- **A only:** attributed straight spans wholly inside code are now rejected. There is no current non-teaching instance.
- **B only:** two Lean EXISTS quotations are now compared whole. The quote total stays at 1050 and no finding results.

## Brief accuracy (rule 6)

None of these changes the question's premise, so none voids the tally. None of my votes rests on one of them.

1. **Line numbers.** The citation is at `10-conformance-checklist.md:3096–3097`, not 3095–3096; the brief's own patch hunk agrees with 3096–3097.
2. **Lean quotations not mentioned.** "One discovered current valid citation matters" holds for attributed citations. But the brief doesn't mention the two unattributed Lean nested quotations, or that B changes their EXISTS reading.
3. **A claim my execution broke.** "Their backtick scanner matches equal-length runs inside a paragraph" holds for A and C, and for B's `chunks()`. In B's `find()`/`exists()` path the scanner runs per chunk; case 2 is the counterexample.

I found no self-contradiction in the brief. Its other claims I checked were reproduced: the curly form compares the value, the unconverted CNF-302 citation is rejected, B accepts the correct straight form, and the CI control text matches the workflow.

## Strongest no-change counterargument (written on request; not my vote)

- After PR #17 the attributed defect has no live instance, and N is green.
- Every changed form alters check strength and needs the owner's approval.
- A and C add a syntax rule and force edits to a correct citation.
- B rewrites the extraction all four rules share, and still has a silent hole.
- The gate's docstring already discloses nested mispairing, and the curly convention works whenever it's used.

My rebuttal: the owner prefers checker enforcement over author memory, and the misses reproduce. N also hides a hole today: CNF-302's citation is never compared, and corrupting it stays green.

Logs and scripts are in `/var/tmp/provisiond-panel-r91/tmp/opus/`: `verification/`, `plant-logs/`, `ci-on-N.{A,B}.log` and `scripts/`.
