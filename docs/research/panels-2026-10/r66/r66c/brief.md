# Panel brief r66c (panel D): Fence G's restore window, drafted; the carried fixes; the dropped rollback clause — pv-buc. 2026-10-24

You are one of four independent reviewers. Your working directory is a fresh throwaway clone of the specification
repository `provisiond-spec` at `d78085a` (master). Read `AGENTS.md` first. `br show pv-buc` prints the bead (if `br`
fails, `.beads/issues.jsonl` holds it). You MAY edit tracked files in this clone to test a claim. Write nothing
outside it (never `/tmp` or `/var/tmp`). Never commit, push or call a provider API. **Run no gate and no `lake`**:
Lean changes are named, not built. Keep `TMPDIR` as set. Do not delegate, background or wait on anything. Have a
draft answer by minute 30. A web lookup is allowed only for postgresql.org documentation, quoted.

**Where this stands.** Fence G (a startup generation every engine write checks) and Form R (a lost lock connection
is a stop the engine records) were merged into one text and read in round r66b. That text is the **Appendix** at the
end of this brief, verbatim; your clone does not contain it. r66b accepted R 4-0. On G, three readers found a
restore window (Q1 below), and the readers proposed fixes this brief carries (Q2). The owner then answered, verbatim:

- on the restore window: "Draft 2) using the panel and assess complexity". Option 2 is an app-side check: the engine
  itself detects that the store went backwards and exits;
- on r66b's rollback question: "Us this scenario real? The project isn't built yet". The answer is no (Q3);
- the owner's standing preference: safety enforced in the application over safety that rests on deployment
  configuration, and "what happens if there is a misconfiguration?"

**Labels.** r66b's four readers are **Reader W, X, Y, Z** here. Inside the Appendix, "Reader 1"–"Reader 4" are an
earlier round's readers, its **[took: …]** notes are settled choices (do not re-argue them), and "Q1", "Q2", "Q3"
mean r66b's questions: its Q2 is Appendix 2 (R), and its Q3 is the rollback question this brief drops. Spans are
numbered as in the Appendix.

**Check every claim this brief makes before you rely on it**, and report each error under "Brief errors". Read text
by requirement id; line numbers are `d78085a` hints. Every quotation of `d78085a` text in this brief was checked
with `grep -F` line by line; text marked "Appendix" is r66b's merged text, not in the repository. Ids the Appendix
takes: `STO-59`, `OPS-50`, `CNF-366`–`CNF-370`, `ADR-0047`. Next free ids for your draft: `STO-60`, `OPS-51`,
`CNF-371`, `ADR-0048` (a draft may instead amend `ADR-0047`, which records R and G).

## Q1. The restore window: draft an app-side check (drafting, not ACCEPT/CANNOT ACCEPT)

### The story

1. An engine E starts. Its startup pass writes the value g into `STO-59`'s row (Appendix 1).
2. A backup is taken after that pass, so the backup holds g.
3. The store is restored from that backup, and E is never stopped. The restore brings `STO-59`'s row back at g.
4. The Appendix's `STO-59` has the restore write a fresh value h "in the transaction that commits `STO-56`'s
   record", and span 19 makes that a MUST of `STO-54`. `STO-56` orders that record only as "written into the restored or promoted store before either component is
   started" (05:1338). E was not started; it survived.
5. `STO-56` says "Both components read the open row before anything else they do" (05:1340): that is what tells "a
   starting process" it is continuing an incident. Nothing makes a surviving E read it again.
