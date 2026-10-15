I recommend **AMEND WITH CHANGES**: the rule belongs in ADR-0025, with only a pointer in AGENTS.md. The gates are green at `5407f68`, and I edited no tracked file.

**1. Facts**
- **Nothing in the repository answers it.** ADR-0025 never uses the word "weaken". AGENTS.md:16 says only "a semantic change like any other". It says neither "needs the owner" nor "forbidden", although pv-f6g's description (`3639a80`) attributes "forbidden" to ADR-0025.
- **The allowance is committed, not just in your rloop instructions.** Bead comment 327 says "keep the guarantee for Reconcile.current", and comments 328–330 say "keep … the guarantee for the current setting". Your wording drops that clause, and it is the actual argument.
- **The shape is structural.** Theorems "take each guard as a hypothesis and stay green" (ci.yml:268-270, 432-434).
- **Inventory.** 144 theorems carry 228 guard-field hypotheses. In 141 of them (225 hypotheses), `current` satisfies every one. The other 3 are the "without" halves of witness pairs: `Claim.repeat_refused_without_branch`, `Fence.paused_grace_unguarded`, `Runway.runway_early_without_the_start`.
- **22 hypotheses (on 21 theorems) were added to theorems that already existed.**
  - *Needed — I checked 5.* With the hypothesis dropped, `decide` refutes `close_releases_exact_remainder`, `open_authorized_at_commit`, `floors_preserved` and `absence_requires_three`, each using an existing without-witness's inputs (Witnesses.lean:1887, 1868, 1609). Witnesses.lean:1131 directly contradicts `quarantine_before_first_claim`. Comment 326 records the counterexample for the three Reconcile theorems. The other 17 are unchecked.
  - *Not named in the docstring (neither the hypothesis nor its guard is mentioned) — seven:* Restore.lean:677, 735, 802, 840; Fence.lean:1220, 2055; and Fence.lean:2014's `hk`.
  - *Docstring cites the refuting witness:* none of the 22.
- **`2d2a0d0` removed 12 binders:** 6 on four tagged theorems and 6 on their `_single` copies.

**2. Is "only where false without it" checkable?** Not by a linter or a mutation.
- All 12 removed binders were referenced by their proofs (`0ca996c`), and a clean build gives 0 unused-variable warnings. So the linter can't catch an unneeded hypothesis.
- A CI row that deletes the hypothesis and expects a red build goes red on true statements too, because it tests the proof script.
- What already exists is the "admitted without it" witness, which `decide` checks and a CI row red-controls (0025:118-120). In every case I checked it is the counterexample, so the docstring should cite it.
- Where a witness contradicts no conclusion directly, add an 8-line `decide` refutation (examples in `scratch/Refute.lean`).
- The ticket is the wrong place for the counterexample: the bot can't read it.

**3. Where it belongs**
- A guard hypothesis that `current` satisfies weakens nothing the set claims. A red theorem signals an amendment that "contradicts a property the set claims" (AGENTS.md:15). That property is the theorem at `current`, where the hypothesis discharges by `rfl`.
- Nor is it an assumption, which is "What is not Lean's to carry" (0025:64); `current` carries guards.
- So no existing text covers it. The amendment extends 0025:66-67's "a signature shows the dependence" to this kind of hypothesis.
- Its home is ADR-0025. AGENTS.md gets only a pointer ("Arguments have owners too", AGENTS.md:36).
- "New guard" must not mean "dated": the ledger guards are "rule undated" (ci.yml:521-524).

**4. Vote: AMEND WITH CHANGES.** In ADR-0025, after the guard bullet:

> *Amended 2026-10-14 (Q32):* A theorem quantified over the record takes the fields it needs as hypotheses, so a `ci.yml` row reds only its own witness. The set's claim is the theorem at `current`, so a hypothesis `current` satisfies is not a weakening. One added to an existing theorem must be one without which the statement is false; its docstring names it and cites the witness refuting the statement without it. Removing an unneeded hypothesis is always allowed. Adding any other hypothesis to an existing theorem, or narrowing its conclusion, is the weakening `AGENTS.md` describes.

Append to AGENTS.md:16: "(`ADR-0025` says which guard hypotheses are not)".

What this changes from your wording:
- It covers every field, dated or not.
- It drops "renamed" and "needs the owner".
- It puts the counterexample in the witness layer.

Cost: nothing is retroactive, and each future addition needs one citation. Fixing the seven docstrings is optional.

**5. Strongest case for the other side (written on request): NO AMENDMENT.**
- AGENTS.md already treats weakening as a reviewed "semantic change", not a ban, and the docstrings show readers handling it: Funding.lean:1264 says "`hk` is the statement's scope, not a weakening", and Reconcile.lean:345 names its added hypothesis.
- Licensing one shape implies every other shape is banned — a universal that "one counterexample retires" (AGENTS.md:41).
- The defect was in a run instruction (comment 327: "the conflict was in the caller's instruction"). So the fix belongs in the work order, where it already lives.

The scratch files are untracked inside the clone: `scratch/` (the inventory and refutation scripts plus their output), `scratch-gate.log` and `scratch-beaddiff.py`.
