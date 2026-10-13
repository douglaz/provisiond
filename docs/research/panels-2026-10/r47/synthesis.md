# Panel r47 synthesis — what remains of the formal layer (pv-vwe) and pv-erp, 2026-10-13

Readers: fable, opus (claude xhigh), astra, sol (codex xhigh); clones at 32c77dc. All exit 0. Under review:
`evaluation.md` (a sub-agent's read at 5acc252).

## The seven candidates

| | Verdict | Readers |
|---|---|---|
| (a) capability gating | DECLINE 3–1 | astra would write it narrowly on `Rescue.Install.step.beginRescue` |
| (b) `PRV-36`/`STO-53` effective-window maximum | **WRITE 4–0**, and owed: ADR-0018 added the max by dated amendment (`OPS-32` "read 'declared' until 2026-09-08") and ADR-0025 makes every such guard a model parameter. `Windows.visibility` → `pastWindow` → `sweepStep`; pair: declared 8, observed 20, sweep at 10 (opus proved it in scratch) |
| (c) `OPS-40` signed-URL gates | DECLINE 3–1 | astra would write it; the model has no clock (`Rescue.lean:27`) |
| (d) `WIR-45` secrecy | DECLINE 4–0 | |
| (e) `STO-17` uniqueness key | DECLINE 4–0 | |
| (f) `PRV-31` sale rule (Q25) | WRITE 3–1 | opus declines: `purchaseTail` is "Snapshot facts only" and `CNF-166` lists the same cases. For: a "bound = today is sellable" theorem catches "today or later" unselling all of v1 on every push |
| (g) `LDG-9` across commitments | WRITE 3–1, but as a per-commitment revision of `Ledger.step`, not a pair | opus declines as specified: a retyping touching every Ledger theorem and `Render.ldg31Table`. The model today yields both "bad" traces (`Ledger.lean:112`, `:119`) |

## New candidates the evaluation missed

- **Q22's read-back branch (4–0 that it outranks the list):** v1's every delete is a dated cancellation
  with a read-back; nothing in `Fence.lean` produces `Settled.scheduled`, so no Fence trace reaches the
  rendered scheduled row. Pair: dated acceptance with a failed read-back → `scheduled`, fence kept; without
  the guard → gone-write, fence cleared, machine present.
- **Q20's failed re-read (opus; owed, one token):** `Reconcile.Answer` has only `found | notFound`; add
  `failed` so "a failed direct absence confirmation cannot record absence" has its pair.
- **ADR-0041's Q29 baseline guard (fable, astra, sol):** `sessionDecision` takes pins as an input; a
  `pinsFrom baseline record` would feed it. Fix the text first: at 32c77dc `PRV-19` and `CNF-355` still say
  "strictly later than this session's reset" against ADR-0041 (pv-wd0 is applying Q29).
- Already covered: Q26 (`Witnesses` conjunct), Q28 (`windowAtLeastTwoSweeps`, ci control). Q24: nothing
  modelled.

## pv-erp and pv-vwe

- **pv-erp: PARK at P4 (3–1; astra: guard now).** The evaluation's "cheapest fix" is wrong: it would go red
  on today's corpus (`"enforce what it can"` recurs with marks, `11-open-findings.md:1618`) and breaks a
  passing self-test (`check_citations.py:679`). Copy the R7a/R8 cases into the bead: they sit in a Run
  directory the repository does not hold (opus).
- **pv-vwe: CLOSE (3–1; opus: keep (b) as a child and close when it lands).** Standalone beads citing
  ADR-0025 and the 2026-09-21 comment; the closing comment must not claim universal guard coverage.

## Defects in the evaluation

"v1 has a single driver" is false (ADR-0039 keeps Cloud and DigitalOcean specified); "no model has a tenant"
is false; the (g) row cites the two-commitment defect as sound; line numbers and quote counts are stale;
PRV-13b's half of (f) is partly computable.

## Strongest "don't build"

A pair fires only when the amender edits the Lean; the last round's gaps were found by rloop Managers and
two live sessions, not by theorems (opus). Each WRITE alters a landed model in files of 500–4,000 lines,
against the set's own record that fix rounds add defects at the rate they remove them (fable).
