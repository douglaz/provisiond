# r65 tally (panel D, pv-buc only), master b90783d, 2026-10-23

Rules: r65/notes.md (r63 rules 1-7; rule 3 = the gate; fences are evidence, not votes). All four exited 0.
astra (~4 min) engaged every question: both votes, the merge with replacement text, both fences, S3, S4, brief errors.
Spec checks were made read-only against a `git archive b90783d` snapshot. PostgreSQL quotes are the readers' own
(from postgresql.org) and the manager did not re-check them; they bear only on the fences.

## OUTCOME: (c) owner question

- Both forms are acceptable.
  - E: 4 ACCEPT.
  - R: 3 ACCEPT and 1 blocking CANNOT ACCEPT (astra). astra's objection is verified. It sits only in R's new test
    item, and its repair changes no engine behaviour.
- R is picked 4-0, and no verified brief error voids the tally (below).
- The label is owner (r64, 4-0), and the R/E choice is a values call. Per the assistant's rule, this goes to the owner
  now rather than to another round.
- Per r63 rule 2, the merged R (or E) text with the fixes below still gets a confirmation read
  (ACCEPT / CANNOT ACCEPT) before it becomes the Run's work order. The owner question quotes only behaviour the panel
  read.

## Votes

| reader | R (merged) | E (completed) | pick | merge | Fence G | Fence A |
|---|---|---|---|---|---|---|
| fable | ACCEPT | ACCEPT | R | right, but "below" is wrong | YES | NO |
| opus | ACCEPT | ACCEPT | R | wrong in 3 spans, none blocking | YES | YES |
| astra | CANNOT ACCEPT (blocking, verified) | ACCEPT | R, with its fixture repair | wrong only in the CNF-366 fixture | YES | YES |
| sol | ACCEPT | ACCEPT | R | right | YES | YES |

Totals:
- R: 3 ACCEPT, 1 CANNOT ACCEPT.
- E: 4 ACCEPT.
- Pick: R 4-0.
- Fence G: 4 YES.
- Fence A: 3 YES, 1 NO.

Strongest reason given for each pick:
- **fable:** S5. Under E, rows E1 claimed after E2's pass are "`running` under a live E2 that never sweeps them".
  R records them.
- **opus:** S4, which needs no misconfiguration. Under E, an install that never touched the disk ends
  `needs_reconciliation` delivered with `retryable: false`; under R it ends `failed`. That is `ADR-0044`'s rejected C:
  "discards worker knowledge and substitutes crash recovery".
- **astra:** R "preserves outcomes already established by the worker without claiming that the startup lock fences
  writes."
- **sol:** R "preserves outcomes already in hand and lets E1 finish rows claimed after E2's startup pass".

**astra's blocker (verified).** R's `CNF-366` says the store "accepts writes again within the Stop-record bound" and
asserts "the engine exits non-zero only after the records land".
- The trace: Store-retry bound 5, Stop-record bound 60, store refusing until t=6. A conforming engine exits at t=5:
  `OPS-21` says "whichever ends first ends the record" (03:1779-1781), and `CNF-362` says "the engine exits when the
  first bound ends" (10:1634-1636). That is a MUST, with a trace, inside the form's own CNF, so it passes the gate.
- The repair touches one span, and no other reader repaired it, so the notes' "repairs differ" clause does not fire.
  Repair text: "For cases (i)–(iii) and (vi), arrange that the record can land before either the Stop-record bound or
  the Store-retry bound expires, with no later stop. Where a write repeats, the store refuses its transactions until
  lock-loss detection and then accepts writes with sufficient time remaining under both bounds."

**Against the pick (written on request; these are not votes).**
- fable: E "keeps OPS-47's lock a one-question boot check and never lets a lockless engine write for a whole
  Stop-record bound beside a successor"; R's gains are "detours (S1, S2) or rare (S3, S4)".
- opus: R "lets an engine that has lost its only evidence that it is alone keep writing for a whole Stop-record
  bound"; S4's window is narrow.
- astra: R "prolongs the interval in which a misconfigured successor overlaps the old engine"; E's shutdown is
  simpler.
