# r63f tally: S2 consensus and S3 vote (pv-s4m). 2026-10-23

All four readers exited 0 with full answers: fable.md 4265 bytes, opus.md 4860, astra.md 3903, sol.md 3959. The
rules are in notes.md, fixed before launch. Every PICK below carries a quoted MUST or a trace, so all are valid
(rule 1).

| Item | fable | opus | astra | sol | Result |
|---|---|---|---|---|---|
| STOP | **B**, A acceptable | **A** (moved from B), B acceptable | **A**, B acceptable | **B** (moved from A), A acceptable | **2-2, and both forms are acceptable to all four.** Rule 2(b) qualifies both, and the PICKs tie, so it goes to the owner (S2') |
| LOCK | **B** with repairs, A acceptable | **B** with replacement text, A acceptable | **A**, B NOT ACCEPTABLE as written | **A**, B NOT ACCEPTABLE as written | **LOCK-A carries** (rule 2(b)): all four pick it or accept it, and nobody objects. LOCK-B fails: two valid objections |
| S3 | S3-A | S3-A | S3-A | S3-A | **S3-A, 4-0: the panel's pick.** All four say it closes §1's trace. S3-B and S3-AB are acceptable to all four. S3-P and S3-N are NOT ACCEPTABLE to all four. To the owner under rule 3(c) |

## LOCK

- **LOCK-B's objection** (astra, sol): verified.
  - `00:408` sets `statement_timeout` and `lock_timeout` with no ordering between them.
  - The docs say that if `lock_timeout` is the same or larger, "the statement timeout would always trigger first".
  - `03:1825-1826`: a call that "errors or times out" repeats against the bound.
  - LOCK-B exempts only `lock_timeout`. So a statement behind a waiter can still use up the bound and exit, and C9's
    "without the engine exiting" fails.
  - Two further problems:
    - FL3: the engine can't see another role's wait event.
    - Opus: "while a primary backend waits with wait event `SyncRep`" is true on any busy healthy primary.
- **The repaired B texts don't converge.** Under rule 4 they don't enter the result.
  - Fable: opus's condition, plus `lock_timeout` < `statement_timeout` and a role grant.
  - Opus: a stall test, "neither standby … has flushed … the flush position … when the repeat began".
  - Astra and sol, nearly identical to each other: "a blocking chain ends at a primary backend waiting in `SyncRep`",
    covering both time-outs, with the deployment providing cross-role visibility.
  - Astra and sol both write that such an exemption would make B acceptable ("MOVE").
- **What LOCK-A costs, agreed by all four:** P4 is LOST for contention. During a two-standby stall, a write that
  keeps meeting a frozen write's lock can still use up the bound and restart the engine. `OVR-18` alarms the stall.
  No reader found money lost.

## STOP

- **Two readers swapped sides,** and each now finds the other side acceptable.
  - Opus moved to A. "B saves only the engine's connection slots": an `api` replica stopped during a stall leaves
    its own waiters, and nothing drains `api`. And under LOCK-A the engine can exit anyway.
  - Sol moved to B: "B avoids creating those orphans through orderly shutdown."
- **No money trace either way.** Fable: under A, a kill is "a crash" (`03:1773`), and "a row still `running` goes to
  restart recovery".
- **P.** Under A, P3 is kept: a record already sent still lands (opus). Under B, P3 moves to "time excluding
  `SyncRep`" (sol).

## S3

- **All four:** with `off`, postmaster.c:3185-3189 exits the postmaster, so the next start is one RS gates.
- **The cost they accept:** a backend crash is a full outage, lasting through the supervisor's restart and the
  standbys' catch-up.
- **Opus's add-on, read only by opus:** ", and the deployment restarts it". It adds an obligation, so it changes
  behaviour (rule 4), and it goes to the owner as a note.
- **Opus's note:** while RS holds connections during a stall, the engine's connect attempts use up `OPS-49`'s bound,
  which is P4's loop. That is existing behaviour for any store outage, not specific to S3-A.

## Brief errors (each verified)

- **Patroni** (opus, sol), s3-analysis §3/§4(ii). With `primary_start_timeout = 0` and no failover possible,
  Patroni takes ha.py:692, "starting as readonly because i had the session lock", not "starting primary after
  failure": that branch needs a truthy timeout (:662). The path is still ungated, so no conclusion changes.
  Corrected in s3-analysis.md.
- **The table** (sol): `00:408` doesn't list `transaction_timeout`. This touches nothing voted.
- **C6** (astra), in forms-final. "a stalled synchronous standby, on which every write waits" contradicts N3's "while
  both are, every write waits". N3 missed C6. The fix becomes a Run review point.
- **The "[S1 merge: …]" note** (opus) sat inside the normative STO-54 text. It has been moved out of the quote.
- **Rejected:** opus's postmaster.c:2592-2593. The file has the test at :2593 and `crashed = true` at :2594.
- **The STO-54/OC merge** keeps its meaning (fable, astra, sol, opus).

## Ripple: Run review points (verified)

- **`STO-13` `05:1398-1401`:** "so that the time `api` queues behind a migration is bounded" is false while a DDL's
  commit waits (fable, opus, FL2). Fable's text: ", except while that DDL's commit waits for a standby (`STO-7`)".
  It's one reader's text, not voted, and changes no behaviour.
- **`05:189-192` ("fit inside `max_connections`"):** record that waiters left by an exited process hold slots outside
  the account during a stall (astra, sol). It changes no behaviour.
- **C6:** "and either named standby being unavailable (`STO-7`)" (astra), to match N3's `STO-7`.
- **If STOP-B:** the same Run must update the quotes of the `OPS-21` sentences it rewrites:
  - `ADR-0044:46-49`, `10-conformance-checklist.md:1602`, and `StopRecord.lean:4-5` and `:118-119` (astra, sol,
    opus);
  - C13 must also amend `ADR-0044` (opus);
  - under LOCK-A, DL-1's "no client-side deadline cuts it short" gains sol's text: "The standby wait itself has no
    deadline; `OPS-49`'s contention-exhaustion exit remains applicable."
- **If S3-B:** `05:195`'s "MAY front the pools only on two conditions" gains the pooler condition (sol).

## Further rounds before the Run

None needed. Every behaviour-bearing text in either STOP answer, in LOCK-A and in S3-A was read by all four. Two
things would need a round, and only if the owner asks for them: opus's restart add-on, and a repaired LOCK-B.
