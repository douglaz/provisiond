# r78b — opus (claude-opus-5-5, xhigh) — pv-75w3 S-STOP-R

## 1. Mark and preference

**S-STOP-R (S1–S4 as one package): ACCEPT. I verified it as printed and propose no repairs.**
**Final preference: S-STOP-R.**

The ACCEPT covers the printed complete forms exactly. It adds no wording, quotation or behaviour change.

## 2. Strongest actual argument

A stop that the process survives, arriving before the fence transaction is sent, already leads to a `stalled` episode with a null fence. The worker records that outcome itself. Today CNF-312 tests only the other way to reach that state: a crash followed by an operator's resolution. Read at the pin, the chain is:

1. **OPS-21.** "A cancellation of `execute` that the engine survives MUST be recorded before the engine exits."
   - The record is "the guarded write of `OPS-22`" with "a cut-off `conflict` with `details.reason: "cut_off"` (`WIR-9a`)".
   - "The record write MUST NOT be cancelled by the cancellation that stopped `execute`."
   - The stop comes before any fence transaction is sent, so there is nothing in flight to finish. The record settles the attempt, and no fence is written.
2. **OPS-11, last row.** "any failure the worker records while `OPS-45`'s write-started marker is unset, where no rescue session was opened … MUST settle `failed`, whatever its kind … unless the mutation is known to have been accepted".
   - OPS-45 sets the delete marker when "the provider call is dispatched". No call is dispatched here, so the marker is unset.
3. **OPS-48.** `failed` becomes `stalled` with the fence "**Unchanged**". "An episode none of whose attempts reached the fence transaction holds null."
4. **API-64.** A retry is "admissible only on an episode in `stalled`". It has no retryability precondition.
5. **OPS-41 step 2.** "A retry reading the fence null decides from step 3 unless the tenant is suspended now."

**This is the owner's own scope.**
- ADR-0032 quotes owner comment 194: "Covers all three routes".
- It held the third route back only because "no current clause orders a worker-recorded failure before the fence write".
- Two later clauses made that premise false:
  - OPS-21's stop record (2026-10-18, `ADR-0044`);
  - OPS-11's marker-unset `failed` row (2026-10-23, `pv-9j6`, `ADR-0046`: "Yes, settle failed (Recommended)").

**The package adds coverage only.** It runs the same decision rows, with the same expected outcomes, on a second real prefix. That prefix's own assertions catch broken builds that route 1 cannot:
- a stop record that writes `destroy_committed`;
- an episode left `attempting`;
- a cut-off classified as `needs_reconciliation`;
- a provider call.

Route 1's operator resolution (`not_applied`) never runs the worker's cut-off record path. So nothing today asserts that this path leaves the fence null and the episode `stalled` before step 2 reads them.

**Adversarial trace.** The trace is: enqueue → claim → stop before the fence is sent → shielded record acknowledged within both bounds → `failed`/`stalled`/null fence/null marker → fresh retry. Every check holds:
- **Suspension:** it now runs on both prefixes: "on separate fresh instances of each prefix, route 1 and the survived-stop prefix". The table cell reads "For each prefix, use its suspension fan-out above."
- **Orders A and B:** they run on "separate fresh instances of each prefix". The read/commit instrumentation comes after that paragraph, so it applies to both.
- **Fenced controls:** both "retain their own prefixes" and are unchanged.
- **No substitutes:** "No crash, startup classification, operator resolution or manually seeded stalled row substitutes for this prefix". The prefix also requires "no later stop or superseding generation". The selection paragraph adds "this is a recording-success fixture, not abandonment or a lost-reply/later-stop case".
- **Store-error warning:** kept word for word: "Do not inject a store error as a separate failed route".
- **Generation loss and bound exhaustion:** these exits still belong to CNF-362, which is untouched.
- **Nothing undisclosed:**
  - no fixture restriction beyond the brief's;
  - no extra payload;
  - no `retryable` assertion, which matches CNF-362's "Make no assertion about `retryable` for the other cases";
  - no new retryability rule;
  - no executable Lean change.

### Conditions

1. **Exact landing.** Land the printed complete forms exactly. Replace both `<landing date>` placeholders in ADR-0032 (the Status line and the amendment line) with the landing date. A placeholder left in would be a defect.
2. **Lean unchanged.** Leave executable Lean unchanged: no definition, hypothesis, theorem, guard or witness edit. The gate must be green at landing.
3. **Costs accepted.** The owner accepts the coverage costs in §8. These are costs, not policy.

## 3. Exact repairs

None. Behaviour is unchanged. The observations in E3 are not repairs, and none of them changes a verdict.

## 4. Requested strongest counterargument (labelled; not my vote)

