# r66 tally (panel D, pv-buc: Fence G's text + Form R read with G), 2026-10-24

Rules: r66/notes.md. Answers: fable, opus, astra, sol (all exit 0; astra engages both questions in full).
Verified at `d78085a` with a whitespace-flattened search over every tracked .md/.lean (file:line below).

## Q1, G's text: **(b) another round.** Tally 0-4 ACCEPT (all four CANNOT ACCEPT).

Blocking defects (gate met; the cited facts verified):
- **B1, startup refuses itself (4/4).** `OPS-50` "Every write transaction made in the engine process … MUST read `STO-59`'s
  row `FOR SHARE` as its first statement, compare it … with the value the engine's own startup pass wrote" vs `OPS-15`
  "The pass's first transaction MUST begin by replacing `STO-59`'s startup generation". Both quotes are the draft; a write
  it should admit is refused on every start; `CNF-368` unreachable. Repairs differ in text: fable "other than the
  generation write that begins `OPS-15`'s pass"; opus "after its startup pass's generation write has committed"; astra
  "Except for `OPS-15`'s generation-replacement transaction"; sol "Except for `OPS-15`'s generation-advance transaction".
- **B2, the advance must be its own transaction (opus blocking; astra, sol inside B1's repair; fable non-blocking).**
  opus: with the sweep in the advance's transaction, a REPEATABLE READ/SERIALIZABLE pass keeps its pre-wait snapshot and
  misses a claim that committed while it waited; the row stays `running` (`OPS-15` "MUST move every `running`
  operation", `OPS-5`). Premise verified: serializable transactions are permitted (`0015`:42, 12-billing:434) and
  serialization failures are expected (03:1859, 03:1862); no text mandates READ COMMITTED. Repairs: opus "MUST replace
  … and do nothing else, and MUST commit before the pass reads any operation"; astra/sol "separate transaction …
  acknowledgement of its commit before the sweep, any claim, or any periodic component".
- **B3, restore write anchored to the wrong step (fable blocking with a stale-write trace; opus, astra, sol agree).**
  `STO-59`'s "as it bumps every tenant's credential generation" is `STO-54` step (3) "*Before the first `api` request*"
  (05:1548), after step (2) "*Before the first claim*" (05:1542). The right anchor is `STO-56` "written into the restored
  or promoted store before either component is started" (05:1338). fable and opus: write it "in the transaction that
  commits `STO-56`'s record"; opus, astra, sol: the MUST is behaviour and belongs in `STO-54`'s procedure.
- **B4, `CNF-368`/`CNF-369` unreachable (4/4).** 05:1427 "the engine before `STO-51`'s startup lock and so before
  `OPS-15`'s pass"; `OPS-47` (03:144) "retry for the stated bound (`OVR-19`) and then exit non-zero having done no work".
  A successor never reaches its advance while the first engine holds the lock. Four different fixtures (harness holder
  with no engine holding the lock: fable, opus; lost lock session with an already-sent holder: astra, sol).
- **B5, `CNF-370` vacuous (fable, opus; astra, sol: pin the survivor to the backup's value).** After "a startup
  advance" the survivor's value already differs from the backup's, so it is refused with no restore write.
- **B6, `CNF-367` (4/4).** The first refusal exits the engine, so "drive each … writer" needs one run per writer.
- **B7, "unlanded" (astra, sol).** G's "A record pending under `OPS-21` ends there, unlanded" (and R's copy) is false
  after a lost reply: `OPS-49` (03:1847) "the row is already written, the money already posted once";
  `StopRecord.exit_store` (:328). Two different replacements.
- **B8, previous-release engines (astra, sol).** `STO-13` runs migrations "while the previous release's engine and `api`
  keep running" (05:1407) and "Rollback is the previous binary against the current schema" (05:1430); its stop-everything
  rule covers predicates "both components evaluate" (05:1432). An old binary with an undetected lost lock claims after a
  new engine's advance, unchecked. Two different `STO-13` texts (sol adds "Rollback to such a binary is inadmissible").
- **B9, the timeout (sol blocking; opus, fable non-blocking).** No "startup-lock retry bound" exists; the row is
  "Startup-lock wait bound", typed `duration` (00-overview:399), so zero is admissible and `lock_timeout = 0` disables
  the timeout (sol; `CNF-369` then fails). opus: `lock_timeout` bounds each acquisition separately and `statement_timeout`
  is registered (00-overview:409, 05:139); set both. (PostgreSQL doc quotes not re-fetched; repo side verified.)
- **B10, residual overclaims (sol).** "and its row reaches `needs_reconciliation` or one of `OPS-15`'s exceptions" is
  false for `OPS-32` cleanup: `CNF-303` requires deletion "with the row still absent" (10:2894). Delete the clause.

Missing ids (verified; quotation updates, so they join the list, but texts differ and go into the next round):
03:415-416 quotes `STO-3` "nothing contends with it", which span 11 removes (4/4); 10:1519-1521 quotes `OPS-47`'s
"nothing here refuses the second", which span 1 removes (4/4); `Claim.lean`:22 "a second engine. `OPS-47`'s single
engine is assumed throughout" (4/4); `ADR-0022`:82 "The guarded status write is the transaction's first statement"
needs a dated note (4/4); `STO-13` (B8).

Pointer-only ids: behaviour, not pointer: **`STO-54`/`STO-56`** (opus, astra, sol; fable's B3 fix too), **`OVR-18`**'s
superseded alarm (astra, sol), **`OVR-19`**'s timeout assignment (sol; B9). Pointers: `STO-1`, `STO-6`, `OVR-17` (opus:
must cover `ledger`'s components, which "run in the one engine process", 00-overview:319), `ADR-0016`, `ADR-0022` (plus
the dated note), `CONTEXT.md`:520-527 (fable: say why G is not the epoch), `CNF-362` (no reader flags it).

Non-blocking, recorded, not merged: `OPS-50`'s list omits `OPS-8`'s defer (fable) and the engine-hosted `ledger`
writers (opus); `OPS-49`'s `lock_timeout` sites gain `STO-59`'s row (fable, 03:1862); `CONTEXT.md`:108 collides with
"credential generation" (fable); `OPS-47` 03:140 "a node cut off from its supervisor … is out of scope" and 03:147
"It answers one question, once, at boot" read oddly beside G and R (fable); Lean: a generation field in `Guards` makes a
mismatch `zeroRows`, contradicting span 7 — model it on `engineStep` → `.exited` (opus); `Claim.claim` takes only
`(admitted : Bool) (r : Row)` (Claim.lean:196, astra); `ADR-0025`'s refused/admitted witness pair (sol, `0025`:119);
`superseded_exits` must keep `exit_store`'s lost-reply alternative (astra, sol). A random UUID is not proof of non-reuse
(astra, sol; not counted, the MUST NOT stands). Lean names all exist: `Event` :28, `schedule_bounded` :121,
`later_stop_exits` :201, `money_posts_at_most_once` :285, `finished_unrecorded_exit` :395; no `lockLost`.

Void? No. Brief errors 1-4 below are defects in the drafted text being judged, not the question's premise; the tally
would be 0-4 either way.

## Q2, R read with G: **(b) another round.** Tally 0-4 clean ACCEPT (fable, opus: ACCEPT bar one span; astra, sol: CANNOT ACCEPT).

- **Open point (OPS-47 "is lost"): yes, 4-0; G does not change it, 4-0.** Trace: the backend dies at t0, the engine
  detects it at t1; a conforming engine claims in between, breaking R's "MUST claim nothing more"; with no takeover G
  admits that claim. MUST + trace: blocking.
- **`CNF-366` fix: right in intent, 4-0, but "as its loud log timestamps the detection" needs a log R never mandates**
  (verified: R's text in brief.md:177-180 has none; master 03:144 has none). A conforming engine can fail the CNF.
- Repairs converge in substance (detection-anchored, loud log at detection), differ in text: fable and opus near-same
  ("MUST, from the moment it detects the loss, log loudly that the lock [connection] is/was lost, claim nothing more and
  begin no periodic pass, …"); astra ("Where the engine detects loss …, it MUST immediately stop beginning claims and
  periodic passes and log the loss with the detection timestamp. …"); sol ("when the engine detects loss …, MUST log that
  detection loudly with its timestamp, begin no further claim transaction or periodic pass") plus "after the loss" →
  "after the engine detects the loss" in R's `OPS-21` sentence and `CNF-366`(iv).
- **Contradiction with G:** R's interplay sentence copies G's "ends there, unlanded" (B7; astra, sol). fable, opus: none
  of substance. Also: `CNF-366`'s success fixtures must keep the generation unchanged (astra); `CNF-366`(v) "every
  transaction refused" clashes with `OPS-50`'s "refuses" — write "a store error" (fable).
- Void? No premise error found. R's `OPS-21` anchor is at 03:1773 as stated (the file has a straight `"`, the brief `”`).

## Verified brief errors
1. "startup-lock retry bound" does not exist; `OVR-19`'s row is "Startup-lock wait bound" (00-overview:399).
2. The restore argument: the credential bump is `STO-54` step (3), after the engine's step (2); `STO-56`'s "before either
   component is started" (05:1338) is the anchor.
3. The lock-order argument: "holds nothing but the generation row" needs the advance to be its own transaction, which
   the draft does not say.
4. "`Claim.lean` (guard model, :23)": :22-23 is the single-engine docstring; `Guards` is :73, `workerGuard` :97.
5. "checked with `grep -F`": the check was whitespace-normalised (notes.md:56); every span matches flattened (4/4).
6. Line hints off by one (span 1 at 03:137; span 6 at 03:355-356, per fable/opus; not re-checked).

## What the next round must read (one merged form, G + R)
G: B1+B2 as one `OPS-15`/`OPS-50` text (exempt advance in its own transaction, nothing else, commit acknowledged
before the sweep, claims or periodic components); B3 as a `STO-54` procedure step in `STO-56`'s record transaction,
`STO-59` pointing at it; B9 (name the wait bound, finite positive, `statement_timeout` too, liveness stated); B7 a
lost-reply sentence (shared with R); B8 a `STO-13` contract step (rollback admissibility may be an owner point if
readers split); B10 delete the clause; the missing quotations and `ADR-0022`/`Claim.lean` notes; `OVR-18`/`OVR-19`/
`STO-54` as behaviour text; the `CNF-367`..`CNF-370` fixtures; the Lean modelling (B-notes above).
R: the detection-anchored `OPS-47` clause with a mandated loud log (fable/opus text as base), sol's "after the engine
detects the loss" in `OPS-21` and `CNF-366`(iv), the lost-reply sentence, astra's and fable's `CNF-366` fixture notes.
Rule 5 watch: B7's clause and R's loss clause are amended for the first time here; non-convergence next round deletes.

Combined Run: NOT ready. No (c) this round. `PRV-29` bead still to file (assistant).
