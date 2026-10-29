#!/usr/bin/env python3
"""Compare the complete live stop-record quotation and corrupt only a scratch copy."""

from pathlib import Path
from tempfile import TemporaryDirectory
from unittest.mock import call, patch
import hashlib
import os
import shutil
import subprocess
import sys

import check_citations as c


def compare_live_site(docs, adrs, reqs):
    filename, owner = '10-conformance-checklist.md', 'OPS-21'
    quote = (
        "The Stop-record bound and its expiry exit, the later-stop exit, the Store-retry "
        "bound's exhaustion exit, the superseded exit (`OPS-50`), the lost-reply case and "
        "the supervisor's wait apply to the record of a stop after `execute` returns as "
        "they do to a recorded cancellation; the cut-off classification and its reason "
        "do not, nor does the rule against repeating a transaction already sent inside `execute`."
    )
    attributed = f'`{owner}` says "{quote}"'
    body = reqs['CNF-362'][1]
    assert body.count(attributed) == docs[filename].count(attributed) == 1, (
        'control needs the complete unchanged CNF-362 attribution')
    site = next(chunk for chunk in c.chunks(docs[filename]) if attributed in chunk)
    assert len(quote) > 400 and 'superseded' in quote
    assert not c.TEACHING.search(site)
    assert not c.DOC.search(site) and not c.ADR.search(site), 'owner body is the only pool'
    assert not list(c.unpaired_marks(site)), 'the full paired content must be retained'
    line = docs[filename].count('\n', 0, docs[filename].index(attributed)) + 1
    with patch.object(c, 'contains_quote', wraps=c.contains_quote) as compare:
        result = c.find({filename: site}, adrs, reqs)
    assert result == ([], [], 1), ('unchanged complete live owner comparison', result)
    assert compare.call_args_list == [call(c.comparison_text(reqs[owner][1]), quote)], (
        'the entire quotation must compare exactly once against loaded OPS-21',
        compare.call_args_list)
    print(f'PASS: {filename}:{line}: complete {len(quote)}-character quote {quote!r} '
          f'compares against loaded {owner}; one real contains_quote call, no alternative pool or baseline')
    return filename, owner, quote, attributed, site


def main():
    root = Path(c.ROOT)
    baseline_path, index_path = Path(c.BASELINE), Path(c.INDEX)
    filename = '10-conformance-checklist.md'
    originals = {root / filename: (root / filename).read_bytes(),
                 baseline_path: baseline_path.read_bytes(), index_path: index_path.read_bytes()}
    baseline, index = originals[baseline_path], originals[index_path]
    assert index.strip(), 'control needs the existing formal index; missing input is never a skip'

    try:
        with TemporaryDirectory(prefix='stop-record-citations-') as directory:
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
            assert not any(path.is_symlink() for path in scratch.rglob('*')), (
                'scratch inputs must be genuine copies, never links to mutable checkout files')
            previous = Path.cwd()
            try:
                with patch.object(c, 'ROOT', str(scratch)):
                    docs, adrs, reqs = c.load()
            finally:
                os.chdir(previous)
            filename, owner, quote, attributed, site = compare_live_site(docs, adrs, reqs)
            target = scratch / filename
            original = originals[root / filename]
            before = attributed.encode()
            after = before.replace(b"supervisor's wait", b"supervisor's nap")
            assert before.count(b"supervisor's wait") == original.count(before) == 1
            assert before != after
            offset = original.index(before)
            mutated = original[:offset] + after + original[offset + len(before):]
            assert mutated == original.replace(before, after, 1)
            corrupt = quote.replace("supervisor's wait", "supervisor's nap")
            assert len(corrupt) > 400 and 'superseded' in corrupt

            def gate(label, status):
                command = [sys.executable, 'tools/check_citations.py']
                result = subprocess.run(command, cwd=scratch, capture_output=True, text=True)
                print(f'COMMAND: {command!r}; cwd={str(scratch)!r}; phase={label}; exit={result.returncode}')
                print(f'STDOUT ({label}):\n{result.stdout}', end='')
                print(f'STDERR ({label}): {result.stderr!r}')
                assert result.returncode == status, (label, result.returncode, result.stdout, result.stderr)
                assert not result.stderr, (label, result.stderr)
                assert (scratch / 'tools' / 'citation-baseline.json').read_bytes() == baseline
                assert scratch_index.read_bytes() == index
                return result.stdout

            assert target.read_bytes() == original
            gate('unchanged', 0)
            try:
                target.write_bytes(mutated)
                assert target.read_bytes() == mutated, 'exact full-content plant must be on disk'
                # Prove the corrupted full content reaches the same loaded owner, too.
                with patch.object(c, 'contains_quote', wraps=c.contains_quote) as compare:
                    result = c.find({filename: site.replace(quote, corrupt)}, adrs, reqs)
                assert result == ([(filename, owner, c.norm(corrupt))], [], 1), result
                assert compare.call_args_list == [call(c.comparison_text(reqs[owner][1]), corrupt)]
                output = gate("supervisor's wait -> supervisor's nap inside complete quotation", 1)
                diagnostic = f'{filename} attributes to {owner} a phrase {owner} does not contain:'
                assert output.count(diagnostic) == output.count('attributes to') == 1, output
                assert f'"{c.norm(corrupt)}"' in output, output
                summary = ('FAIL: 1 unverifiable quoted attribution(s) and 0 Lean docstring quote(s) '
                           "found nowhere. Quote the requirement's own words, or cite it without quoting.")
                assert [line for line in output.splitlines() if line.startswith('FAIL:')] == [summary], output
                assert 'quotes a phrase found' not in output, output
            finally:
                target.write_bytes(original)
                assert target.read_bytes() == original, 'scratch restoration must be byte for byte'
                gate('restored byte for byte', 0)
            print('PASS: live stop-record control: unchanged 0 -> sole named OPS-21 mismatch 1 -> restored 0; '
                  'complete quote and final clause compared, both original skip triggers retained')
    finally:
        for path, content in originals.items():
            assert path.read_bytes() == content, f'source checkout bytes changed: {path}'
            print(f'PASS: source bytes unchanged: {path.relative_to(root)}; '
                  f'sha256={hashlib.sha256(content).hexdigest()}')
    return 0


if __name__ == '__main__':
    try:
        sys.exit(main())
    except (AssertionError, OSError) as exc:
        print(f'FAIL: live stop-record control: {exc}')
        sys.exit(1)
