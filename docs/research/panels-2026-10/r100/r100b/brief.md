# Panel r100b — the one consensus round on Q1 and Q-ROUTE

Pin: `2cb8e1189310ae096e598bac798df3437be59500` (unchanged from r100: master; local branch `pv-e45e` is at the same commit). Your clone
is detached at it. Read every source with `git show 2cb8e1189310ae096e598bac798df3437be59500:<path>` in your clone and check the bytes
yourself. Every block below is sliced from r100's frozen brief (`/var/tmp/provisiond-panel-r100/brief.md`,
SHA-256 `9ae53cd973ac7575f2673906e5b6ca23e4245c74dfec1cdfaef567e7e4962e33`), from form files or from r100's answers by the manager's build script
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
  Q2-QUOTE `d82170607ffaccca68bf057c8f6f3117caa7fcc02d65599ad19f9e02502c83f6`;
  Q3-QUOTE `83bc80552410d2e6292c1a0d1cf702e82d635878ce0858b089e43ee68cf8fc09`;
  Q4-KEEP `5db74cb1fc638bf9250e7c8f2b733aaec85b88f905d22c9f9375aa091e4b1c94` (the row joined, one newline becomes one space);
  Q5-KEEP `a873afce596157e55a6d03068aad8904c855002cbe720e32e3139368fa05f27e` (no bytes change, so the `PRV-10` form is `check/F-QUOTE.txt`, `2393f71eef02a593e37ca93d6dc4bd441bfc928a0bbeff4e9939e43a34bf2323`);
  Q6-QUOTE `ad77bbdd4095faa1336db546c6058f1ef58ee3239607af89299974aa0b4bf9d5`;
  Q7-KEEP `d59a4fadf509e0272ffa120048fdba452c4609f886513e973b7ef55156c981db` (no bytes change). No reader opened a Q8.
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
`AGENTS.md:45–46` requires “every sentence asserting what another requirement says carries its quote”. Q1-QUOTE leaves the original assertion as a separate, unquoted sentence. This ALT changes its period to a semicolon, attaching the supporting quotations to that sentence. The adopted step-5 words are at `Q2-A-cited.md:50–52`; step 4 contains “obtain the current driver List offers result” at `03-operation-lifecycle.md:803`. The existing exception paragraph likewise carries quotations (`03-operation-lifecycle.md:2076–2079`). No timing or exception changes.
`````

- Reader B (ALT):

`````text
This is Q1-QUOTE with the first sentence’s final period changed to a semicolon. The reason is the exact completion rule at [AGENTS.md:45]([clone]/AGENTS.md:45): “every sentence asserting what another requirement says carries its quote”. Q1-QUOTE leaves that assertion in a separate, unquoted sentence. Adjacent supporting evidence improves the paragraph, but the alternative meets the sentence-level instruction directly.
`````

- Reader C (QUOTE), who did not see the ALT:

`````text
- **Strongest reason:** the paragraph this insert extends carries `OPS-43`'s words for this same kind of claim, and the insert says it "uses the same exception" (`03-operation-lifecycle.md:2076-2079`).
  - "it runs on step 4's current List offers result, after that read and before any provider mutation" states what two `OPS-43` steps do. That is `AGENTS.md:29-30` directly.
  - It is also the shape r99 settled QUOTE 3–0 (`PRV-25`'s ordering and outcome).
- **Limit:** "before any provider mutation" also appears at `03:870`, so the gate would catch a corrupted quote but not its removal from step 5. The other two quotations carry the claim.
- **Why not KEEP:** the first half of the sentence is `OPS-23`'s own exception, but the second half is not.
`````

### Q-ROUTE: a dated note appended to Q2-A-cited.md (R-NOTE), or none (R-RUN)

Both leave comment 857 unedited and add no preparation commit. R-NOTE adds the appended note.

- Reader A (R-NOTE):

`````text
**Q-ROUTE — R-NOTE**, conditionally. Both printed routes preserve owner item 26’s “Comment 857 is not edited” and “No preparation commit” (`owner-decisions-1030.md:226–228`). I prefer R-NOTE because the appended correction makes the later wording decision discoverable from the historical adopted form while retaining its original bytes as an exact prefix. With my Q5-KEEP pick, use the original `check/F-QUOTE.txt`.
`````

- Reader B (R-RUN):

`````text
**Q-ROUTE — R-RUN.** This applies because my ballot includes replacements with changed bytes, including Q4-KEEP. Owner item 26 explicitly adopts “Comment 857 is not edited” and “No preparation commit”; R-RUN preserves both while carrying the exact replacements and archiving their review.

I also accept R-NOTE. I verified its prospective artifact consists of the original adopted bytes followed by exactly `R-NOTE-append.md`. Its statement “This note grants no independent authority to change a requirement” preserves the distinction between the historical adoption and the later wording decision. R-RUN is sufficient for my preference.
`````

- Reader C (R-NOTE):

`````text
- **Strongest reason:** comment 857 line 6 still sends readers to Q2-A-cited.md as the "Adopted exact form", and the Run will land different bytes. Since item 26 keeps the comment unedited, a dated note in that file is the only forward pointer at the place readers land.
  - It matches the owner's choice in item 25 ("Add dated archive note").
  - It matches the `Q1-A.md:61` and `:86` and `Q4-D.md:100` and `:127` precedents, including their `../../rNN/notes.md` pointer shape. `r99/notes.md` exists at the pin.
  - It adds no preparation commit, so item 26 holds.
`````

## 3. Every exact option, in full

The two sections below are sliced from r100's `brief.md` (lines 424-490 and 874-922) and each is
followed by what r100b adds.

## Q1 — the `OPS-23` insert

Adopted span: `docs/research/panels-2026-10/r86/r86b/Q2-A-cited.md:62-63` (comment 857:88-89). It lands after `03-operation-lifecycle.md:2076-2079`. `Q1-OLD.txt`, SHA-256 `91b89db887aa220e7afbd11a2eff527a2441d0860109b7cfd59394777d5615c2`:

`````text
The offer-kind consistency check at OPS-43 step 5 uses the same exception: it runs on
step 4's current List offers result, after that read and before any provider mutation.
`````

Sources, verbatim at the pin:

`03-operation-lifecycle.md:2076-2079` (the landed `OPS-23` exception paragraph the insert follows):

`````text
The worker's claim-time absence check and sale re-test at `OPS-43`'s step 5, "Check for the named
offer's absence from that result", are exceptions to this requirement's "before the driver is
called": they run on the result of `OPS-43`'s step 4, "Obtain the current driver List offers
result", after that read.
`````

`03-operation-lifecycle.md:803` (`OPS-43` step 4, unchanged by the Run):

`````text
4. Gate on `list_offers` under `DOM-10`, then obtain the current driver List offers result.
`````

`Q2-A-cited.md:48-57` (adopted new `OPS-43` step 5):

`````text
```text
5. Check for the named offer's absence from that result, applying the create-tail verdict
   quoted above. If present but its kind differs from request_summary's machine_kind,
   settle failed with invalid_request, details.reason: "offer_not_sellable" and
   retryable: false on both the error and the operation view, before any provider mutation;
   do not substitute the current kind or its capability. Otherwise re-test the named offer
   for sale on that result and the running descriptor. An absent offer or kind mismatch
   gets no price comparison, per-order key upload or order request; the same existing
   pre-step-9 settlement releases the commitment and any resource-offer exclusion.
```
`````

QUOTE's quoted segments and where they sit (checked by `check/build.py`, whitespace-insensitive, each found exactly once in its block):

- OPS-43 5, `Q2-A-cited.md (adopted new OPS-43 step 5, :49-56)`:50-51: "If present but its kind differs from request_summary's machine_kind, settle failed with invalid_request"
- OPS-43 5, `Q2-A-cited.md (adopted new OPS-43 step 5, :49-56)`:52: "before any provider mutation"
- OPS-43 4, `03-operation-lifecycle.md`:803: "obtain the current driver List offers result"

**Q1-QUOTE** (`Q1-QUOTE.txt`, SHA-256 `03732e8fe458a0e015d2c630d243ea1737777ec2077e5a8641d91a641def2cfc`, pin `2cb8e1189310ae096e598bac798df3437be59500`), the exact bytes replacing the span:

`````text
The offer-kind consistency check at OPS-43 step 5 uses the same exception: it runs on
step 4's current List offers result, after that read and before any provider mutation.
`OPS-43` says "If present but its kind differs from request_summary's machine_kind, settle
failed with invalid_request" and "before any provider mutation", and its step 4 says "obtain
the current driver List offers result".
`````

**Q1-KEEP** (`Q1-KEEP.txt`, SHA-256 `937155571f5b6cf8613b55b42b1de46c55ab75476847c7fdcd060a6c2afa9754`, pin `2cb8e1189310ae096e598bac798df3437be59500`):

`````text
KEEP: no byte changes. The Q2-A-cited.md:62-63 span (comment 857:88-89) stays exactly as adopted; the Run writes it as Q2-A-cited.md has it, at pin 2cb8e1189310ae096e598bac798df3437be59500.
`````

Trial: T-Q1 (this QUOTE alone, every other span as adopted, Q4 joined) exits 0, 367 Markdown and 143 Lean docstring quotations compared, unquoted attributions 22, none new. N-Q1 (all QUOTE forms, this one's third quoted word "but" replaced by WRONGWORD) exits 1.

QUOTE keeps the adopted two lines and appends one sentence carrying step 5's and step 4's words for the claims it relies on (what the check is, "before any provider mutation", and the List offers read). KEEP rests on the insert being `OPS-23`'s own exception rule that names where it applies, as the landed paragraph above it is (and that paragraph does quote steps 4 and 5).


### Q1: what r100b adds

**Q1-ALT** (`Q1-ALT.txt`, SHA-256 `97035ff0c6bbfae893123db51d53b03bad68e512a47415554d3cf5350fe43816`, pin `2cb8e1189310ae096e598bac798df3437be59500`), printed byte-identically
by Readers A and B, the exact bytes replacing the span:

`````text
The offer-kind consistency check at OPS-43 step 5 uses the same exception: it runs on
step 4's current List offers result, after that read and before any provider mutation;
`OPS-43` says "If present but its kind differs from request_summary's machine_kind, settle
failed with invalid_request" and "before any provider mutation", and its step 4 says "obtain
the current driver List offers result".
`````

Trials (`r100b/check/trial_b.py`, results `r100b/check/trial.json`; scratch clones of the pin, same
read-only lake index as r100 §9): every settled form applied (Q2-QUOTE, Q3-QUOTE, Q4-KEEP, Q6-QUOTE;
Q5 and Q7 unchanged; `check/F-QUOTE.txt`), with each Q1 option in turn.

| Trial | Q1 option | Exit | Markdown compared | Lean QUOTED compared |
|---|---|---|---|---|
| T-S-Q1KEEP | Q1-KEEP | 0 | 366 | 146 |
| T-S-Q1QUOTE | Q1-QUOTE | 0 | 369 | 146 |
| T-S-Q1ALT | Q1-ALT | 0 | 369 | 146 |
| N-S-Q1ALT | Q1-ALT, first quotation's third word "but" replaced by WRONGWORD | 1 | — | — |

The three passing trials report 22 unquoted attributions, none new. N-S-Q1ALT fails with "FAIL: 1
unverifiable quoted attribution(s)", the corrupted Q1-ALT quotation. QUOTE and ALT make the same three
comparisons; the gate does not distinguish them.

## Q-ROUTE — how a changed form reaches the Run and the record

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

**R-RUN** (`R-RUN.txt`, SHA-256 `606973ea02527fc50d1ae9be52e073d69ff74c2009c455cd61a925e06c31a0dd`, pin `2cb8e1189310ae096e598bac798df3437be59500`):

`````text
No preparation commit; comment 857 and docs/research/panels-2026-10/r86/r86b/Q2-A-cited.md are not edited. The pv-e45e Run instruction quotes verbatim /var/tmp/provisiond-panel-r98/brief.md:201–203, the PRV-10 form (r100 check/F-QUOTE.txt, or check/F-QUOTE-Q5.txt if Q5 settles on Q5-QUOTE), and each settled r100 form whose bytes differ from the adopted text, each with the Q2-A-cited.md span it replaces; the Run writes those forms in place of those spans and archives the reviewed r100 record at docs/research/panels-2026-10/r100/. No branch or tracker edit occurs in this panel turn.
`````

**R-NOTE** (`R-NOTE.txt`, SHA-256 `d50de4177d3aa9c689d1bc4e6f1ff7cd6fbb08831ae8fd5702484ce3efff43a7`, pin `2cb8e1189310ae096e598bac798df3437be59500`):

`````text
Exactly as R-RUN, and in addition the Run appends exactly R-NOTE-append.md to docs/research/panels-2026-10/r86/r86b/Q2-A-cited.md, all original bytes remaining an exact prefix. Comment 857 is not edited. No branch or tracker edit occurs in this panel turn.
`````

`R-NOTE-append.md` (SHA-256 `40db5de25fb651fc30575c9850d4397f78d0b76213df023e372f572238b58af9`), the exact bytes appended. The pinned
Q2-A-cited.md ends with a blank line, so it begins directly with the heading:

`````markdown
## Wording correction — 2026-11-03 (Panel r100)

The text above is retained as the historical form approved in owner item 17; its original
bytes remain unchanged. Under the owner's 2026-10-28 wording rule (“For such wording
questions, try to solve by getting a consensus of the panel”), the pv-e45e Run writes the
exact replacements selected in the panel record below in place of the spans they replace.
Comment 857 is not edited. This note grants no independent authority to change a
requirement; any substantive unresolved conflict returns to the owner.

