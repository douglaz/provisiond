"""Assemble brief.md. Every source block is sliced from the pinned bytes (or from the named
read-only record) by line range, with a content assert; every form block is the form file's bytes."""
from pathlib import Path
import subprocess, hashlib, json

P = Path('/var/tmp/provisiond-panel-r99'); C = P / 'check'; REPO = C / 'repo'
PIN = (P / 'PIN').read_text().strip()
BASE = 'b5f71e78a1f195acfa4ac28f090d38e9a35568f0'
meta = json.loads((C / 'build.json').read_text())

def show(path, rev=PIN):
    return subprocess.check_output(['git', 'show', f'{rev}:{path}'], cwd=REPO, text=True)

def sl(text, a, b, must):
    lines = text.split('\n')[a - 1:b]
    out = '\n'.join(lines)
    assert must in out, (a, b, must)
    return out

def fsl(path, a, b, must):
    return sl(Path(path).read_text(), a, b, must)

def form(name):
    return (P / name).read_text()

def sha(name):
    return hashlib.sha256((P / name).read_bytes()).hexdigest()

F5 = '`````'
def blk(body, lang='text'):
    body = body[:-1] if body.endswith('\n') else body
    return f'{F5}{lang}\n{body}\n{F5}'

D, PRV, OPS, API, AG = (show(f) for f in ('01-domain-model.md', '02-provider-contract.md',
                                         '03-operation-lifecycle.md', '04-api-contract.md', 'AGENTS.md'))
QA = show('docs/research/panels-2026-10/r86/r86b/Q1-A.md')
R93 = Path('/var/tmp/provisiond-panel-r93')
OD = '/var/tmp/provisiond-manager/owner-decisions-1030.md'

def qsection(k, title, src_blocks, notes):
    m = meta['questions'][k]
    s = [f'## {k} — {title}\n', f'Landed span ({m["span"]} at the pin), `{k}-OLD.txt`, SHA-256 `{sha(k + "-OLD.txt")}`:\n',
         blk(form(f'{k}-OLD.txt')), '\nSource, verbatim at the pin:\n']
    for label, body in src_blocks:
        s += [f'{label}\n', blk(body), '']
    s += ['Quoted segments and where they sit (checked by `check/build.py` with whitespace-insensitive matching, each found exactly once):\n']
    for q in m['sources']:
        s.append(f'- `{q["file"]}:{q["lines"]}`: "{q["segment"]}"')
    s += ['', f'**{k}-QUOTE** (`{k}-QUOTE.txt`, SHA-256 `{sha(k + "-QUOTE.txt")}`, pin `{PIN}`), the exact bytes replacing the span:\n',
          blk(form(f'{k}-QUOTE.txt')),
          f'\n**{k}-KEEP** (`{k}-KEEP.txt`, SHA-256 `{sha(k + "-KEEP.txt")}`, pin `{PIN}`):\n',
          blk(form(f'{k}-KEEP.txt')), '', notes, '']
    return '\n'.join(s)

