#!/usr/bin/env python3
"""Build the r99b consensus packet from r99's frozen bytes and the pinned sources. Nothing is retyped:
r99 brief sections are sliced by line, OPS-41 source lines come from `git show PIN:...` in r99's
check/repo, forms are file bytes, and r99's answers are copied verbatim except for the marked
seat-name redactions listed in REDACT. The seat-to-letter map goes only to check/labels.json."""
import hashlib, json, pathlib, re, subprocess

R = pathlib.Path('/var/tmp/provisiond-panel-r99')
B = R / 'r99b'
PIN = (R / 'PIN').read_text().strip()
assert PIN == 'efb40cc55ff04be693473914afd42ef68008fa15'

def sha(b): return hashlib.sha256(b if isinstance(b, bytes) else b.encode()).hexdigest()

brief = (R / 'brief.md').read_text()
assert sha(brief) == '424f9626b5080078c4a68aaa801b7d69a13739cac3c0b2a0576ecfa23c74d98f'
notes = (R / 'notes.md').read_text()
assert sha(notes) == '14c98e411963fb6d60f4bb0d96fd6a9d70508b2abf353041c2ac6385a4b2b736'
L = brief.split('\n')

def sl(a, b):  # 1-based inclusive line slice of r99's brief
    return '\n'.join(L[a - 1:b])

assert L[263] == '## Q2 — the API-64 transaction' and L[306].startswith('QUOTE inserts one sentence') and L[308].startswith('## Q3')
assert L[351] == "## Q4 — OPS-41's no-call success or defer" and L[406] == '' and L[407].startswith("QUOTE carries OPS-41's words for each outcome")
assert L[447] == '## Q-REC — how the record follows' and L[494].endswith('changes only its own spans.') and L[496].startswith('## 7.')
q2_sec, q4_sec, q4_note, qrec_sec = sl(264, 307), sl(352, 406), L[407], sl(448, 495)

def show(path):
    return subprocess.check_output(['git', 'show', f'{PIN}:{path}'], cwd=R / 'check/repo', text=True)

OPS = show('03-operation-lifecycle.md').split('\n')
def ops(a, b, starts):
    assert OPS[a - 1].startswith(starts), (a, OPS[a - 1])
    return '\n'.join(OPS[a - 1:b])
o_head = ops(1099, 1102, '**The worker decides in this order, inside the fence transaction')
o_s1 = ops(1104, 1107, '1. **The machine is recorded gone, or its episode is closed.** The worker makes no provider call')
o_s2 = ops(1113, 1113, '   Step 1 and the restore claim gate above remain ahead of this decision.')
o_s3 = ops(1117, 1126, '3. **A rate exists for the machine')
assert 'the worker MUST return the attempt to `queued`' in OPS[1121]
o_s4 = ops(1132, 1134, '4. **There is no rate, and the outage')
assert 'The claim defers' in OPS[1132]
o_tail = ops(1153, 1156, '**The short deferrals in steps 3 and 4 are not settlements.**')

Q1A = show('docs/research/panels-2026-10/r86/r86b/Q1-A.md').split('\n')
assert Q1A[62] == 'The text above is retained as the historical form approved in owner item 16.'
q1a_note = '\n'.join(Q1A[60:65])

F = {n: (R / n).read_bytes() for n in ('Q1-QUOTE.txt', 'Q2-QUOTE.txt', 'Q2-KEEP.txt', 'Q4-QUOTE.txt', 'Q4-KEEP.txt', 'Q4-OLD.txt',
                                      'R-NOTE.txt', 'R-NOTE-append.md', 'R-BRIEF.txt', 'R-ARCHIVE.txt')}
