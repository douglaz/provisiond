**Verdict:** (b) is sound and retires (a); adopt the variant that compares the whole record as an opaque value, and verify one fact live before the fingerprint half carries weight.

**Why.** The engine never needs to know *when* Robot wrote the record, only whether it is the record it saw before it reset. Equality against a copy needs no zone, no clock, no skew margin and has no repeated hour. Traces (Q1):

- **Equal `boot_time` strings.** Impossible for one server except the DST hour, where two boots an hour apart print identically; fingerprints then still differ.
- **Foreign boot, or our own retried reset, between the copy and our boot.** Its record differs and is accepted; our host presents other keys; refused, `integrity` at the deadline, `PRV-20` holds. Fails closed. (a) fails the same way whenever the foreign `boot_time` is later than our reset.
- **Partial update.** `(T2, [])` not accepted (empty). `(T1, K2)` accepted, correct. `(T2, K1)` accepted, refused at connect. `live-session3.txt:19` shows both fields arriving together.
- **Reset fails.** `PRV-18` deactivates; no session, no read. Ambiguous reset: `OPS-11`.
- **404 then a record.** Accept the first non-empty one. Residual: a transient 404, which the Hetzner docs do not define for this path.
- **Detector.** The pair (`boot_time` string, fingerprint set), non-empty fingerprints. Fingerprints alone are dead if keys persist per server; `boot_time` alone accepts the `(T2, K1)` half-update. The opaque pair survives both unknowns.

**Q2.** The read sits inside `PRV-15`'s Robot call after activation and before `POST /reset`, carried in the session value `PRV-19` takes as input ("`external_id`, the current session"; `DOM-11` is in-memory). A crash before the reset needs no durability: `OPS-45` writes `rescue_exited_cleanly=false` before dispatch and `OPS-15` says "any `running` row at startup is interrupted"; nobody refreshes that session again. A failed read is retried, then begin rescue fails before the reset and `PRV-18`'s cleanup applies. `PRV-20` implies the copy is not pin material and the first accepted set sticks; it forbids only clearing and emptying, so add that a later differing record cannot replace an accepted set.

**Q3.** Nothing remains for (a). Keep `boot_time` raw for diagnostics. Don't build: (a) compares Robot's wall clock with the engine's reset instant to answer a question the engine answers by equality, and needs a zone fact, a DST rule that fails closed one hour a year, a skew tolerance and fixtures for each. Framing check: the Hetzner docs list `authorized_key` on `/rescue/last`; if Robot populates it, the record listing our single-use key (`PRV-15`'s input) is our boot's with no baseline at all. The r45 runner printed three fields (`live-session3.txt:19` against `live-session2.txt:13`), so it is `[verify]`: one field in the next live session, which should also boot one server twice.

**Defects.**

1. "Every rescue boot generates fresh keys" is unverified: `ADR-0041:19`, `08-provider-notes.md:129`, `decisions-q27-q28.md:7`. Each server was booted once (3088292 in session 2, 3086901 in session 3). The docs say nothing. `ADR-0041:42-43`'s "match by accident" rests on it.
2. `ADR-0041:20` "within thirty seconds": first read at +44 s (`live-session3.txt:11-12`). `ADR-0041:18` "about sixty seconds": 87 s there, 91 s in `live-session2.txt:14-15`. Non-normative; `RSC-9` derives the deadline from the boot timeout.
3. `manager-blocker.md:11` says the Berlin evidence is dates only; `live-session2.txt:13` holds a timestamp sample (`created_at` 17:58:55 for a 15:58:55Z upload). Irrelevant under (b).
4. Ordering rule to replace: `02-provider-contract.md:690-695`, `10-conformance-checklist.md:3562-3563`, `ADR-0041:29-30`.
5. `Rescue.lean:25-27` and `:105-106` name the boot-time comparison in prose; no declaration models freshness, so no theorem changes.

**Edits.**

- `ADR-0041`: `## Amendment — 2026-10-12: a fresh record is one that changed since the reset (Q29)`. Replace Decision bullet 2; reword the rejected row at 42-43 to "without comparing it with the pre-reset copy"; mark line 19 `[verify]`; note one extra `/boot` read per rescue (`ADR-0034`'s counter). Status line: amended.
- `PRV-15`: "On Robot, after activation and before the reset, begin rescue MUST read `GET /boot/{n}/rescue/last` and carry the answer (`404`, or `boot_time` and `host_key`) in the session as the pre-reset copy, never as pins. A failed read is retried; if it still fails, begin rescue fails before the reset."
- `PRV-19`: "Robot refresh MUST accept the record's SHA256 fingerprints only when `host_key` is non-empty and (`boot_time`, `host_key`) differs from the pre-reset copy, compared as values; a pre-reset `404` accepts the first non-empty record. `boot_time` is never parsed."
- `PRV-20`: "A later differing record does not replace an accepted set."
- `CNF-355`: replace the equals-or-precedes case with: pre-reset record returned unchanged after reset stays awaiting; changed record pins; a non-timestamp `boot_time` string still pins; pre-reset `404`; failed pre-read fails before any reset; later differing record does not replace.
- `08-provider-notes.md:129`: fresh keys `[verify]`.
- `Rescue.lean:26,105-106`: say "pre-reset copy comparison".

**Manager repairs.** No interaction: `permitsPresented` concerns which presented identity a pinned set admits, (b) only changes how the driver set is populated; a throttled pre-read's 403 cites `PRV-5`'s alarm, which is `CNF-283`'s owner already.
