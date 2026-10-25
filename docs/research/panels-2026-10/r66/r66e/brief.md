# Panel brief r66e (panel D): the final confirmation read of Form R and Fence G, combined — pv-buc. 2026-10-24

You are one of four independent reviewers. Your working directory is a fresh throwaway clone of the specification
repository `provisiond-spec` at `d78085a` (master). Read `AGENTS.md` first. `br show pv-buc` prints the bead (if `br`
fails, `.beads/issues.jsonl` holds it). You MAY edit tracked files in this clone to test a claim. Write nothing
outside it (never `/tmp` or `/var/tmp`). Never commit, push or call a provider API. **Run no gate and no `lake`**.
Keep `TMPDIR` as set. Do not delegate, background or wait on anything. Have a draft answer by minute 25. A web
lookup is allowed only for postgresql.org documentation, quoted.

**What this is.** Two changes for one implementation Run, given below as one combined text: **Form R** (a lost
startup-lock connection is a stop the engine records) and **Fence G** (a startup generation every engine write
checks; a mismatch exits). Your clone contains neither. Earlier rounds accepted R 4-0, and accepted 4-0 a set of fixes
to G, which are applied here. G was held on one point, its restore window: an engine that keeps running across a
restore from backup matches the backup's generation until the restore record commits.

**The owner's answer, verbatim:** "I don't think we should tolerate a gross operator mistake like restoring some
backup with the system running". The text below reads it so: a restore performed while any engine or `api` process
runs is outside what G defends. `STO-54`'s procedure states, as a step, that every engine and `api` process is
stopped before the restore begins (span 26); no app-side restore check is added; G's not-covered list names that
restore as unsupported. **This scope is the owner's and is not re-voted.** Disagreement with it is recorded and does
not block.

**What changed from the texts earlier rounds read.**
- The accepted fixes are applied in place: `OPS-21`'s two exit lists and `CNF-362`'s quotation (span 23); R's
  `OPS-47` wording ("subject to its exits"); the Lean parameter `generationCheck`; `ADR-0019`'s note (span 13) and
  `ADR-0047`'s quotation of it; span 16's replacement; `OPS-50`'s two-copies sentence and its `PRV-9` wording;
  `OPS-15`'s exemption sentence; `README.md` (span 24); `ADR-0025` (span 25).
