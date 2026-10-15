# Panel brief: what remains of the formal layer (pv-vwe) and pv-erp, 2026-10-13

You are one of four independent reviewers. The working directory is a throwaway clone of the
specification repository `provisiond-spec` at `32c77dc` (branch `robot-live-2026-10-12`). Read `AGENTS.md`
and `docs/adr/0025-*.md` first. Do not edit tracked files; write scratch files only inside this clone
(never `/tmp` or `/var/tmp`); you may run the gates (`nix develop --command bash tools/check-all.sh`,
unpiped) and build Lean in a scratch copy inside the clone. Search the Markdown with whitespace normalised.
This owner repeatedly shows my framing wrong with a first-principles question and dissolves machinery rather
than tuning it; check this framing too, and verify every fact stated.

## Context

Epic `pv-vwe` ("The formal layer: every clause in the inventory gets a Lean home", ADR-0025) has all 42
child tickets closed. Its 2026-09-21 comment (read it: `br show pv-vwe` or `.beads/issues.jsonl`) lists
seven "CANDIDATES NOT WRITTEN", the DECLINED items, and THE ADMISSION TEST: "a red-build pair per parameter
is necessary, not sufficient, because an unused model can have excellent negative controls and protect
nothing. Composition with an existing state transition or an authoritative rendered table is what admits a
candidate." Bug `pv-erp` (P4) is the QUOTED checker's alternative-occurrence gap.

A sub-agent evaluated all of it against today's spec: `docs/research/panels-2026-10/r47/evaluation.md` (read
it). Its recommendation: WRITE (b) PRV-36/STO-53's effective-window maximum, (f) PRV-31's sale rule (with
ADR-0037 Q25), (g) LDG-9's aggregate reserved scalar across commitments; DECLINE (a), (c), (d), (e); close
`pv-vwe`; park `pv-erp` at P4.

## Questions

1. For each of (a)-(g): is the verdict right under THE ADMISSION TEST? Check the cited declarations and line
   numbers; for each WRITE, name the exact composition point and the witness pair, and say whether the
   theorem would be about the requirement as written or a simplification; for each DECLINE, the strongest
   case for writing it anyway.
2. Since 2026-09-21 the spec gained ADR-0033..0041 with many amendments. Is there a candidate NOT on the
   list that now passes the admission test better than these (e.g. a guard a dated amendment added whose
   removal no witness exercises: Q22's read-back branch, Q24/Q26's key eligibility, Q25's sale exclusion,
   Q28's two-sweep window, ADR-0041's baseline comparison)? ADR-0025's rule is "a negative theorem for every
   guard a dated amendment added".
3. Close `pv-vwe` now, or keep it open? Standalone beads or children? And `pv-erp`: park, close, or the
   "reject loudly when a fragment occurs more than once and a quote mark is present" guard now?
4. The strongest "don't build" for the whole proposal.

## Output

At most 800 words, no preamble: a verdict line per item (a)-(g), pv-erp and pv-vwe; any new candidate;
every defect in the evaluation with `file:line`.
