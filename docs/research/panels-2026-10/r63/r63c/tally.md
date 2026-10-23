# r63c tally (panel C, last round) — 2026-10-23, clones at dc5d40d

All four exited 0: fable 1730 B, opus 1891 B, astra 668 B, sol 487 B. No reader ran a gate or `lake`. Rules: notes.md.

## S' (pv-s4m): 4-0 ACCEPT. Carries (rule 2).

## F' (pv-n98 + A1): 4-0 ACCEPT. Carries (rule 3). The F6 bullet stays; rule 3's deletion does not apply.

## Brief errors: none (all four)

## Non-blocking notes (not votes, not in the voted text; handed to the Run as review points, behaviour unchanged)

- S2 "keep the supervisor (`OPS-47`) ... from connecting" (fable, opus): the supervisor never connects.
  `03:136-137` (`OPS-47`): "an external supervisor that restarts it and never runs two". The clause that follows
  already covers the engine it starts. Wording, fixed in scope.
- F6 provider application acts on `running` rows only (fable, opus): otherwise a `queued` irreversible row marked
  applied makes the next claim set `secondOrder` (`Restore.lean:440`). This is a proof-route detail, and the
  gate fails if it's wrong.
- S8: claim the first create before cutting the standby off, so the standby holds it `running` and the test
  reaches `OPS-15`'s create exception (opus). This affects how strong the check is. One reader, unread by the others.
  S8's "the standby lacks the first's step-8 write and the second's claim" already implies it.

## Goes to the owner

Q1 S' (4-0; r63b's S 3-1, r63 substance 4-0). Q2 F' (4-0; r63 rated it "mechanics" 4-0). Q3 one Run (r63 3-1;
opus: pv-n98 could land before Q1). Ids free at dc5d40d: CNF-365 (last is CNF-364, 10:138), ADR-0045 (last is 0044).