out = []
out.append(f'''# Panel r99 — PR #69's added `DOM-10` sentences against "Quote the sentence"

Pin: `{PIN}` (PR #69 head, branch `pv-5pmu`, over master `{BASE}`). Your clone is detached at it.
Read every source with `git show {PIN}:<path>` in your clone and check the bytes yourself. Source
blocks below were sliced from those bytes by `check/build_brief.py`; form blocks are the form files'
bytes. Read `notes.md` first.

**apply notes.md rule 6 exactly as written; this prompt adds no void rule.**

Owner's settling rule, verbatim: "a question is settled when at least three agree and more agree than
disagree, and a tie comes to you. If grok is down, it falls back to three of four".

## 1. The story in plain terms

On 2026-10-30 the owner approved `pv-5pmu`'s wording (owner item 16, "Approve A (Recommended)"). It
adds four paragraphs to `DOM-10` saying when a non-create operation's capability is checked and
which error wins. On 2026-10-31 panel r93 corrected two of its sentences (the replay sentence and the
manual-release clause) to quote the requirements they described, because a review bot flagged them.
PR #69 lands the corrected wording word for word.

On 2026-11-03 the review bot flagged a third sentence of the same wording, at
`01-domain-model.md:575`: "PRV-25's identical-PTR success remains after its capability check." Its
finding (codex P1 4450997798, thread PRRT_kwDOT30eC86y-3YB) says the sentence restates `PRV-25`
without its own words, against `AGENTS.md` lines 29-32. The merge turn verified that `PRV-25`
supports the substance and that the sentence does not quote it, posted that as an evidence reply
(4451040045), and left the thread open. Under the owner's 2026-10-28 wording rule ("For such wording
questions, try to solve by getting a consensus of the panel"), a wording-only touch on adopted text
gets panel consensus first and goes to the owner only when there is no consensus.

So that round 2 does not surface a fourth sentence, the manager swept every line PR #69 adds and
listed every sentence that asserts what another requirement says without that requirement's words
(§3). This panel decides, for each listed sentence, whether to quote it (QUOTE), leave it (KEEP), or
use a complete exact alternative; and, if anything changes, how the approval record follows (Q-REC).
Part of your job is to say whether each option really is wording-only.

## 2. The rule, and what the gate checks

`AGENTS.md:29-32` and `:45-46` at the pin, verbatim:

{blk(sl(AG, 29, 46, 'Completion:'))}

The citation gate (`tools/check_citations.py`) checks a quotation only in these shapes, with the ID in
backticks: `` `ID` says/said/states/stated/reads/read "…" ``, `` `ID`'s <rule|claim|wording|statement|sentence|words|text> that "…" ``,
`` `ID`'s "…" `` and `` `ID`: "…" ``; and only quotations of four or more normalized words. The first
speech attribution in a sentence owns every later quotation in that sentence. Summary verbs (forbids,
requires, names, …) are outside its reach by design. The landed DOM-10 block writes IDs without
backticks, so r93's two quotations ("API-7 step 5a says", "API-65 says") are outside the gate's reach;
the manager checked both by hand against `04-api-contract.md:209` and `:1168` at the pin (whitespace
normalized) and they match. Every QUOTE form below uses the backticked shape so the gate checks it
(§7). That is a style difference from r93's two quotations; an ALT may differ.

## 3. The sweep

Method: `git diff {BASE} {PIN}` (`check/sweep-diff.txt`). It adds 39 lines to `01-domain-model.md`
(DOM-10, :540-577), three to `03-operation-lifecycle.md` (OPS-23, :2081-2082) and two to
`04-api-contract.md` (API-7, :243), and changes pv-5pmu's line in `.beads/issues.jsonl` (the bead closes).
Every added sentence was read against what it names.

The landed DOM-10 block at the pin ({'01-domain-model.md:540-577'}), verbatim:

{blk(sl(D, 540, 577, 'named by PRV-4.'))}

**Listed (asked as Q1–Q5).** Each describes what another requirement contains, in words that are not
that requirement's:

- Q1 `01-domain-model.md:575` — "PRV-25's identical-PTR success remains after its capability check." (the flagged sentence)
- Q2 `01-domain-model.md:547-548` — "An API-64 operator retry checks delete_machine before its state-change/enqueue transaction;" (describes API-64's transaction)
- Q3 `01-domain-model.md:560-561` — "A capability refusal is classified by OPS-11 and carries DOM-10's existing unsupported result." (says OPS-11 classifies it)
- Q4 `01-domain-model.md:565-566` — "A no-call success or defer returned by that decision takes no capability check." (describes what OPS-41's decision returns)
- Q5 `01-domain-model.md:576-577` — "…or the capability-less methods named by PRV-4." (says PRV-4 names capability-less methods)

**Considered and not listed** (the manager reads each as a name, label, position or pointer, not as a
statement of what the requirement says; any reader who disagrees may print a complete exact ALT
under an extra question, Q6, naming the span):

- `:542-543` "API-7's steps 1–5c" — a position in API-7's numbered list.
- `:547` and `:555` "API-64 operator retry" / "API-64 retry attempts" — names the operation API-64 defines.
- `:557` "either OPS-45 marker" — names OPS-45's markers (`03-operation-lifecycle.md:1502` "write-started marker", `:1513` "a second marker is required").
- `:559` "OPS-40's signed-URL check" — names a check.
- `:561` "DOM-10's existing unsupported result" — DOM-10 itself (`01-domain-model.md:516-519`).
- `:564-565` "OPS-41's restore claim gate and ordered fence-transaction decision" — names OPS-41's parts (`03-operation-lifecycle.md:994`, `:1021-1025`).
- `:568-569` "the existing failed-attempt and episode disposition" — names no requirement.
- `:570-571` "API-7's operator retry ceiling and OPS-39's system-ceiling exemption retain their existing scope." — a no-change statement; the labels match `04-api-contract.md:238` ("**`API-64`'s retry is not exempt**: it counts against `SEC-39`'s operator retry ceiling") and `03-operation-lifecycle.md:972-973` ("**Exposure-reducing system cancellations MUST be exempt from `SEC-39`'s per-principal destruction ceiling.**"). This is the closest call among the unlisted ones.
- `03-operation-lifecycle.md:2081-2082` and `04-api-contract.md:243` — pointers to DOM-10 ("Cite the owner").

**Already quoted:** `:546-547` (API-7 step 5a) and `:548-549` (API-65), r93's corrections, outside the
gate's reach but checked by hand (§2). **Pre-existing, not added by this PR:** `01-domain-model.md:516-517`
"the ones `PRV-4` names" is on master; it is out of this sweep.

## 4. Why r93 kept these spans unchanged

r93 was a wording panel on two flagged sentences only. Its record, read only, verbatim:

- `/var/tmp/provisiond-panel-r93/brief.md:9`:
{blk(fsl(R93 / 'brief.md', 9, 9, 'Only pv-5pmu'))}
- `/var/tmp/provisiond-panel-r93/brief.md:231`:
{blk(fsl(R93 / 'brief.md', 231, 231, 'leaving the API-64 retry clause'))}
- `/var/tmp/provisiond-panel-r93/assertion-map.md:274-276` (a byte-preservation audit: O = archived Q1-A, Q = Q-QUOTE.md, B = the prospective brief):
{blk(fsl(R93 / 'assertion-map.md', 274, 276, 'Unchanged bytes'))}
- `/var/tmp/provisiond-panel-r93/opus.md:211` (a reader's note):
{blk(fsl(R93 / 'opus.md', 211, 211, 'out of scope here'))}
- `/var/tmp/provisiond-panel-r93/tally.md:25` (on r93's own Q-KEEP for the two flagged sentences):
{blk(fsl(R93 / 'tally.md', 25, 25, 'No reader proved the Q-KEEP exemption'))}
- `/var/tmp/provisiond-panel-r93/tally.md:97`:
{blk(fsl(R93 / 'tally.md', 97, 97, 'outside this pair'))}

The manager's fair reading: r93 kept these spans byte for byte because they were outside its two-
sentence scope, and one reader foresaw that a later bot pass could flag them; r93 did not rule on
whether they fall under the quotation rule. Two facts point the other way, and you should weigh them:
the owner approved the whole Q1-A text (item 16), and r93's settled package
(`/var/tmp/provisiond-panel-r93/settled-pv-5pmu.md`, SHA-256
`2c579a573654e9f5ded4d66a9e16eaa747dcef63ed1bbc9b68287ef652152f21`) deliberately retained "all other
Q1-A bytes unchanged". Also relevant: r93 rejected its own Q-KEEP for the two flagged sentences, which
had the same shape as Q1 ("A replay returned by API-7 step 5a never reaches this check" became a quotation).

## 5. The approval record

Owner item 16, verbatim (`{OD}:127-133`, machine-local):

{blk(fsl(OD, 127, 133, 'Approve A (Recommended)'))}

`docs/research/panels-2026-10/r86/r86b/Q1-A.md` at the pin holds the original form (Q1's sentence at
`:40`) and r93's dated note "## Wording correction — 2026-10-31 (Panel N r93)" (`:61-83`). pv-5pmu's
Agent Brief comment 856 (status `closed` at the pin) is `evidence/pv-5pmu-comment-856.md`, byte-equal
to the comment's `text` in `.beads/issues.jsonl` at the pin; its line 6 reads:

{blk(sl((P / 'evidence/pv-5pmu-comment-856.md').read_text(), 6, 6, 'Executable form'))}

Its "Desired behavior / key interfaces" block (lines 31-68, inside the text fence at :30 and :69) is byte-equal to the landed DOM-10 block
(checked by `check/build.py`). Each Q1–Q5 OLD span occurs exactly once in it.

The evidence reply already posted on the thread (4451040045), verbatim:

{blk(Path('/var/tmp/provisiond-manager/pv-5pmu-pr/drain-merge/reply-4450997798.txt').read_text())}
''')

