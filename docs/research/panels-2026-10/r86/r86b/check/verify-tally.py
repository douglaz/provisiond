from pathlib import Path
import subprocess, json, re, hashlib, datetime, io, contextlib, importlib.util, sys
P=Path('/var/tmp/provisiond-panel-r86/r86b'); C=P/'check'; base=P.parent/'check/spec'
pin='3109b5b44eae17e288cf52aaa976993bd8c5626c'
def sha(b): return hashlib.sha256(b).hexdigest()
def git(*a): return subprocess.check_output(['git','-C',str(base),*a])
assert git('rev-parse','HEAD').decode().strip()==pin
brief=(P/'brief.md').read_bytes(); text=brief.decode()
r={'at':datetime.datetime.now(datetime.timezone.utc).isoformat(),'pin':pin,'packet':{},'answers':{},'historical_answers':{},'clones':{},'sources':[]}
for name in ('brief.md','notes.md'):
 b=(P/name).read_bytes();r['packet'][name]={'bytes':len(b),'sha256':sha(b)}
for seat in ('fable','opus','astra','sol'):
 b=(P/f'{seat}.md').read_bytes();assert len(b)>10000
 assert (P/f'{seat}.exit').read_text().strip()=='0'
 d={}
 for suffix in ('.md','.exit','.out','.err','.draft.md'):
  q=P/(seat+suffix)
  if q.exists():
   bb=q.read_bytes();d[suffix]={'bytes':len(bb),'sha256':sha(bb)}
   if suffix=='.out':assert bb.strip()==b.strip()
 r['answers'][seat]={'substantive':True,'final_pick_Q1':'Q1-A','final_pick_Q2':'Q2-A-cited' if seat in ('fable','opus') else 'Q2-B-cited','files':d}
 marker=f'<!-- BEGIN VERBATIM R86 {seat} -->\n'.encode()
 block=brief.split(marker,1)[1].split(f'<!-- END VERBATIM R86 {seat} -->'.encode(),1)[0]
 old=(P.parent/f'{seat}.md').read_bytes();history=(P/'history'/f'{seat}.md')
 if not history.exists():history=P/'history'/f'r86-{seat}.md'
 assert block.startswith(old) and not block[len(old):].strip()
 assert history.read_bytes()==old
 start=text[:text.index(marker.decode())].count('\n')+2
 r['historical_answers'][seat]={'bytes':len(old),'sha256':sha(old),'verbatim':True,'brief_first_answer_line':start,'brief_last_answer_line':start+old.decode().count('\n')-1}
 for root in (P/seat,):
  head=subprocess.check_output(['git','-C',str(root),'rev-parse','HEAD']).decode().strip()
  status=subprocess.check_output(['git','-C',str(root),'status','--porcelain']).decode()
  assert head==pin and not status
  r['clones'][seat]={'head':head,'status':status}
# Verify printed pin excerpts independently against git objects; no main-tree reads.
pat=r'`([^`\n]+\.md):(\d+)–(\d+)` at `'+pin+r'`:\n\n````text\n(.*?)````'
for m in re.finditer(pat,text,re.S):
 f,a,z,b=m.groups();src=git('show',f'{pin}:{f}').decode().splitlines(keepends=True)
 assert b==''.join(src[int(a)-1:int(z)]),(f,a,z)
 r['sources'].append({'path':f,'first':int(a),'last':int(z),'matches_pin':True})
# Formal, guard amendment, and corrected OVR/OPS excerpts.
for f,a,z in [('00-overview.md',22,24),('03-operation-lifecycle.md',17,18),('tools/formal/Provisiond/Admission.lean',15,20),('tools/formal/Provisiond/Admission.lean',317,320),('tools/formal/Provisiond/Admission.lean',1180,1257),('docs/adr/0025-a-formalized-clause-lives-in-lean-and-the-markdown-renders-it.md',175,196)]:
 b=''.join(git('show',f'{pin}:{f}').decode().splitlines(keepends=True)[a-1:z])
 assert b in text,(f,a,z)
 r['sources'].append({'path':f,'first':a,'last':z,'matches_pin':True})
