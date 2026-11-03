Seat **sol**, reviewed pin `2cb8e1189310ae096e598bac798df3437be59500`.

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