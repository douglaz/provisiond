from pathlib import Path
import hashlib, json, subprocess, re
p=Path('/var/tmp/provisiond-panel-r89')
b=p/'r89b'
pin=(b/'PIN').read_text().strip()
packet=(b/'brief.md').read_bytes()
notes=(b/'notes.md').read_text()
receipt={'pin':pin,'packet_bytes':len(packet),'packet_sha256':hashlib.sha256(packet).hexdigest(),'clones':{},'answers_verbatim':[],'forms_complete':[]}
assert len(packet)<500000
settle='a question is settled when at least three agree and more agree than disagree, and a tie comes to you. If grok is down, it falls back to three of four'
assert settle in notes
rule6=(p/'notes.md').read_text().split('6. ',1)[1].split('\n7.',1)[0]
assert rule6 in notes
assert b'apply notes.md rule 6 exactly as written; this prompt adds no void rule' in packet
for seat in ('fable','opus','astra','sol'):
    assert (p/f'{seat}.md').read_bytes()==(b/'answers'/f'r89-{seat}.md').read_bytes()
    assert (p/f'{seat}.md').read_bytes() in packet
    receipt['answers_verbatim'].append(seat)
for label in ('A','B','C','D','Cprime'):
    actual=(b/f'form-{label}.md').read_bytes()
    original=(p/f'form-{label}.md') if label!='Cprime' else (p/'check/tally/form-Cprime.md')
    assert actual==original.read_bytes() and actual in packet
    receipt['forms_complete'].append(label)
for seat in ('fable','opus','astra','sol','consistency','grok'):
    clone=b/seat
    head=subprocess.check_output(['git','-C',str(clone),'rev-parse','HEAD'],text=True).strip()
    status=subprocess.check_output(['git','-C',str(clone),'status','--porcelain=v1'],text=True)
    assert head==pin and not status,(seat,head,status)
    receipt['clones'][seat]={'head':head,'clean':True}
for path in ('run-codex.sh','run-claude-stdin.sh'):
    assert (b/path).read_text()==(p/path).read_text().replace(str(p),str(b))
for name in ('before','final'):
    assert (p/f'check/gate-tally-{name}.exit').read_text().strip()=='0'
    assert 'All gates passed.' in (p/f'check/gate-tally-{name}.log').read_text()
receipt['baseline_full_unpiped_gates']={'before':0,'final':0}
assert (b/'check/consistency.exit').read_text().strip()=='0'
assert (b/'check/consistency.md').stat().st_size>30
assert (b/'check/consistency-disposition.md').exists()
probe=(b/'check/grok-probe.txt').read_text()
assert (b/'check/grok-probe.exit').read_text().strip()=='1' and '402 Payment Required' in probe
receipt['grok']='missing: HTTP 402; one actual call'
receipt['threshold']='three of four'
(b/'check/validation.json').write_text(json.dumps(receipt,indent=2)+'\n')
manifest=json.loads((b/'check/packet-manifest.json').read_text())
manifest.update(packet_bytes=len(packet),packet_sha256=receipt['packet_sha256'],notes_sha256=hashlib.sha256(notes.encode()).hexdigest())
(b/'check/packet-manifest.json').write_text(json.dumps(manifest,indent=2)+'\n')
print('validation PASS: exact complete forms, verbatim answers, original rule 6, owner threshold, clean pin, full baseline gates, consistency receipt, Grok 402, packet size')