- The `STO-13` transition clause is dropped: span 22 is deleted, with its not-covered bullet and `OPS-50` clause, and
  `ADR-0047` is reworded. The repository holds only the specification (`AGENTS.md`:4: "Nothing that implements the
  specified system belongs here."), and the owner's answer is that the project is not built yet.
- New here: span 26 (the restore step); the unsupported-restore line in the not-covered list; `CNF-370`, which now
  drives a restore with every engine and `api` process stopped and asserts only the restore record's fresh value and
  distinctness; `STO-59`'s heading, its freshness sentence and the `CONTEXT.md` entry, which now say generation
  choices are fresh and that reinstating a backed-up value is not a new choice.
- Span 19 (the fresh value written in the restore record's transaction) is unchanged.
- Round notes and reader attributions are removed. Three notes marked "not spec text" stay as rationale.

**Labels.** Spans are numbered 1–26 as in earlier rounds: 22 is deleted, and 23–26 are new. Line numbers are
`d78085a` hints. **Check every claim this brief makes before you rely on it**, and report each error under "Brief
errors". Every quotation of `d78085a` text in this brief was checked with `grep -F` line by line.

## What to answer

1. **ACCEPT or CANNOT ACCEPT** the whole combined text (parts 1 and 2), read whole.
   - **The gate:** a CANNOT ACCEPT must name a loss that changes a checked verdict: a `CNF` assertion or Lean theorem
     the text flips, makes unreachable or vacuous (id or name), or a MUST/SHOULD (file, id) with a trace that breaks
     it; for G also a trace in which the text admits a stale write or refuses a write it should admit.
   - A trace that needs an engine or `api` process running across a restore violates span 26's MUST. It is not a
     conforming counterexample.
   - Quote each defect and give replacement text for it only. A defect that names none of these is recorded and does
     not block. Wording-only fixes may ride into the Run.
2. **Does anything in the combined text contradict the surrounding spec at `d78085a`?** Answer yes or no. A yes needs
   quotes on both sides: the combined text's words, and the `d78085a` words with file and line.

## Answer

**About 1,000 words, not counting replacement text.** Sections: **1. ACCEPT / CANNOT ACCEPT** (each defect quoted,
gate named, replacement), **2. Contradictions** (yes or no; each with both quotes), **Brief errors** (each wrong
fact, with the grep or quote).

## The combined text, part 1: Fence G

**The design** (a summary, not spec text).
(1) One row, `STO-59`, holds the startup generation. Each startup pass replaces it with a fresh
random UUID in a transaction of its own, committed and acknowledged before anything else in the pass; a restore
writes a fresh one in the transaction that commits `STO-56`'s record. Every check is equality. (2) Every other
engine-process write transaction reads that row `FOR SHARE` first and compares it with its own pass's value, holding
the lock to commit. A mismatch rolls back and the engine exits non-zero at once, never repeating. (3) The advance
waits on every open share lock, bounded by `statement_timeout` and `lock_timeout` set to the Startup-lock wait bound.
On timeout the new engine exits non-zero having claimed nothing.

PostgreSQL 18, 13.3.2: "A shared lock blocks other transactions from performing `UPDATE`" and "Row-level locks are
released at transaction end". **Lock order:** the generation read precedes `LDG-35`'s primitive, and the advance is
a transaction holding only the generation row, so it waits on share holders and holds nothing they wait for: no
cycle. Because the advance commits before the sweep's transaction begins, the sweep's snapshot is taken after every
share holder the advance waited on has committed.

### New text
- **`STO-59`** (05, a new paragraph after `STO-51`'s, before `### Engine choice` at 05:99): "**STO-59** **ADDED
  2026-10-24 (`ADR-0047`) — the startup generation is one row, and generation choices are fresh.** The store MUST
  hold exactly one row carrying the **startup generation**. `OPS-15`'s startup pass replaces it with a fresh random
  UUID (`gen_random_uuid()`) in a transaction of its own. It is not a counter and is never compared for order:
  every check is equality (`OPS-50`). Every startup advance and restore-record transaction MUST choose a random UUID distinct from the values chosen
  by earlier startup advances and restore-record transactions, including choices whose effects a restore removed.
  Reinstating a backed-up value is not a new generation choice. `STO-54`'s procedure writes a fresh value in the transaction that commits `STO-56`'s record, which is
  written "before either component is started". Without that write, an engine that survived the restore still holds
  the restored value and would match. This row is the fence `STO-51`'s lock is not."

- **`OPS-50`** (03, after `OPS-49`'s last bullet): "**OPS-50** **ADDED 2026-10-24 (`ADR-0047`) — every engine write
  checks the startup generation, and a mismatch exits.** Except for `OPS-15`'s generation-advance transaction, every
  write transaction made in the engine process — a claim (`OPS-5`), a worker's writes (`OPS-22`, `OPS-43` step 8,
  `OPS-45`'s markers, `OPS-42`'s machine-row writes), a settle or cut-off record (`OPS-21`), an `OPS-8` defer, every
  component `OVR-17` assigns to the engine, `OPS-27` and `OPS-32` included, and the `ledger` components `OVR-17` says
  "run in the engine process" — MUST read `STO-59`'s row `FOR SHARE` as its first statement, compare it for equality
  with the value the engine's own startup pass wrote, and hold that lock until it commits. A component that acts on
  the provider from reads (the key deletion `PRV-9` gives `OPS-32`'s sweep) MUST make the check in the read transaction that licenses the
  dispatch. Where the values differ, the transaction MUST roll back, and the engine MUST log loudly that it was
  superseded and exit non-zero at once, beginning no other transaction. A mismatch is not a store error (`OPS-49`)
  and is never repeated. A refused generation check ends recording without another attempt; an earlier attempt may
  already have committed with its reply lost. Writes made in the api process are not checked. **What it does not
  cover:** a provider call licensed by a check that committed before `OPS-15`'s advance goes out — step 9 after step
  8 (`OPS-43`: "Step 9 MUST begin only after step 8's transaction is acknowledged"), an install's destructive phase
  after one marker, end-rescue, `PRV-9`/`PRV-18` temporary-key deletion, `OPS-32` after its read. Nor does it fence
  two writable copies of the database; its guarantee covers one writable database history."

- **`OPS-15`**, a new paragraph after its first, which ends "pass is needed; nothing but a restart can leave a
  `running` row with no worker behind it." (03:359): "The engine's first write transaction after taking `STO-51`'s
  lock MUST contain only the replacement of `STO-59`'s startup generation (`OPS-50`'s exception). Its commit MUST be acknowledged before
  the engine begins any other write transaction, the remainder of the pass, or any worker or periodic component. Its
  replacing statement MUST run with `statement_timeout` and `lock_timeout` both set to `OVR-19`'s Startup-lock wait
  bound. That statement waits on every open `FOR SHARE` of the row (`OPS-50`), so every earlier engine's write
  either committed before it, and is swept here, or is refused after it. On that timeout or any store error,
  including a lost reply on its commit, the engine MUST log loudly and exit non-zero having claimed nothing; this
  exit is not `OPS-49`'s retry, which covers workers and periodic components. **Liveness:** a `SyncRep` holder
  (`STO-7`: "A standby wait has no server-side timeout"), or share holders that keep turning over, can hold the
  advance until that exit, which `OVR-18` alarms; the supervisor's restart is the retry."
  - *Note, not spec text (the anchor):* the first sentence is anchored to the engine's first write after the lock,
    not to "the pass's first transaction", because `STO-54`'s step (2) writes "*Before the first claim:*" (05:1542) on
    a startup with an open restore record, and a write before the advance would have no own value to compare against.
  - *Note, not spec text (both timeouts):* `lock_timeout` "applies separately to each lock acquisition attempt"
    (postgresql.org), and `STO-7` registers a `statement_timeout`; setting both bounds the whole wait.
  - *Note, not spec text (a zero bound):* PostgreSQL says of `lock_timeout` and `statement_timeout` that "A value of zero (the default)
    disables the timeout" (postgresql.org). `OVR-19`'s row becomes "finite, positive" (below),
    so a zero is out of range, and `OVR-19` says startup MUST "refuse to run on a missing or out-of-range value". A
    zero bound therefore stops startup before any advance; it never disables the advance's timeout.

- **`ADR-0047`** (new, one ADR for R and G): records R's decision. States that G **reverses `ADR-0019`'s
  rejection** of "guard the claim itself on `engine_epoch = mine`", which `ADR-0019` rejected on scope and on cost:
  "Rejected because it buys a defence for the case this ADR puts out of scope, and keeps a column, a counter and a
  guard term alive to do it." (0019:80-81); `ADR-0047` states the cost G pays in their place, and that G widens it to
  every engine write and closes the race with `FOR SHARE`. States the not-covered cases (the list below), that no
  transition from an engine without the check is specified, because on the owner's answer no build predates
  `OPS-50`, the timeout typing, and that `finished_unrecorded_exit` is weakened by one disjunct (below), against
  `ADR-0044`'s "No existing theorem is weakened".
- **`CONTEXT.md`**: a new entry, **Startup generation**: "the `STO-59` value each startup pass replaces; equality
  only; freshly chosen by each startup advance and restore-record transaction".

### Amended spans (before → after)
1. `OPS-47` (03:137-139). Before:
   ```
   **That is a deployment obligation and not a
   property this specification enforces** (`OVR-19`): where two engines run, nothing here refuses the
   second, and both will work the queue.
   ```
   After: "**That is a deployment obligation** (`OVR-19`). Where two engines run, no write of the first commits once
   the second's startup pass has committed a new `STO-59` generation (`OPS-50`); provider calls the first already
   licensed still go out."
2. `OPS-47` (03:146). Before: "**The lock is not a fence**: no write is guarded on it," After: "**The lock is not a
   fence**: no write is guarded on it (the generation is, `OPS-50`),". (R's loss clause replaces the sentence before
   it; see part 2.)
3. `OPS-6` (03:176-177). Before:
   ```
   claimed — and is not a fence against a second engine, of which `OPS-47` says "where two engines
   run, nothing here refuses the second".
   ```
   After: "claimed — and is not a fence against a second engine; that is `OPS-50`'s generation check."
4. 03:1735-1737 prose. Before:
   ```
   (`STO-3`). `OPS-42`'s fence writes a machine row and carries no such guard, which is why `OPS-47`
   says "where two engines run, nothing here refuses the second, and both will work the queue"
   instead of implying otherwise.
   ```
   After: "(`STO-3`). `OPS-42`'s fence writes a machine row and carries no such guard; against a second engine it
   carries `OPS-50`'s generation check, as every engine write does."
5. `OPS-5` (03:159). Before: "or the startup pass finds it (`OPS-15`)." After: "or the startup pass finds it
   (`OPS-15`). The claiming step's transaction makes `OPS-50`'s generation check first."
6. `OPS-15` (03:355-356). Before:
   ```
   any claim, the engine MUST move every `running` operation to `needs_reconciliation` — with one
   writer, any `running` row at startup is interrupted —
   ```
   After: "any claim, the engine MUST move every `running` operation to `needs_reconciliation` — after the
   generation advance below no earlier engine's write commits (`OPS-50`), so any `running` row at startup is
   interrupted —"
7. `OPS-22` (03:1832-1833). Before:
   ```
   leave the record
   alone, and exit.
   ```
   After: "leave the record alone, and exit. A write that `OPS-50`'s generation check refuses is not a zero-row
   write: the engine exits at once (`OPS-50`)."
8. `OPS-49` (03:1843-1844). Before:
   ```
   where `OVR-18`'s alarm is
   watching.
   ```
   After: "where `OVR-18`'s alarm is watching. A refused generation check (`OPS-50`) is not a store error and is
   never repeated."
9. `STO-51` (05:91-92). Before:
   ```
   and says
   nothing about any write that already happened.
   ```
   After: "and says nothing about any write that already happened. The fence is `STO-59`'s generation (`OPS-50`)."
10. `STO-3` (05:29-30). Before:
    ```
    — after `LDG-35`'s
      primitive is taken where the settlement needs it, since that lock is the transaction's entry —
    ```
    After: "— after `OPS-50`'s generation read and then `LDG-35`'s primitive where the settlement needs it, since
    those locks, in that order, are the transaction's entry —"
11. `STO-3` (05:48-49). Before:
    ```
    It runs
      before the process makes any claim, so nothing contends with it.
    ```
    After: "It runs after `OPS-15`'s generation advance and before the process makes any claim, so no earlier
    engine's write commits beside it (`OPS-50`)."
12. `CNF-290` (10:1511-1512). Before:
    ```
    and that the old process's late settled-state write affects **no row** and exits it
          (`STO-3`, `OPS-22`).
    ```
    After: "and that the old process's late settled-state write commits nothing and exits it (`OPS-50` once the
    generation has moved; `STO-3`, `OPS-22` otherwise)."
13. `ADR-0019` (0019:78-81): unchanged, with a dated note after the option, which ends "a guard term alive to do it."
    (0019:81): "*2026-10-24: `ADR-0047` reopens this option and adopts it, widened to every engine write (`OPS-50`,
    `STO-59`).*"
