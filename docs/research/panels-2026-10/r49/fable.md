**Gate at `5407f68`:** `nix develop --command bash tools/check-all.sh`, unpiped, exit 0. No tracked file changed. Scratch left in the clone: `.scratch_hyps2.py`, `.scratch_gate.out`.

**1. Facts.** ADR-0025 never says whether a new guard's hypothesis weakens a theorem, but it already owns the shape: a guard "is a parameter of the model that carries it" (`docs/adr/0025…:118`) and what is not Lean's "enters as a hypothesis, never an axiom … so a signature shows the dependence" (`0025:64`; `CONTEXT.md:441-443` "A theorem's signature shows what it assumes"). The reason is recorded three times: `.github/workflows/ci.yml:432-433` "Fence.lean's own theorems take each guard as a hypothesis and stay green", `Fence.lean:1619-1620` "each a hypothesis, so that a flipped key reddens its witness and not this theorem", `Rescue.lean:860-863`. The row loop at `ci.yml:853` requires exactly one red, so a theorem stated at `current` without the hypothesis would break its row. `AGENTS.md:14-17` and README's conventions add nothing.

Counts (binder shape `(h : p.F = v)`, script `.scratch_hyps2.py`):

| at `5407f68` | n |
|---|---|
| `theorem` declarations | 765 |
| carrying a guard hypothesis | 139 |
| pinned to a non-current value | 3 |
| proof-unused (Lean warning) | 0 |

All 139 are proof-used: a fresh full build emits zero `unused variable` warnings, and Lean 4.30 does emit one for an unused theorem hypothesis (scratch probe). "Enabled" is the wrong word: `Admission.lean:331` and `Rescue.lean:96` are current-`false`, and their theorems pin `false`. The three non-current pins are in-module admitted-without halves (`Claim.lean:284`, `Fence.lean:570`, `Runway.lean:123`). The three the brief names are false without the hypothesis: a scratch `decide` shows each conclusion fails on the pair's own trace with the guard off, and those traces are `Witnesses.lean:1609`, `:1887`, `:1868`. Docstrings: only `Reconcile.lean:345` names the field; `Ledger.lean:478` and `:521` say "the added own-close/aggregate-authorization hypothesis"; 20 of 139 have no docstring at all.

**2. Checkable?** Yes, by what exists. The counterexample is the guard's admitted-without witness, which `0025:118-120` already requires and `ci.yml` already flips; in all three cases it refutes the hypothesis-free statement. "Pinned to `current`'s value" is a twenty-line grep with three known exceptions. A CI mutation that deletes hypotheses is new machinery for a property the witness already carries, and a docstring restating the signature is the second copy `AGENTS.md:26-28` warns of.

**3. Where.** The shape is not a weakening: the set's claim is `P current`, unchanged, and the lost instances are configurations the set refutes by witness. The real weakenings are a pin to a non-current value or a non-guard premise, and the repository already records the latter as a narrowing by its owner: `docs/adr/0033…:88-96` for `initial.prepaid = none`, pv-f6g item 2 for `hi`. One sentence under ADR-0025's guard bullet; AGENTS.md keeps the general rule.

**4. Vote: AMEND WITH CHANGES.** Append to `0025:118`:

> *Amended 2026-10-14 (Q32): a theorem over the record may take a guard pinned to its `current` value as a hypothesis; that is how a `ci.yml` row reddens one witness and not the theorem (`Fence.recheck_proceeds`'s docstring), and the guard's admitted-without witness is the counterexample showing the hypothesis is needed, named on the ticket. A pin to another value states a withdrawn configuration (`Runway.runway_early_without_the_start`). Any other added premise narrows the theorem and is recorded by its owner, as `ADR-0033`'s formal scope note records `initial.prepaid = none`.*

Changes from the owner's wording: "enabled" becomes "pinned to `current`", the docstring clause and the forbidden-change list go (AGENTS.md owns them), and "recorded (where?)" is answered with the witness.

**5. Strongest case for the other side (written on request).** NO AMENDMENT. The rule and its reason already stand at `ci.yml:432`, `Fence.lean:1619`, `Rescue.lean:863` and `CONTEXT.md:443`, and `0025:64` generalizes them; a fifth copy is the drift `AGENTS.md:22-24` records for `SEC-46`. The checks exist today: zero unused-hypothesis warnings, one witness per guard, one red per row. "Only where false without it" is a Manager's working rule that caught six cases inside Runs, and the Run instruction is its home, not a decision record.
