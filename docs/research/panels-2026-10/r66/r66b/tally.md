# r66b tally (panel D: pv-buc, merged Fence G + Form R; Q3 `STO-13` rollback), 2026-10-24

Base `d78085a`. All four readers exited 0 with full answers. The rules are r66b/notes.md's, fixed before launch.
Reader labels are fable, opus, astra and sol. Every claim that moves a tally was checked with `git show d78085a:<file>`.
Line numbers are `d78085a` line numbers.

## Summary

| Q | Tally | Outcome |
|---|---|---|
| Q1 merged G | ACCEPT 1 (fable), CANNOT ACCEPT 3 (opus, astra, sol) | **(c)**: the restore-window point goes to the owner (rule 5). After that, a confirmation round (r66c) reads B1, the restore text the owner picks, and `CNF-370`. |
| Q2 R with G | ACCEPT 4-0 | **(a)** |
| Q3 `STO-13` rollback | (A) 3 (fable, opus*, astra), (B) 1 (sol) | **(c)**: sol's dissent is about cost, so it cannot be verified false. *opus's (A) adds a sentence of its own. |

No question is void. The combined Run is **NOT ready**.

## Q1. Merged G: 1-3

### Blocking defects (verified)

**D-restore. The restore window precedes the fence.**
- Raised by astra and sol as blockers, and by opus as `CNF-370` trace (a). opus's non-blocking "Restore window" note is the same point.
- Span 19 writes the fresh value "in the transaction that commits `STO-56`'s record". The only ordering of that record is
  `STO-56`'s "before either component is **started**" (05:1338; 05:1556).
- The rule "Before any component connects to the promoted store, the deployment MUST stop every engine and `api` process
  that was connected to the old primary" (05:1507-1508) sits inside the promotion-as-restart bullet. A backup restore has
  no rule that orders a **surviving** process's access before the record commits.
- **Trace (sol):**
  1. E holds g. The backup holds g and a `running` row under E's claim number.
  2. The restored store becomes reachable.
  3. E reconnects, reads g `FOR SHARE`, and commits its pending settlement.
  4. The record commits h only afterwards.
- The engine obeyed `OPS-50`, yet `CNF-370`'s "the survivor's next write is refused" fails. The gate is met: `CNF-370`
  is a CNF verdict that a conforming engine fails.
- **Three different repairs:**
  - astra: "The restored store MUST remain inaccessible to every engine process, including a surviving process, until that
    transaction's commit is acknowledged. Only then may a survivor reach `OPS-50`'s generation check."
  - sol: "Until that transaction has been acknowledged, the deployment MUST prevent either component, including a process
    that survived the restore, from using the restored store."
  - opus: "No component connects to the restored store before that transaction commits.", plus a `CNF-370` rewrite with a
    proxy fixture (below).
- They differ on scope (engine only, or both components) and on the instant (commits, or acknowledged). All three are
  "the deployment MUST …".
- **Rule 5.** This clause (span 19 and `CNF-370`) was amended in r66 (B3, B5) and again in r66b, without converging.
  Deleting it reopens the hole `STO-59` itself names: "an engine that survived the restore still holds the restored value
  and would match". Deletion is therefore barred, and the point is **(c)**. The owner question is below.

**D-B1 (opus): `OPS-21`'s closed exit lists lack the superseded exit.**
- `OPS-21` says "MUST be recorded before the engine exits … subject to the bounded abandonment and later-stop exits
  below" (03:1741-1742).
- The after-return list is "the Store-retry bound's exhaustion exit, the lost-reply case" (03:1807).
- `OPS-50` says "exit non-zero at once".
- Trace: `CNF-367`'s cut-off-record run exits unrecorded under neither listed exit, so the MUST breaks.
- The Lean side (`finished_unrecorded_exit`, `@[req "OPS-21"]`, StopRecord.lean:394-395) gains the disjunct; the Markdown
  does not. Verified. opus's line hints of 1739 and 1798 are off; the text is right.
- opus's repair:
  - "subject to the bounded abandonment, later-stop and superseded (`OPS-50`) exits below."
  - "the Store-retry bound's exhaustion exit, the superseded exit (`OPS-50`), the lost-reply case".
- One reader, and no reader contests it, so it goes to the **confirmation read** (notes Q1 rule).
- It changes the exit set of a MUST, so it is behaviour, not wording.

