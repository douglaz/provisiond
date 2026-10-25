# r65b tally (panel D, pv-buc), master b90783d, 2026-10-24

Rules: r65b/notes.md (written before launch), applied as written. Readers: fable, opus, astra, sol. All four exited 0
(fable 02:52Z, opus 02:55Z, astra 02:44Z, sol 02:55Z). Astra took 4 minutes but answers Q1, Q2 (a)-(f) and Q3 in
full. Facts below were checked against a `git archive b90783d` snapshot. Line refs are b90783d.

## Outcomes

| Q | Outcome | Tally |
|---|---|---|
| Q1 R vs E | **(a) consensus: R**, which goes to the owner as the panel's recommendation (label owner, r64 4-0) | R ACCEPT 4-0, E ACCEPT 4-0, pick R 4-0, fixes 1-9 right 4-0, E placement wrong 4-0 (one repair) |
| Q2 Fence G | **(a) consensus: ADOPT in principle**. It goes to the owner as a recommendation because it reverses `ADR-0019`'s scope rejection (4-0 on (d)). The sketch as written is NOT sound: G's text needs its own drafting and reading round | ADOPT 4-0. Sound: 3 YES, 1 NO with a verified stale-write trace (opus) |
| Q3 Fence A | **Moot** (moot rule: Q2 consensus ADOPT, and 4 of 4 call A moot under G). If the owner declines G, Q3 stands as 4-0 DON'T ADOPT | DON'T ADOPT 4-0. Sound: 2 YES, 2 NO (a dispute over the baseline, not a vote) |

