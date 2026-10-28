# r78b — pv-75w3: complete survived-stop coverage form S-STOP-R

The owner's r78 tally instruction authorizes this follow-up read. Review only; no adoption, tracker write, implementation, Run or automatic further round. Pin **cebdc4f8f728f40d7fdf3c10ed094a1a7d2b8527**. Work only in your independent detached clone under /var/tmp/provisiond-panel-r78/r78b/ and your ../<reader>.draft.md. Read this brief and that folder's notes.md whole. Main checkout, its branches/tracker, manager brief, other panels and production are off limits. No br, branch changes, commit, push, subagents or background work. No credential/session/config reads, including ~/.claude, ~/.codex and ~/.grok.

Five seats: fable claude-fable-5-1 xhigh, opus claude-opus-5-5 xhigh, astra gpt-6-astra high, sol gpt-6.1-sol xhigh, grok grok-4.7 xhigh. Timeout 3600 per seat; MemoryMax=16G, MemorySwapMax=0, OOMPolicy=continue; npm-global first on PATH, TMPDIR in this folder. Save a substantive draft by minute 45 and return a final answer in this turn, about 1400 words plus exact repairs/evidence.

**apply notes.md rule 6 exactly as written; this prompt adds no void rule.** Apply rule 1 to the entire package. Give ACCEPT / AMEND / CANNOT ACCEPT and one explicit final preference S-STOP-R or NONE. An AMEND names exact before/replacement and behaviour changed/unchanged. Fixture changes, new runtime duties, restrictions and proof mechanisms are behavioural. A preferred direction is not complete-form acceptance. Separately check that rules, examples, scope and acceptance criteria agree. A requested strongest counterargument is not your vote.

Plain terms: a worker has picked up a deletion, but has not sent the transaction promising to delete. A stop arrives, the process survives and the store acknowledges its stop record in time. Existing rules settle that attempt as failed, with no promise to delete written. Should the existing retry checks also run from that real stop route, alongside their crash-and-operator-resolution route?

## What changed since r78, and what has not been settled

Read /var/tmp/provisiond-panel-r78/tally.md and the five previous final answers there (fable.md, opus.md, astra.md, sol.md, grok.md), particularly the exact repairs. They are prior opinions, not acceptance of this form. r78 Q1 is already 5–0 by explicit preference for K-EXACT and is outside this read. r78 Q2 had one countable conditional wording-only acceptance and four behavioural AMENDs: no settlement. This combined form is **unreviewed until this round**.

The specific retained suspension selectors contradicted the new two-prefix instruction. The old span description also risked deleting the read/commit instrumentation; the new form keeps those lines literally. ADR-0032's old scope remains visible as historical, its owner quote survives, and the earlier crash/restore description becomes non-exhaustive. Source attributions carry quotations. The Fence description states its fixed failed outcome and retained larger trace set without claiming model composition.

The current classification follows ADR-0046's 2026-10-23 alignment, together with OPS-21's survived-stop obligation; do not date the entire result from the 2026-10-18 stop-record amendment alone. Do not claim later-stop, lost-reply or supersession exits universally leave a running row: an earlier sent write may already have committed. Those are not this acknowledgement-success fixture.

## Checked source boundaries

All before passages below are exact at the pin, verified against git-show. The source snapshots under check/ are evidence, not a changed specification. No candidate has been implemented or runtime-tested. Initial/final baseline gates do not execute conformance fixtures.

- OPS-21 says "A cancellation of `execute` that the engine survives MUST be recorded before the engine exits" and "The record write MUST NOT be cancelled by the cancellation that stopped `execute`". Its record is the guarded OPS-22 write, error "a cut-off `conflict` with `details.reason: "cut_off"`". Check the owner directly for exact punctuation and exits.
- OPS-11's last row says "any failure the worker records while `OPS-45`'s write-started marker is unset" and "MUST settle `failed`, whatever its kind", below goal-state success and except known acceptance, with the rescue condition. OPS-45's delete marker row says "the provider call is dispatched". WIR-9a's conflict reasons include `"cut_off"`.
- OPS-48's failed row is stalled with fence "**Unchanged**", and says "An episode none of whose attempts reached the fence transaction holds null." OPS-41 step 2 says "A retry reading the fence null decides from step 3 unless the tenant is suspended now."
- OPS-49 says "the component MUST repeat the **whole transaction**" and "the engine MUST exit non-zero" on exhaustion. A store error alone is not worker-classified failure. OPS-50 says "A refused generation check ends recording without another attempt; an earlier attempt may already have committed with its reply lost." OPS-47 says "The loss is not a later stop".
- Fence.failBeforeFence matches holding plus an attempt and calls finish with .failed/.failed. Inspect finish, applyRow, Tables.episodeStep, the interrupted_retry_prefix_witness, extension_first and StopRecord.working_store_records. Fence and StopRecord are not composed. No executable definition, hypothesis, theorem, guard or witness changes.

