from pathlib import Path
import re,json
p=Path('/var/tmp/provisiond-panel-r89')
claude=(p/'check/quota-prelaunch-claude.txt').read_text();codex=(p/'check/quota-prelaunch-codex.txt').read_text()
values={}
for field in ['Current session','Current week (all models)','Current week (Fable)']:
 m=re.search(re.escape(field)+r':\s*(\d+)%',claude)
 if not m: raise SystemExit('HOLD: unavailable Claude reading '+field)
 values[field]=int(m.group(1))
 if field!='Current week (Fable)' and values[field]>80:raise SystemExit('HOLD: '+field+' over 80%')
m=re.search(r'●[^\n]*?\s(\d+)%',codex)
if not m:raise SystemExit('HOLD: active Codex WEEK unavailable')
values['active Codex WEEK']=int(m.group(1))
if values['active Codex WEEK']>=100:raise SystemExit('HOLD: active Codex WEEK at 100%; never switch/logout')
for name in ['before','final']:
 f=p/'check'/f'gate-{name}.exit'
 if not f.exists() or f.read_text().strip()!='0':raise SystemExit('WAIT: required unpiped '+name+' gate has not passed')
assert (p/'check/consistency.exit').read_text().strip()=='0'
assert (p/'check/consistency-disposition.md').exists()
probe=(p/'check/grok-probe.txt').read_text()
assert '402' in probe or 'Not signed in' in probe,'Unexpected probe result: evaluate before launch'
values['grok']='missing: 402' if '402' in probe else 'missing: Not signed in'
values['threshold']='three of four'
(p/'check/prelaunch-guard.json').write_text(json.dumps(values,indent=2)+'\n')
print('launch guard PASS: '+json.dumps(values))
