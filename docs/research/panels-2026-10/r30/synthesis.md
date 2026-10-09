# Panel r30 synthesis — a network restriction's provenance after an operator-only withdrawal (2026-10-09)

Readers: sol, astra (codex xhigh), fable, opus (claude xhigh); clones at 843a2f2. All exit 0.

## Agreed (4–0)

- Blank (null) source/time on the Manager's trace (never read, operator recorded then withdrew). Reject
  keeping a trace of the operator's look (option 2) and "latest observation of either kind" (a withdrawal
  rendered `operator_notice` at t2 asserts a negative the operator never observed; it also mislabels a
  surviving provider warning).
- No reader distinguishes "never looked" from "looked, withdrawn": `DOM-27`'s "The signal's job is to
  **stop** a remediation loop" fires only on `restricted`; `SEC-32` audits each operator write and
  `operator_ref` names the notice.
- r24's "`CNF-250` holds unchanged" was false the moment the operator column became clearable (fable
  corrected its own r24 claim). r24's three columns omit `operator_ref` → four nullable columns.
- `WIR-47` owns the render rule; "nobody has looked" appears in four places — one owner.
- Lean: none, provided withdrawal is a body on the existing `record-network-restriction` route (a new
  route adds a `Verb` constructor matched in eight places).

## Split 2–2: what does `unknown` render when the provider HAS read clear flags?

- Show the clear reading (sol, astra): `unknown` / `provider_api` / its time — "null exactly when neither
  source has a retained observation".
- Show nothing (fable, opus): `source`/`observed_at` render only beside `restricted`; `unknown` always
  renders null/null. Reasons: ADR-0038 D2 already defines them for "the positive one" only; a non-null
  provenance on `unknown` is the deleted `{"status": "none", "source": "provider_api"}` under a new name
  (ADR-0038 deleted `none` because "no source can support the negative"); the provider's last-read time
  is already on the view as `state_observed_at`. Total by construction; the Manager's case disappears.

## Edits (fable/opus shape)

ADR-0038 dated note under Decision 2 ("where neither is positive, `source` and `observed_at` are null");
`WIR-47` (render rule; body `restricted` + `operator_ref`; withdrawal `{"status": "unknown"}` on the same
route; 409 deleted); `DOM-27`; 05-persistence four columns (no "nobody has looked" sentence); `PRV-35`
keeps "`unknown` MUST NOT be rendered as `none`"; `CNF-250` → "null exactly when `status` is `unknown`",
fresh fixture kept, plus a clear read renders null/null; `CNF-233` the Manager's trace + r24's four
sequences, no 409; `CNF-228` `restricted` from either source; `WIR-11` → unknown/null/null; `WIR-43`
fixture gains the joined object. Opus: `WIR-47`'s body carries an operator-supplied `observed_at` while
the column is `operator_recorded_at` — say which renders.