- sol: the same overlap point; "Where the worker already knows only uncertainty, recording buys less."

## S3 (a delete already accepted with a date, then parked under E)

What each reader concluded:
- **fable:** "a conforming driver resolves it with no person". Not supported: the writer it cites, `WIR-35`, is
  "**operator-only**" (13:905). Its Robot point concerns `cancellation_date=now` (immediate), not a dated cancellation.
- **opus:** a gap. No text names an automatic writer of the dated outcome; under E it is "a detour or a person
  depending on a resolver the spec never specifies".
- **astra:** evidence permits automation, but the text "guarantees neither automation nor an operator".
- **sol:** recovery "can avoid a person when fresh authoritative evidence recovers the schedule and date"; no special
  rule is needed.

**Verified: opus is right.** 03:95-96 says "Resolution transitions out of `needs_reconciliation` are made by no worker
— by `OPS-27`'s sweep or `OPS-31`/`WIR-35`'s operator verb".
- `OPS-27`'s sweep searches by a create's correlator (03:505-508).
- `PRV-29` (02:423) requires evidence-based resolution for non-creates but names no writer other than the operator.

So under E, S3 ends with an operator, unless the spec gains a resolver it doesn't have today. Under R, it is
`succeeded`, `cancellation_scheduled`, with no person. This favours R. It is not a brief error: the brief flagged S3
as unverified.

## Reported brief errors (each verified at b90783d)

None of these voids the tally (rule 6 as pre-registered in notes.md).

1. **Correction 4 is contested: verified as a brief error, but it does not void.**
   - The brief: "`OPS-22`'s zero-row exit is the worker's, not the whole engine's."
   - For the worker reading: `OPS-22` (03:1825-1828) "the worker MUST … exit"; `STO-3` (05:33-35); 03:1731 "the
     worker stops there".
   - For the engine reading: `ADR-0022`:41 "B's settle then affects zero rows and **the engine exits under
     `OPS-22`**", and `CNF-290` (10:1505) "the old process's late settled-state write affects **no row** and exits
     it".
   - Effect on S5 under R: under the engine reading, E1's first record of a row E2 already swept affects no row and
     exits E1. Post-pass rows still unrecorded at that point stay `running`, as under E.
   - Why it doesn't void: under either reading, R strands no more rows than E, so S5's direction holds. Only S5's
     size is overstated. It is fable's strongest reason and part of sol's. opus's S4 and astra's reason don't rest on
     it.
   - It goes into the owner question's misconfiguration line as a caveat. **Separate item for the assistant:** the
     worker-versus-engine meaning of `OPS-22`'s exit is inconsistent at master. That is behaviour, so it is worth its
     own bead; this manager touched no beads.
2. **"'Below' is right" is wrong** (fable, opus). The classification paragraph (03:1749-1761) and the in-`execute`
   transaction rule (03:1743-1747) sit above the insertion point (03:1766). This is a wording defect in R's
   `OPS-21` sentence and is fixed below.
3. **"confirmed-read" appears nowhere** (opus). A grep of the tree outside docs/research is empty. `CNF-362` uses
   "absorbed-read" (10:1611).
4. **The insertion point** (opus) separates "The sent transaction's fate is the server's" (03:1767) from the
   later-stop sentence it refers back to (03:1766).
5. **`CNF-366`(vi) drives only a waiting parent** (opus). The parent cancelled mid-fan-out, which Q1b states, is
   asserted by nothing. `CNF-362` drives it "at successive fan-out positions" (10:1624).
6. **The intro's "a kill or a failover records nothing under both"** (astra, sol) repeats correction 5's error.
   `CNF-362` says "Accept either outcome" (10:1645). It is the same under both forms.
7. **S1's E row "stays `running`"** (astra, sol) is not guaranteed. A repeating write may already have committed:
   "the row is already written, the money already posted once" (03:1842). R and E then agree; S1 separates them only
   when that write had not committed.
8. **S1/S2's "a detour, not a person"** (astra, sol) is too strong. `OPS-27`'s table, 03:516: "the listing window has
   expired … **Unresolved.** Escalate to an operator". This makes E worse.
