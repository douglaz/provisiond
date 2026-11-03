"""r100 citation trial at BASE 2cb8e11, copied from /var/tmp/provisiond-manager/dr-e45e-check/citation-trial.py
(read only there). Applies comment 857's edits, with each r100 form substituted for the span it replaces, plus
the PRV-10 form (F-QUOTE, or F-QUOTE-Q5 under Q5-QUOTE), to a fresh clone at BASE, then runs
tools/check_citations.py. Each clone is deleted after its run; diff, log and exit are kept."""
from pathlib import Path
import subprocess, json, re, hashlib, shutil
P = Path('/var/tmp/provisiond-panel-r100'); C = P / 'check'; R = Path('/home/user/projects/provisiond-spec')
BASE = '2cb8e1189310ae096e598bac798df3437be59500'; PIN = 'b5f71e78a1f195acfa4ac28f090d38e9a35568f0'
IDXBUILD = '514b4a4ac92c73798c2a9ab3369970008c952f26'
IDX = R / 'tools/formal/.lake/index.jsonl'
assert hashlib.sha256(IDX.read_bytes()).hexdigest() == '7d378b871bcc783cc91b0aa5d29a6ffd10d3a5c1a588fbb7283bf04a7989fcd9'
FQ0 = C / 'F-QUOTE.txt'; FQ5 = C / 'F-QUOTE-Q5.txt'
assert hashlib.sha256(FQ0.read_bytes()).hexdigest() == '2393f71eef02a593e37ca93d6dc4bd441bfc928a0bbeff4e9939e43a34bf2323'
rows = [json.loads(l) for l in subprocess.check_output(['git', 'show', BASE + ':.beads/issues.jsonl'], cwd=R, text=True).splitlines() if l.strip()]
row = [r for r in rows if r['id'] == 'pv-e45e']; assert len(row) == 1; row = row[0]
BRIEF = [c['text'] for c in row['comments'] if c['id'] == 857][0]
assert BRIEF == Path('/var/tmp/provisiond-panel-r98/evidence/pv-e45e-comment-857.md').read_text()
QS = ['Q1', 'Q2', 'Q3', 'Q4', 'Q5', 'Q6', 'Q7']
def rd(n): return (P / n).read_text()[:-1]  # each Qn-*.txt ends with one LF that is not part of the span
OLD = {q: rd(f'{q}-OLD.txt') for q in QS}
QUOTE = {q: rd(f'{q}-QUOTE.txt') for q in QS}
Q4KEEP = rd('Q4-KEEP.txt')
log = []

def one(text, old, new, tag):
    n = text.count(old); assert n == 1, (tag, n); log.append(tag); return text.replace(old, new, 1)

def edit(T, path, old, new, tag):
    f = T / path; f.write_text(one(f.read_text(), old, new, tag))

def blocks(subs):
    b = BRIEF
    for old, new, tag in subs:
        b = one(b, old, new, 'form ' + tag)
    B = re.findall(r'```text\n(.*?)\n```', b, re.S); assert len(B) == 20, len(B)
    return B

def apply_brief(T, B):
    cur5d, cur3, new5d, newtail, new3, new5, ops23ins, sum05, sto50, cnf55, cnf19 = B[0:11]
    l19o, l19n, l317o, l317n, l1181o, l1181n, l1205o, l1205n = B[11:19]
    edit(T, '04-api-contract.md', cur5d, new5d, 'API-7 5d')
    api = (T / '04-api-contract.md').read_text()
    assert api.count('**Rich purchase tails') == 1
    s = api.index('**Rich purchase tails'); e = api.index('no listing is stored.', s) + len('no listing is stored.')
    (T / '04-api-contract.md').write_text(api[:s] + newtail + api[e:]); log.append('API-7 tail opening')
    edit(T, '03-operation-lifecycle.md', cur3, new3, 'OPS-43 step 3')
    old5 = ("5. Check for the named offer's absence from that result, applying the create-tail verdict quoted\n"
            "   above; if present, re-test the named offer for sale on that result and the running descriptor.")
    edit(T, '03-operation-lifecycle.md', old5, new5, 'OPS-43 step 5')
    a23 = '"Obtain the current driver List offers\nresult", after that read.\n'
    edit(T, '03-operation-lifecycle.md', a23, a23 + '\n' + ops23ins + '\n', 'OPS-23 insert')
    edit(T, '05-persistence.md', "the **offer snapshot** (`offer_id`, the offer's `install_strategies` as accepted,",
         sum05, '05 request_summary')
    sa = "on the `request_summary` row. *Amended 2026-10-16 (`ADR-0037`, `pv-tsb`).*"
    edit(T, '05-persistence.md', sa, sa + '\n  ' + sto50.replace('\n', '\n  '), 'STO-50')
    ca = "per-request purchase acknowledgement and the account-level opt-in."
    edit(T, '10-conformance-checklist.md', ca, ca + ' ' + cnf55.replace('\n', '\n      '), 'CNF-55')
    fa = "so the test proves the outer gate exists. (`DOM-10`, `DEF-10`)"
    edit(T, '10-conformance-checklist.md', fa, fa + '\n      ' + cnf19.replace('\n', '\n      '), 'CNF-19')
    L = 'tools/formal/Provisiond/Admission.lean'
    for o, n, t in ((l19o, l19n, 'L19'), (l317o, l317n, 'L317'), (l1181o, l1181n, 'L1181'), (l1205o, l1205n, 'L1205')):
        edit(T, L, o, n, t)

