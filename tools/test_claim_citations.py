#!/usr/bin/env python3
"""Observe the live Claim quotation in both checks, then corrupt a scratch copy."""

from pathlib import Path
from tempfile import TemporaryDirectory
from unittest.mock import call, patch
import hashlib
import os
import shutil
import subprocess
import sys

import check_citations as c


FILENAME = 'tools/formal/Provisiond/Claim.lean'
OWNER = 'OPS-49'
QUOTE = 'are not store errors and do not consume the bound'


def compare_live_site(scratch, docs, adrs, reqs):
    source = (scratch / FILENAME).read_text()
    module = next(c.docstrings(source))
    assert source.count(QUOTE) == module.count(QUOTE) == 1
    site, = [chunk for chunk in c.chunks(module) if QUOTE in chunk]
    assert site.count('superseded_never_commits') == 2, 'retain both live identifiers'
    assert list(c.quotations(site)) == [(site.index('"'), QUOTE)]
    assert not c.DOC.search(site) and not c.ADR.search(site), 'owner body is the only pool'
    assert not c.HISTORICAL.search(site) and not c.TEACHING.search(site)
    assert not list(c.unpaired_marks(site))
    attribution = c.ATTRIB.search(site)
    assert attribution and attribution.group(1) == OWNER
    assert reqs[OWNER][0] == '03-operation-lifecycle.md'
    owner_body = c.comparison_text(reqs[OWNER][1])
    with patch.object(c, 'contains_quote', wraps=c.contains_quote) as compare:
        result = c.find({FILENAME: site}, adrs, reqs, corpus=docs)
    assert result == ([], [], 1), ('live owner comparison', result)
    assert compare.call_args_list == [call(owner_body, QUOTE)], compare.call_args_list
    line = source.count('\n', 0, source.index(QUOTE)) + 1
    print(f'PASS: {FILENAME}:{line}: unchanged {QUOTE!r} compared exactly once '
          f'against loaded normalized {OWNER}; owner body alone, both identifiers retained')

    # Observe fragments() after the historical skip, without replacing its result.
    # The normal corpus must accept the quote, and removing only its matching
    # document must make the actual EXISTS comparison reject the same quote.
    corpus = list(docs.values()) + list(adrs.values())
    normalized = c.norm(QUOTE).replace('"', '').replace("'", '')
    matching = [name for name, text in list(docs.items()) + list(adrs.items())
                if normalized in c.norm(text).replace('"', '').replace("'", '')]
    assert matching == ['03-operation-lifecycle.md'], matching
    for label, pool, expected in [
        ('normal root/ADR corpus', corpus, []),
        ('only 03-operation-lifecycle.md removed',
         [text for name, text in docs.items() if name != matching[0]] + list(adrs.values()),
         [(FILENAME, c.norm(QUOTE))]),
    ]:
        with patch.object(c, 'fragments', wraps=c.fragments) as fragments:
            result = c.exists({FILENAME: site}, pool)
        assert result == (expected, 1), (label, result)
        assert fragments.call_args_list == [call(normalized)], (label, fragments.call_args_list)
        print(f'PASS: live EXISTS: {label}; exact fragment reaches comparison; result={result!r}')
    return site


