# Panel r33 synthesis — which instant an operator's restriction record shows (Q15b, pv-ucs.7), 2026-10-10

Readers: sol, astra (codex xhigh), fable, opus (claude xhigh); clones at 7d21478. All exit 0.

## Verdict: 4–0 AGAINST my recommendation — store and render the server's recording instant; drop the
## request's `observed_at`.

- One field, one clock: the provider half is our READ time ("when it was read", ADR-0038:34) — Hetzner's
  `blocked` and Robot's `locked` are booleans with no instant — and the machine row already dates
  observations by when provisiond learned them, "never at the unknown instant the provider acted"
  (`STO-48`). An operator-supplied onset would make `observed_at` mean "last confirmed" under
  `provider_api` and "began" under `operator_notice`.
- Its one reader is the operator chasing a stale record: ADR-0038 "The rendered `observed_at` shows the
  record's age". A re-record after a fresh check moves the time forward — the freshness signal. A notice
  date makes a re-confirmed lock and a forgotten one look the same. The notice's own date lives behind
  `operator_ref`.
- ADR-0038 already chose: "when it was recorded" / "the operator's record time".

## Defects in my framing (verified)

1. "The recording time is already in `SEC-32`'s audit record" — false: SEC-32 lists "correlation id, tenant,
   authenticated identity, … operation kind, target machine, and outcome", no time; SEC-33 keeps audit
   apart from any view.
2. "Refuse a future instant; default to recording time when omitted" — two meanings in one field;
   backdating still passes; an instant before the machine row is legitimate for a resolution-attached
   machine.
3. Replays: a client re-reading its clock under the same idempotency key gets a mismatch; a typo'd
   instant needs a correcting record.
4. "The two must agree" is wrong in the other direction too: "Nothing is ranked" — selected timestamps need
   not increase.

## Edits

`WIR-47`: body `{"status": "restricted", "operator_ref": "..."}`; withdrawal `{"status": "unknown"}`;
`operator_recorded_at` is the recording transaction's clock; a repeat record moves it forward; replay
preserves the original. ADR-0038 dated note. 05-persistence `operator_recorded_at`, `provider_observed_at`
("when the flag was read"); DOM-27 drops the STO-44 cite. CNF-233: a record at t1 renders t1 (never a body
value); a second record at t3 renders t3; replay. CNF-250 per Q15. Fable: a finding on WIR-50's undefined
operator-supplied `observed_at` (same gap, other route). Formal: none.
