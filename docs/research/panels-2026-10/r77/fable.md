# fable — r77 Panel B

Pin verified: my clone's HEAD is `1fc54e8f361e4a9342359388314d32c398595f62`; every excerpt the brief quotes matches the file at the cited lines.

## 1. Q1 — pv-ymjo

**Y-WIDE: AMEND. Y-PROV: AMEND. Final preference: Y-PROV.** Both need the same four common-text repairs below; nothing Y-PROV-specific needs repair, and Y-WIDE's extra paragraph is internally consistent but wrong on the merits.

**Reason for Y-PROV.** WIR-9a's rule is about rollback, in its own words: "Neither key is rendered from markers a restore may have rolled back", and STO-54's owner sentence is about a row restored "with its `OPS-45` markers as the backup holds them". A row admitted after step (3) was in no backup. OPS-45 says each marker write is "acknowledged by the store before the provider call it precedes is made", and CONTEXT.md's Restore entry says "a restart loses no acknowledged commit". So a fresh row's null marker after a process crash means exactly what it means on an ordinary restart: the phase did not begin. WIR-9a's own justification does not reach fresh rows either. It says `none` "would tell the caller the opposite of what the operator is told about the same row", but STO-54 tells the operator to resolve as ambiguous only "a `running` install found after a restore ... as the backup holds them". Y-WIDE admits this: "including where no restore rolled back that row's markers". It then renders identical facts differently depending on whether the operator has yet closed the record, which STO-56's close conditions can hold open for an interval or more, and it sends `rescue_address` and `rescue_port` with `unknown` for a machine never rebooted into rescue, against OPS-45's "Null is the only value that means no session was opened", with no staleness to excuse it.

**Mechanics checked.** The common initialization happens in "the acknowledged transaction that establishes the restore record", which STO-54 requires before either component starts, so it is early enough. It survives every successor (the column "MUST NOT be cleared") and a second actual restore ("applies the initialization again"). A process crash is not treated as rollback under Y-PROV. Rescue companion fields agree: `unknown` "retains the address-and-port requirements above". The table, the rescue-inventory cells and the conformance text agree with each package's rule. No checked verdict changes under either package: CNF-302's restore step concerns an old row, which both render `unknown`, and no CNF item or Lean theorem covers a fresh row. `Rescue.rescueExit`, tagged WIR-9a, renders from the column alone and models neither the existing restore paragraph nor the Boolean, so the Lean layer is untouched by both. With no verified blocker, the choice is policy and returns to the owner.

**Exact repairs (common text, both packages).**

A1, behaviour changed. Location: common STO-54 paragraph, sentence beginning "On each actual store restore". Before: "on every surviving install or rescue-inventory row whose status is `queued`, `running` or `needs_reconciliation`". Replacement: "on every surviving install or rescue-inventory row whose status is `queued` or `running`". Why: a row already `needs_reconciliation` in the backup has no later marker write, since OPS-45 says "a settled or unresolved record is no longer re-run (`ADR-0017`)", and it is moved by neither the quarantine nor the pass, so today it renders ordinary values. The packages would flip CNF-300's case "`needs_reconciliation`, `retryable: false`, `disk_effect: "none"` ... and `rescue_exit: "unknown"`" to `unknown`/`unknown` after any later restore. No CNF item asserts that rendering after a restore, so this is a hidden baseline loss and not a verified blocker. The brief's disclosure covers only the marking of "surviving unsettled" rows, not this consequence.

A2, wording, behaviour unchanged. Location: the STO-54 running-install replacement. Before: "with its `OPS-45` marker columns as the backup holds them. See the marker-provenance rule above and `WIR-9a` for rendering;". Replacement: "with its `OPS-45` marker columns as the backup holds them, so a null marker there does not mean the disk is untouched and the operator resolves such a row as ambiguous; the marker-provenance rule above records that, and `WIR-9a` renders from it;". Rule 5: the printed replacement deletes the operator instruction without preserving it anywhere.

A3, behaviour changed, owner policy. Location: common paragraph. Before: "Rows predating the column for which provenance cannot be established MUST initialize true". Replacement: "A pre-column install or rescue-inventory row MUST initialize true where it is `queued`, `running` or `needs_reconciliation` when the migration runs, and false where it is settled". The printed predicate is undecidable; read strictly it flips every historical failed install to `unknown`. Disclosed cost of my form: a settled pre-column row resolved out of an earlier quarantine renders ordinary values thereafter.

A4, wording, behaviour unchanged. Before: "Another actual restore applies the initialization again, including when an earlier incident was still open." Replacement: "Another actual restore applies the initialization again, under `STO-56`'s one-open-record rule." STO-56 says "at most one row may have `closed_at` null".

