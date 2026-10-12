# Panel brief: operation retention versus the provisioning guard on a temporary key (Q26), 2026-10-12

You are one of four independent reviewers. The working directory is a throwaway clone of the
specification repository `provisiond-spec` at commit `1f70010` (branch `pv-ucs-impl`). Read `AGENTS.md`
first. Do not edit tracked files; write scratch files only inside this clone (never `/tmp`); you may run
the gates (`nix develop --command bash tools/check-all.sh`, unpiped). Search the Markdown with whitespace
normalised. This owner repeatedly shows my framing wrong with a first-principles question and dissolves
machinery rather than tuning it; check this framing too, and verify every fact I state.

## Context

An rloop Manager blocked ticket pv-ucs.10; read its report, `docs/research/panels-2026-10/r44/manager-blocker.md`
(the owner-clarification section). Settled: ADR-0040 with its Q24 amendment (the sweep is the only deleter of
a settled operation's key, and MUST delete it once Decision 2 permits). Decision 2: "A temporary key is
deleted only once its operation has settled or vanished, and no machine it produced still reads
`provisioning`"; also "A key whose operation record is gone is deleted, since an unrecorded machine is never
attached." `STO-14`: "A retention job MUST remove settled operations older than a configured age" (excluding
`needs_reconciliation`). `CNF-303` lets a create settle while its machine still reads `provisioning`. Lean
`Provisiond.Rescue.Session.keyEligible` is `!w.recordPresent || ((settled) && !w.producedProvisioning)`.

## The question

A settled create's machine still reads `provisioning` when retention removes the operation row; the next
sweep finds the tagged key with no operation record. Keep the key (provisioning guard) or delete it
(vanished-row rule)? Candidates: (1) `STO-14` skips a settled operation while a machine it produced still
reads `provisioning` (the Manager's recommendation); (2) the vanished-row rule wins, accepting the consequence.

Check first principles: what does "provisioning" mean on each provider at this point — is the key still
needed after a create settles (Robot installs keys at order time; the live test deleted the key right
after `ready` and the order still listed it; does any provider read the key after the create settles)? How
long can a machine read `provisioning` after settlement, against a retention age measured in days? Does the
provisioning guard even need the operation row (the machine row could carry the key's operation id)? Is the
smallest answer that the guard is moot after settlement on every v1 path?

## Output

At most 600 words, no preamble: a one-line verdict; why; every defect with `file:line`; the edits; the
strongest "don't build".
