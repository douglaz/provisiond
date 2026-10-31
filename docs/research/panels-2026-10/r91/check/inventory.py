from pathlib import Path
import contextlib, importlib.util, inspect, io, json, sys
P=Path('/var/tmp/provisiond-panel-r91')
sys.path.insert(0,str(P/'check/spec/tools'))
import check_citations as c
records=[]
source=inspect.getsource(c.find)
source=source.replace('                    checked += 1\n', '''                    records.append({'file':f,'owner':owner,'quote':q,'chunk':sent,
                                    'quote_position_in_chunk':_pos,
                                    'passes':any(contains_quote(p, q) for p in pool)})
                    checked += 1
''')
ns=dict(c.__dict__,records=records)
exec(source,ns)
docs,adrs,reqs=c.load()
lean=c.load_lean_docstrings()
ns['find'](docs,adrs,reqs)
ns['find'](lean,adrs,reqs,corpus=docs)
(P/'current-attributions.json').write_text(json.dumps(records,ensure_ascii=False,indent=2)+'\n')
# Record every generated quote-content case, including all corruption variants.
cases=[]
def profile(frame,event,arg):
    if event=='return' and frame.f_code.co_name=='check_quote_content':
        cases.extend(frame.f_locals['cases'])
sys.setprofile(profile)
with contextlib.redirect_stdout(io.StringIO()):
    assert c.check_quote_content()==0
sys.setprofile(None)
(P/'existing-quote-content-cases.json').write_text(json.dumps([
    dict(name=n,source=s,quote=q,accepted=a,exists_ok=e) for n,s,q,a,e in cases],ensure_ascii=False,indent=2)+'\n')
(P/'existing-checker.py').write_text(Path(c.__file__).read_text())
print('current attributions',len(records),'quote-content definitions',len(cases))
for file in ['current-attributions.json','existing-quote-content-cases.json','existing-checker.py']:
    print(file,(P/file).stat().st_size)
