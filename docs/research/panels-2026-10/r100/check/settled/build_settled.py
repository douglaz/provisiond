#!/usr/bin/env python3
"""Build settled-r100.md and the Run instruction quote block from the r100 record (Opus manager, 2026-11-03)."""
import hashlib, subprocess
from pathlib import Path

P = Path('/var/tmp/provisiond-panel-r100')
S = P / 'check' / 'settled'
PIN = '2cb8e1189310ae096e598bac798df3437be59500'
REPO = Path.home() / 'projects' / 'provisiond-spec'
Q2A = 'docs/research/panels-2026-10/r86/r86b/Q2-A-cited.md'

def sha(b): return hashlib.sha256(b).hexdigest()
def fsha(p): return sha(Path(p).read_bytes())
def span(name): return (P / name).read_text()[:-1]

assert (P / 'PIN').read_text().strip() == PIN
q2a = subprocess.run(['git', '-C', str(REPO), 'show', f'{PIN}:{Q2A}'], capture_output=True, check=True).stdout
assert q2a == (P / 'evidence' / 'Q2-A-cited.md').read_bytes()
assert sha(q2a) == 'd611bbae87294a0fc0087c567fa82aa1404cd0c5a54abe394b5327488ec51ea2'
q2at = q2a.decode()
c857 = (P / 'evidence' / 'pv-e45e-comment-857.md').read_text()
r98 = Path('/var/tmp/provisiond-panel-r98/brief.md').read_text().split('\n')
R98_201_203 = '\n'.join(r98[200:203])
assert R98_201_203.startswith('- **Q1-RUN (a).**') and R98_201_203.endswith('No preparation commit.')
assert fsha('/var/tmp/provisiond-panel-r98/brief.md') == '8d3fb791555ecad30f7b390c069916923e3b992773341c23dbf1a31d498e4995'
FQ = (P / 'check' / 'F-QUOTE.txt').read_text()
assert fsha(P / 'check' / 'F-QUOTE.txt') == '2393f71eef02a593e37ca93d6dc4bd441bfc928a0bbeff4e9939e43a34bf2323'
APP = (P / 'R-NOTE-append.md').read_text()

# Q: (settled file, r100 or r100b, Q2-A-cited lines, comment 857 lines, where it lands at the pin, changes bytes)
Q = {
 'Q1': ('Q1-ALT.txt', 'r100b', (62, 63), (88, 89), '`03-operation-lifecycle.md`: the OPS-23 insert written after lines 2076–2079', True),
 'Q2': ('Q2-QUOTE.txt', 'r100', (131, 134), (160, 163), '`tools/formal/Provisiond/Admission.lean`: replaces the docstring text at lines 317–319', True),
 'Q3': ('Q3-QUOTE.txt', 'r100', (144, 146), (173, 175), '`tools/formal/Provisiond/Admission.lean`: replaces words on lines 1181–1182', True),
 'Q4': ('Q4-KEEP.txt', 'r100', (69, 70), (95, 96), '`05-persistence.md`: inside the one-line table row at line 523', True),
 'Q5': ('Q5-KEEP.txt', 'r100', (39, 43), (65, 69), '`03-operation-lifecycle.md`: OPS-43 step 3, lines 797–802', False),
 'Q6': ('Q6-QUOTE.txt', 'r100', (55, 56), (81, 82), '`03-operation-lifecycle.md`: the last clause of OPS-43 step 5, replacing lines 804–805', True),
 'Q7': ('Q7-KEEP.txt', 'r100', (101, 101), (130, 130), '`10-conformance-checklist.md`: the CNF-19 block line', False),
}
qlines = q2at.split('\n'); clines = c857.split('\n')
for q, (f, rnd, ql, cl, land, changes) in Q.items():
    old = span(f'{q}-OLD.txt')
    assert q2at.count(old) == 1 and c857.count(old) == 1, q
    assert '\n'.join(qlines[ql[0]-1:ql[1]]).endswith(old.split('\n')[-1]) or old.split('\n')[-1] in '\n'.join(qlines[ql[0]-1:ql[1]]), q
    assert old.split('\n')[0] in '\n'.join(qlines[ql[0]-1:ql[1]]) and old.split('\n')[0] in '\n'.join(clines[cl[0]-1:cl[1]]), q
    if changes:
        new = span(f)
        assert new != old, q