**Cost, reported separately.** One bulk update over unsettled install and rescue-inventory rows inside the record transaction, with every component stopped (STO-54's 2026-10-24 lead-in). Bounded by in-flight work, so latency is negligible. Migration is an add-with-default under ADR-0024. A3's upgrade treatment hides legacy facts only for rows unsettled at the migration.

## 2. Q2 — pv-8mt4

**M-S: AMEND. M-I: ACCEPT. Final preference: M-S.**

**Checks I ran, on my own `lake build` of the pin.** The scratch probe compiles unchanged, exit 0, all seven cells and both equality theorems. Integrating the printed nested `stepS` branch breaks eleven proof scripts in `Restore.lean`, none of them `successor_sweeps_running`: `step_create_not_failed`, `step_safe_restart`, `step_quarantined_restore`, `step_gen_restore`, `step_absence_restore`, `step_parent_restore`, `step_parent_any` and their dependents. Every failure is a `split` that handled one `if`; the new branch changes only `passDone`, so each statement still holds. Written as an else-if, the same function breaks seven scripts; I repaired each with one extra `split` or `(try split)`, and the full build plus `lake exe gate` is green. I proved the two shapes equal for every parameter, world and event (`panel-logs/shape-eq.lean`, exit 0). The old negative witness with its conjunct changed to `passDone = true` proves by `decide`. The new progress pair proves by `decide` with the brief's cells. The CI flip of `passEveryStartup` in `current`: with the positive progress witness on `startupPassGuards Restore.current` the build has two reds, and `ci.yml:918` fails any row with "more than one red"; with the witness pinned to `restoredWorkParams` it has exactly one red, at `Witnesses.lean:1422`, whose context names `postStepTwoPower`. Not run: M-I's repository and CI integration beyond the probe's four cells; repairs for the nested shape.

**M-S amendments, all behaviour unchanged.** (i) The positive progress witness uses `restoredWorkParams`, not `startupPassGuards Restore.current`, as `fresh_work_swept_after_restore` already does. (ii) The seven proof-script adaptations above, statements untouched. (iii) Integrate the branch as `else if w.locked && !w.passDone then { w with passDone := true }` after the existing `if`, proven equal to the printed shape, or accept eleven adaptations instead. The old `passDone` gate protected OPS-15's "before any claim". In the good model that meaning is unchanged, by `S_current_step_eq`. In the mutant it now means "handling complete", which is faithful: OPS-15 only says the engine "MUST log the count it found", so nothing in the system records that the sweep ran.

**M-I.** Mechanically sound: `I_required_step_eq` is all-state, the four cells compute, and the equality theorem guards the duplicated claim branch against drift. But it reaches the harm only with both guards off, so the stranded-plus-progress witness refutes "before any claim" together with "runs at every startup", and the harm cannot be attributed to the skipped sweep alone. `requirePass` is a function argument, not a `current` field, so its control is a bespoke CI step like the one-sweep step, not a row.

## 3. Brief defects

Apply notes.md rule 6 exactly as written; this prompt adds no void rule. None of these changes a premise, so no tally is void.

- D1: M-S says to "adapt only its proof if required". Seven to eleven other proof scripts need adaptation. Affects M-S's cost; my AMEND rests on it.
- D2: M-S's instruction to put the positive progress witness on `startupPassGuards/current` while keeping the existing row conflicts with `ci.yml:918`. Verified by flip. My AMEND (i) rests on it.
- D3: "including when an earlier incident was still open" conflicts with STO-56. My A4 rests on it.
- D4: The common text's `needs_reconciliation` scope undercuts the brief's own claim that the rule changes only what the quarantine or pass moves. My A1 rests on it.

## 4. Internal consistency

Q1's tables, rescue-inventory cells and conformance text agree with each package's paragraph; the narrowed "ordinary restart with no open restore record" wording does not collide with Y-WIDE's open-incident transition. The only conflict is D3 above. Q2's baseline blocked-claim cell stays distinct from the sought harm. The only conflict is D2. I treated each alternative as its own obligation, not as adopted together.

## 5. Requested counterarguments, not votes

**Against Y-PROV.** It fails unsafe: an implementation that sets the column by status on the pass instead of at the record transaction renders `none` on a rolled-back row, "the one lie the column exists to prevent" (CNF-302). Y-WIDE's over-approximation cannot produce that lie while the record is open, and an operator reasons about one rule during an incident.

**Against M-S.** It redefines the mutant that pv-n98 landed, so the existing `passEveryStartup` row now certifies a different bad model, and it edits seven proofs in the normative model file for a test-model benefit. M-I leaves `Restore.lean` byte-identical.

**Disclosure.** I wrote build logs to `../fable-*.log` before moving them into `fable/panel-logs/`. My clone carries the M-S prototype uncommitted; `panel-logs/ms-prototype.diff` is the exact diff.