*Counterargument:*
- OPS-41 step 2 reads only the transaction's state: the fence, current suspension and funding. ADR-0032 already says the rule is "keyed on the fence, not the route".
- Route 1 yields the same `failed`/`stalled`/null-fence row. Re-running Orders A/B and the suspended row on a second prefix therefore tests no new decision logic.
- The prefix also largely repeats CNF-362, which already drives "power, reverse DNS, delete and release attachment cut off before their write-started marker write settle `failed`".
- So the package pays for three more fresh instances, a stop hook and restart orchestration, and gets duplicated coverage.
- It also leaves a title ("Interrupted cancellation") that no longer describes its second prefix.

*Why I do not adopt it:*
- I read all of CNF-362 (lines 1669–1804). A grep finds no "episode", "stalled", "fence" or `destroy_committed` in it. Its only "retry" hits are `retryable` and the Store-retry bound.
- So CNF-362 never places a delete before the fence, and never follows the cut-off row to a retry decision.
- What remains untested is how the worker's record path combines with the step-2 decision. That is what "Covers all three routes" asked for.

## 5. Broken brief claims (rule 6)

None found. No question's premise is voided, and no vote here rests on a brief error. I checked:
- S1's "the only edits are …", by diffing `check/cnf312-before.md` against the complete form;
- that every before-passage matches the pin;
- every quoted owner, inside its owner section:
  - "The loss is not a later stop" is at 03:150, inside OPS-47 (03:135–1275);
  - the refused-generation sentence is at 03:1995, inside OPS-50 (03:1983–2002);
- that `StopRecord.working_store_records` and `Fence.extension_first` exist;
- that `failBeforeFence` → `finish … .failed .failed` → `applyRow`/`episodeStep` gives `(.stalled, false)`;
- that the witness gives `failed … = some .stalled ∧ … fence = none`;
- the chronology: ADR-0044 is dated 2026-10-18 and ADR-0046 is dated 2026-10-23.

## 6. Checks actually run

1. **Applied S1–S4.**
   - I applied each pair in `check/edits.json` to my clone and asserted that each before-text occurs exactly once.
   - The resulting CNF-312 region and ADR-0032 file are byte-identical to the complete forms.
   - The Lean diff touches only docstring and module-comment lines.
2. **Gate on the applied package.**
   - I ran `nix develop --command bash tools/check-all.sh` unpiped. It exited **0**, and all seven gates passed: formal, identifiers, fixtures, obligations, coverage, citations and regions.
   - The citations gate reports "none new against baseline 6", and no Lean docstring quotes are missing.
   - Log: `tmp/opus-gate-after.log`.
3. **No `CNF-` identifier** appears in `tools/formal/` after S4 (`grep -rn` returned nothing).
4. **Quotations.** Each was checked with a whitespace-normalised substring count against its owner file.
5. **Baseline.** I restored the clone to the pin (`git checkout -- .`, clean) and ran the same gate there. It exited **0**. Log: `tmp/opus-gate-pin.log`.
6. **Reads:**
   - OPS-11, OPS-15, OPS-21 (whole), OPS-41 and its note, OPS-42, OPS-43 steps 1–2, OPS-45, OPS-48;
   - API-64, API-68;
   - CNF-312 (after form, whole), CNF-361 (the steps 1–8 cancellation), CNF-362 (whole), CNF-271's note;
   - ADR-0032 (after form, whole) and the README withdrawal rule;
   - a grep for `` `execute` `` across the root specs, `docs/adr/` (including ADR-0044) and `CONTEXT.md`;
   - in `Fence.lean`: the intro, `finish`, `applyRow` and `failBeforeFence`; also `Tables.episodeStep` and `Witnesses.interrupted_retry_prefix_witness`.

**Failures:** none.

**Not run:**
- There is no implementation and no fixture runner, so nothing was exercised at runtime. The gates do not execute fixtures.
- No new proof was needed.
- I did not read other seats' answers.

## 7. Policy

- **Existing decisions.** The package stays within ADR-0032's fence-keyed policy (comment 194, "Covers all three routes") and ADR-0046's marker classification.
- **No new rule.** It changes no rule, field, classification, retryability or serialization.
- **Normative text.** The only edit to `03` sits inside the non-normative model-verification note.
- **No new owner policy decision is needed.** What remains for the owner is the usual adoption and cost decision.

## 8. Costs (reported separately)

- **Extra conformance runs.**
  - Three more fresh instances on the survived-stop prefix: Order A, Order B and Suspended/null-fence. The last has its own fan-out.
  - Null-fence decision instances go from 3 to 6. The fenced controls are unchanged.
- **Injection and instrumentation.**
  - A hook that delivers the stop inside cancellable `execute`, between the claim and the first fence send. Route 1 already needs a kill at that point; only the action differs.
  - Observing that the record write is acknowledged while the store stays healthy within both bounds.
  - Reuse of the existing fence read/commit instrumentation and the provider call counter.
- **Restart orchestration.**
  - The engine exits after the record, so each instance needs a restart before its retry or fan-out. At that restart OPS-15 finds no `running` row to reclassify.
  - The harness supervisor must follow OPS-21's "MUST wait at least the Stop-record bound after a stop before it kills the engine". An early kill turns the instance into route 1, which the case says does not substitute.