## Whole candidate S-STOP-R

All of S1–S4 is one package. Its declared behavioural change is conformance coverage: the selected decision rows run under two real prefixes, with the same expected outcomes. It adds no runtime classification, fence, field, retryability or serialization rule and no new proof. The acknowledgement-success/no-later-stop boundary is explicit; it does not redefine abandonment or lost-reply handling.

### S1 — replace the complete CNF-312 item with this complete item

This is the final item, not a partial algorithm for choosing an ambiguous span. Compare with check/cnf312-before.md. The only edits are the old scope paragraph's tail and route-selection paragraph, the fan-out selector, and the suspended/null-fence table selector. The crash prefix, instrumentation, fenced/undispatched prefix, deciding observations, discriminating controls and restore scope remain.

```markdown
- [ ] **CNF-312** — **Interrupted cancellation before its fence (2026-10-05, `pv-gip.43`, Q14).**
      Exercise `OPS-41` step 2 and `OPS-42` ordering on independent instances with an
      available rate, a healthy provider account and no other admission refusal. Each starts
      unfunded with an active tenant; the suspended row below changes that tenant's state.
      For Orders A and B, provide sufficient available balance and choose an extension that
      funds the machine at the deciding rate. The other rows use a favorable rate and
      re-derivation to fund it, without an extension.
      **Route 1 prefix:** let the sweep enqueue the cancellation and the worker claim it, then
      kill the worker before its fence transaction. Restart: `OPS-15` requires "move every
      `running` operation to `needs_reconciliation`" and "MUST NOT move them back to `queued`".
      Assert that operation state and episode `uncertain`. Resolve `not_applied` as operator:
      assert the attempt `failed`, episode `stalled`, null `destroy_committed`, null
      `write_started_at`, and zero provider calls throughout the prefix. Drive the actual
      lifecycle; manually seeded stalled rows and startup requeue do not satisfy this case.

      **Survived-stop prefix:** on a fresh independent instance with the same funding, account
      and tenant conditions, enqueue and claim the cancellation, then deliver a stop while
      `execute` is cancellable and before the first fence transaction is sent. Keep the engine
      alive and the store working until its stop record is acknowledged within the stated
      bounds, with no later stop or superseding generation. Assert the original attempt
      settles `failed` with cut-off `conflict` and `details.reason: "cut_off"`, the episode is
      `stalled`, `destroy_committed` and `write_started_at` remain null, and no provider call
      occurred. No crash, startup classification, operator resolution or manually seeded
      stalled row substitutes for this prefix. For stop classification and recording, see
      `OPS-21` and `OPS-11`.

      Drive Orders A and B and the suspended/null-fence row on separate fresh instances of
      each prefix: route 1 and the survived-stop prefix. The fenced rows retain their own
      prefixes below. Do not inject a store error as a separate failed route: `OPS-49` requires
      "repeat the **whole transaction**" and on bound exhaustion "the engine MUST exit non-zero".
      Keep the record store available within both stated bounds; this is a recording-success
      fixture, not abandonment or a lost-reply/later-stop case.
      Instrument the deciding fence transaction's read/commit boundary:
      retry enqueue alone establishes neither transaction order.

      **Fenced, undispatched prefix:** drive a real cancellation through its unfunded fence
      transaction and wait for commit, then kill the worker **before the dispatch-marker
      write and provider call**. `OPS-42` says the worker "releases it before the provider
      call".

      `OPS-45`'s delete marker row says "the provider call is dispatched". Assert the
      marker is still null at the injection boundary; a kill merely before the call does
      not establish that. Restart through the same startup classification, then resolve
      `not_applied` as operator. `OPS-45` says "an operation interrupted rather than classified
      is `OPS-15`'s, whatever the markers hold"; `OPS-48`'s resolved-not-applied row is
      `stalled` with the fence "**Unchanged**". Assert the original attempt `failed`, episode
      `stalled`, fence still holding that episode's id, original attempt's `write_started_at`
      null, and zero provider calls throughout this prefix.

      **Suspension fan-out:** on separate fresh instances of each prefix, route 1 and the survived-stop prefix, suspend the tenant. `API-58` says the
      pass "MUST NOT enqueue" for an already-open delete episode, and must "append
      `tenant_suspended` to that episode's `reasons` set" and "name its `current_operation_id`
      in `cancellations`". Assert the same episode and its current failed attempt account for
      the machine, the reason is appended, the parent terminates, and the fan-out enqueues
      no new cancellation attempt.

      | Case | Required observations |
      |---|---|
      | Order A: extend, then retry | Extension admits and commits before the retry's fence transaction. The attempt settles `succeeded` with a no-mutation result; episode `closed`/`funded`; fence null; provider call count remains zero. The extension's commitment is kept: reconcile any legitimate metering independently and assert no cancellation-driven commitment release. |
      | Order B: retry's fence transaction commits unfunded, then extend | Observe the fence holding the episode id before submitting the extension; it returns `409` / `cancellation_committed`, with no balance movement or commitment growth attributable to that refused extension. The provider is called. |
      | Fenced control | Use `CNF-271`'s provider-failed stall after fencing, accept a favorable rate and re-derive future runway without clearing that fence. Retry still calls the provider again and does not close `funded` through a funding abort. |
      | Fenced, undispatched control | Use the fenced, undispatched prefix above. Accept a favorable rate and re-derive funded runway without clearing the fence. Retry the same episode: observe a provider call and no funding-abort close to `funded`. The original attempt's `write_started_at` remains null; distinguish it from the fresh retry attempt's own initially unset marker. |
      | Suspended, null fence | For each prefix, use its suspension fan-out above. Accept a favorable rate and re-derive funded runway while suspension remains current; do not extend. Retry as operator and observe that the deciding transaction reads a null fence and a currently suspended tenant. Observe a provider call and no funding-abort close to `funded`. |

      These assertions discriminate unconditional retry bypass (Order A), a funding re-check
      on every retry (fenced control), and a missing extension fence (Order B).
      The **fenced, undispatched control** fails a build that keys retry bypass on the
      **previous attempt's `write_started_at`** instead of the episode fence: it re-checks
      funding and closes `funded`, violating both the provider-call and no-funding-abort
      assertions. That build passes Order A and the dispatched/provider-failed controls.
      The **suspended, null-fence row** fails a build that branches to the null-fence funding
      path **before considering current suspension**: it closes the funded machine's episode
      and omits the provider call, violating the same assertions. `OPS-41` step 2 instead
      says "A retry reading the fence null decides from step 3 unless the tenant is suspended
      now." Preserve `CNF-271`'s timer and keep controls and `CNF-272`'s fenced/resume controls.
      These new rows specify implementation observations, not additional model results:
      the existing Fence model's interrupt handles only the pre-fence holding phase and
      carries no persisted dispatch-marker history.
      **Restore scope, inspected rather than rehearsed here:** `OPS-41` says "A claim made while
      a restore record is open and its `grace_ends_at` is null or in the future defers, and writes
      no fence" and "The rule applies whichever path enqueued the cancellation — a delete
      re-run by step (2), an operator's retry". That claim gate precedes this item's decision;
      after it, step 2's null-fence path uses the same ordered funding decision as a re-run
      delete, including step 3's "Only if the predicate would cancel" paused-grace check.
      `STO-54` directs goal-state kinds to "re-run, since `OPS-11` classifies ‘already in the
      target state’ as `succeeded`". Text inspection finds no retry/first-attempt exception when
      the provider already deleted but restore rolled the fence back: both retain the claim
      gate and ordered decision; a dispatched delete uses that existing goal-state result.
      A funded abort can precede dispatch on either path while the restored row still says
      present. This item does not drive route 2 or establish restore conformance; that remains
      with `CNF-218` and `CNF-295`. (`OPS-15`, `OPS-31`, `OPS-41`, `OPS-42`, `OPS-48`, `API-64`,
      `LDG-62`, `STO-54`)
```

