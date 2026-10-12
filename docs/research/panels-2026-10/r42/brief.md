# Panel brief: when a successful create's temporary key is deleted (Q24), 2026-10-11

You are one of three independent reviewers. The working directory is a throwaway clone of the
specification repository `provisiond-spec` at commit `db6bb54` (branch `pv-ucs-impl`). Read `AGENTS.md`
first. Do not edit tracked files; write scratch files only inside this clone (never `/tmp`); you may run
the gates (`nix develop --command bash tools/check-all.sh`, unpiped). Search the Markdown with whitespace
normalised. This owner repeatedly shows my framing wrong with a first-principles question and dissolves
machinery rather than tuning it; check this framing too, and verify every fact I state.

## Context

An rloop Manager blocked ticket pv-ucs.10 (a review-residue ticket) on its item 12; read its report,
`docs/research/panels-2026-10/r42/manager-blocker.md`. Settled: `ADR-0040` (read it whole) — Decision 2: "A
temporary key is deleted only once its operation has settled or vanished, and no machine it produced still
reads `provisioning`"; Consequences: "A caller's key held by an unresolved operation blocks that caller's
next create on the same account, because providers reject a duplicate fingerprint." `PRV-9` repeats the
eligibility rule and says "This common eligibility rule governs driver cleanup and `OPS-32`'s sweep for
create and rescue". Nothing says who deletes an eligible key after a SUCCESSFUL create, or when; read
literally, it waits for the next `OPS-32` pass, and meanwhile the same caller's next create on that account
meets a duplicate-fingerprint refusal.

## The question

1. Prompt driver cleanup: once the create has settled and no produced machine reads `provisioning`, the
   driver attempts deletion; a failed delete leaves the create's result intact and the sweep is the
   fallback (the Manager's recommendation).
2. Sweep only: state that a same-key create can be refused until the next sweep.

Check first principles: is the key even the caller's (does `PRV-9` register the caller's public key under
an engine-chosen name per operation, or reuse one)? Does Robot's or Cloud's duplicate-fingerprint refusal
actually hit a second create (the live test: `POST /key` with a fresh key; research V9 found the order's
transaction still lists a deleted key)? When does the "no machine still reads `provisioning`" guard clear
for a successful create — at settlement, or only after a later read — and who observes it? Does prompt
cleanup interact with `OPS-8`'s one operation per machine, `OPS-11`/`OPS-12` (a delete is a mutation: is a
lost reply on the key delete ambiguous?), or `PRV-41`? Is there a smaller shape (e.g. reuse an already
registered identical key instead of re-registering)?

## Output

At most 700 words, no preamble: a one-line verdict; why; every defect with `file:line`; the edits; the
strongest "don't build".
