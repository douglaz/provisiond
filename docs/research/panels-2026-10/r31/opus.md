**Q16a. Verdict: the counterexample is reachable, and V8 is not the fact that decides it. Your rule is safe but redundant. Withdraw `PRV-42`'s identity resolution and let `OPS-27` resolve auction creates.**

- **It doesn't need B ≠ A.**
  - `PRV-42`'s absent row depends only on `PRV-36`'s window (`02-provider-contract.md:1069`), measured "from the dispatch of the create" (`03-operation-lifecycle.md:1354`).
  - Robot orders "poll through an `in process` state with no documented bound" (`03:1451`).
  - `OPS-33`'s `ADR-0035` guard covers only "a matched order that is still in progress", and the identity read never matches an order.
  - So a slow order reads 404 past the window and closes absent, which loses `OPS-36`'s late attach. V8's guard never runs.
- **V8's guard collapses into `OPS-27`.** It checks `server_number` "on the transaction". After a lost reply, only `PRV-32`'s search can reach that transaction: V7 says the by-id fetch "needs the id that a lost reply never delivered". Your rule is therefore `OPS-27`'s search-then-read plus a redundant read. Reading the transaction's `server_number` handles B ≠ A with no guard.
- **What dropping the identity read costs, against `PRV-42`'s "four counts" (`02:1071`):**
  - Exact match and per-attempt discrimination: the fingerprint already gives both.
  - Ordering permission: moot. Placing the order needed it, and `OPS-27` already says "Before the terminal write the system MUST search the correlator across every ordering channel" (`03:484-486`).
  - Retention is the only real cost. An order still unmatched after 30 days goes to `OPS-31`, after `OPS-33` has already released the commitment.

**Defects in your framing:**
- "Keep the order's per-order fingerprint": nothing removed it. `PRV-9`, `PRV-26` and the settle-time search already require it. The false sentence is "the correlator is unnecessary" (`02:1048`).
- Leaving it `[verify]` costs something. `ADR-0036`'s claim covers only `offer_is_resource` offers (`02:1054-1055`). Declaring that flag triggers "MUST prefer the identity read" (`02:1080-1081`), yet the italic says it "is `[verify]` before a driver depends on it" (`02:1085-1086`). A Robot driver must break one of the two.

**Strongest "don't build":** the withdrawal itself, since it only deletes. After it, nothing depends on "offer id = server number". It stays an observation (`08-provider-notes.md:419`) rather than a `[verify]`.

**Edits:**
- `PRV-42`:
  - Keep the `ADR-0036` claim and the check that the offer is still listed.
  - Redefine `offer_is_resource` as "the offer names one machine".
  - Withdraw the resolution clause, the table, the four counts, "MUST prefer" and the italic, in the corpus's withdrawn form.
- `CNF-285`: resolution reads the transaction's `server_number`.
- Research note: supersede V8's consequence and drop written inquiry 3.
- A new ADR recording V8's guard as the rejected alternative.
- Formal layer: no change. No declaration carries `@[req "PRV-42"]`, and `Reconcile.lean` models only the search path.

**Q16b. Verdict: the conflict sits in the sweep's test. Your rule fixes it only if it also binds the sweep. "Delete on settlement" is smaller, and correct once you add one guard.**

**The Manager's conflict, precisely:**
- `PRV-9` says "MUST NOT remove them until the provider has actually consumed the key material" (`02:133-134`).
- `OPS-32` deletes a tagged key "whose operation is not `running`" (`03:1422-1424`).
- Startup moves every `running` operation to `needs_reconciliation` (`03:1481`), and `ADR-0035` sends every failure after acceptance there too.
- So after a crash or a failed poll during an asynchronous deploy, the sweep deletes the key before the provider has used it. That is `DEF-6` arriving through the sweep. `CNF-303` (`10-conformance-checklist.md:2382-2385`) currently requires this deletion.

**The root cause** is "on the same footing as an image" (`03:1424`). Images are purged "on entry to `needs_reconciliation`" (`06-rescue-install.md:473-474`) for `ADR-0005` privacy, and a public key carries no privacy reason. Also, "Its private half died with the process" (`03:1425`) is false for create keys: they are the caller's `ssh_public_keys` (`13-wire-contract.md:642`).

**Gaps in your rule:**
- It doesn't say whether it binds the sweep.
- "Robot: rescue booted" covers rescue, not create. A Robot create's key can be used up once the order is `ready`, and that key is also the correlator (`03:1427-1430`).
- Cherry (V19) is missing.
- Rescue needs no new rule. The engine's own SSH login proves the key was used, and `PRV-21` deletes it afterwards.
- "Until resolved" has a hole: `OPS-27` row 1 can attach a machine that is still deploying.

**Smaller rule** (home in `PRV-9`, cited by `OPS-32`): delete a temporary key once its operation has "settled or vanished" (`RSC-42`'s sweep wording, `06:480-481`) and no machine it produced reads `provisioning` (`01-domain-model.md:103`).
- **Failed or cancelled before acceptance:** deleted.
- **Failed or cancelled after acceptance:** the operation is in `needs_reconciliation` ("Resolution-pending, not terminal", `CONTEXT.md:76`). The key is kept until `OPS-27` or an `OPS-31` operator verb settles it.
- **Operation record missing** (`STO-14` retention, `05-persistence.md:1365`, or a restore): deleted, because unrecorded machines are never auto-attached.
- **Robot:** `OPS-33`'s correlator search applies only to an operation that "remains open". `OPS-32`'s Robot exception can therefore go.
- **Why the guard is needed:** nothing in the spec says a create settles only once the provider has finished building. That gap should be named.

**Do providers charge for or limit lingering keys?**
- No provider documents a charge for keys.
- Uniqueness is the real limit. Hetzner Cloud returns `uniqueness_error`, "SSH key with the same fingerprint already exists", and Robot returns `409 KEY_ALREADY_EXISTS` (research note `:151`, `:255`). DigitalOcean's spec documents no duplicate error, and I couldn't settle Cherry's from its docs.
- So a caller's key held by an unresolved operation blocks that caller's next create on the same account. No rule handles this collision even today (two concurrent creates with one key), and keeping keys longer stretches it to however long an operator takes.

**Strongest "don't build":** don't poll each provider for key use in the sweep. Keep V2, V18 and V19 as `[verify]` until live batches A3–4, C2–3 and D2–3 run; those tests would only justify deleting earlier.

**Edits:**
- `PRV-9`: state the rule above.
- `OPS-32`: cite `PRV-9`, and drop "not running", the "private half" sentence and the Robot exception.
- `CNF-303`: a crashed create's key survives until both conditions hold.
- `DEF-6`: cite `PRV-9`.

**Formal layer:**
- `OPS-32`'s key sweep is not formalized (`Reconcile.lean:46`), and `sweepRemovesCredential` at `Rescue.lean:979` removes the key unconditionally.
- In a scratch copy I made that sweep step a no-op while `needsReconciliation` is unresolved, and added a theorem stating it.
  - `check_formal.sh` exited 0 with 801 tagged declarations, up from 800.
  - `uncertain_exit_persists_the_key` and `crash_leaves_the_credential_registered` still prove.
- Limits: the model only reaches `needsReconciliation` through a crash. Tag the new theorem `OPS-32`; the prose at `Witnesses.lean:3055-3057` goes stale.

The full gate suite passed on the unmodified clone (exit 0), and I edited no tracked files.
