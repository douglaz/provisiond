from pathlib import Path
import hashlib,json,re,subprocess
p=Path('/var/tmp/provisiond-panel-r89'); r=p/'check/spec'; pin=(p/'PIN').read_text().strip()
forms=json.loads((p/'check/forms.json').read_text()); receipt={'pin':pin,'forms':{},'clones':{},'wrappers':{},'packet_bytes':(p/'brief.md').stat().st_size}
assert receipt['packet_bytes']<500000
for key,form in forms.items():
 transformed={}
 ranges={}
 for b in form['blocks']:
  path=b['path']; source=(r/path).read_text()
  baseline=''.join(source.splitlines(True)[b['start']-1:b['end']])
  assert re.match(r'^ *',baseline).group()==re.match(r'^ *',b['text']).group(),(key,b['site'],'leading indentation changed')
  if b['action']=='Retain verbatim':
   assert baseline.strip()==b['text'].strip(),(key,b['site'],'retain mismatch')
  else:
   ranges.setdefault(path,[]).append(b)
  assert b['text'] in (p/f'form-{key}.md').read_text(),(key,b['site'])
 for path,blocks in ranges.items():
  source=(r/path).read_text().splitlines(True)
  for a,b in zip(sorted(blocks,key=lambda x:x['start']),sorted(blocks,key=lambda x:x['start'])[1:]):
   assert a['end']<b['start'],(key,path,'overlap')
  for b in sorted(blocks,key=lambda x:x['start'],reverse=True):
   source[b['start']-1:b['end']]=[b['text']]
  transformed[path]=''.join(source)
 for path,text in transformed.items():
  assert not re.search(r'bill per order|bills on order|order.billed|per ordering account',text,re.I),(key,path,'undefined phrase remains')
 prv=transformed['02-provider-contract.md']
 # Quoted consumers must continue to resolve the same exact normalized strings.
 prv=' '.join(prv.split())
 assert 'explicit purchase acknowledgement' in prv
 assert 'the account is configured to allow ordering' in prv
 assert ('**paid create**' in transformed['01-domain-model.md']) == form['central']
 assert ('**Hourly cloud cases.**' in transformed['10-conformance-checklist.md']) == form['extra']
 assert 'hourly or other recurring machine rental' in transformed['01-domain-model.md']
 assert 'allow_orders' in transformed['01-domain-model.md']
 assert '`API-7`\'s step 5d at admission and `OPS-43`\'s step 3 at claim' in prv
 receipt['forms'][key]={'sites':[b['site'] for b in form['blocks']],'definition_owned_by_DOM16':form['central'],'explicit_hourly_cases':form['extra'],'undefined_scope_removed':True,'consumer_quotes_preserved':True,'sha256':hashlib.sha256((p/f'form-{key}.md').read_bytes()).hexdigest()}
for seat in ['fable','opus','astra','sol','consistency']:
 assert subprocess.check_output(['git','-C',str(p/seat),'rev-parse','HEAD'],text=True).strip()==pin
 status=subprocess.check_output(['git','-C',str(p/seat),'status','--porcelain'],text=True)
 assert not status,(seat,status)
 receipt['clones'][seat]={'pin':pin,'clean':True}
for name in ['run-codex.sh','run-claude-stdin.sh']:
 expected=(Path('/var/tmp/provisiond-panel-r82')/name).read_text().replace('/var/tmp/provisiond-panel-r82','/var/tmp/provisiond-panel-r89')
 assert (p/name).read_text()==expected,name
 receipt['wrappers'][name]='r82 path substitution only'
brief=(p/'brief.md').read_text();notes=(p/'notes.md').read_text()
assert '"Every paid create (Recommended)"' in brief
settle='a question is settled when at least three agree and more agree than disagree, and a tie comes to you. If grok is down, it falls back to three of four'
assert settle in notes
assert 'apply notes.md rule 6 exactly as written; this prompt adds no void rule' in brief
assert (p/'check/gate-before.exit').read_text().strip()=='0'
receipt['baseline_gate_before']=0
receipt['brief_sha256']=hashlib.sha256((p/'brief.md').read_bytes()).hexdigest()
receipt['notes_sha256']=hashlib.sha256((p/'notes.md').read_bytes()).hexdigest()
(p/'check/packet-verification.json').write_text(json.dumps(receipt,indent=2)+'\n')
print('packet verification PASS: source ranges, retained dependents, complete exact forms, undefined aliases, consumer quotations, clean pinned clones, copied wrappers, owner rule and packet size')
