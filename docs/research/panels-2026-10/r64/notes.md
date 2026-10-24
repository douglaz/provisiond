# r64 manager notes (panel D: pv-buc, pv-9j6), verified at master b90783d, 2026-10-23

Status: claims VERIFIED, brief NOT written, readers NOT launched (the previous manager hit its context stop line).
A fresh manager writes brief.md from these notes in the r63 format (/var/tmp/provisiond-panel-r63/brief.md) and launches.

## Verdict on the beads: both live, neither cosmetic, neither resolved on master

- pv-buc: no sentence anywhere governs a stop's record when OPS-47's lock connection drops; no CNF item drives a
  lost lock connection at all (CNF-290 drives only a *refused* lock; CNF-362 drives no lock loss).
- pv-9j6: OPS-45 says failed; OPS-11's last row and Tables.classify say needs_reconciliation for an ambiguous kind.

## Stale or changed since the beads were filed

- pv-buc predates PR #23. Two new facts bear on it:
  - 05:151 (ADR-0045) "A sent COMMIT is never abandoned ... short of its process exiting".
  - 05:1507-1508 "Before any component connects to the promoted store, the deployment MUST stop every engine and
    `api` process that was connected to the old primary". Lock loss is now routine on every failover, and the
    deployment's stop arrives with it.
- pv-9j6's line refs (r57's 03:1380 and so on) have moved. Every claim still holds verbatim.
- ADR-0019:55-59 restates OPS-47's "where the connection carrying it is lost it MUST exit" and gives no reason
  for it. If an option deletes the clause, the brief asks the readers what the clause protects. Candidates:
  STO-56's "once per process" record read; the boot check staying true for the process lifetime.

## Line refs (b90783d)

pv-buc:
- OPS-47 03:135; lock-loss exit 03:145-146 "where the connection carrying it is lost it MUST exit"; 03:146-147 "The
  lock is not a fence ... losing it invalidates nothing already written".
- OPS-21 03:1738-1740 "MUST be recorded before the engine exits ... subject to the bounded abandonment and later-stop
  exits below". The exits: later stop 03:1766, Store-retry exhaustion 03:1769-1770, Stop-record expiry 03:1775-1777,
  supervisor wait 03:1781-1782. After-return record 03:1799 and 03:1804. `grep -c -i startup` over 03:1738-1818 = 0.
- OPS-49 03:1833; "A worker cancelled during the retry loop stops retrying and exits" 03:1868.
- STO-51 05:88. Worker pseudocode 03:1685-1700. Parameters 00:399-402 (startup-lock wait bound, startup-lock
  connection keepalives, Store-retry bound, Stop-record bound).
- CNF-362 10:1608. CNF-290 10:1502.
- StopRecord.lean: Event = store | serialization | laterStop (:28-32); schedule :46; later_stop_exits :201;
  exit_store :328; finished_unrecorded_exit :395. Module doc: "No provider call, restart, fan-out or competing
  execution runs here."

pv-9j6:
- OPS-45 03:1403. Scope 03:1411-1412 names install, rescue inventory, power, reverse DNS, delete, release
  attachment. Marker row 03:1437 "the provider call is dispatched". Settlement 03:1466-1472: "This rule classifies
  a failure a worker recorded"; "Everything else follows `OPS-11`'s classification".
- OPS-11 03:223. Last row 03:233 "`needs_reconciliation` if the failure is *ambiguous*, otherwise `failed`" (no
  marker). Cut-off conflict ambiguous 03:270-271. Acceptance amendment 03:278-284.
- OPS-21 03:1757-1761. Its pointers name create, install, rescue inventory and refresh only. "The kind's row owns
  the outcome, including where it reads ambiguity." "Where the row reads `OPS-45`'s markers, the record MUST classify
  against the markers its own transaction reads". Under option A this sentence starts to reach the four kinds.
- 05:421 write_started_at row: "with the column below makes the failure deterministic rather than ambiguous
  (`OPS-11`)". This is a second copy; 05:422 says "(`OPS-45`, which owns the rule)".
