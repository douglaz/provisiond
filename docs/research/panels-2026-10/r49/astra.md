**AMEND WITH CHANGES**, reviewing `5407f68`.

ADR-0025 requires “a parameter of the model” and the refused/admitted witness pair; the `current` mutation and single-refutation mechanics live in CI (ADR-0025:118; `.github/workflows/ci.yml:266,843`). I found no necessity-based permission in ADR-0025, AGENTS.md:13–17, CONTEXT.md:440–450, or README.md:139–189. AGENTS calls weakening “a semantic change like any other”; it does **not** itself prescribe owner approval for every such change. The allowance also survives in the repository’s tracker, not solely run instructions (`pv-0uk`, comment 330); the reported removals are recorded in comments 407 and `pv-f6g` comment 562.

The census (reader scratch file `census.md`, not kept), cross-checked against Lean’s elaborated signatures, finds **142 theorems** carrying enabled-setting hypotheses: **141** on parameter fields, plus `Rescue.Install.overtaken_unguards` on `Claim.current.claimTerm` (`Rescue.lean:866`). This includes `Rules`, enum settings, and current settings of `false`; three disabled-only theorems are excluded.

The proposed necessity standard is not universally met. I proved these existing statements without `allCommitmentsAuthorize`, preserving their conclusions and other hypotheses:

- `Ledger.open_authorized_at_commit_single` (`Ledger.lean:645`).
- `Ledger.floors_preserved_single` (`Ledger.lean:652`).
- `Ledger.open_against_read_is_the_serialized_open_single` (`Ledger.lean:944`).

The checked proofs (reader scratch file `Probe.lean`, not kept) exploit agreement between first-slot and total reservations on one commitment. Conversely, `run_floors_single` needs the guard: subsequent opens create multiple commitments (checked counterexample (reader scratch file `Necessity.lean`, not kept)). The first two recovery theorems have no individual docstrings; neither does `ProviderTraffic.fresh_claim_reuses` (`ProviderTraffic.lean:75`). Strictly, the recovery declarations were introduced with their premises, so wording limited to existing theorems that “gain” hypotheses would miss them (`0ca996c`).

Prefer a checked counterexample in `Witnesses.lean`, reusing an existing witness where it establishes the exact necessity. It must satisfy the retained hypotheses and falsify the conclusion. A failed build after deleting a hypothesis establishes neither: even an unnecessary premise may be referenced by the proof script. ADR-0025:146 explicitly rejects evaluation failure as refutation; its witness rationale keeps witnesses and theorems on shared definitions (150–152).

Put the rule **only in ADR-0025**; AGENTS already points there and says “One rule, one home” (AGENTS.md:14,33). For fixed definitions, adding a premise weakens the universally quantified statement; preserving its `current` specialization does not preserve every instance. That follows the glossary’s “under its stated assumptions” (CONTEXT.md:448).

Suggested amendment:

> **2026-10-14, Q32.** When an authorized model extension introduces a guard, a retained generic theorem MAY add that guard’s current-setting hypothesis only if the otherwise unchanged statement is false without it. Retain a checked counterexample under the same model definitions, satisfying every remaining hypothesis and falsifying the conclusion; reuse an existing witness where sufficient. The theorem’s docstring names the hypothesis and witness. Preserve its identity, conclusions, other hypotheses, and current-setting property. Removing hypotheses while retaining a checked proof is permitted. This exception authorizes no other weakening or change of model meaning.

**Strongest case for the other side (written on request)**

No amendment is needed: parameterization deliberately introduces counterfactual models; the enabled premise identifies the original model’s embedding. ADR-0025 already exposes assumptions, and CI explicitly expects generic theorems to survive guard flips. Requiring necessity evidence for each theorem may add maintenance work without improving the intended current-policy property (ADR-0025:64,118; `.github/workflows/ci.yml:268`).

Both required gates passed; tracked files remained unchanged (evidence (reader scratch file `review-evidence.md`, not kept)).