14. `CONTEXT.md`:108. Before: "_Avoid_: attempt, attempt count, generation, epoch (withdrawn)," After: "_Avoid_:
    attempt, attempt count, generation (that is the startup generation), epoch (withdrawn),".

15. `OPS-15`'s create exception (03:415-416), which quotes `STO-3`'s words that span 11 removes. Before:
    ```
    This describes their predicates, not an in-scope second engine: `STO-3` says
    "nothing contends with it".
    ```
    After: "This describes their predicates; an earlier engine's step-8 write cannot commit once the pass has
    advanced the generation (`OPS-50`)."
16. `CNF-290`'s note (10:1519-1521), which quotes `OPS-47`'s words that span 1 removes. Before:
    ```
    What this drill must not be
          read to prove is that a second engine cannot write: `OPS-47` says "where two engines run,
          nothing here refuses the second, and both will work the queue".*
    ```
    After: "For the dedicated generation-fence drills, see `CNF-367`–`CNF-370` (`OPS-50`).*"
17. `Claim.lean` docstring (:22-24). Before:
    ```
    refused claim (`engineClaim` claims again from `idle` without counting), and a second engine.
    `OPS-47`'s single engine is assumed throughout, as `OPS-6` says the number "is not a fence against
    a second engine". -/
    ```
    After: "refused claim (`engineClaim` claims again from `idle` without counting), and a second engine beyond
    `OPS-50`'s generation check, which `superseded_never_commits` models. Otherwise `OPS-47`'s single engine is
    assumed, as `OPS-6` says the number "is not a fence against a second engine". -/" (Span 3 keeps those words in
    `OPS-6`.)