### S2 — OPS-41's complete model-verification paragraph

Replace only the paragraph beginning `*Model verification amended 2026-10-05 (pv-gip.43)` (with its actual backticks) by the complete paragraph below. The source before paragraph is check/ops41-note-before.md. Other OPS-41 clauses remain.

```markdown
*Model verification amended 2026-10-05 (`pv-gip.43`):
`Provisiond.Fence.extension_first` uses the admitted extension's null fence directly to exclude
the guarded retry exemption. It covers ordinary and retried attempts without assuming either
reachability or a previously fenced episode. The enlarged lifecycle admits interruption,
resolution and abstract pre-fence failure; the former RetryFenceInv and retry_has_episode_fence
are withdrawn, falsified by sweep, claim, interrupt, resolve notApplied, retry with an open
episode and null fence. For the survived-stop record see `OPS-21`: "A cancellation of `execute` that the engine survives MUST be recorded before the engine exits"; for the pre-fence conformance prefix see `CNF-312`. The model does not compose stop delivery or bounded recording with this lifecycle. The proof establishes no full crash/restore procedure, queue scheduling, database
serialization, provider behavior or running-service conformance.*
```

### S3 — complete ADR-0032 after the amendment

Use the actual landing date instead of every `<landing date>` placeholder; this read does not invent it. Preserve all rejected alternatives and the historical owner quote. No second argument home is added elsewhere. The complete resulting ADR follows; its exact original is check/adr0032-before.md.

