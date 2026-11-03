# Settled pv-e45e wording correction — Panel r100 (with consensus round r100b)

Q1: Q1-ALT. Q2: Q2-QUOTE. Q3: Q3-QUOTE. Q4: Q4-KEEP. Q5: KEEP. Q6: Q6-QUOTE. Q7: KEEP. Q-ROUTE: R-NOTE with its append.

How each settled. Q2–Q7 settled 3–0 in Panel r100 (`tally.md`). Q1 (r100: QUOTE, ALT, ALT) and Q-ROUTE (r100: R-NOTE, R-RUN, R-NOTE) split 2–1 and went to the one consensus round, r100b, where each settled 3–0: Q1 on Q1-ALT and Q-ROUTE on R-NOTE. In both rounds opus, astra and sol are the three present, substantive seats. Fable (usage-limit line) and grok (HTTP 402) are missing seats, not votes, so every settlement is 3–0 on the same exact form, compared by hash. Every reader judged its picks wording-only, with no verified blocking loss under notes rule 3, and said comment 857 stays unedited. No tally was voided under rule 6. No owner question remains. This file records the settlement only: no tracker, branch, commit or PR change occurred, and the Run has not been launched.

r100b answers (all exit 0): opus.md 9849 B; astra.md (= astra.out) 4318 B; sol.md (= sol.out) 4897 B. Acceptance: opus ACCEPT Q1-ALT and Q1-QUOTE, CANNOT Q1-KEEP; astra and sol ACCEPT Q1-ALT only. Q-ROUTE: all three ACCEPT both R-NOTE and R-RUN; all three pick R-NOTE.

Pin: `2cb8e1189310ae096e598bac798df3437be59500` (master; checked 2026-11-03). Packets: r100 brief.md `9ae53cd973ac7575f2673906e5b6ca23e4245c74dfec1cdfaef567e7e4962e33`, notes.md `6add3e8790dbcb33d2e18b9a581e741fcfaa6465f01eadd2b706645de89f8e73`; r100b brief.md `89441b0a1c2c8f5f227405f179b2713a4313c7a402a8eadf72e67d6523c08306`, notes.md `e6881dd9995008b3e5e5bea71c7b458906045e351f56c518f99d7caf44f283ad`.

Span convention: each `Qn-*.txt` and `R-*.txt` file ends with one LF that is not part of the span (`read_text()[:-1]`). `R-NOTE-append.md` is appended whole, including its final LF.

## Forms

| Q | Settled form | File | Bytes (file) | SHA-256 (file) | Bytes change? |
|---|---|---|---|---|---|
| Q1 | Q1-ALT | `Q1-ALT.txt` | 397 | `97035ff0c6bbfae893123db51d53b03bad68e512a47415554d3cf5350fe43816` | yes |
| Q2 | Q2-QUOTE | `Q2-QUOTE.txt` | 494 | `d82170607ffaccca68bf057c8f6f3117caa7fcc02d65599ad19f9e02502c83f6` | yes |
| Q3 | Q3-QUOTE | `Q3-QUOTE.txt` | 354 | `83bc80552410d2e6292c1a0d1cf702e82d635878ce0858b089e43ee68cf8fc09` | yes |
| Q4 | Q4-KEEP | `Q4-KEEP.txt` | 180 | `5db74cb1fc638bf9250e7c8f2b733aaec85b88f905d22c9f9375aa091e4b1c94` | yes |
| Q5 | Q5-KEEP | `Q5-KEEP.txt` | 190 | `a873afce596157e55a6d03068aad8904c855002cbe720e32e3139368fa05f27e` | no |
| Q6 | Q6-QUOTE | `Q6-QUOTE.txt` | 258 | `ad77bbdd4095faa1336db546c6058f1ef58ee3239607af89299974aa0b4bf9d5` | yes |
| Q7 | Q7-KEEP | `Q7-KEEP.txt` | 186 | `d59a4fadf509e0272ffa120048fdba452c4609f886513e973b7ef55156c981db` | no |
| Q-ROUTE | R-NOTE | `R-NOTE.txt` | 257 | `d50de4177d3aa9c689d1bc4e6f1ff7cd6fbb08831ae8fd5702484ce3efff43a7` | — |
| (R-NOTE inherits) | R-RUN | `R-RUN.txt` | 590 | `606973ea02527fc50d1ae9be52e073d69ff74c2009c455cd61a925e06c31a0dd` | — |
| (R-NOTE append) | R-NOTE-append | `R-NOTE-append.md` | 656 | `40db5de25fb651fc30575c9850d4397f78d0b76213df023e372f572238b58af9` | — |
| (PRV-10 form, Q5 KEEP) | F-QUOTE | `check/F-QUOTE.txt` | 1962 | `2393f71eef02a593e37ca93d6dc4bd441bfc928a0bbeff4e9939e43a34bf2323` | — |