for q in ('Q5', 'Q7'):
    assert span(Q[q][0]).startswith('KEEP: no byte changes.')

HASH = {
 'Q1-ALT.txt': '97035ff0c6bbfae893123db51d53b03bad68e512a47415554d3cf5350fe43816',
 'Q2-QUOTE.txt': 'd82170607ffaccca68bf057c8f6f3117caa7fcc02d65599ad19f9e02502c83f6',
 'Q3-QUOTE.txt': '83bc80552410d2e6292c1a0d1cf702e82d635878ce0858b089e43ee68cf8fc09',
 'Q4-KEEP.txt': '5db74cb1fc638bf9250e7c8f2b733aaec85b88f905d22c9f9375aa091e4b1c94',
 'Q5-KEEP.txt': 'a873afce596157e55a6d03068aad8904c855002cbe720e32e3139368fa05f27e',
 'Q6-QUOTE.txt': 'ad77bbdd4095faa1336db546c6058f1ef58ee3239607af89299974aa0b4bf9d5',
 'Q7-KEEP.txt': 'd59a4fadf509e0272ffa120048fdba452c4609f886513e973b7ef55156c981db',
 'R-NOTE.txt': 'd50de4177d3aa9c689d1bc4e6f1ff7cd6fbb08831ae8fd5702484ce3efff43a7',
 'R-RUN.txt': '606973ea02527fc50d1ae9be52e073d69ff74c2009c455cd61a925e06c31a0dd',
 'R-NOTE-append.md': '40db5de25fb651fc30575c9850d4397f78d0b76213df023e372f572238b58af9',
}
for f, h in HASH.items():
    assert fsha(P / f) == h, f
q1q = (P / 'Q1-QUOTE.txt').read_bytes(); q1a = (P / 'Q1-ALT.txt').read_bytes()
diffs = [i for i in range(len(q1q)) if q1q[i] != q1a[i]]
assert len(q1q) == len(q1a) and diffs == [171] and q1q[171:172] == b'.' and q1a[171:172] == b';'
prosp = (P / 'check' / 'prospective-Q2-A-cited-with-note.md').read_bytes()
assert prosp == q2a + APP.encode() and sha(prosp) == '0e665520d8d83469799d5afc62ad735f506b26e23d9b61b66696e9a88ea7a7c1'
blob = subprocess.run(['git', 'hash-object', str(P / 'check' / 'prospective-Q2-A-cited-with-note.md')], capture_output=True, text=True, check=True).stdout.strip()

F4 = '````'
def fence(t): return f'{F4}text\n{t}\n{F4}\n'

# ---------- Run instruction quote block ----------
qb = []
qb.append('# pv-e45e Run instruction: verbatim quotations (Panels r98, r100 and r100b)\n')
qb.append(f'Every block below is exact bytes, shown between four-backtick fences. Pin `{PIN}`. The adopted text is `{Q2A}` (SHA-256 `{sha(q2a)}`) and pv-e45e comment 857, which is not edited.\n')
qb.append('## 1. Route decision r98 Q1-RUN (a), `/var/tmp/provisiond-panel-r98/brief.md:201-203`\n')
qb.append(fence(R98_201_203))
qb.append('## 2. Settled route r100b Q-ROUTE: R-NOTE (`R-NOTE.txt`, SHA-256 `' + HASH['R-NOTE.txt'] + '`)\n')
qb.append(fence(span('R-NOTE.txt')))
qb.append('R-NOTE begins "Exactly as R-RUN"; R-RUN is (`R-RUN.txt`, SHA-256 `' + HASH['R-RUN.txt'] + '`):\n')
qb.append(fence(span('R-RUN.txt')))
qb.append('## 3. The PRV-10 form (Q5 settled KEEP, so this is r100 `check/F-QUOTE.txt`, SHA-256 `2393f71eef02a593e37ca93d6dc4bd441bfc928a0bbeff4e9939e43a34bf2323`, its final LF is not part of the form. It replaces `02-provider-contract.md`\'s PRV-10 span that begins "The configuration half is `DOM-10`\'s gate" and ends "then the capability gate”.")\n')
qb.append(fence(FQ[:-1] if FQ.endswith('\n') else FQ))
qb.append('## 4. Settled forms whose bytes differ from the adopted text, each with the span it replaces\n')
qb.append('The Run writes each settled form in place of its adopted span wherever that span is written into the spec. Every adopted span occurs exactly once in Q2-A-cited.md and once in comment 857.\n')
for q in ('Q1', 'Q2', 'Q3', 'Q4', 'Q6'):
    f, rnd, ql, cl, land, _ = Q[q]
    lab = f[:-4]
    qb.append(f'### {q}: {lab} (settled 3–0 in {rnd}; SHA-256 `{HASH[f]}`) replaces Q2-A-cited.md:{ql[0]}-{ql[1]} (comment 857:{cl[0]}-{cl[1]}); lands in {land}\n')
    qb.append('Adopted span:\n'); qb.append(fence(span(f'{q}-OLD.txt')))
    qb.append(f'{lab}:\n'); qb.append(fence(span(f)))