for form in ('Q1-A','Q1-B','Q2-A','Q2-B','Q2-A-prime','Q2-A-cited','Q2-B-cited'):
 b=(P/f'{form}.md').read_bytes();assert b in brief,form
 r.setdefault('exact_forms',{})[form]={'bytes':len(b),'sha256':sha(b),'in_packet_verbatim':True}
r['Q1_consensus_shape']={'aim_and_other_answers':'brief.md:3','disagreements':'brief.md:39-47','complete_A':'brief.md:686-743','complete_B':'brief.md:745-785 (API/OPS pointer insertions explicitly incorporated from A at line 785)','complete_C0':'brief.md:787-789','accept_and_final_request':'brief.md:1333','address_actual_dissent':'brief.md:1335','historical_answer_ranges':r['historical_answers']}
(C/'tally-verification.json').write_text(json.dumps(r,indent=2)+'\n')
# Read terminal streams in full, retain focused diagnostic receipts without copying session traces.
streams={}
for seat in ('fable','opus','astra','sol'):
 f=P/f'{seat}.err';s=f.read_text();lines=s.splitlines()
 hits=[(i+1,l[:500]) for i,l in enumerate(lines) if re.search(r'(?i)(not signed in|you.ve hit|session.limit|usage.limit|timed out|permission denied|selected model is at capacity|API error)',l)]
 streams[seat]={'lines':len(lines),'tail':lines[-5:],'diagnostic_matches':hits}
(C/'tally-stream-inspection.json').write_text(json.dumps(streams,indent=2)+'\n')
# Re-run existing citation checker read-only on reader-applied exact candidates.
# Use the authoritative same-pin index published by this turn's successful full base gate.
index=base/'tools/formal/.lake/index.jsonl';assert index.exists()
checks={}
for label,dirname in [('base','base'),('Q1-A','c-Q1-A-printed'),('Q2-A','c-Q2-A-printed'),('Q2-B','c-Q2-B-printed'),('Q2-A-prime','c-Q2-A-prime-printed'),('Q2-A-cited','c-Q2-A-cited-printed'),('Q2-B-cited','c-Q2-B-cited-printed'),('Q1A+Q2Acited','c-Q1A+Q2Acited-ticks'),('Q1A+Q2Bcited','c-Q1A+Q2Bcited-ticks')]:
 root=P/'tmp/fable'/dirname
 name='tally_citations_'+label.replace('-','_').replace('+','_')
 spec=importlib.util.spec_from_file_location(name,root/'tools/check_citations.py')
 module=importlib.util.module_from_spec(spec);sys.modules[name]=module;spec.loader.exec_module(module)
 module.INDEX=str(index)
 out=io.StringIO()
 with contextlib.redirect_stdout(out):rc=module.main()
 log=C/f'tally-citations-{label}.log';log.write_text(out.getvalue())
 expected=1 if label in ('Q2-A','Q2-B') else 0
 assert rc==expected,(label,rc)
 checks[label]={'exit':rc,'log':log.name,'actual_same_pin_index_sha256':sha(index.read_bytes())}
(C/'tally-citation-checks.json').write_text(json.dumps(checks,indent=2)+'\n')
print(json.dumps({'answers':{s:(x['final_pick_Q1'],x['final_pick_Q2']) for s,x in r['answers'].items()},'source_blocks':len(r['sources']),'history':{s:(v['brief_first_answer_line'],v['brief_last_answer_line']) for s,v in r['historical_answers'].items()},'citation_checks':{k:v['exit'] for k,v in checks.items()},'diagnostic_hit_counts':{k:len(v['diagnostic_matches']) for k,v in streams.items()}},indent=2))
