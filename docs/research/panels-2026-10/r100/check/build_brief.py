"""Assemble r100 brief.md. Every source block is sliced from the pinned bytes (git show PIN:<path>, read only)
or from the named read-only record by line range, with a content assert; every form block is the form file's bytes."""
from pathlib import Path
import subprocess, hashlib, json, re

P = Path('/var/tmp/provisiond-panel-r100'); C = P / 'check'
REPO = '/home/user/projects/provisiond-spec'
PIN = (P / 'PIN').read_text().strip()
assert PIN == '2cb8e1189310ae096e598bac798df3437be59500'
meta = json.loads((C / 'build.json').read_text())
trial = json.loads((C / 'trial.json').read_text())

def show(path, rev=PIN):
    return subprocess.check_output(['git', '-C', REPO, 'show', f'{rev}:{path}'], text=True)

def sl(text, a, b, must):
    out = '\n'.join(text.split('\n')[a - 1:b])
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

AG, OPS, API, PER, CNF = (show(f) for f in ('AGENTS.md', '03-operation-lifecycle.md', '04-api-contract.md',
                                            '05-persistence.md', '10-conformance-checklist.md'))
LEAN = show('tools/formal/Provisiond/Admission.lean')
QA_PATH = 'docs/research/panels-2026-10/r86/r86b/Q2-A-cited.md'
QA = show(QA_PATH)
assert QA == (P / 'evidence/Q2-A-cited.md').read_text()
assert hashlib.sha256(QA.encode()).hexdigest() == 'd611bbae87294a0fc0087c567fa82aa1404cd0c5a54abe394b5327488ec51ea2'
R86B = Path('/var/tmp/provisiond-panel-r86/r86b')
R99 = Path('/var/tmp/provisiond-panel-r99')
OD = '/var/tmp/provisiond-manager/owner-decisions-1030.md'
C857 = (P / 'evidence/pv-e45e-comment-857.md').read_text()

def line_excerpt(path, n, must):
    line = Path(path).read_text().split('\n')[n - 1]
    i = line.index(must)
    return line, i

def trial_stats(name):
    log = (C / f'trial-{name}.log').read_text()
    md = re.search(r'Markdown quoted attributions: (\d+) compared', log).group(1)
    lq = re.search(r'(\d+) compared under QUOTED', log).group(1)
    un = re.search(r'unquoted attributions: (\d+), none new', log).group(1)
    ex = (C / f'trial-{name}.exit').read_text().strip()
    assert ex == str(trial['trials'][name]['exit'])
    return ex, md, lq, un

def qsection(k, title, where, src_blocks, notes, extra_forms=()):
    m = meta['questions'][k]
    s = [f'## {k} — {title}\n',
         f'Adopted span: `{QA_PATH}:{m["Q2-A-cited.md"]}` (comment 857:{m["comment857"]}). {where} '
         f'`{k}-OLD.txt`, SHA-256 `{sha(k + "-OLD.txt")}`:\n',
         blk(form(f'{k}-OLD.txt')), '\nSources, verbatim at the pin:\n']
    for label, body in src_blocks:
        s += [f'{label}\n', blk(body), '']
    s += ['QUOTE\'s quoted segments and where they sit (checked by `check/build.py`, whitespace-insensitive, each found exactly once in its block):\n']
    for q in m['sources']:
        s.append(f'- {q["owner"]}, `{q["file"]}`:{q["lines"]}: "{q["segment"]}"')
    s += ['', f'**{k}-QUOTE** (`{k}-QUOTE.txt`, SHA-256 `{sha(k + "-QUOTE.txt")}`, pin `{PIN}`), the exact bytes replacing the span:\n',
          blk(form(f'{k}-QUOTE.txt')),
          f'\n**{k}-KEEP** (`{k}-KEEP.txt`, SHA-256 `{sha(k + "-KEEP.txt")}`, pin `{PIN}`):\n',
          blk(form(f'{k}-KEEP.txt')), '']
    for lab, fn, intro in extra_forms:
        s += [f'**{lab}** (`{fn}`, SHA-256 `{sha(fn)}`, pin `{PIN}`){intro}:\n', blk(form(fn)), '']
    ex, md, lq, un = trial_stats(f'T-{k}')
    nex = (C / f'trial-N-{k}.exit').read_text().strip()
    s += [f'Trial: T-{k} (this QUOTE alone, every other span as adopted' + ('' if k == 'Q4' else ', Q4 joined') + f') exits {ex}, {md} Markdown and {lq} Lean '
          f'docstring quotations compared, unquoted attributions {un}, none new. N-{k} (all QUOTE forms, this one\'s third '
          f'quoted word "{trial["wrongword"][k]}" replaced by WRONGWORD) exits {nex}.\n', notes, '']
    return '\n'.join(s)

