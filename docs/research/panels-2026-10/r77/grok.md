I'll read the panel notes and the pinned sources before judging either package. The draft goes to `../grok.draft.md`; nothing outside this clone gets changed.Notes are in. Next I’ll check the pinned quotes, AGENTS.md, and the two candidate forms against the clone.The scratch proof is the part I still need to re-check. I’ll compile the candidate transitions and the cells the printed examples leave out.The draft is long. I’ll cut it to the vote, the checked cells, and the repair.## 1. Q1

**Y-WIDE: CANNOT ACCEPT. Y-PROV: ACCEPT. Final preference: Y-PROV.**

Y-PROV follows the reason the override exists. `WIR-9a`'s heading is "Neither key is rendered from markers a restore may have rolled back". The `STO-54` sentence both packages replace says a running install found after a restore goes to `needs_reconciliation` "with its `OPS-45` markers as the backup holds them, so a null marker there does not mean the disk is untouched". A process crash after fresh admission does not restore an earlier database.

The common initialization is early enough. It runs in "the acknowledged transaction that establishes the restore record", before either component starts, and sets the column true on every surviving install or rescue-inventory row in `queued`, `running`, or `needs_reconciliation`. That is before quarantine, on the rows the backup holds. A successor "MUST NOT repeat that initialization". Y-PROV says the quarantine and each startup pass preserve the column, and "Whether the incident is still open does not itself invalidate markers of newly admitted work." Closure and payload purge are forbidden from clearing it, so every later startup of the same incident keeps the bit. "Another actual restore applies the initialization again, including when an earlier incident was still open", which is why a formerly fresh unsettled row renders unknown/unknown in the last table row. A process crash is not that write.

Fresh raw-disk cells under Y-PROV are the ordinary rendering in `WIR-9a`'s first two paragraphs: null/null → `none` / `none`; write marker set and rescue false → `destructive_boundary_crossed` / `unknown`; write marker set and rescue true → `destructive_boundary_crossed` / `clean`. Rescue inventory gets no `disk_effect`. Its null/false/true cells are `none` / `unknown` / `clean`. "unknown rescue exit retains the address-and-port requirements above", so fresh (b) carries `rescue_address` and `rescue_port`, and fresh (a) and fresh (c) do not. That matches `RSC-19` and `Rescue.details` (`tools/formal/Provisiond/Rescue.lean:972–986`), which attach address and port only for `unknown`. `CNF-302`'s pre-dispatch kill, and its "restore from a backup … both keys `unknown`", stay: the restored unsettled row is initialized true. The packages do not turn `needs_reconciliation` into `failed`, replay the operation, or infer a session from status. Other kinds get false only so the column can be non-null, and gain no wire key.

Y-WIDE cannot land. It sets the flag on every open-incident transition to `needs_reconciliation`, "including a row admitted after step (3)", "even where no restore rolled back that row's markers". The shared rule says the column "MUST NOT be cleared on that operation", and the conformance text says wire values "do not change merely because of closure or payload purge". The hide is permanent. On fresh (b) and (c) the write-started marker has committed. `WIR-9a` says `destructive_boundary_crossed` "tells the caller not to assume its prior contents survived". Y-WIDE renders `unknown` for that raw-disk row. On fresh (a), and on a fresh rescue-inventory row whose rescue marker is null, `OPS-45` says "Null is the only value that means no session was opened", but the wire becomes `rescue_exit: "unknown"` and therefore carries address and port (`WIR-9a`, `RSC-19`). On fresh (c) a committed clean exit is reported unknown. Those are the package's own cells. They treat a committed post-restore crash as the rollback `STO-54` names with "as the backup holds them".

**Durable provenance and cost.** Both packages bulk-update every surviving unsettled install and rescue-inventory row inside the restore-record transaction. That cost tracks unsettled rows and is not free. Pre-column rows whose provenance cannot be established initialize true. Rendering is computed on read (`WIR-9a`: "rendered from the operation's marker columns"), so that upgrade can conceal facts on settled historical installs. That is the package's stated conservative upgrade, and it is the owner's cost choice. I am not rejecting the Boolean for it. `STO-13` still owns the migration shape: "such a column is nullable in the release that adds it and tightened after a backfill in a later one." A `DEFAULT false` backfill would trust every old row and miss the true initialization. `Rescue.rescueExit` (`@[req "WIR-9a"]`) still renders only from the column. It already omits the 2026-09-16 override. Neither package extends it. Coverage gap, not a flipped theorem.

