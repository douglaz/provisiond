# fable — r77b Panel B Q1

Pin verified: clone HEAD `1fc54e8f361e4a9342359388314d32c398595f62`; every excerpt the brief quotes matches the cited lines byte for byte. No tracked file changed: each package was landed as literal text by `panel-scratch/apply.py`, gated, and restored. The same text is saved at `../fable.draft.md`.

## 1. Votes

- **Y-PROV-R: ACCEPT**, with two verified wording repairs (W1, W2 below; behaviour unchanged).
- **Y-WIDE-R: ACCEPT** on mechanics, same W1 and W2, with a substantive policy objection recorded in §5.
- **Final preference: Y-PROV-R.**

Both packages are mechanically complete as printed. What remains is policy and cost for the owner: W's permanent concealment of committed fresh facts, the `needs_reconciliation` scope, the legacy upgrade, and the supersession grant of a full fresh procedure and grace.

**Why P.** `WIR-9a`'s heading is "Neither key is rendered from markers a restore may have rolled back", resting on `STO-54`'s "a `running` install found after a restore goes to `needs_reconciliation` with its `OPS-45` markers as the backup holds them". A row admitted after step (3) was in no backup. The pass that moves it after a crash "runs at every startup, the record open or not" (`OPS-15`), and `CONTEXT.md`'s restart "loses no acknowledged commit". P renders the committed facts. W renders `unknown` for a committed `destructive_boundary_crossed` and a committed `clean`, and for fresh (a) renders `rescue_exit: "unknown"` with `rescue_address` and `rescue_port` for a machine never rebooted into rescue, although `OPS-45` says "Null is the only value that means no session was opened". W's bit is monotone, so that operation's wire depends forever on whether the operator had closed the record when the crash happened. W is coherent and fails safe; it is the worse policy.

## 2. Traces (check 2)

**Initialization before every startup path.** C2 ties the bulk write to "the acknowledged transaction that establishes the restore record". `STO-54` requires that transaction before either component starts, on a backup restore and on a promotion it classifies as a restore ("`STO-56`'s record is committed into the promoted store before either component is started"). A restart-classified promotion establishes no record, so it gets no write and C5 creates no incident; it continues an open R as a process successor does. A successor repeats nothing. Closure and purge never clear the bit. Staged upgrade: null renders `unknown`; backfill writes only nulls.

**Actual restore over an open R.** Baseline has no path: "at most one row may have `closed_at` null" and "The operator MUST NOT close the record until". C5 closes R in the establishing transaction and inserts N unmarked. Every guard the replaced lead protected is re-imposed by N's full procedure. N's step (3) writes its own `grace_ends_at`. `OPS-41` defers every exposure-reducing cancellation "while a restore record is open and its `grace_ends_at` is null or in the future", so no cancellation window opens between R's close and N's step (3). The per-currency paused measure restarts from N's step (3), a superset of R's remainder. N's step (2) makes every unsettled parent wait again, `OPS-32`'s two passes run again, and the late-attach check is N's. What is lost is declared and follows from Δ₂ being a real lost interval: tenants who re-issued after R's step (3) lose tokens again, and the operator's exposure runs one more interval. Continuing R's marks over Δ₂ would be the naive boot `ADR-0023` is written against.

**Second supersession, lost reply.** Chains work by induction on the single open row. The same-id retry is sound: if the first attempt committed, R is closed and the matching N exists; if not, the retry performs it, and the provenance write rides the same transaction. A *different-id* duplicate attempt would supersede N₁ with N₂ before any component starts. That is a spurious chain with no safety loss, since the full procedure still runs once and the bit is idempotent. Observation, not a blocker; any guard is behavioural and unreviewed.

**Checked verdicts.** `CNF-295` asserts "refuse close while any other prerequisite in `STO-56` remains unsatisfied" and "once the operator closes the record a restart is an ordinary one". Both concern the operator's close, which C5 leaves intact; supersession is the establishing transaction of a new restore. `CNF-300` asserts rendering with no restore; `CNF-302`'s restore step asserts `unknown` on a quarantined row. No CNF assertion or Lean theorem changes. Formal layer: `Rescue.rescueExit` (`@[req "WIR-9a"]`, `tools/formal/Provisiond/Rescue.lean:971`) renders from the column alone and already omits the 2026-09-16 override, a coverage gap unchanged by both. `RestoreTrace.store` (`Restore.lean:164`) builds a fresh unmarked record whatever the backup held, which agrees with supersession and models no closure or predecessor. `STO-56`'s one tagged theorem is step (3)'s grace write, untouched. No formalized statement changes meaning, so `ADR-0025` forces no paired Lean edit.

