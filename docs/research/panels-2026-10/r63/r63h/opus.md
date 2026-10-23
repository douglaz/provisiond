| Item | Vote | Quote or trace |
|---|---|---|
| NA′ | PICK | "Cancellation alone does not release that write checkout." This closes the H-c cancellation path that `05:143` licensed, and it drops the bound that `18-syncrep.c:331` falsifies. |
| NA-sol | ACCEPTABLE | Under B′ it isn't needed to bound connection slots (§1). |
| INV-ADR′ | PICK | Forms-final `STO-54`: "Any other promotion — … — is a restore". `05:1485-1486` states a lost window. So only the narrowed form is true. |
| FSW-L | ACCEPTABLE | |
| FSW-N | PICK | `05:867`: "**never re-issued**". Trace: the reader samples its target after its read. So the target is ≥ the mint's LSN, which was flushed before the wait (`18-xact.c:1506`). During the freeze the check can't pass, so the address is never shown. |
| T1 | PICK (replace) | It tests B′'s "closed unused, and nothing falls back to an unchecked one" and "never by committing a write". |
| T2 | ACCEPTABLE | |
| T3a | ACCEPTABLE | |
| T3b | PICK | It tests `STO-54`'s "the one further ahead is promoted" against H-e, where both standbys had `receive_lsn` `0/4000000`. |
| T4a | ACCEPTABLE | |
| T4b | PICK | PA-2: "until both standbys report or an operator decides". |
| T5 | PICK | B′ says "up to the flush position". In H-f, an idle primary sat equal to both standbys for 40 s, so "past" fails a correct build. |
| T6a | ACCEPTABLE | |
| T6b | PICK | It tests `STO-55` `05:178`, "is refused `overloaded`", which bites only when the budget is full. It also gives C9's "that replica's" an antecedent. |
| T7 | NOT ACCEPTABLE | NA′ holds the connection only "before the reply arrives", and nothing requires reusing it afterwards. A conforming pool that recycles it, for example to reset it (`05:143-145`), fails T7. |

## 1. NA′ / NA-sol

**Under B′, NA-sol is unnecessary for the slot bound.** The manager's argument holds, but it cites the wrong lines.
- `18-syncrep.c:210/216` is the entry fast path, not the release.
- Release is `SyncRepWakeQueue` (`:924`), and only a streaming or stopping walsender does it (`:494`).
- So a check can pass during catchup a moment before the waiters are released. That gap is brief.

**The in-flight COMMIT.**
- Let F be the last position a named standby flushes before the freeze.
- A stuck orphan has L > F. Its replacement therefore passed with a target ≤ F, sampled before L was flushed.
- The excess is bounded by the replacements that passed before the freeze: in practice at most the write budget, once per freeze.
- No check passes during the freeze, and a returning standby releases every orphan. This is availability only (F2).

**Under S3-A, NA-sol is needed: yes.**
- During a freeze, a write waits on c1, and c1's transport is found dead, so NA′ frees the checkout.
- Nothing checks the replacement c2, so its write waits too. This repeats.
- It ends at H-c's "remaining connection slots are reserved", which refuses every new connection, reads included.

**C9 still holds.** It cancels HTTP clients while the database transports stay alive, so NA′'s exceptions don't arise. T6 is what makes "refused `overloaded`" bite.

## 2. INV-ADR′

- **The case is accurate.** I checked `03:760`, `03:1422`, `03:1630-1635` and `04:829-831`.
- **Nothing depends on the broad form.** "allowed failover" appears nowhere in the spec or in forms-final, and restores have their own cover (`05:1516-1519`).

## 3. FSW

**(i) The draft covers it, but the promoting party can't know.**

Coverage:
- `STO-7` names shutdown as one way to terminate ("other than by shutting the primary down").
- `STO-54`'s "had a waiting backend cancelled or terminated (`STO-7`)" has no exception for that, so step 6's promotion is a restore.
- Read literally, it also makes a restore of a promotion after any fast shutdown with a waiter. That holds even when a connected standby received everything (`warm-standby.txt:169`: WAL must first be "transferred to the currently connected standby servers"). And "after" has no time limit.

Knowability:
- The evidence is the primary's log and the WARNING sent to a component. `STO-7` makes that WARNING "a lost reply", and nothing records either outside the primary.
- `STO-54`'s reports compare the standbys with each other, never with the primary's end of WAL. Under PA-2, the automatic failover sees both reports and promotes as a restart.
- An operator who shut the primary down during `OVR-18`'s alarm could infer it. But a host reboot does the same and records nothing.

**What it would need:** a durable record, kept outside the primary, of the primary's end of WAL at each shutdown. A promotion would be a restart only if the chosen standby reached that position.
- This is a new duty under rule 9.
- It is also a deployment duty that fails silently, which is the owner's worry. That is why I pick FSW-N.

**Other consequences.** Deposits are not the only one.
- **Revocation replay.** The re-send gets `409` `credential_already_replaced` (`04:582`). After a promotion classed as a restart, the stolen token is live again: a restart doesn't run the restore's "every spending token dies" (`05:1516-1517`).
- **`OPS-32`.** The sweep reads "settled" and deletes the key or image at the provider. That provider call runs after the read returns, so the SIGTERM can't stop it.
- **`API-11` and `API-53`:** their effects are visible to the client but recoverable.
- **`LDG-14`** sits behind `OPS-45`'s marker commit. That commit waits for a standby, so it is never acknowledged.

