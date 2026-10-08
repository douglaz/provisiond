# Panel r20 synthesis — a failed read after an accepted mutation (T1), 2026-10-06

Readers: sol, astra (codex xhigh), fable, opus (claude xhigh); clones at 3e4b6fa. All exit 0.
Citations below verified against the files.

## Verdict: 4–0 against (a) as written ("dispatched"); 4–0 for keying on ACCEPTANCE.

- sol/astra phrase it as the driver reporting the target mutation's outcome (rejected / unknown /
  accepted-pending); fable/opus as `details.accepted` + a fourth bullet in OPS-11's ambiguity list.
  Same rule.
- Why not "dispatched": true on key uploads before the order (PRV-9) and on the order's own 4xx
  rejection — every sold-out or refused order would become a reconciliation, holding the commitment
  through OPS-33's window, spending ADR-0034's reserve, and paging an operator on Robot's standard
  channel (PRV-33) up to 20/day per account, free to an attacker. Transport death is already
  ambiguous by kind (03:251). "Accepted" requires a placed order, which the attacker pays for.
- The set already keys on acceptance everywhere but OPS-11: LDG-39 "Order accepted by the provider"
  → "Debited" (12:1080); OPS-27's entry point "the provider accepting the order in its reply"
  (03:469); ADR-0033 "debited on confirmed acceptance".
- Which request: the one that "performs the mutation" and carries the correlator (PRV-26, 02:595).
- (b) fails: Robot throttles with `403 RATE_LIMIT_EXCEEDED` (astra, fable, opus, from Robot docs),
  which PRV-5 does not map to `rate_limited`. (c) fails: the engine cannot see inside the driver's
  call (key upload vs order; rejection vs acceptance).

## Findings beyond the brief

- Robot hits T1 with no attacker: "a Robot order reports `ready` with a server number before the
  server API lists the machine" (03:445-446) — a `not_found` read there classifies `failed`. (fable)
- OPS-27's settle-time search (03:458-462) is a mandated read after acceptance on every create; it
  settles `succeeded` only on exactly one resource, and its zero-result / failed-search branch has no
  stated outcome. (fable, opus)
- CNF-31a requires the defect: "A create failing with a provider 4xx is `failed`" (10:171-172).
- LDG-39 row precedence: an accepted-then-ambiguous create must take row 3 (pending fee) until
  OPS-27's transaction. (fable, astra)
- My claim "the other kinds are fine because OPS-45 records dispatch" was FALSE (all four):
  OPS-45 "Everything else follows OPS-11's classification"; `classify` passes markers only to the
  install row (Tables.lean:178-181). Release attachment: "A successful release writes the row's
  `released_at`" (02:438), so an accepted release whose follow-up read fails keeps metering the
  customer, and OPS-32 never sweeps attachments. Resolution must write `released_at` for a release
  resolved applied. (opus, fable)
- Pre-existing, separate (opus): a delete whose 2xx is followed by a throttled PRV-45 attachment
  listing settles `failed`; only PRV-45 writes `machine_attachments`, so LDG-32 can close while a
  surviving volume bills the operator. "PRV-45 runs on every gone path."
- OPS-33's negative window must not run against a matched, still-in-process order (fable).
- Wire: a `needs_reconciliation` create of kind `rate_limited` carries `retry_after_ms` beside
  `retryable: false` (fable, 04:1214-1215).

## Edits (union)

- PRV-5: `details.accepted` on every driver error; a driver that cannot tell reports `internal`
  (already ambiguous; no implicit default); map Robot's 403 RATE_LIMIT_EXCEEDED to `rate_limited`.
- OPS-11: fourth ambiguity bullet — the mutating request was accepted — for the whole last row
  (create, power, reverse-DNS, delete, release attachment). PRV-11 becomes an instance.
- OPS-27: the settle-time search after acceptance: anything but exactly one resource is
  `needs_reconciliation`; OPS-33's window does not run against a matched in-process order.
- OPS-31/OPS-48 resolution: a release resolved applied writes `released_at`.
- LDG-39: row precedence. CNF-31a, F48's note, WIR-9a / the retry_after_ms vs retryable pairing.
- Lean (Tables only): `Failure` gains `accepted`; `ambiguous` reads it; new theorem "an accepted
  last-row failure is never `failed`"; `classify_total`, `admission_only_failed` (pin accepted =
  false), `install_marker_directions`, Witnesses.lean:2271-2283 updated. Claim/Reconcile untouched.
