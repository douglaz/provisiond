"""r99 scratch citation trial at efb40cc. T0: pin as is. T1: all five QUOTE forms. T-Qn: one QUOTE form.
T2: T1 plus R-NOTE's Q1-A.md append. N-Qn: T1 with one word of Qn's first quote corrupted (negative
control: the gate must fail naming Qn's owner, proving the quote is in the gate's reach)."""
from pathlib import Path
import subprocess, json, hashlib, shutil

P = Path('/var/tmp/provisiond-panel-r99'); C = P / 'check'
PIN = (P / 'PIN').read_text().strip()
IDX = Path('/var/tmp/rloop-units/provisiond-spec-pv-5pmu-1103T0348/citation-trial/tools/formal/.lake/index.jsonl')
IDXSRC = IDX.parents[3]
QS = ['Q1', 'Q2', 'Q3', 'Q4', 'Q5']
OWNER = {'Q1': 'PRV-25', 'Q2': 'API-64', 'Q3': 'OPS-11', 'Q4': 'OPS-41', 'Q5': 'PRV-4'}
CORRUPT = {'Q1': ('ordinary authorization', 'ordinary WRONGWORD'),
           'Q2': ('the enqueue and', 'the WRONGWORD and'),
           'Q3': ('classify the error', 'classify the WRONGWORD'),
           'Q4': ('make no provider call', 'make no WRONGWORD call'),
           'Q5': ('with no entry there', 'with no WRONGWORD there')}

def rd(n): return (P / n).read_text()[:-1]  # strip the file's trailing newline

def apply(T, qs, corrupt=None):
    f = T / '01-domain-model.md'; t = f.read_text()
    for q in qs:
        old, new = rd(f'{q}-OLD.txt'), rd(f'{q}-QUOTE.txt')
        if q == corrupt:
            a, b = CORRUPT[q]; assert new.count(a) == 1; new = new.replace(a, b)
        assert t.count(old) == 1, q; t = t.replace(old, new, 1)
    f.write_text(t)

def rnote(T):
    f = T / 'docs/research/panels-2026-10/r86/r86b/Q1-A.md'
    f.write_text(f.read_text() + (P / 'R-NOTE-append.md').read_text())

def setup(name):
    T = C / name
    if T.exists(): shutil.rmtree(T)
    subprocess.run(['git', 'clone', '--no-hardlinks', '--quiet', str(C / 'repo'), str(T)], check=True)
    subprocess.run(['git', 'checkout', '--quiet', '--detach', PIN], cwd=T, check=True)
    files = subprocess.check_output(['git', 'ls-files', 'tools/formal', 'tools/check_citations.py'], cwd=T, text=True).splitlines()
    for f in files:
        assert (T / f).read_bytes() == (IDXSRC / f).read_bytes(), f
    tgt = T / 'tools/formal/.lake/index.jsonl'; tgt.parent.mkdir(parents=True, exist_ok=True); shutil.copyfile(IDX, tgt)
    return T, len(files)

trials = [('T0', lambda T: None), ('T1', lambda T: apply(T, QS)),
          ('T2', lambda T: (apply(T, QS), rnote(T)))]
trials += [(f'T-{q}', (lambda q: lambda T: apply(T, [q]))(q)) for q in QS]
trials += [(f'N-{q}', (lambda q: lambda T: apply(T, QS, corrupt=q))(q)) for q in QS]

out = {'pin': PIN, 'index_sha256': hashlib.sha256(IDX.read_bytes()).hexdigest(), 'index_source': str(IDX), 'trials': {}}
for name, step in trials:
    T, nfiles = setup('trial-' + name)
    step(T)
    (C / f'trial-{name}.diff').write_bytes(subprocess.check_output(['git', 'diff'], cwd=T))
    with (C / f'trial-{name}.log').open('w') as fh:
        r = subprocess.run(['python3', 'tools/check_citations.py'], cwd=T, stdout=fh, stderr=subprocess.STDOUT)
    log = (C / f'trial-{name}.log').read_text()
    rec = {'exit': r.returncode, 'formal_inputs_equal_to_index_source': nfiles,
           'diff_sha256': hashlib.sha256((C / f'trial-{name}.diff').read_bytes()).hexdigest(),
           'summary': [l.strip() for l in log.splitlines() if l.startswith(('FAIL', 'unquoted attributions', 'quotes compared', 'OK', 'Checked')) or 'attributes to' in l]}
    if name.startswith('N-'):
        q = name[2:]
        rec['expected_owner_named'] = f'attributes to {OWNER[q]} a phrase' in log
    shutil.rmtree(T)
    out['trials'][name] = rec
    print(name, r.returncode, rec.get('expected_owner_named', ''))
(C / 'trial.json').write_text(json.dumps(out, indent=2) + '\n')
