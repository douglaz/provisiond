**Final answer: pick B. ACCEPT B as printed. CANNOT ACCEPT A as printed. Question 4: YES to one CNF addition, NO to a new gate.**

Evidence base: my clone at c824e4f, the PostgreSQL 18 page fetched today, and three unpiped gate runs in `/var/tmp/provisiond-panel-r81/tmp/fable/` (pin copy, A applied, B applied).

| sandbox | `nix develop --command bash tools/check-all.sh` exit |
|---|---|
| pin, untouched | 0 |
| A1–A9 applied | 0 |
| B applied | 0 |

Logs and exit files sit beside each copy as `{base,A,B}-gate.{log,exit}`. A's run rebuilt the Lean modules and the citations gate compared the new docstring quote (1039 quotes, 0 absent, same as the pin).

## 1. The conflict is real at the pin, and confined to the aborted first attempt

PostgreSQL 18, Current Date/Time, verified on the official page: "These SQL-standard functions all return values based on the start time of the current transaction", "their values do not change during the transaction", and "`transaction_timestamp()` is equivalent to `CURRENT_TIMESTAMP`". A client cannot assign a transaction's start time. Two transactions begun at different instants carry different values.

Trace (i), first transaction aborts. The dead transport arrives before COMMIT reaches the store; the backend rolls back; no N exists. The retry begins a new transaction at t2. `STO-56` (05-persistence.md:1442–1443) says the operator MUST "reuse both on a lost-reply retry", so the persisted instant must be the retained t1. `STO-54` (:1636–1637) says "restore_instant is transaction_timestamp() of the newly begun transaction inserting this incident", which is t2. Two MUSTs on one column with different values. The operator cannot condition reuse on whether the first attempt committed, because a lost reply is exactly not knowing that (`STO-7`:209 "treats it as a lost reply"). This is a contradictory obligation, not an unsupported premise.

Trace (ii), committed with the reply lost. The pin is coherent only under one reading: the operator "selects" the instant by reading the first transaction's own `transaction_timestamp()` inside it before COMMIT. Then the retry finds N carrying that instant, the guarded no-op matches, nothing changes, and recovery proceeds. The r77b tally's "An uncommitted first attempt instead establishes N once" is right about the id and silent about the instant; it did not examine this clock pair. P/C5 and the landed paragraph agree word for word, so this is not an Implementer departure.

## 2. Exact form

**B: ACCEPT as printed.** One wording defect, non-blocking: B drops the retained instant but keeps "A mismatch in the committed id's restore instant or predecessor MUST be refused". On a lost-reply retry the operator now holds no instant to compare, so that arm has no input and cannot fire. It is dead text, not a contradiction. The predecessor arm keeps exactly the status the r77b tally gave it: under-explained mechanics, no forced refusal, R2 still excluded. B's "an instant selected for an earlier attempt" likewise names a selection B no longer requires; harmless. Bare `restore_instant` and `STO-54` without backticks are invisible to the identifier gate (it matches backticked ids only) and match STO-54:1636's own style.

Exact alternative B′, a distinct form, offered only if the owner wants the dead arm gone. Same text as B with its seventh sentence replaced by:

```text
A mismatch in the committed id's predecessor MUST be refused with both components stopped.
```

I do not count B′ as a wording-only repair: it deletes a MUST arm, even a vacuous one.

**A: CANNOT ACCEPT as printed.** Three defects, two of form and one of substance:

- A9 rewrites the dated UO decision section of `ADR-0023` in place so that the pv-3jw6 record now describes a later decision, and it cannot cite a decision source because none exists yet. This repo appends dated sections ("This supersedes the numeric-report clause under *The decision* above") and AGENTS.md says to write the record after the rule lands.
- A3 replaces lines 21–28 with seven lines and swallows blank line 21, merging two docstring paragraphs. Cosmetic; apply as 22–28.
- A1 says "Its clock definition is new" and gives no clock. UO named the store's transaction clock. Under A the event time is read on an unnamed clock the operator chooses, and A2 then needs a certified error bound for that clock relative to the store's acknowledgement clocks. The unknown path keeps certificates honest, but the definition is looser than what the owner adopted.

A1–A8 as a rule-and-sync set are coherent and gate-green; my grep after applying A found no residual old-clock phrase in the gate corpus. An acceptable A′ is A1–A8 (A3 at 22–28) plus a new appended `ADR-0023` section written after the owner decides. I am not printing that section: it must cite the r81 decision source, which does not exist yet.

**Why B.** It is one paragraph in one file. It keeps the set's single clock: the store's transaction clock, which is also what `LDG-58` acceptance rows and CNF-99's "roll the transaction clock back" rely on. It follows the set's lost-reply pattern (`STO-3`: retain the key, repeat the write, "affects one row and changes nothing") instead of introducing client-selected timestamps. It qualifies the one sentence the r77b brief itself called "a manager-proposed addition ... unreviewed" (brief.md:340), rather than replacing a definition that went through r74–r76, a 4–0 panel, the formal sync and the r79 E-KEEP disposition.

