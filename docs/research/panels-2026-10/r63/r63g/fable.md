Done. The reader answer is at `/var/tmp/provisiond-panel-r63g/fable.draft.md`, written at 06:03Z, inside the 35-minute draft deadline. It is about 1490 words. The repository was not touched, and no database was started.

**Votes**

| Item | Vote |
|---|---|
| NA | PICK |
| STOP | A PICK (moved from B), B acceptable |
| S3 | S3-B' PICK, S3-A and S3-AB acceptable |
| PT | PICK |
| PA | PA-2 PICK, PA-1 acceptable |
| INV | INV-ADR PICK, INV-STO not acceptable |

**What drove the picks**

- NA is consistent with OPS-21. Its "short of its process exiting" carve-out is exactly OPS-21's expiry exit, and it generalizes the settle-write sentence at `03:1791`.
- I moved STOP to A. With NA the orphan pile-up is bounded per live process, LOCK-A already lets the engine exit mid-stall, and B would make the supervisor's wait unbounded, which is the infra responsibility the owner objects to.
- S3-B' closes the H-a trace and fails closed on a missing privilege. Its check is relative to STO-54's promotion set rather than the server's sync config, so a drifted standby list cannot open it.
- INV-STO is refused on a trace: STO-55's sweeps read in a read-only transaction whose commit is not acknowledged, so the clause's first disjunct is false for conforming code, and the second has no referent under S3-A.

**Findings beyond the votes**

- No CNF assertion catches a promotion that ranks standbys by receive LSN. I proposed a C12 addition modelled on H-e.
- The C12 withhold step only detects a write-on-connect check if run with a standby streaming. Proposed wording fix.
- The barrier-only counter-argument leaves API-11's receipt re-sends uncertified. The trace ends in LDG-14 destroying a machine after a shown success.
- The owner questions are missing verify.md's Q-R. S3-B' answers it by construction, so I proposed stating that instead of asking.
- Brief errors: forms-final cites `03:1738` for a sentence at `03:1763`. The "breaks NA's bound" argument against write checks rests on abandoned checks, which NA forbids. Everything else I relied on checks against its source.
