# Panel D, r66b, pv-buc

## Q1 (Fence G): **CANNOT ACCEPT**

Two defects block: B1 and B2. Each needs only a small edit to one span.

**B1: the superseded exit is missing from `OPS-21`'s exit lists.**
- **Gate:** `OPS-21` MUST, plus `finished_unrecorded_exit`.
- `OPS-21` says "A cancellation of `execute` that the engine survives MUST be recorded before the engine exits, for every operation kind, subject to the bounded abandonment and later-stop exits below."
- `OPS-50` says "the transaction MUST roll back, and the engine MUST … exit non-zero at once."
- **Trace:** this is `CNF-367`'s own run on the cut-off-record path. The generation is advanced out of band. A stop arrives during `execute`. The record's first transaction finds a mismatch, and the engine exits without recording.
  - The exit was neither a bounded abandonment nor a later stop, so the MUST is broken.
  - The Lean side adds this exit as a new disjunct of `finished_unrecorded_exit` (`@[req "OPS-21"]`). The Markdown, which renders it, does not.
  - R's quotation of `OPS-50` inside `OPS-21` reports the rule but does not add the exit to either closed list.
- Replacement text:
  - `OPS-21` (03:1739-1741). Before: "subject to the bounded abandonment and later-stop exits below." After: "subject to the bounded abandonment, later-stop and superseded (`OPS-50`) exits below."
  - The after-return list (03:1798). Before: "the Store-retry bound's exhaustion exit, the lost-reply case". After: "the Store-retry bound's exhaustion exit, the superseded exit (`OPS-50`), the lost-reply case".

**B2: a conforming system can fail `CNF-370`.**
- **Trace (a):** the survivor reaches the restored store after it lands but before `STO-56`'s record commits. "Reaching the restored store before any engine starts on it" allows that. Its write matches the backup's value and commits, so "the survivor's next write is refused" fails.
- **Trace (b):** an in-place restore kills the lock connection. Under R, a survivor with no worker in flight detects the loss and exits without writing, so the assertion is unreachable.
- **Trace (c):** the restore puts the backup's value back in the row, so "every value ever written to the row is distinct" fails on every run if "written" covers what a restore puts back.
- Replacement for `CNF-370`: "Start an engine and hold one of its workers in `execute`; back up. Through a proxy the harness controls, refuse the engine's store connections from then until the restore has committed `STO-56`'s record. Make the Stop-record and Store-retry bounds longer than that interval, and start no other engine. Then admit its connections. Assert the restore record's transaction wrote a fresh value before either component started (`STO-56`), that the survivor's next write (its settle or cut-off record) commits nothing and the engine exits non-zero, and that every value written by an advance or by a restore record's transaction is distinct."

**Not blocking:**
- **Restore window.** A survivor that reaches the restored store before `STO-56`'s record still matches. That is a pre-advance licence, but the not-covered list names only `OPS-15`'s advance. Add to `STO-54`'s new sentence: "No component connects to the restored store before that transaction commits."
- **`CNF-367`, read-licensed path.** For `OPS-32`'s cleanup, "commits nothing" proves nothing on its own, because the duty is about the dispatch. Add: "and dispatches no provider call it licensed."
- **`OVR-19` retyping.** Nothing checks the new "finite, positive" type. Add a validation clause to `CNF-369`: "startup refuses a missing, zero, negative or non-finite Startup-lock wait bound."
- **Commit wait.** `statement_timeout` does not bound the advance's own commit wait (`STO-7`: "A standby wait has no server-side timeout"). The liveness note should say that too.
- **`STO-54` step (1).** It is "*Before the startup lock*" and includes "`provider_account_status` is re-established". No requirement names the engine as the writer. If an implementation's engine makes that write, `OPS-50` has no value to compare against. Pin step (1) to the operator, or exempt writes made before the advance.

