#!/usr/bin/env python3
"""Exercise the live withdrawal quotation in a scratch copy, including restoration."""

from pathlib import Path
from tempfile import TemporaryDirectory
from unittest.mock import call, patch
import os
import shutil
import subprocess
import sys

import check_citations as c


def compare_live_site(docs, adrs, reqs):
    filename = '13-wire-contract.md'
    owner = 'WIR-2'
    quote = 'Unknown fields in a request body MUST be\nrejected'
    attributed = f'`{owner}`\'s "{quote}"'
    body = reqs['WIR-47'][1]
    assert body.count(attributed) == 1, 'control needs the exact multiline WIR-47 site'
    site = next(chunk for chunk in c.chunks(body) if attributed in chunk)
    assert 'a withdrawal body' in site, 'control must retain the domain noun'
    assert not c.HISTORICAL.search(site) and not c.TEACHING.search(site), (
        'unchanged WIR-47 must reach owner comparison, not a historical/teaching skip')
    assert not c.DOC.search(site) and not c.ADR.search(site), 'owner body is the only pool'
    line = docs[filename].count('\n', 0, docs[filename].index(attributed)) + 1

    # Wrap the existing comparison without replacing its result. Inspect just
    # this real chunk: aggregate corpus counts cannot establish this site's reach.
    with patch.object(c, 'contains_quote', wraps=c.contains_quote) as compare:
        result = c.find({filename: site}, adrs, reqs)
    assert result == ([], [], 1), ('unchanged WIR-47 owner comparison', result)
    assert compare.call_args_list == [call(c.comparison_text(reqs[owner][1]), quote)], (
        'unchanged WIR-47 must compare exactly once against the loaded WIR-2 body',
        compare.call_args_list)
    print(f'PASS: {filename}:{line}: WIR-47 compares {quote!r} against loaded {owner}; '
          'one real contains_quote call, no skip or baseline')
    return filename, owner, quote, attributed


def main():
    root = Path(c.ROOT)
    baseline = Path(c.BASELINE).read_bytes()
    index = Path(c.INDEX).read_bytes()  # Missing formal output is a failure, never a skip.
    assert index.strip(), 'control needs the existing formal index'

    with TemporaryDirectory(prefix='withdrawal-citations-') as directory:
        scratch = Path(directory) / 'repo'
        scratch.mkdir()
        for path in root.glob('*.md'):
            shutil.copy2(path, scratch / path.name)
        shutil.copytree(root / 'docs' / 'adr', scratch / 'docs' / 'adr')
        shutil.copytree(root / 'tools', scratch / 'tools',
                        ignore=shutil.ignore_patterns('.lake', '__pycache__'))
        scratch_index = scratch / Path(c.INDEX).relative_to(root)
        scratch_index.parent.mkdir(parents=True)
        scratch_index.write_bytes(index)
        previous = Path.cwd()
        try:
            with patch.object(c, 'ROOT', str(scratch)):
                docs, adrs, reqs = c.load()
        finally:
            os.chdir(previous)
        filename, owner, quote, attributed = compare_live_site(docs, adrs, reqs)
        target = scratch / filename
        original = (root / filename).read_bytes()
        before = attributed.encode()
        after = before.replace(b'rejected', b'accepted')
        offset = original.index(before)
        assert original.count(before) == 1 and offset > original.index(b'**WIR-47**')
        assert before.count(b'rejected') == 1 and before != after
        mutated = original.replace(before, after, 1)
        assert mutated == original[:offset] + after + original[offset + len(before):]
        assert b'a withdrawal body' in mutated

        def gate(label, status):
            result = subprocess.run([sys.executable, 'tools/check_citations.py'], cwd=scratch,
                                    capture_output=True, text=True)
            print(f'COMMAND: {sys.executable} tools/check_citations.py ({label}); exit {result.returncode}')
            print(result.stdout, end='')
            print(result.stderr, end='', file=sys.stderr)
            assert result.returncode == status, (label, result.returncode, result.stderr)
            assert not result.stderr, (label, result.stderr)
            assert (scratch / 'tools' / 'citation-baseline.json').read_bytes() == baseline
            assert scratch_index.read_bytes() == index
            return result.stdout

        assert target.read_bytes() == original
        gate('unchanged', 0)
        try:
            target.write_bytes(mutated)
            assert target.read_bytes() == mutated, 'exact one-word plant must be on disk'
            output = gate('rejected -> accepted inside the WIR-47 quotation only', 1)
            diagnostic = f'{filename} attributes to {owner} a phrase {owner} does not contain:'
            corrupt = c.norm(quote.replace('rejected', 'accepted'))
            assert output.count(diagnostic) == 1 and output.count('attributes to') == 1, output
            assert f'"{corrupt}"' in output, output
            summary = ('FAIL: 1 unverifiable quoted attribution(s) and 0 Lean docstring quote(s) '
                       "found nowhere. Quote the requirement's own words, or cite it without quoting.")
            assert [line for line in output.splitlines() if line.startswith('FAIL:')] == [summary], output
            assert 'quotes a phrase found' not in output, output
        finally:
            target.write_bytes(original)
            assert target.read_bytes() == original, 'scratch restoration must be byte for byte'
        gate('restored byte for byte', 0)
        assert (root / filename).read_bytes() == original, 'source checkout was not the mutation target'
        assert Path(c.BASELINE).read_bytes() == baseline
        print('PASS: live withdrawal control: unchanged 0 -> named WIR-2 corruption 1 -> restored 0; '
              'only the quoted word changed, no unrelated failures')
    return 0


if __name__ == '__main__':
    try:
        sys.exit(main())
    except AssertionError as exc:
        print(f'FAIL: live withdrawal control: {exc}')
        sys.exit(1)
