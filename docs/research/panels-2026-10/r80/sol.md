Final: A

**A: ACCEPT. B: CANNOT ACCEPT.**

[AGENTS.md](https://github.com/douglaz/provisiond/blob/f25c9a2f03106353e26cb9feeed89dc647d4767d/AGENTS.md#L29) requires: “A claim about what another requirement says carries that requirement’s own words.” Its completion condition is explicit: “every sentence asserting what another requirement says carries its quote.”

“OPS-15’s before-any-claim requirement” attributes an obligation to OPS-15 without quoting it. A supplies the exact words “at startup, before any claim,” present in [OPS-15’s opening sentence](https://github.com/douglaz/provisiond/blob/f25c9a2f03106353e26cb9feeed89dc647d4767d/03-operation-lifecycle.md#L371). That quotation identifies the timing being modeled; it does not purport to reproduce the entire requirement or remove its exceptions.

A also preserves the separate explanation: “True is the current policy; false permits claims after lock and the restore step-(2) mark without requiring the per-process pass.” B leaves the source attribution unquoted. Supplying a quotation in a PR reply would not repair that sentence.

The owner’s verbatim adoption establishes that the existing wording was authorized. It does not establish that the wording satisfies the quotation instruction. The subsequent direction—“For such wording questions, try to solve by getting a consensus of the panel”—supports considering this exact replacement. I propose no alternative.

**A beyond wording:**

- **Behavior unchanged.** The exact patch changes only the first docstring sentence. [The claim expression](https://github.com/douglaz/provisiond/blob/f25c9a2f03106353e26cb9feeed89dc647d4767d/tools/formal/Provisiond/RestoreIndependent.lean#L15) remains `w.locked && (!requirePass || w.passDone) && (!w.fault.isRestore || w.stepTwoMarked)`. Neither Boolean setting acquires different behavior.
- **Requirement unchanged.** OPS-15’s normative text and the tagged declaration remain untouched. The replacement quotes an existing timing clause; it creates no new obligation and changes no exception. It repairs compliance with the existing writing instruction.
- **Check strength unchanged.** No definition, theorem statement, hypothesis, proof, witness, checker, baseline or negative control changes. The independent controls in [CI](https://github.com/douglaz/provisiond/blob/f25c9a2f03106353e26cb9feeed89dc647d4767d/.github/workflows/ci.yml#L990) still repair each disabled guard and require its designated witness to fail. A adds a quotation for the existing [EXISTS comparison](https://github.com/douglaz/provisiond/blob/f25c9a2f03106353e26cb9feeed89dc647d4767d/tools/check_citations.py#L681); its words occur in OPS-15. That changes the checked text and quotation reporting, not the checker’s strength.

I identify no concrete changed checked verdict or normative obligation. This conclusion comes from source inspection; I did not rerun gates.

**Requested counterargument, not my vote:** M-I expressly required the printed documentation, and the adoption said “No unread repair or union is approved.” A departs from that exact adopted text, even though its effect is editorial. The later manager should therefore treat A as the specific wording exception considered here, without implying approval for other alterations.

I cannot accept B as printed under the quotation instruction. Consensus on A requires accepting this exact sentence replacement. Consensus on B would require an explicit exception to that instruction; the supplied evidence does not expressly provide one.

The clone was clean and detached at the requested pin. No files were changed and no remote actions were taken.