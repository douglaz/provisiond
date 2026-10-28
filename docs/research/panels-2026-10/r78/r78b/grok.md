I'll review S-STOP-R against the pin and notes only, starting with the brief's rules and the checked sources. No adoption, tracker writes, or implementation.Notes are in. Next I’ll pin the clone and check the quoted sources against the printed package.The route holds under the existing rules. One citation date in the model note is wrong, and that is the only repair.**S-STOP-R: AMEND, citation only, behaviour unchanged. Under rule 1 that verified repair counts as ACCEPT. Explicit preference: S-STOP-R.**

The printed package is the coverage form to adopt, once the model note's new sentences carry the landing date. No runtime classification, fence, marker, retryability, serialization, or proof change is required. The extra conformance runs are a disclosed cost inside ADR-0032 and ADR-0046.

## Strongest argument

A delete claimed and still inside cancellable `execute`, with the fence transaction not yet sent, is already settled by the current owners. The sweep opens the episode and enqueues the attempt. The worker claims it. With no open restore grace, `OPS-41` does not defer that claim. The stop is `OPS-21`: the engine must record a cancellation of `execute` that it survives before it exits, and that record write must not be cancelled by the stop. The record is `OPS-22`'s guarded write. Its error is a cut-off `conflict` with `details.reason: "cut_off"` (`WIR-9a`). Nothing has been sent, so there is no in-flight fence transaction for the server to finish.

`OPS-45` sets a delete's `write_started_at` when "the provider call is dispatched". That call is after the fence transaction. The marker is unset, and no rescue session was opened. `OPS-11`'s last row, aligned by ADR-0046 on 2026-10-23, says any failure the worker records while that marker is unset "MUST settle `failed`, whatever its kind", below goal-state success and except a known acceptance. The cut-off is that recorded failure. `OPS-48`'s failed row is `stalled` with the fence "**Unchanged**", and "An episode none of whose attempts reached the fence transaction holds null." The handoff is the original attempt `failed`, episode `stalled`, `destroy_committed` null, `write_started_at` null, and no provider call.

`OPS-41` step 2 then says "A retry reading the fence null decides from step 3 unless the tenant is suspended now." Orders A and B and the suspended row ask that same question. Running them after this record asks it of the stop route as well as of crash plus operator `not_applied`. The fence value is the key either way.

`failBeforeFence` matches `.holding` plus an attempt and calls `finish` with `.failed` / `.failed`. `episodeStep` maps attempting plus settled-failed to stalled and does not clear the fence. `interrupted_retry_prefix_witness` already records that shape. Fence imports Claim, Runway, Rate, and Tables. StopRecord imports Claim and Tables. Neither imports the other. `working_store_records` is the recording proof. The new comments say the event assumes that record landed failed, keeps the larger trace set, and does not compose stop delivery or bounded recording. No composition proof is required for that claim. The tag stays `OPS-45`.

Condition: the citation repair below. The `<landing date>` tokens in ADR-0032 stay until the real landing date is known. This read does not invent one. Filling them changes no behaviour.

## Exact repair

Location: `03-operation-lifecycle.md`, the paragraph that begins `*Model verification amended 2026-10-05 (`pv-gip.43`):` (pin lines 1184–1192). S2 puts the survived-stop sentences inside that 2026-10-05 note. Those sentences describe `OPS-21` as amended in 2026 and `CNF-312`'s new prefix. The 2026-10-05 note at the pin still ends "Pre-fence failure is an over-approximation, not a specified injection point."

Before: the complete S2 paragraph, including its 2026-10-05 header and the new `OPS-21` / `CNF-312` sentences.

Replacement, two paragraphs. The first is the pin text, unchanged:

```
*Model verification amended 2026-10-05 (`pv-gip.43`):
`Provisiond.Fence.extension_first` uses the admitted extension's null fence directly to exclude
the guarded retry exemption. It covers ordinary and retried attempts without assuming either
reachability or a previously fenced episode. The enlarged lifecycle admits interruption,
resolution and abstract pre-fence failure; the former RetryFenceInv and retry_has_episode_fence
are withdrawn, falsified by sweep, claim, interrupt, resolve notApplied, retry with an open
episode and null fence. Pre-fence failure is an over-approximation, not a specified injection
point. The proof establishes no full crash/restore procedure, queue scheduling, database
serialization, provider behavior or running-service conformance.*
```

The second is new:

```
*Amended <landing date> (`pv-75w3`):* For the survived-stop record see `OPS-21`: "A cancellation of `execute` that the engine survives MUST be recorded before the engine exits"; for the pre-fence conformance prefix see `CNF-312`. The model does not compose stop delivery or bounded recording with this lifecycle. The 2026-10-05 sentence above still describes that model event: it admits failures beyond the survived-stop route.
```

Behaviour unchanged. The `OPS-21` quotation is an exact prefix of the sentence at `03-operation-lifecycle.md:1784–1785`. The fixture and S3 still name the bounded exits. No checklist row, Lean declaration, theorem, hypothesis, guard, or witness moves.

## What the package changes, and what it keeps

S1's survived-stop prefix is a real stop before the fence transaction is sent, acknowledged with the store up, with no later stop and no superseding generation. Route 1 stays kill, `OPS-15` to `needs_reconciliation`, episode `uncertain`, operator `not_applied`. The driving sentence, the suspension fan-out, and the suspended table cell each name route 1 and the survived-stop prefix on separate fresh instances. The two lines "Instrument the deciding fence transaction's read/commit boundary" and "retry enqueue alone establishes neither transaction order" remain byte for byte. The fenced and fenced-undispatched prefixes, their controls, Orders A and B's observations, and the restore scope stay.

