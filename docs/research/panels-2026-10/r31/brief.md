# Panel brief: auction identity resolution and temporary-key lifetime (pv-ucs.9), 2026-10-09

You are one of four independent reviewers. The working directory is a throwaway clone of the
specification repository `provisiond-spec` at commit `843a2f2` (branch `pv-ucs-impl`; numbered Markdown
requirements, ADRs in `docs/adr/`, glossary `CONTEXT.md`, Lean in `tools/formal/`). Read `AGENTS.md`
first. Do not edit tracked files; you may write scratch files and run the gates. Search the Markdown
with whitespace normalised. This owner repeatedly shows my framing wrong with a first-principles
question and dissolves machinery rather than tuning it; check this framing too, and verify every fact I
state before relying on it.

## Context

Ticket pv-ucs.9 applies the research note `docs/research/provider-verify-2026-10.md` (read §1's table and
V2, V8, V9, V18, V19). The decision ADRs today are ADR-0033..0039 (settled). Read
`docs/research/panels-2026-10/r31/manager-blocker.md` — the rloop Manager's own words blocking pv-ucs.9 on
two owner questions.

## Q16a — may a negative auction identity read resolve a lost-reply order absent?

`PRV-42` (02-provider-contract.md): on the auction channel, offer id equals server number, so "resolution
MUST be an identity read rather than a search, and the correlator is unnecessary"; its table maps "absent,
past `PRV-36`'s effective visibility window" to resolved-absent; and "that it holds by rule rather than by
coincidence is `[verify]` before a driver depends on it". Research V8 proposes a guard: "When the identity
read finds a server, assert `server_number == offer id` on the transaction. On a mismatch, treat the
channel as catalogue-like and use `PRV-32`'s fingerprint search." Counterexample (Manager): order offer A,
lose the reply, provider delivers server B ≠ A; past the window `GET /server/A` → not found; the guard
never runs; the commitment is released while B exists.
My recommendation: keep the order's per-order fingerprint; the identity shortcut settles only a positive
read with a matching number; a negative identity read falls back to `PRV-32`'s fingerprint search and
cannot by itself resolve absent; unavailable evidence leaves the order unresolved (`OPS-33`'s window).

## Q16b — when may a temporary SSH key be deleted?

`PRV-9`/`DEF-6`; research V2 (Hetzner Cloud: clean up after the create Action reaches `success`, not after
the call returns; rescue keys after the reset that boots rescue), V18 (DigitalOcean: after the Droplet is
`active`), V19 (Cherry: until `deployed`/`allocated`). The Manager found provider consumption and
operation status giving conflicting deletion instructions — read its text for the exact conflict.
My recommendation: delete only after the provider confirms the machine is up (Cloud action success; DO
`active`; Robot: rescue booted); if confirmation never comes, the key stays until the operation is
resolved.

## What I want from you

1. Q16a: is the counterexample reachable on Robot's auction channel as specified (`PRV-32`, `PRV-38`,
   `PRV-42`, `OPS-27`, `OPS-33`)? Does my rule cost anything (the correlator `PRV-42` called unnecessary;
   Robot's transaction listing retention of 30 days, V7)? Is there a smaller rule?
2. Q16b: state the Manager's conflict precisely, then say whether my rule resolves it. What happens to a
   key whose operation fails, is cancelled, or lands in `needs_reconciliation`? Does any provider charge
   for or limit lingering keys? Is "delete on settlement, whatever the outcome" smaller?
3. The strongest "don't build this" for each; which is better left a `[verify]` until the live tests.
4. Edits and formal-layer impact.

## Output

At most 900 words, no preamble: a verdict line per question; why; every defect in my framing with
`file:line`; the edits.