**D-B2 (opus): `CNF-370` fails or is unreachable for a conforming engine.**
- (a) is D-restore.
- (b) An in-place restore kills the lock connection. Under R ("treat the loss as a stop of every worker not already
  recording one … then exit non-zero"), a survivor with no worker in flight exits without writing. "Its next write is
  refused" is then unreachable. Verified from R's text.
- (c) "every value ever written to the row is distinct" fails if putting the backup's g back counts as writing it.
  `STO-59`'s own "MUST NOT be written to the row twice, including across a restore" has the same ambiguity.
- opus's replacement: "Start an engine and hold one of its workers in `execute`; back up. Through a proxy the harness
  controls, refuse the engine's store connections from then until the restore has committed `STO-56`'s record. Make the
  Stop-record and Store-retry bounds longer than that interval, and start no other engine. Then admit its connections.
  Assert the restore record's transaction wrote a fresh value before either component started (`STO-56`), that the
  survivor's next write (its settle or cut-off record) commits nothing and the engine exits non-zero, and that every
  value written by an advance or by a restore record's transaction is distinct."
- astra keeps `CNF-370` and adds the access boundary instead. **This depends on the owner's restore answer**, so it goes
  to r66c with it.

### Verdicts on the brief's **[took]** choices

| Choice | fable | opus | astra | sol |
|---|---|---|---|---|
| B1 `OPS-50` prefix | holds | holds; `OPS-15`'s "This transaction alone is exempt…" restates it, use "(`OPS-50`'s exception)" (wording) | holds | holds |
| B7 lost-reply sentence (rule-5 watch) | holds | not contested | quoted approvingly | quoted approvingly |
| B10 deletion | holds (`CNF-303` verified) | — | — | — |
| `OPS-15` anchor (manager's) | holds (coincides with "first transaction of the pass") | holds | holds | holds |
| B9 both timeouts | holds; redundant, since `statement_timeout` alone suffices | same, and calls the brief's rationale a misreading | holds | holds |
| Span 15, 18, 22 | hold | hold | hold | hold |
| Span 16 | holds | holds | **contests** (brief error, below) | — |
| B3/B5 restore anchor + `CNF-370` | holds | `CNF-370` fails (D-B2) | **contests**: anchor right, ordering insufficient | **contests**: same |
| `CNF-367`/`368`/`369` | hold | hold; non-blocking adds below | hold | hold |

**Rule-5 watch, G's lost-reply sentence: CONVERGED.** No reader amends it. It stays.

### Non-blocking (recorded, NOT merged)

- **fable**
  1. `OPS-49`'s `lock_timeout` bullet (03:1863) should name `OPS-50`'s generation read as a third site.
  2. `OPS-50`'s read-licensed dispatch: "and that transaction MUST end before the dispatch."
  3. `STO-59`: replace the value "in place, by an `UPDATE` of that one row" (a `DELETE`+`INSERT` hands a blocked
     `FOR SHARE` no row).
  4. Replace "`OPS-32`'s cleanup" with "the key deletion `PRV-9` gives `OPS-32`'s sweep" (wording). fable's "grep cleanup
     returns nothing" is literally false (11 hits in 03, none naming `OPS-32`'s act); this moves no tally.
- **opus**
  - `CNF-367` should also assert "dispatches no provider call it licensed".
  - `CNF-369` should also check that startup refuses a missing, zero, negative or non-finite Startup-lock wait bound.
  - The liveness note should say `statement_timeout` does not bound the commit's `SyncRep` wait.
  - `STO-54` step (1) ("*Before the startup lock*", which includes "`provider_account_status` is re-established", verified)
    names no writer. Pin it to the operator, or exempt it.
  - `Restore.lean`'s `Permissions` docstring.
- **opus, Lean, verified.** ADR-0025:117-118 says "Every guard that a dated amendment added is a parameter of the model
  that carries it, and the module holds two theorems: the bad trace is refused with the guard and admitted without it."
  The brief's "No field is added" leaves the "admitted without it" witness nothing to switch off. opus proposes a
  `generationCheck : Bool` parameter and a `superseded_commits_without_check` witness. This is not wording; carry it.
- **astra, sol.** `gen_random_uuid()` is "a version 4 (random) UUID", so the Lean freshness must be an explicit assumption.
  `superseded_never_commits` needs freshness and transaction-order assumptions and must keep `lost_claim_reply_exits`.
- **sol.** The `CONTEXT.md`:520-527 entry is rationale, not a pointer; keep it in `ADR-0047`.

### Missing ids, verified (quotation updates, so they join the list without a vote)

`git grep 'specification enforces' d78085a` outside the research archive finds only OPS-47 itself (03:138) and these two:
- `README.md`:304-305 quotes `OPS-47`'s "a deployment obligation and not a property this specification enforces", which
  span 1 deletes. opus's text: "That the process is one is, in `OPS-47`'s words, "a deployment obligation" (`ADR-0019`);
  `OPS-50` refuses a superseded engine's writes (`ADR-0047`)."
- `ADR-0025`:65-66 quotes the same words and needs a dated note.

## Q2. R merged with G: 4-0 ACCEPT, outcome (a)

- **fable:** ACCEPT. R's quotes check (03:1792, 03:1783, 03:144). It records one gap, which it does not count: a periodic
  component mid-transaction at the loss is neither stopped nor waited for. Its writes are guarded, so nothing unsafe
  follows.
- **opus:** ACCEPT. No contradiction: R's `OPS-21` quotes `OPS-50`, and `CNF-366` holds the generation fixed. One
  **wording-only** fix: "record each under `OPS-21` within its Stop-record bound and exits, and then exit non-zero" becomes
  "…within its Stop-record bound, subject to its exits, and then exit non-zero." Once B1 lands, R's quotation and G's exit
  list say the same thing.
- **astra:** ACCEPT. Lock loss preserves a pending record; a generation mismatch ends it.
- **sol:** ACCEPT. The same reading.
- **Rule-5 watch, R's `OPS-47` loss clause: CONVERGED** (4 ACCEPT; the only note is wording). Nothing goes to the owner.
- Q2 is final, but it rides in the combined Run, which waits on Q1 and Q3.

## Q3. `STO-13` rollback: (A) 3, (B) 1, outcome (c)

- **fable (A).**
  - `STO-13` (05:1425-1426): "A removal, rename, tightening or `VALIDATE` is a **contract step** and ships no earlier than
    the release after the one that stopped depending on the thing removed". (B)'s "prevent such an engine from
    reconnecting" therefore has no lawful mechanism in that release.
  - (A)'s cost is master's state for the rollback's duration; span 22's MUST covers the roll forward.
- **opus (A), plus one sentence.**
  - (B) contradicts `STO-13`'s definition, since G removes nothing.
  - "recovery past it is `STO-54`'s restore" is false while a forward fix stays admissible.
  - (B) prices a bad G release at a restore, whose step (3) bumps "every tenant's credential generation" (verified).
  - opus adds: "The rollback MUST write a fresh `STO-59` value before the previous-release engine starts, so that any
    engine of the rolled-back release still running is refused." This closes sol's trace. **It is one reader's unreviewed
    text.**
- **astra (A).** (B) turns recovery from a bad first G release into a restore incident. `OPS-47`'s one-process obligation
  stays.
- **sol (B).**
  - Trace: the newer E loses its lock unnoticed and keeps g. The rollback's unchecked engine runs beside it, and both write.
  - sol accepts the restore cost. It concedes that blocking the old engine "must be enforced by deployment or connection
    admission". "MUST serve a newer one" (05:1429) is verified.
  - sol's trace is true under plain (A); the brief states it as (A)'s cost. The dissent is a choice of cost, so it cannot
    be verified false, and a 3-1 split is **not consensus**.
- **Verified flaw in (B)'s own text.** "it is a contract step" contradicts 05:1425's definition. This is a flaw in an
  option, not in Q3's premise, so Q3 is **not void**. If the owner picks (B), its text needs a redraft (amend `STO-13`'s
  definition) and a reading round.

