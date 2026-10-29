# r80 tally — PR #35 permitsI docstring wording

Pin: `f25c9a2f03106353e26cb9feeed89dc647d4767d`. Tally recorded 2026-10-28 20:02:22 UTC.

Apply notes.md rule 6 exactly as written; this prompt adds no void rule.

All five named answer and exit files were read in full. All exits are 0, all answers are substantive, and none is a limit/unavailable response. Missing seats: none. Requested counterarguments below remain counterarguments, never votes. The fixed rules in notes.md were not changed.

| Seat | Final pick | A | B | Beyond wording: behavior / requirement / check strength | Strongest argument for final pick | Broken claim / limitation |
|---|---|---|---|---|---|---|
| fable | A | ACCEPT | ACCEPT | unchanged / unchanged / unchanged | A supplies the exact source words and gains one passing EXISTS comparison. | “Hyphenated, these are OPS-15's words” describes a paraphrase, not a contiguous quote; the same answer recognizes the distinction. “Not checkable” means no mechanical quotation comparison. Neither point changes its A preference. It disclosed an off-limits `ls` of the manager patch path without a file read; this is a protocol lapse, with no void rule or evidence of an altered premise. |
| opus | A | ACCEPT | CANNOT ACCEPT | unchanged / unchanged / unchanged | AGENTS.md's completion condition requires a quote even where the checker cannot enforce that instruction. | No material factual claim broken. The counterargument about exact adoption is requested, not its vote. |
| astra | A | ACCEPT | CANNOT ACCEPT | unchanged / unchanged / unchanged | A quotes the timing accurately while preserving the separate disabled-guard explanation. | No material factual claim broken. Source inspection, not a fresh reader gate run. |
| sol | A | ACCEPT | CANNOT ACCEPT | unchanged / unchanged / unchanged | A repairs the unquoted attribution without changing the model expression or its obligations. | No material factual claim broken. Source inspection, not a fresh reader gate run. |
| grok | A | ACCEPT | ACCEPT | unchanged / unchanged / unchanged | A replaces the coined timing label with OPS-15's exact words while preserving both policy sentences. | Its short list of attribution regex shapes omits bare possessives; the actual A/B input probes correctly have zero QUOTED comparisons. No effect on preference or acceptance. |

## Verification and rule 6

`check/tally-source-verification.json` retains the source checks, answer hashes, citation probes and pre-edit formal artifact hashes. Compared the brief's AGENTS.md excerpt, complete OPS-15 block, M-I excerpt, current declaration context and exact A patch against pinned repository bytes. Checked the M-I excerpt against the original old-panel excerpt read-only. Checked the adoption excerpt against the owner record and the finding verbatim against the retained thread source. The subsequent owner instruction is quoted in the current task and brief. No verified brief error changes the question's premise; no other verified brief error found. Rule 6 does not void the tally.

The controlling instruction is AGENTS.md:29–30: “A claim about what another requirement says carries that requirement's own words”; its completion at lines 45–46 says “every sentence asserting what another requirement says carries its quote”. OPS-15's opening includes “at startup, before any claim”. The proposed sentence quotes that exact contiguous span; it appears once in the root documents plus ADRs, in the OPS-15 document. Its preceding qualification “Subject to the exceptions below” governs the row dispositions; the excerpt identifies startup ordering and does not replace the complete obligation or exceptions.

Reproduced the citation probe with the pinned checker: B has EXISTS count 0 and A count 1, with no missing quotes; both have QUOTED count 0, no UNQUOTED finding, and no unpaired marks. A's quote is not skipped as historical or teaching. Lean colons are outside QUOTED, and the unbackticked id also matches none of the attribution regex shapes. Thus no claim of owner-specific mechanical verification is being credited. The checker implementation and thresholds stay unchanged.

Verified separately:

- Behavior: A changes only the first docstring sentence. `permitsI`, `stepI`, `runI`, the tag, all theorem statements/proofs and all witnesses retain their exact bytes. The guard remains `w.locked && (!requirePass || w.passDone) && (!w.fault.isRestore || w.stepTwoMarked)`. No formal source consumes docstrings through `findDocString`/`docString`; Gate.lean and Render.lean do not read them.
- Requirement: no Markdown or normative obligation changes. The exact M-I documentation differs by this one sentence under the later wording exception. The policy and selected-operation explanation remain verbatim. ADR-0025's cited docstring duty concerns hypotheses added to existing theorems; it does not create an additional obligation for this definition's attribution.
- Check strength: no declaration, guard hypothesis, gate, baseline, fixture, negative control, proof statement or verdict is weakened. The CI repairs continue to replace only `def badRequirePass : Bool := false` and `def badPassEveryStartup : Bool := false` and refute the designated assertions. Relative citation counts remain relative. EXISTS checks one additional valid quote using its existing rule. No checked verdict becomes false, unreachable or vacuous; no blocking loss under rules 3 or 7.

The manager's required pre-action unpiped `nix develop --command bash tools/check-all.sh` exited 0 (`check/tally-gate-before.log`, `.exit`). The post-edit gate will be recorded with the PR round evidence.

## Settlement

Explicit final preferences: A = 5, B = 0, alternative = 0. Acceptability: A = all five; B = fable and grok (2 accept, 3 cannot accept). Only A qualifies under rule 2, so there is no multiple-form tie-break to invent. No missing seat or grok fallback applies. No verified substantive change or blocking loss exists.

**SETTLED A:** exactly `Global guard for OPS-15: "at startup, before any claim".` in place of the first sentence, and nothing else. The 2026-10-28 wording exception authorizes this exact editorial departure without another owner question. No consensus round is needed.

Action receipt: exact A committed and pushed as `f1e3906eb811e8040fdbd1af9ed388fdb4742d56`; post-edit unpiped check-all exit 0, formal artifact hashes unchanged; thread replied/resolved; one review request, own capped `provisiond-pv-8mt4-pr35-round2` active. Evidence: `/var/tmp/provisiond-manager/pv-8mt4-pr/round2/`.
