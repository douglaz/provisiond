# r64 tally (panel D: pv-buc, pv-9j6). 2026-10-23

All four exited 0. Answers: fable.md, opus.md, astra.md, sol.md. Rules: notes.md (r63 rules 1-7, rule 3 = the gate).
Every claim below that moves a tally was checked at `b90783d` (main repo, HEAD = b90783d). **No CANNOT ACCEPT on
either question names a checked verdict, so nothing blocks under the gate.** Neither question converged on an
exact form: **Q1 (b), Q2 (b).** Q3: 4-0 for separate Runs.

## Q1 (pv-buc): exit at once, or record first, when the lock connection drops?

### Votes

| Reader | Vote (as written) | Counts as (rule 1) | Behaviour picked | Label |
|---|---|---|---|---|
| fable | CANNOT ACCEPT A, pick B′ | CANNOT ACCEPT A, non-blocking (says so) | record first; a pending record continues | owner |
| opus | CANNOT ACCEPT A, pick B amended | CANNOT ACCEPT A, non-blocking (says so) | record first; a pending record continues | owner |
| astra | AMEND A, "behaviour changed" | CANNOT ACCEPT A, own form; names no verdict | exit at once, with or without a stop | owner |
| sol | AMEND A, "behaviour changed" | CANNOT ACCEPT A, own form; names no verdict | exit at once, with or without a stop | owner |

- **A as drafted: 0/4.** By behaviour the split is **2-2**:
  - **B′, record first** (fable, opus). A lost lock connection is a stop of every worker not already recording
    one. The engine claims nothing more and records each under `OPS-21`. The loss is **not** a later stop, so a
    record already pending continues under its own bound and exits. Then the engine exits. Fable's and opus's
    texts differ: opus adds "begin no periodic pass", "exit non-zero" and an `OPS-49` pointer. Neither adds a
    `StopRecord.lean` constructor.
  - **A′, exit at once** (astra, sol). The engine exits at once on a lost lock connection, whether or not a stop
    or its record is pending, without starting a record. It must not begin or repeat a record transaction. A
    sent transaction stays the server's to decide. Rows go to `OPS-15`. Both readers add `Event.lockLost`, an exit
    theorem, and the lost-lock exit in `finished_unrecorded_exit`. Their texts differ: astra edits `OPS-21`'s
    "subject to" clause, and sol lists `ADR-0044` among the files it touches.
- **The label is 4-0 owner.** Every reader calls it a product call: may losing the lock cost an outcome already
  in hand?
- **Q1b:** each reader's form says its intent outright. B′ cancels each worker in `execute`, which records a
  cut-off `conflict`. A′ exits at once, which is a crash for each worker.

### Counter-arguments, written on request (not votes)

- **fable, against B′:** A is the smaller promise. Writing on for up to the Stop-record bound widens the window
  in which a second engine's boot check gets the wrong answer. An in-place restart drops the pool too.
- **opus, against B′:** B′ adds a stop the engine sends itself, a carve-out and a `CNF` item, and it keeps a
  lockless engine writing for up to the bound. A reuses `OPS-15`'s crash path, which gives a second engine's
  startup pass no window to race the records.
- **astra, against A′:** "A destroys useful in-memory outcomes after a harmless connection failure. B could
  preserve them within the existing bound."
- **sol, against A′:** "A discards a successful provider outcome after an unrelated connection failure, despite
  no demonstrated safety benefit."
- Both A′ readers concede the cost in their own Owner lines. Astra: "immediate exit sacrifices a record that
  could still land; no independent in-scope safety property requires that sacrifice."

### What `OPS-47`'s "where the connection carrying it is lost it MUST exit" protects

- **fable:** the next boot's answer, "a free lock means no live engine", which is what "hold it for its
  lifetime" promises. Nothing checked depends on it (`CNF-290` drives only a refused lock). `STO-56`'s
  once-per-process read is protected by `STO-54`'s stop, not by this exit.
- **opus:** only "hold it for its lifetime". The lock is "released when its session ends" (`STO-51`, verified at
  05:90), so an engine that runs on lets a misconfigured second engine boot unrefused. No `CNF` checks this.
  `STO-56` doesn't depend on it, and `api` holds no lock.
