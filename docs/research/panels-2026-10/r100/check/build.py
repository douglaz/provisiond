"""r100 form builder. Every OLD span is checked to occur exactly once in the adopted package
(Q2-A-cited.md, read only) and in pv-e45e comment 857 (tracker at PIN); every quoted segment is
checked (whitespace-insensitive, exactly once) in its owner's text as the Run leaves it: the base
file at PIN, or the adopted block that the Run writes. Writes the form files at the packet root,
check/*.md prospective files, and forms.sha256. Writes nothing outside /var/tmp/provisiond-panel-r100."""
from pathlib import Path
import subprocess, hashlib, json, re

P = Path('/var/tmp/provisiond-panel-r100'); C = P / 'check'
R = Path('/home/user/projects/provisiond-spec')  # read only: git show
PIN = '2cb8e1189310ae096e598bac798df3437be59500'
(P / 'PIN').write_text(PIN + '\n')

def show(path):
    return subprocess.check_output(['git', '-C', str(R), 'show', f'{PIN}:{path}'], text=True)

QA_PATH = Path('/var/tmp/provisiond-panel-r86/r86b/Q2-A-cited.md')
QA = QA_PATH.read_text()
QA_REPO = 'docs/research/panels-2026-10/r86/r86b/Q2-A-cited.md'
assert show(QA_REPO) == QA
assert hashlib.sha256(QA.encode()).hexdigest() == 'd611bbae87294a0fc0087c567fa82aa1404cd0c5a54abe394b5327488ec51ea2'
rows = [json.loads(l) for l in show('.beads/issues.jsonl').splitlines() if l.strip()]
row = [r for r in rows if r['id'] == 'pv-e45e']; assert len(row) == 1
C857 = [c['text'] for c in row[0]['comments'] if c['id'] == 857][0]
assert C857 == Path('/var/tmp/provisiond-panel-r98/evidence/pv-e45e-comment-857.md').read_text()
(P / 'evidence').mkdir(exist_ok=True)
(P / 'evidence/pv-e45e-comment-857.md').write_text(C857)
(P / 'evidence/Q2-A-cited.md').write_text(QA)
B = re.findall(r'```text\n(.*?)\n```', C857, re.S); assert len(B) == 20
new5d, new5 = B[2], B[5]
FQ = Path('/var/tmp/provisiond-panel-r98/check/F-QUOTE.txt').read_text()
assert hashlib.sha256(FQ.encode()).hexdigest() == '2393f71eef02a593e37ca93d6dc4bd441bfc928a0bbeff4e9939e43a34bf2323'

SRC = {'OPS-11': ('03-operation-lifecycle.md', show('03-operation-lifecycle.md')),
       'CNF-55': ('10-conformance-checklist.md', show('10-conformance-checklist.md')),
       'API-7 5d': ('Q2-A-cited.md (adopted new API-7 step 5d, :6-15)', QA),
       'OPS-43 5': ('Q2-A-cited.md (adopted new OPS-43 step 5, :49-56)', QA),
       'OPS-43 4': ('03-operation-lifecycle.md', show('03-operation-lifecycle.md'))}

def ws(s): return ' '.join(s.split())
def line_of(t, i): return t.count('\n', 0, i) + 1
def locate(text, seg):
    pat = r'\s+'.join(re.escape(w) for w in seg.split())
    ms = list(re.finditer(pat, text)); assert len(ms) >= 1, (seg, len(ms))
    # First occurrence is the owner's own text (OPS-11 row 03:249 precedes OPS-43's verbatim re-quotes).
    return line_of(text, ms[0].start()), line_of(text, ms[0].end())
def span(text, old):
    assert text.count(old) == 1, (old[:60], text.count(old))
    i = text.index(old); a, b = line_of(text, i), line_of(text, i + len(old) - 1)
    return f'{a}' + (f'-{b}' if b != a else '')