out = []
out.append(f'''# Panel r100 — pv-e45e's adopted Q2-A-cited text against "Quote the sentence"

Pin: `{PIN}` (master; local branch `pv-e45e` is at the same commit, with no commits of its own). Your
clone is detached at it. Read every source with `git show {PIN}:<path>` in your clone and check the
bytes yourself. Source blocks below were sliced from those bytes by `check/build_brief.py`; form
blocks are the form files' bytes. Read `notes.md` first.

**apply notes.md rule 6 exactly as written; this prompt adds no void rule.**

Owner's settling rule, verbatim: "a question is settled when at least three agree and more agree than
disagree, and a tie comes to you. If grok is down, it falls back to three of four".

## 1. The story in plain terms

On 2026-10-30 the owner decided pv-e45e's design question, "may one account sell both VMs and physical
servers?", with "A: yes, kind per offer" (owner item 17). That adopts exactly the text of
`{QA_PATH}` (the r86b form "Q2-A-cited"), as pv-e45e's brief: it rewrites `API-7` step 5d, the
rich-purchase tail's opening, `OPS-43` steps 3 and 5, and adds sentences to `OPS-23`, the
`05-persistence.md` `request_summary` row, `STO-50`, `CNF-55`, `CNF-19` and four Lean docstrings in
`tools/formal/Provisiond/Admission.lean`. pv-e45e's Agent Brief comment 857 carries the same blocks.

On 2026-11-03 the owner settled how a related `PRV-10` quotation reaches the Run (owner item 26, "Run
instruction carries the edit"): no preparation commit, comment 857 is not edited, and the Run
instruction quotes the r98 route text and `check/F-QUOTE.txt` verbatim.

At 15:50Z the same day, the manager launching pv-e45e's Run stopped at its pre-Run quote check. Some
adopted sentences assert what another requirement says without that requirement's words, against
`AGENTS.md:29-30` and its completion line `:45-46` (§2). The Run's reviewers would very likely flag
them, as a review bot flagged the same shape on PR #69 (panel r99). Under the owner's 2026-10-28
wording rule ("For such wording questions, try to solve by getting a consensus of the panel"), a
wording-only touch on adopted text gets panel consensus first and goes to the owner only when there is
no consensus.

So the Run's review does not surface another sentence later, the manager swept everything the Run
would write (§3) and lists seven sentences. For each, this panel decides whether to quote (QUOTE),
leave it as adopted (KEEP), or use a complete exact alternative; Q4 also has a byte-identical ASIS.
Q-ROUTE asks how any change reaches the Run and the record. Part of your job is to say whether each
option really is wording-only.

## 2. The rule, and what the gate checks

`AGENTS.md:29-46` at the pin, verbatim:

{blk(sl(AG, 29, 46, 'Completion:'))}

The citation gate (`tools/check_citations.py`) checks a quotation only in these shapes, with the ID in
backticks: `` `ID` says/said/states/stated/reads/read "…" ``, `` `ID`'s <rule|claim|wording|statement|sentence|words|text> that "…" ``,
`` `ID`'s "…" `` and `` `ID`: "…" ``; only quotations of four or more normalized words; and in Lean
docstrings the EXISTS rule (every quoted string must exist somewhere in the corpus). The first speech
attribution in a sentence owns every later quotation in that sentence. Summary verbs are outside its
reach by design. It scans only root `*.md` (`tools/check_citations.py:642`) and `docs/adr/*.md`
(`:645`), plus the Lean docstrings, so `docs/research/` is outside it. Most IDs in the adopted text
are written without backticks (e.g. "OPS-43 step 5", "API-7", "CNF-55"), so those mentions are
outside the gate's reach whatever they say. Every QUOTE form below uses the backticked shape so that
the gate checks it against the text as it would stand after the Run (§9).

Note that several QUOTE forms quote the adopted new `API-7` step 5d or `OPS-43` step 5, which exist
only once the Run lands them; the trial applies the whole adopted package first and then checks.

## 3. The sweep

Swept whole: `{QA_PATH}` at the pin (SHA-256 `d611bbae87294a0fc0087c567fa82aa1404cd0c5a54abe394b5327488ec51ea2`,
159 lines, byte-equal to the r86b record and to `evidence/Q2-A-cited.md`), comment 857
(`evidence/pv-e45e-comment-857.md`, SHA-256 `{sha("evidence/pv-e45e-comment-857.md")}`, byte-equal to
the comment's `text` in `.beads/issues.jsonl` at the pin; its 20 text blocks are Q2-A-cited's blocks
plus the current-text blocks; line map: Q2-A-cited `:N` is comment 857 `:N+26` up to `:70` and
`:N+29` after), and the PRV-10 form `check/F-QUOTE.txt` (SHA-256 `{sha("check/F-QUOTE.txt")}`, byte-equal to
`/var/tmp/provisiond-panel-r98/check/F-QUOTE.txt`). Every sentence of every block the Run writes was
asked: does it assert what another requirement (by ID, or a step of one) says? If so, does it carry
that requirement's own words? The manager's record is `check/sweep.txt`.

The adopted text, whole, verbatim (`{QA_PATH}` at the pin):

{blk(QA, 'markdown')}

**Listed (asked as Q1–Q7).**

- Q1 `Q2-A-cited.md:62-63` — the `OPS-23` insert: "The offer-kind consistency check at OPS-43 step 5 uses the same exception: it runs on step 4's current List offers result, after that read and before any provider mutation." Restates where `OPS-43` steps 4 and 5 run, without their words.
- Q2 `Q2-A-cited.md:131-134` — the `Admission.lean:317-319` docstring: "step 5d gates a create on the ordering capability selected by the named offer's kind in the stored listing, and takes no gate for an offer absent from it." Paraphrases `API-7` step 5d, and replaces a quotation already in the file (`"**gate a create on its ordering capability**"`).
- Q3 `Q2-A-cited.md:144-146` — the `Admission.lean:1181-1182` docstring: "for an offer absent from that listing step 5d takes no gate". Paraphrases step 5d's absent-offer branch. Its first clause (what the model's Boolean answers) is model semantics and is not listed.
- Q4 `Q2-A-cited.md:69-70` — the `05-persistence.md:523` `request_summary` row: "copied from the named offer at admission under API-7". Borderline: the same shape as r99's Q2, which the owner kept (item 27). Also: the adopted block's line break after "copied from the" lands inside the one-line Markdown table row and splits it (Q4 below).
- Q5 `Q2-A-cited.md:39` (span `:39-43`) — `OPS-43` step 3: "The `api` writes `machine_kind` at admission". Borderline: it names no requirement, but restates what `API-7` step 5d's last sentence requires.
- Q6 `Q2-A-cited.md:55-56` — `OPS-43` step 5's last clause: "the same existing pre-step-9 settlement releases the commitment and any resource-offer exclusion." Asserts what `OPS-11`'s pre-step-9 settlement does; landed `OPS-43` steps 1 and 8 (`03-operation-lifecycle.md:790`, `:819`) quote `OPS-11` for the same release claim.
- Q7 `Q2-A-cited.md:101` — the `CNF-19` addition: "assert the CNF-55 pre-List-offers refusal using the retained machine_kind." Borderline: a test directive, but it characterizes where `CNF-55`'s refusal happens ("pre-List-offers") without `CNF-55`'s words.

The launch manager's five (`/var/tmp/provisiond-manager/dr-e45e-check/sweep.txt`) are Q1, Q2, Q3 (its
F1–F3) and Q4, Q5 (its B1, B2), all confirmed; Q4 is extended by the row split. Q6 and Q7 are new.

**Considered and not listed** (the manager reads each as a pointer, a name, the requirement's own rule,
a test directive naming which refusal to assert, or already quoted; any reader who disagrees may open
Q8 with a complete exact ALT naming its span):

- `:6` "open the existing LDG-35 admission transaction"; `:22-23` "inside the existing LDG-35 transaction" — name the transaction; the sentence is `API-7`'s own rule.
- `:9` and `:41` "gate on DOM-10's matching ordering capability" — names the gate; the sentence is the step's own rule.
- `:22` "After steps 1–5d", `:24`, `:30` — `API-7`'s references to its own step.
- `:35-37` step 3 opening — carries `OPS-23`, `PRV-10` and `PRV-8` quotations (the r86b "-cited" restoration).
- `:38` "the missing-field checks in `OPS-23`" and `:39-40` "for missing or invalid fields, see `OPS-23`" — pointers (the pin already has "missing-field checks defined in `OPS-23`", `03-operation-lifecycle.md:799-800`).
- `:50-52` `details.reason: "offer_not_sellable"` — a value literal, not a quotation.
- `:76` `STO-50` "as defined on the request_summary row" — a pointer.
- `:82-84` the `CNF-55` fixture sentences — `CNF-55`'s own text.
- `:90-99`, `:100`, `:102-106` `CNF-19` directives: `:92` "refuses at API-7 step 5d naming provision_bare_metal", `:94-95` "the normal collected tail", `:99` "the existing stale-listing refusal", `:102` "OPS-23's incomplete_record result" (`OPS-23`'s own term, `03-operation-lifecycle.md:2052`), `:104` "OPS-43 step 4" and "step 5's kind-mismatch refusal", `:106` "the existing absent-offer refusal" — directives naming which refusal to assert. Q7 is listed because it also characterizes the cited refusal's placement.
- `:120` (Lean line 19) and `:156-157` (Lean line 1205) — carry quotations.
- `:133-134` "Off, a create without that declaration reaches the purchase tail." — model flag semantics, unchanged landed words.
- `:144` the first clause of the Lean line-1181 docstring — model semantics.
- `check/F-QUOTE.txt` — every added span is a quotation of the new steps. Under Q5-QUOTE it is regenerated by r98's rule as `check/F-QUOTE-Q5.txt` (Q5).

**Pre-existing, out of scope (reported, not asked):** the landed `OPS-23` paragraph quotes step 4 as
"Obtain the current driver List offers result" (`03-operation-lifecycle.md:2078`) while step 4 at
`:803` reads "obtain"; the Run does not touch it. The adopted tail opening (`:21`) drops the
backticks the pinned tail has around ADR-0030 and LDG-35; not a quotation issue.

## 4. How r86/r86b judged the quotations in Q2-A-cited

All read only; verbatim with file:line.

- r86b's brief says what "-cited" added, `/var/tmp/provisiond-panel-r86/r86b/brief.md:44`:
{blk(fsl(R86B / 'brief.md', 44, 44, 'additionally restore selected OPS-43 quotations'))}
- and how the cited forms came to the panel, `r86b/brief.md:684` (the paragraph opening "Complete candidates for this round"):
{blk(fsl(R86B / 'brief.md', 684, 684, 'claim no resolution of the disputed formal semantics'))}
- r86's fable answer, reproduced verbatim in r86b (`r86b/brief.md:1342` "BEGIN VERBATIM R86 fable"), excerpt of `r86b/brief.md:1386`:
{blk((lambda L: L[0][L[1]:L[0].index('not a gate failure.') + len('not a gate failure.')])(line_excerpt(R86B / 'brief.md', 1386, 'Both Q2 forms also replace')))}
- r86's opus answer, reproduced in r86b (`r86b/brief.md:1460` "# r86 Panel G: opus reader answer", section "Brief errors (rule 6)" at `:1586`), `r86b/brief.md:1590-1591`:
{blk(fsl(R86B / 'brief.md', 1590, 1591, 'A one-line docstring follow-up is advisable'))}
- r86b opus, `r86b/opus.md:102`, `:104` and `:152`:
{blk(fsl(R86B / 'opus.md', 102, 104, 'It is still lawful.'))}
{blk(fsl(R86B / 'opus.md', 152, 152, 'Why A-cited over A-prime.'))}
- r86b fable, `r86b/fable.md:10-11`, `:59` (its rule-6 note) and `:65` (its alternative A-formal, unreviewed):
{blk(fsl(R86B / 'fable.md', 10, 11, 'Final Q2 pick'))}
{blk(fsl(R86B / 'fable.md', 59, 59, 'must be joined on landing'))}
{blk(fsl(R86B / 'fable.md', 65, 65, 'lines-317–319 Lean substitutions exactly as printed'))}
- r86b tally, `r86b/tally.md:70`:
{blk(fsl(R86B / 'tally.md', 70, 70, 'A-prime, A-cited and B-cited exit 0'))}

The manager's fair reading: in r86b, "cited" meant gate-clean plus the restored `OPS-43` step-3
quotations (`OPS-23`, `PRV-10`, `PRV-8`). The Lean docstrings were judged for formal semantics and for
the gate (opus.md:102-104; tally.md:70; brief.md:1591 asked for a docstring follow-up), not against
the quotation rule. No r86 or r86b reader judged the `OPS-23` insert (Q1), the line-317 and line-1181
paraphrases (Q2, Q3), the 05 row (Q4; fable noted only its line break), the step-3 admission clause
(Q5), the step-5 settlement clause (Q6) or the `CNF-19` line (Q7) against the quotation rule. Weigh the
other way: the owner adopted the whole text exactly (item 17, §5); fable's A-formal took the line-317
substitution "exactly as printed" (fable.md:65); and r86 fable called the step-3 paraphrase "a quality
regression … not a gate failure" (brief.md:1386), i.e. a reader did weigh the rule, if only for step 3.

**The r99 precedent (same shape, different text).** Panel r99 swept PR #69's adopted `DOM-10` wording
for the same rule. Its tally (`/var/tmp/provisiond-panel-r99/tally.md`): a sentence restating
`PRV-25`'s ordering and outcome settled QUOTE 3–0 (`:22-35`); "classified by OPS-11" settled KEEP 3–0
as a pointer to its owner, `AGENTS.md:34` (`:52-65`); "the capability-less methods named by PRV-4" settled
KEEP 3–0 as a list-owner pointer, `AGENTS.md:40-43` (`:83-96`). "An API-64 operator retry checks
delete_machine before its state-change/enqueue transaction" split 2–1 in r99 and again in r99b, every
seat switched, and went to the owner, who chose "Keep the clause as landed" (owner item 27, §5).
Q4 here ("copied from the named offer at admission under API-7") has that shape: a new rule of its own
that names the requirement it comes from.

## 5. The approval record

Owner item 17, verbatim (`{OD}:135-142`, machine-local):

{blk(fsl(OD, 135, 142, 'A: yes, kind'))}

Owner item 26, verbatim (`{OD}:218-233`):

{blk(fsl(OD, 218, 233, 'Run instruction carries the edit'))}

The route text item 26 adopts, `/var/tmp/provisiond-panel-r98/brief.md:201-203`:

{blk(fsl('/var/tmp/provisiond-panel-r98/brief.md', 201, 203, 'No preparation commit.'))}

Owner item 27, verbatim (`{OD}:234-246`):

{blk(fsl(OD, 234, 246, 'Keep the clause as landed'))}

Comment 857's line 6, verbatim (`evidence/pv-e45e-comment-857.md:6`):

{blk(sl(C857, 6, 6, 'Adopted exact form'))}
''')

