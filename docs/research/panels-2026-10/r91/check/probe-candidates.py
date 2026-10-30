from pathlib import Path
import ast, importlib.util, inspect, json, os, shutil, subprocess, sys, tempfile
P=Path('/var/tmp/provisiond-panel-r91')
base=P/'check/spec'
receipts=[]
for kind in ('N','A','B','C'):
    root=P/'tmp'/('manager-'+kind)
    shutil.copytree(base,root,ignore=shutil.ignore_patterns('.git','.lake','__pycache__'),dirs_exist_ok=True)
    target=root/'tools/check_citations.py'
    target.write_bytes((P/'candidates'/kind/'tools/check_citations.py').read_bytes())
    (root/'10-conformance-checklist.md').write_bytes((P/'candidates'/kind/'10-conformance-checklist.md').read_bytes())
    (root/'tools/formal/.lake').mkdir(exist_ok=True)
    shutil.copy2(base/'tools/formal/.lake/index.jsonl',root/'tools/formal/.lake/index.jsonl')
    r=subprocess.run(['python3','tools/check_citations.py'],cwd=root,capture_output=True,text=True)
    (P/'check'/f'candidate-{kind}-cli.log').write_text(r.stdout+r.stderr)
    print(kind, 'CLI',r.returncode, flush=True)
    receipt={'candidate':kind,'cli_exit':r.returncode}
    if kind!='N' and r.returncode==0:
        r=subprocess.run(['python3',str(P/'candidates'/kind/'ci-control.py')],cwd=root,capture_output=True,text=True,env={**os.environ,'TMPDIR':str(P/'tmp')})
        (P/'check'/f'candidate-{kind}-ci.log').write_text(r.stdout+r.stderr)
        receipt['ci_exit']=r.returncode
        print(kind,'CI',r.returncode,flush=True)
    receipts.append(receipt)
(P/'check/candidate-results.json').write_text(json.dumps(receipts,indent=2)+'\n')
