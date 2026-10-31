**Final preference: B, exactly as printed.** It compares the nested values while preserving the existing CNF-302 punctuation. C is an acceptable convention-enforcement alternative.

| Form | Verdict | Strongest reason |
|---|---|---|
| **A** | **CANNOT ACCEPT** | It unnecessarily rejects correct quotations wholly inside code, even without nested values. C supplies the narrower guard as a complete printed alternative. |
| **B** | **ACCEPT — preferred** | It detects the planted corruptions through content comparison and accepts the unconverted, correct CNF-302 citation. |
| **C** | **ACCEPT** | The complete migrated package enforces the convention and catches the defect while retaining quotations wholly inside code. Its punctuation restriction must be accepted explicitly. |
| **N** | **CANNOT ACCEPT** | It leaves the demonstrated nested-value misses dependent on author memory. A clean corpus does not repair them. |

The answer to the **raw, unconverted question is no**: neither guard catches the defect *without rejecting valid current citation syntax*. Both reject CNF-302’s correct citation of CNF-300. Extraction is necessary among these choices **if retaining that punctuation is required**. It is not necessary merely to enforce the convention: C plus its printed migration accomplishes that.

I read the complete packet, including the existing case-generating loops, corpus chunks, comparison records and raw spans. I ran:

```sh
python3 /var/tmp/provisiond-panel-r91/verify.py --source "$PWD" --work /var/tmp/provisiond-panel-r91/tmp/astra/verification
```

The command exited **0**. Its real, unpiped `python3 tools/check_citations.py` executions produced:

| Check | N | A | B | C |
|---|---:|---:|---:|---:|
| Complete package, clean corpus | 0 | 0 | 0 | 0 |
| Exact embedded CI control | absent | 0 | 0 | 0 |
| Correct, unconverted CNF-302 citation | 0, unchecked | 1 | 0, compared | 1 |

The verifier also confirmed each embedded workflow Python body exactly matches its supplied `ci-control.py`. The inherited self-test routines and comparison functions are unchanged; the real CLI ran them successfully before the corpus checks. Their requirement/document/ADR pools, Markdown/extracted-Lean paths, apostrophe cases and elision variants remain intact.

Receipts: [verification results](/var/tmp/provisiond-panel-r91/tmp/astra/verification/results.json), [A clean run](/var/tmp/provisiond-panel-r91/tmp/astra/verification/A-valid.log), [B clean run](/var/tmp/provisiond-panel-r91/tmp/astra/verification/B-valid.log), [C clean run](/var/tmp/provisiond-panel-r91/tmp/astra/verification/C-valid.log), and [CI-control logs](/var/tmp/provisiond-panel-r91/tmp/astra/verification).

For each changing candidate, the embedded control independently changed `account_terminated` to `account_terminatd`, `"state"` to `"stat"`, and `two recoverable` to `three recoverable` in the live bare-possessive citation:

- **A/C:** correct straight input and every straight corruption exited **1**, with the convention diagnostic. Correct curly input exited **0**; every curly corruption exited **1**, naming the API-63 content mismatch.
- **B:** correct straight and curly inputs exited **0**; every corruption exited **1**, naming the API-63 content mismatch.
- Each control restored the original input and required another **0**.

These distinguish syntax enforcement from comparison. A/C reject an ambiguous straight quotation before determining whether its wording is correct.

I additionally ran:

```sh
python3 /var/tmp/provisiond-panel-r91/tmp/astra/extra.py
```

It exited **0** and recorded individual CLI outputs for the speech-verb form, a wholly-inside-code citation, and a CNF-302 corruption. [Individual results and diagnostics](/var/tmp/provisiond-panel-r91/tmp/astra/extra-logs/results.json).

For straight outer marks, the observed corruption exits were:

| Form and attribution | `account_terminatd` | `"stat"` | `three recoverable` |
|---|---:|---:|---:|
| N, bare possessive | **0 — missed** | **0 — missed** | **0 — missed** |
| N, speech verb | **0 — missed** | **0 — missed** | 1 |
| A, either attribution | 1 | 1 | 1 |
| B, either attribution | 1 | 1 | 1 |
| C, either attribution | 1 | 1 | 1 |

A/C’s named diagnostic includes:

```text
FAIL: 03-operation-lifecycle.md:778: API-63 straight quotation closes inside inline code; use curly outer marks (“…”).
```

B’s corruptions produce:

```text
03-operation-lifecycle.md attributes to API-63 a phrase API-63 does not contain:
```

The new self-tests additionally exercise noun attribution, Markdown colon attribution, extracted Lean, and one-/two-backtick forms. They retain Markdown-only colon ownership.

The CNF-302 migration is a **syntax-acceptance change**, not preservation of the original input. The unconverted correct citation fails A/C with:

```text
FAIL: 10-conformance-checklist.md:3096: CNF-300 straight quotation closes inside inline code; use curly outer marks (“…”).
```

The printed migration preserves its content and makes the full quotation eligible for comparison. B obtains that comparison without migration. I also changed its nested `"none"` to `"nope"` under B: exit **1**, with `attributes to CNF-300 a phrase CNF-300 does not contain`. [B corruption log](/var/tmp/provisiond-panel-r91/tmp/astra/extra-logs/B-CNF-302-none-corruption.log).

My additional correct-input probe was:

```text
`API-63` says `"Recording a status the driver itself reports MUST be refused"`.
```

N, B and C exited **0**; A exited **1** with the convention diagnostic. This is A’s declared behavior, not an implementation surprise, but it rejects an unambiguous citation that does not need the nested-value repair. That is my reason for declining A. I propose no synthesized repair: C is already the complete narrower alternative.

B’s scope is acceptable **as bounded and documented**. Equal-length backtick runs pair within a paragraph; unmatched runs remain literal; fences receive no special treatment. It does not solve arbitrary nesting or stray balanced quotation marks. Its extraction feeds both QUOTED and Lean EXISTS, and full-span protection changes chunking where necessary. Existing history, teaching, word and length filters still apply. In particular, this is not universal checking of every nested quotation.

C has a narrower extraction impact, but adds a second pass that reproduces attribution and suppression decisions. Its migration and actionable diagnostic make it defensible when enforcing the punctuation convention is the chosen policy. B avoids that additional author-facing restriction and directly checks the intended quotation.

I found **no lost existing comparison slice in the supplied comparison inventory**, including records marked `passes: false`; those standing findings remain findings under the unchanged baseline. [Preservation receipt](/var/tmp/provisiond-panel-r91/tmp/astra/extra-logs/preservation.json). No printed package changes a Lean declaration, conformance assertion or comparison matcher. The substantive changes are quotation reach and syntax acceptance, including the collateral flips disclosed above. I did not run Lean or the full gate, as instructed.

I checked whether the brief contradicts itself. **No premise-changing contradiction or broken behavioral claim emerged from execution.** The unconverted rejection is explicitly disclosed, so it does not invalidate the migrated-package question. There is a minor location error: the nested CNF-302 quotation is at pinned lines **3096–3097**, rather than the brief’s 3095–3096. Under notes.md rule 6, that does not change the premise or void this recommendation; no acceptance decision rests on it.

**Strongest no-change counterargument, written on request—not my vote:** N preserves established extraction behavior and avoids introducing another bounded parsing convention. Existing curly citations already receive comparison, and B affects both chunking and EXISTS. That supports cautious review, but it does not outweigh the reproduced silent misses or the owner’s preference for enforcement.

This is a technical recommendation only. The pinned clone remains untouched; pv-602 stays deferred pending owner approval of a settled exact form.