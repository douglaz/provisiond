**1. What the text forces.** The story ends with an operator. `OPS-15` says "MUST move every `running` operation to `needs_reconciliation`" (03:348). `OPS-38` says "A create that recorded none … is **Unresolved**" (03:627-628). `OPS-27` says "Escalate to an operator" and "Released per `OPS-33`" (03:473), which on Robot is "bounded by **operator response time**" (02:1037). `OPS-45` "does **not** reach `create`" (03:1334). One path reaches the same end without any restart: `OPS-21`, "cancellation MUST be treated as an ambiguous outcome" (03:1645-1646).
- **Fact 4 holds, and is worse than stated.** `PRV-9`'s per-order key is still uploaded on a `none` channel, and 05:382 says "`ssh_key_fingerprint` on Robot" with no channel scope. So step 8 may write a fingerprint or nothing; the text doesn't decide.
- **Fact 5 holds.** "a claimed create with no entry … does not dispatch" (04:1423-1424) is not guaranteed on a `none` channel. "with an entry MUST be treated as potentially dispatched" (04:1428) stays true.
- **Fact 6 holds.** Only `OPS-45`'s markers are "acknowledged by the store before the provider call it precedes" (03:1446-1447). `STO-3`'s list (05:20-21) doesn't include step 8's write.

**2. Soundness.** For "no step-8 record" to prove "no provider mutation":
- **S1, every mutation comes after step 8.** Already forced: "MUST order the following steps as listed" (03:681).
- **S2, step 8's write is acknowledged before step 9.** The fix must add this, using `OPS-45`'s sentence.
- **S3, step 8 writes a record on every channel.** The fix must add this.
- **S4, step 8's write carries `STO-3`'s worker guard, claim term included; zero rows means exit with no step 9.** The fix must add this. The startup pass and a surviving old worker then contend on one row, so the rule holds even where `OPS-47` fails (03:137-138). With one engine nothing overtakes a live create worker: `OPS-8` never refuses a null `machine_id` (05:380), and `API-58`/`API-63` act only on `queued` rows.
- **S5, the pass tests "no record" inside its conditional write, not in a read before it (`STO-1`).** The fix must add this.
- **S6, the pass reads the store the worker wrote.** A restore breaks this (fact 7; `restore_breaks_soundness` in the formal layer). **There is also a gap:** no text says what promoting an async standby counts as (05:1449-1451, `local` commit). A promotion can lose a committed step 8 after the order went out, and `STO-5` covers only "process restart". The fix must say that any store which lost committed writes takes `STO-54`'s branch. If it doesn't, the operator ends up paying for a machine nobody recorded.

**3. Pick: shape (a), home `OPS-15`, settle `failed`.**
- **The column:** `operations.order_armed_at`, written once with `COALESCE` in step 8's transaction on every channel, under S2 and S4, and null on every other kind. Its rule lives in `OPS-43` step 8.
- **The exception:** in `OPS-15`, on a restart only, a `running` create with the column null MUST settle `failed`. The guard is `(id, status = running, kind = create, order_armed_at IS NULL)`. The create never enters resolution, so `OPS-29`'s "unresolved, not a guess" is untouched.
- **Error and `retryable`:** `internal` naming the restart, as for refresh (03:375-376), with `retryable: true` because nothing was bought.
- **`OPS-11` reading:** `OPS-11` doesn't classify it: "an operation interrupted rather than classified is `OPS-15`'s" (03:1386). The exception must say so, because `internal` (03:262) and a cut-off `conflict` (03:264-265) are both ambiguous on the create row. No existing kind is honest here; a new `conflict` reason is the alternative, and that's the owner's call.
- **`LDG-39` row:** "Deterministic rejection before acceptance", which is "**Never debited**; released with the commitment". `STO-58`'s exclusion is freed.
- **What it costs:** the startup pass starts writing money, under `LDG-35`. Today it writes none, because the fee obligation is already stored at admission (`LDG-67`: "that home is the create's record in `operations.request_summary`").
- **`API-63`:** "the correlator entry is what tells…" becomes "`order_armed_at` is what tells…", and "with an entry" becomes "with it set".
- **Other edits owed:** `STO-3`; `OPS-45` (03:1336-1337), whose "rather than from anything the engine can record about itself" this falsifies; `OPS-38`; the Marker entry in `CONTEXT.md`; `passOp` in `Restore.lean`; and a CNF next to `CNF-290`. That CNF kills the engine before step 8 commits and expects `failed`, with a control that kills it after the commit and expects `needs_reconciliation`.
- **Rejected:**
  - **(b):** `OPS-38` counts "every correlator the operation recorded", and `PRV-26` wants the correlator "opaque and unique". The index at 05:301 and the machine-row copy at 05:267 also read these columns.
  - **(c):** collisions are correlated, not just short. When store retries run out, "the engine MUST exit non-zero" (03:1668), which parks every create that is mid-claim at once.
  - **Requeue, like `suspend_tenant`:** `OPS-6`'s claim number "bounds nothing", so a create that crashes the engine would loop it forever. A requeued create can also order after `API-58`'s step 4 has already run.
  - **Moving the entry earlier:** that is the state before `pv-14b`.

**4. `ADR-0035`.** My pick escapes its rejected alternative. That marker "cannot tell a key upload from an order or a rejection from an acceptance" (adr/0035:59-61), which only matters for a *set* marker read as dispatch. A null column comes before every step-9 request and needs no view into the driver. This needs a new ADR, since it amends `ADR-0016`'s startup pass and adds a column, plus a dated pointer at adr/0035:59.

**5. `pv-qga`.** Decide them together, but keep two homes. Shipped alone, `pv-k4l` makes a crash in step 4 settle `failed` while a timeout in step 4 parks. If `pv-qga` settles `failed`, this column is its evidence (the same shape as `OPS-45`'s install rule), so `pv-qga` depends on `pv-k4l`. Only in that case does `pv-qga` owe two edits: narrowing `CNF-31b`'s "pre-send `network` failure yields `needs_reconciliation`", and amending `ADR-0035`'s Q11 rejection (adr/0035:107). Merging the beads would pull both edits into `pv-k4l`.

**6. Strongest case for the other side (written on request).** Today's rule fails safe whenever an assumption breaks: a restore nobody recorded, an adapter that sends before the commit returns, a promotion nobody called a restore. The fix turns each of these into a quiet `failed` with the money released and an orphan order at the provider. It also rests on S2, an ordering that only a kill-timing drill observes. To spare the operator one `OPS-31` `absent`, which they can give from `OPS-15`'s log, it adds a column `ADR-0035` declined and money writes in a pass that writes none today. A page is the honest price of a crash mid-claim, and (c) costs nothing to build and has nothing to get wrong.

---
The same text is in `panel-r56-opus.md` in the clone (797 words), and no tracked file was edited. `br` created the untracked `.beads/beads.db.fsqlite-migration-state`; I didn't write it.