9. **S5's "each holds its machine"** (astra, sol) is too broad. The index is `WHERE status = 'running' AND
   yielded_at IS NULL` (05:94). The stranded `running` rows remain.
10. **"A cut-off during a provider call ends `needs_reconciliation` under both"** (sol) is too broad. A create before
    step 9 settles `failed` (03:232; `OPS-15` 03:394). It is the same under both forms.
11. **Fence A's "only records it refuses … end better"** (astra, sol) is overstated. Fence A also refuses records
    whose outcome equals the sweep's, for example refresh, "Always `failed`" (03:228). This is fence evidence only.
12. **E's Lean list is incomplete** (fable, opus).
    - `finished_unrecorded_exit`'s `selection` lemma has three `rcases h with ack | bound | store | later |
      redelivery` splits (StopRecord.lean:435, 453, 468) with 5-disjunct `Or.inr` chains. A sixth disjunct needs
      them changed.
    - The `money_posts_at_most_once` docstring says "both stop events" (282).
    - E weakens `finished_unrecorded_exit` by one disjunct, but `ADR-0044`:95 says "No existing theorem is weakened",
      so `ADR-0046` must say so (fable).
- **Not a brief error:** fable's "no r64/r64b record at b90783d" concerns provenance, not a spec claim. Panel records
  live under /var/tmp until landing.

## Fixes to carry. Each changes no behaviour; all get the r63 rule-2 confirmation read

R:
1. **`CNF-366`'s fixture sentence:** astra's replacement (above). It only constrains the test; engine behaviour is
   unchanged.
2. **`OPS-21`:** "the cancellation rules below apply" → "this requirement's cancellation rules apply". fable and opus
   gave identical text. It is a pointer fix; Q1b and `CNF-366` already state the cut-off classification.
3. **`OPS-21` placement:** put R's sentence after "…classifies the row as interrupted”." (03:1770), not between
   03:1766 and 03:1767 (opus). Same text, so no behaviour change.
4. **`CNF-366`(i):** "outside `OPS-21`'s confirmed-read cases" → "outside `CNF-362`'s absorbed-read cases" (opus).
   This only names the existing label.
5. **`CNF-366`(vi):** "a waiting `suspend_tenant` parent" → "a `suspend_tenant` parent at successive fan-out positions
   and waiting on its children" (opus). It tests `OPS-21`'s existing "at any point in its fan-out".
6. **`CNF-366`(v):** "(the loss, or the earlier stop)" → "(the loss as the engine sees it, or the earlier stop)"
   (opus). This is test measurement; an engine can only measure from detection.
7. **Drop the merged "hold it until it begins to exit" edit.** `OPS-47` keeps master's "hold it for its lifetime" and
   `STO-51` keeps "holds for its lifetime".
   - That is no change against b90783d.
   - It removes opus's hazard: "begins to exit" could release the lock at an ordinary deploy stop while records are
     pending, letting a successor sweep them.
   - fable's and opus's rewordings differ. Choosing one would be the manager's own synthesis, and r63 rule 5 favours
     deletion over rewording.
   - opus's "until it exits or the connection carrying it is lost" is the candidate if the confirmation read wants the
     words.

E:

8. **Lean:** the three `selection` splits and the docstring (error 12). The manager builds this after the choice.
9. **`ADR-0046`:** state that E weakens `finished_unrecorded_exit` by one disjunct.

## Fences (evidence for the owner, not votes on R/E)

**Fence G: sound, 4 YES.**
- What it reaches (all four agree): every claim and write after the takeover's advance commits, including claims E1
  makes before it detects the loss (astra, sol, opus).
- What it doesn't reach: a provider request already sent, or anything before the pass.
- opus: it also reaches dispatches preceded by a write, so S5's stranded rows are gone under either form.
- Where it sits: it is `ADR-0019`'s rejected "Fix the predicate", which `ADR-0019` calls "Correct, and cheap" and
  rejects on scope, not soundness (0019:78-81). It has a working second writer (03:172, "The value has a second writer
  that is …").
- Cost:
  - a share lock on one hot row in every engine transaction;
  - a takeover that waits for E1's open transactions;
  - stale outcomes discarded after a takeover.
- What it amends: `OPS-47` "**The lock is not a fence**", `STO-51` "guards no write", `STO-3`'s write contracts,
  `OPS-21`/`OPS-22` (stale-owner exits), and `ADR-0019`'s scope.

**Fence A: 3 YES (opus, astra, sol), 1 NO (fable).**
- fable's trace (reported, not applied): every record Fence A refuses is already guarded by `OPS-22`'s claim number.
  So it blocks only correct records: S5's, which E2 then strands. And after a blip, E1's own unreaped session refuses
  it, which turns R into E in S1. `ADR-0019`:69: "advisory lock survives its holder when the holder dies without
  closing the connection".
- Cost (all four): a second checkpoint against "once, at boot", and no protection for pre-detection claims or sent
  transactions.

## Owner question (TL;DR, ready to relay)

**The problem in plain terms.**
- At 10:00:00 the engine has just bought a server for a customer and is saving "bought, charged once".
- At 10:00:01 the database restarts for maintenance, which drops the engine's "I'm the only engine" lock.
- **Record first:** the engine takes no new jobs, waits for the database (up to its record limit, say 60 s), saves
  "bought, charged once", then exits.
- **Exit now:** the engine exits at 10:00:01. At the next start, the purchase shows "needs checking" and is re-checked
  with the provider. That is usually automatic. It needs a person if the provider's listing window has passed, and
  always for a server deletion already scheduled with an end date.

**Options (panel pick first).**
1. **Record first (R).** Picked 4-0. R is accepted 3-1. The one objection is a test-only defect, fixed without
   behaviour change.
2. **Exit now (E).** Accepted 4-0, picked 0.

**On a misconfiguration (a second engine started by mistake).**
- **Before the first engine notices the drop:** neither option stops the first engine taking jobs and calling
  providers. That window is set by the connection keepalive.
- **After it notices, under E:** the first engine exits at once. Jobs it took after the second engine's start-up
  sweep stay "in progress" and block their servers until the second engine is restarted.
- **After it notices, under R:** the first engine takes no new jobs, saves those jobs within the record limit, and
  exits. For up to that limit, the second engine wrongly believes it is alone.
- **Caveat:** the spec is inconsistent on whether a save that finds its job already taken over exits the whole
  engine. If it does, R can exit early and leave some of those jobs stuck as under E, but never more than E.

**Fences: a separate yes/no each. Both amend `OPS-47`'s "The lock is not a fence" and reopen `ADR-0019`.**
- **Fence G (generation row): sound, 4-0.** This is the one fence enforced in the app.
  - What it does: once the second engine takes over, the database refuses every later job claim or save by the first
    engine. No jobs get stranded, under either option.
  - What it doesn't do: recall a provider request already sent.
  - Cost: one extra row lock in every engine transaction, a takeover that waits on the old engine's open
    transactions, and outcomes from the old engine discarded.
  - What it amends: `OPS-47`, `STO-51`, `STO-3`, `OPS-21`/`OPS-22`, and `ADR-0019`'s scope. `ADR-0019` considered
    this option and called it "Correct, and cheap", then rejected it as out of scope.
- **Fence A (re-take the lock before saving; R only): 3-1 sound** (fable says no).
  - What it costs: after a network blip, the engine's own dead session refuses it. In the misconfiguration case, the
    second engine holds the lock. So R falls back to E exactly where R helps.
  - What it protects: nothing before the first engine notices the drop.
  - What it amends: `OPS-47`'s "once, at boot" and `ADR-0019`.

**IDs.** pv-buc; `OPS-47`, `OPS-21`, `OPS-49`, `STO-51`, `ADR-0019`, `ADR-0044` decision 1; new `ADR-0046` and
`CNF-366`. Label owner (r64, 4-0).

**Next.**
1. The owner picks R or E, then gives yes/no on G and on A.
2. A confirmation read of the chosen form with the listed fixes (r63 rule 2), plus each fence that got a yes.
3. Then the pv-buc Run.