ADM = "On admission, retain the named offer's kind as machine_kind in the create's request_summary offer snapshot"
Q = {
 'Q1': dict(site='OPS-23 insert after 03:2079', old=(
   "The offer-kind consistency check at OPS-43 step 5 uses the same exception: it runs on\n"
   "step 4's current List offers result, after that read and before any provider mutation."),
   new=(
   "The offer-kind consistency check at OPS-43 step 5 uses the same exception: it runs on\n"
   "step 4's current List offers result, after that read and before any provider mutation.\n"
   "`OPS-43` says \"If present but its kind differs from request_summary's machine_kind, settle\n"
   "failed with invalid_request\" and \"before any provider mutation\", and its step 4 says \"obtain\n"
   "the current driver List offers result\"."),
   quotes=[('OPS-43 5', "If present but its kind differs from request_summary's machine_kind, settle failed with invalid_request"),
           ('OPS-43 5', 'before any provider mutation'),
           ('OPS-43 4', 'obtain the current driver List offers result')]),
 'Q2': dict(site='Admission.lean:317-319 docstring', old=(
   "`orderingCapabilityGuard` (`API-7`, 2026-10-22, `pv-p3k`; step 5d reworded 2026-10-30,\n"
   "`pv-e45e`): step 5d gates a create on the ordering capability selected by the named offer's kind\n"
   "in the stored listing, and takes no gate for an offer absent from it. Off, a create without that\n"
   "declaration reaches the purchase tail."),
   new=(
   "`orderingCapabilityGuard` (`API-7`, 2026-10-22, `pv-p3k`; step 5d reworded 2026-10-30,\n"
   "`pv-e45e`): step 5d gates a create on the ordering capability selected by the named offer's kind\n"
   "in the stored listing, and takes no gate for an offer absent from it; `API-7` says \"If the named\n"
   "offer is present, take its kind and gate on DOM-10's matching ordering capability\" and \"If the\n"
   "offer is absent, run no ordering-capability check\". Off, a create without that declaration\n"
   "reaches the purchase tail."),
   quotes=[('API-7 5d', "If the named offer is present, take its kind and gate on DOM-10's matching ordering capability"),
           ('API-7 5d', 'If the offer is absent, run no ordering-capability check')]),
 'Q3': dict(site='Admission.lean:1181-1182 docstring', old=(
   "whether the account declares the ordering capability selected by the named offer's kind in the\n"
   "stored listing; for an offer absent from that listing step 5d takes no gate and the Boolean is\n"
   "supplied `true`. Offer-kind selection and descriptor construction are outside this model."),
   new=(
   "whether the account declares the ordering capability selected by the named offer's kind in the\n"
   "stored listing; for an offer absent from that listing step 5d takes no gate and the Boolean is\n"
   "supplied `true` (`API-7` says \"If the offer is absent, run no ordering-capability check\").\n"
   "Offer-kind selection and descriptor construction are outside this model."),
   quotes=[('API-7 5d', 'If the offer is absent, run no ordering-capability check')]),
 'Q4': dict(site='05-persistence.md:523 operations.request_summary row (one table line)', old=(
   "the **offer snapshot** (`offer_id`, `machine_kind` (`virtual` or `bare_metal`, copied from the\n"
   "named offer at admission under API-7), the offer's `install_strategies` as accepted,"),
   new=(
   "the **offer snapshot** (`offer_id`, `machine_kind` (`virtual` or `bare_metal`, copied from the "
   "named offer at admission under API-7; `API-7` says \"" + ADM + "\"), the offer's "
   "`install_strategies` as accepted,"),
   keepbytes=(
   "the **offer snapshot** (`offer_id`, `machine_kind` (`virtual` or `bare_metal`, copied from the "
   "named offer at admission under API-7), the offer's `install_strategies` as accepted,"),
   quotes=[('API-7 5d', ADM)]),
 'Q5': dict(site='OPS-43 step 3, 03:797-802 replaced', old=(
   "   or `bare_metal`. The `api` writes `machine_kind` at admission; for missing or invalid\n"
   "   fields, see `OPS-23`. Check caller-supplied fields first, then api-written admission\n"
   "   fields, then gate on `DOM-10`'s matching ordering capability selected by that persisted\n"
   "   `machine_kind`, using the descriptor the worker runs with. No current offer read supplies\n"
   "   this gate."),
   new=(
   "   or `bare_metal`. The `api` writes `machine_kind` at admission (`API-7` says \"On admission,\n"
   "   retain the named offer's kind as machine_kind in the create's request_summary offer\n"
   "   snapshot\"); for missing or invalid fields, see `OPS-23`. Check caller-supplied fields\n"
   "   first, then api-written admission fields, then gate on `DOM-10`'s matching ordering\n"
   "   capability selected by that persisted `machine_kind`, using the descriptor the worker runs\n"
   "   with. No current offer read supplies this gate."),
   quotes=[('API-7 5d', ADM)]),
 'Q6': dict(site='OPS-43 step 5, last clause', old=(
   "the same existing\n"
   "   pre-step-9 settlement releases the commitment and any resource-offer exclusion."),
   new=(
   "the same existing\n"
   "   pre-step-9 settlement releases the commitment and any resource-offer exclusion; `OPS-11`\n"
   "   says \"The commitment is released in full under `LDG-32`\" and \"Where the create holds a\n"
   "   resource-offer exclusion, it is freed under `STO-58`\"."),
   quotes=[('OPS-11', 'The commitment is released in full under `LDG-32`'),
           ('OPS-11', 'Where the create holds a resource-offer exclusion, it is freed under `STO-58`')]),
 'Q7': dict(site='CNF-19 appended block, its eleventh line', old=(
   "assert the CNF-55 pre-List-offers refusal using the retained machine_kind."),
   new=(
   "assert the CNF-55 pre-List-offers refusal using the retained machine_kind (`CNF-55` says\n"
   "\"the worker refuses it at `OPS-43`'s step 3\")."),
   quotes=[('CNF-55', "the worker refuses it at `OPS-43`'s step 3")]),
}

