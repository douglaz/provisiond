#!/usr/bin/env python3
"""Panel-local verifier; no repository file or index is built or modified."""
from pathlib import Path
import argparse, json, os, shutil, subprocess

P = Path(__file__).resolve().parent
parser = argparse.ArgumentParser()
parser.add_argument('--source', required=True, type=Path)
parser.add_argument('--work', required=True, type=Path)
args = parser.parse_args()
assert args.work.resolve().is_relative_to(P / 'tmp')
assert not args.work.exists(), 'choose a fresh work directory'
args.work.mkdir(parents=True)
source = args.source.resolve()
head = subprocess.run(['git', 'rev-parse', 'HEAD'], cwd=source,
                      capture_output=True, text=True, check=True).stdout.strip()
assert head == (P / 'PIN').read_text().strip(), head
results = []
for kind in ['N', 'A', 'B', 'C']:
    root = args.work / kind
    shutil.copytree(source, root, ignore=shutil.ignore_patterns('.git', '.lake', '__pycache__'))
    for relative in ['tools/check_citations.py', '10-conformance-checklist.md', '.github/workflows/ci.yml']:
        (root / relative).write_bytes((P / 'candidates' / kind / relative).read_bytes())
    (root / 'tools/formal/.lake').mkdir()
    shutil.copy2(P / 'shared-index.jsonl', root / 'tools/formal/.lake/index.jsonl')
    result = subprocess.run(['python3', 'tools/check_citations.py'], cwd=root,
                            capture_output=True, text=True)
    (args.work / (kind + '-valid.log')).write_text(result.stdout + result.stderr)
    assert result.returncode == 0, (kind, result.returncode, result.stdout, result.stderr)
    row = {'candidate': kind, 'valid_cli_exit': result.returncode}
    if kind in ['A', 'C']:
        checklist = root / '10-conformance-checklist.md'
        migrated = checklist.read_bytes()
        checklist.write_bytes((source / '10-conformance-checklist.md').read_bytes())
        raw = subprocess.run(['python3', 'tools/check_citations.py'], cwd=root,
                             capture_output=True, text=True)
        (args.work / (kind + '-unmigrated.log')).write_text(raw.stdout + raw.stderr)
        assert raw.returncode == 1 and 'CNF-300 straight quotation closes inside inline code;' in raw.stdout
        row['unconverted_valid_citation_exit'] = raw.returncode
        checklist.write_bytes(migrated)
    if kind != 'N':
        workflow = (root / '.github/workflows/ci.yml').read_text()
        anchor = '      - name: Prove the citation gate rejects nested inline-code value corruptions\n'
        step = workflow.split(anchor, 1)[1].split('\n      # Exercise', 1)[0]
        embedded = step.split("          python3 - <<'PY'\n", 1)[1].rsplit('          PY\n', 1)[0]
        code = ''.join(line[10:] if line.startswith('          ') else line
                       for line in embedded.splitlines(True))
        assert code == (P / 'candidates' / kind / 'ci-control.py').read_text()
        result = subprocess.run(['python3', '-'], input=code, cwd=root,
                                capture_output=True, text=True,
                                env={**os.environ, 'TMPDIR': str(args.work)})
        (args.work / (kind + '-ci.log')).write_text(result.stdout + result.stderr)
        assert result.returncode == 0, (kind, result.returncode, result.stdout, result.stderr)
        row['embedded_ci_exit'] = result.returncode
    else:
        path = root / '03-operation-lifecycle.md'
        original = path.read_text()
        prefix = "with `API-63`'s “"
        start = original.index(prefix) + len(prefix) - 1
        end = original.index('”', start) + 1
        quoted = original[start + 1:end - 1]
        plants = []
        for before, after in [('account_terminated', 'account_terminatd'),
                              ('"state"', '"stat"'), ('two recoverable', 'three recoverable')]:
            wrong = quoted.replace(before, after, 1)
            path.write_text(original[:start] + '"' + wrong + '"' + original[end:])
            result = subprocess.run(['python3', 'tools/check_citations.py'], cwd=root,
                                    capture_output=True, text=True)
            (args.work / ('N-' + after.replace('"', '') + '.log')).write_text(result.stdout + result.stderr)
            plants.append({'value': after, 'exit': result.returncode})
        path.write_text(original)
        row['straight_possessive_corruptions'] = plants
    results.append(row)
    print(json.dumps(row), flush=True)
(args.work / 'results.json').write_text(json.dumps(results, indent=2) + '\n')
