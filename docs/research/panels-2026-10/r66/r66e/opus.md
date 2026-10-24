# Panel D (r66e), pv-buc: Form R + Fence G, combined

## 1. ACCEPT

Reading parts 1 and 2 together, I found nothing that passes the gate. No `CNF` assertion or Lean theorem flips or becomes vacuous. I found no MUST that a conforming trace breaks, and no stale write that G admits.

- **Lock order:** `api` never touches the generation row, and the advance holds nothing else. So no wait cycle is possible.
- **Earlier engine's write:** an earlier engine's write either commits before the advance (and before the sweep) or reads the new value and exits.
- **Lean weakening:** adding `superseded` to `finished_unrecorded_exit` (StopRecord.lean:395–411) puts it beside the existing `laterStop` disjunct, matching span 23.

**Recorded defects.** None of these meets the gate. Each is a wording fix that can ride into the Run.

**D1. The engine must not write before the advance, but no text says so.**
- The new `OPS-15` paragraph says "Its commit MUST be acknowledged before the engine begins any other write transaction".
- `STO-54`'s step (1) runs "*Before the startup lock:*" (05:1519). It includes "`provider_account_status` is re-established" (05:1528) and has its own mark, `steps_completed` "(0 to 3)" (05:1336).
- d78085a does not say which process performs step (1). If the engine writes step (1)'s results before the lock, it breaks the new MUST, and `OPS-50` has no own value to compare against.
- This does not block, because a conforming design exists. The worker algorithm shows no write before `take_startup_lock` (03:1687–1693). `Restore.lean` models step (1) as `.lock => { w with locked := true }` (:441), whose docstring says "It writes nothing of the grace, which is step (3)'s" (:385).
- The brief's anchor note covers step (2) only.

Replacement: append to the second sentence of the new `OPS-15` paragraph:
> "The engine makes no write before that transaction: what `STO-54`'s step (1) writes before the startup lock is not written by the engine process."

**D2. The pseudocode has no advance step.**
- The worker algorithm goes from `take_startup_lock` (03:1693) straight to `run_startup_pass` (03:1695).
- Three passages name "a restart" as a zero-row cause: 03:1728–1729, 03:1732–1733, and `STO-3` at 05:33–34. G makes that cause unreachable for engine writes, because a superseded write is refused before its guarded statement.

Replacement: after the lock lines, add
```
    if not advance_generation(bound):             # OPS-15, OPS-50: first write after the lock;
        exit_nonzero()                            #   timeout, store error or lost reply -> exit
```
Then add to 03:1732: "(after a restart, `OPS-50` refuses an earlier engine's write before its guard)".

**D3. Nothing bounds the advance's own commit.**
- `statement_timeout` bounds only "Its replacing statement".
- The advance's own COMMIT can sit in `SyncRep`: `STO-7` says "A standby wait has no server-side timeout".
- The liveness sentence names only "a `SyncRep` holder".

Replacement:
> "**Liveness:** a `SyncRep` holder, the advance's own commit waiting for a standby (`STO-7`: "A standby wait has no server-side timeout"), or share holders that keep turning over, can hold the advance…"

**D4. `STO-59`'s distinctness MUST cannot be met deterministically.**
- The sentence: "MUST choose a random UUID distinct from the values chosen by earlier … including choices whose effects a restore removed".
- No implementation can consult values a restore removed. Only randomness meets it.

Replacement:
> "Every startup advance and restore-record transaction MUST draw a new value from `gen_random_uuid()`, never a stored, remembered or restored one; that draw is what makes it distinct from every earlier choice, including choices whose effects a restore removed."

**D5. Two gaps in `Claim.lean`.**
- Line 15 says "What the model omits: `OPS-15`'s startup pass", but `superseded_never_commits` models that pass's advance. Span 17 changes lines 22–24 only.
- `engineStep` (:430) takes no parameter record. If `generationCheck` joins `Guards` (:73), then `engineStep`, `lost_claim_reply_exits` and `exited_never_claims` each gain a `Guards` argument.

Replacement for line 15: "What the model omits: `OPS-15`'s startup pass, except the generation advance `superseded_never_commits` models,"

**D6. Span 12's "otherwise" branch can never run.**
- In `CNF-290`'s restart drill the restart always advances the generation, so the "`STO-3`, `OPS-22` otherwise" branch is unreachable.
- No verdict is lost. The assertion is still checked under `OPS-50`. `STO-3`'s zero-row worker guard is still driven by `CNF-197`, and its claim term by `CNF-27`.

Replacement: "commits nothing and exits it (`OPS-50`)".

**D7. Server timeouts can kill the test session in `CNF-368`/`CNF-369`.**
- Both items hold a store session open in a transaction, and `CNF-369` holds it "past the Startup-lock wait bound".
- `OVR-19` (00:409) does not order `idle_in_transaction_session_timeout` against that bound. A deployment-configured session can therefore be killed first.
- If that happens, `CNF-368`'s claimed row rolls back, and `CNF-369`'s "`STO-59`'s value is unchanged" fails.

Replacement: in both items, "open a store session outside the pool, with `idle_in_transaction_session_timeout` and `statement_timeout` disabled, that reads…".

**D8. The not-covered list should name the post-hoc promotion class.**
- 05:1513–1514 classifies a promotion that "served a component before it had caught up" as a restore. In that class a component ran on the promoted store.
- Span 26 places this class out of scope. That fits the owner's scope, and the list should say it by name.

Replacement: append to the unsupported-restore bullet: "This includes a promotion `STO-54` classes as a restore because it served a component before it had caught up."

## 2. Contradictions: No

Every passage outside `docs/research` that quotes words the spans remove is amended in step. I grepped the removed words across `*.md` and `tools/formal`, and each hit is covered by spans 1–25: 03:138–139, 03:146, 03:176–177, 03:415–416, 03:1735–1736, 05:49, 10:1511, 10:1521, `README.md`:305, ADR-0019:58, ADR-0022:92 and ADR-0025:65–66.

D1 comes closest. It becomes a contradiction only if the engine performs step (1), and d78085a assigns step (1) to no process.

## Brief errors

1. **"r65b's Form E fix-8 list" cannot be checked in the clone.** `ls docs/research/panels-2026-10/` ends at `r64`, and `grep -rln "Form E\|fix-8\|r65b" docs .beads` returns only r64b files. The reference may be right, but nothing here shows it.
2. **Span 26 overstates what follows from the restore procedure.** It says "A promotion that is a restore runs this procedure (05:1514-1515), so its components are stopped before the promotion begins."
   - The class at 05:1513–1514 ("served a component before it had caught up") is a restore precisely because a component ran on the promoted store.
   - The existing rule (05:1507–1508) is "Before any component connects to the promoted store", which is not "before the promotion begins".
3. **Everything else checks out.** Every other quotation and line hint I tested resolved. That covers spans 1–21 and 23–26, 0019:80–81, 0022:82 and 0022:92–93, 0025:65–67, `Claim.lean`:22–24 and :430, 00:338, 00:353, 00:399, 03:769, 05:145 and `CONTEXT.md`:108. The new ids `OPS-50`, `STO-59`, `CNF-366`–`370` and `ADR-0047` are all unused. I did not fetch the PostgreSQL quotations.

I saved a copy as `panel-d-answer.md` in the clone (untracked). I ran no gate and no `lake`, and committed nothing.
