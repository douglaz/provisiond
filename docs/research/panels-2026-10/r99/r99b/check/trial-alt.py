"""r99b scratch citation trial of the forms first printed in r99's answers, at efb40cc.
A-Q4ALT: Q1-QUOTE (settled) + Q4-ALT. A-ALL: Q1-QUOTE + Q2-QUOTE + Q4-ALT + R-NOTE-ALT's Q1-A.md append.
N-Q4ALT: A-ALL with one word of Q4-ALT's new third quotation corrupted (negative control: the gate
must fail naming OPS-41). Same method and read-only lake index as r99's check/trial.py."""
from pathlib import Path
import subprocess, json, hashlib, shutil

R = Path('/var/tmp/provisiond-panel-r99'); B = R / 'r99b'; C = B / 'check'
PIN = (R / 'PIN').read_text().strip()
IDX = Path('/var/tmp/rloop-units/provisiond-spec-pv-5pmu-1103T0348/citation-trial/tools/formal/.lake/index.jsonl')
IDXSRC = IDX.parents[3]
assert hashlib.sha256(IDX.read_bytes()).hexdigest() == '7d378b871bcc783cc91b0aa5d29a6ffd10d3a5c1a588fbb7283bf04a7989fcd9'

def rd(p): return p.read_text()[:-1]  # strip the file's trailing newline

FORMS = {'Q1': R / 'Q1-QUOTE.txt', 'Q2': R / 'Q2-QUOTE.txt', 'Q4': B / 'forms/Q4-ALT.txt'}

def apply(T, qs, corrupt=False):
    f = T / '01-domain-model.md'; t = f.read_text()
    for q in qs:
        old, new = rd(R / f'{q}-OLD.txt'), rd(FORMS[q])
        if corrupt and q == 'Q4':
            a = 'The short deferrals in steps 3 and 4'
            assert new.count(a) == 1; new = new.replace(a, 'The short WRONGWORD in steps 3 and 4')
        assert t.count(old) == 1, q; t = t.replace(old, new, 1)
    f.write_text(t)

def note(T):
    f = T / 'docs/research/panels-2026-10/r86/r86b/Q1-A.md'
    f.write_text(f.read_text() + (B / 'forms/R-NOTE-ALT-append.md').read_text())

def setup(name):
    T = C / name
    if T.exists(): shutil.rmtree(T)
    subprocess.run(['git', 'clone', '--no-hardlinks', '--quiet', str(R / 'check/repo'), str(T)], check=True)
    subprocess.run(['git', 'checkout', '--quiet', '--detach', PIN], cwd=T, check=True)
    files = subprocess.check_output(['git', 'ls-files', 'tools/formal', 'tools/check_citations.py'], cwd=T, text=True).splitlines()
    for f in files:
        assert (T / f).read_bytes() == (IDXSRC / f).read_bytes(), f
    tgt = T / 'tools/formal/.lake/index.jsonl'; tgt.parent.mkdir(parents=True, exist_ok=True); shutil.copyfile(IDX, tgt)
    return T, len(files)

trials = [('A-Q4ALT', lambda T: apply(T, ['Q1', 'Q4'])),
          ('A-ALL', lambda T: (apply(T, ['Q1', 'Q2', 'Q4']), note(T))),
          ('N-Q4ALT', lambda T: (apply(T, ['Q1', 'Q2', 'Q4'], corrupt=True), note(T)))]
out = {'pin': PIN, 'index_sha256': hashlib.sha256(IDX.read_bytes()).hexdigest(), 'trials': {}}
for name, step in trials:
    T, nfiles = setup('trial-' + name)
    step(T)
    (C / f'trial-{name}.diff').write_bytes(subprocess.check_output(['git', 'diff'], cwd=T))
    with (C / f'trial-{name}.log').open('w') as fh:
        r = subprocess.run(['python3', 'tools/check_citations.py'], cwd=T, stdout=fh, stderr=subprocess.STDOUT)
    log = (C / f'trial-{name}.log').read_text()
    rec = {'exit': r.returncode, 'formal_inputs_equal_to_index_source': nfiles,
           'diff_sha256': hashlib.sha256((C / f'trial-{name}.diff').read_bytes()).hexdigest(),
           'summary': [l.strip() for l in log.splitlines() if l.startswith(('FAIL', 'unquoted attributions', 'quotes compared', 'OK', 'Checked')) or 'attributes to' in l or 'compared' in l]}
    if name.startswith('N-'):
        rec['expected_owner_named'] = 'attributes to OPS-41 a phrase' in log
    shutil.rmtree(T)
    out['trials'][name] = rec
    print(name, r.returncode, rec.get('expected_owner_named', ''))
(C / 'trial-alt.json').write_text(json.dumps(out, indent=2) + '\n')
