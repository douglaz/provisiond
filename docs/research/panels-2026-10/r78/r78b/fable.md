Pin verified: my clone is at cebdc4f8f728f40d7fdf3c10ed094a1a7d2b8527, clean before and after work. Draft saved at `/var/tmp/provisiond-panel-r78/r78b/fable.draft.md` (13:15Z). No tracker, branch, commit, push, subagent or background work.

# r78b — fable (claude-fable-5-1, xhigh) — S-STOP-R, pv-75w3

**apply notes.md rule 6 exactly as written; this prompt adds no void rule.**

## Mark and preference

**S-STOP-R (S1–S4 as one package): ACCEPT. Explicit final preference: S-STOP-R.** No conditions. No repairs attached. The observations below are not conditions.

## Strongest actual argument

The pinned owners already make every assertion in the survived-stop prefix true, and the package adds nothing but the fixture that drives them.

1. `OPS-21` (03-operation-lifecycle.md:1784–1785) says "A cancellation of `execute` that the engine survives MUST be recorded before the engine exits". Its record is `OPS-22`'s guarded write, with "a cut-off `conflict` with `details.reason: "cut_off"`", and "The record write MUST NOT be cancelled by the cancellation that stopped `execute`". A transaction not yet sent is not the in-flight case.
2. `OPS-11`'s last row (:248) says "any failure the worker records while `OPS-45`'s write-started marker is unset" and "MUST settle `failed`, whatever its kind". `OPS-45`'s delete marker row (:1477) says "the provider call is dispatched". Nothing was dispatched, so the marker is null and the attempt is `failed`.
3. `OPS-48` (:1292, :1303–1304): "`failed` — deterministic; the provider did not act" is `stalled` with the fence "**Unchanged**", and "An episode none of whose attempts reached the fence transaction holds null." The record never writes the fence.
4. `OPS-41` step 2 (:1123) says "A retry reading the fence null decides from step 3 unless the tenant is suspended now." Orders A/B and the suspended row therefore observe exactly what they observe after route 1.
5. `WIR-9a` (13-wire-contract.md:141) lists `"cut_off"` under `conflict`. `API-64` admits retry on `stalled`. `API-58`'s fan-out quotes "MUST NOT enqueue", "append `tenant_suspended` to that episode's `reasons` set" and "name its `current_operation_id` in `cancellations`" are exact.

The two defects that sank r78's S-STOP are closed. The fan-out selector and the suspended cell now select both prefixes, and the instrumentation lines "Instrument the deciding fence transaction's read/commit boundary: retry enqueue alone establishes neither transaction order." are retained byte for byte.

## Verification run

- The brief's S1, S2, S3 blocks and the four S4 passages are byte-identical to check/cnf312-after.md, ops41-note-after.md, adr0032-after.md, fence-intro-after.txt and fence-doc-after.txt.
- Before snapshots match the pin. CNF-312 at 10-conformance-checklist.md:2435–2517 is identical to check/cnf312-before.md. The OPS-41 note anchors uniquely at 03-operation-lifecycle.md:1184. The Fence.lean passages anchor uniquely at :96 and :982. ADR-0032 matches save one trailing blank line in the snapshot.
- The CNF-312 diff touches only the old tail (before :15–23), the new prefix and drive paragraph, the fan-out selector and the suspended cell. Route 1, the fenced/undispatched prefix, all table rows, the discriminating controls, restore scope and closing citations are unchanged.
- Lean. Fence imports Claim, Runway, Rate and Tables. StopRecord imports Claim and Tables. Neither imports the other, so "does not compose" is true. `failBeforeFence` (:985–988) matches `.holding n, some a` and calls `finish w n a .failed .failed`. `finish` (:884) makes the worker write and `applyRow` on this attempt's episode. `Tables.episodeStep` maps attempting plus settled-failed to `(.stalled, false)`, fence untouched. `interrupted_retry_prefix_witness` already evaluates sweep, claim, failBeforeFence to stalled with a null fence. `extension_first` keeps its guard, null-fence, not-suspended and current-state hypotheses. The `@[req "OPS-45"]` tag and the definition are unchanged. The Fence.lean diff is comment lines only.
- Full unpiped gate with S1–S4 applied by exact unique replacement: exit 0, 13:06:12 to 13:10:47, Lean built cold. Coverage stays at 74 uncovered, the baseline, so OPS-23 losing its CNF-312 citation regresses nothing. Citations pass, including S2's colon-form `OPS-21` quote and the EXISTS check on both Lean docstring quotes. Log: `/var/tmp/provisiond-panel-r78/r78b/tmp/fable-gate-sstopr.log`.
- Restored with `git checkout -- .`, status clean. Pristine gate exit 0, 13:12:20 to 13:13:06. Log: `tmp/fable-gate-pristine-final.log`.
- ADR quotes are not gate input, so S3's two new quotes were checked by hand. Both are exact after whitespace normalization: `OPS-21` at :1784–1785 and `OPS-49` at :1918–1919 ("the component MUST repeat the **whole transaction**"). The retained ADR quotes from `OPS-15`, `OPS-31`, `OPS-48`, `STO-54` and `OPS-41` are all exact.