**Responses that expose a deposit destination:**
- `POST /v1/deposits` when re-sent (`API-45`, WIR-14 `"address"`);
- `GET /v1/deposits/{id}` (WIR-15).

## 4. Tests

- T1 should replace the r63g sentence (fix 8).
- T3b can pass by luck: a build that ranks standbys by receive LSN sees a tie (fix 9).

## 5. What each narrowing gives up

- **NA's dropped claim** protected `05:189-194`'s "The sum fits". Under B′ that still holds, apart from the in-flight excess and process exits (F2). Under A it doesn't (§1).
- **INV-ADR's broad form:** nothing (§2).
- **INV-STO** didn't cover FSW, because the reader is "on a connection `STO-7` checked".
- **The per-read check FSW-L forgoes** is the only thing protecting `05:867` in the window, since (i) can't be applied. That cost goes to the owner.
- **NA-sol, if not adopted:**
  - Under B′, writes take read connections after dead transports, so reads degrade. Availability only.
  - Under A, it is H-c.
- **Tests, if dropped:**
  - Without T3, build (e) goes uncaught, so an acknowledged write is lost and its address re-issued.
  - Without T6, C9's refusal check is vacuous.
  - Without T5, a test that fails correct builds stays.
  - T2 and T7 lose nothing.

## 6. Owner questions

Mostly accurate. Fixes 1-7, 10 and 11 cover these:
- `:56` is wrong. Emptying the list reverts to asynchronous streaming (`warm-standby.txt:165`: synchronous replication needs it "set to a non-empty value"). H-d2 edges shows saves confirmed without a copy.
- `:69` misses that reads stop too.
- `:44` understates B's cost.
- `:14` reads as a contradiction.
- `:87` contradicts E2's "unmeasured".
- F omits FSW-N's reach.
- **PA Wait has no misconfiguration line**, which is the owner's own question.

## 7. Counter-argument

FSW needs all five of these:
1. a freeze;
2. a fast shutdown during it, with no standby connected (`:169`);
3. a reader whose transaction wrote no WAL (`18-xact.c:1558-1560`), since any other reader waits and is terminated;
4. that reader must reply before `postmaster.c:3482`'s tight loop signals it, because a pending SIGTERM makes its next `CHECK_FOR_INTERRUPTS` FATAL. That needs the postmaster preempted mid-loop;
5. disk loss before either standby returns.

It is harmless if the same customer re-sends first, because they get the same index back.

**Concessions.**
- The blocked `API-45` re-sender is woken by the waiter's own lock release (`18-xact.c:2405`, then `:2454`). So it races right behind visibility.
- If another tenant mints first, the payer's funds are credited to that tenant.

## 8. Brief errors

- The release citation `18-syncrep.c:210/216` is wrong (§1). The local flush is at `18-xact.c:1506`, not `:1563-1567`.
- W1's "even when the worker exits (`OPS-49`)" conflicts with NA′. `03:1829` says "the engine MUST exit non-zero". That is a process exit, which NA′ already excepts.
- The owner-draft lines in §6.

## Fixes

Fixes 1-7, 10 and 11 are wording and change no behaviour. Fixes 8 and 9 change only test text.

1. Owner `:56`: "if the copy list is emptied, the database confirms saves without waiting for a copy, and nothing in the service notices (follow-up F3)."
2. Owner `:69`: "Writes stay down" → "The service stays down, reads included,".
3. Owner, PA Wait, add: "If misconfigured: a failover tool left free to switch on one copy's report silently loses confirmed writes, and the service re-issues addresses."
4. Owner `:44`: "Cost: while both copies are down, no new database connection can be used, even to read: a restarting service process can't connect, and a running one can't replace a connection it loses."
5. Owner `:14`: "nothing irreversible may depend on a write that is not yet on a copy, which even a no-loss switch can drop."
6. Owner `:87`: "for an instant" → "for an unmeasured moment, to requests already connected".
7. Owner F, FSW-N, add: "It covers deposit addresses only. A replayed token revocation answered in that moment, and the engine's clean-up deletions, stay with follow-up F4. Under A it also brings in B's check and its read permission." F's slot: "The draft counts this switch as a restore, but nobody can tell once the main server is lost."
8. T1: "Assert closure" → "Assert both components close it,".
9. T3b, append: "then repeat with the standbys' roles swapped".
10. Owner `:35`: "It needs one read permission and no special server setting." STOP-B gains: "If misconfigured: a deploy tool left at its default stop timeout kills the engine mid-wait anyway, as under A."
11. Owner S3-A slot: "Under A, a broken database connection during a freeze lets waiting saves pile up until the database refuses every new connection, even to read."

Final:
- NA′: PICK
- NA-sol: ACCEPTABLE
- INV-ADR′: PICK
- FSW-L: ACCEPTABLE
- FSW-N: PICK
- T1: PICK (replace)
- T2: ACCEPTABLE
- T3a: ACCEPTABLE
- T3b: PICK
- T4a: ACCEPTABLE
- T4b: PICK
- T5: PICK
- T6a: ACCEPTABLE
- T6b: PICK
- T7: NOT ACCEPTABLE
