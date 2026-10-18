# Panel brief r57: pv-qga, a create failure before any provider mutation, 2026-10-18

You are one of four independent reviewers. Your working directory is a throwaway clone of the
specification repository `provisiond-spec` at `a1dd00f` (master). Read `AGENTS.md` first. `br show pv-qga`
prints the bead. You MAY edit tracked files in this clone to test a claim; write nothing outside it (never
`/tmp` or `/var/tmp`), and never commit, push or call a provider API. Read nothing outside this clone except
toolchain files. The gates exit 0 at `a1dd00f`: `nix develop --command bash tools/check-all.sh`, about
4 minutes; run it unpiped, redirecting to a file in the clone, and read its exit code. Keep `TMPDIR` as set.
Do not delegate, background or wait on anything: do the work yourself in this session. Have a draft answer
by minute 45. Verify every fact below before relying on it. **Answer in at most 500 words.**

## Settled (off-limits)

- `pv-14b`'s claim order, `OPS-43` steps 1-9 (03:714-757), and its sentence "The first failing check stops
  subsequent checks; its owning classification governs disposition" (03:757).
- `pv-k4l`: the column `operations.about_to_order_at`, written in step 8; `OPS-15`'s restart-only exception
  (03:384-408) settling a running create with the column null `failed`, `internal`, `retryable: true`,
  released under `LDG-39`'s "Deterministic rejection before acceptance" row; `ADR-0042`.
- In round r56b all four readers expected pv-qga to settle `failed`: "A live worker knows it reached no
  mutation" (docs/research/panels-2026-10/r56/synthesis.md, r56b section). This round is about the shape.

## The defect (confirmed)

A create is claimed. Step 4's List offers read times out. No key was uploaded and no order was sent.
`OPS-11` (03:263-266) calls a failure ambiguous when "the error kind is `network`, `timeout`, or `internal`",
with no mutation qualifier, and the create row (03:232) is "`needs_reconciliation` if the failure is
*ambiguous*". The create parks, the correlator searches for an order never placed, and the customer's
commitment stays held until `OPS-33`'s window. Had the process been killed at the same instant, `OPS-15`
would settle it `failed` and release the money at once (`CNF-358`, 10:1458). `CNF-31a` (10:194-195: "A create
failing with a provider 5xx, a network error, or a timeout is `needs_reconciliation`, including without known
acceptance") and `CNF-31b` (10:212-213) require the parking. The formal layer agrees: `Tables.classify` on
`.createMachine` with `⟨.timeout, false, .unrecorded, false, false⟩` is `needsReconciliation` (the manager
checked with `decide`; see also `rejected_order_witness`, Witnesses.lean:3008).

The kinds at issue are only the ambiguous-by-kind ones: `network`, `timeout`, `internal`, `provider` with a
5xx or no status, and a cut-off `conflict`. A deterministic kind at step 4 is already `failed`.

`ADR-0035`'s Q11 amendment rejected "settling a pre-send `network` failure as `failed` (a behaviour change
beyond the question)" (adr/0035:108-109). That case is a failure of the **order** request before any byte
was sent, after step 8. `OPS-21` (03:1697-1699) says cancellation of `execute` "MUST be treated as an
ambiguous outcome"; r56 assigned a cancellation before step 8 to this bead (r56 synthesis, "Gaps found
beyond the brief").

## The manager's recommendation, as claims to break

**Shape B: create-only, in `OPS-11`'s create row.** Any create failure the worker records before step 8's
transaction commits settles `failed`, whatever its kind, OPS-21's cancellation included. After step 8
commits, the row reads as today, so `ADR-0035`'s Q11 rejection and `CNF-31b`'s pre-send order case stand.

1. **The boundary is the worker's position, not a column read.** A running create has no `machine_id`
   (05:390), so `OPS-8` never defers it, and with one writer the column is null exactly until this
   execution's step 8 commits. The settle write keeps its usual guard, with no `about_to_order_at IS NULL`
   term.
2. **The error keeps the driver's kind**, with `retryable: true` on the error and the operation view for the
   kinds that were ambiguous before.
3. **Money:** a full release under `LDG-39`'s "Deterministic rejection before acceptance" row and `LDG-32`'s
   "the create fails deterministically" (12:312), each with an "includes" clause as pv-k4l added.
4. **Lean:** `Failure` (or `Markers`) gains a "before step 8" fact for create, a theorem that such a failure
   is `failed` for every kind, and a negative-control witness.
5. **Rejected shapes:** (A) scope the ambiguity list to mutating requests, which reaches delete, power,
   reverse DNS and release; (C) an `OPS-43`-owned exception "not an `OPS-11` classification", shaped like
   `PRV-13c`.
6. **Out of scope:** pv-009, pv-p1y, pv-xer, pv-s5b, and step 9's key-upload failure.

## Questions

1. Pick A, B or C (or a fourth shape), with your strongest reason.
2. Break claims 1-6. Quote the text that breaks each. Is there a path where the worker's position and the
   column disagree?
3. List every edit the fix owes: requirements, CNF items, ADR home (amend `ADR-0042`, amend `ADR-0035`, or a
   new ADR), Lean and ci.yml. Name any the manager missed.
4. Plant the plausible wrong edit in your clone (for example, settle `failed` on a null column read, or drop
   the cut-off `conflict`). Report whether any gate goes red, and what a negative control should catch.
5. Do delete, power, reverse DNS or release attachment make a provider read before their mutation that has
   the same defect? If yes, cite the text: is that a separate bead?
6. Make the strongest case for leaving the create parked (status quo), written as its advocate.