ADM = 'tools/formal/Provisiond/Admission.lean'
QA5D = ('`Q2-A-cited.md:5-16` (adopted new `API-7` step 5d):', sl(QA, 5, 16, 'On admission, retain'))
out.append(qsection('Q1', 'the `OPS-23` insert', 'It lands after `03-operation-lifecycle.md:2076-2079`.', [
    ('`03-operation-lifecycle.md:2076-2079` (the landed `OPS-23` exception paragraph the insert follows):', sl(OPS, 2076, 2079, 'are exceptions to this requirement')),
    ('`03-operation-lifecycle.md:803` (`OPS-43` step 4, unchanged by the Run):', sl(OPS, 803, 803, 'obtain the current driver List offers result')),
    ('`Q2-A-cited.md:48-57` (adopted new `OPS-43` step 5):', sl(QA, 48, 57, 'before any provider mutation'))],
    'QUOTE keeps the adopted two lines and appends one sentence carrying step 5\'s and step 4\'s words for '
    'the claims it relies on (what the check is, "before any provider mutation", and the List offers read). '
    'KEEP rests on the insert being `OPS-23`\'s own exception rule that names where it applies, as the landed '
    'paragraph above it is (and that paragraph does quote steps 4 and 5).'))
out.append(qsection('Q2', 'the `Admission.lean:317-319` docstring', f'It replaces `{ADM}:317-319`.', [
    (f'`{ADM}:317-319` at the pin (what the adopted text replaces):', sl(LEAN, 317, 319, 'gate a create on its ordering capability')),
    QA5D],
    'QUOTE keeps the adopted docstring and adds `API-7`\'s words for both halves before "Off, …"; the Lean '
    'EXISTS rule checks them. KEEP rests on the docstring being a model summary of what the guard models, '
    'not a claim about `API-7`\'s wording; and on r86b, where fable\'s A-formal kept this substitution exactly '
    '(§4). Against KEEP: the pinned docstring quotes `API-7`, and the adopted text replaces that quotation with '
    'a paraphrase.'))