EXP = {'Q1-QUOTE.txt': '4c0cbffbf91643afc682f63211c82ae400928e101dd9b4d48aa8e11a49d5419e',
       'Q2-QUOTE.txt': '2b46b8b8d673696e3a4668f96be33fe3e2da919431613e22188cb35793b4adc6',
       'Q2-KEEP.txt': 'e3d78fbf0b44b7cd667f0a418c3b5b15b03c4cf067aa5ab9d033a1d8ed4f82f8',
       'Q4-QUOTE.txt': '06392de56a1eb54ff3e45e435f0c81f86d3053f5a92d1cb04328276dbeaee10d',
       'Q4-KEEP.txt': '230d598ccbb5634c9846500e948d8c0cbd737728308f421c035e3789e744f4c3',
       'Q4-OLD.txt': '8f673c0a119baeb0677a6ecff4cc4947e29f8c11d5af415835953682d7ad89b7',
       'R-NOTE.txt': '6e6a167b06d2df2d3a1d45dd0a0ee8d2c2ff005a8e5bbd3ffa3a6e446e3b413b',
       'R-NOTE-append.md': '02dcd93d7347976e0934b235e3c428a26796a287bfff91d2a37ab003ca58d298',
       'R-BRIEF.txt': '33e383dd7d1bddc691fa89d8685a4f3f539084106db10914752201c8fd13ad40',
       'R-ARCHIVE.txt': '15d0281707c66b533cf46a38e4b71a4ca5d4ba9bac28dd9b54c98335290df635'}
for n, h in EXP.items():
    assert sha(F[n]) == h, n
alt = (B / 'forms/Q4-ALT.txt').read_bytes()
assert sha(alt) == 'c12991b321e6e9abc74e67dfebba3f16554ee8048ff09a0ca0895933614fa318'
rnalt = (B / 'forms/R-NOTE-ALT.txt').read_bytes()
rnalt_app = (B / 'forms/R-NOTE-ALT-append.md').read_bytes()
assert sha(rnalt_app) == '445f69c220bfcdefd455fb6447c2c5e93b76d16274a9c051e21b0423358b02ea'
assert rnalt_app.startswith(b'\n\n') and rnalt_app.endswith(b'`.\n') and not rnalt_app.endswith(b'\n\n')
assert alt.endswith(b'check.\n') and rnalt.endswith(b'panel turn.\n')

ans = {s: (R / f'{s}.md').read_text() for s in ('fable', 'opus', 'astra', 'sol')}
assert ans['fable'].startswith("You've reached your Fable limit.")
assert alt.decode().rstrip('\n') in ans['opus'], 'Q4-ALT must equal the bytes printed in the answer'
assert rnalt.decode().rstrip('\n') in ans['opus'], 'R-NOTE-ALT must equal the bytes printed in the answer'
assert rnalt_app.decode().rstrip('\n').lstrip('\n') in ans['opus']

LABEL = {'astra': 'A', 'sol': 'B', 'opus': 'C'}
REDACT = {
    'opus': [('# Seat opus: r99 answer', '# Seat [seat]: r99 answer'),
             ('`tmp/opus/Q4-ALT.txt`', '`[scratch]/Q4-ALT.txt`'),
             ('`tmp/opus/Q-REC-ALT-append.md`', '`[scratch]/Q-REC-ALT-append.md`'),
             ('scratch stayed in `tmp/opus`.', 'scratch stayed in `[scratch]`.')],
    'astra': [('Seat astra reviewed PR #69', 'Seat [seat] reviewed PR #69')],
    'sol': [('Seat sol reviewed PR #69', 'Seat [seat] reviewed PR #69')],
}
red = {}
for s, reps in REDACT.items():
    t = ans[s]
    for a, b in reps:
        assert t.count(a) == 1, (s, a)
        t = t.replace(a, b)
    assert not re.search(r'\b(opus|astra|sol|fable|grok)\b', t, re.I), (s, re.search(r'\b(opus|astra|sol|fable|grok)\b', t, re.I))
    red[s] = t

def q(s, text):  # a quotation that must occur verbatim in seat s's r99 answer
    assert text in ans[s], (s, text)
    return text

RULE6 = '**apply notes.md rule 6 exactly as written; this prompt adds no void rule.**'
SETTLE = ('"a question is settled when at least three agree and more agree than\n'
          'disagree, and a tie comes to you. If grok is down, it falls back to three of four"')

def blk(b, lang='text'):
    t = b.decode() if isinstance(b, bytes) else b
    return f'`````{lang}\n{t.rstrip(chr(10))}\n`````'

assert 'The text above, with the 2026-10-31 Panel N r93 correction, is retained as the historical form approved in owner item 16' in ' '.join(F['R-NOTE-append.md'].decode().split())
assert 'The form approved in owner item 16 and the 2026-10-31 Panel N r93 correction above are retained with their bytes unchanged.' in ' '.join(rnalt_app.decode().split())
assert 'its selected Qn-QUOTE.txt bytes' in F['R-NOTE.txt'].decode() and 'settled QUOTE or ALT bytes' in rnalt.decode()
assert 'exactly as R-NOTE' in F['R-BRIEF.txt'].decode() and 'exactly as R-NOTE' in F['R-ARCHIVE.txt'].decode()
tj = json.loads((B / 'check/trial-alt.json').read_text())
assert tj['trials']['A-Q4ALT']['exit'] == 0 and tj['trials']['A-ALL']['exit'] == 0
assert tj['trials']['N-Q4ALT']['exit'] == 1 and tj['trials']['N-Q4ALT']['expected_owner_named']

