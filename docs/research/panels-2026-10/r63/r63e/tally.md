# r63e tally: panel C, form S''' (pv-s4m), the LAST round. 2026-10-23

All four exited 0 (fable.md 3340, opus.md 3667, astra.md 2656, sol.md 2414 bytes). Rules: notes.md, fixed before
launch. No r63f.

| Item | fable | opus | astra | sol | Result |
|---|---|---|---|---|---|
| CORE | ACCEPT | ACCEPT | CANNOT | CANNOT | **2-2, falls short** (rule 2). The objections name only C9's "without the engine exiting" and C13's "DL answers its crash loop". No reader objected to any other CORE span, so the rest stands |
| RS | KEEP | DELETE (valid; replacement text) | KEEP | KEEP | **KEEP 3-1**. The lone dissent was checked and is a real gap → owner S3 |
| DL | KEEP | KEEP | DELETE (valid) | DELETE (valid) | **2-2, falls short** → its fallback, the owner (S2) |
| OC | KEEP | KEEP | KEEP | KEEP | **KEEP 4-0** |
| WR | KEEP | KEEP | KEEP | KEEP | **KEEP 4-0** |
| RL | KEEP | KEEP | KEEP | KEEP | **KEEP 4-0** |
| N3 | ACCEPT | ACCEPT | ACCEPT | ACCEPT | **4-0: reviewed text** for three servers |
| NREC | 3 | 3 | 3 | 3 | **3 servers, 4-0**: the panel's recommendation (S1) |

## CORE objection (astra, sol; verified; converging) and opus's opposite fix → S2

- **The trace.** Write A holds a lock (`LDG-35`) while it waits for the standby. 26.2.8.3 says "transaction locks
  continue to be held until the transfer is confirmed", and xact.c:1605 says the same. Engine transaction B keeps
  hitting `lock_timeout`, which `03:1847` makes "a store error ... against this same bound". The bound exhausts,
  and the engine "MUST exit non-zero" (`03:1829`). So C9's "without the engine exiting" and C13's "DL answers its
  crash loop" are false.
- **The objectors' fixes converge on one behaviour:** the exit is accepted.
  - Astra: delete "without the engine exiting", and C13 says that "lock-contention exhaustion can still restart the
    engine".
  - Sol: C9 says "each wait in `SyncRep`", and adds "Exercise a contending engine write and assert `OPS-49`'s bounded
    retry and exit".
- **Opus** (ripple, not a CORE objection) found the same trace and proposes the opposite behaviour: "A
  `lock_timeout` while a primary backend waits with wait event `SyncRep` (`STO-7`) does not consume the bound".
- **Fable** didn't address lock contention.
- The fixes change behaviour, and only their proposers read them. Under rules 2 and 7 they go to the owner, as
  part of S2.

## DL (2-2) → S2

- **All four agree** the commit's standby wait is outside the store-call deadline and outside `OPS-49`'s
  Store-retry bound. Astra's and sol's replacement texts keep that, and both retain DL-3.
- **The split is `OPS-21`'s Stop-record bound.**
  - `03:1765-1768`: "covers connection, execution, commit, read-back and backoff together. On expiry ... the engine
    MUST log loudly ... and exit".
  - `03:1738`: "the engine MUST NOT wait for it past that bound".
  - `03:1771-1772`: "The deployment's supervisor MUST wait at least the Stop-record bound after a stop before it
    kills the engine."
  - Fable and opus exempt the standby wait from it, and extend the supervisor's wait to match. Astra and sol keep
    it: "`OPS-21`'s stop bounds still apply".
- All four found `OPS-21`: fable and opus as a ripple, astra and sol as their DELETE reason. FE2 found the same.
- **Safety check (manager):** neither side leaves a known money hole.
  - `OPS-21` already handles a record that doesn't land: "A kill before the record lands is a crash", and "a row
    still `running` goes to restart recovery".
  - A late-landing commit is the existing lost-reply case, which claim numbers guard (`ADR-0022`).
  - The cost differs by side. Under "keep the bounds", every exit during a stall leaves a frozen session holding a
    connection and its locks until the standby returns. That breaks `05:191`'s "fit inside `max_connections`"
    during a long stall (sol). Under "exempt", a stop during a stall hangs until the standby returns.
- r63 rule 6: astra calls DL's "Why" ("DL answers `ADR-0023`'s crash loop") a brief error. It is verified by the
  trace above. The affected items, DL and C13's sentence, go to the owner anyway.

## RS's lone dissent (opus), checked: a real safety gap → S3

- **The trace.** One PostgreSQL process is killed, for example by a memory cap as on 2026-10-21, while a deposit
  write waits on a partitioned standby. Verified from runtime-config-error-handling: "`restart_after_crash` ... When
  set to on, which is the default, PostgreSQL will automatically reinitialize after a backend crash".
  - Crash recovery marks the waiting commit committed, and the pools reconnect.
  - The deployment sees no "start of the primary", so RS never fires.
  - A re-send returns the deposit. The primary is then lost, and the promotion drops the deposit. That breaks
    `04:830` and `05:867`, the same hole RS closes.
- **Fix** (opus's text, read by opus alone): "The deployment turns `restart_after_crash` off, so a backend crash
  stops the primary. After any start of the primary, …". The docs name this use: "when PostgreSQL is being invoked
  by clusterware, it may be useful to disable the restart".
- It is new words that change behaviour, so it goes to the owner (rule 7). It is not deleted, because without it
  the hole stays open.

## Facts

- **FE1, none (4-0).** No theorem carries `committed false` across a restart or promotion: `Restore.lean` takes no
  `StoreOutcome`, and `StopRecord.lean:9` excludes "restart". C15 stays a docstring edit.
- **FE2, yes (4-0).**
  - `OPS-21`'s Stop-record bound and the supervisor kill (all four).
  - `OPS-49`'s `lock_timeout` rule (opus, astra, sol).
  - `OVR-18` only raises an alarm, and `/healthz` (`04:7`) is liveness only (fable, opus).

## NREC reasons (4-0 for three servers)

- Fable: with two servers, every primary restart (RS) and every write waits on the one standby.
- Opus: `STO-6` (`05:104-107`) accepts only "the supervisor's restart window" as the outage of the mechanisms that
  stop billing. With two servers, any single failure stops `LDG-14`'s cancellation and `SEC-45`'s suspension.
  Verified at `05:104-107`.
- Astra: one failure still leaves a path to synchronous writes without first provisioning a replacement.
- Sol: a surviving standby can acknowledge writes after one server fails.

## Run review points (deletion-only or location fixes; verified)

- `CONTEXT.md`: C14's phrase starts at `:184` ("a restart loses no committed" / "work"). Lean paths are under
  `tools/formal/Provisiond/` (fable).
- Fable confirmed that `CNF-365` and `ADR-0045` are free: the last ids at dc5d40d are `CNF-364` and `ADR-0044`.
- Under S2 option A, DL-2's OPS-49 words lose ", which no client-side deadline cuts short". `STO-7` keeps DL-1's
  keepalive clause so DL-3's row has a home.
- Under S2 option B, `00:402`'s Stop-record row follows the amended `OPS-21` sentence (fable).