Source pin: `2cb8e1189310ae096e598bac798df3437be59500`.
Panel record: `../../r100/notes.md`.
`````

`check/prospective-Q2-A-cited-with-note.md` (SHA-256 `0e665520d8d83469799d5afc62ad735f506b26e23d9b61b66696e9a88ea7a7c1`)
shows the result; the pinned bytes are its exact prefix. `docs/research/` is outside the gate (§2).
For the all-QUOTE case, `check/prospective-Q2-A-cited-allquote.md` (SHA-256
`6e58fd5afcdd6ccbeb47287e2fb9b5accc0446ae02b91619dc8aad6fdcc2c436`) shows what the Run would write in place of the
adopted text; it is a reading aid, not a form.


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
You've reached your Fable limit. Switch to another model, or manage usage credits at https://claude.ai/settings/usage?from=cc_cli_limit_message, to continue.
`````

### Grok (missing seat)

The r100 preflight and this round's refreshed preflight both returned: "API error (status 402 Payment
Required): Grok Build usage balance exhausted".

### Reader A

``````markdown
Seat **[seat]**, reviewed pin `2cb8e1189310ae096e598bac798df3437be59500`.

**Final picks:** Q1-ALT below; Q2-QUOTE; Q3-QUOTE; Q4-KEEP; Q5-KEEP; Q6-QUOTE; Q7-KEEP; R-NOTE.