out = []
w = out.append
w(f'''# Panel r99b — the one consensus round on Q2, Q4 and Q-REC

Pin: `{PIN}` (unchanged from r99: PR #69 head, branch `pv-5pmu`). Your clone is detached at it.
Read sources with `git show {PIN}:<path>` in your clone and check the bytes yourself. Every block
below is sliced from r99's frozen brief, from the pinned sources or from form files by the
manager's build script (fenced, because it holds the seat map); none was retyped. Relative paths inside r99's sections (`Qn-*.txt`,
`R-*.txt`, `R-NOTE-append.md`, `check/`, `evidence/`, `forms.sha256`) resolve from r99's folder
`/var/tmp/provisiond-panel-r99`; r99b's new form files are in `/var/tmp/provisiond-panel-r99/r99b/forms/`.
Read r99b's `notes.md` first.

{RULE6}

Owner's settling rule, verbatim: {SETTLE}

## 1. Where r99 left things

Fable answered with a usage-limit line and Grok returned HTTP 402 (re-probed for this round: still
402), so both are missing seats. Three readers answered in full; their answers are in §5 as
Reader A, Reader B and Reader C, without names. Three present seats means a question settles only
when all three make the same exact final pick (3–0).

- **Settled 3–0 and not reopened here:** Q1 on Q1-QUOTE (`Q1-QUOTE.txt`, sha256
  `{sha(F['Q1-QUOTE.txt'])}`); Q3 on Q3-KEEP and Q5 on Q5-KEEP (no bytes change). No reader opened a Q6.
- **Q-REC applies**, because Q1 settled on a non-KEEP form.
- **Split 2–1, asked again here:** Q2, Q4 and Q-REC. This is their one consensus round (notes rule 4);
  there is no r99c. A question that does not settle here goes to the owner.

| Question | Reader A | Reader B | Reader C | Printed forms every reader ACCEPTED in r99 |
|---|---|---|---|---|
| Q2 | Q2-KEEP | Q2-KEEP | Q2-QUOTE | Q2-QUOTE and Q2-KEEP |
| Q4 | Q4-KEEP | Q4-KEEP | Q4-ALT (new; C cannot accept KEEP) | Q4-QUOTE (Q4-ALT was read by C only) |
| Q-REC | R-NOTE | R-NOTE | R-NOTE-ALT (new; C cannot accept R-BRIEF or R-ARCHIVE) | R-NOTE (R-NOTE-ALT was read by C only) |

Acceptance does not choose a form (notes rule 2): only the same exact final pick from all three settles.

## 2. The exact disagreements

### Q2 (`01-domain-model.md:547-548`): add API-64's words before the clause, or keep it

- Reader C (QUOTE): "{q('opus', 'the rule depends on one fact about `API-64`, that the state change and the enqueue form a single transaction.')}"
  and "{q('opus', 'It states that fact in a coined term: "state-change/enqueue" appears in no root requirement except `01-domain-model.md:547`.')}"
  It also says: "{q('opus', 'the main predicate is `DOM-10`\'s own, so I accept KEEP.')}"
- Reader A (KEEP): "{q('astra', 'the operative assertion is DOM-10’s own placement rule: “checks delete_machine before its state-change/enqueue transaction.” “API-64 operator retry” identifies the operation, and “state-change/enqueue transaction” identifies the boundary.')}"
- Reader B (KEEP): "{q('sol', '“Its state-change/enqueue transaction” identifies the transaction before which that new check runs. It does not independently specify the transaction’s atomicity or idempotency semantics.')}"

### Q4 (`01-domain-model.md:565-566`): quote OPS-41's outcomes, and if so which words

- Reader C (Q4-ALT): "{q('opus', '"returned by that decision" has the same shape as r93\'s "returned by API-7 step 5a", so I cannot accept KEEP.')}"
  On Q4-QUOTE: "{q('opus', 'Its defect is incomplete evidence.')}" Reader C also reported the brief error in §3 below and
  judged it premise-changing.
- Reader A (KEEP): "{q('astra', 'The operative rule is DOM-10’s “takes no capability check” (`01-domain-model.md:565`). It applies to outcomes obtained from the preceding gates; it does not prescribe their predicates.')}"
- Reader B (KEEP): "{q('sol', '“A no-call success or defer returned by that decision” identifies the applicable outcomes conditionally; the sentence does not restate their triggering conditions.')}"

### Q-REC: how the record follows

- Reader C (R-NOTE-ALT): "{q('opus', 'R-NOTE is acceptable and follows the right precedent, but it has three record defects:')}"
  (its three defects are in §5; they are checked in the Q-REC disclosures below).
- Reader A (R-NOTE): "{q('astra', 'I prefer R-NOTE because it synchronizes the executable block and leaves a dated explanation at the historical form’s existing location.')}"
- Reader B (R-NOTE): "{q('sol', 'R-NOTE preserves the original archive bytes, keeps the executable brief synchronized, and adds a direct route from the historical form to the later correction.')}"

## 3. Every exact option, in full

Each of the three sections below is sliced from r99's `brief.md` (lines 264-307, 352-406 and
448-495) and is followed by what r99b adds: the new forms a reader printed, and corrections.

{q2_sec}

{q4_sec}

### Q4: r99's note, withdrawn, and the corrected sources

r99's `brief.md:408` said, verbatim:

{blk(q4_note)}

Its first sentence's "words for each outcome" and its "Note that the defer comes from OPS-41's
restore claim gate, not its fence-transaction decision" are **wrong** (reported by Readers A and C;
verified by the manager). Reader B cited the decision's own deferrals (`:1133`, `:1153`) and read the
note as naming only the selected quotation's source. OPS-41's ordered fence-transaction decision has its
own no-call success and its own short deferrals, which r99 did not print. Also, "keeps the landed
sentence's bytes after them" is not literal: Q4-QUOTE and Q4-ALT both change the landed initial "A"
(`Q4-OLD.txt` begins `A no-call`) to "a". The landed span, Q4-KEEP and every form's bytes are
unchanged by this correction.

`03-operation-lifecycle.md:1099-1102` at the pin (the decision's lead):

{blk(o_head)}

`:1104-1107` (step 1, a no-call success):

{blk(o_s1)}

`:1113` (in step 2):

{blk(o_s2)}

`:1117-1126` (step 3, including its no-mutation abort and its short deferral):

{blk(o_s3)}

`:1132-1134` (step 4, a short deferral):

{blk(o_s4)}

`:1153-1156`:

{blk(o_tail)}

Where each quotation sits: Q4-QUOTE quotes `:1003-1004` (the no-mutation abort, which step 3 at
`:1118` invokes as "the no-mutation abort and settlement above") and `:1025` (the restore claim gate,
which `:1113` places ahead of the decision). Q4-ALT adds `:1153`. Neither quotes step 1's own words
(`:1104-1105`) or step 4's "The claim defers" (`:1133`); Reader C discloses the step 1 omission.

**Rule 6 handling (manager's reading, not a vote):** Reader C judged the error premise-changing.
Reader A judged it not, and said its vote relies on the forms' broad scope, not on the note. Reader B
read the note narrowly, as above, and said neither form should narrow the no-check rule to the
restore-claim branch. The manager did not
void Q4's r99 tally: the error is about how complete QUOTE's evidence is and changes no form's
bytes. This round prints the corrected sources. If main judges the error premise-changing, this
round's Q4 counts as the corrected re-ask instead.

**Q4-ALT** (Reader C's, new in r99; `r99b/forms/Q4-ALT.txt`, SHA-256 `{sha(alt)}`, pin `{PIN}`), the
exact bytes replacing the `Q4-OLD.txt` span:

{blk(alt)}

Citation trial (r99b `check/trial-alt.py`, same method and read-only lake index as r99's §7, results
`r99b/check/trial-alt.json`): Q1-QUOTE + Q4-ALT, exit 0 (365 compared, unquoted attributions 22,
none new); Q1-QUOTE + Q2-QUOTE + Q4-ALT + R-NOTE-ALT's append, exit 0 (366 compared, none new); the
same with "The short deferrals" corrupted to "The short WRONGWORD", exit 1 naming `OPS-41`. Q4-ALT's
quotations are in the gate's reach.

{qrec_sec}

### Q-REC: what r99b adds

Settled so far: Q1-QUOTE, Q3-KEEP and Q5-KEEP. So the all-QUOTE prospective files that r99 points to
above are **not** the result: Q3 and Q5 change nothing. The changed spans will be Q1 plus whichever
of Q2 and Q4 settle on a non-KEEP form (or come back so from the owner).

**R-NOTE-ALT** (Reader C's, new in r99; `r99b/forms/R-NOTE-ALT.txt`, SHA-256 `{sha(rnalt)}`, pin `{PIN}`):

{blk(rnalt)}

Its appended block (`r99b/forms/R-NOTE-ALT-append.md`, SHA-256 `{sha(rnalt_app)}`; it begins with two
newlines):

{blk(rnalt_app, 'markdown')}

Disclosures (checked by the manager at the pin; not changes to any option):

1. **ALT bytes.** R-NOTE's step (1) replaces spans with "its selected Qn-QUOTE.txt bytes", and R-BRIEF
   and R-ARCHIVE take step (1) from R-NOTE. If Q4 settles on Q4-ALT, those three name no bytes for
   it. R-NOTE-ALT's step (1) says "settled QUOTE or ALT bytes".
2. **The note's label.** R-NOTE's append says (its line breaks joined) "The text above, with the 2026-10-31 Panel N r93
   correction, is retained as the historical form approved in owner item 16". At the pin
   `docs/research/panels-2026-10/r86/r86b/Q1-A.md:61-65` reads:

{blk(q1a_note)}

   so the pinned note gives the item-16 label to the text above it before r93's replacements.
   R-NOTE-ALT's append says instead "The form approved in owner item 16 and the 2026-10-31 Panel N
   r93 correction above are retained with their bytes unchanged."
3. **Comment 856, line 6.** R-NOTE, R-BRIEF and R-ARCHIVE leave it ending "with the 2026-10-31 Panel
   N r93 wording correction." (§5 of r99's brief prints the line). R-NOTE-ALT rewrites that ending
   to name r99 too. r93's package also rewrote line 6 (`/var/tmp/provisiond-panel-r93/settled-pv-5pmu.md:11`
   and its "Agent Brief authority-line replacement" section from `:48`).
4. **Owner item 25** (`/var/tmp/provisiond-manager/owner-decisions-1030.md:204-210`) asked for pv-9ecf
   "Add a dated archive note, or change the brief only?" and chose "Add dated archive note
   (Recommended)"; "Change the brief only" was rejected.
5. **Citation trial:** R-NOTE-ALT's append with Q1-QUOTE, Q2-QUOTE and Q4-ALT gives exit 0 (above).
   r99's T2 covered R-NOTE's append.

## 4. What to return

For each of Q2, Q4 and Q-REC:

1. A final pick: one printed label (Q2-QUOTE, Q2-KEEP; Q4-QUOTE, Q4-KEEP, Q4-ALT; R-NOTE, R-BRIEF,
   R-ARCHIVE, R-NOTE-ALT) or a new complete exact ALT printed in full. Say whether it changes your
   r99 pick, and why.
2. ACCEPT or CANNOT ACCEPT for every printed option, including Q4-ALT and R-NOTE-ALT, with a reason for
   each CANNOT ACCEPT. Keep your preference separate from what you can accept.
3. Any verified blocking loss under notes rule 3 in the picked form, or none.
4. Answer the other side's strongest argument (§2) directly.
5. Any brief error you find in this packet, with file:line, and whether it changes a premise.

Do not reopen Q1, Q3 or Q5, and open no Q6. Read only: no edits to your clone or anything else, no Git
mutation, no subagents, no Nix, no lake, no br. Write scratch only under your tmp folder. Your final
message is your answer.

## 5. r99's answers, verbatim

Each answer is copied byte for byte except where a seat name or a seat's scratch path appeared; those
are replaced by the visible marks `[seat]` and `[scratch]`. Nothing else is changed.

### Fable (missing seat: limit line)

{blk(ans['fable'])}

### Grok (missing seat)

The r99 preflight and this round's refreshed preflight both returned: "API error (status 402 Payment
Required): Grok Build usage balance exhausted".
''')
for s in ('astra', 'sol', 'opus'):
    w(f'''
### Reader {LABEL[s]}

``````markdown
{red[s].rstrip(chr(10))}
``````
''')
brief_b = ''.join(out)
for s in ('astra', 'sol', 'opus'):
    assert red[s].rstrip('\n') in brief_b