---

## Evidence

### E1. Rule-1 check of the whole package

**Rules.** Every quoted owner is exact once whitespace is normalised:
- OPS-21's sentences;
- OPS-49's "repeat the **whole transaction**" and "the engine MUST exit non-zero";
- OPS-11, OPS-45, OPS-48, OPS-15, OPS-42, OPS-41 step 2 and OPS-50.

**Rules, examples, scope and acceptance criteria agree:**
- **Prefix assertions.** Each of the prefix's assertions follows from §2's chain: `failed`, the cut-off `conflict`/`"cut_off"`, `stalled`, null `destroy_committed`/`write_started_at`, and zero provider calls.
- **Fan-out and table.** Both now select "each prefix", which removes the r78 mismatch.
- **API-58.** Its rule that an open episode gets no new enqueue still holds, because `stalled` is open.
- **Scope.** ADR-0032:30 no longer claims to list every route. The Q14 scope paragraph is kept under "Historical scope" with the owner quote verbatim. Rejected alternatives (2)–(4) are unchanged.
- **OPS-41 note and Fence text.** Both keep the larger trace set and both boundaries: "no … running-service conformance" and "does not model stop delivery, bounded recording or their composition".
- **CNF-271.** Its "`CNF-312` covers the interrupted, never-fenced prefix" is still true and does not claim to be exhaustive.

### E2. Removed text: purpose and verdict lost

| Removed or replaced | Purpose | Verdict lost |
|---|---|---|
| CNF-312 "`OPS-45` says … orders no such failure before this fence write" | Justified not driving a worker-recorded route | None. It recorded a fact that has since changed. |
| CNF-312 "`OPS-23` … establishes no such ordering either. Therefore drive route 1 alone." | The route-1-only fixture restriction | None. This is the declared fixture change. |
| CNF-312 "fresh instance of that route-1 … prefix" | Instance independence | None. Kept, and extended to each prefix. |
| Fan-out and table "route-1 prefix" | Suspension before retry on a null fence | None. Now applies to both prefixes. |
| ADR-0032:30 "The established … routes are crash and restore" | Listed the routes known at the time | None. No longer exhaustive; Q14 is kept as history. |
| OPS-41 note "Pre-fence failure is an over-approximation, not a specified injection point." | Stopped the model from claiming conformance | None. "The proof establishes no … running-service conformance" is kept. |
| Fence intro/docstring "no implementation conformance fixture", "OPS-49 store failures are not classified" | No conformance claim; store errors excluded | None. Replaced by "Implementation observations remain conformance obligations" and "store errors alone are not classified by this event". Comment-only. |

No CNF assertion or Lean theorem becomes changed, unreachable or vacuous. No MUST or SHOULD is lost. **There is no blocking loss under rule 3.**

### E3. Non-blocking observations (not repairs)

- **(a) Scope of `execute`.**
  - No sentence says outright that a delete's fence transaction runs inside `execute`. The prefix depends on that window: "while `execute` is cancellable and before the first fence transaction is sent".
  - The text supports the window:
    - CNF-361 says "Also cancel `execute` at each of steps 1-8 on each channel", and those are the create's claim-time steps under OPS-43.
    - OPS-21 lists "`OPS-43`'s step-8 transaction or an `OPS-45` marker write" as store transactions "inside `execute`".
    - OPS-21 says "every provider call that outcome depends on is made inside `execute`".
  - I searched for an explicit span or contrary text by grepping `` `execute` `` across the root specs and `docs/adr/`, including ADR-0044, which introduced the stop record. `CONTEXT.md` has no `execute` entry. I found nothing that places claim-time work, or the delete fence, outside `execute`.
  - This does not block. To block, a reader would have to quote text placing the delete's fence transaction outside cancellable `execute`; that would make the prefix impossible to satisfy.
- **(b) Title.** It still says "Interrupted". In OPS-45's vocabulary that word names the OPS-15 crash route. The body names both prefixes, so the title selects nothing.
- **(c) Restart.** The prefix never says "restart". That is the orchestration cost in §8, not a contradiction.
- **(d) ADR heading.** "Historical scope … superseded" sits over the owner quote, but what is superseded is the scope claim, not the owner's rule. The amendment's "The decision remains keyed on the fence, not the route" carries that rule forward.
- **(e) Markers.** CNF-312, the OPS-41 note and the Fence text carry no pv-75w3 marker. This matches the README rule that wording which "merely records a fact that changed" is "deleted outright — no marker". ADR-0032 carries the dated amendment.

---

This text is also saved as `/var/tmp/provisiond-panel-r78/r78b/opus.draft.md`, and the clone is clean at cebdc4f. This read used no grok; that seat is run separately. Separately, the grok tool connection failed to start in this session, and the Gmail, Calendar and Drive connectors need signing in through claude.ai's connector settings.
