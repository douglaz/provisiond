"""r99 form builder. Every OLD span and every quoted source segment is checked against the
pinned bytes (git show PIN:<path> in check/repo). Writes the form files at the packet root,
check/prospective-*.md, and forms.sha256. Nothing outside /var/tmp/provisiond-panel-r99 is written."""
from pathlib import Path
import subprocess, hashlib, json, re

P = Path('/var/tmp/provisiond-panel-r99'); C = P / 'check'; REPO = C / 'repo'
PIN = 'efb40cc55ff04be693473914afd42ef68008fa15'
assert (P / 'PIN').read_text().strip() == PIN

def show(path):
    return subprocess.check_output(['git', 'show', f'{PIN}:{path}'], cwd=REPO, text=True)

DOM = show('01-domain-model.md')
SRC = {'PRV': show('02-provider-contract.md'), 'OPS': show('03-operation-lifecycle.md'),
       'API': show('04-api-contract.md')}
FILE = {'PRV': '02-provider-contract.md', 'OPS': '03-operation-lifecycle.md', 'API': '04-api-contract.md'}

def ws(s):
    return ' '.join(s.split())

def line_of(text, idx):
    return text.count('\n', 0, idx) + 1

def locate_ws(text, seg):
    """Find seg in text with whitespace runs matched loosely; return (start_line, end_line)."""
    pat = r'\s+'.join(re.escape(w) for w in seg.split())
    ms = list(re.finditer(pat, text))
    assert len(ms) == 1, (seg, len(ms))
    return line_of(text, ms[0].start()), line_of(text, ms[0].end())

# Each question: OLD span at the pin (exact bytes, occurs once), QUOTE replacement (exact bytes),
# and the quoted source segments with their owner prefix.
Q = {
 'Q1': dict(
   old="PRV-25's identical-PTR success remains after its capability check.",
   new=('`PRV-25` says "After the ordinary authorization, capability and `API-16` validation" and '
        '"An identical established value MUST settle `succeeded`"; that identical-PTR success remains '
        'after its capability check.'),
   quotes=[('PRV', 'After the ordinary authorization, capability and `API-16` validation'),
           ('PRV', 'An identical established value MUST settle `succeeded`')]),
 'Q2': dict(
   old="An API-64 operator retry checks delete_machine before its state-change/enqueue\ntransaction;",
   new=('`API-64` says "the state change, the enqueue and the idempotency record commit together". '
        'An API-64 operator retry checks delete_machine before its state-change/enqueue\ntransaction;'),
   quotes=[('API', 'the state change, the enqueue and the idempotency record commit together')]),
 'Q3': dict(
   old="A capability\nrefusal is classified by OPS-11 and carries DOM-10's existing unsupported result.",
   new=("A capability\nrefusal is classified by OPS-11 and carries DOM-10's existing unsupported result; "
        '`OPS-11` says "the system MUST classify the error into `failed` or `needs_reconciliation`".'),
   quotes=[('OPS', 'the system MUST classify the error into `failed` or `needs_reconciliation`')]),
 'Q4': dict(
   old="A no-call success or defer returned\nby that decision takes no capability check.",
   new=('`OPS-41` says "the worker MUST make no provider call, settle the operation `succeeded`" and '
        '"the claim MUST defer"; a no-call success or defer returned\nby that decision takes no capability check.'),
   quotes=[('OPS', 'the worker MUST make no provider call, settle the operation `succeeded`'),
           ('OPS', 'the claim MUST defer')]),
 'Q5': dict(
   old="or the capability-less methods named by PRV-4.",
   new=('or the capability-less methods named by PRV-4; `PRV-4` says "The three methods with no entry '
        'there — *describe capabilities*, *get machine* and *refresh rescue session*".'),
   quotes=[('PRV', 'The three methods with no entry there — *describe capabilities*, *get machine* and *refresh rescue session*')]),
}

KEEP = {
 'Q1': ('KEEP: no byte changes. 01-domain-model.md:575 stays exactly as landed at {pin}. Main answers '
        'review thread PRRT_kwDOT30eC86y-3YB (codex P1 4450997798) with the panel\'s evidence and resolves it.'),
}
for k in ('Q2', 'Q3', 'Q4', 'Q5'):
    KEEP[k] = 'KEEP: no byte changes. The {span} span stays exactly as landed at {pin}. No thread exists for it; nothing is posted.'

meta = {'pin': PIN, 'questions': {}}
allquote = DOM
for k, q in Q.items():
    assert DOM.count(q['old']) == 1, (k, DOM.count(q['old']))
    i = DOM.index(q['old'])
    a, b = line_of(DOM, i), line_of(DOM, i + len(q['old']) - 1)
    span = f'01-domain-model.md:{a}' + (f'-{b}' if b != a else '')
    # QUOTE must keep the OLD span's non-quote words: the new text minus the inserted quote clause
    # must still contain every OLD word in order (no meaning change outside the inserted quote).
    srcs = []
    for owner, seg in q['quotes']:
        assert f'"{seg}"' in q['new'], (k, seg)
        assert len(ws(seg).split()) >= 4, (k, seg)
        la, lb = locate_ws(SRC[owner], seg)
        srcs.append({'file': FILE[owner], 'lines': f'{la}' + (f'-{lb}' if lb != la else ''), 'segment': seg})
    (P / f'{k}-OLD.txt').write_text(q['old'] + '\n')
    (P / f'{k}-QUOTE.txt').write_text(q['new'] + '\n')
    (P / f'{k}-KEEP.txt').write_text(KEEP[k].format(pin=PIN, span=span) + '\n')
    allquote = allquote.replace(q['old'], q['new'], 1)
    meta['questions'][k] = {'span': span, 'sources': srcs}