```markdown
# Revival is an operator decision

**Status:** accepted (2026-10-04, `pv-gip.11`, owner decisions Q11/Q12); amended
2026-10-05 (`pv-gip.43`, Q14); amended <landing date> (`pv-75w3`).

A decision to delete deserves care before it is made. A provider hiccup followed by a favorable
rate is no new decision to keep a machine. Automatic revival made that accident choose for the
operator, while overloading retry with revival made the operator's intent ambiguous.

The rule homes are `OPS-41`, `OPS-48`, `API-64` and `API-68`; the wire home for keep is
`WIR-55`. This decision supersedes `ADR-0021`'s retry-as-withdrawal argument and its accepted
no-exit residual, preserving its gone-write and permanent-close reasoning.

Rejected alternatives from the Q11 panel: closing in re-derivation (Opus/Sol) would let price
maintenance reverse the deletion decision; a second sweep population (Astra) would add a second
lifecycle scanner for the same automatic reversal. The original Q12 decision (narrowed by Q14 below) rejects retry that revives: an
operator asking to retry deletion should not unknowingly keep the machine. An explicit keep
records that choice without pretending it pays for the machine.


## Q14: the decision is recorded by the fence — 2026-10-05

Owner decision on `pv-gip.43`, comment 194, narrows Q12. The owner's Q12 reason on `pv-gip.11`,
comment 178, was "the decision to delete was made when the fence was written". A never-fenced
episode has no recorded deletion decision to reverse: its retry decides from funding and can close
`funded`. `OPS-41` step 2 is the sole normative home; this addendum owns the reason. Q11's
operator decision remains necessary to leave a stalled episode, apart from the gone-write;
price maintenance alone does not close it. No state, verb, close reason, column or row is added.

The crash and restore null-fence stalled routes run through `OPS-15`: "move every
`running` operation to `needs_reconciliation`". For restore its warning is "the row may have
settled at the provider inside the lost interval". `OPS-31`'s `not_applied` outcome is "it did
not, so it settles `failed`"; `OPS-48` renders "Resolved `not_applied` — the machine is still there" as `stalled`
with the fence "**Unchanged**". Neither route manufactures the missing fence.
After a restore, a rolled-back fence counts as never written: a decision made in the lost
interval is not honored. The retry decides as a re-run delete does under `STO-54`, which directs
goal-state kinds to "re-run, since `OPS-11` classifies ‘already in the target state’ as
`succeeded`". The original restore claim gate remains ahead of that decision: `OPS-41` says
"A claim made while a restore record is open and its `grace_ends_at` is null or in the future
defers, and writes no fence". That gate is distinct from step 3's funding-only paused-grace
check, reached "Only if the predicate would cancel".

**Historical scope (2026-10-05; superseded by the amendment below).**

Owner comment 194 says "Covers all three routes", including worker-recorded pre-fence
failure. The fence-keyed rule covers that condition if such an ordering is ever specified;
no current clause orders a worker-recorded failure before the fence write: `OPS-45` says "This rule classifies a failure a worker recorded";
its interruption rule applies "whatever the markers hold". `OPS-23` requires validation
"before the driver is called", which does not order it before the fence. Store failures instead
follow `OPS-49`'s "repeat the **whole transaction**" and, on exhaustion, "the engine MUST exit
non-zero". Thus this amendment specifies no separate route-3 injection. The model deliberately
admits abstract pre-fence failure as an over-approximation; `CNF-312` drives the established crash
route only. In every case the rule is keyed on the fence, not the route.

*Amended <landing date> (`pv-75w3`):* `OPS-21` says "A cancellation of `execute` that the engine survives MUST be recorded before the engine exits". `CNF-312` owns the survived-stop pre-fence prefix alongside its crash prefix. For classification see `OPS-11`; for the record and its bounded exits see `OPS-21`; for extension/retry ordering see `OPS-41` and `OPS-42`. For store errors see `OPS-49`: "the component MUST repeat the **whole transaction**". The decision remains keyed on the fence, not the route.

Rejected alternatives:

- (2) `not_applied` closes the episode: no existing close reason is true there; the fix would key on one route rather than the fence.
- (3) Fence earlier: a crash would decide deletion without the re-check.
- (4) Startup requeue: the proposed alternative covers the crash route only, using the
  interrupted attempt's markers to choose requeue. Restore can roll those markers back too;
  they cannot establish what happened in the lost interval (`OPS-15`: "the row may have
  settled at the provider inside the lost interval"). The accepted rule uses the restored
  record, with the missing fence treated as above; it does not preserve a lost fence or
  reinstate startup requeue.

The former RetryFenceInv and retry_has_episode_fence are withdrawn: sweep, claim, interrupt,
resolve notApplied, retry leaves an open episode and a null fence. The replacement extension
proof uses that null fence directly, and the interruptedRetry witness compares the guarded and
unguarded policy. These are model results, not running-service conformance; full crash/restore,
queue scheduling, database and provider behavior remain outside those proofs.
```

