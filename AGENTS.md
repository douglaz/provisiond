# AGENTS.md

Specifications only. `tools/` holds the gates that check them; `.github/workflows/` runs the same
script. Nothing that implements the specified system belongs here.

## Gates

`bash tools/check-all.sh`, before you start and again before you report done. Run it unpiped — a
pipe reports the pipeline's status, not the gate's, which is why `check-all.sh` captures each exit
code directly.

Green is evidence only because the workflow breaks a document on every run and asserts two gates
reject it. `DEF-16` is why.

## Writing a requirement

The rule and the record are two edits with two different failure rates. Land the rule; write the
record after.

**Quote the sentence.** A claim about what another requirement says carries that requirement's own
words. `` `WIR-30` says "The gate reads the copy the machine took at create" `` is checkable;
"`WIR-30` forbids resolving eligibility that way" is an assertion, and assertions of that shape were
false repeatedly on 2026-09-03 — `ddd3df0` and `254fc24` carry the cases and what each one cost.

**Cite the owner.** One rule, one home; everywhere else points at it.
`07-security-requirements.md`'s scope note holds the argument, and `SEC-46` is the standing example
of a second copy drifting until an amendment shipped claiming to have applied while the requirement
said the opposite. **Arguments have owners too** — re-explaining a rule in a second document is how
a second normative copy gets written, because you cannot explain a rule without restating it.

**Cite the list; let it hold the number.** A count written into prose is wrong the first time either
end moves. `ADR-0003`'s footnote, `ADR-0011` and the checklist's blocking-count section each record
their own version of this. The same applies to a universal: one counterexample retires it, and
`OVR-17` carried a false one for weeks.

**Completion:** every sentence asserting what another requirement says carries its quote, and every
list or count names its source instead of restating it.

## Conventions with a home already

- Identifiers, retention, withdrawn ids → `README.md`, *Requirement conventions*.
- Vocabulary, overloaded and banned words → `CONTEXT.md`.
- Decisions and what was rejected to reach them → `docs/adr/`.
- What an implementation must demonstrate → `10-conformance-checklist.md`.
