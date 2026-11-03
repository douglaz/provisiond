#!/usr/bin/env python3
"""Build r100b brief.md from r100's frozen brief, form files and reader answers (seat map: labels.json)."""
import hashlib, json, pathlib, re, sys

R = pathlib.Path('/var/tmp/provisiond-panel-r100')
B = R / 'r100b'
PIN = '2cb8e1189310ae096e598bac798df3437be59500'
LABELS = {'A': 'sol', 'B': 'astra', 'C': 'opus'}
SEAT_OF = {v: k for k, v in LABELS.items()}

def sha(p):
    return hashlib.sha256(pathlib.Path(p).read_bytes()).hexdigest()

def text(p):
    return pathlib.Path(p).read_text(encoding='utf-8')

def anon(s, seat):
    s = s.replace(f'/var/tmp/provisiond-panel-r100/{seat}/', '[clone]/')
    s = s.replace('Astra’s final ballot', '[seat]’s final ballot')
    s = s.replace('Seat **sol**', 'Seat **[seat]**')
    s = s.replace('# Panel r100: opus reader answer', '# Panel r100: [seat] reader answer')
    s = s.replace('`tmp/opus`', '`[scratch]`')
    return s

brief_lines = text(R / 'brief.md').split('\n')
def brief_slice(a, b):  # 1-based inclusive
    return '\n'.join(brief_lines[a - 1:b])

assert brief_lines[423].startswith('## Q1 — the `OPS-23` insert'), brief_lines[423]
assert brief_lines[490].startswith('## Q2 —'), brief_lines[490]
assert brief_lines[873].startswith('## Q-ROUTE'), brief_lines[873]
assert brief_lines[922].startswith('## 9. Citation trial'), brief_lines[922]

ans = {s: text(R / f'{s}.md') for s in ('opus', 'astra', 'sol')}
ans_lines = {s: ans[s].split('\n') for s in ans}
def ex(seat, a, b=None):
    b = b or a
    return anon('\n'.join(ans_lines[seat][a - 1:b]), seat)

for s in ans:
    a = anon(ans[s], s)
    # Only historical r86b file citations may still name a seat.
    for m in re.finditer(r'\b(opus|astra|sol|Astra|Sol|Opus)\b', a):
        ctx = a[max(0, m.start() - 12):m.end() + 12]
        assert ('r86b `' in ctx) or ("astra and sol's" in a[max(0, m.start() - 12):m.end() + 20]) \
            or ("and sol's objection" in a[max(0, m.start() - 12):m.end() + 20]), (s, ctx)

q1alt = text(R / 'Q1-ALT.txt')
assert sha(R / 'Q1-ALT.txt') == '97035ff0c6bbfae893123db51d53b03bad68e512a47415554d3cf5350fe43816'
assert sha(R / 'check/astra-Q1-ALT.txt') == sha(R / 'check/sol-Q1-ALT.txt') == sha(R / 'Q1-ALT.txt')
q1quote = text(R / 'Q1-QUOTE.txt')
assert q1alt == q1quote.replace('provider mutation.\n`OPS-43`', 'provider mutation;\n`OPS-43`', 1) and q1alt != q1quote

trial = json.loads(text(B / 'check/trial.json'))
def tlog(name):
    return text(B / f'check/trial-{name}.log')
def nums(name):
    lg = tlog(name)
    md = re.search(r'Markdown quoted attributions: (\d+) compared', lg); ln = re.search(r'(\d+) compared under QUOTED', lg)
    return (md.group(1) if md else '?', ln.group(1) if ln else '?')