## 2. Q2

**M-S: AMEND. M-I: ACCEPT. Final preference: M-I.**

Compiled `/tmp/q2-check.lean` with `nix develop` / `lake env lean` from `check/spec/tools/formal`. Exit 0. The file is the printed scratch (`S_current_step_eq`, `I_required_step_eq`, and the seven examples) plus the cells below. Not run: an in-place edit of `Restore.step` followed by `lake build` of `Witnesses.lean`; the `ci.yml` negative-control job; any runtime conformance.

Extra cells that closed:

- Baseline `Restore.run skipped progressTrace`: power 3 `running` and not applied; create 4 applied; `stepTwoMarked`.
- `runI false` + `restoredWorkParams`: power 3 `needsReconciliation`, create 4 applied, `passDone`.
- `runI true` + `restoredWorkParams`: those same three facts.
- `runI true` + `skipped`: power 3 `running`, `passDone = false`, `stepTwoMarked`.
- `runS skipped` on `[.lock, .startupPass]` from the restore boot: row 0 quarantined, `passDone`, `stepTwoMarked`. The false mutant still sweeps while step (2) is unmarked.
- `successor_sweeps_running_S`: same statement as `successor_sweeps_running`, over `runS`/`stepS`, closed with the existing script (`simp only` of the step, `hp`, `locked`, `passDone = false`, `Bool.true_or`, `if_true`, then the status/kind split). On this evidence the nested branch does not force a weaker statement. The `Witnesses.lean` rebuild was not run.

`S_current_step_eq` is every event and every world under `passEveryStartup = true`. `I_required_step_eq` is every event and every world at `requirePass = true`. The printed harm cell (create 4 and power 3 `running`, create 5 `running` and applied) closed for `runS skipped` and `runI false skipped`. The blocked baseline (create 5 stays `queued`, `passDone = false`) closed for `Restore.run skipped`.

**Checked-verdict loss in printed M-S.** `ci.yml:907–924` flips one field of `current` and requires exactly one `error: Provisiond/` line, a refuted `decide` whose context contains the row token. The row is `Restore|passEveryStartup|true|false|postStepTwoPower` (`ci.yml:785`). `successor_sweeps_power` is the only witness that reads `startupPassGuards Restore.current` (`Witnesses.lean:1397–1422`). M-S tells the positive progress witness to use `startupPassGuards/current` and to assert the swept rows are `needsReconciliation`. Flipping `current.passEveryStartup` to false then reddens both that witness and `successor_sweeps_power`. Two reds fail the control ("more than one red"). The printed `runS restoredWorkParams` cell would not: `restoredWorkParams` hardcodes `passEveryStartup := true`. The integration sentence and the printed cells disagree. The sentence is what breaks the control the package also says to keep. I did not execute the workflow; the loss follows from that row's sed-and-count rule plus the witness binding.

M-I leaves `Params`, `permits`, `step`, `run`, `successor_sweeps_running`, and the existing witnesses unchanged. false/false is the only combination that strands and applies create 5, and the package calls it a two-guard engine. true/false on this trace still sweeps (power 3 confirmed above) because `stepI` does not replace `.startupPass`. Written like the scratch, off `restoredWorkParams` and `skipped` rather than `Restore.current`, the four witnesses do not add a second red. The new `requirePass` control is a separate step, same shape as `ci.yml:936–960`. I did not run it.

`passDone` today protects `OPS-15`'s "before any claim". The permits docstring says "A claim also needs this process's running-row pass, independently of the record's step (2) mark." Both fault branches require `w.passDone` (`Restore.lean:350–352`). Under `passEveryStartup = true`, `S_current_step_eq` says M-S still sets the flag only together with the sweep, so the good-model gate is the same gate. The false mutant is what changes: handling can set the flag and skip the sweep. `successor_strands_power_without_pass` still refutes the unguarded sweep, because power 3 stays `running`. Replacing its `passDone = false` conjunct is the declared metadata change. The mark is AMEND because of the control loss. Conforming states do not diverge.