for blob in (alt, rnalt, rnalt_app):
    assert blob.decode().strip('\n') in brief_b
assert not re.search(r'\b(opus|astra|sol)\b', brief_b, re.I), re.search(r'\b(opus|astra|sol)\b', brief_b, re.I)
(B / 'brief.md').write_text(brief_b)

reps = [
    ('# Panel r99 — notes (read first)', '# Panel r99b — notes (read first)'),
    ('Six questions are open. Q1–Q5 each ask about one added `DOM-10` sentence in PR #69 (branch\n'
     '`pv-5pmu`): pick QUOTE, KEEP, or a complete exact ALT. Q-REC asks how the record follows if any\n'
     'Q1–Q5 settles on a non-KEEP form: pick R-NOTE, R-BRIEF, R-ARCHIVE or a complete exact ALT. Answer\n'
     'each question independently.',
     'This is r99\'s one consensus round. Three questions are open: Q2 (Q2-QUOTE, Q2-KEEP or a complete\n'
     'exact ALT), Q4 (Q4-QUOTE, Q4-KEEP, the printed Q4-ALT or a complete exact ALT) and Q-REC (R-NOTE,\n'
     'R-BRIEF, R-ARCHIVE, the printed R-NOTE-ALT or a complete exact ALT). Q1 is settled 3–0 on Q1-QUOTE,\n'
     'and Q3 and Q5 3–0 on KEEP; they are not reopened, and no Q6 is open. Answer each question\n'
     'independently.'),
    ('This launch\n   does not launch that round.', 'This round, r99b, is\n   that one round; there is no r99c.'),
    ('- Do not post to, resolve or hide anything on PR #69 or any GitHub thread.',
     '- Do not post to, resolve or hide anything on PR #69 or any GitHub thread.\n'
     '- r99\'s answers reach you only through r99b\'s `brief.md` §5, without names. Do not read any reader\n'
     '  output or record in `/var/tmp/provisiond-panel-r99` or its `r99b` folder: the `*.md` answers other\n'
     '  than `brief.md` and `notes.md`, every `*.out`, `*.err` and `*.exit`, `tally.md`, `STATE.md`,\n'
     '  `packet-manifest.json`, `prompts/`, `check/*-systemctl-show.txt`, `r99b/check/labels.json`,\n'
     '  `r99b/check/build.py`, `r99b/check/build.out`, `r99b/check/build.err`, and\n'
     '  every other seat\'s `tmp/` folder. In `/var/tmp/provisiond-manager/` read only\n'
     '  `owner-decisions-1030.md`.'),
]
for a, b in reps:
    assert notes.count(a) == 1, a
    notes = notes.replace(a, b)
