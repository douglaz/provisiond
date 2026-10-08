# Panel r24 synthesis — network-restriction field, round 2 (2026-10-07)

Readers: fable, opus (claude xhigh), astra, sol (codex xhigh); clones at 82e7f37. All exit 0.
Reviewed my round-2 recommendation (merge; one triple + write rule; narrowed WIR-47 refusal).
Citations verified.

## Verdict: AMEND, 4–0 — merge yes; one triple NO; refusal DELETED, not narrowed.

- Merge `restricted`/`disabled`: 4–0. No reader branches on the split (LDG-71 "still consuming
  runway" either way; DOM-26's delete either way); CNF-228's `disabled` is a fixture value; `source`
  already carries what the split pretended to (provider = flag on an address, operator = notice about
  the machine). 01:317-319 ("even a boolean would lose information a single enum value cannot carry")
  must be rewritten.
- One triple fails: 4–0, by trace. Four states (none / provider / operator / both) do not fit a
  status+source triple. My bullets contradicted my headline (unguarded provider write vs "neither
  overwrites"). Either reading fails a sequence:
  (i) op → flag set → flag clear: unguarded erases the operator's notice (my stated cost was false);
  (ii) flag set → op records → flag clear → op withdraws: the narrowed 409 refuses the notice, the
      clear shows `unknown` while the lock persists;
  (iv) op → flag set → op withdraws: `unknown` while the flag is set, until an unscheduled refresh.
  (iii) flag clears while a whole-server lock persists is `unknown` under any storage — a limit of the
  source.
- Two observations on the machine row, OR-combined: 4–0. Not a second home: DOM-27's one home is the
  machine as against the case (01:321-324); `state` + `state_observed_at` already sit on that row as
  two columns. Opus reversed its round-1 objection explicitly. Same size: fable/opus — three nullable
  columns (`provider_restricted` bool + `provider_observed_at`; `operator_recorded_at`), `source`
  derived; two writers each touching only its own columns; no write rule.
- Refusal: delete (fable, opus, astra, sol). With `none` gone an operator value can only agree or add;
  withdrawal touches only its own column. 05:1047-1049 is account-status's argument borrowed "on
  `machines.network_restriction`'s reasoning", and 05:1056-1058 says "unlike PRV-35 … the precedence
  rule therefore bites" — both must stand on account status's own reason (healthy/terminated exclude
  each other). API-63's "exactly as WIR-47 refuses" (04:1420) likewise.
- Forgotten record: accept as a stated cost (4–0); nothing surfaces it today (OPS-26 lists operations
  and episodes). Do not clear on case closure (STO-39: several cases; SEC-41 opens none) or gone-write.
  fable: state it in WIR-47 in the shape of 02:752-753 ("bounded by operator response time") and give
  the body an `operator_ref` (as WIR-50's) so the follow-up has an owner; the harm is real because
  DOM-27 names delete as the remedy, so a stale record invites deleting a working machine.

## Defects found beyond round 1 (verified)

- 04:44 "record a restriction no driver can read" — false under any round-2 shape.
- 02:757 "MUST declare that it cannot" loses its only reader; PRV-44 never gave it a field.
- 02:757-758 "the same cache semantics as every other machine field" — false under a guarded write.
- 05:269 "A driver-read value is authoritative over an operator-recorded one" goes.
- WIR-43's fixture (13:1037-1049) omits the object WIR-47 says is joined into the case projection.
- 01:313 cites STO-44 for the observed time; the columns are 05:268-270.
- STO-44 (05:1111) "says what is true now" → dated evidence.

## Edits (converged)

DOM-27 (enum `restricted | unknown`, two observations OR-combined, rewrite 317-319, fix citation);
PRV-35 (positives only; delete the declaration clause and the precedence sentence; "combined, never
ranked: a clear read removes nothing an operator recorded"; Robot confidence lowered, mapping under
verification; Cloud null family; server.locked unmapped); 05:268-270 (three nullable columns),
05:269, 05:284, 05:1047-1061 re-homed, 05:1111; WIR-47 (record + withdraw, no 409, the cost sentence,
operator_ref; render rule: provider positive, else operator record, else last read); WIR-11 example
(13:299 → unknown); 04:44, API-61 (withdrawal), API-63 (04:1420); WIR-43 fixture; CNF-228
(`restricted` from either source), CNF-233 (the four sequences; no 409), CNF-250 unchanged; SEC-41
per-machine cost stated. Lean: none.
