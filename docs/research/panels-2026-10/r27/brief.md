# Panel brief: what a driver reports when it cannot tell whether the provider accepted a mutation (2026-10-08)

You are one of four independent reviewers. The working directory is a throwaway clone of the
specification repository `provisiond-spec` at commit `4830cd0` (branch `pv-ucs-impl`; numbered Markdown
requirements, ADRs in `docs/adr/`, glossary `CONTEXT.md`, Lean in `tools/formal/`). Read `AGENTS.md`
first. Do not edit tracked files; you may write scratch files and run the gates. Search the Markdown
with whitespace normalised. This owner repeatedly shows my framing wrong with a first-principles
question and dissolves machinery rather than tuning it; check this framing too, and verify every fact I
state before relying on it.

## Settled (do not re-litigate)

`ADR-0035` (read it whole): a failure after the provider accepted a mutation is ambiguous whatever its
kind; drivers report `details.accepted`; keyed on acceptance, not dispatch. Panel record:
`docs/research/panels-2026-10/r20/synthesis.md`.

## The gap (an rloop Manager blocked ticket pv-ucs.3 on it)

Read `docs/research/panels-2026-10/r27/manager-blocker.md` (the Manager's own words). The implementation of
pv-ucs.3 is in this clone's history as `cf3c32a` (not accepted); read `git show cf3c32a` for the current
`PRV-5` wording. Trace: an order POST whose body was sent, then a connection reset before any reply; the
driver cannot tell whether the provider accepted it.

- `PRV-5`: "A driver MUST map provider transport failures to `network`, provider timeouts to `timeout`".
- The new `PRV-5` text from `cf3c32a`: "A driver that cannot determine acceptance MUST report `internal`
  with `details.accepted: null`; it MUST NOT omit the field or substitute `false` for unknown acceptance."
- `ADR-0035` Decision: "A driver that cannot tell reports `internal`, which is already ambiguous. No
  implicit default enters `OPS-11`." And its rejected-dispatch rationale: "A connection that dies
  mid-request is already ambiguous by kind."

Both readings end in `needs_reconciliation`; they differ in the error kind the wire carries and in what
conformance tests.

## My recommendation (the owner asked for this panel before deciding)

Keep `network`/`timeout` for transport failures, with `details.accepted: null`. `internal` applies only
where the error would otherwise classify deterministically (a 4xx or other non-ambiguous kind) and the
driver cannot tell acceptance. Add a dated clarification to `ADR-0035` saying its `internal` sentence was
too broad. (The Manager recommended the same.)

## What I want from you

1. Is the conflict real, and is it only a wording conflict or a behaviour one? Who reads the error kind
   (callers via `WIR-9a`/`DOM-17`'s `retryable`, `OPS-11`, operators, `OPS-27`/`OPS-31` resolution, the
   formal `Tables` classifier from `cf3c32a`)? Does `network` vs `internal` change anything a caller or
   operator does?
2. Where is my recommendation wrong? Enumerate the cases: transport failure before any byte sent;
   after the body was sent; a timeout waiting for the reply; a 4xx/5xx reply; a reply the driver cannot
   parse; a failure on a *later* request of the same operation (poll, key cleanup) after the order was
   accepted (`details.accepted: true`). What does each report under my rule, and is every case decided?
3. Is `accepted: null` itself the right carrier, or is a tri-state redundant given the error kind? Does
   `OPS-11`'s classifier need the field at all on kinds that are already ambiguous?
4. A smaller or more honest shape? The strongest "don't build this"?
5. Formal layer: which declarations in `cf3c32a` (`Provisiond.Tables` `Failure`, `ambiguous`,
   `classify`, the totality proofs, witnesses) change under each reading?

## Output

At most 800 words, no preamble: verdict (accept my recommendation / amend / a named other) in one line;
why in one paragraph; the case table from item 2; every defect in my framing with `file:line`; the
requirement ids, CNF items and declarations the chosen answer edits.
