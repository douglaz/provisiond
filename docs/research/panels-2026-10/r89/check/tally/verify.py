from pathlib import Path
import hashlib, json, re, subprocess

p = Path('/var/tmp/provisiond-panel-r89')
out = p / 'check/tally'
pin = (p/'PIN').read_text().strip()
src = p/'sol'
sha = lambda b: hashlib.sha256(b).hexdigest()
receipt = {'pin': pin, 'answers': {}, 'clones': {}, 'source_excerpts': [], 'forms': {}}
for seat in ('fable', 'opus', 'astra', 'sol', 'consistency'):
    head = subprocess.check_output(['git', '-C', str(p/seat), 'rev-parse', 'HEAD'], text=True).strip()
    status = subprocess.check_output(['git', '-C', str(p/seat), 'status', '--porcelain=v1'], text=True)
    assert head == pin and not status, (seat, head, status)
    receipt['clones'][seat] = {'head': head, 'tracked_and_untracked_status': status}
for seat in ('fable', 'opus', 'astra', 'sol'):
    body = (p/f'{seat}.md').read_bytes()
    assert len(body) > 4000 and (p/f'{seat}.exit').read_text().strip() == '0'
    files = {}
    for suffix in ('md', 'err', 'out', 'draft.md'):
        f = p/f'{seat}.{suffix}'
        if not f.exists():
            continue
        data = f.read_bytes()
        files[f.name] = {'bytes': len(data), 'sha256': sha(data)}
        if suffix == 'out':
            assert data.strip() == body.strip(), (seat, 'stdout differs')
        if suffix == 'err' and data:
            log = data.decode()
            commands = re.findall(r'^exec\n(.*?)(?=^ (?:succeeded|exited|failed)|^hook:|\Z)', log, re.M|re.S)
            (out/f'{seat}-commands.txt').write_text('\n\n'.join(commands))
            commentary = re.findall(r'^codex\n(.*?)(?=^hook:|^exec\n|^codex\n|\Z)', log, re.M|re.S)
            (out/f'{seat}-commentary.txt').write_text('\n\n'.join(commentary))
            errors = [line for line in log.splitlines() if re.match(r'^(ERROR|Error:|WARNING|Warning:|rg:|Traceback|.*exited [1-9])', line)]
            (out/f'{seat}-diagnostics.txt').write_text('\n'.join(errors)+'\n')
    receipt['answers'][seat] = files

brief = (p/'brief.md').read_text()
for title, path, start, end in json.loads((p/'check/extract-index.json').read_text()):
    quoted = re.search(r'### '+re.escape(title)+r' —[^\n]*\n\n```text\n(.*?)```', brief, re.S).group(1)
    actual = (src/path).read_text().splitlines(True)[start-1:end]
    expected = ''.join(f'{n}: {line}' for n, line in enumerate(actual, start))
    assert quoted == expected, title
    receipt['source_excerpts'].append({'title': title, 'path': path, 'start': start, 'end': end, 'exact': True})

forms = json.loads((p/'check/forms.json').read_text())
for label, form in forms.items():
    text = (p/f'form-{label}.md').read_text()
    assert text in brief, label
    for b in form['blocks']:
        assert b['text'] in text
        if b['action'] == 'Retain verbatim':
            expected = ''.join((src/b['path']).read_text().splitlines(True)[b['start']-1:b['end']])
            assert expected.strip() == b['text'].strip(), (label, b['site'])
    receipt['forms'][label] = {'sha256': sha(text.encode()), 'blocks': len(form['blocks'])}

opus = (p/'opus.md').read_text()
cp = opus[opus.index('## Form C′ —'):].split('\nThe same text is at ', 1)[0].rstrip()+'\n'
cp_blocks = re.findall(r'### (Replace|Retain verbatim): ([^\n]+)\n\n```markdown\n(.*?)```', cp, re.S)
assert len(cp_blocks) == len(forms['C']['blocks'])
changed = []
for (action, heading, body), b in zip(cp_blocks, forms['C']['blocks']):
    if body != b['text']:
        expected = ''.join((src/b['path']).read_text().splitlines(True)[b['start']-1:b['end']])
        assert action == 'Retain verbatim' and body == expected, b['site']
        changed.append(b['site'])
assert len(changed) == 3, changed
(out/'form-Cprime.md').write_text(cp)
receipt['Cprime'] = {'sha256': sha(cp.encode()), 'changed_sites_from_C': changed, 'complete': True}
(out/'verification.json').write_text(json.dumps(receipt, indent=2)+'\n')
print(json.dumps({'source_blocks_exact': len(receipt['source_excerpts']), 'forms': list(forms), 'Cprime_changed_sites': changed, 'substantive_exit_zero_answers': list(receipt['answers'])}))