- **astra:** nothing beyond the literal lifetime-lock policy. `STO-56` is no justification, and "The boot check
  cannot become a continuous guarantee."
- **sol:** "no independent, in-scope property". Neither the boot check nor `STO-56` gives a counterexample.
- **Manager's reading.** No checked verdict depends on the clause.
  - The one protection named (fable, opus) is a real window, but it is **unchecked** and limited to a
    misconfiguration.
  - `ADR-0019` puts that case out of scope: "If a deployment ever runs two engines, this system has no
    defence". `OPS-47` says "It answers one question, once, at boot".
  - C drew no picks, so nothing is deleted.
  - B′ pays the window for up to the Stop-record bound. A′ pays it only for the time detection takes. Any owner
    story must state this misconfiguration case (the owner's preference for app-enforced safety).
  - **Warning:** a second non-converging round pushes toward rule 5's deletion. That would collide with this
    named window, which makes it an owner question, not a quiet deletion.

### Verified checks and brief errors

1. **Brief error. Story (a)'s "the correlator resolves it" (opus): VERIFIED wrong for one channel.**
   02-provider-contract.md:1049: "an ambiguous create on that channel MUST resolve to an operator, never to a
   guess." That understates A/A′'s cost in the very comparison the split turns on, and astra and sol voted
   without it. **It changes the premise, so it voids Q1's tally (rule 6).** It affects A/A′, whose stated cost is
   too low.
2. **Brief error. "Startup-lock connection keepalives … exists only to detect that loss" (fable, opus, astra):
   VERIFIED wrong.** ADR-0019:69-73: a session lock "survives its holder when the holder dies without closing the
   connection … the keepalive requirement is the actual cure". The parameter survives C. **It affects only C,**
   which drew no picks, and three readers caught the error themselves. It does not void the tally on its own.
3. **Brief error. "No `CNF` item drives a lost lock connection" (opus): VERIFIED wrong in letter.** CNF-365
   (10:1100, 1104) runs "Kill the primary" and "crash the primary, restart it in place" while components run,
   which drops `OPS-47`'s connection. CNF-365 asserts nothing about a stop's record. No option flips it:
   - "every engine … has stopped before any component connects to the promoted store" holds under A′, and under
     B′ while `STO-54`'s stop counts as a later stop.
   - "no component uses a connection before a standby has flushed" binds B′'s reconnecting record writes. The
     next brief should say so.
   - Premise ("nothing governs the record") stands. It affects CNF-366's placement and B′'s reconnect.
4. **Brief error. Q1b's "Under A the engine exits at once" (astra, sol): VERIFIED.** OPS-47 (03:145-146) says
   only "it MUST exit", with no timing. A's added sentence covers only a pending record. It affects A at Q1b,
   which is why astra and sol wrote A′.
5. **Draft A's CNF bullet over-asserts (astra, sol): VERIFIED.** CNF-362 (10:1645) says "Accept either outcome:
   the transaction committed …". An exit cannot undo a sent transaction. This is a defect in A's draft, not a
   premise error.
6. **B as drafted contradicts itself (fable, opus): VERIFIED by definition.** `OPS-21`'s later stop is "one
   arriving after the stop being recorded and before that record lands", and it names no source. A loss read as
   a stop, arriving while a record is pending, is a later stop, so it "ends the record as an exit". That is A's
   behaviour, not B's. B′'s "is not a later stop" sentence is the fix. It is a defect in option B.
7. **(b) failover (brief asked to verify):**
   - Holds where a stop is delivered. `STO-54` (05:1507-1508) says "the deployment MUST stop every engine", and
     a delivered stop is a later stop.
   - Astra and sol add, correctly: `STO-54` says only that processes "has stopped" (05:1502), so a kill is
     possible. 03:1741 says "A kill or crash records nothing".
   - Under every option, (b) ends unrecorded (fable; opus adds that the lock drops with the old primary). (b)
     does not separate the options. The gap that remains is (a).
8. **Fable's "A is the exit the owner already rejected in `ADR-0044`": the quote is VERIFIED, the claim
   OVERSTATED.**
   - ADR-0044:69-70 says "**C: must not record.** Rejected: it discards worker knowledge and substitutes crash
     recovery even when the process and store can complete the record." It carries no owner-decision number,
     unlike B ("Rejected by owner decision 1").
   - A mirrors the later-stop exit the owner kept.
   - The real precedent for B′ is owner decision 1, quoted at ADR-0044:108-109: "Any stop the engine survives
     MUST record the outcome before the engine exits. This covers every operation kind". So are the rejections
     at :78-81 (X: "Exiting parks a create nobody ordered, and the outcome would turn on whether the store error
     came before the stop") and at :135-136 ("it throws away an outcome in hand").
   - These are precedent by rationale. Under A′ the engine does not "survive", so whether decision 1 reaches a
     lost lock is the owner's scope call.
   - The brief quoted none of this, and only fable cited it.
9. Also checked: `OPS-49` keeps "the provider's outcome retained in memory" (03:1837). The rule that a sent
   COMMIT is never abandoned is `STO-7`'s (05:134, 151), and it holds "short of its process exiting", so A′'s
   exit is allowed.

### Outcome: **(b) another reading round**

Three reasons:
- Rule 4: no form reaches 3/4, and a 2-2 has no pick to put first.
- Rule 6: error 1 voids the tally.
- Both candidate forms are merges that no reader has read whole.

Every reader labels it an owner call, so build the round to produce an owner-ready comparison. A 2-2 after it
goes to the owner as a split (rule 4). **The next brief must fix or merge these (not drafted here):**
- Correct story (a): on a `correlator: none` channel the create goes to an operator (PRV-33, 02:1049).
- Correct C: the keepalives survive C ("the actual cure", ADR-0019:72).
- Present B as B′: a merge of fable's and opus's texts, with "the loss is not a later stop".
- Present A as A′: a merge of astra's and sol's texts, with exit-at-once timing in `OPS-47` and Q1b stated.
- Fix A′'s CNF to keep CNF-362's "Accept either outcome".
- Caveat (b): a kill on failover is a crash, so (b) does not separate the options.
- Name CNF-365's in-place restart as the existing drill that drops the lock. State how B′'s reconnecting
  record writes meet its connection-check assertion.
- Quote ADR-0044's decision 1 and the rejected exits (:78-81, :135-136) neutrally, scoped as precedent by
  rationale.
- State the misconfiguration window each form pays.
- Have every reader vote ACCEPT / CANNOT ACCEPT on **both** exact forms.

## Q2 (pv-9j6): a failure the worker records with the marker unset, for the four kinds

### Votes

| Reader | Vote (as written) | Counts as (rule 1, letter) | D | Label |
|---|---|---|---|---|
| fable | ACCEPT A, with D | for A | yes (variant: "(`OPS-45` owns what that settles)") | mechanics |
| opus | AMEND A, behaviour unchanged | for A (checked: no bullet of A changed) | yes | mechanics |
| astra | AMEND A plus D, "behaviour changed" | CANNOT ACCEPT A, own form; names no verdict | yes, exact deletion | owner |
| sol | AMEND A plus D, "behaviour changed" | CANNOT ACCEPT A, own form; names no verdict | yes, exact deletion | owner |

- **Behaviour: 4-0 for A.** `OPS-45` governs, through A's guarded arms (`!f.accepted`) with goal-state
  precedence.
  - Checked, astra's and sol's texts change no A bullet in any reachable state. The acceptance guard and the
    rescue clause are already in A's Lean, and `PRV-5` (02:46) makes "marker unset and accepted" unreachable.
    Their "behaviour changed" reads as against master.
  - **I did not reinterpret the label.** By the letter A has 2/4 and rule 4 applies. Counted for A, rule 2
    still requires a confirmation read of the merged text. The outcome is the same either way.
- **D: 4-0.** Fable's form is a pointer variant.
- **retryable:** 4-0, no new rule. **`Rescue.lean` `governs`:** 4-0, unchanged.
- **CNF-31a:** 3-1 unchanged (fable, astra, sol). Opus adds a both-directions assertion.
- **(i) explicit not-accepted guard in the prose:** 2-2. Astra and sol say yes. Fable and opus say no, citing
  `PRV-5`.
- **Mechanics/owner label:** 2-2.

### Counter-arguments, written on request (not votes)

- **fable:** `internal` is a catch-all. The bug it most often names is a dispatch the engine failed to mark, and
  A settles that `failed` over a provider that acted.
- **opus:** a driver that dispatches before marking turns a mutation that may have landed into `failed`. B fails
  safe.
- **astra and sol:** B keeps the simpler conservative classifier, and A depends on marker timing.

### Verified checks and brief errors

1. **Brief error. "Pre-dispatch" is not "marker unset" (fable, astra, sol): VERIFIED.** OPS-45 (03:1429-1437)
   persists the marker "at the moment a phase begins that could have altered the machine, and before that phase
   runs"; for these kinds "the provider call is dispatched".
   - Story 2, "the driver fails while building the request", sits after the marker and stays ambiguous under
     every option.
   - A stop between the marker's acknowledgement and dispatch is also outside A.
   - The brief's "OPS-45 says a pre-dispatch failure of those four kinds is failed" is too broad.
   - **The premise holds.** A's text and every reader's form key on "marker unset", and story 1 (null
     `write_started_at`) is sound. **It does not void the tally.** It affects A's CNF bullet: the `internal` case
     must be "a failure before the marker write", the engine's own failure before the provider call.
2. **Draft A omits deleting CNF-362's exclusion (sol): VERIFIED.** 10:1665-1666: "Make no assertions about
   power, reverse DNS, delete or release attachment stopped before dispatch (`pv-9j6`)." A's added CNF-362 cases
   contradict this sentence unless it goes. This is a draft defect, not a premise error.
3. **A's prose omits `OPS-45`'s rescue clause, which A's Lean carries (`m.rescueClean`).** Astra and sol restore
   it. Draft defect.
4. **Gate check: no existing theorem flips under A.**
   - Opus's "No theorem pins a last-row kind at ⟨false, _⟩" is wrong in letter. `createMachine` is a last-row
     kind, and `rejected_order_witness`, `before_step9_failure_witness` and `cutoff_conflict_witness`
     (Witnesses:3130-3162) pin it at ⟨false, true⟩. `admission_only_failed` (Tables:239-242) pins every kind at
     ⟨false, true⟩ to `failed`.
   - A leaves the create arm alone, and A keeps `failed` there.
   - No theorem or witness pins power, reverse DNS, delete or release at ⟨false, _⟩.
   - `accepted_never_failed` (Tables:256-259) stays green with the guard.
5. **CNF-31b's last-row pre-send `network` case (10:229-231): VERIFIED unaffected.** It happens inside the
   dispatched call, so the marker is set. Astra and sol want "marker set" written into it.
6. **CNF-31a covers create and install only (10:205-212): VERIFIED.**

### Outcome: **(b) another reading round, a confirmation read**

The behaviour converged 4-0 and D 4-0. The form is a merge of fixes that no reader has read whole. **The next
brief must merge or settle (not drafted here):**
- Delete CNF-362's exclusion at 10:1665-1666.
- Re-key the CNF additions to "before the marker write", with story 2 corrected.
- Put `OPS-45`'s rescue clause in the last row's prose.
- Settle the 2-2 on the prose acceptance guard, or carry both texts.
- Add fable's `last_row_marker_unset_failed`, opus's witness with its `markerRule := false` negative, and astra's
  negative witness. Pick one set.
- Opus's CNF-31a both-directions assertion (3-1 against).
- Opus's extra CNF-362 case: a delete stopped while its marker write repeats.
- "Marker set" in CNF-31b.
- D's text, fable's variant or the exact deletion.
- The 2-2 owner/mechanics label.

The read is ACCEPT / CANNOT ACCEPT on that exact form. Under rule 2 its behaviour then goes to the owner as the
panel's recommendation.

## Q3

4-0 for separate Runs (fable, opus, astra, sol). Fable wants pv-9j6 first, because it carries the Lean build
risk.