**Requested counterargument.** A gives one event time per actual restore however many attempts it took, keeps f as tight as the first attempt, and keeps a mechanical same-restore check on retry: a reused id with a coinciding predecessor is refused by the instant arm under A and passes under B, where only the operator's distinct-id MUST stands between a reused id and a no-op on a closed record, which starts components with no open incident. Under B, an operator who retries an hour later gets an incident "created" an hour after the restore began, and f loosens by that hour. My reply: that instant arm was never checkable in the one case that matters without producing this very contradiction; the residual scenario needs an operator to reuse an id of a closed incident present in the backup; and the loosened f is still a true certificate because fencing precedes t1 < t2.

## 3. Substance and collateral effects

Substantive versus editorial: A1, A2, A9 and B's paragraph change requirements; A3–A8 are documentation syncs that change no declaration, theorem or guard. The model's `now` is an arbitrary `Nat`; `RestoreTrace.store` writes `restoreInstant := t.now`; `afterCrash` reads it back; `step_three_writes_grace` uses its own `instant`; the witnesses pin `restoreInstant := 50` as a value only. No theorem depends on which clock supplied the value, so neither option forces a paired declaration edit, and neither should claim formal coverage.

What each replaced rule protected and what moves:

- **Stopping/fencing.** `STO-54`:1632–1634 still stops both components before the restore and holds startup until the record's commit is acknowledged. Under A the explicit "The transaction begins after the existing stopping/fencing requirements are satisfied" becomes "The selection occurs after", with the transaction after selection by construction. No loss under either.
- **Certificate truth.** Under B, f = t2 + e_event with "no old-history acknowledgement follows that transaction's start": true, looser by the retry delay. Under A, f = t_sel + e_event where e_event now bounds an operator-chosen clock; A2 says so, and an uncertifiable clock yields null. Neither invents a bound.
- **Null/unknown path, endpoint reuse.** Unchanged under both: endpoints and `history_evidence_ref` are written with the row the inserting transaction commits, and "Continuations reuse the persisted endpoints and evidence unchanged."
- **Record/start boundary, marker provenance, supersession.** C2's initialization rides "the acknowledged transaction that establishes the restore record". Under B in case (i) that is the retry's transaction, which closes R and inserts N whole; in case (ii) it is a no-op. The partial unique open-row index still prevents two open incidents. Unchanged under A.
- **Step marks, grace, ordinary continuation.** Grace is anchored on step (3) (`STO-56`:1458–1460, `OPS-41`:1017, `STO-49`:796), never on the restore instant, and CNF-295's "assert its grace uses its own event, not b, f or restore_instant" stays meaningful. `afterCrash` reads "the instant from the record and never re-computed". No consumer of the instant's absolute value changes except f.
- **Check strength.** No conformance assertion or theorem flips under either. B retires the instant arm of the retry guard to a no-input sentence; what that arm guarded is traced in the counterargument above. A keeps it.
- **E-KEEP and pv-kwuf.** Neither option touches the startup-lock bound, SQL timeout serialization or precision. B keeps the SQL clock E-KEEP left alone. A's selected instant has no stated precision, consistent with E-KEEP only by silence.

Forced replacements missing from the packet: none for B. B needs no live passage changed; the `ADR-0023` P section quotes nothing from the retry paragraph. Its record is a new dated section after the owner decides, not part of B's acceptance. For A, the rule layer is complete and the record form is wrong, as above.

## 4. Separate CNF/gate answer: YES to a CNF case, NO to a gate

No static gate can observe a runtime retry, and `check_citations.py` already guards the quoted definitions. CNF-302 covers the committed-lost-reply shape ("A lost transaction reply must not produce two open incidents") but never drives an aborted first attempt. The failures a case would catch: a tool that caches the instant and writes it as a literal on the retry; a tool that refuses the retry because a cached instant mismatches, leaving both components stopped and recovery blocked; and a tool that inserts a second record after a durable-but-unacknowledged commit.

Exact words to append to CNF-302's supersession paragraph, after "silently continue using predecessor step marks.", written for B:

```text
Separately drive establishment twice for one actual restore with one retained id: once with
the first attempt's connection dropped before its commit reaches the store, and once with it
dropped after the commit is durable but before its reply. In each run assert exactly one
record carries that id, no refusal occurs, and recovery proceeds after the acknowledged
repeat without operator re-selection. In the aborted run assert the persisted
`restore_instant` equals the inserting retry transaction's own `transaction_timestamp()`,
read in that transaction, and not an instant captured before the first attempt; in the
committed run assert it is the first transaction's and the repeat changes nothing. `STO-56`:
"Repeating establishment with that id when a committed matching record exists MUST affect
that record as a guarded no-op".
```

Under A the aborted-run assertion would instead read "equals the instant selected and retained before the first attempt", and the quote would cite A's unchanged `STO-56` sentence. This case is not part of A or B and conditions neither vote.

Housekeeping: nothing in my clone, the tracker or any panel record was changed; the only writes are the sandbox copies and logs under `/var/tmp/provisiond-panel-r81/tmp/fable/`.