| Question | ACCEPT | CANNOT ACCEPT | Pick wording-only? |
|---|---|---|---|
| Q1 | Q1-ALT below | Q1-QUOTE, Q1-KEEP | Yes |
| Q2 | Q2-QUOTE | Q2-KEEP | Yes |
| Q3 | Q3-QUOTE | Q3-KEEP | Yes |
| Q4 | Q4-QUOTE, Q4-KEEP | Q4-ASIS | Yes |
| Q5 | Q5-QUOTE, Q5-KEEP | — | Yes |
| Q6 | Q6-QUOTE | Q6-KEEP | Yes |
| Q7 | Q7-QUOTE, Q7-KEEP | — | Yes |
| Q-ROUTE | R-RUN, R-NOTE | — | Yes, conditional on wording-only settlements |

My CANNOT ACCEPT judgments identify editorial defects, **not rule-3 blocking losses**. I found no changed conformance verdict, theorem domain, guard hypothesis, normative obligation, fixture, or negative-control strength in the selected replacements.

**Q1 — Q1-ALT.** Replace exactly `docs/research/panels-2026-10/r86/r86b/Q2-A-cited.md:62–63` (comment 857:88–89) with:

```text
The offer-kind consistency check at OPS-43 step 5 uses the same exception: it runs on
step 4's current List offers result, after that read and before any provider mutation;
`OPS-43` says "If present but its kind differs from request_summary's machine_kind, settle
failed with invalid_request" and "before any provider mutation", and its step 4 says "obtain
the current driver List offers result".
```

