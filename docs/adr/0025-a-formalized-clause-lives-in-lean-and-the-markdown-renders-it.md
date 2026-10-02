# A formalized clause lives in Lean, the Markdown requirement renders it, and a proof is never conformance

**Status:** accepted (2026-09-13; proposed 2026-09-12 by `lean-01.md`, decided after two independent
readers of one brief — Codex at xhigh and a fresh Fable reader — each ran Lean 4.30.0 from `flake.nix`
and proved the first theorems before answering). The first modules are `tools/formal/`; the gate that
runs them joins `tools/check-all.sh`. Amended 2026-09-19 with the wire-fixture decision under
*Scope*, and 2026-10-01 (`pv-vwe.28`) with the deletion of the tactic sentence under *Trust
policy*. Does not amend `ADR-0001`: the formal layer describes and checks the system and
implements none of it.

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
  a third copy. **The rendering gate (`tools/check_regions.py`) and the resolver for backticked
  `Provisiond.*` names (in `tools/check_citations.py`) landed 2026-09-15 with the closed tables**;
  `OPS-48`'s table, `DOM-31`'s diagram, `LDG-38`'s worked examples and `LDG-31`'s worked table are
  the first marked regions (`lake exe render` prints the list), and inside each the declaration is authoritative and the Markdown
  renders it. Every other formalized clause is still under the transitional rule above until its
  region is marked. A `match` region — a table whose rows carry prose — is diffed on the tokens the
  declaration determines; the prose beside them stays the document's, where the citation gates read
  it.
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
  The policy is what `Gate.lean` enforces; which tactic closes a witness is the proof's own choice.
  *Amended 2026-10-01 (`pv-vwe.28`): the sentence "Witnesses over rationals close by
  `decide +kernel`" is deleted, and with it the exception list that `Witnesses.lean`'s docstring
  kept against it — the witnesses a `ci.yml` Params row must see refuted, which close by a
  different tactic. That list was a second home for a rule `docs/adr/` owns. The rejected
  alternative is under *Considered options*.*
- **No Mathlib.** Every theorem proved so far closed on core Lean. Mathlib is added only in a
  commit that names the theorem that cannot be closed without it.
- **The gate runs with the others, on every push.** `lake build` and `lake exe gate` join
  `tools/check-all.sh` under `nix develop --command`; `nix flake check` builds them too. Each check
  has a negative control in `ci.yml` on `DEF-16`'s model, and `ci.yml` holds the list. The
  claim-term control landed with the claim model on 2026-09-14; the rendered-region and
  dangling-name controls landed with the rendering gate on 2026-09-15.
- **`check_arithmetic.py` is deleted.** The Lean gate is required in CI from its first commit, so
  the condition was met the day it was written. Two encodings of one formula are the second copy
  `AGENTS.md` forbids, and the Python one was the weaker; its last property without a theorem, the
  single-corruption bound, landed as one before the deletion.
- **Scope is the full inventory, in this order.** Arithmetic and historical witnesses (`LDG-33`,
  `LDG-38`, `OPS-41`); the claim model (`ADR-0022`); the cancellation fence composed on it
  (`OPS-41`, `OPS-42`, `LDG-62`, `OPS-48`); the closed tables with the rendering gate (`OPS-11`,
  `OPS-48`, `DOM-31`); then reconciliation and restore, funding and the tenant lifecycle, rescue and
  install, wire canonicalization and redaction. Wire fixtures were decided after the tables proved
  the rendering mechanism. The fence is not built before the claim model: without the rate-outage
  branch, the tenant's current suspension state and the episode, a fence model proves a false
  requirement. *Amended 2026-09-19: wire fixtures are not generated, and the precedence rule in
  `13-wire-contract.md`'s opening paragraph stands unamended because no generated shape exists to
  register. The rendering gate removes a copy because every token it diffs is one the declaration
  determines — `Provisiond.Render.ldg31Table` is computed whole, and in
  `Provisiond.Render.ops48Table` the keys and steps are listed by hand while the outcomes beside
  them are computed and the coverage theorem holds the list complete. A fixture's values are
  determined by nothing in Lean:
  `WIR-37` asks for "full UUIDs, `Z`-suffixed timestamps, 64-hex digests", which are chosen, and
  would enter Lean as the same literals inside a string, a copy relocated rather than removed. The
  wire module holds `Json` as a value — canonicalized, redacted, never serialized; there is no
  `Json → String` — and two projections: `Provisiond.Wire.operationView`, with `WIR-10`'s field
  list but ids and timestamps as naturals and its enumerations unspelled, and
  `Provisiond.Wire.machineView`, two fields of the many `WIR-11`'s example carries. No other
  example has a type beyond `Json`.
  Emitting bytes would therefore need a serializer, formatters for ids and timestamps and a wire
  spelling for every enumeration, each a second copy of a convention the wire document already
  states and `tools/check_fixtures.py` already parses; and the projections' independence theorems
  hold for every row, so a rendered row proves nothing they do not. `lean-01.md` proposed the
  generation; this is the evidence it waited for. The decision reopens if a serializer lands for a
  reason of its own.*
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

**Widening `ci.yml`'s row check to accept "did not reduce"** so that every witness could keep one
tactic. Rejected 2026-10-01 (`pv-vwe.28`): a term that fails to evaluate is not a refutation.

**A model checker instead of a proof assistant for the lifecycle models.** Considered, since every
contested question here was settled by executing a negative witness. Not adopted as a second tool:
bounded traces are enumerated by `decide` in the same files the invariant proofs live in, so the
witness and the theorem share one set of definitions and cannot drift from each other.

## Consequences

- `tools/formal/` with `lean-toolchain`, `lakefile.toml`, `Provisiond/Req.lean` (the attribute),
  one module per model under `Provisiond/` — `Provisiond.lean`'s imports are the list, and the
  wrapper refuses a module missing from it — `Gate.lean` (the axiom check and the index) and
  `Render.lean` (the marked regions, from `Provisiond/Render.lean`). `tools/check-all.sh` runs
  the build and the gate first, then the document gates that read the index;
  `ci.yml` gains
  the negative controls; `flake.nix`'s check builds them.
- `CONTEXT.md` gains **specification gate**, **witness**, **model**, **assumption** and
  **property**; *oracle* stays on **Rate**'s avoid list, and **reference model** was added on
  2026-09-14 with the claim model, the first lifecycle model.
- `README.md`'s gates table gains the Lean row and its ADR table this row; `AGENTS.md` names the
  shell the gates need.
- `tools/check_arithmetic.py` is deleted with its `check-all.sh` row, its `ci.yml` control and its
  README row.
- `11-open-findings.md`: `F52`'s open sub-decision — whether tenants are told a restore interval is
  running — closes as *no notice*, a dated clause on `STO-54`'s unrepaired list, which carries the
  reasons.
