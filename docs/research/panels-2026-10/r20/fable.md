**Verdict: a named other — (a) keyed on *acceptance*, not *dispatch*: a failure after the mutating request was answered with success is ambiguous, whatever its kind.**

**Why.** The kind rule is sound only when the error in hand is the mutating request's own answer. "Sent" marks the wrong set. It changes today's outcome in two cases: a follow-up failure after a 2xx (the hole) and the order's own 4xx (a regression). A dead connection is already ambiguous by kind (`03-operation-lifecycle.md:251`). "Accepted" marks the hole exactly, and the ledger already keys on it: `LDG-39` "Order accepted by the provider" → "**Debited**" (`12-billing-and-ledger.md:1080`), `ADR-0033` "debited on confirmed acceptance" (`:30`), and `OPS-27`'s "the provider **accepting the order in its reply**" (`03:469`). `OPS-11` is the one reader that never looked. As a fourth bullet under "A failure is **ambiguous** when" (`03:249`), it covers every kind on the last row.

**The defect is real.** I evaluated the classifier in a scratch copy of `tools/formal`: create with `rate_limited`, `not_found`, `authentication` or `provider`+4xx each gives `failed`.

- **Cloud:** `POST /servers` answers `201` with the server; the poll's `429` settles `failed`. `LDG-32` releases on "the create fails deterministically" (`12:299`); fee and first unit are never debited. Keys are copied at create (`08-provider-notes.md:54-57`, `[verify]`), so the tenant keeps root. Only `OPS-32` sees it: "An unrecorded machine MUST NOT be auto-attached … it is reported to the operator" (`03:1347-1348`), from a sweep that yields to the same throttle (`03:1358`). `failed` is terminal (`03:127-131`), so `OPS-33` and `OPS-36` never run. The operator pays until a human deletes it by hand. The caller receives `retry_after_ms` (`13-wire-contract.md:131`), so an honest agent buys a second machine.
- **Robot:** worse, with no attacker. The order polls for minutes (`08:390`), and "a Robot order reports `ready` with a server number before the server API lists the machine" (`03:445-446`). That read is `not_found`, so `failed`, with a setup fee behind it. The sweep cannot link server to operation: the "correlator lives on the order, never on the server" (`03:1345`).

**Defects in the framing**

1. **Robot does not answer `429`.** Hetzner's Robot documentation: "If the request limit is reached, the HTTP status '403 - Forbidden' is returned", code `RATE_LIMIT_EXCEEDED`. `PRV-5`'s "where the status warrants it" (`02-provider-contract.md:34`) will not make that `rate_limited`. So (b) misses the product that matters and needs (a)'s driver fact anyway.
2. **(a) turns every provider rejection of the order into a reconciliation.** `dispatched` is true on the order's own `422` or `403`. That contradicts `03:238` ("pages a human for a typo") and `CNF-31a`, "A create failing with a provider 4xx is `failed`" (`10-conformance-checklist.md:172`). It also arms r19's D3: hold the account at its resource limit, and every other tenant's create locks its commitment for `OPS-33`'s window, spends `ADR-0034`'s reserve on `OPS-27` searches, and pages an operator on a `correlator: none` channel (`02:738-754`).
3. **"The operation's mutating request" is several.** `PRV-9`'s key registration precedes the order (`02:94-96`) and its cleanup follows. `PRV-26` names the one that counts: the correlator "MUST be written in the same request that performs the mutation" (`02:595`).
4. **The hole is not only the driver's poll.** The engine's own settle-time search (`03:458-462`) is a read after the order on every create, and nothing classifies its failure.
5. **"They have `OPS-45`'s marker" is false** (below).
6. **`LDG-39` contradicts `LDG-32` here already.** An accepted-then-`failed` create matches row 1 (debit) and "released in full". After the fix it matches rows 1 and 3 (`12:1080-1082`); row 3 must govern until `03:468`'s transaction.
7. **Resolution is not only "attaches or resolves absent".** `OPS-33` releases at the negative window, then `OPS-36` says "attach the machine, then immediately route it through the exhaustion path" (`03:511`). A matched, still-`in process` order is not "A negative search" (`03:1381`); say the window does not run against it.
8. **Wire.** A `needs_reconciliation` create of kind `rate_limited` carries `retry_after_ms` beside `retryable: false` (`04-api-contract.md:1214-1215`).

**Other kinds.** The marker is never read on the last row. `classify` passes `Markers` only to `installRow` (`Tables.lean:178-181`), and marker-independence for create, delete, release, power and reverse DNS closes by `rfl`. `OPS-45` agrees: where the marker means dispatch, the answer comes "never from this column" (`03:1241`). So a 4xx after dispatch is `failed` on all four.

None of them releases money: "a power action, a reverse-DNS change and a delete open none" (`03:1111-1112`). The error runs against the tenant instead. A delete that acted keeps metering until the sweep's gone-write, "the maximum time a customer can be billed for a machine that is gone" (`12:537-538`).

**Release attachment has no such backstop.** "A successful release writes the row's `released_at`" (`02:438`), the meter runs "until `released_at` is set" (`12:316`), and `OPS-32` (`03:1283-1379`) sweeps machines, images and keys, not attachments. The same bullet closes all four, and a delete lands in `uncertain`, which evidence resolves, instead of `stalled`.

**Edits**

- `OPS-11`: the bullet.
- `PRV-5`: a `details` flag that the mutating request was accepted, with `OPS-13`'s identifiers.
- `PRV-11`: becomes an instance.
- `OPS-27`: the settle-time search's failure, and `OPS-33`'s window.
- `LDG-39`: row precedence.
- `WIR-9a`, `CNF-31a`.
- Lean, `Tables` only: `Failure` gains a field, `ambiguous` reads it, `classify_total` gains a quantifier, and `admission_only_failed` must pin the field false. That is its own "pre-provider" premise, not a weakening. `Claim` and `Reconcile` encode none of this.

**(c)** fails because the engine cannot see inside the driver's call: its marker cannot tell key upload from order, or rejection from acceptance.

**Strongest "don't build".** One sentence in `PRV-11`: after acceptance a create returns no error but that `timeout`, and a refused read is retried inside the poll. That places no order; `OPS-12` forbids only a re-poll "that re-issues the mutation" (`03:275`). No field, no Lean. It fails on `PRV-41`, "An authentication failure MUST NOT be retried" (`02:890`), which forces the driver to mislabel a `401` as `timeout`. It also cannot reach the engine's own search.

No tracked files were edited, and the full gates were not run.
