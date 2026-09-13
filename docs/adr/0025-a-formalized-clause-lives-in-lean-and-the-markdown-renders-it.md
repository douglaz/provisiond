# A formalized clause lives in Lean, the Markdown requirement renders it, and a proof is never conformance

**Status:** accepted (2026-09-13; proposed 2026-09-12 by `lean-01.md`, decided after two independent
readers of one brief — Codex at xhigh and a fresh Fable reader — each ran Lean 4.30.0 from `flake.nix`
and proved the first theorems before answering). The first modules are `tools/formal/`; the gate that
runs them joins `tools/check-all.sh`. Does not amend `ADR-0001`: the formal layer describes and
checks the system and implements none of it.

## The problem as found

`README.md`'s gates read the documents; one, `tools/check_arithmetic.py`, executes two formulas. On
2026-09-12 three defects landed that passed every gate and two readers because each citation
resolved while the consequences contradicted: `LDG-38` described its period reset as "in the
customer's favour" when `r ≥ 0` makes the reset charge more on every input; `STO-12` required one
migration per transaction while `STO-13` required `CONCURRENTLY` index builds, which PostgreSQL
refuses inside a transaction block; `STO-54` and `ADR-0023` called a one-interval grace "what stands
between the restore and the destroyed disk". `F52` records them. `lean-01.md` found them by asking
what each rule *implied* rather than what it *cited*, and proposed that a checker do that.

The arithmetic gate, as it stood that day, was narrower than its labels: floating point with a
`1e-9` tolerance, an 11×40×40 box for the runway predicate, 3,000 random trials for the recurrence,
a one-step corruption check, and no increment that crossed a billing-period boundary — the boundary
`F52`'s first defect was about.

Two readers put to one brief, "use Lean for pretty much everything we can", converged on what that
is, and each ran exploratory Lean before answering. Both proved `LDG-38`'s four core theorems —
`0 ≤ r`, `r < 1`, a nonnegative posted debit, and `F52`'s reset direction — on core Lean's
`Std.Rat` with no Mathlib, under the standard axioms; those are landed in `tools/formal/`. Both
also proved, in scratch files that are not landed, `ADR-0022`'s stale-defer trace refused with the
claim term and admitted without it; that model is the inventory's second item. Both found the
withdrawn `usable_sats > 0` predicate as an executable witness. One found that `decide` alone gets
stuck on rational equalities and reached for `native_decide`; the other closed the same witness with
`decide +kernel` under the standard axioms, which settles the trust question below by evidence.

## The decision

- **Authority is per clause, and a formalized clause's home is its Lean declaration.** A
  calculation, a predicate or a closed table that the formal layer carries is defined once, in
  `tools/formal/`, on a declaration tagged `@[req "LDG-38"]` with the identifier it formalizes. The
  Markdown requirement keeps its identifier, its MUST, its rationale, its amendment record and its
  retained traps — those are not formalized — and its rendered formula or table is a copy of the
  declaration. Until the rendering gate below lands for a clause, the Markdown stays authoritative
  and the Lean is a checking interpretation, which is `check_arithmetic.py`'s standing precedent.
- **The rendering is kept honest by a gate, not by discipline.** A region between markers in a
  requirement is either generated from the declaration — pure computation, such as a worked table —
  or diffed against what the declaration emits, where the region carries prose or citations a
  rewrite would erase. Drift is a red gate. The index that gate will read is already emitted from
  the `@[req]` attributes by `lake exe gate`; there is no hand-kept manifest, because a manifest is
  a third copy. **The rendering gate and the resolver for backticked `Provisiond.*` names are owed
  with the inventory's fourth item, the closed tables, and until they land no requirement carries
  a marked region or cites a declaration by name** — the transitional rule above holds for every
  clause.
- **A theorem is never conformance.** `tools/check_coverage.py` counts conformance items and
  nothing from the formal layer; a `CNF` identifier does not appear in `tools/formal/`. A proof is
  about the model under its stated hypotheses; a conformance item is about a running implementation.
  Nothing here changes the README's "Nothing here has been validated against a running
  implementation."
