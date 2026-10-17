**1. Claims**

- **C2 breaks for one class of field.** No text stops release N from adding a field the *caller* must send. `WIR-2` only says the server can add *response* fields "without a version bump" (13:33-34). For a field the caller must send, re-sending the same body hits an N `api` that refuses it at the boundary, so `retryable: true` is false. C2 holds for fields the `api` writes itself. `OPS-23`'s own example is one: the accepted-price fields "carried on the operation's `request_summary`" (03:714-717). "Same request" has to mean a fresh key, because a same-key re-send "MUST return the existing operation" (`API-11`, 04:929-930). `PRV-40` calls the fresh-key re-send `retryable: true` and "a new operation" (02:1191-1194).
- **C4 supports the kind only.** `price_moved` states no `retryable` (03:723-724). The precedent for the flag is `PRV-40`'s claim-time closure: settled `failed`, "operation-view `retryable: true`", released under `LDG-39` (02:1188-1193).
- **C5 understates the collision.** `"state"` is the set's generic reason (04:1045, 04:1072, 13:932). On a create it is also `PRV-42`'s resource-offer guard, with `retryable: false` (04:290-294).
- **C1 holds but doesn't decide.** `OPS-43` already emits `invalid_request` at claim for an offer that became unsellable after admission, with no caller error (03:697-699). A sharper quote: "'top up' and 'fix your request' are different actions" (`DOM-20`, 01:613).
- **The list isn't called closed.** 13:125 says "Minimum keys", and `WIR-10a`'s closed enums (13:258) don't include `reason`.

**2. Pick: 1′, limited to fields the `api` writes.** Its kind, reason and flag all point the caller at the right action, re-send unchanged. `PRV-40` already uses this shape for the other claim-time failure that isn't the caller's fault. A missing field the caller must send gets what an N boundary would answer: `invalid_request` naming the field, `retryable: false`.

**3. Honest mid-roll, and it holds for the other kinds.**
- `DOM-17` asks whether a repeat is "safe and sensible" (01:653-654), not whether it succeeds at once. `halted` is `true` because "The same purchase can succeed when the gate clears" (13:162).
- An early re-send buys nothing and its commitment is released. Its cost is one `SEC-39` slot, which admission spends (04:229-231). The window is bounded: `ADR-0024` calls version skew "the normal state of every roll" (`ADR-0024`:13).
- Install settles `failed` "for any failure at all while `OPS-45`'s two markers say the disk is untouched" (03:231), and carries `disk_effect: "none"` (13:187).
- Delete is 1′'s strongest case. With `false`, an obedient caller stops deleting a machine that keeps billing.

**4. A new reason is needed.** `"state"` collides (C5). `price_moved` requires `shortfall_native` and `currency` (13:137). `idempotency_mismatch` belongs to `API-11`.

**5. Identifiers and `CNF-34`.**
- `OPS-23` (03:1673-1676) gains the kind, the reason, and `retryable: true` on the error and the operation view.
- `WIR-9a` (13:137) gains `"incomplete_record"` (`OPS-23`).
- `OPS-11` is unchanged. `LDG-39` (12:1264) covers the create's release.

`CNF-34`: Store a queued create without its accepted-price fields. Assert no driver call; `failed` with `conflict`/`"incomplete_record"` and `retryable: true` on the error and the view; and the commitment released. Repeat for an install and assert `disk_effect: "none"`.

**Strongest case for the other side (written on request)**

1′ makes every release author sort each new field into api-written or caller-sent, and nothing checks the sort. If a caller-sent field is filed as api-written, every create gets "re-send", and agents spend `SEC-39` slots looping for the whole roll. Option 2's `false` costs at most one purchase, which the caller re-makes on purpose, and it needs no sorting at all.

---

The answer is saved untracked at `docs/research/panels-2026-10/r55b/opus.md` (450 words by `wc -w`); no tracked files changed. As the brief allowed, I didn't run the gates. Every `file:line` above was checked against `cdc6adf`.
