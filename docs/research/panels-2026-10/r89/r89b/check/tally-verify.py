import hashlib
import json
from pathlib import Path
import re
import subprocess

panel = Path('/var/tmp/provisiond-panel-r89/r89b')
clone = panel / 'consistency'
pin = (panel / 'PIN').read_text().strip()

def git(*args):
    return subprocess.check_output(['git', '-C', str(clone), *args])

def source(path):
    return git('show', f'{pin}:{path}').decode()

def sha(b):
    return hashlib.sha256(b).hexdigest()

brief = (panel / 'brief.md').read_text()
evidence = brief.split('## Pinned source evidence from r89, verbatim\n', 1)[1].split('## Complete exact options', 1)[0]
checks = []
for m in re.finditer(r'### ([^\n]+) — `([^`]+):(\d+)–(\d+)` at `([^`]+)`\n\n```text\n(.*?)\n```', evidence, re.S):
    label, path, start, end, quoted_pin, numbered = m.groups()
    start, end = int(start), int(end)
    assert quoted_pin == pin
    numbered_lines = numbered.splitlines()
    assert len(numbered_lines) == end - start + 1
    content = []
    for lineno, line in enumerate(numbered_lines, start):
        prefix = f'{lineno}: '
        assert line.startswith(prefix), (path, lineno)
        content.append(line[len(prefix):])
    assert content == source(path).splitlines()[start-1:end], (path, start, end)
    checks.append({'label': label, 'path': path, 'start': start, 'end': end, 'matches_pin': True})
assert checks

form_pattern = re.compile(r'^### (Replace|Retain verbatim): ([^\n]+) — `([^`]+):(\d+)–(\d+)` at the pin\n\n```markdown\n(.*?)\n```', re.M | re.S)
forms = {}
form_records = {}
for name in ['A', 'B', 'C', 'Cprime', 'D']:
    path = panel / f'form-{name}.md'
    b = path.read_bytes()
    body = b.decode()
    assert body.rstrip() in brief, name
    blocks = []
    for m in form_pattern.finditer(body):
        action, label, src_path, start, end, text = m.groups()
        start, end = int(start), int(end)
        base = '\n'.join(source(src_path).splitlines()[start-1:end])
        if action == 'Retain verbatim':
            assert text == base, (name, label)
        blocks.append({'action': action, 'label': label, 'path': src_path,
                       'start': start, 'end': end, 'text': text, 'same_as_pin': text == base})
    assert blocks, name
    forms[name] = blocks
    form_records[name] = {'bytes': len(b), 'sha256': sha(b), 'blocks': [{k: v for k, v in x.items() if k != 'text'} for x in blocks]}

prime_changes = []
for c, prime in zip(forms['C'], forms['Cprime']):
    assert (c['label'], c['path'], c['start'], c['end']) == (prime['label'], prime['path'], prime['start'], prime['end'])
    if c['text'] != prime['text'] or c['action'] != prime['action']:
        assert prime['action'] == 'Retain verbatim' and prime['same_as_pin']
        prime_changes.append(prime['label'])
assert prime_changes == ['WIR-17 field rules opening', 'CNF-34', 'CNF-342 acknowledgement paragraph']

historical = {}
for seat in ['fable', 'opus', 'astra', 'sol']:
    old = (panel.parent / f'{seat}.md').read_bytes()
    copied = (panel / 'answers' / f'r89-{seat}.md').read_bytes()
    assert old == copied, seat
    assert old.decode().rstrip() in brief, seat
    historical[seat] = {'bytes': len(old), 'sha256': sha(old), 'copy_exact': True, 'embedded_verbatim': True}

answers = {}
expected_bytes = {'fable': 9067, 'opus': 12112, 'astra': 10687, 'sol': 10550}
for seat, count in expected_bytes.items():
    b = (panel / f'{seat}.md').read_bytes()
    assert len(b) == count, seat
    assert (panel / f'{seat}.exit').read_text().strip() == '0'
    assert re.search(r'Final:\s*C′', b.decode()), seat
    # Actual answers were read independently; these checks pin the reviewed artifacts.
    out = panel / f'{seat}.out'
    if out.exists():
        assert out.read_bytes().rstrip(b'\n') == b.rstrip(b'\n')
    answers[seat] = {'bytes': len(b), 'sha256': sha(b), 'exit': 0,
                     'final': 'C′', 'unqualified_accept': ['C′'],
                     'cannot_accept_as_printed': ['A', 'B', 'C', 'D'],
                     'stderr_bytes': (panel / f'{seat}.err').stat().st_size}

clones = {}
for seat in ['fable', 'opus', 'astra', 'sol', 'consistency']:
    target = panel / seat
    head = subprocess.check_output(['git', '-C', str(target), 'rev-parse', 'HEAD']).decode().strip()
    status = subprocess.check_output(['git', '-C', str(target), 'status', '--porcelain']).decode()
    assert head == pin and status == '', (seat, head, status)
    clones[seat] = {'head': head, 'status_porcelain': status}

assert not list(panel.rglob('*.draft.md'))
result = {'pin': pin, 'packet_bytes': len((panel/'brief.md').read_bytes()),
          'packet_sha256': sha((panel/'brief.md').read_bytes()),
          'evidence': checks, 'forms': form_records, 'Cprime_changes_from_C': prime_changes,
          'historical_answers': historical, 'answers': answers, 'clones': clones,
          'drafts': [], 'grok': 'missing: 402; no probe repeated'}
dest = panel / 'check/tally-verification.json'
dest.write_text(json.dumps(result, indent=2) + '\n')
print(json.dumps({'result': 'PASS', 'evidence_ranges': len(checks), 'form_blocks': {n: len(b) for n,b in forms.items()},
                  'final_picks': {s: a['final'] for s, a in answers.items()},
                  'Cprime_sha256': form_records['Cprime']['sha256'], 'output': str(dest)}))
