from pathlib import Path
from collections import Counter
import ast, importlib.util, inspect, json, sys
P=Path('/var/tmp/provisiond-panel-r91')
sys.path.insert(0,str(P/'check/spec/tools'))
base=json.loads((P/'current-attributions.json').read_text())
key=lambda r:(r['file'],r['owner'],r['quote'],r['passes'])
old=Counter(map(key,base))
receipt={}
for kind in ['A','B','C']:
    path=P/'tmp/manager-final-verifier'/kind/'tools/check_citations.py'
    spec=importlib.util.spec_from_file_location('comparison_'+kind,path)
    c=importlib.util.module_from_spec(spec)
    sys.modules[spec.name]=c
    spec.loader.exec_module(c)
    records=[]
    source=inspect.getsource(c.find)
    source=source.replace('                    checked += 1\n', '''                    records.append(dict(file=f,owner=owner,quote=q,
                                        passes=any(contains_quote(p, q) for p in pool)))
                    checked += 1
''')
    namespace=dict(c.__dict__,records=records)
    exec(source,namespace)
    docs,adrs,reqs=c.load()
    lean=c.load_lean_docstrings()
    namespace['find'](docs,adrs,reqs)
    namespace['find'](lean,adrs,reqs,corpus=docs)
    new=Counter(map(key,records))
    lost=old-new
    assert not lost,(kind,lost)
    receipt[kind]={'lost_existing_comparisons':list(lost.elements()),'added_comparisons':list((new-old).elements())}
(P/'check/current-comparison-preservation.json').write_text(json.dumps(receipt,ensure_ascii=False,indent=2)+'\n')
print(json.dumps(receipt,ensure_ascii=False,indent=2))
