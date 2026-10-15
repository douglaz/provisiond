# Panel brief: when may a theorem assume a new guard is on? (Q32), 2026-10-14

You are one of four independent reviewers. The working directory is a throwaway clone of the
specification repository `provisiond-spec` at `5407f68` (branch `robot-live-2026-10-12`). Read `AGENTS.md`
and `docs/adr/0025-*.md` first. Do not edit tracked files; write scratch files only inside this clone
(never `/tmp` or `/var/tmp`); you may run the gates (`nix develop --command bash tools/check-all.sh`,
unpiped) and build Lean in a scratch copy inside the clone. This owner repeatedly shows my framing wrong with
a first-principles question and dissolves machinery rather than tuning it; check this framing too, and
verify every fact stated below before relying on it.

## The question

The formal layer (ADR-0025) makes every guard a dated amendment added a named field of a parameter record
(`Params`/`Guards`, with a `current` value), proved by a witness pair (refused with it, admitted without it)
and one CI negative-control row in `.github/workflows/ci.yml` that flips it and must red exactly that
witness. Generic theorems quantified over the record often need a guard ON to hold at all, so they carry its
enabled-hypothesis — e.g. `Reconcile.absence_requires_three` (one per guard), and on this branch
`Ledger.close_releases_exact_remainder` (`closeOwnCommitment`) and the floor/authorization theorems
(`allCommitmentsAuthorize`).

AGENTS.md says: "read the theorem before weakening it, since weakening a statement to make a proof pass is
a semantic change like any other." ADR-0025, as far as I can find, does not say whether adding a NEW guard's
enabled-hypothesis to an existing theorem is such a weakening. The allowance lived only in my rloop run
instructions, first as "MAY gain the new guard's own enabled-hypothesis", then tightened by the Manager to
"only where the theorem is false without it" (pv-0uk was sent back once to remove four unneeded ones;
pv-f6g removed two more and an unrelated `hi` hypothesis the rule forbade). A strict reader of the repository
alone — e.g. the PR's codex bot — cannot tell an allowed assumption from a forbidden weakening.

Proposed dated amendment to ADR-0025 (2026-10-14, owner decision Q32), my wording:

> A theorem quantified over a parameter record MAY gain a **new** guard's own enabled-hypothesis, and only
> where the theorem is false without it; the counterexample is recorded (where?). Its conclusions and other
> hypotheses are unchanged, and its docstring names the added hypothesis. Removing an unneeded hypothesis is
> always allowed. Any other change that weakens a statement — a dropped or narrowed conclusion, an unrelated
> hypothesis, a renamed or replaced theorem, a disconnected model — is a semantic change under AGENTS.md and
> needs the owner.

## What I need from you

1. Verify the facts: does ADR-0025 (or AGENTS.md, CONTEXT.md, README "Requirement conventions") already say
   anything that answers this? Count the theorems at `5407f68` that carry a guard enabled-hypothesis, and say
   whether any of them would fail the proposed rule (needed? named in the docstring?).
2. Is "only where the theorem is false without it" checkable, and by what — a recorded counterexample (on
   the ticket? in the docstring? as a `decide` witness?), a CI mutation that deletes the hypothesis and
   expects the build to fail, or reviewer judgement? Prefer what the repository already does.
3. Does the rule belong in ADR-0025, in AGENTS.md, in both, or nowhere (e.g. is the enabled-hypothesis shape
   simply not a weakening, because the `current` guarantee is unchanged)? Say why from the repository's own
   text.
4. Your vote: AMEND AS WORDED, AMEND WITH CHANGES (give the text), or NO AMENDMENT — with what it changes.
5. Then, labelled "Strongest case for the other side (written on request)", the best argument against your
   vote. It is not your position.

Under 600 words. Cite `file:line` or identifiers for every claim.
