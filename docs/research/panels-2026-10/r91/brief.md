# Panel L r91 — nested values in attributed straight quotations

Read this brief and notes.md whole. Your independent clone is pinned at **aeb7ff65369238212903d6b60b8ae1622f5c93d8**, origin/master after Panel E prep PR #50. This turn only launches this reading panel. pv-602 stays deferred until a settled exact form receives the owner's approval, because this changes check strength.

The concrete problem: a document quotes an error reason and puts quotation marks around both the whole quotation and the reason inside it. The checker can stop at the inner mark. Changing `account_terminated` to `account_terminatd` can then stay green. Using curly outer marks currently makes the checker compare the value; the author has to remember to do that. The prepared question asks whether the checker should enforce that convention or extract the whole quotation itself.

Pinned clone read only: no source, Git, tracker or panel-record writes; no commit, push, checkout, reset, stash, clean, PR contact, subagents or background work. Verification writes only under `/var/tmp/provisiond-panel-r91/tmp/<your-seat>/`, in scratch copies. Do not read credential/session/config locations (`~/.claude`, `~/.codex`, `~/.grok`, auth files, kubeconfig, browser profiles), another reader's output/clone, other panel folders, pgharness or the main checkout. The named shared packet files are allowed. No `lake build` and no full check-all: this host has at most two simultaneous formal builds. Use the supplied index and run the actual Python CLI unpiped. Return a substantive final answer within the 3600-second wrapper limit; aim for <=2200 words plus any complete repaired patch. Do not wait on another reader.

**apply notes.md rule 6 exactly as written; this prompt adds no void rule.**

## Read the complete shared packet

Read `source-evidence.md` whole: it prints the prepared owner-queue entry, the bead's entire description and comments, reopening evidence, current owning passages with id and path:line, and the author's outer-mark convention. The bead remains deferred in the pin. The original A–E means the October 21 panels, completed in the October 26 handoff. Later history-filter repairs did not settle extraction. No question is dropped.

Read `existing-checker.py` whole. This is the exact pinned tools/check_citations.py, including every existing self-test routine and case-generating loop. Read `existing-quote-content-cases.json` whole: the generated source/quote pairs, including every existing valid case and corruption variant; all requirement, cited-document and cited-ADR pools, Markdown and extracted Lean paths and both elision spellings remain in the unchanged routine. Read `current-attributions.json` whole: every current QUOTED comparison, with owner, exact quote, chunk_id and current pass/finding flag. Read `current-chunks.json` whole for the full source chunk of each record; chunk_id is its array index. The standing baseline findings are labelled `passes: false`, not asserted valid. Read `current-raw-attributed-spans.json` whole too: raw attributed spans before length/word/history filtering, including short prefixes that ordinary comparison misses. Array lengths belong to those artifacts; none of these lists is replaced by a prose count.

Every exact candidate patch is printed below in full. The full resulting files are also under candidates/<form>/; the patch plus the exact shared base defines every byte. N has an empty patch and byte-identical files. The CI negative control's entire Python body is both in the workflow patch and candidates/<form>/ci-control.py; verify they agree. No baseline, Lean declaration, existing self-test routine or comparison matcher is changed by any form. New self-tests are appended and wired into the real CLI, never substituted for old cases. `verify.py` is a panel-only testing aid, not a proposed repository file.

## One discovered current valid citation matters

`source-evidence.md` quotes CNF-302's citation of CNF-300 at `10-conformance-checklist.md:3095–3096` exactly. It already nests straight-quoted `none` and `unknown` inside code in straight outer marks. This citation is not the original OPS-43 site. The literal cheap guard, applied without a prose migration, rejects it even when its content is correct. Both guard candidates A and C therefore include a fully printed two-mark migration at this site to curly outer marks; its quoted content is unchanged. The unconverted correct citation remains in the preservation evidence, and you must disclose its changed syntax acceptance. Do not equate keeping its content with retaining acceptance of its old punctuation. B leaves its bytes unchanged and is intended to compare it as a whole. This is why a clean-corpus check is needed in addition to a planted typo.

## Exact forms to assess

- **A — literal cheap guard plus the required current-site outer-mark migration.** Before reach filtering, reject each current attributed raw straight span whose closing mark is inside a matching backtick span. The diagnostic is exactly `FAIL: <file>:<line>: <owner> straight quotation closes inside inline code; use curly outer marks (“…”).` It preserves existing historical/teaching suppression and attribution ownership; Markdown-only colon reach stays Markdown-only. A also rejects a quotation wholly inside code; that behavior is explicitly tested and must be assessed, even if absent in current input. Straight nested quotations fail on syntax whether the value is correct or wrong. Curly correct quotations pass and corruptions must fail content comparison.
- **B — code-span-aware extraction.** If an outside-code straight opener would close inside a paired backtick span, find its closing mark outside code within the same paragraph, use the exact full source slice, and protect that full span from chunk splitting. Existing curly extraction and spans opened inside code retain their path. No prose migration. The diagnostic for a changed nested value remains the existing `attributes to API-63 a phrase API-63 does not contain` output. This is bounded backtick-run handling, not a general Markdown parser or arbitrary nested-quotation parser; assess that exact scope.
- **C — narrower cheap guard plus the same two-mark migration.** A's package, but reject only when the opening mark is outside code. It retains quotations wholly inside code. This is a distinct exact form, not silently counted as A.
- **N — no change.** Keep the pinned checker, docstring, self-tests, CI and prose byte for byte, relying on the existing author convention. This has no new diagnostic, self-test or CI control. The absence of these changes is the complete N form. Reproduce and report its missed corruptions rather than implying that a clean gate repairs them. Consider the owner's stated preference for checker enforcement, not author memory, in deciding whether N is defensible.

For A/B/C the exact complete self-test and CI control appear in the patches. Their backtick scanner matches equal-length runs inside a paragraph, treats unmatched runs as literal, and gives fences no special parsing. Do not assume a stronger grammar. The full package, including docstring limitations, must be acceptable as printed; a repair must be supplied as a distinct complete patch and cannot be silently merged by the manager.

