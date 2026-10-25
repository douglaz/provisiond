**Q1. CANNOT ACCEPT G's text** (sound in design; five spans need replacing, three of them gate-level).

**Defect 1 — `OPS-50`'s universal covers the advance itself.** `OPS-50`: "Every write transaction made in the engine process … MUST read `STO-59`'s row `FOR SHARE` as its first statement". `OPS-15` new paragraph: "The pass's first transaction MUST begin by replacing `STO-59`'s startup generation." Trace: the engine starts; its first transaction's first statement cannot be both, and before the pass writes there is no value to compare. Gate: two MUSTs, one trace. Replacement for the `OPS-50` opening:

> Every write transaction made in the engine process, other than the generation write that begins `OPS-15`'s pass — a claim (`OPS-5`), …

**Defect 2 — `STO-59` anchors the restore's fresh write to step (3).** `STO-59`: "the restore procedure (`STO-54`, `STO-56`) MUST write a fresh value, as it bumps every tenant's credential generation." That bump is `STO-54` step (3), "*Before the first `api` request*", after step (2), which the engine's own pass performs. Trace: E1 starts (V1); backup; no restart; restore from that backup; E1 survives and reaches the restored store before any engine starts; its `FOR SHARE` reads V1 = its own; the write commits on restored state. Gate: a stale write admitted. Replacement for that sentence:

> the restore procedure MUST write a fresh value in the transaction that commits `STO-56`'s record, of which `STO-56` says it is "written into the restored or promoted store before either component is started"; the credential-generation bump of `STO-54`'s step (3) is the same idea, later.

**Defect 3 — `CNF-370` is vacuous for the write `STO-59` requires.** "Backup, then a startup advance, then restore with a surviving engine": after the advance the survivor holds V2 and the restored row holds V1, so it is refused whether or not the restore writes anything. Gate: `CNF-370`. Replacement:

> **`CNF-370`** — Start an engine; back up; keep it running with no restart; restore from that backup with the engine surviving and reaching the restored store before any engine starts on it. Assert the restore wrote a fresh value before either component started (`STO-56`), the survivor's next write is refused and it exits non-zero, and every value ever written to the row is distinct.

**Defect 4 — `CNF-368`/`CNF-369` are unreachable as written.** 05:1428 orders "the engine before `STO-51`'s startup lock and so before `OPS-15`'s pass", so a successor started while the first engine holds the lock never reaches its advance; a conforming successor waits the wait bound and exits, failing "its advance waits". Gate: `CNF-368`, `CNF-369`. Replacement preamble for both:

> With no engine holding `STO-51`'s lock, and a harness transaction holding `STO-59`'s row `FOR SHARE` with a settled-state write of a `running` row uncommitted, start an engine: its advance waits; commit the harness transaction; assert the pass does not move that row and the advance commits after it. (`CNF-369`:) Hold it past `OVR-19`'s Startup-lock wait bound instead: the engine logs loudly and exits non-zero having claimed nothing.