## Brief errors (verified; none voids a question)

1. **Span 13 / `ADR-0047`.**
   - The `ADR-0019` option ends at :81 ("…a guard term alive to do it."); "Correct, and cheap." is mid-line :80. Anchor
     the note after :81 (fable).
   - Manager's own finding: "rejected only on scope" is also inexact. :80-81 say "Rejected because it buys a defence for
     the case this ADR puts out of scope, **and keeps a column, a counter and a guard term alive to do it**". That is scope
     plus cost, and `ADR-0047` should say both.
2. **Span 16** contradicts span 12. Span 12 has `CNF-290`'s late write commit nothing via "`OPS-50` once the generation
   has moved"; span 16 says the drill "does not exercise" the fence (astra). Replacement, wording-only: "For the dedicated
   generation-fence drills, see `CNF-367`–`CNF-370` (`OPS-50`).*"
3. **`OPS-50`'s "two writable copies of the database, which `STO-54` excludes"** rests on 05:1508, which applies to
   promotion only (astra). Replacement, wording-only: "Nor does it fence two writable copies of the database; its
   guarantee covers one writable database history."
4. **"Is an id still missing?"** Yes: README:304-305 and ADR-0025:65-66 (above).
5. **Not checkable in the repo; moves no tally.** opus says the 13.3.2 quote is truncated ("…or during savepoint
   rollback"). fable and opus say the B9 rationale overstates, because `statement_timeout` alone bounds the wait.

## Carry-forward for r66c and the Run (NOT a Run instruction; Q1 is not (a))

- **Behaviour; r66c reads it:**
  - B1's two `OPS-21` list edits.
  - The restore text the owner picks.
  - `CNF-370` (opus's fixture, adjusted to that pick).
  - The ADR-0025:118 Lean parameter and its witness pair.
- **Wording-only fixes, listed and not voted:**
  - span 13's anchor moved to `ADR-0019`:81;
  - `ADR-0047`'s "scope and cost";
  - span 16's replacement;
  - `OPS-50`'s two-copies sentence;
  - opus's "subject to its exits" in R's `OPS-47`;
  - opus's "(`OPS-50`'s exception)";
  - fable's `OPS-32` term.
- **Quotation updates:** `README.md`:304-305 and `ADR-0025`:65-66.
- **Recorded, open for r66c to adopt or not:**
  - opus's `STO-54` step (1) writer note;
  - fable's 1-3 and opus's `CNF-367`/`369` adds.
- **Next free ids are unchanged** (all four readers confirmed the maxima `OPS-49`, `STO-58`, `CNF-365`, `ADR-0046`):
  `ADR-0047`, `OPS-50`, `STO-59`, `CNF-366`; G's items are `CNF-367`..`CNF-370`.
- **Still pending:** the `PRV-29` bead, to be filed in the pv-buc branch by the Run-prep manager.

## Owner question 1 (Q1, restore window). TL;DR

**Story.**
- The engine is running, and the store is restored from last night's backup. That backup holds the engine's own
  generation value.
- If the engine reconnects to the restored store before the restore's record (with its fresh value) commits, its check
  passes.
- Example: it commits a create's "succeeded" settle into a store the restore rewound, skipping `STO-54`'s quarantine.
- All three fixes readers wrote are an ordering the deployment must keep: nobody touches the restored store until that
  commit.

**Options.**
1. **The deployment barrier (panel pick).** Three of four readers raised it (astra, sol, opus); fable missed it. The texts
   differ, and r66c would read one merged text.
2. **Delete the restore clause.** This is rule 5's default: restore survivors are listed under "not covered". It leaves the
   hole above with no barrier at all, as master is today. No reader proposed it.
3. **An app-enforced check.** The engine itself would notice it is talking to a restored store and exit. No reader
   drafted one; it needs a drafting round and a reading round before it can be a pick.

**On a misconfiguration.**
- With option 1, if the restored store is reachable too early (DNS, proxy or pooler pointed back first), the survivor's
  writes commit on rewound state. Nothing in the app refuses them.
- With option 2, that happens on every restore that has a survivor.
- With option 3, it would fail closed if designed so; not yet shown.

**Costs.**
- Option 1: one more operator ordering step in `STO-54`, plus r66c.
- Option 2: none now, but a known hole.
- Option 3: at least two more rounds before the Run.

## Owner question 2 (Q3, rollback past the G release). TL;DR

**Story.**
- The release that adds the check goes out, and a bug forces a rollback to the old engine binary, which knows nothing of
  the check.
- Example: a new engine silently lost its lock and keeps its value. The rolled-back old engine starts beside it, and
  nothing refuses either, so both work the queue as on master today.

**Options.**
1. **(A) Rollback stays admissible (panel pick, 3-1: fable, opus, astra).** The fence is off while the rollback lasts.
   - opus's variant adds "The rollback MUST write a fresh `STO-59` value before the previous-release engine starts", which
     refuses any lingering new engine. It is one reader's text and unreviewed; r66c would read it.
2. **(B) The release is a contract step (sol).** The old binary is inadmissible, and recovery is a restore. Its text
   contradicts `STO-13`'s definition (a contract step is "A removal, rename, tightening or `VALIDATE`"), so it needs a
   redraft and a read.

**On a misconfiguration.**
- (A): an operator who rolls back while a new engine still runs gets two unfenced engines. With opus's variant, that
  happens only if the operator also skips the write.
- (B): the "prevent reconnecting" is deployment-enforced (sol concedes this). An old binary redeployed anyway runs
  unfenced and out of spec.

**Costs.**
- (A): the fence is off for the rollback's duration.
- (B): a bad first G release costs a restore incident: listener down, every tenant re-issues credentials (`STO-54` step
  (3)), plus `STO-13`'s definition amended.