- CNF-31a 10:205. CNF-31b 10:223 asserts a last-row pre-send `network` failure is needs_reconciliation; the
  marker is written before dispatch, so that case is unaffected. CNF-362 10:1615-1617 scopes the four kinds to
  "stopped during their provider call after dispatch", so it avoids the pre-dispatch case.
- Tables.lean: classify :189-198 (power, delete and release go to goalState/mutationRow, reverseDns to
  mutationRow, and none reads Markers); installRow :166.
  - **accepted_never_failed :256-259 quantifies over every marker pair ⟨w,x⟩ for the lastRow kinds.** A marker
    arm without a `!f.accepted` guard returns failed at w=false, accepted=true, so the theorem goes red. Draft A
    must guard on acceptance, as the create arm does at :197. A pre-dispatch failure cannot carry acceptance.
- Rescue.lean: governs :463 includes the four kinds. classifiedUntouched :692. The seam theorem :698 reaches
  installRow only.
- Precedent: r58 synthesis :179, "pv-9j6: decide separately, 4-0 ... a recorded pre-dispatch `timeout` or
  `internal` shows the same `OPS-45`/`OPS-11` disagreement"; r57 synthesis :176.
- retryable: the create row pins `retryable: true`. CNF-362 says "Make no assertion about `retryable` for the
  other cases" (install). WIR-9b owns precedence. Ask whether A needs a retryable rule.

Next free ids: CNF-366, ADR-0046.

## Option sketches for the brief (not yet panelled)

Q1, pv-buc. Story: a deploy stops the engine. A create's `execute` has returned success, and its settle write is
repeating under OPS-49. The lock connection drops (a PostgreSQL restart). Engine A exits at once: the row stays
`running`, OPS-15 parks it, and the correlator resolves it. Engine B lands the write within the Stop-record bound:
`succeeded`, money posted once.
- A: lock loss is a listed exit, like a later stop: no classification, a sent transaction is not repeated.
  StopRecord's laterStop covers it, or a lockLost event does. CNF-362 gains the case.
- B: lock loss is a stop of every worker. The engine claims nothing more, records under OPS-21 within the
  Stop-record bound and its exits, then exits. Check B against 05:1507.
- C: delete OPS-47's lock-loss exit, and ask what it protects.
- Sub-question: does the rule also govern a lock loss with no stop, while workers are in `execute`?

Q2, pv-9j6. Story: a delete is cut off before dispatch, a recorded cut-off `conflict`. A second story is a
pre-dispatch `internal`.
- A: OPS-45 governs. The last row gains "and `failed` for any failure the worker records while OPS-45's
  write-started marker is unset". classify becomes: goalState first, then
  `markerRule && !writeStarted && rescueClean && !accepted` → failed, else mutationRow. CNF-31a, CNF-31b and
  CNF-362 assert it.
- B: OPS-11 governs. OPS-45's settlement and 05:421 narrow to install and rescue inventory. The marker stays as
  resolution evidence.
- D (add-on): delete 05:421's restatement.

Gate: a CANNOT ACCEPT names a loss that changes a checked verdict.
That is a CNF assertion or Lean theorem the form flips, makes unreachable or makes vacuous, or a MUST with a trace.
List those verdicts by id. Plus r63's outcome rules 1-7 (/var/tmp/provisiond-panel-r63/notes.md).

## Outcome rules (fixed before launch, 2026-10-23)

r63's outcome rules 1-7 (/var/tmp/provisiond-panel-r63/notes.md) apply per question (Q1 pv-buc, Q1b, Q2 pv-9j6),
with rule 3's test replaced by the gate: a CANNOT ACCEPT names a checked verdict the form flips, makes unreachable
or makes vacuous (CNF id or Lean theorem), or a MUST with a trace. Q1's open "what does the clause protect"
answers are evidence for C, not votes. Brief: /var/tmp/provisiond-panel-r64/brief.md.