18. `ADR-0022`:82 ("The guarded status write is the transaction's first statement"): a dated note at the end of
    that paragraph: "*2026-10-24: `ADR-0047` changes this order; `OPS-50`'s generation read precedes the guarded
    status write.*" `ADR-0022`:92-93 ("`OPS-47`'s "where two engines run,
    nothing here refuses the second"" / "stays true."): a dated note after "stays true.": "*2026-10-24: `OPS-47` no
    longer says this; an earlier engine's writes are refused once a later engine's pass advances the generation
    (`ADR-0047`, `OPS-50`).*"
19. **`STO-54`, behaviour.** In "The procedure survives its own interruption", after "whatever ended its
    predecessor." (05:1557) add: "The transaction that commits that record MUST also write a fresh `STO-59` startup
    generation (`OPS-50`), so an engine that survived the restore holds a value the restored store does not." A
    promotion that is a restore runs the same procedure (05:1514-1515). `STO-56` gets a pointer only.
20. **`OVR-18`, behaviour (the alarm).** After "`ADR-0023`): the recovery point exceeding its threshold, and either
    named standby being unavailable (`STO-7`)." (00-overview:338) add: "**Two exits are alarmed on the same model**
    (added 2026-10-24, `ADR-0047`): an engine's superseded exit (`OPS-50`), and its startup exit on the generation
    advance's timeout (`OPS-15`)."