The store-error ban stays quoted: `OPS-49` "repeat the **whole transaction**" and, on exhaustion, "the engine MUST exit non-zero". S3 keeps comment 194, "Covers all three routes", inside a block marked historical, keeps every rejected alternative, and replaces "The established null-fence stalled routes are crash and restore" with "The crash and restore null-fence stalled routes run through `OPS-15`". The new ADR paragraph points at `OPS-21`, `OPS-11`, `CNF-312`, `OPS-41`, `OPS-42`, and `OPS-49`, and says the decision stays keyed on the fence. S4's executable line is still `finish w n a .failed .failed`.

Removed sentences and what they protected:

- `CNF-312`'s "`OPS-45` orders no such failure before this fence write" stopped a reader from using `OPS-45` as a schedule. `OPS-45` still only classifies a failure a worker recorded. `OPS-21` orders this record. No `OPS-45` verdict changes.
- "`OPS-23` establishes no such ordering either. Therefore drive route 1 alone" stopped a validation-failure injection and limited the item to the crash prefix. The ordering claim remains true in `OPS-23`. Dropping "alone" is the declared second prefix. The store-error ban is still in the item.
- S2's "not a specified injection point" described the model event. The repair puts it back on the 2026-10-05 note and says the new paragraph is the one that names the survived-stop route.
- ADR-0032's exhaustive "are crash and restore" named the routes then known. Crash and restore still run through `OPS-15`. The survived-stop route is the later paragraph.

No checked CNF assertion or Lean theorem becomes false, unreachable, or vacuous. `interrupted_retry_prefix_witness` still has both the interrupt/resolve shape and the `failBeforeFence` shape. Six `failBeforeFence` case arms in `Fence.lean` are untouched. Declared new coverage is the amendment under rule 3, and the baseline verdicts above stay in force.

Rules, examples, scope, and acceptance criteria agree. The prefix asserts the handoff the owners already give. The table asserts the same Order A extension-first close, Order B fence-before-extension refusal, fenced provider call, undispatched marker distinction, and suspended provider call. The suspended fan-out still quotes `API-58`'s "MUST NOT enqueue", "append `tenant_suspended` to that episode's `reasons` set", and "name its `current_operation_id` in `cancellations`". Restore stays inspected, with `CNF-218` and `CNF-295`. No CNF identifier enters `tools/formal/`.

## Cost, policy, counterargument

Cost, separate from the mark: Orders A and B and the suspended row each gain one survived-stop run. Each run has to deliver the stop before the fence transaction is sent, keep the store inside the Stop-record bound and the Store-retry bound, and come back on a later process for the retry, because the engine exits after the record. The read/commit instrumentation stays. The prose and the Lean comments do not supply that harness.

This stays inside ADR-0032 and ADR-0046. ADR-0046 already settles marker-unset recorded failure as `failed`. ADR-0032 already keys the retry on the fence. No new owner policy is required for the engine. The added runs are the coverage this form specifies. This read does not adopt the form, write the tracker, or start a Run.

**Requested counterargument, not a vote.** The survived-stop handoff matches route 1's handoff after `not_applied`: failed, stalled, null fence, null marker, no provider call. `CNF-362` already requires a delete cut off before the marker write to settle `failed` with `cut_off`, and requires the engine to exit only after that record. A build that follows the fence, as ADR-0032 requires, makes the same retry decision from either prefix. Repeating all three rows buys assurance against a provenance branch, at the cost of three more full lifecycles. One order on the new prefix would be cheaper if the only fear is a route-keyed branch.

That argument does not change the preference. The suspended row is the case that fails a null-fence funding path taken before current suspension. Running it on both prefixes is the check that the branch is absent from the stop route. The form is the right coverage once the model note is dated.

## Rule 6

No brief error voids the question. The premise holds: this acknowledgement, with no later stop and no superseding generation, settles failed with a null fence, and the retry owners already decide from that fence.

Reported with the tally, without voiding anything. The brief and S2/S3/S4 quote `OPS-21` through "before the engine exits" and stop before ", for every operation kind, subject to the bounded abandonment, later-stop and superseded (`OPS-50`) exits below." The quoted span is exact. S1 and S3 state the bounds and the exits. Owner comment 194 is preserved from the ADR; its raw ticket text is not in this clone. The classification date in the brief is ADR-0046's 2026-10-23 alignment together with `OPS-21`, which matches the pin.

## Checks

Run: pin `cebdc4f8f728f40d7fdf3c10ed094a1a7d2b8527`, clean tree; `notes.md` whole; `CNF-312`; ADR-0032; the `OPS-41` model paragraph; `OPS-21`, `OPS-11`'s last row, `OPS-45`'s delete marker and recorded-failure paragraph, `OPS-48`'s failed row and null-fence gloss, `OPS-49`, `OPS-50`, `OPS-47`'s "The loss is not a later stop", `API-58`'s open-episode fan-out, `WIR-9a`'s `"cut_off"`, ADR-0046, the worker `execute` line; `failBeforeFence`, `finish`, `applyRow`, `episodeStep`, `interrupted_retry_prefix_witness`; Fence and StopRecord imports. S1 was diffed against the pin item: the declared selector edits are present, and the instrument lines match.

Not run: `tools/check-all.sh`, a Lean rebuild, the citation checker, any conformance fixture, any patch of the clone. Comment-only Lean edits do not change the executable text. No implementation and no further round.

The same text is in `r78b/grok.draft.md`.