## Independent execution required from every reader

First inspect the exact candidate code, diagnostic, self-tests and CI control together. Run all existing self-tests through the real CLI on every changing candidate and prove the pinned clean corpus remains green for the full package. Check the unconverted CNF-302 case separately: decide whether the guard's rejection and printed migration are an acceptable convention enforcement or a reason to require extraction. Preserve every inherited valid fixture and corruption case. Do not weaken contains_quote(), corresponding_roles(), span_content(), the apostrophe rules, the baseline or the existing tests to make a candidate pass. pv-erp's alternative-occurrence problem (R7/R8) is out of scope; do not attempt its search/optimization or make it a condition for this decision.

Use your own clone as --source and a fresh allowed work directory:

```sh
python3 /var/tmp/provisiond-panel-r91/verify.py --source "$PWD" --work /var/tmp/provisiond-panel-r91/tmp/<your-seat>/verification
```

Read the testing aid before running it. It copies only into your scratch, installs each complete candidate there, copies the supplied built index, runs the real CLI, and extracts/runs the exact embedded workflow control. No formal build is invoked. Its N probe changes each named value in the live OPS-43 bare-possessive citation after switching the outer marks to straight; record the actual exits, including misses. The changing candidates' embedded controls assert valid current and restored inputs exit 0; curly exact input succeeds, each named corruption exits 1; A/C's correct straight form also exits 1 with the convention diagnostic; B's correct straight form exits 0 and only corruptions exit 1. This distinguishes syntax rejection from comparison.

Each reader must personally verify that changing the bead's nested `account_terminated` and `"state"` values fails on every changing candidate. Also verify its `two recoverable` -> `three recoverable` plant and both direct possessive and speech-verb forms; the new self-test includes the forms plus noun/colon, Markdown/extracted Lean and one-/two-backtick paths. Inspect the actual tests so the required failure cannot be satisfied by some unrelated baseline error. Report real command, exit and named diagnostic, with a path to your logs. Add a small adversarial case if useful. If a candidate fails, say which exact valid input or corruption breaks it and supply the full repair separately; do not count a hypothetical repaired form as accepted.

## The prepared question (one technical decision)

Does the previously approved cheap rule—reject an attributed straight-quoted span that ends inside inline code, with a diagnostic pointing to the existing outer-mark convention—catch the bead's nested-value corruptions without rejecting valid current citations? Or is code-span-aware quotation extraction necessary?

Answer the raw unconverted question as well as the complete migrated packages above. Prefer an enforced rule over author memory, while distinguishing the exact behavior and cost of each candidate. Give a final preferred A/B/C/N or complete exact alternative, then separately ACCEPT / CANNOT ACCEPT for each A/B/C/N with the strongest reason. State any checked/normative verdict lost or changed, including collateral syntax flips. Ask whether this brief contradicts itself, identify anything it claimed that your execution broke, and label your strongest no-change counterargument as written on request rather than your vote. The panel settles a technical recommendation only; owner approval, not this tally, authorizes a later check-strength change. This turn launches no follow-on round or implementation.

## Exact candidate A — complete patch

```diff
--- a/tools/check_citations.py
+++ b/tools/check_citations.py
@@ -64,7 +64,11 @@
            with a source file and line, even in historical/teaching prose or
            spans outside the word/length limits. Each paragraph is checked
            independently; separately extracted Lean docstrings stay separate.
-           What it cannot see: balanced nested or mispaired straight/curly
+           Attributed raw straight spans that close inside a paired backtick
+           span fail before word/length filtering, with file, line and owner;
+           use curly outer marks (“…”) for a citation containing straight-quoted
+           values. This enforces the existing outer-mark convention.
+           What it cannot see: other balanced nested or mispaired straight/curly
            marks can still select the wrong span within a paragraph. Two stray
            straight marks, such as inch marks surrounding a real quotation,
            can pair with its marks and hide it, including in a Lean docstring:
@@ -194,7 +198,8 @@
 A scan discovering no source .lean files outside .lake fails even with a valid
 index and empty Lean exemption families. Files without docstrings still count.
 
-Exit 0 = clean, 1 = unpaired double marks, an unverifiable quote, a Lean docstring
+Exit 0 = clean, 1 = unpaired double marks, a rejected inline-code quotation end,
+an unverifiable quote, a Lean docstring
 quote found nowhere, an unresolved name, a new finding or stale baseline entry,
 a damaged baseline, an empty Lean source scan, an unterminated Lean block comment
 or a failed extractor case,
@@ -252,6 +257,67 @@
 # Pair every span before filtering its length. A short or overlong span's closing
 # mark must never be recycled as the opening mark of the next quotation.
 QUOTE = re.compile(r'“((?:[^”\n]|\n(?!\s*\n))*)”|"((?:[^"\n]|\n(?!\s*\n))*)"')
+
+
+def inline_code_spans(text):
+    """Content bounds of matching backtick runs, confined to one paragraph.
+
+    This is the gate's bounded prose scanner, not a Markdown parser. A run
+    closes only on a run of the same length; a different-length run is content.
+    Unmatched runs are literal. Fenced blocks receive no special treatment.
+    """
+    offset = 0
+    for paragraph in re.split(r'(\n\s*\n)', text):
+        runs = list(re.finditer(r'`+', paragraph))
+        i = 0
+        while i < len(runs):
+            j = next((j for j in range(i + 1, len(runs))
+                      if len(runs[j].group()) == len(runs[i].group())), None)
+            if j is None:
+                i += 1
+            else:
+                yield offset + runs[i].end(), offset + runs[j].start()
+                i = j + 1
+        offset += len(paragraph)
+
+
+def nested_inline_code_errors(docs, first_line=1):
+    """Attributed raw straight spans that close in a paired backtick span.
+
+    Inspect raw pairs before word/length filtering: the first fragment of the
+    defective bare-possessive citation has fewer than four words.
+    """
+    for filename, text in docs.items():
+        lean = filename.endswith('.lean')
+        codes = list(inline_code_spans(text))
+        offset = 0
+        for sent in chunks(text):
+            start = text.index(sent, offset)
+            offset = start + len(sent)
+            historical = HISTORICAL.search(sent)
+            if TEACHING.search(sent) or (lean and historical):
+                continue
+            speech = ATTRIB.search(sent)
+            direct = list(POSSESSIVE.finditer(sent))
+            if not lean:
+                direct += list(COLON.finditer(sent))
+            for match in QUOTE.finditer(sent):
+                if match.group(2) is None:
+                    continue
+                owners = []
+                if speech and match.start() > speech.start():
+                    owners.append(speech.group(1) or speech.group(3))
+                owners += [m.group(1) for m in direct if m.end() == match.start()]
+                if not owners or (not lean and historical
+                                  and historical_quote(sent, match.start(), match.group(2))):
+                    continue
+                closing = start + match.end() - 1
+                opening = start + match.start()
+                if not any(left <= closing < right for left, right in codes):
+                    continue
+                line = text.count('\n', 0, closing) + first_line
+                for owner in dict.fromkeys(owners):
+                    yield filename, line, owner
 
 
 def chunks(text):