**The [took] choices.** They hold, with two notes:
- `OPS-15`'s "This transaction alone is exempt from `OPS-50`'s generation read" restates `OPS-50`'s prefix in a second place. Replace it with "(`OPS-50`'s exception)".
- B9: PostgreSQL says "if `statement_timeout` is nonzero, it is rather pointless to set `lock_timeout` to the same or larger value, since the statement timeout would always trigger first." Setting both is harmless but redundant; `statement_timeout` alone bounds the wait.

**Missing ids.**
- `README.md:304-305` says, "in `OPS-47`'s words, "a deployment obligation and not a property this specification enforces"". Span 1 deletes those words. After: "That the process is one is, in `OPS-47`'s words, "a deployment obligation" (`ADR-0019`); `OPS-50` refuses a superseded engine's writes (`ADR-0047`)."
- `ADR-0025:64-65` quotes the same words. It needs a dated note only, since the citation gate does not read ADRs as quoted input.
- I found no other residual quotation of a span being changed (I grepped each removed phrase).
- Every pointer-only amendment is a pointer, not new behaviour.
- `CNF-368` and `CNF-369` hold.

**Lean.** `ADR-0025:118` says "Every guard that a dated amendment added is a parameter of the model that carries it". "No field is added to `Guards`" leaves the second witness ("admitted without it") nothing to switch off.
- Add a `generationCheck : Bool` parameter to the model that carries `engineStep`, for example a new `Claim.EngineParams`.
- Name the second witness `superseded_commits_without_check`.
- The `StopRecord` plan holds. Also amend `Restore.lean`'s `Permissions` docstring, which says "On a restart everything but the claim … is permitted at once"; it should come after the advance.

## Q2 (Form R as merged): **ACCEPT**

R does not contradict G:
- R's `OPS-21` sentence quotes `OPS-50`'s refusal.
- `CNF-366` says "Keep the startup generation unchanged throughout these cases".
- Span 2's "(the generation is, `OPS-50`)" sits after R's new sentences and agrees with them.
- `CNF-366` checks only what the text requires. The loud log it timestamps is required "from the moment it detects the loss".
- Wording only: "record each under `OPS-21` within its Stop-record bound and exits, and then exit non-zero" reads better as "…within its Stop-record bound, subject to its exits, and then exit non-zero."

Once B1 lands, R's `OPS-21` quotation and G's exit list say the same thing.

## Q3 (`STO-13` rollback): **(A)**, with one added sentence

(B) contradicts `STO-13`:
- `STO-13` defines a contract step as "A removal, rename, tightening or `VALIDATE`", and G's release removes nothing.
- "recovery past it is `STO-54`'s restore" is false while a forward-fix release stays admissible.
- Taken literally, (B) prices a bad G release at a restore, whose step (3) bumps every tenant's credential generation.

`STO-13`'s existing predicate rule does not cover span 22, so span 22's MUST is needed. That rule fires on "a predicate or derivation both components evaluate", and `api` makes no generation check.

Q3's own trace (a newer engine that lost its lock unnoticed keeps matching its value) is closed by one write. Span 22 continues: "Rollback to such a binary stays admissible under the rule above. The rollback MUST write a fresh `STO-59` value before the previous-release engine starts, so that any engine of the rolled-back release still running is refused. While the previous release runs, nothing refuses a second engine, as before `ADR-0047`." Add the rollback as the row's third writer in `STO-59` and in the `CONTEXT.md` pointer.

## Brief errors

1. The 13.3.2 quotation is cut short. The full sentence is "Row-level locks are released at transaction end or during savepoint rollback, just like table-level locks." `OPS-50`'s "hold that lock until it commits" covers the savepoint case.
2. B9's rationale, that setting both timeouts bounds the whole wait, misreads the docs. They call `lock_timeout` at or above a nonzero `statement_timeout` "rather pointless", so `statement_timeout` alone does it.
3. "Is an id still missing?": yes, `README.md:304-305`. Every quotation and line hint I checked was accurate. The next-free ids are unused (the last are `OPS-49`, `STO-58`, `CNF-365` and `ADR-0046`).