out = []
w = out.append
w(f'''# Panel r100b — the one consensus round on Q1 and Q-ROUTE

Pin: `{PIN}` (unchanged from r100: master; local branch `pv-e45e` is at the same commit). Your clone
is detached at it. Read every source with `git show {PIN}:<path>` in your clone and check the bytes
yourself. Every block below is sliced from r100's frozen brief (`/var/tmp/provisiond-panel-r100/brief.md`,
SHA-256 `{sha(R / 'brief.md')}`), from form files or from r100's answers by the manager's build script
(fenced, because it holds the seat map); none was retyped. Relative paths inside r100's sections
(`Qn-*.txt`, `R-*.txt`, `R-NOTE-append.md`, `check/`, `evidence/`, `forms.sha256`) resolve from r100's
folder `/var/tmp/provisiond-panel-r100`; r100b's trial files are in `/var/tmp/provisiond-panel-r100/r100b/check/`.
Read r100b's `notes.md` first.

**apply notes.md rule 6 exactly as written; this prompt adds no void rule.**

Owner's settling rule, verbatim: "a question is settled when at least three agree and more agree than
disagree, and a tie comes to you. If grok is down, it falls back to three of four"

## 1. Where r100 left things

Fable answered with a usage-limit line and Grok returned HTTP 402 (re-probed for this round: still
402, "Grok Build usage balance exhausted"), so both are missing seats. Three readers answered in full;
their answers are in §6 as Reader A, Reader B and Reader C, without names. Three present seats means a
question settles only when all three make the same exact final pick (3–0).

- **Settled 3–0 and not reopened here** (r100 form files, SHA-256):
  Q2-QUOTE `{sha(R / 'Q2-QUOTE.txt')}`;
  Q3-QUOTE `{sha(R / 'Q3-QUOTE.txt')}`;
  Q4-KEEP `{sha(R / 'Q4-KEEP.txt')}` (the row joined, one newline becomes one space);
  Q5-KEEP `{sha(R / 'Q5-KEEP.txt')}` (no bytes change, so the `PRV-10` form is `check/F-QUOTE.txt`, `{sha(R / 'check/F-QUOTE.txt')}`);
  Q6-QUOTE `{sha(R / 'Q6-QUOTE.txt')}`;
  Q7-KEEP `{sha(R / 'Q7-KEEP.txt')}` (no bytes change). No reader opened a Q8.
- **Q-ROUTE applies**, because Q2, Q3, Q4 and Q6 settled on forms whose bytes differ from the adopted text.
- **Split 2–1, asked again here:** Q1 and Q-ROUTE. This is their one consensus round (notes rule 4);
  there is no r100c. A question that does not settle here goes to the owner.

| Question | Reader A | Reader B | Reader C | Printed forms every reader ACCEPTED in r100 |
|---|---|---|---|---|
| Q1 | Q1-ALT (new) | Q1-ALT (new) | Q1-QUOTE | none (A and B cannot accept QUOTE or KEEP; C cannot accept KEEP and did not read the ALT) |
| Q-ROUTE | R-NOTE | R-RUN | R-NOTE | R-RUN and R-NOTE |

Readers A and B printed the same Q1-ALT, byte for byte. Acceptance does not choose a form (notes rule 2):
only the same exact final pick from all three settles.

## 2. The exact disagreements

### Q1 (`Q2-A-cited.md:62-63`, comment 857:88-89): one appended quoting sentence (QUOTE), or the same with the first sentence's period made a semicolon (ALT)

Q1-ALT differs from Q1-QUOTE in one byte: line 2's final `.` becomes `;`, so the quotations belong to the
sentence that makes the claim. Neither changes the adopted two lines' words.

- Reader A (ALT):

`````text
{ex('sol', 30)}
`````

- Reader B (ALT):

`````text
{ex('astra', 28)}
`````

- Reader C (QUOTE), who did not see the ALT:

`````text
{ex('opus', 25, 29)}
`````

### Q-ROUTE: a dated note appended to Q2-A-cited.md (R-NOTE), or none (R-RUN)

Both leave comment 857 unedited and add no preparation commit. R-NOTE adds the appended note.

- Reader A (R-NOTE):

`````text
{ex('sol', 44)}
`````

- Reader B (R-RUN):

`````text
{ex('astra', 71, 73)}
`````

- Reader C (R-NOTE):

`````text
{ex('opus', 85, 88)}
`````

## 3. Every exact option, in full

The two sections below are sliced from r100's `brief.md` (lines 424-490 and 874-922) and each is
followed by what r100b adds.

{brief_slice(424, 490)}

### Q1: what r100b adds

**Q1-ALT** (`Q1-ALT.txt`, SHA-256 `{sha(R / 'Q1-ALT.txt')}`, pin `{PIN}`), printed byte-identically
by Readers A and B, the exact bytes replacing the span:

`````text
{q1alt.rstrip(chr(10))}
`````

Trials (`r100b/check/trial_b.py`, results `r100b/check/trial.json`; scratch clones of the pin, same
read-only lake index as r100 §9): every settled form applied (Q2-QUOTE, Q3-QUOTE, Q4-KEEP, Q6-QUOTE;
Q5 and Q7 unchanged; `check/F-QUOTE.txt`), with each Q1 option in turn.

| Trial | Q1 option | Exit | Markdown compared | Lean QUOTED compared |
|---|---|---|---|---|
''')
for name, opt in (('T-S-Q1KEEP', 'Q1-KEEP'), ('T-S-Q1QUOTE', 'Q1-QUOTE'), ('T-S-Q1ALT', 'Q1-ALT'),
                  ('N-S-Q1ALT', 'Q1-ALT, first quotation\'s third word "but" replaced by WRONGWORD')):
    md, ln = nums(name)
    ex_ = trial['trials'][name]['exit']
    if ex_ != 0:
        md, ln = '—', '—'
    w(f'| {name} | {opt} | {ex_} | {md} | {ln} |\n')