SHA-256, including the terminating newline: `97035ff0c6bbfae893123db51d53b03bad68e512a47415554d3cf5350fe43816`.

`AGENTS.md:45–46` requires “every sentence asserting what another requirement says carries its quote”. Q1-QUOTE leaves the original assertion as a separate, unquoted sentence. This ALT changes its period to a semicolon, attaching the supporting quotations to that sentence. The adopted step-5 words are at `Q2-A-cited.md:50–52`; step 4 contains “obtain the current driver List offers result” at `03-operation-lifecycle.md:803`. The existing exception paragraph likewise carries quotations (`03-operation-lifecycle.md:2076–2079`). No timing or exception changes.

**Q2 — Q2-QUOTE.** The adopted phrase “step 5d gates a create” explicitly describes the requirement’s behavior; it is more than a description of the model flag. The pinned docstring already carries `API-7`’s “**gate a create on its ordering capability**” (`Admission.lean:317–319`). The chosen form supplies the replacement branches’ actual words from `Q2-A-cited.md:8–11`. Keeping the previously approved docstring does not establish an exception to `AGENTS.md:29–30`.

**Q3 — Q3-QUOTE.** The Boolean convention and the external explanation are distinguishable. “the Boolean is supplied `true`” describes the model convention; “step 5d takes no gate” describes the requirement. The parenthetical supplies `API-7`’s “If the offer is absent, run no ordering-capability check” (`Q2-A-cited.md:11`). It changes no declaration or theorem (`Admission.lean:1184–1201`) and does not resolve the substantive formal objection retained in owner item 17.

**Q4 — Q4-KEEP.** This is the persistence row’s own field definition with a source pointer, consistent with `AGENTS.md:34`: “One rule, one home; everywhere else points at it.” I accept QUOTE too, but prefer the shorter definition. The pinned `request_summary` row is one physical line (`05-persistence.md:523`); the adopted newline splits it. KEEP repairs that formatting without changing a word. ASIS leaves the verified rendering defect.

**Q5 — Q5-KEEP.** “The `api` writes `machine_kind` at admission” declares the writer of the field this step validates. That classification has a direct local purpose: `OPS-23` says, “A release that adds a required field MUST state whether the caller supplies it or the `api` writes it at admission” (`03-operation-lifecycle.md:2073–2074`). It need not become a report of `API-7`’s wording. QUOTE is also acceptable, provided its mechanically regenerated `F-QUOTE-Q5.txt` accompanies it; I verified both PRV-10 forms against their respective exact step slices.

**Q6 — Q6-QUOTE.** This clause reports an existing settlement’s effects rather than merely delegating to its owner. `OPS-11` contains “The commitment is released in full under `LDG-32`” and “Where the create holds a resource-offer exclusion, it is freed under `STO-58`” (`03-operation-lifecycle.md:249`). Quotations elsewhere in the procedure (`:790`, `:819`) do not make this sentence carry its quotation. The chosen form preserves both effects and their existing conditions.

**Q7 — Q7-KEEP.** I read this as a test directive selecting an assertion to reuse. Its “pre-List-offers refusal” identifies the existing case whose assertion includes “no provider request, including no List offers read” (`10-conformance-checklist.md:373–374`). It does not claim that the old case already tested retained `machine_kind`. QUOTE is acceptable but unnecessary; its quotation locates the refusal at step 3 (`:369–370`).

**Q-ROUTE — R-NOTE**, conditionally. Both printed routes preserve owner item 26’s “Comment 857 is not edited” and “No preparation commit” (`owner-decisions-1030.md:226–228`). I prefer R-NOTE because the appended correction makes the later wording decision discoverable from the historical adopted form while retaining its original bytes as an exact prefix. With my Q5-KEEP pick, use the original `check/F-QUOTE.txt`.

**Comment 857 stays unedited under my R-NOTE pick.**

