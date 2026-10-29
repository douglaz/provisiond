# r62e manager notes (2026-10-22), for a fresh manager to tally

**Scope:** `API-40`'s attribution span only; this is panel B's last open point. The two options are as2 (astra +
sol) and opus2 (opus), from r62d. Their exact text is in `brief.md` and in `variants.py` (`as2`, `opus2`).

**Before launch:**
- Owner, 2026-10-22, on a1: "Wide: all four ops (Recommended)". The ruling is recorded in the manager brief. WIDE
  is folded into `../provisiond-panel-r62/final-form.patch` (`amend.py a1-opus`), and final-form.md marks it
  "r62d + owner". Candidate bead 4 is dropped.
- The r62c patch is kept as `final-form.patch.bak-r62c`.
- Six text gates on a fresh clone of 07bac41 + the WIDE patch: all exit 0 (`../provisiond-panel-r62d/gates/final-wide.*`).
  With as2 and with opus2 on top: all exit 0 (`gates/wide-as2.*`, `gates/wide-opus2.*`). The plants and the
  semicolon join turn citations red (r62d tally).

## Outcome rules (coordinator, fixed before launch)

- **Settled:** an option settles when at least 3 of the 4 readers ACCEPT it and none marks it CANNOT ACCEPT.
- **Both settle:** the PICK majority wins, with BOTH counting for each option. On a PICK tie, report it to the
  coordinator as split.
- **Anything else is split:** neither option settles, or a reader offers replacement text. Stop and tell the
  coordinator. **No r62f.**

## On settle

1. Fresh clone: `/var/tmp/provisiond-panel-r62d/gates.sh r62e-final <as2|opus2>`. It runs the six text gates on
   07bac41 + `final-form.patch` + the variant.
2. Save `git -C /var/tmp/provisiond-panel-r62d/gates/variant-r62e-final diff` as
   `../provisiond-panel-r62/final-form.patch`. Back up the old one first.
3. In final-form.md:
   - put the chosen text in the `API-40` bullet, marked "reviewed (r62e)";
   - remove the Open section;
   - set the header to "Nothing is open".
4. Append an r62e section to `../provisiond-panel-r62/tally.md`:
   - one line per reader;
   - every reader fact, verified;
   - the gate exit codes.
5. Report:
   - the tally;
   - the final-form status;
   - the 3 candidate beads (`PRV-47` mixed rejection, `DOM-10` admission gap, citation gate's "withdrawal" filter);
   - opus's non-bead note (`API-40` rationale wording).

## Tally checklist

- Check each `<r>.exit` and each `<r>.md`'s size and first line. A 53-byte "You've hit your session limit" body
  with exit 1 means the reader must be rerun, not counted.
- Verify every fact a reader asserts against a clone with the patch applied before relaying it.
- Keep a reader's vote apart from any counter-argument it writes.

## Launch (started 2026-10-22 18:17:55Z; all four units active at +20 s)

- `launch.sh` starts four units, `panel-r62e-{fable claude-fable-5-1, opus claude-opus-5-5, astra gpt-6-astra
  high, sol gpt-6.1-sol xhigh}`.
- Each unit runs with `MemoryMax=16G MemorySwapMax=0 OOMPolicy=continue`, `TMPDIR=$P/tmp` and a 2400 s timeout.
- The clones `$P/<r>` are at 07bac41 and clean.
- Answers go to `$P/<r>.md`, exit codes to `$P/<r>.exit`.
- The brief goes to the Claude readers as argv, the same as r62d, and to codex on stdin.
