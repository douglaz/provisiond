I have all the facts; writing the review now.

**Verdict.** Triage right on mechanism, wrong on path: at dec039f the listing never runs on v1's only provider, so the leak is the ordinary delete, not a throttle accident. Delete the post-mortem listing; write rows from the machine read, enqueue the release at the gone-write.

**Q1, the trace.** Throttled listing after a 2xx: `OPS-11`'s fourth bullet at 03:270-275 classifies it `needs_reconciliation`, not `failed`. The next complete sweep pass records the machine gone at 03:1343-1346, closes the episode under `OPS-48`'s last row at 03:1081, and tombstones it because `STO-18` at 05:357 keys only on rows and none exist. `LDG-74` at 12:569 says "The row is tombstoned when `STO-18` allows". `LDG-32` at 12:308-310 closes vacuously. That transaction is where the attachment becomes invisible. The operator's later `applied` lists nothing: `WIR-35` at 13:889-896 carries no listing, and `PRV-45` at 02:548 says resolution "does not record the machine gone".

Provider-terminated: same gone-write, same tombstone, no listing on any trigger in 12:527-532. `LDG-74` at 12:572 calls it "the ordinary case" and then tombstones it.

Scheduled: `OPS-48`'s third row at 03:1072 closes "in the transaction that tombstones the machine at the effective date". `PRV-45`'s condition at 02:528, "every delete that succeeds with the resource gone", is never met. ADR-0037 at line 151 says "Robot's `now` returns a date, which names the end of that day", and `PRV-45` at 02:544-546 repeats it, so every Robot delete is `cancellation_scheduled` under `DOM-19`. ADR-0034 at line 112 says "v1 sells only Robot". So the listing runs on zero v1 deletes.

Your other claims check: `OPS-32` at 03:1368-1377 visits only retained machines and writes only `released_at`; `API-65` at 04:1093 admits only an existing row; ADR-0035 at line 79 excludes this case.

One latent defect you did not list: 03:1072 and `Tables.lean:350,449` make the scheduled machine's tombstone its gone-write, which `LDG-74` at 12:564 forbids ("MUST NOT be collapsed"). Harmless today only because no scheduled machine ever has rows.

**Q2, the threat.** No adversary is needed. ADR-0037 Q18 at lines 160-161 sold `primary_ipv4` offers on the premise "A surviving one is operator rent until its `cleanup: api` cancellation". At dec039f no path dispatches that cancellation on Robot, so the premise is false and every honest delete leaks the add-on, conditional on step 9. An attacker pays ADR-0033's prepaid hour on an auction box with no setup fee per 08:155-158. The operator pays the add-on "per day or part thereof" per research 589, with no end date and no alarm. Rate is bounded by Robot's order throughput, "up to twenty a day per account" per ADR-0035:54; duration is unbounded.

**Q3, the fix.**

- (a) Retain until listed: a new `machines` column, conjuncts on `STO-18` and `LDG-32`, and a sweep that inserts rows and enqueues, contradicting 03:1374 "This does not dispatch a release mutation". Unsound on Robot: a post-gone per-machine listing must find IPs by `server_number` in `GET /ip`, and whether a cancelled server's IPs keep that link is exactly step 9's unknown. A complete empty listing then releases the gate over a live orphan.
- (b) Account diff: an unknown orphan can only be reported, since auto-deleting unrecorded resources is the remedy `OPS-32` at 03:1413 refuses for machines. Reporting is the manual step the owner rejects.
- (c) Listing on every gone path: does not survive a failed listing without (a)'s retention, and shares (a)'s soundness hole.
- (e) Smaller: the engine already reads the server on every authoritative observation. `STO-41` at 05:1234-1236 names them: create, resolution attach, post-action update, refresh. Robot's `GET /server/{n}` already returns "ip (Array): Array of assigned single IP addresses" and "subnet (Array)" per the webservice reference, on the 200/h read the sweep already spares. So rows are upserted from the present-machine read, keyed `(machine_id, kind, external_id)`, and the gone-write transaction, where all three paths converge, enqueues `release_attachment` for each billable `api` row with null `released_at`. Nothing is read after the machine is gone, so no throttle can lose a row. An IP that went with the server answers "already cancelled", which `OPS-11` at 03:289 makes success and writes `released_at`; a dated answer takes Q14's existing path; `OPS-32`'s direct-read absence stays. ADR-0035, Q14, `LDG-32` and `STO-18` need no change: the gone-write records gone and the tombstone waits, which `LDG-74` already says.

**Q4, don't build.** Step 9 costs €0.08 and may show the add-on cancels with the server, making every option dead code in v1. Q18 already rejected the IPv6-only sale. But the text cannot stand: it declares the IP a possible survivor and sells it on a cleanup no path dispatches. Lean today omits attachments entirely, `Funding.lean:141-143`, so nothing catches a regression. It must show: a gone-write over an unreleased billable `api` row enqueues the release and does not tombstone; the scheduled row closes on the gone-write with the tombstone separate; negative control, enqueuing only from the delete's terminal transaction, fails on the scheduled and terminated traces. CNF-65 at 10:313-317 becomes three traces ending in a release at the gone-write. CNF-277 at 10:2150-2153 adds a terminated machine with a surviving IP. CNF-328 at 10:3261 and CNF-347 at 10:3460 replace "listing after deletion" with rows from the last present read plus a direct read after.

**Edits.**

1. `02-provider-contract.md:528-533`: replace the post-delete listing with the upsert from the present-machine read; move the enqueue from "the delete's terminal transaction" to the gone-write.
2. `03-operation-lifecycle.md:1072,1081`: both gone rows enqueue releases; the scheduled row closes on the gone-write, tombstone "when `STO-18` allows".
3. `03-operation-lifecycle.md:1368-1377`: drop the sweep's listing; keep the direct read.
4. `05-persistence.md:333-355`: unique key and the write's new home.
5. `12-billing-and-ledger.md:541-547`: the gone-write also enqueues.
6. `tools/formal/Provisiond/Tables.lean:350,449` and `Fence.lean:941-945` with 03:1072.
7. `docs/adr/0037:160-161`: note the premise now holds.
8. CNF-65, CNF-277, CNF-328, CNF-347 as above; ADR-0035:79 closes.