qb.append('Q5 (Q2-A-cited.md:39-43) and Q7 (:101) settled KEEP: the Run writes them exactly as adopted.\n')
qb.append('## 5. The append to Q2-A-cited.md (whole `R-NOTE-append.md`, SHA-256 `' + HASH['R-NOTE-append.md'] + '`, ending with one LF)\n')
qb.append(fence(APP[:-1]))
QB = '\n'.join(qb)
(S / 'run-instruction-quotes.md').write_text(QB)
QBH = sha(QB.encode())

# ---------- settled-r100.md ----------
o = []
o.append('# Settled pv-e45e wording correction — Panel r100 (with consensus round r100b)\n')
o.append('Q1: Q1-ALT. Q2: Q2-QUOTE. Q3: Q3-QUOTE. Q4: Q4-KEEP. Q5: KEEP. Q6: Q6-QUOTE. Q7: KEEP. Q-ROUTE: R-NOTE with its append.\n')
o.append('How each settled. Q2–Q7 settled 3–0 in Panel r100 (`tally.md`). Q1 (r100: QUOTE, ALT, ALT) and Q-ROUTE (r100: R-NOTE, R-RUN, R-NOTE) split 2–1 and went to the one consensus round, r100b, where each settled 3–0: Q1 on Q1-ALT and Q-ROUTE on R-NOTE. In both rounds opus, astra and sol are the three present, substantive seats. Fable (usage-limit line) and grok (HTTP 402) are missing seats, not votes, so every settlement is 3–0 on the same exact form, compared by hash. Every reader judged its picks wording-only, with no verified blocking loss under notes rule 3, and said comment 857 stays unedited. No tally was voided under rule 6. No owner question remains. This file records the settlement only: no tracker, branch, commit or PR change occurred, and the Run has not been launched.\n')
o.append('r100b answers (all exit 0): opus.md 9849 B; astra.md (= astra.out) 4318 B; sol.md (= sol.out) 4897 B. Acceptance: opus ACCEPT Q1-ALT and Q1-QUOTE, CANNOT Q1-KEEP; astra and sol ACCEPT Q1-ALT only. Q-ROUTE: all three ACCEPT both R-NOTE and R-RUN; all three pick R-NOTE.\n')
o.append(f'Pin: `{PIN}` (master; checked 2026-11-03). Packets: r100 brief.md `9ae53cd973ac7575f2673906e5b6ca23e4245c74dfec1cdfaef567e7e4962e33`, notes.md `6add3e8790dbcb33d2e18b9a581e741fcfaa6465f01eadd2b706645de89f8e73`; r100b brief.md `89441b0a1c2c8f5f227405f179b2713a4313c7a402a8eadf72e67d6523c08306`, notes.md `e6881dd9995008b3e5e5bea71c7b458906045e351f56c518f99d7caf44f283ad`.\n')
o.append('Span convention: each `Qn-*.txt` and `R-*.txt` file ends with one LF that is not part of the span (`read_text()[:-1]`). `R-NOTE-append.md` is appended whole, including its final LF.\n')
o.append('## Forms\n')
o.append('| Q | Settled form | File | Bytes (file) | SHA-256 (file) | Bytes change? |\n|---|---|---|---|---|---|')
for q, (f, rnd, ql, cl, land, ch) in Q.items():
    o.append(f'| {q} | {f[:-4]} | `{f}` | {(P/f).stat().st_size} | `{HASH[f]}` | {"yes" if ch else "no"} |')