Adopted spans (OLD): Q1-OLD `91b89db887aa220e7afbd11a2eff527a2441d0860109b7cfd59394777d5615c2`; Q2-OLD `4524048925d049ea5220035ce9d259fa3681fe2ae0a72c0547eefa11a2a65ce8`; Q3-OLD `4bd4350a8282428dd293b49b1e51306bd5ca23bc0c034d77b3ee7c7d9e916912`; Q4-OLD `434ff18ea37383aff8146cdda770b5d1040115541249ab9ce9e80b316b13252d`; Q5-OLD `eccfa79b55784a9cfa092ba606ea67776db58a91bc7cdb73d1ff5d8571d6551b`; Q6-OLD `32874589b5372b0b0f2799e46aa243ad4ba3ef2a5db1ea61c12d6a1c5f55d95c`; Q7-OLD `e8c33b627550be3699e9de7b95f7390ed04c7174ed55caffc9ef77312c2db5dd`.

Q1-ALT is Q1-QUOTE (`03732e8fe458a0e015d2c630d243ea1737777ec2077e5a8641d91a641def2cfc`) with one byte changed: byte 172 (1-based; offset 171), the period ending line 2 becomes a semicolon. Q4-KEEP keeps the adopted words and joins the span's two lines into one, so its bytes differ from Q4-OLD. Q5-KEEP and Q7-KEEP change no bytes.

### Q1-OLD (Q2-A-cited.md:62-63, comment 857:88-89)

````text
The offer-kind consistency check at OPS-43 step 5 uses the same exception: it runs on
step 4's current List offers result, after that read and before any provider mutation.
````

### Q1-ALT

````text
The offer-kind consistency check at OPS-43 step 5 uses the same exception: it runs on
step 4's current List offers result, after that read and before any provider mutation;
`OPS-43` says "If present but its kind differs from request_summary's machine_kind, settle
failed with invalid_request" and "before any provider mutation", and its step 4 says "obtain
the current driver List offers result".
````

### Q2-OLD (Q2-A-cited.md:131-134, comment 857:160-163)

````text
`orderingCapabilityGuard` (`API-7`, 2026-10-22, `pv-p3k`; step 5d reworded 2026-10-30,
`pv-e45e`): step 5d gates a create on the ordering capability selected by the named offer's kind
in the stored listing, and takes no gate for an offer absent from it. Off, a create without that
declaration reaches the purchase tail.
````

### Q2-QUOTE

````text
`orderingCapabilityGuard` (`API-7`, 2026-10-22, `pv-p3k`; step 5d reworded 2026-10-30,
`pv-e45e`): step 5d gates a create on the ordering capability selected by the named offer's kind
in the stored listing, and takes no gate for an offer absent from it; `API-7` says "If the named
offer is present, take its kind and gate on DOM-10's matching ordering capability" and "If the
offer is absent, run no ordering-capability check". Off, a create without that declaration
reaches the purchase tail.
````

### Q3-OLD (Q2-A-cited.md:144-146, comment 857:173-175)

````text
whether the account declares the ordering capability selected by the named offer's kind in the
stored listing; for an offer absent from that listing step 5d takes no gate and the Boolean is
supplied `true`. Offer-kind selection and descriptor construction are outside this model.
````

### Q3-QUOTE

````text
whether the account declares the ordering capability selected by the named offer's kind in the
stored listing; for an offer absent from that listing step 5d takes no gate and the Boolean is
supplied `true` (`API-7` says "If the offer is absent, run no ordering-capability check").
Offer-kind selection and descriptor construction are outside this model.
````