@@ -614,7 +680,7 @@
             yield (start, body) if with_offsets else body
 
 
-def load_lean_docstrings(mark_errors=None):
+def load_lean_docstrings(mark_errors=None, nested_errors=None):
     """Keep Lean prose separate from load()'s requirement and name sources."""
     docs = {}
     for directory, dirs, files in os.walk(os.path.join(ROOT, 'tools', 'formal')):
@@ -635,6 +701,10 @@
                         first_line = text.count('\n', 0, start) + 1
                         mark_errors.extend((filename, line, kind)
                                            for line, kind in unpaired_marks(body, first_line))
+                if nested_errors is not None:
+                    for start, body in blocks:
+                        first_line = text.count('\n', 0, start) + 1
+                        nested_errors.extend(nested_inline_code_errors({filename: body}, first_line))
                 docs[filename] = '\n\n'.join(body for _, body in blocks)
     return docs
 
@@ -904,6 +974,55 @@
     return 0
 
 
+def check_nested_inline_code():
+    """Nested values, raw short prefixes, input kinds and existing outer marks."""
+    source = '`details.reason: "account_terminated"` where the status is `terminated` and `"state"` for the two recoverable statuses, since presenting an unreachable account as a permanent termination is false, and with `retryable: false` for `"account_terminated"` and `retryable: true` for `"state"` on both the error and the operation view'
+    reqs = {'API-63': ('source.md', source)}
+    shapes = ["`API-63` says ", "`API-63`'s ", "`API-63`'s rule that ",
+              "`API-63`: "]
+    try:
+        for filename in ['probe.md', 'probe.lean']:
+            for shape in shapes:
+                if filename.endswith('.lean') and shape == shapes[-1]:
+                    continue  # the Markdown-only colon rule is unchanged
+                for ticks in ['`', '``']:
+                    wording = source.replace('`', ticks)
+                    owners = {'API-63': ('source.md', wording)}
+                    for left, right in [('“', '”'), ('"', '"')]:
+                        prose = shape + left + wording + right
+                        if filename.endswith('.lean'):
+                            prose = '\n\n'.join(docstrings('/-- ' + prose + ' -/')).strip()
+                        assert not list(unpaired_marks(prose))
+                        changed = [prose.replace('account_terminated', 'account_terminatd', 1),
+                                   prose.replace('"state"', '"stat"', 1),
+                                   prose.replace('two recoverable', 'three recoverable', 1)]
+                        errors = list(nested_inline_code_errors({filename: prose}))
+                        assert bool(errors) == (left == '"'), (filename, shape, ticks, left, errors)
+                        for wrong in changed:
+                            if left == '"':
+                                assert list(nested_inline_code_errors({filename: wrong})), wrong
+                            else:
+                                assert not list(nested_inline_code_errors({filename: wrong})), wrong
+                                assert find({filename: wrong}, {}, owners)[0], wrong
+                        if left == '“':
+                            assert find({filename: prose}, {}, owners) == ([], [], 1)
+        plain = '`API-63` says "alpha beta gamma delta"'
+        assert find({'probe.md': plain}, {}, {'API-63': ('source.md', 'alpha beta gamma delta')}) == ([], [], 1)
+        wrapped = '`API-63` says `"alpha beta gamma delta"`'
+        assert bool(list(nested_inline_code_errors({'probe.md': wrapped}))) == True
+        for prefix in ['Previously ', 'For example, ']:
+            nested = prefix + shapes[0] + '"' + source + '"'
+            assert not list(nested_inline_code_errors({'probe.md': nested}))
+        assert not list(nested_inline_code_errors({'probe.md': '"' + source + '"'}))
+        short = '`API-63` says "now"'
+        assert not list(nested_inline_code_errors({'probe.md': short}))
+    except AssertionError as exc:
+        print(f'FAIL: nested inline-code citation: {exc}')
+        return 1
+    print('PASS: nested inline-code citations: exact marks, short prefixes and value corruptions')
+    return 0
+
+
 def check_sentence_boundaries():
     """Keep closing marks, then protect paired spans at the actual cut position."""
     name = 'closing markup'
@@ -1399,7 +1518,7 @@
     if (check_sentence_boundaries() or check_docstrings() or check_quotations()
             or check_withdrawal_history() or check_markdown_quote_reach()
             or check_possessives() or check_colons()
-            or check_quote_content()):
+            or check_quote_content() or check_nested_inline_code()):
         return 1
     try:
         with open(BASELINE) as source:
@@ -1420,7 +1539,8 @@
     docs, adrs, reqs = load()
     mark_errors = [(f, line, kind) for f, text in docs.items()
                    for line, kind in unpaired_marks(text)]
