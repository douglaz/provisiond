# AGENTS.md

Specifications only. `tools/` holds the gates that check them; `.github/workflows/` runs the same
script. Nothing that implements the specified system belongs here.

## Gates

`nix develop --command bash tools/check-all.sh`, before you start and again before you report
done. Run it unpiped — a pipe reports the pipeline's status, not the gate's, which is why
`check-all.sh` captures each exit code directly. The shell is required: the formal gate needs Lean,
and a missing toolchain is a red gate, not a skipped one.

A formalized clause's home is its Lean declaration in `tools/formal/`, tagged `@[req "LDG-38"]`
(`ADR-0025`). Change the declaration and the Markdown together; a theorem that stops proving is
the gate telling you the amendment contradicts a property the set claims — read the theorem
before weakening it, since weakening a statement to make a proof pass is a semantic change like
any other. Never put a `CNF` identifier in `tools/formal/`.

Green is evidence only because the workflow breaks a document on every run and asserts the gates
reject it — one negative-control step per gate that has one, and `.github/workflows/ci.yml` holds
the list rather than this sentence. `DEF-16` is why.

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
end moves. `ADR-0003`'s footnote, `ADR-0011` and `F16` in `11-open-findings.md` each record their
own version of this. The same applies to a universal: one counterexample retires it, and
`OVR-17` carried a false one for weeks.

**Completion:** every sentence asserting what another requirement says carries its quote, and every
list or count names its source instead of restating it.

## Agent skills

### Issue tracker

Beads (`br`), local-first in `.beads/`, committed with the specs. See `docs/agents/issue-tracker.md`.

### Triage labels

The five default roles as `br` labels. See `docs/agents/triage-labels.md`.

### Domain docs

Single-context: `CONTEXT.md` and `docs/adr/` at the root. See `docs/agents/domain.md`.

## Conventions with a home already

- Identifiers, retention, withdrawn ids → `README.md`, *Requirement conventions*.
- Vocabulary, overloaded and banned words → `CONTEXT.md`.
- Decisions and what was rejected to reach them → `docs/adr/`.
- What an implementation must demonstrate → `10-conformance-checklist.md`.
