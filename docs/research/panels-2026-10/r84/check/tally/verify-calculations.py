from pathlib import Path
import hashlib,json,subprocess,re
p=Path('/var/tmp/provisiond-panel-r84'); repo=p/'check/spec'; b=(p/'brief.md').read_text()
sets={'A':{9,10,11,12,13,32},'B':{9,10,12,13,32}}
def trim(s,ws):
 a,z=0,len(s)
 while a<z and ord(s[a]) in ws:a+=1
 while z>a and ord(s[z-1]) in ws:z-=1
 return s[a:z]
def norm(s,ws):
 s=trim(s,ws).translate(str.maketrans('ABCDEFGHIJKLMNOPQRSTUVWXYZ','abcdefghijklmnopqrstuvwxyz'))
 return s[2:] if s.startswith('0x') else s
hashes=[]
for form,ws in sets.items():
 for c in [8,9,10,11,12,13,14,31,32,127,160]:
  ch=chr(c); raw=ch+'0XAb'+ch
  assert norm(raw,ws)==('ab' if c in ws else ch+'0xab'+ch)
  assert norm(ch,ws)==('' if c in ws else ch)
  assert norm('0XA'+ch+'B',ws)=='a'+ch+'b'
 assert norm(' 0x0XAB ',ws)=='0xab'
 assert norm('0X',ws)==''
 assert norm(' 0X/DeV/sda ',ws)=='/dev/sda'
 for field in ['serial','wwn']:
  d={'serial':None,'wwn':None,'size_bytes':1024};d[field]=norm('\v0XAb\v',ws)
  row={'form':form,'field':field}
  for name,v in [('list',[d]),('element',d)]:
   raw=json.dumps(v,sort_keys=True,separators=(',',':'),ensure_ascii=False).encode()
   row[name]={'bytes':raw.decode(),'sha256':hashlib.sha256(raw).hexdigest()}
  assert row['list']['sha256'] in b
  assert row['list']['sha256']!=row['element']['sha256']
  hashes.append(row)
assert len(('é'*512).encode())==1024 and len(('é'*512+'a').encode())==1025
assert len(('é'*128).encode())==256 and len(('é'*128+'a').encode())==257
assert json.loads('"'+r'\u0061'*1024+'"')=='a'*1024
(p/'check/tally/calculations.json').write_text(json.dumps(hashes,indent=2)+'\n')
print('Independent normalization, prefix, UTF-8 and supplied-list-hash assertions PASS.')
for h in hashes: print(h['form'],h['field'],'list',h['list']['sha256'],'element',h['element']['sha256'])
rows=[json.loads(l) for l in (repo/'.beads/issues.jsonl').read_text().splitlines()]
for ident in ['pv-ez8','pv-2j3','pv-tbrs','pv-wfld']:
 r=next(x for x in rows if x['id']==ident);print(ident,r.get('status'),r.get('labels'))
for name in ['check/spec','fable','opus','astra','sol']:
 head=subprocess.check_output(['git','rev-parse','HEAD'],cwd=p/name,text=True).strip()
 status=subprocess.check_output(['git','status','--porcelain=v1'],cwd=p/name,text=True)
 assert head=='3109b5b44eae17e288cf52aaa976993bd8c5626c'
 assert not status,(name,status)
 print(name,head,'clean')
print('Initial unpiped gate exit:',(p/'check/gate-tally-before.exit').read_text().strip())
for ident in ['API-13','RSC-46','SEC-29','OPS-23','RSC-23']:
 tags=[]
 for f in (repo/'tools/formal').rglob('*.lean'):
  if re.search(r'@\[req "'+ident+r'"\]',f.read_text()):tags.append(str(f.relative_to(repo)))
 print('formal tags',ident,tags)
