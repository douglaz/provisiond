from pathlib import Path
import hashlib
import json
import re
import subprocess

P = Path('/var/tmp/provisiond-panel-r84/r84b')
A = P / 'check/tally'
C = P / 'sol'
PIN = '3109b5b44eae17e288cf52aaa976993bd8c5626c'

def pinned(path):
    return subprocess.check_output(['git', '-C', str(C), 'show', f'{PIN}:{path}'], text=True)

brief = (P / 'brief.md').read_text()
extracts = []
for m in re.finditer(r'### `([^`]+):(\d+)–(\d+)`\n\n```text\n(.*?)\n```', brief, re.S):
    path, first, last, quoted = m.groups()
    actual = '\n'.join(pinned(path).splitlines()[int(first)-1:int(last)])
    assert actual == quoted, path
    extracts.append({'path': path, 'first': int(first), 'last': int(last), 'exact': True})
assert len(extracts) == 11
(A / 'extract-check.json').write_text(json.dumps(extracts, indent=2) + '\n')

for q, forms in [(1, 'ABC'), (3, 'ABE')]:
    for form in forms:
        start = brief.index(f'### Q{q}-{form} —')
        end = brief.find('\n### ', start + 1)
        if q == 1 and form == 'C':
            end = brief.index('\n**Consensus Q1:**', start)
        if q == 3 and form == 'E':
            end = brief.index('\n## Verified hash comparison', start)
        (A / f'q{q}-{form}.md').write_text(brief[start:end] + '\n')

sets = {'AE': '\t\n\v\f\r ', 'B': '\t\n\f\r '}
def norm(value, trim):
    value = value.strip(trim).translate(str.maketrans('ABCDEFGHIJKLMNOPQRSTUVWXYZ', 'abcdefghijklmnopqrstuvwxyz'))
    if value.startswith('0x'):
        value = value[2:]
    return value

rows = []
for label, trim in sets.items():
    for char in '\t\n\v\f\r ':
        value = char + '0XAb' + char
        n = norm(value, trim)
        assert n == ('\v0xab\v' if label == 'B' and char == '\v' else 'ab')
        assert bool(norm(char, trim)) == (label == 'B' and char == '\v')
        assert value.strip(trim) == (value if label == 'B' and char == '\v' else '0XAb')
    for char in '\b\x0e\x1f\x7f\xa0':
        assert norm(char + '0XAb' + char, trim) == char + '0xab' + char
        assert (char + '0XAb' + char).strip(trim) == char + '0XAb' + char
    for char in '\t\n\v\f\r \b\x0e\x1f\x7f\xa0':
        assert norm('0X' + char + 'Ab', trim) == char + 'ab'
    assert norm(' 0x0XAB ', trim) == '0xab'
    assert norm('0X', trim) == ''
    assert norm(' 0X/DeV/sda ', trim) == '/dev/sda'
    assert norm('\v/dev/sda\v', trim).startswith('/dev/') == (label == 'AE')
    for field in ['serial', 'wwn']:
        value = norm('\v0XAb\v', trim)
        element = {'wwn': None, 'serial': None, 'size_bytes': 1024}
        element[field] = value
        # These fixtures have ASCII keys, null/string values and one small integer.
        # Sorted compact JSON yields their specified RFC 8785 bytes.
        options = {'sort_keys': True, 'separators': (',', ':'), 'ensure_ascii': False}
        object_bytes = json.dumps(element, **options).encode()
        list_bytes = json.dumps([element], **options).encode()
        object_digest = hashlib.sha256(object_bytes).hexdigest()
        list_digest = hashlib.sha256(list_bytes).hexdigest()
        assert object_digest != list_digest
        rows.append({'set': label, 'field': field, 'normalized': value,
                     'list_bytes': list_bytes.decode(), 'list_digest': list_digest,
                     'element_bytes': object_bytes.decode(), 'element_digest': object_digest})
assert rows[0]['list_digest'] == '8a7ab8eb85404e4ef4022bdf6f1cfc768b029d7f68271f0f60c931d494b72641'
assert rows[0]['element_digest'] == 'b2fa45b2bdac148628b4ec507afb927aafd8d8c51a5389e5a1a35a8d117bbc05'
(A / 'calculations.json').write_text(json.dumps(rows, indent=2) + '\n')

issues = [json.loads(x) for x in pinned('.beads/issues.jsonl').splitlines()]
chosen = [x for x in issues if x['id'] in ['pv-ez8', 'pv-tbrs', 'pv-6p8']]
(A / 'pinned-tracker-evidence.json').write_text(json.dumps(chosen, indent=2) + '\n')
files = ['04-api-contract.md', '06-rescue-install.md', '10-conformance-checklist.md',
         '03-operation-lifecycle.md', '01-domain-model.md', '13-wire-contract.md',
         'tools/formal/Provisiond/Rescue.lean']
line_ranges = [(236,252,958,981),(245,330),(2243,2245,2295,2333),(2018,2049),
               (575,591),(289,304,720,736),(295,410)]
with (A / 'source-evidence.txt').open('w') as out:
    for file, ranges in zip(files, line_ranges):
        lines = pinned(file).splitlines()
        for first, last in zip(ranges[::2], ranges[1::2]):
            out.write(f'\n{PIN}:{file}:{first}-{last}\n')
            out.write('\n'.join(f'{i+1}: {lines[i]}' for i in range(first-1,last)) + '\n')
states = []
for seat in ['fable', 'opus', 'astra', 'sol', 'check/spec']:
    clone = P / seat
    head = subprocess.check_output(['git', '-C', str(clone), 'rev-parse', 'HEAD'], text=True).strip()
    status = subprocess.check_output(['git', '--no-optional-locks', '-C', str(clone), 'status', '--short'], text=True)
    assert head == PIN and not status, (seat, head, status)
    states.append({'clone': seat, 'head': head, 'tracked_status': status})
(A / 'clone-status.json').write_text(json.dumps(states, indent=2) + '\n')
print('PASS: eleven exact pinned extracts; six unchanged forms copied; both trim sets, all printed boundary families and four object/list pairs; pinned tracker evidence; five clean pinned clones.')
