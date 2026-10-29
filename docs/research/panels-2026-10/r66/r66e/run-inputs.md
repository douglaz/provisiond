# r66e run inputs: the combined R + G Run for pv-buc. 2026-10-24

Source: r66e tally.md (outcome (a), 4-0 ACCEPT). Base `d78085a`. Line ranges are /var/tmp/provisiond-panel-r66e/brief.md.
Quote ranges verbatim into the Run instruction; do not paraphrase (owner rule: quote every clause of a cited decision).

## 1. Spec text the Run applies

| What | brief.md lines | Spec text? |
|---|---|---|
| G design summary | 63-76 | No. Rationale for `ADR-0047` |
| G new text: `STO-59`, `OPS-50`, `OPS-15` paragraph, `ADR-0047`, `CONTEXT.md` entry | 78-136 | Yes, except 117-125 |
| Three "not spec text" notes (anchor, both timeouts, zero bound) | 117-125 | No. Rationale for `ADR-0047` |
| Amended spans 1-21, 23-26 (22 deleted) | 138-293 | Yes. Span 26's gloss at 291-293 ("The rest of the bullet … before the promotion begins.") is NOT spec text; see fix W8 |
| Pointer-only amendments | 294-298 | Yes |
| `CNF-367`-`CNF-370` | 300-314 | Yes |
| Lean (named, not built) | 315-328 | Yes |
| What G does not cover (`ADR-0047` states it) | 330-337 | Yes |
| Form R: `OPS-47`, `OPS-21`, `OPS-49`, `ADR-0019` note, `StopRecord.lean` comment, stated behaviour, `CNF-366` | 339-389 | Yes |

## 2. Wording-only fixes (each changes no behaviour)

- **W1** `executive-summary.md`:250-253 (verified contradiction). Replace from "**Two engines are out of scope and the
  set says so**" through "(`ADR-0019`)." with a's text, r66e/a.md:13. Restates span 1; no new rule.
- **W2** `README.md` ADR index: add after :117 a's `0047` row, r66e/a.md:17. Index only.
- **W3** new `OPS-15` paragraph, end of its second sentence: "The engine makes no write before that transaction."
  (b D1, first clause only). Restates "Its commit MUST be acknowledged before the engine begins any other write
  transaction".
- **W4** 03 worker pseudocode after `take_startup_lock` (03:1692-1693): b's two lines, r66e/b.md:28-31; and at
  03:1732 b's parenthetical, r66e/b.md:32. Mirrors `OPS-15`.
- **W5** `Claim.lean`:15: b's replacement, r66e/b.md:53. Docstring. Run note: `engineStep` (:430) takes no `Guards`;
  `generationCheck` in `Guards` (:73) changes the signatures of `engineStep`, `lost_claim_reply_exits` and
  `exited_never_claims`.
- **W6** span 12: "commits nothing and exits it (`OPS-50`)" (b D6). The "otherwise" branch is unreachable; `CNF-197`
  and `CNF-27` still drive `STO-3`'s zero-row guard.
- **W7** `CNF-368` and `CNF-369`: b's fixture clause, r66e/b.md:66. Check strength only.
- **W8** span 26: drop the brief's gloss (291-293's last sentence) and read "*Before the restore begins,*" for a
  promotion that is a restore as "before the procedure runs on it" (05:1514). Manager wording, not a reader's; it
  removes the brief error, not a rule.
- **W9** `ADR-0047` records span 26's step and quotes the owner's dated words (section 6) verbatim (notes.md:92-95).
- **W10** `CNF-370`: a restart between the backup and the restore, so a choice "whose effects a restore removed"
  exists (notes.md:96-98). Check strength.
- **W11** r66c Q3's D4 rewordings from two readers (notes.md:128; r66c tally).
- Optional: a(f)'s multixact cost as one `ADR-0047` clause.

Not carried unless main decides (tally.md): a(c), a(d), a(e), b D1 second clause, b D3, b D4, b D8.

## 3. Ids

- New, unused at `d78085a` (git grep outside docs/research): `STO-59`, `OPS-50`, `ADR-0047`, `CNF-366`, `CNF-367`,
  `CNF-368`, `CNF-369`, `CNF-370`. Last used: `STO-58`, `OPS-49`, `CNF-365`, `ADR-0046`.
- CNF items: `CNF-366` (R, brief 371-389), `CNF-367`-`CNF-370` (G, brief 302-314).
- Lean items, named: `generationCheck : Bool` (parameter of the model carrying `engineStep`);
  `superseded_never_commits`; `superseded_commits_without_check` (witness); `StopRecord.lean`'s `Event.superseded`;
  `superseded_exits` (beside `later_stop_exits`, keeps `exit_store`'s lost-reply alternative); edits to `schedule`,
  `schedule_bounded`, the three `selection` splits, `money_posts_at_most_once`'s docstring; `finished_unrecorded_exit`
  weakened by one disjunct (`ADR-0047` says so); `Claim.lean` docstring (span 17, W5); `Event` doc comment (R).

## 4. Bead to file in the pv-buc branch

- `PRV-29` names no automatic resolver for a non-create `needs_reconciliation`. (`PRV-29` at 02:422.) File with
  `BEADS_DIR=<worktree>/.beads` if in a worktree.

## 5. Panel records to commit

- r64 is already in. Add r65, r65b, r66, r66b, r66c, r66d, r66e to `docs/research/panels-2026-10/` following
  db53414: `r65/` with `r65/r65b/`; `r66/` with `r66/r66b/` … `r66/r66e/`.
- Per round: brief.md, notes.md, tally.md and one answer per reader named fable.md, opus.md, astra.md, sol.md (r63/r64
  precedent). r66e: a→fable, b→opus, c→astra, d→sol.
- Strip: model ids (e.g. r66e notes.md:41-46's table), quota sections (r66e notes.md:135-142), `.err`/`.out` logs,
  exit files, clones, tmp/, parts/ scripts. Check each notes.md for these before copying.
- Add r65 and r66 rows to `docs/research/panels-2026-10/README.md`.

## 6. Owner decisions, verbatim (owner-q1-sync-2026-10-23.md, pv-buc blocks)

- r65: R vs E "double check it again"; Fence G "call the panel to double check this"; Fence A "try to get a consensus
  here".
- r65b: R "Yes, R (Recommended)"; Fence G "Adopt; one combined Run".
- r66b: restore gap "Draft 2) using the panel and assess complexity"; rollback "Us this scenario real? The project
  isn't built yet".
- r66c: "try to reach a consensus".
- r66d: "I don't think we should tolerate a gross operator mistake like restoring some backup with the system
  running".

The assistant's readings, kept separate from the owner's words: r66b, "no build without the fence will exist if G lands
before any build; the STO-13 transition clause … dissolve[s]"; r66d, "restoring a backup while any engine or api runs is
outside what G defends … no app-side restore check is added".