- **What is not Lean's to carry enters as a hypothesis, never an axiom.** Provider behaviour
  (`PRV-36`'s window), PostgreSQL's semantics, and `OPS-47`'s "a deployment obligation and not a
  property this specification enforces" are named parameters on the theorems that depend on them, so
  a signature shows the dependence. A model that omits a second engine says so in its docstring.
- **Trust policy, enforced by the gate.** Every `@[req]` declaration may depend on `propext`,
  `Classical.choice` and `Quot.sound` and on nothing else; `sorryAx` is refused transitively;
  the project declares no `axiom`; `native_decide` is refused everywhere under `Provisiond.*`
  except the `Provisiond.Explore` namespace, which may hold nothing tagged — Lean 4.30.0 mints a
  fresh per-declaration axiom for it that an old-name blacklist would miss, so the gate matches the
  axiom's shape, not a name. An untagged declaration outside `Explore` is otherwise unconstrained.
  Witnesses over rationals close by `decide +kernel`.
- **No Mathlib.** Every theorem proved so far closed on core Lean. Mathlib is added only in a
  commit that names the theorem that cannot be closed without it.
- **The gate runs with the others, on every push.** `lake build` and `lake exe gate` join
  `tools/check-all.sh` under `nix develop --command`; `nix flake check` builds them too. Each check
  has a negative control in `ci.yml` on `DEF-16`'s model, and `ci.yml` holds the list. Two more
  are owed with the modules they exercise: the claim term deleted (the claim model) and a rendered
  region edited (the rendering gate).
- **`check_arithmetic.py` is deleted.** The Lean gate is required in CI from its first commit, so
  the condition was met the day it was written. Two encodings of one formula are the second copy
  `AGENTS.md` forbids, and the Python one was the weaker; its last property without a theorem, the
  single-corruption bound, landed as one before the deletion.
- **Scope is the full inventory, in this order.** Arithmetic and historical witnesses (`LDG-33`,
  `LDG-38`, `OPS-41`); the claim model (`ADR-0022`); the cancellation fence composed on it
  (`OPS-41`, `OPS-42`, `LDG-62`, `OPS-48`); the closed tables with the rendering gate (`OPS-11`,
  `OPS-48`, `DOM-31`); then reconciliation and restore, funding and the tenant lifecycle, rescue and
  install, wire canonicalization and redaction. Wire fixtures are decided after the tables prove the
  rendering mechanism. The fence is not built before the claim model: without the rate-outage
  branch, the tenant's current suspension state and the episode, a fence model proves a false
  requirement.
- **Every guard that a dated amendment added is a parameter of the model that carries it**, and the
  module holds two theorems: the bad trace is refused with the guard and admitted without it. A
  successful proof without the second theorem is decoration.

## Considered options

**Lean is authoritative for everything, Markdown cites it.** Rejected: the citations gate cannot
read Lean, most of the set is prose no checker can carry, and a requirement is more than its formula.
Authority per clause keeps the identifier, the MUST and the traps where the gates can see them.

**Markdown stays authoritative and Lean is only a gate**, the arithmetic precedent extended. The
transitional rule, kept for every clause until its rendering is gated. Rejected as the end state
because two hand-kept copies drift — `SEC-46` is the record — and only generation or a diff makes the
second copy free.

**A separate repository.** Rejected: the gates lived in a scratch directory once and "ceased to
exist without anyone noticing" (`README.md`); a check that guards this set lives with it.

**A hand-kept `requirements.json` mapping ids to declarations**, `lean-01.md`'s proposal. Rejected as
a third copy, and because a `conformance:` key naming `CNF` ids is one regex away from being counted
as coverage.

**Mathlib from the first module.** Rejected on evidence: nothing proved so far needed it, and it
costs a multi-gigabyte cache, minutes of CI and an exact-tag coupling to the Lean version.

**`native_decide` for witnesses.** Rejected under `@[req]` once `decide +kernel` was shown to close
the same witnesses under the standard axioms.

**A model checker instead of a proof assistant for the lifecycle models.** Considered, since every
contested question here was settled by executing a negative witness. Not adopted as a second tool:
bounded traces are enumerated by `decide` in the same files the invariant proofs live in, so the
witness and the theorem share one set of definitions and cannot drift from each other.

## Consequences

- `tools/formal/` with `lean-toolchain`, `lakefile.toml`, `Provisiond/Req.lean` (the attribute),
  `Provisiond/Runway.lean`, `Provisiond/Meter.lean`, `Provisiond/Witnesses.lean`, and `Gate.lean`
  (the axiom check and the index). `tools/check-all.sh` runs the build and the gate; `ci.yml` gains
  the negative controls; `flake.nix`'s check builds them.
- `CONTEXT.md` gains **specification gate**, **witness**, **model**, **assumption** and
  **property**; *oracle* stays on **Rate**'s avoid list, and **reference model** is added when the
  first lifecycle model exists to name.
- `README.md`'s gates table gains the Lean row and its ADR table this row; `AGENTS.md` names the
  shell the gates need.
- `tools/check_arithmetic.py` is deleted with its `check-all.sh` row, its `ci.yml` control and its
  README row.
- `11-open-findings.md`: `F52`'s open sub-decision — whether tenants are told a restore interval is
  running — closes as *no notice*, a dated clause on `STO-54`'s unrepaired list, which carries the
  reasons.
