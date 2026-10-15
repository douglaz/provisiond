Checked at `32c77dc`; gates green (EXIT=0). Scratch: `.scratch-panel.lean`, `.scratch-census.py`.

**Framing.** ADR-0025's rule is "a parameter of the model that carries it". A pair is owed where a model already carries the clause and the bad amendment is a one-token flip; anything else is a model extension. That admits (b) and one unlisted candidate, and declines (f) and (g).

## Verdicts

- **(a) DECLINE, agree.** No model has a capability set. Case for writing: `unsupported` is not admission-only (`Tables.lean:71-73`), so after acceptance it is `needs_reconciliation`; only the pre-dispatch gate keeps it `failed`.
- **(b) WRITE, agree; it is owed.** `OPS-32`: 'this sentence read "declared" until 2026-09-08'. `Reconcile.lean:95-96` quotes the max over a plain `Nat` (`:102`). Composition: `Windows.get` → `pastWindow` (`:185`) → `sweepStep`'s `record` (`:217`). Pair proved in scratch (axioms: `propext`): wait end 0, declared 8, one sample 20, complete unlisted `notFound` sweep at 10. Max: nothing recorded. Declared-only: `authoritativeAbsence`, `meterStoppedAt = some 10`, closed, `live = true`. As written for `OPS-32`'s sentence; a simplification of `STO-53` (samples given, no write path). `Restore.lean:290` takes the elapse as a Bool: out of scope. Cost: a `Windows` reshape (one literal in `Witnesses.lean`), one `Params` field, one `ci.yml` row.
- **(c) DECLINE, agree, wrong reason.** "No money" is not the admission test; `Rescue.lean:27` is: "one event with no clock". Case for writing: the doomed write would show on `Tables.installRow`'s markers.
- **(d) DECLINE, agree.** No case projection exists. Case for writing: `Wire.lean:745`'s shape.
- **(e) DECLINE, agree.** Case for writing: `F15`, money.
- **(f) DECLINE, dissent.** `purchaseTail` is "Snapshot facts only" (`Admission.lean:1028`), and `offerSaleGuard` already has its pair (`Witnesses.lean:3684`, `ci.yml:758`). Nothing downstream is modelled: `Runway.lean:43`, "`prot` is an input". `CNF-166` (`10-conformance-checklist.md:3119`) lists the same three cases. Case for writing: `CNF-166` waits for an implementation; a "bound = today is sellable" theorem runs on every push and catches "today or later" unselling all of v1.
- **(g) DECLINE as specified, dissent.** It is a retyping, not a pair. Scratch, under `Ledger.current`: `[topup 200, open 100, open 50, close]` gives `reserved = 0`; `usageDebit 120` instead gives `deficiency = 0`. Today's tagged `step` already yields both "bad" traces: no one-token flip exists. `Funding.post` clamps against its one subject's `remaining` (`Funding.lean:610`). Cost: every Ledger theorem plus the rendered `Render.ldg31Table` (`Render.lean:171`). Case for writing: two machines per tenant is the normal case, which `Ledger.lean:35` omits.

## New candidates

1. **Q20's failed reread: owed, one token.** `OPS-32`: "a failed direct absence confirmation cannot record absence". `Reconcile.Answer` (`Reconcile.lean:117`) has only `found | notFound`. Add `failed`; the bad amendment is `a = .notFound` → `a ≠ .found` in `sweepStep` (`:216`).
2. **Q22's read-back: the best extension.** `Fence.ofReply` (`Fence.lean:807`) carries `OPS-48`'s first column and maps a successful reply to `(.gone, .succeeded)`. Nothing in `Fence.lean` produces `Settled.scheduled`, so no Fence trace reaches the rendered scheduled row (`Tables.lean:408`). ADR-0039 sells Robot only (`:61`), whose every delete is a dated cancellation with a read-back (`02-provider-contract.md:212-219`): "Read failure does not turn the accepted dated cancellation into `needs_reconciliation` or establish absence". Pair: dated acceptance, read-back fails. Guard: `scheduled`, fence kept. Without it (ADR-0037's rejected '"`now` is immediate" constant', `:229`): gone-write, fence cleared, machine present. Like (g) it changes a type (`Fence.lean:95` omits "evidence gathering"); unlike (g), a dated amendment added it and a rendered table already holds its row.

Q28 is paired (`Witnesses.lean:3887`); a conjunct catches Q26 (`:3047`). Q24, Q25, Q29: no model carries the clause.

## pv-vwe, pv-erp

- **pv-vwe: (b) as a child; close when it lands.** It is an M5 miss (M5 names `PRV-36`). Q20 and Q22 are standalone beads citing ADR-0025. No gate enforces the rule; (b) and Q20 are its misses.
- **pv-erp: PARK, after copying the cases in.** At HEAD: 131 Markdown and 107 Lean quotes, 242 matcher calls, 4 multi-occurrence, none with a mark. The guard as phrased breaks a passing self-test: `"the rows' values remain positive"` (`check_citations.py:679`, `:797`) recurs with an apostrophe and must stay accepted. The bead's R7a/R8 cases sit in a Run directory the repository does not hold.

## Strongest don't-build

The ADRs record who found the last round's gaps: rloop Managers (Q25, Q26) and two live sessions (ADR-0041). A pair fires only when the amender edits the Lean, and (b), (f), (g) guard regressions nobody proposes.

## Evaluation defects

- `evaluation.md:1` read `5acc252`. Stale: `DOM-10` is `01-domain-model.md:515`; the max `02-provider-contract.md:1053-1056`; `PRV-31` `:544` (Q25 at `:547-549`, `:567`); `WIR-45` `13-wire-contract.md:1183`; `beginRescue` `Rescue.lean:568`; the sale witness `Witnesses.lean:3684`.
- `:8` "v1 has a single driver (ADR-0039)" is false: `0039:62`, "The Cloud and DigitalOcean drivers stay specified".
- `:12` "no model has a tenant" is false: `Types.lean:16`, `Funding.lean:187`.
- `:14` swaps the comment's bad amendment ("subtracting one of two commitments"); "opening with two commitments is covered" is wrong, since under `current` the second open is refused (`Witnesses.lean:1652`); omits `Render.lean:171`.
- `:16-21` counts stale (122, 233); the guard collides with a self-test.