o.append(f'| Q-ROUTE | R-NOTE | `R-NOTE.txt` | {(P/"R-NOTE.txt").stat().st_size} | `{HASH["R-NOTE.txt"]}` | — |')
o.append(f'| (R-NOTE inherits) | R-RUN | `R-RUN.txt` | {(P/"R-RUN.txt").stat().st_size} | `{HASH["R-RUN.txt"]}` | — |')
o.append(f'| (R-NOTE append) | R-NOTE-append | `R-NOTE-append.md` | {(P/"R-NOTE-append.md").stat().st_size} | `{HASH["R-NOTE-append.md"]}` | — |')
o.append('| (PRV-10 form, Q5 KEEP) | F-QUOTE | `check/F-QUOTE.txt` | 1962 | `2393f71eef02a593e37ca93d6dc4bd441bfc928a0bbeff4e9939e43a34bf2323` | — |\n')
o.append('Adopted spans (OLD): ' + '; '.join(f'{q}-OLD `{fsha(P / (q + "-OLD.txt"))}`' for q in Q) + '.\n')
o.append('Q1-ALT is Q1-QUOTE (`03732e8fe458a0e015d2c630d243ea1737777ec2077e5a8641d91a641def2cfc`) with one byte changed: byte 172 (1-based; offset 171), the period ending line 2 becomes a semicolon. Q4-KEEP keeps the adopted words and joins the span\'s two lines into one, so its bytes differ from Q4-OLD. Q5-KEEP and Q7-KEEP change no bytes.\n')
for q, (f, rnd, ql, cl, land, ch) in Q.items():
    if ch:
        o.append(f'### {q}-OLD (Q2-A-cited.md:{ql[0]}-{ql[1]}, comment 857:{cl[0]}-{cl[1]})\n'); o.append(fence(span(f'{q}-OLD.txt')))
        o.append(f'### {f[:-4]}\n'); o.append(fence(span(f)))
    else:
        o.append(f'### {f[:-4]}\n'); o.append(fence(span(f)))
o.append('### R-NOTE (settled route)\n'); o.append(fence(span('R-NOTE.txt')))
o.append('### R-RUN (inherited by R-NOTE\'s "Exactly as R-RUN")\n'); o.append(fence(span('R-RUN.txt')))
o.append('### R-NOTE-append (whole file, shown between the fences; it ends with one LF)\n'); o.append(fence(APP[:-1]))
o.append('## Brief corrections folded in (verified at the pin)\n')
o.append('1. Q6 "a third copy" (r100 `brief.md:262`, `:818`). OPS-43 steps 1 and 8 (`03-operation-lifecycle.md:790`, `:819`) quote only the commitment half of OPS-11. OPS-11\'s exclusion sentence ("Where the create holds a resource-offer exclusion, it is freed under `STO-58`") occurs only at `03:249`, inside OPS-11 itself. Q6-QUOTE is therefore the first OPS-43 quotation of the exclusion half, not a third copy of an existing quotation. All three readers picked Q6-QUOTE; the question and both forms stand.')
o.append('2. §2 "scans docs/adr" (r100 `brief.md:70`). `tools/check_citations.py` checks quotations only in root `*.md` (`glob("*.md")`) and in Lean docstrings. It reads `docs/adr/*.md` only as sources (`adrs`, `tools/check_citations.py:644-645`; its docstring at :32-33 says "ADRs are sources, not QUOTED input"); it does not scan ADRs as quoted input. `docs/research/` is outside every gate, so no gate checks the append or the archive: verify them by the hashes here.')
o.append('3. R-NOTE "Exactly as R-RUN". R-RUN says "comment 857 and docs/research/panels-2026-10/r86/r86b/Q2-A-cited.md are not edited"; R-NOTE adds "in addition the Run appends exactly R-NOTE-append.md to … Q2-A-cited.md, all original bytes remaining an exact prefix". All three r100b readers resolve this the same way, and this package applies it: Q2-A-cited.md\'s original 8750 bytes are not changed and stay an exact prefix; the only change to that file is the exact append. Comment 857 is not edited at all. The settled R-NOTE bytes stay as settled (`d50de417…43a7`); this reading changes no form.\n')
o.append('Other reader claims checked at the pin, none changing a premise: (a) opus: the r99 precedent Reader C cited in r100 is the semicolon shape (`01-domain-model.md:575`); true, a correction of a reader claim, not a brief error. (b) opus: "before any provider mutation" also occurs at `03:870`, so the gate would not catch its removal from step 5; true, and Q1-QUOTE has the same limit. (c) Owner item 25 chose the dated archive note; true.\n')
o.append('## Exact locations at the pin\n')
o.append(f'- `{Q2A}` ({len(q2a)} bytes, {q2at.count(chr(10))} lines, SHA-256 `{sha(q2a)}`, git blob `e360b5928708c1261db086385c4615f81ae8fef8`, ends with "```" LF LF). Each OLD span occurs exactly once here and exactly once in comment 857 (`evidence/pv-e45e-comment-857.md`, SHA-256 `9fa9dba3f79b051bc5f09a8d3f6a5a8bf6a08ca308db0ec0ebd812fd8f5823e1`).')
for q, (f, rnd, ql, cl, land, ch) in Q.items():
    o.append(f'- {q}: Q2-A-cited.md:{ql[0]}-{ql[1]}, comment 857:{cl[0]}-{cl[1]}; {land}. {"Written as " + f[:-4] if ch else "Written exactly as adopted"}.')