out.append(qsection('Q3', 'the `Admission.lean:1181-1182` docstring', f'It replaces words on `{ADM}:1181-1182`.', [
    (f'`{ADM}:1180-1183` at the pin:', sl(LEAN, 1180, 1183, 'Machine-kind selection')),
    QA5D],
    'QUOTE adds `API-7`\'s absent-offer sentence in parentheses. Only the absent-offer clause is asked; the '
    'first clause (what the Boolean answers) is model semantics. KEEP rests on the clause describing the '
    'model\'s convention ("the Boolean is supplied `true`"), which r86 opus asked for as a docstring follow-up '
    '(brief.md:1591), rather than restating `API-7`.'))
row = PER.split('\n')[522]
assert row.startswith('| `request_summary` | json |') and "the **offer snapshot** (`offer_id`, the offer's `install_strategies` as accepted," in row
diff = (C / 'trial-T-ASIS.diff').read_text()
h = diff[diff.index('diff --git a/05-persistence.md'):diff.index('diff --git a/10-conformance-checklist.md')]
hl = [l for l in h.split('\n') if l.startswith(('-| `request_summary`', '+| `request_summary`', '+named offer at admission'))]
assert len(hl) == 3, hl
hl = [l[:150] + ' …' if len(l) > 150 else l for l in hl]
out.append(qsection('Q4', 'the 05 `request_summary` row', f'It replaces the exact words "the **offer snapshot** (`offer_id`, the offer\'s `install_strategies` as accepted," inside `05-persistence.md:523`, a single Markdown table row of {len(row)} characters.', [
    ('`05-persistence.md:523` at the pin, first 330 characters (the whole row is one line):', row[:330] + ' …'),
    QA5D,
    ('`check/trial-T-ASIS.diff`, the 05 hunk\'s changed lines (each cut at 150 characters): the adopted line break splits the row into a table row and a stray line', '\n'.join(hl))],
    'Q4 has three forms. **Q4-ASIS** writes the adopted bytes as they are, line break included, which splits the '
    'table row (r86b fable.md:59: "the 05-persistence replacement text as printed has a line break inside a table '
    'row and must be joined on landing, a formatting matter"). **Q4-KEEP** is the adopted words joined onto one '
    'line: every word as adopted, only the line break replaced by a space. **Q4-QUOTE** is Q4-KEEP plus `API-7`\'s '
    'words. KEEP rests on the clause being the row\'s own rule naming its source, the same shape as r99\'s Q2 that '
    'the owner kept (item 27). ASIS keeps the bytes exactly but leaves a broken table row; KEEP and QUOTE change '
    'bytes, so Q-ROUTE applies to them.',
    extra_forms=[('Q4-ASIS', 'Q4-ASIS.txt', ', no byte change')]))