I verified the source/form hashes, comment-857 equality, quotation spans, supplied positive and negative receipts, and Q4’s whitespace-only join. A targeted in-memory application of my selected package, using the unchanged pinned citation parser, introduced no new citation residuals; corrupting Q1-ALT’s quotation was detected. This was not a full gate run.

**Rule 6:** I verified no brief error that changes a question’s premise; no question should be voided on my findings. Q1-QUOTE’s sentence-level deficiency is an assessed option defect, not a false premise. I open no Q8.

Process disclosure: I mistakenly started the Nix gate before applying notes.md’s fence, then interrupted it with exit 130. It produced partial build artifacts; tracked status remained clean. I made no source, Git, or tracker edits.
``````

### Reader B

``````markdown
[seat]’s final ballot, reviewed against pin `2cb8e1189310ae096e598bac798df3437be59500`:

| Question | Final pick | ACCEPT | CANNOT ACCEPT | Pick wording-only? |
|---|---|---|---|---|
| Q1 | **Q1-ALT**, printed below | Q1-ALT | Q1-QUOTE; Q1-KEEP | Yes |
| Q2 | **Q2-QUOTE** | Q2-QUOTE | Q2-KEEP | Yes |
| Q3 | **Q3-QUOTE** | Q3-QUOTE | Q3-KEEP | Yes |
| Q4 | **Q4-KEEP** | Q4-KEEP; Q4-QUOTE | Q4-ASIS | Yes |
| Q5 | **Q5-KEEP** | Q5-KEEP; Q5-QUOTE | — | Yes; unchanged |
| Q6 | **Q6-QUOTE** | Q6-QUOTE | Q6-KEEP | Yes |
| Q7 | **Q7-KEEP** | Q7-KEEP; Q7-QUOTE | — | Yes; unchanged |
| Q-ROUTE | **R-RUN**, conditionally | R-RUN; R-NOTE | — | Yes |

These acceptance judgments distinguish editorial compliance from substantive blocking losses. I identify no changed conformance verdict, weakened theorem, changed guard hypothesis, or weakened existing negative control caused by these wording alternatives. My CANNOT ACCEPT judgments concern the quotation rule or Q4’s broken table.

Below, **A** means the pinned [Q2-A-cited.md]([clone]/docs/research/panels-2026-10/r86/r86b/Q2-A-cited.md).

**Q1 — Q1-ALT.** Replace exactly A:62–63, comment 857:88–89, with:

```text
The offer-kind consistency check at OPS-43 step 5 uses the same exception: it runs on
step 4's current List offers result, after that read and before any provider mutation;
`OPS-43` says "If present but its kind differs from request_summary's machine_kind, settle
failed with invalid_request" and "before any provider mutation", and its step 4 says "obtain
the current driver List offers result".
```

This is Q1-QUOTE with the first sentence’s final period changed to a semicolon. The reason is the exact completion rule at [AGENTS.md:45]([clone]/AGENTS.md:45): “every sentence asserting what another requirement says carries its quote”. Q1-QUOTE leaves that assertion in a separate, unquoted sentence. Adjacent supporting evidence improves the paragraph, but the alternative meets the sentence-level instruction directly.

The sources support the unchanged claim: A:50–52 supplies “If present but its kind differs…” and “before any provider mutation”; [03-operation-lifecycle.md:803]([clone]/03-operation-lifecycle.md:803) supplies “obtain the current driver List offers result”. The exception remains exactly where the adopted text places it.

This is an option defect, not a verified error in the brief’s description: the brief expressly says Q1-QUOTE appends a sentence. **No rule-6 void.**

**Q2 — Q2-QUOTE.** A:132–133 describes what a named specification step does: “step 5d gates a create…” and “takes no gate for an offer absent from it”. That is a claim about `API-7`, even inside a model docstring. It is distinct from the following model-flag explanation.

A:8–11 provides the exact support: “If the named offer is present, take its kind and gate on DOM-10’s matching ordering capability” and “If the offer is absent, run no ordering-capability check”. The pinned [Admission.lean:317]([clone]/tools/formal/Provisiond/Admission.lean:317) already uses an attributed quotation for this description. Q2-QUOTE preserves the adopted explanation and restores direct support.

The added quotations change no declaration or model input convention. **No premise-changing brief error.**

**Q3 — Q3-QUOTE.** The model convention and its stated specification justification are separable. A:145–146 says both “step 5d takes no gate” and “the Boolean is supplied `true`”. The latter describes the model interface; the former reports the step’s behavior. Q3-QUOTE supports that report with A:11’s “If the offer is absent, run no ordering-capability check”.

The unchanged function at [Admission.lean:1185]([clone]/tools/formal/Provisiond/Admission.lean:1185) branches on the supplied Boolean. Adding the quotation neither changes that branch nor supplies a new proof about offer absence. **No premise-changing brief error.**

**Q4 — Q4-KEEP.** The row defines the persisted field and identifies its source. A:69–70’s “copied from the named offer at admission under API-7” is acceptable as that schema definition and source pointer. This fits [AGENTS.md:34]([clone]/AGENTS.md:34): “One rule, one home; everywhere else points at it.” Owner item 27 supports accepting this distinction, although it does not grant a general exemption to unrelated paraphrases.

