# Panel brief, round 2: the network-restriction field (`PRV-35`/`DOM-27`), 2026-10-07

You are one of four independent reviewers. The working directory is a throwaway clone of the
specification repository `provisiond-spec` at commit `82e7f37` (numbered Markdown requirements,
ADRs in `docs/adr/`, glossary `CONTEXT.md`, Lean in `tools/formal/`). Read `AGENTS.md` first. Do not
edit tracked files; you may write scratch files and run the gates. Search the Markdown with
whitespace normalised. This owner repeatedly shows my framing wrong with a first-principles question
and dissolves machinery rather than tuning it; check this framing too, and verify every fact I state.

## Round 1

Read `/var/tmp/provisiond-panel-r24/r23-synthesis.md` and the three answers beside it
(`r23-sol.md`, `r23-astra.md`, `r23-opus.md`; a fourth reader was unavailable). All three rejected
my original options and proposed the core: **the field carries positive evidence only; `none` is
deleted.** That core is not under review unless you find it wrong.

## What is under review: the recommendation now put to the owner

1. **Two values: `restricted | unknown`.** `none` deleted; `restricted` and `disabled` merged.
2. **One stored status (the existing `status`/`source`/`observed_at` triple at
   `05-persistence.md:268-270`) with a write rule:** neither source overwrites the other's positive,
   and each withdraws only its own.
   - A provider read showing a set flag writes `restricted` / `provider_api`.
   - A provider read showing clear flags writes `unknown` / `provider_api`, but only over a
     `provider_api` value or an `unknown`.
   - The operator records `restricted` / `operator_notice` over anything except a `provider_api`
     `restricted`; the operator withdraws by recording `unknown`, only over its own record.
3. **`WIR-47`'s refusal narrows** from "where the driver reports this provider" to "over a
   provider-reported `restricted`". `API-63`'s "exactly as `WIR-47` refuses" (`04-api-contract.md:1420`)
   follows.
4. **Records:** `WIR-11`'s example (13:299) stops showing `none`; `PRV-35`'s Robot confidence is
   lowered; Cloud's `server.locked` stays unmapped pending a written inquiry; the `SEC-41` cost (an
   account-wide lock becomes one operator record per machine) is stated; `CNF-228`/`CNF-233` are
   rewritten and coverage is added for the two sources interleaving.
5. **Accepted cost told to the owner:** an operator record nobody withdraws stays `restricted` after
   the provider unlocks.

## The two choices I made where round 1 split — attack these first

- **Merge vs keep `restricted`/`disabled`.** Round 1: astra merge; opus define-by-coverage or merge;
  sol keep with definitions. `CNF-228` asserts `disabled`. Does anything (a reader, a remedy, the
  tenant's agent, `LDG-71`, abuse cases, `API-63`) need the distinction? Is merging a loss of a
  stated property?
- **One triple + write rule vs two per-source observations with a derived view.** Round 1: opus one
  triple ("two triples adds a second home"); sol and astra two observations ("different observations,
  not competing copies of one fact"). Trace these sequences on the one-triple rule and say where it
  loses information or gives a wrong view:
  (i) operator records restricted → provider flag sets → provider flag clears;
  (ii) provider flag sets → operator records → provider flag clears → operator withdraws;
  (iii) provider flag sets → provider flag clears while Hetzner's whole-server lock persists;
  (iv) operator withdraws while the provider flag is set.
  If the one-triple rule fails a sequence, is the two-observation shape actually larger (columns,
  writers, conformance) or the same size?

## Also

- Is the "forgotten record stays restricted" cost acceptable, or does something already exist to
  surface it (the observed time, an alarm, `OPS-26`'s listing, case closure)? Should case closure or
  a gone-write clear it?
- Does the narrowed `WIR-47` refusal still prevent the "two homes" drift `05-persistence.md:1045-1066`
  was written against?
- Anything the recommendation breaks that round 1 did not name.

## Output

At most 800 words, no preamble: accept / amend / reject the recommendation in one line; your answer
on each of the two choices with the sequence traces; every defect with `file:line`; the edits.