21. **`OVR-19`, behaviour (the timeout).** Before: "| Startup-lock wait bound | `OPS-47` | duration | yes |"
    (00-overview:399). After: "| Startup-lock wait bound | `OPS-47`, `OPS-15` | finite, positive duration; also the
    generation advance's `statement_timeout` and `lock_timeout` (`OPS-15`) | yes |". This also forbids a zero bound
    for `OPS-47`'s lock retry. That bound was untyped "duration" before.
22. *Deleted: the `STO-13` transition clause. No build predates `OPS-50`.*
23. **`OPS-21`'s two closed exit lists, and `CNF-362`'s quotation, in lockstep** (behaviour).
  R's `OPS-21` sentence quotes `OPS-50`'s refusal, but neither closed list names the exit.
  - 03:1741-1742. Before: "subject to the" / "bounded abandonment and later-stop exits below." After: "subject to
    the bounded abandonment, later-stop and superseded (`OPS-50`) exits below."
  - 03:1807. Before: "the Store-retry bound's exhaustion exit, the lost-reply case" After: "the Store-retry bound's
    exhaustion exit, the superseded exit (`OPS-50`), the lost-reply case".
  - `CNF-362` quotes 03:1807 verbatim at 10:1682. The same insertion is made inside that quotation.
24. **`README.md`:304-306** (quotation update: span 1 removes the words it quotes). Before:
  ```
  That the process is one is, in `OPS-47`'s words, "a
  deployment obligation and not a property this specification enforces"
  (`ADR-0019`).
  ```
  After: "That the process is one is, in `OPS-47`'s words, "a deployment obligation" (`ADR-0019`); `OPS-50` refuses
  a superseded engine's writes (`ADR-0047`)."
25. **`ADR-0025`:64-67** (quotation update). The bullet quotes `OPS-47`'s "a deployment obligation and not a" /
  "property this specification enforces" (:65-66), words span 1 removes. Add after "a signature shows the dependence.
  A model that omits a second engine says so in its docstring." (:67): "*2026-10-24: `OPS-47` no longer carries these
  words; see `ADR-0047`.*"