**Defect 5 — two unamended spans quote words G deletes** (AGENTS.md's quote rule; not gate-level). 03:415-416: "This describes their predicates, not an in-scope second engine: `STO-3` says "nothing contends with it"." Amendment 11 removes those words from `STO-3`, and G puts the second engine's writes in scope. Replacement:

> This describes their predicates; against a second engine both writes make `OPS-50`'s generation check first, and `STO-3` says "no earlier engine's write commits beside it (`OPS-50`)".

10:1519-1521: "What this drill must not be read to prove is that a second engine cannot write: `OPS-47` says "where two engines run, nothing here refuses the second, and both will work the queue"." Amendment 12 misses it. Replacement:

> What this drill does not prove is that a second engine's provider calls stop: `OPS-47` says "provider calls the first already licensed still go out" (`OPS-50`).

**Id list.** Missing: 03:415-416 and 10:1519-1521 above. `OPS-47`'s unamended "a node cut off from its supervisor while it still reaches the provider is out of scope" now half-contradicts amendment 1; suggest "keeps only the provider calls it already licensed (`OPS-50`), and those are the operator's to notice". `OPS-49`'s bullet "A `lock_timeout` is a store error for this purpose: on `LDG-35`'s primitive or on `STO-52`'s index" gains a third site, the `FOR SHARE` on `STO-59`'s row, so a worker timing out behind the advance repeats and then sees the new value. `OPS-50`'s enumeration omits `OPS-8`'s defer (`STO-3`'s fifth write); the universal covers it, add it. `OVR-19`'s row is "Startup-lock wait bound", not "retry bound", in `OPS-15`'s paragraph and `CNF-369`. `OPS-15`'s paragraph should say the advance is a transaction of its own, committed before any sweep write; "the pass's first transaction MUST begin by" lets the sweep share it, which holds the exclusive row lock through the sweep and puts the sweep's `LDG-35` waits under the advance's `lock_timeout`. `CONTEXT.md`:520-527's pointer should say why G is not the epoch: the row has a second writer, the next pass and the restore, which is `OPS-6`'s own test. `CONTEXT.md`:108's "generation (that is the startup generation)" collides with `STO-54`'s "credential generation"; write "generation (the startup and credential generations are other things)". `ADR-0022`:92 says the old `OPS-47` words "stay true"; a dated note. The pointer list is otherwise pointers, not behaviour. No engine write path escapes the universal; the meter's driver call in engine (`OVR-17`) is covered by "made in the engine process", not by the enumeration.

**CNF items.** `CNF-367`: after the first refusal the engine exits "beginning no other transaction", so "drive each … writer" needs "each in its own run, with a fresh out-of-band write". `CNF-368`/`369`: Defect 4. `CNF-370`: Defect 3.

**Lean.** `Claim.lean`:14-24 header says the model omits "a second engine"; it must change with the guard. `StopRecord.lean`: `Event` (:28), `schedule` (:46), `schedule_bounded` (:121), `later_stop_exits` (:201), `money_posts_at_most_once` docstring "both stop events" (:281), `finished_unrecorded_exit` (:395) with `selection` a `have` at :408 whose `cases e` splits are the three named. All exist; `lockLost` does not, as expected.

**Q2. CANNOT ACCEPT R as written on one span; ACCEPT with the replacement below.**

**Open point: yes.** "where the connection carrying it is lost, the engine MUST claim nothing more" is broken by a claim between the backend's death and keepalive detection, which no engine can avoid. G does not change the answer: with no takeover nothing refuses that claim, and the window matters exactly when no successor exists. The `CNF-366` fix is right in intent but asserts "as its loud log timestamps the detection", and R requires no log at detection. One replacement fixes both:

> where the connection carrying it is lost, the engine MUST, from the moment it detects the loss (`OVR-19`'s keepalives bound it), log loudly that the lock is lost, claim nothing more and begin no periodic pass, treat the loss as a stop of every worker not already recording one, record each under `OPS-21` within its Stop-record bound and exits, and then exit non-zero.

**Contradictions with G:** none of substance. `OPS-21`'s added "A record that `OPS-50`'s generation check refuses ends there, unlanded" sits beside R's "The loss is not a later stop" consistently: the loss starts records, a takeover ends them. One word clash: `CNF-366` (v) "With every transaction refused after the loss" means `OPS-49`'s "A server-side timeout is a refused write", while `OPS-50` now says "refuses" for a mismatch that exits at once. Write "every transaction a store error after the loss". Around R: `OPS-47`'s unamended "It answers one question, once, at boot" sits awkwardly beside a loss that is a stop; append "and its loss afterwards is a stop (below)".

**Brief errors.**
- "checked with `grep -F`": 11 of 14 before-spans return 0 with `grep -F` on the files at `d78085a` because they wrap; all 14 match on newline-flattened text. No span is wrong.
- `OVR-19`:399 names "Startup-lock wait bound", not "startup-lock retry bound".
- Span 6 is at 03:355-356; span 1 starts at 03:137.
- Lock-order argument: "the advance holds nothing but the generation row" holds only if the advance is its own transaction, which the text does not say. The argument also omits the fact that makes a write never wrongly refused: 05:1428 "the engine before `STO-51`'s startup lock and so before `OPS-15`'s pass", so a refused second engine never advances. State it in `OPS-15`'s paragraph.
- Restore argument: "a restore writes a fresh one before the store serves anything" is the intent, but the drafted anchor is step (3) (Defect 2).
