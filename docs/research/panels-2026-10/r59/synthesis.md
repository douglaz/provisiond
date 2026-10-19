# Panel r59 synthesis: pv-zbp review, a stop during `PRV-13c`'s post-order read, 2026-10-19

Readers: fable (claude-fable-5-1, xhigh), opus (claude-opus-5-5, xhigh), astra (gpt-6-astra, high) and sol
(gpt-6.1-sol, xhigh). Each had its own clone of branch `pv-zbp-triage` at `647ed9b`. All four exited 0,
with answers of 2.8-4.2 KB. Every `file:line` below was checked against `647ed9b`. The brief is `brief.md`.
The patches and gate logs the readers link stay under `/var/tmp` and are not committed.

## The story

A Robot auction-channel create's order is accepted. The settle-time search finds exactly one machine and
the confirming `GET /server/{n}` succeeds. The driver then makes `PRV-13c`'s one post-order read,
`GET /server/{n}/cancellation`. A deploy stops the engine during that read, and the engine survives.

- **The branch says cut-off.** `OPS-21` (03:1764) says "For a create, the worker's settle-time verification
  is inside `execute`: `OPS-27`'s correlator search and its confirming read, and `PRV-13c`'s post-order read
  in that settlement pass, so a stop during any of them is the cancellation being recorded". It also says
  (03:1722) "The worker classifies a recorded cancellation under `OPS-11`". `CNF-362`'s Placement control
  (10:1613-1616) asserts "a cut-off `conflict` with `details.reason: "cut_off"`, `needs_reconciliation`".
- **`PRV-13c` says the settlement stands.** It says (02:607-608) "A failed post-order read of any kind,
  `rate_limited` included, MUST NOT enter `OPS-11`'s classifier and MUST NOT change the create's
  settlement". `CNF-356`'s Q31 amendment (10:3951-3954), with a network error on that read, asserts "the
  same `succeeded` status ... with only `earliest_cancellation_date` null in the failed case. Assert no
  `needs_reconciliation`".

## Errors in the brief that the readers caught