def check_history_boundaries():
    source = 'alpha beta gamma delta'
    # Test both sides of Unicode word boundaries, case, markup and position.
    for embedded in ['superseded_never_commits', '_superseded', 'superseded_',
                     '9superseded', 'superseded9', 'ésuperseded', 'supersededé',
                     'xsuperseded', 'supersededx']:
        for word in [embedded, embedded.upper(), embedded.title()]:
            for marked in [word, f'`{word}`']:
                for inside in [False, True]:
                    quote = source + ' ' + marked if inside else source
                    tail = '' if inside else ' alongside ' + marked
                    prose = f'`OPS-49` says "{quote}"{tail}.'
                    assert not c.HISTORICAL.search(prose), prose
                    owners = {OWNER: ('source.md', quote)}
                    assert c.find({'probe.lean': prose}, {}, owners) == ([], [], 1), prose
                    assert c.exists({'probe.lean': prose}, [quote]) == ([], 1), prose
                    wrong = prose.replace('delta', 'WRONG')
                    corrupt = c.norm(quote.replace('delta', 'WRONG'))
                    assert c.find({'probe.lean': wrong}, {}, owners) == (
                        [('probe.lean', OWNER, corrupt)], [], 1), wrong
                    assert c.exists({'probe.lean': wrong}, [quote]) == (
                        [('probe.lean', corrupt)], 1), wrong
    # Genuine history still skips even with an embedded identifier nearby or
    # with standalone superseded inside the quote. Keep other marker policies.
    for marker in ['superseded', 'SUPERSEDED', 'SuPeRsEdEd', 'xamendedx']:
        for prose in [
            f'{marker}: `OPS-49` says "alpha beta gamma WRONG" alongside `superseded_never_commits`.',
            f'`OPS-49` says "alpha beta {marker} gamma WRONG" alongside superseded_never_commits.',
            f'`OPS-49` says "alpha beta gamma WRONG" alongside superseded_never_commits; {marker}.',
        ]:
            assert c.HISTORICAL.search(prose), prose
            assert c.find({'probe.lean': prose}, {}, {}) == ([], [], 0), prose
            assert c.exists({'probe.lean': prose}, []) == ([], 1), prose
    # Embedded identifiers must not change Lean's colon or length boundaries.
    prose = '`OPS-49`: "alpha beta gamma WRONG" alongside superseded_never_commits.'
    assert c.find({'probe.lean': prose}, {}, {}) == ([], [], 0)
    assert c.exists({'probe.lean': prose}, []) == ([('probe.lean', 'alpha beta gamma wrong')], 1)
    for length in [400, 401]:
        prefix = 'alpha beta superseded_never_commits '
        quote = prefix + 'x' * (length - len(prefix))
        prose = f'`OPS-49` says "{quote}"'
        result = c.find({'probe.lean': prose}, {}, {})
        if length == 400:
            assert result == ([('probe.lean', OWNER, c.norm(quote))], [], 1), result
            assert c.exists({'probe.lean': prose}, []) == ([('probe.lean', c.norm(quote))], 1)
        else:
            bad, unquoted, compared = result
            assert not bad and compared == 0 and len(unquoted) == 1, result
            assert c.exists({'probe.lean': prose}, []) == ([], 0)
    print('PASS: Lean history boundaries: embedded Unicode/digit/underscore/case variants, '
          'inside/outside quotes, with/without backticks; standalone history and parser limits retained')


def snapshot(root):
    return {path.relative_to(root): hashlib.sha256(path.read_bytes()).hexdigest()
            for path in root.rglob('*') if path.is_file()}