fq = (C / 'F-QUOTE.txt').read_text(); fq5 = (C / 'F-QUOTE-Q5.txt').read_text()
out.append(qsection('Q5', 'the `OPS-43` step 3 admission clause', 'It replaces `03-operation-lifecycle.md:797-802` (`OPS-43` step 3) as part of the adopted step.', [
    ('`03-operation-lifecycle.md:797-802` at the pin (`OPS-43` step 3, replaced by the adopted step):', sl(OPS, 797, 802, 'then the capability gate')),
    ('`Q2-A-cited.md:34-44` (adopted new `OPS-43` step 3):', sl(QA, 34, 44, 'this gate.')),
    QA5D],
    'QUOTE adds `API-7`\'s retention sentence in parentheses and rewraps the step. Cascade: `PRV-10`\'s form '
    '(`check/F-QUOTE.txt`, which the Run carries under item 26) quotes step 3 whole, so under Q5-QUOTE the same '
    'r98 re-slice rule gives `check/F-QUOTE-Q5.txt` (SHA-256 '
    f'`{sha("check/F-QUOTE-Q5.txt")}`, {len(fq5.encode())} bytes against F-QUOTE\'s {len(fq.encode())}): '
    'its step-3 quotation then contains the parenthesis and the new line breaks; nothing else differs. KEEP '
    'rests on the clause naming no requirement: it is step 3\'s own statement of who writes the field it validates.'))
