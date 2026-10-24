## Q1 (pv-buc)

**R:** ACCEPT. **E:** ACCEPT. I found no `CNF` item or theorem that either form flips.

**Pick: R.** Per row: a worker cut off during a provider call ends `needs_reconciliation` under both forms. A cut-off `conflict` is ambiguous, and `OPS-15` sweeps the row. Every other row ends the same or better under R:
- A create the provider accepted on a `correlator: none` channel settles `succeeded` instead of going to an operator.
- A pre-marker install settles `failed` instead of `needs_reconciliation`. Under M, so does a pre-dispatch delete.

No row ends worse. `OPS-47` says losing the lock "invalidates nothing already written". Under E the loss costs the outcome in hand, which is `ADR-0044`'s rejected option C: it "substitutes crash recovery even when the process and store can complete the record".

**Against my pick:** R turns a dropped idle connection into a stop that cuts off every `execute`. A misconfigured second engine's boot answer stays wrong for up to one Stop-record bound longer. R also costs more to prove: five `CNF-366` cases, plus `STO-7`'s reconnection check counted against the bound.

**The owner's question: none needed.** After E1 sees the loss, a guard orders every write it still makes:
- E1 claims nothing, begins no pass and cancels every `execute`, so it dispatches no new provider mutation.
- Each record is one transaction. Its first write is `OPS-22`'s guarded status write, which "short-circuits the rest" (`STO-3`). The rest includes the money writes and `OPS-48`'s fence and episode writes, which run "in the terminal transaction".
- E2's startup pass is guarded on `(id, status = running)`.

For each row the first commit wins. Either E1's record lands, which is a better outcome than E2's sweep, or it affects no row and E1 exits under `OPS-22`. The real exposure is the window before E1 sees the loss. That window is the same under both forms, and no check at record time closes it.

**If the owner wants a check anyway:** before its first record after the loss, E1 takes `STO-51`'s lock again, once, on a fresh connection, and holds it until exit. If that is refused, or the lock is lost again, E1 exits at once. What it costs:
- It amends `OPS-47`'s "It answers one question, once, at boot" and `STO-51`'s "it fails a second engine's *startup*".
- After a network blip, E1's own unreaped session refuses it. `ADR-0019` says "A session advisory lock survives its holder when the holder dies without closing the connection". R then falls back to E in the very case R exists for.
- The only records it refuses are ones that would have ended better than E2's sweep.
- It adds a second checkpoint, the start of the "growing back" that `ADR-0019` warns against.

## Q2 (pv-9j6)

**M:** ACCEPT.

**[P]:** YES. `classify` has to carry `!f.accepted`, because `accepted_never_failed` leaves the markers free. [P] makes the Markdown say what the Lean declaration says.

**[Q]:** NO. Under M's Lean, `accepted = true` with the marker unset gives `needs_reconciliation`, so [Q]'s universal is false. M's own `CNF-31b` and `CNF-362` cases already test the change.

**Read whole, does M contradict anything around it?** Yes, but only without [P]:
- M says "any failure the worker records while `OPS-45`'s write-started marker is unset … MUST settle `failed`, whatever its kind".
- The acceptance paragraph says "A later `rate_limited`, `not_found`, `authentication`, or provider 4xx error MUST NOT classify that accepted mutation `failed`."

No trace reaches that clash. `OPS-45` requires each marker write to be "acknowledged by the store before the provider call it precedes is made", and `PRV-5` requires `details.accepted: false` before any byte is sent. On paper the two still conflict, and [P] resolves it.

Two small fixes:
- `CNF-31b` still says the last row reads "`needs_reconciliation` if the failure is *ambiguous*…". After M, that is only the row's "Otherwise" branch.
- In `CNF-362`, "This item is the only check of this case" now follows two cases, so it should read "these cases".

## Brief errors

1. "`ADR-0045`'s 'A sent COMMIT is never abandoned'": the sentence is in `STO-7`. `05-persistence.md` has "**A sent COMMIT is never abandoned** (*added 2026-10-23, `ADR-0045`*)". The only match for "abandon" in ADR-0045 is "deadline-driven abandonment".
2. "Expects exactly one failing file": `ci.yml`'s goal-state flip checks for exactly one error line, with `grep -c '^error: Provisiond/' … -eq 1`. M passes it.
3. Form E is missing an edit. It changes `OPS-21`'s "The Stop-record bound and its expiry exit, the later-stop exit, …", which `CNF-362` quotes word for word. `ADR-0044` says "the citation gate fails an edit that drops or changes one", so `CNF-362`'s quote must change too.
4. Form E's new `lockLost` event also needs an arm in `schedule`, and new cases in `schedule_bounded`, `later_stop_exits` and `finished_unrecorded_exit`.