-    lean = load_lean_docstrings(mark_errors)
+    nested_errors = []
+    lean = load_lean_docstrings(mark_errors, nested_errors)
     if not lean:
         print("FAIL: no source .lean files discovered under tools/formal (excluding .lake); "
               "restore the Lean sources and check the scan path. A preexisting index "
@@ -1433,6 +1553,12 @@
             print(f"  {f}:{line}: unpaired {kind} double quotation marks")
     if mark_errors:
         print(f"FAIL: {len(mark_errors)} quotation mark source-line finding(s)")
+        return 1
+    nested_errors += list(nested_inline_code_errors(docs))
+    for filename, line, owner in nested_errors:
+        print(f"FAIL: {filename}:{line}: {owner} straight quotation closes inside inline code; "
+              "use curly outer marks (“…”).")
+    if nested_errors:
         return 1
     bad, unquoted, markdown_compared = find(docs, adrs, reqs)
     lean_bad, _, compared = find(lean, adrs, reqs, corpus=docs)
--- a/.github/workflows/ci.yml
+++ b/.github/workflows/ci.yml
@@ -201,6 +201,53 @@
           fi
           grep -q 'attributes to OVR-1 a phrase OVR-1 does not contain' citations.log
           echo "citation gate correctly rejected an unverifiable quoted attribution"
+
+      - name: Prove the citation gate rejects nested inline-code value corruptions
+        if: matrix.shard == 0
+        run: |
+          python3 - <<'PY'
+          from pathlib import Path
+          import shutil
+          import subprocess
+          from tempfile import TemporaryDirectory
+
+          # Exercise the actual CLI in an isolated full copy, retaining the built index.
+          with TemporaryDirectory(prefix='nested-citation-') as directory:
+              root = Path(directory) / 'repo'
+              shutil.copytree('.', root, ignore=shutil.ignore_patterns('.git', '__pycache__'))
+              path = root / '03-operation-lifecycle.md'
+              original = path.read_text()
+              prefix = "with `API-63`'s “"
+              assert original.count(prefix) == 1
+              start = original.index(prefix) + len(prefix) - 1
+              end = original.index('”', start) + 1
+              quoted = original[start + 1:end - 1]
+              assert '"account_terminated"' in quoted and '"state"' in quoted
+              assert 'two recoverable' in quoted
+
+              def run(text, expected, diagnostic=None):
+                  path.write_text(text)
+                  result = subprocess.run(['python3', 'tools/check_citations.py'], cwd=root,
+                                          capture_output=True, text=True)
+                  assert result.returncode == expected, (expected, result.returncode, result.stdout, result.stderr)
+                  if diagnostic:
+                      assert diagnostic in result.stdout, result.stdout
+
+              run(original, 0)
+              straight = original[:start] + '"' + quoted + '"' + original[end:]
+              run(straight, 1, 'API-63 straight quotation closes inside inline code; use curly outer marks (“…”).')
+              for before, after in [('account_terminated', 'account_terminatd'),
+                                    ('"state"', '"stat"'), ('two recoverable', 'three recoverable')]:
+                  changed = quoted.replace(before, after, 1)
+                  assert changed != quoted
+                  # The cited owner and every other source stay unchanged.
+                  curly_wrong = original[:start] + '“' + changed + '”' + original[end:]
+                  straight_wrong = original[:start] + '"' + changed + '"' + original[end:]
+                  run(curly_wrong, 1, 'attributes to API-63 a phrase API-63 does not contain')
+                  run(straight_wrong, 1, 'API-63 straight quotation closes inside inline code; use curly outer marks (“…”).')
+              run(original, 0)
+          print('PASS: live nested citation: valid source, three corruptions and restoration')
+          PY
 
       # Exercise the unchanged live site as well as the one-word plant: a skip
       # must not pass for a successful comparison. The control copies the index
--- a/10-conformance-checklist.md
+++ b/10-conformance-checklist.md
@@ -3093,8 +3093,8 @@
 
       Separately construct `CNF-300`'s unresolved failed-rescue-exit row with `disk_effect` `none` and
       `rescue_exit` `unknown` without a prior restore, then back it up and actually restore it
-      (`CNF-300`: "`disk_effect: "none"` (it aborted before writing) and `rescue_exit:
-      "unknown"`"). It
+      (`CNF-300`: “`disk_effect: "none"` (it aborted before writing) and `rescue_exit:
+      "unknown"`”). It
       remains `needs_reconciliation`, acquires `true` provenance before startup, and now renders
       `unknown`/`unknown`. This is a declared conservative change on a row already awaiting
       resolution. For settled rows with established `false` provenance, an actual restore does not
```

## Exact candidate B — complete patch

```diff
--- a/tools/check_citations.py
+++ b/tools/check_citations.py
@@ -64,7 +64,13 @@
            with a source file and line, even in historical/teaching prose or
            spans outside the word/length limits. Each paragraph is checked
            independently; separately extracted Lean docstrings stay separate.
-           What it cannot see: balanced nested or mispaired straight/curly
+           A straight quotation opened outside a paired backtick span skips
+           straight marks inside such spans when selecting its closing mark.
+           Its exact content, including nested quoted values, is then compared.
+           Matching backtick runs are paragraph-local; fenced blocks receive
+           no special parsing. Curly spans and quotations opened inside code
+           keep their existing extraction. This does not parse arbitrary nesting.
+           What it cannot see: other balanced nested or mispaired straight/curly
            marks can still select the wrong span within a paragraph. Two stray
            straight marks, such as inch marks surrounding a real quotation,
            can pair with its marks and hide it, including in a Lean docstring:
@@ -124,7 +130,7 @@
   EXISTS   Every quote of four or more normalised words in a Lean docstring
            must appear somewhere in the corpus -- every root *.md plus
            docs/adr/*.md -- whether or not its chunk carries an attribution
-           (`pv-vwe.25`, decided 2026-10-01). A quote is what QUOTE matches:
+           (`pv-vwe.25`, decided 2026-10-01). A quote is what quotations() yields:
            a paired span of at most 400 characters containing at least four
            normalised words. Longer Lean quotations are counted by neither rule,
            but their marks are consumed before scanning the next span.
@@ -143,7 +149,7 @@
            requirement passes, because no owner is consulted; a misquote
            that happens to match text anywhere in the corpus passes, including
            `11-open-findings.md`'s and the ADRs' records of withdrawn or wrong
-           wording; and a quote QUOTE mispairs is as invisible here as under
+           wording; and a quote the scanner mispairs is as invisible here as under
            QUOTED, for the reasons given there. Explicit attribution syntax is
            the owner's named direction if verbatim-but-misattributed quotes
            start to matter (`pv-vwe.25`, the decision of 2026-10-01).
@@ -254,17 +260,66 @@
 QUOTE = re.compile(r'“((?:[^”\n]|\n(?!\s*\n))*)”|"((?:[^"\n]|\n(?!\s*\n))*)"')
 
 
+def inline_code_spans(text):
+    """Content bounds of matching backtick runs, confined to one paragraph.
+
+    This is the gate's bounded prose scanner, not a Markdown parser. A run
+    closes only on a run of the same length; a different-length run is content.
+    Unmatched runs are literal. Fenced blocks receive no special treatment.
+    """
+    offset = 0
+    for paragraph in re.split(r'(\n\s*\n)', text):
+        runs = list(re.finditer(r'`+', paragraph))
+        i = 0
+        while i < len(runs):
+            j = next((j for j in range(i + 1, len(runs))
+                      if len(runs[j].group()) == len(runs[i].group())), None)
+            if j is None:
+                i += 1
+            else:
+                yield offset + runs[i].end(), offset + runs[j].start()
+                i = j + 1
+        offset += len(paragraph)
+
+
+def quotation_spans(text):
+    """Yield exact (start, end, content) slices; extend only crossed code ends.
+
+    A straight opener outside code closes at the next straight mark outside
+    code, when flat pairing would close inside code. Curly spans and straight
+    spans opened inside code retain their existing extraction. Blank lines
+    remain hard boundaries. The existing unpaired-mark guard still runs first.
+    """
+    codes = list(inline_code_spans(text))
+    cursor = 0
+    while match := QUOTE.search(text, cursor):
+        start, end = match.span()
+        wording = match.group(1) if match.group(1) is not None else match.group(2)
+        inside = lambda pos: any(left <= pos < right for left, right in codes)
+        if match.group(2) is not None and not inside(start) and inside(end - 1):
+            boundary = re.search(r'\n\s*\n', text[start:])
+            limit = start + boundary.start() if boundary else len(text)
+            closing = text.find('"', end, limit)
+            while closing >= 0 and inside(closing):
+                closing = text.find('"', closing + 1, limit)
+            if closing >= 0:
+                end = closing + 1
+                wording = text[start + 1:closing]
+        yield start, end, wording
+        cursor = end
+
+
 def chunks(text):
     """Apply SPLIT only outside paired quotations, regardless of their length."""
-    spans = iter(QUOTE.finditer(text))
+    spans = iter(quotation_spans(text))
     span = next(spans, None)
     start = pos = 0
     while boundary := SPLIT.search(text, pos):
         pos = boundary.end()
         cut = boundary.start('sentence') if boundary.group('sentence') else boundary.start()
-        while span and span.end() <= cut:
+        while span and span[1] <= cut:
             span = next(spans, None)
-        if span and span.start() < cut < span.end():
+        if span and span[0] < cut < span[1]:
             continue
         yield text[start:cut]
         start = boundary.end()
@@ -284,10 +339,9 @@
 
 def quotations(text, max_length=400):
     """Yield (position, wording) after pairing, then applying the reach limits."""
-    for match in QUOTE.finditer(text):
-        wording = match.group(1) or match.group(2) or ""
+    for start, _end, wording in quotation_spans(text):
         if (max_length is None or len(wording) <= max_length) and len(norm(wording).split()) >= 4:
-            yield match.start(), wording
+            yield start, wording
 
 
 DOC = re.compile(r"`(\d\d-[a-z-]+\.md|README\.md|CONTEXT\.md|AGENTS\.md)`")
@@ -904,6 +958,51 @@
     return 0
 
 
+def check_nested_inline_code():
+    """Nested values, raw short prefixes, input kinds and existing outer marks."""
+    source = '`details.reason: "account_terminated"` where the status is `terminated` and `"state"` for the two recoverable statuses, since presenting an unreachable account as a permanent termination is false, and with `retryable: false` for `"account_terminated"` and `retryable: true` for `"state"` on both the error and the operation view'
+    reqs = {'API-63': ('source.md', source)}
+    shapes = ["`API-63` says ", "`API-63`'s ", "`API-63`'s rule that ",
+              "`API-63`: "]
+    try:
+        for filename in ['probe.md', 'probe.lean']:
+            for shape in shapes:
+                if filename.endswith('.lean') and shape == shapes[-1]:
+                    continue  # the Markdown-only colon rule is unchanged
+                for ticks in ['`', '``']:
+                    wording = source.replace('`', ticks)
+                    owners = {'API-63': ('source.md', wording)}
+                    for left, right in [('“', '”'), ('"', '"')]:
+                        prose = shape + left + wording + right
+                        if filename.endswith('.lean'):
+                            prose = '\n\n'.join(docstrings('/-- ' + prose + ' -/')).strip()
+                        assert not list(unpaired_marks(prose))
+                        changed = [prose.replace('account_terminated', 'account_terminatd', 1),
+                                   prose.replace('"state"', '"stat"', 1),
+                                   prose.replace('two recoverable', 'three recoverable', 1)]
+                        assert list(quotations(prose)) == [(len(shape), wording)], prose
+                        assert find({filename: prose}, {}, owners) == ([], [], 1), prose
+                        assert exists({filename: prose}, [wording]) == ([], 1), prose
+                        for wrong in changed:
+                            assert find({filename: wrong}, {}, owners)[0], wrong
+                            assert exists({filename: wrong}, [wording])[0], wrong
+        plain = '`API-63` says "alpha beta gamma delta"'
+        assert find({'probe.md': plain}, {}, {'API-63': ('source.md', 'alpha beta gamma delta')}) == ([], [], 1)
+        wrapped = '`API-63` says `"alpha beta gamma delta"`'
+        assert list(quotations(wrapped)) == [(wrapped.index('"'), 'alpha beta gamma delta')]
+        assert find({'probe.md': wrapped}, {}, {'API-63': ('source.md', 'alpha beta gamma delta')}) == ([], [], 1)
+        for gap in ['. ', '\n- ', '\n|']:
+            wording = source.replace(' where', gap + 'where', 1)
+            prose = shapes[0] + '"' + wording + '"'
+            assert list(chunks(prose)) == [prose]
+        assert list(quotation_spans('"alpha beta\n\ngamma delta"')) == []
+    except AssertionError as exc:
+        print(f'FAIL: nested inline-code citation: {exc}')
+        return 1
+    print('PASS: nested inline-code citations: exact marks, short prefixes and value corruptions')
+    return 0
+
+
 def check_sentence_boundaries():
     """Keep closing marks, then protect paired spans at the actual cut position."""
     name = 'closing markup'
@@ -1399,7 +1498,7 @@
     if (check_sentence_boundaries() or check_docstrings() or check_quotations()
             or check_withdrawal_history() or check_markdown_quote_reach()
             or check_possessives() or check_colons()
-            or check_quote_content()):
+            or check_quote_content() or check_nested_inline_code()):
         return 1
     try:
         with open(BASELINE) as source:
--- a/.github/workflows/ci.yml
+++ b/.github/workflows/ci.yml
@@ -201,6 +201,53 @@
           fi
           grep -q 'attributes to OVR-1 a phrase OVR-1 does not contain' citations.log
           echo "citation gate correctly rejected an unverifiable quoted attribution"
+
+      - name: Prove the citation gate rejects nested inline-code value corruptions
+        if: matrix.shard == 0
+        run: |
+          python3 - <<'PY'
+          from pathlib import Path
+          import shutil
+          import subprocess
+          from tempfile import TemporaryDirectory
+
+          # Exercise the actual CLI in an isolated full copy, retaining the built index.
+          with TemporaryDirectory(prefix='nested-citation-') as directory:
+              root = Path(directory) / 'repo'
+              shutil.copytree('.', root, ignore=shutil.ignore_patterns('.git', '__pycache__'))
+              path = root / '03-operation-lifecycle.md'
+              original = path.read_text()
+              prefix = "with `API-63`'s “"
+              assert original.count(prefix) == 1
+              start = original.index(prefix) + len(prefix) - 1
+              end = original.index('”', start) + 1
+              quoted = original[start + 1:end - 1]
+              assert '"account_terminated"' in quoted and '"state"' in quoted
+              assert 'two recoverable' in quoted
+
+              def run(text, expected, diagnostic=None):
+                  path.write_text(text)
+                  result = subprocess.run(['python3', 'tools/check_citations.py'], cwd=root,
+                                          capture_output=True, text=True)
+                  assert result.returncode == expected, (expected, result.returncode, result.stdout, result.stderr)
+                  if diagnostic:
+                      assert diagnostic in result.stdout, result.stdout
+
+              run(original, 0)
+              straight = original[:start] + '"' + quoted + '"' + original[end:]
+              run(straight, 0)
+              for before, after in [('account_terminated', 'account_terminatd'),
+                                    ('"state"', '"stat"'), ('two recoverable', 'three recoverable')]:
+                  changed = quoted.replace(before, after, 1)
+                  assert changed != quoted
+                  # The cited owner and every other source stay unchanged.
+                  curly_wrong = original[:start] + '“' + changed + '”' + original[end:]
+                  straight_wrong = original[:start] + '"' + changed + '"' + original[end:]
+                  run(curly_wrong, 1, 'attributes to API-63 a phrase API-63 does not contain')
+                  run(straight_wrong, 1, 'attributes to API-63 a phrase API-63 does not contain')
+              run(original, 0)
+          print('PASS: live nested citation: valid source, three corruptions and restoration')
+          PY
 
       # Exercise the unchanged live site as well as the one-word plant: a skip
       # must not pass for a successful comparison. The control copies the index
```

## Exact candidate C — complete patch

```diff
--- a/tools/check_citations.py
+++ b/tools/check_citations.py
@@ -64,7 +64,13 @@
            with a source file and line, even in historical/teaching prose or
            spans outside the word/length limits. Each paragraph is checked
            independently; separately extracted Lean docstrings stay separate.
-           What it cannot see: balanced nested or mispaired straight/curly
+           Attributed raw straight spans that close inside a paired backtick
+           span fail before word/length filtering, with file, line and owner;
+           use curly outer marks (“…”) for a citation containing straight-quoted
+           values. This enforces the existing outer-mark convention.
+           This guard applies only when the opening mark is outside code;
+           a quotation wholly inside code keeps its existing comparison.
+           What it cannot see: other balanced nested or mispaired straight/curly
            marks can still select the wrong span within a paragraph. Two stray
            straight marks, such as inch marks surrounding a real quotation,
            can pair with its marks and hide it, including in a Lean docstring:
@@ -194,7 +200,8 @@
 A scan discovering no source .lean files outside .lake fails even with a valid
 index and empty Lean exemption families. Files without docstrings still count.
 
-Exit 0 = clean, 1 = unpaired double marks, an unverifiable quote, a Lean docstring
+Exit 0 = clean, 1 = unpaired double marks, a rejected inline-code quotation end,
+an unverifiable quote, a Lean docstring
 quote found nowhere, an unresolved name, a new finding or stale baseline entry,
 a damaged baseline, an empty Lean source scan, an unterminated Lean block comment
 or a failed extractor case,
@@ -252,6 +259,69 @@
 # Pair every span before filtering its length. A short or overlong span's closing
 # mark must never be recycled as the opening mark of the next quotation.
 QUOTE = re.compile(r'“((?:[^”\n]|\n(?!\s*\n))*)”|"((?:[^"\n]|\n(?!\s*\n))*)"')
+
+
+def inline_code_spans(text):
+    """Content bounds of matching backtick runs, confined to one paragraph.
+
+    This is the gate's bounded prose scanner, not a Markdown parser. A run
+    closes only on a run of the same length; a different-length run is content.
+    Unmatched runs are literal. Fenced blocks receive no special treatment.
+    """
+    offset = 0
+    for paragraph in re.split(r'(\n\s*\n)', text):
+        runs = list(re.finditer(r'`+', paragraph))
+        i = 0
+        while i < len(runs):
+            j = next((j for j in range(i + 1, len(runs))
+                      if len(runs[j].group()) == len(runs[i].group())), None)
+            if j is None:
+                i += 1
+            else:
+                yield offset + runs[i].end(), offset + runs[j].start()
+                i = j + 1
+        offset += len(paragraph)
+
+
+def nested_inline_code_errors(docs, first_line=1):
+    """Attributed raw straight spans that close in a paired backtick span.
+
+    Inspect raw pairs before word/length filtering: the first fragment of the
+    defective bare-possessive citation has fewer than four words.
+    """
+    for filename, text in docs.items():
+        lean = filename.endswith('.lean')
+        codes = list(inline_code_spans(text))
+        offset = 0
+        for sent in chunks(text):
+            start = text.index(sent, offset)
+            offset = start + len(sent)
+            historical = HISTORICAL.search(sent)
+            if TEACHING.search(sent) or (lean and historical):
+                continue
+            speech = ATTRIB.search(sent)
+            direct = list(POSSESSIVE.finditer(sent))
+            if not lean:
+                direct += list(COLON.finditer(sent))
+            for match in QUOTE.finditer(sent):
+                if match.group(2) is None:
+                    continue
+                owners = []
+                if speech and match.start() > speech.start():
+                    owners.append(speech.group(1) or speech.group(3))
+                owners += [m.group(1) for m in direct if m.end() == match.start()]
+                if not owners or (not lean and historical
+                                  and historical_quote(sent, match.start(), match.group(2))):
+                    continue
+                closing = start + match.end() - 1
+                opening = start + match.start()
+                if not any(left <= closing < right for left, right in codes):
+                    continue
+                if any(left <= opening < right for left, right in codes):
+                    continue
+                line = text.count('\n', 0, closing) + first_line
+                for owner in dict.fromkeys(owners):
+                    yield filename, line, owner
 
 
 def chunks(text):
@@ -614,7 +684,7 @@
             yield (start, body) if with_offsets else body
 
 
-def load_lean_docstrings(mark_errors=None):
+def load_lean_docstrings(mark_errors=None, nested_errors=None):
     """Keep Lean prose separate from load()'s requirement and name sources."""
     docs = {}
     for directory, dirs, files in os.walk(os.path.join(ROOT, 'tools', 'formal')):
@@ -635,6 +705,10 @@
                         first_line = text.count('\n', 0, start) + 1
                         mark_errors.extend((filename, line, kind)
                                            for line, kind in unpaired_marks(body, first_line))
+                if nested_errors is not None:
+                    for start, body in blocks:
+                        first_line = text.count('\n', 0, start) + 1
+                        nested_errors.extend(nested_inline_code_errors({filename: body}, first_line))
                 docs[filename] = '\n\n'.join(body for _, body in blocks)
     return docs
 
@@ -904,6 +978,55 @@
     return 0
 
 
+def check_nested_inline_code():
+    """Nested values, raw short prefixes, input kinds and existing outer marks."""
+    source = '`details.reason: "account_terminated"` where the status is `terminated` and `"state"` for the two recoverable statuses, since presenting an unreachable account as a permanent termination is false, and with `retryable: false` for `"account_terminated"` and `retryable: true` for `"state"` on both the error and the operation view'
+    reqs = {'API-63': ('source.md', source)}
+    shapes = ["`API-63` says ", "`API-63`'s ", "`API-63`'s rule that ",
+              "`API-63`: "]
+    try:
+        for filename in ['probe.md', 'probe.lean']:
+            for shape in shapes:
+                if filename.endswith('.lean') and shape == shapes[-1]:
+                    continue  # the Markdown-only colon rule is unchanged
+                for ticks in ['`', '``']:
+                    wording = source.replace('`', ticks)
+                    owners = {'API-63': ('source.md', wording)}
+                    for left, right in [('“', '”'), ('"', '"')]:
+                        prose = shape + left + wording + right
+                        if filename.endswith('.lean'):
+                            prose = '\n\n'.join(docstrings('/-- ' + prose + ' -/')).strip()
+                        assert not list(unpaired_marks(prose))
+                        changed = [prose.replace('account_terminated', 'account_terminatd', 1),
+                                   prose.replace('"state"', '"stat"', 1),
+                                   prose.replace('two recoverable', 'three recoverable', 1)]
+                        errors = list(nested_inline_code_errors({filename: prose}))
+                        assert bool(errors) == (left == '"'), (filename, shape, ticks, left, errors)
+                        for wrong in changed:
+                            if left == '"':
+                                assert list(nested_inline_code_errors({filename: wrong})), wrong
+                            else:
+                                assert not list(nested_inline_code_errors({filename: wrong})), wrong
+                                assert find({filename: wrong}, {}, owners)[0], wrong
+                        if left == '“':
+                            assert find({filename: prose}, {}, owners) == ([], [], 1)
+        plain = '`API-63` says "alpha beta gamma delta"'
+        assert find({'probe.md': plain}, {}, {'API-63': ('source.md', 'alpha beta gamma delta')}) == ([], [], 1)
+        wrapped = '`API-63` says `"alpha beta gamma delta"`'
+        assert bool(list(nested_inline_code_errors({'probe.md': wrapped}))) == False
+        for prefix in ['Previously ', 'For example, ']:
+            nested = prefix + shapes[0] + '"' + source + '"'
+            assert not list(nested_inline_code_errors({'probe.md': nested}))
+        assert not list(nested_inline_code_errors({'probe.md': '"' + source + '"'}))
+        short = '`API-63` says "now"'
+        assert not list(nested_inline_code_errors({'probe.md': short}))
+    except AssertionError as exc:
+        print(f'FAIL: nested inline-code citation: {exc}')
+        return 1
+    print('PASS: nested inline-code citations: exact marks, short prefixes and value corruptions')
+    return 0
+
+
 def check_sentence_boundaries():
     """Keep closing marks, then protect paired spans at the actual cut position."""
     name = 'closing markup'
@@ -1399,7 +1522,7 @@
     if (check_sentence_boundaries() or check_docstrings() or check_quotations()
             or check_withdrawal_history() or check_markdown_quote_reach()
             or check_possessives() or check_colons()
-            or check_quote_content()):
+            or check_quote_content() or check_nested_inline_code()):
         return 1
     try:
         with open(BASELINE) as source:
