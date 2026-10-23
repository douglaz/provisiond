# Reader fable, r63h

## Votes

| Item | Vote | Quote or trace |
|---|---|---|
| NA′ | PICK | `18-xact.c:1563-1567` "marked clog … then `SyncRepWaitForLSN`": a commit is flushed before it queues, so it sits at or below any later flush target. B′: "until one of the standbys … has flushed the primary's WAL up to the flush position the primary reports on that connection" (forms-r63g:46-47). A replacement cannot pass in a freeze while the orphan waits. NA′ claims only what cancellation gives. |
| NA-sol | NOT ACCEPTABLE | "Until that backend is known to have finished" names no means. Under B′ the bound holds by the trace above. Under A it is needed, or A states the cost (item 1). |
| INV-ADR′ | PICK | forms-final:42-44 "every acknowledged commit was flushed by one of them … its promotion loses none": a restart discards only unacknowledged visible history. `05:1486` "the lost window `T − Δ`" is the restore. |
| FSW-L | PICK | Window is one postmaster pass: `postmaster.c:3482` loop; `postgres18.c:3027-3050` `die()` only sets `ProcDiePending` and the latch; the reader exits at its next interrupt check (`:502-510`, `:3356`). A deposit-only closure leaves `OPS-32` `03:1631` "**deleted** rather than reported" in the same window to F4 anyway. |
| FSW-N | ACCEPTABLE | Sound: a same-session flush target is ≥ every commit the read saw; with both standbys down the check "cannot see a standby's position". |
| T1 | PICK, replace | Catches Q8(a)(b) via "With healthy replication" and "through the connection-attempt deadline". Keep "both components" (fix e). |
| T2 | ACCEPTABLE | An inspection, not an assertion. F3 owns run-time topology. |
| T3a | ACCEPTABLE | "complete history" is not `STO-54`'s term. |
| T3b | PICK | It is H-e step for step. Q8(e): "no assertion catches it, 4-0". (My r63g text.) |
| T4a | ACCEPTABLE | Same assertion as T4b, new sentence. |
| T4b | PICK | Smaller edit to C12's existing sentence. |
| T5 | PICK | H-f: "insert, flush and both standbys sat at the same LSN for 40 s". "past" never holds on an idle primary; harness used `flush_lsn >=` (results:85). |
| T6a | PICK | Keeps the voted sentence; uses `05:184`'s term "write checkouts are budgeted separately". Q8(d). |
| T6b | ACCEPTABLE | Same drive, rewrites the voted sentence. |
| T7 | PICK | The observable of "never … releases its connection": same backend pid after release. |

## 1. NA′ and NA-sol

The manager's argument holds. The commit record is flushed before the backend queues (`18-xact.c:1563-1567`). The replacement samples target T ≥ L on the primary. A standby's flush ≥ T releases the waiter: `18-syncrep.c:555-559` sets `lsn[mode]` "so that when we wake backends they will release up to this location", and `:907-923` wakes every proc with `waitLSN ≤ lsn`. In-flight case: T < L only if the transport was found dead before the server flushed the orphan's commit. Excess is at most one per such event, and only if a freeze begins inside [T, L]. Otherwise the standby reaches L within milliseconds and releases it. Under S3-A: **yes**, needed or the cost stated. A gates only "After any start of the primary" (forms-final:22). A replacement is used at once. Its write waits at `18-syncrep.c:330-331` with no socket event. The next transport death orphans it, NA′ refills the budget on "the transport is found dead", and the pile grows to `max_connections` (H-c: 17 waiters, FATAL; 30 s unreleased). NA-sol would stop the refill but needs a `pg_stat_activity` read by pid, a privilege A does not otherwise grant. C9's assertion holds within its step (cancellations, live transports, no exit). It is not universal; fix f scopes it.

## 2. INV-ADR′

Accurate. Nothing depends on the broader form: INV-STO is deleted and F4 now reads "against the objective" (forms-r63h §5). The owner line "a write that a no-loss switch could lose" contradicts itself (fix 2).

## 3. FSW

**(i)** The words cover it: "or had a waiting backend cancelled or terminated (`STO-7`) — is a restore". A fast shutdown terminates the waiter by `STO-7`'s permitted means, and PostgreSQL names it "terminating connection due to administrator command" (`18-syncrep.c:304`, H-b). But the list enumerates violations, so the reading is contestable, and the promoting party cannot know: the WARNING is on the lost primary, and both standbys report equal ends. Exact need: an off-primary witness named in `STO-54`. The trace requires both standbys disconnected, since connected ones receive all WAL before shutdown (warm-standby.txt:169), so "a primary stopped while `OVR-18`'s both-standbys alarm was active" is that witness (fix d; behaviour change).

**Not only deposits.** `OPS-32`'s sweep reads, its backend dies, and the provider delete proceeds. `API-11`'s "existing operation" and 409, the revocation 409 `credential_already_replaced` with the old token live again after promotion, and `API-53`'s revision can all escape; those are contract breaks, not money. `LDG-14` cannot: its cancel is an operation needing an acknowledged marker (`03:1422`), impossible in a freeze. `API-54` is a constraint on fixes, not a consequence.

**Destinations:** `WIR-14` POST response and `WIR-15` GET ("the same body"): `lightning.invoice` and `onchain.address`. `WIR-42` returns a balance view, no destination.

## 4. Tests

Votes above. T1 replaces the r63g sentence with "both components" merged.

## 5. What each narrowing gives up

