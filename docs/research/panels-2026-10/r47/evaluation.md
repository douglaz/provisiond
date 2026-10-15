# Evaluation under review (a sub-agent's read of the repo at 5acc252; verify every line)

Recommendation: close pv-vwe and park pv-erp. Of the seven candidates, three pass the admission test and
are worth writing: (b), (f) and (g). None was made moot by newer changes.

| | Current owner | Lean today | Composes with | Bad amendment it turns red | Verdict |
|---|---|---|---|---|---|
| a | DOM-10 `01-domain-model.md:513`, PRV-4 `02-provider-contract.md:26` | Nothing ("capabil" has 0 hits in tools/formal) | Nothing that changes an outcome. `Tables.classify` (`Tables.lean:160ff`) already gives `failed` for a pre-dispatch `unsupported` and `needs_reconciliation` after acceptance (ADR-0035) | A gate that lives only inside the driver; both outcomes already safe; v1 has a single driver (ADR-0039) | DECLINE |
| b | PRV-36 max at `02-provider-contract.md:1014-1017`, STO-53 `05-persistence.md:485`, OPS-32 reads it `03-operation-lifecycle.md:1379-1381` | `Reconcile.Windows.visibility` (`Reconcile.lean:101`) is a plain number; its docstring claims the max; nothing computes it | `Reconcile.pastWindow` / `sweepStep` (`:185`, `:217`), beside the `visibilityFromWaitEnd` pair (`Witnesses.lean:1445-1460`) | OPS-32's pre-2026-09-08 "declared": declared 8, observed sample 20, a sweep at 10 records a live machine absent, stops its meter, releases its commitment (`:1383-1388`) | WRITE |
| c | OPS-40 `03-operation-lifecycle.md:639` | Nothing | Only the event order in `Rescue.Install` (`beginRescue`, `Rescue.lean:551`) | "Validate once, at accept": a red pair exists but proves only that an install finishes within its bound; no money; CNF-172 (`10-conformance-checklist.md:3151`) tests both checks | DECLINE |
| d | WIR-45 `13-wire-contract.md:1178` | Only an analogue: `Wire.machineView_independent_of_provider_fields` (`Wire.lean:745`); no abuse-case row | Nothing; generating WIR-37 fixtures was declined, so a Lean case view is a hand-kept copy proved by `rfl` | Adding the provider's case reference to the view, with no gate tying that view to the wire | DECLINE |
| e | STO-17 `05-persistence.md:323` (DOM-4 `01-domain-model.md:82`) | `Reconcile.Candidate` (`:64`), `duplicates_keyed_by_account_and_id` (`Witnesses.lean:1513`) key on account and external id; no model has a tenant | Nothing: no transition holds two tenants' rows; it would restate the database key, which ADR-0025 treats as an assumption | Putting `tenant_id` back in the key (F15); CNF-107 tests it against a real database | DECLINE |
| f | PRV-31 `02-provider-contract.md:526`, stricter after Q25 (`:529-531`, `:549-550`; `ADR-0037:270`) | `Admission.purchaseTail` / `tailAdmitted` (`Admission.lean:1054/1074`) refuse on an `offerSellable` Bool input nothing computes | That input, beside `without_sale_guard_unsellable_offer_is_admitted` (`Witnesses.lean:3672`) | An offer with no bound in either source is sold (F26); only the descriptor checked when the offer reports a later bound; "today or later" replacing "later than today" (Robot's bound is today, so every v1 offer becomes unsellable) | WRITE (the PRV-31 part only; PRV-13b's half stays an input) |
| g | LDG-9 `12-billing-and-ledger.md:224` | `Ledger.Balances.reserved` is the total over all commitments; opening with two commitments is covered (`Witnesses.lean:1645`); a usage debit is capped against the total (`Ledger.lean:112`) and closing a commitment zeroes the total (`:119`); the model's docstring says it omits more than one commitment (`:35`) | `Ledger.step` with `floors_preserved` / `close_releases_exact_remainder` (`:201` / `:173`) | Closing machine A releases B's reserve, or A's overrun is taken from B's reserve | WRITE (Ledger only; `Funding.World.available` stays single-commitment) |

pv-erp: PARK at P4. The QUOTED and EXISTS checks reported "no new findings" (122 Markdown and 107 Lean
quotes compared; 3 known misattributions, all in `11-open-findings.md`). A read-only wrap of the quote
matcher: of 233 calls, 4 had a fragment occurring more than once and none of those had a quote mark in the
quote or its matches, so the union method gives the same verdicts as a per-alternative search on today's
corpus. Not CLOSE (R7a/R8 silently accept corrupted quotes); not DESIGN NOW (nothing exposed). Cheapest fix
if it surfaces: reject loudly when a fragment occurs more than once and a quote mark is present.

pv-vwe: close it; record (a), (c), (d), (e) as declined with the reasons above; file (b), (f), (g) as
standalone beads citing ADR-0025 and the 2026-09-21 comment.