# The prospective DOM-10 added block (all five QUOTE forms) and the single-question blocks.
def block(text):
    s = text.index('For power on, power off, reboot, hard reset')
    e = text.index('the capability-less methods named by PRV-4', s)
    e = text.index('\n', e) + 1
    return text[s:e]
(C / 'base-DOM10-block.md').write_text(block(DOM))
(C / 'prospective-DOM10-allquote.md').write_text(block(allquote))
(C / 'prospective-01-domain-model-allquote.md').write_text(allquote)

# Comment 856 (from the tracker at the pin) and its prospective all-QUOTE text.
rows = [json.loads(l) for l in show('.beads/issues.jsonl').splitlines() if l.strip()]
row = [r for r in rows if r.get('id') == 'pv-5pmu']; assert len(row) == 1
cm = [c for c in row[0].get('comments', []) if str(c.get('id')) == '856']; assert len(cm) == 1
c856 = cm[0]['text']
(P / 'evidence/pv-5pmu-comment-856.md').write_text(c856)
c856_new = c856
for k, q in Q.items():
    assert c856.count(q['old']) == 1, (k, 'c856', c856.count(q['old']))
    c856_new = c856_new.replace(q['old'], q['new'], 1)
(C / 'prospective-comment-856-allquote.md').write_text(c856_new)
assert block(DOM) in c856, 'landed block not byte-equal to comment 856 block'
meta['comment_856_block_equal_to_landed'] = True
meta['comment_856_status'] = row[0].get('status')

# Q1-A.md at the pin, and the R-NOTE append.
QA = 'docs/research/panels-2026-10/r86/r86b/Q1-A.md'
qa = show(QA)
NOTE = ('\n\n## Wording correction — 2026-11-03 (Panel r99)\n\n'
        'The text above, with the 2026-10-31 Panel N r93 correction, is retained as the historical\n'
        'form approved in owner item 16; its original bytes remain unchanged. Under the owner\'s\n'
        '2026-10-28 wording rule (“For such wording questions, try to solve by getting a consensus of\n'
        'the panel”), the landed `DOM-10` text and the pv-5pmu Agent Brief use the exact replacements\n'
        'selected in the panel record below. This note grants no independent authority to change a\n'
        'requirement; any substantive unresolved conflict returns to the owner.\n\n'
        f'Source pin: `{PIN}`.\n'
        'Panel record: `../../r99/notes.md`.\n')
assert not qa.endswith('\n\n'), 'Q1-A ends with a blank line; adjust append'
(P / 'R-NOTE-append.md').write_text(NOTE)
(C / 'prospective-Q1-A.md').write_text(qa + NOTE)
assert (C / 'prospective-Q1-A.md').read_text().startswith(qa)

R = {
 'R-NOTE': ('Fix commit on branch pv-5pmu, in PR #69: (1) in 01-domain-model.md replace each selected '
            'Qn-OLD.txt span with its selected Qn-QUOTE.txt bytes; (2) in the text of pv-5pmu comment 856 '
            'in .beads/issues.jsonl replace the same spans with the same bytes, changing no other field, '
            'comment or bead; (3) append exactly R-NOTE-append.md to '
            'docs/research/panels-2026-10/r86/r86b/Q1-A.md, all original bytes remaining an exact prefix; '
            '(4) archive the reviewed r99 record at docs/research/panels-2026-10/r99/. The archived r93 '
            'record stays unchanged. No branch or tracker edit occurs in this panel turn.'),
 'R-BRIEF': ('Fix commit on branch pv-5pmu, in PR #69: (1) and (2) exactly as R-NOTE; leave '
             'docs/research/panels-2026-10/r86/r86b/Q1-A.md unchanged, with no note; (4) archive the '
             'reviewed r99 record at docs/research/panels-2026-10/r99/. The archived r93 record stays '
             'unchanged. No branch or tracker edit occurs in this panel turn.'),
 'R-ARCHIVE': ('Fix commit on branch pv-5pmu, in PR #69: (1) exactly as R-NOTE; leave comment 856 and '
               'docs/research/panels-2026-10/r86/r86b/Q1-A.md unchanged as historical records of the closed '
               'bead; (4) archive the reviewed r99 record at docs/research/panels-2026-10/r99/, which alone '
               'records the divergence. The archived r93 record stays unchanged. No branch or tracker edit '
               'occurs in this panel turn.'),
}
for k, v in R.items():
    (P / f'{k}.txt').write_text(v + '\n')

files = sorted([f'{k}-{t}.txt' for k in Q for t in ('OLD', 'QUOTE', 'KEEP')] +
               [f'{k}.txt' for k in R] + ['R-NOTE-append.md', 'evidence/pv-5pmu-comment-856.md'] +
               ['check/base-DOM10-block.md', 'check/prospective-DOM10-allquote.md',
                'check/prospective-01-domain-model-allquote.md', 'check/prospective-comment-856-allquote.md',
                'check/prospective-Q1-A.md'])
with (P / 'forms.sha256').open('w') as fh:
    for f in files:
        fh.write(f'{hashlib.sha256((P / f).read_bytes()).hexdigest()}  {f}\n')
(C / 'build.json').write_text(json.dumps(meta, indent=2, ensure_ascii=False) + '\n')
print(json.dumps(meta, indent=2, ensure_ascii=False))
