# Panel D, r65b: pv-buc

## Q1

**R: ACCEPT. E: ACCEPT.** Neither form flips a CNF verdict or a theorem. E's one wording problem is its placement, covered below, and it doesn't block.

**Pick, without G: R.** Cases S1–S4 need no misconfiguration, only a database blip or an in-place restart. Under E, whether an outcome already in hand survives is then decided by the keepalive row (`OVR-19`), which is the infrastructure setting the owner distrusts.

After detection, R starts no new provider mutation:
- every worker is cancelled, and `OPS-21` says it "MUST NOT repeat it or begin anything it precedes", which covers step 9 after step 8;
- only the two absorbed reads continue, and both are reads.

So R's extra activity is guarded store writes and nothing else. E also weakens `finished_unrecorded_exit`, against `ADR-0044`:95 ("No existing theorem is weakened").

**Fixes 1–9: all right.** One non-blocking note on fix 6: an outside tester cannot see "the loss as the engine sees it" unless the loud log timestamps the detection.

**E's placement (open point): wrong**, for the same reason as correction 4. Put E's sentence after 03:1770, where it no longer splits 1766 from 1767.

> `OPS-21`, after “…`OPS-15` classifies the row as interrupted”.” (03:1770): “A loss of the connection carrying `OPS-47`'s startup lock ends a pending record as an exit without worker classification at any point: before the record's first transaction, during it, or while `OPS-49` repeats it. After the loss is seen the worker MUST NOT begin or repeat a record transaction; a transaction already sent is the server's to decide, and a row still `running` goes to restart recovery (`OPS-15`, including its exceptions).”

Optional for E, to match R's `OPS-49` pointer:

> `OPS-49`'s retry-loop bullet gains: “`OPS-47` says a lost lock connection means “it MUST exit non-zero at once”: a worker repeating a transaction when the loss is seen stops repeating.”

**S5, worker reading.**
- **R:** every post-pass row is recorded, because its guard has no contender. Zero-row records of pre-pass rows end only their own workers, and E1 exits after the last record.
- **E:** post-pass rows still unrecorded at detection stay `running`. Those with `yielded_at` null block their machines until E2 restarts.

**S5, engine reading.**
- **R:** E1 exits at its first zero-row write on a pre-pass row. Post-pass rows unrecorded at that moment strand as under E. That write can come *before* detection, and then R and E behave identically.
- **E:** as under the worker reading, or earlier, by the same zero-row exit.

**Against my pick (on request):** R keeps a process writing for up to the Stop-record bound after it knows it is no longer alone, beside a successor that believes it is. E's "exit at once" is the simpler rule and keeps "once, at boot" exact. Its losses are detours through `needs_reconciliation`, which existing resolution already handles.

## Q2: ADOPT G, with one repair

**Sound: NO as sketched; YES with the repair.**

The trace:
1. A backup is taken while the generation is 5.
2. E1 starts later and advances it to 6.
3. The store is restored from that backup (generation 5) while E1 survives. That is the misconfiguration `STO-54`'s "MUST stop every engine" guards against.
4. E3 starts on the restored store, advances 5 to 6, and sweeps.
5. E1 reconnects and reads 6, which equals its own value. It claims and writes beside E3, so a stale write is admitted.

**Repair:** "the pass writes a value never written before (a fresh UUID); every check is equality." There is precedent: the credential generation "is bumped" on a restore (05:1550) for the same reason.

- **(a) Yes.**
  - A guarded write that committed just before the advance licenses every dispatch after it, up to the next write.
  - Step 9 is "Perform the per-order key upload, then the order": two mutations after one step-8 write.
  - An install runs its whole destructive phase after one marker.
  - End-rescue is dispatched with no write just before it.
  - Temporary-key deletion (`PRV-9`, `PRV-18`) is the same.
  - G narrows r64b's window to each worker's in-flight phase. It does not close it.
- **(b)** E2 reaches the advance only after it holds the advisory lock, so E1's lock session is already gone. In S5's in-place restart every E1 session died, so there is no wait. A wait exists only where E1's pool sessions outlive its lock session, as in a partition. PostgreSQL 18 says "a transaction seeking … a row-level lock will wait indefinitely for conflicting locks to be released", and "Row-level locks are released at transaction end". The wait is therefore bounded by:
  - `STO-7`'s server-side timeouts, which E1 sets itself;
  - the server reaping dead peers through keepalives;
  - E2's own `lock_timeout`.

  `OPS-49` covers workers and periodic components, not the startup pass, so G must say what E2 does on a timeout: exit non-zero, alarmed.