def main():
    root = Path(c.ROOT)
    baseline_path, index_path = Path(c.BASELINE), Path(c.INDEX)
    baseline, index = baseline_path.read_bytes(), index_path.read_bytes()
    assert index.strip(), 'published formal index is required, never skipped'
    original = (root / FILENAME).read_bytes()
    check_history_boundaries()

    with TemporaryDirectory(prefix='claim-citations-') as directory:
        scratch = Path(directory) / 'repo'
        scratch.mkdir()
        for path in root.glob('*.md'):
            shutil.copy2(path, scratch / path.name)
        shutil.copytree(root / 'docs' / 'adr', scratch / 'docs' / 'adr')
        shutil.copytree(root / 'tools', scratch / 'tools',
                        ignore=shutil.ignore_patterns('.lake', '__pycache__'))
        scratch_index = scratch / index_path.relative_to(root)
        scratch_index.parent.mkdir(parents=True)
        scratch_index.write_bytes(index)
        assert not any(path.is_symlink() for path in scratch.rglob('*')), 'use genuine copies'
        inputs = snapshot(scratch)
        # Snapshot every copied input in the checkout too, including Types.lean,
        # the baseline and the published index. No checkout input is mutated.
        checkout_inputs = {path: hashlib.sha256((root / path).read_bytes()).hexdigest()
                           for path in inputs}
        assert checkout_inputs == inputs, 'copied corpus must match the checkout'
        previous = Path.cwd()
        try:
            with patch.object(c, 'ROOT', str(scratch)):
                docs, adrs, reqs = c.load()
        finally:
            os.chdir(previous)
        site = compare_live_site(scratch, docs, adrs, reqs)
        target = scratch / FILENAME
        before = QUOTE.encode()
        after = before.replace(b'consume', b'inflate')
        assert before.count(b'consume') == original.count(before) == 1
        offset = original.index(before)
        mutated = original[:offset] + after + original[offset + len(before):]
        assert mutated == original.replace(before, after, 1) and mutated != original
        assert mutated.count(b'superseded_never_commits') == original.count(b'superseded_never_commits')
        assert site.count('superseded_never_commits') == 2
        corrupt = c.norm(QUOTE.replace('consume', 'inflate'))

        def unchanged_inputs(expected_target):
            actual = snapshot(scratch)
            expected = dict(inputs)
            expected[Path(FILENAME)] = hashlib.sha256(expected_target).hexdigest()
            assert actual == expected, 'only the intended Claim quotation may change'
            assert {path: hashlib.sha256((root / path).read_bytes()).hexdigest()
                    for path in checkout_inputs} == checkout_inputs, 'checkout inputs changed'
            assert baseline_path.read_bytes() == baseline and index_path.read_bytes() == index

        def gate(label, status, content):
            command = [sys.executable, '-B', 'tools/check_citations.py']
            unchanged_inputs(content)
            result = subprocess.run(command, cwd=scratch, capture_output=True, text=True)
            print(f'COMMAND: {command!r}; cwd={str(scratch)!r}; phase={label}; exit={result.returncode}')
            print(f'STDOUT ({label}):\n{result.stdout}', end='')
            print(f'STDERR ({label}): {result.stderr!r}')
            assert result.returncode == status, (label, result.returncode, result.stdout, result.stderr)
            assert not result.stderr, (label, result.stderr)
            unchanged_inputs(content)
            return result.stdout

        gate('unchanged', 0, original)
        try:
            target.write_bytes(mutated)
            assert target.read_bytes() == mutated
            output = gate('consume -> inflate in the actual Claim quotation only', 1, mutated)
            owner_diagnostic = f'{FILENAME} attributes to {OWNER} a phrase {OWNER} does not contain:'
            exists_diagnostic = f'{FILENAME} quotes a phrase found in no document or ADR:'
            for diagnostic in [owner_diagnostic, exists_diagnostic]:
                assert output.count(diagnostic) == 1, output
                assert f'  {diagnostic}\n      "{corrupt}"\n' in output, output
            assert output.count('attributes to') == output.count('quotes a phrase found') == 1, output
            summary = ('FAIL: 1 unverifiable quoted attribution(s) and 1 Lean docstring quote(s) '
                       "found nowhere. Quote the requirement's own words, or cite it without quoting.")
            assert [line for line in output.splitlines() if line.startswith('FAIL:')] == [summary], output
        finally:
            target.write_bytes(original)
            assert target.read_bytes() == original, 'restoration must be byte for byte'
            gate('restored byte for byte', 0, original)
        print(f'PASS: live Claim control in {scratch}: exits 0 -> 1 -> 0; '
              'separate sole OPS-49 and EXISTS findings; byte restoration verified; '
              'other inputs, baseline, index and checkout unchanged')
    return 0


if __name__ == '__main__':
    try:
        sys.exit(main())
    except (AssertionError, OSError, ValueError) as exc:
        print(f'FAIL: live Claim control: {exc}')
        sys.exit(1)