out.append(qsection('Q1', 'the PRV-25 sentence (flagged)', [
    ('`02-provider-contract.md:869-876` (PRV-25):', sl(PRV, 869, 876, 'An identical established value MUST settle'))],
    'QUOTE carries both halves the sentence relies on: the ordering ("After … capability …") and the success '
    '("settle `succeeded`"). KEEP rests on the sentence not being a claim the rule covers, or on r93 / owner item 16 '
    'having decided it (§4).'))
out.append(qsection('Q2', 'the API-64 transaction', [
    ('`04-api-contract.md:1109-1118` (API-64):', sl(API, 1109, 1118, 'commit together'))],
    'QUOTE inserts one sentence before the landed sentence and keeps its bytes; it ends with a full stop so '
    'that the gate does not assign API-65\'s later quotation in the same landed sentence to API-64. KEEP rests on the '
    'clause being a new DOM-10 timing rule that only names API-64\'s transaction.'))
out.append(qsection('Q3', '"classified by OPS-11"', [
    ('`03-operation-lifecycle.md:240-241` (OPS-11 lead):', sl(OPS, 240, 241, 'the system MUST classify')),
    ('`03-operation-lifecycle.md:250` (OPS-11, the last row):', sl(OPS, 250, 250, 'power, reverse-DNS, delete, release attachment'))],
    'QUOTE appends OPS-11\'s own lead words. KEEP rests on "classified by OPS-11" being a pointer to the '
    'owner ("Cite the owner") rather than a statement of what OPS-11 says.'))
