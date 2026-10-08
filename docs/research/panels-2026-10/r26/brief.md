# Panel brief: does a failed refresh count toward the per-machine refresh bound? (2026-10-08)

You are one of four independent reviewers. The working directory is a throwaway clone of the
specification repository `provisiond-spec` at commit `0c52755` (branch `pv-ucs-impl`; numbered
Markdown requirements, ADRs in `docs/adr/`, glossary `CONTEXT.md`, Lean in `tools/formal/`). Read
`AGENTS.md` first. Do not edit tracked files; you may write scratch files and run the gates. Search the
Markdown with whitespace normalised. This owner repeatedly shows my framing wrong with a
first-principles question and dissolves machinery rather than tuning it; check this framing too, and
verify every fact I state before relying on it.

## Settled (do not re-litigate)

`ADR-0034` (read it whole): refresh is answered from the cache inside a freshness window; reverse-DNS
is ceilinged; the provider request limit is a declared budget with a system reserve; admission is
decided once per operation. Background: `docs/research/panels-2026-10/r19/synthesis.md` (D2r).

## The gap (an rloop Manager blocked ticket pv-ucs.2 on it)

Read `docs/research/panels-2026-10/r26/manager-blocker.md` (the Manager's own words). In short: Decision 1
says "A refresh of a machine whose `state_observed_at` falls within the deployment's stated freshness
window (`OVR-19`) settles without a provider call. At most one provider read per machine per window
then reaches the provider, however fast a caller loops." `state_observed_at` is set only by an
authoritative read (`05-persistence.md`, `machines`), and `OPS-11`'s refresh row is "Always `failed`. It
is read-only; a failure changed nothing." So a refresh whose provider read fails leaves the timestamp
stale, and the next refresh a second later reads again: the per-machine bound does not hold for reads
that fail.

## Options put to the owner

- (a) Count every attempt: a refresh within the window of the machine's last refresh *attempt*
  (successful or not) is answered from the cache, returning the cached state with its true
  `state_observed_at`.
- (b) Count every attempt, but refuse the refresh locally with an error and a retry-after (the
  Manager's recommendation).
- (c) Count only successful readings; accept the residual.

My recommendation was (a), and I claimed it needs no new state because "the last refresh's dispatch
time is already in the operations table". **That claim is false**: `operations` has `created_at`,
`updated_at`, `available_at`, `claim_number` and `OPS-45`'s `write_started_at`, which `OPS-45` does not
set for a refresh. Check what (a) actually needs.

## What I want from you

1. Is the gap real? Trace the loop through `ADR-0034`, `DOM-8`, `OPS-8`, `OPS-11`, the refresh endpoint
   in `04-api-contract.md` and the `machines` columns. Which failures can a refresh hit (provider 5xx,
   404 inside `PRV-36`'s window, `429`, auth, timeout) and does any of them already leave a record that
   could bound the next read? Does `ADR-0035`'s acceptance rule touch a read-only refresh at all?
2. Can a tenant make reads fail on purpose, and what does the loop cost the operator when they do,
   given `ADR-0034`'s request budget and system reserve? Is the per-machine bound load-bearing once the
   budget-with-reserve exists, or is it only about fairness between tenants?
3. Where is (a) wrong? What state does it need (a new `machines` column, an `operations` query over the
   last claimed refresh, something else)? Does "answered from the cache" mislead a caller who asked
   *because* the last read failed? Interaction with `OPS-8` (one running operation per machine), the
   account sweep (`OPS-32`) and other operations that read the provider opportunistically (`DOM-8`).
4. Where are (b) and (c) wrong? A third shape, especially a smaller one (e.g. the bound counts the
   refresh *operation*, not the read; or a failed refresh stamps an attempt time on the machine).
5. The strongest "don't build this".

## Output

At most 800 words, no preamble: verdict (a), (b), (c) or a named other in one line; why in one
paragraph; every defect in my framing with `file:line`; the requirement ids, columns and declarations
the chosen answer edits.