- **(c) For safety, yes:** the database, plus every write path carrying the read, which is an implementation obligation a CNF item can check, plus the repair. For liveness, timeouts matter, but a wrong setting gives an alarmed stall, not a stale write. G does not reach the provider at all (see (a)).
- **(d) Yes, extended.** `ADR-0016`:25: "At startup the engine increments a single `engine_epoch` row and holds the value". The option rejected at `ADR-0019`:78 checks the claim against that shared row, which has a second writer, the next startup. That is not the self-stamped `operations.epoch`, so r65's two-reader split mixed up the deleted mechanism with the rejected option. G is that option, widened to every write, plus `FOR SHARE` ordering. `ADR-0019` rejected it only on scope ("Correct, and cheap"), and scope is exactly what the owner's preference reopens. The new ADR must say it reverses that rejection.
- **(e) No.** G removes S5 only. S1–S4 stand.
- **(f) Add:**
  - `OPS-6` (03:176-177) and the prose at 03:1733-1735;
  - `OPS-15` (03:413-414) and `OPS-5`, both confirmed;
  - `STO-1`, and `STO-3`'s startup-pass bullet (05:49, "nothing contends with it");
  - `OPS-49` (a mismatch exits rather than repeating) and `OVR-17`/`OVR-19`;
  - `OPS-42`'s machine-row writes;
  - `STO-54`/`STO-56` (the repair);
  - `CNF-290` (10:1515);
  - `Claim.lean`:23;
  - `ADR-0016`, `ADR-0022` (:9, :92) and F46;
  - a schema row (`STO-51` says "It carries no row");
  - `CONTEXT.md`:108, which lists "generation" under *Avoid*, and :520-527.

## Q3

**Against my own position:** Without A, R lets E1 write beside a live E2 whose boot answer is wrong. A restores "one engine writes" whenever a successor exists, and never ends worse than E.

**My answer:** every write A stops is a record already guarded by `OPS-22`'s claim number and status and by `OPS-15`'s `(id, status = running)`. So A blocks no write the guards would refuse, only correct ones. And after a blip, E1's own unreaped session refuses A, which turns S1–S4 into E with no second engine anywhere.

**DON'T ADOPT A.**

**Sound:** for stale writes, YES, since A only adds refusals. For "refuses a record it should admit", NO, measured against R, because A amends R. The trace:
1. A network blip leaves E1's lock backend half-open on the server.
2. E1 sees the loss while S1's settle write is repeating.
3. A's re-take is refused by E1's own session (`ADR-0019`: "A session advisory lock survives its holder…").
4. E1 exits. The settle write, which the guard would admit and which records `succeeded`, is lost, and the row goes to `needs_reconciliation`.

**Under G: moot.** After a takeover, G already refuses every E1 write. Without a takeover, A's only effect is the blip refusal.

## Brief errors

1. **Q3 is truncated.** It opens mid-sentence ("exits at once. It also amends…"), so A's mechanism is never stated. I voted on this reading: on seeing the loss, re-take `STO-51`'s lock on a fresh connection; if that works, record under R; if refused, exit at once.
2. **G's "With G" trace.** "the marker mismatches … so no order is placed" holds only if step 8 had not yet committed (see (a)). The column is also not a marker: `OPS-45` says "The column is not a marker".
3. **G sketch, item 5.** Not every swept row "go[es] through `needs_reconciliation`". `OPS-15`'s exceptions apply: refresh goes `failed`, a create with a null column goes `failed`, and the parent returns to `queued`.
4. **S3.** `PRV-29`'s normative text names no writer at all; the operator appears only in its withdrawn-text note. Two passages describe automatic resolution for kinds other than create:
   - the flowchart (03:455-462) routes them to "Read provider evidence, PRV-29", with automatic outcomes, and 03:500 says "The red boxes are where a human is required";
   - `OPS-45` (03:1472-1474) says resolution "proceeds by PRV-29/PRV-36's provider evidence where the driver can produce it".

   But 03:95-96 and 00:295 tie the sweep to the create correlator. So this is a gap where the text contradicts itself (described, with no named writer), not "ends with an operator". R's advantage in S3 is unaffected.
5. **The line before S1** ("needs_reconciliation under both").
   - Refresh is `failed` under both ("Always `failed`", and `OPS-15`'s refresh exception).
   - An install or rescue inventory before its write-started marker, with no rescue session open, settles `failed` under R (`CNF-362`) but `needs_reconciliation` under E.
6. **Missing case.** S1–S5 leave out a create stopped between step 8's acknowledgement and step 9. Under R it is `failed` (`OPS-11`'s create row). Under E it is `needs_reconciliation`, because 03:238 says "A restart in that same window takes the ordinary path". It needs no misconfiguration.
7. **S5 under R, "provider calls outstanding continue".** R cancels them ("A provider call abandoned mid-flight"), except the two absorbed reads. Only the provider's side of a call already sent continues, and that is the same under E.
8. **"No infrastructure setting has to be right".** True for safety only after the repair; the restore trace above breaks the sketch as written.
9. **Unverifiable here.** The r64 and r65 votes and quotes can't be checked: `docs/research/panels-2026-10/` stops at r63. That makes them unverifiable, not wrong.

All other quotes and line references I checked match `b90783d`. I edited no files and ran no gate and no `lake`.