out.append(qsection('Q4', 'OPS-41\'s no-call success or defer', [
    ('`03-operation-lifecycle.md:994` (OPS-41):', sl(OPS, 994, 994, 'ordered decision below under the fence')),
    ('`03-operation-lifecycle.md:1001-1005` (OPS-41, the no-call success):', sl(OPS, 1001, 1005, 'make no')),
    ('`03-operation-lifecycle.md:1021-1026` (OPS-41, the claim defer):', sl(OPS, 1021, 1026, 'the claim MUST defer'))],
    'QUOTE carries OPS-41\'s words for each outcome and keeps the landed sentence\'s bytes after them. Note that '
    'the defer comes from OPS-41\'s restore claim gate, not its fence-transaction decision; the landed "that decision" '
    'spans both (`:564-565`), and QUOTE does not change that. KEEP rests on the sentence being a DOM-10 rule about '
    'what takes a check, naming outcomes rather than saying what OPS-41 says.'))
out.append(qsection('Q5', 'the methods PRV-4 names', [
    ('`02-provider-contract.md:25-29` (PRV-4):', sl(PRV, 25, 29, 'refresh rescue session'))],
    'QUOTE appends PRV-4\'s list. KEEP rests on "Cite the list; let it hold the number" (`AGENTS.md:40-43`): '
    'pointing at the list\'s owner instead of restating it is that rule\'s own form, and master\'s `01-domain-model.md:516-517` '
    'already says "the ones `PRV-4` names".'))

out.append(f'''## Q-REC — how the record follows

Answer this only conditionally: it applies if any of Q1–Q5 settles on a non-KEEP form, because then
the landed text differs from comment 856 and from the r93 package. The precedent is owner item 25,
which chose r97's Q4 "Add dated archive note (Recommended)" (r97's L-NOTE). Pick one, or print a
complete exact ALT. All three leave the archived r93 record unchanged.

**R-NOTE** (`R-NOTE.txt`, SHA-256 `{sha('R-NOTE.txt')}`, pin `{PIN}`):

{blk(form('R-NOTE.txt'))}

`R-NOTE-append.md` (SHA-256 `{sha('R-NOTE-append.md')}`), the exact bytes appended (it begins with two newlines):

{blk(form('R-NOTE-append.md'), 'markdown')}

`check/prospective-Q1-A.md` shows the result; the pinned Q1-A.md bytes are its exact prefix.

**R-BRIEF** (`R-BRIEF.txt`, SHA-256 `{sha('R-BRIEF.txt')}`, pin `{PIN}`):

{blk(form('R-BRIEF.txt'))}

**R-ARCHIVE** (`R-ARCHIVE.txt`, SHA-256 `{sha('R-ARCHIVE.txt')}`, pin `{PIN}`):

{blk(form('R-ARCHIVE.txt'))}

For the all-QUOTE case, `check/prospective-comment-856-allquote.md` and
`check/prospective-DOM10-allquote.md` show the exact resulting text (`forms.sha256` lists every file's
SHA-256). A subset of QUOTE forms changes only its own spans.

## 7. Citation trial (scratch clones of the pin, `check/trial.py`, results `check/trial.json`)

The lake index came read only from the pv-5pmu Run's trial; `tools/formal` and the gate are
byte-equal to that source at the pin. Every run below is `python3 tools/check_citations.py`.

- T0, the pin as is: exit 0; 360 Markdown quotations compared; unquoted attributions 22, none new against baseline 22.
- T1, all five QUOTE forms: exit 0; 367 compared (the seven new quotations); unquoted 22, none new.
- T-Q1 … T-Q5, each QUOTE form alone: exit 0.
- T2, T1 plus R-NOTE's Q1-A.md append: exit 0.
- N-Q1 … N-Q5, negative controls (T1 with one word of that question's first quotation replaced by WRONGWORD): exit 1 each, naming that question's owner (PRV-25, API-64, OPS-11, OPS-41, PRV-4). Every QUOTE form is in the gate's reach.

KEEP is T0.

## 8. Your answer

For each of Q1, Q2, Q3, Q4, Q5 and Q-REC (and any Q6 you open):

1. Final pick: one label (Qn-QUOTE, Qn-KEEP, R-NOTE, R-BRIEF, R-ARCHIVE) or a complete exact ALT
   printed in full with its exact span.
2. ACCEPT or CANNOT ACCEPT for every printed option, separately from the pick.
3. Whether the picked form is wording-only: no behavior, requirement or check-strength change (rule 3).
4. The strongest reason, with file:line at the pin.
5. Any brief error you verified, and whether it changes the question's premise (rule 6).
''')

text = '\n'.join(out)
(P / 'brief.md').write_text(text)
print(len(text.encode()), hashlib.sha256(text.encode()).hexdigest())