def fquote(T, B, fq):
    cur5d, cur3, new5d = B[0:3]; new3 = B[4]
    t = (T / '02-provider-contract.md').read_text()
    s = t.index("The configuration half is `DOM-10`'s gate"); e = t.index('then the capability gate”.', s) + len('then the capability gate”.')
    assert t.count("The configuration half is `DOM-10`'s gate") == 1
    o5 = cur5d[len('5d. '):-1]; n5 = new5d[len('5d. '):-1]; o3 = cur3[len('3. '):-1]; n3 = new3[len('3. '):-1]
    old = t[s:e]
    assert old.count('`API-7` says “' + o5 + '”') == 1 and old.count('`OPS-43` says “' + o3 + '”') == 1
    rule = old.replace('`API-7` says “' + o5 + '”', '`API-7` says “' + n5 + '”').replace('`OPS-43` says “' + o3 + '”', '`OPS-43` says “' + n3 + '”')
    if fq is None:  # N-Q5 control only: PRV-10 re-sliced from the WRONGWORD step 3 by the r98 rule
        new = rule; tag = 'rule-derived'
    else:
        new = fq.read_text().rstrip('\n'); tag = fq.name
        assert new == rule
    (T / '02-provider-contract.md').write_text(t[:s] + new + t[e:]); log.append('PRV-10 ' + tag)

FORMAL = ['tools/formal', 'tools/check-all.sh', 'tools/check_citations.py', 'tools/check_formal.sh', 'tools/check_formal.py',
          'tools/lean_region_emitter.py', 'flake.nix', 'flake.lock']

def setup(name):
    T = C / name
    if T.exists(): shutil.rmtree(T)
    subprocess.run(['git', 'clone', '--no-hardlinks', '--quiet', str(R), str(T)], check=True)
    subprocess.run(['git', 'checkout', '--quiet', '--detach', BASE], cwd=T, check=True)
    files = subprocess.check_output(['git', 'ls-files'] + FORMAL, cwd=T, text=True).splitlines()
    for f in files:
        assert (T / f).read_bytes() == subprocess.check_output(['git', 'show', IDXBUILD + ':' + f], cwd=R), f
    tgt = T / 'tools/formal/.lake/index.jsonl'; tgt.parent.mkdir(parents=True, exist_ok=True); shutil.copyfile(IDX, tgt)
    return T, len(files)

def wrong(q):
    """QUOTE form of q with the third word of its first quotation replaced by WRONGWORD."""
    f = QUOTE[q]; m = re.search(r'says\s+"([^"]+)"', f); assert m, q
    seg = m.group(1); ws = list(re.finditer(r'\S+', seg)); w = ws[2]
    bad = seg[:w.start()] + 'WRONGWORD' + seg[w.end():]
    return f[:m.start(1)] + bad + f[m.end(1):], w.group(0)

KEEP4 = (OLD['Q4'], Q4KEEP, 'Q4-KEEP')
def subs_for(sel, wrongq=None):
    s = []
    for q in QS:
        if q in sel:
            new = QUOTE[q]
            if q == wrongq: new = wrong(q)[0]
            s.append((OLD[q], new, f'{q}-QUOTE' + ('-WRONGWORD' if q == wrongq else '')))
        elif q == 'Q4':
            s.append(KEEP4)
    return s

trials = [('T0', None, None, None), ('T-ASIS', [], FQ0, None), ('T-KEEP', subs_for([]), FQ0, None)]
trials += [(f'T-{q}', subs_for([q]), FQ5 if q == 'Q5' else FQ0, None) for q in QS]
trials += [('T-ALL', subs_for(QS), FQ5, None)]
trials += [(f'N-{q}', subs_for(QS, q), None if q == 'Q5' else FQ5, q) for q in QS]

out = {'base': BASE, 'index_sha256': hashlib.sha256(IDX.read_bytes()).hexdigest(), 'index_build_commit': IDXBUILD,
       'wrongword': {q: wrong(q)[1] for q in QS}, 'trials': {}}
for name, subs, fq, wq in trials:
    log.clear()
    T, nfiles = setup('clone-' + name)
    if subs is not None:
        B = blocks(subs); apply_brief(T, B); fquote(T, B, fq)
    (C / f'trial-{name}.diff').write_bytes(subprocess.check_output(['git', 'diff'], cwd=T))
    with (C / f'trial-{name}.log').open('w') as fh:
        r = subprocess.run(['python3', 'tools/check_citations.py'], cwd=T, stdout=fh, stderr=subprocess.STDOUT)
    (C / f'trial-{name}.exit').write_text(f'{r.returncode}\n')
    shutil.rmtree(T)
    out['trials'][name] = {'exit': r.returncode, 'formal_inputs_equal_to_index_build': nfiles, 'edits': list(log),
                           'diff_sha256': hashlib.sha256((C / f'trial-{name}.diff').read_bytes()).hexdigest()}
    print(name, r.returncode, len(log), flush=True)
dr = json.loads(Path('/var/tmp/provisiond-manager/dr-e45e-check/trial.json').read_text())
out['dr_e45e_T2_diff_sha256'] = dr['trials']['T2']['diff_sha256']
out['T_ASIS_reproduces_dr_e45e_T2'] = out['trials']['T-ASIS']['diff_sha256'] == dr['trials']['T2']['diff_sha256']
(C / 'trial.json').write_text(json.dumps(out, indent=2) + '\n')
print(out['T_ASIS_reproduces_dr_e45e_T2'])
