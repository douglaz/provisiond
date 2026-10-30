from pathlib import Path
import re,json,subprocess,hashlib
P=Path('/var/tmp/provisiond-panel-r84'); C=P/'check'; pin='3109b5b44eae17e288cf52aaa976993bd8c5626c'
for name in ['quota-prelaunch-claude','quota-prelaunch-codex']:
 assert (C/(name+'.exit')).read_text().strip()=='0', name
s=(C/'quota-prelaunch-claude.out').read_text()
vals={name:int(re.search(re.escape(name)+r':\s*(\d+)%',s).group(1)) for name in ['Current session','Current week (all models)','Current week (Fable)']}
line=next(l for l in (C/'quota-prelaunch-codex.out').read_text().splitlines() if l.lstrip().startswith('●'))
w=int(re.search(r'(\d+)%',line).group(1))
assert vals['Current session']<=80 and vals['Current week (all models)']<=80, 'Claude hold'
assert w<100, 'Codex hold at 100%'
for name in ['gate-before','gate-final','consistency']:
 assert (C/(name+'.exit')).read_text().strip()=='0',name
assert (C/'consistency-disposition.md').exists(), 'Consistency result must be read and dispositioned before launch'
b=(P/'brief.md').read_text(); n=(P/'notes.md').read_text()
for r in json.loads((C/'source-receipt.json').read_text()):
 q='\n'.join((C/'spec'/r['file']).read_text().splitlines()[r['first']-1:r['last']]); assert '\n'+q+'\n' in b
assert 'a question is settled when at least three agree and more agree than disagree, and a tie comes to you. If grok is down, it falls back to three of four' in n
assert 'apply notes.md rule 6 exactly as written; this prompt adds no void rule' in b and 'apply notes.md rule 6 exactly as written; this prompt adds no void rule' in n
for f in ['run-codex.sh','run-claude-stdin.sh','launch.sh']:
 expected=(Path('/var/tmp/provisiond-panel-r82')/f).read_text().replace('r82','r84')
 if f=='launch.sh': expected=expected.replace('panel-r84-$seat-stdin','panel-r84-$seat')
 assert (P/f).read_text()==expected
for seat in ['fable','opus','astra','sol']:
 def git(*args): return subprocess.check_output(['git','--no-optional-locks','-C',str(P/seat),*args],text=True).strip()
 assert git('rev-parse','HEAD')==pin and git('rev-parse','origin/master')==pin
 assert not git('status','--porcelain=v1') and not git('branch','--show-current')
 assert not (P/(seat+'.exit')).exists()
# No main write: inspect only, optional Git index refresh disabled.
main='/home/user/projects/provisiond-spec'
assert subprocess.check_output(['git','--no-optional-locks','-C',main,'rev-parse','HEAD'],text=True).strip()==pin
assert not subprocess.check_output(['git','--no-optional-locks','-C',main,'status','--porcelain=v1'],text=True).strip()
r={'Claude':vals,'Codex_active_week':w,'hold':False,'pin':pin,'clones_clean':True,'source_quotes_verified':True,'copied_scripts_paths_labels_only':True,'gates':[0,0],'main_clean':True,'packet_bytes':len(b.encode())+len(n.encode())}
(C/'quota-prelaunch.json').write_text(json.dumps(r,indent=2)+'\n')
(C/'packet.sha256').write_text(''.join(hashlib.sha256((P/f).read_bytes()).hexdigest()+'  '+f+'\n' for f in ['brief.md','notes.md','launch.sh','run-claude-stdin.sh','run-codex.sh']))
print(json.dumps(r,indent=2))
