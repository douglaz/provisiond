# r77 Panel B — opus (claude-opus-5-5, xhigh)

**Votes:**

| Question | Package | Mark |
|---|---|---|
| Q1 | Y-PROV | AMEND (A1, A2; both wording/preservation, behaviour unchanged) |
| Q1 | Y-WIDE | AMEND (same A1, A2) |
| Q1 | **Final preference** | **Y-PROV** |
| Q2 | M-S | AMEND (B1 changes a witness's parameters; B2 is proof-only) |
| Q2 | M-I | ACCEPT |
| Q2 | **Final preference** | **M-I** |

M-I is my Q2 preference because printed M-S turns the existing CI control red. Scratch evidence is in this round's TMPDIR (`tmp/opus-*`, including `opus-ms.diff` and `opus-mi.diff`); the same answer is in `../opus.draft.md`. My clone is back at pin `1fc54e8`, and nothing was committed.

## 1. Q1 — pv-ymjo

**Why Y-PROV.** The owner rule is `WIR-9a`: "Neither key is rendered from markers a restore may have rolled back". It rests that rule on `STO-54`, which says of exactly those rows that "a null marker there does not mean the disk is untouched". `STO-54` says it of "a `running` install found after a restore … with its `OPS-45` markers as the backup holds them".

- No backup holds the markers of an install admitted after step (3). The pass that moves it after a crash is `OPS-15`'s ordinary sweep ("runs at every startup, the record open or not"), not a rollback.
- Y-PROV keeps the base facts on rows whose provenance is intact: "`none` where this operation is established to have written nothing" and "`clean` where the driver's end-rescue call returned success".
- Under Y-WIDE, the same crashed fresh row shows `unknown` if it crashed before the operator closed the record (`STO-56`), and `clean` if it crashed after. The wire output then depends on paperwork, not on the row.

**Why Y-WIDE is still acceptable.** It is coherent and fails safe: `unknown` is never the lie `CNF-302` exists to prevent. Choosing between the two is a policy decision.

**Mechanics of the shared provenance write:**
- **Early enough.** It runs in the acknowledged transaction that establishes the restore record, which `STO-54` requires before any component starts.
- **Survives successors.** "MUST NOT repeat that initialization" plus "MUST NOT be cleared" means a process crash is never treated as a rollback.
- **Second restore.** A second actual restore re-marks a formerly fresh row that is still unsettled.
- **Promotions.** In my reading, a promotion `STO-54` classifies as a restore is covered too, because the record is committed into the promoted store.
- **Rescue address and port.** These agree with `RSC-19` only after A1. Rendering after the payload purge holds.

**Cost concerns, separate from baseline losses:**
- **Bulk write.** Each restore adds one bulk write over the unsettled install and rescue-inventory rows.
- **Legacy rows.** The pre-column rule never says what "establishes" provenance, so in practice every pre-column row's facts are hidden. The brief declares this cost.
- **Nested restore.** `STO-56` says both "One row per restore" and "at most one row may have `closed_at` null", and doesn't say how a restore over an already-open incident gets its record. This gap predates both packages.

**Undisclosed side effect (both packages; no checked verdict changes).** The shared write also marks rows already in `needs_reconciliation` in the backup. Their markers are final: `OPS-3` says "Resolution transitions out of `needs_reconciliation` are made by no worker". Today those rows render their markers; under either package they become `unknown`/`unknown`.

## 2. Q2 — pv-8mt4

**Why M-I.** M-I is the only package acceptable exactly as printed. My direction favours M-S with B1 and B2: one field produces the harm, and the mutant matches an engine that finishes startup without sweeping. That is a repair needing its own complete-form reading, not a vote.

**What the old `passDone` gate protected.**
- **Conforming model:** nothing changes; `S_current_step_eq` proves equality in every state and for every event.
- **Mutant:** `passDone` was the only link between "no sweep" and "no claim", which is exactly pv-8mt4's coverage gap.
- **M-I:** M-I keeps that link and adds a second guard, `requirePass = false`, which also lets a restart claim right after `lock` with no pass at all.

**Checks I ran, in my clone at the pin:**
- **Probe.** `check/probe-models.lean` recompiled: rc 0. An injected false cell went red, so the probe genuinely checks.
- **M-S integrated:**
  - `successor_sweeps_running` needed no change.
  - **Seven other proofs broke** on the nested `if`: `step_create_not_failed`, `step_safe_restart`, `step_quarantined_restore`, `step_gen_restore`, `step_absence_restore`, `step_parent_restore` and `step_parent_any`. Each closed with an added `split` or `(try split)`; no statement changed.
  - `lake build` and `lake exe gate` both rc 0.
- **M-S against the existing CI control** (`ci.yml`'s own sed setting `passEveryStartup := false`):
  - As printed: **2 reds**. `ci.yml` rejects that ("more than one red"), so printed M-S turns the existing control red.
  - With B1: 1 red, naming `postStepTwoPower`.
  - Reverting the mutant's new branch turns both the amended old negative witness and the new negative witness red.
- **M-I integrated**, four named witnesses with parameters written inside each one, build rc 0:

  | Flip | Reds |
  |---|---|
  | false/false witness, `runI false` → `true` | 1 |
  | false/false witness, mutant params → `restoredWorkParams` | 1 |
  | existing `ci.yml` flip | 1 (on `postStepTwoPower`) |

  The new CI step must flip values inside one witness. Flipping the probe's shared `skipped` definition turns two cells red.
- **Not run:** the full `tools/check-all.sh` on either prototype.

## 3. Brief defects

None of these is a premise error; all are package defects.
- **M-S, CI:** "using startupPassGuards/current" breaks the existing control (fixed by B1).
- **M-S, proofs:** "adapt only its proof" names the wrong theorem; seven others need proof-only repairs (B2).
- **Q1, wire text:** "every key required above" also reaches `rescue_address`, `rescue_port` and the per-kind table keys (A1).
- **Q1, `STO-54` text:** the replacement silently deletes "so a null marker there does not mean the disk is untouched and the operator resolves such a row as ambiguous" (A2).
- **Q1, `needs_reconciliation`:** the side effect above is undisclosed.

The source quotes and line ranges match the pin, and none of my votes rests on a brief error. Applying notes.md rule 6 exactly as written (this prompt adds no void rule), neither tally is voided by my reading.

## 4. Internal consistency

- **Q1:** the table, the conformance cells and both package rules agree. The one conflict is that "every key required above is rendered `unknown`" contradicts "`unknown` rescue exit retains the address-and-port requirements above", and `rescue_port` cannot be "unknown".
- **Q2:** M-S's "using startupPassGuards/current" conflicts with "The existing negative control still flips only passEveryStartup", given `ci.yml`'s one-red rule.

## 5. Requested counterarguments (not votes)

- **Q1, against Y-PROV:** its safety rests on one bulk write being run by every restore path, including operator-run promotions and the nested case `STO-56` leaves undefined. A missed write shows `none` on a rolled-back row. Y-WIDE's write on each transition while the incident is open catches every old row a second time, and it matches the current body's literal wording ("the post-restore startup pass moved").
- **Q2, against M-I:** the existing one-field control stays blind, because its stranding witness still freezes every claim. M-I needs two guards off for a harm that M-S shows with one.
- **Q2, against M-S:** it rewrites the transition about 20 theorems reason over (seven proofs needed repair) and redefines an existing, documented mutant.

## Exact repairs

**A1 (both Q1 packages; wording only; behaviour unchanged, matching each package's table and conformance cells).** In the shared WIR-9a replacement:
- **Before:** "every key required above is rendered `unknown` where `restore_markers_untrusted` is true"
- **After:** "`disk_effect` (install) and `rescue_exit` (both kinds) are rendered `unknown` where `restore_markers_untrusted` is true"

**A2 (both Q1 packages; preservation; behaviour unchanged).** In the shared STO-54 replacement:
- **Before:** "…as the backup holds them. See the marker-provenance rule above…"
- **After:** "…as the backup holds them, so a null marker there does not mean the disk is untouched and the operator resolves such a row as ambiguous. See the marker-provenance rule above…"

**B1 (M-S; behaviour changed: witness parameters only; the model and `current` are unchanged; declared coverage cost: no CI flip reaches the positive progress witness).**
- **Before:** "using startupPassGuards/current and the single passEveryStartup=false mutant"
- **After:** "using restoredWorkParams and `{ restoredWorkParams with passEveryStartup := false }`; the positive witness MUST NOT use Restore.current, so the existing control's single red stays `successor_sweeps_power` on postStepTwoPower"

**B2 (M-S; proof-only; behaviour unchanged).**
- **Before:** "adapt only its proof if required by the factored branch"
- **After:** "it needs no change; the factored branch requires proof-only repairs (an added `split`/`(try split)`, statements unchanged) in step_create_not_failed, step_safe_restart, step_quarantined_restore, step_gen_restore, step_absence_restore, step_parent_restore and step_parent_any"