26. **`STO-54`, behaviour: the restore starts with the system stopped.** Before (05:1519):
    ```
    - **The procedure, in this order.** (1) *Before the startup lock:* the public listener is down;
    ```
    After: "- **The procedure, in this order.** *Before the restore begins,* the deployment MUST stop every engine and
    `api` process, and MUST start neither component until the transaction that commits `STO-56`'s record (below) has
    been acknowledged (*added 2026-10-24, `ADR-0047`*). (1) *Before the startup lock:* the public listener is down;"
    The rest of the bullet is unchanged. The step is unnumbered, so `STO-56`'s `steps_completed` (0 to 3) is
    unchanged. A promotion that is a restore runs this procedure (05:1514-1515), so its components are stopped before
    the promotion begins.
**Pointer-only amendments (one appended `OPS-50`/`STO-59` pointer each; no behaviour).** `STO-1` (claim contract);
`STO-6` (primitive list: the row and its `FOR SHARE`); `STO-56` (its record's transaction carries `STO-54`'s fresh
value); `OVR-17` (each engine writer, the `ledger` components included, carries `OPS-50`); `ADR-0016`; `CONTEXT.md`:
520-527, saying why the generation is not the withdrawn epoch: the row has writers other than the engine that checks
it, the next pass and the restore; `CNF-362`'s quotation is span 23's.

### New conformance items

- **`CNF-367`** — In a separate run for each engine write path `OPS-50` lists, advance the generation out of band
  (no second engine) after that engine's startup advance, then drive the selected path: it commits nothing; the
  engine logs "superseded" and exits non-zero; no transaction repeats.
- **`CNF-368`** — With no engine holding `STO-51`'s lock, open a store session that reads `STO-59`'s row
  `FOR SHARE` and claims a `queued` operation, its transaction left open. Start an engine: assert its generation
  write waits; commit the session; assert the engine's sweep moves the claimed row to its `OPS-15` startup state.
- **`CNF-369`** — As `CNF-368`, but hold the session past the Startup-lock wait bound: assert the engine logs
  loudly and exits non-zero having claimed nothing, `STO-59`'s value is unchanged, and the session's commit then
  succeeds.
- **`CNF-370`** — Start an engine; back up; stop every engine and `api` process; restore from that backup. Assert
  that the transaction that commits `STO-56`'s record wrote a fresh value to `STO-59`'s row before either component
  started (`STO-54`). Then start an engine on the restored store, and assert that every value written by an advance
  or by a restore record's transaction is distinct.
### Lean (named, not built)

- `Claim.lean`: the check is modelled on `engineStep` (:430): a mismatch moves the engine to `.exited` with the row
  unchanged, so it is not a `zeroRows` outcome (span 7). The check is a parameter of the model that carries `engineStep`,
  `generationCheck : Bool`. `superseded_never_commits` holds with it on, and the witness
  `superseded_commits_without_check` admits the bad trace with it off. A new
  theorem `superseded_never_commits` states that no claim by a superseded engine commits after the advance, with
  `ADR-0025`'s witness pair: "the bad trace is refused with the guard and admitted without it". The docstring
  changes as span 17 says.
- `StopRecord.lean`: `Event` gains `| superseded`, which ends the record as `laterStop` does. It applies through
  r65b's Form E fix-8 list, with `superseded` in place of `lockLost` (`schedule`, `schedule_bounded`,
  `later_stop_exits` plus a `superseded_exits` beside it, the three `selection` splits, `money_posts_at_most_once`'s
  docstring). `superseded_exits` keeps `exit_store`'s lost-reply alternative. It weakens
  `finished_unrecorded_exit` by one disjunct, which `ADR-0047` states.

### What G does not cover (stated plainly; `ADR-0047` states this list)

- A provider call licensed by a check that committed **before** the takeover goes out (the list in `OPS-50`).
- Two writable copies of the database (`STO-54`). G fences one database history only.
- A restore performed while any engine or `api` process runs. It is unsupported: `STO-54`'s procedure stops every one
  before the restore begins (span 26). Until the transaction that commits `STO-56`'s record commits, a surviving
  engine can pass its check on the restored value, and `api`'s writes are never checked (`OPS-50`).
- Liveness: a `SyncRep` holder, or share holders that keep turning over, delay the takeover until `OPS-15`'s exit.

## The combined text, part 2: Form R