(B / 'notes.md').write_text(notes)

(B / 'check/labels.json').write_text(json.dumps({'Reader ' + v: k for k, v in LABEL.items()}, indent=2) + '\n')

SEATS = {'fable': 'claude-fable-5-1', 'opus': 'claude-opus-5-5', 'astra': 'gpt-6-astra', 'sol': 'gpt-6.1-sol'}
(B / 'prompts').mkdir(exist_ok=True)
for s in SEATS:
    head = (f'Seat {s}. THIS IS THE ACTUAL r99b CONSENSUS-ROUND LAUNCH. Execute the full review now and return your '
            'substantive answer as your final message. Do not merely acknowledge.\n\n'
            f'Launch assignment: your independent clone is {B}/{s}, detached at the pin {PIN}; the packet is '
            f'{B}/brief.md (reproduced below). Read {B}/notes.md first. Relative paths inside r99\'s sections '
            f'(Qn-*.txt, R-*.txt, R-NOTE-append.md, check/, evidence/, forms.sha256) resolve from r99\'s folder {R}; '
            f'r99b\'s own files are {B}/forms/ and {B}/check/trial-alt.py, trial-alt.json and the trial logs. Do not read any '
            'reader output or record that notes.md\'s fences list. Do not read ~/.grok or any other '
            'credential/account directory. Do not read or touch /home/user/projects/provisiond-spec. '
            f'Write scratch only under {B}/tmp/{s}.\n\n{RULE6}\n\n')
    (B / 'prompts' / f'{s}.md').write_text(head + brief_b)
for f in ('brief.md', 'notes.md'):
    print(f, sha((B / f).read_bytes()))