The formatting defect is concrete: [05-persistence.md:523]([clone]/05-persistence.md:523) is one table row. Inserting A’s internal newline splits it. I verified Q4-KEEP differs from Q4-OLD only by replacing that internal newline with a space. Q4-QUOTE also repairs the row and quotes A:14–15 accurately, so I accept it.

Q4-ASIS preserves the broken rendering and is unacceptable editorially. **The brief reports this defect correctly; no rule-6 void.**

**Q5 — Q5-KEEP.** The writer declaration has a direct purpose in the worker’s validation rule. [03-operation-lifecycle.md:2073]([clone]/03-operation-lifecycle.md:2073) says: “A release that adds a required field MUST state whether the caller supplies it or the `api` writes it at admission.”

A:39’s “The `api` writes `machine_kind` at admission” makes precisely that classification. It lets the worker apply the correct missing-or-invalid-field treatment. It is not framed as a report of another requirement’s wording, and I would retain it.

Q5-QUOTE is also accurate and wording-only. Its collateral quotation update is necessary: I verified that `F-QUOTE-Q5.txt` is exactly the corresponding substitution inside `F-QUOTE.txt`, respecting the existing quotation’s omitted terminal period. **No premise-changing brief error.**

**Q6 — Q6-QUOTE.** “The same existing … settlement releases…” reports an existing settlement’s effect; it does more than identify the settlement. [03-operation-lifecycle.md:249]([clone]/03-operation-lifecycle.md:249) supplies both quoted clauses:

- “The commitment is released in full under `LDG-32`”
- “Where the create holds a resource-offer exclusion, it is freed under `STO-58`”

Q6-QUOTE attaches that support to the claim. Earlier quotations in steps 1 and 8 do not make this sentence carry its own quotation under AGENTS.md’s completion wording.

The conditional “any resource-offer exclusion” remains conditional; the quote does not create an exclusion or change settlement timing, guards, amounts, or outcomes. **No premise-changing brief error.**

**Q7 — Q7-KEEP.** This is a test instruction selecting an existing assertion for the new retained-kind fixture. [10-conformance-checklist.md:369]([clone]/10-conformance-checklist.md:369) says “the worker refuses it at `OPS-43`’s step 3”, and :373–374 explicitly requires “no provider request, including no List offers read”.

Thus “the CNF-55 pre-List-offers refusal” identifies the assertion to reuse. I treat it consistently with the other checklist directives naming an existing refusal. Q7-QUOTE is accurate and acceptable, although its selected quotation supports placement through step 3 rather than quoting the no-List-offers words directly.

Neither form changes the fixture or expected result. **No premise-changing brief error.**

**Q-ROUTE — R-RUN.** This applies because my ballot includes replacements with changed bytes, including Q4-KEEP. Owner item 26 explicitly adopts “Comment 857 is not edited” and “No preparation commit”; R-RUN preserves both while carrying the exact replacements and archiving their review.

I also accept R-NOTE. I verified its prospective artifact consists of the original adopted bytes followed by exactly `R-NOTE-append.md`. Its statement “This note grants no independent authority to change a requirement” preserves the distinction between the historical adoption and the later wording decision. R-RUN is sufficient for my preference.

Under my ballot, the Run carries the original `check/F-QUOTE.txt`, because Q5 stays KEEP. Q1-ALT must be carried in full as its own form; it must not be tallied as Q1-QUOTE. **No premise-changing brief error.**

**Comment 857 stays unedited under my R-RUN pick.**

All QUOTE additions are wording-only relative to the **adopted package**: they add source evidence without changing behavior, normative obligations, conformance assertions, Lean declarations, or existing negative-control strength. They do add lexical citation-check coverage. That disclosed increase is not a change to the system behavior or formal/conformance obligations being checked.

This conclusion does **not** reclassify the original adoption as editorial. A:109 expressly identifies the absent-offer skip and fixture qualification. The theorem at [Admission.lean:1196]([clone]/tools/formal/Provisiond/Admission.lean:1196) still proves the supplied-false case. These quotation repairs do not resolve the formal-model objection retained in owner item 17.

I verified the adopted form and comment 857 against their pinned bytes, the printed form hashes, the quoted source fragments, the trial diff hashes, and the supplied positive and negative-control log diagnostics. I also ran an in-memory, targeted citation probe using the pinned checker: Q1-ALT makes the same three comparisons as Q1-QUOTE, and corrupting its first quotation produces the expected unverifiable attribution. This was not a full candidate gate.

One brief clarification belongs with the tally: §2’s scanning description conflates citation sources with quotation-check inputs. At `tools/check_citations.py:1567–1569`, root Markdown and Lean docstrings receive attribution checks; ADR text supplies supporting corpus material. ADRs also participate in the name check at :1515–1518. This does not affect these forms or any vote, and **does not change a question’s premise**. I open no Q8 and void no question under rule 6.

Finally, I violated the panel fence by starting `nix develop --command bash tools/check-all.sh`. I terminated its process group; it exited 143 after producing build artifacts. Tracked-file status remained clean, but that does not undo the scratch-location violation. I claim no completed gate result from that run.
``````

### Reader C