out.append(qsection('Q6', 'the `OPS-43` step 5 settlement clause', 'It is the last clause of the adopted step 5, which replaces `03-operation-lifecycle.md:804-805`.', [
    ('`03-operation-lifecycle.md:249` at the pin (`OPS-11`, the create row, one line):', sl(OPS, 249, 249, 'The commitment is released in full under `LDG-32`')),
    ('`03-operation-lifecycle.md:786-792` at the pin (`OPS-43` step 1, which quotes `OPS-11` for the same release):', sl(OPS, 786, 792, 'pre-step-9 create rule'))],
    'QUOTE appends `OPS-11`\'s words for both released things. KEEP rests on "the same existing pre-step-9 '
    'settlement" pointing at the settlement already quoted in steps 1 and 8, so that a third copy of the '
    'quotation adds nothing ("Cite the owner", AGENTS.md:34).'))
out.append(qsection('Q7', 'the `CNF-19` directive', 'It is the twelfth line of the block appended to `CNF-19`.', [
    ('`10-conformance-checklist.md:358-376` at the pin (`CNF-55`):', sl(CNF, 358, 376, 'refuses it at `OPS-43`\'s step 3'))],
    'QUOTE adds `CNF-55`\'s words for where the worker refuses. KEEP rests on the line being a test directive '
    'naming which assertion to reuse ("the CNF-55 … refusal"), like the other `CNF-19` directives in §3; '
    '"pre-List-offers" matches `CNF-55`\'s "no provider request, including no List offers read" (`:373-374`).'))

