# r66e tally (panel D, pv-buc): final confirmation read of Form R + Fence G, combined. 2026-10-24

Master `d78085a`. Rules: r66e/notes.md, applied as written. Labels a-d (notes.md launch table maps them; not repeated here).
All four units exited 0.

## Outcome: (a) consensus, 4-0 ACCEPT

| Reader | Verdict | Contradiction with d78085a | Gated defect |
|---|---|---|---|
| a | ACCEPT | yes, one: `executive-summary.md`:250-253 (wording) | none |
| b | ACCEPT | no | none |
| c | ACCEPT | yes, the same one (wording) | none |
| d | ACCEPT | yes, the same one (wording); also lists three deliberate reversals the text records (`ADR-0019`:80, `ADR-0022`:82, `ADR-0044`:95) | none |

No CANNOT ACCEPT. No gated defect. The one contradiction is verified true and is wording only, so rule 4's last
sentence sends it to rule 3. No verified premise error (below). Scope: no reader disputes the owner's scope; c and d
state that a surviving-process trace violates span 26's MUST.

## Span 19

- No reader says span 19 should be deleted. No reader says it protects a supported case. c: `CNF-370` "does not
  purport to demonstrate protection during an unsupported online restore"; d: no restore-window blocker "within that
  scope". a and b do not mention it.
- Checked at d78085a: with span 26 every engine and `api` is stopped before the procedure and none starts until the
  record's transaction is acknowledged, and the first startup after it advances the generation anyway (`OPS-15`). So
  span 19's fresh value changes nothing in a conforming restore; it only refuses a survivor once the record commits,
  which is the unsupported case. This matches notes.md's "for main only" line.
- Not raised by a reader, so no owner question (task rule). For main: `CNF-370`'s first assertion and `STO-59`'s
  "restore-record transaction" wording both depend on span 19; deleting it later is a three-place edit.

## Each reader's recorded items, with verification and disposition

"Rides" = wording-only fix for the Run (rule 3); each changes no behaviour. "Not carried" = recorded, does not block
(rule 2), main's call.

### The contradiction (a, c, d)
- **Verified.** `executive-summary.md`:250-253: "**Two engines are out of scope and the set says so** (`OPS-47`): a
  startup lock refuses the second one's *boot*, and nothing refuses its writes, because the epoch that claimed to was
  comparing a value against itself (`ADR-0019`)." Against span 1 and `OPS-50`. No span edits this file.
- **Rides**, one reader's text verbatim: **a's**, because it mirrors span 1's accepted words ("no write of the
  earlier one commits"; "provider calls it already licensed still go out") and keeps the paragraph's bold-lead form.
  c's (pointer only) and d's (quotes `OPS-50`) are fallbacks if the Run's reviewer objects to a restatement.

### a
- (b) README ADR index has no `0047` row. **Verified**: `README.md`:117 is `0046`'s row, the last. **Rides** (a's
  row text).
- (c) R+G race: E1's advance queued when its lock connection drops; R forbids claims and periodic passes but not the
  startup sweep. a's own trace commits nothing stale. Replacement "run none of `OPS-15`'s pass," adds a MUST NOT to R:
  **behaviour, not carried.**
- (d) "Both timeouts" note: PostgreSQL's "rather pointless to set `lock_timeout` to the same or larger value". The
  note as written ("setting both bounds the whole wait") is true; `statement_timeout` does the bounding. a's
  replacement adds "so a lock wait and a slow statement cannot be confused in the log", which is unsupported if the
  statement timeout always fires first. **Not carried.** The PG quote was not fetched here; if `ADR-0047` carries the
  note, the Run fetches it.
- (e) `statement_timeout` versus a COMMIT's standby wait; pre-existing at d78085a (`STO-7`:145 "A standby wait has no
  server-side timeout"). **Not carried**; a possible follow-up for main, not filed.
- (f) multixact cost: rationale. **Rides** only as an optional `ADR-0047` cost clause, if the Run wants it.