meta = {'pin': PIN, 'questions': {}}
qa_all, c_all = QA, C857
for k, q in Q.items():
    sq, sc = span(QA, q['old']), span(C857, q['old'])
    for owner, seg in q['quotes']:
        assert f'"{ws(seg)}"' in ws(q['new']), (k, seg)
        assert len(ws(seg).split()) >= 4, (k, seg)
    srcs = []
    for owner, seg in q['quotes']:
        f, t = SRC[owner]; la, lb = locate(t, seg)
        if owner == 'OPS-11': assert la == 249, la
        if owner == 'API-7 5d': assert 6 <= la <= lb <= 15, (la, lb); assert ws(seg) in ws(new5d)
        if owner == 'OPS-43 5': assert 49 <= la <= lb <= 56, (la, lb); assert ws(seg) in ws(new5)
        srcs.append({'owner': owner, 'file': f, 'lines': f'{la}' + (f'-{lb}' if lb != la else ''), 'segment': seg})
    # The QUOTE form keeps every adopted word in order (it only adds the quotation, or a rewrap/join).
    st = lambda s: [re.sub(r'[^\w`*]', '', w) for w in ws(s).split()]
    ow = [w for w in st(q['old']) if w]; it = iter([w for w in st(q['new']) if w])
    assert all(any(w == x for x in it) for w in ow), k
    (P / f'{k}-OLD.txt').write_text(q['old'] + '\n')
    (P / f'{k}-QUOTE.txt').write_text(q['new'] + '\n')
    if k == 'Q4':
        (P / 'Q4-KEEP.txt').write_text(q['keepbytes'] + '\n')
        (P / 'Q4-ASIS.txt').write_text(
            f'ASIS: no byte changes. The Run writes Q2-A-cited.md:{sq} (comment 857:{sc}) exactly as adopted, '
            'including its line break, into the one-line 05-persistence.md:523 table row.\n')
    else:
        (P / f'{k}-KEEP.txt').write_text(
            f'KEEP: no byte changes. The Q2-A-cited.md:{sq} span (comment 857:{sc}) stays exactly as adopted; '
            f'the Run writes it as Q2-A-cited.md has it, at pin {PIN}.\n')
    qa_all = qa_all.replace(q['old'], q['new'], 1); c_all = c_all.replace(q['old'], q['new'], 1)
    meta['questions'][k] = {'site': q['site'], 'Q2-A-cited.md': sq, 'comment857': sc, 'sources': srcs}