### S4 — explanatory formal text only

In tools/formal/Provisiond/Fence.lean replace exactly this module-introduction passage:
```
`failBeforeFence` over-approximates worker-recorded pre-fence failure: no current ordering
clause establishes that injection point. Proofs cover this larger trace set, which supplies
no implementation conformance fixture.
```
with:
```
`failBeforeFence` admits worker-recorded failure before fencing, including a survived-stop
record; see `OPS-21`: "A cancellation of `execute` that the engine survives MUST be recorded
before the engine exits". It does not model stop delivery, bounded recording or their composition
with this lifecycle; the event assumes that record landed with the attempt `failed`. It still
admits failures beyond that specified route; the larger trace set is retained. Implementation
observations remain conformance obligations.
```

Replace exactly this declaration docstring:
```
/-- Abstract worker-recorded failure before fencing. This is an over-approximation, not an
established injection point; OPS-49 store failures are not classified by this event. -/
```
with:
```
/-- Worker-recorded failure before fencing, including a survived-stop record; see `OPS-21`:
"A cancellation of `execute` that the engine survives MUST be recorded before the engine exits".
Stop delivery and bounded recording are outside this model; store errors alone are not classified
by this event (for the store-error path, see `OPS-49`: "the component MUST repeat the **whole
transaction**"). -/
```

Keep the immediately following tag and full definition literally unchanged:
```lean
@[req "OPS-45"]
def failBeforeFence (w : World) : World :=
  match w.phase, w.attempt with
  | .holding n, some a => finish w n a .failed .failed
  | _, _ => w
```

All other formal text and every executable declaration, theorem, hypothesis and witness remain unchanged. No CNF identifier enters tools/formal/. The event still admits failures beyond the specified survived-stop route. The landed failure outcome is assumed at this abstraction boundary; no model of stop scheduling, bounded recording, their composition or runtime observation is claimed. If composition is required for a claim this exact form actually makes, identify that claim and vote AMEND with the required boundary.

## Adversarial read and handoff

Trace real enqueue → claim/hold → originating stop before **sending** the fence transaction → shielded guarded record acknowledged within both independent bounds → failed/stalled/null fence/null marker → fresh retry. Check current suspension on **both** prefixes, Orders A/B at the deciding transaction's read/commit boundary, and both fenced controls. Verify every retained observation and every quoted owner. Check no undisclosed fixture restriction, extra payload, retryability rule or theorem weakening entered. A store error alone, a crash, a lost reply, later stop, generation loss or bound exhaustion cannot substitute for the selected success prefix; neither can a seeded stalled row. Conversely do not erase their existing exits.

Name the purpose of each removed safeguard or historical statement and any checked/normative verdict lost. Rule 3 requires a checked changed/unreachable/vacuous verdict or a quoted MUST/SHOULD plus owner and trace for a blocking loss. Declared fixture changes are amendments, not hidden baseline loss. Report costs separately: extra conformance runs, injection/instrumentation and restart orchestration are not supplied by prose or Lean.

Return your whole-package mark and explicit preference first, strongest actual argument and all conditions, exact repairs if any, then a labelled requested counterargument. List broken brief claims with rule-6 effect, checks actually run, failures and not-run checks. State whether this stays within the existing fence-keyed policy and marker classification decisions (ADR-0032, ADR-0046) or needs a new owner policy/cost decision. No implementation or automatic further round.
