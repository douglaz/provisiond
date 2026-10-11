# Panel brief: pv-ucs.4 — attachments left unrecorded when the attachment listing never runs (Q21), 2026-10-11

You are one of four independent reviewers. The working directory is a throwaway clone of the
specification repository `provisiond-spec` at commit `dec039f`. Read `AGENTS.md` first. Do not edit
tracked files; write scratch files only inside this clone (never `/tmp`); you may run the gates
(`nix develop --command bash tools/check-all.sh`, unpiped). Search the Markdown with whitespace
normalised. This owner repeatedly shows my framing wrong with a first-principles question and dissolves
machinery rather than tuning it; check this framing too, and verify every fact I state. The owner has
rejected absorbing an operator loss without a threat model, and rejected manual operator steps.

## The bug (pv-ucs.4, filed 2026-10-06, before ADR-0035 and ADR-0037's amendments)

"A delete whose `DELETE` returns 2xx and whose follow-up `PRV-45` attachment listing is throttled settles
`failed`. Only `PRV-45` writes `machine_attachments`, so `STO-18` holds nothing back and `LDG-32` can close
the commitment while a surviving volume bills the operator. `OPS-32`'s sweep covers machines, images and
keys, not attachments. Proposed: `PRV-45`'s listing runs on every gone path (`OPS-48`'s gone-write row,
`LDG-74`), not only inside a successful delete."

## A triage read at dec039f (verify every claim)

- `PRV-45`: "The engine MUST call it on every delete that succeeds with the resource gone" (02:528-529),
  rows written "in the same transaction as the delete's outcome" (02:530); nothing says what happens when
  the listing call fails. `ADR-0035:79`: "Not covered here: a delete whose success is followed by a
  throttled attachment listing".
- Whatever the delete settles as (succeeded with no rows, `needs_reconciliation`, `failed`), the machine is
  later recorded gone, `STO-18` (05:357) has no rows to hold it, `LDG-74` tombstones it, `LDG-32` closes.
- No later path lists attachments again: `OPS-32`'s attachment pass (ADR-0037 Q14) visits only machines
  "still retained by `STO-18`" (03:1368) and only writes `released_at`; `API-65` releases existing rows only.
- Wider than filed: a machine the provider terminated (no delete; `LDG-74` calls "a terminated machine
  leaving volumes behind" the "ordinary case", 12:572-573) and a scheduled delete also skip the listing.
- `OPS-32` never enumerates account-level attachments (Robot `GET /ip`, `GET /subnet`), so an orphan IP
  whose server is tombstoned is never found.
- v1 cost: the customer pays nothing (no attachment customer rate, ADR-0037 Q18); the operator pays Hetzner
  for a surviving additional IP/subnet with no end date. Conditional on Robot IPs surviving server
  cancellation at all (`02:195` "possible survivors pending research batch B, step 9"; Hetzner's FAQ:
  "You may need to cancel these separately").
- Proposed smallest fix: `STO-18` retains a gone machine until a complete `PRV-45` listing has been
  written for it (and `LDG-32`'s close condition likewise); `OPS-32`'s existing pass over retained
  machines then repeats the listing, inserts missing rows and enqueues `release_attachment` for billable
  `api` rows, as `PRV-45`'s terminal transaction does.

## Questions

1. Is the triage right? Trace a Robot delete whose listing is throttled, a provider-terminated machine, and
   a scheduled delete, at dec039f. Where exactly does a surviving billable attachment become invisible?
2. Can an adversary cause it, and what does it cost the operator? Or is it only an accident path?
3. The smallest fix. Compare: (a) the proposal above (retain until a complete listing; the sweep repeats
   it); (b) an account-level orphan comparison in `OPS-32` (Robot `GET /ip`/`GET /subnet` against known
   attachments); (c) run the listing on every gone path (the bug's proposal — does it survive a failed
   listing?). Or something smaller. Does any of it interact with ADR-0035 (`needs_reconciliation` after
   acceptance), ADR-0037 Q14/Q18, or `LDG-32`'s and `STO-18`'s tombstone and commitment rules?
4. The strongest "don't build this", and what the Lean model and CNF items must show.

## Output

At most 900 words, no preamble: a one-line verdict; why; every defect with `file:line`; the edits.
