**1. What the text forces today.** `OPS-15` (03:348-349): "the engine MUST move every `running` operation to `needs_reconciliation`"; the only exceptions are `refresh` (03:375) and `suspend_tenant` (03:382). The row recorded no correlator, so `OPS-38` (03:627-628) sends it to `OPS-27`'s last row (03:473): operator, "Released per `OPS-33`", which on Robot waits on "operator response time" (02:1036-1037). This holds on the auction channel too: no fingerprint was recorded, so there is nothing to search. Story confirmed.

- **Fact 4 confirmed.** `PRV-26` presupposes a correlator: "Whichever it is, the kind and the value MUST be recorded" (02:868-870). For `correlator: none` (02:79, 02:1027) no text names a stored value.
- **Fact 5 confirmed, and it reframes the bead.** 04:1423-1425 already asserts the invariant pv-k4l needs ("a claimed create with no entry ... does not dispatch") and the termination fence leans on it. Forcing its preconditions is owed to `API-63` whatever pv-k4l decides.
- **Fact 6 half-breaks.** Commit-before-call is forced: `PRV-26` "recorded on the operation row ... before the order is sent" (02:869-871), `API-63` "between the write and the call" (04:1422). Durability is `local` (05:1451), enough against a crash, not a restore. The guard is not forced: `STO-3`'s list (05:20-21) and `OPS-3`'s "A transition made by a worker" cover no correlator write, and `API-63`'s conditional write guards `STO-47`'s row on `healthy` (04:1417), not the operation.

**2. Soundness.** "No step-8 record" proves "no mutation" iff:

- (i) the record is written on every channel. Not forced (fact 4). The fix adds it.
- (ii) it commits before any step-9 call, key upload included. Forced: `PRV-26`, 04:1422, step 9 at 03:706.
- (iii) a worker whose step-8 write affects no row never reaches step 9. Not forced. The fix adds `STO-3`'s guard with `OPS-45`'s sentence (03:1439-1441: "MUST report whether it affected a row ... it exits"). Defence in depth only: `OPS-47` puts two engines out of scope (03:138-141) and exits the engine when the lock connection drops (03:145).
- (iv) restart, not restore. Forced once the exception says so, as 03:363 does for `suspend_tenant`; `STO-54`'s premise is that a create may have ordered inside Δ.

**3. Pick: (b), home `OPS-15`.**

- `05:382`: `correlator_kind` is written at step 8 on every channel, `none` (the descriptor's word, 02:79) where `PRV-33` governs; null means step 8 did not commit.
- `OPS-43` step 8: the operation-row write carries `STO-3`'s worker guard and reports rows; zero rows, no step 9.
- `OPS-15`, beside `refresh`: a create found `running` at startup with `correlator_kind` null MUST be settled `failed`, on a restart; on a restore it moves like any other row. Guard `(id, status = running, correlator_kind IS NULL)`, no claim term (05:42-45).
- Error `internal` "naming the restart" (03:376's wording), `retryable: true` (01:653: repeating the same request is safe; nothing was sent).
- `OPS-11` reading: not a classification. 03:1385-1387: "an operation interrupted rather than classified is `OPS-15`'s". `Tables.lean` untouched.
- `LDG-39` row: "Deterministic rejection before acceptance", never debited, released with the commitment (`LDG-32`), the row step 1 already uses (03:687).
- `API-63` 04:1426-1427: "Interruption can instead leave the create unresolved" becomes "Interruption before the entry settles it `failed` (`OPS-15`); with an entry it is unresolved". The 04:1423 sentence becomes true on every channel.
- `OPS-38` unchanged: "recorded none" is now literal.
- Formal: `Restore.lean:338-341` has `| .running, _ => needsReconciliation`. The exception needs a `recorded` field on `Op` (66-70), a branch under `!f.isRestore`, and `restart_never_reorders` (595) re-proved; a `failed` row is as unreachable as a quarantined one.
- One CNF item in `CNF-302`'s shape (10:2468-2469): kill before and after step 8, both channels, plus a restore.

Not (a): a new column, write-once and COALESCE rules for a fact the existing pair carries. Not the `OPS-27` home: engine evidence would become a fourth ground for `absent` (03:470) and the row would pass through `LDG-39`'s ambiguous row first. Not (c): the hold is operator-bounded, not seconds (02:1036-1038). (d) is unneeded.

**4. `ADR-0035`.** Escaped. The bullet (adr/0035:59-61) rejects a *set* marker because it "cannot tell a key upload from an order"; (b) reads only null, before step 9, where no key was uploaded either. Line 107 is scoping and is pv-qga's. A new short ADR, since the question differs; one pointer sentence in the 0035 bullet so it is not read as rejecting the null case.

**5. pv-qga.** Under (b) an interruption during step 4 settles `failed` while a timeout of the same read parks, though the live worker knows strictly more. Both consume one premise: before step 8 commits, no mutation exists. Decide together in that ADR, land as two beads, pv-qga depending on pv-k4l. Do not merge: pv-qga flips `OPS-11`'s create row, `CNF-31b` and `Tables.lean`; pv-k4l touches `OPS-15` and `Restore.lean`.

**Strongest case for the other side (written on request).** The proof is a timing invariant over `OPS-43`'s step order, which moved twice this week (pv-hsm, pv-14b). The next move of step 8 voids it silently, and the only gate that would notice is a conformance item no implementation runs yet. `OPS-15` states the posture being abandoned: "a crashed worker is exactly the case where the provider may have acted and nobody recorded it" (03:350-351). Wrong once, the cost is `LDG-13`'s unfunded machine with a customer's key on it. (c) costs one page and a delay the operator can see and price.