## Rules, examples, scope and acceptance criteria agree

S1's drive sentence, fan-out and table all select both prefixes. S3 says `CNF-312` owns the survived-stop prefix alongside its crash prefix. S2 points at `OPS-21` and `CNF-312`. S4 says the event admits a survived-stop record with the attempt `failed`, which is what `finish … .failed .failed` does. No rule changes. The acknowledgement-success, no-later-stop, no-supersession boundary is stated in S1 and matches `OPS-21`'s exits, `OPS-50`'s "A refused generation check ends recording without another attempt; an earlier attempt may already have committed with its reply lost" and `OPS-47`'s "The loss is not a later stop". S1 does not claim those exits leave a running row.

## Removed safeguards and historical statements

- CNF-312 old :15–16, "`OPS-45` says … it orders no such failure before this fence write". Purpose: justify route-1 exclusivity. As a claim about all clauses it has been false since `OPS-21` and ADR-0046. Loss: none checked. `OPS-45`'s own sentence survives in `OPS-45` and in the fenced prefix.
- Old :18–19, the `OPS-23` non-ordering sentence and "Therefore drive route 1 alone". Purpose: exclude an unspecified injection. Replaced by a specified prefix whose `cut_off` assertion a validation failure cannot satisfy. Loss: none.
- Old :22–23, route-1-only selection. This is the declared coverage change.
- Store-error ban retained verbatim with both `OPS-49` quotes. Crash route, fenced controls, extension/fence order, current-suspension precedence and the restore claim gate retained.
- ADR-0032:30's exhaustive "established … routes are crash and restore" becomes non-exhaustive. The comment-194 paragraph is kept whole under a historical label. Rejected alternatives (2) to (4) kept. README's convention deletes changed-fact wording in requirements outright, which S1 does. ADRs are decision records and keep their history, which S3 does.
- Fence.lean's "over-approximation, not an established injection point" becomes an accurate description. The larger trace set and non-composition are kept. No theorem, hypothesis, guard or witness changes.

No blocking loss under rule 3. No CNF assertion is changed, made unreachable or vacuous. No theorem is weakened. No MUST or SHOULD is contradicted.

## Costs, reported separately

- Conformance runs: Orders A, B and the suspended row each run from two prefixes, six instance runs for three rows, plus the survived-stop prefix's own run. Fenced rows unchanged.
- Injection and instrumentation: a stop hook after claim and before the fence transaction is sent, observation of the record's acknowledgement inside both `OVR-19` bounds, and the read/commit instrumentation already required.
- Restart orchestration: `OPS-21` makes the engine exit after the record, so the retry and the suspension fan-out run on a restarted engine. That restart is ordinary, and its `OPS-15` pass finds no `running` row from this attempt. S1 does not spell the restart out. It follows from `OPS-21`. Stating it would be a fixture step, so it is not a condition.
- No runtime test, parser run or composed proof exists for the candidate. Prose and Lean supply none of the above.

## Observations, not conditions

1. S2 adds landing-date content under the retained "Model verification amended 2026-10-05" label. README requires no marker. Nit.
2. The brief's one-sentence "declared behavioural change" omits the prefix's own new assertions (failed, `cut_off`, stalled, null fence, null marker, no call). S1 states them and they overlap `CNF-362`'s delete line. Disclosure nit, no rule-6 effect.
3. CNF-312's closing citation list omits `OPS-21` and `OPS-11`, which the body cites. The coverage gate reads the body. Nit.

## Policy boundary

The package stays within ADR-0032 (decision keyed on the fence, not the route; owner comment 194 "Covers all three routes") and ADR-0046 (owner decision "Yes, settle failed (Recommended)"). It adds no classification, fence, field, retryability, serialization rule or proof. The only owner-facing item is the conformance cost above. No new owner policy decision is required.

## Requested counterargument against S-STOP-R (not a vote)

The survived-stop prefix ends in the same durable state as route 1: `failed`, `stalled`, null fence, null marker. Repeating Orders A/B and the suspended row from it catches only a build that keys the retry decision on how the stall arose, which ADR-0032 already forbids, while `CNF-362` already asserts the delete cut-off's `failed` classification. Adding the episode, fence and marker assertions to `CNF-362`'s delete line plus one Order from the stop prefix would be cheaper. Reply: the retry decision's owner is `OPS-41` and its fixture is `CNF-312`. A build that gates step 2's null-fence path on the existence of an `OPS-31` resolution record passes route 1 and `CNF-362` and fails only here, for three extra runs on an already-instrumented item.

## Brief claims and rule 6

Every quoted passage in "Checked source boundaries" is exact at the pin. No verified brief error changes the premise, so the tally is not void. The one imprecision is observation 2. The chronology, ADR-0046 on 2026-10-23 together with `OPS-21`'s 2026-10-18 duty, is correctly stated.

## Checks not run

Runtime conformance of either prefix, stop injection, the CI negative-control steps as a separate matrix, any new or composed proof, PostgreSQL, and the landing date, which this read does not invent. Failures: none. No implementation or further round is approved by this read.
