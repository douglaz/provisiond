# Panel D, reader fable, `b90783d`

**Q1 (pv-buc): CANNOT ACCEPT A; pick B′ (B with a pending-record fix). Owner call.** This names no checked verdict, so it does not block. A is the exit the owner already rejected in `ADR-0044`: "**C: must not record.** Rejected: it discards worker knowledge and substitutes crash recovery even when the process and store can complete the record." Exiting at once protects nothing an exit at the bound does not: the session died with the connection, so the lock is free in both windows, and the supervisor starts no second engine while this one lives. B as drafted contradicts itself: a worker already recording a stop would read the loss as a later stop, which "ends the record as an exit". B′ says it is not one.

**What the exit protects:** the next boot's answer, "a free lock means no live engine", which is what "hold it for its lifetime" promises and the lock's only job. Nothing checked depends on it: `CNF-290` drives a refused lock only. `STO-56`'s once-per-process read is protected by `STO-54`'s stop, not by this exit.

**(b) verified:** `OPS-21`'s later-stop sentence names no source for the stop, and `STO-54`'s stop is a stop in `OPS-21`'s sense ("A kill or crash records nothing" is the other case). Every road in (b) exits unrecorded under every option, so only (a) is live.

**B's questions:** the record cannot reach the promoted store if `STO-54` is honoured, since that store is not connectable until every engine has stopped; repeats fail against the dead primary until the `STO-54` stop (a later stop) or a bound exits. `ADR-0045`'s "short of its process exiting" is exactly the bound's exit; a sent COMMIT over a dead transport is "found dead" and repeated under `OPS-49`. Nothing changes.

**Q1b:** yes, governed. Each worker in `execute` is cancelled and records a cut-off `conflict` under its row. The drafted text says so.

Drafted B′:

- `OPS-47`, replacing "where the connection carrying it is lost it MUST exit": "where the connection carrying it is lost, the engine MUST claim nothing more, treat the loss as a stop of every worker, record each under `OPS-21` within the Stop-record bound and its exits, and then exit; a record already pending when the loss is seen is not ended by it."
- `OPS-21`, after the later-stop sentence: "A loss of the connection carrying `OPS-47`'s startup lock is not a later stop: `OPS-47` says “treat the loss as a stop of every worker”, so for a worker in `execute` it is the cancellation being recorded, for one whose `execute` has returned it is recorded by the settle write, and it ends no record already pending."
- `ADR-0019`'s restatement takes the same words with a dated note; `ADR-0046` records the decision.
- `StopRecord.lean`: no constructor. `Event`'s comment gains: "A lock-connection loss is the originating stop or no event: `OPS-21` says it “is not a later stop”."
- `CNF-366`: "**A lost startup-lock connection is a stop, not a crash.** With the store otherwise working, drop `OPS-47`'s lock connection (i) during a cancellation's record and during an after-return settle write: assert the record lands, no further claim, and exit after it; (ii) with no stop and workers in `execute`: assert each records a cut-off `conflict` under its row and the engine exits only after the records land; (iii) with every transaction refused: assert exit within the Stop-record bound measured from the loss, the loud log, and `OPS-15` at restart. Assertions as `CNF-362`'s."

Touches `OPS-47`, `OPS-21`, `ADR-0019`, `ADR-0046`, `StopRecord.lean` (comment), `CNF-366`. The keepalives parameter stays.

**Q2 (pv-9j6): ACCEPT A, with D. Mechanics.** `OPS-45` already states scope and precedence ("This rule classifies a failure a worker recorded"; "Everything else follows `OPS-11`'s classification"); the row and `classify` lag it, and a `needs_reconciliation` for a delete the provider never saw is the loss `OPS-45` was written against. The `!f.accepted` guard is right, and it mirrors the create arm. One `decide` theorem pins the new arm so a later edit is a red build; it rides the existing `markerRule` control in `ci.yml`.

(i) No prose guard. The marker precedes dispatch and `PRV-5` says "A failure before any byte of the mutating request was sent MUST report `details.accepted: false`", so marker-unset-and-accepted is unreachable; only the theorem's quantifier needs the guard.

(ii) No new `retryable` rule. Install-before-marker and refresh cut-offs that settle `failed` already carry none (`CNF-362`: "Make no assertion about `retryable` for the other cases"); the four kinds join them. Pinning all three is a separate bead. `WIR-9b` is untouched.

`CNF-31a` unchanged: its stake is "a repeated provider mutation", and a pre-dispatch failure dispatched none. `Rescue.lean`'s `governs` unchanged.

Drafted Lean, under `classify`:

```lean
| .power | .deleteMachine | .releaseAttachment =>
    some (if goalState r f then .succeeded
          else if r.markerRule && !m.writeStarted && m.rescueClean && !f.accepted then .failed
          else mutationRow r f)
| .reverseDns =>
    some (if r.markerRule && !m.writeStarted && m.rescueClean && !f.accepted then .failed
          else mutationRow r f)

/-- `OPS-11`'s last row: "`failed`, whatever its kind, for any failure the worker records
while `OPS-45`'s write-started marker is unset". -/
@[req "OPS-11"]
theorem last_row_marker_unset_failed :
    ∀ (goal s : Bool) (k : Kind) (e : ErrorKind) (c : Bool) (u : Upstream) (g b : Bool),
      k.lastRow = true → k ≠ .createMachine →
      classify ⟨goal, true, s, true⟩ k ⟨e, c, u, g, false, b⟩ ⟨false, true⟩ = some .failed := by
  decide
```

D, `05-persistence.md`'s `write_started_at` row: "Null means the mutation provably did not begin (`OPS-45` owns what that settles) — but **non-null does NOT mean …". Behaviour unchanged.

Touches `OPS-11`, `OPS-21` (pointer list), `Tables.lean`, `CNF-31b`, `CNF-362`, `05-persistence.md`, `ADR-0046`.

**Q3.** Two Runs, pv-9j6 first: they share only `CNF-362` and `OPS-21` at different sentences, and pv-9j6 carries the Lean build risk.

**Against my picks (written on request).**

- Q1: A is the smaller promise. An engine without its lock is, by `OPS-47`'s own words, in "a misconfigured deployment"; letting it write for a Stop-record bound widens the window in which a second engine's boot answer is wrong, and an in-place restart drops the pool too, so the record lands only after a reconnect A would skip.
- Q2: B keeps one classifier for the four kinds. `internal` is a catch-all, and the bug it most often names is a dispatch the engine failed to mark; A settles that `failed` over a provider that acted, where `OPS-11` today pages someone.
- Q3: one Run avoids two PRs editing `CNF-362` and `OPS-21` in sequence.

**Brief errors.**

- "the 'Startup-lock connection keepalives' parameter, which exists only to detect that loss": `ADR-0019` gives it another job, "A session advisory lock survives its holder when the holder dies without closing the connection … the keepalive requirement is the actual cure". It lets the server reap a dead holder's session, so C need not delete it. `grep -n keepalive docs/adr/0019*.md`.
- Q2's second case, "a pre-dispatch `internal` (the driver fails while building the request)", is after the marker: `OPS-45` writes it "before that phase runs", the row is "the provider call is dispatched", and `CNF-362` reads that as "during their provider call after dispatch". A driver failure stays ambiguous under A; the pre-dispatch `internal` is the engine's own failure before invoking the driver. `grep -n 'before that phase runs' 03-operation-lifecycle.md`.
- Everything else checked holds, including `Event`'s three constructors, `governs` on six kinds, the free ids, and `CNF-31b`'s pre-send `network` assertion.
