**R (merged): ACCEPT. E (completed): ACCEPT. Pick: R.**

Neither form flips a `CNF` item or a theorem as far as I traced, so both pass the gate and I pick on the merits.

**Strongest reason: S4, which needs no misconfiguration.** `OPS-15`'s exceptions are refresh, the null-column create and the parent. `OPS-45` says "an operation interrupted rather than classified is `OPS-15`'s, whatever the markers hold". So under E, an install that never touched the disk ends `needs_reconciliation` and is delivered `retryable: false` (`API-51`). Under R it ends `failed`, the outcome `CNF-362` already asserts for a stop. That is `ADR-0044`'s rejected C: "it discards worker knowledge and substitutes crash recovery even when the process and store can complete the record". A lock loss usually comes from a store restart or a network blip, not a second engine. R's price is one Stop-record bound, with no claims and only guarded writes.

**The merge: wrong in three spans, none blocking** (replacement text below).

**Against my pick:** E keeps `OPS-47`'s one boot question and `ADR-0019`'s named limit. R lets an engine that has lost its only evidence that it is alone keep writing for a whole Stop-record bound. Under E, S1 and S2 are detours rather than people, and S4's window (before the marker) is narrow.

**Fence G: sound, YES.** PostgreSQL 18 says "A shared lock blocks other transactions from performing `UPDATE`", so the advance waits for every share-locked E1 transaction, and every later E1 transaction reads the new value.
- **Reach:** every claim and write after the advance commits. That includes dispatches preceded by a write (step 8, `OPS-45` markers), so S5's stranded rows are gone. It reaches nothing before the advance and no call already sent.
- **Contested point:** both camps are half right. What separates G from the deleted epoch is `OPS-6`'s "The value has a second writer that is not the write being guarded". But `ADR-0019` calls the claim-only form "Correct, and cheap" and rejects it on scope, not soundness.
- **Cost:** a share lock on one hot row in every engine transaction. PostgreSQL says "locking a row might cause a disk write", and concurrent lockers need a multixact ("whenever there is more than one transaction concurrently locking a row"). The takeover also waits on E1's open transactions, and `ADR-0019`'s scope is reversed.

**Fence A: sound, YES.** It guards no write and never ends worse than E. **Cost:** it succeeds only after an in-place restart with no second engine. After a blip, E1's own unreaped session refuses it (`ADR-0019`: "A session advisory lock survives its holder…"); in S5, E2 refuses it. So R falls back to E exactly where R gains most, and "once, at boot" becomes twice.

**R's S5 advantage depends on one reading.** `CNF-290` says the old process's write "affects **no row** and exits it". If "it" means the process, E1's first zero-row record exits E1 and strands the remaining post-pass rows, as under E. Correction 4 reads that exit as the worker's (`STO-3`: "the worker moves on and does not exit"; `OPS-22`: "leave the record alone, and exit"). This tension is unresolved.

**Brief errors**
1. **S3:** no text names an automatic writer of the dated outcome. `DOM-31`'s only edge from `uncertain` to `scheduled` is "resolved applied, dated", and `WIR-35`'s `applied` with a date is operator-only. But `OPS-45` says resolution "proceeds by `PRV-29`/`PRV-36`'s provider evidence where the driver can produce it". So under E, S3 is a detour or a person depending on a resolver the spec never specifies: a gap, not a separator. Meanwhile the episode sits `uncertain`, "the operator's to look at".
2. **"'Below' is right" is false.** The cut-off classification paragraph ("The worker classifies a recorded cancellation under `OPS-11`…") and the in-`execute` transaction rule both sit above the later-stop sentence.
3. **"confirmed-read" appears nowhere** (grep finds nothing). `CNF-362` says "outside the absorbed-read cases below". The brief dropped "absorbed-read" for not being `OPS-21`'s, then used a label that is nobody's.
4. **Insertion point:** placing R's sentence right after the later-stop sentence cuts it off from "The sent transaction's fate is the server's", whose antecedent is that later-stop sentence.
5. **`CNF-366`(vi)** drives only a "waiting" parent. Q1b's parent cancelled mid-fan-out is driven by nothing.
6. **Correction 4** is contested by `CNF-290` (above).
7. **Lean under E:** `money_posts_at_most_once`'s docstring "both stop events" goes stale.

---

**Replacement text (R)**

- `OPS-47`: "hold it for its lifetime" → "hold it until it exits or the connection carrying it is lost". The merged "until it begins to exit" can be read as releasing the lock when a deploy stop arrives, while records are still pending. An overlapping successor would then take the lock and sweep rows the stopping engine is still recording.
- `STO-51`: "holds for its lifetime" → "holds until it exits or that connection is lost".
- `OPS-21`: "the cancellation rules below apply" → "this requirement's cancellation rules apply". Place the sentence after "…classifies the row as interrupted”." at the end of that paragraph.
- `CNF-366`(i): "outside `OPS-21`'s confirmed-read cases" → "outside `CNF-362`'s absorbed-read cases".
- `CNF-366`(vi): "and a waiting `suspend_tenant` parent" → "and a `suspend_tenant` parent at successive fan-out positions and waiting on its children".
- `CNF-366`(v): "(the loss, or the earlier stop)" → "(the loss as the engine sees it, or the earlier stop)". The engine can only measure from when it detects the loss.