``````markdown
# Panel r100: [seat] reader answer

Rule applied: **apply notes.md rule 6 exactly as written; this prompt adds no void rule.** I found no brief error that voids a question; the three I verified are listed at the end.

| Question | Final pick | ACCEPT | CANNOT ACCEPT |
|---|---|---|---|
| Q1 | **Q1-QUOTE** | Q1-QUOTE | Q1-KEEP |
| Q2 | **Q2-QUOTE** | Q2-QUOTE | Q2-KEEP |
| Q3 | **Q3-QUOTE** | Q3-QUOTE, Q3-KEEP | none |
| Q4 | **Q4-KEEP** | Q4-KEEP, Q4-QUOTE | Q4-ASIS |
| Q5 | **Q5-KEEP** | Q5-KEEP, Q5-QUOTE | none |
| Q6 | **Q6-QUOTE** | Q6-QUOTE, Q6-KEEP | none |
| Q7 | **Q7-KEEP** | Q7-KEEP, Q7-QUOTE | none |
| Q-ROUTE | **R-NOTE** | R-NOTE, R-RUN | none |
| Q8 | not opened | n/a | n/a |

Each CANNOT ACCEPT above is a rule conflict or a formatting defect. None is a rule 3 blocking loss, because none changes a checked verdict, and I quote no MUST or SHOULD against those forms.

**Comment 857 stays unedited under R-NOTE.**

## Q1: the `OPS-23` insert

