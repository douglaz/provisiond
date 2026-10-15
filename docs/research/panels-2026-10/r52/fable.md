Gates at `74ad5f7`: all pass, exit 0. Clone left clean.

## 1. Is the finding real?

Partly. The crash trace is settled by existing rules; only two words are not.

- Crash after the read, before commit: `OPS-15` moves the `running` create to `needs_reconciliation` (03-operation-lifecycle.md:347-352). `OPS-27` searches the correlator and "MUST follow a match with *get machine*" (03:481), then lands the create through entry point 2 or 3 (03:515-519). The Q31 sentence puts the column write in that transaction "at every entry point" (03:540), and `CNF-356` makes the landing pass read there (10-conformance-checklist.md:3649).
- The "no durable home" premise is the spec's chosen crash model, not a hole. `STO-55` forbids a transaction across any provider call (05-persistence.md:143), so every read's result lives only in memory until commit. `OPS-49` names it: "the outcome in hand is thrown away and `OPS-15` classifies the row as interrupted" (03:1582-1585). The confirming read sits in the identical window and resolution simply repeats it; nobody calls that a retry.
- What is unanchored: `PRV-13c`'s "once" and "MUST NOT be retried ... MUST NOT read ... again" (02-provider-contract.md:593, 601) count from no durable event. A literal reader writes null; an `OPS-49` reader re-reads. The text must pick. Note that `CONTEXT.md:111` defines **Retry** as an operator act, so "retried" here is already an overload.

## 2. Fixes

- **(a) lost result = failed read.** Not implementable as two lines. Recovery cannot tell a lost read from one never made (crash before the order reply, or before the confirming read). To honour "no re-read" it must skip the read on every interrupted create, writing null where nothing failed, and must branch on interrupted-vs-classified provenance (03:1300-1301). It also contradicts `CNF-356`:3649 unless that line is narrowed to the lost-reply path. It extends Q31's "failed read of any kind", which `PRV-5` defines as a returned failure, to a thrown-away success. That is a new owner decision.
- **(b) durable attempt record.** `OPS-45`'s marker exists because a disk write cannot be re-established by reading; a read can. Rejected.
- **(c) re-read at landing.** Already what `OPS-27` does with the confirming read. Cost: a restart loses at most the engine's worker count of in-flight reads, each worker holding one operation (`STO-55`), against 200/hour on `GET /server/{n}/cancellation` (08-provider-notes.md:469) and 20 orders/day/endpoint (`ADR-0036`). Restarts are alarmed (03:153-154).
- **(d) the spec already supports (c).** Anchor "once" to the landing: *the pass that commits the landed-order transaction reads once, after its confirming read; after that commit no pass reads again; a result an interrupted worker held is thrown away with the rest of its outcome (`OPS-49`), as the confirming read's is.* This is Q31's own "once, when the create settles": the crashed worker's create never settled. No owner decision needed. Replace "retried" with "repeated".

## 3. Sweep: one more defect of the same weight

`PRV-13c`:597 "On failure, the declared bound MUST remain the priced term" has no home. `LDG-33`'s formula prices only "cost through any future permitted-from date" (12-billing-and-ledger.md:352); it has no declared-bound input, and the `PRV-31` quote offered as support is about the commitment, not `protected_sats`. `CNF-356`:3642 asserts the bound-priced term is zero, true only because the v1 bound is today. Q31's own panel note ("a failure leaves the column null and `LDG-33`'s term prices nothing") names the gap the decision meant to close. Fix: one clause in `LDG-33`'s formula line, "or the offer's declared bound (`PRV-31`) where the column is null"; `PRV-13c` quotes it.

## 4. Recommendation

Fix (d) and the `LDG-33` clause, add the crash case to `CNF-356` (crash after the read; assert the landing pass reads and records the date, two reads total), then merge on the next clean gate. Both are short, both are text a careful reviewer reaches next, and (d) is the owner's own first-principles move: no new rule, the existing crash model applied.

## 5. Strongest case for the other side (written on request)

(a) is the conservative reading of Q31's threat model: "one per delivered order" was a counted cost, and (d) makes it "one per landing", which admits a repeat on every restart with creates in flight. A null column is already a fully specified, tested state with a cancellation-response repair path, and the v1 term is zero, so (a) spends nothing and risks nothing; (d) spends counter and reopens the `/server` budget argument that produced Q28 and Q31. The provenance branch (a) needs is one `OPS-15` fact the record already carries. If the owner values a fixed count over a repeated read, (a) plus the `CNF-356` narrowing is the smaller promise.
