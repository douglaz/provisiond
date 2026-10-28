1. **Q1 — Y-WIDE: AMEND; Y-PROV: AMEND. Final preference: NONE.**

The marker mechanism itself is coherent. The common rule puts initialization in “the acknowledged transaction that establishes the restore record” before either component starts, covers queued/running/already-reconciling rows, and preserves the marker columns. Another actual restore reasserts true even if its backup held false. “A successor continuing an existing incident after a process crash MUST NOT repeat that initialization” correctly distinguishes process death from rollback.

The retained column supports retained-error rendering without extending the summary: `STO-50` says “anything not on the list MUST NOT be written to it.”

Y-PROV’s cells follow its proposed “Whether the incident is still open does not itself invalidate markers of newly admitted work.” Y-WIDE’s different cells follow its explicit “This records incident scope, even where no restore rolled back that row's markers.” These are declared alternatives. Both preserve old-row unknown/unknown and the address-and-port requirement for unknown rescue exit. No recovery-key-file promise follows: `RSC-19` says “An engine crash persists nothing”. The create/power witness establishes timing, not install-marker values.

**Common feasibility amendment needed:** take a backup containing open incident R, completed step (3), a fresh install, and unexpired grace. Restore that backup again. The proposed initialization accompanies establishment of the new restore record. But `STO-56` ([05-persistence.md:1374](https://github.com/douglaz/provisiond/blob/1fc54e8f361e4a9342359388314d32c398595f62/05-persistence.md#L1374)) says “One row per restore”, “at most one row may have `closed_at` null”, and “The operator MUST NOT close the record until” its listed conditions hold.

A new open row conflicts with the index; closing R violates that MUST NOT; reusing its completed marks skips the new procedure. Neither package supplies supersession handling. This is a feasibility gap in the expressly included nested-restore case, not a false fresh-marker premise or hidden baseline wire loss.

**Costs, separately:** both forms add retained metadata, admission initialization, and a synchronous pre-start bulk update over surviving unsettled install/inventory rows. Backlog and indexing determine recovery latency and WAL cost. Conservative pre-column initialization deliberately conceals additional legacy facts. Y-WIDE additionally conceals trustworthy fresh facts and writes provenance in each specified transition. Y-PROV requires preserving the distinction correctly. No migration or runtime conformance execution was supplied or run.

2. **Q2 — M-S: AMEND; M-I: ACCEPT. Final preference: M-I.**

M-I honestly separates two global controls and preserves the original mutant’s blocked-claim result. It does not claim that `passEveryStartup=false` alone produces the composite harm. Its false/false trace strands both rows 4 and 3 while row 5 actually runs/applies. Restoring `requirePass` blocks row 5; restoring the sweep reconciles rows 4 and 3. The claim rule contains no selected-row or desired-result premise. `ADR-0025`’s distinction stands: “A proof is about the model under its stated hypotheses”.

M-S’s model semantics also work. The old `passDone` gate protected this process’s sweep before claims, independently of step (2)’s durable mark. M-S deliberately changes its false mutant to attest startup handling instead. It still requires the lock and handling event. All-state equality under `passEveryStartup=true` preserves conforming behavior. The original power witness still refutes the successor theorem without `hp`; its declared metadata change creates no vacuity.

**M-S CI amendment needed:** the existing runner ([ci.yml:917](https://github.com/douglaz/provisiond/blob/1fc54e8f361e4a9342359388314d32c398595f62/.github/workflows/ci.yml#L917)) rejects an error count other than one. The additional positive witness uses `startupPassGuards/current`, so the mutation produces two intended refutations.

My copied full-module prototype returned exactly those two `decide` failures: the preserved `postStepTwoPower` positive and the new progress positive. The existing count-equals-one check consequently fails. Extending only the comment/trace evidence cannot fix that runner. This is a CI integration loss, not a false successor theorem.

**Checks actually run:**

- Pin verified; tracked sources unchanged. Baseline and final unpiped `check-all.sh` both passed, exit 0. [Final receipt](/var/tmp/provisiond-panel-r77/sol/scratch-sol/final-gates.log).
- The supplied seven cells and both all-state/all-event equality lemmas compiled in my [extended probe](/var/tmp/provisiond-panel-r77/sol/scratch-sol/extended-probe.lean). Additional checks covered the complete power-row cells, run-level equivalence, and transfer of the unchanged successor-theorem statement to `runS`. Printed axiom checks for both step equalities and that theorem satisfied the trust policy.
- A copied M-S module initially failed existing proof scripts at the nested branch. Extra case splits restored a green full build without changing declaration signatures. My added witness also initially needed `open Restore`; correcting that scratch integration error restored green.
- Local negative probes produced the expected two M-S refutations and one corresponding refutation for each M-I guard restoration.
- Full GitHub CI and runtime conformance were not run.

3. **Brief defects and tally treatment.**

I found no verified factual error changing either motivating premise. The inherited-open-record gap is missing feasibility handling in both Q1 packages. The one-red mismatch is missing CI admission detail in M-S. My AMEND votes rest on those package gaps; neither means the quoted theorem or baseline blocked-claim computation is false. No substantive answer from another seat was read or tallied.

apply notes.md rule 6 exactly as written; this prompt adds no void rule.

Apply rule 2’s exact settling sentence: “a question is settled when at least three agree and more agree than disagree, and a tie comes to you. If grok is down, it falls back to three of four”, together with its unchanged no-verified-blocker condition. These AMEND votes do not accept the printed packages. Ties and policy/cost choices remain with the owner.

4. **Internal consistency.**

The marker tables, rendering rules and companion-field requirements agree. Their differing scopes are alternatives, not simultaneous obligations. Both model forms’ computed cells agree with the examples, including the baseline blocked cell.

The unresolved conflicts are the nested-restore obligation against `STO-56`’s record/closure constraints, and M-S’s additional current-dependent positive against the existing single-red runner. No weakening of `successor_sweeps_running` is needed.

5. **Requested counterarguments, separate from votes, and exact repairs.**

Against Q1’s provenance direction: missing one restored unsettled row can turn stale nulls into false reassurance. Both designs depend on restore-tool and upgrade correctness, and the bulk write delays startup. Y-WIDE offers simpler incident-scope reasoning while knowingly hiding fresh facts. After repair, my direction preference would be Y-PROV; that is not package acceptance.

Against my accepted Q2 preference M-I: it duplicates claim logic and needs both controls off to demonstrate the composite harm. M-S is smaller and has verified all-event equality for the valid guard. Preserving the original negative engine and exposing the independent claim-policy failure outweigh that cost for my vote.

**Exact proposed repairs — behaviour changed. Repaired forms require their own complete-form reading.**

**Q1, common STO-54 paragraph.** Before:

> Another actual restore applies the initialization again, including when an earlier incident was still open.

Replacement:

> Another actual restore applies the initialization again. An open incident inherited from the restored store is superseded under STO-56; an ordinary process successor never supersedes it.

**Q1, STO-56 fields.** Before:

> and `closed_at`, nullable.

Replacement:

> `closed_at`, nullable, and `supersedes_incident_id`, nullable, a foreign key to the retained predecessor record.

Add after its opening paragraph:

> On an actual store restore whose restored store contains an open incident R, the transaction establishing the new record MUST close R by supersession and insert a distinct record naming R in `supersedes_incident_id`, with `steps_completed = 0`, `grace_ends_at = null` and `closed_at = null`. R is retained. For provenance initialization and the start boundary, see STO-54. Supersession is the sole exception to the ordinary close conditions below: it replaces the predecessor’s outstanding recovery obligations with the new incident’s full procedure and close conditions, and no predecessor step mark satisfies a new step.

Before:

> **The operator MUST NOT close the record until**

Replacement:

> **Except for the atomic supersession above, the operator MUST NOT close the record until**

Append to the proposed conformance addition:

> Repeat the actual restore using a backup containing an open predecessor whose ordinary close conditions are unmet. Assert the retained predecessor is closed by supersession, the distinct new record names it and begins unmarked, provenance is true, and the complete new procedure and its close conditions apply. A mere process crash must create no new incident.

This introduces supersession policy and a new full restore grace; the owner must choose that policy explicitly.

**Q2, M-S CI paragraph.** Before:

> extend its owned CI comment/trace evidence to mention the new progress pair without removing the old control.

Replacement:

> Name the new witnesses `successor_progress_sweeps` and `successor_progress_strands_without_pass`. For the Restore.passEveryStartup mutation only, require exactly the decide refutations of `successor_sweeps_power` on postStepTwoPower and `successor_progress_sweeps` on progressTrace, rejecting every additional error and either missing target. Preserve the one-field mutation and original trace check. All other guard rows retain their existing one-red rule.

[Draft saved](/var/tmp/provisiond-panel-r77/sol.draft.md). No implementation or follow-on round is approved.

An unnecessary broad process listing returned unrelated command lines; no substantive seat answer was read or used.