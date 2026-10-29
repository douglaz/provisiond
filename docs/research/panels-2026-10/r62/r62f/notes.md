# r62f manager notes (2026-10-22), for a fresh manager to tally

**Scope:** one form only, `del` (`variants.py`; full text `candidate-del.patch` = 07bac41 + r62 final-form.patch +
`del`). It deletes `API-40`'s conflict rationale (`04:772-777` patched: "The order resolves a conflict between two
MUSTs…" through "whichever way a handler goes.") and keeps the outcome sentence with the join "For a body carrying
both a bad token and an unknown field, **the token check wins**: …". Coordinator routing after r62e split (0-4 on
as2 and opus2): delete, don't reword. Owner's standing lesson: prefer deleting an unsupported clause.

**Before launch:** six text gates on a fresh clone of 07bac41 + final-form.patch + `del`: all exit 0
(`gates/del.*`). No quote is left in the paragraph; control plants in it: true `WIR-2` quote → citations 0
(`control-true`), false → citations 1 (`control-false`).

## Outcome rules (coordinator, fixed before launch)

- Readers answer ACCEPT or CANNOT ACCEPT only. Replacement or added text is out of scope and is not counted.
- **Valid CANNOT:** it names specific normative content (a MUST/SHOULD, quoted with its location, or a concrete
  behaviour) that the reader says the deletion loses. A valid CANNOT blocks.
- A CANNOT that names no lost normative content (wording, style, rationale, replacement text) is recorded but does
  not block.
- **Settled:** ≥3 ACCEPT and no valid CANNOT.
- **Anything else: stop and report.** No further round (no r62g). The manager does not judge whether a named loss
  is real; it verifies the reader's facts and reports them.

## On settle (r62e notes' settle steps, with `del`)

1. `/var/tmp/provisiond-panel-r62f/gates.sh r62f-final del` (six gates, fresh clone).
2. Back up `../provisiond-panel-r62/final-form.patch` (`.bak-r62e`), then save
   `git -C gates/variant-r62f-final diff` over it.
3. final-form.md (back up `.bak-r62e`): `API-40` bullet → the deletion, marked "reviewed (r62f)"; remove Open; header
   "Nothing is open"; add "File with the drain PR": `PRV-47` mixed rejection, `DOM-10` admission gap, citation gate's
   "withdrawal" filter. Opus's r62d note is answered by the deletion (the clause it questioned is gone).
4. Append an r62f section to `../provisiond-panel-r62/tally.md`: one line per reader, facts verified, gate exits.

## Tally checklist

- Check each `<r>.exit` and `<r>.md` size/first line. A 53-byte "You've hit your session limit" body with exit 1
  means rerun, not count. Claude session was 90% used at launch (resets 21:10Z).
- Verify every fact a reader asserts against a fresh clone with `candidate-del.patch` applied.

## Launch (started 2026-10-22 18:51:17Z; all four units active at +20 s)

- `launch.sh` starts `panel-r62f-{fable claude-fable-5-1, opus claude-opus-5-5, astra gpt-6-astra high, sol
  gpt-6.1-sol xhigh}`, each `MemoryMax=16G MemorySwapMax=0 OOMPolicy=continue`, `TMPDIR=$P/tmp`, 2400 s timeout.
- Clones `$P/<r>` fresh at 07bac41, clean. Answers `$P/<r>.md`, exits `$P/<r>.exit`. Brief: argv to Claude, stdin
  to codex. Brief fixed before launch: r62e's 4-0 agreement stated as "against `WIR-12`'s MUST a field-naming
  answer breaks nothing" (opus held the "violates the other" sentence true under as2).
