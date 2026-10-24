## Q1 (pv-buc): CANNOT ACCEPT A, but it doesn't block: I can't name a check A flips. I pick B, amended. Behaviour changed.

**What the exit protects:** only `OPS-47`'s "hold it for its lifetime". The lock is "released when its session ends" (`STO-51`). So an engine that keeps running after losing it lets a misconfigured second engine boot unrefused. No `CNF` item checks this. `STO-56`'s read doesn't depend on the lock: it relies on `STO-54`'s stop, and `api` holds no lock at all.

That protection needs the engine to stop claiming and to exit within a bound. It doesn't need an immediate exit. A's cost is that every in-place PostgreSQL restart throws away each outcome `OPS-49` holds "retained in memory" and leaves the row to `OPS-15`.

**B as drafted gives engine X's result in case (a):** a loss after a pending stop counts as a later stop under `OPS-21`.

**Can B's record reach the promoted store?** Not if the deployment complies: `STO-54` promotes only "After every engine … has stopped", and that stop is itself a later stop. **Does `ADR-0045` change anything?** No (`STO-7`: "`OPS-21`'s stop bounds still apply"). **Q1b:** yes, this is intended, and the draft says so.

**Draft:**
- `OPS-47`: replace "where the connection carrying it is lost it MUST exit" with “where the connection carrying it is lost it MUST claim nothing more and begin no periodic pass, treat the loss as a stop of every worker not already recording one, record each under `OPS-21`, and then exit non-zero. The loss is not a later stop: a record already pending continues under its own Stop-record bound and exits.” `ADR-0046` amends `ADR-0019`'s restatement to match.
- `OPS-21`, after the later-stop sentence, and `OPS-49`'s retry-loop bullet: “`OPS-47` says of a lost lock connection "The loss is not a later stop".”
- `CNF-366`: “With no stop pending, drop `OPS-47`'s lock connection while a worker is in `execute`, and again while a create's after-return settle write repeats under `OPS-49`; separately, drop it while an earlier stop's record repeats. Restore the store within the Stop-record bound. Assert: no claim or periodic pass after the loss; a cut-off `conflict` recorded for the `execute` case; both settle writes landed, the create `succeeded` with its money posted once; a non-zero exit after the records land; and a stop after the loss is a later stop.”
- `StopRecord.lean`: no change. For a worker not yet stopped, the loss is the originating stop; for a pending record it is no event.

**Ids:** `OPS-47`, `OPS-21`, `OPS-49`, `ADR-0019`, `ADR-0046`, `CNF-366`. **Owner:** whether losing the lock may cost an outcome already in hand is a product call.

## Q2 (pv-9j6): AMEND A. Behaviour unchanged.

`OPS-45`'s scope names the four kinds, and its precedence covers them: "This rule classifies a failure a worker recorded" … "Everything else follows `OPS-11`'s classification". The marker is written "before that phase runs", so a null marker means the provider saw nothing. Sending that failure to `needs_reconciliation` pages a human for a delete that was never sent.

**Gate checks:**
- No theorem pins a last-row kind at `⟨false, _⟩`; the witnesses use `⟨true, true⟩`.
- The `!f.accepted` guard keeps `accepted_never_failed` true.
- `CNF-31b`'s pre-send `network` failure happens after the marker write, so it is unaffected.

I also take D.

**(i)** No guard is needed in the prose: acceptance implies a set marker, and the create row's prose has no guard either. **(ii)** No `retryable` rule is needed: install's pre-marker `failed` pins none.

**Draft:**
- `OPS-11`'s last row, first sentence only; the goal-state precedence and the release sentence stand: “`failed`, whatever its kind, for a failure the worker records while `OPS-45`'s write-started marker is unset (`OPS-45`, which owns the rule); otherwise `needs_reconciliation` if the failure is *ambiguous*, and `failed` if not.”
- `Tables.lean`: Draft A's arms, both guarded with `!f.accepted`. Add a witness beside `host_key_abort_witness`: a delete's pre-dispatch cut-off `conflict` at `⟨false, true⟩` is `failed`, and `needsReconciliation` with `markerRule := false`.
- `CNF-31a`: “For power, reverse DNS, delete and release attachment assert both directions: marker set, an ambiguous failure is never `failed`; marker unset, no recorded failure is `needs_reconciliation`.”
- `CNF-31b`: Draft A's cases. `CNF-362`: Draft A's cases, plus “stop a delete while `OPS-49` repeats its write-started marker write: after a first attempt that committed with its reply lost, assert `needs_reconciliation`; after one the store refused, `failed`; in both, no provider call is dispatched.”

**Ids:** `OPS-11`, `OPS-21`, `Tables.classify`, `CNF-31a`, `CNF-31b`, `CNF-362`, `05-persistence.md`. `governs` stays unchanged. **Mechanics:** `Rescue.lean`'s `@[req "OPS-45"]` `classifiedUntouched` already states the settlement on the markers alone, but its seam theorem reaches only `installRow`.

## Q3

No: run them as two Runs, one after the other. They share text in `OPS-21` but no rule.

## Against my picks (written on request)

- **Q1:** B adds a stop the engine sends itself, a carve-out and a `CNF` item, and it keeps an engine without the lock writing for up to the bound. A reuses `OPS-15`'s crash path and gives a second engine's startup pass no window to race the records.
- **Q2:** A trusts every driver to write the marker before any mutating sub-request. A driver that dispatches first turns a mutation that may have landed into `failed`, which invites the repeat `CNF-31a` guards against. B fails safe.

## Brief errors

1. **C:** the keepalives don't exist "only to detect that loss". `ADR-0019` calls them "the actual cure" for "however long the database takes to reap a half-open session" (`grep -n "actual cure" docs/adr/0019-*`).
2. **"No `CNF` item drives a lost lock connection" is wrong.** `CNF-365` drives one implicitly, with "Kill the primary" and "restart it in place" while the engine runs.
3. **(a)'s "the correlator resolves it" is false on a `correlator: none` channel.** `PRV-33` says that create "MUST resolve to an operator".
4. **(b) holds, but the two engines end up in the same state.** The lock drops when the old primary dies, before `STO-54`'s stop arrives, so engine Y's repeats have nowhere to land.

---
This answer is also saved, untracked, as `r64-opus-answer.md` at the clone root. I ran no gate and no `lake`, and edited no tracked file.