- **`CNF-147` should have been `CNF-356`.** All four readers caught this. The brief named `CNF-147` as the
  Q31 fixture. The `succeeded`-with-null-date assertion is `CNF-356`'s (10:3945-3964). `CNF-147`
  (10:1402-1416) is the end-to-end Robot item, and its read-back clause ("presence or read failure settles
  scheduled with the returned effective date", 10:1409-1410) is pv-ilb's case.
- **The manager's Q3 claim is broken: three readers say wrong, and fable says half right.** The claim was
  that `OPS-21`'s "`execute` returns only once the outcome its settle write records is final, so every
  provider call that outcome depends on is made inside `execute`" (03:1763) does not reach the post-order
  read.
  - opus, astra and sol: the date is part of what the settle write records. `OPS-27` (03:577-578) says
    "that transaction MUST include the column write with the machine row", so the read belongs inside
    `execute`.
  - The error was reading "inside `execute`" as "cut-off". opus: "The branch's mistake was treating
    'inside `execute`' as 'cut-off'."
  - fable: the sentence "neither places nor excludes the read; the 'For a create' sentence decides".
- **The same error sits in pv-zbp's own contract** (sol).
  - The Agent Brief says "A stop during any of those is still `OPS-21`'s cancellation of `execute`,
    unchanged".
  - Its 2026-10-19 amendment keeps acceptance criterion 2's alternative: "the text makes a stop during
    those reads `OPS-21`'s cancellation of `execute`".
  - So the Run did what its brief said. Option (a) amends that brief, not only the branch's wording.
- **One reader on the contradiction itself (astra).** `CNF-362` and `CNF-356` inject different faults (a
  stop; a `403` or network error), so the two checklist items do not contradict each other on the same
  input. The contradiction is `OPS-21` against `PRV-13c`, and it turns on whether a stop is a failed read
  "of any kind".

## Picks

| | fable | opus | astra | sol |
|---|---|---|---|---|
| Q1 contradiction | yes | yes | yes, "under the unqualified failure rule" | yes, "absent an unstated cancellation exception" |
| Q2 option | **(a)** | **(a)** | **(a)** | **(a)** |
| Q3 manager's claim | half right | wrong | wrong | wrong |
| Q4 date | null; no collision | null; no collision | null; no collision | null; no collision |
| Q5 decides pv-ilb | yes, but it needs its own sentence and a `CNF-362` carve-out | **no**: "The principle carries over; my text does not" | yes | yes |
| Window the new sentence covers | a stop that "cuts short" the read | a stop "after that confirming read succeeds and before `execute` returns" | a stop "that cuts short either of these latter reads" (post-order and `PRV-13`'s) | a stop "during" either read (post-order and `PRV-13`'s) |
| Restates that the bound runs from the stop | no | no | yes: "the stop, not ... the return" | yes: "that stop" |
| Q6 reversal plant | green; only `CNF-362` checks | `OPS-21` alone: `citations` red; with the `CNF-362` quote synchronized: green | green | green |

**Strongest argument for (a), one per reader:**

- **fable:** "The outcome is final before the read starts, and `PRV-13c` forbids the read moving it." It
  adds: "(b) parks a verified create", and "`OPS-21`'s rationale 'A provider call abandoned mid-flight is
  exactly the uncertainty this design exists to represent' is false for a read that can change nothing."
- **opus:** "The search and confirming read are cut-off because their failure already gives
  `needs_reconciliation` (`OPS-27`). By the same reasoning, this read's failure gives `succeeded`." It
  adds that `ADR-0037` (Q31) "already rejected (b)'s shape".
- **astra:** "The interruption supplies no reason to discard established success when the remaining
  read's failure is explicitly absorbed."
- **sol:** "losing the date cannot erase verified delivery."

**Against their own pick, written on request (these are not votes):**

- **fable:** (a) "splits `OPS-21`'s 'for every operation kind' into per-call carve-outs, one per absorbed
  read". It also "loses the date for a stop the engine itself caused", and then the null date means
  "over-reserving the tenant's runway".
- **opus:** "(b) is cheap". A deploy parks at most the creates in flight. "A kill in that window already
  parks them", and "(a) also has the worker make a provider call after a stop".
- **astra:** "cancellation is control flow, not a returned provider failure. 'Of any kind' could quantify
  only returned errors. Thus (a) needs an explicit exception".
- **sol:** "The amended agent brief expressly demanded cut-off here. Option (a) therefore needs an
  explicit lifecycle amendment".

## What was checked

**Verified:**

- Every quote above, at the lines given.
- `ADR-0037` Q31 (adr/0037:415-417): "Rejected: ... keeping it with a failure that waits in
  `needs_reconciliation`, since a spent hour would stall every delivered server." That sentence is about a
  `rate_limited` failure. opus's point that a deploy parks only the creates in flight is a fair
  distinction.
- `PRV-13c`'s discard sentence (02:618-619) is about "interruption by engine exit or crash (`OPS-15`)". It
  does not reach a survived stop whose record lands.
- "Within a settlement pass the post-order read MUST NOT be repeated" (02:615-616) holds, because there is one
  interrupted attempt.
- `PRV-5`'s alarm trigger is "every Robot `403 RATE_LIMIT_EXCEEDED`" (02:51), which a stop does not
  supply.
- The kill parity opus cites. `CNF-362`'s After-return control (10:1611-1612) says "a kill after `execute`
  returns and before the settle write lands writes nothing; assert `OPS-15` classifies the row at
  restart". `OPS-21` (03:1714-1715) says "A kill or crash records nothing".
- The changed sentence is quoted in exactly two places: `OPS-21` itself (03:1764) and `ADR-0044`
  (adr/0044:117). No Lean declaration or docstring quotes it.
- fable's gate gap. `ADR-0044`:117 introduces its quote with "`OPS-21` places the create verification:".
  "places" is not in `check_citations.py`'s `SPEECH = r"says|said|states|stated|reads|read"` (tools:195),
  so the gate does not check that quote. fable's corrupted copy stayed green. Using "says" there fixes it
  in scope. It needs no bead.
- Every reader's gate claims agree with their logs.
  - Option (a) is green in all four clones.
  - A reversal of the deciding sentence, made in sync with its `CNF-362` quote, is green in all four.
  - `CNF-362` is the only check.

**Broken or corrected:**

- **fable's money cost does not hold in v1.**
  - The null date is priced through the declared bound. `LDG-33` says "or, where
    `machines.earliest_cancellation_date` is null, through `machines.declared_cancellation_bound`"
    (12:357).
  - In v1 an offer "MUST NOT be sold on prepaid terms if either its descriptor-declared bound or its
    offer-reported bound is later than the provider's local today" (`PRV-31`, 02:557-559).
  - `CNF-356` (10:3955-3956) says the term's "contribution is zero for this v1 offer".
  - So a null date reserves nothing extra in v1. The real cost is that the system does not learn of a
    deviation. `ADR-0037` (adr/0037:410-411): "Only this read learns of a deviating contract while the
    tenant's committed satoshis can still cover it."
  - Q31 already accepted that cost for a network-error failure. The date then arrives with an accepted
    cancellation's response (02:630-632).
- **fable misattributes a quote.** It gives "A failed read supplies no absence evidence" as `PRV-13`'s.
  That text is in no requirement. The nearest are `CNF-64`'s "The failed read supplies no absence
  evidence" (10:386) and `PRV-13`'s "Read failure does not turn the accepted dated cancellation into
  `needs_reconciliation` or establish absence" (02:228-229). The substance holds.
- **fable's analogy is not the same case.** It quotes `ADR-0044`'s rejection that exiting "throws away an
  outcome in hand" (adr/0044:133-134). That rejected exiting when a stop lands in an ordinary settle
  write's loop. The analogy is fair.

## Drafting points the four drafts leave open (not voted; for a short round before anything is applied)

1. **The gap before the read is sent.** Take a stop after the confirming read succeeds but before the
   post-order read is sent.
   - fable's, astra's and sol's sentences cover only a stop that "cuts short" the read or comes "during"
     it. The gap falls back to `OPS-21`'s general rule (03:1711-1712), which gives a cut-off. That parks
     a verified create, the outcome all four reject.
   - Skipping the read instead collides with `PRV-13c`'s "The settlement pass whose landed-order
     transaction commits MUST make the one post-order read" (02:614-615).
   - Only opus covers the gap: "the worker still makes `PRV-13c`'s post-order read ... the stop ends that
     read at once". opus itself lists that as a cost: "(a) also has the worker make a provider call after
     a stop".
2. **"A stop after `execute` returns" by definition.**
   - fable's and opus's drafts record the stop "as a stop after `execute` returns". `OPS-21` (03:1765)
     defines that as a stop "that arrives after `execute` returns", and this stop arrives before.
   - astra and sol avoid that label: they record the stop "under the after-return recording rules" and
     restate the bound's start. 03:1743 already says "The Stop-record bound is measured from the stop".
   - Also open: whether a second stop between the return and the record is a later stop. 03:1771 defines
     a later stop only after "a stop has cancelled `execute`", and under (a) this stop does not.
3. **The `CNF-362` scope sentence.** astra's and sol's drafts exclude the absorbed reads from the generic
   "For each operation kind, stop the engine while its worker is in `execute`" (10:1544). fable's and
   opus's drafts do not.

The manager has not settled these. Under the standing rule, a split the manager settles needs its own
round before it is applied.

Superseded by the owner decision below: no r59b round ran.

## What one customer gets under each option

The customer prepays and orders a Robot auction server. Before ordering, the system sets aside the setup
fee and the first hour from their balance. Hetzner accepts the order, and the system finds the server and
confirms it. The deploy stops the engine while the system is asking Hetzner for the server's earliest
cancellation date.

- **(a), absorbed.** Before the engine exits, the order is recorded `succeeded`.
  - The server is the customer's, and the setup fee and first hour are taken once.
  - The cancellation date stays blank, so the money held against cancellation is priced from the offer's
    declared bound. That bound is "today" in v1, so nothing extra is held.
  - If this one server's contract deviates, the system learns it only when the customer cancels. This
    already happens today when that read fails with a network error (`CNF-356`).
- **(b), cut-off.** The order is recorded as a cut-off `conflict` and parks in `needs_reconciliation`.
  - The customer sees an unresolved order with `retryable: false`. Nothing is debited yet, and the
    set-aside stays held.
  - After the restart, automatic resolution runs. `OPS-27` (03:499) says "The system MUST attempt
    automatic resolution before asking a human". It searches again and confirms the server again. It
    asks for the date again, because the store holds no machine row (02:620-621). Then it attaches the
    server "as though it had succeeded" (03:506) and takes the fee and first hour once.
  - The costs: a delay before the customer has the server, and a repeat of the search (across every
    ordering channel, 03:511), the confirming read and the date read, all against Robot's hourly budget.
    In exchange the date is learned.
  - `OPS-33`'s release (03:1619-1622) runs only on a negative search, so it does not apply while the
    server is found.
- **(c), drop.** The text says nothing on the case, so one engine parks the order and another records it
  `succeeded`. That is pv-ilb's shape. No reader picked (c).

**A kill** instead of a survived stop parks the order under every option (`OPS-15`, 03:1714-1715).

## pv-ilb

On the literal question the tally is 3-1: fable, astra and sol say the answer decides pv-ilb, and opus
says no. On substance all four agree that the principle carries over and the text does not.

- **The principle:** a stop the engine survives that cuts short a read whose failure its requirement
  absorbs is that read's failure, and `execute` returns the outcome that requirement prescribes.
- **The difference.** `PRV-13`'s direct read (02:222-231) can change the settled state: mapped absence
  "records the machine gone at this read". The post-order read only fills a nullable column.
- **The money effect of absorbing there.** `PRV-13` prescribes "the accepted attempt settles `succeeded`
  as `cancellation_scheduled` with its effective date" (02:226-228). `LDG-74` says "the stored effective
  date clips the customer meter even while gone confirmation waits" (12:603-604). Only the episode's
  close waits for the sweep.
- **How each reader would write it.**
  - astra and sol cover both reads in one `OPS-21` sentence.
  - fable wants pv-ilb's own sentence and a carve-out from `CNF-362`'s "power, reverse DNS, delete and
    release attachment stopped during their provider call after dispatch enter `needs_reconciliation`"
    (10:1549-1550).
  - opus wants pv-ilb left to its own text.
- Whether pv-ilb joins this branch is a scope call for the owner.

## Where a ruling lands

| Identifier | Site at `647ed9b` | Under (a) |
|---|---|---|
| `OPS-21`'s placement sentences | 03:1763 ("`execute` returns only once ..."), 03:1764 ("For a create ...") | 1763 kept (Q3). 1764 narrowed to the search and confirming read, plus a new sentence for the absorbed read and the drafting points above, and a dated amendment note |
| `OPS-21`'s rationale | 03:1727 ("A provider call abandoned mid-flight ...") | sol narrows it to a call "whose failure enters `OPS-11`'s classifier" |
| Worker algorithm comments | 03:1681, 03:1689 | astra's and sol's drafts update both |
| `CNF-362`'s Placement control | 10:1613-1616 | the post-order read moves out, into an absorbed-read case asserting `CNF-356`'s outcome |
| `CNF-362`'s scope sentence and delete clause | 10:1544, 10:1549-1550 | the scope sentence excludes the absorbed reads; the delete clause is carved out only if pv-ilb joins |
| `PRV-13c` | 02:607-608 | unchanged (settled) |
| `CNF-356` | 10:3945-3964 | unchanged; the new `CNF-362` case cites it |
| `CNF-147` | 10:1407-1410 | unchanged (pv-ilb's read-back) |
| `ADR-0044` | adr/0044:117 | quote re-synchronized and introduced with "says"; one rejected option added |
| pv-zbp Agent Brief | acceptance criterion 2 and its 2026-10-19 amendment | amended: the post-order read is absorbed, not cut off |
| pv-ilb | bead | closed with pv-zbp if it joins; otherwise triaged on this principle |

## Owner decision, 2026-10-19

**Option 1: (a) for both reads, so pv-ilb closes with pv-zbp.** A survived stop during `PRV-13c`'s
post-order read, or during `PRV-13`'s direct read after an accepted dated cancellation, is that read's
failure; the create settles `succeeded` with a null date, and the delete settles `succeeded` as
`cancellation_scheduled`.

r59b was skipped. The coordinator relayed that the three drafting points are wording or already
settled by the ruling: a stop between the confirming read and the date question follows (a), because
the outcome is already final there. They were closed in the applying commit:

1. The gap: `OPS-21`'s new sentence covers a stop "after a create's settle-time confirming read
   succeeds, or after a delete's cancellation is accepted with an effective date, and before `execute`
   returns", and "The worker still makes the read that follows, the stop ends it at once as a failed read
   unless it has already completed".
2. The label: the settle write "records the stop as it records a stop after `execute` returns", so
   the after-return rules apply without calling this stop one.
3. The scope: `CNF-362`'s generic sentence now runs "outside the absorbed-read cases below", and its
   delete clause excludes "a delete's direct read after an accepted dated cancellation".
