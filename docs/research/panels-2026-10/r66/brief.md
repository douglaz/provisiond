# Panel brief r66 (panel D): Fence G's text, and Form R read whole with it — pv-buc. 2026-10-24

You are one of four independent reviewers. Your working directory is a fresh throwaway clone of the specification
repository `provisiond-spec` at `d78085a` (master). Read `AGENTS.md` first. `br show pv-buc` prints the bead (if `br`
fails, `.beads/issues.jsonl` holds it). You MAY edit tracked files in this clone to test a claim. Write nothing
outside it (never `/tmp` or `/var/tmp`). Never commit, push or call a provider API. **Run no gate and no `lake`**:
the Lean changes below are named, not built. Keep `TMPDIR` as set. Do not delegate, background or wait on anything.
Have a draft answer by minute 25. A web lookup is allowed only for postgresql.org documentation, quoted.

**Where this stands.** Round r65b picked Form R (record first) 4-0 and called Fence G sound 4-0 in principle, but
not as sketched: one reader's restore trace showed a reused generation value admits a stale write. The owner
answered, verbatim: on R, "Yes, R (Recommended)"; on Fence G, "Adopt; one combined Run". Fence A is dropped. So R is
held until G's text is drafted and read; then one Run implements both.

This round has two questions. **Q1** reads Fence G's exact text. **Q2** reads Form R whole with G. Every quoted
"before" span was checked at `d78085a` with `grep -F`, but the manager has been wrong in briefs before: **check every
claim this brief makes before you rely on it**, and report each error under "Brief errors". Read text by requirement
id; line numbers below are `d78085a` hints. Next free ids at `d78085a`: `ADR-0047`, `OPS-50`, `STO-59`, `CNF-366`
(R's), so G's items start at `CNF-367`. One ADR, `ADR-0047`, records R and G together.

## The gate (how a CANNOT ACCEPT counts)

A CANNOT ACCEPT must name a loss that changes a checked verdict: a `CNF` assertion or a Lean theorem that the text
flips, makes unreachable or makes vacuous (give its id or theorem name), or a MUST/SHOULD (file and requirement id)
together with a trace that breaks it. For G it also counts with a trace in which the text admits a stale write (an
old engine's write committing after the advance) or refuses a write it should admit (no takeover happened). Give
replacement text for that span only. A CANNOT ACCEPT that names none of these is recorded but does not block.
Wording you dislike is not counted.

## Q1. Fence G's exact text

**This is the manager's drafted proposal, not a reviewed text. Judge it.** It answers r65b's required inputs: a
never-reused value; the comparison and the `FOR SHARE` in the protected write's own transaction; an explicit,
alarmed startup exit on the advance's timeout; `OPS-15`'s exceptions in the takeover sweep; r65b's id list; the
reversal of `ADR-0019`'s rejection; the residual dispatch window stated plainly.

**The design in three lines.** (1) One row, `STO-59`, holds the startup generation: each startup pass writes a fresh
random UUID as its first statement, and a restore writes a fresh one before the store serves anything, so no value is
ever written twice and every check is equality. (2) Every engine-process write transaction reads that row `FOR SHARE`
first and compares it with its own pass's value, holding the lock to commit; a mismatch rolls back and the engine
exits non-zero at once, never repeating. (3) The advance waits on every open share lock, with `lock_timeout` set to
the startup-lock bound, and on timeout the new engine exits non-zero having claimed nothing.

PostgreSQL 18, 13.3.2: "A shared lock blocks other transactions from performing `UPDATE`" and "Row-level locks are
released at transaction end". **Lock order:** the generation read precedes `LDG-35`'s primitive. The advance holds
nothing but the generation row (it is the pass's first statement, before any claim), so it waits on share holders
and nothing waits on it while holding a lock it wants: no cycle. Repeated new share locks can delay the advance: a
liveness point only.

### New text

- **`STO-59`** (05, after `STO-51`): "**STO-59** **ADDED 2026-10-24 (`ADR-0047`) — the startup generation is one
  row, and no value is written to it twice.** The store MUST hold exactly one row carrying the **startup
  generation**. `OPS-15`'s startup pass replaces it with a fresh random UUID (`gen_random_uuid()`) as its first
  statement. It is not a counter and is never compared for order: every check is equality (`OPS-50`). A value MUST
  NOT be written to the row twice, including across a restore from backup: before a restored store serves any
  component, the restore procedure (`STO-54`, `STO-56`) MUST write a fresh value, as it bumps every tenant's
  credential generation. Without that write, an engine that survived the restore still holds the restored value
  and would match. This row is the fence `STO-51`'s lock is not."
- **`OPS-50`** (03, after `OPS-49`): "**OPS-50** **ADDED 2026-10-24 (`ADR-0047`) — every engine write checks the
  startup generation, and a mismatch exits.** Every write transaction made in the engine process — a claim
  (`OPS-5`), a worker's writes (`OPS-22`, `OPS-43` step 8, `OPS-45`'s markers, `OPS-42`'s machine-row writes), a
  settle or cut-off record (`OPS-21`), and every component `OVR-17` assigns to the engine, `OPS-27` and `OPS-32`
  included — MUST read `STO-59`'s row `FOR SHARE` as its first statement, compare it for equality with the value
  the engine's own startup pass wrote, and hold that lock until it commits. A component that acts on the provider
  from reads (`OPS-32`'s cleanup) MUST make the check in the read transaction that licenses the dispatch. Where the
  values differ, the transaction MUST roll back, and the engine MUST log loudly that it was superseded and exit
  non-zero at once, beginning no other transaction. A mismatch is not a store error (`OPS-49`) and is never
  repeated. A record pending under `OPS-21` ends there, unlanded, as an exit does. Writes made in the api process
  are not checked. **What it does not cover:** a provider call licensed by a check that committed before
  `OPS-15`'s advance goes out — step 9 after step 8 (`OPS-43`: "Step 9 MUST begin only after step 8's transaction
  is acknowledged"), an install's destructive phase after one marker, end-rescue, `PRV-9`/`PRV-18` temporary-key
  deletion, `OPS-32` after its read — and its row reaches `needs_reconciliation` or one of `OPS-15`'s exceptions.
  Nor does it fence two writable copies of the database, which `STO-54` excludes: "the old primary MUST NOT serve
  a component again"."
- **`OPS-15`**, new paragraph after its first: "The pass's first transaction MUST begin by replacing `STO-59`'s
  startup generation. That write waits on every open `FOR SHARE` of the row (`OPS-50`), so every earlier engine's
  write either committed before it, and is swept here, or is refused after it. It MUST run with `lock_timeout` set
  to `OPS-47`'s startup-lock retry bound (`OVR-19`). On that timeout or any store error the engine MUST log loudly
  and exit non-zero having claimed nothing; this exit is not `OPS-49`'s retry, which covers workers and periodic
  components. A `SyncRep` holder (`STO-7`: "A standby wait has no server-side timeout") can stall the advance until
  that exit."
- **`ADR-0047`** (new, one ADR for R and G): records R's decision; states that G **reverses `ADR-0019`'s
  rejection** of "guard the claim itself on `engine_epoch = mine`", rejected only on scope ("Correct, and cheap.
  Rejected because it buys a defence for the case this ADR puts out of scope"), widened to every engine write and
  race-closed by `FOR SHARE`; states the not-covered cases above; and states that `finished_unrecorded_exit` is
  weakened by one disjunct (below), against `ADR-0044`'s "No existing theorem is weakened".
- **`CONTEXT.md`**: a new entry **Startup generation** ("the `STO-59` value each startup pass replaces; equality
  only; never written twice").

### Amended spans (before → after)

1. `OPS-47` (03:138-139). Before: "**That is a deployment obligation and not a property this specification enforces**
   (`OVR-19`): where two engines run, nothing here refuses the second, and both will work the queue." After:
   "**That is a deployment obligation** (`OVR-19`). Where two engines run, no write of the first commits once the
   second's startup pass has replaced `STO-59`'s generation (`OPS-50`); provider calls the first already licensed
   still go out."
2. `OPS-47` (03:146). Before: "**The lock is not a fence**: no write is guarded on it," After: "**The lock is not a
   fence**: no write is guarded on it (the generation is, `OPS-50`),". (R's replacement of "where the connection
   carrying it is lost it MUST exit." stands, Q2.)
3. `OPS-6` (03:176-177). Before: "and is not a fence against a second engine, of which `OPS-47` says "where two
   engines run, nothing here refuses the second"." After: "and is not a fence against a second engine; that is
   `OPS-50`'s generation check."
4. 03:1735-1737 prose. Before: "`OPS-42`'s fence writes a machine row and carries no such guard, which is why
   `OPS-47` says "where two engines run, nothing here refuses the second, and both will work the queue" instead of
   implying otherwise." After: "`OPS-42`'s fence writes a machine row and carries no such guard; against a second
   engine it carries `OPS-50`'s generation check, as every engine write does."
5. `OPS-5` (03:159). Before: "or the startup pass finds it (`OPS-15`)." After: "or the startup pass finds it
   (`OPS-15`). The claiming step's transaction makes `OPS-50`'s generation check first."
6. `OPS-15` (03:354-355). Before: "— with one writer, any `running` row at startup is interrupted —" After: "— after
   the generation write below no earlier engine's write commits (`OPS-50`), so any `running` row at startup is
   interrupted —".
7. `OPS-22` (03:1832-1833). Before: "leave the record alone, and exit." After: "leave the record alone, and exit. A
   write that `OPS-50`'s generation check refuses is not a zero-row write: the engine exits at once (`OPS-50`)."
8. `OPS-49` (03:1843-1844). Before: "where `OVR-18`'s alarm is watching." After: "where `OVR-18`'s alarm is watching.
   A refused generation check (`OPS-50`) is not a store error and is never repeated."
9. `STO-51` (05:91-92). Before: "and says nothing about any write that already happened." After: "and says nothing
   about any write that already happened. The fence is `STO-59`'s generation (`OPS-50`)."
10. `STO-3` (05:30). Before: "after `LDG-35`'s primitive is taken where the settlement needs it, since that lock is
    the transaction's entry —" After: "after `OPS-50`'s generation read and then `LDG-35`'s primitive where the
    settlement needs it, since those locks, in that order, are the transaction's entry —".
11. `STO-3` (05:48-49). Before: "It runs before the process makes any claim, so nothing contends with it." After: "It
    runs after `OPS-15`'s generation write and before the process makes any claim, so no earlier engine's write
    commits beside it (`OPS-50`)."
12. `CNF-290` (10:1511-1512). Before: "and that the old process's late settled-state write affects **no row** and
    exits it (`STO-3`, `OPS-22`)." After: "and that the old process's late settled-state write commits nothing and
    exits it (`OPS-50` once the generation has moved; `STO-3`, `OPS-22` otherwise)."
13. `ADR-0019` (78-80): unchanged, with a dated note after the option: "*2026-10-24: this option was rejected on
    scope; `ADR-0047` reopens the scope and adopts it, widened to every engine write (`OPS-50`, `STO-59`).*"
14. `CONTEXT.md`:108. Before: "_Avoid_: attempt, attempt count, generation, epoch (withdrawn)," After: "_Avoid_:
    attempt, attempt count, generation (that is the startup generation), epoch (withdrawn),".

**Pointer-only amendments (no quoted before; one appended `OPS-50`/`STO-59` pointer each).** `STO-1` (claim
contract), `STO-6` (primitive list: the row and its `FOR SHARE`), `STO-54`/`STO-56` (the restore's fresh value),
`OVR-17` (each engine writer carries `OPS-50`), `OVR-18` (the "superseded" exit is alarmed), `OVR-19` (the advance's
`lock_timeout` is the startup-lock bound; no new row), `ADR-0016`, `ADR-0022`, `CONTEXT.md`:520-527, and `CNF-362`'s
quotation if `OPS-21`'s list changes. **Check:** is any of these behaviour, not a pointer? Is an id missing?

### New conformance items

- **`CNF-367`** — An out-of-band generation write (no second engine), then drive each worker write and each `OVR-17`
  engine writer: none commits; the engine logs "superseded" and exits non-zero; no transaction repeats.
- **`CNF-368`** — With an engine transaction holding the row `FOR SHARE` open, start a successor: its advance waits;
  the open transaction commits and the successor's sweep sees that commit.
- **`CNF-369`** — Hold that `FOR SHARE` past the startup-lock bound: the successor logs loudly and exits non-zero,
  having claimed nothing.
- **`CNF-370`** — Backup, then a startup advance, then restore with a surviving engine: the restore writes a fresh
  value; the survivor's next write is refused and it exits; every value written is distinct.

### Lean (named, not built)

- `Claim.lean` (guard model, :23): gains the generation equality, and a theorem that no claim by a superseded engine
  commits after the advance.
- `StopRecord.lean`: `Event` gains `| superseded`, which ends the record as `laterStop` does, applied through the
  same list as r65b's Form E fix 8 with `superseded` for `lockLost` (`schedule`, `schedule_bounded`,
  `later_stop_exits` plus a `superseded_exits` beside it, the three `selection` splits, `money_posts_at_most_once`'s
  docstring). It weakens `finished_unrecorded_exit` by one disjunct, which `ADR-0047` states.

### What G does not cover (stated plainly)

- A provider call licensed by a check that committed **before** the takeover goes out (the list in `OPS-50`).
- Two writable copies of the database (`STO-54`). G fences one database history only.
- Liveness: a `SyncRep` holder stalls the takeover until `OPS-15`'s exit.

**Q1 asks:** ACCEPT or CANNOT ACCEPT G's text. Quote every defect, with replacement text for that span. In
particular: is the value truly never reused (restore, a failed advance, a PITR restore)? Does any engine write path
escape `OPS-50`? Does any amended span contradict an unamended one?

## Q2. Form R read whole with G

R carries r65's fixes 1–7 (confirmed "all right" 4-0 in r65b). **Fixes 8 and 9 belong to Form E** (Lean `selection`
splits and a docstring; the ADR stating `finished_unrecorded_exit`'s weakening) **and do not apply to R.** G's Lean
arm reuses them as a template (Q1). Two edits since r65b: the new ADR is `ADR-0047` (PR #24 took `ADR-0046`), and
R's `OPS-21` anchor is now 03:1773. R's text, as r65b read it:

- `OPS-47` keeps master's "hold it for its lifetime" (fix 7). Replace "where the connection
  carrying it is lost it MUST exit." with: "where the connection carrying it is lost, the engine MUST claim nothing
  more and begin no periodic pass, treat the loss as a stop of every worker not already recording one, record each
  under `OPS-21` within its Stop-record bound and exits, and then exit non-zero. The loss is not a later stop: a
  record already pending when the loss is seen continues under its own Stop-record bound and exits."

- `OPS-21`, after "…`OPS-15` classifies the row as interrupted”." (03:1773, fix 3): "A loss of the connection carrying `OPS-47`'s startup lock is not a later
  stop: `OPS-47` says “treat the loss as a stop of every worker not already recording one”. For a worker still in
  `execute`, this requirement's cancellation rules apply, including the stop that “MUST NOT cancel `execute`” and the parent's
  defer, which “records no error”; for one whose `execute` has returned, its settle write records it; it ends no
  record already pending. A stop that arrives after the loss and before that record lands is a later stop."
- `OPS-49`, its retry-loop bullet gains: "`OPS-47` says of a lost lock connection “The loss is not a later stop”: a
  worker repeating a record when the loss is seen keeps repeating it."
- `ADR-0019`'s restatement takes `OPS-47`'s new words with a dated note. A new ADR (next free id at landing:
  `ADR-0047`, one ADR with G) records the decision.
- `StopRecord.lean`: no new constructor. `Event`'s doc comment gains: "A lost lock connection is the originating
  stop or no event: `OPS-21` says it “is not a later stop”."
- **Stated by the text (r65b's Q1b):** with no stop pending, the loss is a stop the engine survives for each worker in
  `execute`. A non-parent worker is cancelled and records a cut-off `conflict` under its row (`OPS-11`), except a
  create past its confirming read and a delete past its accepted dated cancellation, which the stop "MUST NOT
  cancel" and which settle as `CNF-362`'s read cases do. A cancelled `suspend_tenant` parent records the defer, with
  no error.
- New `CNF-366`: "**A lost startup-lock connection is a stop of every worker, not a later stop.** `OPS-47` says
  “The loss is not a later stop”. Terminate the lock connection's backend: (i) with no stop pending, while a
  non-parent worker is in `execute`, outside `CNF-362`'s absorbed-read cases; (ii) with no stop pending, while a
  create's after-return settle write repeats under `OPS-49`; (iii) while an earlier stop's cut-off record repeats
  under `OPS-49`. For cases (i)–(iii) and (vi), arrange that the record can land before either the
  Stop-record bound or the Store-retry bound expires, with no later stop. Where a write repeats, the store refuses
  its transactions until lock-loss detection and then accepts writes with sufficient time remaining under both
  bounds. Assert: no claim and no periodic pass begins after the loss; case (i) records a cut-off
  `conflict` classified against its row (`OPS-11`); the settle write and the earlier record land, the create
  `succeeded` with its money posted once; the engine exits non-zero only after the records land. (iv) Deliver a stop
  after the loss, before a record lands: assert `CNF-362`'s later-stop assertions, including “Accept either
  outcome”. (v) With every transaction refused after the loss, assert exit within the Stop-record bound measured
  from the stop being recorded (the loss as the engine sees it, or the earlier stop), the loud log, and `OPS-15` at restart, including its
  exceptions. (vi) Repeat `CNF-362`'s cases for a create past its confirming read, a delete past its accepted dated
  cancellation, and a `suspend_tenant` parent at successive fan-out positions and waiting on its children, with the loss as the stop and no stop pending, asserting
  their `CNF-362` outcomes: no `needs_reconciliation` and no `cut_off` for the reads, the defer with no error for
  the parent, and exit only after the settle write or defer lands."

**Dropped since r65 (fix 7):** the edit "hold it until it begins to exit" (`OPS-47`) and "holds until it begins to
exit" (`STO-51`). Master's "for its lifetime" stands in both. Reasons: r63's rule 5 prefers deletion over
rewording; "begins to exit" could release the lock at an ordinary deploy stop while records are pending, letting a
successor sweep them; and R's loss clause already covers the case where the lock is lost.


**R's `CNF-366`, one fix since r65b (it changes only what the test checks).** A reader showed r64b's finding, 4-0,
that the old engine claims during the window before it detects the loss, so a conforming engine can fail "no claim
and no periodic pass begins after the loss". The fix leaves the engine's required behaviour alone. In `CNF-366`,
"Assert: no claim and no periodic pass begins after the loss;" becomes "Assert: no claim and no periodic pass begins
after the engine detects the loss, as its loud log timestamps the detection;".

**R's interplay with G (added to R's `OPS-21` sentence).** After R's "A stop that arrives after the loss and before
that record lands is a later stop." add: "A record that `OPS-50`'s generation check refuses ends there, unlanded:
the engine exits (`OPS-50`)." With no takeover (r65b's S1–S4) R's records land; after a takeover each is refused.

**Open point (answer it; nothing is pre-merged).** R's `OPS-47` clause reads "where the connection carrying it is
lost, the engine MUST claim nothing more and begin no periodic pass". Does it have the same problem as `CNF-366`'s
assertion: a MUST that a conforming engine breaks during the window before it detects the loss? If yes, give the
replacement text (for example "is lost, from the moment the engine detects the loss, it MUST…") and say whether G
changes the answer (under G, a claim in that window after a takeover is refused anyway).

**Q2 asks:** ACCEPT or CANNOT ACCEPT R as amended. Is the `CNF-366` fix right? The open point above. **Does R
contradict G, or anything around it?** A yes needs quotes from both sides.

## Out of scope (recorded, not voted)

- `PRV-29` names no automatic resolver for a non-create `needs_reconciliation`; it will be filed as a bead.
- The `OPS-22` worker-vs-engine exit on a zero-row record is already filed as `pv-1ylh`.

## Answer

**Total: at most 1,200 words, not counting replacement text.**

**Q1.** **ACCEPT or CANNOT ACCEPT G's text.** Every defect quoted, with replacement text for that span only and the
gate it meets (CNF id or Lean theorem, a MUST/SHOULD with a trace, or a stale write admitted / a write wrongly
refused). Then: the id list (each missing or wrong id, with a quote); the four `CNF` items (each one a conforming
engine can fail?); the Lean names.

**Q2.** **ACCEPT or CANNOT ACCEPT R as amended.** The `CNF-366` fix: right, or replacement text. The open point:
yes or no, with text if yes. Contradictions with G or the text around it: none, or each with quotes from both sides.

**Brief errors:** each wrong fact, with the grep or quote that shows it. Check the quoted "before" spans, the lock
order argument and the restore argument especially.