o.append('')
o.append('## Route: R-NOTE as exact operations (in the pv-e45e Run, not in this turn)\n')
o.append('1. The pv-e45e Run instruction quotes verbatim every block in `check/settled/run-instruction-quotes.md` (SHA-256 `' + QBH + '`, reproduced in full below): r98 `brief.md:201-203`, R-NOTE and R-RUN, the PRV-10 form `check/F-QUOTE.txt`, the five settled forms whose bytes differ (Q1-ALT, Q2-QUOTE, Q3-QUOTE, Q4-KEEP, Q6-QUOTE) each with the Q2-A-cited.md span it replaces, and R-NOTE-append.md. No preparation commit.')
o.append('2. The Run writes the adopted text with each of those five forms in place of its span. Q5 and Q7 are written exactly as adopted. PRV-10\'s quotation is written as F-QUOTE.txt.')
o.append(f'3. `{Q2A}`: `f.write_text(f.read_text() + append)`, with `append` the whole `R-NOTE-append.md`. All 8750 original bytes remain an exact prefix. Because the file ends with "```" LF LF, one empty line precedes the new heading. Result: 9406 bytes, SHA-256 `0e665520d8d83469799d5afc62ad735f506b26e23d9b61b66696e9a88ea7a7c1`, git blob `{blob}` (= `check/prospective-Q2-A-cited-with-note.md`).')
o.append('4. **Comment 857 stays unedited.** No field of the pv-e45e row, no comment and no other bead changes. The r86 record (other than the append to Q2-A-cited.md) stays unchanged.')
o.append('5. Archive the reviewed r100 record, with r100b, at `docs/research/panels-2026-10/r100/`. The append\'s link `../../r100/notes.md` resolves to `docs/research/panels-2026-10/r100/notes.md`, so `notes.md` (SHA-256 `6add3e8790dbcb33d2e18b9a581e741fcfaa6465f01eadd2b706645de89f8e73`) must be in the commit. Copy from `/var/tmp/provisiond-panel-r100/`, paths kept:')
o.append('   - top level: `notes.md`, `notes.sha256`, `brief.md`, `brief.sha256`, `PIN`, `STATE.md`, `packet-manifest.json`, `forms.sha256`, every `Q1-*.txt` … `Q7-*.txt` (including `Q1-ALT.txt`), `R-NOTE.txt`, `R-RUN.txt`, `R-NOTE-append.md`, the answers `fable.md`, `opus.md`, `astra.md`, `sol.md`, and `tally.md`, `settled-r100.md`, `settled-r100.md.sha256`;')
o.append('   - `evidence/pv-e45e-comment-857.md`, `evidence/Q2-A-cited.md`;')
o.append('   - `check/`: `build.py`, `build.json`, `build.log`, `build_brief.py`, `sweep.txt`, `F-QUOTE.txt`, `F-QUOTE-Q5.txt`, `astra-Q1-ALT.txt`, `sol-Q1-ALT.txt`, `forms.sha256.pre-note-reword`, `prospective-*.md`, `trial.py`, `trial.json`, `trial-*.diff`, `trial-*.log`;')
o.append('   - `check/settled/`: `build_settled.py`, `run-instruction-quotes.md`, `trial_settled.py`, `trial.json`, `trial-*-SETTLED.diff`, `trial-*-SETTLED.log`;')
o.append('   - `r100b/`: `notes.md`, `notes.sha256`, `brief.md`, `brief.sha256`, `PIN`, `STATE.md`, `packet-manifest.json`, `fable.md`, `opus.md`, `astra.md`, `sol.md`, and from `r100b/check/`: `build.py`, `build.out`, `labels.json`, `trial_b.py`, `trial.json`, `trial-*.diff`, `trial-*.log`.')
o.append('   Leave out: `prompts/`, `tmp/`, the reader home folders (`fable/`, `opus/`, `astra/`, `sol/`), every `*.err`, `*.out`, `*.exit`, `*.stdout`, `launch.sh`, `run-*.sh`, `*-systemctl-show.txt`, `quota*`, `grok-preflight*`, `run-grok-preflight.sh`, `launch-time.txt`, `check/main-status-after-wal-move.txt`, `check/repo/` and any clone, and every manager-state file. The two `STATE.md` files are launch snapshots; `tally.md` and this file supersede them. Before committing, grep the copied tree for the Robot server number and any IP; at 16:58Z the record held neither.')
o.append('\nNo branch or tracker edit occurs in this panel turn.\n')
o.append('## Combined citation trial at the pin (`check/settled/`)\n')
o.append(f'`trial_settled.py` (SHA-256 `{fsha(S / "trial_settled.py")}`) applies 19 edits to a fresh clone at the pin (lake index copied in; 37 formal inputs equal to the index build) and runs `python3 tools/check_citations.py`. Results in `trial.json` (`{fsha(S / "trial.json")}`).\n')
o.append(f'- **T-SETTLED**: the combined settled forms (Q1-ALT, Q2-QUOTE, Q3-QUOTE, Q4-KEEP, Q6-QUOTE; Q5 and Q7 as adopted; PRV-10 = F-QUOTE.txt). Exit **{(S / "trial-T-SETTLED.exit").read_text().strip()}**. "Markdown quoted attributions: 369 compared; 6, none new against baseline 6"; "Lean docstring quotes: 1052; 146 compared under QUOTED; EXISTS finds 0 absent"; unquoted attributions 22, none new. Diff SHA-256 `{fsha(S / "trial-T-SETTLED.diff")}`, byte-identical to `r100b/check/trial-T-S-Q1ALT.diff`.')
o.append(f'- **N-SETTLED** (negative control): the same, with one word in each quoted phrase of Q1-ALT, Q2-QUOTE, Q3-QUOTE and Q6-QUOTE replaced by `wrongword`. Exit **{(S / "trial-N-SETTLED.exit").read_text().strip()}**: "FAIL: 4 unverifiable quoted attribution(s) and 2 Lean docstring quote(s) found nowhere" (OPS-11 in 03 for Q6, OPS-43 in 03 for Q1, API-7 twice in Admission.lean for Q2 and Q3). Diff SHA-256 `{fsha(S / "trial-N-SETTLED.diff")}`.\n')
o.append('## Check the apply turn must repeat\n')
o.append('1. Confirm master is still the pin, or re-resolve every location and hash above. Confirm each file in the Forms table by its SHA-256.')
o.append('2. Re-run `python3 -I /var/tmp/provisiond-panel-r100/check/settled/trial_settled.py`; T-SETTLED must exit 0 with "369 compared" and diff SHA-256 `63fcfd1cef2644c609fc81b2348af1a5a313d6c2060c846c5f1d2570429f40d9`, and N-SETTLED must exit 1 with the four attributions and two Lean quotes above. Run this before copying `check/settled/` into the archive.')
o.append(f'3. In the Run\'s worktree, confirm `{Q2A}` has SHA-256 `0e665520d8d83469799d5afc62ad735f506b26e23d9b61b66696e9a88ea7a7c1` and its first 8750 bytes equal the pin\'s; comment 857 is unchanged.')
o.append('4. The full gate, unpiped: `bash tools/check-all.sh > <log> 2>&1; echo $?`; it must print 0 and "All gates passed."\n')
o.append('## The Run instruction quote block (`check/settled/run-instruction-quotes.md`, exact file contents)\n')
o.append('`````markdown\n' + QB + '`````\n')
out = '\n'.join(o)
(P / 'settled-r100.md').write_text(out)
h = sha(out.encode())
(P / 'settled-r100.md.sha256').write_text(f'{h}  settled-r100.md\n')
print('settled-r100.md', h, len(out.encode()))
print('run-instruction-quotes.md', QBH, len(QB.encode()))