6. So if E reaches the restored store before the record commits, it reads g `FOR SHARE`, the equality check passes,
   and its write commits into the rewound store (Reader Z's trace in r66b).

A backup taken before E's own pass holds an earlier value, and equality already refuses E there. The window needs a
backup taken after the survivor's pass. It has two shapes:

- **In place.** The restore replaces the database behind E's connections, so E's lock connection drops. R (Appendix
  2, `OPS-47`) then has E "treat the loss as a stop of every worker not already recording one, record each under
  `OPS-21` …, and then exit non-zero". Those records are writes into the restored store, and they can land before
  the restore record commits.
- **Another server behind the same address.** E's lock connection may stay on the old server, so E sees no loss. It
  keeps claiming and running periodic passes against the restored store, and it skips `STO-54`'s step (1) freeze and
  step (2) quarantine, which a process runs when it starts with a restore record open. While the old server serves
  E's lock connection there are two writable databases. F7 (Q2) has `OPS-50` say "its guarantee covers one writable
  database history": **say which side of that line your draft puts this shape on.**

### The hard constraint

A restore brings back everything in the store at its backup value, `STO-59`'s row included. A check that compares
the store only with itself cannot see the rewind. It must compare the store against something held outside it: the
engine's own memory, or something PostgreSQL itself changes on a restore. Quote postgresql.org for any PostgreSQL
behaviour you rely on, and say which restore methods it holds for.

### What r66b's readers found against the Appendix's `CNF-370`

- **(a)** The window above (Reader Y, Reader Z, and Reader X's trace (a)).
- **(b)** Reader X: an in-place restore kills the lock connection. Under R, a survivor with no worker in flight exits
  without writing, so `CNF-370`'s "the survivor's next write is refused" is unreachable.
- **(c)** Reader X: `CNF-370`'s "every value ever written to the row is distinct" fails if putting the backup's g back
  counts as writing it. The Appendix's `STO-59` has the same ambiguity: "A value MUST NOT be written to the row twice,
  including across a restore from backup".

### The three r66b repairs, all deployment rules

- Reader Y: "The restored store MUST remain inaccessible to every engine process, including a surviving process,
  until that transaction's commit is acknowledged. Only then may a survivor reach `OPS-50`'s generation check."
- Reader Z: "Until that transaction has been acknowledged, the deployment MUST prevent either component, including a
  process that survived the restore, from using the restored store."
- Reader X: "No component connects to the restored store before that transaction commits.", with the `CNF-370`
  fixture in F3.

### What to draft

**The goal:** the engine itself refuses to write into a store that went backwards, and then exits non-zero, with no
deployment ordering rule needed for that refusal. This is a goal, not a mechanism. Three directions, as examples
only; none is preferred, and you may pick another:

- **A monotonic value** the engine remembers and the store can only move forward, compared as "less than". Your cost
  item must answer the Appendix's `STO-59` ("It is not a counter and is never compared for order") and `ADR-0019`'s
  reason for rejecting an epoch guard: it "keeps a column, a counter and a guard term alive to do it" (0019:81).
- **A restore epoch.** Your cost item must answer where its value lives so that a restore does not bring it back at
  the backup's value, who writes it, and what happens when the restore procedure omits that write.
- **Re-reading a restore marker inside every write transaction.** Your cost item must answer what the check reads
  before `STO-56`'s record commits (the window is exactly that interval) and what each write transaction pays.

Whatever you draft, also answer, inside the six items below:

- both shapes of the window, and traces (b) and (c);
- a promotion that is a restore: `STO-54` says such a promotion "is a restore: the procedure below runs on it, and"
  / "`STO-56`'s record is committed into the promoted store before either component is started." (05:1514-1515).
  Does your check cover it, and does it replace, keep or depend on the stop rule "Before any component connects to
  the promoted store, the deployment MUST stop" / "every engine and `api` process that was connected to the old
  primary" (05:1507-1508)?
- a surviving `api` process: the Appendix's `OPS-50` says "Writes made in the api process are not checked."
  Covered, or why not;
- your own `CNF-370` (a replacement or a delta to F3's text) or a new item, which a conforming engine passes;
- the Appendix's `STO-59` sentence "A value MUST NOT be written to the row twice": keep, reword or replace.

**Give, for your draft:**

1. **The exact spec text**, with before/after spans quoted from `d78085a` or relative to the Appendix (name the
   span or bullet).
2. **What it costs:** new columns or rows, per-transaction work, new `CNF` items, Lean changes, and roughly how many
   requirement spans change.
3. **Its misconfiguration behaviour:** what happens if the restore is run wrong, the clock is wrong, or the backup
   is older or newer than expected.
4. **What it still does not cover.**
5. **A complexity rating:** small, medium or large, with one line of reasoning.
6. **Whether the r66b deployment barrier is still needed** alongside it, and which of the three texts above if so.

You may instead argue that no app-side check is sound. Then give the reason, with a trace or a quoted constraint, in
place of items 1–5, and still answer item 6.

## Q2. The carried fixes: a confirmation read

Each F-item is applied on top of the Appendix. **ACCEPT or CANNOT ACCEPT each.**

**The gate.** A CANNOT ACCEPT must name a loss that changes a checked verdict: a `CNF` assertion or a Lean theorem
that the text flips, makes unreachable or makes vacuous (give its id or theorem name), or a MUST/SHOULD (file and
requirement id) together with a trace that breaks it. For G it also counts with a trace in which the text admits a
stale write or refuses a write it should admit. Give replacement text for that item only. A CANNOT ACCEPT that names
none of these is recorded but does not block. Wording you dislike is not counted.

- **F1. `OPS-21`'s two closed exit lists, and `CNF-362`'s quotation, in lockstep** (behaviour; Reader X, uncontested).
  R's `OPS-21` sentence quotes `OPS-50`'s refusal, but neither closed list names the exit.
  - 03:1741-1742. Before: "subject to the" / "bounded abandonment and later-stop exits below." After: "subject to
    the bounded abandonment, later-stop and superseded (`OPS-50`) exits below."
  - 03:1807. Before: "the Store-retry bound's exhaustion exit, the lost-reply case" After: "the Store-retry bound's
    exhaustion exit, the superseded exit (`OPS-50`), the lost-reply case".
  - `CNF-362` quotes 03:1807 verbatim at 10:1682. The same insertion is made inside that quotation.
- **F2. R's `OPS-47`** (Appendix 2; wording, Reader X). Before: "record each under `OPS-21` within its Stop-record
  bound and exits, and then exit non-zero." After: "record each under `OPS-21` within its Stop-record bound, subject
  to its exits, and then exit non-zero."
- **F3. `CNF-370`** (behaviour; Reader X). It replaces the Appendix's `CNF-370`: "Start an engine and hold one of its
  workers in `execute`; back up. Through a proxy the harness controls, refuse the engine's store connections from
  then until the restore has committed `STO-56`'s record. Make the Stop-record and Store-retry bounds longer than
  that interval, and start no other engine. Then admit its connections. Assert the restore record's transaction
  wrote a fresh value before either component started (`STO-56`), that the survivor's next write (its settle or
  cut-off record) commits nothing and the engine exits non-zero, and that every value written by an advance or by a
  restore record's transaction is distinct." **Read it as the fixture for span 19 as written**: the survivor's write
  comes after the record commits, a case G must handle whatever Q1 picks. The proxy is a harness device, not a
  deployment rule. An ACCEPT here does not endorse a barrier; Q1's drafts give their own `CNF-370` delta.
- **F4. Lean** (behaviour; Reader X). `ADR-0025` says "**Every guard that a dated amendment added is a parameter of
  the model that carries it**, and the" / "module holds two theorems: the bad trace is refused with the guard and
  admitted without it." (0025:118-119). The Appendix's "No field is added to `Guards`/`workerGuard`" leaves the
  witness nothing to switch off. Before (Appendix 1, Lean, `Claim.lean`): "No field is added to
  `Guards`/`workerGuard` (Reader 2)." After: "The check is a parameter of the model that carries `engineStep`,
  `generationCheck : Bool`. `superseded_never_commits` holds with it on, and the witness
  `superseded_commits_without_check` admits the bad trace with it off."
- **F5. Span 13 and `ADR-0047`** (wording). The `ADR-0019` option ends at :81 ("this ADR puts out of scope, and keeps
  a column, a counter and a guard term alive to do it."), and its rejection is on scope and on cost.
  - Span 13. Before: "a dated note after the option ending "Correct, and cheap." (0019:80): "*2026-10-24: this option
    was rejected on scope; `ADR-0047` reopens the scope and adopts it, widened to every engine write (`OPS-50`,
    `STO-59`).*"" After: "a dated note after the option, which ends "a guard term alive to do it." (0019:81):
    "*2026-10-24: `ADR-0047` reopens this option and adopts it, widened to every engine write (`OPS-50`,
    `STO-59`).*""
  - `ADR-0047`. Before: "which was rejected only on scope ("Correct, and cheap.", 0019:80)". After: "which
    `ADR-0019` rejected on scope and on cost: "Rejected because it buys a defence for the case this ADR puts out of
    scope, and keeps a column, a counter and a guard term alive to do it." (0019:80-81); `ADR-0047` states the cost
    G pays in their place".
- **F6. Span 16's replacement** (wording; Reader Y: it contradicted span 12, whose late write "commits nothing … (`OPS-50`
  once the generation has moved"). Before (span 16's After): "What this drill does not exercise is the generation
  fence; `CNF-367`–`CNF-370` drive it (`OPS-50`).*" After: "For the dedicated generation-fence drills, see
  `CNF-367`–`CNF-370` (`OPS-50`).*" Span 16's Before (10:1519-1521) is unchanged.
- **F7. `OPS-50`'s two-copies sentence** (wording; Reader Y: the quoted rule at 05:1508 sits in the promotion bullet
  only). Before (Appendix 1, `OPS-50`): "Nor does it fence two writable copies of the database, which `STO-54`
  excludes: "the old primary MUST NOT serve a component again", or an engine binary that makes no check
  (`STO-13`)." After: "Nor does it fence two writable copies of the database; its guarantee covers one writable
  database history." (The `STO-13` clause also goes with Q3's drop, D2.)
- **F8. `README.md`:304-306** (quotation update: span 1 removes the words it quotes). Before:
  ```
  That the process is one is, in `OPS-47`'s words, "a
  deployment obligation and not a property this specification enforces"
  (`ADR-0019`).
  ```
  After: "That the process is one is, in `OPS-47`'s words, "a deployment obligation" (`ADR-0019`); `OPS-50` refuses
  a superseded engine's writes (`ADR-0047`)."
- **F9. `ADR-0025`:64-67** (quotation update). The bullet quotes `OPS-47`'s "a deployment obligation and not a" /
  "property this specification enforces" (:65-66), words span 1 removes. Add after "a signature shows the dependence.
  A model that omits a second engine says so in its docstring." (:67): "*2026-10-24: `OPS-47` no longer carries these
  words; see `ADR-0047`.*"

**Wording, applied and listed, not voted:**

- **W-1** `OPS-15` (Appendix 1): "This transaction alone is exempt from `OPS-50`'s generation read." is deleted, and
  the paragraph's first sentence ends "…the replacement of `STO-59`'s startup generation (`OPS-50`'s exception)."
  (Reader X: the sentence restates `OPS-50`'s prefix.)
- **W-2** `OPS-50` (Appendix 1): "(`OPS-32`'s cleanup)" becomes "(the key deletion `PRV-9` gives `OPS-32`'s sweep)"
  (Reader W). `PRV-9` (02:142): "registered at the provider MUST be deleted by `OPS-32`'s sweep when, and only when,
  its operation".

**Not adopted** (r66b non-blocking notes, recorded, not voted): Reader X's `STO-54` step (1) writer note; Reader W's
notes 1–3; Reader X's `CNF-367`/`CNF-369` additions; Reader Y's and Reader Z's Lean freshness hypothesis.

**Q2 asks:** ACCEPT or CANNOT ACCEPT each of F1–F9. Does any F-item contradict another, the Appendix, or `d78085a`?
A yes needs quotes from both sides.

## Q3. The dropped `STO-13` transition clause

The repository holds only the specification (`AGENTS.md`:4: "Nothing that implements the specified system belongs
here."), and the owner's answer is that the project is not built yet. So no build without `OPS-50`'s check exists to
roll back to or to run beside the first build with it. The transition clause and r66b's Q3 are dropped. The manager
stripped these dependents:

- **D1.** Span 22 (Appendix 1, `STO-13`) is deleted whole.
- **D2.** `OPS-50`'s ", or an engine binary that makes no check (`STO-13`)" goes (F7 replaces that sentence).
- **D3.** The not-covered bullet "An engine binary that makes no check (`STO-13`, Q3)." is deleted.
- **D4.** `ADR-0047`. Before: "the `STO-13` boundary with Q3's answer". After: "that no transition from an engine
  without the check is specified, because on the owner's answer no build predates `OPS-50`".

**Q3 asks:** with D1–D4 applied, does anything else in the Appendix, in F1–F9 or at `d78085a` depend on the dropped
clause or on r66b's Q3? A yes needs a quote. Is D4's sentence right, or should `ADR-0047` say nothing?

## Answer

**Total: about 2,000 words, not counting drafted spec text.**

**Q1.** Your draft, with items 1–6 labelled; or the "no check is sound" reason and item 6.

**Q2.** For each of F1–F9: ACCEPT or CANNOT ACCEPT. Quote each defect, with the gate it meets and replacement text
for that item only. Contradictions: none, or each with quotes from both sides.

**Q3.** Each dependent, quoted, or "none found" with what you searched. D4: keep, change (give the text), or nothing.

**Brief errors:** each wrong fact, with the grep or quote that shows it.

## Appendix 1: Fence G as merged in r66b (verbatim)

**The design.** (1) One row, `STO-59`, holds the startup generation. Each startup pass replaces it with a fresh
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
share holder the advance waited on has committed (r66's REPEATABLE READ trace).

### New text

- **`STO-59`** (05, a new paragraph after `STO-51`'s, before `### Engine choice` at 05:99): "**STO-59** **ADDED
  2026-10-24 (`ADR-0047`) — the startup generation is one row, and no value is written to it twice.** The store MUST
  hold exactly one row carrying the **startup generation**. `OPS-15`'s startup pass replaces it with a fresh random
  UUID (`gen_random_uuid()`) in a transaction of its own. It is not a counter and is never compared for order:
  every check is equality (`OPS-50`). A value MUST NOT be written to the row twice, including across a restore from
  backup: `STO-54`'s procedure writes a fresh value in the transaction that commits `STO-56`'s record, which is
  written "before either component is started". Without that write, an engine that survived the restore still holds
  the restored value and would match. This row is the fence `STO-51`'s lock is not."
  **[took: Reader 1's and Reader 2's anchor, `STO-56`'s record transaction; the MUST lives in `STO-54` (Reader 2, Reader 3, Reader 4).]**

- **`OPS-50`** (03, after `OPS-49`'s last bullet): "**OPS-50** **ADDED 2026-10-24 (`ADR-0047`) — every engine write
  checks the startup generation, and a mismatch exits.** Except for `OPS-15`'s generation-advance transaction, every
  write transaction made in the engine process — a claim (`OPS-5`), a worker's writes (`OPS-22`, `OPS-43` step 8,
  `OPS-45`'s markers, `OPS-42`'s machine-row writes), a settle or cut-off record (`OPS-21`), an `OPS-8` defer, every
  component `OVR-17` assigns to the engine, `OPS-27` and `OPS-32` included, and the `ledger` components `OVR-17` says
  "run in the engine process" — MUST read `STO-59`'s row `FOR SHARE` as its first statement, compare it for equality
  with the value the engine's own startup pass wrote, and hold that lock until it commits. A component that acts on
  the provider from reads (`OPS-32`'s cleanup) MUST make the check in the read transaction that licenses the
  dispatch. Where the values differ, the transaction MUST roll back, and the engine MUST log loudly that it was
  superseded and exit non-zero at once, beginning no other transaction. A mismatch is not a store error (`OPS-49`)
  and is never repeated. A refused generation check ends recording without another attempt; an earlier attempt may
  already have committed with its reply lost. Writes made in the api process are not checked. **What it does not
  cover:** a provider call licensed by a check that committed before `OPS-15`'s advance goes out — step 9 after step
  8 (`OPS-43`: "Step 9 MUST begin only after step 8's transaction is acknowledged"), an install's destructive phase
  after one marker, end-rescue, `PRV-9`/`PRV-18` temporary-key deletion, `OPS-32` after its read. Nor does it fence
  two writable copies of the database, which `STO-54` excludes: "the old primary MUST NOT serve a component again",
  or an engine binary that makes no check (`STO-13`)."
  - **[took: Reader 4's "Except for `OPS-15`'s generation-advance transaction," (B1).** It is a prefix and leaves the
    sentence whole. Reader 1's "other than the generation write that begins" and Reader 3's "generation-replacement" say
    the same thing. Reader 2's "after … has committed" moves the ordering into `OPS-50`, which `OPS-15` now states.]
  - **[took: Reader 4's lost-reply sentence (B7), the shorter of the two.** It replaces r66's "A record pending under
    `OPS-21` ends there, unlanded, as an exit does." Reader 3's version says the same in two sentences.]
  - **[B10]:** r66's "— and its row reaches `needs_reconciliation` or one of `OPS-15`'s exceptions" is deleted
    (Reader 4: `CNF-303` requires deletion "with the row still absent").
  - The `OPS-8` defer (Reader 1) and the `ledger` components (Reader 2) were r66's non-blocking notes. They are added to the
    list because `CNF-367` drives every listed write. `OVR-17`'s words, at 00-overview:316, are "the three `ledger`
    rows run in the engine process".

- **`OPS-15`**, a new paragraph after its first, which ends "pass is needed; nothing but a restart can leave a
  `running` row with no worker behind it." (03:359): "The engine's first write transaction after taking `STO-51`'s
  lock MUST contain only the replacement of `STO-59`'s startup generation. Its commit MUST be acknowledged before
  the engine begins any other write transaction, the remainder of the pass, or any worker or periodic component. This transaction alone is exempt from `OPS-50`'s generation read. Its
  replacing statement MUST run with `statement_timeout` and `lock_timeout` both set to `OVR-19`'s Startup-lock wait
  bound. That statement waits on every open `FOR SHARE` of the row (`OPS-50`), so every earlier engine's write
  either committed before it, and is swept here, or is refused after it. On that timeout or any store error,
  including a lost reply on its commit, the engine MUST log loudly and exit non-zero having claimed nothing; this
  exit is not `OPS-49`'s retry, which covers workers and periodic components. **Liveness:** a `SyncRep` holder
  (`STO-7`: "A standby wait has no server-side timeout"), or share holders that keep turning over, can hold the
  advance until that exit, which `OVR-18` alarms; the supervisor's restart is the retry."
  - **[took: Reader 4's three sentences for B1+B2,** paired with Reader 4's `OPS-50` prefix. They are the smallest text that
    carries everything r66's tally asks for: its own transaction, nothing else in it, commit acknowledged before the
    sweep, claims and periodic components. Reader 2's single sentence omits the acknowledgement and the periodic
    components. Reader 3's adds a lock-ordering clause and a fourth sentence. **The manager's change, not a reader's:**
    the first sentence is anchored to the engine's first write after the lock, not to "the pass's first
    transaction", because `STO-54`'s step (2) writes "*Before the first claim*" (05:1542) on a startup with an
    open restore record, and a write before the advance would have no own value to compare against.]
  - **[took: Reader 2's timeout sentence (B9).** Reader 2: `lock_timeout` "applies separately to each lock acquisition
    attempt", and `STO-7` registers a `statement_timeout`; setting both bounds the whole wait. Reader 4's fix is the type
    change below. It is needed too, and does not conflict.]
  - **A zero bound:** PostgreSQL says of `lock_timeout` and `statement_timeout` that "A value of zero (the default)
    disables the timeout" (Reader 4's quote, postgresql.org; check it). `OVR-19`'s row becomes "finite, positive" (below),
    so a zero is out of range, and `OVR-19` says startup MUST "refuse to run on a missing or out-of-range value". A
    zero bound therefore stops startup before any advance; it never disables the advance's timeout.

- **`ADR-0047`** (new, one ADR for R and G): records R's decision. States that G **reverses `ADR-0019`'s
  rejection** of "guard the claim itself on `engine_epoch = mine`", which was rejected only on scope ("Correct, and
  cheap.", 0019:80), and that G widens it to every engine write and closes the race with `FOR SHARE`. States the
  not-covered cases, the `STO-13` boundary with Q3's answer, the timeout typing, and that `finished_unrecorded_exit`
  is weakened by one disjunct (below), against `ADR-0044`'s "No existing theorem is weakened".
- **`CONTEXT.md`**: a new entry, **Startup generation**: "the `STO-59` value each startup pass replaces; equality
  only; never written twice".

### Amended spans (before → after). Spans 2, 3, 4, 5, 7, 8, 9, 12, 13 and 14 are r66's, unchanged.

1. `OPS-47` (03:137-139). Before:
   ```
   **That is a deployment obligation and not a
   property this specification enforces** (`OVR-19`): where two engines run, nothing here refuses the
   second, and both will work the queue.
   ```
   After: "**That is a deployment obligation** (`OVR-19`). Where two engines run, no write of the first commits once
   the second's startup pass has committed a new `STO-59` generation (`OPS-50`); provider calls the first already
   licensed still go out." *(Changed from r66: "has replaced" becomes "has committed", because an advance that
   rolls back supersedes nothing (Reader 3).)*
2. `OPS-47` (03:146). Before: "**The lock is not a fence**: no write is guarded on it," After: "**The lock is not a
   fence**: no write is guarded on it (the generation is, `OPS-50`),". (R's loss clause replaces the sentence before
   it; see Q2.)
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
13. `ADR-0019` (0019:78-80): unchanged, with a dated note after the option ending "Correct, and cheap." (0019:80):
    "*2026-10-24: this option was rejected on scope; `ADR-0047` reopens the scope and adopts it, widened to every
    engine write (`OPS-50`, `STO-59`).*"
14. `CONTEXT.md`:108. Before: "_Avoid_: attempt, attempt count, generation, epoch (withdrawn)," After: "_Avoid_:
    attempt, attempt count, generation (that is the startup generation), epoch (withdrawn),".

**New in this round: the quotations r66 found stale (B-missing), and the behaviour ids.**

15. `OPS-15`'s create exception (03:415-416), which quotes `STO-3`'s words that span 11 removes. Before:
    ```
    This describes their predicates, not an in-scope second engine: `STO-3` says
    "nothing contends with it".
    ```
    After: "This describes their predicates; an earlier engine's step-8 write cannot commit once the pass has
    advanced the generation (`OPS-50`)." **[took: Reader 2's.** It is the shortest, and it quotes nothing that could go
    stale. Reader 1's quotes span 11's new words, and Reader 4's replaces three sentences.]
16. `CNF-290`'s note (10:1519-1521), which quotes `OPS-47`'s words that span 1 removes. Before:
    ```
    What this drill must not be
          read to prove is that a second engine cannot write: `OPS-47` says "where two engines run,
          nothing here refuses the second, and both will work the queue".*
    ```
    After: "What this drill does not exercise is the generation fence; `CNF-367`–`CNF-370` drive it (`OPS-50`).*"
    **[took: Reader 2's.** Reader 4's is the same claim without the ids. Reader 1's and Reader 3's add a residual claim.]
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
    status write.*" **[took: Reader 4's**, the one that is dated.] `ADR-0022`:92-93 ("`OPS-47`'s "where two engines run,
    nothing here refuses the second"" / "stays true."): a dated note after "stays true.": "*2026-10-24: `OPS-47` no
    longer says this; an earlier engine's writes are refused once a later engine's pass advances the generation
    (`ADR-0047`, `OPS-50`).*" (Reader 1, Reader 2.)
19. **`STO-54`, behaviour (B3).** In "The procedure survives its own interruption", after "whatever ended its
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
22. **`STO-13`, behaviour (B8).** After "is `STO-54`'s restore." (05:1432, before "**A change to a predicate") add:
    "**`OPS-50`'s check fences only engines that make it.** The release that adds it MUST stop every engine of the
    previous release before its own first engine starts, so its first startup advance has no unchecked engine
    beside it. A previous-release engine still running makes no generation check and is not refused." Q3 decides
    what follows this sentence. **[took: the core shared by Reader 3's and Reader 4's texts.** The rollback clause, on which
    they differ, is Q3.]

**Pointer-only amendments (one appended `OPS-50`/`STO-59` pointer each; no behaviour).** `STO-1` (claim contract);
`STO-6` (primitive list: the row and its `FOR SHARE`); `STO-56` (its record's transaction carries `STO-54`'s fresh
value); `OVR-17` (each engine writer, the `ledger` components included, carries `OPS-50`); `ADR-0016`; `CONTEXT.md`:
520-527, saying why the generation is not the withdrawn epoch: the row has writers other than the engine that checks
it, the next pass and the restore (Reader 1); `CNF-362`'s quotation, if `OPS-21`'s quoted list changes. **Check:** is
any of these behaviour, not a pointer? Is an id still missing?

### New conformance items

- **`CNF-367`** — In a separate run for each engine write path `OPS-50` lists, advance the generation out of band
  (no second engine) after that engine's startup advance, then drive the selected path: it commits nothing; the
  engine logs "superseded" and exits non-zero; no transaction repeats. **[took: Reader 4's, which replaces only the
  setup (B6). Reader 2's is a full rewrite of the item.]**
- **`CNF-368`** — With no engine holding `STO-51`'s lock, open a store session that reads `STO-59`'s row
  `FOR SHARE` and claims a `queued` operation, its transaction left open. Start an engine: assert its generation
  write waits; commit the session; assert the engine's sweep moves the claimed row to its `OPS-15` startup state.
- **`CNF-369`** — As `CNF-368`, but hold the session past the Startup-lock wait bound: assert the engine logs
  loudly and exits non-zero having claimed nothing, `STO-59`'s value is unchanged, and the session's commit then
  succeeds. **[took: Reader 2's harness fixture for both (B4).** Reader 1's is the same shape. Reader 3's and Reader 4's need a
  staged lock-connection loss, and the harness reaches the same advance with less. With no engine holding the
  lock, the exit cannot come from `STO-51`'s refusal (Reader 3's concern).]
- **`CNF-370`** — Start an engine; back up; keep it running with no restart; restore from that backup with the
  engine surviving and reaching the restored store before any engine starts on it. Assert the restore wrote a fresh
  value before either component started (`STO-56`), the survivor's next write is refused and it exits non-zero, and
  every value ever written to the row is distinct. **[took: Reader 1's (B5).** It pins the survivor to the backup's
  value, as Reader 3 and Reader 4 ask. Reader 2's is equivalent.]

### Lean (named, not built)

- `Claim.lean`: the check is modelled on `engineStep` (:430): a mismatch moves the engine to `.exited` with the row
  unchanged, so it is not a `zeroRows` outcome (span 7). No field is added to `Guards`/`workerGuard` (Reader 2). A new
  theorem `superseded_never_commits` states that no claim by a superseded engine commits after the advance, with
  `ADR-0025`'s witness pair: "the bad trace is refused with the guard and admitted without it" (Reader 4). The docstring
  changes as span 17 says.
- `StopRecord.lean`: `Event` gains `| superseded`, which ends the record as `laterStop` does. It applies through
  r65b's Form E fix-8 list, with `superseded` in place of `lockLost` (`schedule`, `schedule_bounded`,
  `later_stop_exits` plus a `superseded_exits` beside it, the three `selection` splits, `money_posts_at_most_once`'s
  docstring). `superseded_exits` keeps `exit_store`'s lost-reply alternative (Reader 3, Reader 4). It weakens
  `finished_unrecorded_exit` by one disjunct, which `ADR-0047` states.

### What G does not cover (stated plainly)

- A provider call licensed by a check that committed **before** the takeover goes out (the list in `OPS-50`).
- Two writable copies of the database (`STO-54`). G fences one database history only.
- An engine binary that makes no check (`STO-13`, Q3).
- Liveness: a `SyncRep` holder, or share holders that keep turning over, delay the takeover until `OPS-15`'s exit.

## Appendix 2: Form R as merged in r66b (verbatim)

R carries r65's fixes 1–7, confirmed in r65b. Form E's fixes 8 and 9 do not apply to R. Below is R's text with
r66's repairs in it.

- **`OPS-47`** keeps master's "hold it for its lifetime". Before (03:145-146):
  ```
  where the connection carrying
  it is lost it MUST exit.
  ```
  After: "where the connection carrying it is lost, the engine MUST, from the moment it detects the loss, log loudly
  that the lock connection was lost, claim nothing more and begin no periodic pass, treat the loss as a stop of every
  worker not already recording one, record each under `OPS-21` within its Stop-record bound and exits, and then exit
  non-zero. The loss is not a later stop: a record already pending when the loss is seen continues under its own
  Stop-record bound and exits." **[took: Reader 2's.** Reader 1's is the same text plus "(`OVR-19`'s keepalives bound
  it)", a claim this round would have to check. Reader 3's and Reader 4's say the same thing in different sentences.]
- **`OPS-21`**, after "thrown away and `OPS-15` classifies the row as interrupted"." (03:1773): "A loss of the
  connection carrying `OPS-47`'s startup lock is not a later stop: `OPS-47` says “treat the loss as a stop of every
  worker not already recording one”. For a worker still in `execute`, this requirement's cancellation rules apply,
  including the stop that “MUST NOT cancel `execute`” and the parent's defer, which “records no error”; for one whose
  `execute` has returned, its settle write records it; it ends no record already pending. A stop that arrives after
  the engine detects the loss and before that record lands is a later stop. `OPS-50` says “A refused generation
  check ends recording without another attempt; an earlier attempt may already have committed with its reply
  lost.”" **[took: Reader 4's "after the engine detects the loss", and Reader 4's quotation in place of r66's "ends there,
  unlanded" sentence.]**
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
  - Changes from r66: the generation sentence (Reader 3); "after the engine detects the loss" in the assertion, which
    the mandated loud log now timestamps, and in (iv) (Reader 4); "every transaction a store error" in (v), since
    `OPS-50` now uses "refuses" for a mismatch (Reader 1).