out.append(f'''## Q-ROUTE — how a changed form reaches the Run and the record

Answer this conditionally: it applies if any of Q1–Q7 settles on a form whose bytes differ from the
adopted text (any QUOTE, Q4-KEEP, or an ALT). It does not apply if every question settles on KEEP or
Q4-ASIS. Pick one, or print a complete exact ALT.

Precedents: owner item 26 ("Run instruction carries the edit": no preparation commit, comment 857 not
edited, the Run instruction quotes the settled forms verbatim), and the dated archive notes r97 Q4
(owner item 25) and r99 Q-REC (`/var/tmp/provisiond-panel-r99/r99b/forms/R-NOTE-ALT.txt`, which also
edited comment 856 and appended "## Wording correction — 2026-11-03 (Panel r99)" to the r86b record).
Both forms below leave comment 857 unedited, as item 26 has it, and add no preparation commit; a
"prep commit edits comment 857" route is not printed because item 26 rejected exactly that ("Prep
commit edits comment 857 (Recommended)"). An ALT may still propose it.

**R-RUN** (`R-RUN.txt`, SHA-256 `{sha('R-RUN.txt')}`, pin `{PIN}`):

{blk(form('R-RUN.txt'))}

**R-NOTE** (`R-NOTE.txt`, SHA-256 `{sha('R-NOTE.txt')}`, pin `{PIN}`):

{blk(form('R-NOTE.txt'))}

`R-NOTE-append.md` (SHA-256 `{sha('R-NOTE-append.md')}`), the exact bytes appended. The pinned
Q2-A-cited.md ends with a blank line, so it begins directly with the heading:

{blk(form('R-NOTE-append.md'), 'markdown')}

`check/prospective-Q2-A-cited-with-note.md` (SHA-256 `{sha('check/prospective-Q2-A-cited-with-note.md')}`)
shows the result; the pinned bytes are its exact prefix. `docs/research/` is outside the gate (§2).
For the all-QUOTE case, `check/prospective-Q2-A-cited-allquote.md` (SHA-256
`{sha('check/prospective-Q2-A-cited-allquote.md')}`) shows what the Run would write in place of the
adopted text; it is a reading aid, not a form.

## 9. Citation trial (scratch clones of the pin, `check/trial.py`, results `check/trial.json`)

The trial copies `/var/tmp/provisiond-manager/dr-e45e-check/citation-trial.py`: it applies comment
857's edits with each r100 form substituted for its span, plus the `PRV-10` form (`check/F-QUOTE.txt`,
or `check/F-QUOTE-Q5.txt` under Q5-QUOTE), to a fresh clone at the pin, then runs
`python3 tools/check_citations.py`. The lake index was copied read only (SHA-256
`{trial["index_sha256"]}`, built at `{trial["index_build_commit"]}`); `tools/formal` and the gate are
byte-equal to that build at the pin.

| Trial | What is applied | Exit | Markdown compared | Lean QUOTED compared | Unquoted (none new) |
|---|---|---|---|---|---|''')
desc = {'T0': 'the pin as is', 'T-ASIS': 'adopted text as is (Q4 row split), F-QUOTE', 'T-KEEP': 'adopted text, Q4 joined (Q4-KEEP), F-QUOTE',
        'T-ALL': 'all seven QUOTE forms, F-QUOTE-Q5'}