- **NA's claim** protected the write budget as the server-side bound. Under B′ the check protects it (item 1). Under A nothing does; trace in item 1.
- **INV-ADR broader form** protected nothing true. Restores are covered by `05:1485-1516` and `05:867`'s skip-forward.
- **INV-STO** did not cover FSW: "or on a connection `STO-7` checked" admits the window's reader.
- **Per-read check** protected deposits in the window only. Nothing left but F4. An immediate-mode stop avoids the window entirely: SIGQUIT makes nothing visible, and the recovered commit sits behind the new-connection check.
- **NA-sol** protected the bound under A only. Trace in item 1.
- **Tests dropped:** T1, fallback or short-timeout builds pass. T2, nothing automatic. T3, `receive_lsn` ranking passes. T4, automatic restore untested. T5, a false failure on an idle primary. T6, C9 cannot fail. T7, a close-and-count build passes.

## 6. Owner questions

Facts check against the forms and harness except as fixed below: "two new ones" is a count in prose; INV-ADR′ line self-contradictory; "now fixed" overstates NA′; S2′-A cost omits pile-up across repeated stops; S2′-B and Wait lack misconfiguration lines; S3-B "restarting server process" is ambiguous; F "visible for an instant" misplaces the instant; FSW-N's privilege under A is unstated.

## 7. Counter-argument

The reader's SIGTERM is dispatched in the same `SignalChildren` pass, microseconds after the waiter's, before the waiter has even woken (latch wake, WARNING write, commit cleanup). `die()` sets the flag and latch; a reader idle or blocked on the mint's key dies at its next interrupt check, the first thing after wake. A reader mid-statement holds a snapshot older than the commit. The surviving case is a single-statement upsert whose snapshot postdates visibility and whose last interrupt check precedes its signal, before its response flushes: microseconds, racing the postmaster. Then the primary must never serve again before promotion; any restart streams the commit. An immediate stop has no window at all. Harm if it lands: one address re-issued, repairable by a manual index skip.

## 8. Brief errors

- `18-syncrep.c:210/216` is `SyncRepWaitForLSN`'s pre-wait early exit, not the release. The release is `:555-559` and `:907-923`.
- `:331` is `:330-331`.
- FSW step 5 and FSW-L "not yet signalled": the condition is "not yet acted on its signal" (`postgres18.c:3027-3050`). It cuts both ways.
- Step 6 "storage is lost" is sufficient, not necessary: a stopped primary never restarted before a standby is promoted loses the commit on rewind ("rejoins only as a standby", forms-final:49-50). More plausible, not less.
- Owner draft errors as in item 6.

## Fixes (exact text; behaviour change flagged)

1. Intro: "and so do the reviewer's two new ones" → "and so do the ones the reviewer added". No change.
2. INV-ADR′ line: "nothing irreversible may depend on a write that is visible but not yet confirmed by a copy, because a switch to a copy loses it. A restore can still lose confirmed writes." No change.
3. S2′: "that's now fixed" → "that's now bounded". No change.
4. S2′-A cost, append: "Repeated stops during one freeze pile them up (follow-up F2)." No change.
5. S2′-B, add: "If misconfigured: a platform kill timer shorter than the freeze turns B into A, silently." No change.
6. S3-B cost: "a restarting server process" → "a service process that starts or restarts". No change.
7. S3-A bracket: "A broken database connection still lets waiting saves pile up until the database is full (measured). Closing that under A needs the service to read PostgreSQL's activity view, which only B otherwise needs." No change.
8. P Wait, add: "If misconfigured: a failover tool left on its default switches to copy 2 anyway and calls it a no-loss switch. The loss is silent." No change.
9. F TL;DR: "makes waiting saves visible as the server goes down, and a connection still open for an instant can read one." No change.
10. F slot: "Today's text counts that switch as a no-loss switch: both copies report the same position, and nothing off the main server records that a save was cut. So the address can later be handed to another customer." No change.
11. F FSW-N, add: "It needs option B's read permission; under A it brings that permission in." No change.
12. F Accept, add: "An immediate stop of the main server, instead of a fast one, has no such window." No change as information.

Forms text:

- a. Drop opus W1's "even when the worker exits (`OPS-49`) or `OPS-21`'s bound expires": it conflicts with "short of its process exiting", since `OPS-49` says "the engine MUST exit non-zero". Keep E1's "except a sent COMMIT, which no deadline releases". No change beyond NA′.
- b. NA′: "neither a deadline nor the cancellation … releases" → "… MUST NOT release". No change.
- c. FSW-L text: "that has not yet been signalled" → "that has not yet acted on its own signal"; "If the primary is then lost before a standby has the commit" → "If the primary then never serves again before a standby is promoted"; append "An immediate-mode stop has no such window." No change.
- d. `STO-54`, only if the owner wants classification: "(`STO-7`), which includes a primary stopped while `OVR-18`'s both-standbys alarm was active". **Behaviour change.**
- e. T1 merged: "With healthy replication, withhold position-query results from both components through the connection-attempt deadline. Assert each closes the connection without use or fallback, that the check issued no write, and that it created no `SyncRep` backend." No change.
- f. C9: "assert the primary never holds" → "assert that, throughout this step, the primary holds no". No change.

Final:
NA′: PICK
NA-sol: NOT ACCEPTABLE
INV-ADR′: PICK
FSW-L: PICK
FSW-N: ACCEPTABLE
T1: PICK (replace)
T2: ACCEPTABLE
T3a: ACCEPTABLE
T3b: PICK
T4a: ACCEPTABLE
T4b: PICK
T5: PICK
T6a: PICK
T6b: ACCEPTABLE
T7: PICK