w(f'''
The three passing trials report 22 unquoted attributions, none new. N-S-Q1ALT fails with "FAIL: 1
unverifiable quoted attribution(s)", the corrupted Q1-ALT quotation. QUOTE and ALT make the same three
comparisons; the gate does not distinguish them.

{brief_slice(874, 922)}

### Q-ROUTE: what r100b adds

- With Q5 settled on KEEP, R-RUN's and R-NOTE's `PRV-10` form is `check/F-QUOTE.txt`, not `F-QUOTE-Q5.txt`.
  The forms whose bytes differ from the adopted text are Q2-QUOTE, Q3-QUOTE, Q4-KEEP, Q6-QUOTE and
  whichever Q1 form settles (any Q1 form but Q1-KEEP).
- Reader C reported, and the manager verified as text, that R-NOTE's opening "Exactly as R-RUN" literally
  inherits R-RUN's "comment 857 and docs/research/panels-2026-10/r86/r86b/Q2-A-cited.md are not edited",
  while R-NOTE itself appends to Q2-A-cited.md. Reader C judged it harmless because the "in addition"
  clause and the exact-prefix condition resolve it. It changes no question's premise; a reader who cannot
  accept R-NOTE's wording for this reason may print a complete exact ALT.

## 4. Brief errors reported in r100 (verified at the pin)

None changed a question's premise and none voided a tally. No r100 vote on Q1 or Q-ROUTE rests on one.

1. r100 brief Q6 text (`brief.md:262`, `:818`) says `OPS-43` steps 1 and 8 (`03-operation-lifecycle.md:790`,
   `:819`) quote `OPS-11` for "the same release claim" and calls QUOTE "a third copy". Those steps quote only
   the commitment half; the exclusion sentence appears only at `03-operation-lifecycle.md:249`; the brief
   also omits `03-operation-lifecycle.md:869-884`. Q6 is settled and not reopened.
2. r100 brief §2 (`brief.md:70`) says the gate "scans" `docs/adr/*.md`; `tools/check_citations.py` reads ADRs
   as sources, not as QUOTED input. `docs/research/` is outside the gate either way.
3. The R-NOTE inheritance in §3 above.

## 5. What to return

For each of Q1 and Q-ROUTE:

1. A final pick: one printed label (Q1-QUOTE, Q1-KEEP, Q1-ALT; R-RUN, R-NOTE) or a new complete exact ALT
   printed in full with its exact span. Say whether it changes your r100 pick, and why.
2. ACCEPT or CANNOT ACCEPT for every printed option, including Q1-ALT, with a reason for each CANNOT
   ACCEPT. Keep your preference separate from what you can accept.
3. Whether the picked form is wording-only: no behavior, requirement or check-strength change (rule 3),
   and any verified blocking loss, or none.
4. Answer the other side's strongest argument (§2) directly.
5. Any brief error you find in this packet, with file:line, and whether it changes a premise (rule 6).

Also say, in one line, whether comment 857 stays unedited under your Q-ROUTE pick. Do not reopen Q2–Q7
and open no Q8. Read only: no edits to your clone or anything else, no Git mutation, no subagents, no
Nix (no `nix develop`, no `tools/check-all.sh`), no lake, no br. Write scratch only under your tmp
folder. Your final message is your answer.

## 6. r100's answers, verbatim

Each answer is copied byte for byte except where a seat name, a seat's clone path or a seat's scratch
path appeared; those are replaced by the visible marks `[seat]`, `[clone]` and `[scratch]`. Nothing else
is changed. Names inside citations of earlier panels' files (for example r86b's `opus.md:102` and the
"astra and sol's objection" retained in owner item 17) refer to those earlier records, not to this
round's readers.

### Fable (missing seat: limit line)

`````text
{text(R / 'fable.md').rstrip(chr(10))}
`````

### Grok (missing seat)

The r100 preflight and this round's refreshed preflight both returned: "API error (status 402 Payment
Required): Grok Build usage balance exhausted".
''')
for L in ('A', 'B', 'C'):
    s = LABELS[L]
    body = anon(ans[s], s).rstrip('\n')
    assert '``````' not in body
    w(f'\n### Reader {L}\n\n``````markdown\n{body}\n``````\n')

brief = ''.join(out)
(B / 'brief.md').write_text(brief, encoding='utf-8')
(B / 'check/labels.json').write_text(json.dumps(LABELS, indent=1) + '\n')
print('brief.md', len(brief.encode()), sha(B / 'brief.md'))
