**Final pick: C.** Acceptability, each judged as the complete printed package: **A ACCEPT**, **B CANNOT ACCEPT as printed**, **C ACCEPT**, **N CANNOT ACCEPT**. I also supply a tested repair of B, called B′ below, which I would accept but do not prefer.

## Answer to the prepared question

**Raw, unconverted cheap rule:** it does catch the bead's corruptions, because it makes the straight-nested form unwritable rather than comparing it. It does **not** leave every valid current citation accepted. One correct citation at the pin is rejected on syntax: CNF-302's quote of CNF-300 at `10-conformance-checklist.md:3096`. That passage landed on 2026-10-29 in PR #36, eight days after pv-602 was parked, so the bead's own "sooner" trigger has in fact fired: a straight quotation nested inside a straight one got past review, and under the pinned checker nothing inside it is compared. The printed A and C packages restore acceptance of that site only by changing its two outer marks, which I report as a collateral syntax flip, not as proof the original bytes still pass.

**Is extraction necessary?** Not to catch the corruptions. It is the only way to accept the straight-outer form, and B as printed does that with a hole I could reproduce, described below. B′ closes the hole.

## What I ran

All runs used my pinned clone at `aeb7ff6` as source and scratch copies under `/var/tmp/provisiond-panel-r91/tmp/fable/`. I confirmed first that `existing-checker.py` is byte-identical to the pinned checker, that base plus each `exact.patch` reproduces every candidate file, that the brief's printed patches equal `exact.patch`, and that each `ci-control.py` equals the body embedded in its workflow.

```sh
python3 /var/tmp/provisiond-panel-r91/verify.py --source "$PWD" \
  --work /var/tmp/provisiond-panel-r91/tmp/fable/verification
```

| verify.py row | result |
|---|---|
| N clean corpus | exit 0 |
| N straight possessive plants: `account_terminatd`, `"stat"`, `three recoverable` | exit 0, 0, 0 |
| A, B, C clean corpus and existing self-tests | exit 0 each |
| A, C with the pinned, unmigrated checklist | exit 1, `CNF-300 straight quotation closes inside inline code` |
| A, B, C embedded CI control | exit 0 each |

Logs: `tmp/fable/verification/*.log`, `results.json`.

My own probe matrix ran the real CLI 88 times, unpiped, on the OPS-43 live site in both attribution forms and on the CNF-302 site. Script `tmp/fable/scripts/probes.py`; logs and `probes.json` under `tmp/fable/probes/`. CONV is the convention diagnostic, ATTR is `attributes to API-63 a phrase API-63 does not contain`.

| OPS-43 site, correct / `account_terminatd` / `"stat"` / `three recoverable` | N | A and C | B |
|---|---|---|---|
| possessive, curly | 0 / 1 / 1 / 1 ATTR | same | same |
| possessive, straight | 0 / 0 / 0 / 0 | 1 / 1 / 1 / 1 CONV | 0 / 1 / 1 / 1 ATTR |
| speech verb, curly | 0 / 1 / 1 / 1 ATTR | same | same |
| speech verb, straight | 0 / 0 / 0 / 1 | 1 / 1 / 1 / 1 CONV | 0 / 1 / 1 / 1 ATTR |

The N speech-verb row reproduces the bead's probe exactly: fragments between inner marks are compared, so `three recoverable` fails, while both nested values pass green.

| CNF-302 quote of CNF-300, correct / `"nonee"` / `abortd` | N | A and C | B |
|---|---|---|---|
| pinned straight bytes | 0 / 0 / 0 | 1 / 1 / 1 CONV | 0 / 1 / 1 ATTR:CNF-300 |
| migrated curly | 0 / 1 / 1 ATTR | 0 / 1 / 1 ATTR | 0 / 1 / 1 ATTR |

So the pinned corpus carries a live, attributed, straight-nested citation that N never compares. B compares it as a whole in place. A and C compare it only after the migration.