No question is voided and none is (c). There is no owner *split*. Two owner *confirmations* are needed (Q1's
label, G's ADR reversal); see "Owner relay" at the end.

## Q1: R vs E

| Reader | R | E | Pick (no G) | Strongest reason |
|---|---|---|---|---|
| fable | ACCEPT | ACCEPT | R | `OPS-21` "“Survives” means the process outlives the stop" (03:1740): the engine outlives a lost lock connection, so `ADR-0044` decision 1 reaches it unless the owner re-scopes. E discards an outcome in hand in S1-S4 and prevents no write |
| opus | ACCEPT | ACCEPT | R | S1-S4 need no misconfiguration. Under E the keepalive row (`OVR-19`), an infra setting, decides whether an outcome in hand survives. After detection R starts no new provider mutation |
| astra | ACCEPT | ACCEPT | R | S3 is decisive (keeps an accepted dated cancellation; no operator). S4 independently favours R with no misconfiguration |
| sol | ACCEPT | ACCEPT | R | S4 is decisive with no misconfiguration. S3 also |

No CANNOT ACCEPT, blocking or not. No pick is conditional on G. All four say G leaves the pick at R (Q2 (e)).

**Fixes 1-9 (rule-2 confirmation read): "all right" 4-0.** Fable checked the anchors, and I re-checked them:
10:1611 "absorbed-read"; 10:1624 "at successive fan-out positions"; `rcases h with ack | bound | store | later |
redelivery` at StopRecord.lean:435, 453 and 468; the docstring at 282; `ADR-0044`:95 "No existing theorem is weakened".

**E's placement (open point): wrong 4-0, with the same repair from all four.** Move E's `OPS-21` sentence to after
03:1770 ("…`OPS-15` classifies the row as interrupted"."), as R does. Verified: 03:1766 (the later stop) and
03:1767 ("The sent transaction's fate is the server's") form one block, and E's sentence carries its own "a
transaction already sent is the server's to decide". This is one span with one repair (opus gives the text, which
is E's sentence unchanged), so it is converged. It **changes no behaviour**, and it matters only if the owner picks E.

**Non-blocking notes (recorded, NOT merged; merging one would be an unreviewed merge):**
- **sol: "Both fixtures should explicitly say 'after detection'" where they forbid further transactions, claims
  or passes.** R's `CNF-366` asserts "no claim and no periodic pass begins after the loss". r64b found 4-0 that E1
  claims during the blind window, so a conforming engine can fail that assertion. This is the same class as
  r65's blocking fixture defect (an assertion a conforming engine cannot meet). Sol voted ACCEPT and named no
  gate, so it does not block. **The step before the Run must handle it.** The change it implies is to the checked
  assertion, not to the engine's required behaviour. R's `OPS-47` clause has the same issue: "where the connection
  carrying it is lost, the engine MUST claim nothing more" (E already says "is detected").
- **opus, on fix 6:** "the loss as the engine sees it" is invisible to an outside tester unless the loud log
  timestamps the detection.
- **opus, optional for E:** an `OPS-49` pointer to match R's: "`OPS-47` says a lost lock connection means “it MUST
  exit non-zero at once”: a worker repeating a transaction when the loss is seen stops repeating."

**S5 traces (evidence; the `OPS-22` inconsistency is not voted here).**

| Reader | Worker reading | Engine reading |
|---|---|---|
| fable | R: every post-pass row recorded within the bound (E2 never touched them, so the guard admits). E: all stay `running`, and the non-yielded ones hold machines until E2 restarts | R: the first pre-pass record that meets E2's sweep exits E1, and post-pass rows not yet landed strand as under E. E: unchanged |
| opus | R: every post-pass row recorded; zero-row records of pre-pass rows end only their own workers; E1 exits after the last. E: unrecorded post-pass rows stay `running`, and the non-yielded ones block until E2 restarts | R: exit at the first zero-row write on a pre-pass row, and the rest strand as under E. If that write comes *before* detection, R = E. E: the same, or earlier by that same zero-row exit |
| astra | R records them unless a bound, a later stop or another exit intervenes. E strands them | R records some before its first zero-row exit, and the rest strand. A sent transaction may still commit |
| sol | R records or defers them if the bounds permit. E leaves them `running` until E2 restarts | R keeps what landed before its first zero-row exit, and the rest strand as under E. E exits at detection |

All four agree with the manager's traces: R is never worse than E, and only the size of R's S5 gain depends on
the reading. Opus adds that under the engine reading a pre-detection zero-row write makes R and E identical.

**Against the pick (written on request; rule 7, not votes):** E is one sentence and one `CNF`, and keeps "once,
at boot" exact (fable, opus). R keeps a lockless engine writing for up to the Stop-record bound beside a successor
that thinks it is alone (all four). Periodic passes already running continue, and operation guards don't protect
every machine write (sol). S1-S4's losses are detours that `OPS-27` / `needs_reconciliation` already repair (fable,
opus). R's gain needs a store that accepts the record before *either* bound ends (astra).

**Brief errors reported for Q1, verified, with why none voids Q1.** notes.md's test is a verified break of a
separating case *that affected the case for the pick*.
1. **"On a `correlator: none` channel nothing separates the forms" is FALSE** (astra, sol; opus as "missing
   case"). After step 8 is acknowledged and before step 9, R records a cut-off before step 9, and that is `failed`.
   The create row says "Any create failure the worker records before any step-9 request … MUST settle `failed`,
   whatever its kind". E restarts, and 03:237 says "A restart in that same window takes the ordinary path …
   since the column is set" (`needs_reconciliation`). This holds on every channel, so it is a new separating
   case. **Not a void:** it adds a case in R's favour.
2. **S3: "`PRV-29` (02:423) names no writer but the operator" is wrong** (fable, opus, astra). `PRV-29`
   (02:422-427) names no writer at all. The flowchart (03:455-463) routes non-creates to "Read provider evidence,
   PRV-29" with automatic outcomes. `OPS-45` (03:1472-1474) says resolution "proceeds by `PRV-29`/`PRV-36`'s
   provider evidence where the driver can produce it". 03:95-96 and `OVR-17`'s list (00:295) name only `OPS-27`'s
   correlator sweep or the operator. So whether S3 under E ends with an operator is a spec gap, not a fact.
   **Not a void:** this touches astra's stated *decisive* reason, but astra names S4 as an independent reason. S3
   still separates the forms: R settles `succeeded` as `cancellation_scheduled`, and E goes through
   `needs_reconciliation` whoever resolves it.
3. **S5 overstates E's machine blocking** (astra). `operations.machine_id` is "nullable; set on completion for
   create" (05:411). A stranded `running` create has a null `machine_id`, and STO-51's partial unique index
   (05:93-94) does not block on it. Only non-create kinds hold their machines. **Not a void:** it shrinks an E
   cost and reverses no row.
4. **S1/S5 overpromise R's recording** (astra, sol). `OPS-21`: "whichever ends first ends the record" (03:1780).
   R lands the record only if the store is back before *both* the Stop-record and Store-retry bounds; otherwise it
   exits as E does. **Not a void:** R is never worse than E.
5. **S5 under R: "provider calls outstanding continue" is too broad** (opus). R treats the loss as a stop, which
   cancels `execute` ("A provider call abandoned mid-flight", 03:1754), except the two absorbed reads. Only the
   provider's side of a call already sent continues, and that is the same under E. **Not a void:** it is in R's
   favour.
6. **The line before S1 is still too broad** (opus, astra, sol). Refresh is "Always `failed`" (03:228) under both
   forms, so it does not separate them. The absorbed reads keep success. Opus adds that an install or rescue
   inventory before its write-started marker, with no rescue session open, is `failed` under R (03:231, "for any
   failure at all while `OPS-45`'s two markers say the disk is untouched") and `needs_reconciliation` under E.
   That is S4 extended to rescue inventory ("Same rows as `install`"). **Not a void:** it is in R's favour or
   neutral.
7. **S1/S2's E outcomes omit "resolves *absent*"** (astra; `OPS-27`, 03:526-530). **Not a void:** it is another
   E path, not an R loss.
8. Nits: `ADR-0022`'s quote spans 40-41 (fable). The r64/r65 records are absent from the clone (all four), so
   those records were unverifiable, not wrong.

**S4 was challenged by no reader**, and it needs no misconfiguration. Sol names it decisive and astra names it as
an independent reason. That is what keeps the pick at 4-0 through errors 1-7.

## Q2: Fence G

| Reader | Vote | Sound | (d) Is G `ADR-0019`'s rejected option? | (e) Does G change the pick? |
|---|---|---|---|---|
| fable | ADOPT, stated as a reversal of `ADR-0019`'s scope | YES | Yes | No |
| opus | ADOPT, with one repair | NO as sketched (trace below); YES with the repair | Yes, extended | No |
| astra | ADOPT | YES as a database-write fence (the comparison and the writes in one transaction, holding the share lock to commit) | Yes | No |
| sol | ADOPT | YES as a database fence (same condition) | Yes | No |

**ADOPT carries 4-0 (consensus).** It carries *in principle*. notes.md says "No full G text is voted this round",
and the sketch is not sound as written.

**Opus's NO trace (it counts under notes.md: G admits a stale write).** A backup is taken while the generation is
5. E1 advances it to 6. The store is restored from that backup (back to 5) while E1 survives. E3 starts on the
restored store and advances 5 to 6. E1 reads 6, which equals its own value, so its writes are admitted beside E3's.
**Verified by construction:** the generation is a row in the store, so a restore rolls it back, and "advance"
repeats a value. The surviving engine is the misconfiguration `STO-54` forbids. For promotion `STO-54` says "the
deployment MUST stop every engine and `api` process that was connected to the old primary" (05:1508), and any
other promotion "is a restore". Precedent for the repair: on a restore "every tenant's credential generation is
bumped" (05:1550). **Repair (opus; sol's (c) "a generation that is not reused" agrees):** the pass writes a
value never written before (a fresh UUID), and every check is an equality test. This is a reader fix, so it is
**not merged**. It is a required input to G's text round.

**(a) Does a provider mutation go out after the advance without a guarded write before it? 4-0: yes; G narrows
r64b's window, it does not close it.** A guarded write that committed just before the advance licenses the
dispatches after it. Step 9 comes after step 8 (`OPS-43`: "Step 9 MUST begin only after step 8's transaction is
acknowledged", 03:767), and step 9 is two calls. Other cases: an install's whole destructive phase after one
marker; end-rescue (opus); temporary-key deletion `PRV-9`/`PRV-18` (opus); `OPS-32`'s cleanup, which acts from
reads (sol). Those rows reach `needs_reconciliation` or `OPS-15`'s exceptions.

**(b) How long can the takeover wait? 4-0: no universal bound.**
- The wait is bounded by E1's own `STO-7` server-side timeouts, by keepalive reaping of a partitioned E1, and by
  E2's `lock_timeout`.
- A `SyncRep` holder can hold its locks indefinitely. `STO-7` (05:145): "A standby wait has no server-side
  timeout". Fable notes that E2's writes would wait then too.
- Opus: in S5's in-place restart every E1 session is already gone, so there is no wait. A wait exists only where
  E1's pool outlives its lock session, as in a partition.
- Split for the text round: fable reads E2's timeout as `OPS-49`'s store error. Opus, sol and astra want an
  explicit startup exit. `OPS-49` covers "a worker, or … a periodic component" (03:1834-1835), and `OPS-15` "MUST
  NOT run periodically", so the explicit exit is needed.

**(c) Does G rest only on the shared database? Qualified 4-0: for safety, yes, but not "no infrastructure setting
has to be right".** G holds only with:
- a never-reused value (opus, sol);
- every write path carrying the check, an implementation obligation a `CNF` can test (opus, astra);
- one database history: `STO-54` "the old primary MUST NOT serve a component again" (05:1508; astra, sol). G does
  not fence two writable histories.

Timeouts affect liveness only: a wrong setting gives an alarmed stall, not a stale write (4-0).

**(d) 4-0: yes, G is `ADR-0019`'s rejected "Fix the predicate", widened to every write and made race-free by
`FOR SHARE`.** This settles r65's 1-2 split. Verified:
- `ADR-0016`:25-27: "At startup the engine increments a single `engine_epoch` row and holds the value; every
  engine write to `operations` and `machines` is guarded on `epoch = mine`."
- `ADR-0019`:78-80: "guard the claim itself on `engine_epoch = mine` … Correct, and cheap. Rejected because it
  buys a defence for the case this ADR puts out of scope".

G is not the deleted self-stamped epoch (`OPS-47`'s italic note, 03:150-151). The new ADR must say it reverses a
scope rejection.

**(f) The id list.** The brief's unverified guess is **verified: `OPS-15` and `OPS-5` belong** (4-0, and I checked
both).
- `OPS-15` (03:352-357): "with one writer, any `running` row at startup is interrupted" and "nothing but a restart
  can leave a `running` row with no worker behind it". G's advance goes in its first transaction.
- `OPS-5` (03:156-157): "Claiming MUST be atomic … one indivisible step". G adds the `FOR SHARE` read and
  comparison to it.

Missing from the brief's list (reader counts in brackets):
- `OPS-6` [4]: "is not a fence against a second engine", 03:175-177.
- `OPS-49` [4]: a mismatch exits and is never repeated.
- `CNF-290` [4].
- `CONTEXT.md` [3]: "generation" is on the _Avoid_ list at :108.
- `STO-1` [2], `STO-6` [2], `OPS-42`'s machine-row writes [2], `OVR-17` [2], `Claim.lean` [2], `OVR-19` [2], and a
  schema row [3] (`STO-51` says "It carries no row", 05:91).
- [1] each: `STO-3`'s startup-pass bullet (05:49, "nothing contends with it"), `ADR-0016`, `ADR-0022`, `STO-54`/
  `STO-56` for the repair, `OPS-43` step 8, `OVR-18`, and `STO-7`/`STO-55` for the wait contract.
- Sol: amend `OPS-47`'s "nothing here refuses the second" (03:138-139) but keep "the lock is not a fence".

**Brief errors reported for Q2, verified, with why none voids Q2.** In each case the readers corrected the fact and
then voted ADOPT 4-0, so no premise behind a vote was false.
1. **"With G … the marker mismatches … so no order is placed" holds only if step 8 had not committed before the
   advance** (opus, astra, sol). See (a).
2. **"No infrastructure setting has to be right" is too absolute** (opus, astra, sol). See (c). **It must not
   reach the owner as written.**
3. **Sketch item 5 omits `OPS-15`'s exceptions** (opus, astra, sol): refresh is `failed`, a null-column create is
   `failed`, and the parent goes back to `queued`. Not every swept row goes through `needs_reconciliation`.
4. The brief calls step 8's write the "pre-order marker". Opus says "The column is not a marker" (`OPS-45`). I
   found that phrase at 03:1425 but did not read its context. **Unverified**, and a nit either way.
5. The PostgreSQL quote comes from 13.3.2 "Row-Level Locks" and omits "Row-level locks are released at
   transaction end" (fable). A citation nit.

**Required inputs to G's text round** (evidence, not voted):
- the never-reused value;
- the comparison and the `FOR SHARE` in the same transaction as the protected write;
- an explicit startup-advance timeout exit, non-zero and alarmed;
- `OPS-15`'s exceptions in the takeover sweep;
- the (f) list;
- the new ADR stating the reversal of `ADR-0019`'s rejection;
- the residual dispatch window stated plainly.

## Q3: Fence A

**The truncation is checked, and it does not void Q3.** Q3's opening sentence is missing (brief.md:340 begins
"exits at once. It also amends…"), and all four reported it. r65/brief.md:249-251 defines A: "Before its first
record after the loss, E1 takes `STO-51`'s lock again, once, on a fresh connection, and holds it until exit. If
that is refused, or the lock is lost again, E1 exits at once." The four readers reconstructed it as follows:
- opus: "re-take `STO-51`'s lock on a fresh connection; if that works, record under R; if refused, exit at once"
  (matches);
- astra: "a fresh-session reacquisition attempt before recording, refusal causing immediate exit" (matches);
- sol: "successful reacquisition retains the new session lock through recording" (matches "holds it until exit");
- fable: traced "A re-acquires; E1's own unreaped session refuses it … E1 exits" (matches).

No reader restated "or the lock is lost again, E1 exits at once". That clause only adds refusals, so it can only
strengthen DON'T ADOPT. All four voted on r65's A.

| Reader | Vote | Sound | Under G |
|---|---|---|---|
| fable | DON'T ADOPT | NO. Trace: after a transport blip, E1's own unreaped session refuses A, so E1 exits with a working store and no second engine, losing S1's settle write, which `OPS-22`'s guard admits and `OPS-21` says "MUST be recorded". Baseline R | moot |
| opus | DON'T ADOPT | YES for stale writes; NO for "refuses a record it should admit", measured against R (the same blip trace) | moot |
| astra | DON'T ADOPT | YES as a reacquisition checkpoint (soundness against its own contract, usefulness against R) | moot |
| sol | DON'T ADOPT | YES as the proposed checkpoint, with refusal added as an exit to R | moot |

**DON'T ADOPT 4-0. Moot under G 4-0.** Q2 is consensus ADOPT, so **Q3 is recorded as moot**. If the owner
declines G, Q3 stands as **4-0 DON'T ADOPT**. A is out either way.

The 2-2 split on soundness is about the baseline, not the facts. All four agree that A blocks no write the
`OPS-22`/`OPS-15` guards would refuse. All four agree that the writes it does block are correct records: after a
blip E1's own session refuses it, and in S5 so does E2. Fable's line all four can sign: "(1) A refuses no write
the guards wrongly admit; (2) against R it costs correct records; (3) against E it is never worse."

The strongest arguments against each reader's own position on A (rule 7, not votes): A is conservative when two
engines write (fable); it restores "one engine writes" whenever a successor exists (opus); it adds a fresh
exclusivity check (astra); it is a current ownership checkpoint (sol). Each reader answers that the guards
already pick the winning record, and that A's only extra effect is the refusal after a blip.

**Brief error reported for Q3, verified:** the quoted r65 line "it succeeds only after an in-place restart" is
false (astra, sol). `STO-51` says the lock is "released when its session ends" (05:90), so terminating or reaping
E1's old backend is enough. This was a reader's quote, not a premise of the vote, and all four still DON'T ADOPT.

## Bead candidates for the assistant (behaviour; NOT filed)
- **`OPS-22` worker vs engine exit on a zero-row record** (from r65; still open). `ADR-0022`:40-41 and `CNF-290`
  say the engine exits; `OPS-22` (03:1826-1828) says the worker does.
- **No named writer for automatic non-create resolution** (from S3). The flowchart (03:455-463), `OPS-45`
  (03:1472-1474) and `PRV-29` describe automatic resolution by provider evidence. 03:95-96 and `OVR-17` (00:295)
  name only `OPS-27`'s correlator sweep or the operator.

## Owner relay (no split; two confirmations, as the panel's recommendation)

**TL;DR.**
1. **The story.** The database restarts in place for 20 seconds while a create's "it worked" write is retrying.
   The restart also drops the engine's startup-lock connection. Under **R** the engine finishes that write
   (`succeeded`, money posted once) and then exits. Under **E** it exits at once, and the create waits in
   `needs_reconciliation` until a sweep or an operator resolves it. A delete with an accepted dated cancellation
   would need an operator. No second engine is involved.
2. **Options.**
   - **R, record first: panel pick, 4-0.** E reads 4-0 ACCEPT but is not picked.
   - **Fence G: ADOPT 4-0.** G puts one generation value in the database. Every engine write checks it, and a
     takeover changes it, so an engine that has been replaced can no longer write. G is the "guard on the shared
     epoch" option that `ADR-0019` rejected only as out of scope, so adopting it reverses that rejection (4-0).
   - **Fence A: dropped** (moot under G; 4-0 DON'T ADOPT without G).
3. **On a misconfiguration (a second engine started by mistake).** E2's boot check refuses it and it exits,
   unless E1's lock connection drops while E2 is retrying.
   - **Without G:** before E1 notices the drop, both engines claim and call providers. After it notices, R
     records E1's rows and E strands them until E2 restarts; under E the non-create rows also block their
     machines.
   - **With G:** from E2's takeover on, every E1 database write is refused, and E1 exits at its next write.
   - **What G does not fix:**
     - A provider call licensed by a write that committed just before the takeover still goes out (for
       example, an order placed after step 8). That row goes to `needs_reconciliation`.
     - G needs a never-reused value, or a restore with a surviving engine defeats it.
     - G does not protect against two writable database copies. `STO-54`'s promotion rule still has to hold.
4. **Costs.**
   - R: a few more spec sentences and one `CNF`.
   - G:
     - a hot-row share lock in every engine transaction;
     - a takeover that can wait on a partitioned E1;
     - correct outcomes discarded after a takeover;
     - new exits, `CNF` cases and Lean work;
     - a reversed ADR;
     - its own drafting and reading round before any Run.

**The question:** "R, plus Fence G (reversing `ADR-0019`'s scope), with A dropped: yes?"