@@ -1420,7 +1543,8 @@
     docs, adrs, reqs = load()
     mark_errors = [(f, line, kind) for f, text in docs.items()
                    for line, kind in unpaired_marks(text)]
-    lean = load_lean_docstrings(mark_errors)
+    nested_errors = []
+    lean = load_lean_docstrings(mark_errors, nested_errors)
     if not lean:
         print("FAIL: no source .lean files discovered under tools/formal (excluding .lake); "
               "restore the Lean sources and check the scan path. A preexisting index "
@@ -1433,6 +1557,12 @@
             print(f"  {f}:{line}: unpaired {kind} double quotation marks")
     if mark_errors:
         print(f"FAIL: {len(mark_errors)} quotation mark source-line finding(s)")
+        return 1
+    nested_errors += list(nested_inline_code_errors(docs))
+    for filename, line, owner in nested_errors:
+        print(f"FAIL: {filename}:{line}: {owner} straight quotation closes inside inline code; "
+              "use curly outer marks (“…”).")
+    if nested_errors:
         return 1
     bad, unquoted, markdown_compared = find(docs, adrs, reqs)
     lean_bad, _, compared = find(lean, adrs, reqs, corpus=docs)
--- a/.github/workflows/ci.yml
+++ b/.github/workflows/ci.yml
@@ -201,6 +201,53 @@
           fi
           grep -q 'attributes to OVR-1 a phrase OVR-1 does not contain' citations.log
           echo "citation gate correctly rejected an unverifiable quoted attribution"
+
+      - name: Prove the citation gate rejects nested inline-code value corruptions
+        if: matrix.shard == 0
+        run: |
+          python3 - <<'PY'
+          from pathlib import Path
+          import shutil
+          import subprocess
+          from tempfile import TemporaryDirectory
+
+          # Exercise the actual CLI in an isolated full copy, retaining the built index.
+          with TemporaryDirectory(prefix='nested-citation-') as directory:
+              root = Path(directory) / 'repo'
+              shutil.copytree('.', root, ignore=shutil.ignore_patterns('.git', '__pycache__'))
+              path = root / '03-operation-lifecycle.md'
+              original = path.read_text()
+              prefix = "with `API-63`'s “"
+              assert original.count(prefix) == 1
+              start = original.index(prefix) + len(prefix) - 1
+              end = original.index('”', start) + 1
+              quoted = original[start + 1:end - 1]
+              assert '"account_terminated"' in quoted and '"state"' in quoted
+              assert 'two recoverable' in quoted
+
+              def run(text, expected, diagnostic=None):
+                  path.write_text(text)
+                  result = subprocess.run(['python3', 'tools/check_citations.py'], cwd=root,
+                                          capture_output=True, text=True)
+                  assert result.returncode == expected, (expected, result.returncode, result.stdout, result.stderr)
+                  if diagnostic:
+                      assert diagnostic in result.stdout, result.stdout
+
+              run(original, 0)
+              straight = original[:start] + '"' + quoted + '"' + original[end:]
+              run(straight, 1, 'API-63 straight quotation closes inside inline code; use curly outer marks (“…”).')
+              for before, after in [('account_terminated', 'account_terminatd'),
+                                    ('"state"', '"stat"'), ('two recoverable', 'three recoverable')]:
+                  changed = quoted.replace(before, after, 1)
+                  assert changed != quoted
+                  # The cited owner and every other source stay unchanged.
+                  curly_wrong = original[:start] + '“' + changed + '”' + original[end:]
+                  straight_wrong = original[:start] + '"' + changed + '"' + original[end:]
+                  run(curly_wrong, 1, 'attributes to API-63 a phrase API-63 does not contain')
+                  run(straight_wrong, 1, 'API-63 straight quotation closes inside inline code; use curly outer marks (“…”).')
+              run(original, 0)
+          print('PASS: live nested citation: valid source, three corruptions and restoration')
+          PY
 
       # Exercise the unchanged live site as well as the one-word plant: a skip
       # must not pass for a successful comparison. The control copies the index
--- a/10-conformance-checklist.md
+++ b/10-conformance-checklist.md
@@ -3093,8 +3093,8 @@
 
       Separately construct `CNF-300`'s unresolved failed-rescue-exit row with `disk_effect` `none` and
       `rescue_exit` `unknown` without a prior restore, then back it up and actually restore it
-      (`CNF-300`: "`disk_effect: "none"` (it aborted before writing) and `rescue_exit:
-      "unknown"`"). It
+      (`CNF-300`: “`disk_effect: "none"` (it aborted before writing) and `rescue_exit:
+      "unknown"`”). It
       remains `needs_reconciliation`, acquires `true` provenance before startup, and now renders
       `unknown`/`unknown`. This is a declared conservative change on a row already awaiting
       resolution. For settled rows with established `false` provenance, an actual restore does not
```

## Exact candidate N — complete patch

Empty patch. All files remain identical to the supplied pinned base.
