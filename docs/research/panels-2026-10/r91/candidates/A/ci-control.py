from pathlib import Path
import shutil
import subprocess
from tempfile import TemporaryDirectory

# Exercise the actual CLI in an isolated full copy, retaining the built index.
with TemporaryDirectory(prefix='nested-citation-') as directory:
    root = Path(directory) / 'repo'
    shutil.copytree('.', root, ignore=shutil.ignore_patterns('.git', '__pycache__'))
    path = root / '03-operation-lifecycle.md'
    original = path.read_text()
    prefix = "with `API-63`'s “"
    assert original.count(prefix) == 1
    start = original.index(prefix) + len(prefix) - 1
    end = original.index('”', start) + 1
    quoted = original[start + 1:end - 1]
    assert '"account_terminated"' in quoted and '"state"' in quoted
    assert 'two recoverable' in quoted

    def run(text, expected, diagnostic=None):
        path.write_text(text)
        result = subprocess.run(['python3', 'tools/check_citations.py'], cwd=root,
                                capture_output=True, text=True)
        assert result.returncode == expected, (expected, result.returncode, result.stdout, result.stderr)
        if diagnostic:
            assert diagnostic in result.stdout, result.stdout

    run(original, 0)
    straight = original[:start] + '"' + quoted + '"' + original[end:]
    run(straight, 1, 'API-63 straight quotation closes inside inline code; use curly outer marks (“…”).')
    for before, after in [('account_terminated', 'account_terminatd'),
                          ('"state"', '"stat"'), ('two recoverable', 'three recoverable')]:
        changed = quoted.replace(before, after, 1)
        assert changed != quoted
        # The cited owner and every other source stay unchanged.
        curly_wrong = original[:start] + '“' + changed + '”' + original[end:]
        straight_wrong = original[:start] + '"' + changed + '"' + original[end:]
        run(curly_wrong, 1, 'attributes to API-63 a phrase API-63 does not contain')
        run(straight_wrong, 1, 'API-63 straight quotation closes inside inline code; use curly outer marks (“…”).')
    run(original, 0)
print('PASS: live nested citation: valid source, three corruptions and restoration')