**Companion fields and cells.** "An `unknown` `rescue_exit` retains the address-and-port requirements above" matches `RSC-19` and `Rescue.details`. Every table cell follows from its package's C3 plus `WIR-9a`'s first two paragraphs. Rescue inventory has no write-started marker (`OPS-45`'s table says "never"), so C6's instruction to introduce no `disk_effect` there is right. Nothing in either package replays, settles, or infers a session from status.

## 3. The `needs_reconciliation` scope (check 1)

The source does not justify it as rollback protection. A row already `needs_reconciliation` in a consistent backup had its markers committed before the transition, and `OPS-3` says "Resolution transitions out of `needs_reconciliation` are made by no worker", so nothing later writes them. The inclusion only ever flips a trustworthy `none`/`unknown` to `unknown`/`unknown`, and leaves the wire more pessimistic than the operator instruction, which names only "a `running` install found after a restore". The form discloses it and tests it (C6, second paragraph), and no checked verdict depends on post-restore rendering of such a row. It is a declared conservative amendment, not a concealed loss, but it sits oddly inside P, whose point is exact provenance. Narrowing the set to `queued` or `running` is an unreviewed behavioural alternative for the owner.

## 4. Exact wording repairs (both packages; behaviour unchanged; verified against the printed text)

**W1 — C6 is a template, not landable text.** The CNF-302 addition says "Assert the selected package's fresh-row table values", "with `rescue_exit` `unknown` under both packages", "assert unknown, unknown, unknown under Y-WIDE-R and none, unknown, clean under Y-PROV-R", and "test the selected supersession rule's stated consequences and report collateral normative/checked-verdict changes". Replace with the chosen column. For P: "assert `none`/`none` for (a), `destructive_boundary_crossed`/`unknown` for (b), `destructive_boundary_crossed`/`clean` for (c)" and "assert `none`, `unknown`, `clean`". For W: "assert `unknown`/`unknown` for each" and "assert `unknown`, `unknown`, `unknown`". Delete "and report collateral normative/checked-verdict changes", a review instruction rather than an assertion, and land only the chosen table column.

**W2 — stale consequence in `STO-54` (`05-persistence.md:1616`).** Before: "The operator closes the record only under `STO-56`'s close rule (*amended 2026-10-03, `ADR-0029`*), after which a process that starts is an ordinary restart." After: the same sentence followed by "Where a later restore lands on a store holding the record open, `STO-56`'s supersession closes it and the process that then starts continues the new incident." Pointer only; C5 already says "No component starts between closing R and establishing the new record".

Optional, not required: say once that "actual store restore" means any event `STO-54` classifies as a restore, a promotion included.

## 5. Substantive objection to W (affects preference, not mechanics)

W does not record "incident scope". A worker-classified `needs_reconciliation` during the open incident, such as `CNF-300`'s failed rescue exit, keeps its facts, while a pass-moved row loses them. It records "moved by a pass while the paperwork was open", permanently, and discards `destructive_boundary_crossed`, the value `WIR-9a` says "tells the caller not to assume its prior contents survived".

## 6. Costs (separate)

A bulk pre-start write over unsettled install and inventory rows on every restore. A nullable column, a backfill and a later tightening. A new `supersedes_incident_id` field. The upgrade conceals settled legacy facts and the facts of rows admitted by previous-release writers during the overlap window. The fresh procedure brings a second credential bump and longer exposure. None measured.

## 7. Brief claims (check 4)

Every quoted span and line range matches the pin. `fresh_work_swept_after_restore` is the theorem at `Witnesses.lean:1437`, docstring from 1433, not an error. No premise-changing error found. **apply notes.md rule 6 exactly as written; this prompt adds no void rule.**

## 8. Checks run

| Check | Result |
|---|---|
| Baseline `nix develop --command bash tools/check-all.sh`, unpiped | rc 0, all seven gates PASS. Two earlier attempts hit my 590 s command cap mid-build; the build is incremental and completed on the third. |
| Y-PROV-R landed, full `check-all.sh` | rc 0, all seven PASS |
| Y-WIDE-R landed | ids, fixtures, obligations, coverage, citations, regions each rc 0, run individually; the formal gate reads no Markdown and was green |
| Not run | runtime conformance; migration or latency measurement; any Lean model of provenance or supersession |

Logs are in `fable/panel-scratch/` and `fable/panel-*.log`, untracked. The clone is otherwise clean at the pin.

## 9. Requested counterargument against Y-PROV-R (not a vote)

The current body says the override applies to "an operation the restore quarantine or the post-restore startup pass moved", and a pass while the record is open is post-restore. P renders `none` from a null marker during an incident, and the bit is "not added to `request_summary`", so a caller cannot tell a fresh `none` from a rolled-back one by the wire alone. P's safety rests on every restore path, promotions included, running one bulk write. W cannot produce that lie while the record is open.

No implementation, adoption or follow-on round is approved by this read.