Module-level analysis, script `tmp/fable/scripts/analysis.py`, log `tmp/fable/analysis/analysis.log`, wrapped `contains_quote` and diffed the full set of compared quotes, all extracted quotations, chunk lists and EXISTS results across N, A, B, C over Markdown and Lean docstrings:

- The only comparison-set change in every changing form is the CNF-302 citation becoming compared, and passing. Nothing previously compared is dropped. UNQUOTED stays at the baseline count.
- B additionally re-extracts two Lean docstring quotes in `Rescue.lean` and `Witnesses.lean` as whole spans ending in `rescue_exit: "unknown"`; both pass EXISTS.
- The A and C guard, run over the unmigrated base texts and every Lean docstring block, fires exactly once, at `10-conformance-checklist.md:3096`. Over the migrated texts it fires nowhere.
- Scanning every straight span in the corpus with the candidates' backtick scanner finds many spans wholly inside code, such as JSON fixtures, and exactly one that opens outside code and closes inside it: the CNF-302 site.

## Where B as printed breaks

B's `quotation_spans` is called from `quotations()` on each chunk, so the backtick pairing it uses is chunk-local, while its docstring says "Matching backtick runs are paragraph-local". The two differ whenever a chunk boundary falls inside a code span, which happens when an earlier code span in the same paragraph contains a sentence ender followed by whitespace, a list marker or a table bar. The current corpus has 24 such cut positions in two files, so the shape is not hypothetical.

Reproduction with the bead's exact API-63 wording, module-level, results in `analysis.log`:

| input | N | A, C | B |
|---|---|---|---|
| ``Run `e.g. first` and then `API-63` says "…nested…"``, `account_terminatd` | bad 0 | guard fires | bad 0 |
| same, possessive form, any plant | 0 compared | guard fires | 0 compared |
| same with ``See `a\n- b` then`` as the lead | bad 0 | guard fires | bad 0 |

The leading chunk ends inside the earlier code span, the citation's chunk starts with an unmatched backtick run, parity flips, the straight opener now sits inside a false code span, and B falls back to flat pairing: the exact pv-602 miss, silently, with no diagnostic. A and C compute code spans on the whole text with absolute positions and reject instead. This is why B's docstring as printed is inaccurate and why I cannot accept B as printed, even though every test the brief asked for passes on it.

## Repair B′, a distinct complete form

B′ is B's printed patch with `chunks()` also protecting paired inline code spans from cuts, so the chunk-local scan always pairs runs as the paragraph does, plus a docstring sentence and a self-test for the hazard shapes. Its `ci.yml` is byte-identical to B's; the checklist stays at the pinned bytes. Full checker patch against base: `tmp/fable/analysis/Bprime-vs-base.patch`. The delta from printed B is exactly:

```diff
--- B/tools/check_citations.py
+++ Bp/tools/check_citations.py
@@ -68,7 +68,9 @@
            straight marks inside such spans when selecting its closing mark.
            Its exact content, including nested quoted values, is then compared.
            Matching backtick runs are paragraph-local; fenced blocks receive
-           no special parsing. Curly spans and quotations opened inside code
+           no special parsing. Paired inline code spans, like paired quotations,
+           are never cut by a chunk boundary, so the per-chunk scan pairs runs
+           as the paragraph does. Curly spans and quotations opened inside code
            keep their existing extraction. This does not parse arbitrary nesting.
            What it cannot see: other balanced nested or mispaired straight/curly
            marks can still select the wrong span within a paragraph. Two stray
@@ -310,8 +312,17 @@
 
 
 def chunks(text):
-    """Apply SPLIT only outside paired quotations, regardless of their length."""
-    spans = iter(quotation_spans(text))
+    """Apply SPLIT only outside paired quotations and paired inline code spans.
+
+    A cut inside a code span would leave each neighbouring chunk an unmatched
+    backtick run, so quotations() would pair the chunk's remaining runs
+    differently from the paragraph and could open a straight quotation inside
+    a false code span. Protecting the span keeps the chunk-local scan equal to
+    the paragraph-local one.
+    """
+    protected = sorted([(start, end) for start, end, _ in quotation_spans(text)]
+                       + [(left - 1, right + 1) for left, right in inline_code_spans(text)])
+    spans = iter(protected)
     span = next(spans, None)
     start = pos = 0
     while boundary := SPLIT.search(text, pos):
@@ -996,6 +1007,14 @@
             prose = shapes[0] + '"' + wording + '"'
             assert list(chunks(prose)) == [prose]
         assert list(quotation_spans('"alpha beta\n\ngamma delta"')) == []
+        for lead in ['Run `e.g. first` and then ', 'See `a\n- b` then ']:
+            for shape in shapes[:2]:
+                prose = lead + shape + '"' + source + '"'
+                assert list(chunks(prose)) == [prose], prose
+                assert find({'probe.md': prose}, {}, reqs) == ([], [], 1), prose
+                for wrong in [prose.replace('account_terminated', 'account_terminatd', 1),
+                              prose.replace('"state"', '"stat"', 1)]:
+                    assert find({'probe.md': wrong}, {}, reqs)[0], wrong
     except AssertionError as exc:
         print(f'FAIL: nested inline-code citation: {exc}')
         return 1
```