assert ws(Q['Q4']['keepbytes']) == ws(Q['Q4']['old'])
(C / 'prospective-Q2-A-cited-allquote.md').write_text(qa_all)

# F-QUOTE under Q5-QUOTE: the r98 re-slice rule applied to the new step 3.
new3 = B[4]; assert new3.count(Q['Q5']['old']) == 1
new3q = new3.replace(Q['Q5']['old'], Q['Q5']['new'])
n3, n3q = new3[len('3. '):-1], new3q[len('3. '):-1]
assert FQ.count('`OPS-43` says “' + n3 + '”') == 1
(C / 'F-QUOTE-Q5.txt').write_text(FQ.replace('`OPS-43` says “' + n3 + '”', '`OPS-43` says “' + n3q + '”'))
(C / 'F-QUOTE.txt').write_text(FQ)

NOTE = ('## Wording correction — 2026-11-03 (Panel r100)\n\n'
        'The text above is retained as the historical form approved in owner item 17; its original\n'
        'bytes remain unchanged. Under the owner\'s 2026-10-28 wording rule (“For such wording\n'
        'questions, try to solve by getting a consensus of the panel”), the pv-e45e Run writes the\n'
        'exact replacements selected in the panel record below in place of the spans they replace.\n'
        'Comment 857 is not edited. This note grants no independent authority to change a\n'
        'requirement; any substantive unresolved conflict returns to the owner.\n\n'
        f'Source pin: `{PIN}`.\n'
        'Panel record: `../../r100/notes.md`.\n')
assert QA.endswith('```\n\n')
(P / 'R-NOTE-append.md').write_text(NOTE)
(C / 'prospective-Q2-A-cited-with-note.md').write_text(QA + NOTE)

RR = {
 'R-RUN': ('No preparation commit; comment 857 and docs/research/panels-2026-10/r86/r86b/Q2-A-cited.md '
           'are not edited. The pv-e45e Run instruction quotes verbatim /var/tmp/provisiond-panel-r98/'
           'brief.md:201–203, the PRV-10 form (r100 check/F-QUOTE.txt, or check/F-QUOTE-Q5.txt if Q5 '
           'settles on Q5-QUOTE), and each settled r100 form whose bytes differ from the adopted text, '
           'each with the Q2-A-cited.md span it replaces; the Run writes those forms in place of those '
           'spans and archives the reviewed r100 record at docs/research/panels-2026-10/r100/. No branch '
           'or tracker edit occurs in this panel turn.'),
 'R-NOTE': ('Exactly as R-RUN, and in addition the Run appends exactly R-NOTE-append.md to '
            'docs/research/panels-2026-10/r86/r86b/Q2-A-cited.md, all original bytes remaining an exact '
            'prefix. Comment 857 is not edited. No branch or tracker edit occurs in this panel turn.'),
}
for k, v in RR.items():
    (P / f'{k}.txt').write_text(v + '\n')

files = sorted([f'{k}-{t}.txt' for k in Q for t in ('OLD', 'QUOTE', 'KEEP')] + ['Q4-ASIS.txt'] +
               [f'{k}.txt' for k in RR] + ['R-NOTE-append.md', 'evidence/pv-e45e-comment-857.md',
               'evidence/Q2-A-cited.md', 'check/F-QUOTE.txt', 'check/F-QUOTE-Q5.txt',
               'check/prospective-Q2-A-cited-allquote.md', 'check/prospective-Q2-A-cited-with-note.md'])
with (P / 'forms.sha256').open('w') as fh:
    for f in files:
        fh.write(f'{hashlib.sha256((P / f).read_bytes()).hexdigest()}  {f}\n')
(C / 'build.json').write_text(json.dumps(meta, indent=2, ensure_ascii=False) + '\n')
print(json.dumps(meta, indent=1, ensure_ascii=False))