for q in ['Q1', 'Q2', 'Q3', 'Q4', 'Q5', 'Q6', 'Q7']:
    desc[f'T-{q}'] = f'{q}-QUOTE alone, others adopted, Q4 joined' if q != 'Q4' else 'Q4-QUOTE alone, others adopted'
rows = []
for t in ['T0', 'T-ASIS', 'T-KEEP', 'T-Q1', 'T-Q2', 'T-Q3', 'T-Q4', 'T-Q5', 'T-Q6', 'T-Q7', 'T-ALL']:
    ex, md, lq, un = trial_stats(t)
    rows.append(f'| {t} | {desc[t]} | {ex} | {md} | {lq} | {un} |')
assert trial['T_ASIS_reproduces_dr_e45e_T2'] is True
nlines = []
for q in ['Q1', 'Q2', 'Q3', 'Q4', 'Q5', 'Q6', 'Q7']:
    nlines.append(f'N-{q} {(C / f"trial-N-{q}.exit").read_text().strip()}')
out.append('\n'.join(rows) + f'''

T-ASIS's diff is byte-identical to the launch manager's trial T2 (`dr-e45e-check/trial.json`), so the
trial applies the adopted text as the Run would. Negative controls (T-ALL with the third word of one
question's first quotation replaced by WRONGWORD): {", ".join(nlines)}; each fails with that question's corrupted
quotation as the one unverifiable attribution (N-Q2 and N-Q3 also with one Lean docstring quote found nowhere). Every QUOTE form is in the gate's
reach. KEEP is T-ASIS, plus the Q4 join (T-KEEP). From T0 to T-ASIS one Markdown and one Lean
comparison are lost; the adopted text drops `PRV-10`'s "the account is configured to allow ordering"
from step 3 (r86b opus.md:152) and the line-317 docstring's `API-7` quotation (Q2). The manager did
not trace each count to its sentence.

## 10. Your answer

For each of Q1, Q2, Q3, Q4, Q5, Q6, Q7 and Q-ROUTE (and any Q8 you open):

1. Final pick: one label (Qn-QUOTE, Qn-KEEP, Q4-ASIS, R-RUN, R-NOTE) or a complete exact ALT printed in
   full with its exact span.
2. ACCEPT or CANNOT ACCEPT for every printed option, separately from the pick.
3. Whether the picked form is wording-only: no behavior, requirement or check-strength change (rule 3).
4. The strongest reason, with file:line at the pin.
5. Any brief error you verified, and whether it changes the question's premise (rule 6).

Also say, in one line, whether comment 857 stays unedited under your Q-ROUTE pick.
''')

text = '\n'.join(out)
(P / 'brief.md').write_text(text)
print(len(text.encode()), hashlib.sha256(text.encode()).hexdigest())