- **Pick:** Q1-QUOTE.
- **Wording-only:** yes. It adds one sentence of quotation, and no rule, declaration or fixture changes. It adds three gate comparisons and weakens nothing.
- **Strongest reason:** the paragraph this insert extends carries `OPS-43`'s words for this same kind of claim, and the insert says it "uses the same exception" (`03-operation-lifecycle.md:2076-2079`).
  - "it runs on step 4's current List offers result, after that read and before any provider mutation" states what two `OPS-43` steps do. That is `AGENTS.md:29-30` directly.
  - It is also the shape r99 settled QUOTE 3–0 (`PRV-25`'s ordering and outcome).
- **Limit:** "before any provider mutation" also appears at `03:870`, so the gate would catch a corrupted quote but not its removal from step 5. The other two quotations carry the claim.
- **Why not KEEP:** the first half of the sentence is `OPS-23`'s own exception, but the second half is not.

## Q2: `Admission.lean:317-319`

- **Pick:** Q2-QUOTE.
- **Wording-only:** yes. It changes a docstring only, with no declaration, proof statement or guard hypothesis touched.
- **Open objection:** astra and sol's objection stays on record, neither resolved nor worsened. r86b `opus.md:102` called the adopted docstring edit a semantic narrowing, but that belongs to the owner-adopted text, not to this addition.
- **Strongest reason:** the two neighbouring guard entries each carry their rule's words (`Admission.lean:312-315`, `:321-323`). The pinned line 318 does too.
  - The old words must go, because the Run removes them from `API-7`. The choice is whether to replace them with new words or with a paraphrase.
  - The KEEP case calls this a model summary, but "step 5d gates a create…" speaks about `API-7`. Only "Off, …" speaks about the model.
  - Under KEEP this entry would have no checked tie to `API-7`.

## Q3: `Admission.lean:1181-1182`

- **Pick:** Q3-QUOTE.
- **Wording-only:** yes. It changes a docstring only.
- **Strongest reason:** "step 5d takes no gate" is a claim about `API-7`, and it sits on the clause that decides what `orderingDeclared` means for an absent offer (r86b `brief.md:1591`). The `true` convention depends on that sentence, so if `API-7` changes it, the EXISTS rule will now report it.
- **Reader note:** the parenthetical comes after "supplied `true`" but supports only the step-5d half. The sentence already says which half is which, so it doesn't mislead. I accept KEEP because the clause is partly a model convention.

## Q4: the 05 `request_summary` row

- **Pick:** Q4-KEEP.
- **Wording-only:** yes. One newline becomes one space, with every word unchanged. r86b `fable.md:59` already said it "must be joined on landing, a formatting matter".
- **Strongest reason:** the clause is the row's own field definition naming its source, the "Cite the owner" pointer shape (`AGENTS.md:34`).
  - The owner kept this shape in item 27, and the same row points the same way elsewhere ("(`OPS-13`)", `05-persistence.md:523`).
  - QUOTE is true and checkable, but it puts a 20-word quote inside nested parentheses in a 1982-character table row, and it adds little.
- **Why not ASIS:** the first half of the row would end at "copied from the" with no closing pipe. The stray second line would start without a pipe but end with one (my check of `trial-T-ASIS.diff`). The persistence table's definition would be cut mid-sentence. It passes the gates I could run, but it's a real defect.

## Q5: `OPS-43` step 3 admission clause

- **Pick:** Q5-KEEP.
- **Wording-only:** yes, with no byte change.
- **Strongest reason:** this clause carries out a landed duty, so it isn't a report about another requirement. `OPS-23` says "A release that adds a required field MUST state whether the caller supplies it or the `api` writes it at admission" (`03:2072-2074`). The brief's KEEP case doesn't cite this sentence.
- **Cost of QUOTE:** it would also replace the F-QUOTE bytes the owner recorded by SHA in item 26 with F-QUOTE-Q5, nesting an `API-7` quotation inside `PRV-10`'s quotation of step 3. It passes the gate and I accept it, but nothing here justifies that change.

## Q6: `OPS-43` step 5 settlement clause

- **Pick:** Q6-QUOTE.
- **Wording-only:** yes. Both quotations are `OPS-11`'s existing text (`03:249`), and no obligation changes.
- **Strongest reason:** the landed settlement paragraph covers only "If the offer is absent from that result or the re-test finds it unsellable" (`03:869`).
  - The adopted text doesn't extend that paragraph to the new kind-mismatch branch.
  - For a kind mismatch, this clause is the only statement of the release, and adopted step 5 never names `OPS-11`.
  - So "the same existing" settlement isn't a pointer to an owner, and QUOTE supplies that owner.
- **Counterweight:** for an absent offer, `03:872-884` already carries the words, which is why I accept KEEP. See brief error 1.

## Q7: the `CNF-19` directive

- **Pick:** Q7-KEEP.
- **Wording-only:** yes, with no byte change.
- **Strongest reason:** this is the checklist's standing way to reuse another item's case. For example, "`CNF-279`'s pinned-key abort" (`10-conformance-checklist.md:3184`), "`CNF-277`'s outage fixtures" (`:3045`) and "`CNF-362`'s later-stop assertions" (`:1801`). "pre-List-offers" only says which of `CNF-55`'s two refusals is meant.
- **Weakness in QUOTE:** its words support "step 3", while the words matching "pre-List-offers" are "no List offers read" (`:373-374`). It's true and gate-checked, so I accept it, but it doesn't quote the word in question.

## Q-ROUTE

- **Pick:** R-NOTE. It applies because Q4-KEEP and the QUOTE forms change bytes.
- **Wording-only:** yes. It touches records only. No gate reads `docs/research/` (no match in `tools/` or `.github/`), and my rerun of T-KEEP, T-ALL and the QUOTE trials used no note.
- **Strongest reason:** comment 857 line 6 still sends readers to Q2-A-cited.md as the "Adopted exact form", and the Run will land different bytes. Since item 26 keeps the comment unedited, a dated note in that file is the only forward pointer at the place readers land.
  - It matches the owner's choice in item 25 ("Add dated archive note").
  - It matches the `Q1-A.md:61` and `:86` and `Q4-D.md:100` and `:127` precedents, including their `../../rNN/notes.md` pointer shape. `r99/notes.md` exists at the pin.
  - It adds no preparation commit, so item 26 holds.

## Q8

Not opened. I agree with the "considered and not listed" reading. The closest case is `Q2-A-cited.md:102`, "`OPS-23`'s incomplete_record result". It names a result in the owner's own term (`03:2052`) and makes no further claim.

## Verification

- **Forms and sources:** form hashes, spans and line maps match, and comment 857 is byte-equal to the beads text at the pin. Each `Qn-OLD` occurs exactly once in both the adopted text and comment 857, and the note preserves the original bytes as an exact prefix.
- **Citation trial rerun:** I reran it in scratch and every comparison count in §9 reproduces. My diffs for T-ASIS, T-KEEP, T-ALL, T-Q5 and T-Q6 are byte-equal to the packet's.
- **Stub index:** the real lake index is in a fenced directory, so I used an empty one. NAMES therefore fails with 49 unresolved names at T0, and my rerun's citation exit is 1 on every trial. T-ALL's only differences from T0 are the counts, so NAMES adds nothing new there. I read the single-form trials by their counts rather than diffing each log.
- **Later quotations:** the packet's controls corrupt only each first quotation. I also corrupted Q1's second and third and Q2's and Q6's second, and each one fails the gate.
- **Other gates:** `check_ids`, `check_obligations` and `check_coverage` exit 0 on every applied trial, with logs identical to T0 on T-ASIS and T-ALL.
- **Not run:** `check_fixtures` (it needs `markdown_it` under Nix), Lean and `check_regions`, all fenced. So no full candidate gate exists yet, and the Run must produce one. No Markdown region cites the two touched declarations.

## Brief errors (rule 6)

None of these changes a question's premise, and none voids a tally.

1. **Q6: "the same release claim" and "a third copy".** Steps 1 and 8 (`03:790`, `:819`) quote only the commitment half. `OPS-11`'s exclusion sentence appears only at `03:249`. The brief also omits `03:869-884`, `OPS-43`'s own settlement paragraph for an absent or unsellable offer. The question and forms still stand, and my vote doesn't rest on this. A vote reasoning that steps 1 and 8 already quote the whole claim would rest on it.
2. **§2 "scans":** the gate reads `docs/adr/*.md` as sources, not as QUOTED input (`tools/check_citations.py:32`). `docs/research/` stays out either way.
3. **R-NOTE form text:** "Exactly as R-RUN" literally inherits R-RUN's "Q2-A-cited.md are not edited". The "in addition" clause and the prefix condition resolve it, so this is harmless but worth reading carefully.

The clone is clean and still at the pin. My only writes are under `[scratch]` (124M, including three trial clones).
``````
