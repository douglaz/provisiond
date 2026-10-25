Draft is ready. Everything the brief quotes from `d78085a` checked out; one unlisted document contradicts the combined text, and I'm writing the answer now.

# Panel D, reader r66e-a: Form R + Fence G combined

## 1. ACCEPT

I accept the whole combined text. No defect I found meets the gate. I checked every amended span against `d78085a`, traced the lock protocol against the PostgreSQL 18 documentation, and read `Claim.lean` and `StopRecord.lean` for what the named changes touch. The core argument holds: every engine write transaction takes `FOR SHARE` on the generation row as its first statement, so a transaction that started before the advance holds a lock the advance waits for, and one that starts after it reads the new value and rolls back before holding anything else. The documentation confirms both halves the design rests on. On row locks: "A shared lock blocks other transactions from performing `UPDATE`, `DELETE`, `SELECT FOR UPDATE` or `SELECT FOR NO KEY UPDATE` on these rows, but it does not prevent them from performing `SELECT FOR SHARE`". On the standby wait the Liveness clause names: "Waiting doesn't utilize system resources, but transaction locks continue to be held until the transfer is confirmed." The Lean changes are consistent with the files: `schedule`, `schedule_bounded`, `later_stop_exits` and the three `rcases` splits in `finished_unrecorded_exit` are the only matches on `Event`, and `Witnesses.lean` only builds concrete event lists, so a new constructor breaks nothing there. R's text matches the r64b merge instructions and quotes `OPS-21`'s words correctly.

Recorded, non-blocking. Each has replacement text; all are wording or rationale and may ride into the Run.

**(a) An unlisted document still says the old thing.** `executive-summary.md:250-253` reads: "**Two engines are out of scope and the set says so** (`OPS-47`): a startup lock refuses the second one's *boot*, and nothing refuses its writes, because the epoch that claimed to was comparing a value against itself (`ADR-0019`)." The combined text's `OPS-50` refuses exactly those writes. No gate reads this sentence, so it does not block, but it is the second normative copy `AGENTS.md` warns about. Replacement:

> **Two engines are a deployment fault the set fences** (`OPS-47`, `OPS-50`): a startup lock refuses the second one's *boot*, and once a later engine's startup pass has advanced `STO-59`'s generation, no write of the earlier one commits; provider calls it already licensed still go out (`ADR-0047`). The epoch that first claimed this was comparing a value against itself (`ADR-0019`).

**(b) The README's ADR index has a row per ADR through `0046`** (`README.md:114-117`). The text adds none for `0047`. Replacement, after line 117:

> | `0047` | A lost startup-lock connection is a stop the engine records, and every engine write checks a startup generation that a later startup pass or a restore replaces; a mismatch exits. Adopts the option `0019` rejected; amends `0022` |

**(c) R and G meet in one race the text leaves to inference.** Trace: engine E1 takes the lock and its advance waits on share holders; its lock connection drops; E2 takes the lock and its advance queues on the same row; the holders finish; E2's update commits first, then E1's re-evaluates under read committed and commits E1's value on top. E2's sweep reads E1's value and exits superseded. E1 has no workers, and R's words forbid only claims and periodic passes, so E1 may still run its startup sweep before exiting. Nothing stale commits and the supervisor restarts, so this is not a gate defect. Replacement in R's `OPS-47` sentence, after "begin no periodic pass,": "run none of `OPS-15`'s pass,".

**(d) The "both timeouts" note overstates `lock_timeout`.** PostgreSQL says: "if `statement_timeout` is nonzero, it is rather pointless to set `lock_timeout` to the same or larger value, since the statement timeout would always trigger first." With both set to one bound, `lock_timeout` never fires. The MUST is harmless; the rationale is wrong. Replacement for the note's last clause: "`statement_timeout` alone bounds the wait, since PostgreSQL says the statement timeout 'would always trigger first' when both are equal; `lock_timeout` is set so a lock wait and a slow statement cannot be confused in the log."

**(e) A flag outside G's scope.** PostgreSQL says `statement_timeout` "is measured from the time a command arrives at the server until it is completed by the server", and a COMMIT is not complete until its standby wait ends. `STO-7` (05:145) says "A standby wait has no server-side timeout". That tension exists at `d78085a` on every pooled connection and is not this change's. The new `OPS-15` text scopes its timeouts to "Its replacing statement", which is the right scope; the Run should make sure they do not also cover that transaction's COMMIT.

**(f) Cost note.** Every engine write transaction share-locking one row makes PostgreSQL mint a multixact per new locker set. With `STO-55`'s pool this is modest, but it is the price the design pays and `ADR-0047` could name it.

## 2. Contradictions: yes, one

- **Combined text:** `OPS-50`: "Where the values differ, the transaction MUST roll back, and the engine MUST log loudly that it was superseded and exit non-zero at once". Span 1: "no write of the first commits once the second's startup pass has committed a new `STO-59` generation".
- **`d78085a`:** `executive-summary.md:250-252`: "**Two engines are out of scope and the set says so** (`OPS-47`): a startup lock refuses the second one's *boot*, and nothing refuses its writes". Replacement is (a) above.

Candidates I checked and reject as contradictions: `03-operation-lifecycle.md:139-141` keeps "a node cut off from its supervisor while it still reaches the provider is out of scope", which stays true of its provider calls and sits beside span 1's "provider calls the first already licensed still go out"; `README.md:90` and `ADR-0016:28-30` describe past decisions; `CONTEXT.md:524-525`'s rule against "a guard whose compared value has a single writer that is also the thing being guarded" is met, since the next pass and the restore also write the row; `03:351`'s "With one writer (`OPS-47`)" remains the deployment posture. Every other sentence the spans quote and remove has a listed edit, which I confirmed by grep: the only remaining copies of "nothing here refuses the second" and "deployment obligation and not a" are in spans 1, 3, 4, 16, 18, 24 and 25.

## Brief errors

- **`ADR-0022`:92-93 line split.** The brief renders the quotation as three line segments. At `d78085a` line 92 holds the whole quotation, "against a second engine: `OPS-47`'s "where two engines run, nothing here refuses the second"", and line 93 begins "stays true." The range is right; the break shown inside the quotation does not exist.
- **"Earlier rounds accepted R 4-0" is not checkable in this clone.** The latest tally present, `docs/research/panels-2026-10/r64/r64b/tally.md`, records R as written at "2 ACCEPT, 2 blocking CANNOT ACCEPT" with "Picks: R 4-0". The round that accepted the merged R is not in the repository at `d78085a`.
- **"Three notes marked 'not spec text'"** undercounts by one if the design summary's "(a summary, not spec text)" is meant; three is right if it is not.

Every other line hint and quotation in the brief matched `grep -n` at `d78085a`: 03:137-139, 146, 159, 176-177, 355-356, 359, 415-416, 769, 1735-1737, 1741-1742, 1773, 1807, 1832-1833, 1843-1844, 1879; 05:29-30, 48-49, 91-92, 99, 145, 1514-1515, 1519, 1542, 1557; 10:1511-1512, 1519-1521, 1682; 00:338, 353, 399; 0019:80-81; 0022:82; 0025:64-67; README 304-306; CONTEXT 108, 520-527; `Claim.lean` 22-24 and 430; `AGENTS.md:4`. The ids `STO-59`, `OPS-50`, `ADR-0047` and `CNF-366` to `CNF-370` are unused at `d78085a`.