### AMEND — M-S witness binding

Location: "Add named positive and negative witnesses for progressTrace using startupPassGuards/current and the single passEveryStartup=false mutant, asserting all cells printed above."

Before: `using startupPassGuards/current and the single passEveryStartup=false mutant`

Replacement: `The positive witness uses restoredWorkParams, so passEveryStartup is hardcoded true. The negative witness uses { restoredWorkParams with passEveryStartup := false }. Neither reads Restore.current. Keep the ci.yml row Restore|passEveryStartup|true|false|postStepTwoPower as the only witness that flip reddens. Extend the comment at .github/workflows/ci.yml:550–551 to name progressTrace. Do not add a second row that flips passEveryStartup.`

Behaviour unchanged: `Restore.step` under `passEveryStartup = true`; `successor_sweeps_running`'s statement; `successor_sweeps_power`; the printed progressTrace cells; the existing one-red control. Behaviour changed against the integration sentence only: the new positive witness does not go red when `current.passEveryStartup` is flipped. This is not acceptance of printed M-S. It needs its own full reading. No third shape: `stepS` is already the one-function change.

## 3. Brief defects

apply notes.md rule 6 exactly as written; this prompt adds no void rule.

The excerpts I re-read match the brief, including `WIR-9a` 196–222, both `OPS-15` spans, both `STO-54` spans, `OPS-45` 1482–1498, `CNF-302` 2917–2939, and the cited Lean ranges. `fresh_work_swept_after_restore` admits creates and claims create 4 and power 3. `Op` has no install-marker fields (`Restore.lean:77–84`). The timing claim is right and is not an install-marker model. Neither question is void.

The gloss "Y-WIDE also hides valid fresh facts while the incident is open" is false of the package. The column is never cleared, and the conformance text says closure does not change the wire values. That does not void Q1: the package and the table are explicit. A vote that accepts Y-WIDE because the facts return at closure rests on the gloss.

No premise-changing Q2 error. Both claim branches require `w.passDone`, as `permits` writes them.

## 4. Internal consistency

The Q1 packages are alternatives. "Assert the exact fresh-row wire values in the selected form's table" keeps the two columns from being one obligation. Rescue-inventory prose does not add `disk_effect`. The install table does not require it there.

"It does not invalidate already-settled rows merely because they survive in a backup" is the restore initialization: `succeeded` and `failed` are outside the status list. The pre-column sentence is a different write and can conceal settled legacy rows. Read in that order, they do not collide.

M-S's examples use `restoredWorkParams` and `skipped`. Its integration sentence says `startupPassGuards/current`. Only the sentence breaks the one-red control. That is why M-S is AMEND.

M-I matches its scratch. `progressTrace` claims create 5 only after `.startupPass`, so true/false does not show a claim before the pass. The package does not say it does. The unchosen package is not a second obligation.

## 5. Requested counterarguments (not votes)

**Against Y-PROV.** The body a caller can check is broader than the heading: "On an operation the restore quarantine or the post-restore startup pass moved (`STO-54`, `OPS-15`), `disk_effect` and `rescue_exit` are both `unknown` whatever the columns hold." `OPS-15` says the pass runs "at every startup, the record open or not." A fresh row the successor moves while `STO-56`'s record is open is a row that pass moved. Y-PROV renders `none` from a null marker during that incident. `STO-54` tells the operator that a restored null "does not mean the disk is untouched", and the bit is "not added to `request_summary`'s closed enumeration", so wire `none` does not show whether the row was fresh or rolled back. Y-WIDE is the reading that does not start trusting columns the current body names.

**Against M-I.** It does not refute a skipped running-row pass. `runI true skipped` still leaves create 5 `queued`. The harm appears only with `requirePass = false` as well, a switch `Restore.permits` does not have. `ADR-0025` gives each dated guard one parameter and admits the bad trace by removing that guard. M-I admits this harm only by removing two. `stepI`'s claim arm copies `Restore.step`, and `I_required_step_eq` pins only `requirePass = true`. The one-function mutant in the plain terms — startup handling returns, the sweep did not run, a later claim applies — is `stepS`. This vote does not accept that printed package.

The same text is in `grok.draft.md`.