R's text, with F2 applied.
- **`OPS-47`** keeps master's "hold it for its lifetime". Before (03:145-146):
  ```
  where the connection carrying
  it is lost it MUST exit.
  ```
  After: "where the connection carrying it is lost, the engine MUST, from the moment it detects the loss, log loudly
  that the lock connection was lost, claim nothing more and begin no periodic pass, treat the loss as a stop of every
  worker not already recording one, record each under `OPS-21` within its Stop-record bound, subject to its exits, and then exit
  non-zero. The loss is not a later stop: a record already pending when the loss is seen continues under its own
  Stop-record bound and exits."
- **`OPS-21`**, after "thrown away and `OPS-15` classifies the row as interrupted"." (03:1773): "A loss of the
  connection carrying `OPS-47`'s startup lock is not a later stop: `OPS-47` says “treat the loss as a stop of every
  worker not already recording one”. For a worker still in `execute`, this requirement's cancellation rules apply,
  including the stop that “MUST NOT cancel `execute`” and the parent's defer, which “records no error”; for one whose
  `execute` has returned, its settle write records it; it ends no record already pending. A stop that arrives after
  the engine detects the loss and before that record lands is a later stop. `OPS-50` says “A refused generation
  check ends recording without another attempt; an earlier attempt may already have committed with its reply
  lost.”"
- **`OPS-49`**, its retry-loop bullet (ending "subject to its exceptions and the lost-reply case above.", 03:1879)
  gains: "`OPS-47` says of a lost lock connection “The loss is not a later stop”: a worker repeating a record when
  the loss is seen keeps repeating it."
- `ADR-0019`'s restatement takes `OPS-47`'s new words, with a dated note. `ADR-0047` records the decision.
- `StopRecord.lean`: no new constructor for the loss. `Event`'s doc comment gains: "A lost lock connection is the
  originating stop or no event: `OPS-21` says it “is not a later stop”."
- **Stated by the text:** with no stop pending, the loss is a stop the engine survives for each worker in
  `execute`. A non-parent worker is cancelled and records a cut-off `conflict` under its row (`OPS-11`). The
  exceptions are a create past its confirming read and a delete past its accepted dated cancellation: the stop
  "MUST NOT cancel" them, and they settle as `CNF-362`'s read cases do. A cancelled `suspend_tenant` parent records
  the defer, with no error.
- New **`CNF-366`**: "**A lost startup-lock connection is a stop of every worker, not a later stop.** `OPS-47` says
  “The loss is not a later stop”. Keep the startup generation unchanged throughout these cases; no successor or
  out-of-band writer advances it. Terminate the lock connection's backend: (i) with no stop pending, while a
  non-parent worker is in `execute`, outside `CNF-362`'s absorbed-read cases; (ii) with no stop pending, while a
  create's after-return settle write repeats under `OPS-49`; (iii) while an earlier stop's cut-off record repeats
  under `OPS-49`. For cases (i)–(iii) and (vi), arrange that the record can land before either the Stop-record bound
  or the Store-retry bound expires, with no later stop. Where a write repeats, the store refuses its transactions
  until lock-loss detection and then accepts writes with sufficient time remaining under both bounds. Assert: no
  claim and no periodic pass begins after the engine detects the loss, as its loud log timestamps the detection;
  case (i) records a cut-off `conflict` classified against its row (`OPS-11`); the settle write and the earlier
  record land, the create `succeeded` with its money posted once; the engine exits non-zero only after the records
  land. (iv) Deliver a stop after the engine detects the loss, before a record lands: assert `CNF-362`'s later-stop
  assertions, including “Accept either outcome”. (v) With every transaction a store error after the loss, assert
  exit within the Stop-record bound measured from the stop being recorded (the loss as the engine sees it, or the
  earlier stop), the loud log, and `OPS-15` at restart, including its exceptions. (vi) Repeat `CNF-362`'s cases for
  a create past its confirming read, a delete past its accepted dated cancellation, and a `suspend_tenant` parent at
  successive fan-out positions and waiting on its children, with the loss as the stop and no stop pending, asserting
  their `CNF-362` outcomes: no `needs_reconciliation` and no `cut_off` for the reads, the defer with no error for
  the parent, and exit only after the settle write or defer lands."
