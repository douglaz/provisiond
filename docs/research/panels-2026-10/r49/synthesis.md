# Panel r49 synthesis — when may a theorem assume a guard is on? (Q32), 2026-10-14

Readers: fable (claude-fable-5-1), opus (claude-opus-5-5), astra (gpt-6-astra), sol (gpt-6.1-sol), all at xhigh;
clones at 5407f68. All exit 0; each ran the gates (exit 0) except where stated in its answer.

## Votes

All four: **AMEND WITH CHANGES**, in ADR-0025. opus adds a one-clause pointer in AGENTS.md; astra and sol
want ADR-0025 only ("One rule, one home", AGENTS.md); fable leaves AGENTS.md's general rule as it is.

## Facts the readers established

- Nothing in ADR-0025, AGENTS.md, CONTEXT.md or README answers it. AGENTS.md calls weakening "a semantic
  change like any other" and prescribes neither a ban nor owner approval; the allowance is committed in
  `pv-0uk`'s comments 327–330, with the clause "keep the guarantee for the current setting" that my wording
  dropped (opus).
- The shape is structural and already explained in three places: `ci.yml` ("Fence.lean's own theorems take
  each guard as a hypothesis and stay green"), `Fence.lean`, `Rescue.lean` (fable).
- Inventory at 5407f68: about 140 theorems carry guard hypotheses (139–144 by reader, by counting rule);
  current satisfies every one except three admitted-without halves of witness pairs. "Enabled" is the wrong
  word: two guards are current-`false` (fable).
- **Three `_single` ledger theorems carry `allCommitmentsAuthorize` without needing it**
  (`open_authorized_at_commit_single`, `floors_preserved_single`,
  `open_against_read_is_the_serialized_open_single`): astra and sol each proved them without it in scratch Lean.
  They were added on this branch (`0ca996c`).
- Seven older docstrings (Restore, Fence) do not name an added hypothesis; none of the 22 hypotheses added to
  existing theorems cites its refuting witness (opus).
- Not checkable by tooling: Lean emits no unused-variable warning (every hypothesis is referenced by its
  proof), and a CI row that deletes a hypothesis tests the proof script, going red on true statements too.
  The evidence that already exists is the guard's admitted-without witness, `decide`-checked and red-controlled
  by its CI row; in every case checked it is the counterexample (fable, opus). Where it contradicts no
  conclusion directly, a short `decide` refutation in `Witnesses.lean` (astra, sol, opus).
- The rule must cover undated guards too: the ledger guards' rule is undated (opus).

## Where they differ

- Docstring: opus, sol and astra want it to name the hypothesis and cite the refuting witness (the bot cannot
  read a ticket); fable would name the witness on the ticket and keep docstrings from restating signatures.
- Wording base: opus's states the reason ("the set's claim is the theorem at `current`, so a hypothesis
  `current` satisfies is not a weakening"); fable's says "pinned to `current`'s value"; astra's and sol's
  scope it to an owner-authorized extension.

## Strongest case for the other side (written on request — not the readers' positions)

No amendment: ADR-0025 already makes hypotheses explicit and demands negative witnesses; AGENTS.md treats
weakening as a reviewed semantic change, not a ban; licensing one shape implies every other is banned; and the
defect was in a run instruction, so the fix belongs in the work order.