### Q4-OLD (Q2-A-cited.md:69-70, comment 857:95-96)

````text
the **offer snapshot** (`offer_id`, `machine_kind` (`virtual` or `bare_metal`, copied from the
named offer at admission under API-7), the offer's `install_strategies` as accepted,
````

### Q4-KEEP

````text
the **offer snapshot** (`offer_id`, `machine_kind` (`virtual` or `bare_metal`, copied from the named offer at admission under API-7), the offer's `install_strategies` as accepted,
````

### Q5-KEEP

````text
KEEP: no byte changes. The Q2-A-cited.md:39-43 span (comment 857:65-69) stays exactly as adopted; the Run writes it as Q2-A-cited.md has it, at pin 2cb8e1189310ae096e598bac798df3437be59500.
````

### Q6-OLD (Q2-A-cited.md:55-56, comment 857:81-82)

````text
the same existing
   pre-step-9 settlement releases the commitment and any resource-offer exclusion.
````

### Q6-QUOTE

````text
the same existing
   pre-step-9 settlement releases the commitment and any resource-offer exclusion; `OPS-11`
   says "The commitment is released in full under `LDG-32`" and "Where the create holds a
   resource-offer exclusion, it is freed under `STO-58`".
````

### Q7-KEEP

````text
KEEP: no byte changes. The Q2-A-cited.md:101 span (comment 857:130) stays exactly as adopted; the Run writes it as Q2-A-cited.md has it, at pin 2cb8e1189310ae096e598bac798df3437be59500.
````

### R-NOTE (settled route)

````text
Exactly as R-RUN, and in addition the Run appends exactly R-NOTE-append.md to docs/research/panels-2026-10/r86/r86b/Q2-A-cited.md, all original bytes remaining an exact prefix. Comment 857 is not edited. No branch or tracker edit occurs in this panel turn.
````

### R-RUN (inherited by R-NOTE's "Exactly as R-RUN")

````text
No preparation commit; comment 857 and docs/research/panels-2026-10/r86/r86b/Q2-A-cited.md are not edited. The pv-e45e Run instruction quotes verbatim /var/tmp/provisiond-panel-r98/brief.md:201–203, the PRV-10 form (r100 check/F-QUOTE.txt, or check/F-QUOTE-Q5.txt if Q5 settles on Q5-QUOTE), and each settled r100 form whose bytes differ from the adopted text, each with the Q2-A-cited.md span it replaces; the Run writes those forms in place of those spans and archives the reviewed r100 record at docs/research/panels-2026-10/r100/. No branch or tracker edit occurs in this panel turn.
````

### R-NOTE-append (whole file, shown between the fences; it ends with one LF)

````text
## Wording correction — 2026-11-03 (Panel r100)

The text above is retained as the historical form approved in owner item 17; its original
bytes remain unchanged. Under the owner's 2026-10-28 wording rule (“For such wording
questions, try to solve by getting a consensus of the panel”), the pv-e45e Run writes the
exact replacements selected in the panel record below in place of the spans they replace.
Comment 857 is not edited. This note grants no independent authority to change a
requirement; any substantive unresolved conflict returns to the owner.

Source pin: `2cb8e1189310ae096e598bac798df3437be59500`.
Panel record: `../../r100/notes.md`.
````

## Brief corrections folded in (verified at the pin)

1. Q6 "a third copy" (r100 `brief.md:262`, `:818`). OPS-43 steps 1 and 8 (`03-operation-lifecycle.md:790`, `:819`) quote only the commitment half of OPS-11. OPS-11's exclusion sentence ("Where the create holds a resource-offer exclusion, it is freed under `STO-58`") occurs only at `03:249`, inside OPS-11 itself. Q6-QUOTE is therefore the first OPS-43 quotation of the exclusion half, not a third copy of an existing quotation. All three readers picked Q6-QUOTE; the question and both forms stand.
2. §2 "scans docs/adr" (r100 `brief.md:70`). `tools/check_citations.py` checks quotations only in root `*.md` (`glob("*.md")`) and in Lean docstrings. It reads `docs/adr/*.md` only as sources (`adrs`, `tools/check_citations.py:644-645`; its docstring at :32-33 says "ADRs are sources, not QUOTED input"); it does not scan ADRs as quoted input. `docs/research/` is outside every gate, so no gate checks the append or the archive: verify them by the hashes here.
3. R-NOTE "Exactly as R-RUN". R-RUN says "comment 857 and docs/research/panels-2026-10/r86/r86b/Q2-A-cited.md are not edited"; R-NOTE adds "in addition the Run appends exactly R-NOTE-append.md to … Q2-A-cited.md, all original bytes remaining an exact prefix". All three r100b readers resolve this the same way, and this package applies it: Q2-A-cited.md's original 8750 bytes are not changed and stay an exact prefix; the only change to that file is the exact append. Comment 857 is not edited at all. The settled R-NOTE bytes stay as settled (`d50de417…43a7`); this reading changes no form.

Other reader claims checked at the pin, none changing a premise: (a) opus: the r99 precedent Reader C cited in r100 is the semicolon shape (`01-domain-model.md:575`); true, a correction of a reader claim, not a brief error. (b) opus: "before any provider mutation" also occurs at `03:870`, so the gate would not catch its removal from step 5; true, and Q1-QUOTE has the same limit. (c) Owner item 25 chose the dated archive note; true.

## Exact locations at the pin

- `docs/research/panels-2026-10/r86/r86b/Q2-A-cited.md` (8750 bytes, 159 lines, SHA-256 `d611bbae87294a0fc0087c567fa82aa1404cd0c5a54abe394b5327488ec51ea2`, git blob `e360b5928708c1261db086385c4615f81ae8fef8`, ends with "```" LF LF). Each OLD span occurs exactly once here and exactly once in comment 857 (`evidence/pv-e45e-comment-857.md`, SHA-256 `9fa9dba3f79b051bc5f09a8d3f6a5a8bf6a08ca308db0ec0ebd812fd8f5823e1`).
- Q1: Q2-A-cited.md:62-63, comment 857:88-89; `03-operation-lifecycle.md`: the OPS-23 insert written after lines 2076–2079. Written as Q1-ALT.
- Q2: Q2-A-cited.md:131-134, comment 857:160-163; `tools/formal/Provisiond/Admission.lean`: replaces the docstring text at lines 317–319. Written as Q2-QUOTE.
- Q3: Q2-A-cited.md:144-146, comment 857:173-175; `tools/formal/Provisiond/Admission.lean`: replaces words on lines 1181–1182. Written as Q3-QUOTE.
- Q4: Q2-A-cited.md:69-70, comment 857:95-96; `05-persistence.md`: inside the one-line table row at line 523. Written as Q4-KEEP.
- Q5: Q2-A-cited.md:39-43, comment 857:65-69; `03-operation-lifecycle.md`: OPS-43 step 3, lines 797–802. Written exactly as adopted.
- Q6: Q2-A-cited.md:55-56, comment 857:81-82; `03-operation-lifecycle.md`: the last clause of OPS-43 step 5, replacing lines 804–805. Written as Q6-QUOTE.
- Q7: Q2-A-cited.md:101-101, comment 857:130-130; `10-conformance-checklist.md`: the CNF-19 block line. Written exactly as adopted.

## Route: R-NOTE as exact operations (in the pv-e45e Run, not in this turn)

1. The pv-e45e Run instruction quotes verbatim every block in `check/settled/run-instruction-quotes.md` (SHA-256 `f17f3fb52142fee521027aed6a96eee2dae9c061eeb0aff5f46aea232eff1d8d`, reproduced in full below): r98 `brief.md:201-203`, R-NOTE and R-RUN, the PRV-10 form `check/F-QUOTE.txt`, the five settled forms whose bytes differ (Q1-ALT, Q2-QUOTE, Q3-QUOTE, Q4-KEEP, Q6-QUOTE) each with the Q2-A-cited.md span it replaces, and R-NOTE-append.md. No preparation commit.
2. The Run writes the adopted text with each of those five forms in place of its span. Q5 and Q7 are written exactly as adopted. PRV-10's quotation is written as F-QUOTE.txt.
3. `docs/research/panels-2026-10/r86/r86b/Q2-A-cited.md`: `f.write_text(f.read_text() + append)`, with `append` the whole `R-NOTE-append.md`. All 8750 original bytes remain an exact prefix. Because the file ends with "```" LF LF, one empty line precedes the new heading. Result: 9406 bytes, SHA-256 `0e665520d8d83469799d5afc62ad735f506b26e23d9b61b66696e9a88ea7a7c1`, git blob `e09f2a02a3d6e73c065dc098495a4a38a6750937` (= `check/prospective-Q2-A-cited-with-note.md`).
4. **Comment 857 stays unedited.** No field of the pv-e45e row, no comment and no other bead changes. The r86 record (other than the append to Q2-A-cited.md) stays unchanged.
5. Archive the reviewed r100 record, with r100b, at `docs/research/panels-2026-10/r100/`. The append's link `../../r100/notes.md` resolves to `docs/research/panels-2026-10/r100/notes.md`, so `notes.md` (SHA-256 `6add3e8790dbcb33d2e18b9a581e741fcfaa6465f01eadd2b706645de89f8e73`) must be in the commit. Copy from `/var/tmp/provisiond-panel-r100/`, paths kept:
   - top level: `notes.md`, `notes.sha256`, `brief.md`, `brief.sha256`, `PIN`, `STATE.md`, `packet-manifest.json`, `forms.sha256`, every `Q1-*.txt` … `Q7-*.txt` (including `Q1-ALT.txt`), `R-NOTE.txt`, `R-RUN.txt`, `R-NOTE-append.md`, the answers `fable.md`, `opus.md`, `astra.md`, `sol.md`, and `tally.md`, `settled-r100.md`, `settled-r100.md.sha256`;
   - `evidence/pv-e45e-comment-857.md`, `evidence/Q2-A-cited.md`;
   - `check/`: `build.py`, `build.json`, `build.log`, `build_brief.py`, `sweep.txt`, `F-QUOTE.txt`, `F-QUOTE-Q5.txt`, `astra-Q1-ALT.txt`, `sol-Q1-ALT.txt`, `forms.sha256.pre-note-reword`, `prospective-*.md`, `trial.py`, `trial.json`, `trial-*.diff`, `trial-*.log`;
   - `check/settled/`: `build_settled.py`, `run-instruction-quotes.md`, `trial_settled.py`, `trial.json`, `trial-*-SETTLED.diff`, `trial-*-SETTLED.log`;
   - `r100b/`: `notes.md`, `notes.sha256`, `brief.md`, `brief.sha256`, `PIN`, `STATE.md`, `packet-manifest.json`, `fable.md`, `opus.md`, `astra.md`, `sol.md`, and from `r100b/check/`: `build.py`, `build.out`, `labels.json`, `trial_b.py`, `trial.json`, `trial-*.diff`, `trial-*.log`.
   Leave out: `prompts/`, `tmp/`, the reader home folders (`fable/`, `opus/`, `astra/`, `sol/`), every `*.err`, `*.out`, `*.exit`, `*.stdout`, `launch.sh`, `run-*.sh`, `*-systemctl-show.txt`, `quota*`, `grok-preflight*`, `run-grok-preflight.sh`, `launch-time.txt`, `check/main-status-after-wal-move.txt`, `check/repo/` and any clone, and every manager-state file. The two `STATE.md` files are launch snapshots; `tally.md` and this file supersede them. Before committing, grep the copied tree for the Robot server number and any IP; at 16:58Z the record held neither.

No branch or tracker edit occurs in this panel turn.

## Combined citation trial at the pin (`check/settled/`)

`trial_settled.py` (SHA-256 `0796e045916e86b7d0a675e94c917e817402ba8766cfcec82b28012b93da3d43`) applies 19 edits to a fresh clone at the pin (lake index copied in; 37 formal inputs equal to the index build) and runs `python3 tools/check_citations.py`. Results in `trial.json` (`585afcd25c2d863a60f405e7fba472d38bd9d4aa6094f4fcf9f8f1f78d25f888`).

- **T-SETTLED**: the combined settled forms (Q1-ALT, Q2-QUOTE, Q3-QUOTE, Q4-KEEP, Q6-QUOTE; Q5 and Q7 as adopted; PRV-10 = F-QUOTE.txt). Exit **0**. "Markdown quoted attributions: 369 compared; 6, none new against baseline 6"; "Lean docstring quotes: 1052; 146 compared under QUOTED; EXISTS finds 0 absent"; unquoted attributions 22, none new. Diff SHA-256 `63fcfd1cef2644c609fc81b2348af1a5a313d6c2060c846c5f1d2570429f40d9`, byte-identical to `r100b/check/trial-T-S-Q1ALT.diff`.
- **N-SETTLED** (negative control): the same, with one word in each quoted phrase of Q1-ALT, Q2-QUOTE, Q3-QUOTE and Q6-QUOTE replaced by `wrongword`. Exit **1**: "FAIL: 4 unverifiable quoted attribution(s) and 2 Lean docstring quote(s) found nowhere" (OPS-11 in 03 for Q6, OPS-43 in 03 for Q1, API-7 twice in Admission.lean for Q2 and Q3). Diff SHA-256 `d165602df75773f521f046f1f56128fb2f023cd6d7634d597420ebb33d4c67a9`.

## Check the apply turn must repeat

1. Confirm master is still the pin, or re-resolve every location and hash above. Confirm each file in the Forms table by its SHA-256.
2. Re-run `python3 -I /var/tmp/provisiond-panel-r100/check/settled/trial_settled.py`; T-SETTLED must exit 0 with "369 compared" and diff SHA-256 `63fcfd1cef2644c609fc81b2348af1a5a313d6c2060c846c5f1d2570429f40d9`, and N-SETTLED must exit 1 with the four attributions and two Lean quotes above. Run this before copying `check/settled/` into the archive.
3. In the Run's worktree, confirm `docs/research/panels-2026-10/r86/r86b/Q2-A-cited.md` has SHA-256 `0e665520d8d83469799d5afc62ad735f506b26e23d9b61b66696e9a88ea7a7c1` and its first 8750 bytes equal the pin's; comment 857 is unchanged.
4. The full gate, unpiped: `bash tools/check-all.sh > <log> 2>&1; echo $?`; it must print 0 and "All gates passed."

## The Run instruction quote block (`check/settled/run-instruction-quotes.md`, exact file contents)

`````markdown
# pv-e45e Run instruction: verbatim quotations (Panels r98, r100 and r100b)

Every block below is exact bytes, shown between four-backtick fences. Pin `2cb8e1189310ae096e598bac798df3437be59500`. The adopted text is `docs/research/panels-2026-10/r86/r86b/Q2-A-cited.md` (SHA-256 `d611bbae87294a0fc0087c567fa82aa1404cd0c5a54abe394b5327488ec51ea2`) and pv-e45e comment 857, which is not edited.

## 1. Route decision r98 Q1-RUN (a), `/var/tmp/provisiond-panel-r98/brief.md:201-203`

````text
- **Q1-RUN (a).** Comment 857 is not edited. The pv-e45e Run also updates `PRV-10`'s quotation to the
  new text, as mechanical follow-through on the brief's step rewrites, and its instruction carries the
  Q2 form verbatim. No preparation commit.
````

## 2. Settled route r100b Q-ROUTE: R-NOTE (`R-NOTE.txt`, SHA-256 `d50de4177d3aa9c689d1bc4e6f1ff7cd6fbb08831ae8fd5702484ce3efff43a7`)

````text
Exactly as R-RUN, and in addition the Run appends exactly R-NOTE-append.md to docs/research/panels-2026-10/r86/r86b/Q2-A-cited.md, all original bytes remaining an exact prefix. Comment 857 is not edited. No branch or tracker edit occurs in this panel turn.
````

R-NOTE begins "Exactly as R-RUN"; R-RUN is (`R-RUN.txt`, SHA-256 `606973ea02527fc50d1ae9be52e073d69ff74c2009c455cd61a925e06c31a0dd`):

````text
No preparation commit; comment 857 and docs/research/panels-2026-10/r86/r86b/Q2-A-cited.md are not edited. The pv-e45e Run instruction quotes verbatim /var/tmp/provisiond-panel-r98/brief.md:201–203, the PRV-10 form (r100 check/F-QUOTE.txt, or check/F-QUOTE-Q5.txt if Q5 settles on Q5-QUOTE), and each settled r100 form whose bytes differ from the adopted text, each with the Q2-A-cited.md span it replaces; the Run writes those forms in place of those spans and archives the reviewed r100 record at docs/research/panels-2026-10/r100/. No branch or tracker edit occurs in this panel turn.
````

## 3. The PRV-10 form (Q5 settled KEEP, so this is r100 `check/F-QUOTE.txt`, SHA-256 `2393f71eef02a593e37ca93d6dc4bd441bfc928a0bbeff4e9939e43a34bf2323`, its final LF is not part of the form. It replaces `02-provider-contract.md`'s PRV-10 span that begins "The configuration half is `DOM-10`'s gate" and ends "then the capability gate”.")

````text
The configuration half is `DOM-10`'s gate on the create's ordering capability (`DOM-16`); `DOM-10` says “Every operation with a capability MUST be gated on it before the
driver is called, **including create**”. At admission, step 5d is the gate: `API-7` says “For create, open the existing LDG-35 admission transaction and read the provider account's
    stored offer listing in the same read-only snapshot the rich purchase tail will use,
    regardless of listing age; no stored listing means an empty offers set. If the named
    offer is present, take its kind and gate on DOM-10's matching ordering capability using
    the descriptor api runs with. A capability refusal stops here and is not collected by
    the tail. If the offer is absent, run no ordering-capability check and infer no kind from
    the provider account, capability set, offer-id spelling or caller input; continue to the
    ordinary tail's absent-offer verdict. No provider call or admission write is made here.
    On admission, retain the named offer's kind as machine_kind in the create's
    request_summary offer snapshot in the same transaction as the operation and commitment”. At claim, step 3 is the gate: `OPS-43` says “Repeat boundary validation under `OPS-23`: "Validation that was performed at the API boundary
   MUST be repeated in the worker before the driver is called". This includes `PRV-10`'s
   "explicit purchase acknowledgement", `PRV-8`'s "at least one SSH public key", and the
   missing-field checks in `OPS-23`. Validate `request_summary`'s `machine_kind` as `virtual`
   or `bare_metal`. The `api` writes `machine_kind` at admission; for missing or invalid
   fields, see `OPS-23`. Check caller-supplied fields first, then api-written admission
   fields, then gate on `DOM-10`'s matching ordering capability selected by that persisted
   `machine_kind`, using the descriptor the worker runs with. No current offer read supplies
   this gate”.
````

## 4. Settled forms whose bytes differ from the adopted text, each with the span it replaces

The Run writes each settled form in place of its adopted span wherever that span is written into the spec. Every adopted span occurs exactly once in Q2-A-cited.md and once in comment 857.

### Q1: Q1-ALT (settled 3–0 in r100b; SHA-256 `97035ff0c6bbfae893123db51d53b03bad68e512a47415554d3cf5350fe43816`) replaces Q2-A-cited.md:62-63 (comment 857:88-89); lands in `03-operation-lifecycle.md`: the OPS-23 insert written after lines 2076–2079

Adopted span:

````text
The offer-kind consistency check at OPS-43 step 5 uses the same exception: it runs on
step 4's current List offers result, after that read and before any provider mutation.
````

Q1-ALT:

````text
The offer-kind consistency check at OPS-43 step 5 uses the same exception: it runs on
step 4's current List offers result, after that read and before any provider mutation;
`OPS-43` says "If present but its kind differs from request_summary's machine_kind, settle
failed with invalid_request" and "before any provider mutation", and its step 4 says "obtain
the current driver List offers result".
````

### Q2: Q2-QUOTE (settled 3–0 in r100; SHA-256 `d82170607ffaccca68bf057c8f6f3117caa7fcc02d65599ad19f9e02502c83f6`) replaces Q2-A-cited.md:131-134 (comment 857:160-163); lands in `tools/formal/Provisiond/Admission.lean`: replaces the docstring text at lines 317–319

Adopted span:

````text
`orderingCapabilityGuard` (`API-7`, 2026-10-22, `pv-p3k`; step 5d reworded 2026-10-30,
`pv-e45e`): step 5d gates a create on the ordering capability selected by the named offer's kind
in the stored listing, and takes no gate for an offer absent from it. Off, a create without that
declaration reaches the purchase tail.
````

Q2-QUOTE:

````text
`orderingCapabilityGuard` (`API-7`, 2026-10-22, `pv-p3k`; step 5d reworded 2026-10-30,
`pv-e45e`): step 5d gates a create on the ordering capability selected by the named offer's kind
in the stored listing, and takes no gate for an offer absent from it; `API-7` says "If the named
offer is present, take its kind and gate on DOM-10's matching ordering capability" and "If the
offer is absent, run no ordering-capability check". Off, a create without that declaration
reaches the purchase tail.
````

### Q3: Q3-QUOTE (settled 3–0 in r100; SHA-256 `83bc80552410d2e6292c1a0d1cf702e82d635878ce0858b089e43ee68cf8fc09`) replaces Q2-A-cited.md:144-146 (comment 857:173-175); lands in `tools/formal/Provisiond/Admission.lean`: replaces words on lines 1181–1182

Adopted span:

````text
whether the account declares the ordering capability selected by the named offer's kind in the
stored listing; for an offer absent from that listing step 5d takes no gate and the Boolean is
supplied `true`. Offer-kind selection and descriptor construction are outside this model.
````

Q3-QUOTE:

````text
whether the account declares the ordering capability selected by the named offer's kind in the
stored listing; for an offer absent from that listing step 5d takes no gate and the Boolean is
supplied `true` (`API-7` says "If the offer is absent, run no ordering-capability check").
Offer-kind selection and descriptor construction are outside this model.
````

### Q4: Q4-KEEP (settled 3–0 in r100; SHA-256 `5db74cb1fc638bf9250e7c8f2b733aaec85b88f905d22c9f9375aa091e4b1c94`) replaces Q2-A-cited.md:69-70 (comment 857:95-96); lands in `05-persistence.md`: inside the one-line table row at line 523

Adopted span:

````text
the **offer snapshot** (`offer_id`, `machine_kind` (`virtual` or `bare_metal`, copied from the
named offer at admission under API-7), the offer's `install_strategies` as accepted,
````

Q4-KEEP:

````text
the **offer snapshot** (`offer_id`, `machine_kind` (`virtual` or `bare_metal`, copied from the named offer at admission under API-7), the offer's `install_strategies` as accepted,
````

### Q6: Q6-QUOTE (settled 3–0 in r100; SHA-256 `ad77bbdd4095faa1336db546c6058f1ef58ee3239607af89299974aa0b4bf9d5`) replaces Q2-A-cited.md:55-56 (comment 857:81-82); lands in `03-operation-lifecycle.md`: the last clause of OPS-43 step 5, replacing lines 804–805

Adopted span:

````text
the same existing
   pre-step-9 settlement releases the commitment and any resource-offer exclusion.
````

Q6-QUOTE:

````text
the same existing
   pre-step-9 settlement releases the commitment and any resource-offer exclusion; `OPS-11`
   says "The commitment is released in full under `LDG-32`" and "Where the create holds a
   resource-offer exclusion, it is freed under `STO-58`".
````

Q5 (Q2-A-cited.md:39-43) and Q7 (:101) settled KEEP: the Run writes them exactly as adopted.

## 5. The append to Q2-A-cited.md (whole `R-NOTE-append.md`, SHA-256 `40db5de25fb651fc30575c9850d4397f78d0b76213df023e372f572238b58af9`, ending with one LF)

````text
## Wording correction — 2026-11-03 (Panel r100)

The text above is retained as the historical form approved in owner item 17; its original
bytes remain unchanged. Under the owner's 2026-10-28 wording rule (“For such wording
questions, try to solve by getting a consensus of the panel”), the pv-e45e Run writes the
exact replacements selected in the panel record below in place of the spans they replace.
Comment 857 is not edited. This note grants no independent authority to change a
requirement; any substantive unresolved conflict returns to the owner.

Source pin: `2cb8e1189310ae096e598bac798df3437be59500`.
Panel record: `../../r100/notes.md`.
````
`````