B′ evidence, log `tmp/fable/analysis/bp-analysis.log` and `Bp-valid.log`, `Bp-ci.log`: real CLI exit 0 with all existing self-tests and the new one passing; B's embedded CI control exit 0 against B′; every hazard shape, including the colon form, now compares the whole quotation and fails each plant; comparison set and UNQUOTED signatures identical to B; zero chunk cuts inside code spans remain. Disclosed behaviour change: 13 chunks merge, one blockquote line in `02-provider-contract.md` and fenced blocks in `lean-01.md`, with no verdict change. B′ has not been read by the other seats and must not be merged silently.

## Verdicts and reasons

- **C, ACCEPT, preferred.** Additive guard, no extraction change, fails closed on the parity hazard, mirrors `find()`'s ownership and history rules exactly, and matches the owner-approved triage direction. Its cost is one two-character migration at a site that is itself proof the convention gets forgotten, and the guard is what makes forgetting impossible from then on. It keeps a quotation wholly inside code compared as today.
- **A, ACCEPT.** Identical to C except it also rejects a quotation wholly inside code with advice that does not fit that case. No current site is affected, so acceptable, but strictly less precise than C.
- **B, CANNOT ACCEPT as printed.** Reproducible silent regression to the pv-602 miss in a shape the corpus already contains, and a docstring whose paragraph-local claim is false for `quotations()`. B′ removes both and I would accept it.
- **N, CANNOT ACCEPT.** Author memory is the only protection, the owner has asked for checker enforcement, and the pin already holds an attributed straight-nested citation that no rule compares.

**Checked or normative verdicts lost or changed:** none in any form. No Lean declaration, theorem, guard hypothesis, fixture or baseline changes. A and C alter two punctuation characters in CNF-302's test prose; the assertion content is unchanged. **Collateral flips:** A and C reject the pinned CNF-302 bytes until migrated, A additionally rejects any future citation wholly inside code; B and B′ reject no valid syntax; B′ merges chunks at code spans containing sentence boundaries.

**Does the brief contradict itself?** No. Every claim I could test held: the raw guard rejects the correct CNF-302 bytes, B compares them whole, A's wholly-inside-code rejection is tested and C's exemption is tested, N misses all three possessive plants. One precision point: the brief says no comparison matcher changes in any form, which is true, but B does rewrite the extraction functions `chunks()` and `quotations()`, as the brief's own description of B implies. My execution broke nothing the brief claimed; what it broke is B's docstring claim of paragraph-local matching.

**Strongest no-change counterargument, as written on request and not my vote:** the curly convention is documented in the checker docstring and the manager brief, every site landed after 2026-10-21 except one followed it, the curly path is fully tested, and each changing form adds a second scanner whose own edge cases are new attack surface, as B's parity hazard shows. The reply is that the one exception is a live, attributed, uncompared citation today, which is exactly the failure the owner's enforcement preference exists to prevent.