### b
- D1 engine writes before the advance. **Verified**: 05:1519 step (1) is "*Before the startup lock:*" and includes
  "`provider_account_status` is re-established" (05:1528); d78085a names no process for it; pseudocode 03:1689-1693
  writes nothing before `take_startup_lock`; `Restore.lean` models step (1) as `.lock` that "writes nothing". **Rides,
  first clause only:** "The engine makes no write before that transaction" restates the new `OPS-15` MUST ("Its commit
  MUST be acknowledged before the engine begins any other write transaction"). The second clause (step (1)'s writes
  are "not written by the engine process") assigns a writer d78085a does not: **not carried**; flag for main.
- D2 pseudocode has no advance step. **Verified** (03:1693 → 03:1695). **Rides**: b's two pseudocode lines and the
  03:1732 parenthetical. Mirrors `OPS-15`.
- D3 the advance's own commit under `SyncRep`. **Not carried as written**: b's clause says it holds the advance "until
  that exit", but the timeouts cover only "Its replacing statement", so no exit bounds the commit. Same point as a(e).
  Main's call.
- D4 `STO-59`'s distinctness MUST "cannot be met deterministically". The replacement turns notes.md's adopted
  outcome MUST into a method MUST: **behaviour, not carried.**
- D5 `Claim.lean`:15 "What the model omits: `OPS-15`'s startup pass". **Verified**. **Rides** (b's line-15 text).
  Run note: `engineStep` (:430) takes no `Guards`; adding `generationCheck` to `Guards` (:73) changes `engineStep`'s,
  `lost_claim_reply_exits`' and `exited_never_claims`' signatures.
- D6 span 12's "otherwise" branch is unreachable. **Verified**: in `CNF-290`'s restart drill (10:1508-1512) the
  advance precedes the sweep, so the old write is refused, never zero-row. No verdict lost: `CNF-197` (10:2009-2012,
  "a *worker* write against an operation moved by something else affects no row") and `CNF-27`'s claim-number case
  (10:176-179) still drive `STO-3`'s zero-row guard. **Rides** (b's text).
- D7 `CNF-368`/`CNF-369` sessions can be killed by `idle_in_transaction_session_timeout`. **Verified**: `OVR-19`'s
  store-timeouts row does not order it against the Startup-lock wait bound. **Rides** (b's fixture clause): check
  strength, notes.md's precedent.
- D8 not-covered list should name the post-hoc promotion class (05:1513-1514 "served a component before it had
  caught up"). 05:1514 says such a promotion "is a restore: the procedure below runs on it", and span 26's MUST can be
  met for it by stopping every component before the procedure runs. Declaring it unsupported changes scope: **not
  carried.** See brief error 1.

### c
- The contradiction only (above). No brief errors.

### d
- The contradiction only (above), plus three reversals the text already records (span 13, span 18, `ADR-0047`). No
  brief errors.

## Brief errors

1. **Verified (b):** span 26's gloss "A promotion that is a restore runs this procedure (05:1514-1515), so its
   components are stopped before the promotion begins." For the post-hoc class a component already ran on the
   promoted store, and 05:1507 says "Before any component connects to the promoted store", not before the promotion.
   It is brief commentary after the After quote, not spec text. **No vote rests on it** (b raised it and accepted;
   a, c, d do not use it). Does not void. The Run must not carry the gloss; one wording clause rides: span 26's
   "*Before the restore begins,*" reads, for a promotion that is a restore, "before the procedure runs on it".
2. a: `ADR-0022`:92-93 shown with a line break inside the quotation. Line 92 holds the whole quotation, 93 starts
   "stays true." The range is right; brief wrapping only. Cosmetic.
3. a: "Three notes marked 'not spec text'" ignores the design summary's "(a summary, not spec text)". Pedantic.
4. Not errors: "Earlier rounds accepted R 4-0" (r65b tally:11; r66b tally:12) and "accepted 4-0 a set of fixes to
   G" (r66c tally:107); "r65b's Form E fix-8 list" (r65b brief.md:239-242). Unverifiable in the clone only.

## Known wording items from notes.md (ride)

- `ADR-0047` records span 26's step and quotes the owner's dated words verbatim.
- `CNF-370`: a restart between the backup and the restore, so a choice "whose effects a restore removed" exists.
- r66c Q3's D4 rewordings from two readers (notes.md:128).
